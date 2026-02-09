import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/models.dart';
import 'package:aquarium_app/services/local_json_storage_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock PathProvider for testing
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = Directory.systemTemp.createTempSync('aquarium_test_');
    return dir.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  group('Storage Service Race Condition Tests', () {
    test('Concurrent tank saves should not lose data', () async {
      final storage = LocalJsonStorageService();
      
      // Clear any existing data
      await storage.clearAllData();

      // Create a base tank
      final baseTank = Tank(
        id: 'test-tank-1',
        name: 'Initial Tank',
        type: TankType.freshwater,
        volumeLitres: 100,
        startDate: DateTime.now(),
        targets: WaterTargets.freshwaterTropical(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await storage.saveTank(baseTank);

      // Simulate concurrent updates to the same tank
      final futures = <Future<void>>[];
      const concurrentOps = 20;

      for (var i = 0; i < concurrentOps; i++) {
        final updatedTank = baseTank.copyWith(
          name: 'Tank Update $i',
          updatedAt: DateTime.now(),
        );
        futures.add(storage.saveTank(updatedTank));
      }

      // Wait for all operations to complete
      await Future.wait(futures);

      // Verify the tank was saved (should be one of the updates, not corrupted)
      final retrievedTank = await storage.getTank('test-tank-1');
      expect(retrievedTank, isNotNull);
      expect(retrievedTank!.id, equals('test-tank-1'));
      expect(retrievedTank.name, startsWith('Tank Update'));
      
      print('✅ Tank after concurrent saves: ${retrievedTank.name}');
    });

    test('Concurrent mixed operations should maintain consistency', () async {
      final storage = LocalJsonStorageService();
      await storage.clearAllData();

      // Create initial data
      final tank1 = Tank(
        id: 'tank-1',
        name: 'Tank 1',
        type: TankType.freshwater,
        volumeLitres: 100,
        startDate: DateTime.now(),
        targets: WaterTargets.freshwaterTropical(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tank2 = Tank(
        id: 'tank-2',
        name: 'Tank 2',
        type: TankType.marine,
        volumeLitres: 200,
        startDate: DateTime.now(),
        targets: WaterTargets.freshwaterTropical(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await storage.saveTank(tank1);
      await storage.saveTank(tank2);

      // Simulate concurrent mixed operations
      final futures = <Future<void>>[];

      // Add livestock to tank 1
      for (var i = 0; i < 10; i++) {
        final livestock = Livestock(
          id: 'livestock-1-$i',
          tankId: 'tank-1',
          commonName: 'Fish $i',
          count: 1,
          dateAdded: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        futures.add(storage.saveLivestock(livestock));
      }

      // Add equipment to tank 2
      for (var i = 0; i < 10; i++) {
        final equipment = Equipment(
          id: 'equipment-2-$i',
          tankId: 'tank-2',
          type: EquipmentType.filter,
          name: 'Filter $i',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        futures.add(storage.saveEquipment(equipment));
      }

      // Update tank names concurrently
      for (var i = 0; i < 10; i++) {
        futures.add(storage.saveTank(tank1.copyWith(
          name: 'Tank 1 Update $i',
          updatedAt: DateTime.now(),
        )));
        futures.add(storage.saveTank(tank2.copyWith(
          name: 'Tank 2 Update $i',
          updatedAt: DateTime.now(),
        )));
      }

      // Execute all operations concurrently
      await Future.wait(futures);

      // Verify data consistency
      final retrievedTanks = await storage.getAllTanks();
      expect(retrievedTanks.length, equals(2));

      final retrievedLivestock = await storage.getLivestockForTank('tank-1');
      expect(retrievedLivestock.length, equals(10));

      final retrievedEquipment = await storage.getEquipmentForTank('tank-2');
      expect(retrievedEquipment.length, equals(10));

      print('✅ All concurrent operations completed successfully');
      print('   Tanks: ${retrievedTanks.length}');
      print('   Livestock in tank-1: ${retrievedLivestock.length}');
      print('   Equipment in tank-2: ${retrievedEquipment.length}');
    });

    test('Concurrent delete operations should not cause corruption', () async {
      final storage = LocalJsonStorageService();
      await storage.clearAllData();

      // Create multiple tanks
      for (var i = 0; i < 20; i++) {
        final tank = Tank(
          id: 'tank-$i',
          name: 'Tank $i',
          type: TankType.freshwater,
          volumeLitres: 100,
          startDate: DateTime.now(),
          targets: WaterTargets.freshwaterTropical(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await storage.saveTank(tank);
      }

      // Delete half of them concurrently
      final deleteFutures = <Future<void>>[];
      for (var i = 0; i < 10; i++) {
        deleteFutures.add(storage.deleteTank('tank-$i'));
      }

      await Future.wait(deleteFutures);

      // Verify correct number of tanks remain
      final remainingTanks = await storage.getAllTanks();
      expect(remainingTanks.length, equals(10));

      // Verify the correct tanks remain
      for (var i = 10; i < 20; i++) {
        final tank = await storage.getTank('tank-$i');
        expect(tank, isNotNull);
        expect(tank!.name, equals('Tank $i'));
      }

      print('✅ Concurrent deletes completed successfully');
      print('   Remaining tanks: ${remainingTanks.length}');
    });

    test('Stress test: 100 concurrent operations', () async {
      final storage = LocalJsonStorageService();
      await storage.clearAllData();

      final futures = <Future<void>>[];
      const operationCount = 100;

      for (var i = 0; i < operationCount; i++) {
        final tankId = 'stress-tank-${i % 10}'; // 10 different tanks
        final tank = Tank(
          id: tankId,
          name: 'Stress Tank $i',
          type: TankType.freshwater,
          volumeLitres: (100 + i).toDouble(),
          startDate: DateTime.now(),
          targets: WaterTargets.freshwaterTropical(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        futures.add(storage.saveTank(tank));
      }

      final stopwatch = Stopwatch()..start();
      await Future.wait(futures);
      stopwatch.stop();

      final tanks = await storage.getAllTanks();
      expect(tanks.length, equals(10)); // Should have 10 unique tanks

      print('✅ Stress test completed');
      print('   Operations: $operationCount');
      print('   Time: ${stopwatch.elapsedMilliseconds}ms');
      print('   Unique tanks: ${tanks.length}');
    });

    test('Verify atomic write (no partial saves)', () async {
      final storage = LocalJsonStorageService();
      await storage.clearAllData();

      // Create a tank with related data
      final tank = Tank(
        id: 'atomic-tank',
        name: 'Atomic Test Tank',
        type: TankType.freshwater,
        volumeLitres: 100,
        startDate: DateTime.now(),
        targets: WaterTargets.freshwaterTropical(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final livestock = Livestock(
        id: 'atomic-livestock',
        tankId: 'atomic-tank',
        commonName: 'Test Fish',
        count: 1,
        dateAdded: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save both concurrently
      await Future.wait([
        storage.saveTank(tank),
        storage.saveLivestock(livestock),
      ]);

      // Verify both are saved
      final retrievedTank = await storage.getTank('atomic-tank');
      final retrievedLivestock = await storage.getLivestockForTank('atomic-tank');

      expect(retrievedTank, isNotNull);
      expect(retrievedLivestock.length, equals(1));
      expect(retrievedLivestock.first.id, equals('atomic-livestock'));

      print('✅ Atomic write verified');
    });
  });
}
