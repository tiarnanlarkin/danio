import '../models/models.dart';

/// Abstract storage interface - can be backed by memory, Hive, SQLite, etc.
abstract class StorageService {
  // Tanks
  Future<List<Tank>> getAllTanks();
  Future<Tank?> getTank(String id);
  Future<void> saveTank(Tank tank);
  Future<void> deleteTank(String id);

  // Livestock
  Future<List<Livestock>> getLivestockForTank(String tankId);
  Future<void> saveLivestock(Livestock livestock);
  Future<void> deleteLivestock(String id);

  // Equipment
  Future<List<Equipment>> getEquipmentForTank(String tankId);
  Future<void> saveEquipment(Equipment equipment);
  Future<void> deleteEquipment(String id);

  // Logs
  Future<List<LogEntry>> getLogsForTank(String tankId, {int? limit, DateTime? after});
  Future<void> saveLog(LogEntry log);
  Future<void> deleteLog(String id);

  // Tasks
  Future<List<Task>> getTasksForTank(String? tankId); // null = all tasks
  Future<void> saveTask(Task task);
  Future<void> deleteTask(String id);
}

/// In-memory implementation for development and testing
class InMemoryStorageService implements StorageService {
  final Map<String, Tank> _tanks = {};
  final Map<String, Livestock> _livestock = {};
  final Map<String, Equipment> _equipment = {};
  final Map<String, LogEntry> _logs = {};
  final Map<String, Task> _tasks = {};

  // Singleton
  static final InMemoryStorageService _instance = InMemoryStorageService._();
  factory InMemoryStorageService() => _instance;
  InMemoryStorageService._();

  // --- Tanks ---
  @override
  Future<List<Tank>> getAllTanks() async {
    return _tanks.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Tank?> getTank(String id) async => _tanks[id];

  @override
  Future<void> saveTank(Tank tank) async {
    _tanks[tank.id] = tank;
  }

  @override
  Future<void> deleteTank(String id) async {
    _tanks.remove(id);
    // Also delete related data
    _livestock.removeWhere((_, v) => v.tankId == id);
    _equipment.removeWhere((_, v) => v.tankId == id);
    _logs.removeWhere((_, v) => v.tankId == id);
    _tasks.removeWhere((_, v) => v.tankId == id);
  }

  // --- Livestock ---
  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) async {
    return _livestock.values.where((l) => l.tankId == tankId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    _livestock[livestock.id] = livestock;
  }

  @override
  Future<void> deleteLivestock(String id) async {
    _livestock.remove(id);
  }

  // --- Equipment ---
  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) async {
    return _equipment.values.where((e) => e.tankId == tankId).toList()
      ..sort((a, b) => a.type.index.compareTo(b.type.index));
  }

  @override
  Future<void> saveEquipment(Equipment equipment) async {
    _equipment[equipment.id] = equipment;
  }

  @override
  Future<void> deleteEquipment(String id) async {
    _equipment.remove(id);
  }

  // --- Logs ---
  @override
  Future<List<LogEntry>> getLogsForTank(String tankId, {int? limit, DateTime? after}) async {
    var logs = _logs.values.where((l) => l.tankId == tankId).toList();
    if (after != null) {
      logs = logs.where((l) => l.timestamp.isAfter(after)).toList();
    }
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null && logs.length > limit) {
      logs = logs.take(limit).toList();
    }
    return logs;
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    _logs[log.id] = log;
  }

  @override
  Future<void> deleteLog(String id) async {
    _logs.remove(id);
  }

  // --- Tasks ---
  @override
  Future<List<Task>> getTasksForTank(String? tankId) async {
    var tasks = _tasks.values.toList();
    if (tankId != null) {
      tasks = tasks.where((t) => t.tankId == tankId).toList();
    }
    tasks.sort((a, b) {
      // Overdue first, then by due date
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return tasks;
  }

  @override
  Future<void> saveTask(Task task) async {
    _tasks[task.id] = task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.remove(id);
  }

  /// Add demo data for testing
  Future<void> addDemoData() async {
    final now = DateTime.now();

    // Demo tank
    final tank = Tank(
      id: 'demo-tank-1',
      name: 'Living Room Tank',
      type: TankType.freshwater,
      volumeLitres: 120,
      lengthCm: 80,
      widthCm: 40,
      heightCm: 40,
      startDate: now.subtract(const Duration(days: 60)),
      targets: WaterTargets.freshwaterTropical(),
      notes: 'Planted community tank',
      isDemoTank: true,
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    );
    await saveTank(tank);

    // Demo livestock
    final livestock = [
      Livestock(
        id: 'demo-fish-1',
        tankId: tank.id,
        commonName: 'Neon Tetra',
        scientificName: 'Paracheirodon innesi',
        count: 12,
        sizeCm: 2.5,
        maxSizeCm: 4,
        dateAdded: now.subtract(const Duration(days: 45)),
        temperament: Temperament.peaceful,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now,
      ),
      Livestock(
        id: 'demo-fish-2',
        tankId: tank.id,
        commonName: 'Corydoras',
        scientificName: 'Corydoras aeneus',
        count: 6,
        sizeCm: 4,
        maxSizeCm: 7,
        dateAdded: now.subtract(const Duration(days: 30)),
        temperament: Temperament.peaceful,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
    ];
    for (final l in livestock) {
      await saveLivestock(l);
    }

    // Demo equipment
    final equipment = [
      Equipment(
        id: 'demo-equip-1',
        tankId: tank.id,
        type: EquipmentType.filter,
        name: 'Fluval 307',
        brand: 'Fluval',
        model: '307',
        maintenanceIntervalDays: 30,
        lastServiced: now.subtract(const Duration(days: 20)),
        installedDate: now.subtract(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
      Equipment(
        id: 'demo-equip-2',
        tankId: tank.id,
        type: EquipmentType.heater,
        name: 'Eheim Jäger 150W',
        brand: 'Eheim',
        settings: {'targetTemp': 26.0},
        installedDate: now.subtract(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
      Equipment(
        id: 'demo-equip-3',
        tankId: tank.id,
        type: EquipmentType.light,
        name: 'Fluval Plant 3.0',
        brand: 'Fluval',
        settings: {'hoursPerDay': 8},
        installedDate: now.subtract(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
    ];
    for (final e in equipment) {
      await saveEquipment(e);
    }

    // Demo logs
    final logs = [
      LogEntry(
        id: 'demo-log-1',
        tankId: tank.id,
        type: LogType.waterTest,
        timestamp: now.subtract(const Duration(days: 1)),
        waterTest: const WaterTestResults(
          temperature: 25.5,
          ph: 7.0,
          ammonia: 0,
          nitrite: 0,
          nitrate: 15,
        ),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      LogEntry(
        id: 'demo-log-2',
        tankId: tank.id,
        type: LogType.waterChange,
        timestamp: now.subtract(const Duration(days: 3)),
        waterChangePercent: 25,
        notes: 'Routine weekly water change',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
    for (final l in logs) {
      await saveLog(l);
    }

    // Demo tasks
    final tasks = DefaultTasks.forNewTank(tank.id);
    for (final t in tasks) {
      await saveTask(t);
    }
  }
}
