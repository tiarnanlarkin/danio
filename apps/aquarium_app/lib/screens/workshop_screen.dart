import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../providers/user_profile_provider.dart';
import 'co2_calculator_screen.dart';
import 'cycling_assistant_screen.dart';
import 'dosing_calculator_screen.dart';
import 'compatibility_checker_screen.dart';
import 'cost_tracker_screen.dart';
import 'water_change_calculator_screen.dart';
import 'stocking_calculator_screen.dart';
import 'unit_converter_screen.dart';
import 'tank_volume_calculator_screen.dart';
import 'lighting_schedule_screen.dart';
import '../providers/tank_provider.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/danio_snack_bar.dart';
import '../providers/user_profile_notifier.dart';
// charts_screen.dart requires tankId - accessed from tank detail screen



/// Workshop Room - Tools & Calculators
class WorkshopScreen extends ConsumerStatefulWidget {
  const WorkshopScreen({super.key});

  @override
  ConsumerState<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends ConsumerState<WorkshopScreen> {
  @override
  void initState() {
    super.initState();
    _showFirstVisitTooltip();
  }

  Future<void> _showFirstVisitTooltip() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final visited = prefs.getBool('tab_4_workshop_visited') ?? false;
    if (!visited) {
      await prefs.setBool('tab_4_workshop_visited', true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        DanioSnackBar.info(context, '🔧 The Workshop — calculators, guides, and tools');
      });
    }
  }

  /// Pick a tank, then navigate to the Cycling Assistant for that tank.
  Future<void> _openCyclingAssistant() async {
    final tanks = await ref.read(tanksProvider.future);
    if (!mounted) return;

    if (tanks.isEmpty) {
      DanioSnackBar.info(context, 'Add a tank first to use the Cycling Assistant.');
      return;
    }

    String? tankId;
    if (tanks.length == 1) {
      tankId = tanks.first.id;
    } else {
      // Simple tank picker dialog.
      if (!mounted) return;
      tankId = await showDialog<String>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Choose a Tank'),
          children: tanks
              .map(
                (tank) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, tank.id),
                  child: Text(tank.name),
                ),
              )
              .toList(),
        ),
      );
    }

    if (tankId == null || !mounted) return;
    NavigationThrottle.push(context, CyclingAssistantScreen(tankId: tankId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    DanioColors.workshopBackground1Dark,
                    DanioColors.workshopBackground2Dark,
                    DanioColors.workshopBackground3Dark,
                  ]
                : [
                    DanioColors.workshopBackground1,
                    DanioColors.workshopBackground2,
                    DanioColors.workshopBackground3,
                  ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              // AppBar with back button
              SliverAppBar(
                title: const Text('🔧 Workshop'),
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textPrimaryDark,
                elevation: 0,
                pinned: true,
              ),

              // Header
              SliverToBoxAdapter(child: _WorkshopHeader()),

              // Tool cards — 10 cards in 2-col grid
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildListDelegate([
                    _ToolCard(
                      icon: Icons.water_drop,
                      title: 'Water Change',
                      subtitle: 'Calculate changes',
                      color: DanioColors.tealWater,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const WaterChangeCalculatorScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.pool,
                      title: 'Stocking',
                      subtitle: 'Fish capacity',
                      color: DanioColors.wishlistAmber,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const StockingCalculatorScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.science,
                      title: 'CO₂ Calculator',
                      subtitle: 'From pH & KH',
                      color: DanioColors.tealWater,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const Co2CalculatorScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.medication_liquid,
                      title: 'Dosing',
                      subtitle: 'Fertilizer calculator',
                      color: AppColors.success,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const DosingCalculatorScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.swap_horiz,
                      title: 'Unit Converter',
                      subtitle: 'Convert units',
                      color: DanioColors.workshopAccentSteel,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const UnitConverterScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.calculate,
                      title: 'Tank Volume',
                      subtitle: 'Calculate capacity',
                      color: DanioColors.tealWater,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const TankVolumeCalculatorScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.lightbulb,
                      title: 'Lighting',
                      subtitle: 'Schedule lights',
                      color: DanioColors.wishlistAmber,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const LightingScheduleScreen(),
                      ),
                    ),

                    _ToolCard(
                      icon: Icons.compare_arrows,
                      title: 'Compatibility',
                      subtitle: 'Check fish matches',
                      color: DanioColors.wishlistAmber,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const CompatibilityCheckerScreen(),
                      ),
                    ),

                    _ToolCard(
                      icon: Icons.science,
                      title: 'Cycling Assistant',
                      subtitle: 'Track tank cycle',
                      color: DanioColors.tealWater,
                      onTap: _openCyclingAssistant,
                    ),

                  ]),
                ),
              ),

              // Cost Tracker — full-width card at the bottom
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm2,
                ),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80,
                    child: _ToolCard(
                      icon: Icons.attach_money,
                      title: 'Cost Tracker',
                      subtitle: 'Track your aquarium expenses',
                      color: AppColors.success,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const CostTrackerScreen(),
                      ),
                    ),
                  ),
                ),
              ),

              // Quick conversions section
              SliverToBoxAdapter(child: _QuickConversions()),

              // Bottom padding for navigation bar
              const SliverToBoxAdapter(
                child: SizedBox(height: kScrollEndPadding),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

class _WorkshopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm2),
                decoration: BoxDecoration(
                  color: AppColors.whiteAlpha12,
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(color: AppColors.whiteAlpha20),
                ),
                child: const Icon(
                  Icons.build,
                  color: DanioColors.studyGold,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔧 Workshop',
                      style: (Theme.of(context).textTheme.headlineSmall ?? const TextStyle())
                          .copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tools & calculators',
                      style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
                        color: DanioColors.workshopTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.whiteAlpha15,
            borderRadius: AppRadius.largeRadius,
            border: Border.all(color: AppColors.whiteAlpha20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm3),
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Icon(icon, color: color, size: AppIconSizes.md),
              ),
              const Spacer(),
              Text(
                title,
                style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle()).copyWith(
                  color: DanioColors.workshopTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _QuickConversions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: RepaintBoundary(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg2),
          decoration: BoxDecoration(
            color: AppColors.whiteAlpha15,
            borderRadius: AppRadius.largeRadius,
            border: Border.all(color: AppColors.whiteAlpha20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Reference',
                style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ConversionRow('1 gallon', '3.785 liters'),
              _ConversionRow('1 inch', '2.54 cm'),
              _ConversionRow('°F to °C', '(°F - 32) × 5/9'),
              _ConversionRow('ppm', 'mg/L (same)'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversionRow extends StatelessWidget {
  final String left;
  final String right;

  const _ConversionRow(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
              color: DanioColors.workshopTextSecondary,
            ),
          ),
          Text(
            right,
            style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
              color: DanioColors.studyGold,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
