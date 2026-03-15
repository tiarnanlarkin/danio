import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../create_tank_screen.dart';
import '../../widgets/core/app_card.dart';
import '../../widgets/core/bubble_loader.dart';
import '../../widgets/core/app_states.dart';
import '../../providers/storage_provider.dart';
import '../../providers/tank_provider.dart';
import '../../services/stocking_calculator.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
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
import '../../widgets/danio_daily_card.dart';
import '../cycling_assistant_screen.dart';
import '../../utils/app_feedback.dart';
import '../../utils/haptic_feedback.dart';

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
import 'widgets/tank_health_card.dart';
import '../../widgets/water_trend_arrows.dart';
import 'widgets/quick_add_fab.dart';
import 'widgets/stocking_indicator.dart';
import '../../utils/navigation_throttle.dart';

const _uuid = Uuid();

/// Tank detail screen displaying comprehensive tank information and management tools.
///
/// Displays a dashboard with tank overview, parameters, livestock, equipment,
/// tasks, logs, and various management tools. Provides quick actions via FAB
/// menu for adding logs, livestock, equipment, and tasks.
///
/// Navigation:
/// - From: Home screen tank card, tank list
/// - To: Logs, livestock, equipment, charts, settings, and various detail screens
///
/// Features:
/// - Real-time parameter display and trends
/// - Livestock and equipment previews
/// - Upcoming tasks and maintenance reminders
/// - Recent logs and quick add actions
/// - Tank analytics and charts
/// - Cycling status tracking
/// - Cost tracking and journal access
class TankDetailScreen extends ConsumerWidget {
  /// Unique identifier for the tank to display.
  final String tankId;

  /// Creates a tank detail screen.
  ///
  /// The [tankId] parameter is required and must reference a valid tank.
  const TankDetailScreen({super.key, required this.tankId});

  // Skeleton loading builders
  static Widget _buildTaskSkeletonPreview() {
    return Skeletonizer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AppCard(
          padding: AppCardPadding.none,
          child: Column(
            children: List.generate(
              3,
              (_) => ListTile(
                leading: Icon(Icons.schedule, color: AppColors.textHint),
                title: Text('Loading task...'),
                subtitle: Text('Due soon'),
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AppCard(
          padding: AppCardPadding.none,
          child: Column(
            children: placeholders.take(5).map((log) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppOverlays.primary20,
                  child: const Icon(Icons.science, color: AppColors.primary, size: AppIconSizes.sm),
                ),
                title: Text(log.title ?? 'Loading activity...'),
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              width: 120,
              margin: EdgeInsets.only(right: index < 3 ? AppSpacing.sm2 : 0),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm2),
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              width: 120,
              margin: EdgeInsets.only(right: index < 3 ? AppSpacing.sm2 : 0),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm2),
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
      AppHaptics.success();
      AppFeedback.showSuccess(context, '${task.title} completed!');
    }
  }

  Future<void> _deleteTank(BuildContext context, WidgetRef ref, Tank tank) async {
    // P0-4 FIX: Show confirmation dialog before soft-deleting
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tank?'),
        content: Text(
          'Delete ${tank.name}? This action can be undone for 5 seconds.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Tank'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete Tank',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

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

    // Show SnackBar with undo action (5 seconds).
    // Use the pre-captured `messenger` — `context` belongs to the
    // TankDetailScreen route that has already been popped and is deactivated.
    // Calling AppFeedback.showSuccess(context, ...) after pop() would throw
    // "Looking up a deactivated widget's ancestor is unsafe".
    messenger.showSnackBar(
      SnackBar(
        content: Text('${tank.name} deleted'),
        duration: kSnackbarDuration,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Restore the tank
            actions.undoDeleteTank(tankId);
            // Use the ancestor messenger directly — the detail route is gone.
            AppHaptics.success();
            messenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: AppSpacing.sm2),
                    Expanded(
                      child: Text(
                        '${tank.name} restored',
                        style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
                margin: const EdgeInsets.all(AppSpacing.md),
              ),
            );
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
        appBar: AppBar(title: const Text('Tank')),
        body: Center(
          child: AppErrorState(
            title: 'Couldn\'t load this tank',
            message: 'Please try again.',
            onRetry: () => ref.invalidate(tankProvider(tankId)),
          ),
        ),
      ),
      data: (tank) {
        if (tank == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tank')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop_outlined, size: 64, color: context.textHint),
                  const SizedBox(height: AppSpacing.md),
                  Text('Tank not found', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This tank may have been deleted.',
                    style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tankProvider(tankId));
              ref.invalidate(logsProvider(tankId));
              ref.invalidate(allLogsProvider(tankId));
              ref.invalidate(livestockProvider(tankId));
              ref.invalidate(equipmentProvider(tankId));
              ref.invalidate(tasksProvider(tankId));
            },
            child: CustomScrollView(
              slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    tank.name,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    onPressed: () => NavigationThrottle.push(context, MaintenanceChecklistScreen(
                          tankId: tankId,
                          tankName: tank.name,
                        )),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                    ),
                    tooltip: 'Gallery',
                    onPressed: () => NavigationThrottle.push(context, PhotoGalleryScreen(
                          tankId: tankId,
                          tankName: tank.name,
                        )),
                  ),
                  IconButton(
                    icon: const Icon(Icons.book_outlined, color: Colors.white),
                    tooltip: 'Journal',
                    onPressed: () => NavigationThrottle.push(context, JournalScreen(tankId: tankId)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.show_chart, color: Colors.white),
                    tooltip: 'Charts',
                    onPressed: () => NavigationThrottle.push(context, ChartsScreen(tankId: tankId)),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      switch (value) {
                        case 'settings':
                          NavigationThrottle.push(context, TankSettingsScreen(tankId: tankId));
                        case 'compare':
                          NavigationThrottle.push(context, const TankComparisonScreen());
                        case 'costs':
                          NavigationThrottle.push(context, const CostTrackerScreen());
                        case 'value':
                          NavigationThrottle.push(context, LivestockValueScreen(
                                tankId: tankId,
                                tankName: tank.name,
                              ));
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

              // Demo tank banner
              if (tank.isDemoTank)
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () => NavigationThrottle.push(context, const CreateTankScreen()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm2),
                      color: DanioColors.amberText.withValues(alpha: 0.15),
                      child: Row(
                        children: [
                          const Text('🐠', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Demo Tank — Tap here to create your own',
                              style: AppTypography.labelMedium.copyWith(
                                color: DanioColors.amberText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: DanioColors.amberText),
                        ],
                      ),
                    ),
                  ),
                ),

              // Quick stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: QuickStats(tank: tank, logsAsync: logsAllAsync, livestockAsync: livestockAsync, equipmentAsync: equipmentAsync),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
              ),

              // Tank Health Score
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: logsAllAsync.when(
                    loading: () => const DashboardLoadingCard(title: 'Health'),
                    error: (e, _) => Center(
                      child: Text(
                        'Something went wrong',
                        style: AppTypography.bodyMedium.copyWith(color: context.textHint),
                      ),
                    ),
                    data: (logs) => TankHealthCard(tank: tank, logs: logs),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
              // Action buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                      const SizedBox(width: AppSpacing.sm2),
                      Expanded(
                        child: ActionButton(
                          icon: Icons.water_drop_outlined,
                          label: 'Water Change',
                          color: AppColors.accent, // Teal water
                          onTap: () =>
                              _navigateToAddLog(context, LogType.waterChange),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm2),
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
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.15, end: 0, duration: 300.ms, delay: 100.ms),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // Dashboard: latest snapshot
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: logsAllAsync.when(
                    loading: () => const DashboardLoadingCard(
                      title: 'Latest Water Snapshot',
                    ),
                    error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
                    data: (logs) => LatestSnapshotCard(tank: tank, logs: logs),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm2)),

              // Dashboard: trends
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: logsAllAsync.when(
                    loading: () => const DashboardLoadingCard(title: 'Trends'),
                    error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
                    data: (logs) => TrendsRow(
                      tank: tank,
                      logs: logs,
                      onOpenCharts: (param) => NavigationThrottle.push(context, ChartsScreen(tankId: tankId, initialParam: param)),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm2)),

              // Dashboard: alerts
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: logsAllAsync.when(
                    loading: () => const DashboardLoadingCard(title: 'Alerts'),
                    error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
                    data: (logs) => AlertsCard(tank: tank, logs: logs),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              // Cycling status (for tanks < 90 days old)
              SliverToBoxAdapter(
                child: logsAllAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
                  data: (logs) => Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                    child: GestureDetector(
                      onTap: () => NavigationThrottle.push(context, CyclingAssistantScreen(tankId: tank.id)),
                      child: CyclingStatusCard(tank: tank, logs: logs),
                    ),
                  ),
                ),
              ),

              // Danio Daily briefing
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  child: const DanioDailyCard(),
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
                  onViewAll: () => NavigationThrottle.push(context, TasksScreen(tankId: tankId)),
                ),
              ),

              SliverToBoxAdapter(
                child: tasksAsync.when(
                  loading: () => _buildTaskSkeletonPreview(),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
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
                  onViewAll: () => NavigationThrottle.push(context, LogsScreen(tankId: tankId)),
                ),
              ),

              SliverToBoxAdapter(
                child: logsRecentAsync.when(
                  loading: () => _buildLogsSkeletonList(),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
                  data: (logs) => LogsList(
                    logs: logs.take(5).toList(),
                    onTap: (log) => NavigationThrottle.push(context, LogDetailScreen(tankId: tankId, logId: log.id)),
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
                  onViewAll: () => NavigationThrottle.push(context, LivestockScreen(tankId: tankId)),
                ),
              ),

              SliverToBoxAdapter(
                child: livestockAsync.when(
                  loading: () => _buildLivestockSkeletonPreview(),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
                  data: (livestock) => LivestockPreview(livestock: livestock),
                ),
              ),

              // Stocking level indicator
              SliverToBoxAdapter(
                child: livestockAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
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
                  onViewAll: () => NavigationThrottle.push(context, EquipmentScreen(tankId: tankId)),
                ),
              ),

              SliverToBoxAdapter(
                child: equipmentAsync.when(
                  loading: () => _buildEquipmentSkeletonPreview(),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
                  data: (equipment) => EquipmentPreview(equipment: equipment),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: kScrollEndPadding)),
              ],
            ),
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
      AppHaptics.success();
      AppFeedback.showSuccess(context, 'Feeding logged! 🐟');
    }
  }

  void _navigateToAddLog(BuildContext context, LogType type) {
    NavigationThrottle.push(context, AddLogScreen(tankId: tankId, initialType: type));
  }
}
