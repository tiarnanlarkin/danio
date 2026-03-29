import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/tank_provider.dart';
import '../../providers/room_theme_provider.dart';
import '../../providers/user_profile_provider.dart';
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
import '../../widgets/stage/ambient_tip_overlay.dart';
import '../../widgets/stage/lighting_pulse.dart';
import '../../utils/app_page_routes.dart';
import '../../utils/navigation_throttle.dart';
import '../../widgets/room_scene.dart';
import '../../widgets/first_visit_tooltip.dart';
import '../onboarding/returning_user_flows.dart';
import '../create_tank_screen.dart';
import '../add_log_screen.dart';
import '../journal_screen.dart';
import '../tank_settings_screen.dart';
import '../backup_restore_screen.dart';
import '../tank_detail/tank_detail_screen.dart';
import 'home_sheets.dart';
import 'widgets/tank_switcher.dart';
import 'widgets/selection_mode_panel.dart';
import 'widgets/empty_room_scene.dart';
import 'widgets/today_board.dart';
import 'widgets/welcome_banner.dart';
import 'widgets/comeback_banner.dart';
import 'widgets/daily_nudge.dart';
import 'widgets/streak_hearts_overlay.dart';
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
  int _currentTankIndex = 0;
  bool _dailyNudgeDismissed = false;
  bool _isSelectMode = false;
  bool _isNavigatingToCreate = false;
  bool _showWelcomeBanner = false;
  bool _showComebackBanner = false;
  bool _demoModeDismissed = false;
  bool _showTankTooltip = true;
  bool _showHeartsTooltip = true;
  bool _showStageHandleTooltip = true;
  bool _showRoomMetaphorTooltip = true;
  String? _cachedUserName;
  String? _cachedFishSpeciesName;
  final Set<String> _selectedTankIds = {};

  @override
  void initState() {
    super.initState();
    _checkWelcomeBanner();
    _checkComebackBanner();
    _checkReturningUserFlow();
    _checkTooltipFlags();
  }

  // ── Lifecycle checks ──────────────────────────────────────────────────

  Future<void> _checkTooltipFlags() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final seenTank = prefs.getBool('tooltip_seen_tank') ?? false;
    final seenHearts = prefs.getBool('tooltip_seen_hearts') ?? false;
    final seenStageHandles = prefs.getBool('tooltip_seen_stage_handles') ?? false;
    final seenRoomMetaphor = prefs.getBool('tooltip_seen_room_metaphor') ?? false;
    if (mounted) {
      setState(() {
        _showTankTooltip = !seenTank;
        _showHeartsTooltip = !seenHearts;
        _showStageHandleTooltip = !seenStageHandles;
        _showRoomMetaphorTooltip = !seenRoomMetaphor;
      });
    }
  }

  /// Waits for the user profile to load from the provider.
  ///
  /// Waits for [userProfileProvider] to finish loading by polling the
  /// StateNotifierProvider until it emits a non-loading value.
  /// Falls back gracefully if loading fails or times out.
  Future<UserProfile?> _waitForProfile() async {
    // Fast path: already loaded synchronously.
    final current = ref.read(userProfileProvider).valueOrNull;
    if (current != null) return current;

    // Poll until the async value resolves (loading → data or error).
    // Timeout after 5 seconds to prevent infinite waits on slow devices.
    const pollInterval = Duration(milliseconds: 100);
    const timeout = Duration(seconds: 5);
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(pollInterval);
      final state = ref.read(userProfileProvider);
      if (state is AsyncData<UserProfile?>) return state.value;
      if (state is AsyncError<UserProfile?>) return null;
    }

    // Timed out — return whatever is in state (may be null).
    return ref.read(userProfileProvider).valueOrNull;
  }

  Future<void> _checkWelcomeBanner() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final hasSeen = prefs.getBool('has_seen_welcome_banner') ?? false;
    if (!hasSeen && mounted) {
      final profile = await _waitForProfile();
      if (profile != null) {
        _cachedUserName = profile.name;
      }
      setState(() => _showWelcomeBanner = true);
      await prefs.setBool('has_seen_welcome_banner', true);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showWelcomeBanner = false);
      });
    }
  }

  Future<void> _checkComebackBanner() async {
    try {
      final profile = await _waitForProfile();
      if (profile == null || !mounted) return;

      final hadStreak = profile.currentStreak;
      final lastActivity = profile.lastActivityDate;
      _cachedFishSpeciesName = profile.firstFishSpeciesId;
      _cachedUserName ??= profile.name;
      if (hadStreak <= 0 || lastActivity == null) return;

      final today = DateTime.now();
      final todayStr = today.toIso8601String().substring(0, 10);
      final yesterdayStr = today.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
      final lastStr = lastActivity.toIso8601String().substring(0, 10);

      if (lastStr != todayStr && lastStr != yesterdayStr && mounted) {
        setState(() => _showComebackBanner = true);
      }
    } catch (e, st) {
      logError('HomeScreen: comeback banner check failed: $e', stackTrace: st, tag: 'HomeScreen');
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

      if (daysSinceSignup >= 1 && daysSinceSignup <= 2 && currentStreak >= 1 &&
          (prefs.getBool('seen_day2_prompt') ?? false) == false) {
        milestoneCard = Day2StreakPrompt(
          fishName: fishName,
          onContinue: () => Navigator.of(context).pop(),
          onDismiss: () => Navigator.of(context).pop(),
        );
        prefsKey = 'seen_day2_prompt';
      } else if (daysSinceSignup >= 7 && daysSinceSignup <= 8 && currentStreak >= 5 &&
          (prefs.getBool('seen_day7_milestone') ?? false) == false) {
        // FB-B3 fix: pop the dialog first, then navigate to Compatibility Checker
        milestoneCard = Day7MilestoneCard(onFeatureTap: () {
          Navigator.of(context).pop();
          NavigationThrottle.push(context, const CompatibilityCheckerScreen());
        });
        prefsKey = 'seen_day7_milestone';
      } else if (daysSinceSignup >= 30 && daysSinceSignup <= 31 && currentStreak >= 1 &&
          (prefs.getBool('seen_day30_committed') ?? false) == false) {
        final totalXp = profile.totalXp;
        final lessonsCompleted = profile.completedLessons.length;
        milestoneCard = Day30CommittedCard(
          lessonsCompleted: lessonsCompleted,
          xpEarned: totalXp,
          // FB-B4: No upgrade destination yet — pass null to hide the CTA.
          // Wire onUpgrade to a real paywall/upgrade screen when available.
          onUpgrade: null,
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
      logError('HomeScreen: returning user flow check failed: $e', stackTrace: st, tag: 'HomeScreen');
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
    return !ref.watch(userProfileProvider.select((p) => p.value?.hasSeenTutorial ?? false));
  }

  // ── Navigation ────────────────────────────────────────────────────────

  void _navigateToCreateTank(BuildContext context) {
    if (!mounted || _isNavigatingToCreate) return;
    setState(() => _isNavigatingToCreate = true);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateTankScreen()))
        .whenComplete(() async {
      if (mounted) {
        setState(() => _isNavigatingToCreate = false);
        final tanksBefore = ref.read(tanksProvider).valueOrNull ?? [];
        ref.invalidate(tanksProvider);
        final tanksAfter = await ref.read(tanksProvider.future)
            .timeout(const Duration(seconds: 3), onTimeout: () => []);
        if (mounted && tanksAfter.length > tanksBefore.length) {
          final beforeIds = tanksBefore.map((t) => t.id).toSet();
          final newIndex = tanksAfter.indexWhere((t) => !beforeIds.contains(t.id));
          if (newIndex >= 0) setState(() => _currentTankIndex = newIndex);
        }
      }
    });
  }

  void _navigateToTankDetail(BuildContext context, Tank tank) {
    Navigator.of(context).push(TankDetailRoute(page: TankDetailScreen(tankId: tank.id)));
  }

  void _navigateToWaterChange(BuildContext context, Tank tank) {
    Navigator.of(context).push(
      ModalScaleRoute(page: AddLogScreen(tankId: tank.id, initialType: LogType.waterChange)),
    );
  }

  Future<void> _bulkDelete(BuildContext context, List<Tank> allTanks) async {
    if (_selectedTankIds.isEmpty) {
      if (mounted) {
        DanioSnackBar.warning(context, 'Pick some tanks first!');
      }
      return;
    }
    final selectedTanks = allTanks.where((t) => _selectedTankIds.contains(t.id)).toList();
    final tankNames = selectedTanks.map((t) => t.name).join(', ');
    final confirmed = await showAppDestructiveDialog(
      context: context,
      title: 'Delete ${_selectedTankIds.length} tank${_selectedTankIds.length > 1 ? 's' : ''}?',
      message: 'Tanks to delete:\n\n$tankNames\n\nThis will remove all livestock, equipment, logs, and tasks for these tanks.',
      destructiveLabel: 'Delete ${_selectedTankIds.length > 1 ? 'Tanks' : 'Tank'}',
      cancelLabel: 'Keep',
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(tankActionsProvider).bulkDeleteTanks(_selectedTankIds.toList());
      if (context.mounted) {
        setState(() { _isSelectMode = false; _selectedTankIds.clear(); _currentTankIndex = 0; });
        DanioSnackBar.success(context, '${selectedTanks.length} tank${selectedTanks.length > 1 ? 's' : ''} deleted');
      }
    } catch (e, st) {
      logError('HomeScreen: bulk delete tanks failed: $e', stackTrace: st, tag: 'HomeScreen');
      if (context.mounted) DanioSnackBar.error(context, 'Couldn\'t delete those tanks, try again in a moment');
    }
  }

  Future<void> _bulkExport(BuildContext context, List<Tank> allTanks) async {
    if (_selectedTankIds.isEmpty) {
      if (mounted) DanioSnackBar.warning(context, 'Pick some tanks first!');
      return;
    }
    if (mounted) {
      setState(() => _selectedTankIds.clear());
      NavigationThrottle.push(context, const BackupRestoreScreen());
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  Widget _buildLivingRoomScreen() {
    final theme = ref.watch(currentRoomThemeProvider);
    final tanksAsync = ref.watch(tanksProvider);
    if (!mounted) return const SkeletonRoom();
    if (tanksAsync.isLoading && !tanksAsync.hasValue) return const SkeletonRoom();
    if (tanksAsync.hasError && !tanksAsync.hasValue) {
      return AppErrorState(
        title: 'Couldn\'t load your tanks',
        message: 'Check your connection and give it another go!',
        onRetry: () => ref.invalidate(tanksProvider),
      );
    }

    final tanksData = tanksAsync.valueOrNull ?? [];
    return Builder(builder: (context) {
      final tanks = tanksData;
      if (!mounted) return const SkeletonRoom();

      if (tanks.isEmpty) {
        return EmptyRoomScene(
          onCreateTank: () => _navigateToCreateTank(context),
          onLoadDemo: () async {
            final actions = ref.read(tankActionsProvider);
            final demoTank = await actions.seedDemoTankIfEmpty();
            if (!mounted) return;
            ref.invalidate(tanksProvider);
            try {
              await ref.read(tanksProvider.future).timeout(const Duration(seconds: 3), onTimeout: () => [demoTank]);
            } catch (e, st) {
              logError('HomeScreen: demo tank refresh after delete failed: $e', stackTrace: st, tag: 'HomeScreen');
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
                  onTankTap: () => _navigateToTankDetail(context, currentTank),
                  onTestKitTap: () => showWaterParams(context, currentLogs, currentTank.id),
                  onFoodTap: () => showFeedingInfo(context, currentLogs, currentTank.id),
                  onPlantTap: () => showPlantInfo(context),
                  onStatsTap: () => showStatsInfo(context, currentLogs, currentTank.id),
                  onThemeTap: () => showThemePicker(context, ref),
                  onJournalTap: () => NavigationThrottle.push(context, JournalScreen(tankId: currentTank.id), route: RoomSlideRoute(page: JournalScreen(tankId: currentTank.id))),
                  onCalendarTap: () => showStreakCalendar(context),
                ),
              ),
            ),
          ),

          // Stage system
          Positioned.fill(
            child: Consumer(builder: (context, ref, _) {
              final hasOpen = ref.watch(stageProvider.select((s) => s.openPanels.isNotEmpty));
              return IgnorePointer(ignoring: !hasOpen, child: const StageScrim());
            }),
          ),
          Positioned.fill(
            child: Consumer(builder: (context, ref, _) {
              final roomTheme = ref.watch(currentRoomThemeProvider);
              return Stack(children: [
                SwissArmyPanel.left(theme: roomTheme, child: TempPanelContent(tankId: currentTank.id, theme: roomTheme)),
                SwissArmyPanel.right(theme: roomTheme, child: WaterPanelContent(tankId: currentTank.id, theme: roomTheme)),
              ]);
            }),
          ),
          AmbientTipOverlay(theme: theme),

          // Stage handle strips
          Builder(builder: (context) {
            final topOffset = MediaQuery.of(context).size.height * 0.38;
            return Stack(children: [
              // Subtle edge accent lines when panels are closed
              Consumer(builder: (context, ref, _) {
                final openPanels = ref.watch(stageProvider.select((s) => s.openPanels));
                final leftClosed = !openPanels.contains(StagePanel.temp);
                final rightClosed = !openPanels.contains(StagePanel.waterQuality);
                return Stack(children: [
                  if (leftClosed)
                    Positioned(
                      left: 0,
                      top: topOffset - 4,
                      child: Container(
                        width: 3,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(90),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
                        ),
                      ),
                    ),
                  if (rightClosed)
                    Positioned(
                      right: 0,
                      top: topOffset - 4,
                      child: Container(
                        width: 3,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(90),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)),
                        ),
                      ),
                    ),
                ]);
              }),
              Positioned(left: 0, top: topOffset, child: const StageHandleStrip(panel: StagePanel.temp, isLeft: true, icon: Icons.thermostat_rounded)),
              Positioned(right: 0, top: topOffset, child: const StageHandleStrip(panel: StagePanel.waterQuality, isLeft: false, icon: Icons.science_rounded)),
            ]);
          }),

          // Top bar overlay
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                left: AppSpacing.md, right: AppSpacing.sm, bottom: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppOverlays.black30, Colors.transparent]),
              ),
              child: Row(children: [
                const Spacer(),
                const Padding(padding: EdgeInsets.only(right: AppSpacing.sm), child: HeartIndicator(compact: true)),
                Semantics(
                  label: 'Tank Toolbox', button: true,
                  child: IconButton(
                    icon: const Icon(Icons.build_outlined, color: AppOverlays.white90),
                    tooltip: 'Tank Toolbox',
                    onPressed: () => showTankToolbox(context, ref, currentTank.id),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: AppOverlays.white90),
                  tooltip: 'Tank Settings',
                  onPressed: () => NavigationThrottle.push(context, TankSettingsScreen(tankId: currentTank.id)),
                ),
              ]),
            ),
          ),

          const StreakHeartsOverlay(),

          // Demo tank banner (Fix 2: has dismiss × button)
          if (currentTank.isDemoTank && !_demoModeDismissed)
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.only(left: AppSpacing.sm, top: AppSpacing.xs, bottom: AppSpacing.xs, right: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.science_outlined, size: 14, color: AppColors.onWarning),
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
                        onTap: () => setState(() => _demoModeDismissed = true),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: Icon(Icons.close, size: 18, color: AppColors.onWarning),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom sheet panel (single DraggableScrollableSheet with 4 tabs)
          Positioned.fill(
            child: Semantics(
              label: 'Activity panel — Progress, Tanks, Today',
              child: BottomSheetPanel(
                progressContent: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: GamificationDashboard(onTap: () => showStatsDetails(context, ref)),
                ),
                tanksContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    if (!_isSelectMode)
                      TankSwitcher(
                        tanks: tanks, currentIndex: _currentTankIndex,
                        onChanged: (index) => setState(() => _currentTankIndex = index),
                        onAddTank: () => _navigateToCreateTank(context),
                        onLongPress: tanks.length > 1 ? _toggleSelectMode : null,
                      )
                    else
                      SelectionModePanel(
                        tanks: tanks, selectedIds: _selectedTankIds,
                        onToggleSelection: _toggleTankSelection,
                        onCancel: _toggleSelectMode,
                        onDeleteSelected: () => _bulkDelete(context, tanks),
                        onExportSelected: () => _bulkExport(context, tanks),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    ...tanks.asMap().entries.map((e) => TankListTile(
                      name: e.value.name,
                      volumeLitres: e.value.volumeLitres,
                      isSelected: e.key == _currentTankIndex,
                      showChevron: true,
                      isDemoTank: e.value.isDemoTank,
                      onTap: () => _navigateToTankDetail(context, e.value),
                    )),
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
                      trailing: Icon(Icons.add, color: context.textHint, size: 18),
                      onTap: () => _navigateToCreateTank(context),
                    ),
                    const Divider(height: 1),
                  ],
                ),
                todayContent: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
                  child: TodayBoardCard(tankId: currentTank.id),
                ),
              ),
            ),
          ),

          RoomControlFAB(
            isHidden: _isNavigatingToCreate,
            onStats: () => showStatsInfo(context, currentLogs, currentTank.id),
            onWaterChange: () => _navigateToWaterChange(context, currentTank),
            onFeed: () => showFeedingInfo(context, currentLogs, currentTank.id),
            onQuickTest: () => showQuickLogSheet(context, ref, currentTank),
            onAddTank: () => _navigateToCreateTank(context),
          ),

          if (!_dailyNudgeDismissed)
            DailyNudgeBanner(onDismiss: () => setState(() => _dailyNudgeDismissed = true)),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final showWelcome = _showWelcomeBanner;
    final showComeback = _showComebackBanner && !showWelcome;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildLivingRoomScreen()),
          if (showWelcome)
            WelcomeBanner(
              userName: _cachedUserName,
              visible: _showWelcomeBanner,
              onDismiss: () => setState(() => _showWelcomeBanner = false),
            ),
          if (showComeback)
            ComebackBanner(
              userName: _cachedUserName,
              fishSpeciesName: _cachedFishSpeciesName,
              onDismiss: () => setState(() => _showComebackBanner = false),
            ),
          if (_showTankTooltip && !showWelcome && !showComeback)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: FirstVisitTooltip(
                  prefsKey: 'tooltip_seen_tank',
                  emoji: '🏠',
                  message: 'This is your Living Room — manage your aquariums here!',
                  onDismissed: () => setState(() => _showTankTooltip = false),
                ),
              ),
            ),
          if (_showHeartsTooltip && !showWelcome && !showComeback)
            Positioned(
              top: 56,
              left: 0,
              right: 0,
              child: FirstVisitTooltip(
                prefsKey: 'tooltip_seen_hearts',
                emoji: '❤️',
                message: 'Hearts show your progress! Earn them by completing lessons and caring for your tank. Lose one for each wrong quiz answer — but don\'t worry, they reset daily!',
                autoDismissDuration: const Duration(seconds: 6),
                onDismissed: () => setState(() => _showHeartsTooltip = false),
              ),
            ),
          if (_showStageHandleTooltip && !showWelcome && !showComeback)
            Positioned(
              bottom: 160,
              left: 0,
              right: 0,
              child: FirstVisitTooltip(
                prefsKey: 'tooltip_seen_stage_handles',
                emoji: '👆',
                message: 'Tap the side handles to check water parameters and feeding info!',
                autoDismissDuration: const Duration(seconds: 5),
                onDismissed: () => setState(() => _showStageHandleTooltip = false),
              ),
            ),
          if (_showRoomMetaphorTooltip && !showWelcome && !showComeback && !_showTankTooltip && !_showHeartsTooltip && !_showStageHandleTooltip)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: FirstVisitTooltip(
                  prefsKey: 'tooltip_seen_room_metaphor',
                  emoji: '🏡',
                  message: 'This is your virtual fish room. Your tank lives in the centre — tap the panels on each side to check water parameters, lighting, and more!',
                  autoDismissDuration: const Duration(seconds: 6),
                  onDismissed: () => setState(() => _showRoomMetaphorTooltip = false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
