import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../providers/settings_provider.dart';
import '../services/onboarding_service.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'shop_street_screen.dart';

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
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Export All Data'),
            subtitle: const Text('Share your aquarium data as JSON'),
            onTap: () => _exportData(context),
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
            leading: const Icon(Icons.replay_outlined),
            title: const Text('Replay Onboarding'),
            subtitle: const Text('See the intro screens again'),
            onTap: () => _replayOnboarding(context),
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
