import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_dialog.dart';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/danio_snack_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/core/app_states.dart';
import '../widgets/mascot/mascot_widgets.dart';
import '../widgets/app_bottom_sheet.dart';
import '../utils/logger.dart';

const _uuid = Uuid();

class TasksScreen extends ConsumerWidget {
  final String tankId;

  const TasksScreen({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(tankId));

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: tasksAsync.when(
        loading: () => const Center(child: BubbleLoader()),
        error: (err, _) => AppErrorState(
          title: 'Couldn\'t load your tasks',
          onRetry: () => ref.invalidate(tasksProvider(tankId)),
        ),
        data: (tasks) {
          if (tasks.isEmpty) {
            return EmptyState.withMascot(
              icon: Icons.task_alt,
              title: 'Set yourself up for success! ✅',
              message:
                  'Add water changes, testing, and maintenance tasks - your fish will thank you',
              mascotContext: MascotContext.encouragement,
              actionLabel: 'Add Task',
              onAction: () => _showAddDialog(context, ref),
            );
          }

          final overdue = tasks
              .where((t) => t.isOverdue && t.isEnabled)
              .toList();
          final dueToday = tasks
              .where((t) => t.isDueToday && t.isEnabled && !t.isOverdue)
              .toList();
          final upcoming = tasks
              .where((t) => !t.isOverdue && !t.isDueToday && t.isEnabled)
              .toList();
          final disabled = tasks.where((t) => !t.isEnabled).toList();

          // Build flat list of items for ListView.builder
          final items = <_TaskListItem>[];

          if (overdue.isNotEmpty) {
            items.add(
              _TaskListItem.header(
                title: 'Overdue',
                color: AppColors.warning,
                count: overdue.length,
              ),
            );
            items.addAll(overdue.map((t) => _TaskListItem.task(t)));
            items.add(_TaskListItem.spacer());
          }

          if (dueToday.isNotEmpty) {
            items.add(
              _TaskListItem.header(
                title: 'Due Today',
                color: context.textSecondary,
                count: dueToday.length,
              ),
            );
            items.addAll(dueToday.map((t) => _TaskListItem.task(t)));
            items.add(_TaskListItem.spacer());
          }

          if (upcoming.isNotEmpty) {
            items.add(
              _TaskListItem.header(
                title: 'Upcoming',
                color: context.textSecondary,
                count: upcoming.length,
              ),
            );
            items.addAll(upcoming.map((t) => _TaskListItem.task(t)));
            items.add(_TaskListItem.spacer());
          }

          if (disabled.isNotEmpty) {
            items.add(
              _TaskListItem.header(
                title: 'Disabled',
                color: context.textHint,
                count: disabled.length,
              ),
            );
            items.addAll(disabled.map((t) => _TaskListItem.task(t)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              if (item.isHeader) {
                return _SectionHeader(
                  title: item.headerTitle!,
                  color: item.headerColor!,
                  count: item.headerCount!,
                );
              } else if (item.isSpacer) {
                return const SizedBox(height: AppSpacing.md);
              } else {
                final t = item.task!;
                return _TaskCard(
                  task: t,
                  onComplete: () => _completeTask(ref, t),
                  onSnooze: () => _showSnoozeDialog(context, ref, t),
                  onEdit: () => _showEditDialog(context, ref, t),
                  onDelete: () => _confirmDelete(context, ref, t),
                  onHistory: () => _showTaskHistoryDialog(context, t),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        tooltip: 'Add a new task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _completeTask(WidgetRef ref, Task task) async {
    final storage = ref.read(storageServiceProvider);
    final now = DateTime.now();

    final completed = task.complete();
    await storage.saveTask(completed);

    // Also add a log entry so completions show up in Recent Activity.
    await storage.saveLog(
      LogEntry(
        id: _uuid.v4(),
        tankId: tankId,
        type: LogType.taskCompleted,
        timestamp: now,
        title: task.title,
        notes: task.description,
        relatedTaskId: task.id,
        relatedEquipmentId: task.relatedEquipmentId,
        createdAt: now,
      ),
    );

    // If this task is tied to equipment maintenance, update equipment + log it.
    if (task.relatedEquipmentId != null) {
      final equipment = await storage.getEquipmentForTank(tankId);
      Equipment? e;
      for (final x in equipment) {
        if (x.id == task.relatedEquipmentId) {
          e = x;
          break;
        }
      }
      if (e != null) {
        await storage.saveEquipment(
          e.copyWith(lastServiced: now, updatedAt: now),
        );
        await storage.saveLog(
          LogEntry(
            id: _uuid.v4(),
            tankId: tankId,
            type: LogType.equipmentMaintenance,
            timestamp: now,
            title: 'Serviced ${e.name}',
            notes: e.typeName,
            relatedEquipmentId: e.id,
            relatedTaskId: task.id,
            createdAt: now,
          ),
        );
      }
    }

    // Award XP for completing a maintenance task (with boost if active)
    final isBoostActive = ref.read(xpBoostActiveProvider);
    await ref
        .read(userProfileProvider.notifier)
        .recordActivity(
          xp: XpRewards.taskComplete,
          xpBoostActive: isBoostActive,
        );

    ref.invalidate(tasksProvider(tankId));
    ref.invalidate(equipmentProvider(tankId));
    ref.invalidate(logsProvider(tankId));
    ref.invalidate(allLogsProvider(tankId));
  }

  void _showSnoozeDialog(BuildContext context, WidgetRef ref, Task task) {
    showAppDialog(
      context: context,
      title: 'Snooze Task',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('1 day'),
            onTap: () {
              Navigator.maybePop(context);
              _snoozeTask(ref, task, 1);
            },
          ),
          ListTile(
            title: const Text('3 days'),
            onTap: () {
              Navigator.maybePop(context);
              _snoozeTask(ref, task, 3);
            },
          ),
          ListTile(
            title: const Text('1 week'),
            onTap: () {
              Navigator.maybePop(context);
              _snoozeTask(ref, task, 7);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _snoozeTask(WidgetRef ref, Task task, int days) async {
    final storage = ref.read(storageServiceProvider);
    final snoozed = task.snooze(days);
    await storage.saveTask(snoozed);
    ref.invalidate(tasksProvider(tankId));
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showAppDragSheet(
      context: context,
      builder: (_) => _AddTaskSheet(tankId: tankId, ref: ref),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Task task) {
    showAppDragSheet(
      context: context,
      builder: (_) => _AddTaskSheet(tankId: tankId, ref: ref, existing: task),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Task task) {
    showAppDestructiveDialog(
      context: context,
      title: 'Delete Task?',
      message: 'Remove "${task.title}" from your task list?',
      destructiveLabel: 'Delete Task',
      cancelLabel: 'Keep',
      onConfirm: () async {
        try {
          await ref.read(storageServiceProvider).deleteTask(task.id);
          ref.invalidate(tasksProvider(tankId));
        } catch (e, st) {
          logError('TasksScreen: task delete failed: $e', stackTrace: st, tag: 'TasksScreen');
          if (context.mounted) {
            DanioSnackBar.error(context, "Couldn't delete that task. Give it another go!");
          }
        }
      },
    );
  }

  void _showTaskHistoryDialog(BuildContext context, Task task) {
    showDialog<void>(
      context: context,
      builder: (_) => _TaskHistoryDialog(tankId: tankId, task: task),
    );
  }
}

/// Helper class to represent items in the task list (header, task, or spacer)
class _TaskListItem {
  final bool isHeader;
  final bool isSpacer;
  final String? headerTitle;
  final Color? headerColor;
  final int? headerCount;
  final Task? task;

  _TaskListItem._({
    this.isHeader = false,
    this.isSpacer = false,
    this.headerTitle,
    this.headerColor,
    this.headerCount,
    this.task,
  });

  factory _TaskListItem.header({
    required String title,
    required Color color,
    required int count,
  }) => _TaskListItem._(
    isHeader: true,
    headerTitle: title,
    headerColor: color,
    headerCount: count,
  );

  factory _TaskListItem.task(Task task) => _TaskListItem._(task: task);

  factory _TaskListItem.spacer() => _TaskListItem._(isSpacer: true);
}

class _TaskHistoryDialog extends ConsumerWidget {
  final String tankId;
  final Task task;

  const _TaskHistoryDialog({required this.tankId, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allLogsProvider(tankId));

    return AppDialog(
      title: 'History - ${task.title}',
      actions: [
        AppButton(
          label: 'Close',
          onPressed: () => Navigator.maybePop(context),
          variant: AppButtonVariant.text,
        ),
      ],
      child: SizedBox(
        width: double.maxFinite,
        child: logsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.sm2),
            child: Center(child: BubbleLoader.small()),
          ),
          error: (err, _) => AppErrorState(
            compact: true,
            title: 'Couldn\'t load history',
            message: 'Close this and give it another go!',
            onRetry: () => ref.invalidate(allLogsProvider(tankId)),
          ),
          data: (logs) {
            final completions =
                logs.where((l) => l.type == LogType.taskCompleted).where((l) {
                  // Prefer ID match. Fall back to title match for older entries.
                  if (l.relatedTaskId != null) {
                    return l.relatedTaskId == task.id;
                  }
                  return (l.title ?? '') == task.title;
                }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            if (completions.isEmpty) {
              return Text(
                'No completions yet.\n\nTip: when you complete a task, it\'ll show up here and in Recent Activity!',
                style: AppTypography.bodyMedium,
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completed ${task.completionCount} time${task.completionCount == 1 ? '' : 's'}',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm2),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: completions.length.clamp(0, 25),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final log = completions[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 18,
                        ),
                        title: Text(
                          DateFormat('MMM d, yyyy').format(log.timestamp),
                        ),
                        subtitle: Text(
                          DateFormat('h:mm a').format(log.timestamp),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.xxs),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(title, style: AppTypography.labelLarge),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Text(
              '$count',
              style: AppTypography.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onSnooze;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHistory;

  const _TaskCard({
    required this.task,
    required this.onComplete,
    required this.onSnooze,
    required this.onEdit,
    required this.onDelete,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: IconButton(
          tooltip: 'Toggle task',
          icon: Icon(
            Icons.check_circle_outline,
            color: task.isEnabled ? AppColors.success : context.textHint,
          ),
          onPressed: task.isEnabled ? onComplete : null,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: !task.isEnabled ? TextDecoration.lineThrough : null,
            color: !task.isEnabled ? context.textHint : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null)
              Text(
                task.description!,
                style: AppTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (task.dueDate != null)
              Text(
                _formatDue(task.dueDate!),
                style: TextStyle(
                  color: isOverdue
                      ? AppColors.warning
                      : (isDueToday ? AppColors.info : context.textSecondary),
                  fontWeight: (isOverdue || isDueToday)
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            if (task.isEnabled)
              const PopupMenuItem(value: 'snooze', child: Text('Snooze')),
            const PopupMenuItem(value: 'history', child: Text('History')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            if (value == 'snooze') onSnooze();
            if (value == 'history') onHistory();
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
        ),
        onTap: onEdit,
      ),
    );
  }

  String _formatDue(DateTime date) {
    final days = date.difference(DateTime.now()).inDays;
    if (days < -1) return '${-days} days overdue';
    if (days == -1) return 'Yesterday';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 7) return 'In $days days';
    return DateFormat('MMM d').format(date);
  }
}

class _AddTaskSheet extends StatefulWidget {
  final String tankId;
  final WidgetRef ref;
  final Task? existing;

  const _AddTaskSheet({required this.tankId, required this.ref, this.existing});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late RecurrenceType _recurrence;
  late bool _isEnabled;
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.existing?.description ?? '',
    );
    _recurrence = widget.existing?.recurrence ?? RecurrenceType.none;
    _isEnabled = widget.existing?.isEnabled ?? true;
    _dueDate =
        widget.existing?.dueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: max(MediaQuery.of(context).viewInsets.bottom, MediaQuery.of(context).viewPadding.bottom) + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing != null ? 'Edit Task' : 'Add Task',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Clean filter',
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.sm2),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),

            // Recurrence
            Text('Repeat', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _RecurrenceChip(
                  label: 'Once',
                  isSelected: _recurrence == RecurrenceType.none,
                  onTap: () =>
                      setState(() => _recurrence = RecurrenceType.none),
                ),
                _RecurrenceChip(
                  label: 'Daily',
                  isSelected: _recurrence == RecurrenceType.daily,
                  onTap: () =>
                      setState(() => _recurrence = RecurrenceType.daily),
                ),
                _RecurrenceChip(
                  label: 'Weekly',
                  isSelected: _recurrence == RecurrenceType.weekly,
                  onTap: () =>
                      setState(() => _recurrence = RecurrenceType.weekly),
                ),
                _RecurrenceChip(
                  label: 'Monthly',
                  isSelected: _recurrence == RecurrenceType.monthly,
                  onTap: () =>
                      setState(() => _recurrence = RecurrenceType.monthly),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Due date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null && mounted) setState(() => _dueDate = date);
              },
              borderRadius: AppRadius.mediumRadius,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: context.textSecondary),
                    const SizedBox(width: AppSpacing.sm2),
                    Text(
                      _dueDate != null
                          ? DateFormat('MMM d, yyyy').format(_dueDate!)
                          : 'Set due date',
                      style: AppTypography.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            if (widget.existing != null) ...[
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                title: const Text('Enabled'),
                value: _isEnabled,
                onChanged: (v) => setState(() => _isEnabled = v),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
            AppButton(
              onPressed: _isSaving ? null : _save,
              label: widget.existing != null ? 'Save' : 'Add',
              isLoading: _isSaving,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppFeedback.showWarning(context, 'Please enter a title');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = widget.ref.read(storageServiceProvider);
      final now = DateTime.now();

      final task = Task(
        id: widget.existing?.id ?? _uuid.v4(),
        tankId: widget.tankId,
        title: title,
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        recurrence: _recurrence,
        dueDate: _dueDate,
        isEnabled: _isEnabled,
        isAutoGenerated: widget.existing?.isAutoGenerated ?? false,
        lastCompletedAt: widget.existing?.lastCompletedAt,
        completionCount: widget.existing?.completionCount ?? 0,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      await storage.saveTask(task);
      widget.ref.invalidate(tasksProvider(widget.tankId));

      if (mounted) Navigator.maybePop(context);
    } catch (e, st) {
      logError('TasksScreen: task save failed: $e', stackTrace: st, tag: 'TasksScreen');
      if (mounted) {
        AppFeedback.showError(context, 'Oops, something went wrong!');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _RecurrenceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecurrenceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}
