import '../models/log_entry.dart';
import 'tank_care_priority_service.dart';

enum TankVisualCondition { clear, unsafeWater, tooWarm, tooCold, staleWater }

class TankVisualState {
  final TankVisualCondition condition;
  final String semanticsLabel;

  const TankVisualState({
    required this.condition,
    required this.semanticsLabel,
  });

  bool get hasOverlay => condition != TankVisualCondition.clear;
}

class TankVisualStateService {
  static const double warmWaterCelsius = 30;
  static const double coldWaterCelsius = 20;
  static const double staleNitratePpm = 40;
  static const int staleWaterChangeDays = 14;

  const TankVisualStateService._();

  static TankVisualState fromLogs(List<LogEntry> logs, {DateTime? now}) {
    final waterState = fromWaterTest(_latestWaterTest(logs)?.waterTest);
    if (waterState.hasOverlay) return waterState;

    final latestWaterChange = _latestWaterChange(logs);
    final referenceTime = now ?? DateTime.now();
    if (latestWaterChange != null &&
        referenceTime.difference(latestWaterChange.timestamp).inDays >
            staleWaterChangeDays) {
      return const TankVisualState(
        condition: TankVisualCondition.staleWater,
        semanticsLabel: 'Tank visual state: stale water',
      );
    }

    return const TankVisualState(
      condition: TankVisualCondition.clear,
      semanticsLabel: 'Tank visual state: clear water',
    );
  }

  static TankVisualState fromWaterTest(WaterTestResults? results) {
    if (results == null || !results.hasValues) {
      return const TankVisualState(
        condition: TankVisualCondition.clear,
        semanticsLabel: 'Tank visual state: clear water',
      );
    }

    if ((results.ammonia ?? 0) >
            TankCarePriorityService.unsafeNitrogenThreshold ||
        (results.nitrite ?? 0) >
            TankCarePriorityService.unsafeNitrogenThreshold) {
      return const TankVisualState(
        condition: TankVisualCondition.unsafeWater,
        semanticsLabel: 'Tank visual state: unsafe water',
      );
    }

    final temperature = results.temperature;
    if (temperature != null && temperature >= warmWaterCelsius) {
      return const TankVisualState(
        condition: TankVisualCondition.tooWarm,
        semanticsLabel: 'Tank visual state: water too warm',
      );
    }
    if (temperature != null && temperature < coldWaterCelsius) {
      return const TankVisualState(
        condition: TankVisualCondition.tooCold,
        semanticsLabel: 'Tank visual state: water too cold',
      );
    }

    if ((results.nitrate ?? 0) >= staleNitratePpm) {
      return const TankVisualState(
        condition: TankVisualCondition.staleWater,
        semanticsLabel: 'Tank visual state: stale water',
      );
    }

    return const TankVisualState(
      condition: TankVisualCondition.clear,
      semanticsLabel: 'Tank visual state: clear water',
    );
  }

  static LogEntry? _latestWaterTest(List<LogEntry> logs) {
    final waterTests =
        logs
            .where(
              (log) => log.type == LogType.waterTest && log.waterTest != null,
            )
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return waterTests.isEmpty ? null : waterTests.first;
  }

  static LogEntry? _latestWaterChange(List<LogEntry> logs) {
    final changes =
        logs.where((log) => log.type == LogType.waterChange).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return changes.isEmpty ? null : changes.first;
  }
}
