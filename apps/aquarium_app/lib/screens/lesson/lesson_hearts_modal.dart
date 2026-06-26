import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';
import '../../utils/logger.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_dialog.dart';

/// Shows an explanation of the energy system when the user asks for it.
Future<void> maybeExplainHearts(
  BuildContext context,
  WidgetRef ref, {
  required bool isPracticeMode,
}) async {
  if (isPracticeMode) return;
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final explained = prefs.getBool('hearts_explained') ?? false;
  if (explained) return;
  if (!context.mounted) return;
  await showAppDialog<void>(
    context: context,
    title: 'Energy',
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
  if (!context.mounted) return;
  try {
    final saved = await prefs.setBool('hearts_explained', true);
    if (!saved) {
      logError(
        'Energy explainer dismissal flag failed to save.',
        tag: 'LessonHeartsModal',
      );
    }
  } catch (e, st) {
    logError(
      'Energy explainer dismissal flag failed to save: $e',
      stackTrace: st,
      tag: 'LessonHeartsModal',
    );
  }
}
