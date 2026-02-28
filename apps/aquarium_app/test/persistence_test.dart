import 'package:flutter_test/flutter_test.dart';
import 'package:danio/models/models.dart';
import 'package:danio/services/hive_storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

void main() {
  group('Phase 2A — Persistence Acceptance Tests', () {
    late Directory tempDir;
    
    setUp(() async {
      // Create temp directory for test Hive boxes
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      await Hive.initFlutter(tempDir.path);
    });
    
    tearDown() async {
      // Clean up
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    
    test('✅ Acceptance Test 1: Create tank → restart → tank exists', () async {
      // Initialize storage
      final initialized = await HiveStorageService.initialize();
      expect(initialized, true, reason: 'Storage should initialize successfully');
      
      final storage = HiveStorageService.instance;
      
      // Create a tank
      final tank = Tank(
        id: 'test-tank-1',
        name: 'My First Tank',
        tankType: TankType.freshwater,
        volumeGallons: 20.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await storage.saveTank(tank);
      
      // Verify it's saved
      final savedTank = await storage.getTank('test-tank-1');
      expect(savedTank, isNotNull);
      expect(savedTank!.name, 'My First Tank');
      expect(savedTank.volumeGallons, 20.0);
      
      // Simulate app restart by closing and reopening Hive
      await Hive.close();
      
      // Re-initialize (simulates app restart)
      final reinitOk = await HiveStorageService.initialize();
      expect(reinitOk, true, reason: 'Storage should reinitialize after "restart"');
      
      final storageAfterRestart = HiveStorageService.instance;
      
      // Tank should still exist
      final tankAfterRestart = await storageAfterRestart.getTank('test-tank-1');
      expect(tankAfterRestart, isNotNull, reason: 'Tank should persist across restart');
      expect(tankAfterRestart!.name, 'My First Tank');
      expect(tankAfterRestart.volumeGallons, 20.0);
      expect(tankAfterRestart.tankType, TankType.freshwater);
    });
    
    test('✅ Acceptance Test 2: Create tank + fish + logs → restart → all present', () async {
      await HiveStorageService.initialize();
      final storage = HiveStorageService.instance;
      
      // Create tank
      final tank = Tank(
        id: 'tank-1',
        name: 'Community Tank',
        tankType: TankType.freshwater,
        volumeGallons: 30.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storage.saveTank(tank);
      
      // Add fish
      final fish = Livestock(
        id: 'fish-1',
        tankId: 'tank-1',
        species: 'Betta splendens',
        commonName: 'Betta',
        quantity: 1,
        addedAt: DateTime.now(),
      );
      await storage.saveLivestock(fish);
      
      // Add logs
      final log1 = LogEntry(
        id: 'log-1',
        tankId: 'tank-1',
        timestamp: DateTime.now(),
        type: LogType.waterChange,
        notes: 'Changed 30% water',
      );
      final log2 = LogEntry(
        id: 'log-2',
        tankId: 'tank-1',
        timestamp: DateTime.now(),
        type: LogType.parameterTest,
        ph: 7.0,
        ammonia: 0.0,
        nitrite: 0.0,
        nitrate: 5.0,
      );
      final log3 = LogEntry(
        id: 'log-3',
        tankId: 'tank-1',
        timestamp: DateTime.now(),
        type: LogType.feeding,
        notes: 'Fed 2 pellets',
      );
      
      await storage.saveLog(log1);
      await storage.saveLog(log2);
      await storage.saveLog(log3);
      
      // Verify counts before restart
      final tanksCount = (await storage.getAllTanks()).length;
      final fishCount = (await storage.getLivestockForTank('tank-1')).length;
      final logsCount = (await storage.getLogsForTank('tank-1')).length;
      
      expect(tanksCount, 1);
      expect(fishCount, 1);
      expect(logsCount, 3);
      
      // Restart
      await Hive.close();
      await HiveStorageService.initialize();
      final storageAfterRestart = HiveStorageService.instance;
      
      // All should still exist
      final tanksAfter = await storageAfterRestart.getAllTanks();
      final fishAfter = await storageAfterRestart.getLivestockForTank('tank-1');
      final logsAfter = await storageAfterRestart.getLogsForTank('tank-1');
      
      expect(tanksAfter.length, 1, reason: 'Tank should persist');
      expect(fishAfter.length, 1, reason: 'Fish should persist');
      expect(logsAfter.length, 3, reason: 'All 3 logs should persist');
      
      // Verify tank data
      expect(tanksAfter.first.name, 'Community Tank');
      
      // Verify fish data
      expect(fishAfter.first.species, 'Betta splendens');
      
      // Verify log data
      final waterChangeLog = logsAfter.firstWhere((l) => l.type == LogType.waterChange);
      expect(waterChangeLog.notes, 'Changed 30% water');
      
      final paramLog = logsAfter.firstWhere((l) => l.type == LogType.parameterTest);
      expect(paramLog.ph, 7.0);
      expect(paramLog.nitrate, 5.0);
    });
    
    test('✅ Stats tracking works', () async {
      await HiveStorageService.initialize();
      final storage = HiveStorageService.instance;
      
      // Add some data
      await storage.saveTank(Tank(
        id: 'tank-stats-1',
        name: 'Stats Tank',
        tankType: TankType.planted,
        volumeGallons: 10.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      await storage.saveLivestock(Livestock(
        id: 'fish-stats-1',
        tankId: 'tank-stats-1',
        species: 'Test fish',
        commonName: 'Test',
        quantity: 5,
        addedAt: DateTime.now(),
      ));
      
      final stats = storage.getStats();
      
      expect(stats['tanks'], greaterThanOrEqualTo(1));
      expect(stats['livestock'], greaterThanOrEqualTo(1));
      expect(stats['schema_version'], kStorageSchemaVersion);
    });
  });
}
