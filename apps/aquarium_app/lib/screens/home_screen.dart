import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_elements.dart';
import '../widgets/hobby_items.dart';
import '../widgets/hobby_desk.dart';
import 'create_tank_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'tank_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tanksAsync = ref.watch(tanksProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Room background with more elements
          const _RoomBackground(),
          
          // Main content
          CustomScrollView(
            slivers: [
              // Simple app bar
              SliverAppBar(
                expandedHeight: 80,
                floating: true,
                pinned: true,
                backgroundColor: AppColors.background.withOpacity(0.9),
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'My Fish Room',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
                ),
              ),
              
              // Content
              tanksAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(
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
                ),
                data: (tanks) {
                  if (tanks.isEmpty) {
                    return SliverFillRemaining(
                      child: _EmptyRoom(
                        onCreateTank: () => _navigateToCreateTank(context),
                        onLoadDemo: () async {
                          final actions = ref.read(tankActionsProvider);
                          final demoTank = await actions.seedDemoTankIfEmpty();
                          if (context.mounted) {
                            _navigateToTankDetail(context, demoTank);
                          }
                        },
                      ),
                    );
                  }
                  
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: _FishRoomView(
                        tanks: tanks,
                        onTankTap: (tank) => _navigateToTankDetail(context, tank),
                      ),
                    ),
                  );
                },
              ),
              
              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateTank(context),
        icon: const Icon(Icons.add),
        label: const Text('New Tank'),
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
}

/// Room background with window, plants, and decorative items
class _RoomBackground extends StatelessWidget {
  const _RoomBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base wall color
        Container(color: AppColors.background),
        
        // Window on the wall
        const Positioned(
          top: 60,
          right: 20,
          child: Opacity(
            opacity: 0.5,
            child: WindowDecoration(width: 70, height: 90),
          ),
        ),
        
        // Soft blobs
        Positioned(
          top: -30,
          left: -40,
          child: SoftBlob(size: 150, color: AppColors.primary, seed: 1),
        ),
        Positioned(
          bottom: 150,
          right: -50,
          child: SoftBlob(size: 120, color: AppColors.secondary, seed: 2),
        ),
        
        // Floor area
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  const Color(0xFFE8DDD0),
                ],
              ),
            ),
          ),
        ),
        
        // Plants in corners
        Positioned(
          bottom: 0,
          left: 0,
          child: PlantDecoration(height: 120, color: AppColors.success),
        ),
        Positioned(
          bottom: 0,
          right: 8,
          child: PlantDecoration(height: 90, color: AppColors.primary, flip: true),
        ),
      ],
    );
  }
}

/// Main fish room view showing tanks on shelves and hobby items
class _FishRoomView extends StatelessWidget {
  final List<Tank> tanks;
  final Function(Tank) onTankTap;

  const _FishRoomView({required this.tanks, required this.onTankTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shelf unit with tanks
        _ShelfUnit(tanks: tanks, onTankTap: onTankTap),
        
        const SizedBox(height: 24),
        
        // Hobby desk with equipment
        Text(
          'My Equipment',
          style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        
        HobbyDesk(
          filterMedia: ['sponge', 'ceramic', 'carbon'],
          filterRunning: true,
          heaterOn: true,
          lightOn: true,
          onItemTap: (item) {
            _showItemDetail(context, item);
          },
        ),
        
        const SizedBox(height: 24),
        
        // Scattered hobby items
        Text(
          'Around the Room',
          style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        
        _ScatteredItems(),
      ],
    );
  }

  void _showItemDetail(BuildContext context, String item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        child: ItemDetailPopup(
          title: _getItemTitle(item),
          icon: _getItemIcon(item),
          accentColor: _getItemColor(item),
          rows: _getItemRows(item),
          onClose: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  String _getItemTitle(String item) {
    switch (item) {
      case 'filter': return 'Canister Filter';
      case 'heater': return 'Aquarium Heater';
      case 'temperature': return 'Temperature';
      case 'light': return 'LED Light';
      case 'tests': return 'Water Tests';
      case 'food': return 'Fish Food';
      default: return item;
    }
  }

  IconData _getItemIcon(String item) {
    switch (item) {
      case 'filter': return Icons.filter_alt;
      case 'heater': return Icons.whatshot;
      case 'temperature': return Icons.thermostat;
      case 'light': return Icons.lightbulb;
      case 'tests': return Icons.science;
      case 'food': return Icons.restaurant;
      default: return Icons.info;
    }
  }

  Color _getItemColor(String item) {
    switch (item) {
      case 'filter': return AppColors.info;
      case 'heater': return AppColors.error;
      case 'temperature': return AppColors.warning;
      case 'light': return Colors.amber;
      case 'tests': return AppColors.primary;
      case 'food': return AppColors.secondary;
      default: return AppColors.primary;
    }
  }

  List<ItemDetailRow> _getItemRows(String item) {
    switch (item) {
      case 'filter':
        return [
          const ItemDetailRow(label: 'Status', value: 'Running', color: AppColors.success),
          const ItemDetailRow(label: 'Flow Rate', value: '800 L/h'),
          const ItemDetailRow(label: 'Media', value: 'Sponge, Ceramic, Carbon'),
          const ItemDetailRow(label: 'Last Cleaned', value: '2 weeks ago'),
        ];
      case 'heater':
        return [
          const ItemDetailRow(label: 'Status', value: 'Heating', color: AppColors.warning),
          const ItemDetailRow(label: 'Set Temp', value: '25°C'),
          const ItemDetailRow(label: 'Power', value: '100W'),
        ];
      case 'tests':
        return [
          const ItemDetailRow(label: 'pH', value: '7.2', color: AppColors.success),
          const ItemDetailRow(label: 'Ammonia', value: '0 ppm', color: AppColors.success),
          const ItemDetailRow(label: 'Nitrite', value: '0 ppm', color: AppColors.success),
          const ItemDetailRow(label: 'Nitrate', value: '15 ppm', color: AppColors.success),
          const ItemDetailRow(label: 'Last Test', value: '2 days ago'),
        ];
      default:
        return [const ItemDetailRow(label: 'Tap for details', value: '→')];
    }
  }
}

/// Shelf unit displaying tanks
class _ShelfUnit extends StatelessWidget {
  final List<Tank> tanks;
  final Function(Tank) onTankTap;

  const _ShelfUnit({required this.tanks, required this.onTankTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFC49A6C).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4A574).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.shelves, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Tank Shelf',
                style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${tanks.length} tank${tanks.length == 1 ? '' : 's'}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Tanks in a horizontal scroll
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tanks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (ctx, i) {
                final tank = tanks[i];
                return MiniTankScene(
                  name: tank.name,
                  volumeLitres: tank.volumeLitres,
                  width: 140,
                  onTap: () => onTankTap(tank),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Random scattered hobby items for visual interest
class _ScatteredItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // More notebook cards with stats
        NotebookCard(
          rotation: -1.5,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📋 Maintenance', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              Text('Water change: 3 days ago', style: AppTypography.bodySmall),
              Text('Filter clean: 2 weeks ago', style: AppTypography.bodySmall),
            ],
          ),
        ),
        
        NotebookCard(
          rotation: 2,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🐟 Fish Count', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              Text('Total: -- fish', style: AppTypography.bodySmall),
              Text('Species: -- types', style: AppTypography.bodySmall),
            ],
          ),
        ),
        
        // Tablet showing quick stats
        TabletCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Stats', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatBubble(value: '--', label: '°C', size: 45, color: AppColors.info),
                  const SizedBox(width: 8),
                  StatBubble(value: '--', label: 'pH', size: 45, color: AppColors.success),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Empty room when no tanks exist
class _EmptyRoom extends StatelessWidget {
  final VoidCallback onCreateTank;
  final VoidCallback onLoadDemo;

  const _EmptyRoom({required this.onCreateTank, required this.onLoadDemo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty shelf
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFC49A6C).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4A574).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textHint.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.water_drop_outlined,
                    size: 40,
                    color: AppColors.textHint.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  width: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A574),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          NotebookCard(
            rotation: 1.5,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Your fish room is empty!',
                  style: AppTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Add your first tank to start tracking your aquarium hobby.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onCreateTank,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Tank'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onLoadDemo,
                  child: const Text('Load sample tank'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Scattered empty items
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.4,
                child: BucketItem(fillLevel: 0, height: 40),
              ),
              const SizedBox(width: 16),
              Opacity(
                opacity: 0.4,
                child: NetItem(size: 30),
              ),
              const SizedBox(width: 16),
              Opacity(
                opacity: 0.4,
                child: FoodJarItem(fillLevel: 0.2, height: 45),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
