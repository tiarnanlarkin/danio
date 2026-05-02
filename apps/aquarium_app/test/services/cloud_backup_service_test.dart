import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/services/cloud_backup_service.dart';
import 'package:danio/services/storage_service.dart';

void main() {
  group('CloudBackupService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('export includes SharedPreferences-backed app state', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 2});
      final storage = InMemoryStorageService();

      final data = await CloudBackupService.instance.exportAllDataForTesting(
        storage,
      );

      final prefsData = data['sharedPreferences'] as Map<String, dynamic>;
      final entries = prefsData['entries'] as Map<String, dynamic>;
      expect(entries['theme_mode'], 2);
    });

    test('restore keeps local child records when ids conflict', () async {
      final storage = InMemoryStorageService();
      final now = DateTime(2026, 1, 1);
      const prefix = 'cloud-local-wins';
      final tankId = '$prefix-tank';

      final tank = Tank(
        id: tankId,
        name: 'Local Tank',
        type: TankType.freshwater,
        volumeLitres: 100,
        startDate: now,
        targets: WaterTargets.freshwaterTropical(),
        createdAt: now,
        updatedAt: now,
      );
      await storage.saveTank(tank);

      final localLivestock = Livestock(
        id: '$prefix-fish',
        tankId: tankId,
        commonName: 'Local Fish',
        count: 1,
        dateAdded: now,
        createdAt: now,
        updatedAt: now,
      );
      final localEquipment = Equipment(
        id: '$prefix-equipment',
        tankId: tankId,
        type: EquipmentType.filter,
        name: 'Local Filter',
        createdAt: now,
        updatedAt: now,
      );
      final localLog = LogEntry(
        id: '$prefix-log',
        tankId: tankId,
        type: LogType.observation,
        timestamp: now,
        notes: 'local log',
        createdAt: now,
      );
      final localTask = Task(
        id: '$prefix-task',
        tankId: tankId,
        title: 'Local Task',
        recurrence: RecurrenceType.none,
        createdAt: now,
        updatedAt: now,
      );

      await storage.saveLivestock(localLivestock);
      await storage.saveEquipment(localEquipment);
      await storage.saveLog(localLog);
      await storage.saveTask(localTask);

      final remoteLivestock = localLivestock.copyWith(
        commonName: 'Remote Fish',
      );
      final remoteEquipment = localEquipment.copyWith(name: 'Remote Filter');
      final remoteLog = localLog.copyWith(notes: 'remote log');
      final remoteTask = localTask.copyWith(title: 'Remote Task');
      final newRemoteTask = Task(
        id: '$prefix-new-task',
        tankId: tankId,
        title: 'New Remote Task',
        recurrence: RecurrenceType.none,
        createdAt: now,
        updatedAt: now,
      );

      final result = await CloudBackupService.instance.importDataForTesting(
        storage,
        {
          'tanks': [tank.copyWith(name: 'Remote Tank').toJson()],
          'livestock': [remoteLivestock.toJson()],
          'equipment': [remoteEquipment.toJson()],
          'logs': [remoteLog.toJson()],
          'tasks': [remoteTask.toJson(), newRemoteTask.toJson()],
        },
      );

      expect((await storage.getTank(tankId))?.name, 'Local Tank');
      expect(
        (await storage.getLivestockForTank(
          tankId,
        )).firstWhere((item) => item.id == localLivestock.id).commonName,
        'Local Fish',
      );
      expect(
        (await storage.getEquipmentForTank(
          tankId,
        )).firstWhere((item) => item.id == localEquipment.id).name,
        'Local Filter',
      );
      expect(
        (await storage.getLogsForTank(
          tankId,
        )).firstWhere((item) => item.id == localLog.id).notes,
        'local log',
      );
      expect(
        (await storage.getTasksForTank(
          tankId,
        )).firstWhere((item) => item.id == localTask.id).title,
        'Local Task',
      );
      expect(
        (await storage.getTasksForTank(
          tankId,
        )).firstWhere((item) => item.id == newRemoteTask.id).title,
        'New Remote Task',
      );
      expect(result.changedTankIds, contains(tankId));
    });
  });
}
