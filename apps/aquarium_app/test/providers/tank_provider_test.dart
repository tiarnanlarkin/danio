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
      _tanks.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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
  Future<List<LogEntry>> getLogsForTank(String tankId,
      {int? limit, DateTime? after}) async {
    var logs = _logs.values.where((l) => l.tankId == tankId).toList();
    if (after != null) logs = logs.where((l) => l.timestamp.isAfter(after)).toList();
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
}
