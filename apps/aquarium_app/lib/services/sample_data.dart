import 'package:uuid/uuid.dart';

import '../models/models.dart';
import 'storage_service.dart';

const _uuid = Uuid();

/// Service for generating sample tank data for onboarding and demos.
///
/// Provides pre-populated freshwater tank setups with realistic livestock,
/// equipment, logs, and tasks. Used for first-time user experience and testing.
class SampleData {
  static Future<Tank> seedFreshwaterDemo(StorageService storage) async {
    final now = DateTime.now();

    // If there is already a tank, return the most recently updated.
    final existing = await storage.getAllTanks();
    if (existing.isNotEmpty) {
      return existing.first;
    }

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
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    );
    await storage.saveTank(tank);

    // Livestock
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
      await storage.saveLivestock(l);
    }

    // Equipment
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
      await storage.saveEquipment(e);
    }

    // Logs
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
      await storage.saveLog(l);
    }

    // Tasks
    final tasks = DefaultTasks.forNewTank(tank.id);
    for (final t in tasks) {
      await storage.saveTask(t);
    }

    return tank;
  }

  /// Adds a second demo tank even if the user already has tanks.
  ///
  /// Unlike [seedFreshwaterDemo], this always creates a NEW tank with unique IDs.
  static Future<Tank> addFreshwaterDemoTank(StorageService storage) async {
    final now = DateTime.now();

    final tank = Tank(
      id: _uuid.v4(),
      name: 'Sample Tank',
      type: TankType.freshwater,
      volumeLitres: 120,
      lengthCm: 80,
      widthCm: 40,
      heightCm: 40,
      startDate: now.subtract(const Duration(days: 60)),
      targets: WaterTargets.freshwaterTropical(),
      notes: 'Demo data - feel free to edit or delete.',
      createdAt: now,
      updatedAt: now,
    );
    await storage.saveTank(tank);

    final livestock = [
      Livestock(
        id: _uuid.v4(),
        tankId: tank.id,
        commonName: 'Neon Tetra',
        scientificName: 'Paracheirodon innesi',
        count: 12,
        sizeCm: 2.5,
        maxSizeCm: 4,
        dateAdded: now.subtract(const Duration(days: 45)),
        temperament: Temperament.peaceful,
        createdAt: now,
        updatedAt: now,
      ),
      Livestock(
        id: _uuid.v4(),
        tankId: tank.id,
        commonName: 'Corydoras',
        scientificName: 'Corydoras aeneus',
        count: 6,
        sizeCm: 4,
        maxSizeCm: 7,
        dateAdded: now.subtract(const Duration(days: 30)),
        temperament: Temperament.peaceful,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    for (final l in livestock) {
      await storage.saveLivestock(l);
    }

    final equipment = [
      Equipment(
        id: _uuid.v4(),
        tankId: tank.id,
        type: EquipmentType.filter,
        name: 'Fluval 307',
        brand: 'Fluval',
        model: '307',
        maintenanceIntervalDays: 30,
        lastServiced: now.subtract(const Duration(days: 20)),
        installedDate: now.subtract(const Duration(days: 60)),
        createdAt: now,
        updatedAt: now,
      ),
      Equipment(
        id: _uuid.v4(),
        tankId: tank.id,
        type: EquipmentType.heater,
        name: 'Eheim Jäger 150W',
        brand: 'Eheim',
        settings: {'targetTemp': 26.0},
        installedDate: now.subtract(const Duration(days: 60)),
        createdAt: now,
        updatedAt: now,
      ),
      Equipment(
        id: _uuid.v4(),
        tankId: tank.id,
        type: EquipmentType.light,
        name: 'Fluval Plant 3.0',
        brand: 'Fluval',
        settings: {'hoursPerDay': 8},
        installedDate: now.subtract(const Duration(days: 60)),
        createdAt: now,
        updatedAt: now,
      ),
    ];
    for (final e in equipment) {
      await storage.saveEquipment(e);
    }

    final logs = [
      LogEntry(
        id: _uuid.v4(),
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
        createdAt: now,
      ),
      LogEntry(
        id: _uuid.v4(),
        tankId: tank.id,
        type: LogType.waterChange,
        timestamp: now.subtract(const Duration(days: 3)),
        waterChangePercent: 25,
        notes: 'Routine weekly water change',
        createdAt: now,
      ),
    ];
    for (final l in logs) {
      await storage.saveLog(l);
    }

    final tasks = DefaultTasks.forNewTank(tank.id);
    for (final t in tasks) {
      await storage.saveTask(t);
    }

    return tank;
  }
}
