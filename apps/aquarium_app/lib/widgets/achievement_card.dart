/// Achievement Card Widget - Displays achievement in grid
/// Shows locked/unlocked state with progress bar
library;

import 'package:flutter/material.dart';
import '../models/achievements.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final AchievementProgress progress;
  final VoidCallback onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !progress.isUnlocked;
    final progressPercent = progress.getProgress(achievement.targetCount);
    final hasProgress = progressPercent > 0 && progressPercent < 1.0;

    // Get rarity color
    final rarityColor = _getRarityColor(achievement.rarity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked ? Colors.grey.shade300 : rarityColor,
            width: isLocked ? 1 : 3,
          ),
          color: isLocked ? Colors.grey.shade100 : rarityColor.withOpacity(0.1),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: rarityColor.withOpacity(0.3),
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
                      style: TextStyle(
                        fontSize: 64,
                        color: isLocked ? Colors.black26 : null,
                      ),
                    ),
                  ),

                  // Locked overlay
                  if (isLocked && achievement.isHidden)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock,
                            size: 48,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    )
                  else if (isLocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_outline,
                            size: 32,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                  // Rarity badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: rarityColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        achievement.rarity.displayName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.isHidden && isLocked ? '???' : achievement.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.isHidden && isLocked
                        ? 'Hidden achievement'
                        : achievement.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isLocked ? Colors.grey : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Progress bar for in-progress achievements
                  if (hasProgress) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${progress.currentCount} / ${achievement.targetCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.bronze:
        return const Color(0xFFCD7F32);
      case AchievementRarity.silver:
        return const Color(0xFFC0C0C0);
      case AchievementRarity.gold:
        return const Color(0xFFFFD700);
      case AchievementRarity.platinum:
        return const Color(0xFFE5E4E2);
    }
  }
}
