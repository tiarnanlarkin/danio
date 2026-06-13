import 'dart:async' show Completer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/tank_provider.dart';
import '../../providers/room_theme_provider.dart';
import '../../providers/guidance_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/guidance_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_states.dart';
import '../../widgets/hearts_widgets.dart';
import '../../widgets/gamification_dashboard.dart';
import '../../widgets/stage/stage_provider.dart';
import '../../widgets/stage/stage_scrim.dart';
import '../../widgets/stage/swiss_army_panel.dart';
import '../../widgets/stage/bottom_sheet_panel.dart';
import '../../widgets/stage/temp_panel_content.dart';
import '../../widgets/stage/water_panel_content.dart';
import '../../widgets/stage/lighting_pulse.dart';
import '../../widgets/danio_bottom_dock.dart';
import '../../navigation/app_routes.dart';
import '../../utils/app_page_routes.dart';
import '../../utils/navigation_throttle.dart';
import '../../widgets/room_scene.dart';
import '../../widgets/first_visit_tooltip.dart';
import '../onboarding/returning_user_flows.dart';
import '../create_tank_screen.dart';
import '../create_tank_screen/setup_mode.dart';
import '../add_log_screen.dart';
import '../journal_screen.dart';
import '../tank_settings_screen.dart';
import '../backup_restore_screen.dart';
import 'home_sheets.dart';
import 'widgets/tank_switcher.dart';
import 'widgets/selection_mode_panel.dart';
import 'widgets/empty_room_scene.dart';
import 'widgets/today_board.dart';
import 'widgets/room_control_fab.dart';
import 'widgets/skeleton_room.dart';
import 'widgets/tank_list_tile.dart';
import '../../widgets/danio_snack_bar.dart';
import '../../widgets/core/app_dialog.dart';
import '../../utils/logger.dart';
import '../compatibility_checker_screen.dart';

/// HomeScreen - The Living Room in the House Navigator.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Vertical offset (in dp) added to `MediaQuery.padding.top` to anchor
  /// the demo tank banner into the slot between the top bar and the tank scene.
  static const double _notificationSlotTopOffset = 100;

  int _currentTankIndex = 0;
  bool _isSelectMode = false;
  bool _isNavigatingToCreate = false;
  bool _demoModeDismissed = false;
  bool _showStageHandleTooltip = false;
  final Set<String> _selectedTankIds = {};

  @override
  void initState() {
    super.initState();
    _checkReturningUserFlow();
    _checkGuidancePrompt();
  }

  // ── Lifecycle checks ──────────────────────────────────────────────────

  Future<void> _checkGuidancePrompt() async {
    final service = await ref.read(guidanceServiceProvider.future);
    final hasOpenPanels = ref.read(stageProvider).openPanels.isNotEmpty;
    final decision = await service.shouldShow(
      GuidancePromptId.tankStageHandles,
      GuidanceContext(
        surface: GuidanceSurface.tank,
        hasOpenPanels: hasOpenPanels,
      ),
    );
    if (mounted) setState(() => _showStageHandleTooltip = decision.shouldShow);
  }

  /// Waits for the user profile to load from the provider.
  ///
  /// Listens for [userProfileProvider] to transition from loading to
  /// data/error. Falls back gracefully if loading times out after 5 seconds.
  Future<UserProfile?> _waitForProfile() async {
    // Fast path: already loaded synchronously.
    final current = ref.read(userProfileProvider);
    if (!current.isLoading) return current.valueOrNull;

    // Listen for the provider to finish loading instead of polling.
    final completer = Completer<UserProfile?>();
    final sub = ref.listenManual(userProfileProvider, (_, next) {
      if (!next.isLoading && !completer.isCompleted) {
        completer.complete(next.valueOrNull);
      }
    });

    try {
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => ref.read(userProfileProvider).valueOrNull,
      );
    } finally {
      sub.close();
    }
  }

  Future<void> _checkReturningUserFlow() async {
    if (!mounted) return;
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final profile = await _waitForProfile();
      if (profile == null) return;

      final createdAt = profile.createdAt;
      final currentStreak = profile.currentStreak;
      final daysSinceSignup = DateTime.now().difference(createdAt).inDays;
      final fishName = profile.firstFishSpeciesId;

      Widget? milestoneCard;
      String? prefsKey;

      if (daysSinceSignup >= 1 &&
          daysSinceSignup <= 2 &&
          currentStreak >= 1 &&
          (prefs.getBool('seen_day2_prompt') ?? false) == false) {
        milestoneCard = Day2StreakPrompt(
          fishName: fishName,
          onContinue: () => Navigator.of(context).pop(),
          onDismiss: () => Navigator.of(context).pop(),
        );
        prefsKey = 'seen_day2_prompt';
      } else if (daysSinceSignup >= 7 &&
          daysSinceSignup <= 8 &&
          currentStreak >= 5 &&
          (prefs.getBool('seen_day7_milestone') ?? false) == false) {
        // FB-B3 fix: pop the dialog first, then navigate to Compatibility Checker
        milestoneCard = Day7MilestoneCard(
          onFeatureTap: () {
            Navigator.of(context).pop();
            NavigationThrottle.push(
              context,
              const CompatibilityCheckerScreen(),
              rootNavigator: true,
            );
          },
        );
        prefsKey = 'seen_day7_milestone';
      } else if (daysSinceSignup >= 30 &&
          daysSinceSignup <= 31 &&
          currentStreak >= 1 &&
          (prefs.getBool('seen_day30_committed') ?? false) == false) {
        final totalXp = profile.totalXp;
        final lessonsCompleted = profile.completedLessons.length;
        milestoneCard = Day30CommittedCard(
          lessonsCompleted: lessonsCompleted,
          xpEarned: totalXp,
          // Complete-local build uses this as a celebration-only card.
          onExplore: null,
        );
        prefsKey = 'seen_day30_committed';
      }

      if (milestoneCard != null && mounted) {
        await showAppDialog<void>(
          context: context,
          barrierDismissible: true,
          child: milestoneCard,
        );
        if (prefsKey != null) await prefs.setBool(prefsKey, true);
      }
    } catch (e, st) {
      logError(
        'HomeScreen: returning user flow check failed: $e',
        stackTrace: st,
        tag: 'HomeScreen',
      );
    }
  }

  // ── Selection mode ────────────────────────────────────────────────────

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) _selectedTankIds.clear();
    });
  }

  void _toggleTankSelection(String tankId) {
    setState(() {
      if (_selectedTankIds.contains(tankId)) {
        _selectedTankIds.remove(tankId);
      } else {
        _selectedTankIds.add(tankId);
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  bool _isNewUser(WidgetRef ref) {
    return !ref.watch(
      userProfileProvider.select((p) => p.value?.hasSeenTutorial ?? false),
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────

  void _navigateToCreateTank(
    BuildContext context, {
    SetupMode mode = SetupMode.guided,
  }) {
    if (!mounted || _isNavigatingToCreate) return;
    setState(() => _isNavigatingToCreate = true);
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => CreateTankScreen(mode: mode)))
        .whenComplete(() async {
          if (mounted) {
            setState(() => _isNavigatingToCreate = false);
            final tanksBefore = ref.read(tanksProvider).valueOrNull ?? [];
            ref.invalidate(tanksProvider);
            final tanksAfter = await ref
                .read(tanksProvider.future)
                .timeout(const Duration(seconds: 3), onTimeout: () => []);
            if (mounted && tanksAfter.length > tanksBefore.length) {
              final beforeIds = tanksBefore.map((t) => t.id).toSet();
              final newIndex = tanksAfter.indexWhere(
                (t) => !beforeIds.contains(t.id),
              );
              if (newIndex >= 0) setState(() => _currentTankIndex = newIndex);
            }
          }
        });
  }

  void _navigateToTankDetail(BuildContext context, Tank tank) {
    AppRoutes.toTankDetail(context, tank.id);
  }

  void _navigateToWaterChange(BuildContext context, Tank tank) {
    Navigator.of(context, rootNavigator: true).push(
      ModalScaleRoute(
        page: AddLogScreen(tankId: tank.id, initialType: LogType.waterChange),
      ),
    );
  }

  Future<void> _bulkDelete(BuildContext context, List<Tank> allTanks) async {
    if (_selectedTankIds.isEmpty) {
      if (mounted) {
        DanioSnackBar.warning(context, 'Pick some tanks first!');
      }
      return;
    }
    final selectedTanks = allTanks
        .where((t) => _selectedTankIds.contains(t.id))
        .toList();
    final tankNames = selectedTanks.map((t) => t.name).join(', ');
    final confirmed = await showAppDestructiveDialog(
      context: context,
      title:
          'Delete ${_selectedTankIds.length} tank${_selectedTankIds.length > 1 ? 's' : ''}?',
      message:
          'Tanks to delete:\n\n$tankNames\n\nThis will remove all livestock, equipment, logs, and tasks for these tanks.',
      destructiveLabel:
          'Delete ${_selectedTankIds.length > 1 ? 'Tanks' : 'Tank'}',
      cancelLabel: 'Keep',
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(tankActionsProvider)
          .bulkDeleteTanks(_selectedTankIds.toList());
      if (context.mounted) {
        setState(() {
          _isSelectMode = false;
          _selectedTankIds.clear();
          _currentTankIndex = 0;
        });
        DanioSnackBar.success(
          context,
          '${selectedTanks.length} tank${selectedTanks.length > 1 ? 's' : ''} deleted',
        );
      }
    } catch (e, st) {
      logError(
        'HomeScreen: bulk delete tanks failed: $e',
        stackTrace: st,
        tag: 'HomeScreen',
      );
      if (context.mounted) {
        DanioSnackBar.error(
          context,
          'Couldn\'t delete those tanks, try again in a moment',
        );
      }
    }
  }

  Future<void> _bulkExport(BuildContext context, List<Tank> allTanks) async {
    if (_selectedTankIds.isEmpty) {
      if (mounted) DanioSnackBar.warning(context, 'Pick some tanks first!');
      return;
    }
    if (mounted) {
      setState(() => _selectedTankIds.clear());
      NavigationThrottle.push(
        context,
        const BackupRestoreScreen(),
        rootNavigator: true,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  Widget _buildLivingRoomScreen() {
    final theme = ref.watch(currentRoomThemeProvider);
    final tanksAsync = ref.watch(tanksProvider);
    if (!mounted) return const SkeletonRoom();
    if (tanksAsync.isLoading && !tanksAsync.hasValue) {
      return const SkeletonRoom();
    }
    if (tanksAsync.hasError && !tanksAsync.hasValue) {
      return AppErrorState(
        title: 'Couldn\'t load your tanks',
        message: 'Check your connection and give it another go!',
        onRetry: () => ref.invalidate(tanksProvider),
      );
    }

    final tanksData = tanksAsync.valueOrNull ?? [];
    return Builder(
      builder: (context) {
        final tanks = tanksData;
        if (!mounted) return const SkeletonRoom();

        if (tanks.isEmpty) {
          return EmptyRoomScene(
            onCreateTank: (mode) => _navigateToCreateTank(context, mode: mode),
            onLoadDemo: () async {
              final actions = ref.read(tankActionsProvider);
              final demoTank = await actions.seedDemoTankIfEmpty();
              if (!mounted) return;
              ref.invalidate(tanksProvider);
              try {
                await ref
                    .read(tanksProvider.future)
                    .timeout(
                      const Duration(seconds: 3),
                      onTimeout: () => [demoTank],
                    );
              } catch (e, st) {
                logError(
                  'HomeScreen: demo tank refresh after delete failed: $e',
                  stackTrace: st,
                  tag: 'HomeScreen',
                );
              }
              if (context.mounted) _navigateToTankDetail(context, demoTank);
            },
          );
        }

        final currentTank = tanks[_currentTankIndex % tanks.length];
        final currentLogs =
            ref.watch(logsProvider(currentTank.id)).valueOrNull ?? [];
        return Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: LightingPulseWrapper(
                  child: LivingRoomScene(
                    tankId: currentTank.id,
                    tankName: currentTank.name,
                    tankVolume: currentTank.volumeLitres,
                    theme: theme,
                    isNewUser: _isNewUser(ref),
                    onTankTap: () =>
                        _navigateToTankDetail(context, currentTank),
                    onTestKitTap: () =>
                        showWaterParams(context, currentLogs, currentTank.id),
                    onFoodTap: () =>
                        showFeedingInfo(context, currentLogs, currentTank.id),
                    onPlantTap: () => showPlantInfo(context),
                    onStatsTap: () =>
                        showStatsInfo(context, currentLogs, currentTank.id),
                    onThemeTap: () => showThemePicker(context, ref),
                    onJournalTap: () => NavigationThrottle.push(
                      context,
                      JournalScreen(tankId: currentTank.id),
                      route: RoomSlideRoute(
                        page: JournalScreen(tankId: currentTank.id),
                      ),
                    ),
                    onCalendarTap: () => showStreakCalendar(context),
                  ),
                ),
              ),
            ),

            // Stage system
            Positioned.fill(
              child: Consumer(
                builder: (context, ref, _) {
                  final hasOpen = ref.watch(
                    stageProvider.select((s) => s.openPanels.isNotEmpty),
                  );
                  return IgnorePointer(
                    ignoring: !hasOpen,
                    child: const StageScrim(),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Consumer(
                builder: (context, ref, _) {
                  final roomTheme = ref.watch(currentRoomThemeProvider);
                  return Stack(
                    children: [
                      SwissArmyPanel.left(
                        theme: roomTheme,
                        child: TempPanelContent(
                          tankId: currentTank.id,
                          theme: roomTheme,
                        ),
                      ),
                      SwissArmyPanel.right(
                        theme: roomTheme,
                        child: WaterPanelContent(
                          tankId: currentTank.id,
                          theme: roomTheme,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Stage handle strips
            //
            // Note: previously had subtle 3px translucent accent strips on each
            // edge (when the matching panel was closed) as a "panel exists" hint.
            // QA brief 2026-04 flagged the right strip as an unwanted transparent
            // edge — removed both for symmetry. The StageHandleStrip widgets
            // themselves remain as the panel-open affordance.
            Builder(
              builder: (context) {
                final topOffset = MediaQuery.of(context).size.height * 0.38;
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: topOffset,
                      child: const StageHandleStrip(
                        panel: StagePanel.temp,
                        isLeft: true,
                        icon: Icons.thermostat_rounded,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: topOffset,
                      child: const StageHandleStrip(
                        panel: StagePanel.waterQuality,
                        isLeft: false,
                        icon: Icons.science_rounded,
                      ),
                    ),
                  ],
                );
              },
            ),

            // Top bar overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                  left: AppSpacing.md,
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppOverlays.black30, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: HeartIndicator(compact: true),
                    ),
                    Semantics(
                      label: 'Tank Toolbox',
                      button: true,
                      excludeSemantics: true,
                      onTap: () =>
                          showTankToolbox(context, ref, currentTank.id),
                      child: IconButton(
                        icon: const Icon(
                          Icons.build_outlined,
                          color: AppOverlays.white90,
                        ),
                        tooltip: 'Tank Toolbox',
                        onPressed: () =>
                            showTankToolbox(context, ref, currentTank.id),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AppOverlays.white90,
                      ),
                      tooltip: 'Tank Settings',
                      onPressed: () => NavigationThrottle.push(
                        context,
                        TankSettingsScreen(tankId: currentTank.id),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Demo tank banner (Fix 2: has dismiss × button)
            if (currentTank.isDemoTank && !_demoModeDismissed)
              Positioned(
                top:
                    MediaQuery.of(context).padding.top +
                    _notificationSlotTopOffset,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.sm,
                    top: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                    right: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.science_outlined,
                        size: 14,
                        color: AppColors.onWarning,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          'Demo Mode — this is sample data',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onWarning,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Semantics(
                        label: 'Dismiss demo mode banner',
                        button: true,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _demoModeDismissed = true),
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.onWarning,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom sheet panel (single DraggableScrollableSheet with 4 tabs)
            //
            // Constrain only the pull-up sheet near the floating dock, with
            // the lower part tucked behind the oval so the handle visually
            // emerges from the rail while remaining draggable.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom:
                  MediaQuery.of(context).viewPadding.bottom +
                  DanioBottomDock.height +
                  DanioBottomDock.sheetOverlap,
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: Semantics(
                  label: 'Activity panel — Progress, Tanks, Today',
                  child: BottomSheetPanel(
                    sheetWidth: DanioBottomDock.straightSheetWidthFor(
                      MediaQuery.sizeOf(context).width,
                    ),
                    closedNibWidth: DanioBottomDock.stageSheetNibWidthFor(
                      MediaQuery.sizeOf(context).width,
                    ),
                    closedNibHeight: DanioBottomDock.stageSheetNibHeight,
                    dockGlassStyle: DanioBottomDock.glassStyleFor(
                      context,
                      attached: true,
                    ),
                    progressContent: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: GamificationDashboard(
                        onTap: () => showStatsDetails(context, ref),
                      ),
                    ),
                    tanksContent: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        if (!_isSelectMode)
                          TankSwitcher(
                            tanks: tanks,
                            currentIndex: _currentTankIndex,
                            onChanged: (index) =>
                                setState(() => _currentTankIndex = index),
                            onAddTank: () => _navigateToCreateTank(context),
                            onLongPress: tanks.length > 1
                                ? _toggleSelectMode
                                : null,
                          )
                        else
                          SelectionModePanel(
                            tanks: tanks,
                            selectedIds: _selectedTankIds,
                            onToggleSelection: _toggleTankSelection,
                            onCancel: _toggleSelectMode,
                            onDeleteSelected: () => _bulkDelete(context, tanks),
                            onExportSelected: () => _bulkExport(context, tanks),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        ...tanks.asMap().entries.map(
                          (e) => TankListTile(
                            name: e.value.name,
                            volumeLitres: e.value.volumeLitres,
                            isSelected: e.key == _currentTankIndex,
                            showChevron: true,
                            isDemoTank: e.value.isDemoTank,
                            onTap: () =>
                                _navigateToTankDetail(context, e.value),
                          ),
                        ),
                        // Add New Tank action
                        ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.add_circle_outline_rounded,
                            color: context.textSecondary.withAlpha(128),
                            size: 20,
                          ),
                          title: Text(
                            'Add New Tank',
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.textSecondary.withAlpha(160),
                            ),
                          ),
                          trailing: Icon(
                            Icons.add,
                            color: context.textHint,
                            size: 18,
                          ),
                          onTap: () => _navigateToCreateTank(context),
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                    todayContent: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: TodayBoardCard(tankId: currentTank.id),
                    ),
                  ),
                ),
              ),
            ),

            RoomControlFAB(
              isHidden: _isNavigatingToCreate,
              onStats: () =>
                  showStatsInfo(context, currentLogs, currentTank.id),
              onWaterChange: () => _navigateToWaterChange(context, currentTank),
              onFeed: () =>
                  showFeedingInfo(context, currentLogs, currentTank.id),
              onQuickTest: () => showQuickLogSheet(context, ref, currentTank),
              onAddTank: () => _navigateToCreateTank(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // FQ-E2: Streak loss acknowledgement
    ref.listen<int>(streakResetProvider, (prev, next) {
      if (next > 0 && mounted) {
        ref.read(streakResetProvider.notifier).state = 0;
        DanioSnackBar.info(
          context,
          'Welcome back. Your $next-day streak reset, but let\'s start a new one.',
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildLivingRoomScreen()),
          if (_showStageHandleTooltip)
            Positioned(
              bottom:
                  MediaQuery.of(context).viewPadding.bottom +
                  DanioBottomDock.height +
                  AppSpacing.lg,
              left: 0,
              right: 0,
              child: FirstVisitTooltip(
                prefsKey: GuidanceService.storageKey(
                  GuidancePromptId.tankStageHandles,
                ),
                icon: Icons.swipe_rounded,
                iconColor: AppColors.primary,
                message: 'Tap the side handles for water and feeding details.',
                autoDismissDuration: const Duration(seconds: 5),
                onDismissed: () =>
                    setState(() => _showStageHandleTooltip = false),
              ),
            ),
        ],
      ),
    );
  }
}
