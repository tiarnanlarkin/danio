import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../widgets/core/app_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../theme/app_theme.dart';

class TaskPreview extends StatelessWidget {
  final List<Task> tasks;
  final ValueChanged<Task> onComplete;

  const TaskPreview({super.key, required this.tasks, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AppCard(
          padding: AppCardPadding.spacious,
          child: CompactEmptyState(
            icon: Icons.task_alt,
            message: 'No tasks scheduled yet',
            actionLabel: 'Add Task',
            onAction: null, // Handled by parent screen
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppCard(
        padding: AppCardPadding.none,
        child: Column(
          children: tasks
              .asMap()
              .entries
              .map(
                (entry) => TaskTile(
                  task: entry.value,
                  onComplete: () => onComplete(entry.value),
                )
                    .animate()
                    .fadeIn(delay: (50 * entry.key).ms, duration: 300.ms)
                    .slideX(begin: 0.1, end: 0, delay: (50 * entry.key).ms, duration: 300.ms),
              )
              .toList(),
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;

  const TaskTile({super.key, required this.task, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;

    return ListTile(
      leading: Icon(
        isOverdue
            ? Icons.warning_amber
            : (isDueToday ? Icons.today : Icons.schedule),
        color: isOverdue
            ? AppColors.warning
            : (isDueToday ? AppColors.info : AppColors.textHint),
      ),
      title: Text(task.title),
      subtitle: Text(
        task.dueDate != null ? _formatDue(task.dueDate!) : 'No due date',
        style: TextStyle(
          color: isOverdue ? AppColors.warning : AppColors.textSecondary,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.check_circle_outline),
        color: task.isEnabled ? AppColors.success : AppColors.textHint,
        tooltip: 'Complete task',
        onPressed: task.isEnabled ? onComplete : null,
      ),
    );
  }

  String _formatDue(DateTime date) {
    final days = date.difference(DateTime.now()).inDays;
    if (days < 0) return '${-days}d overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    if (days < 7) return 'Due in ${days}d';
    return 'Due ${DateFormat('MMM d').format(date)}';
  }
}
