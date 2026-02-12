import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../providers/room_theme_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/core/bubble_loader.dart';
import 'house_navigator.dart';
import '../theme/room_themes.dart';
import '../widgets/decorative_elements.dart';
import '../widgets/hobby_items.dart';
import '../widgets/hobby_desk.dart';
import '../widgets/room_scene.dart';
import '../widgets/speed_dial_fab.dart';
import '../widgets/daily_goal_progress.dart';
import '../widgets/streak_calendar.dart';
import '../widgets/error_state.dart';
import '../widgets/hearts_widgets.dart';
import '../widgets/gamification_dashboard.dart';
import '../utils/app_feedback.dart';
import 'add_log_screen.dart';
import 'create_tank_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'tank_detail_screen.dart';
import '../utils/app_page_routes.dart';

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

  Widget _buildLivingRoomScreen() {
    final tanksAsync = ref.watch(tanksProvider);

    return tanksAsync.when(
      loading: () => const Center(child: BubbleLoader.large(message: 'Loading tanks...')),
      error: (err, stack) => ErrorState(
        message: 'Failed to load tanks',
        details: 'Please check your connection and try again',
        onRetry: () => ref.invalidate(tanksProvider),
      ),
      data: (tanks) {
        if (tanks.isEmpty) {
          return _EmptyRoomScene(
            onCreateTank: () => _navigateToCreateTank(context),
            onLoadDemo: () async {
              final actions = ref.read(tankActionsProvider);
              final demoTank = await actions.seedDemoTankIfEmpty();
              if (context.mounted) {
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
                tankName: currentTank.name,
                tankVolume: currentTank.volumeLitres,
                theme: ref.watch(currentRoomThemeProvider),
                onTankTap: () => _navigateToTankDetail(context, currentTank),
                onTestKitTap: () => _showWaterParams(context),
                onFoodTap: () => _showFeedingInfo(context),
                onPlantTap: () => _showPlantInfo(context),
                onStatsTap: () => _showStatsInfo(context),
                onThemeTap: () => _showThemePicker(context, ref),
              ),
            ),

            // Top bar overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 8,
                  bottom: 8,
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
                    GestureDetector(
                      onTap: () => _showRoomSwitcher(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Living Room',
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: AppOverlays.black50,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppOverlays.white70,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Hearts indicator
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: HeartIndicator(compact: true),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: AppOverlays.white90,
                      ),
                      tooltip: 'Search',
                      onPressed: () => Navigator.push(
                        context,
                        RoomSlideRoute(page: const SearchScreen()),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: AppOverlays.white90,
                      ),
                      tooltip: 'Settings',
                      onPressed: () => Navigator.push(
                        context,
                        RoomSlideRoute(page: const SettingsScreen()),
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
                    child: _TankSwitcher(
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
                    child: _SelectionModePanel(
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
            // Positioned above the dashboard with safe area padding
            Positioned(
              bottom: 170 + MediaQuery.of(context).padding.bottom,
              right: 16,
              child: SpeedDialFAB(
                closedIcon: Icons.water_drop_rounded,
                openIcon: Icons.close_rounded,
                actions: [
                  SpeedDialAction(
                    icon: Icons.add_rounded,
                    label: 'Add Tank',
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
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
                const Icon(Icons.palette, size: 24),
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
                      padding: const EdgeInsets.all(12),
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
        margin: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
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
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(ctx),
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
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
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
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const DailyGoalProgress(size: 120),
            const SizedBox(height: 20),
            Text('Ways to earn XP:', style: AppTypography.labelLarge),
            const SizedBox(height: 12),
            _XpSourceRow(icon: Icons.school, label: 'Complete lesson', xp: 50),
            _XpSourceRow(icon: Icons.quiz, label: 'Pass quiz', xp: 25),
            _XpSourceRow(icon: Icons.science, label: 'Log water test', xp: 10),
            _XpSourceRow(icon: Icons.water_drop, label: 'Water change', xp: 10),
            _XpSourceRow(icon: Icons.task_alt, label: 'Complete task', xp: 15),
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

    // TODO: Implement actual export functionality
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export feature coming soon!')),
      );
    }
  }

  /// Quick-add floating action button for fast parameter logging
  Widget _buildQuickAddFAB() {
    final tanksAsync = ref.watch(tanksProvider);

    return tanksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (tanks) {
        if (tanks.isEmpty) return const SizedBox.shrink();

        final currentTank = tanks.length > _currentTankIndex
            ? tanks[_currentTankIndex]
            : tanks.first;

        return SpeedDialFAB(
          closedIcon: Icons.add_rounded,
          openIcon: Icons.close_rounded,
          actions: [
            SpeedDialAction(
              icon: Icons.water_drop,
              label: 'Log Parameters',
              onPressed: () {
                Navigator.push(
                  context,
                  ModalScaleRoute(
                    page: AddLogScreen(
                      tankId: currentTank.id,
                      initialType: LogType.waterTest,
                    ),
                  ),
                );
              },
            ),
            SpeedDialAction(
              icon: Icons.note_add,
              label: 'Quick Note',
              onPressed: () {
                Navigator.push(
                  context,
                  ModalScaleRoute(
                    page: AddLogScreen(
                      tankId: currentTank.id,
                      initialType: LogType.observation,
                    ),
                  ),
                );
              },
            ),
            SpeedDialAction(
              icon: Icons.add_circle_outline,
              label: 'Add Tank',
              onPressed: () => _navigateToCreateTank(context),
            ),
          ],
        );
      },
    );
  }
}

class _TankSwitcher extends StatelessWidget {
  final List<Tank> tanks;
  final int currentIndex;
  final Function(int) onChanged;
  final VoidCallback onAddTank;
  final VoidCallback? onLongPress;

  const _TankSwitcher({
    required this.tanks,
    required this.currentIndex,
    required this.onChanged,
    required this.onAddTank,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final hasMultipleTanks = tanks.length > 1;

    // Clean card-only design - tap to open picker
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.88),
          ],
        ),
        borderRadius: AppRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppOverlays.white60, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasMultipleTanks ? () => _showTankPicker(context) : null,
          onLongPress: onLongPress,
          borderRadius: AppRadius.mediumRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Fish icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: const Icon(
                    Icons.set_meal_rounded, // Fish icon
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Tank info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tanks[currentIndex].name,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${tanks[currentIndex].volumeLitres.toStringAsFixed(0)}L${hasMultipleTanks ? ' • ${currentIndex + 1}/${tanks.length}' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Picker indicator (only if multiple tanks)
                if (hasMultipleTanks)
                  Icon(
                    Icons.unfold_more_rounded,
                    color: AppColors.textHint,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTankPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _TankPickerSheet(
        tanks: tanks,
        currentIndex: currentIndex,
        onSelected: (index) {
          onChanged(index);
          Navigator.pop(ctx);
        },
        onAddTank: () {
          Navigator.pop(ctx);
          onAddTank();
        },
      ),
    );
  }
}

class _TankPickerSheet extends ConsumerStatefulWidget {
  final List<Tank> tanks;
  final int currentIndex;
  final Function(int) onSelected;
  final VoidCallback onAddTank;

  const _TankPickerSheet({
    required this.tanks,
    required this.currentIndex,
    required this.onSelected,
    required this.onAddTank,
  });

  @override
  ConsumerState<_TankPickerSheet> createState() => _TankPickerSheetState();
}

class _TankPickerSheetState extends ConsumerState<_TankPickerSheet> {
  late List<Tank> _tanks;
  bool _hasReordered = false;

  @override
  void initState() {
    super.initState();
    _tanks = List.from(widget.tanks);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: AppRadius.largeRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.water_drop, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('Your Tanks', style: AppTypography.headlineSmall),
                const Spacer(),
                if (_hasReordered)
                  TextButton.icon(
                    onPressed: _saveOrder,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Save'),
                  )
                else
                  TextButton.icon(
                    onPressed: widget.onAddTank,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
              ],
            ),
          ),

          // Tank list (reorderable)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _tanks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  _hasReordered = true;
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final tank = _tanks.removeAt(oldIndex);
                  _tanks.insert(newIndex, tank);
                });
              },
              itemBuilder: (context, index) {
                final tank = _tanks[index];
                final isSelected =
                    tank.id == widget.tanks[widget.currentIndex].id;

                return Container(
                  key: ValueKey(tank.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: AppRadius.mediumRadius,
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: ListTile(
                    onTap: () => widget.onSelected(_tanks.indexOf(tank)),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.white,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Icon(
                        Icons.water,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      tank.name,
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${tank.volumeLitres.toStringAsFixed(0)}L • ${tank.type.name}',
                      style: AppTypography.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Icon(Icons.check_circle, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(Icons.drag_handle, color: AppColors.textHint),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Hint
          if (_hasReordered)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.info),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tap "Save" to keep this order',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Future<void> _saveOrder() async {
    try {
      final actions = ref.read(tankActionsProvider);
      await actions.reorderTanks(_tanks);

      if (mounted) {
        Navigator.pop(context);
        AppFeedback.showSuccess(context, 'Tank order saved');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Failed to save order. Please try again.',
        );
      }
    }
  }
}

class _XpSourceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int xp;

  const _XpSourceRow({
    required this.icon,
    required this.label,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Text(
              '+$xp XP',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionModePanel extends StatelessWidget {
  final List<Tank> tanks;
  final Set<String> selectedIds;
  final Function(String) onToggleSelection;
  final VoidCallback onCancel;
  final VoidCallback onDeleteSelected;
  final VoidCallback onExportSelected;

  const _SelectionModePanel({
    required this.tanks,
    required this.selectedIds,
    required this.onToggleSelection,
    required this.onCancel,
    required this.onDeleteSelected,
    required this.onExportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tank selection list
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: AppRadius.mediumRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppOverlays.white60,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.checklist, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Select Tanks',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${selectedIds.length} selected',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: 'Cancel selection',
                      onPressed: onCancel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Tank list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tanks.length,
                  itemBuilder: (context, index) {
                    final tank = tanks[index];
                    final isSelected = selectedIds.contains(tank.id);

                    return ListTile(
                      onTap: () => onToggleSelection(tank.id),
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (_) => onToggleSelection(tank.id),
                      ),
                      title: Text(
                        tank.name,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${tank.volumeLitres.toStringAsFixed(0)}L • ${tank.type.name}',
                        style: AppTypography.bodySmall,
                      ),
                      trailing: Icon(
                        Icons.water,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textHint,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: selectedIds.isEmpty ? null : onDeleteSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mediumRadius,
                  ),
                ),
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Delete'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: selectedIds.isEmpty ? null : onExportSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mediumRadius,
                  ),
                ),
                icon: const Icon(Icons.file_download_outlined, size: 20),
                label: const Text('Export'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyRoomScene extends StatelessWidget {
  final VoidCallback onCreateTank;
  final VoidCallback onLoadDemo;

  const _EmptyRoomScene({required this.onCreateTank, required this.onLoadDemo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Empty room background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5EDE3), Color(0xFFEDE5DA)],
            ),
          ),
        ),

        // Window
        Positioned(
          top: 80,
          right: 30,
          child: Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF87CEEB), Color(0xFFB8E0F0)],
              ),
              border: Border.all(color: const Color(0xFF8B7355), width: 6),
              borderRadius: AppRadius.xsRadius,
            ),
          ),
        ),

        // Floor
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD4A574), Color(0xFFC49664)],
              ),
            ),
          ),
        ),

        // Empty stand where tank should go
        Positioned(
          bottom: 100,
          left: 40,
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D4037), Color(0xFF4E342E)],
              ),
              borderRadius: AppRadius.xsRadius,
              boxShadow: [
                BoxShadow(
                  color: AppOverlays.black30,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),

        // "Tank goes here" placeholder
        Positioned(
          bottom: 160,
          left: 50,
          child: Container(
            width: 180,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: AppRadius.smallRadius,
              border: Border.all(
                color: AppColors.textHint.withOpacity(0.5),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 40,
                  color: AppColors.textHint.withOpacity(0.5),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your tank here',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floor plant (waiting)
        Positioned(
          bottom: 80,
          right: 20,
          child: Opacity(
            opacity: 0.5,
            child: Container(
              width: 40,
              height: 80,
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF228B22).withOpacity(0.5),
                      borderRadius: AppRadius.mediumRadius,
                    ),
                  ),
                  Container(
                    width: 25,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCD853F).withOpacity(0.5),
                      borderRadius: AppRadius.xsRadius,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Call to action
        Center(
          child: NotebookCard(
            rotation: 1.5,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🐠 Welcome!', style: AppTypography.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  'This room is waiting for\nyour first aquarium.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onCreateTank,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Your Tank'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: onLoadDemo,
                  child: const Text('Try a sample tank'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
