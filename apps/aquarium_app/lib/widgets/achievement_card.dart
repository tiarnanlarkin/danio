/// Achievement Card Widget - Displays achievement in grid
/// Shows locked/unlocked state with progress bar
library;
import 'package:danio/theme/app_theme.dart';

import 'package:flutter/material.dart';
import '../models/achievements.dart';
import 'effects/sparkle_effect.dart';

/// Displays an achievement card in grid layout showing locked/unlocked state.
///
/// Shows achievement icon, title, description, and progress bar. Locked
/// achievements are displayed with reduced opacity. Newly unlocked achievements
/// can display sparkle effects.
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final AchievementProgress progress;
  final VoidCallback onTap;
  /// Whether to show sparkle effect (for newly unlocked)
  final bool showSparkle;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.progress,
    required this.onTap,
    this.showSparkle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !progress.isUnlocked;
    final progressPercent = progress.getProgress(achievement.targetCount);
    final hasProgress = progressPercent > 0 && progressPercent < 1.0;

    // Get rarity color
    final rarityColor = _getRarityColor(achievement.rarity);

    final card = Semantics(
      label: achievement.isHidden && isLocked
          ? 'Hidden achievement, locked'
          : '${achievement.name}, ${isLocked ? 'locked' : 'unlocked'}, ${achievement.description}',
      button: true,
      enabled: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: isLocked ? Theme.of(context).colorScheme.outlineVariant : rarityColor,
            width: isLocked ? 1 : 3,
          ),
          color: isLocked ? Theme.of(context).colorScheme.surfaceContainerHighest : rarityColor.withAlpha(26),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: rarityColor.withAlpha(76),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon and rarity badge
            Expanded(
              child: Stack(
                children: [
                  // Icon
                  Center(
                    child: Text(
                      achievement.icon,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: isLocked ? AppColors.blackAlpha25 : null,
                      ),
                    ),
                  ),

                  // Locked overlay
                  if (isLocked && achievement.isHidden)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock,
                            size: AppIconSizes.xl,
                            color: AppColors.whiteAlpha70,
                          ),
                        ),
                      ),
                    )
                  else if (isLocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppOverlays.white70,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_outline,
                            size: 32,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ),

                  // Rarity badge
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: rarityColor,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Text(
                        achievement.rarity.displayName.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Name and description
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.isHidden && isLocked ? '???' : achievement.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLocked ? AppColors.textHint : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    achievement.isHidden && isLocked
                        ? 'Hidden achievement'
                        : achievement.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isLocked ? AppColors.textHint : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Progress bar for in-progress achievements
                  if (hasProgress) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: AppRadius.xsRadius,
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 6,
                        backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${progress.currentCount} / ${achievement.targetCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );

    // Return card with optional sparkle effect
    if (showSparkle) {
      return SparkleEffect(child: card);
    }
    return card;
  }

  Color _getRarityColor(AchievementRarity rarity) {
    return AppAchievementColors.forTier(rarity.name);
  }
}
