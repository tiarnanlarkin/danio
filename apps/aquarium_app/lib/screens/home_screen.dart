import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_elements.dart';
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
          // Cozy background with plants and blobs
          const CozyRoomBackground(
            showPlants: true,
            showBlobs: true,
            child: SizedBox.expand(),
          ),
          
          // Main content
          CustomScrollView(
            slivers: [
              // App bar with window decoration hint
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
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
                    'My Aquariums',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  background: Stack(
                    children: [
                      // Soft gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primaryLight.withOpacity(0.3),
                              AppColors.background.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                      // Window decoration in corner
                      const Positioned(
                        top: 40,
                        right: 60,
                        child: Opacity(
                          opacity: 0.4,
                          child: WindowDecoration(width: 60, height: 80),
                        ),
                      ),
                    ],
                  ),
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
                      child: _EmptyState(
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
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tank = tanks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _CozyTankCard(
                              tank: tank,
                              onTap: () => _navigateToTankDetail(context, tank),
                            ),
                          );
                        },
                        childCount: tanks.length,
                      ),
                    ),
                  );
                },
              ),
              
              // Bottom padding for FAB
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
        ],
      ),
      
      // FAB to add new tank
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateTank(context),
        tooltip: 'Add Tank',
        icon: const Icon(Icons.add),
        label: const Text('Add Tank'),
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

/// Tank card styled like it's sitting on a shelf in a cozy room
class _CozyTankCard extends StatelessWidget {
  final Tank tank;
  final VoidCallback onTap;

  const _CozyTankCard({required this.tank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Tank on shelf
          ShelfDecoration(
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                // Glass tank effect
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.4),
                    AppColors.primaryDark.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Water wave effect at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: WaterWave(
                      height: 30,
                      color: AppColors.primary,
                    ),
                  ),
                  // Tank name overlay
                  Positioned(
                    bottom: 8,
                    left: 12,
                    right: 12,
                    child: Text(
                      tank.name,
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Volume badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tank.volumeLitres.toStringAsFixed(0)}L',
                        style: AppTypography.labelSmall.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Info notebook below shelf
          NotebookCard(
            rotation: -0.5,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                StatBubble(
                  value: '—',
                  label: '°C',
                  color: AppColors.info,
                  size: 50,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tank.name,
                        style: AppTypography.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to view details',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTank;
  final VoidCallback onLoadDemo;

  const _EmptyState({required this.onCreateTank, required this.onLoadDemo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty shelf illustration
          ShelfDecoration(
            child: Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.textHint.withOpacity(0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.water_drop_outlined,
                  size: 48,
                  color: AppColors.textHint.withOpacity(0.5),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Notebook with instructions
          NotebookCard(
            rotation: 1,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Your shelf is empty!',
                  style: AppTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Add your first aquarium to start tracking water parameters, livestock, and maintenance.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                ElevatedButton.icon(
                  onPressed: onCreateTank,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Your First Tank'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onLoadDemo,
                  child: const Text('Load a sample tank'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
