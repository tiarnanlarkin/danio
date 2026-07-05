import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/onboarding_provider.dart';
import '../../services/onboarding_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/core/app_list_tile.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_dialog.dart';
import '../../utils/logger.dart';

/// Data section for the settings screen.
/// Handles photo storage info. Backup export/import lives in Backup & Restore.
class SettingsDataSection extends StatelessWidget {
  final WidgetRef ref;

  const SettingsDataSection({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: 'Photo Storage',
          subtitle: 'View where photos are stored',
          onTap: () => showPhotoStorageInfo(context),
        ),
      ],
    );
  }
}

/// Show a dialog with photo storage path info.
Future<void> showPhotoStorageInfo(BuildContext context) async {
  final dir = await getApplicationDocumentsDirectory();
  final photoDir = Directory('${dir.path}/photos');
  final exists = await photoDir.exists();

  int photoCount = 0;
  if (exists) {
    photoCount = await photoDir.list().length;
  }

  if (context.mounted) {
    showAppDialog(
      context: context,
      title: 'Photo Storage',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location:\n${photoDir.path}'),
          const SizedBox(height: AppSpacing.md),
          Text('Photos stored: $photoCount'),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Photos are stored locally on your device in the app\'s documents folder.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Got It',
          onPressed: () => Navigator.maybePop(context),
          variant: AppButtonVariant.text,
          isFullWidth: true,
        ),
      ],
    );
  }
}

/// Confirm and clear all local data.
Future<void> confirmClearData(BuildContext context, WidgetRef ref) async {
  final confirmed = await showAppDestructiveDialog(
    context: context,
    title: 'Clear All Data?',
    message:
        'This will permanently delete all your tanks, logs, tasks, and photos. This cannot be undone.',
    destructiveLabel: 'Delete Everything',
  );

  if (confirmed != true || !context.mounted) return;

  final reallyConfirmed = await showAppDestructiveDialog(
    context: context,
    title: 'Are you absolutely sure?',
    message: 'All data will be lost forever.',
    destructiveLabel: 'Yes, delete everything',
    cancelLabel: 'No, keep my data',
  );

  if (reallyConfirmed != true || !context.mounted) return;

  try {
    final dir = await getApplicationDocumentsDirectory();
    final dataFile = File('${dir.path}/aquarium_data.json');
    if (await dataFile.exists()) await dataFile.delete();
    final photoDir = Directory('${dir.path}/photos');
    if (await photoDir.exists()) await photoDir.delete(recursive: true);
    final service = await OnboardingService.getInstance();
    await service.resetOnboarding();

    if (context.mounted) {
      ref.invalidate(onboardingCompletedProvider);
      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);
    }
  } catch (e, st) {
    logError(
      'SettingsDataSection: clear data failed: $e',
      stackTrace: st,
      tag: 'SettingsDataSection',
    );
    if (context.mounted) {
      AppFeedback.showError(context, 'Couldn\'t clear data. Try again!');
    }
  }
}

/// GDPR "Delete My Data" - clears all local data and navigates to onboarding.
Future<void> confirmDeleteMyData(BuildContext context, WidgetRef ref) async {
  final confirmed = await showAppDialog<bool>(
    context: context,
    title: 'Delete My Data',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This will permanently delete all your local data '
          '(tanks, progress, achievements). This cannot be undone.',
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'For privacy or data help, email '
          'larkintiarnanbizz@gmail.com',
          style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Crash reports held by Google expire after 90 days. '
          'To request earlier deletion, contact larkintiarnanbizz@gmail.com.',
          style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    ),
    actions: [
      AppButton(
        label: 'Cancel',
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context, false);
        },
        variant: AppButtonVariant.text,
        isFullWidth: true,
      ),
      const SizedBox(height: AppSpacing.xs),
      AppButton(
        label: 'Delete Everything',
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context, true);
        },
        variant: AppButtonVariant.destructive,
        isFullWidth: true,
      ),
    ],
  );

  if (confirmed != true || !context.mounted) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    final prefsCleared = await prefs.clear();
    if (!prefsCleared) {
      throw StateError('SharedPreferences clear returned false.');
    }
    final dir = await getApplicationDocumentsDirectory();
    final dataFile = File('${dir.path}/aquarium_data.json');
    if (await dataFile.exists()) await dataFile.delete();
    final photoDir = Directory('${dir.path}/photos');
    if (await photoDir.exists()) await photoDir.delete(recursive: true);
    final service = await OnboardingService.getInstance();
    await service.resetOnboarding();

    if (context.mounted) {
      ref.invalidate(onboardingCompletedProvider);
      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);
    }
  } catch (e, st) {
    logError(
      'SettingsDataSection: delete data failed: $e',
      stackTrace: st,
      tag: 'SettingsDataSection',
    );
    if (context.mounted) {
      AppFeedback.showError(context, 'Couldn\'t delete data. Try again!');
    }
  }
}
