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
import '../../widgets/seasonal_tip_card.dart';
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
    return Skeletonizer(
      child: Stack(
        children: [
          // Skeleton room background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppOverlays.surfaceVariant50,
                  AppColors.surfaceVariant,
                ],
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
                    const SizedBox(width: 12),
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
    final tanksAsync = ref.watch(tanksProvider);

    return tanksAsync.when(
      loading: () => _buildSkeletonRoom(),
      error: (err, stack) => AppErrorState(
        title: 'Couldn\'t load your tanks',
        message: 'Check your connection and give it another go',
        onRetry: () => ref.invalidate(tanksProvider),
      ),
      data: (tanks) {
        _maybeShowFirstTankPrompt(context, tanks);
        if (tanks.isEmpty) {
          return EmptyRoomScene(
            onCreateTank: () => _navigateToCreateTank(context),
            onLoadDemo: () async {
              final actions = ref.read(tankActionsProvider);
              final demoTank = await actions.seedDemoTankIfEmpty();
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
              child: LivingRoomScene(
                tankId: currentTank.id,
                tankName: currentTank.name,
                tankVolume: currentTank.volumeLitres,
                theme: ref.watch(currentRoomThemeProvider),
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

            // Tank switcher - clean card between tank and graph
            if (!_isSelectMode)
              Builder(
                builder: (context) {
                  final bottomPadding = MediaQuery.of(context).padding.bottom;
                  return Positioned(
                    bottom: 180 + bottomPadding, // Above gamification dashboard with FAB clearance
                    left: 16,
                    right: 88, // Leave room for speed dial FAB
                    child: TankSwitcher(
                      tanks: tanks,
                      currentIndex: _currentTankIndex,
                      onChanged: (index) {
                        setState(() => _currentTankIndex = index);
                      },
                      onAddTank: () => _navigateToCreateTank(context),
                      onLongPress: tanks.length > 1 ? _toggleSelectMode : null,
                    ),
                  );
                },
              ),

            // Selection mode UI
            if (_isSelectMode)
              Builder(
                builder: (context) {
                  final bottomPadding = MediaQuery.of(context).padding.bottom;
                  return Positioned(
                    bottom: 180 + bottomPadding, // Above gamification dashboard
                    left: 16,
                    right: 16,
                    child: SelectionModePanel(
                      tanks: tanks,
                      selectedIds: _selectedTankIds,
                      onToggleSelection: _toggleTankSelection,
                      onCancel: _toggleSelectMode,
                      onDeleteSelected: () => _bulkDelete(context, tanks),
                      onExportSelected: () => _bulkExport(context, tanks),
                    ),
                  );
                },
              ),

            // Streak & hearts warning
            Builder(
              builder: (context) {
                final streak = ref.watch(userProfileProvider.select((p) => p.value?.currentStreak ?? 0));
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
                      // Water change streak
                      Builder(
                        builder: (context) {
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
                        const SizedBox(height: 4),
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
              },
            ),

            // Gamification Dashboard - shows all stats at a glance
            // Right margin avoids overlap with FAB
            Positioned(
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              left: 16,
              right: 80, // Leave space for FAB
              child: GamificationDashboard(
                onTap: () => _showStatsDetails(context),
              ),
            ),

            // Speed Dial FAB - radial menu for quick actions
            // ROADMAP: P3 — Add inline 'Quick Log' bottom sheet with pH/temp/ammonia fields for one-tap logging from home screen
            // for even faster water param entry without navigating to full log screen
            // Positioned above the dashboard with safe area padding
            Positioned(
              bottom: 170 + MediaQuery.of(context).padding.bottom,
              right: 16,
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
            ),

            // Seasonal fishkeeping tip
            _buildSeasonalTipOverlay(),

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

  Widget _buildSeasonalTipOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 110,
      left: 0,
      right: 0,
      child: const SeasonalTipCard(),
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
          _buildLivingRoomScreen(),
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

  void _maybeShowFirstTankPrompt(BuildContext context, List<Tank> tanks) {
    if (_firstTankPromptShown || tanks.isNotEmpty) return;
    _firstTankPromptShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showFirstTankSheet(context);
    });
  }

  void _showFirstTankSheet(BuildContext context) {
    final nameC = TextEditingController(text: 'My First Tank');
    final sizeC = TextEditingController(text: '60');
    var tankType = TankType.freshwater;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg2, right: AppSpacing.lg2, top: AppSpacing.md,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.md,
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
              const SizedBox(height: 12),
              Text('Let\'s set up your first tank! \u{1F420}',
                style: Theme.of(context).textTheme.titleLarge!.copyWith( fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: 'Tank name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sizeC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Size (litres)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<TankType>(
                segments: const [
                  ButtonSegment(value: TankType.freshwater, label: Text('Freshwater')),
                  ButtonSegment(value: TankType.marine, label: Text('Saltwater')),
                ],
                selected: {tankType},
                onSelectionChanged: (v) => setSheetState(() => tankType = v.first),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create Tank'),
                  onPressed: () async {
                    final name = nameC.text.trim();
                    final litres = double.tryParse(sizeC.text) ?? 60;
                    if (name.isEmpty) return;
                    final actions = ref.read(tankActionsProvider);
                    final tank = await actions.createTank(
                      name: name,
                      type: tankType,
                      volumeLitres: litres,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      _navigateToTankDetail(context, tank);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCreateTank(BuildContext context) {
    Navigator.of(context).push(
      ModalScaleRoute(page: const CreateTankScreen()),
    );
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
            const SizedBox(height: 12),
            Text('Quick Water Test', style: AppTypography.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(
                  controller: phC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'pH', border: OutlineInputBorder(), isDense: true),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: tempC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Temp (C)', border: OutlineInputBorder(), isDense: true),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: ammoniaC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'NH3', border: OutlineInputBorder(), isDense: true),
                )),
              ],
            ),
            const SizedBox(height: 16),
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
    );
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Tank Toolbox 🔧', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
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
          value: temp != null ? '${temp.toStringAsFixed(1)} C' : 'No data yet',
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
              const Divider(height: 24),
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
                const SizedBox(width: 12),
                Text('Room Theme', style: AppTypography.headlineSmall),
              ],
            ),
            const SizedBox(height: 20),
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
                              : Colors.grey.shade300,
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 20),
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 20),
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 20),
            const DailyGoalProgress(size: 120),
            const SizedBox(height: 20),
            Text('Ways to earn XP:', style: AppTypography.labelLarge),
            const SizedBox(height: 12),
            XpSourceRow(icon: Icons.school, label: 'Complete lesson', xp: 50),
            XpSourceRow(icon: Icons.quiz, label: 'Pass quiz', xp: 25),
            XpSourceRow(icon: Icons.science, label: 'Log water test', xp: 10),
            XpSourceRow(icon: Icons.water_drop, label: 'Water change', xp: 10),
            XpSourceRow(icon: Icons.task_alt, label: 'Complete task', xp: 15),
            const SizedBox(height: 20),
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
            content: Text('Couldn\'t delete those tanks. Try again in a moment.'),
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
