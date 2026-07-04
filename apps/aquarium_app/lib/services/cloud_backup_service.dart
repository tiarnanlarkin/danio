import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

import '../models/models.dart';
import 'local_json_storage_service.dart';
import 'shared_preferences_backup.dart';
import 'storage_service.dart';
import 'supabase_service.dart';
import '../utils/logger.dart';

/// Account-keyed cloud backup service.
///
/// The optional cloud lane serialises local data, encrypts the backup blob with
/// AES-256 using a key derived from the signed-in Supabase user id and app salt,
/// and uploads it to Supabase Storage. This avoids plaintext backup blobs, but
/// it is not user-held or end-to-end backup encryption.
///
/// Restore flow: download -> decrypt -> merge with local (local wins on
/// conflict).
class CloudBackupService {
  CloudBackupService._();
  static final CloudBackupService instance = CloudBackupService._();

  static const String _bucketName = 'user-backups';
  static const int _keyLength = 32; // AES-256

  Future<Map<String, dynamic>> exportAllDataForTesting(StorageService storage) {
    return _exportAllData(storage);
  }

  Future<CloudBackupRestoreResult> importDataForTesting(
    StorageService storage,
    Map<String, dynamic> data,
  ) {
    return _importData(storage, data);
  }

  // ---------------------------------------------------------------------------
  // Backup: serialise -> encrypt -> upload
  // ---------------------------------------------------------------------------

  /// Create an account-keyed backup of all local data and upload to Supabase.
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

    // 3. Derive the account-scoped encryption key from userId (deterministic)
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
    await SupabaseService.instance.storage
        .from(_bucketName)
        .uploadBinary(path, blob, fileOptions: const FileOptions(upsert: true));

    appLog(
      '[CloudBackup] Uploaded ${blob.length} bytes -> $path',
      tag: 'CloudBackupService',
    );
  }

  // ---------------------------------------------------------------------------
  // Restore: download -> decrypt -> merge
  // ---------------------------------------------------------------------------

  /// Download the account-keyed backup and merge into local storage.
  ///
  /// Merge strategy: local data wins on conflict (based on id).
  Future<CloudBackupRestoreResult> downloadAndRestoreBackup() async {
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
    final result = await _importData(LocalJsonStorageService(), data);

    appLog(
      '[CloudBackup] Restored backup from $path',
      tag: 'CloudBackupService',
    );
    return result;
  }

  // ---------------------------------------------------------------------------
  // Data export (uses public StorageService API)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _exportAllData(StorageService storage) async {
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

      allLivestock.addAll(livestock.map((l) => l.toJson()));
      allEquipment.addAll(equipment.map((e) => e.toJson()));
      allLogs.addAll(logs.map((l) => l.toJson()));
      allTasks.addAll(tasks.map((t) => t.toJson()));
    }

    final prefsBackupJson = await SharedPreferencesBackup.exportAsJson();
    final prefsBackupData = jsonDecode(prefsBackupJson) as Map<String, dynamic>;

    return {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'tanks': tanks.map((t) => t.toJson()).toList(),
      'livestock': allLivestock,
      'equipment': allEquipment,
      'logs': allLogs,
      'tasks': allTasks,
      'sharedPreferences': prefsBackupData,
    };
  }

  // ---------------------------------------------------------------------------
  // Data import (local wins on conflict)
  // ---------------------------------------------------------------------------

  Future<CloudBackupRestoreResult> _importData(
    StorageService storage,
    Map<String, dynamic> data,
  ) async {
    final changedTankIds = <String>{};
    final knownTankIds = {
      for (final tank in await storage.getAllTanks()) tank.id,
    };
    var preferenceEntriesRestored = 0;
    var preferencesRestoreFailed = false;

    // Import tanks - skip if already exists locally (local wins)
    for (final map in _backupRecordMaps(data, 'tanks')) {
      final id = map['id'];
      if (id is! String || id.isEmpty) {
        continue;
      }
      final existing = await storage.getTank(id);
      if (existing == null) {
        final tank = _parseBackupRecord(() => Tank.fromJson(map));
        if (tank == null) {
          continue;
        }
        await storage.saveTank(tank);
        knownTankIds.add(tank.id);
        changedTankIds.add(tank.id);
      }
    }

    // Import livestock - skip existing ids (local wins)
    for (final map in _backupRecordMaps(data, 'livestock')) {
      final livestock = _parseBackupRecord(() => Livestock.fromJson(map));
      if (livestock == null) {
        continue;
      }
      if (!knownTankIds.contains(livestock.tankId)) {
        continue;
      }
      if (await _livestockExists(storage, livestock.tankId, livestock.id)) {
        continue;
      }
      await storage.saveLivestock(livestock);
      changedTankIds.add(livestock.tankId);
    }

    // Import equipment - skip existing ids (local wins)
    for (final map in _backupRecordMaps(data, 'equipment')) {
      final equipment = _parseBackupRecord(() => Equipment.fromJson(map));
      if (equipment == null) {
        continue;
      }
      if (!knownTankIds.contains(equipment.tankId)) {
        continue;
      }
      if (await _equipmentExists(storage, equipment.tankId, equipment.id)) {
        continue;
      }
      await storage.saveEquipment(equipment);
      changedTankIds.add(equipment.tankId);
    }

    // Import logs (append missing entries only - same ids stay local)
    for (final map in _backupRecordMaps(data, 'logs')) {
      final log = _parseBackupRecord(() => LogEntry.fromJson(map));
      if (log == null) {
        continue;
      }
      if (!knownTankIds.contains(log.tankId)) {
        continue;
      }
      if (await _logExists(storage, log.tankId, log.id)) {
        continue;
      }
      await storage.saveLog(log);
      changedTankIds.add(log.tankId);
    }

    // Import tasks - skip existing ids (local wins)
    for (final map in _backupRecordMaps(data, 'tasks')) {
      final task = _parseBackupRecord(() => Task.fromJson(map));
      if (task == null) {
        continue;
      }
      final tankId = task.tankId;
      if (tankId != null && !knownTankIds.contains(tankId)) {
        continue;
      }
      if (await _taskExists(storage, task.tankId, task.id)) {
        continue;
      }
      await storage.saveTask(task);
      if (tankId != null) changedTankIds.add(tankId);
    }

    final prefsData = data['sharedPreferences'];
    if (prefsData != null && prefsData is Map<String, dynamic>) {
      try {
        preferenceEntriesRestored =
            await SharedPreferencesBackup.restoreFromJson(prefsData);
      } catch (e) {
        preferencesRestoreFailed = true;
        logError(
          '[CloudBackup] SharedPreferences restore warning: $e',
          tag: 'CloudBackupService',
        );
      }
    } else if (prefsData != null) {
      preferencesRestoreFailed = true;
      appLog(
        '[CloudBackup] SharedPreferences restore warning: invalid preferences payload',
        tag: 'CloudBackupService',
      );
    }

    return CloudBackupRestoreResult(
      changedTankIds: changedTankIds,
      preferenceEntriesRestored: preferenceEntriesRestored,
      preferencesRestoreFailed: preferencesRestoreFailed,
    );
  }

  Iterable<Map<String, dynamic>> _backupRecordMaps(
    Map<String, dynamic> data,
    String collectionName,
  ) sync* {
    final records = data[collectionName];
    if (records is! List) {
      return;
    }

    for (final record in records) {
      if (record is Map<String, dynamic>) {
        yield record;
      } else if (record is Map) {
        try {
          yield Map<String, dynamic>.from(record);
        } catch (_) {
          continue;
        }
      }
    }
  }

  T? _parseBackupRecord<T>(T Function() parse) {
    try {
      return parse();
    } catch (_) {
      return null;
    }
  }

  Future<bool> _livestockExists(
    StorageService storage,
    String tankId,
    String id,
  ) async {
    final items = await storage.getLivestockForTank(tankId);
    return items.any((item) => item.id == id);
  }

  Future<bool> _equipmentExists(
    StorageService storage,
    String tankId,
    String id,
  ) async {
    final items = await storage.getEquipmentForTank(tankId);
    return items.any((item) => item.id == id);
  }

  Future<bool> _logExists(
    StorageService storage,
    String tankId,
    String id,
  ) async {
    final items = await storage.getLogsForTank(tankId);
    return items.any((item) => item.id == id);
  }

  Future<bool> _taskExists(
    StorageService storage,
    String? tankId,
    String id,
  ) async {
    final items = await storage.getTasksForTank(tankId);
    return items.any((item) => item.id == id);
  }

  // ---------------------------------------------------------------------------
  // Key derivation
  // ---------------------------------------------------------------------------

  /// Derive an AES-256 key from the account id using SHA-256.
  ///
  /// This deterministic account key lets the same signed-in cloud account
  /// restore across devices. A future user-held recovery-key design would need a
  /// migration and a clear recovery UX before the product could claim
  /// end-to-end backup encryption.
  encrypt_pkg.Key _deriveKey(String userId) {
    const salt = 'aquarium-app-backup-v1';
    final hash = sha256.convert(utf8.encode('$salt:$userId'));
    return encrypt_pkg.Key(
      Uint8List.fromList(hash.bytes.sublist(0, _keyLength)),
    );
  }
}

class CloudBackupRestoreResult {
  final Set<String> changedTankIds;
  final int preferenceEntriesRestored;
  final bool preferencesRestoreFailed;

  const CloudBackupRestoreResult({
    required this.changedTankIds,
    required this.preferenceEntriesRestored,
    required this.preferencesRestoreFailed,
  });

  bool get restoredPreferences => preferenceEntriesRestored > 0;
}
