import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/core/app_list_tile.dart';
import '../../../utils/navigation_throttle.dart';
import '../../acclimation_guide_screen.dart';
import '../../algae_guide_screen.dart';
import '../../breeding_guide_screen.dart';
import '../../disease_guide_screen.dart';
import '../../emergency_guide_screen.dart';
import '../../feeding_guide_screen.dart';
import '../../glossary_screen.dart';
import '../../hardscape_guide_screen.dart';
import '../../nitrogen_cycle_guide_screen.dart';
import '../../parameter_guide_screen.dart';
import '../../plant_browser_screen.dart';
import '../../quarantine_guide_screen.dart';
import '../../species_browser_screen.dart';
import '../../substrate_guide_screen.dart';
import '../../equipment_guide_screen.dart';
import '../../quick_start_guide_screen.dart';
import '../../troubleshooting_screen.dart';
import '../../vacation_guide_screen.dart';
import '../../faq_screen.dart';

/// All guide & education items for the settings screen.
/// Extracted to keep settings_screen.dart lean and avoid first-build jank.
class GuidesSection extends StatelessWidget {
  const GuidesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Essential - Quick start and emergency
        ExpansionTile(
          leading: const Icon(Icons.star, color: AppColors.primary),
          title: const Text('Essential Guides'),
          subtitle: const Text('Start here - critical knowledge'),
          children: [
            NavListTile(
              icon: Icons.rocket_launch,
              title: 'Quick Start Guide',
              subtitle: 'Setting up your first aquarium',
              onTap: () => NavigationThrottle.push(
                context,
                const QuickStartGuideScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.emergency,
              iconColor: AppColors.error,
              title: 'Emergency Guide',
              subtitle: 'Urgent problems & immediate actions',
              onTap: () => NavigationThrottle.push(
                context,
                const EmergencyGuideScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.autorenew,
              title: 'Nitrogen Cycle Guide',
              subtitle: 'Learn how to cycle your tank',
              onTap: () => NavigationThrottle.push(
                context,
                const NitrogenCycleGuideScreen(),
              ),
            ),
          ],
        ),

        // Water & Parameters
        ExpansionTile(
          leading: Icon(Icons.water_drop, color: context.textSecondary),
          title: const Text('Water & Parameters'),
          subtitle: const Text('Water quality and chemistry'),
          children: [
            NavListTile(
              icon: Icons.analytics_outlined,
              title: 'Water Parameters Guide',
              subtitle: 'Ideal ranges for common fish',
              onTap: () => NavigationThrottle.push(
                context,
                const ParameterGuideScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.grass,
              title: 'Algae Guide',
              subtitle: 'Identify and control common algae',
              onTap: () => NavigationThrottle.push(
                context,
                const AlgaeGuideScreen(),
              ),
            ),
          ],
        ),

        // Fish Care
        ExpansionTile(
          leading: const Icon(Icons.set_meal, color: AppColors.success),
          title: const Text('Fish Care'),
          subtitle: const Text('Feeding, health, and wellbeing'),
          children: [
            NavListTile(
              icon: Icons.restaurant,
              title: 'Feeding Guide',
              subtitle: 'How much, how often, what types',
              onTap: () => NavigationThrottle.push(
                context,
                const FeedingGuideScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.healing,
              title: 'Fish Disease Guide',
              subtitle: 'Identify and treat common diseases',
              onTap: () => NavigationThrottle.push(
                context,
                const DiseaseGuideScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.sync_alt,
              title: 'Acclimation Guide',
              subtitle: 'How to safely add new fish',
              onTap: () => NavigationThrottle.push(
                context,
                const AcclimationGuideScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.local_hospital,
              title: 'Quarantine Guide',
              subtitle: 'Setup, protocol, medications',
              onTap: () => NavigationThrottle.push(
                context,
                const QuarantineGuideScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.favorite,
              title: 'Breeding Guide',
              subtitle: 'Methods, conditioning, raising fry',
              onTap: () => NavigationThrottle.push(
                context,
                const BreedingGuideScreen(),
              ),
            ),
          ],
        ),

        // Tank Setup & Design
        ExpansionTile(
          leading: const Icon(Icons.landscape, color: AppColors.warning),
          title: const Text('Tank Setup & Design'),
          subtitle: const Text('Equipment, substrate, hardscape'),
          children: [
            NavListTile(
              icon: Icons.build,
              title: 'Equipment Guide',
              subtitle: 'Filters, heaters, lights, CO2, testing',
              onTap: () => NavigationThrottle.push(
                context,
                const EquipmentGuideScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.layers,
              title: 'Substrate Guide',
              subtitle: 'Types, recommendations, layering',
              onTap: () => NavigationThrottle.push(
                context,
                const SubstrateGuideScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.terrain,
              title: 'Hardscape Guide',
              subtitle: 'Rocks, driftwood, aquascaping tips',
              onTap: () => NavigationThrottle.push(
                context,
                const HardscapeGuideScreen(),
              ),
            ),
          ],
        ),

        // Planning & Travel
        ExpansionTile(
          leading: const Icon(Icons.flight_takeoff),
          title: const Text('Planning & Travel'),
          subtitle: const Text('Vacation prep and maintenance'),
          children: [
            NavListTile(
              icon: Icons.flight,
              title: 'Vacation Planning',
              subtitle: 'Prepare your tank for time away',
              onTap: () => NavigationThrottle.push(
                context,
                const VacationGuideScreen(),
              ),
            ),
          ],
        ),

        // Reference Materials
        ExpansionTile(
          leading: const Icon(Icons.library_books),
          title: const Text('Reference'),
          subtitle: const Text('Databases, glossary, FAQ'),
          children: [
            NavListTile(
              icon: Icons.set_meal,
              title: 'Fish Database',
              subtitle: '45+ species with care info',
              onTap: () => NavigationThrottle.push(
                context,
                const SpeciesBrowserScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.eco,
              title: 'Plant Database',
              subtitle: '20+ aquarium plants with care info',
              onTap: () => NavigationThrottle.push(
                context,
                const PlantBrowserScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.menu_book,
              title: 'Glossary',
              subtitle: '50+ aquarium terms explained',
              onTap: () => NavigationThrottle.push(
                context,
                const GlossaryScreen(),
              ),
            ),
            NavListTile(
              icon: Icons.quiz,
              title: 'FAQ',
              subtitle: 'Frequently asked questions',
              onTap: () => NavigationThrottle.push(context, const FaqScreen()),
            ),
            NavListTile(
              icon: Icons.build_circle,
              title: 'Troubleshooting',
              subtitle: 'Common problems & solutions',
              onTap: () => NavigationThrottle.push(context, const TroubleshootingScreen()),
            ),
          ],
        ),
      ],
    );
  }
}
