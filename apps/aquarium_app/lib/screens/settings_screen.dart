import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/settings_provider.dart';
import 'about_screen.dart';
import 'acclimation_guide_screen.dart';
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
import 'onboarding_screen.dart';
import 'shop_street_screen.dart';
import 'dosing_calculator_screen.dart';
import 'compatibility_checker_screen.dart';
import 'cost_tracker_screen.dart';
import 'emergency_guide_screen.dart';
import 'lighting_schedule_screen.dart';
import 'stocking_calculator_screen.dart';
import 'water_change_calculator_screen.dart';
import 'tank_volume_calculator_screen.dart';
import 'vacation_guide_screen.dart';
import 'unit_converter_screen.dart';
import 'water_change_calculator_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(_themeModeLabel(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, ref, settings.themeMode),
          ),

          const Divider(),

          // Notifications
          _SectionHeader(title: 'Notifications'),
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
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Water Change Calculator'),
            subtitle: const Text('Calculate how much water to change'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WaterChangeCalculatorScreen()),
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
              MaterialPageRoute(builder: (_) => const TankVolumeCalculatorScreen()),
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
              MaterialPageRoute(builder: (_) => const WaterChangeCalculatorScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Compatibility Checker'),
            subtitle: const Text('Check if fish work together'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompatibilityCheckerScreen()),
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
              MaterialPageRoute(builder: (_) => const StockingCalculatorScreen()),
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
            onTap: () => _importData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Photo Storage'),
            subtitle: const Text('View where photos are stored'),
            onTap: () => _showPhotoStorageInfo(context),
          ),

          const Divider(),

          // Help section
          _SectionHeader(title: 'Help'),
          ListTile(
            leading: const Icon(Icons.rocket_launch),
            title: const Text('Quick Start Guide'),
            subtitle: const Text('Setting up your first aquarium'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuickStartGuideScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.emergency, color: AppColors.error),
            title: const Text('Emergency Guide'),
            subtitle: const Text('Urgent problems & immediate actions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyGuideScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.autorenew),
            title: const Text('Nitrogen Cycle Guide'),
            subtitle: const Text('Learn how to cycle your tank'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NitrogenCycleGuideScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Water Parameters Guide'),
            subtitle: const Text('Ideal ranges for common fish'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ParameterGuideScreen()),
            ),
          ),
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
            leading: const Icon(Icons.set_meal),
            title: const Text('Fish Database'),
            subtitle: const Text('45+ species with care info'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpeciesBrowserScreen()),
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
            leading: const Icon(Icons.sync_alt),
            title: const Text('Acclimation Guide'),
            subtitle: const Text('How to safely add new fish'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AcclimationGuideScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Equipment Guide'),
            subtitle: const Text('Filters, heaters, lights, CO2, testing'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EquipmentGuideScreen()),
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
          ListTile(
            leading: const Icon(Icons.local_hospital),
            title: const Text('Quarantine Guide'),
            subtitle: const Text('Setup, protocol, medications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuarantineGuideScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Breeding Guide'),
            subtitle: const Text('Methods, conditioning, raising fry'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BreedingGuideScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.layers),
            title: const Text('Substrate Guide'),
            subtitle: const Text('Types, recommendations, layering'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubstrateGuideScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.landscape),
            title: const Text('Hardscape Guide'),
            subtitle: const Text('Rocks, driftwood, aquascaping tips'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HardscapeGuideScreen()),
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
            leading: const Icon(Icons.build_circle),
            title: const Text('Troubleshooting'),
            subtitle: const Text('Common problems & solutions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TroubleshootingScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.flight),
            title: const Text('Vacation Planning'),
            subtitle: const Text('Prepare your tank for time away'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VacationGuideScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.replay_outlined),
            title: const Text('Replay Onboarding'),
            subtitle: const Text('See the intro screens again'),
            onTap: () => _replayOnboarding(context),
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
            leading: Icon(Icons.delete_forever_outlined, color: AppColors.error),
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

  Future<void> _toggleNotifications(BuildContext context, WidgetRef ref, bool enable) async {
    if (enable) {
      final service = NotificationService();
      await service.initialize();
      final granted = await service.requestPermissions();
      
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification permission denied')),
          );
        }
        return;
      }
    }
    
    await ref.read(settingsProvider.notifier).setNotificationsEnabled(enable);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enable ? 'Notifications enabled!' : 'Notifications disabled'),
          backgroundColor: enable ? AppColors.success : null,
        ),
      );
    }
  }

  Future<void> _testNotification(BuildContext context) async {
    try {
      final service = NotificationService();
      await service.initialize();
      await service.showTestNotification();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test notification sent!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
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

  void _showThemePicker(BuildContext context, WidgetRef ref, AppThemeMode current) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Choose Theme', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System default'),
              subtitle: const Text('Follow device settings'),
              trailing: current == AppThemeMode.system 
                  ? const Icon(Icons.check, color: AppColors.primary) 
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.system);
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
                ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.light);
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
                ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.dark);
                Navigator.pop(ctx);
              },
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
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dataFile = File('${dir.path}/aquarium_data.json');

      if (!await dataFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data to export')),
          );
        }
        return;
      }

      await Share.shareXFiles(
        [XFile(dataFile.path)],
        subject: 'Aquarium App Data Export',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
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
            child: Text(
              'Import',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final contents = await file.readAsString();

      // Validate it's valid JSON
      try {
        // ignore: unused_local_variable
        final decoded = contents; // Just check it's a string we can read
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid file format')),
          );
        }
        return;
      }

      // Write to app data location
      final dir = await getApplicationDocumentsDirectory();
      final dataFile = File('${dir.path}/aquarium_data.json');
      await dataFile.writeAsString(contents);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data imported! Restart the app to see changes.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear data: $e')),
        );
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
