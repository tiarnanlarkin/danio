import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../models/wishlist.dart';
import '../providers/settings_provider.dart';
import 'about_screen.dart';
import 'notification_settings_screen.dart';
import 'acclimation_guide_screen.dart';
import 'backup_restore_screen.dart';
import 'co2_calculator_screen.dart';
import 'reminders_screen.dart';
import 'tank_comparison_screen.dart';
import 'wishlist_screen.dart';
import 'algae_guide_screen.dart';
import 'breeding_guide_screen.dart';
import 'glossary_screen.dart';
import 'hardscape_guide_screen.dart';
import 'quick_start_guide_screen.dart';
import 'troubleshooting_screen.dart';
import 'quarantine_guide_screen.dart';
import 'substrate_guide_screen.dart';
import 'equipment_guide_screen.dart';
import 'nitrogen_cycle_guide_screen.dart';
import 'disease_guide_screen.dart';
import 'plant_browser_screen.dart';
import 'species_browser_screen.dart';
import 'feeding_guide_screen.dart';
import 'parameter_guide_screen.dart';
import '../services/notification_service.dart';
import '../services/onboarding_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import 'onboarding_screen.dart';
import 'shop_street_screen.dart';
import 'theme_gallery_screen.dart';
import 'difficulty_settings_screen.dart';
import 'dosing_calculator_screen.dart';
import 'compatibility_checker_screen.dart';
import 'cost_tracker_screen.dart';
import 'emergency_guide_screen.dart';
import 'faq_screen.dart';
import 'lighting_schedule_screen.dart';
import 'stocking_calculator_screen.dart';
import 'water_change_calculator_screen.dart';
import 'tank_volume_calculator_screen.dart';
import 'vacation_guide_screen.dart';
import 'unit_converter_screen.dart';
import 'learn_screen.dart';
import 'tank_detail_screen.dart';
import '../providers/tank_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/room_navigation.dart';
import '../utils/accessibility_utils.dart';
import '../models/adaptive_difficulty.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Learning System (Duolingo-style)
          _SectionHeader(title: 'Learn'),
          _LearnCard(ref: ref),

          // Daily Goal Settings
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Daily Goal'),
            subtitle: Text('Set your daily XP target'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDailyGoalPicker(context, ref),
          ),

          // House Navigation (Rooms)
          _SectionHeader(title: 'Explore'),
          const RoomNavigation(),

          // Appearance
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Light/Dark Mode'),
            subtitle: Text(_themeModeLabel(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, ref, settings.themeMode),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Room Themes'),
            subtitle: const Text('Customize your living room style'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemeGalleryScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Difficulty Settings'),
            subtitle: const Text('Adjust app complexity level'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _DifficultySettingsWrapper(),
              ),
            ),
          ),

          const Divider(),

          // Notifications
          _SectionHeader(title: 'Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Streak Reminders'),
            subtitle: const Text('Daily notifications to maintain your streak'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsScreen(),
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Task Reminders'),
            subtitle: const Text('Get notified when tasks are due'),
            value: settings.notificationsEnabled,
            onChanged: (value) => _toggleNotifications(context, ref, value),
          ),
          if (settings.notificationsEnabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('Test Notification'),
              subtitle: const Text('Send a test notification'),
              onTap: () => _testNotification(context),
            ),

          const Divider(),

          // Tools
          _SectionHeader(title: 'Tools'),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Reminders'),
            subtitle: const Text('Schedule maintenance tasks'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Fish Wishlist'),
            subtitle: const Text('Track fish you want to keep'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const WishlistScreen(category: WishlistCategory.fish),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.compare),
            title: const Text('Compare Tanks'),
            subtitle: const Text('Side-by-side tank comparison'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TankComparisonScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Water Change Calculator'),
            subtitle: const Text('Calculate how much water to change'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WaterChangeCalculatorScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bubble_chart),
            title: const Text('CO2 Calculator'),
            subtitle: const Text('Calculate CO2 from pH and KH'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Co2CalculatorScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Dosing Calculator'),
            subtitle: const Text('Calculate fertilizer & medication doses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DosingCalculatorScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Unit Converter'),
            subtitle: const Text('Volume, temperature, length, hardness'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UnitConverterScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.view_in_ar),
            title: const Text('Tank Volume Calculator'),
            subtitle: const Text('Calculate volume for any tank shape'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TankVolumeCalculatorScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Cost Tracker'),
            subtitle: const Text('Track aquarium expenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CostTrackerScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: const Text('Water Change Calculator'),
            subtitle: const Text('Calculate changes to hit target nitrate'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WaterChangeCalculatorScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Compatibility Checker'),
            subtitle: const Text('Check if fish work together'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CompatibilityCheckerScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb),
            title: const Text('Lighting Schedule'),
            subtitle: const Text('Optimize light duration for your setup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LightingScheduleScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Stocking Calculator'),
            subtitle: const Text('Check if your tank is overstocked'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StockingCalculatorScreen(),
              ),
            ),
          ),

          const Divider(),

          // Shop Street
          _SectionHeader(title: 'Shop'),
          ListTile(
            leading: const Icon(Icons.storefront),
            title: const Text('Shop Street'),
            subtitle: const Text('Find aquarium supplies online'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopStreetScreen()),
            ),
          ),

          const Divider(),

          // About section
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: const Text('Aquarium'),
            subtitle: const Text('Version 0.1.0'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => _showAboutDialog(context),
          ),

          const Divider(),

          // Data section
          _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Export All Data'),
            subtitle: const Text('Share your aquarium data as JSON'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from a backup file'),
            onTap: () => _importData(context),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Photo Storage'),
            subtitle: const Text('View where photos are stored'),
            onTap: () => _showPhotoStorageInfo(context),
          ),

          const Divider(),

          // Guides & Education section (expandable)
          _SectionHeader(title: 'Guides & Education'),

          // Essential - Quick start and emergency
          ExpansionTile(
            leading: const Icon(Icons.star, color: AppColors.primary),
            title: const Text('Essential Guides'),
            subtitle: const Text('Start here - critical knowledge'),
            children: [
              ListTile(
                leading: const Icon(Icons.rocket_launch),
                title: const Text('Quick Start Guide'),
                subtitle: const Text('Setting up your first aquarium'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuickStartGuideScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.emergency, color: AppColors.error),
                title: const Text('Emergency Guide'),
                subtitle: const Text('Urgent problems & immediate actions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmergencyGuideScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.autorenew),
                title: const Text('Nitrogen Cycle Guide'),
                subtitle: const Text('Learn how to cycle your tank'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NitrogenCycleGuideScreen(),
                  ),
                ),
              ),
            ],
          ),

          // Water & Parameters
          ExpansionTile(
            leading: const Icon(Icons.water_drop, color: AppColors.info),
            title: const Text('Water & Parameters'),
            subtitle: const Text('Water quality and chemistry'),
            children: [
              ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Water Parameters Guide'),
                subtitle: const Text('Ideal ranges for common fish'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ParameterGuideScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.grass),
                title: const Text('Algae Guide'),
                subtitle: const Text('Identify and control common algae'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlgaeGuideScreen()),
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
              ListTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Feeding Guide'),
                subtitle: const Text('How much, how often, what types'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedingGuideScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.healing),
                title: const Text('Fish Disease Guide'),
                subtitle: const Text('Identify and treat common diseases'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DiseaseGuideScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.sync_alt),
                title: const Text('Acclimation Guide'),
                subtitle: const Text('How to safely add new fish'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AcclimationGuideScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.local_hospital),
                title: const Text('Quarantine Guide'),
                subtitle: const Text('Setup, protocol, medications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuarantineGuideScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Breeding Guide'),
                subtitle: const Text('Methods, conditioning, raising fry'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BreedingGuideScreen(),
                  ),
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
              ListTile(
                leading: const Icon(Icons.build),
                title: const Text('Equipment Guide'),
                subtitle: const Text('Filters, heaters, lights, CO2, testing'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EquipmentGuideScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.layers),
                title: const Text('Substrate Guide'),
                subtitle: const Text('Types, recommendations, layering'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SubstrateGuideScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.terrain),
                title: const Text('Hardscape Guide'),
                subtitle: const Text('Rocks, driftwood, aquascaping tips'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HardscapeGuideScreen(),
                  ),
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
              ListTile(
                leading: const Icon(Icons.flight),
                title: const Text('Vacation Planning'),
                subtitle: const Text('Prepare your tank for time away'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VacationGuideScreen(),
                  ),
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
              ListTile(
                leading: const Icon(Icons.set_meal),
                title: const Text('Fish Database'),
                subtitle: const Text('45+ species with care info'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SpeciesBrowserScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.eco),
                title: const Text('Plant Database'),
                subtitle: const Text('20+ aquarium plants with care info'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlantBrowserScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text('Glossary'),
                subtitle: const Text('50+ aquarium terms explained'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GlossaryScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.quiz),
                title: const Text('FAQ'),
                subtitle: const Text('Frequently asked questions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.build_circle),
                title: const Text('Troubleshooting'),
                subtitle: const Text('Common problems & solutions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TroubleshootingScreen(),
                  ),
                ),
              ),
            ],
          ),

          const Divider(),

          // Help & Support section (app-related)
          _SectionHeader(title: 'Help & Support'),
          ListTile(
            leading: const Icon(Icons.replay_outlined),
            title: const Text('Replay Onboarding'),
            subtitle: const Text('See the intro screens again'),
            onTap: () => _replayOnboarding(context),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Add Sample Tank'),
            subtitle: const Text('Explore the app with demo data'),
            onTap: () async {
              final actions = ref.read(tankActionsProvider);
              final demoTank = await actions.addDemoTank();
              if (context.mounted) {
                AppFeedback.showSuccess(context, 'Sample tank added!');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TankDetailScreen(tankId: demoTank.id),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Export or import your tank data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Version info and features'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),

          const Divider(),

          // Danger zone
          _SectionHeader(title: 'Danger Zone', color: AppColors.error),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: AppColors.error,
            ),
            title: Text(
              'Clear All Data',
              style: TextStyle(color: AppColors.error),
            ),
            subtitle: const Text('Delete all tanks, logs, and settings'),
            onTap: () => _confirmClearData(context),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleNotifications(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) async {
    if (enable) {
      final service = NotificationService();
      await service.initialize();
      final granted = await service.requestPermissions();

      if (!granted) {
        if (context.mounted) {
          AppFeedback.showWarning(context, 'Notification permission denied');
        }
        return;
      }
    }

    await ref.read(settingsProvider.notifier).setNotificationsEnabled(enable);

    if (context.mounted) {
      if (enable) {
        AppFeedback.showSuccess(context, 'Notifications enabled!');
      } else {
        AppFeedback.showInfo(context, 'Notifications disabled');
      }
    }
  }

  Future<void> _testNotification(BuildContext context) async {
    try {
      final service = NotificationService();
      await service.initialize();
      await service.showTestNotification();

      if (context.mounted) {
        AppFeedback.showSuccess(context, 'Test notification sent!');
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(context, 'Failed: $e');
      }
    }
  }

  String _themeModeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System default';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode current,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choose Theme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System default'),
              subtitle: const Text('Follow device settings'),
              trailing: current == AppThemeMode.system
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(AppThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: current == AppThemeMode.light
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(AppThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing: current == AppThemeMode.dark
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(AppThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDailyGoalPicker(BuildContext context, WidgetRef ref) {
    final profile = ref.read(userProfileProvider).value;
    final currentGoal = profile?.dailyXpGoal ?? 50;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Daily XP Goal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your goal every day to maintain your streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _GoalOption(
              ref: ref,
              goal: 25,
              label: 'Casual',
              description: 'Just a few minutes',
              current: currentGoal,
              icon: '🐢',
            ),
            _GoalOption(
              ref: ref,
              goal: 50,
              label: 'Regular',
              description: 'One lesson per day',
              current: currentGoal,
              icon: '🐟',
            ),
            _GoalOption(
              ref: ref,
              goal: 100,
              label: 'Serious',
              description: 'Multiple lessons',
              current: currentGoal,
              icon: '🦈',
            ),
            _GoalOption(
              ref: ref,
              goal: 200,
              label: 'Intense',
              description: 'Max dedication',
              current: currentGoal,
              icon: '🐋',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Aquarium',
      applicationVersion: '0.1.0 (MVP)',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.water_drop, color: AppColors.primary),
      ),
      children: [
        const Text(
          'Personal aquarium management — track tanks, livestock, equipment & maintenance.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Your data is stored locally on this device.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context) async {
    if (!context.mounted) return;

    AppFeedback.showLoading(context, 'Preparing export…');
    var dismissLoadingInFinally = true;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final dataFile = File('${dir.path}/aquarium_data.json');

      if (!await dataFile.exists()) {
        if (context.mounted) {
          AppFeedback.dismiss(context);
          dismissLoadingInFinally = false;
          AppFeedback.showInfo(context, 'No data to export');
        }
        return;
      }

      await Share.shareXFiles([
        XFile(dataFile.path),
      ], subject: 'Aquarium App Data Export');
    } catch (e) {
      if (context.mounted) {
        AppFeedback.dismiss(context);
        dismissLoadingInFinally = false;
        AppFeedback.showError(context, 'Export failed: $e');
      }
    } finally {
      if (context.mounted && dismissLoadingInFinally) {
        AppFeedback.dismiss(context);
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    // Show warning dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'This will replace ALL your current data with the imported file.\n\n'
          'Make sure you have a backup of your current data first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Import', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty || !context.mounted) return;

    final filePath = result.files.single.path;
    if (filePath == null) {
      AppFeedback.showError(context, 'Could not access selected file');
      return;
    }

    AppFeedback.showLoading(context, 'Importing data…');
    var dismissLoadingInFinally = true;

    try {
      final file = File(filePath);
      final contents = await file.readAsString();

      // Validate it's valid JSON
      try {
        jsonDecode(contents);
      } on FormatException {
        if (context.mounted) {
          AppFeedback.dismiss(context);
          dismissLoadingInFinally = false;
          AppFeedback.showError(
            context,
            'Invalid file format (not valid JSON)',
          );
        }
        return;
      }

      // Write to app data location
      final dir = await getApplicationDocumentsDirectory();
      final dataFile = File('${dir.path}/aquarium_data.json');
      await dataFile.writeAsString(contents);

      if (context.mounted) {
        AppFeedback.dismiss(context);
        dismissLoadingInFinally = false;
        AppFeedback.showSuccess(
          context,
          'Data imported! Restart the app to see changes.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.dismiss(context);
        dismissLoadingInFinally = false;
        AppFeedback.showError(context, 'Import failed: $e');
      }
    } finally {
      if (context.mounted && dismissLoadingInFinally) {
        AppFeedback.dismiss(context);
      }
    }
  }

  Future<void> _showPhotoStorageInfo(BuildContext context) async {
    final dir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${dir.path}/photos');
    final exists = await photoDir.exists();

    int photoCount = 0;
    if (exists) {
      photoCount = await photoDir.list().length;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Photo Storage'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Location:\n${photoDir.path}'),
              const SizedBox(height: 16),
              Text('Photos stored: $photoCount'),
              const SizedBox(height: 16),
              const Text(
                'Photos are stored locally on your device in the app\'s documents folder.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _replayOnboarding(BuildContext context) async {
    final service = await OnboardingService.getInstance();
    await service.resetOnboarding();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your tanks, logs, tasks, and photos. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete Everything',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Double-confirm
    final reallyConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you absolutely sure?'),
        content: const Text('All data will be lost forever.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, keep my data'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Yes, delete everything',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (reallyConfirmed != true || !context.mounted) return;

    try {
      final dir = await getApplicationDocumentsDirectory();

      // Delete data file
      final dataFile = File('${dir.path}/aquarium_data.json');
      if (await dataFile.exists()) {
        await dataFile.delete();
      }

      // Delete photos directory
      final photoDir = Directory('${dir.path}/photos');
      if (await photoDir.exists()) {
        await photoDir.delete(recursive: true);
      }

      // Reset onboarding
      final service = await OnboardingService.getInstance();
      await service.resetOnboarding();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(context, 'Failed to clear data: $e');
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const _SectionHeader({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: color ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Learning system card - shows XP progress and links to Learn screen
class _LearnCard extends StatelessWidget {
  final WidgetRef ref;

  const _LearnCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(learningStatsProvider);
    final profile = ref.watch(userProfileProvider).asData?.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LearnScreen()),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learn Fishkeeping',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (stats != null) ...[
                      Text(
                        '${stats.levelTitle} • ${stats.totalXp} XP',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      if (stats.currentStreak > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '🔥 ${stats.currentStreak} day streak',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        if (profile != null &&
                            (profile.hasStreakFreeze ||
                                profile.streakFreezeUsedThisWeek)) ...[
                          const SizedBox(height: 2),
                          Text(
                            profile.hasStreakFreeze
                                ? '🧊 Streak freeze available'
                                : '🧊 Streak freeze used this week',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ] else
                      Text(
                        'Start your learning journey',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalOption extends StatefulWidget {
  final WidgetRef ref;
  final int goal;
  final String label;
  final String description;
  final int current;
  final String icon;

  const _GoalOption({
    required this.ref,
    required this.goal,
    required this.label,
    required this.description,
    required this.current,
    required this.icon,
  });

  @override
  State<_GoalOption> createState() => _GoalOptionState();
}

class _GoalOptionState extends State<_GoalOption> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.goal == widget.current;

    return ListTile(
      leading: _isLoading
          ? const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(widget.icon, style: const TextStyle(fontSize: 32)),
      title: Text('${widget.goal} XP/day'),
      subtitle: Text('${widget.label} • ${widget.description}'),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      selected: isSelected,
      enabled: !_isLoading,
      onTap: () async {
        setState(() => _isLoading = true);
        try {
          await widget.ref
              .read(userProfileProvider.notifier)
              .setDailyGoal(widget.goal);
          if (mounted) {
            Navigator.pop(context);
            AppFeedback.showSuccess(
              context,
              'Daily goal updated to ${widget.goal} XP',
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      },
    );
  }
}

/// Wrapper for DifficultySettingsScreen that provides a default profile
class _DifficultySettingsWrapper extends StatefulWidget {
  const _DifficultySettingsWrapper();

  @override
  State<_DifficultySettingsWrapper> createState() =>
      _DifficultySettingsWrapperState();
}

class _DifficultySettingsWrapperState
    extends State<_DifficultySettingsWrapper> {
  late UserSkillProfile _profile;

  @override
  void initState() {
    super.initState();
    // Create a default profile for viewing
    _profile = const UserSkillProfile(
      skillLevels: {},
      performanceHistory: {},
      manualOverrides: {},
    );
  }

  void _onProfileUpdated(UserSkillProfile updatedProfile) {
    setState(() {
      _profile = updatedProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DifficultySettingsScreen(
      skillProfile: _profile,
      onProfileUpdated: _onProfileUpdated,
    );
  }
}
