import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/onboarding_provider.dart';
import '../../services/onboarding_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/core/app_list_tile.dart';
import '../../widgets/core/app_button.dart';

/// Data section for the settings screen.
/// Handles export, import, photo storage info, and clear/delete data actions.
class SettingsDataSection extends StatelessWidget {
  final WidgetRef ref;

  const SettingsDataSection({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppListTile(
          leading: const Icon(Icons.upload_outlined),
          title: 'Export All Data',
          subtitle: 'Share your aquarium data as JSON',
          onTap: () => exportData(context),
        ),
        AppListTile(
          leading: const Icon(Icons.download_outlined),
          title: 'Import Data',
          subtitle: 'Replace all app data with a backup file',
          onTap: () => importData(context),
        ),
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

/// Export all data as a JSON file.
Future<void> exportData(BuildContext context) async {
  if (!context.mounted) return;

  AppFeedback.showLoading(context, 'Preparing export...');
  var dismissLoadingInFinally = true;

  try {
    final dir = await getApplicationDocumentsDirectory();
    final dataFile = File('${dir.path}/aquarium_data.json');

    if (!await dataFile.exists()) {
      if (context.mounted) {
        AppFeedback.dismiss(context);
        dismissLoadingInFinally = false;
        AppFeedback.showInfo(
          context,
          'Nothing to export yet — start logging to build your data!',
        );
      }
      return;
    }

    await Share.shareXFiles([XFile(dataFile.path)],
        subject: 'Danio Data Export');
  } catch (e) {
    if (context.mounted) {
      AppFeedback.dismiss(context);
      dismissLoadingInFinally = false;
      AppFeedback.showError(
        context,
        'Export didn\'t work. Give it another go!',
      );
    }
  } finally {
    if (context.mounted && dismissLoadingInFinally) {
      AppFeedback.dismiss(context);
    }
  }
}

/// Import data from a user-selected JSON file.
Future<void> importData(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Replace all data?'),
      content: const Text(
        'This will overwrite your current tanks, fish, logs, and settings with the backup file. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, false);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, true);
          },
          child: const Text('Replace'),
        ),
      ],
    ),
  );

  if (confirm != true || !context.mounted) return;

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

  AppFeedback.showLoading(context, 'Importing data...');
  var dismissLoadingInFinally = true;

  try {
    final file = File(filePath);
    final contents = await file.readAsString();

    dynamic decoded;
    try {
      decoded = jsonDecode(contents);
    } on FormatException {
      if (context.mounted) {
        AppFeedback.dismiss(context);
        dismissLoadingInFinally = false;
        AppFeedback.showError(
          context,
          'Invalid backup file — expected Danio export format',
        );
      }
      return;
    }

    if (decoded is! Map ||
        !decoded.containsKey('tanks') ||
        !decoded.containsKey('livestock') ||
        !decoded.containsKey('logs')) {
      if (context.mounted) {
        AppFeedback.dismiss(context);
        dismissLoadingInFinally = false;
        AppFeedback.showError(
          context,
          'Invalid backup file — expected Danio export format',
        );
      }
      return;
    }

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
      AppFeedback.showError(
        context,
        'Import failed. The file may be invalid or corrupted.',
      );
    }
  } finally {
    if (context.mounted && dismissLoadingInFinally) {
      AppFeedback.dismiss(context);
    }
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Photo Storage'),
        content: Column(
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
          TextButton(
            onPressed: () => Navigator.maybePop(ctx),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }
}

/// Confirm and clear all local data.
Future<void> confirmClearData(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Clear All Data?'),
      content: const Text(
        'This will permanently delete all your tanks, logs, tasks, and photos. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, false);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, true);
          },
          child: Text(
            'Delete Everything',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final reallyConfirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Are you absolutely sure?'),
      content: const Text('All data will be lost forever.'),
      actions: [
        TextButton(
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, false);
          },
          child: const Text('No, keep my data'),
        ),
        TextButton(
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, true);
          },
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
  } catch (e) {
    if (context.mounted) {
      AppFeedback.showError(context, 'Couldn\'t clear data. Try again!');
    }
  }
}

/// GDPR "Delete My Data" — clears all local data and navigates to onboarding.
Future<void> confirmDeleteMyData(
  BuildContext context,
  WidgetRef ref,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete My Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will permanently delete all your local data '
            '(tanks, progress, achievements). This cannot be undone.',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'For server-side data deletion requests, email '
            'larkintiarnanbizz@gmail.com',
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, false);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, true);
          },
          child: Text(
            'Delete Everything',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
  } catch (e) {
    if (context.mounted) {
      AppFeedback.showError(context, 'Couldn\'t delete data. Try again!');
    }
  }
}
