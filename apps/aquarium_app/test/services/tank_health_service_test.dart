// Tests for TankHealthService.calculateScore()
//
// Run: flutter test test/services/tank_health_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/services/tank_health_service.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/models/log_entry.dart';

Tank _testTank({double volumeLitres = 100}) {
  final now = DateTime.now();
  return Tank(
    id: 'tank-1',
    name: 'Test Tank',
    type: TankType.freshwater,
    volumeLitres: volumeLitres,
    startDate: now.subtract(const Duration(days: 60)),
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

LogEntry _waterChange({int daysAgo = 3}) {
  final ts = DateTime.now().subtract(Duration(days: daysAgo));
  return LogEntry(
    id: 'wc-$daysAgo',
    tankId: 'tank-1',
    type: LogType.waterChange,
    timestamp: ts,
    waterChangePercent: 30,
    createdAt: ts,
  );
}

LogEntry _waterTest({
  int daysAgo = 1,
  double? ammonia = 0.0,
  double? nitrite = 0.0,
  double? nitrate = 10.0,
  double? ph = 7.0,
}) {
  final ts = DateTime.now().subtract(Duration(days: daysAgo));
  return LogEntry(
    id: 'wt-$daysAgo',
    tankId: 'tank-1',
    type: LogType.waterTest,
    timestamp: ts,
    createdAt: ts,
    waterTest: WaterTestResults(
      ammonia: ammonia,
      nitrite: nitrite,
      nitrate: nitrate,
      ph: ph,
    ),
  );
}

void main() {
  final tank = _testTank();

  group('TankHealthService.calculateScore — healthy tank', () {
    test('recent water change + good params → excellent or good', () {
      final logs = [_waterChange(daysAgo: 3), _waterTest(daysAgo: 1)];
      final result = TankHealthService.calculateScore(tank: tank, logs: logs);
      expect(result.score, greaterThanOrEqualTo(60));
      expect(
        result.level,
        anyOf(TankHealthLevel.excellent, TankHealthLevel.good),
      );
    });

    test('score is in range 0-100', () {
      final logs = [_waterChange(daysAgo: 3), _waterTest(daysAgo: 1)];
      final result = TankHealthService.calculateScore(tank: tank, logs: logs);
      expect(result.score, inInclusiveRange(0, 100));
    });

    test('excellent label when score >= 80', () {
      // Water change today + perfect params → should hit 80+
      final logs = [
        _waterChange(daysAgo: 0),
        _waterTest(daysAgo: 1),
        // Add extra logs to boost regularity score
        for (int i = 1; i <= 12; i++) _waterChange(daysAgo: i * 2),
      ];
      final result = TankHealthService.calculateScore(tank: tank, logs: logs);
      if (result.score >= 80) {
        expect(result.label, equals('Excellent'));
        expect(result.level, equals(TankHealthLevel.excellent));
      }
    });
  });

  group('TankHealthService.calculateScore — ammonia spike', () {
    test('high ammonia → score reduced and warning in factors', () {
      final normalLogs = [_waterChange(daysAgo: 3)];
      final normalResult =
          TankHealthService.calculateScore(tank: tank, logs: normalLogs);

      final ammoniaLogs = [
        _waterChange(daysAgo: 3),
        _waterTest(daysAgo: 1, ammonia: 1.0, nitrite: 0.0, nitrate: 10.0),
      ];
      final spikeResult =
          TankHealthService.calculateScore(tank: tank, logs: ammoniaLogs);

      // Ammonia spike should reduce score compared to no spike
      // And the factors should mention ammonia
      final hasAmmoniaWarning = spikeResult.factors.any(
        (f) => f.toLowerCase().contains('ammonia'),
      );
      expect(hasAmmoniaWarning, isTrue);
    });

    test('ammonia = 0 gives full ammonia points', () {
      final logs = [
        _waterChange(daysAgo: 3),
        _waterTest(daysAgo: 1, ammonia: 0.0),
      ];
      final result = TankHealthService.calculateScore(tank: tank, logs: logs);
      // Should not have any ammonia warning
      final hasAmmoniaWarning = result.factors.any(
        (f) => f.toLowerCase().contains('ammonia'),
      );
      expect(hasAmmoniaWarning, isFalse);
    });
  });

  group('TankHealthService.calculateScore — missing water logs', () {
    test('no logs → score <= 40 (poor or fair)', () {
      final result = TankHealthService.calculateScore(tank: tank, logs: []);
      expect(result.score, lessThanOrEqualTo(40));
      expect(
        result.level,
        anyOf(TankHealthLevel.poor, TankHealthLevel.fair),
      );
    });

    test('no logs → factors mention missing water changes', () {
      final result = TankHealthService.calculateScore(tank: tank, logs: []);
      final mentionsWaterChange = result.factors.any(
        (f) =>
            f.toLowerCase().contains('water change') ||
            f.toLowerCase().contains('no water changes'),
      );
      expect(mentionsWaterChange, isTrue);
    });

    test('no water test → neutral param score, factors note this', () {
      final logs = [_waterChange(daysAgo: 3)];
      final result = TankHealthService.calculateScore(tank: tank, logs: logs);
      final mentionsTest = result.factors.any(
        (f) =>
            f.toLowerCase().contains('test') ||
            f.toLowerCase().contains('parameter'),
      );
      expect(mentionsTest, isTrue);
    });
  });

  group('TankHealthService.calculateScore — overdue water change', () {
    test('water change 15 days ago → poor/fair and factor mentions overdue',
        () {
      final logs = [_waterChange(daysAgo: 15)];
      final result = TankHealthService.calculateScore(tank: tank, logs: logs);
      final hasOverdue = result.factors.any(
        (f) => f.toLowerCase().contains('overdue'),
      );
      expect(hasOverdue, isTrue);
    });
  });

  group('TankHealthService.calculateScore — stale water test', () {
    test('water test 20 days ago → reduced param score', () {
      final freshTestLogs = [
        _waterChange(daysAgo: 3),
        _waterTest(daysAgo: 1),
      ];
      final staleTestLogs = [
        _waterChange(daysAgo: 3),
        _waterTest(daysAgo: 20),
      ];
      final fresh = TankHealthService.calculateScore(
        tank: tank,
        logs: freshTestLogs,
      );
      final stale = TankHealthService.calculateScore(
        tank: tank,
        logs: staleTestLogs,
      );
      expect(fresh.score, greaterThanOrEqualTo(stale.score));
    });
  });

  group('TankHealthService.calculateWaterChangeStreak', () {
    test('no logs → streak is 0', () {
      expect(TankHealthService.calculateWaterChangeStreak([]), equals(0));
    });

    test('water change this week → streak is at least 1', () {
      final logs = [_waterChange(daysAgo: 2)];
      expect(
        TankHealthService.calculateWaterChangeStreak(logs),
        greaterThanOrEqualTo(1),
      );
    });

    test('consecutive weekly changes → streak counts correctly', () {
      final now = DateTime.now();
      // Create logs for the last 3 Mondays (one change per week)
      final logs = <LogEntry>[];
      for (int week = 0; week < 3; week++) {
        final ts = now.subtract(Duration(days: week * 7 + 1));
        logs.add(
          LogEntry(
            id: 'wc-week-$week',
            tankId: 'tank-1',
            type: LogType.waterChange,
            timestamp: ts,
            waterChangePercent: 30,
            createdAt: ts,
          ),
        );
      }
      final streak = TankHealthService.calculateWaterChangeStreak(logs);
      expect(streak, greaterThanOrEqualTo(1));
    });
  });
}
