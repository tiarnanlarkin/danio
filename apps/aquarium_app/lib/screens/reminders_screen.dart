import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/empty_state.dart';
import '../widgets/core/bubble_loader.dart';
import '../widgets/mascot/mascot_widgets.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  List<_Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('aquarium_reminders');
      if (json != null) {
        final list = jsonDecode(json) as List;
        setState(() {
          _reminders = list.map((e) => _Reminder.fromJson(e)).toList();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString('aquarium_reminders', json);
  }

  void _addReminder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddReminderSheet(
        onSave: (reminder) {
          setState(() {
            _reminders.add(reminder);
            _reminders.sort((a, b) => a.nextDue.compareTo(b.nextDue));
          });
          _saveReminders();
        },
      ),
    );
  }

  void _toggleReminder(int index) {
    final reminder = _reminders[index];
    setState(() {
      if (reminder.isRecurring) {
        // Mark as done and schedule next occurrence
        final newReminder = reminder.copyWith(
          lastCompleted: DateTime.now(),
          nextDue: _calculateNextDue(reminder),
        );
        _reminders[index] = newReminder;
      } else {
        // One-time reminder - remove it
        _reminders.removeAt(index);
      }
      _reminders.sort((a, b) => a.nextDue.compareTo(b.nextDue));
    });
    _saveReminders();
  }

  DateTime _calculateNextDue(_Reminder reminder) {
    final now = DateTime.now();
    switch (reminder.frequency) {
      case 'daily':
        return DateTime(
          now.year,
          now.month,
          now.day + 1,
          reminder.nextDue.hour,
          reminder.nextDue.minute,
        );
      case 'weekly':
        return DateTime(
          now.year,
          now.month,
          now.day + 7,
          reminder.nextDue.hour,
          reminder.nextDue.minute,
        );
      case 'biweekly':
        return DateTime(
          now.year,
          now.month,
          now.day + 14,
          reminder.nextDue.hour,
          reminder.nextDue.minute,
        );
      case 'monthly':
        return DateTime(
          now.year,
          now.month + 1,
          now.day,
          reminder.nextDue.hour,
          reminder.nextDue.minute,
        );
      default:
        return reminder.nextDue;
    }
  }

  void _deleteReminder(int index) {
    final reminder = _reminders[index];
    setState(() {
      _reminders.removeAt(index);
    });
    _saveReminders();

    // Use native snackbar for undo functionality (AppFeedback doesn't support actions yet)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: ${reminder.title}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _reminders.insert(index, reminder);
              _reminders.sort((a, b) => a.nextDue.compareTo(b.nextDue));
            });
            _saveReminders();
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  int _calculateItemCount(List<_Reminder> overdue, List<_Reminder> upcoming) {
    int count = 0;
    if (overdue.isNotEmpty) {
      count += 1 + overdue.length + 1; // header + items + spacing
    }
    if (upcoming.isNotEmpty) {
      count += 1 + upcoming.length; // header + items
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final overdue = _reminders.where((r) => r.nextDue.isBefore(now)).toList();
    final upcoming = _reminders.where((r) => !r.nextDue.isBefore(now)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: _isLoading
          ? const Center(child: BubbleLoader())
          : _reminders.isEmpty
          ? EmptyState.withMascot(
              icon: Icons.notifications_none,
              title: 'No reminders set',
              message:
                  'Set up reminders for feeding, water changes, and maintenance tasks',
              mascotContext: MascotContext.encouragement,
              actionLabel: 'Add Reminder',
              onAction: _addReminder,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _calculateItemCount(overdue, upcoming),
              itemBuilder: (context, index) {
                int currentIndex = 0;

                // Overdue section
                if (overdue.isNotEmpty) {
                  // Overdue header
                  if (index == currentIndex) {
                    return _SectionHeader(
                      title: 'Overdue',
                      count: overdue.length,
                      color: AppColors.error,
                    );
                  }
                  currentIndex++;

                  // Overdue items
                  if (index < currentIndex + overdue.length) {
                    final r = overdue[index - currentIndex];
                    return _ReminderTile(
                      reminder: r,
                      isOverdue: true,
                      onComplete: () => _toggleReminder(_reminders.indexOf(r)),
                      onDelete: () => _deleteReminder(_reminders.indexOf(r)),
                    );
                  }
                  currentIndex += overdue.length;

                  // Spacing after overdue
                  if (index == currentIndex) {
                    return const SizedBox(height: AppSpacing.lg);
                  }
                  currentIndex++;
                }

                // Upcoming section
                if (upcoming.isNotEmpty) {
                  // Upcoming header
                  if (index == currentIndex) {
                    return _SectionHeader(title: 'Upcoming', count: upcoming.length);
                  }
                  currentIndex++;

                  // Upcoming items
                  if (index < currentIndex + upcoming.length) {
                    final r = upcoming[index - currentIndex];
                    return _ReminderTile(
                      reminder: r,
                      isOverdue: false,
                      onComplete: () => _toggleReminder(_reminders.indexOf(r)),
                      onDelete: () => _deleteReminder(_reminders.indexOf(r)),
                    );
                  }
                }

                return const SizedBox.shrink();
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminder,
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
    );
  }
}

class _Reminder {
  final String id;
  final String title;
  final String? notes;
  final String category;
  final DateTime nextDue;
  final DateTime? lastCompleted;
  final bool isRecurring;
  final String frequency;

  const _Reminder({
    required this.id,
    required this.title,
    this.notes,
    required this.category,
    required this.nextDue,
    this.lastCompleted,
    required this.isRecurring,
    required this.frequency,
  });

  _Reminder copyWith({
    String? title,
    String? notes,
    String? category,
    DateTime? nextDue,
    DateTime? lastCompleted,
    bool? isRecurring,
    String? frequency,
  }) {
    return _Reminder(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      nextDue: nextDue ?? this.nextDue,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'category': category,
    'nextDue': nextDue.toIso8601String(),
    'lastCompleted': lastCompleted?.toIso8601String(),
    'isRecurring': isRecurring,
    'frequency': frequency,
  };

  factory _Reminder.fromJson(Map<String, dynamic> json) => _Reminder(
    id: json['id'],
    title: json['title'],
    notes: json['notes'],
    category: json['category'],
    nextDue: DateTime.parse(json['nextDue']),
    lastCompleted: json['lastCompleted'] != null
        ? DateTime.parse(json['lastCompleted'])
        : null,
    isRecurring: json['isRecurring'] ?? false,
    frequency: json['frequency'] ?? 'once',
  );
}

/// Empty state widget (UNUSED - Kept for reference)
/*
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text('No Reminders Yet', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Set up reminders for water changes, filter cleaning, feeding, and more.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
*/

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color? color;

  const _SectionHeader({required this.title, required this.count, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.1),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Text(
              '$count',
              style: AppTypography.bodySmall.copyWith(
                color: color ?? AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final _Reminder reminder;
  final bool isOverdue;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _ReminderTile({
    required this.reminder,
    required this.isOverdue,
    required this.onComplete,
    required this.onDelete,
  });

  IconData _categoryIcon() {
    switch (reminder.category.toLowerCase()) {
      case 'water change':
        return Icons.water_drop;
      case 'filter':
        return Icons.filter_alt;
      case 'feeding':
        return Icons.restaurant;
      case 'testing':
        return Icons.science;
      case 'medication':
        return Icons.medical_services;
      case 'plants':
        return Icons.eco;
      default:
        return Icons.notifications;
    }
  }

  String _formatDue() {
    final now = DateTime.now();
    final diff = reminder.nextDue.difference(now);

    if (diff.inDays < 0) {
      final days = -diff.inDays;
      if (days == 1) return 'Yesterday';
      return '$days days ago';
    } else if (diff.inDays == 0) {
      if (diff.inHours < 0) return 'Earlier today';
      if (diff.inHours < 1) return 'Soon';
      return 'In ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Tomorrow';
    } else if (diff.inDays < 7) {
      return DateFormat('EEEE').format(reminder.nextDue);
    } else {
      return DateFormat('MMM d').format(reminder.nextDue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: isOverdue ? AppColors.errorAlpha05 : null,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isOverdue ? AppColors.error : AppColors.primary)
                  .withOpacity(0.1),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Icon(
              _categoryIcon(),
              color: isOverdue ? AppColors.error : AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(reminder.title, style: AppTypography.labelLarge),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _formatDue(),
                    style: AppTypography.bodySmall.copyWith(
                      color: isOverdue ? AppColors.error : null,
                    ),
                  ),
                  if (reminder.isRecurring) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.repeat, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Text(reminder.frequency, style: AppTypography.bodySmall),
                  ],
                ],
              ),
              if (reminder.notes != null && reminder.notes!.isNotEmpty)
                Text(
                  reminder.notes!,
                  style: AppTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.check_circle_outline,
              color: isOverdue ? AppColors.error : AppColors.success,
            ),
            onPressed: onComplete,
          ),
        ),
      ),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  final Function(_Reminder) onSave;

  const _AddReminderSheet({required this.onSave});

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = 'Water Change';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _dueTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isRecurring = true;
  String _frequency = 'weekly';

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  final _categories = [
    'Water Change',
    'Filter',
    'Feeding',
    'Testing',
    'Medication',
    'Plants',
    'Other',
  ];
  final _frequencies = ['daily', 'weekly', 'biweekly', 'monthly'];

  void _applyPreset(String preset) {
    switch (preset) {
      case 'water_change':
        _titleController.text = 'Weekly water change';
        _category = 'Water Change';
        _isRecurring = true;
        _frequency = 'weekly';
        _notesController.text = 'Change 25-30% of tank water';
        break;
      case 'filter':
        _titleController.text = 'Clean filter';
        _category = 'Filter';
        _isRecurring = true;
        _frequency = 'monthly';
        _notesController.text = 'Rinse filter media in old tank water';
        break;
      case 'test':
        _titleController.text = 'Test water parameters';
        _category = 'Testing';
        _isRecurring = true;
        _frequency = 'weekly';
        _notesController.text = 'Check ammonia, nitrite, nitrate, pH';
        break;
      case 'feed':
        _titleController.text = 'Daily feeding';
        _category = 'Feeding';
        _isRecurring = true;
        _frequency = 'daily';
        _dueTime = const TimeOfDay(hour: 9, minute: 0);
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Reminder', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),

            // Quick presets
            Text('Quick Presets', style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PresetChip(
                  icon: Icons.water_drop,
                  label: 'Water Change',
                  onTap: () => _applyPreset('water_change'),
                ),
                _PresetChip(
                  icon: Icons.filter_alt,
                  label: 'Filter Clean',
                  onTap: () => _applyPreset('filter'),
                ),
                _PresetChip(
                  icon: Icons.science,
                  label: 'Water Test',
                  onTap: () => _applyPreset('test'),
                ),
                _PresetChip(
                  icon: Icons.restaurant,
                  label: 'Feeding',
                  onTap: () => _applyPreset('feed'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Weekly water change',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Other'),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Due Date'),
                    subtitle: Text(DateFormat('MMM d, y').format(_dueDate)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Time'),
                    subtitle: Text(_dueTime.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _dueTime,
                      );
                      if (picked != null) setState(() => _dueTime = picked);
                    },
                  ),
                ),
              ],
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recurring'),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),

            if (_isRecurring)
              SegmentedButton<String>(
                segments: _frequencies
                    .map(
                      (f) => ButtonSegment(
                        value: f,
                        label: Text(f[0].toUpperCase() + f.substring(1)),
                      ),
                    )
                    .toList(),
                selected: {_frequency},
                onSelectionChanged: (v) => setState(() => _frequency = v.first),
              ),

            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: AppSpacing.md),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_titleController.text.isEmpty) {
                    AppFeedback.showWarning(context, 'Please enter a title');
                    return;
                  }

                  final nextDue = DateTime(
                    _dueDate.year,
                    _dueDate.month,
                    _dueDate.day,
                    _dueTime.hour,
                    _dueTime.minute,
                  );

                  widget.onSave(
                    _Reminder(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      notes: _notesController.text.isNotEmpty
                          ? _notesController.text
                          : null,
                      category: _category,
                      nextDue: nextDue,
                      isRecurring: _isRecurring,
                      frequency: _isRecurring ? _frequency : 'once',
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PresetChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.largeRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppOverlays.primary10,
          borderRadius: AppRadius.largeRadius,
          border: Border.all(color: AppOverlays.primary30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
