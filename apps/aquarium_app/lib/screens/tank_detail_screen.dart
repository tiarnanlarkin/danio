import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import 'add_log_screen.dart';
import 'livestock_screen.dart';
import 'equipment_screen.dart';
import 'tasks_screen.dart';

class TankDetailScreen extends ConsumerWidget {
  final String tankId;

  const TankDetailScreen({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tankAsync = ref.watch(tankProvider(tankId));
    final logsAsync = ref.watch(logsProvider(tankId));
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
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      // TODO: Tank settings
                    },
                  ),
                ],
              ),

              // Quick stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _QuickStats(tank: tank, logsAsync: logsAsync),
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

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

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
                  data: (tasks) => _TaskPreview(tasks: tasks.take(3).toList()),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Recent logs
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Recent Activity',
                  onViewAll: () {
                    // TODO: Full logs screen
                  },
                ),
              ),
              
              SliverToBoxAdapter(
                child: logsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (logs) => _LogsList(logs: logs.take(5).toList()),
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
        );
      },
    );
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

  const _TaskPreview({required this.tasks});

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
          children: tasks.map((task) => _TaskTile(task: task)).toList(),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;

  const _TaskTile({required this.task});

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
        color: AppColors.success,
        onPressed: () {
          // TODO: Complete task
        },
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

  const _LogsList({required this.logs});

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
          children: logs.map((log) => _LogTile(log: log)).toList(),
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final LogEntry log;

  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getLogColor(log.type).withOpacity(0.2),
        child: Icon(_getLogIcon(log.type), color: _getLogColor(log.type), size: 20),
      ),
      title: Text(_getLogTitle(log)),
      subtitle: Text(DateFormat('MMM d, h:mm a').format(log.timestamp)),
      onTap: () {
        // TODO: Log detail
      },
    );
  }

  IconData _getLogIcon(LogType type) {
    switch (type) {
      case LogType.waterTest: return Icons.science;
      case LogType.waterChange: return Icons.water_drop;
      case LogType.feeding: return Icons.restaurant;
      case LogType.medication: return Icons.medication;
      case LogType.observation: return Icons.visibility;
      case LogType.livestockAdded: return Icons.add_circle;
      case LogType.livestockRemoved: return Icons.remove_circle;
      case LogType.equipmentMaintenance: return Icons.build;
      case LogType.other: return Icons.note;
    }
  }

  Color _getLogColor(LogType type) {
    switch (type) {
      case LogType.waterTest: return AppColors.primary;
      case LogType.waterChange: return AppColors.secondary;
      case LogType.feeding: return Colors.orange;
      case LogType.medication: return Colors.red;
      case LogType.observation: return Colors.purple;
      case LogType.livestockAdded: return AppColors.success;
      case LogType.livestockRemoved: return AppColors.error;
      case LogType.equipmentMaintenance: return Colors.brown;
      case LogType.other: return AppColors.textHint;
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
