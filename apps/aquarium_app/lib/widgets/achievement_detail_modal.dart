/// Achievement Detail Modal - Detailed view when tapping achievement
/// Shows full description, progress, unlock date, and XP reward
library;

import '../theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/achievements.dart';

/// Modal showing detailed achievement information when tapped.
///
/// Displays full description, progress tracking, unlock date, XP reward,
/// and rarity-specific styling. Used in the achievements grid view.
class AchievementDetailModal extends StatelessWidget {
  final Achievement achievement;
  final AchievementProgress progress;

  const AchievementDetailModal({
    super.key,
    required this.achievement,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !progress.isUnlocked;
    final progressPercent = progress.getProgress(achievement.targetCount);
    final rarityColor = _getRarityColor(achievement.rarity);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Icon with glow effect
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLocked
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : rarityColor.withAlpha(51),
                boxShadow: isLocked
                    ? []
                    : [
                        BoxShadow(
                          color: rarityColor.withAlpha(102),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
              ),
              child: Center(
                child: Stack(
                  children: [
                    Text(
                      achievement.icon,
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            color: isLocked ? AppColors.blackAlpha25 : null,
                          ),
                    ),
                    if (isLocked && achievement.isHidden)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.textSecondary,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lock,
                              size: AppIconSizes.xl,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Rarity badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: AppSpacing.xs2,
              ),
              decoration: BoxDecoration(
                color: rarityColor,
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Text(
                achievement.rarity.displayName.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Name
            Text(
              achievement.isHidden && isLocked ? '???' : achievement.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLocked ? context.textHint : null,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: AppSpacing.xs2,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Text(
                '${achievement.category.icon} ${achievement.category.displayName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              achievement.isHidden && isLocked
                  ? 'This is a hidden achievement. Complete specific actions to reveal and unlock it!'
                  : achievement.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isLocked ? context.textHint : context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Progress section
            if (achievement.targetCount != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${progress.currentCount} / ${achievement.targetCount}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: rarityColor,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm2),
                    ClipRRect(
                      borderRadius: AppRadius.smallRadius,
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 12,
                        backgroundColor: context.cardColor,
                        valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${(progressPercent * 100).toStringAsFixed(1)}% Complete',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.textHint),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Reward info
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    rarityColor.withAlpha(51),
                    rarityColor.withAlpha(26),
                  ],
                ),
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.xp,
                        size: AppIconSizes.lg,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${achievement.rarity.xpReward} XP',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Reward',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textHint,
                        ),
                      ),
                    ],
                  ),
                  if (progress.unlockedAt != null) ...[
                    Container(
                      width: 1,
                      height: 60,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          DateFormat('MMM d').format(progress.unlockedAt!),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Unlocked',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.textHint),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Status
            if (isLocked)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm2),
                decoration: BoxDecoration(
                  // Warm tint adapts to dark mode
                  color: isDark
                      ? AppColors.primaryAlpha10
                      : AppColors.primaryAlpha08,
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(
                    color: isDark
                        ? AppColors.primaryAlpha30
                        : AppColors.primaryAlpha25,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm2),
                    Expanded(
                      child: Text(
                        'Keep learning to unlock this achievement!',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm2),
                decoration: BoxDecoration(
                  // Warm amber tint — works in both light and dark
                  color: isDark
                      ? AppColors.warningAlpha12
                      : AppColors.warningAlpha10,
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(
                    color: isDark
                        ? AppColors.warningAlpha40
                        : AppColors.warningAlpha30,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm2),
                    Expanded(
                      child: Text(
                        'Achievement Unlocked!',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    return AppAchievementColors.forTier(rarity.name);
  }
}
