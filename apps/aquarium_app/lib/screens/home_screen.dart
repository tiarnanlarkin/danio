import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/tank_card.dart';
import 'create_tank_screen.dart';
import 'tank_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tanksAsync = ref.watch(tanksProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Aquariums',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryLight,
                      AppColors.background,
                    ],
                  ),
                ),
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
                      return TankCard(
                        tank: tank,
                        onTap: () => _navigateToTankDetail(context, tank),
                      );
                    },
                    childCount: tanks.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      
      // FAB to add new tank
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
          // Illustration placeholder
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          
          Text(
            'No tanks yet',
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          Text(
            'Add your first aquarium to start tracking water parameters, livestock, and maintenance.',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
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
    );
  }
}
