import 'package:danio/models/log_entry.dart';
import 'package:danio/services/tank_visual_state_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TankVisualStateService', () {
    final now = DateTime(2026, 6, 13, 12);

    test('unsafe ammonia maps to unsafe water', () {
      final state = TankVisualStateService.fromWaterTest(
        WaterTestResults(ammonia: 0.5, nitrite: 0, nitrate: 10),
      );

      expect(state.condition, TankVisualCondition.unsafeWater);
      expect(state.semanticsLabel, 'Tank visual state: unsafe water');
      expect(state.hasOverlay, isTrue);
    });

    test('unsafe nitrite maps to unsafe water', () {
      final state = TankVisualStateService.fromWaterTest(
        WaterTestResults(ammonia: 0, nitrite: 0.5, nitrate: 10),
      );

      expect(state.condition, TankVisualCondition.unsafeWater);
    });

    test('warm tropical water maps to warm visual state', () {
      final state = TankVisualStateService.fromWaterTest(
        WaterTestResults(temperature: 30, ammonia: 0, nitrite: 0, nitrate: 10),
      );

      expect(state.condition, TankVisualCondition.tooWarm);
      expect(state.semanticsLabel, 'Tank visual state: water too warm');
    });

    test('cold tropical water maps to cold visual state', () {
      final state = TankVisualStateService.fromWaterTest(
        WaterTestResults(temperature: 19.5, ammonia: 0, nitrite: 0),
      );

      expect(state.condition, TankVisualCondition.tooCold);
      expect(state.semanticsLabel, 'Tank visual state: water too cold');
    });

    test('high nitrate maps to stale water visual state', () {
      final state = TankVisualStateService.fromWaterTest(
        WaterTestResults(ammonia: 0, nitrite: 0, nitrate: 40),
      );

      expect(state.condition, TankVisualCondition.staleWater);
      expect(state.semanticsLabel, 'Tank visual state: stale water');
    });

    test('safe readings map to clear water', () {
      final state = TankVisualStateService.fromWaterTest(
        WaterTestResults(temperature: 25, ammonia: 0, nitrite: 0, nitrate: 15),
      );

      expect(state.condition, TankVisualCondition.clear);
      expect(state.semanticsLabel, 'Tank visual state: clear water');
      expect(state.hasOverlay, isFalse);
    });

    test('old water change maps to stale water from logs', () {
      final state = TankVisualStateService.fromLogs([
        _waterTestLog(now, WaterTestResults(ammonia: 0, nitrite: 0)),
        _waterChangeLog(now.subtract(const Duration(days: 15))),
      ], now: now);

      expect(state.condition, TankVisualCondition.staleWater);
      expect(state.semanticsLabel, 'Tank visual state: stale water');
    });

    test('recent water change with safe readings stays clear from logs', () {
      final state = TankVisualStateService.fromLogs([
        _waterTestLog(now, WaterTestResults(ammonia: 0, nitrite: 0)),
        _waterChangeLog(now.subtract(const Duration(days: 6))),
      ], now: now);

      expect(state.condition, TankVisualCondition.clear);
      expect(state.hasOverlay, isFalse);
    });

    test('unsafe water stays highest priority when water change is old', () {
      final state = TankVisualStateService.fromLogs([
        _waterTestLog(now, WaterTestResults(ammonia: 0.5, nitrite: 0)),
        _waterChangeLog(now.subtract(const Duration(days: 21))),
      ], now: now);

      expect(state.condition, TankVisualCondition.unsafeWater);
    });
  });
}

LogEntry _waterTestLog(DateTime timestamp, WaterTestResults results) {
  return LogEntry(
    id: 'water-test-${timestamp.microsecondsSinceEpoch}',
    tankId: 'tank-visual',
    type: LogType.waterTest,
    timestamp: timestamp,
    waterTest: results,
    createdAt: timestamp,
  );
}

LogEntry _waterChangeLog(DateTime timestamp) {
  return LogEntry(
    id: 'water-change-${timestamp.microsecondsSinceEpoch}',
    tankId: 'tank-visual',
    type: LogType.waterChange,
    timestamp: timestamp,
    waterChangePercent: 30,
    createdAt: timestamp,
  );
}
