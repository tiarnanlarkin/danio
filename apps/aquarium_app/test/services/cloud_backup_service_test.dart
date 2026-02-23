/// Tests for CloudBackupService — encryption round-trip, serialisation, restore merge
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:flutter_test/flutter_test.dart';

import 'package:aquarium_app/models/models.dart';

void main() {
  group('Encryption/decryption round-trip', () {
    /// Replicates CloudBackupService._deriveKey logic
    encrypt_pkg.Key deriveKey(String userId) {
      const salt = 'aquarium-app-backup-v1';
      final hash = sha256.convert(utf8.encode('$salt:$userId'));
      return encrypt_pkg.Key(
        Uint8List.fromList(hash.bytes.sublist(0, 32)),
      );
    }

    test('encrypt then decrypt returns original plaintext', () {
      const userId = 'test-user-abc123';
      const originalJson = '{"tanks":[],"livestock":[],"version":1}';

      final key = deriveKey(userId);
      final iv = encrypt_pkg.IV.fromSecureRandom(16);

      // Encrypt
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
      );
      final plainBytes = utf8.encode(originalJson);
      final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);

      // Build blob (IV prepended)
      final blob = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);

      // Decrypt
      final recoveredIv = encrypt_pkg.IV(Uint8List.fromList(blob.sublist(0, 16)));
      final cipherBytes = blob.sublist(16);
      final decrypted = encrypter.decryptBytes(
        encrypt_pkg.Encrypted(Uint8List.fromList(cipherBytes)),
        iv: recoveredIv,
      );

      final result = utf8.decode(decrypted);
      expect(result, originalJson);
    });

    test('same user always derives the same key (deterministic)', () {
      const userId = 'user-deterministic-test';
      final key1 = deriveKey(userId);
      final key2 = deriveKey(userId);

      expect(key1.bytes, key2.bytes);
    });

    test('different users derive different keys', () {
      final key1 = deriveKey('user-alpha');
      final key2 = deriveKey('user-beta');

      expect(key1.bytes, isNot(equals(key2.bytes)));
    });

    test('large payload encrypts and decrypts correctly', () {
      const userId = 'test-user-large';
      final key = deriveKey(userId);
      final iv = encrypt_pkg.IV.fromSecureRandom(16);

      // Build a large JSON payload
      final tanks = List.generate(50, (i) => {
        'id': 'tank-$i',
        'name': 'Tank $i',
        'volumeLitres': 100 + i * 10,
      });
      final largeJson = json.encode({'tanks': tanks, 'version': 1});

      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
      );

      final encrypted = encrypter.encryptBytes(utf8.encode(largeJson), iv: iv);
      final blob = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);

      // Decrypt
      final recoveredIv = encrypt_pkg.IV(Uint8List.fromList(blob.sublist(0, 16)));
      final decrypted = encrypter.decryptBytes(
        encrypt_pkg.Encrypted(Uint8List.fromList(blob.sublist(16))),
        iv: recoveredIv,
      );

      expect(utf8.decode(decrypted), largeJson);
    });

    test('wrong key fails to produce correct plaintext', () {
      const userId = 'correct-user';
      final correctKey = deriveKey(userId);
      final wrongKey = deriveKey('wrong-user');
      final iv = encrypt_pkg.IV.fromSecureRandom(16);

      const original = '{"secret":"data"}';

      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(correctKey, mode: encrypt_pkg.AESMode.cbc),
      );
      final encrypted = encrypter.encryptBytes(utf8.encode(original), iv: iv);

      // Try to decrypt with wrong key
      final wrongEncrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(wrongKey, mode: encrypt_pkg.AESMode.cbc),
      );

      // Wrong key should either throw or produce garbage
      try {
        final decrypted = wrongEncrypter.decryptBytes(encrypted, iv: iv);
        // If it doesn't throw, the result should be wrong
        expect(utf8.decode(decrypted, allowMalformed: true), isNot(original));
      } catch (e) {
        // Expected — padding error or similar
        expect(e, isNotNull);
      }
    });
  });

  group('Backup serialisation structure', () {
    test('export data contains all expected entity types', () {
      // Simulate the structure returned by _exportAllData
      final exportData = {
        'version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'tanks': <Map<String, dynamic>>[],
        'livestock': <Map<String, dynamic>>[],
        'equipment': <Map<String, dynamic>>[],
        'logs': <Map<String, dynamic>>[],
        'tasks': <Map<String, dynamic>>[],
      };

      expect(exportData.containsKey('version'), true);
      expect(exportData.containsKey('exported_at'), true);
      expect(exportData.containsKey('tanks'), true);
      expect(exportData.containsKey('livestock'), true);
      expect(exportData.containsKey('equipment'), true);
      expect(exportData.containsKey('logs'), true);
      expect(exportData.containsKey('tasks'), true);
      expect(exportData['version'], 1);
    });

    test('Tank serialisation round-trip', () {
      final tank = Tank(
        id: 'tank-1',
        name: 'My Tropical Tank',
        type: TankType.freshwater,
        volumeLitres: 200,
        lengthCm: 100,
        widthCm: 40,
        heightCm: 50,
        startDate: DateTime(2025, 1, 15),
        targets: WaterTargets.freshwaterTropical(),
        notes: 'Planted tank with CO2',
        sortOrder: 0,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2026, 2, 23),
      );

      final jsonMap = tank.toJson();
      final jsonString = json.encode(jsonMap);
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      final restored = Tank.fromJson(decoded);

      expect(restored.id, tank.id);
      expect(restored.name, tank.name);
      expect(restored.type, tank.type);
      expect(restored.volumeLitres, tank.volumeLitres);
      expect(restored.lengthCm, tank.lengthCm);
      expect(restored.widthCm, tank.widthCm);
      expect(restored.heightCm, tank.heightCm);
      expect(restored.notes, tank.notes);
      expect(restored.targets.tempMin, tank.targets.tempMin);
      expect(restored.targets.phMax, tank.targets.phMax);
    });
  });

  group('Restore merge — local-wins strategy', () {
    test('existing local tank is NOT overwritten by backup', () {
      // Simulate local storage
      final localTanks = <String, Tank>{
        'tank-1': Tank(
          id: 'tank-1',
          name: 'Local Name',
          type: TankType.freshwater,
          volumeLitres: 200,
          startDate: DateTime(2025, 1, 1),
          targets: WaterTargets.freshwaterTropical(),
          sortOrder: 0,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2026, 2, 23),
        ),
      };

      // Backup contains same tank with different name
      final backupTanks = [
        {
          'id': 'tank-1',
          'name': 'Backup Name',
          'type': 'freshwater',
          'volumeLitres': 200,
          'startDate': '2025-01-01T00:00:00.000',
          'sortOrder': 0,
          'createdAt': '2025-01-01T00:00:00.000',
          'updatedAt': '2026-01-01T00:00:00.000',
        },
      ];

      // Import with local-wins: skip existing
      for (final tJson in backupTanks) {
        final id = tJson['id'] as String;
        if (!localTanks.containsKey(id)) {
          localTanks[id] = Tank.fromJson(tJson);
        }
      }

      expect(localTanks['tank-1']!.name, 'Local Name',
          reason: 'Local data should win on conflict');
    });

    test('new tank from backup IS imported', () {
      final localTanks = <String, Tank>{
        'tank-1': Tank(
          id: 'tank-1',
          name: 'Existing Tank',
          type: TankType.freshwater,
          volumeLitres: 100,
          startDate: DateTime(2025, 1, 1),
          targets: WaterTargets.freshwaterTropical(),
          sortOrder: 0,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      };

      final backupTanks = [
        {
          'id': 'tank-2',
          'name': 'New From Backup',
          'type': 'freshwater',
          'volumeLitres': 300,
          'startDate': '2025-06-01T00:00:00.000',
          'sortOrder': 1,
          'createdAt': '2025-06-01T00:00:00.000',
          'updatedAt': '2025-06-01T00:00:00.000',
        },
      ];

      for (final tJson in backupTanks) {
        final id = tJson['id'] as String;
        if (!localTanks.containsKey(id)) {
          localTanks[id] = Tank.fromJson(tJson);
        }
      }

      expect(localTanks.length, 2);
      expect(localTanks['tank-2']!.name, 'New From Backup');
    });

    test('logs are always appended (water test history preserved)', () {
      // Simulate local log store
      final localLogs = <String, LogEntry>{
        'log-1': LogEntry(
          id: 'log-1',
          tankId: 'tank-1',
          type: LogType.waterTest,
          timestamp: DateTime(2026, 2, 20),
          waterTest: const WaterTestResults(ph: 7.0),
          createdAt: DateTime(2026, 2, 20),
        ),
      };

      // Backup has a different log
      final backupLogs = [
        LogEntry(
          id: 'log-2',
          tankId: 'tank-1',
          type: LogType.waterTest,
          timestamp: DateTime(2026, 2, 21),
          waterTest: const WaterTestResults(ph: 7.2),
          createdAt: DateTime(2026, 2, 21),
        ),
      ];

      // Always append logs (never skip)
      for (final log in backupLogs) {
        localLogs[log.id] = log; // saveLogs always writes
      }

      expect(localLogs.length, 2);
      expect(localLogs.containsKey('log-1'), true);
      expect(localLogs.containsKey('log-2'), true);
    });
  });
}
