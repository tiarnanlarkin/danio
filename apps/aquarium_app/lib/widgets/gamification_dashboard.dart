/// Gamification Dashboard Widget
/// Shows streak, XP, gems, hearts, and daily goal progress in a compact card
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../providers/gems_provider.dart';
import '../providers/hearts_provider.dart';
import '../theme/app_theme.dart';

/// Compact gamification dashboard showing all stats at a glance
class GamificationDashboard extends ConsumerWidget {
  /// Whether to show as a card with elevation
  final bool showAsCard;

  /// Callback when tapping the dashboard
  final VoidCallback? onTap;

  const GamificationDashboard({
    super.key,
    this.showAsCard = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final gemsAsync = ref.watch(gemsProvider);
    final heartsState = ref.watch(heartsStateProvider);

    return profileAsync.when(
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        final gems = gemsAsync.value?.balance ?? 0;
        final dailyGoal = ref.watch(todaysDailyGoalProvider);
        final todayXp = dailyGoal?.earnedXp ?? 0;
        final goalXp = profile.dailyXpGoal;
        final progress = goalXp > 0 ? (todayXp / goalXp).clamp(0.0, 1.0) : 0.0;

        final content = Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Streak and XP
              Row(
                children: [
                  Flexible(
                    child: _StatItem(
                      icon: '🔥',
                      value: '${profile.currentStreak}',
                      label: 'streak',
                      color: Colors.orange,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: _StatItem(
                      icon: '⭐',
                      value: _formatNumber(profile.totalXp),
                      label: 'XP',
                      color: AppColors.accent,
                      alignRight: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2: Gems and Hearts
              Row(
                children: [
                  Flexible(
                    child: _StatItem(
                      icon: '💎',
                      value: _formatNumber(gems),
                      label: 'gems',
                      color: Colors.cyan,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: _HeartsDisplay(
                      current: heartsState.currentHearts,
                      max: heartsState.maxHearts,
                      timeUntilRefill: heartsState.timeUntilNextRefill,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Row 3: Daily Goal Progress
              _DailyGoalProgress(
                current: todayXp,
                goal: goalXp,
                progress: progress,
              ),
            ],
          ),
        );

        if (showAsCard) {
          return Card(
            margin: EdgeInsets.zero,
            elevation: AppElevation.level1,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mediumRadius,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.mediumRadius,
              child: content,
            ),
          );
        }

        return GestureDetector(
          onTap: onTap,
          child: content,
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: AppElevation.level1,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mediumRadius,
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: AppElevation.level1,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mediumRadius,
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: AppSpacing.sm),
            Text('Unable to load stats'),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;
  final bool alignRight;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment:
              alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeartsDisplay extends StatelessWidget {
  final int current;
  final int max;
  final Duration? timeUntilRefill;

  const _HeartsDisplay({
    required this.current,
    required this.max,
    this.timeUntilRefill,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('❤️', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$current',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: current > 0 ? AppColors.error : AppColors.textHint,
                  ),
                ),
                Text(
                  '/$max',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (timeUntilRefill != null && current < max)
              Text(
                _formatDuration(timeUntilRefill!),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textHint,
                ),
              )
            else
              Text(
                '♥',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '< 1m';
    }
  }
}

class _DailyGoalProgress extends StatelessWidget {
  final int current;
  final int goal;
  final double progress;

  const _DailyGoalProgress({
    required this.current,
    required this.goal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    final isComplete = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '📊',
              style: TextStyle(
                fontSize: 16,
                color: isComplete ? Colors.green : null,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '$current/$goal XP',
                style: AppTypography.labelMedium.copyWith(
                  color: isComplete ? AppColors.success : AppColors.textPrimary,
                  fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            if (isComplete)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppOverlays.success20,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Done!',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                '$percentage%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.xsRadius,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Minimal inline dashboard for tight spaces (e.g., app bar)
class MiniGamificationDisplay extends ConsumerWidget {
  const MiniGamificationDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final gemsBalance = ref.watch(gemBalanceProvider);

    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Streak
            _MiniStat(emoji: '🔥', value: profile.currentStreak),
            const SizedBox(width: 12),
            // Gems
            _MiniStat(emoji: '💎', value: gemsBalance),
          ],
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String emoji;
  final int value;

  const _MiniStat({required this.emoji, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppOverlays.black20,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            value.toString(),
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
