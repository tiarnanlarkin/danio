import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
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

/// Logs for a tank
final logsProvider = FutureProvider.family<List<LogEntry>, String>((ref, tankId) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getLogsForTank(tankId, limit: 50);
});

/// Tasks for a tank (null = all tasks)
final tasksProvider = FutureProvider.family<List<Task>, String?>((ref, tankId) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getTasksForTank(tankId);
});
