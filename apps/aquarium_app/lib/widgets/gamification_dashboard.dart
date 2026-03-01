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
      loading: () => _buildLoadingState(context),
      error: (_, __) => _buildErrorState(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        final gems = gemsAsync.value?.balance ?? 0;
        final dailyGoal = ref.watch(todaysDailyGoalProvider);
        final todayXp = dailyGoal?.earnedXp ?? 0;
        final goalXp = profile.dailyXpGoal;
        final progress = goalXp > 0 ? (todayXp / goalXp).clamp(0.0, 1.0) : 0.0;

        final content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Streak and XP
              Row(
                children: [
                  _StatItem(
                    icon: '🔥',
                    value: '${profile.currentStreak}',
                    label: 'day streak',
                    color: DanioColors.amberGold,
                  ),
                  const Spacer(),
                  _StatItem(
                    icon: '⭐',
                    value: _formatNumber(profile.totalXp),
                    label: 'XP',
                    color: AppColors.accent,
                    alignRight: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2: Gems, Today XP, and Hearts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _StatItem(
                    icon: '💎',
                    value: _formatNumber(gems),
                    label: 'gems',
                    color: DanioColors.tealWater,
                  )),
                  Expanded(child: _StatItem(
                    icon: '⚡',
                    value: _formatNumber(todayXp),
                    label: 'today',
                    color: DanioColors.emeraldGreen,
                  )),
                  Expanded(child: _HeartsDisplay(
                    current: heartsState.currentHearts,
                    max: heartsState.maxHearts,
                    timeUntilRefill: heartsState.timeUntilNextRefill,
                  )),
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

  Widget _buildLoadingState(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: AppElevation.level1,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (i) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 32, height: 16, decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              )),
              const SizedBox(height: 6),
              Container(width: 48, height: 10, decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              )),
            ],
          )),
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
    final rowChildren = [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimaryDark
                : const Color(0xFF3D2B1F),
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 2),
      Flexible(
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: alignRight ? rowChildren.reversed.toList() : rowChildren,
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
        const Text('❤️', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 4),
        Flexible(child: Column(
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
                'hearts',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        )),
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
                color: isComplete ? DanioColors.emeraldGreen : null,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Daily Goal: $current/$goal XP',
              style: AppTypography.labelMedium.copyWith(
                color: isComplete ? AppColors.success : Theme.of(context).colorScheme.onSurface,
                fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
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
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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
      error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
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
