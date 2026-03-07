import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class MaintenanceChecklistScreen extends ConsumerStatefulWidget {
  final String tankId;
  final String tankName;

  const MaintenanceChecklistScreen({
    super.key,
    required this.tankId,
    required this.tankName,
  });

  @override
  ConsumerState<MaintenanceChecklistScreen> createState() =>
      _MaintenanceChecklistScreenState();
}

class _MaintenanceChecklistScreenState
    extends ConsumerState<MaintenanceChecklistScreen> {
  Map<String, bool> _weeklyChecks = {};
  Map<String, bool> _monthlyChecks = {};

  final _weeklyItems = [
    _CheckItem('water_test', 'Test water parameters', Icons.science),
    _CheckItem('water_change', 'Water change (20-30%)', Icons.water_drop),
    _CheckItem('vacuum', 'Vacuum substrate', Icons.cleaning_services),
    _CheckItem('glass', 'Clean glass', Icons.window),
    _CheckItem('check_fish', 'Count & observe fish', Icons.visibility),
    _CheckItem('check_temp', 'Check temperature', Icons.thermostat),
    _CheckItem('trim_plants', 'Trim dead plant matter', Icons.content_cut),
    _CheckItem('top_off', 'Top off evaporated water', Icons.arrow_upward),
  ];

  final _monthlyItems = [
    _CheckItem('clean_filter', 'Rinse filter media', Icons.filter_alt),
    _CheckItem('check_equipment', 'Inspect equipment', Icons.build),
    _CheckItem('deep_clean', 'Deep clean decor if needed', Icons.auto_fix_high),
    _CheckItem('prune_plants', 'Major plant pruning', Icons.eco),
    _CheckItem('check_supplies', 'Check supply levels', Icons.inventory),
    _CheckItem('test_gh_kh', 'Test GH/KH', Icons.analytics),
  ];

  @override
  void initState() {
    super.initState();
    _loadChecks();
  }

  String get _currentWeek {
    final now = DateTime.now();
    final weekNumber = ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7)
        .ceil();
    return '${now.year}-W$weekNumber';
  }

  String get _currentMonth {
    final now = DateTime.now();
    return '${now.year}-${now.month}';
  }

  Future<void> _loadChecks() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = 'checklist_${widget.tankId}';

    final savedWeek = prefs.getString('${prefix}_week');
    final savedMonth = prefs.getString('${prefix}_month');

    if (!mounted) return;
    setState(() {
      // Reset weekly if new week
      if (savedWeek != _currentWeek) {
        _weeklyChecks = {};
      } else {
        for (final item in _weeklyItems) {
          _weeklyChecks[item.id] =
              prefs.getBool('${prefix}_weekly_${item.id}') ?? false;
        }
      }

      // Reset monthly if new month
      if (savedMonth != _currentMonth) {
        _monthlyChecks = {};
      } else {
        for (final item in _monthlyItems) {
          _monthlyChecks[item.id] =
              prefs.getBool('${prefix}_monthly_${item.id}') ?? false;
        }
      }
    });
  }

  Future<void> _saveChecks() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = 'checklist_${widget.tankId}';

    await prefs.setString('${prefix}_week', _currentWeek);
    await prefs.setString('${prefix}_month', _currentMonth);

    for (final item in _weeklyItems) {
      await prefs.setBool(
        '${prefix}_weekly_${item.id}',
        _weeklyChecks[item.id] ?? false,
      );
    }

    for (final item in _monthlyItems) {
      await prefs.setBool(
        '${prefix}_monthly_${item.id}',
        _monthlyChecks[item.id] ?? false,
      );
    }
  }

  void _toggleWeekly(String id) {
    setState(() {
      _weeklyChecks[id] = !(_weeklyChecks[id] ?? false);
    });
    _saveChecks();
  }

  void _toggleMonthly(String id) {
    setState(() {
      _monthlyChecks[id] = !(_monthlyChecks[id] ?? false);
    });
    _saveChecks();
  }

  int get _weeklyComplete => _weeklyChecks.values.where((v) => v).length;
  int get _monthlyComplete => _monthlyChecks.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    final weeklyProgress = _weeklyComplete / _weeklyItems.length;
    final monthlyProgress = _monthlyComplete / _monthlyItems.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tankName} Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset all',
            onPressed: () => _showResetDialog(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          // Build flat list of items for ListView.builder
          final items = <_ChecklistItem>[];
          
          // Progress summary card
          items.add(_ChecklistItem.progressCard(
            weeklyProgress: weeklyProgress,
            monthlyProgress: monthlyProgress,
            weeklyComplete: _weeklyComplete,
            weeklyTotal: _weeklyItems.length,
            monthlyComplete: _monthlyComplete,
            monthlyTotal: _monthlyItems.length,
          ));
          items.add(_ChecklistItem.spacer(AppSpacing.lg));
          
          // Weekly section
          items.add(_ChecklistItem.sectionHeader(
            title: 'Weekly Tasks',
            isComplete: _weeklyComplete == _weeklyItems.length,
          ));
          items.add(_ChecklistItem.spacer(12));
          items.addAll(_weeklyItems.map((item) => _ChecklistItem.weeklyTask(
            item: item,
            checked: _weeklyChecks[item.id] ?? false,
            onTap: () => _toggleWeekly(item.id),
          )));
          items.add(_ChecklistItem.spacer(AppSpacing.lg));
          
          // Monthly section
          items.add(_ChecklistItem.sectionHeader(
            title: 'Monthly Tasks',
            isComplete: _monthlyComplete == _monthlyItems.length,
          ));
          items.add(_ChecklistItem.spacer(12));
          items.addAll(_monthlyItems.map((item) => _ChecklistItem.monthlyTask(
            item: item,
            checked: _monthlyChecks[item.id] ?? false,
            onTap: () => _toggleMonthly(item.id),
          )));
          items.add(_ChecklistItem.spacer(AppSpacing.xxl));

          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              
              if (item.isProgressCard) {
                return AppCard(
                  padding: AppCardPadding.standard,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ProgressCircle(
                              label: 'Weekly',
                              progress: item.weeklyProgress!,
                              count: '${item.weeklyComplete}/${item.weeklyTotal}',
                            ),
                          ),
                          Expanded(
                            child: _ProgressCircle(
                              label: 'Monthly',
                              progress: item.monthlyProgress!,
                              count: '${item.monthlyComplete}/${item.monthlyTotal}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm2),
                      Text(
                        DateFormat('MMMM d, y').format(DateTime.now()),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                );
              } else if (item.isSectionHeader) {
                return Row(
                  children: [
                    Text(item.sectionTitle!, style: AppTypography.headlineSmall),
                    const Spacer(),
                    if (item.sectionComplete!)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: AppRadius.mediumRadius,
                        ),
                        child: Text(
                          '✓ Complete!',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                  ],
                );
              } else if (item.isSpacer) {
                return SizedBox(height: item.spacerHeight);
              } else {
                return _TaskTile(
                  item: item.taskItem!,
                  checked: item.taskChecked!,
                  onTap: item.taskOnTap!,
                );
              }
            },
          );
        },
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Checklist?'),
        content: const Text('This will uncheck all items. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _weeklyChecks = {};
                _monthlyChecks = {};
              });
              _saveChecks();
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// Helper class to represent items in the checklist (progress card, section header, task, or spacer)
class _ChecklistItem {
  final bool isProgressCard;
  final bool isSectionHeader;
  final bool isSpacer;
  
  // Progress card fields
  final double? weeklyProgress;
  final double? monthlyProgress;
  final int? weeklyComplete;
  final int? weeklyTotal;
  final int? monthlyComplete;
  final int? monthlyTotal;
  
  // Section header fields
  final String? sectionTitle;
  final bool? sectionComplete;
  
  // Spacer fields
  final double? spacerHeight;
  
  // Task fields
  final _CheckItem? taskItem;
  final bool? taskChecked;
  final VoidCallback? taskOnTap;

  _ChecklistItem._({
    this.isProgressCard = false,
    this.isSectionHeader = false,
    this.isSpacer = false,
    this.weeklyProgress,
    this.monthlyProgress,
    this.weeklyComplete,
    this.weeklyTotal,
    this.monthlyComplete,
    this.monthlyTotal,
    this.sectionTitle,
    this.sectionComplete,
    this.spacerHeight,
    this.taskItem,
    this.taskChecked,
    this.taskOnTap,
  });

  factory _ChecklistItem.progressCard({
    required double weeklyProgress,
    required double monthlyProgress,
    required int weeklyComplete,
    required int weeklyTotal,
    required int monthlyComplete,
    required int monthlyTotal,
  }) =>
      _ChecklistItem._(
        isProgressCard: true,
        weeklyProgress: weeklyProgress,
        monthlyProgress: monthlyProgress,
        weeklyComplete: weeklyComplete,
        weeklyTotal: weeklyTotal,
        monthlyComplete: monthlyComplete,
        monthlyTotal: monthlyTotal,
      );

  factory _ChecklistItem.sectionHeader({
    required String title,
    required bool isComplete,
  }) =>
      _ChecklistItem._(
        isSectionHeader: true,
        sectionTitle: title,
        sectionComplete: isComplete,
      );

  factory _ChecklistItem.spacer(double height) =>
      _ChecklistItem._(isSpacer: true, spacerHeight: height);

  factory _ChecklistItem.weeklyTask({
    required _CheckItem item,
    required bool checked,
    required VoidCallback onTap,
  }) =>
      _ChecklistItem._(
        taskItem: item,
        taskChecked: checked,
        taskOnTap: onTap,
      );

  factory _ChecklistItem.monthlyTask({
    required _CheckItem item,
    required bool checked,
    required VoidCallback onTap,
  }) =>
      _ChecklistItem._(
        taskItem: item,
        taskChecked: checked,
        taskOnTap: onTap,
      );
}

class _CheckItem {
  final String id;
  final String label;
  final IconData icon;

  const _CheckItem(this.id, this.label, this.icon);
}

class _TaskTile extends StatelessWidget {
  final _CheckItem item;
  final bool checked;
  final VoidCallback onTap;

  const _TaskTile({
    required this.item,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: checked ? AppColors.success : AppColors.textHint,
        ),
        title: Text(
          item.label,
          style: AppTypography.bodyMedium.copyWith(
            decoration: checked ? TextDecoration.lineThrough : null,
            color: checked ? AppColors.textHint : null,
          ),
        ),
        trailing: Checkbox(
          value: checked,
          onChanged: (_) => onTap(),
          activeColor: AppColors.success,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  final String label;
  final double progress;
  final String count;

  const _ProgressCircle({
    required this.label,
    required this.progress,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(
                  progress == 1.0 ? AppColors.success : AppColors.primary,
                ),
              ),
              Center(
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTypography.labelLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: AppTypography.labelLarge),
        Text(count, style: AppTypography.bodySmall),
      ],
    );
  }
}
