import 'dart:convert';
import 'dart:io';

import 'package:aquarium_app/models/models.dart';
import 'package:aquarium_app/services/local_json_storage_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Phase 5.2 — Storage Stress Tests
///
/// Tests cover:
/// 1. Corrupted JSON file → error state, backup created, no crash
/// 2. Empty file → fresh start
/// 3. Missing file → fresh start
/// 4. Partial corruption → valid entities loaded, bad ones skipped
/// 5. Too many corrupted entities → corruption exception
/// 6. clearAllData() → resets to healthy state
/// 7. recoverFromCorruption() → deletes corrupted file, app continues
/// 8. Large dataset → saves and reloads correctly (stress)
///
/// Run: flutter test test/storage_stress_test.dart

Tank _makeTank(String id, {double volume = 100.0}) => Tank(
      id: id,
      name: 'Tank $id',
      type: TankType.freshwater,
      volumeLitres: volume,
      startDate: DateTime(2024, 1, 1),
      targets: WaterTargets.freshwaterTropical(),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider so LocalJsonStorageService writes to a temp dir in tests.
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  const pathProviderMethodChannel =
      MethodChannel('plugins.flutter.io/path_provider_foundation');

  late Directory testDir;
  late File dataFile;

  setUpAll(() async {
    testDir = await Directory.systemTemp.createTemp('storage_stress_');
    dataFile = File(p.join(testDir.path, 'aquarium_data.json'));

    // Register mock for both old and new path_provider channel names.
    for (final channel in [pathProviderChannel, pathProviderMethodChannel]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        return testDir.path;
      });
    }
  });

  tearDownAll(() async {
    try {
      await testDir.delete(recursive: true);
    } catch (_) {}
  });

  /// Reset storage singleton state between tests.
  Future<void> resetStorage(LocalJsonStorageService s) async {
    await s.clearAllData();
    // Delete the data file so each test starts truly fresh.
    if (await dataFile.exists()) await dataFile.delete();
    // Also remove any backup files.
    await for (final f in testDir.list()) {
      if (f.path.contains('.corrupted')) {
        try {
          await (f as File).delete();
        } catch (_) {}
      }
    }
  }

  group('Phase 5.2 — Storage Error Handling', () {
    late LocalJsonStorageService storage;

    setUp(() async {
      storage = LocalJsonStorageService();
      await resetStorage(storage);
    });

    // ── 1. Corrupted JSON ─────────────────────────────────────────────────

    test('1a. Malformed JSON sets corrupted state and creates backup', () async {
      await dataFile.writeAsString('{ "version": 1, INVALID }');

      expect(
        () => storage.getAllTanks(),
        throwsA(isA<StorageCorruptionException>()),
      );
      await Future.delayed(Duration.zero); // allow async ops to settle

      // State should be corrupted
      expect(storage.state, equals(StorageState.corrupted));
      expect(storage.hasError, isTrue);
      expect(storage.lastError, isNotNull);

      // A backup file should have been created
      final backupFiles =
          await testDir.list().where((f) => f.path.contains('.corrupted')).toList();
      expect(backupFiles, isNotEmpty, reason: 'Backup file should be created');
    });

    test('1b. Non-object root JSON (array) throws corruption exception',
        () async {
      await dataFile.writeAsString('["array", "not", "object"]');

      expect(
        () => storage.getAllTanks(),
        throwsA(isA<StorageCorruptionException>()),
      );
    });

    // ── 2. Empty / Missing file ───────────────────────────────────────────

    test('2a. Empty file → fresh start, healthy state', () async {
      await dataFile.writeAsString('');

      final tanks = await storage.getAllTanks();
      expect(tanks, isEmpty);
      expect(storage.state, equals(StorageState.loaded));
      expect(storage.hasError, isFalse);
    });

    test('2b. Missing file → fresh start, healthy state', () async {
      // Ensure file doesn't exist
      if (await dataFile.exists()) await dataFile.delete();

      final tanks = await storage.getAllTanks();
      expect(tanks, isEmpty);
      expect(storage.state, equals(StorageState.loaded));
      expect(storage.hasError, isFalse);
    });

    // ── 3. Partial corruption ─────────────────────────────────────────────

    test('3. Partial corruption → valid entities loaded, bad ones skipped',
        () async {
      final validJson = jsonEncode({
        'version': 1,
        'updatedAt': DateTime.now().toIso8601String(),
        'tanks': {
          'tank-ok': {
            'id': 'tank-ok',
            'name': 'Good Tank',
            'type': 'freshwater',
            'volumeLitres': 100.0,
            'startDate': '2024-01-01T00:00:00.000Z',
            'targets': {
              'tempMin': 22.0,
              'tempMax': 28.0,
              'phMin': 6.5,
              'phMax': 7.5,
            },
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          },
          'tank-bad': {
            'id': 'tank-bad',
            // Missing name, type, volumeLitres, startDate → will throw during parse
          },
        },
        'livestock': {},
        'equipment': {},
        'logs': {},
        'tasks': {},
      });

      await dataFile.writeAsString(validJson);
      final tanks = await storage.getAllTanks();

      // Only the valid tank should be loaded
      expect(tanks.length, equals(1));
      expect(tanks.first.id, equals('tank-ok'));
      expect(storage.state, equals(StorageState.loaded));
    });

    // ── 4. Mass corruption → throws ───────────────────────────────────────

    test('4. >10 corrupted entities triggers corruption exception', () async {
      // Build 15 corrupt tank entries (no required fields)
      final badTanks = <String, dynamic>{};
      for (var i = 0; i < 15; i++) {
        badTanks['tank-$i'] = {'id': 'tank-$i'}; // missing all required fields
      }

      final corruptData = jsonEncode({
        'version': 1,
        'tanks': badTanks,
        'livestock': {},
        'equipment': {},
        'logs': {},
        'tasks': {},
      });

      await dataFile.writeAsString(corruptData);

      expect(
        () => storage.getAllTanks(),
        throwsA(isA<StorageCorruptionException>()),
      );
    });

    // ── 5. clearAllData() ─────────────────────────────────────────────────

    test('5. clearAllData() resets corrupted service to healthy state',
        () async {
      // Induce corruption
      await dataFile.writeAsString('bad json!');

      try {
        await storage.getAllTanks();
      } catch (_) {}

      expect(storage.hasError, isTrue);

      await storage.clearAllData();

      expect(storage.state, equals(StorageState.loaded));
      expect(storage.lastError, isNull);
      expect(storage.hasError, isFalse);
      expect(await dataFile.exists(), isFalse);
    });

    // ── 6. recoverFromCorruption() ────────────────────────────────────────

    test('6. recoverFromCorruption() allows app to continue with empty data',
        () async {
      await dataFile.writeAsString('totally broken');

      try {
        await storage.getAllTanks();
      } catch (_) {}

      expect(storage.hasError, isTrue);

      await storage.recoverFromCorruption();

      expect(storage.state, equals(StorageState.loaded));
      expect(storage.hasError, isFalse);

      // Can now save new data
      await storage.saveTank(_makeTank('recovery-tank'));
      final tanks = await storage.getAllTanks();
      expect(tanks.length, equals(1));
      expect(tanks.first.id, equals('recovery-tank'));
    });

    // ── 7. Save-read round-trip ───────────────────────────────────────────

    test('7. Save and reload multiple entity types without data loss',
        () async {
      final tank = _makeTank('t1');
      final livestock = Livestock(
        id: 'fish-1',
        tankId: 't1',
        commonName: 'Neon Tetra',
        count: 5,
        dateAdded: DateTime(2024, 3, 1),
        createdAt: DateTime(2024, 3, 1),
        updatedAt: DateTime(2024, 3, 1),
      );
      final equipment = Equipment(
        id: 'eq-1',
        tankId: 't1',
        type: EquipmentType.filter,
        name: 'Fluval 307',
        createdAt: DateTime(2024, 3, 1),
        updatedAt: DateTime(2024, 3, 1),
      );

      await storage.saveTank(tank);
      await storage.saveLivestock(livestock);
      await storage.saveEquipment(equipment);

      // Simulate reload by resetting loaded state
      await storage.retryLoad();

      final tanks = await storage.getAllTanks();
      final fish = await storage.getLivestockForTank('t1');
      final equip = await storage.getEquipmentForTank('t1');

      expect(tanks.length, equals(1));
      expect(tanks.first.name, equals('Tank t1'));
      expect(fish.length, equals(1));
      expect(fish.first.commonName, equals('Neon Tetra'));
      expect(equip.length, equals(1));
      expect(equip.first.name, equals('Fluval 307'));
    });

    // ── 8. Large dataset stress ───────────────────────────────────────────

    test('8. Large dataset (50 tanks) saves and reloads without loss',
        () async {
      // Save 50 tanks
      for (var i = 0; i < 50; i++) {
        await storage.saveTank(_makeTank('tank-$i', volume: 50.0 + i));
      }

      // Verify all saved
      var tanks = await storage.getAllTanks();
      expect(tanks.length, equals(50));

      // Reload and verify again
      await storage.retryLoad();
      tanks = await storage.getAllTanks();
      expect(tanks.length, equals(50));

      // Delete one and verify count
      await storage.deleteTank('tank-0');
      tanks = await storage.getAllTanks();
      expect(tanks.length, equals(49));
    });
  });
}
