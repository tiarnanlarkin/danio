import '../models/models.dart';
import 'compatibility_service.dart';

enum TankLivestockVisualCondition { clear, healthConcern, compatibilityConcern }

class TankLivestockVisualState {
  final TankLivestockVisualCondition condition;
  final String semanticsLabel;

  const TankLivestockVisualState({
    required this.condition,
    required this.semanticsLabel,
  });

  bool get hasOverlay => condition != TankLivestockVisualCondition.clear;
}

class TankLivestockVisualService {
  const TankLivestockVisualService._();

  static TankLivestockVisualState fromTank({
    required Tank tank,
    required List<Livestock> livestock,
  }) {
    if (livestock.isEmpty) return clear;

    final hasHealthConcern = livestock.any(
      (entry) => entry.healthStatus != HealthStatus.healthy,
    );
    if (hasHealthConcern) {
      return const TankLivestockVisualState(
        condition: TankLivestockVisualCondition.healthConcern,
        semanticsLabel:
            'Tank livestock visual state: livestock health needs review',
      );
    }

    final issues = <CompatibilityIssue>[];
    for (final entry in livestock) {
      issues.addAll(
        CompatibilityService.checkLivestockCompatibility(
          livestock: entry,
          tank: tank,
          existingLivestock: livestock,
        ),
      );
    }

    if (issues.isNotEmpty) {
      return const TankLivestockVisualState(
        condition: TankLivestockVisualCondition.compatibilityConcern,
        semanticsLabel:
            'Tank livestock visual state: compatibility needs review',
      );
    }

    return clear;
  }

  static const clear = TankLivestockVisualState(
    condition: TankLivestockVisualCondition.clear,
    semanticsLabel: 'Tank livestock visual state: clear',
  );
}
