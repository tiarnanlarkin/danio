import 'package:flutter/material.dart';
import '../../../utils/navigation_throttle.dart';
import '../../../widgets/core/app_list_tile.dart';
import '../../../models/wishlist.dart';
import '../../compatibility_checker_screen.dart';
import '../../dosing_calculator_screen.dart';
import '../../lighting_schedule_screen.dart';
import '../../reminders_screen.dart';
import '../../stocking_calculator_screen.dart';
import '../../tank_comparison_screen.dart';
import '../../tank_volume_calculator_screen.dart';
import '../../unit_converter_screen.dart';
import '../../water_change_calculator_screen.dart';
import '../../wishlist_screen.dart';

/// Tools section for the settings screen.
/// Extracted to reduce settings_screen.dart size.
class ToolsSection extends StatelessWidget {
  const ToolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavListTile(
          icon: Icons.notifications_active,
          title: 'Reminders',
          subtitle: 'Schedule maintenance tasks',
          onTap: () => NavigationThrottle.push(context, const RemindersScreen()),
        ),
        NavListTile(
          icon: Icons.favorite,
          title: 'Fish Wishlist',
          subtitle: 'Track fish you want to keep',
          onTap: () => NavigationThrottle.push(
            context,
            const WishlistScreen(category: WishlistCategory.fish),
          ),
        ),
        NavListTile(
          icon: Icons.compare,
          title: 'Compare Tanks',
          subtitle: 'Side-by-side tank comparison',
          onTap: () =>
              NavigationThrottle.push(context, const TankComparisonScreen()),
        ),
        NavListTile(
          icon: Icons.calculate_outlined,
          title: 'Water Change Calculator',
          subtitle: 'Calculate how much water to change',
          onTap: () => NavigationThrottle.push(
            context,
            const WaterChangeCalculatorScreen(),
          ),
        ),
        NavListTile(
          icon: Icons.science_outlined,
          title: 'Dosing Calculator',
          subtitle: 'Calculate fertilizer & medication doses',
          onTap: () =>
              NavigationThrottle.push(context, const DosingCalculatorScreen()),
        ),
        NavListTile(
          icon: Icons.straighten,
          title: 'Unit Converter',
          subtitle: 'Volume, temperature, length, hardness',
          onTap: () =>
              NavigationThrottle.push(context, const UnitConverterScreen()),
        ),
        NavListTile(
          icon: Icons.view_in_ar,
          title: 'Tank Volume Calculator',
          subtitle: 'Calculate volume for any tank shape',
          onTap: () => NavigationThrottle.push(
            context,
            const TankVolumeCalculatorScreen(),
          ),
        ),
        NavListTile(
          icon: Icons.compare_arrows,
          title: 'Compatibility Checker',
          subtitle: 'Check if fish work together',
          onTap: () => NavigationThrottle.push(
            context,
            const CompatibilityCheckerScreen(),
          ),
        ),
        NavListTile(
          icon: Icons.lightbulb,
          title: 'Lighting Schedule',
          subtitle: 'Optimise light duration for your setup',
          onTap: () =>
              NavigationThrottle.push(context, const LightingScheduleScreen()),
        ),
        NavListTile(
          icon: Icons.bar_chart,
          title: 'Stocking Calculator',
          subtitle: 'Check if your tank is overstocked',
          onTap: () =>
              NavigationThrottle.push(context, const StockingCalculatorScreen()),
        ),
      ],
    );
  }
}
