import 'package:flutter_test/flutter_test.dart';

import 'package:danio/features/smart/intelligence/aquarium_intelligence_service.dart';
import 'package:danio/features/smart/models/smart_models.dart';
import 'package:danio/models/models.dart';

void main() {
  group('AquariumIntelligenceService', () {
    test('flags unsafe ammonia as a critical local risk', () {
      final now = DateTime(2026, 6, 13, 12);
      final tank = _tank(now: now);

      final report = AquariumIntelligenceService.evaluate(
        now: now,
        tanks: [
          AquariumIntelligenceTankInput(
            tank: tank,
            logs: [
              _waterTestLog(
                tankId: tank.id,
                timestamp: now.subtract(const Duration(hours: 1)),
                ammonia: 0.5,
                nitrite: 0,
              ),
            ],
            tasks: const [],
            livestock: const [],
            equipment: const [],
          ),
        ],
      );

      expect(report.tankCount, 1);
      expect(report.criticalRiskCount, 1);

      final item = report.items.singleWhere(
        (item) => item.title == 'Unsafe water detected',
      );
      expect(item.severity, AquariumIntelligenceSeverity.critical);
      expect(item.category, AquariumIntelligenceCategory.risk);
      expect(item.action, AquariumIntelligenceAction.emergencyGuide);
      expect(item.actionLabel, 'Emergency Guide');
      expect(item.reason, contains('Ammonia 0.50 ppm'));
    });

    test('suggests water testing when the latest test is stale', () {
      final now = DateTime(2026, 6, 13, 12);
      final tank = _tank(now: now);

      final report = AquariumIntelligenceService.evaluate(
        now: now,
        tanks: [
          AquariumIntelligenceTankInput(
            tank: tank,
            logs: [
              _waterTestLog(
                tankId: tank.id,
                timestamp: now.subtract(const Duration(days: 10)),
                ammonia: 0,
                nitrite: 0,
              ),
            ],
            tasks: const [],
            livestock: const [],
            equipment: const [],
          ),
        ],
      );

      final item = report.items.singleWhere(
        (item) => item.title == 'Water test due',
      );
      expect(item.severity, AquariumIntelligenceSeverity.warning);
      expect(item.category, AquariumIntelligenceCategory.care);
      expect(item.action, AquariumIntelligenceAction.waterTest);
      expect(item.reason, contains('last water test is 10 days old'));
    });

    test('surfaces overdue care tasks', () {
      final now = DateTime(2026, 6, 13, 12);
      final tank = _tank(now: now);

      final report = AquariumIntelligenceService.evaluate(
        now: now,
        tanks: [
          AquariumIntelligenceTankInput(
            tank: tank,
            logs: [_safeWaterTest(tank.id, now)],
            tasks: [
              _task(
                tankId: tank.id,
                title: 'Weekly Water Change',
                dueDate: now.subtract(const Duration(days: 2)),
              ),
            ],
            livestock: const [],
            equipment: const [],
          ),
        ],
      );

      final item = report.items.singleWhere(
        (item) => item.title == 'Care task overdue',
      );
      expect(item.category, AquariumIntelligenceCategory.care);
      expect(item.action, AquariumIntelligenceAction.tankDetail);
      expect(item.reason, contains('Weekly Water Change'));
    });

    test('surfaces livestock health and compatibility issues', () {
      final now = DateTime(2026, 6, 13, 12);
      final tank = _tank(now: now);

      final report = AquariumIntelligenceService.evaluate(
        now: now,
        tanks: [
          AquariumIntelligenceTankInput(
            tank: tank,
            logs: [_safeWaterTest(tank.id, now)],
            tasks: const [],
            livestock: [
              _livestock(
                tankId: tank.id,
                commonName: 'Neon Tetra',
                count: 2,
                healthStatus: HealthStatus.sick,
                now: now,
              ),
            ],
            equipment: const [],
          ),
        ],
      );

      expect(
        report.items.any(
          (item) => item.title == 'Livestock health needs review',
        ),
        isTrue,
      );
      final compatibility = report.items.singleWhere(
        (item) => item.title == 'Compatibility needs review',
      );
      expect(
        compatibility.category,
        AquariumIntelligenceCategory.compatibility,
      );
      expect(compatibility.action, AquariumIntelligenceAction.workshop);
      expect(compatibility.reason, contains('Needs a larger school'));
    });

    test('surfaces active anomaly history', () {
      final now = DateTime(2026, 6, 13, 12);
      final tank = _tank(now: now);

      final report = AquariumIntelligenceService.evaluate(
        now: now,
        tanks: [
          AquariumIntelligenceTankInput(
            tank: tank,
            logs: [_safeWaterTest(tank.id, now)],
            tasks: const [],
            livestock: const [],
            equipment: const [],
            anomalies: [
              _anomaly(
                tankId: tank.id,
                description: 'pH changed quickly',
                severity: AnomalySeverity.alert,
                detectedAt: now.subtract(const Duration(hours: 3)),
              ),
            ],
          ),
        ],
      );

      final item = report.items.singleWhere(
        (item) => item.title == 'Anomaly history needs review',
      );
      expect(item.category, AquariumIntelligenceCategory.anomaly);
      expect(item.action, AquariumIntelligenceAction.tankDetail);
      expect(item.reason, contains('pH changed quickly'));
      expect(report.activeAnomalyCount, 1);
    });

    test('surfaces overdue equipment maintenance', () {
      final now = DateTime(2026, 6, 13, 12);
      final tank = _tank(now: now);

      final report = AquariumIntelligenceService.evaluate(
        now: now,
        tanks: [
          AquariumIntelligenceTankInput(
            tank: tank,
            logs: [_safeWaterTest(tank.id, now)],
            tasks: const [],
            livestock: const [],
            equipment: [
              _equipment(
                tankId: tank.id,
                now: now,
                lastServiced: now.subtract(const Duration(days: 45)),
                maintenanceIntervalDays: 30,
              ),
            ],
          ),
        ],
      );

      final item = report.items.singleWhere(
        (item) => item.title == 'Equipment maintenance overdue',
      );
      expect(item.category, AquariumIntelligenceCategory.equipment);
      expect(item.action, AquariumIntelligenceAction.tankDetail);
      expect(item.reason, contains('Filter'));
      expect(report.careActionCount, 1);
    });
  });
}

Tank _tank({required DateTime now, String id = 'tank-1'}) {
  return Tank(
    id: id,
    name: 'River Room',
    type: TankType.freshwater,
    volumeLitres: 100,
    startDate: now.subtract(const Duration(days: 60)),
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

LogEntry _waterTestLog({
  required String tankId,
  required DateTime timestamp,
  double? temperature,
  double? ph,
  double? ammonia,
  double? nitrite,
  double? nitrate,
}) {
  return LogEntry(
    id: 'log-$tankId-${timestamp.millisecondsSinceEpoch}',
    tankId: tankId,
    type: LogType.waterTest,
    timestamp: timestamp,
    waterTest: WaterTestResults(
      temperature: temperature,
      ph: ph,
      ammonia: ammonia,
      nitrite: nitrite,
      nitrate: nitrate,
    ),
    createdAt: timestamp,
  );
}

LogEntry _safeWaterTest(String tankId, DateTime now) {
  return _waterTestLog(
    tankId: tankId,
    timestamp: now.subtract(const Duration(hours: 2)),
    temperature: 25,
    ph: 7.2,
    ammonia: 0,
    nitrite: 0,
    nitrate: 20,
  );
}

Task _task({
  required String tankId,
  required String title,
  required DateTime dueDate,
}) {
  final now = DateTime(2026, 6, 13, 12);
  return Task(
    id: 'task-$tankId-$title',
    tankId: tankId,
    title: title,
    recurrence: RecurrenceType.weekly,
    dueDate: dueDate,
    priority: TaskPriority.high,
    createdAt: now,
    updatedAt: now,
  );
}

Livestock _livestock({
  required String tankId,
  required String commonName,
  required int count,
  required DateTime now,
  HealthStatus healthStatus = HealthStatus.healthy,
}) {
  return Livestock(
    id: 'livestock-$tankId-$commonName',
    tankId: tankId,
    commonName: commonName,
    count: count,
    dateAdded: now.subtract(const Duration(days: 30)),
    healthStatus: healthStatus,
    createdAt: now,
    updatedAt: now,
  );
}

Equipment _equipment({
  required String tankId,
  required DateTime now,
  required DateTime lastServiced,
  required int maintenanceIntervalDays,
}) {
  return Equipment(
    id: 'equipment-$tankId-filter',
    tankId: tankId,
    type: EquipmentType.filter,
    name: 'Filter',
    maintenanceIntervalDays: maintenanceIntervalDays,
    lastServiced: lastServiced,
    installedDate: now.subtract(const Duration(days: 120)),
    createdAt: now,
    updatedAt: now,
  );
}

Anomaly _anomaly({
  required String tankId,
  required String description,
  required AnomalySeverity severity,
  required DateTime detectedAt,
}) {
  return Anomaly(
    id: 'anomaly-$tankId',
    tankId: tankId,
    parameter: 'pH',
    description: description,
    severity: severity,
    detectedAt: detectedAt,
  );
}
