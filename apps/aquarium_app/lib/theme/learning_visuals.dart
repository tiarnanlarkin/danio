import 'package:flutter/material.dart';

import '../models/spaced_repetition.dart';
import 'app_theme.dart';

@immutable
class LearningPathVisual {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String? assetPath;

  const LearningPathVisual({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.assetPath,
  });
}

class LearningVisuals {
  static const fallbackPathVisual = LearningPathVisual(
    icon: Icons.menu_book_rounded,
    color: AppColors.primary,
    backgroundColor: AppColors.primaryAlpha10,
  );

  static const _pathVisuals = <String, LearningPathVisual>{
    'nitrogen_cycle': LearningPathVisual(
      icon: Icons.sync_rounded,
      color: AppColors.accentText,
      backgroundColor: AppColors.accentAlpha10,
      assetPath: 'assets/images/illustrations/nitrogen_cycle_flow.png',
    ),
    'water_parameters': LearningPathVisual(
      icon: Icons.science_rounded,
      color: AppColors.info,
      backgroundColor: AppColors.infoAlpha10,
    ),
    'first_fish': LearningPathVisual(
      icon: Icons.set_meal_rounded,
      color: DanioColors.coralAccentText,
      backgroundColor: AppColors.errorAlpha05,
    ),
    'maintenance': LearningPathVisual(
      icon: Icons.cleaning_services_rounded,
      color: AppColors.primaryDark,
      backgroundColor: AppColors.woodBrownAlpha12,
    ),
    'planted': LearningPathVisual(
      icon: Icons.local_florist_rounded,
      color: AppColors.success,
      backgroundColor: AppColors.successAlpha10,
    ),
    'equipment': LearningPathVisual(
      icon: Icons.tune_rounded,
      color: AppColors.secondary,
      backgroundColor: AppColors.secondaryAlpha10,
    ),
    'fish_health': LearningPathVisual(
      icon: Icons.medical_services_rounded,
      color: AppColors.error,
      backgroundColor: AppColors.errorAlpha08,
    ),
    'species_care': LearningPathVisual(
      icon: Icons.groups_rounded,
      color: DanioColors.sapphireBlue,
      backgroundColor: AppColors.infoAlpha10,
    ),
    'advanced_topics': LearningPathVisual(
      icon: Icons.psychology_rounded,
      color: DanioColors.amethyst,
      backgroundColor: AppColors.secondaryAlpha10,
    ),
    'aquascaping': LearningPathVisual(
      icon: Icons.park_rounded,
      color: AppColors.success,
      backgroundColor: AppColors.cozyGreen10,
    ),
    'breeding_basics': LearningPathVisual(
      icon: Icons.favorite_rounded,
      color: DanioColors.amberGoldText,
      backgroundColor: AppColors.warningAlpha10,
    ),
    'troubleshooting': LearningPathVisual(
      icon: Icons.report_problem_rounded,
      color: AppColors.error,
      backgroundColor: AppColors.errorAlpha10,
    ),
  };

  static LearningPathVisual forPath(String pathId) =>
      _pathVisuals[pathId] ?? fallbackPathVisual;

  static bool hasPathVisual(String pathId) => _pathVisuals.containsKey(pathId);

  static IconData masteryIcon(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.new_:
        return Icons.add_circle_outline_rounded;
      case MasteryLevel.learning:
        return Icons.menu_book_rounded;
      case MasteryLevel.familiar:
        return Icons.lightbulb_outline_rounded;
      case MasteryLevel.proficient:
        return Icons.verified_rounded;
      case MasteryLevel.mastered:
        return Icons.workspace_premium_rounded;
    }
  }

  static Color masteryColor(BuildContext context, MasteryLevel level) {
    switch (level) {
      case MasteryLevel.new_:
        return context.textSecondary;
      case MasteryLevel.learning:
        return AppColors.warning;
      case MasteryLevel.familiar:
        return AppColors.info;
      case MasteryLevel.proficient:
        return AppColors.success;
      case MasteryLevel.mastered:
        return AppColors.accentText;
    }
  }
}
