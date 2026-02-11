/// Achievement Detail Modal - Detailed view when tapping achievement
/// Shows full description, progress, unlock date, and XP reward
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/achievements.dart';

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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
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
                    ? Colors.grey.shade200
                    : rarityColor.withOpacity(0.2),
                boxShadow: isLocked
                    ? []
                    : [
                        BoxShadow(
                          color: rarityColor.withOpacity(0.4),
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
                      style: TextStyle(
                        fontSize: 72,
                        color: isLocked ? Colors.black26 : null,
                      ),
                    ),
                    if (isLocked && achievement.isHidden)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lock,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Rarity badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: rarityColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                achievement.rarity.displayName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Name
            Text(
              achievement.isHidden && isLocked ? '???' : achievement.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : null,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${achievement.category.icon} ${achievement.category.displayName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              achievement.isHidden && isLocked
                  ? 'This is a hidden achievement. Complete specific actions to reveal and unlock it!'
                  : achievement.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isLocked ? Colors.grey : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Progress section
            if (achievement.targetCount != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 12,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progressPercent * 100).toStringAsFixed(1)}% Complete',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Reward info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    rarityColor.withOpacity(0.2),
                    rarityColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        '${achievement.rarity.xpReward} XP',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Reward',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  if (progress.unlockedAt != null) ...[
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey.shade300,
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.blue,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d').format(progress.unlockedAt!),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Unlocked',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status
            if (isLocked)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keep learning to unlock this achievement!',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Achievement Unlocked!',
                        style: TextStyle(
                          color: Colors.green.shade700,
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
