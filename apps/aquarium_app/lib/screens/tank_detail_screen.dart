import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../services/stocking_calculator.dart';
import '../theme/app_theme.dart';
import 'add_log_screen.dart';
import 'livestock_screen.dart';
import 'equipment_screen.dart';
import 'tasks_screen.dart';
import 'charts_screen.dart';
import 'logs_screen.dart';
import 'log_detail_screen.dart';
import 'tank_settings_screen.dart';
import '../widgets/cycling_status_card.dart';

const _uuid = Uuid();

class TankDetailScreen extends ConsumerWidget {
  final String tankId;

  const TankDetailScreen({super.key, required this.tankId});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tankAsync = ref.watch(tankProvider(tankId));
    final logsRecentAsync = ref.watch(logsProvider(tankId));
    final logsAllAsync = ref.watch(allLogsProvider(tankId));
    final livestockAsync = ref.watch(livestockProvider(tankId));
    final equipmentAsync = ref.watch(equipmentProvider(tankId));
    final tasksAsync = ref.watch(tasksProvider(tankId));

    return tankAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Failed to load tank: $err')),
      ),
      data: (tank) {
        if (tank == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Tank not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    tank.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            Icons.water,
                            size: 150,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.show_chart, color: Colors.white),
                    tooltip: 'Charts',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChartsScreen(tankId: tankId),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    tooltip: 'Tank settings',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TankSettingsScreen(tankId: tankId),
                      ),
                    ),
                  ),
                ],
              ),

              // Quick stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _QuickStats(tank: tank, logsAsync: logsAllAsync),
                ),
              ),

              // Action buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.science_outlined,
                          label: 'Log Test',
                          color: AppColors.primary,
                          onTap: () => _navigateToAddLog(context, LogType.waterTest),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.water_drop_outlined,
                          label: 'Water Change',
                          color: AppColors.secondary,
                          onTap: () => _navigateToAddLog(context, LogType.waterChange),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.note_add_outlined,
                          label: 'Add Note',
                          color: AppColors.accent,
                          onTap: () => _navigateToAddLog(context, LogType.observation),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Dashboard: latest snapshot
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: logsAllAsync.when(
                    loading: () => const _DashboardLoadingCard(title: 'Latest Water Snapshot'),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (logs) => _LatestSnapshotCard(tank: tank, logs: logs),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Dashboard: trends
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: logsAllAsync.when(
                    loading: () => const _DashboardLoadingCard(title: 'Trends'),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (logs) => _TrendsRow(
                      tank: tank,
                      logs: logs,
                      onOpenCharts: (param) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChartsScreen(tankId: tankId, initialParam: param),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Dashboard: alerts
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: logsAllAsync.when(
                    loading: () => const _DashboardLoadingCard(title: 'Alerts'),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (logs) => _AlertsCard(tank: tank, logs: logs),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Cycling status (for tanks < 90 days old)
              SliverToBoxAdapter(
                child: logsAllAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (logs) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: CyclingStatusCard(tank: tank, logs: logs),
                  ),
                ),
              ),

              // Sections
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Tasks',
                  trailing: tasksAsync.when(
                    loading: () => null,
                    error: (_, __) => null,
                    data: (tasks) {
                      final pending = tasks.where((t) => t.isEnabled && (t.isOverdue || t.isDueToday)).length;
                      if (pending == 0) return null;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pending',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white),
                        ),
                      );
                    },
                  ),
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TasksScreen(tankId: tankId)),
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: tasksAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (tasks) => _TaskPreview(
                    tasks: tasks.take(3).toList(),
                    onComplete: (t) => _completeTask(ref, t),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Recent logs
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Recent Activity',
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LogsScreen(tankId: tankId)),
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: logsRecentAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (logs) => _LogsList(
                    logs: logs.take(5).toList(),
                    onTap: (log) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogDetailScreen(tankId: tankId, logId: log.id),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Livestock
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Livestock',
                  trailing: livestockAsync.when(
                    loading: () => null,
                    error: (_, __) => null,
                    data: (livestock) => Text(
                      '${livestock.fold<int>(0, (sum, l) => sum + l.count)} fish',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LivestockScreen(tankId: tankId)),
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: livestockAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (livestock) => _LivestockPreview(livestock: livestock),
                ),
              ),

              // Stocking level indicator
              SliverToBoxAdapter(
                child: livestockAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (livestock) {
                    if (livestock.isEmpty) return const SizedBox.shrink();
                    final result = StockingCalculator.calculate(
                      tank: tank,
                      livestock: livestock,
                    );
                    return _StockingIndicator(result: result);
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Equipment
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Equipment',
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EquipmentScreen(tankId: tankId)),
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: equipmentAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (equipment) => _EquipmentPreview(equipment: equipment),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          floatingActionButton: _QuickAddFab(
            onWaterTest: () => _navigateToAddLog(context, LogType.waterTest),
            onWaterChange: () => _navigateToAddLog(context, LogType.waterChange),
            onObservation: () => _navigateToAddLog(context, LogType.observation),
            onFeeding: () => _quickLogFeeding(context, ref),
          ),
        );
      },
    );
  }

  Future<void> _quickLogFeeding(BuildContext context, WidgetRef ref) async {
    final storage = ref.read(storageServiceProvider);
    final now = DateTime.now();

    await storage.saveLog(
      LogEntry(
        id: _uuid.v4(),
        tankId: tankId,
        type: LogType.feeding,
        timestamp: now,
        title: 'Fed fish',
        createdAt: now,
      ),
    );

    ref.invalidate(logsProvider(tankId));
    ref.invalidate(allLogsProvider(tankId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Feeding logged! 🐟'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToAddLog(BuildContext context, LogType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddLogScreen(tankId: tankId, initialType: type),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final Tank tank;
  final AsyncValue<List<LogEntry>> logsAsync;

  const _QuickStats({required this.tank, required this.logsAsync});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'Volume',
              value: '${tank.volumeLitres.toStringAsFixed(0)}L',
              icon: Icons.straighten,
            ),
            _StatItem(
              label: 'Age',
              value: _formatAge(tank.startDate),
              icon: Icons.calendar_today,
            ),
            logsAsync.when(
              loading: () => const _StatItem(
                label: 'Last Test',
                value: '...',
                icon: Icons.science,
              ),
              error: (_, __) => const _StatItem(
                label: 'Last Test',
                value: '-',
                icon: Icons.science,
              ),
              data: (logs) {
                final lastTest = logs.where((l) => l.type == LogType.waterTest).firstOrNull;
                return _StatItem(
                  label: 'Last Test',
                  value: lastTest != null ? _formatRelative(lastTest.timestamp) : 'Never',
                  icon: Icons.science,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatAge(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days < 7) return '${days}d';
    if (days < 30) return '${(days / 7).floor()}w';
    if (days < 365) return '${(days / 30).floor()}mo';
    return '${(days / 365).floor()}y';
  }

  String _formatRelative(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return '1d ago';
    if (days < 7) return '${days}d ago';
    return DateFormat('MMM d').format(date);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.headlineSmall),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onViewAll;

  const _SectionHeader({required this.title, this.trailing, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(title, style: AppTypography.headlineSmall),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          const Spacer(),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text('View All'),
            ),
        ],
      ),
    );
  }
}

class _TaskPreview extends StatelessWidget {
  final List<Task> tasks;
  final ValueChanged<Task> onComplete;

  const _TaskPreview({required this.tasks, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text('No tasks scheduled', style: AppTypography.bodyMedium),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: tasks
              .map((task) => _TaskTile(task: task, onComplete: () => onComplete(task)))
              .toList(),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;

  const _TaskTile({required this.task, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;

    return ListTile(
      leading: Icon(
        isOverdue ? Icons.warning_amber : (isDueToday ? Icons.today : Icons.schedule),
        color: isOverdue ? AppColors.warning : (isDueToday ? AppColors.info : AppColors.textHint),
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

class _LogsList extends StatelessWidget {
  final List<LogEntry> logs;
  final ValueChanged<LogEntry>? onTap;

  const _LogsList({required this.logs, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text('No logs yet', style: AppTypography.bodyMedium),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: logs.map((log) => _LogTile(log: log, onTap: onTap)).toList(),
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final LogEntry log;
  final ValueChanged<LogEntry>? onTap;

  const _LogTile({required this.log, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getLogColor(log.type).withOpacity(0.2),
        child: Icon(_getLogIcon(log.type), color: _getLogColor(log.type), size: 20),
      ),
      title: Text(_getLogTitle(log)),
      subtitle: Text(DateFormat('MMM d, h:mm a').format(log.timestamp)),
      onTap: () => onTap?.call(log),
    );
  }

  IconData _getLogIcon(LogType type) {
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

  Color _getLogColor(LogType type) {
    switch (type) {
      case LogType.waterTest:
        return AppColors.primary;
      case LogType.waterChange:
        return AppColors.secondary;
      case LogType.feeding:
        return Colors.orange;
      case LogType.medication:
        return Colors.red;
      case LogType.observation:
        return Colors.purple;
      case LogType.livestockAdded:
        return AppColors.success;
      case LogType.livestockRemoved:
        return AppColors.error;
      case LogType.equipmentMaintenance:
        return Colors.brown;
      case LogType.taskCompleted:
        return AppColors.success;
      case LogType.other:
        return AppColors.textHint;
    }
  }

  String _getLogTitle(LogEntry log) {
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

class _LivestockPreview extends StatelessWidget {
  final List<Livestock> livestock;

  const _LivestockPreview({required this.livestock});

  @override
  Widget build(BuildContext context) {
    if (livestock.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text('No livestock yet', style: AppTypography.bodyMedium),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: livestock.length,
        itemBuilder: (context, index) {
          final l = livestock[index];
          return Container(
            width: 120,
            margin: EdgeInsets.only(right: index < livestock.length - 1 ? 12 : 0),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.set_meal, color: AppColors.primary),
                    const Spacer(),
                    Text(
                      l.commonName,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('×${l.count}', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EquipmentPreview extends StatelessWidget {
  final List<Equipment> equipment;

  const _EquipmentPreview({required this.equipment});

  @override
  Widget build(BuildContext context) {
    if (equipment.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text('No equipment yet', style: AppTypography.bodyMedium),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: equipment.length,
        itemBuilder: (context, index) {
          final e = equipment[index];
          final isOverdue = e.isMaintenanceOverdue;
          return Container(
            width: 120,
            margin: EdgeInsets.only(right: index < equipment.length - 1 ? 12 : 0),
            child: Card(
              margin: EdgeInsets.zero,
              color: isOverdue ? AppColors.warning.withOpacity(0.1) : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _getEquipmentIcon(e.type),
                      color: isOverdue ? AppColors.warning : AppColors.primary,
                    ),
                    const Spacer(),
                    Text(
                      e.name,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(e.typeName, style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getEquipmentIcon(EquipmentType type) {
    switch (type) {
      case EquipmentType.filter: return Icons.filter_alt;
      case EquipmentType.heater: return Icons.thermostat;
      case EquipmentType.light: return Icons.light_mode;
      case EquipmentType.airPump: return Icons.air;
      case EquipmentType.co2System: return Icons.bubble_chart;
      case EquipmentType.autoFeeder: return Icons.restaurant;
      case EquipmentType.thermometer: return Icons.device_thermostat;
      case EquipmentType.wavemaker: return Icons.waves;
      case EquipmentType.skimmer: return Icons.filter_drama;
      case EquipmentType.other: return Icons.settings;
    }
  }
}

class _DashboardLoadingCard extends StatelessWidget {
  final String title;

  const _DashboardLoadingCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(title, style: AppTypography.headlineSmall),
            const Spacer(),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestSnapshotCard extends StatelessWidget {
  final Tank tank;
  final List<LogEntry> logs;

  const _LatestSnapshotCard({required this.tank, required this.logs});

  @override
  Widget build(BuildContext context) {
    final latest = logs.firstWhereOrNull(
      (l) => l.type == LogType.waterTest && l.waterTest != null && l.waterTest!.hasValues,
    );

    if (latest == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Latest Water Snapshot', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              Text('No water tests logged yet.', style: AppTypography.bodyMedium),
            ],
          ),
        ),
      );
    }

    final t = latest.waterTest!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Latest Water Snapshot', style: AppTypography.headlineSmall),
                const Spacer(),
                Text(
                  DateFormat('MMM d').format(latest.timestamp),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ParamPill(
                  label: 'Temp',
                  value: _fmt(t.temperature, decimals: 1),
                  unit: '°C',
                  status: _rangeStatus(
                    value: t.temperature,
                    min: tank.targets.tempMin,
                    max: tank.targets.tempMax,
                  ),
                ),
                _ParamPill(
                  label: 'pH',
                  value: _fmt(t.ph, decimals: 1),
                  status: _rangeStatus(
                    value: t.ph,
                    min: tank.targets.phMin,
                    max: tank.targets.phMax,
                  ),
                ),
                _ParamPill(
                  label: 'NH₃',
                  value: _fmt(t.ammonia, decimals: 2),
                  unit: 'ppm',
                  status: _thresholdStatus(value: t.ammonia, warn: 0.25, danger: 0.5),
                ),
                _ParamPill(
                  label: 'NO₂',
                  value: _fmt(t.nitrite, decimals: 2),
                  unit: 'ppm',
                  status: _thresholdStatus(value: t.nitrite, warn: 0.25, danger: 0.5),
                ),
                _ParamPill(
                  label: 'NO₃',
                  value: _fmt(t.nitrate, decimals: 0),
                  unit: 'ppm',
                  status: _thresholdStatus(value: t.nitrate, warn: 20, danger: 40),
                ),
                _ParamPill(
                  label: 'GH',
                  value: _fmt(t.gh, decimals: 0),
                  unit: 'dGH',
                  status: _rangeStatus(
                    value: t.gh,
                    min: tank.targets.ghMin,
                    max: tank.targets.ghMax,
                  ),
                ),
                _ParamPill(
                  label: 'KH',
                  value: _fmt(t.kh, decimals: 0),
                  unit: 'dKH',
                  status: _rangeStatus(
                    value: t.kh,
                    min: tank.targets.khMin,
                    max: tank.targets.khMax,
                  ),
                ),
                _ParamPill(
                  label: 'PO₄',
                  value: _fmt(t.phosphate, decimals: 2),
                  unit: 'ppm',
                  status: _thresholdStatus(value: t.phosphate, warn: 1.0, danger: 2.0),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Tip: tap a trend below to jump straight to charts.',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double? v, {required int decimals}) {
    if (v == null) return '—';
    return v.toStringAsFixed(decimals);
  }

  _ParamStatus _thresholdStatus({required double? value, required double warn, required double danger}) {
    if (value == null) return _ParamStatus.unknown;
    if (value >= danger) return _ParamStatus.danger;
    if (value >= warn) return _ParamStatus.warning;
    return _ParamStatus.safe;
  }

  _ParamStatus _rangeStatus({required double? value, required double? min, required double? max}) {
    if (value == null) return _ParamStatus.unknown;
    if (min == null && max == null) return _ParamStatus.unknown;

    final below = min != null && value < min;
    final above = max != null && value > max;

    if (below || above) return _ParamStatus.warning;
    return _ParamStatus.safe;
  }
}

enum _ParamStatus {
  unknown,
  safe,
  warning,
  danger,
}

class _ParamPill extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final _ParamStatus status;

  const _ParamPill({
    required this.label,
    required this.value,
    this.unit,
    required this.status,
  });

  Color _statusColor() {
    switch (status) {
      case _ParamStatus.safe:
        return AppColors.paramSafe;
      case _ParamStatus.warning:
        return AppColors.paramWarning;
      case _ParamStatus.danger:
        return AppColors.paramDanger;
      case _ParamStatus.unknown:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _statusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySmall),
              const SizedBox(height: 2),
              Text(
                unit == null ? value : '$value $unit',
                style: AppTypography.labelLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendsRow extends StatelessWidget {
  final Tank tank;
  final List<LogEntry> logs;
  final ValueChanged<String> onOpenCharts;

  const _TrendsRow({required this.tank, required this.logs, required this.onOpenCharts});

  @override
  Widget build(BuildContext context) {
    final tests = logs
        .where((l) => l.type == LogType.waterTest && l.waterTest != null)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (tests.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trends', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              Text('No trend data yet — log a few water tests.', style: AppTypography.bodyMedium),
            ],
          ),
        ),
      );
    }

    const params = <String>[
      'temp',
      'ph',
      'ammonia',
      'nitrite',
      'nitrate',
      'gh',
      'kh',
      'phosphate',
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Trends', style: AppTypography.headlineSmall),
                const Spacer(),
                Text('last ${tests.length.clamp(0, 50)} tests', style: AppTypography.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: params.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final p = params[index];
                  return _SparklineCard(
                    param: p,
                    tests: tests,
                    onTap: () => onOpenCharts(p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklineCard extends StatelessWidget {
  final String param;
  final List<LogEntry> tests;
  final VoidCallback onTap;

  const _SparklineCard({required this.param, required this.tests, required this.onTap});

  String _label() {
    switch (param) {
      case 'temp':
        return 'Temp';
      case 'ph':
        return 'pH';
      case 'ammonia':
        return 'NH₃';
      case 'nitrite':
        return 'NO₂';
      case 'nitrate':
        return 'NO₃';
      case 'gh':
        return 'GH';
      case 'kh':
        return 'KH';
      case 'phosphate':
        return 'PO₄';
      default:
        return param;
    }
  }

  Color _color() {
    switch (param) {
      case 'nitrate':
        return Colors.orange;
      case 'nitrite':
        return Colors.red;
      case 'ammonia':
        return Colors.purple;
      case 'ph':
        return AppColors.primary;
      case 'temp':
        return AppColors.secondary;
      case 'gh':
        return Colors.brown;
      case 'kh':
        return Colors.indigo;
      case 'phosphate':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  double? _value(WaterTestResults t) {
    switch (param) {
      case 'temp':
        return t.temperature;
      case 'ph':
        return t.ph;
      case 'ammonia':
        return t.ammonia;
      case 'nitrite':
        return t.nitrite;
      case 'nitrate':
        return t.nitrate;
      case 'gh':
        return t.gh;
      case 'kh':
        return t.kh;
      case 'phosphate':
        return t.phosphate;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = <double>[];
    for (final l in tests) {
      final v = _value(l.waterTest!);
      if (v != null) values.add(v);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceVariant.withOpacity(0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_label(), style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            Expanded(
              child: values.length < 2
                  ? Center(
                      child: Text('—', style: AppTypography.bodySmall),
                    )
                  : _MiniSparkline(values: values, color: _color()),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  final List<double> values;
  final Color color;

  const _MiniSparkline({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: color.withOpacity(0.10)),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}

enum _AlertSeverity {
  info,
  warning,
  danger,
}

class _AlertItem {
  final _AlertSeverity severity;
  final String title;
  final String? detail;

  const _AlertItem({required this.severity, required this.title, this.detail});
}

class _AlertsCard extends StatelessWidget {
  final Tank tank;
  final List<LogEntry> logs;

  const _AlertsCard({required this.tank, required this.logs});

  @override
  Widget build(BuildContext context) {
    final tests = logs
        .where((l) => l.type == LogType.waterTest && l.waterTest != null)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final latest = tests.firstOrNull;
    if (latest == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alerts', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              Text('No water tests yet — nothing to flag.', style: AppTypography.bodyMedium),
            ],
          ),
        ),
      );
    }

    final latestTest = latest.waterTest!;
    final alerts = <_AlertItem>[];

    // Recency
    final daysSince = DateTime.now().difference(latest.timestamp).inDays;
    if (daysSince >= 14) {
      alerts.add(
        _AlertItem(
          severity: _AlertSeverity.info,
          title: 'No water test in $daysSince days',
          detail: 'Consider logging a quick test to keep trends accurate.',
        ),
      );
    }

    // Targets (range)
    void rangeAlert({
      required String label,
      required double? value,
      required double? min,
      required double? max,
      String? unit,
    }) {
      if (value == null) return;
      if (min == null && max == null) return;

      final below = min != null && value < min;
      final above = max != null && value > max;
      if (!below && !above) return;

      final targetText = [
        if (min != null) 'min ${min.toStringAsFixed(1)}',
        if (max != null) 'max ${max.toStringAsFixed(1)}',
      ].join(' / ');

      alerts.add(
        _AlertItem(
          severity: _AlertSeverity.warning,
          title: '$label out of target range',
          detail: 'Latest: ${value.toStringAsFixed(2)}${unit != null ? ' $unit' : ''} (targets: $targetText)',
        ),
      );
    }

    rangeAlert(
      label: 'Temperature',
      value: latestTest.temperature,
      min: tank.targets.tempMin,
      max: tank.targets.tempMax,
      unit: '°C',
    );
    rangeAlert(
      label: 'pH',
      value: latestTest.ph,
      min: tank.targets.phMin,
      max: tank.targets.phMax,
    );
    rangeAlert(
      label: 'GH',
      value: latestTest.gh,
      min: tank.targets.ghMin,
      max: tank.targets.ghMax,
      unit: 'dGH',
    );
    rangeAlert(
      label: 'KH',
      value: latestTest.kh,
      min: tank.targets.khMin,
      max: tank.targets.khMax,
      unit: 'dKH',
    );

    // Threshold parameters
    void thresholdAlert({
      required String label,
      required double? value,
      required double warn,
      required double danger,
      required int decimals,
      String unit = 'ppm',
    }) {
      if (value == null) return;
      if (value >= danger) {
        alerts.add(
          _AlertItem(
            severity: _AlertSeverity.danger,
            title: '$label is high',
            detail: 'Latest: ${value.toStringAsFixed(decimals)} $unit',
          ),
        );
      } else if (value >= warn) {
        alerts.add(
          _AlertItem(
            severity: _AlertSeverity.warning,
            title: '$label is elevated',
            detail: 'Latest: ${value.toStringAsFixed(decimals)} $unit',
          ),
        );
      }
    }

    thresholdAlert(label: 'Ammonia (NH₃)', value: latestTest.ammonia, warn: 0.25, danger: 0.5, decimals: 2);
    thresholdAlert(label: 'Nitrite (NO₂)', value: latestTest.nitrite, warn: 0.25, danger: 0.5, decimals: 2);
    thresholdAlert(label: 'Nitrate (NO₃)', value: latestTest.nitrate, warn: 40, danger: 80, decimals: 0);
    thresholdAlert(label: 'Phosphate (PO₄)', value: latestTest.phosphate, warn: 1.0, danger: 2.0, decimals: 2);

    // Simple delta trend (nitrate)
    final recentNitrateTests = tests
        .where((l) => l.waterTest?.nitrate != null)
        .take(2)
        .toList();
    if (recentNitrateTests.length == 2) {
      final a = recentNitrateTests[0];
      final b = recentNitrateTests[1];
      final delta = (a.waterTest!.nitrate! - b.waterTest!.nitrate!);
      final gapDays = a.timestamp.difference(b.timestamp).inDays.abs();

      if (gapDays <= 7 && delta >= 10) {
        alerts.add(
          _AlertItem(
            severity: _AlertSeverity.warning,
            title: 'Nitrate jumped +${delta.toStringAsFixed(0)} ppm',
            detail: 'Since the previous test (${DateFormat('MMM d').format(b.timestamp)}).',
          ),
        );
      }
    }

    // If nothing, celebrate stability.
    if (alerts.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alerts', style: AppTypography.headlineSmall),
                    const SizedBox(height: 6),
                    Text('All looks stable based on your latest test.', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort so danger shows first.
    alerts.sort((x, y) => y.severity.index.compareTo(x.severity.index));

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Alerts', style: AppTypography.headlineSmall),
                const Spacer(),
                Text('${alerts.length}', style: AppTypography.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((a) => _AlertRow(item: a)),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final _AlertItem item;

  const _AlertRow({required this.item});

  Color _color() {
    switch (item.severity) {
      case _AlertSeverity.danger:
        return AppColors.paramDanger;
      case _AlertSeverity.warning:
        return AppColors.paramWarning;
      case _AlertSeverity.info:
        return AppColors.info;
    }
  }

  IconData _icon() {
    switch (item.severity) {
      case _AlertSeverity.danger:
        return Icons.error_outline;
      case _AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case _AlertSeverity.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon(), color: c),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTypography.labelLarge),
                  if (item.detail != null) ...[
                    const SizedBox(height: 4),
                    Text(item.detail!, style: AppTypography.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick-add FAB with expandable options
class _QuickAddFab extends StatefulWidget {
  final VoidCallback onWaterTest;
  final VoidCallback onWaterChange;
  final VoidCallback onObservation;
  final VoidCallback onFeeding;

  const _QuickAddFab({
    required this.onWaterTest,
    required this.onWaterChange,
    required this.onObservation,
    required this.onFeeding,
  });

  @override
  State<_QuickAddFab> createState() => _QuickAddFabState();
}

class _QuickAddFabState extends State<_QuickAddFab> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _handleAction(VoidCallback action) {
    _toggle();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Mini FABs
        ScaleTransition(
          scale: _expandAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniFabOption(
                icon: Icons.science,
                label: 'Water Test',
                color: AppColors.primary,
                onTap: () => _handleAction(widget.onWaterTest),
              ),
              const SizedBox(height: 8),
              _MiniFabOption(
                icon: Icons.water_drop,
                label: 'Water Change',
                color: AppColors.secondary,
                onTap: () => _handleAction(widget.onWaterChange),
              ),
              const SizedBox(height: 8),
              _MiniFabOption(
                icon: Icons.restaurant,
                label: 'Log Feeding',
                color: Colors.orange,
                onTap: () => _handleAction(widget.onFeeding),
              ),
              const SizedBox(height: 8),
              _MiniFabOption(
                icon: Icons.edit_note,
                label: 'Observation',
                color: Colors.purple,
                onTap: () => _handleAction(widget.onObservation),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _MiniFabOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniFabOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: label,
          backgroundColor: color,
          onPressed: onTap,
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }
}

class _StockingIndicator extends StatelessWidget {
  final StockingResult result;

  const _StockingIndicator({required this.result});

  Color _levelColor() {
    switch (result.level) {
      case StockingLevel.understocked:
        return AppColors.info;
      case StockingLevel.good:
        return AppColors.success;
      case StockingLevel.moderate:
        return AppColors.paramWarning;
      case StockingLevel.heavy:
        return AppColors.warning;
      case StockingLevel.overstocked:
        return AppColors.error;
    }
  }

  String _levelLabel() {
    switch (result.level) {
      case StockingLevel.understocked:
        return 'Understocked';
      case StockingLevel.good:
        return 'Good';
      case StockingLevel.moderate:
        return 'Moderate';
      case StockingLevel.heavy:
        return 'Heavy';
      case StockingLevel.overstocked:
        return 'Overstocked';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _levelColor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    'Stocking: ${_levelLabel()}',
                    style: AppTypography.labelLarge.copyWith(color: color),
                  ),
                  const Spacer(),
                  Text(
                    '${result.percentFull.toStringAsFixed(0)}%',
                    style: AppTypography.bodySmall.copyWith(color: color),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (result.percentFull / 100).clamp(0, 1),
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(result.summary, style: AppTypography.bodySmall),
              if (result.warnings.isNotEmpty) ...[
                const SizedBox(height: 6),
                ...result.warnings.map((w) => Row(
                  children: [
                    Icon(Icons.warning_amber, size: 12, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        w,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
