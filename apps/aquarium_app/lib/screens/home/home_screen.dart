import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../models/models.dart';
import '../../services/tank_health_service.dart';
import '../analytics_screen.dart';
import '../../providers/tank_provider.dart';
import '../../providers/hearts_provider.dart';
import '../../providers/storage_provider.dart';
import '../../providers/room_theme_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/bubble_loader.dart';
import '../../theme/room_themes.dart';
import '../../widgets/decorative_elements.dart';
import '../../widgets/hobby_items.dart';
import '../../widgets/hobby_desk.dart';
import '../../widgets/mascot/mascot_widgets.dart';
import '../../widgets/room_scene.dart';
import '../../widgets/speed_dial_fab.dart';
import '../../widgets/daily_goal_progress.dart';
import '../../widgets/streak_calendar.dart';
import '../../widgets/core/app_states.dart';
import '../../widgets/hearts_widgets.dart';
import '../../widgets/gamification_dashboard.dart';
import '../../utils/app_feedback.dart';
import '../add_log_screen.dart';
import '../create_tank_screen.dart';
import '../journal_screen.dart';
import '../reminders_screen.dart';
import '../search_screen.dart';
import '../settings_screen.dart';
import '../tank_detail/tank_detail_screen.dart';
import 'widgets/tank_switcher.dart';
import 'widgets/tank_picker_sheet.dart';
import 'widgets/xp_source_row.dart';
import 'widgets/selection_mode_panel.dart';
import 'widgets/empty_room_scene.dart';
import '../backup_restore_screen.dart';
import '../tab_navigator.dart';
import '../../widgets/stage/stage_provider.dart';
import '../../widgets/stage/stage_scrim.dart';
import '../../widgets/stage/swiss_army_panel.dart';
import '../../widgets/stage/bottom_plate.dart';
import '../../widgets/stage/temp_panel_content.dart';
import '../../widgets/stage/water_panel_content.dart';
import '../../widgets/stage/ambient_tip_overlay.dart';
import '../../widgets/stage/lighting_pulse.dart';
import '../../painters/leather_grain_painter.dart';
import '../../painters/saffiano_painter.dart';
import '../../widgets/fun_loading_messages.dart';
import '../house_navigator.dart';
import '../tank_settings_screen.dart';
import '../../utils/app_page_routes.dart';

/// HomeScreen - The Living Room in the House Navigator
/// This is just the tank management view - navigation between rooms
/// is handled by TabNavigator's tab system.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTankIndex = 0;
  bool _dailyNudgeDismissed = false;
  bool _isSelectMode = false;
  bool _firstTankPromptShown = false;
  bool _isNavigatingToCreate = false;
  bool _showWelcomeBanner = false;
  final Set<String> _selectedTankIds = {};

  @override
  void initState() {
    super.initState();
    _checkWelcomeBanner();
  }

  Future<void> _checkWelcomeBanner() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_welcome_banner') ?? false;
    if (!hasSeen && mounted) {
      setState(() => _showWelcomeBanner = true);
      await prefs.setBool('has_seen_welcome_banner', true);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showWelcomeBanner = false);
      });
    }
  }

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) {
        _selectedTankIds.clear();
      }
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

  Widget _buildSkeletonRoom() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Skeleton room background — must be Positioned.fill to actually render.
          // Use theme-aware colors so dark-mode users don't see a white flash
          // on the loading/post-crash recovery screen.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                // Use theme-aware colors so dark-mode users don't see a white
                // flash on the loading/post-crash recovery screen.
                color: isDark ? AppColors.backgroundDark : null,
                gradient: isDark
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppOverlays.surfaceVariant50,
                          AppColors.surfaceVariant,
                        ],
                      ),
              ),
            ),
          ),
          // Skeleton tank placeholder
          Center(
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: AppOverlays.primary10,
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(color: AppOverlays.primary30),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water, size: AppIconSizes.xl, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.sm),
                  const FunLoadingMessage(),
                ],
              ),
            ),
          ),
          // Skeleton tank switcher
          Positioned(
            bottom: 180 + MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 88,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppOverlays.white95,
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppOverlays.primary15,
                        borderRadius: AppRadius.smallRadius,
                      ),
                      child: const Icon(Icons.set_meal_rounded,
                          color: AppColors.primary, size: AppIconSizes.sm),
                    ),
                    const SizedBox(width: AppSpacing.sm2),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Community Tank',
                            style: AppTypography.labelLarge),
                        Text('200L', style: AppTypography.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivingRoomScreen() {
    // Extract once — prevents 3 separate ref.watch calls (lines ~232, ~268, ~299)
    // rebuilding _HomeScreenState when the room theme changes.
    final theme = ref.watch(currentRoomThemeProvider);
    final tanksAsync = ref.watch(tanksProvider);

    // P0-001 FIX: Guard against the _ElementLifecycle.active assertion.
    // If the widget has been deactivated mid-frame (e.g. by a cascading
    // provider rebuild during cold restart or tab switch), bail out early
    // and return a safe loading widget.  This prevents downstream Consumer
    // widgets from being built on an already-deactivated element tree.
    if (!mounted) return _buildSkeletonRoom();

    return tanksAsync.when(
      loading: () => _buildSkeletonRoom(),
      error: (err, stack) => AppErrorState(
        title: 'Couldn\'t load your tanks',
        message: 'Check your connection and give it another go',
        onRetry: () => ref.invalidate(tanksProvider),
      ),
      data: (tanks) {
        if (!mounted) return _buildSkeletonRoom();
        _maybeShowFirstTankPrompt(context, tanks);
        if (tanks.isEmpty) {
          return EmptyRoomScene(
            onCreateTank: () => _navigateToCreateTank(context),
            onLoadDemo: () async {
              final actions = ref.read(tankActionsProvider);
              final demoTank = await actions.seedDemoTankIfEmpty();
              if (!mounted) return;

              // P1-002 FIX: After seeding the demo tank, explicitly wait for
              // tanksProvider to resolve with the new data before navigating.
              // Without this, the navigation can race with the provider reload,
              // leaving the HomeScreen stuck in loading/empty state when the
              // user returns from TankDetailScreen.
              //
              // Also re-invalidate tanksProvider here to handle edge cases
              // where the provider's cached value is stale (e.g. the provider
              // resolved with empty data before seedDemoTankIfEmpty completed).
              ref.invalidate(tanksProvider);

              // Wait for the provider to resolve with data
              try {
                await ref.read(tanksProvider.future).timeout(
                  const Duration(seconds: 3),
                  onTimeout: () => [demoTank], // fallback
                );
              } catch (_) {
                // Don't block navigation on provider errors
              }

              if (mounted) {
                _navigateToTankDetail(context, demoTank);
              }
            },
          );
        }

        final currentTank = tanks[_currentTankIndex % tanks.length];

        return Stack(
          children: [
            // The room scene
            Positioned.fill(
              child: LightingPulseWrapper(
                child: LivingRoomScene(
                tankId: currentTank.id,
                tankName: currentTank.name,
                tankVolume: currentTank.volumeLitres,
                theme: theme,
                isNewUser: _isNewUser(ref),
                useRiveFish: false, // Disable broken Rive fish, use static drawn fish
                onTankTap: () => _navigateToTankDetail(context, currentTank),
                onTestKitTap: () => _showWaterParams(context),
                onFoodTap: () => _showFeedingInfo(context),
                onPlantTap: () => _showPlantInfo(context),
                onStatsTap: () => _showStatsInfo(context),
                onThemeTap: () => _showThemePicker(context, ref),
                onJournalTap: () => _navigateToJournal(context, currentTank.id),
                onCalendarTap: () => _navigateToSchedule(context),
              ),
              ),
            ),

            // === STAGE SYSTEM ===
            // Scrim: fills the Stack, only interactive when a panel is open.
            Positioned.fill(
              child: Consumer(
                builder: (context, ref, _) {
                  final hasOpen = ref.watch(stageProvider.select((s) => s.openPanels.isNotEmpty));
                  return IgnorePointer(
                    ignoring: !hasOpen,
                    child: const StageScrim(),
                  );
                },
              ),
            ),
            // Side panels — SwissArmyPanel self-hides (SizedBox.shrink) when
            // the animation value is effectively zero, so no Offstage needed.
            // Positioned.fill is required so the inner Stack fills the outer
            // Stack; without it the inner Stack is 0×0 and the SwissArmyPanel's
            // own Positioned children use wrong coordinates, making panels
            // invisible or incorrectly sized.
            Positioned.fill(
              child: Consumer(
                builder: (context, ref, _) {
                  final latestTest = ref.watch(latestWaterTestProvider(currentTank.id));
                  final roomTheme = ref.watch(currentRoomThemeProvider);
                  return Stack(
                    children: [
                      SwissArmyPanel.left(
                        theme: roomTheme,
                        child: TempPanelContent(
                          temperature: latestTest.value?.temperature,
                          theme: roomTheme,
                          onStatsTap: () => _showStatsInfo(context),
                        ),
                      ),
                      SwissArmyPanel.right(
                        theme: roomTheme,
                        child: WaterPanelContent(
                          ph: latestTest.value?.ph,
                          ammonia: latestTest.value?.ammonia,
                          nitrate: latestTest.value?.nitrate,
                          nitrite: latestTest.value?.nitrite,
                          theme: roomTheme,
                          onTestKitTap: () => _showWaterParams(context),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            AmbientTipOverlay(theme: theme),
            // Note: StageHandleStrip widgets are rendered by LivingRoomScene
            // (room_scene.dart) — do NOT add them here too (causes duplicates).

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
                    Flexible(
                      child: Text(
                        currentTank.name,
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          shadows: [Shadow(color: AppOverlays.black50, blurRadius: 4)],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    // Hearts indicator
                    const Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: HeartIndicator(compact: true),
                    ),

                    Semantics(
                      label: 'Tank Toolbox',
                      button: true,
                      child: IconButton(
                        icon: Icon(
                          Icons.build_outlined,
                          color: AppOverlays.white90,
                        ),
                        tooltip: 'Tank Toolbox',
                        onPressed: () => _showTankToolbox(context),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Colors.white),
                      tooltip: 'Tank Settings',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TankSettingsScreen(tankId: currentTank.id)),
                      ),
                    ),
                  ],
                ),
              ),
            ),



            // Streak & hearts warning — standalone ConsumerWidget with its own
            // rebuild scope; only heartsStateProvider + streak selector fire here.
            const _StreakHeartsOverlay(),

            // Bottom Plates — Tanks (behind) then Progress (front, renders on top)
            BottomPlate(
              peekHeight: 32,
              // bottomOffset: 0 is correct because TabNavigator uses
              // extendBody: false — the Scaffold body already ends at the
              // NavigationBar top. Setting 80 here caused the plate to float
              // 80dp above the nav bar (a visible gap + content blockage).
              bottomOffset: 0,
              maxHeightFraction: 0.75,
              label: 'Your Tanks',
              emoji: '🐠',
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              backgroundPainter: CustomPaint(
                painter: SaffianoPainter(),
                size: Size.infinite,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  if (!_isSelectMode)
                    TankSwitcher(
                      tanks: tanks,
                      currentIndex: _currentTankIndex,
                      onChanged: (index) => setState(() => _currentTankIndex = index),
                      onAddTank: () => _navigateToCreateTank(context),
                      onLongPress: tanks.length > 1 ? _toggleSelectMode : null,
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
                  const SizedBox(height: 8),
                  // Tanks list tiles (scrollable)
                  ...tanks.asMap().entries.map(
                    (e) => _buildTankTile(context, e.key, e.value, tanks),
                  ),
                ],
              ),
            ),

            BottomPlate(
              peekHeight: 32,
              bottomOffset: 0, // Scaffold body ends at nav bar top; no extra offset needed
              maxHeightFraction: 0.65,
              label: 'Your Progress',
              emoji: '🔥',
              backgroundColor: Theme.of(context).colorScheme.surface,
              backgroundPainter: CustomPaint(
                painter: LeatherGrainPainter(),
                size: Size.infinite,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GamificationDashboard(
                  onTap: () => _showStatsDetails(context),
                ),
              ),
            ),

            // Speed Dial FAB - radial menu for quick actions
            // ROADMAP: P3 — Add inline 'Quick Log' bottom sheet with pH/temp/ammonia fields for one-tap logging from home screen
            // for even faster water param entry without navigating to full log screen
            // Positioned above the dashboard with safe area padding
            Positioned(
              bottom: 70 + MediaQuery.of(context).padding.bottom,
              right: 16,
              child: IgnorePointer(
                // Hide the FAB from touch events while the tank creation wizard
                // is open — the FAB occupies the same screen position as the
                // wizard's Next/Create buttons, causing mis-taps.
                ignoring: _isNavigatingToCreate,
                child: Opacity(
                  opacity: _isNavigatingToCreate ? 0.0 : 1.0,
                  child: SpeedDialFAB(
                actions: [
                  SpeedDialAction(
                    icon: Icons.calendar_view_month_rounded,
                    label: 'Stats',
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: AppColors.primary,  // Brand amber
                    onPressed: () => _showStatsInfo(context),
                  ),
                  SpeedDialAction(
                    icon: Icons.water_drop_rounded,
                    label: 'Water Change',
                    backgroundColor: AppColors.accent,  // Teal - brand water color
                    foregroundColor: Colors.white,
                    onPressed: () => _navigateToWaterChange(context, currentTank),
                  ),
                  SpeedDialAction(
                    icon: Icons.restaurant_rounded,
                    label: 'Feed',
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: DanioColors.coralAccent,
                    onPressed: () => _showFeedingInfo(context),
                  ),
                  SpeedDialAction(
                    icon: Icons.science_rounded,
                    label: 'Quick Test',
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    onPressed: () => _navigateToQuickTest(context, currentTank),
                  ),
                  SpeedDialAction(
                    icon: Icons.water_rounded,
                    label: 'Add Tank',
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    onPressed: () => _navigateToCreateTank(context),
                  ),
                ],
              ),
                ), // end Opacity
              ), // end IgnorePointer
            ),

            // (stage system Offstage block closed above)

            // Seasonal tip replaced by AmbientTipOverlay in stage system

            // Daily goal nudge - shows if user has 0 XP today
            if (!_dailyNudgeDismissed)
              Builder(
                builder: (context) {
                  final todayKey = DateTime.now().toIso8601String().split('T')[0];
                  final todayXp = ref.watch(userProfileProvider.select(
                    (p) => p.value?.dailyXpHistory[todayKey] ?? 0,
                  ));
                  if (todayXp > 0) return const SizedBox.shrink();
                  return Positioned(
                    top: MediaQuery.of(context).padding.top + 60,
                    left: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => setState(() => _dailyNudgeDismissed = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(230),
                          borderRadius: AppRadius.mediumRadius,
                          boxShadow: [
                            BoxShadow(
                              color: AppOverlays.black20,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              '\u{1F3AF}',
                              style: Theme.of(context).textTheme.titleLarge!,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                "Start a quick lesson to earn XP today!",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.onPrimary.withAlpha(180),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }



  Widget _buildTankTile(BuildContext context, int index, Tank tank, List<Tank> tanks) {
    final isSelected = index == _currentTankIndex;
    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: Colors.white.withAlpha(25),
      leading: Icon(
        Icons.set_meal_rounded,
        color: isSelected ? Colors.white : Colors.white70,
        size: 20,
      ),
      title: Text(
        tank.name,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        '${tank.volumeLitres.toStringAsFixed(0)}L',
        style: TextStyle(color: AppColors.whiteAlpha50, fontSize: 12),
      ),
      onTap: () => setState(() => _currentTankIndex = index),
    );
  }

  @override
  Widget build(BuildContext context) {
    // HomeScreen is the Living Room - it shows tank management only.
    // Navigation to other rooms (Learn, Workshop, Shop, etc.) is handled
    // by TabNavigator's tab system, not a BottomNavigationBar here.
    // Note: FAB is handled inside _buildLivingRoomScreen() Stack, not here
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildLivingRoomScreen()),
          if (_showWelcomeBanner)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: AnimatedOpacity(
                opacity: _showWelcomeBanner ? 1.0 : 0.0,
                duration: AppDurations.long2,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.mediumRadius,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('\u{1F420}', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: AppSpacing.sm2),
                        Expanded(
                          child: Text(
                            'Welcome! Your aquarium journey starts now',
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _maybeShowFirstTankPrompt(BuildContext _, List<Tank> tanks) {
    // Guard: widget may be deactivated by the time this runs during a build
    // callback (e.g. provider rebuild during navigation transition).
    if (!mounted) return;
    // DISABLED: auto-launch was causing lifecycle crashes on first load.
    // Users can still tap "+ Add Your Tank" button manually.
    return;
    // ignore: dead_code
    if (_firstTankPromptShown || tanks.isNotEmpty) return;
    // Only auto-launch create flow when Tank tab is actually visible
    final currentTab = ref.read(currentTabProvider);
    if (currentTab != 2) return; // 2 = Tank tab index
    _firstTankPromptShown = true;
    // Double-deferred: schedule for AFTER this build frame completes and then
    // again after a second frame, giving the widget tree time to settle fully
    // after cold-restart provider initialization.  Prevents the
    // _ElementLifecycle.active assertion when navigating during provider init.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Use this.context (State's own context) — the build-method context
        // passed as parameter is stale by the time this deferred callback fires.
        _navigateToCreateFirstTank(context);
      });
    });
  }

  /// Replaces the old bottom-sheet first-tank flow.
  ///
  /// A full-screen push avoids the navigator overlay race condition that caused
  /// the lifecycle assertion crash when pushing TankDetailScreen while the
  /// bottom sheet exit animation was still running. With a full-screen route
  /// there is no overlay element in a transient state — navigation is clean.
  Future<void> _navigateToCreateFirstTank(BuildContext context) async {
    // Guard against double navigation (e.g. auto-prompt + button tap racing).
    if (_isNavigatingToCreate) return;
    _isNavigatingToCreate = true;

    // Capture navigator before any async gap so it remains valid after awaits.
    final navigator = Navigator.of(context, rootNavigator: true);

    // Snapshot tank count BEFORE pushing so we can detect the new tank after pop.
    final tanksBefore = ref.read(tanksProvider).valueOrNull ?? [];

    await navigator.push(
      MaterialPageRoute(builder: (_) => const CreateTankScreen()),
    );

    _isNavigatingToCreate = false;

    // CreateTankScreen calls Navigator.pop() (no result value) after creation.
    // Await the provider future so we get the freshest tank list.
    if (!mounted) return;
    final tanksAfter = await ref.read(tanksProvider.future).timeout(
      const Duration(seconds: 3),
      onTimeout: () => [],
    );
    if (tanksAfter.length > tanksBefore.length) {
      // Find the newly created tank (the one not in the before-list).
      final beforeIds = tanksBefore.map((t) => t.id).toSet();
      final newTank = tanksAfter.firstWhere(
        (t) => !beforeIds.contains(t.id),
        orElse: () => tanksAfter.first,
      );
      if (mounted) {
        ref.read(currentTabProvider.notifier).state = 2; // Switch to Tank tab
        navigator.push(
          TankDetailRoute(page: TankDetailScreen(tankId: newTank.id)),
        );
      }
    }
  }

  void _navigateToCreateTank(BuildContext context) {
    // Guard: widget may have been deactivated between the button build and tap.
    if (!mounted) return;
    // Guard against double navigation racing with the auto-prompt.
    if (_isNavigatingToCreate) return;
    setState(() => _isNavigatingToCreate = true);
    Navigator.of(context).push(
      ModalScaleRoute(page: const CreateTankScreen()),
    ).whenComplete(() {
      if (mounted) setState(() => _isNavigatingToCreate = false);
    });
  }

  void _navigateToTankDetail(BuildContext context, Tank tank) {
    Navigator.of(context).push(
      TankDetailRoute(page: TankDetailScreen(tankId: tank.id)),
    );
  }

  void _navigateToQuickTest(BuildContext context, Tank tank) {
    _showQuickLogSheet(context, tank);
  }

  void _showQuickLogSheet(BuildContext context, Tank tank) {
    final phC = TextEditingController();
    final tempC = TextEditingController();
    final ammoniaC = TextEditingController();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.sm2),
            Text('Quick Water Test', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: TextField(
                  controller: phC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'pH', border: OutlineInputBorder(), isDense: true),
                )),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: TextField(
                  controller: tempC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Temp (°C)', border: OutlineInputBorder(), isDense: true),
                )),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: TextField(
                  controller: ammoniaC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'NH3', border: OutlineInputBorder(), isDense: true),
                )),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save & Earn 10 XP'),
                onPressed: () async {
                  final ph = double.tryParse(phC.text);
                  final temp = double.tryParse(tempC.text);
                  final ammonia = double.tryParse(ammoniaC.text);
                  if (ph == null && temp == null && ammonia == null) return;
                  final now = DateTime.now();
                  final log = LogEntry(
                    id: now.microsecondsSinceEpoch.toString(),
                    tankId: tank.id,
                    type: LogType.waterTest,
                    timestamp: now,
                    createdAt: now,
                    title: 'Quick test',
                    waterTest: WaterTestResults(ph: ph, temperature: temp, ammonia: ammonia),
                  );
                  final storage = ref.read(storageServiceProvider);
                  await storage.saveLog(log);
                  ref.invalidate(logsProvider(tank.id));
                  ref.invalidate(allLogsProvider(tank.id));
                  await ref.read(userProfileProvider.notifier).addXp(10);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      phC.dispose();
      tempC.dispose();
      ammoniaC.dispose();
    });
  }

  void _navigateToWaterChange(BuildContext context, Tank tank) {
    Navigator.of(context).push(
      ModalScaleRoute(
        page: AddLogScreen(tankId: tank.id, initialType: LogType.waterChange),
      ),
    );
  }

  void _navigateToJournal(BuildContext context, String tankId) {
    Navigator.of(context).push(
      RoomSlideRoute(page: JournalScreen(tankId: tankId)),
    );
  }

  void _navigateToSchedule(BuildContext context) {
    Navigator.of(context).push(
      RoomSlideRoute(page: const RemindersScreen()),
    );
  }

  /// Check if user is new to show more prominent animations
  bool _isNewUser(WidgetRef ref) {
    final hasSeenTutorial = ref.watch(userProfileProvider.select(
      (p) => p.value?.hasSeenTutorial ?? false,
    ));
    return !hasSeenTutorial;
  }


  void _showTankToolbox(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Tank Toolbox 🔧', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm2),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Reminders'),
              onTap: () { Navigator.pop(ctx); Navigator.push(context, RoomSlideRoute(page: const RemindersScreen())); },
            ),
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Tank Journal'),
              onTap: () {
                final tanksAsync = ref.read(tanksProvider);
                tanksAsync.whenData((tanks) {
                  if (tanks.isNotEmpty) {
                    Navigator.pop(ctx);
                    _navigateToJournal(context, tanks[_currentTankIndex % tanks.length].id);
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Species Search'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, RoomSlideRoute(page: const SearchScreen()));
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  /// Helper to format a DateTime as a friendly relative string
  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  /// Get the current tank ID based on tank index
  String? _getCurrentTankId() {
    final tanksAsync = ref.read(tanksProvider);
    return tanksAsync.valueOrNull?.isNotEmpty == true
        ? tanksAsync.valueOrNull![_currentTankIndex % tanksAsync.valueOrNull!.length].id
        : null;
  }

  void _showStatsInfo(BuildContext context) {
    final tankId = _getCurrentTankId();
    if (tankId == null) return;

    final logsAsync = ref.read(logsProvider(tankId));
    final logs = logsAsync.valueOrNull ?? [];

    final waterTests = logs.where((l) => l.type == LogType.waterTest && l.waterTest != null).toList();
    final latestTest = waterTests.isNotEmpty ? waterTests.first : null;
    final temp = latestTest?.waterTest?.temperature;

    final feedings = logs.where((l) => l.type == LogType.feeding).toList();
    final latestFeeding = feedings.isNotEmpty ? feedings.first : null;

    final waterChanges = logs.where((l) => l.type == LogType.waterChange).toList();
    final latestChange = waterChanges.isNotEmpty ? waterChanges.first : null;

    _showItemSheet(
      context,
      title: 'Tank Stats',
      icon: Icons.auto_graph,
      color: DanioColors.amethyst,
      rows: [
        ItemDetailRow(
          label: 'Temperature',
          value: temp != null ? '${temp.toStringAsFixed(1)} °C' : 'No data yet',
        ),
        ItemDetailRow(
          label: 'Last fed',
          value: latestFeeding != null ? _timeAgo(latestFeeding.timestamp) : 'Not logged yet',
        ),
        ItemDetailRow(
          label: 'Water change',
          value: latestChange != null ? _timeAgo(latestChange.timestamp) : 'Log your first change!',
        ),
      ],
    );
  }

  void _showWaterParams(BuildContext context) {
    final tankId = _getCurrentTankId();
    if (tankId == null) return;

    final logsAsync = ref.read(logsProvider(tankId));
    final logs = logsAsync.valueOrNull ?? [];

    final waterTests = logs.where((l) => l.type == LogType.waterTest && l.waterTest != null).toList();
    final latestTest = waterTests.isNotEmpty ? waterTests.first : null;
    final wt = latestTest?.waterTest;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: EdgeInsets.all(AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.lg2),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppRadius.largeRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text('\u{1F9EA}', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Water Parameters', style: AppTypography.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.sm2),
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha(20),
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(color: AppColors.accent.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\u{2705} Ideal Ranges (Freshwater)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'pH 6.5-7.5  |  Ammonia 0 ppm  |  Nitrite 0 ppm  |  Nitrate <40 ppm',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (wt == null || !wt.hasValues) ...[
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Column(
                    children: [
                      Text('No test results yet', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Log your first water test to see results here!',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              _buildParamRow('pH', wt.ph?.toStringAsFixed(1) ?? '--', '6.5 - 7.5'),
              _buildParamRow('Ammonia', wt.ammonia != null ? '${wt.ammonia!.toStringAsFixed(2)} ppm' : '--', '0 ppm'),
              _buildParamRow('Nitrite', wt.nitrite != null ? '${wt.nitrite!.toStringAsFixed(2)} ppm' : '--', '0 ppm'),
              _buildParamRow('Nitrate', wt.nitrate != null ? '${wt.nitrate!.toStringAsFixed(1)} ppm' : '--', '<40 ppm'),
              const Divider(height: AppSpacing.lg),
              Text('Last tested: ${_timeAgo(latestTest!.timestamp)}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text('\u{1F41F} What this means for your fish',
              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Stable water parameters are the single most important factor in fish health. Test weekly and after any changes to your tank.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, RoomSlideRoute(
                    page: AddLogScreen(tankId: tankId, initialType: LogType.waterTest),
                  ));
                },
                icon: const Icon(Icons.science, size: 18),
                label: const Text('Log Water Test'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildParamRow(String label, String value, String ideal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          Text(value, style: AppTypography.labelLarge),
          if (ideal.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Text('(ideal: $ideal)',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textHint),
            ),
          ],
        ],
      ),
    );
  }


  void _showFeedingInfo(BuildContext context) {
    final tankId = _getCurrentTankId();
    if (tankId == null) return;

    final logsAsync = ref.read(logsProvider(tankId));
    final logs = logsAsync.valueOrNull ?? [];

    final feedings = logs.where((l) => l.type == LogType.feeding).toList();
    final latestFeeding = feedings.isNotEmpty ? feedings.first : null;

    final today = DateTime.now();
    final feedingsToday = feedings.where((l) =>
        l.timestamp.year == today.year &&
        l.timestamp.month == today.month &&
        l.timestamp.day == today.day).length;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: EdgeInsets.all(AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.lg2),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppRadius.largeRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text('\u{1F3A3}', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Feeding', style: AppTypography.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.sm2),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(20),
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(color: AppColors.secondary.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\u{1F4CB} Feeding Guidelines',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Feed 2-3 times daily  |  Only what they eat in 2 min  |  Variety is key',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildParamRow('Fed today', '$feedingsToday time${feedingsToday == 1 ? '' : 's'}', '2-3x'),
            _buildParamRow(
              'Last fed',
              latestFeeding != null ? _timeAgo(latestFeeding.timestamp) : 'Not yet',
              '',
            ),
            const SizedBox(height: AppSpacing.md),
            Text('\u{1F41F} What this means for your fish',
              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Overfeeding is the #1 cause of water quality issues. Feed small amounts your fish can finish in 2 minutes.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, RoomSlideRoute(
                    page: AddLogScreen(tankId: tankId, initialType: LogType.feeding),
                  ));
                },
                icon: const Icon(Icons.restaurant, size: 18),
                label: const Text('Log Feeding'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }


  void _showPlantInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: EdgeInsets.all(AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.lg2),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppRadius.largeRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text('\u{1FAB4}', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Tank Plants', style: AppTypography.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.sm2),
              decoration: BoxDecoration(
                color: DanioColors.emeraldGreen.withAlpha(20),
                borderRadius: AppRadius.mediumRadius,
                border: Border.all(color: DanioColors.emeraldGreen.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\u{2728} Plant Care Tips',
                    style: AppTypography.labelMedium.copyWith(
                      color: DanioColors.emeraldGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '8-10 hrs light daily  |  Trim dead leaves  |  Root tabs for heavy feeders',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('\u{1F41F} What this means for your fish',
              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Live plants absorb nitrates, produce oxygen, and provide shelter. They are one of the best things you can add to any tank.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '\u{1F4A1} Pro tip: Use old tank water to water your houseplants -- packed with nutrients!',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }


  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: EdgeInsets.all(AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.lg2),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppRadius.largeRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, size: AppIconSizes.md),
                const SizedBox(width: AppSpacing.sm2),
                Text('Room Theme', style: AppTypography.headlineSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.lg2),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: RoomThemeType.values.map((type) {
                final theme = RoomTheme.fromType(type);
                final isSelected = ref.watch(roomThemeProvider) == type;
                return Semantics(
                  label: '${theme.name} theme${isSelected ? ', selected' : ''}',
                  button: true,
                  selected: isSelected,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(roomThemeProvider.notifier).setTheme(type);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 100,
                      padding: EdgeInsets.all(AppSpacing.sm2),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.mediumRadius,
                        border: Border.all(
                          color: isSelected
                              ? theme.accentBlob
                              : AppColors.border,
                          width: isSelected ? 3 : 1,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [theme.background1, theme.background2],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: theme.accentBlob,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: theme.waterMid,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: theme.plantPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            theme.name,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            theme.description,
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: theme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showItemSheet(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<ItemDetailRow> rows,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: EdgeInsets.all(AppSpacing.md),
        child: ItemDetailPopup(
          title: title,
          icon: icon,
          accentColor: color,
          rows: rows,
          onClose: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  void _showStatsDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: EdgeInsets.all(AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.lg2),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppRadius.largeRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm2),
                Text('Your Progress', style: AppTypography.headlineSmall),
                const Spacer(),
                Semantics(
                  label: 'Close progress',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg2),
            // Gamification dashboard without card styling
            const GamificationDashboard(showAsCard: false),
            const SizedBox(height: AppSpacing.lg),
            // Quick actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showDailyGoalDetails(context);
                    },
                    icon: const Icon(Icons.flag),
                    label: const Text('Daily Goal'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showStreakCalendar(context);
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Calendar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg2),
          ],
        ),
      ),
    );
  }

  void _showDailyGoalDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: EdgeInsets.all(AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.lg2),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppRadius.largeRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm2),
                Text('Daily Goal', style: AppTypography.headlineSmall),
                const Spacer(),
                Semantics(
                  label: 'Close daily goal',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg2),
            const DailyGoalProgress(size: 120),
            const SizedBox(height: AppSpacing.lg2),
            Text('Ways to earn XP:', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm2),
            XpSourceRow(icon: Icons.school, label: 'Complete lesson', xp: 50),
            XpSourceRow(icon: Icons.quiz, label: 'Pass quiz', xp: 25),
            XpSourceRow(icon: Icons.science, label: 'Log water test', xp: 10),
            XpSourceRow(icon: Icons.water_drop, label: 'Water change', xp: 10),
            XpSourceRow(icon: Icons.task_alt, label: 'Complete task', xp: 15),
            const SizedBox(height: AppSpacing.lg2),
          ],
        ),
      ),
    );
  }

  void _showStreakCalendar(BuildContext context) {
    Navigator.push(
      context,
      RoomSlideRoute(page: const StreakCalendarScreen()),
    );
  }

  Future<void> _bulkDelete(BuildContext context, List<Tank> allTanks) async {
    if (_selectedTankIds.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pick some tanks first!')));
      }
      return;
    }

    final selectedTanks = allTanks
        .where((t) => _selectedTankIds.contains(t.id))
        .toList();
    final tankNames = selectedTanks.map((t) => t.name).join(', ');
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete ${_selectedTankIds.length} tank${_selectedTankIds.length > 1 ? 's' : ''}?',
        ),
        content: Text(
          'Tanks to delete:\n\n$tankNames\n\nThis will remove all livestock, equipment, logs, and tasks for these tanks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final actions = ref.read(tankActionsProvider);
      await actions.bulkDeleteTanks(_selectedTankIds.toList());

      if (mounted) {
        setState(() {
          _isSelectMode = false;
          _selectedTankIds.clear();
          _currentTankIndex = 0;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '${selectedTanks.length} tank${selectedTanks.length > 1 ? 's' : ''} deleted',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Couldn\'t delete those tanks, try again in a moment'),
          ),
        );
      }
    }
  }

  Future<void> _bulkExport(BuildContext context, List<Tank> allTanks) async {
    if (_selectedTankIds.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pick some tanks first!')));
      }
      return;
    }

    // Navigate to backup/restore screen for full export functionality
    if (mounted) {
      setState(() {
        _selectedTankIds.clear();
      });
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BackupRestoreScreen(),
        ),
      );
    }
  }

}

/// Standalone ConsumerWidget for the streak / hearts overlay.
///
/// Extracted from the inline [Builder] in [_HomeScreenState._buildLivingRoomScreen]
/// so that hearts or streak changes only rebuild this small widget rather than
/// the entire HomeScreen widget tree.
class _StreakHeartsOverlay extends ConsumerWidget {
  const _StreakHeartsOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(
      userProfileProvider.select((p) => p.value?.currentStreak ?? 0),
    );
    final hearts = ref.watch(heartsStateProvider);
    final lowHearts = hearts.currentHearts <= 1;

    if (streak == 0 && !lowHearts) return const SizedBox.shrink();

    return Positioned(
      bottom: 100 + MediaQuery.of(context).padding.bottom,
      left: 16,
      right: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm2, vertical: 6),
              decoration: BoxDecoration(
                color: DanioColors.amberGold.withAlpha(230),
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Text(
                '\u{1F525} $streak day streak!',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Water change streak — isolated in its own Consumer to avoid
          // pulling tanksProvider / allLogsProvider into this widget's scope.
          Consumer(
            builder: (context, ref, _) {
              final tanks = ref.watch(tanksProvider).value ?? [];
              if (tanks.isEmpty) return const SizedBox.shrink();
              final logsAsync = ref.watch(allLogsProvider(tanks.first.id));
              return logsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (logs) {
                  final wcStreak = TankHealthService.calculateWaterChangeStreak(logs);
                  if (wcStreak == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm2, vertical: 6),
                      decoration: BoxDecoration(
                        color: DanioColors.tealWater.withAlpha(230),
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Text(
                        '\u{1F4A7} Water change streak: $wcStreak week${wcStreak == 1 ? "" : "s"}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (lowHearts && hearts.currentHearts >= 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm2, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(210),
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Text(
                hearts.currentHearts == 0
                    ? '\u{1F494} No hearts left - wait for refill!'
                    : '\u{26A0}\u{FE0F} You\'re on your last heart - be careful!',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
