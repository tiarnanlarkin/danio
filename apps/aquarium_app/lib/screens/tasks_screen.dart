import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

const _uuid = Uuid();

class TasksScreen extends ConsumerWidget {
  final String tankId;

  const TasksScreen({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(tankId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          message: 'Failed to load tasks',
          onRetry: () => ref.invalidate(tasksProvider(tankId)),
        ),
        data: (tasks) {
          if (tasks.isEmpty) {
            return EmptyState(
              icon: Icons.task_alt,
              title: 'No tasks yet',
              message: 'Set up reminders for water changes, testing, and maintenance to keep your tank healthy',
              actionLabel: 'Add Task',
              onAction: () => _showAddDialog(context, ref),
            );
          }

          final overdue = tasks.where((t) => t.isOverdue && t.isEnabled).toList();
          final dueToday = tasks.where((t) => t.isDueToday && t.isEnabled && !t.isOverdue).toList();
          final upcoming = tasks.where((t) => !t.isOverdue && !t.isDueToday && t.isEnabled).toList();
          final disabled = tasks.where((t) => !t.isEnabled).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (overdue.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Overdue',
                  color: AppColors.warning,
                  count: overdue.length,
                ),
                ...overdue.map((t) => _TaskCard(
                  task: t,
                  onComplete: () => _completeTask(ref, t),
                  onSnooze: () => _showSnoozeDialog(context, ref, t),
                  onEdit: () => _showEditDialog(context, ref, t),
                  onDelete: () => _confirmDelete(context, ref, t),
                  onHistory: () => _showTaskHistoryDialog(context, t),
                )),
                const SizedBox(height: 16),
              ],
              if (dueToday.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Due Today',
                  color: AppColors.info,
                  count: dueToday.length,
                ),
                ...dueToday.map((t) => _TaskCard(
                  task: t,
                  onComplete: () => _completeTask(ref, t),
                  onSnooze: () => _showSnoozeDialog(context, ref, t),
                  onEdit: () => _showEditDialog(context, ref, t),
                  onDelete: () => _confirmDelete(context, ref, t),
                  onHistory: () => _showTaskHistoryDialog(context, t),
                )),
                const SizedBox(height: 16),
              ],
              if (upcoming.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Upcoming',
                  color: AppColors.textSecondary,
                  count: upcoming.length,
                ),
                ...upcoming.map((t) => _TaskCard(
                  task: t,
                  onComplete: () => _completeTask(ref, t),
                  onSnooze: () => _showSnoozeDialog(context, ref, t),
                  onEdit: () => _showEditDialog(context, ref, t),
                  onDelete: () => _confirmDelete(context, ref, t),
                  onHistory: () => _showTaskHistoryDialog(context, t),
                )),
                const SizedBox(height: 16),
              ],
              if (disabled.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Disabled',
                  color: AppColors.textHint,
                  count: disabled.length,
                ),
                ...disabled.map((t) => _TaskCard(
                  task: t,
                  onComplete: () => _completeTask(ref, t),
                  onSnooze: () => _showSnoozeDialog(context, ref, t),
                  onEdit: () => _showEditDialog(context, ref, t),
                  onDelete: () => _confirmDelete(context, ref, t),
                  onHistory: () => _showTaskHistoryDialog(context, t),
                )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
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
        await storage.saveEquipment(e.copyWith(lastServiced: now, updatedAt: now));
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

    ref.invalidate(tasksProvider(tankId));
    ref.invalidate(equipmentProvider(tankId));
    ref.invalidate(logsProvider(tankId));
    ref.invalidate(allLogsProvider(tankId));
  }

  void _showSnoozeDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Snooze Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1 day'),
              onTap: () {
                Navigator.pop(ctx);
                _snoozeTask(ref, task, 1);
              },
            ),
            ListTile(
              title: const Text('3 days'),
              onTap: () {
                Navigator.pop(ctx);
                _snoozeTask(ref, task, 3);
              },
            ),
            ListTile(
              title: const Text('1 week'),
              onTap: () {
                Navigator.pop(ctx);
                _snoozeTask(ref, task, 7);
              },
            ),
          ],
        ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddTaskSheet(tankId: tankId, ref: ref),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddTaskSheet(tankId: tankId, ref: ref, existing: task),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(storageServiceProvider).deleteTask(task.id);
              ref.invalidate(tasksProvider(tankId));
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showTaskHistoryDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (_) => _TaskHistoryDialog(tankId: tankId, task: task),
    );
  }
}

class _TaskHistoryDialog extends ConsumerWidget {
  final String tankId;
  final Task task;

  const _TaskHistoryDialog({required this.tankId, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allLogsProvider(tankId));

    return AlertDialog(
      title: Text('History — ${task.title}'),
      content: SizedBox(
        width: double.maxFinite,
        child: logsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Text('Error loading history: $err'),
          data: (logs) {
            final completions = logs
                .where((l) => l.type == LogType.taskCompleted)
                .where((l) {
                  // Prefer ID match. Fall back to title match for older entries.
                  if (l.relatedTaskId != null) return l.relatedTaskId == task.id;
                  return (l.title ?? '') == task.title;
                })
                .toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            if (completions.isEmpty) {
              return Text(
                'No completions logged yet.\n\nTip: when you complete the task, it will appear here and in Recent Activity.',
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
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: completions.length.clamp(0, 25),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final log = completions[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                        title: Text(DateFormat('MMM d, yyyy').format(log.timestamp)),
                        subtitle: Text(DateFormat('h:mm a').format(log.timestamp)),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final int count;

  const _SectionHeader({required this.title, required this.color, required this.count});

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
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title, style: AppTypography.labelLarge),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
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
          icon: Icon(
            Icons.check_circle_outline,
            color: task.isEnabled ? AppColors.success : AppColors.textHint,
          ),
          onPressed: task.isEnabled ? onComplete : null,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: !task.isEnabled ? TextDecoration.lineThrough : null,
            color: !task.isEnabled ? AppColors.textHint : null,
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
                      : (isDueToday ? AppColors.info : AppColors.textSecondary),
                  fontWeight: (isOverdue || isDueToday) ? FontWeight.w500 : FontWeight.normal,
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
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descController = TextEditingController(text: widget.existing?.description ?? '');
    _recurrence = widget.existing?.recurrence ?? RecurrenceType.none;
    _isEnabled = widget.existing?.isEnabled ?? true;
    _dueDate = widget.existing?.dueDate ?? DateTime.now().add(const Duration(days: 1));
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Clean filter',
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Recurrence
            Text('Repeat', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _RecurrenceChip(
                  label: 'Once',
                  isSelected: _recurrence == RecurrenceType.none,
                  onTap: () => setState(() => _recurrence = RecurrenceType.none),
                ),
                _RecurrenceChip(
                  label: 'Daily',
                  isSelected: _recurrence == RecurrenceType.daily,
                  onTap: () => setState(() => _recurrence = RecurrenceType.daily),
                ),
                _RecurrenceChip(
                  label: 'Weekly',
                  isSelected: _recurrence == RecurrenceType.weekly,
                  onTap: () => setState(() => _recurrence = RecurrenceType.weekly),
                ),
                _RecurrenceChip(
                  label: 'Monthly',
                  isSelected: _recurrence == RecurrenceType.monthly,
                  onTap: () => setState(() => _recurrence = RecurrenceType.monthly),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Due date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _dueDate = date);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
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
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enabled'),
                value: _isEnabled,
                onChanged: (v) => setState(() => _isEnabled = v),
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.existing != null ? 'Save' : 'Add'),
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
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
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

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Error: $e');
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
