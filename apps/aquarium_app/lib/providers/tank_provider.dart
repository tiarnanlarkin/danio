import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/sample_data.dart';
import 'storage_provider.dart';

const _uuid = Uuid();

/// All tanks list
final tanksProvider = FutureProvider<List<Tank>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getAllTanks();
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
  }

  /// Update an existing tank
  Future<void> updateTank(Tank tank) async {
    final updated = tank.copyWith(updatedAt: DateTime.now());
    await _storage.saveTank(updated);
    _ref.invalidate(tanksProvider);
    _ref.invalidate(tankProvider(tank.id));
  }

  /// Delete a tank and all related data
  Future<void> deleteTank(String id) async {
    await _storage.deleteTank(id);
    _ref.invalidate(tanksProvider);
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

/// Livestock for a tank
final livestockProvider = FutureProvider.family<List<Livestock>, String>((ref, tankId) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getLivestockForTank(tankId);
});

/// Equipment for a tank
final equipmentProvider = FutureProvider.family<List<Equipment>, String>((ref, tankId) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getEquipmentForTank(tankId);
});

/// Logs for a tank (recent only; used for previews / activity lists)
final logsProvider = FutureProvider.family<List<LogEntry>, String>((ref, tankId) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getLogsForTank(tankId, limit: 50);
});

/// All logs for a tank (used for charts/exports)
final allLogsProvider = FutureProvider.family<List<LogEntry>, String>((ref, tankId) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getLogsForTank(tankId);
});

/// Tasks for a tank (null = all tasks)
final tasksProvider = FutureProvider.family<List<Task>, String?>((ref, tankId) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getTasksForTank(tankId);
});
