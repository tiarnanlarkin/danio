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
/// 8. Save-read round-trip — multiple entity types
/// 9. Large dataset stress (50 tanks)
///
/// Implementation note: LocalJsonStorageService is a singleton.
/// To force a re-read of a file we just wrote, we call retryLoad()
/// (which resets internal state to idle and re-reads from disk).
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

  // Mock path_provider so LocalJsonStorageService writes to a temp dir.
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  const pathProviderFoundationChannel =
      MethodChannel('plugins.flutter.io/path_provider_foundation');

  late Directory testDir;
  late File dataFile;

  setUpAll(() async {
    testDir = await Directory.systemTemp.createTemp('storage_stress_');
    dataFile = File(p.join(testDir.path, 'aquarium_data.json'));

    for (final ch in [pathProviderChannel, pathProviderFoundationChannel]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ch, (_) async => testDir.path);
    }
  });

  tearDownAll(() async {
    try {
      await testDir.delete(recursive: true);
    } catch (_) {}
  });

  /// Wipe the data file + backup files; reset singleton to loaded/empty.
  Future<void> freshStart(LocalJsonStorageService s) async {
    await s.clearAllData(); // deletes file, clears in-memory, sets state=loaded
    // Delete any backup files left by previous runs.
    await for (final f in testDir.list()) {
      if (f.path.contains('.corrupted') || f.path.endsWith('.tmp')) {
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
      await freshStart(storage);
    });

    // ── 1. Corrupted JSON ─────────────────────────────────────────────────
    // After clearAllData() the singleton is in 'loaded' state.
    // To make it re-read the file we wrote, call retryLoad() which
    // resets internal state to idle and does a fresh disk read.

    test('1a. Malformed JSON → corrupted state + backup file created',
        () async {
      await dataFile.writeAsString('{ "version": 1, INVALID }');

      // retryLoad() forces re-read from disk → should detect corruption.
      await expectLater(
        storage.retryLoad(),
        throwsA(isA<StorageCorruptionException>()),
      );

      expect(storage.state, equals(StorageState.corrupted));
      expect(storage.hasError, isTrue);

      final backupFiles = await testDir
          .list()
          .where((f) => f.path.contains('.corrupted'))
          .toList();
      expect(backupFiles, isNotEmpty, reason: 'Backup file must be created');
    });

    test('1b. Non-object root JSON (array) → StorageCorruptionException',
        () async {
      await dataFile.writeAsString('["array", "not", "object"]');

      await expectLater(
        storage.retryLoad(),
        throwsA(isA<StorageCorruptionException>()),
      );
      expect(storage.state, equals(StorageState.corrupted));
    });

    // ── 2. Empty / Missing file ───────────────────────────────────────────

    test('2a. Empty file → fresh start, healthy state', () async {
      await dataFile.writeAsString('');
      await storage.retryLoad();

      expect(storage.state, equals(StorageState.loaded));
      expect(storage.hasError, isFalse);
      final tanks = await storage.getAllTanks();
      expect(tanks, isEmpty);
    });

    test('2b. Missing file → fresh start, healthy state', () async {
      if (await dataFile.exists()) await dataFile.delete();
      await storage.retryLoad();

      expect(storage.state, equals(StorageState.loaded));
      expect(storage.hasError, isFalse);
      final tanks = await storage.getAllTanks();
      expect(tanks, isEmpty);
    });

    // ── 3. Partial corruption ─────────────────────────────────────────────

    test('3. Partial corruption → valid entity loaded, bad one skipped',
        () async {
      final json = jsonEncode({
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
          // tank-bad is missing all required fields → will be skipped
          'tank-bad': {'id': 'tank-bad'},
        },
        'livestock': {},
        'equipment': {},
        'logs': {},
        'tasks': {},
      });

      await dataFile.writeAsString(json);
      await storage.retryLoad();

      final tanks = await storage.getAllTanks();
      expect(tanks.length, equals(1));
      expect(tanks.first.id, equals('tank-ok'));
      expect(storage.state, equals(StorageState.loaded));
    });

    // ── 4. Mass corruption → throws ───────────────────────────────────────

    test('4. >10 corrupted entities → StorageCorruptionException', () async {
      final badTanks = <String, dynamic>{};
      for (var i = 0; i < 15; i++) {
        badTanks['tank-$i'] = {'id': 'tank-$i'}; // missing all required fields
      }

      await dataFile.writeAsString(jsonEncode({
        'version': 1,
        'tanks': badTanks,
        'livestock': {},
        'equipment': {},
        'logs': {},
        'tasks': {},
      }));

      await expectLater(
        storage.retryLoad(),
        throwsA(isA<StorageCorruptionException>()),
      );
      expect(storage.state, equals(StorageState.corrupted));
    });

    // ── 5. clearAllData() ─────────────────────────────────────────────────

    test('5. clearAllData() resets corrupted service to healthy state',
        () async {
      // Induce corruption
      await dataFile.writeAsString('bad json!');
      await expectLater(
        storage.retryLoad(),
        throwsA(isA<StorageCorruptionException>()),
      );
      expect(storage.hasError, isTrue);

      await storage.clearAllData();

      expect(storage.state, equals(StorageState.loaded));
      expect(storage.lastError, isNull);
      expect(storage.hasError, isFalse);
      expect(await dataFile.exists(), isFalse);
    });

    // ── 6. recoverFromCorruption() ────────────────────────────────────────

    test('6. recoverFromCorruption() → healthy state, can save new data',
        () async {
      await dataFile.writeAsString('totally broken');
      await expectLater(
        storage.retryLoad(),
        throwsA(isA<StorageCorruptionException>()),
      );
      expect(storage.hasError, isTrue);

      await storage.recoverFromCorruption();

      expect(storage.state, equals(StorageState.loaded));
      expect(storage.hasError, isFalse);
      expect(await dataFile.exists(), isFalse);

      // App should be able to save new data immediately after recovery.
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

      // Force a full reload from disk.
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

    test('8. 50 tanks save, reload and delete correctly (stress)', () async {
      for (var i = 0; i < 50; i++) {
        await storage.saveTank(_makeTank('tank-$i', volume: 50.0 + i));
      }

      var tanks = await storage.getAllTanks();
      expect(tanks.length, equals(50));

      await storage.retryLoad();
      tanks = await storage.getAllTanks();
      expect(tanks.length, equals(50));

      await storage.deleteTank('tank-0');
      tanks = await storage.getAllTanks();
      expect(tanks.length, equals(49));
    });
  });
}
