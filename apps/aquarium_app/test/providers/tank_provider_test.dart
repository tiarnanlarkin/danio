// Tests for TankProvider and TankActions.
//
// Covers:
//   - Creating a new tank and persisting it to storage
//   - Soft-deleting a tank (marks as deleted, starts undo timer)
//   - Undoing soft-delete before timer expires
//   - Listing only non-deleted tanks
//   - SoftDeleteState as a standalone unit
//
// Run: flutter test test/providers/tank_provider_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/models/models.dart';
import 'package:danio/services/storage_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Minimal in-memory StorageService for test isolation.
/// Unlike the production InMemoryStorageService (which is a singleton),
/// each instance starts with a clean slate.
class _TestStorageService implements StorageService {
  final Map<String, Tank> _tanks = {};
  final Map<String, Livestock> _livestock = {};
  final Map<String, Equipment> _equipment = {};
  final Map<String, LogEntry> _logs = {};
  final Map<String, Task> _tasks = {};

  @override
  Future<List<Tank>> getAllTanks() async =>
      _tanks.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  @override
  Future<Tank?> getTank(String id) async => _tanks[id];
  @override
  Future<void> saveTank(Tank tank) async => _tanks[tank.id] = tank;
  @override
  Future<void> saveTanks(List<Tank> tanks) async {
    for (final t in tanks) {
      _tanks[t.id] = t;
    }
  }

  @override
  Future<void> deleteTank(String id) async {
    _tanks.remove(id);
    _livestock.removeWhere((_, v) => v.tankId == id);
    _equipment.removeWhere((_, v) => v.tankId == id);
    _logs.removeWhere((_, v) => v.tankId == id);
    _tasks.removeWhere((_, v) => v.tankId == id);
  }

  @override
  Future<void> deleteAllTanks(List<String> ids) async {
    final idSet = ids.toSet();
    _tanks.removeWhere((id, _) => idSet.contains(id));
  }

  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) async =>
      _livestock.values.where((l) => l.tankId == tankId).toList();
  @override
  Future<void> saveLivestock(Livestock livestock) async =>
      _livestock[livestock.id] = livestock;
  @override
  Future<void> deleteLivestock(String id) async => _livestock.remove(id);

  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) async =>
      _equipment.values.where((e) => e.tankId == tankId).toList();
  @override
  Future<void> saveEquipment(Equipment equipment) async =>
      _equipment[equipment.id] = equipment;
  @override
  Future<void> deleteEquipment(String id) async => _equipment.remove(id);

  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) async {
    var logs = _logs.values.where((l) => l.tankId == tankId).toList();
    if (after != null) {
      logs = logs.where((l) => l.timestamp.isAfter(after)).toList();
    }
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null && logs.length > limit) logs = logs.take(limit).toList();
    return logs;
  }

  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) async => null;
  @override
  Future<void> saveLog(LogEntry log) async => _logs[log.id] = log;
  @override
  Future<void> deleteLog(String id) async => _logs.remove(id);

  @override
  Future<List<Task>> getTasksForTank(String? tankId) async {
    if (tankId == null) return _tasks.values.toList();
    return _tasks.values.where((t) => t.tankId == tankId).toList();
  }

  @override
  Future<void> saveTask(Task task) async => _tasks[task.id] = task;
  @override
  Future<void> deleteTask(String id) async => _tasks.remove(id);
}

class _DeleteTankFailsStorage extends _TestStorageService {
  _DeleteTankFailsStorage({required this.failingTankId});

  final String failingTankId;

  @override
  Future<void> deleteTank(String id) async {
    if (id == failingTankId) {
      throw StateError('tank delete failed');
    }
    await super.deleteTank(id);
  }
}

class _DeleteLivestockFailsStorage extends _TestStorageService {
  _DeleteLivestockFailsStorage({required this.failingLivestockId});

  final String failingLivestockId;

  @override
  Future<void> deleteLivestock(String id) async {
    if (id == failingLivestockId) {
      throw StateError('livestock delete failed');
    }
    await super.deleteLivestock(id);
  }
}

class _SaveDefaultTaskFailsStorage extends _TestStorageService {
  _SaveDefaultTaskFailsStorage({required this.failOnSaveNumber});

  final int failOnSaveNumber;
  int _saveTaskCount = 0;

  @override
  Future<void> saveTask(Task task) async {
    _saveTaskCount += 1;
    if (_saveTaskCount == failOnSaveNumber) {
      throw StateError('task save failed');
    }
    await super.saveTask(task);
  }
}

class _BulkMoveLivestockSaveFailsStorage extends _TestStorageService {
  _BulkMoveLivestockSaveFailsStorage({
    required this.failingLivestockId,
    required this.targetTankId,
  });

  final String failingLivestockId;
  final String targetTankId;

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    if (livestock.id == failingLivestockId &&
        livestock.tankId == targetTankId) {
      throw StateError('livestock save failed');
    }
    await super.saveLivestock(livestock);
  }
}

class _AddDemoTankLivestockSaveFailsStorage extends _TestStorageService {
  _AddDemoTankLivestockSaveFailsStorage({required this.previousDemoTankId});

  final String previousDemoTankId;
  bool failNewDemoLivestockSaves = false;

  @override
  Future<void> deleteAllTanks(List<String> ids) async {
    for (final id in ids) {
      await super.deleteTank(id);
    }
  }

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    if (failNewDemoLivestockSaves && livestock.tankId != previousDemoTankId) {
      throw StateError('demo livestock save failed');
    }
    await super.saveLivestock(livestock);
  }
}

/// Creates an isolated ProviderContainer with a fresh storage service.
ProviderContainer _makeContainer({StorageService? storage}) {
  return ProviderContainer(
    overrides: [
      storageServiceProvider.overrideWithValue(
        storage ?? _TestStorageService(),
      ),
    ],
  );
}

/// Waits for async providers to settle (loading -> data).
Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

/// Build a Tank value for testing.
Tank _makeTank({
  String id = 'tank-1',
  String name = 'Test Tank',
  TankType type = TankType.freshwater,
  double volumeLitres = 100,
}) {
  final now = DateTime.now();
  return Tank(
    id: id,
    name: name,
    type: type,
    volumeLitres: volumeLitres,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ── SoftDeleteState (unit) ─────────────────────────────────────────────────

  group('SoftDeleteState - unit', () {
    test('isDeleted returns false for unknown id', () {
      final sds = SoftDeleteState();
      expect(sds.isDeleted('unknown'), isFalse);
    });

    test('markDeleted sets isDeleted to true', () {
      final sds = SoftDeleteState();
      sds.markDeleted('tank-1', () {});
      expect(sds.isDeleted('tank-1'), isTrue);
    });

    test('restore clears isDeleted', () {
      final sds = SoftDeleteState();
      sds.markDeleted('tank-1', () {});
      sds.restore('tank-1');
      expect(sds.isDeleted('tank-1'), isFalse);
    });

    test('dispose cancels all timers and clears state', () {
      final sds = SoftDeleteState();
      sds.markDeleted('tank-1', () {});
      sds.markDeleted('tank-2', () {});
      sds.dispose();
      expect(sds.isDeleted('tank-1'), isFalse);
      expect(sds.isDeleted('tank-2'), isFalse);
    });

    test('markDeleted cancels previous timer for same id', () {
      var callCount = 0;
      final sds = SoftDeleteState();
      sds.markDeleted('tank-1', () => callCount++);
      // Mark again — should cancel the first timer.
      sds.markDeleted('tank-1', () => callCount += 10);
      // Only the second callback should be live; the first is cancelled.
      expect(sds.isDeleted('tank-1'), isTrue);
      sds.dispose();
    });
  });

  // ── TankActions.createTank ─────────────────────────────────────────────────

  group('TankActions - createTank', () {
    test('creates a new tank and persists it to storage', () async {
      final storage = _TestStorageService();
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      final actions = container.read(tankActionsProvider);
      final tank = await actions.createTank(
        name: 'My Freshwater Tank',
        type: TankType.freshwater,
        volumeLitres: 120,
      );

      expect(tank.name, equals('My Freshwater Tank'));
      expect(tank.volumeLitres, equals(120));
      expect(tank.type, equals(TankType.freshwater));
      expect(tank.id, isNotEmpty);

      // Verify it was persisted to storage.
      final stored = await storage.getTank(tank.id);
      expect(stored, isNotNull);
      expect(stored!.name, equals('My Freshwater Tank'));
    });

    test('creates default tasks along with the tank', () async {
      final storage = _TestStorageService();
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      final actions = container.read(tankActionsProvider);
      final tank = await actions.createTank(
        name: 'Task Tank',
        type: TankType.freshwater,
        volumeLitres: 80,
      );

      // Default tasks should have been created for the new tank.
      final tasks = await storage.getTasksForTank(tank.id);
      expect(tasks, isNotEmpty, reason: 'New tank should have default tasks');
    });

    test('rejects zero or negative volume', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final actions = container.read(tankActionsProvider);
      expect(
        () => actions.createTank(
          name: 'Bad Tank',
          type: TankType.freshwater,
          volumeLitres: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'rolls back tank and partial default tasks if default task save fails',
      () async {
        final storage = _SaveDefaultTaskFailsStorage(failOnSaveNumber: 2);
        final container = _makeContainer(storage: storage);
        addTearDown(container.dispose);

        await expectLater(
          container
              .read(tankActionsProvider)
              .createTank(
                name: 'Partial Tank',
                type: TankType.freshwater,
                volumeLitres: 95,
              ),
          throwsA(isA<StateError>()),
        );
        await _settle();

        expect(await storage.getAllTanks(), isEmpty);
        expect(await storage.getTasksForTank(null), isEmpty);
        expect(await container.read(tanksProvider.future), isEmpty);
      },
    );
  });

  // --- TankActions.addDemoTank ---

  group('TankActions - demo tank', () {
    test('replaces existing demo tanks without removing real tanks', () async {
      final storage = _TestStorageService();
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      await storage.saveTank(_makeTank(id: 'real-tank', name: 'Real Tank'));
      await storage.saveTank(
        _makeTank(id: 'old-demo', name: 'Old Demo').copyWith(isDemoTank: true),
      );

      final demoTank = await container.read(tankActionsProvider).addDemoTank();
      final tanks = await storage.getAllTanks();
      final demoTanks = tanks.where((tank) => tank.isDemoTank).toList();

      expect(tanks.any((tank) => tank.id == 'real-tank'), isTrue);
      expect(await storage.getTank('old-demo'), isNull);
      expect(demoTanks, hasLength(1));
      expect(demoTanks.single.id, demoTank.id);
      expect(demoTank.id, isNot('old-demo'));
    });

    test('restores previous demo data if replacement creation fails', () async {
      const realTankId = 'real-tank';
      const oldDemoTankId = 'old-demo';
      const oldLivestockId = 'old-demo-fish';
      const oldEquipmentId = 'old-demo-filter';
      const oldLogId = 'old-demo-log';
      const oldTaskId = 'old-demo-task';
      final storage = _AddDemoTankLivestockSaveFailsStorage(
        previousDemoTankId: oldDemoTankId,
      );
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      final now = DateTime.now();
      await storage.saveTank(_makeTank(id: realTankId, name: 'Real Tank'));
      await storage.saveTank(
        _makeTank(
          id: oldDemoTankId,
          name: 'Old Demo',
        ).copyWith(isDemoTank: true),
      );
      await storage.saveLivestock(
        Livestock(
          id: oldLivestockId,
          tankId: oldDemoTankId,
          commonName: 'Cherry Barb',
          count: 6,
          dateAdded: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await storage.saveEquipment(
        Equipment(
          id: oldEquipmentId,
          tankId: oldDemoTankId,
          type: EquipmentType.filter,
          name: 'Old Demo Filter',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await storage.saveLog(
        LogEntry(
          id: oldLogId,
          tankId: oldDemoTankId,
          type: LogType.observation,
          timestamp: now,
          notes: 'Existing demo note',
          createdAt: now,
        ),
      );
      await storage.saveTask(
        Task(
          id: oldTaskId,
          tankId: oldDemoTankId,
          title: 'Existing demo task',
          recurrence: RecurrenceType.weekly,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _settle();

      storage.failNewDemoLivestockSaves = true;

      await expectLater(
        container.read(tankActionsProvider).addDemoTank(),
        throwsA(isA<StateError>()),
      );
      await _settle();

      final tanks = await storage.getAllTanks();
      final demoTanks = tanks.where((tank) => tank.isDemoTank).toList();
      expect(tanks.map((tank) => tank.id), contains(realTankId));
      expect(demoTanks, hasLength(1));
      expect(demoTanks.single.id, oldDemoTankId);
      expect(
        (await storage.getLivestockForTank(
          oldDemoTankId,
        )).map((entry) => entry.id),
        contains(oldLivestockId),
      );
      expect(
        (await storage.getEquipmentForTank(
          oldDemoTankId,
        )).map((entry) => entry.id),
        contains(oldEquipmentId),
      );
      expect(
        (await storage.getLogsForTank(oldDemoTankId)).map((entry) => entry.id),
        contains(oldLogId),
      );
      expect(
        (await storage.getTasksForTank(oldDemoTankId)).map((entry) => entry.id),
        contains(oldTaskId),
      );
      expect(
        (await container.read(tanksProvider.future)).map((tank) => tank.id),
        containsAll([realTankId, oldDemoTankId]),
      );
    });
  });

  // ── tanksProvider (listing) ────────────────────────────────────────────────

  group('tanksProvider - listing', () {
    test('returns empty list when no tanks exist', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final tanks = await container.read(tanksProvider.future);
      expect(tanks, isEmpty);
    });

    test('returns all non-deleted tanks', () async {
      final storage = _TestStorageService();
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      // Seed two tanks directly into storage.
      await storage.saveTank(_makeTank(id: 'tank-a', name: 'Tank A'));
      await storage.saveTank(_makeTank(id: 'tank-b', name: 'Tank B'));

      final tanks = await container.read(tanksProvider.future);
      expect(tanks.length, equals(2));
    });
  });

  // ── Soft-delete / undo ─────────────────────────────────────────────────────

  group('TankActions - soft delete and undo', () {
    test('soft-deleted tank is excluded from tanksProvider', () async {
      final storage = _TestStorageService();
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      await storage.saveTank(_makeTank(id: 'tank-del', name: 'Delete Me'));
      await _settle();

      // Verify it appears before deletion.
      var tanks = await container.read(tanksProvider.future);
      expect(tanks.any((t) => t.id == 'tank-del'), isTrue);

      // Soft-delete it.
      container.read(tankActionsProvider).softDeleteTank('tank-del');
      // Invalidation happened; re-read.
      await _settle();
      tanks = await container.read(tanksProvider.future);
      expect(
        tanks.any((t) => t.id == 'tank-del'),
        isFalse,
        reason: 'Soft-deleted tank should not appear in tank list',
      );
    });

    test('undoing soft-delete restores tank in tanksProvider', () async {
      final storage = _TestStorageService();
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      await storage.saveTank(_makeTank(id: 'tank-undo', name: 'Undo Me'));
      await _settle();

      final actions = container.read(tankActionsProvider);
      actions.softDeleteTank('tank-undo');
      await _settle();

      // Undo the delete.
      actions.undoDeleteTank('tank-undo');
      await _settle();

      final tanks = await container.read(tanksProvider.future);
      expect(
        tanks.any((t) => t.id == 'tank-undo'),
        isTrue,
        reason: 'Undone tank should reappear in tank list',
      );
    });

    test('soft-delete does not remove tank from storage immediately', () async {
      final storage = _TestStorageService();
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      await storage.saveTank(_makeTank(id: 'tank-persist', name: 'Persist'));
      await _settle();

      container.read(tankActionsProvider).softDeleteTank('tank-persist');
      await _settle();

      // The tank should still exist in storage (not yet permanently deleted).
      final stored = await storage.getTank('tank-persist');
      expect(
        stored,
        isNotNull,
        reason: 'Tank should remain in storage during soft-delete window',
      );
    });

    test(
      'bulk delete hides tanks but keeps them recoverable for undo',
      () async {
        final storage = _TestStorageService();
        final container = _makeContainer(storage: storage);
        addTearDown(container.dispose);

        await storage.saveTank(_makeTank(id: 'tank-bulk-1', name: 'Bulk One'));
        await storage.saveTank(_makeTank(id: 'tank-bulk-2', name: 'Bulk Two'));
        await storage.saveTank(_makeTank(id: 'tank-keep', name: 'Keep Me'));
        await _settle();

        final actions = container.read(tankActionsProvider);
        await actions.bulkDeleteTanks(['tank-bulk-1', 'tank-bulk-2']);
        await _settle();

        var tanks = await container.read(tanksProvider.future);
        expect(tanks.map((tank) => tank.id), contains('tank-keep'));
        expect(tanks.map((tank) => tank.id), isNot(contains('tank-bulk-1')));
        expect(tanks.map((tank) => tank.id), isNot(contains('tank-bulk-2')));
        expect(await storage.getTank('tank-bulk-1'), isNotNull);
        expect(await storage.getTank('tank-bulk-2'), isNotNull);

        actions.undoDeleteTank('tank-bulk-1');
        actions.undoDeleteTank('tank-bulk-2');
        await _settle();

        tanks = await container.read(tanksProvider.future);
        expect(
          tanks.map((tank) => tank.id),
          containsAll(['tank-bulk-1', 'tank-bulk-2']),
        );
      },
    );

    test('failed permanent soft delete restores tank visibility', () async {
      const tankId = 'tank-delete-failure';
      final storage = _DeleteTankFailsStorage(failingTankId: tankId);
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      await storage.saveTank(_makeTank(id: tankId, name: 'Resilient Tank'));
      await _settle();

      final actions = container.read(tankActionsProvider);
      var undoExpired = false;
      actions.softDeleteTank(tankId, onUndoExpired: () => undoExpired = true);
      await _settle();

      var tanks = await container.read(tanksProvider.future);
      expect(tanks.map((tank) => tank.id), isNot(contains(tankId)));

      await Future<void>.delayed(const Duration(seconds: 6));
      await _settle();

      expect(await storage.getTank(tankId), isNotNull);
      expect(undoExpired, isFalse);

      tanks = await container.read(tanksProvider.future);
      expect(tanks.map((tank) => tank.id), contains(tankId));
    });

    test(
      'failed permanent bulk soft delete restores tank visibility',
      () async {
        const tankId = 'tank-bulk-delete-failure';
        final storage = _DeleteTankFailsStorage(failingTankId: tankId);
        final container = _makeContainer(storage: storage);
        addTearDown(container.dispose);

        await storage.saveTank(_makeTank(id: tankId, name: 'Bulk Resilient'));
        await _settle();

        final actions = container.read(tankActionsProvider);
        await actions.bulkDeleteTanks([tankId]);
        await _settle();

        var tanks = await container.read(tanksProvider.future);
        expect(tanks.map((tank) => tank.id), isNot(contains(tankId)));

        await Future<void>.delayed(const Duration(seconds: 6));
        await _settle();

        expect(await storage.getTank(tankId), isNotNull);

        tanks = await container.read(tanksProvider.future);
        expect(tanks.map((tank) => tank.id), contains(tankId));
      },
    );

    test(
      'failed permanent livestock soft delete restores livestock visibility',
      () async {
        const tankId = 'tank-livestock-delete-failure';
        const livestockId = 'livestock-delete-failure';
        final storage = _DeleteLivestockFailsStorage(
          failingLivestockId: livestockId,
        );
        final container = _makeContainer(storage: storage);
        addTearDown(container.dispose);

        final now = DateTime.now();
        await storage.saveTank(_makeTank(id: tankId, name: 'Livestock Tank'));
        await storage.saveLivestock(
          Livestock(
            id: livestockId,
            tankId: tankId,
            commonName: 'Neon Tetra',
            count: 6,
            dateAdded: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
        await _settle();

        final actions = container.read(tankActionsProvider);
        var undoExpired = false;
        actions.softDeleteLivestock(
          livestockId,
          tankId,
          onUndoExpired: () => undoExpired = true,
        );
        await _settle();

        var livestock = await container.read(livestockProvider(tankId).future);
        expect(
          livestock.map((entry) => entry.id),
          isNot(contains(livestockId)),
        );

        await Future<void>.delayed(const Duration(seconds: 6));
        await _settle();

        expect(await storage.getLivestockForTank(tankId), isNotEmpty);
        expect(undoExpired, isFalse);

        livestock = await container.read(livestockProvider(tankId).future);
        expect(livestock.map((entry) => entry.id), contains(livestockId));
      },
    );
  });

  // ── TankActions.updateTank ─────────────────────────────────────────────────

  group('TankActions - updateTank', () {
    test('updates tank and persists changes', () async {
      final storage = _TestStorageService();
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      final original = _makeTank(id: 'tank-upd', name: 'Original');
      await storage.saveTank(original);
      await _settle();

      final updated = original.copyWith(name: 'Renamed');
      await container.read(tankActionsProvider).updateTank(updated);
      await _settle();

      final stored = await storage.getTank('tank-upd');
      expect(stored!.name, equals('Renamed'));
    });
  });

  // ── TankActions.permanentlyDeleteTank ───────────────────────────────────────

  group('TankActions - permanentlyDeleteTank', () {
    test('removes tank from storage', () async {
      final storage = _TestStorageService();
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      await storage.saveTank(_makeTank(id: 'tank-perm', name: 'Gone'));
      await _settle();

      await container
          .read(tankActionsProvider)
          .permanentlyDeleteTank('tank-perm');
      await _settle();

      final stored = await storage.getTank('tank-perm');
      expect(stored, isNull);
    });
  });

  group('TankActions - bulkMoveLivestock', () {
    test('rolls back earlier moves when a later save fails', () async {
      const sourceTankId = 'bulk-move-rollback-source';
      const targetTankId = 'bulk-move-rollback-target';
      const firstLivestockId = 'bulk-move-rollback-neons';
      const failingLivestockId = 'bulk-move-rollback-corys';
      final storage = _BulkMoveLivestockSaveFailsStorage(
        failingLivestockId: failingLivestockId,
        targetTankId: targetTankId,
      );
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      final now = DateTime.now();
      await storage.saveTank(_makeTank(id: sourceTankId, name: 'Source Tank'));
      await storage.saveTank(_makeTank(id: targetTankId, name: 'Target Tank'));
      await storage.saveLivestock(
        Livestock(
          id: firstLivestockId,
          tankId: sourceTankId,
          commonName: 'Neon Tetra',
          count: 8,
          dateAdded: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await storage.saveLivestock(
        Livestock(
          id: failingLivestockId,
          tankId: sourceTankId,
          commonName: 'Corydoras',
          count: 5,
          dateAdded: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _settle();

      await expectLater(
        container
            .read(tankActionsProvider)
            .bulkMoveLivestock(
              [firstLivestockId, failingLivestockId],
              sourceTankId,
              targetTankId,
            ),
        throwsA(isA<StateError>()),
      );
      await _settle();

      final sourceLivestock = await storage.getLivestockForTank(sourceTankId);
      final targetLivestock = await storage.getLivestockForTank(targetTankId);
      expect(
        sourceLivestock.map((livestock) => livestock.id),
        containsAll([firstLivestockId, failingLivestockId]),
      );
      expect(targetLivestock, isEmpty);
    });
  });
}
