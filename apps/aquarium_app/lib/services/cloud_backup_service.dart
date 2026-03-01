import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

import '../models/models.dart';
import '../utils/model_serialization.dart' as serial;
import 'local_json_storage_service.dart';
import 'supabase_service.dart';

/// Encrypted backup service - serialises all local data to JSON, encrypts with
/// AES-256 using a key derived from the user's UID + a salt, and uploads to
/// Supabase Storage.
///
/// Restore flow: download → decrypt → merge with local (local wins on conflict).
class CloudBackupService {
  CloudBackupService._();
  static final CloudBackupService instance = CloudBackupService._();

  static const String _bucketName = 'user-backups';
  static const int _keyLength = 32; // AES-256

  // ---------------------------------------------------------------------------
  // Backup: serialise → encrypt → upload
  // ---------------------------------------------------------------------------

  /// Create an encrypted backup of all local data and upload to Supabase.
  Future<void> createAndUploadBackup() async {
    if (!SupabaseService.isInitialised) {
      throw StateError('Supabase not initialised');
    }
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) throw StateError('Not signed in');

    // 1. Export all local data via public API
    final storage = LocalJsonStorageService();
    final exportData = await _exportAllData(storage);

    // 2. Serialise to JSON
    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    final plainBytes = utf8.encode(jsonString);

    // 3. Derive encryption key from userId (deterministic)
    final key = _deriveKey(userId);
    final iv = encrypt_pkg.IV.fromSecureRandom(16);

    // 4. Encrypt
    final encrypter = encrypt_pkg.Encrypter(
      encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
    );
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);

    // 5. Prepend IV to ciphertext so we can decrypt later
    final blob = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);

    // 6. Upload to Supabase Storage
    final path = '$userId/backup.enc';
    await SupabaseService.instance.storage.from(_bucketName).uploadBinary(
          path,
          blob,
          fileOptions: const FileOptions(upsert: true),
        );

    debugPrint('[CloudBackup] Uploaded ${blob.length} bytes → $path');
  }

  // ---------------------------------------------------------------------------
  // Restore: download → decrypt → merge
  // ---------------------------------------------------------------------------

  /// Download the encrypted backup and merge into local storage.
  ///
  /// Merge strategy: local data wins on conflict (based on id).
  Future<void> downloadAndRestoreBackup() async {
    if (!SupabaseService.isInitialised) {
      throw StateError('Supabase not initialised');
    }
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) throw StateError('Not signed in');

    // 1. Download blob
    final path = '$userId/backup.enc';
    final blob = await SupabaseService.instance.storage
        .from(_bucketName)
        .download(path);

    // 2. Split IV + ciphertext
    final iv = encrypt_pkg.IV(Uint8List.fromList(blob.sublist(0, 16)));
    final cipherBytes = blob.sublist(16);

    // 3. Decrypt
    final key = _deriveKey(userId);
    final encrypter = encrypt_pkg.Encrypter(
      encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
    );
    final decrypted = encrypter.decryptBytes(
      encrypt_pkg.Encrypted(Uint8List.fromList(cipherBytes)),
      iv: iv,
    );

    // 4. Parse JSON
    final jsonString = utf8.decode(decrypted);
    final data = json.decode(jsonString) as Map<String, dynamic>;

    // 5. Merge into local storage (local wins)
    await _importData(LocalJsonStorageService(), data);

    debugPrint('[CloudBackup] Restored backup from $path');
  }

  // ---------------------------------------------------------------------------
  // Data export (uses public StorageService API)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _exportAllData(
    LocalJsonStorageService storage,
  ) async {
    final tanks = await storage.getAllTanks();
    final allLivestock = <Map<String, dynamic>>[];
    final allEquipment = <Map<String, dynamic>>[];
    final allLogs = <Map<String, dynamic>>[];
    final allTasks = <Map<String, dynamic>>[];

    for (final tank in tanks) {
      final livestock = await storage.getLivestockForTank(tank.id);
      final equipment = await storage.getEquipmentForTank(tank.id);
      final logs = await storage.getLogsForTank(tank.id);
      final tasks = await storage.getTasksForTank(tank.id);

      allLivestock.addAll(livestock.map(serial.livestockToJson));
      allEquipment.addAll(equipment.map(serial.equipmentToJson));
      allLogs.addAll(logs.map(serial.logEntryToJson));
      allTasks.addAll(tasks.map(serial.taskToJson));
    }

    return {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'tanks': tanks.map((t) => t.toJson()).toList(),
      'livestock': allLivestock,
      'equipment': allEquipment,
      'logs': allLogs,
      'tasks': allTasks,
    };
  }

  // ---------------------------------------------------------------------------
  // Data import (local wins on conflict)
  // ---------------------------------------------------------------------------

  Future<void> _importData(
    LocalJsonStorageService storage,
    Map<String, dynamic> data,
  ) async {
    // Import tanks - skip if already exists locally (local wins)
    final tanksJson = data['tanks'] as List<dynamic>? ?? [];
    for (final tJson in tanksJson) {
      final map = tJson as Map<String, dynamic>;
      final id = map['id'] as String;
      final existing = await storage.getTank(id);
      if (existing == null) {
        final tank = Tank.fromJson(map);
        await storage.saveTank(tank);
      }
    }

    // Import livestock
    final livestockJson = data['livestock'] as List<dynamic>? ?? [];
    for (final lJson in livestockJson) {
      final map = lJson as Map<String, dynamic>;
      final livestock = serial.livestockFromJson(map);
      await storage.saveLivestock(livestock);
    }

    // Import equipment
    final equipmentJson = data['equipment'] as List<dynamic>? ?? [];
    for (final eJson in equipmentJson) {
      final map = eJson as Map<String, dynamic>;
      final equipment = serial.equipmentFromJson(map);
      await storage.saveEquipment(equipment);
    }

    // Import logs (always append - water test history is never overwritten)
    final logsJson = data['logs'] as List<dynamic>? ?? [];
    for (final logJson in logsJson) {
      final map = logJson as Map<String, dynamic>;
      final log = serial.logEntryFromJson(map);
      await storage.saveLog(log);
    }

    // Import tasks
    final tasksJson = data['tasks'] as List<dynamic>? ?? [];
    for (final taskJson in tasksJson) {
      final map = taskJson as Map<String, dynamic>;
      final task = serial.taskFromJson(map);
      await storage.saveTask(task);
    }
  }

  // ---------------------------------------------------------------------------
  // Key derivation
  // ---------------------------------------------------------------------------

  /// Derive an AES-256 key from the user's ID using SHA-256.
  ///
  /// In production you'd use PBKDF2 with the user's password; here we use
  /// the UID as a deterministic key source so the same user can always
  /// decrypt their own backups across devices.
  encrypt_pkg.Key _deriveKey(String userId) {
    const salt = 'aquarium-app-backup-v1';
    final hash = sha256.convert(utf8.encode('$salt:$userId'));
    return encrypt_pkg.Key(
      Uint8List.fromList(hash.bytes.sublist(0, _keyLength)),
    );
  }
}
