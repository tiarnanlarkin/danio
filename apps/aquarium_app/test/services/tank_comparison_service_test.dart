import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/models.dart';
import 'package:danio/services/tank_comparison_service.dart';

void main() {
  group('TankComparisonService', () {
    test('ranks the tank with worse health as needing attention first', () {
      final now = DateTime(2026, 5, 9, 12);
      final healthy = _tank('healthy', 'Planted 125L', now);
      final risky = _tank('risky', 'Betta 60L', now);

      final healthySummary = TankComparisonService.buildSummary(
        tank: healthy,
        logs: [
          _waterChange(
            'healthy-change',
            healthy.id,
            now.subtract(const Duration(days: 3)),
          ),
          _waterTest(
            'healthy-test',
            healthy.id,
            now.subtract(const Duration(days: 2)),
            ammonia: 0,
            nitrite: 0,
            nitrate: 10,
            ph: 7,
          ),
          _feeding(
            'healthy-feed',
            healthy.id,
            now.subtract(const Duration(days: 1)),
          ),
        ],
        tasks: const [],
        livestock: [_livestock('tetra', healthy.id, count: 8)],
        equipment: [_equipment('filter', healthy.id)],
        now: now,
      );

      final riskySummary = TankComparisonService.buildSummary(
        tank: risky,
        logs: [
          _waterChange(
            'risky-change',
            risky.id,
            now.subtract(const Duration(days: 19)),
          ),
          _waterTest(
            'risky-test',
            risky.id,
            now.subtract(const Duration(days: 1)),
            ammonia: 0.5,
            nitrite: 0.5,
            nitrate: 80,
            ph: 8.4,
          ),
        ],
        tasks: const [],
        livestock: [_livestock('betta', risky.id, count: 1)],
        equipment: [_equipment('heater', risky.id)],
        now: now,
      );

      final result = TankComparisonService.chooseNeedsAttentionFirst([
        healthySummary,
        riskySummary,
      ]);

      expect(result?.tank.id, risky.id);
      expect(
        riskySummary.attentionScore,
        greaterThan(healthySummary.attentionScore),
      );
      expect(riskySummary.primaryReason, contains('Water'));
    });

    test(
      'overdue tasks increase attention priority with an actionable reason',
      () {
        final now = DateTime(2026, 5, 9, 12);
        final calm = _tank('calm', 'Calm Tank', now);
        final overdue = _tank('overdue', 'Tasky Tank', now);

        final calmSummary = TankComparisonService.buildSummary(
          tank: calm,
          logs: [
            _waterTest(
              'calm-test',
              calm.id,
              now.subtract(const Duration(days: 1)),
            ),
          ],
          tasks: const [],
          livestock: const [],
          equipment: const [],
          now: now,
        );
        final overdueSummary = TankComparisonService.buildSummary(
          tank: overdue,
          logs: [
            _waterTest(
              'overdue-test',
              overdue.id,
              now.subtract(const Duration(days: 1)),
            ),
          ],
          tasks: [
            _task(
              'water-change',
              overdue.id,
              'Water change',
              now.subtract(const Duration(days: 2)),
            ),
          ],
          livestock: const [],
          equipment: const [],
          now: now,
        );

        expect(
          overdueSummary.attentionScore,
          greaterThan(calmSummary.attentionScore),
        );
        expect(overdueSummary.primaryReason, contains('overdue task'));
      },
    );

    test(
      'handles missing water tests without crashing or inventing values',
      () {
        final now = DateTime(2026, 5, 9, 12);
        final tank = _tank('sparse', 'Sparse Tank', now);

        final summary = TankComparisonService.buildSummary(
          tank: tank,
          logs: const [],
          tasks: const [],
          livestock: const [],
          equipment: const [],
          now: now,
        );

        expect(summary.latestWaterTest, isNull);
        expect(summary.waterStatusLabel, 'No water tests');
        expect(summary.primaryReason, contains('No water tests'));
        expect(summary.attentionScore, greaterThanOrEqualTo(0));
      },
    );
  });
}

Tank _tank(String id, String name, DateTime now) => Tank(
  id: id,
  name: name,
  type: TankType.freshwater,
  volumeLitres: id == 'healthy' ? 125 : 60,
  startDate: now.subtract(const Duration(days: 120)),
  targets: WaterTargets.freshwaterTropical(),
  createdAt: now.subtract(const Duration(days: 120)),
  updatedAt: now.subtract(const Duration(days: 1)),
);

LogEntry _waterChange(String id, String tankId, DateTime timestamp) => LogEntry(
  id: id,
  tankId: tankId,
  type: LogType.waterChange,
  timestamp: timestamp,
  waterChangePercent: 30,
  createdAt: timestamp,
);

LogEntry _waterTest(
  String id,
  String tankId,
  DateTime timestamp, {
  double ammonia = 0,
  double nitrite = 0,
  double nitrate = 10,
  double ph = 7,
}) => LogEntry(
  id: id,
  tankId: tankId,
  type: LogType.waterTest,
  timestamp: timestamp,
  waterTest: WaterTestResults(
    ammonia: ammonia,
    nitrite: nitrite,
    nitrate: nitrate,
    ph: ph,
  ),
  createdAt: timestamp,
);

LogEntry _feeding(String id, String tankId, DateTime timestamp) => LogEntry(
  id: id,
  tankId: tankId,
  type: LogType.feeding,
  timestamp: timestamp,
  createdAt: timestamp,
);

Task _task(String id, String tankId, String title, DateTime dueDate) => Task(
  id: id,
  tankId: tankId,
  title: title,
  recurrence: RecurrenceType.weekly,
  dueDate: dueDate,
  createdAt: dueDate.subtract(const Duration(days: 7)),
  updatedAt: dueDate.subtract(const Duration(days: 7)),
);

Livestock _livestock(String id, String tankId, {required int count}) =>
    Livestock(
      id: id,
      tankId: tankId,
      commonName: 'Neon Tetra',
      count: count,
      dateAdded: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Equipment _equipment(String id, String tankId) => Equipment(
  id: id,
  tankId: tankId,
  type: EquipmentType.filter,
  name: 'Filter',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);
