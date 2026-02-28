import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../models/models.dart';
import '../../providers/tank_provider.dart';
import '../../providers/room_theme_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/gems_provider.dart';
import '../../providers/hearts_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/bubble_loader.dart';
import '../house_navigator.dart';
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
import '../../utils/app_page_routes.dart';

/// HomeScreen - The Living Room in the House Navigator
/// This is just the tank management view - navigation between rooms
/// is handled by HouseNavigator's swipe/tab system.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTankIndex = 0;
  bool _isSelectMode = false;
  final Set<String> _selectedTankIds = {};

  @override
  void initState() {
    super.initState();
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
                  Text('Loading tanks...', style: AppTypography.bodyMedium),
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
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
        title: 'Failed to load tanks',
        message: 'Please check your connection and try again',
        onRetry: () => ref.invalidate(tanksProvider),
      ),
      data: (tanks) {
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

        // Providers for compact stats bar
        final profileAsync = ref.watch(userProfileProvider);
        final gemsAsync = ref.watch(gemsProvider);
        final heartsState = ref.watch(heartsStateProvider);
        final dailyGoal = ref.watch(todaysDailyGoalProvider);

        return Column(
          children: [
            // === 1. Top bar with room title + search/settings ===
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 4,
                left: 16,
                right: 8,
                bottom: 4,
              ),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Semantics(
                    label: 'Living Room, switch room',
                    button: true,
                    child: GestureDetector(
                      onTap: () => _showRoomSwitcher(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Living Room',
                            style: AppTypography.headlineSmall,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: AppIconSizes.sm,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    label: 'Search',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () => Navigator.push(
                        context,
                        RoomSlideRoute(page: const SearchScreen()),
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Settings',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Settings',
                      onPressed: () => Navigator.push(
                        context,
                        RoomSlideRoute(page: const SettingsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // === 2. Compact stats bar (streak, XP, gems, hearts) ===
            profileAsync.when(
              loading: () => const SizedBox(height: 44),
              error: (_, __) => const SizedBox(height: 44),
              data: (profile) {
                if (profile == null) return const SizedBox(height: 44);
                final gems = gemsAsync.value?.balance ?? 0;
                return GestureDetector(
                  onTap: () => _showStatsDetails(context),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CompactStat(icon: '🔥', value: '${profile.currentStreak}', color: AppColors.warning),
                        _CompactStat(icon: '⭐', value: _formatXp(profile.totalXp), color: AppColors.accent),
                        _CompactStat(icon: '💎', value: _formatXp(gems), color: AppColors.info),
                        _CompactHearts(current: heartsState.currentHearts, max: heartsState.maxHearts),
                      ],
                    ),
                  ),
                );
              },
            ),

            // === 3. Room scene — clean hero, NO stat overlays ===
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: LivingRoomScene(
                      tankId: currentTank.id,
                      tankName: currentTank.name,
                      tankVolume: currentTank.volumeLitres,
                      theme: ref.watch(currentRoomThemeProvider),
                      isNewUser: _isNewUser(ref),
                      useRiveFish: false,
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
                ],
              ),
            ),

            // === 4. Daily goal progress below scene ===
            profileAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (profile) {
                if (profile == null) return const SizedBox.shrink();
                final todayXp = dailyGoal?.earnedXp ?? 0;
                final goalXp = profile.dailyXpGoal;
                final progress = goalXp > 0 ? (todayXp / goalXp).clamp(0.0, 1.0) : 0.0;
                final percentage = (progress * 100).round();
                final isComplete = progress >= 1.0;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('📈', style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                'Daily Goal: $todayXp/$goalXp XP',
                                style: AppTypography.labelMedium.copyWith(
                                  color: isComplete ? AppColors.success : AppColors.textPrimary,
                                  fontWeight: isComplete ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (isComplete)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppOverlays.success20,
                                    borderRadius: AppRadius.smallRadius,
                                  ),
                                  child: Text('✓ Done!', style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                                )
                              else
                                Text('$percentage%', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: AppRadius.xsRadius,
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isComplete ? AppColors.success : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // === 5. Tank switcher + content below ===
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Column(
                      children: [
                        // Tank switcher
                        if (!_isSelectMode)
                          Padding(
                            padding: const EdgeInsets.only(right: 72), // Room for FAB
                            child: TankSwitcher(
                              tanks: tanks,
                              currentIndex: _currentTankIndex,
                              onChanged: (index) {
                                setState(() => _currentTankIndex = index);
                              },
                              onAddTank: () => _navigateToCreateTank(context),
                              onLongPress: tanks.length > 1 ? _toggleSelectMode : null,
                            ),
                          ),

                        // Selection mode UI
                        if (_isSelectMode)
                          SelectionModePanel(
                            tanks: tanks,
                            selectedIds: _selectedTankIds,
                            onToggleSelection: _toggleTankSelection,
                            onCancel: _toggleSelectMode,
                            onDeleteSelected: () => _bulkDelete(context, tanks),
                            onExportSelected: () => _bulkExport(context, tanks),
                          ),
                      ],
                    ),
                  ),

                  // Speed Dial FAB
                  Positioned(
                    top: 0,
                    right: 16,
                    child: SpeedDialFAB(
                      closedIcon: Icons.water_drop_rounded,
                      openIcon: Icons.close_rounded,
                      actions: [
                        SpeedDialAction(
                          icon: Icons.add_rounded,
                          label: 'Add Tank',
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          onPressed: () => _navigateToCreateTank(context),
                        ),
                        SpeedDialAction(
                          icon: Icons.restaurant_rounded,
                          label: 'Feed',
                          backgroundColor: const Color(0xFFFFF3E0),
                          foregroundColor: const Color(0xFFE65100),
                          onPressed: () => _showFeedingInfo(context),
                        ),
                        SpeedDialAction(
                          icon: Icons.science_rounded,
                          label: 'Quick Test',
                          backgroundColor: const Color(0xFFE8F5E9),
                          foregroundColor: const Color(0xFF2E7D32),
                          onPressed: () => _navigateToQuickTest(context, currentTank),
                        ),
                        SpeedDialAction(
                          icon: Icons.water_drop_rounded,
                          label: 'Water Change',
                          backgroundColor: const Color(0xFFE3F2FD),
                          foregroundColor: const Color(0xFF1565C0),
                          onPressed: () =>
                              _navigateToWaterChange(context, currentTank),
                        ),
                        SpeedDialAction(
                          icon: Icons.insights_rounded,
                          label: 'Stats',
                          backgroundColor: const Color(0xFFF3E5F5),
                          foregroundColor: const Color(0xFF7B1FA2),
                          onPressed: () => _showStatsInfo(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // HomeScreen is the Living Room - it shows tank management only.
    // Navigation to other rooms (Learn, Workshop, Shop, etc.) is handled
    // by HouseNavigator's swipe/tab system, not a BottomNavigationBar here.
    // Note: FAB is handled inside _buildLivingRoomScreen() Stack, not here
    return Scaffold(
      body: _buildLivingRoomScreen(),
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
    Navigator.of(context).push(
      ModalScaleRoute(
        page: AddLogScreen(tankId: tank.id, initialType: LogType.waterTest),
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
    final profile = ref.watch(userProfileProvider).value;
    if (profile == null) return true;
    // Consider user "new" if they haven't completed the tutorial yet
    return !profile.hasSeenTutorial;
  }

  void _showRoomSwitcher(BuildContext context) {
    final rooms = [
      ('Study', Icons.auto_stories, '📚', 0),
      ('Living Room', Icons.weekend, '🛋️', 1),
      ('Friends', Icons.people, '👥', 2),
      ('Leaderboard', Icons.leaderboard, '🏆', 3),
      ('Workshop', Icons.build, '🔧', 4),
      ('Shop Street', Icons.storefront, '🏪', 5),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Switch Room', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            ...rooms.map((room) {
              final currentRoom = ref.watch(currentRoomProvider);
              final isSelected = room.$4 == currentRoom;
              return ListTile(
                leading: Text(room.$3, style: const TextStyle(fontSize: 24)),
                title: Text(room.$1),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  if (!isSelected) {
                    // Navigate to selected room
                    ref.read(currentRoomProvider.notifier).state = room.$4;
                    HapticFeedback.selectionClick();
                  }
                },
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _showStatsInfo(BuildContext context) {
    _showItemSheet(
      context,
      title: 'Tank Stats',
      icon: Icons.auto_graph,
      color: const Color(0xFFBA68C8),
      rows: [
        const ItemDetailRow(label: 'Temperature', value: '-- °C'),
        const ItemDetailRow(label: 'Last fed', value: '--'),
        const ItemDetailRow(label: 'Water change', value: 'Due soon'),
      ],
    );
  }

  void _showWaterParams(BuildContext context) {
    _showItemSheet(
      context,
      title: 'Water Tests',
      icon: Icons.science,
      color: AppColors.primary,
      rows: [
        const ItemDetailRow(label: 'pH', value: '--'),
        const ItemDetailRow(label: 'Ammonia', value: '-- ppm'),
        const ItemDetailRow(label: 'Nitrite', value: '-- ppm'),
        const ItemDetailRow(label: 'Nitrate', value: '-- ppm'),
        const ItemDetailRow(
          label: 'Last tested',
          value: 'Tap tank for details',
        ),
      ],
    );
  }

  void _showFeedingInfo(BuildContext context) {
    _showItemSheet(
      context,
      title: 'Fish Food',
      icon: Icons.restaurant,
      color: AppColors.secondary,
      rows: [
        const ItemDetailRow(label: 'Type', value: 'Tropical Flakes'),
        const ItemDetailRow(label: 'Last fed', value: '--'),
        const ItemDetailRow(label: 'Schedule', value: '2x daily'),
      ],
    );
  }

  void _showPlantInfo(BuildContext context) {
    _showItemSheet(
      context,
      title: 'Houseplants',
      icon: Icons.eco,
      color: const Color(0xFF4CAF50),
      rows: [
        const ItemDetailRow(label: 'Monstera', value: 'Happy 🌿'),
        const ItemDetailRow(label: 'Pothos', value: 'Thriving'),
        const ItemDetailRow(label: 'Tip', value: 'Use old tank water!'),
      ],
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg2),
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
                      padding: const EdgeInsets.all(AppSpacing.sm2),
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
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            theme.description,
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 9,
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
        margin: const EdgeInsets.all(AppSpacing.md),
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
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg2),
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
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg2),
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
        ).showSnackBar(const SnackBar(content: Text('No tanks selected')));
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
            content: Text('Failed to delete tanks. Please try again.'),
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
        ).showSnackBar(const SnackBar(content: Text('No tanks selected')));
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

  String _formatXp(int number) {
    if (number >= 10000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

/// Compact stat for the top stats bar
class _CompactStat extends StatelessWidget {
  final String icon;
  final String value;
  final Color color;

  const _CompactStat({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Compact hearts display for the top stats bar
class _CompactHearts extends StatelessWidget {
  final int current;
  final int max;

  const _CompactHearts({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        return Padding(
          padding: const EdgeInsets.only(right: 1),
          child: Text(
            i < current ? '❤️' : '🤍',
            style: const TextStyle(fontSize: 14),
          ),
        );
      }),
    );
  }
}
