import 'package:flutter/foundation.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import '../widgets/core/app_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../utils/skeleton_placeholders.dart';
import '../widgets/empty_state.dart';
import '../widgets/core/app_states.dart';
import '../widgets/mascot/mascot_widgets.dart';
import '../navigation/app_routes.dart';
import 'log_detail_screen.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/app_bottom_sheet.dart';

class LogsScreen extends ConsumerStatefulWidget {
  final String tankId;

  const LogsScreen({super.key, required this.tankId});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  /// Empty = all types.
  Set<LogType> _typeFilters = <LogType>{};
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(allLogsProvider(widget.tankId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
            onPressed: () => _openFilters(context),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: AppDurations.medium4,
        switchInCurve: Curves.easeOutCubic,
        child: logsAsync.when(
          loading: () => _buildSkeletonList(),
          error: (err, _) => AppErrorState(
            title: 'Couldn\'t load your logs',
            onRetry: () => ref.invalidate(allLogsProvider(widget.tankId)),
          ),
          data: (logs) {
            final filtered = logs.where(_matchesFilters).toList();

            final hasAnyFilters = _typeFilters.isNotEmpty || _dateRange != null;

            if (filtered.isEmpty) {
              if (logs.isEmpty) {
                return EmptyState.withMascot(
                  icon: Icons.list_alt,
                  title: 'Start your tank\'s story! 📖',
                  message:
                      'Start logging water tests, maintenance, and events to track your tank\'s history',
                  mascotContext: MascotContext.noLogs,
                  actionLabel: 'Add Log Entry',
                  onAction: () => AppRoutes.toAddLog(context, widget.tankId),
                );
              } else {
                // Has logs but filtered out
                return EmptyState(
                  icon: Icons.filter_list_off,
                  title: 'No matching logs',
                  message: 'Try adjusting or clearing your filters',
                  actionLabel: 'Clear Filters',
                  onAction: _clearFilters,
                );
              }
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(allLogsProvider(widget.tankId));
                // Wait for new data to load
                await Future.delayed(AppDurations.long2);
              },
              child: Column(
                children: [
                  _FiltersSummaryBar(
                    typeFilters: _typeFilters,
                    dateRange: _dateRange,
                    onClear: hasAnyFilters ? _clearFilters : null,
                    onEdit: () => _openFilters(context),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final log = filtered[index];
                        return Card(
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getLogColor(
                                    log.type,
                                  ).withAlpha(51),
                                  child: Icon(
                                    _getLogIcon(log.type),
                                    color: _getLogColor(log.type),
                                    size: AppIconSizes.sm,
                                  ),
                                ),
                                title: Text(_titleFor(log)),
                                subtitle: Text(
                                  DateFormat(
                                    'd MMM yyyy  •  h:mm a',
                                  ).format(log.timestamp),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => NavigationThrottle.push(
                                  context,
                                  LogDetailScreen(
                                    tankId: widget.tankId,
                                    logId: log.id,
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                            .slideX(
                              begin: 0.1,
                              end: 0,
                              delay: (50 * index).ms,
                              duration: 300.ms,
                            );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a new log entry',
        child: const Icon(Icons.add),
        onPressed: () => _showAddLogSheet(context),
      ),
    );
  }

  bool _matchesFilters(LogEntry log) {
    if (_typeFilters.isNotEmpty && !_typeFilters.contains(log.type)) {
      return false;
    }

    final range = _dateRange;
    if (range != null) {
      // Inclusive end (by extending to end-of-day).
      final start = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final end = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
        999,
      );
      if (log.timestamp.isBefore(start) || log.timestamp.isAfter(end)) {
        return false;
      }
    }

    return true;
  }

  void _clearFilters() {
    setState(() {
      _typeFilters = <LogType>{};
      _dateRange = null;
    });
  }

  Widget _buildSkeletonList() {
    final placeholders = SkeletonPlaceholders.logsList;
    return Skeletonizer(
      child: Column(
        children: [
          _FiltersSummaryBar(
            typeFilters: const {},
            dateRange: null,
            onClear: null,
            onEdit: () {},
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
              itemCount: placeholders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final log = placeholders[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getLogColor(log.type).withAlpha(51),
                      child: Icon(
                        _getLogIcon(log.type),
                        color: _getLogColor(log.type),
                        size: AppIconSizes.sm,
                      ),
                    ),
                    title: Text(_titleFor(log)),
                    subtitle: Text(
                      DateFormat(
                        'd MMM yyyy  •  h:mm a',
                      ).format(log.timestamp),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilters(BuildContext context) async {
    final initialTypes = Set<LogType>.from(_typeFilters);
    final initialRange = _dateRange;

    Set<LogType> workingTypes = Set<LogType>.from(initialTypes);
    DateTimeRange? workingRange = initialRange;

    await showAppDragSheet<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final hasChanges =
                workingRange != initialRange ||
                !setEquals(workingTypes, initialTypes);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Filters',
                            style: AppTypography.headlineSmall,
                          ),
                        ),
                        AppButton(
                          label: 'Clear',
                          onPressed: () {
                            setModalState(() {
                              workingTypes = <LogType>{};
                              workingRange = null;
                            });
                          },
                          variant: AppButtonVariant.text,
                          size: AppButtonSize.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    Text('Type', style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: LogType.values.map((t) {
                        final selected = workingTypes.contains(t);
                        return FilterChip(
                          label: Text(_typeName(t)),
                          selected: selected,
                          onSelected: (v) {
                            setModalState(() {
                              if (v) {
                                workingTypes.add(t);
                              } else {
                                workingTypes.remove(t);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.md),
                    Text('Date', style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: ctx,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          initialDateRange: workingRange,
                        );
                        if (picked != null) {
                          setModalState(() => workingRange = picked);
                        }
                      },
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        workingRange == null
                            ? 'Any date'
                            : '${DateFormat('d MMM').format(workingRange!.start)} - ${DateFormat('d MMM').format(workingRange!.end)}',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      onPressed: hasChanges
                          ? () {
                              setState(() {
                                _typeFilters = Set<LogType>.from(workingTypes);
                                _dateRange = workingRange;
                              });
                              Navigator.maybePop(ctx);
                            }
                          : () => Navigator.maybePop(ctx),
                      label: hasChanges ? 'Apply' : 'Done',
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddLogSheet(BuildContext context) {
    showAppDragSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.science),
              title: const Text('Water Test'),
              onTap: () {
                Navigator.maybePop(ctx);
                _openAdd(context, LogType.waterTest);
              },
            ),
            ListTile(
              leading: const Icon(Icons.water_drop),
              title: const Text('Water Change'),
              onTap: () {
                Navigator.maybePop(ctx);
                _openAdd(context, LogType.waterChange);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Observation'),
              onTap: () {
                Navigator.maybePop(ctx);
                _openAdd(context, LogType.observation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('Medication'),
              onTap: () {
                Navigator.maybePop(ctx);
                _openAdd(context, LogType.medication);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openAdd(BuildContext context, LogType type) {
    AppRoutes.toAddLog(context, widget.tankId, initialType: type);
  }

  static String _typeName(LogType type) {
    switch (type) {
      case LogType.waterTest:
        return 'Water Test';
      case LogType.waterChange:
        return 'Water Change';
      case LogType.feeding:
        return 'Feeding';
      case LogType.medication:
        return 'Medication';
      case LogType.observation:
        return 'Observation';
      case LogType.livestockAdded:
        return 'Livestock Added';
      case LogType.livestockRemoved:
        return 'Livestock Removed';
      case LogType.equipmentMaintenance:
        return 'Equipment Maintenance';
      case LogType.taskCompleted:
        return 'Task Completed';
      case LogType.other:
        return 'Other';
    }
  }

  static IconData _getLogIcon(LogType type) {
    switch (type) {
      case LogType.waterTest:
        return Icons.science;
      case LogType.waterChange:
        return Icons.water_drop;
      case LogType.feeding:
        return Icons.restaurant;
      case LogType.medication:
        return Icons.medication;
      case LogType.observation:
        return Icons.visibility;
      case LogType.livestockAdded:
        return Icons.add_circle;
      case LogType.livestockRemoved:
        return Icons.remove_circle;
      case LogType.equipmentMaintenance:
        return Icons.build;
      case LogType.taskCompleted:
        return Icons.task_alt;
      case LogType.other:
        return Icons.note;
    }
  }

  static Color _getLogColor(LogType type) {
    switch (type) {
      case LogType.waterTest:
        return AppColors.primary;
      case LogType.waterChange:
        return AppColors.secondary;
      case LogType.feeding:
        return AppColors.warning;
      case LogType.medication:
        return AppColors.error;
      case LogType.observation:
        return AppColors.accentAlt;
      case LogType.livestockAdded:
        return AppColors.success;
      case LogType.livestockRemoved:
        return AppColors.error;
      case LogType.equipmentMaintenance:
        return AppColors.woodBrown;
      case LogType.taskCompleted:
        return AppColors.success;
      case LogType.other:
        return AppColors.textHint;
    }
  }

  static String _titleFor(LogEntry log) {
    switch (log.type) {
      case LogType.waterTest:
        final test = log.waterTest;
        if (test != null) {
          final parts = <String>[];
          if (test.ammonia != null) parts.add('NH₃: ${test.ammonia}');
          if (test.nitrite != null) parts.add('NO₂: ${test.nitrite}');
          if (test.nitrate != null) parts.add('NO₃: ${test.nitrate}');
          if (test.ph != null) parts.add('pH: ${test.ph}');
          if (parts.isNotEmpty) return parts.take(2).join(', ');
        }
        return 'Water Test';
      case LogType.waterChange:
        return 'Water Change${log.waterChangePercent != null ? ' (${log.waterChangePercent}%)' : ''}';
      case LogType.taskCompleted:
        return log.title != null ? 'Completed: ${log.title}' : 'Task completed';
      default:
        return log.title ?? log.typeName;
    }
  }
}

class _FiltersSummaryBar extends StatelessWidget {
  final Set<LogType> typeFilters;
  final DateTimeRange? dateRange;
  final VoidCallback? onClear;
  final VoidCallback onEdit;

  const _FiltersSummaryBar({
    required this.typeFilters,
    required this.dateRange,
    required this.onClear,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (typeFilters.isNotEmpty) {
      final label = typeFilters.length == 1
          ? _LogsScreenState._typeName(typeFilters.first)
          : '${typeFilters.length} types';
      chips.add(_Chip(label: label));
    }

    if (dateRange != null) {
      chips.add(
        _Chip(
          label:
              '${DateFormat('d MMM').format(dateRange!.start)}-${DateFormat('d MMM').format(dateRange!.end)}',
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm2, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: chips.isEmpty
                ? Text('All activity', style: AppTypography.bodySmall)
                : Wrap(spacing: 8, runSpacing: 8, children: chips),
          ),
          AppButton(
            label: 'Edit',
            onPressed: onEdit,
            leadingIcon: Icons.tune,
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
          ),
          if (onClear != null)
            IconButton(
              tooltip: 'Clear',
              onPressed: onClear,
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm3,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(label, style: AppTypography.bodySmall),
    );
  }
}
