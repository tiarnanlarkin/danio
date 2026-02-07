import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../providers/room_theme_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../theme/room_themes.dart';
import '../widgets/decorative_elements.dart';
import '../widgets/hobby_items.dart';
import '../widgets/hobby_desk.dart';
import '../widgets/room_scene.dart';
import '../widgets/speed_dial_fab.dart';
import '../widgets/daily_goal_progress.dart';
import '../widgets/streak_display.dart';
import '../widgets/streak_calendar.dart';
import '../widgets/error_state.dart';
import 'create_tank_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'tank_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTankIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tanksAsync = ref.watch(tanksProvider);

    return Scaffold(
      body: tanksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Living Room',
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.white.withOpacity(0.9)),
                        tooltip: 'Search',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_outlined, color: Colors.white.withOpacity(0.9)),
                        tooltip: 'Settings',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tank switcher - clean card between tank and graph
              Positioned(
                bottom: 240, // Between tank illustration and wave graph
                left: 16,
                right: 80, // Leave room for speed dial
                child: _TankSwitcher(
                  tanks: tanks,
                  currentIndex: _currentTankIndex,
                  onChanged: (index) {
                    setState(() => _currentTankIndex = index);
                  },
                  onAddTank: () => _navigateToCreateTank(context),
                ),
              ),

              // Learning Progress Cards
              Positioned(
                bottom: 80,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DailyGoalCard(
                            onTap: () => _showDailyGoalDetails(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StreakCard(
                            onTap: () => _showStreakCalendar(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Speed Dial FAB - radial menu for quick actions
              Positioned(
                bottom: 230,
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
                      label: 'Test',
                      backgroundColor: const Color(0xFFE8F5E9),
                      foregroundColor: const Color(0xFF2E7D32),
                      onPressed: () => _showWaterParams(context),
                    ),
                    SpeedDialAction(
                      icon: Icons.water_drop_rounded,
                      label: 'Water',
                      backgroundColor: const Color(0xFFE3F2FD),
                      foregroundColor: const Color(0xFF1565C0),
                      onPressed: () => _showPlantInfo(context),
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
      ),
      // FAB removed - add button integrated into tank switcher for cleaner UX
    );
  }

  void _navigateToCreateTank(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateTankScreen()),
    );
  }

  void _navigateToTankDetail(BuildContext context, Tank tank) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TankDetailScreen(tankId: tank.id),
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
        const ItemDetailRow(label: 'Last tested', value: 'Tap tank for details'),
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
          borderRadius: BorderRadius.circular(24),
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
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.accentBlob : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.background1,
                          theme.background2,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(radius: 8, backgroundColor: theme.accentBlob),
                            const SizedBox(width: 4),
                            CircleAvatar(radius: 8, backgroundColor: theme.waterMid),
                            const SizedBox(width: 4),
                            CircleAvatar(radius: 8, backgroundColor: theme.plantPrimary),
                          ],
                        ),
                        const SizedBox(height: 8),
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
            const SizedBox(height: 16),
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
          borderRadius: BorderRadius.circular(24),
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
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const DailyGoalProgress(size: 120),
            const SizedBox(height: 20),
            Text(
              'Ways to earn XP:',
              style: AppTypography.labelLarge,
            ),
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
      MaterialPageRoute(builder: (_) => const StreakCalendarScreen()),
    );
  }
}

class _TankSwitcher extends StatelessWidget {
  final List<Tank> tanks;
  final int currentIndex;
  final Function(int) onChanged;
  final VoidCallback onAddTank;

  const _TankSwitcher({
    required this.tanks,
    required this.currentIndex,
    required this.onChanged,
    required this.onAddTank,
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasMultipleTanks ? () => _showTankPicker(context) : null,
          borderRadius: BorderRadius.circular(16),
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
                    borderRadius: BorderRadius.circular(10),
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

class _TankPickerSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
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
                TextButton.icon(
                  onPressed: onAddTank,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          
          // Tank list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: tanks.length,
              itemBuilder: (context, index) {
                final tank = tanks[index];
                final isSelected = index == currentIndex;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected 
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: ListTile(
                    onTap: () => onSelected(index),
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
                        borderRadius: BorderRadius.circular(12),
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
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${tank.volumeLitres.toStringAsFixed(0)}L • ${tank.type.name}',
                      style: AppTypography.bodySmall,
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
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
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
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

class _EmptyRoomScene extends StatelessWidget {
  final VoidCallback onCreateTank;
  final VoidCallback onLoadDemo;

  const _EmptyRoomScene({
    required this.onCreateTank,
    required this.onLoadDemo,
  });

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
              colors: [
                Color(0xFFF5EDE3),
                Color(0xFFEDE5DA),
              ],
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
              borderRadius: BorderRadius.circular(4),
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
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
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
              borderRadius: BorderRadius.circular(8),
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
                const SizedBox(height: 8),
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  Container(
                    width: 25,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCD853F).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
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
                Text(
                  '🐠 Welcome!',
                  style: AppTypography.headlineSmall,
                ),
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
                const SizedBox(height: 8),
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
