import 'package:flutter/material.dart';

import 'app_colors.dart';

enum DanioSurfaceVisualKey {
  smart,
  aiSetup,
  shop,
  fishWishlist,
  plantWishlist,
  equipmentWishlist,
  gemShop,
  achievements,
  workshop,
  dailyGoalCasual,
  dailyGoalRegular,
  dailyGoalSerious,
  dailyGoalIntense,
  streak,
  streakFreeze,
  warning,
  info,
  onboardingLesson,
  fishFallback,
}

class DanioSurfaceVisual {
  final IconData icon;
  final Color color;

  const DanioSurfaceVisual({required this.icon, required this.color});
}

DanioSurfaceVisual danioSurfaceVisual(DanioSurfaceVisualKey key) {
  return switch (key) {
    DanioSurfaceVisualKey.smart => const DanioSurfaceVisual(
      icon: Icons.psychology_alt_outlined,
      color: AppColors.info,
    ),
    DanioSurfaceVisualKey.aiSetup => const DanioSurfaceVisual(
      icon: Icons.smart_toy_outlined,
      color: AppColors.primary,
    ),
    DanioSurfaceVisualKey.shop => const DanioSurfaceVisual(
      icon: Icons.storefront_outlined,
      color: AppColors.primary,
    ),
    DanioSurfaceVisualKey.fishWishlist => const DanioSurfaceVisual(
      icon: Icons.set_meal_outlined,
      color: DanioColors.coralAccent,
    ),
    DanioSurfaceVisualKey.plantWishlist => const DanioSurfaceVisual(
      icon: Icons.eco_outlined,
      color: DanioColors.emeraldGreen,
    ),
    DanioSurfaceVisualKey.equipmentWishlist => const DanioSurfaceVisual(
      icon: Icons.construction_outlined,
      color: DanioColors.wishlistAmber,
    ),
    DanioSurfaceVisualKey.gemShop => const DanioSurfaceVisual(
      icon: Icons.diamond_outlined,
      color: AppColors.accentAlt,
    ),
    DanioSurfaceVisualKey.achievements => const DanioSurfaceVisual(
      icon: Icons.emoji_events_outlined,
      color: AppColors.primary,
    ),
    DanioSurfaceVisualKey.workshop => const DanioSurfaceVisual(
      icon: Icons.build_outlined,
      color: DanioColors.studyGold,
    ),
    DanioSurfaceVisualKey.dailyGoalCasual => const DanioSurfaceVisual(
      icon: Icons.spa_outlined,
      color: DanioColors.tealWaterText,
    ),
    DanioSurfaceVisualKey.dailyGoalRegular => const DanioSurfaceVisual(
      icon: Icons.water_drop_outlined,
      color: AppColors.info,
    ),
    DanioSurfaceVisualKey.dailyGoalSerious => const DanioSurfaceVisual(
      icon: Icons.local_fire_department_outlined,
      color: AppColors.primary,
    ),
    DanioSurfaceVisualKey.dailyGoalIntense => const DanioSurfaceVisual(
      icon: Icons.workspace_premium_outlined,
      color: AppColors.accentAlt,
    ),
    DanioSurfaceVisualKey.streak => const DanioSurfaceVisual(
      icon: Icons.local_fire_department_outlined,
      color: AppColors.primaryLight,
    ),
    DanioSurfaceVisualKey.streakFreeze => const DanioSurfaceVisual(
      icon: Icons.ac_unit_outlined,
      color: AppColors.info,
    ),
    DanioSurfaceVisualKey.warning => const DanioSurfaceVisual(
      icon: Icons.warning_amber_outlined,
      color: AppColors.warning,
    ),
    DanioSurfaceVisualKey.info => const DanioSurfaceVisual(
      icon: Icons.info_outline,
      color: AppColors.info,
    ),
    DanioSurfaceVisualKey.onboardingLesson => const DanioSurfaceVisual(
      icon: Icons.school_outlined,
      color: AppColors.primary,
    ),
    DanioSurfaceVisualKey.fishFallback => const DanioSurfaceVisual(
      icon: Icons.set_meal_outlined,
      color: DanioColors.tealWaterText,
    ),
  };
}
