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
import '../../../theme/app_theme.dart';

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
      error: (_, __) => Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
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
          return _buildEmptyState(context);
        }

        return _TodayBoardContent(tasks: combined);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
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
          const Icon(
            Icons.check_circle_outline,
            size: AppIconSizes.sm,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'All caught up! 🎉',
            style: AppTypography.labelMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayBoardContent extends StatelessWidget {
  final List<Task> tasks;

  const _TodayBoardContent({required this.tasks});

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
              Text(
                hasOverdue ? 'Today board · Needs attention' : 'Today board',
                style: AppTypography.labelSmall.copyWith(
                  color: hasOverdue ? AppColors.warning : AppColors.primary,
                  letterSpacing: 0.4,
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
          ...tasks.map((task) => _TaskRow(task: task)),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final Task task;

  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
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
      dueLabel = days != null ? 'in ${days}d' : '';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
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
              style: AppTypography.labelSmall.copyWith(
                color: rowColor,
              ),
            ),
        ],
      ),
    );
  }
}
