/// Today Board - Living Room Dashboard Panel
///
/// Compact overlay card showing upcoming tasks (today + next 2) for the
/// active tank. Sits above the GamificationDashboard in the home screen Stack.
///
/// Uses AppColors tokens and AppSpacing for consistent sizing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/task.dart';
import '../../../providers/tank_provider.dart';
import '../../../providers/spaced_repetition_provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../../screens/tab_navigator.dart';

/// Compact glass-style card showing today's tasks / upcoming maintenance.
///
/// Reads [tasksProvider] for [tankId] and displays up to [maxItems] tasks,
/// prioritising overdue → due today → upcoming.
class TodayBoardCard extends ConsumerWidget {
  final String tankId;
  final int maxItems;

  const TodayBoardCard({super.key, required this.tankId, this.maxItems = 3});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(tankId));

    return tasksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => Semantics(
        label: 'Unable to load today board',
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.warning),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Unable to load',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.warning),
              ),
            ],
          ),
        ),
      ),
      data: (tasks) {
        // Build ordered list: overdue first, then today, then upcoming
        final overdue = tasks.where((t) => t.isOverdue && t.isEnabled).toList();
        final today = tasks
            .where((t) => t.isDueToday && t.isEnabled && !t.isOverdue)
            .toList();
        final upcoming =
            tasks
                .where((t) => !t.isOverdue && !t.isDueToday && t.isEnabled)
                .toList()
              ..sort(
                (a, b) => (a.dueDate ?? DateTime(9999)).compareTo(
                  b.dueDate ?? DateTime(9999),
                ),
              );

        final combined = [
          ...overdue,
          ...today,
          ...upcoming,
        ].take(maxItems).toList();

        if (combined.isEmpty) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEmptyState(context, ref),
              const SizedBox(height: AppSpacing.xs),
              const _DailyGoalBar(),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TodayBoardContent(tankId: tankId, tasks: combined),
            const SizedBox(height: AppSpacing.xs),
            const _DailyGoalBar(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    // Select only the two counters this widget renders, avoiding rebuilds
    // when currentSession, card-list contents, or other stats fields change.
    final (:dueCards, :totalCards) = ref.watch(
      spacedRepetitionProvider.select(
        (s) => (dueCards: s.stats.dueCards, totalCards: s.stats.totalCards),
      ),
    );
    final hasCardsToReview = dueCards > 0;

    // Pick the best next action
    final int targetTab;
    final String emoji;
    final String label;
    final IconData icon;

    if (hasCardsToReview) {
      targetTab = 1; // Practice
      emoji = '🧠';
      label = 'Practice due reviews';
      icon = Icons.quiz;
    } else if (totalCards > 0) {
      targetTab = 0; // Learn
      emoji = '📖';
      label = 'Browse new lessons';
      icon = Icons.auto_stories;
    } else {
      targetTab = 0; // Learn
      emoji = '🐠';
      label = 'Explore the fish encyclopedia';
      icon = Icons.menu_book;
    }

    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: () => ref.read(currentTabProvider.notifier).state = targetTab,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        decoration: BoxDecoration(
          color: AppOverlays.white80,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(color: AppOverlays.white50),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppIconSizes.sm,
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                hasCardsToReview
                    ? 'Tasks done — $emoji reviews waiting!'
                    : 'All caught up! $emoji $label',
                style: AppTypography.labelMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: context.textSecondary,
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _TodayBoardContent extends StatelessWidget {
  final String tankId;
  final List<Task> tasks;

  const _TodayBoardContent({required this.tankId, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final hasOverdue = tasks.any((t) => t.isOverdue);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppOverlays.white88,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: hasOverdue ? AppOverlays.error20 : AppOverlays.white50,
          width: 1,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                hasOverdue ? Icons.warning_amber_rounded : Icons.today_rounded,
                size: 14,
                color: hasOverdue ? AppColors.warning : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Semantics(
                header: true,
                child: Text(
                  hasOverdue ? 'Today board · Needs attention' : 'Today board',
                  style: AppTypography.labelSmall.copyWith(
                    color: hasOverdue ? AppColors.warning : AppColors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Next ${tasks.length.clamp(0, 3)} task${tasks.length == 1 ? '' : 's'}',
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Task rows
          ...tasks.map((task) => _TaskRow(task: task, tankId: tankId)),
        ],
      ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  final Task task;
  final String tankId;

  const _TaskRow({required this.task, required this.tankId});

  /// Map task title keywords → (tabIndex, navigate callback).
  /// tabIndex: 0=Learn, 1=Practice, 2=Tank, 3=Smart, 4=More
  /// Returns the tab index that best matches the task, or null for tank detail.
  int? _resolveTab(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('lesson') || lower.contains('learn') || lower.contains('quiz') || lower.contains('study')) {
      return 0; // Learn tab
    }
    if (lower.contains('review') || lower.contains('practice') || lower.contains('flash')) {
      return 1; // Practice tab
    }
    // Water-related, feeding, maintenance, filter, glass → Tank tab (home)
    return 2; // Tank tab (default for tank tasks)
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = task.isOverdue;
    final isToday = task.isDueToday;

    final rowColor = isOverdue
        ? AppColors.error
        : isToday
        ? AppColors.warning
        : context.textSecondary;

    String dueLabel;
    if (isOverdue) {
      final daysAgo = task.daysUntilDue;
      dueLabel = daysAgo != null && daysAgo < 0
          ? '${(-daysAgo)}d overdue'
          : 'overdue';
    } else if (isToday) {
      dueLabel = 'today';
    } else {
      final days = task.daysUntilDue;
      dueLabel = days != null ? 'in $days ${days == 1 ? 'day' : 'days'}' : '';
    }

    final targetTab = _resolveTab(task.title);

    void handleTap() {
      if (targetTab != null) {
        ref.read(currentTabProvider.notifier).state = targetTab;
      }
    }

    return Semantics(
      label: '${task.title}, $dueLabel. Tap to navigate.',
      button: true,
      child: InkWell(
        onTap: handleTap,
        borderRadius: AppRadius.smallRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
            horizontal: AppSpacing.xs2,
          ),
          child: Row(
            children: [
              // Priority/status dot
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: AppSpacing.xs2),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? AppColors.error
                      : isToday
                      ? AppColors.warning
                      : context.textHint,
                  shape: BoxShape.circle,
                ),
              ),
              // Task title
              Expanded(
                child: Text(
                  task.title,
                  style: AppTypography.bodySmall.copyWith(
                    color: isOverdue ? AppColors.error : context.textPrimary,
                    fontWeight: isOverdue || isToday
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Due label
              if (dueLabel.isNotEmpty)
                Text(
                  dueLabel,
                  style: AppTypography.labelSmall.copyWith(color: rowColor),
                ),
              // Navigation chevron
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs2),
                child: Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: context.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// FQ-E3: Subtle daily XP goal progress bar.
/// Shows today's earned XP vs the daily goal as a slim progress bar.
class _DailyGoalBar extends ConsumerWidget {
  const _DailyGoalBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalData = ref.watch(todaysDailyGoalProvider);
    if (goalData == null) return const SizedBox.shrink();

    final progress = goalData.progress;
    final earned = goalData.earnedXp;
    final target = goalData.targetXp;
    final isComplete = goalData.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppOverlays.white88,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: isComplete
              ? AppColors.success.withAlpha(60)
              : AppOverlays.white50,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle_rounded : Icons.bolt_rounded,
                size: 13,
                color: isComplete ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  isComplete
                      ? 'Daily goal complete! 🎉'
                      : 'Daily goal · $earned / $target XP',
                  style: AppTypography.labelSmall.copyWith(
                    color: isComplete ? AppColors.success : context.textSecondary,
                    fontWeight: isComplete ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTypography.labelSmall.copyWith(
                  color: isComplete ? AppColors.success : context.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: context.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
