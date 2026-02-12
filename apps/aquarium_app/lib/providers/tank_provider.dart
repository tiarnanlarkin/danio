import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/sample_data.dart';
import 'storage_provider.dart';

const _uuid = Uuid();

/// Tracks soft-deleted items with their deletion timers
class SoftDeleteState {
  final Map<String, Timer> _timers = {};
  final Set<String> _deletedIds = {};

  bool isDeleted(String id) => _deletedIds.contains(id);

  void markDeleted(String id, void Function() onPermanentDelete) {
    _deletedIds.add(id);
    _timers[id]?.cancel();
    _timers[id] = Timer(const Duration(seconds: 5), () {
      onPermanentDelete();
      _timers.remove(id);
      _deletedIds.remove(id);
    });
  }

  void restore(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    _deletedIds.remove(id);
  }

  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _deletedIds.clear();
  }
}

/// Global soft delete state for tanks (survives provider refreshes during the 5s window)
final _softDeleteState = SoftDeleteState();

/// Global soft delete state for livestock (survives provider refreshes during the 5s window)
final _softDeleteLivestockState = SoftDeleteState();

/// All tanks list (excludes soft-deleted tanks, sorted by sortOrder)
final tanksProvider = FutureProvider<List<Tank>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  final allTanks = await storage.getAllTanks();
  final visibleTanks = allTanks
      .where((tank) => !_softDeleteState.isDeleted(tank.id))
      .toList();
  // Sort by sortOrder, then by createdAt as fallback
  visibleTanks.sort((a, b) {
    final orderCompare = a.sortOrder.compareTo(b.sortOrder);
    if (orderCompare != 0) return orderCompare;
    return a.createdAt.compareTo(b.createdAt);
  });
  return visibleTanks;
});

/// Single tank by ID
final tankProvider = FutureProvider.family<Tank?, String>((ref, id) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getTank(id);
});

/// Tank actions notifier
final tankActionsProvider = Provider((ref) => TankActions(ref));

class TankActions {
  final Ref _ref;

  TankActions(this._ref);

  StorageService get _storage => _ref.read(storageServiceProvider);

  /// Seed a demo tank (only if the user has no tanks yet)
  Future<Tank> seedDemoTankIfEmpty() async {
    final tank = await SampleData.seedFreshwaterDemo(_storage);

    // Invalidate relevant providers.
    _ref.invalidate(tanksProvider);
    _ref.invalidate(tankProvider(tank.id));
    _ref.invalidate(livestockProvider(tank.id));
    _ref.invalidate(equipmentProvider(tank.id));
    _ref.invalidate(logsProvider(tank.id));
    _ref.invalidate(allLogsProvider(tank.id));
    _ref.invalidate(tasksProvider(tank.id));

    return tank;
  }

  /// Add a sample/demo tank even if the user already has existing tanks.
  ///
  /// Used by Settings → "Add Sample Tank".
  Future<Tank> addDemoTank() async {
    final tank = await SampleData.addFreshwaterDemoTank(_storage);

    _ref.invalidate(tanksProvider);
    _ref.invalidate(tankProvider(tank.id));
    _ref.invalidate(livestockProvider(tank.id));
    _ref.invalidate(equipmentProvider(tank.id));
    _ref.invalidate(logsProvider(tank.id));
    _ref.invalidate(allLogsProvider(tank.id));
    _ref.invalidate(tasksProvider(tank.id));

    return tank;
  }

  /// Create a new tank
  Future<Tank> createTank({
    required String name,
    required TankType type,
    required double volumeLitres,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    DateTime? startDate,
    WaterTargets? targets,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final tank = Tank(
        id: _uuid.v4(),
        name: name,
        type: type,
        volumeLitres: volumeLitres,
        lengthCm: lengthCm,
        widthCm: widthCm,
        heightCm: heightCm,
        startDate: startDate ?? now,
        targets: targets ?? WaterTargets.freshwaterTropical(),
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await _storage.saveTank(tank);

      // Create default tasks for the new tank
      final defaultTasks = DefaultTasks.forNewTank(tank.id);
      for (final task in defaultTasks) {
        await _storage.saveTask(task);
      }

      // Invalidate tanks list to refresh
      _ref.invalidate(tanksProvider);

      return tank;
    } catch (e) {
      // Let UI handle the error
      rethrow;
    }
  }

  /// Update an existing tank
  Future<void> updateTank(Tank tank) async {
    try {
      final updated = tank.copyWith(updatedAt: DateTime.now());
      await _storage.saveTank(updated);
      _ref.invalidate(tanksProvider);
      _ref.invalidate(tankProvider(tank.id));
    } catch (e) {
      // Let UI handle the error
      rethrow;
    }
  }

  /// Delete a tank and all related data
  Future<void> deleteTank(String id) async {
    try {
      await _storage.deleteTank(id);
      _ref.invalidate(tanksProvider);
    } catch (e) {
      // Let UI handle the error
      rethrow;
    }
  }

  /// Soft delete a tank (marks for deletion, can be undone within 5 seconds)
  /// Returns a callback to undo the deletion
  void softDeleteTank(String id, {void Function()? onUndoExpired}) {
    _softDeleteState.markDeleted(id, () {
      permanentlyDeleteTank(id);
      onUndoExpired?.call();
    });
    _ref.invalidate(tanksProvider);
  }

  /// Undo a soft delete (restores the tank)
  void undoDeleteTank(String id) {
    _softDeleteState.restore(id);
    _ref.invalidate(tanksProvider);
  }

  /// Permanently delete a tank (called after undo timer expires)
  Future<void> permanentlyDeleteTank(String id) async {
    try {
      await _storage.deleteTank(id);
      _ref.invalidate(tanksProvider);
    } catch (e) {
      // Let UI handle the error
      rethrow;
    }
  }

  /// Bulk delete tanks (with confirmation)
  Future<void> bulkDeleteTanks(List<String> ids) async {
    try {
      for (final id in ids) {
        await _storage.deleteTank(id);
      }
      _ref.invalidate(tanksProvider);
    } catch (e) {
      rethrow;
    }
  }

  /// Reorder tanks - updates sortOrder for all tanks based on new positions
  Future<void> reorderTanks(List<Tank> reorderedTanks) async {
    try {
      for (int i = 0; i < reorderedTanks.length; i++) {
        final tank = reorderedTanks[i];
        if (tank.sortOrder != i) {
          final updated = tank.copyWith(
            sortOrder: i,
            updatedAt: DateTime.now(),
          );
          await _storage.saveTank(updated);
        }
      }
      _ref.invalidate(tanksProvider);
    } catch (e) {
      rethrow;
    }
  }

  /// Add livestock to a tank
  Future<Livestock> addLivestock(Livestock livestock) async {
    try {
      await _storage.saveLivestock(livestock);
      _ref.invalidate(livestockProvider(livestock.tankId));
      return livestock;
    } catch (e) {
      // Let UI handle the error
      rethrow;
    }
  }

  /// Update existing livestock
  Future<void> updateLivestock(Livestock livestock) async {
    try {
      final updated = livestock.copyWith(updatedAt: DateTime.now());
      await _storage.saveLivestock(updated);
      _ref.invalidate(livestockProvider(livestock.tankId));
    } catch (e) {
      // Let UI handle the error
      rethrow;
    }
  }

  /// Delete livestock
  Future<void> deleteLivestock(String id, String tankId) async {
    try {
      await _storage.deleteLivestock(id);
      _ref.invalidate(livestockProvider(tankId));
    } catch (e) {
      // Let UI handle the error
      rethrow;
    }
  }

  /// Soft delete livestock (marks for deletion, can be undone within 5 seconds)
  /// Returns a callback to undo the deletion
  void softDeleteLivestock(
    String id,
    String tankId, {
    void Function()? onUndoExpired,
  }) {
    _softDeleteLivestockState.markDeleted(id, () {
      permanentlyDeleteLivestock(id, tankId);
      onUndoExpired?.call();
    });
    _ref.invalidate(livestockProvider(tankId));
  }

  /// Undo a livestock soft delete (restores the livestock)
  void undoDeleteLivestock(String id, String tankId) {
    _softDeleteLivestockState.restore(id);
    _ref.invalidate(livestockProvider(tankId));
  }

  /// Permanently delete livestock (called after undo timer expires)
  Future<void> permanentlyDeleteLivestock(String id, String tankId) async {
    try {
      await _storage.deleteLivestock(id);
      _ref.invalidate(livestockProvider(tankId));
    } catch (e) {
      // Let UI handle the error
      rethrow;
    }
  }

  /// Move livestock to a different tank
  Future<void> moveLivestock(Livestock livestock, String newTankId) async {
    try {
      final moved = livestock.copyWith(tankId: newTankId);
      await _storage.saveLivestock(moved);

      // Invalidate both tanks
      _ref.invalidate(livestockProvider(livestock.tankId));
      _ref.invalidate(livestockProvider(newTankId));
    } catch (e) {
      rethrow;
    }
  }

  /// Bulk move livestock to a different tank
  Future<void> bulkMoveLivestock(
    List<String> livestockIds,
    String fromTankId,
    String toTankId,
  ) async {
    try {
      final storage = _storage;
      final allLivestock = await storage.getLivestockForTank(fromTankId);

      for (final id in livestockIds) {
        final livestock = allLivestock.firstWhere(
          (l) => l.id == id,
          orElse: () => throw StateError('Livestock not found: $id'),
        );
        final moved = livestock.copyWith(tankId: toTankId);
        await storage.saveLivestock(moved);
      }

      _ref.invalidate(livestockProvider(fromTankId));
      _ref.invalidate(livestockProvider(toTankId));
    } catch (e) {
      rethrow;
    }
  }

  /// Import tanks from JSON backup data
  /// Returns the number of tanks successfully imported
  Future<int> importTanks(List<dynamic> tanksJson) async {
    int imported = 0;
    final now = DateTime.now();

    for (final tankJson in tanksJson) {
      try {
        if (tankJson is! Map<String, dynamic>) continue;

        // Create tank from JSON with a new ID to avoid collisions
        final newId = _uuid.v4();

        final tank = Tank.fromJson({
          ...tankJson,
          'id': newId,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });

        await _storage.saveTank(tank);
        imported++;

        // Note: livestock, equipment, logs would need separate handling
        // with updated tankId references if we wanted full import
      } catch (_) {
        // Skip tanks that fail to parse
        continue;
      }
    }

    if (imported > 0) {
      _ref.invalidate(tanksProvider);
    }

    return imported;
  }
}

/// Livestock for a tank (excludes soft-deleted livestock)
final livestockProvider = FutureProvider.family<List<Livestock>, String>((
  ref,
  tankId,
) async {
  final storage = ref.watch(storageServiceProvider);
  final allLivestock = await storage.getLivestockForTank(tankId);
  return allLivestock
      .where((livestock) => !_softDeleteLivestockState.isDeleted(livestock.id))
      .toList();
});

/// Equipment for a tank
final equipmentProvider = FutureProvider.family<List<Equipment>, String>((
  ref,
  tankId,
) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getEquipmentForTank(tankId);
});

/// Logs for a tank (recent only; used for previews / activity lists)
final logsProvider = FutureProvider.family<List<LogEntry>, String>((
  ref,
  tankId,
) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getLogsForTank(tankId, limit: 50);
});

/// All logs for a tank (used for charts/exports)
final allLogsProvider = FutureProvider.family<List<LogEntry>, String>((
  ref,
  tankId,
) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getLogsForTank(tankId);
});

/// Tasks for a tank (null = all tasks)
final tasksProvider = FutureProvider.family<List<Task>, String?>((
  ref,
  tankId,
) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getTasksForTank(tankId);
});
