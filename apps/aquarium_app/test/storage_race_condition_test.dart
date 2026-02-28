import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:aquarium_app/models/models.dart';
import 'package:aquarium_app/services/local_json_storage_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test to verify P0-1 fix: Race condition in concurrent saves
/// 
/// This test rapidly saves multiple tanks concurrently to verify
/// that the Lock in _persist() prevents data corruption.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // LocalJsonStorageService uses path_provider via MethodChannel. In tests we
  // mock it to avoid platform channel failures.
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late final Directory testDocsDir;

  setUpAll(() async {
    testDocsDir = await Directory.systemTemp.createTemp('aquarium_test_docs_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'getApplicationDocumentsDirectory':
        case 'getTemporaryDirectory':
        case 'getApplicationSupportDirectory':
        case 'getLibraryDirectory':
          return testDocsDir.path;
        default:
          return testDocsDir.path;
      }
    });
  });

  tearDownAll(() async {
    try {
      await testDocsDir.delete(recursive: true);
    } catch (_) {
      // ignore
    }
  });

  group('Storage Race Condition Tests', () {
    late LocalJsonStorageService storage;

    setUp(() async {
      storage = LocalJsonStorageService();
      await storage.clearAllData();
    });

    test('P0-1: Concurrent saves should not corrupt data', () async {
      // Create test tanks
      final tanks = List.generate(10, (i) {
        return Tank(
          id: 'tank_$i',
          name: 'Test Tank $i',
          type: TankType.freshwater,
          volumeLitres: 100.0 + i,
          startDate: DateTime.now(),
          targets: WaterTargets.freshwaterTropical(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      // Perform rapid concurrent saves
      final futures = <Future<void>>[];
      for (var tank in tanks) {
        futures.add(storage.saveTank(tank));
      }

      // Wait for all saves to complete
      await Future.wait(futures);

      // Verify all tanks were saved correctly
      final savedTanks = await storage.getAllTanks();
      expect(savedTanks.length, equals(10));

      // Verify each tank exists with correct data
      for (var i = 0; i < 10; i++) {
        final tank = await storage.getTank('tank_$i');
        expect(tank, isNotNull);
        expect(tank!.name, equals('Test Tank $i'));
        expect(tank.volumeLitres, equals(100.0 + i));
      }

      debugPrint('✅ P0-1 Test passed: All 10 concurrent saves completed without corruption');
    });

    test('P0-1: Rapid sequential saves should maintain data integrity', () async {
      // Create a single tank and update it rapidly
      var tank = Tank(
        id: 'rapid_test',
        name: 'Initial Name',
        type: TankType.freshwater,
        volumeLitres: 50.0,
        startDate: DateTime.now(),
        targets: WaterTargets.freshwaterTropical(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save initial tank
      await storage.saveTank(tank);

      // Perform 50 rapid updates
      for (var i = 0; i < 50; i++) {
        tank = tank.copyWith(
          name: 'Updated Name $i',
          volumeLitres: 50.0 + i,
          updatedAt: DateTime.now(),
        );
        await storage.saveTank(tank);
      }

      // Verify final state
      final finalTank = await storage.getTank('rapid_test');
      expect(finalTank, isNotNull);
      expect(finalTank!.name, equals('Updated Name 49'));
      expect(finalTank.volumeLitres, equals(99.0));

      debugPrint('✅ P0-1 Test passed: 50 rapid sequential saves maintained data integrity');
    });

    test('P0-1: Mixed concurrent operations should not deadlock', () async {
      // Create initial tanks
      for (var i = 0; i < 5; i++) {
        await storage.saveTank(Tank(
          id: 'tank_$i',
          name: 'Tank $i',
          type: TankType.freshwater,
          volumeLitres: 100.0,
          startDate: DateTime.now(),
          targets: WaterTargets.freshwaterTropical(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      // Mix of reads and writes concurrently
      final futures = <Future<void>>[];
      
      // Add save operations
      for (var i = 5; i < 10; i++) {
        futures.add(storage.saveTank(Tank(
          id: 'tank_$i',
          name: 'Tank $i',
          type: TankType.freshwater,
          volumeLitres: 100.0,
          startDate: DateTime.now(),
          targets: WaterTargets.freshwaterTropical(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )));
      }

      // Add read operations
      for (var i = 0; i < 5; i++) {
        futures.add(storage.getTank('tank_$i').then((_) {}));
      }

      // Add delete operations
      futures.add(storage.deleteTank('tank_0'));
      futures.add(storage.deleteTank('tank_1'));

      // Wait for all operations
      await Future.wait(futures);

      // Verify final state
      final allTanks = await storage.getAllTanks();
      expect(allTanks.length, equals(8)); // 10 created - 2 deleted

      debugPrint('✅ P0-1 Test passed: Mixed concurrent operations completed without deadlock');
    });
  });
}

/// Extension to add copyWith to Tank model for testing
extension TankCopyWith on Tank {
  Tank copyWith({
    String? id,
    String? name,
    TankType? type,
    double? volumeLitres,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    DateTime? startDate,
    WaterTargets? targets,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tank(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      volumeLitres: volumeLitres ?? this.volumeLitres,
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      startDate: startDate ?? this.startDate,
      targets: targets ?? this.targets,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
