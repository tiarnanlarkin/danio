import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_dialog.dart';

/// Shows a one-time explanation of the energy system on the user's first
/// lesson.  Call from [initState] via [WidgetsBinding.addPostFrameCallback].
Future<void> maybeExplainHearts(
  BuildContext context,
  WidgetRef ref, {
  required bool isPracticeMode,
}) async {
  if (isPracticeMode) return;
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final explained = prefs.getBool('hearts_explained') ?? false;
  if (explained) return;
  await prefs.setBool('hearts_explained', true);
  if (!context.mounted) return;
  showAppDialog(
    context: context,
    title: '⚡ Energy',
    child: const Text(
      'Energy gives you bonus XP! You lose a little per wrong answer, '
      'and it refills over time (1 charge every 30 minutes). '
      'Running out never stops you learning — it just pauses the bonus.',
    ),
    actions: [
      AppButton(
        label: 'Got it!',
        onPressed: () => Navigator.of(context).pop(),
        variant: AppButtonVariant.text,
        isFullWidth: true,
      ),
    ],
  );
}
