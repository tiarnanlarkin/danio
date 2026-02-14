import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../widgets/core/app_card.dart';
import '../../widgets/core/bubble_loader.dart';
import '../../providers/storage_provider.dart';
import '../../providers/tank_provider.dart';
import '../../services/stocking_calculator.dart';
import '../../theme/app_theme.dart';
import '../../utils/skeleton_placeholders.dart';
import '../add_log_screen.dart';
import '../livestock_screen.dart';
import '../equipment_screen.dart';
import '../tasks_screen.dart';
import '../charts_screen.dart';
import '../logs_screen.dart';
import '../log_detail_screen.dart';
import '../tank_settings_screen.dart';
import '../tank_comparison_screen.dart';
import '../cost_tracker_screen.dart';
import '../journal_screen.dart';
import '../maintenance_checklist_screen.dart';
import '../photo_gallery_screen.dart';
import '../livestock_value_screen.dart';
import '../../widgets/cycling_status_card.dart';
import '../../utils/app_feedback.dart';

import 'widgets/section_header.dart';
import 'widgets/quick_stats.dart';
import 'widgets/action_button.dart';
import 'widgets/task_preview.dart';
import 'widgets/logs_list.dart';
import 'widgets/livestock_preview.dart';
import 'widgets/equipment_preview.dart';
import 'widgets/dashboard_loading_card.dart';
import 'widgets/snapshot_card.dart';
import 'widgets/trends_section.dart';
import 'widgets/alerts_card.dart';
import 'widgets/quick_add_fab.dart';
import 'widgets/stocking_indicator.dart';

const _uuid = Uuid();

class TankDetailScreen extends ConsumerWidget {
  final String tankId;

  const TankDetailScreen({super.key, required this.tankId});

  // Skeleton loading builders
  static Widget _buildTaskSkeletonPreview() {
    return Skeletonizer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppCard(
          padding: AppCardPadding.none,
          child: Column(
            children: List.generate(
              3,
              (_) => const ListTile(
                leading: Icon(Icons.schedule, color: AppColors.textHint),
                title: Text('Task loading placeholder'),
                subtitle: Text('Due in some days'),
                trailing: Icon(Icons.check_circle_outline, color: AppColors.success),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildLogsSkeletonList() {
    final placeholders = SkeletonPlaceholders.logsList;
    return Skeletonizer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppCard(
          padding: AppCardPadding.none,
          child: Column(
            children: placeholders.take(5).map((log) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppOverlays.primary20,
                  child: const Icon(Icons.science, color: AppColors.primary, size: 20),
                ),
                title: Text(log.title ?? 'Activity placeholder'),
                subtitle: Text(DateFormat('MMM d, h:mm a').format(log.timestamp)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  static Widget _buildLivestockSkeletonPreview() {
    return Skeletonizer(
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              width: 120,
              margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.set_meal, color: AppColors.primary),
                      const Spacer(),
                      Text('Neon Tetra', style: AppTypography.labelLarge),
                      Text('×10', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _buildEquipmentSkeletonPreview() {
    return Skeletonizer(
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              width: 120,
              margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.filter_alt, color: AppColors.primary),
                      const Spacer(),
                      Text('Fluval 307', style: AppTypography.labelLarge),
                      Text('Filter', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Future<void> _completeTask(
    BuildContext context,
    WidgetRef ref,
    Task task,
    String tankId,
  ) async {
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

    ref.invalidate(tasksProvider(tankId));
    ref.invalidate(equipmentProvider(tankId));
    ref.invalidate(logsProvider(tankId));
    ref.invalidate(allLogsProvider(tankId));

    // Show success feedback
    if (context.mounted) {
      AppFeedback.showSuccess(context, '${task.title} completed!');
    }
  }

  void _deleteTank(BuildContext context, WidgetRef ref, Tank tank) {
    final actions = ref.read(tankActionsProvider);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Soft delete the tank (marks for deletion, starts 5s timer)
    actions.softDeleteTank(
      tankId,
      onUndoExpired: () {
        // Called after 5 seconds if user doesn't undo
        // Tank is already permanently deleted by the timer
      },
    );

    // Pop back to home screen immediately
    navigator.pop();

    // Show SnackBar with undo action (5 seconds)
    messenger.showSnackBar(
      SnackBar(
        content: Text('${tank.name} deleted'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Restore the tank
            actions.undoDeleteTank(tankId);
            AppFeedback.showSuccess(context, '${tank.name} restored');
          },
        ),
      ),
    );
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
      loading: () =>
          const Scaffold(body: Center(child: BubbleLoader.large(message: 'Loading tank...'))),
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
                  background: Hero(
                    tag: 'tank-card-${tank.id}',
                    child: Container(
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
                              color: AppOverlays.white10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.checklist, color: Colors.white),
                    tooltip: 'Checklist',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MaintenanceChecklistScreen(
                          tankId: tankId,
                          tankName: tank.name,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                    ),
                    tooltip: 'Gallery',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoGalleryScreen(
                          tankId: tankId,
                          tankName: tank.name,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.book_outlined, color: Colors.white),
                    tooltip: 'Journal',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JournalScreen(tankId: tankId),
                      ),
                    ),
                  ),
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
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      switch (value) {
                        case 'settings':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TankSettingsScreen(tankId: tankId),
                            ),
                          );
                        case 'compare':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TankComparisonScreen(),
                            ),
                          );
                        case 'costs':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CostTrackerScreen(),
                            ),
                          );
                        case 'value':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LivestockValueScreen(
                                tankId: tankId,
                                tankName: tank.name,
                              ),
                            ),
                          );
                        case 'delete':
                          _deleteTank(context, ref, tank);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'compare',
                        child: ListTile(
                          leading: Icon(Icons.compare_arrows),
                          title: Text('Compare Tanks'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'costs',
                        child: ListTile(
                          leading: Icon(Icons.receipt_long),
                          title: Text('Cost Tracker'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'value',
                        child: ListTile(
                          leading: Icon(Icons.attach_money),
                          title: Text('Estimate Value'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'settings',
                        child: ListTile(
                          leading: Icon(Icons.settings),
                          title: Text('Tank Settings'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          title: Text(
                            'Delete Tank',
                            style: TextStyle(color: AppColors.error),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Quick stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: QuickStats(tank: tank, logsAsync: logsAllAsync),
                ),
              ),

              // Action buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          icon: Icons.science_outlined,
                          label: 'Log Test',
                          color: AppColors.primary,
                          onTap: () =>
                              _navigateToAddLog(context, LogType.waterTest),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionButton(
                          icon: Icons.water_drop_outlined,
                          label: 'Water Change',
                          color: const Color(0xFF1E88E5), // Water blue
                          onTap: () =>
                              _navigateToAddLog(context, LogType.waterChange),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionButton(
                          icon: Icons.note_add_outlined,
                          label: 'Add Note',
                          color: AppColors.accent,
                          onTap: () =>
                              _navigateToAddLog(context, LogType.observation),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // Dashboard: latest snapshot
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: logsAllAsync.when(
                    loading: () => const DashboardLoadingCard(
                      title: 'Latest Water Snapshot',
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (logs) => LatestSnapshotCard(tank: tank, logs: logs),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Dashboard: trends
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: logsAllAsync.when(
                    loading: () => const DashboardLoadingCard(title: 'Trends'),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (logs) => TrendsRow(
                      tank: tank,
                      logs: logs,
                      onOpenCharts: (param) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChartsScreen(tankId: tankId, initialParam: param),
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
                    loading: () => const DashboardLoadingCard(title: 'Alerts'),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (logs) => AlertsCard(tank: tank, logs: logs),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

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
                child: SectionHeader(
                  title: 'Tasks',
                  trailing: tasksAsync.when(
                    loading: () => null,
                    error: (_, __) => null,
                    data: (tasks) {
                      final pending = tasks
                          .where(
                            (t) => t.isEnabled && (t.isOverdue || t.isDueToday),
                          )
                          .length;
                      if (pending == 0) return null;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: AppRadius.mediumRadius,
                        ),
                        child: Text(
                          '$pending',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TasksScreen(tankId: tankId),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: tasksAsync.when(
                  loading: () => _buildTaskSkeletonPreview(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (tasks) => TaskPreview(
                    tasks: tasks.take(3).toList(),
                    onComplete: (t) => _completeTask(context, ref, t, tankId),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // Recent logs
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Recent Activity',
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LogsScreen(tankId: tankId),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: logsRecentAsync.when(
                  loading: () => _buildLogsSkeletonList(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (logs) => LogsList(
                    logs: logs.take(5).toList(),
                    onTap: (log) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LogDetailScreen(tankId: tankId, logId: log.id),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // Livestock
              SliverToBoxAdapter(
                child: SectionHeader(
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
                    MaterialPageRoute(
                      builder: (_) => LivestockScreen(tankId: tankId),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: livestockAsync.when(
                  loading: () => _buildLivestockSkeletonPreview(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (livestock) => LivestockPreview(livestock: livestock),
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
                    return StockingIndicator(result: result);
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // Equipment
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Equipment',
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EquipmentScreen(tankId: tankId),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: equipmentAsync.when(
                  loading: () => _buildEquipmentSkeletonPreview(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (equipment) => EquipmentPreview(equipment: equipment),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          floatingActionButton: QuickAddFab(
            tankId: tankId,
            onWaterTest: () => _navigateToAddLog(context, LogType.waterTest),
            onWaterChange: () =>
                _navigateToAddLog(context, LogType.waterChange),
            onObservation: () =>
                _navigateToAddLog(context, LogType.observation),
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
      AppFeedback.showSuccess(context, 'Feeding logged! 🐟');
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
