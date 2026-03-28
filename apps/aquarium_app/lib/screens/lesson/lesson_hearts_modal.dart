import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';

/// Shows a one-time explanation of the hearts system on the user's first
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
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('❤️ Hearts'),
      content: const Text(
        'Hearts are your learning lives! You lose one per wrong quiz answer. '
        'They refill over time, or you can use gems to refill instantly.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Got it!'),
        ),
      ],
    ),
  );
}
