import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/app_feedback.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/room/interactive_object.dart';
import 'co2_calculator_screen.dart';
import 'dosing_calculator_screen.dart';
import 'compatibility_checker_screen.dart';
import 'cost_tracker_screen.dart';
import 'water_change_calculator_screen.dart';
import 'stocking_calculator_screen.dart';
import 'unit_converter_screen.dart';
import 'tank_volume_calculator_screen.dart';
import 'lighting_schedule_screen.dart';
import '../utils/navigation_throttle.dart';
// charts_screen.dart requires tankId - accessed from tank detail screen

/// Workshop colors - practical maker space theme
/// Adapts slightly for dark mode to maintain readability
class WorkshopColors {
  WorkshopColors._();

  static const background1 = Color(0xFF5D4E37); // Warm brown
  static const background2 = Color(0xFF4A3F2E); // Darker brown
  static const background3 = Color(0xFF3D3425); // Deep brown
  static const accent = Color(0xFFA0AEC0); // Steel blue
  static const accentWarm = Color(0xFFD4A574); // Warm gold
  static const wood = Color(0xFF7A6548); // Light wood
  static const metal = Color(0xFF6B7280); // Steel gray
  static const glassCard = Color(0x20FFFFFF);
  static const glassBorder = Color(0x30FFFFFF);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFB8B0A0);

  // Dark mode adjustments - lighter/desaturated browns
  static const background1Dark = Color(0xFF6E5F48); // Lighter warm brown
  static const background2Dark = Color(0xFF5B5039); // Lighter mid brown
  static const background3Dark = Color(0xFF4E4430); // Lighter base brown

  /// Returns gradient colors adapted to current brightness
  static List<Color> gradientColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? [background1Dark, background2Dark, background3Dark]
        : [background1, background2, background3];
  }
}

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔧 The Workshop — calculators, guides, and tools'),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: WorkshopColors.gradientColors(context),
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
                foregroundColor: WorkshopColors.textPrimary,
                elevation: 0,
                pinned: true,
              ),

              // Header
              SliverToBoxAdapter(child: _WorkshopHeader()),

              // Tool cards
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
                      color: const Color(0xFFFFCA28),
                      onTap: () => NavigationThrottle.push(
                        context,
                        const WaterChangeCalculatorScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.set_meal,
                      title: 'Stocking',
                      subtitle: 'Fish capacity',
                      color: DanioColors.tealWater,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const StockingCalculatorScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.science,
                      title: 'CO₂ Calculator',
                      subtitle: 'From pH & KH',
                      color: const Color(0xFFFFCA28),
                      onTap: () => NavigationThrottle.push(
                        context,
                        const Co2CalculatorScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.medication_liquid,
                      title: 'Dosing',
                      subtitle: 'Fertilizer calculator',
                      color: AppColors.accentAlt,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const DosingCalculatorScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.swap_horiz,
                      title: 'Unit Converter',
                      subtitle: 'Convert units',
                      color: AppColors.xp,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const UnitConverterScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.calculate,
                      title: 'Tank Volume',
                      subtitle: 'Calculate capacity',
                      color: WorkshopColors.accent,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const TankVolumeCalculatorScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.lightbulb,
                      title: 'Lighting',
                      subtitle: 'Schedule lights',
                      color: AppColors.warning,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const LightingScheduleScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.bar_chart,
                      title: 'Charts',
                      subtitle: 'Analytics & trends',
                      color: AppColors.secondaryDark,
                      onTap: () => _showChartsInfo(context),
                    ),
                    _ToolCard(
                      icon: Icons.set_meal,
                      title: 'Compatibility',
                      subtitle: 'Check fish matches',
                      color: AppColors.primaryLight,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const CompatibilityCheckerScreen(),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.build_circle,
                      title: 'Equipment',
                      subtitle: 'Manage gear',
                      color: WorkshopColors.metal,
                      onTap: () => _showEquipmentInfo(context),
                    ),
                    _ToolCard(
                      icon: Icons.attach_money,
                      title: 'Cost Tracker',
                      subtitle: 'Track expenses',
                      color: DanioColors.tealWater,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const CostTrackerScreen(),
                      ),
                    ),
                  ]),
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

  void _showEquipmentInfo(BuildContext context) {
    AppFeedback.showInfo(context, 'Select a tank first to manage equipment.');
  }

  void _showChartsInfo(BuildContext context) {
    AppFeedback.showInfo(context, 'Select a tank first to view charts.');
  }
}

class _WorkshopHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider.select((p) => p.value?.hasSeenTutorial));
    final isNewUser = !(profile ?? false);

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
                  color: WorkshopColors.glassCard,
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(color: WorkshopColors.glassBorder),
                ),
                child: const Icon(
                  Icons.build,
                  color: WorkshopColors.accentWarm,
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
                            color: WorkshopColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tools & calculators',
                      style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
                        color: WorkshopColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              WorkshopObjects.workbench(
                onTap: null, // DIY Projects not yet implemented
                isNewUser: isNewUser,
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
      child: ClipRRect(
        borderRadius: AppRadius.largeRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: WorkshopColors.glassCard,
              borderRadius: AppRadius.largeRadius,
              border: Border.all(color: WorkshopColors.glassBorder),
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
                    color: WorkshopColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: (Theme.of(context).textTheme.bodySmall ?? const TextStyle()).copyWith(
                    color: WorkshopColors.textSecondary,
                  ),
                ),
              ],
            ),
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
      child: ClipRRect(
        borderRadius: AppRadius.largeRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg2),
            decoration: BoxDecoration(
              color: WorkshopColors.glassCard,
              borderRadius: AppRadius.largeRadius,
              border: Border.all(color: WorkshopColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Reference',
                  style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
                    color: WorkshopColors.textPrimary,
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
              color: WorkshopColors.textSecondary,
            ),
          ),
          Text(
            right,
            style: (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
              color: WorkshopColors.accentWarm,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
