// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

import '../widgets/core/app_list_tile.dart';
import '../widgets/danio_snack_bar.dart';
import '../services/onboarding_service.dart';
import '../providers/onboarding_provider.dart';
import 'tab_navigator.dart';

// Screen imports — Onboarding
import '../data/species_database.dart';
import 'onboarding/feature_summary_screen.dart';
import 'onboarding/consent_screen.dart';

// Screen imports — Main

// Screen imports — Tank
import 'create_tank_screen.dart';
import 'tank_detail/tank_detail_screen.dart';
import 'tank_settings_screen.dart';

// Screen imports — Tools (Workshop)
import 'co2_calculator_screen.dart';
import 'compatibility_checker_screen.dart';
import 'cost_tracker_screen.dart';
import 'stocking_calculator_screen.dart';
import 'water_change_calculator_screen.dart';
import 'dosing_calculator_screen.dart';
import 'tank_volume_calculator_screen.dart';
import 'unit_converter_screen.dart';
import 'lighting_schedule_screen.dart';

// Screen imports — Guides
import 'nitrogen_cycle_guide_screen.dart';
import 'algae_guide_screen.dart';
import 'disease_guide_screen.dart';
import 'emergency_guide_screen.dart';
import 'equipment_guide_screen.dart';
import 'feeding_guide_screen.dart';
import 'acclimation_guide_screen.dart';
import 'quarantine_guide_screen.dart';
import 'plant_browser_screen.dart';
import 'species_browser_screen.dart';

// Screen imports — Other
import 'achievements_screen.dart';
import 'analytics_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_policy_screen.dart';
import '../widgets/core/app_dialog.dart';

class DebugMenuScreen extends ConsumerWidget {
  const DebugMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();

      final items = <Widget>[
            _SectionHeader(title: 'Onboarding'),
            _DebugTile(
              title: 'Complete Onboarding',
              subtitle: 'Skip onboarding, go to main app',
              onTap: () => _completeOnboarding(context, ref),
            ),
            _DebugTile(
              title: 'Reset Onboarding',
              subtitle: 'Clear flag — onboarding will show on next launch',
              onTap: () => _resetOnboarding(context, ref),
            ),
            const Divider(),

            // Main Tabs
            // Actual indices: 0=Learn, 1=Quiz, 2=Tank, 3=Smart, 4=Settings
            _SectionHeader(title: 'Main Tabs'),
            _DebugTile(
              title: 'Home (Learn Tab)',
              subtitle: 'Switch to Learn tab (index 0)',
              onTap: () => _switchTab(context, ref, 0),
            ),
            _DebugTile(
              title: 'Quiz Tab',
              subtitle: 'Switch to Quiz tab (index 1)',
              onTap: () => _switchTab(context, ref, 1),
            ),
            _DebugTile(
              title: 'Tank Tab',
              subtitle: 'Switch to Tank tab (index 2)',
              onTap: () => _switchTab(context, ref, 2),
            ),
            _DebugTile(
              title: 'Smart Tab',
              subtitle: 'Switch to Smart tab (index 3)',
              onTap: () => _switchTab(context, ref, 3),
            ),
            _DebugTile(
              title: 'Settings Tab',
              subtitle: 'Switch to Settings tab (index 4)',
              onTap: () => _switchTab(context, ref, 4),
            ),
            const Divider(),

            // Tank Management
            _SectionHeader(title: 'Tank Management'),
            _DebugTile(
              title: 'Create Tank',
              onTap: () => _push(context, const CreateTankScreen()),
            ),
            _DebugTile(
              title: 'Tank Detail',
              subtitle: 'Uses first available tank or shows error',
              onTap: () => _openTankDetail(context),
            ),
            _DebugTile(
              title: 'Tank Settings',
              subtitle: 'Opens settings for first available tank',
              onTap: () => _openTankSettings(context),
            ),
            const Divider(),

            // Tools (Workshop sub-screens)
            _SectionHeader(title: 'Tools'),
            _DebugTile(
              title: 'CO₂ Calculator',
              onTap: () => _push(context, const Co2CalculatorScreen()),
            ),
            _DebugTile(
              title: 'Compatibility Checker',
              onTap: () => _push(context, const CompatibilityCheckerScreen()),
            ),
            _DebugTile(
              title: 'Cost Tracker',
              onTap: () => _push(context, const CostTrackerScreen()),
            ),
            _DebugTile(
              title: 'Stocking Calculator',
              onTap: () => _push(context, const StockingCalculatorScreen()),
            ),
            _DebugTile(
              title: 'Water Change Calculator',
              onTap: () => _push(context, const WaterChangeCalculatorScreen()),
            ),
            _DebugTile(
              title: 'Dosing Calculator',
              onTap: () => _push(context, const DosingCalculatorScreen()),
            ),
            _DebugTile(
              title: 'Tank Volume Calculator',
              onTap: () => _push(context, const TankVolumeCalculatorScreen()),
            ),
            _DebugTile(
              title: 'Unit Converter',
              onTap: () => _push(context, const UnitConverterScreen()),
            ),
            _DebugTile(
              title: 'Lighting Schedule',
              onTap: () => _push(context, const LightingScheduleScreen()),
            ),
            const Divider(),

            // Guides
            _SectionHeader(title: 'Guides'),
            _DebugTile(
              title: 'Nitrogen Cycle',
              onTap: () => _push(context, const NitrogenCycleGuideScreen()),
            ),
            _DebugTile(
              title: 'Algae Guide',
              onTap: () => _push(context, const AlgaeGuideScreen()),
            ),
            _DebugTile(
              title: 'Disease Guide',
              onTap: () => _push(context, const DiseaseGuideScreen()),
            ),
            _DebugTile(
              title: 'Emergency Guide',
              onTap: () => _push(context, const EmergencyGuideScreen()),
            ),
            _DebugTile(
              title: 'Equipment Guide',
              onTap: () => _push(context, const EquipmentGuideScreen()),
            ),
            _DebugTile(
              title: 'Feeding Guide',
              onTap: () => _push(context, const FeedingGuideScreen()),
            ),
            _DebugTile(
              title: 'Acclimation Guide',
              onTap: () => _push(context, const AcclimationGuideScreen()),
            ),
            _DebugTile(
              title: 'Quarantine Guide',
              onTap: () => _push(context, const QuarantineGuideScreen()),
            ),
            _DebugTile(
              title: 'Plant Browser',
              onTap: () => _push(context, const PlantBrowserScreen()),
            ),
            _DebugTile(
              title: 'Species Browser',
              onTap: () => _push(context, const SpeciesBrowserScreen()),
            ),
            const Divider(),

            // Other Screens
            _SectionHeader(title: 'Other Screens'),
            _DebugTile(
              title: 'Achievements',
              onTap: () => _push(context, const AchievementsScreen()),
            ),
            _DebugTile(
              title: 'Analytics',
              onTap: () => _push(context, const AnalyticsScreen()),
            ),
            _DebugTile(
              title: 'Notification Settings',
              onTap: () => _push(context, const NotificationSettingsScreen()),
            ),
            _DebugTile(
              title: 'Privacy Policy',
              onTap: () => _push(context, const PrivacyPolicyScreen()),
            ),
            _DebugTile(
              title: 'Paywall Stub',
              onTap: () => _push(
                context,
                FeatureSummaryScreen(
                  selectedFish: const SpeciesInfo(
                    commonName: 'Test Fish',
                    scientificName: 'Testus testus',
                    family: 'Testidae',
                    careLevel: 'Beginner',
                    minTankLitres: 60,
                    minTempC: 22,
                    maxTempC: 28,
                    minPh: 6.5,
                    maxPh: 7.5,
                    minSchoolSize: 6,
                    temperament: 'Peaceful',
                    diet: 'Omnivore',
                    adultSizeCm: 5,
                    swimLevel: 'Middle',
                    description: 'Debug test fish',
                    compatibleWith: [],
                    avoidWith: [],
                  ),
                  onComplete: () => Navigator.of(context).pop(),
                  onSkip: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            _DebugTile(
              title: 'Consent Screen',
              subtitle: 'Privacy consent (resets analytics pref first)',
              onTap: () => _push(
                context,
                ConsentScreen(
                  onConsentGiven: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            const Divider(),

            // State
            _SectionHeader(title: 'State'),
            _DebugTile(
              title: 'Clear All Data',
              subtitle: '⚠️ Clears SharedPreferences and resets state',
              color: Colors.red.shade700,
              onTap: () => _clearAllData(context, ref),
            ),
            const SizedBox(height: 32),
      ];

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.orange,
              secondary: Colors.deepOrange,
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🐛 Debug Menu'),
          backgroundColor: Colors.orange.shade900,
          foregroundColor: AppColors.onPrimary,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) => items[index],
          itemCount: items.length,
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _switchTab(BuildContext context, WidgetRef ref, int index) async {
    // Pop debug menu and any intermediate screens back to TabNavigator,
    // then switch tab.
    ref.read(currentTabProvider.notifier).state = index;
    // Pop back to the tab navigator
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref) async {
    final service = await OnboardingService.getInstance();
    await service.completeOnboarding();
    ref.invalidate(onboardingCompletedProvider);
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _resetOnboarding(BuildContext context, WidgetRef ref) async {
    final service = await OnboardingService.getInstance();
    await service.resetOnboarding();
    ref.invalidate(onboardingCompletedProvider);
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _openTankDetail(BuildContext context) {
    // Navigate to tank detail — requires a tank ID.
    // We use a placeholder ID; the screen will show empty/loading state
    // if no tank exists.
    _push(context, const TankDetailScreen(tankId: 'debug-test-tank'));
  }

  void _openTankSettings(BuildContext context) {
    _push(context, const TankSettingsScreen(tankId: 'debug-test-tank'));
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppDestructiveDialog(
      context: context,
      title: '⚠️ Clear All Data',
      message:
          'This will clear all SharedPreferences and reset app state.\n\n'
          'The app should be restarted after this.',
      destructiveLabel: 'Clear',
    );

    if (confirmed == true) {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.clear();
      if (context.mounted) {
        DanioSnackBar.info(context, 'All data cleared. Restart the app.');
      }
    }
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _DebugTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _DebugTile({
    required this.title,
    this.subtitle,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: Icon(
        Icons.chevron_right,
        color: color ?? Colors.orange.shade700,
      ),
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

