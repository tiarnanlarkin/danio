import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_elements.dart';
import '../widgets/hobby_items.dart';
import '../widgets/hobby_desk.dart';
import '../widgets/room_scene.dart';
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
        error: (err, stack) => Center(
          child: NotebookCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Something went wrong', style: AppTypography.bodyLarge),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(tanksProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
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
                  onTankTap: () => _navigateToTankDetail(context, currentTank),
                  onThermometerTap: () => _showTemperatureDetail(context),
                  onTestKitTap: () => _showWaterParams(context),
                  onFoodTap: () => _showFeedingInfo(context),
                  onBookTap: () => _showGuideInfo(context),
                  onTeaTap: () => _showRelaxMessage(context),
                  onPlantTap: () => _showPlantInfo(context),
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
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_outlined, color: Colors.white.withOpacity(0.9)),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tank switcher (if multiple tanks)
              if (tanks.length > 1)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: _TankSwitcher(
                    tanks: tanks,
                    currentIndex: _currentTankIndex,
                    onChanged: (index) {
                      setState(() => _currentTankIndex = index);
                    },
                  ),
                ),

              // Bottom hint
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tap items to interact',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTank(context),
        tooltip: 'Add Tank',
        child: const Icon(Icons.add),
      ),
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

  void _showTemperatureDetail(BuildContext context) {
    _showItemSheet(
      context,
      title: 'Temperature',
      icon: Icons.thermostat,
      color: AppColors.warning,
      rows: [
        const ItemDetailRow(label: 'Current', value: '-- °C'),
        const ItemDetailRow(label: 'Target', value: '25 °C'),
        const ItemDetailRow(label: 'Heater', value: 'On', color: AppColors.success),
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

  void _showGuideInfo(BuildContext context) {
    _showItemSheet(
      context,
      title: 'Fishkeeping Guide',
      icon: Icons.menu_book,
      color: const Color(0xFF8B4513),
      rows: [
        const ItemDetailRow(label: 'Topic', value: 'Water Chemistry'),
        const ItemDetailRow(label: 'Tip', value: 'Test weekly!'),
        const ItemDetailRow(label: 'Reading', value: 'Nitrogen Cycle basics'),
      ],
    );
  }

  void _showRelaxMessage(BuildContext context) {
    _showItemSheet(
      context,
      title: '☕ Tea Time',
      icon: Icons.coffee,
      color: const Color(0xFFCD853F),
      rows: [
        const ItemDetailRow(label: 'Mood', value: 'Relaxing 🧘'),
        const ItemDetailRow(label: 'Activity', value: 'Watching fish'),
        const ItemDetailRow(label: 'Stress', value: '-50%', color: AppColors.success),
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
}

class _TankSwitcher extends StatelessWidget {
  final List<Tank> tanks;
  final int currentIndex;
  final Function(int) onChanged;

  const _TankSwitcher({
    required this.tanks,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white70),
            onPressed: currentIndex > 0
                ? () => onChanged(currentIndex - 1)
                : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                tanks[currentIndex].name,
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
            onPressed: currentIndex < tanks.length - 1
                ? () => onChanged(currentIndex + 1)
                : null,
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
