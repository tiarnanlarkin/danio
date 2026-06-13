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

  const TankVisualStateService._();

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
}
