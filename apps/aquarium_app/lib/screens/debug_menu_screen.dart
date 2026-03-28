// ignore_for_file: avoid_print
import 'dart:convert';
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

// Screen imports — QA additions
import 'workshop_screen.dart';
import 'faq_screen.dart';
import 'glossary_screen.dart';
import 'theme_gallery_screen.dart';
import 'quick_start_guide_screen.dart';
import 'terms_of_service_screen.dart';
import 'about_screen.dart';
import 'learn/unlock_celebration_screen.dart';

// Provider imports — QA state injection
import '../providers/tank_provider.dart';
import '../providers/species_unlock_provider.dart';
import '../providers/room_theme_provider.dart';
import '../providers/storage_provider.dart';
import '../models/tank.dart';
import '../models/livestock.dart';
import '../data/species_unlock_map.dart';

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

            // QA State Setup
            _SectionHeader(title: 'QA State Setup'),
            _DebugTile(
              title: 'Seed Demo Tank',
              subtitle: 'Creates QA Test Tank (60L, tropical) with 5 fish',
              onTap: () => _seedDemoTank(context, ref),
            ),
            _DebugTile(
              title: 'Set Energy: Full (5)',
              subtitle: 'Restore hearts to max',
              onTap: () => _setEnergy(context, ref, full: true),
            ),
            _DebugTile(
              title: 'Set Energy: Empty (0)',
              subtitle: 'Drain all hearts',
              onTap: () => _setEnergy(context, ref, full: false),
            ),
            _DebugTile(
              title: 'Set XP: 0',
              onTap: () => _setXp(context, ref, 0),
            ),
            _DebugTile(
              title: 'Set XP: 500',
              onTap: () => _setXp(context, ref, 500),
            ),
            _DebugTile(
              title: 'Set XP: 5000',
              onTap: () => _setXp(context, ref, 5000),
            ),
            _DebugTile(
              title: 'Set Streak: 0',
              onTap: () => _setStreak(context, ref, 0),
            ),
            _DebugTile(
              title: 'Set Streak: 7',
              onTap: () => _setStreak(context, ref, 7),
            ),
            _DebugTile(
              title: 'Set Streak: 30',
              onTap: () => _setStreak(context, ref, 30),
            ),
            _DebugTile(
              title: 'Unlock All Species',
              subtitle: 'Unlocks every species in the database',
              onTap: () => _unlockAllSpecies(context, ref),
            ),
            _DebugTile(
              title: 'Reset Species to Defaults',
              subtitle: 'zebra_danio, neon_tetra, guppy only',
              onTap: () => _resetSpeciesToDefaults(context, ref),
            ),
            _DebugTile(
              title: 'Cycle Room Theme →',
              subtitle: 'Advance to the next room theme',
              onTap: () => _cycleRoomTheme(context, ref),
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
              title: 'Workshop',
              onTap: () => _push(context, const WorkshopScreen()),
            ),
            _DebugTile(
              title: 'FAQ',
              onTap: () => _push(context, const FaqScreen()),
            ),
            _DebugTile(
              title: 'Glossary',
              onTap: () => _push(context, const GlossaryScreen()),
            ),
            _DebugTile(
              title: 'Theme Gallery',
              onTap: () => _push(context, const ThemeGalleryScreen()),
            ),
            _DebugTile(
              title: 'Quick Start Guide',
              onTap: () => _push(context, const QuickStartGuideScreen()),
            ),
            _DebugTile(
              title: 'Terms of Service',
              onTap: () => _push(context, const TermsOfServiceScreen()),
            ),
            _DebugTile(
              title: 'About',
              onTap: () => _push(context, const AboutScreen()),
            ),
            _DebugTile(
              title: 'Unlock Celebration',
              subtitle: 'Test with zebra_danio',
              onTap: () => _push(context, const UnlockCelebrationScreen(speciesId: 'zebra_danio')),
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
            const SizedBox(height: AppSpacing.xl),
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemBuilder: (context, index) => items[index],
          itemCount: items.length,
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  // ── QA State Injection helpers ──────────────────────────────────────────

  Future<void> _seedDemoTank(BuildContext context, WidgetRef ref) async {
    try {
      final storage = ref.read(storageServiceProvider);
      const tankId = 'debug-demo-tank';

      // Create or overwrite the demo tank
      final now = DateTime.now();
      final tank = Tank(
        id: tankId,
        name: 'QA Test Tank',
        type: TankType.freshwater,
        volumeLitres: 60,
        startDate: now,
        targets: WaterTargets.freshwaterTropical(),
        createdAt: now,
        updatedAt: now,
        sortOrder: 9999,
      );
      await storage.saveTank(tank);

      // Add 5 demo fish
      final demoFish = [
        ('zebra_danio', 'Zebra Danio'),
        ('neon_tetra', 'Neon Tetra'),
        ('guppy', 'Guppy'),
        ('cherry_barb', 'Cherry Barb'),
        ('bronze_corydoras', 'Bronze Corydoras'),
      ];
      for (final (speciesId, commonName) in demoFish) {
        final livestock = Livestock(
          id: 'debug-$speciesId',
          tankId: tankId,
          commonName: commonName,
          count: 6,
          dateAdded: now,
          healthStatus: HealthStatus.healthy,
          createdAt: now,
          updatedAt: now,
        );
        await storage.saveLivestock(livestock);
      }

      ref.invalidate(tanksProvider);
      ref.invalidate(tankProvider(tankId));
      ref.invalidate(livestockProvider(tankId));

      if (context.mounted) {
        DanioSnackBar.success(context, 'Demo tank seeded: QA Test Tank (60L, 5 fish)');
      }
    } catch (e) {
      if (context.mounted) {
        DanioSnackBar.error(context, 'Seed failed: $e');
      }
    }
  }

  Future<void> _setEnergy(BuildContext context, WidgetRef ref, {required bool full}) async {
    try {
      final notifier = ref.read(userProfileProvider.notifier);
      await notifier.updateHearts(
        hearts: full ? 5 : 0,
        clearLastHeartRefill: !full,
      );
      if (context.mounted) {
        DanioSnackBar.success(context, full ? 'Energy set to full (5)' : 'Energy drained (0)');
      }
    } catch (e) {
      if (context.mounted) DanioSnackBar.error(context, 'Set energy failed: $e');
    }
  }

  Future<void> _setXp(BuildContext context, WidgetRef ref, int xp) async {
    try {
      final current = ref.read(userProfileProvider).value;
      if (current == null) {
        if (context.mounted) DanioSnackBar.info(context, 'No profile loaded yet');
        return;
      }
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final updated = current.copyWith(totalXp: xp, updatedAt: DateTime.now());
      await prefs.setString('user_profile', jsonEncode(updated.toJson()));
      ref.invalidate(userProfileProvider);
      if (context.mounted) DanioSnackBar.success(context, 'XP set to $xp');
    } catch (e) {
      if (context.mounted) DanioSnackBar.error(context, 'Set XP failed: $e');
    }
  }

  Future<void> _setStreak(BuildContext context, WidgetRef ref, int streak) async {
    try {
      final current = ref.read(userProfileProvider).value;
      if (current == null) {
        if (context.mounted) DanioSnackBar.info(context, 'No profile loaded yet');
        return;
      }
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final updated = current.copyWith(currentStreak: streak, updatedAt: DateTime.now());
      await prefs.setString('user_profile', jsonEncode(updated.toJson()));
      ref.invalidate(userProfileProvider);
      if (context.mounted) DanioSnackBar.success(context, 'Streak set to $streak days');
    } catch (e) {
      if (context.mounted) DanioSnackBar.error(context, 'Set streak failed: $e');
    }
  }

  Future<void> _unlockAllSpecies(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(speciesUnlockProvider.notifier);
      for (final speciesId in speciesLessonMap.keys) {
        await notifier.unlockSpecies(speciesId);
      }
      // Also unlock defaults (no-op if already unlocked)
      for (final speciesId in defaultUnlockedSpecies) {
        await notifier.unlockSpecies(speciesId);
      }
      if (context.mounted) {
        DanioSnackBar.success(context, 'All species unlocked');
      }
    } catch (e) {
      if (context.mounted) DanioSnackBar.error(context, 'Unlock all failed: $e');
    }
  }

  Future<void> _resetSpeciesToDefaults(BuildContext context, WidgetRef ref) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(
        'unlocked_species_v1',
        jsonEncode(defaultUnlockedSpecies),
      );
      ref.invalidate(speciesUnlockProvider);
      if (context.mounted) {
        DanioSnackBar.success(context, 'Species reset to defaults (3)');
      }
    } catch (e) {
      if (context.mounted) DanioSnackBar.error(context, 'Reset species failed: $e');
    }
  }

  void _cycleRoomTheme(BuildContext context, WidgetRef ref) {
    ref.read(roomThemeProvider.notifier).nextTheme();
    final current = ref.read(roomThemeProvider);
    if (context.mounted) {
      DanioSnackBar.success(context, 'Room theme → ${current.name}');
    }
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm2, AppSpacing.md, AppSpacing.xs),
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

