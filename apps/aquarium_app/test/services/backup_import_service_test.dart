import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/services/backup_import_service.dart';
import 'package:danio/services/storage_service.dart';

class _RecordingStorageService implements StorageService {
  final Map<String, Tank> tanks = {};
  final Map<String, Livestock> livestock = {};
  final Map<String, Equipment> equipment = {};
  final Map<String, LogEntry> logs = {};
  final Map<String, Task> tasks = {};

  bool failAfterSaveTank = false;
  bool failOnSaveLog = false;

  @override
  Future<void> deleteAllTanks(List<String> ids) async {
    final idSet = ids.toSet();
    tanks.removeWhere((id, _) => idSet.contains(id));
    livestock.removeWhere((_, item) => idSet.contains(item.tankId));
    equipment.removeWhere((_, item) => idSet.contains(item.tankId));
    logs.removeWhere((_, item) => idSet.contains(item.tankId));
    tasks.removeWhere((_, item) => idSet.contains(item.tankId));
  }

  @override
  Future<void> deleteEquipment(String id) async {
    equipment.remove(id);
  }

  @override
  Future<void> deleteLivestock(String id) async {
    livestock.remove(id);
  }

  @override
  Future<void> deleteLog(String id) async {
    logs.remove(id);
  }

  @override
  Future<void> deleteTank(String id) async {
    await deleteAllTanks([id]);
  }

  @override
  Future<void> deleteTask(String id) async {
    tasks.remove(id);
  }

  @override
  Future<List<Tank>> getAllTanks() async => tanks.values.toList();

  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) async =>
      equipment.values.where((item) => item.tankId == tankId).toList();

  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) async => logs.values
      .where((item) => item.tankId == tankId && item.type == LogType.waterTest)
      .firstOrNull;

  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) async =>
      livestock.values.where((item) => item.tankId == tankId).toList();

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) async => logs.values.where((item) => item.tankId == tankId).toList();

  @override
  Future<Tank?> getTank(String id) async => tanks[id];

  @override
  Future<List<Task>> getTasksForTank(String? tankId) async => tasks.values
      .where((item) => tankId == null || item.tankId == tankId)
      .toList();

  @override
  Future<void> saveEquipment(Equipment item) async {
    equipment[item.id] = item;
  }

  @override
  Future<void> saveLivestock(Livestock item) async {
    livestock[item.id] = item;
  }

  @override
  Future<void> saveLog(LogEntry item) async {
    if (failOnSaveLog) {
      throw StateError('simulated log save failure');
    }
    logs[item.id] = item;
  }

  @override
  Future<void> saveTank(Tank tank) async {
    tanks[tank.id] = tank;
    if (failAfterSaveTank) {
      throw StateError('simulated tank save failure');
    }
  }

  @override
  Future<void> saveTanks(List<Tank> tanks) async {
    for (final tank in tanks) {
      await saveTank(tank);
    }
  }

  @override
  Future<void> saveTask(Task item) async {
    tasks[item.id] = item;
  }
}

Map<String, dynamic> _backupData() {
  return {
    'tanks': [
      {
        'id': 'old-tank',
        'name': 'Backup Tank',
        'type': 'freshwater',
        'volumeLitres': 90,
        'startDate': '2026-01-01T00:00:00.000',
        'targets': {
          'tempMin': 24,
          'tempMax': 26,
          'phMin': 6.8,
          'phMax': 7.4,
        },
        'notes': 'Imported community tank',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-02-01T00:00:00.000',
      },
    ],
    'livestock': [
      {
        'id': 'old-fish',
        'tankId': 'old-tank',
        'commonName': 'Neon tetra',
        'scientificName': 'Paracheirodon innesi',
        'count': 8,
        'dateAdded': '2026-01-02T00:00:00.000',
        'healthStatus': 'healthy',
        'createdAt': '2026-01-02T00:00:00.000',
        'updatedAt': '2026-02-02T00:00:00.000',
      },
    ],
    'equipment': [
      {
        'id': 'old-filter',
        'tankId': 'old-tank',
        'type': 'filter',
        'name': 'Canister filter',
        'settings': {'flow': 'medium'},
        'createdAt': '2026-01-03T00:00:00.000',
        'updatedAt': '2026-02-03T00:00:00.000',
      },
    ],
    'logs': [
      {
        'id': 'old-log',
        'tankId': 'old-tank',
        'type': 'observation',
        'timestamp': '2026-03-04T10:30:00.000',
        'title': 'Feeding response',
        'notes': 'All fish active after feeding.',
        'relatedEquipmentId': 'old-filter',
        'relatedLivestockId': 'old-fish',
        'relatedTaskId': 'old-task',
        'createdAt': '2026-03-04T10:31:00.000',
      },
    ],
    'tasks': [
      {
        'id': 'old-task',
        'tankId': 'old-tank',
        'title': 'Rinse prefilter',
        'description': 'Use old tank water.',
        'recurrence': 'weekly',
        'intervalDays': 7,
        'dueDate': '2026-03-10T00:00:00.000',
        'priority': 'normal',
        'isEnabled': true,
        'isAutoGenerated': false,
        'relatedEquipmentId': 'old-filter',
        'createdAt': '2026-01-04T00:00:00.000',
        'updatedAt': '2026-02-04T00:00:00.000',
      },
    ],
  };
}

String Function() _idSequence(List<String> ids) {
  var index = 0;
  return () => ids[index++];
}

void main() {
  group('BackupImportService', () {
    test(
      'imports tank-scoped backup data with remapped relationships',
      () async {
        final storage = _RecordingStorageService();
        final service = BackupImportService(
          storage: storage,
          newId: _idSequence([
            'new-tank',
            'new-fish',
            'new-filter',
            'new-task',
            'new-log',
          ]),
          now: () => DateTime.utc(2026, 6, 22, 12),
        );

        final result = await service.importTankScopedData(_backupData());

        expect(result.importedTanks, 1);
        expect(result.tankIdMap, {'old-tank': 'new-tank'});
        expect(storage.tanks.keys, contains('new-tank'));
        expect(storage.tanks.keys, isNot(contains('old-tank')));

        final importedFish = storage.livestock['new-fish'];
        expect(importedFish?.tankId, 'new-tank');
        expect(importedFish?.commonName, 'Neon tetra');

        final importedTask = storage.tasks['new-task'];
        expect(importedTask?.tankId, 'new-tank');
        expect(importedTask?.relatedEquipmentId, 'new-filter');

        final importedLog = storage.logs['new-log'];
        expect(importedLog?.tankId, 'new-tank');
        expect(
          importedLog?.timestamp,
          DateTime.parse('2026-03-04T10:30:00.000'),
        );
        expect(importedLog?.relatedEquipmentId, 'new-filter');
        expect(importedLog?.relatedLivestockId, 'new-fish');
        expect(importedLog?.relatedTaskId, 'new-task');
      },
    );

    test(
      'regenerates imported tank ids that already exist locally',
      () async {
        final storage = _RecordingStorageService();
        final existing = Tank(
          id: 'new-tank',
          name: 'Existing Tank',
          type: TankType.freshwater,
          volumeLitres: 60,
          startDate: DateTime.utc(2026, 1, 1),
          targets: WaterTargets.freshwaterTropical(),
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );
        await storage.saveTank(existing);
        final service = BackupImportService(
          storage: storage,
          newId: _idSequence([
            'new-tank',
            'fresh-tank',
            'new-fish',
            'new-filter',
            'new-task',
            'new-log',
          ]),
          now: () => DateTime.utc(2026, 6, 22, 12),
        );

        final result = await service.importTankScopedData(_backupData());

        expect(result.importedTanks, 1);
        expect(result.tankIdMap, {'old-tank': 'fresh-tank'});
        expect(storage.tanks['new-tank']?.name, 'Existing Tank');
        expect(storage.tanks['fresh-tank']?.name, 'Backup Tank');
        expect(storage.livestock['new-fish']?.tankId, 'fresh-tank');
      },
    );

    test(
      'regenerates imported child ids that already exist locally',
      () async {
        final storage = _RecordingStorageService();
        final existingTank = Tank(
          id: 'local-tank',
          name: 'Existing Tank',
          type: TankType.freshwater,
          volumeLitres: 60,
          startDate: DateTime.utc(2026, 1, 1),
          targets: WaterTargets.freshwaterTropical(),
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );
        await storage.saveTank(existingTank);
        await storage.saveLivestock(
          Livestock(
            id: 'existing-fish',
            tankId: existingTank.id,
            commonName: 'Existing guppy',
            scientificName: null,
            count: 2,
            dateAdded: DateTime.utc(2026, 1, 2),
            createdAt: DateTime.utc(2026, 1, 2),
            updatedAt: DateTime.utc(2026, 1, 2),
          ),
        );
        await storage.saveEquipment(
          Equipment(
            id: 'existing-filter',
            tankId: existingTank.id,
            type: EquipmentType.filter,
            name: 'Existing sponge filter',
            createdAt: DateTime.utc(2026, 1, 3),
            updatedAt: DateTime.utc(2026, 1, 3),
          ),
        );
        await storage.saveTask(
          Task(
            id: 'existing-task',
            tankId: existingTank.id,
            title: 'Existing task',
            recurrence: RecurrenceType.none,
            priority: TaskPriority.normal,
            createdAt: DateTime.utc(2026, 1, 4),
            updatedAt: DateTime.utc(2026, 1, 4),
          ),
        );
        await storage.saveLog(
          LogEntry(
            id: 'existing-log',
            tankId: existingTank.id,
            type: LogType.observation,
            timestamp: DateTime.utc(2026, 1, 5),
            title: 'Existing log',
            createdAt: DateTime.utc(2026, 1, 5),
          ),
        );
        final service = BackupImportService(
          storage: storage,
          newId: _idSequence([
            'new-tank',
            'existing-fish',
            'fresh-fish',
            'existing-filter',
            'fresh-filter',
            'existing-task',
            'fresh-task',
            'existing-log',
            'fresh-log',
          ]),
          now: () => DateTime.utc(2026, 6, 22, 12),
        );

        final result = await service.importTankScopedData(_backupData());

        expect(result.importedTanks, 1);
        expect(result.livestockIdMap, {'old-fish': 'fresh-fish'});
        expect(result.equipmentIdMap, {'old-filter': 'fresh-filter'});
        expect(result.taskIdMap, {'old-task': 'fresh-task'});
        expect(
          storage.livestock['existing-fish']?.commonName,
          'Existing guppy',
        );
        expect(
          storage.equipment['existing-filter']?.name,
          'Existing sponge filter',
        );
        expect(storage.tasks['existing-task']?.title, 'Existing task');
        expect(storage.logs['existing-log']?.title, 'Existing log');
        expect(storage.livestock['fresh-fish']?.tankId, 'new-tank');
        expect(storage.equipment['fresh-filter']?.tankId, 'new-tank');
        expect(storage.tasks['fresh-task']?.tankId, 'new-tank');
        expect(storage.tasks['fresh-task']?.relatedEquipmentId, 'fresh-filter');
        expect(storage.logs['fresh-log']?.tankId, 'new-tank');
        expect(storage.logs['fresh-log']?.relatedLivestockId, 'fresh-fish');
        expect(storage.logs['fresh-log']?.relatedEquipmentId, 'fresh-filter');
        expect(storage.logs['fresh-log']?.relatedTaskId, 'fresh-task');
      },
    );

    test(
      'rolls back imported tanks and children when a later save fails',
      () async {
        final storage = _RecordingStorageService()..failOnSaveLog = true;
        final existing = Tank(
          id: 'existing-tank',
          name: 'Existing Tank',
          type: TankType.freshwater,
          volumeLitres: 60,
          startDate: DateTime.utc(2026, 1, 1),
          targets: WaterTargets.freshwaterTropical(),
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );
        await storage.saveTank(existing);

        final service = BackupImportService(
          storage: storage,
          newId: _idSequence([
            'new-tank',
            'new-fish',
            'new-filter',
            'new-task',
            'new-log',
          ]),
          now: () => DateTime.utc(2026, 6, 22, 12),
        );

        await expectLater(
          service.importTankScopedData(_backupData()),
          throwsA(isA<BackupImportException>()),
        );

        expect(storage.tanks.keys, contains('existing-tank'));
        expect(storage.tanks.keys, isNot(contains('new-tank')));
        expect(storage.livestock, isEmpty);
        expect(storage.equipment, isEmpty);
        expect(storage.logs, isEmpty);
        expect(storage.tasks, isEmpty);
      },
    );

    test(
      'rolls back a tank when saveTank persists then reports failure',
      () async {
        final storage = _RecordingStorageService()..failAfterSaveTank = true;
        final service = BackupImportService(
          storage: storage,
          newId: _idSequence(['new-tank']),
          now: () => DateTime.utc(2026, 6, 22, 12),
        );

        await expectLater(
          service.importTankScopedData(_backupData()),
          throwsA(isA<BackupImportException>()),
        );

        expect(storage.tanks.keys, isNot(contains('new-tank')));
        expect(storage.livestock, isEmpty);
        expect(storage.equipment, isEmpty);
        expect(storage.logs, isEmpty);
        expect(storage.tasks, isEmpty);
      },
    );

    test(
      'rejects child entries with unknown backup tank ids before reporting import success',
      () async {
        for (final scenario in const [
          (collection: 'livestock', label: 'livestock'),
          (collection: 'equipment', label: 'equipment'),
          (collection: 'tasks', label: 'task'),
          (collection: 'logs', label: 'log'),
        ]) {
          final storage = _RecordingStorageService();
          final service = BackupImportService(
            storage: storage,
            newId: _idSequence([
              'new-tank',
              'new-fish',
              'new-filter',
              'new-task',
              'new-log',
            ]),
            now: () => DateTime.utc(2026, 6, 22, 12),
          );
          final backupData = {
            ..._backupData(),
            scenario.collection: [
              {
                'id': '${scenario.collection}-orphan',
                'tankId': 'missing-tank',
              },
            ],
          };

          await expectLater(
            service.importTankScopedData(backupData),
            throwsA(
              isA<BackupImportException>().having(
                (error) => error.originalError,
                'originalError',
                isA<FormatException>().having(
                  (error) => error.message,
                  'message',
                  contains(
                    'Invalid backup: ${scenario.label} entries reference unknown tank id "missing-tank"',
                  ),
                ),
              ),
            ),
          );

          expect(storage.tanks.keys, isNot(contains('new-tank')));
          expect(storage.livestock, isEmpty);
          expect(storage.equipment, isEmpty);
          expect(storage.logs, isEmpty);
          expect(storage.tasks, isEmpty);
        }
      },
    );

    test('skips preference restore when backup imports no tanks', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': 0,
        'use_metric': true,
      });
      var tanksInvalidated = false;
      var preferencesInvalidated = false;
      final flow = BackupRestoreImportFlow(
        importService: BackupImportService(storage: _RecordingStorageService()),
        onTanksImported: () => tanksInvalidated = true,
        onPreferencesRestored: () => preferencesInvalidated = true,
      );

      final result = await flow.importBackupData({
        'tanks': <Object?>[],
        'sharedPreferences': {
          'entries': {
            'theme_mode': 2,
            'use_metric': false,
          },
        },
      });

      final prefs = await SharedPreferences.getInstance();
      expect(result.importedTanks, 0);
      expect(result.preferencesRestored, isFalse);
      expect(result.preferencesRestoreFailed, isFalse);
      expect(tanksInvalidated, isFalse);
      expect(preferencesInvalidated, isFalse);
      expect(prefs.getInt('theme_mode'), 0);
      expect(prefs.getBool('use_metric'), isTrue);
    });

    test(
      'reports malformed preference payloads after importing tanks',
      () async {
        SharedPreferences.setMockInitialValues({'theme_mode': 0});
        final storage = _RecordingStorageService();
        var tanksInvalidated = false;
        var preferencesInvalidated = false;
        final flow = BackupRestoreImportFlow(
          importService: BackupImportService(
            storage: storage,
            newId: _idSequence([
              'new-tank',
              'new-fish',
              'new-filter',
              'new-task',
              'new-log',
            ]),
            now: () => DateTime.utc(2026, 6, 22, 12),
          ),
          onTanksImported: () => tanksInvalidated = true,
          onPreferencesRestored: () => preferencesInvalidated = true,
        );

        final result = await flow.importBackupData({
          ..._backupData(),
          'sharedPreferences': 'not-preferences',
        });

        final prefs = await SharedPreferences.getInstance();
        expect(result.importedTanks, 1);
        expect(result.preferencesRestored, isFalse);
        expect(result.preferencesRestoreFailed, isTrue);
        expect(
          result.preferencesRestoreError,
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Invalid format: sharedPreferences must be an object',
          ),
        );
        expect(tanksInvalidated, isTrue);
        expect(preferencesInvalidated, isFalse);
        expect(storage.tanks.keys, contains('new-tank'));
        expect(prefs.getInt('theme_mode'), 0);
      },
    );
  });
}
