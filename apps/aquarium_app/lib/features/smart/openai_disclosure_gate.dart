import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_profile_provider.dart';
import '../../utils/logger.dart';
import '../../widgets/core/app_dialog.dart';
import '../../widgets/danio_snack_bar.dart';
import 'ai_disclosure_preferences.dart';

const _saveFailureMessage = 'Couldn\'t save AI disclosure. Try again.';

/// Ensures the user has accepted Danio's Optional AI data disclosure before an
/// OpenAI request can send photos, text, or aquarium context off-device.
Future<bool> ensureOpenAIDisclosureAccepted({
  required WidgetRef ref,
  required BuildContext context,
  required String logTag,
  required String message,
  void Function(String message)? onSaveFailure,
}) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  if (AiDisclosurePreferences.isAccepted(prefs)) return true;

  if (!context.mounted) return false;
  final accepted = await showAppConfirmDialog(
    context: context,
    title: 'OpenAI Data Disclosure',
    message: message,
    confirmLabel: 'I Understand',
    cancelLabel: 'Cancel',
    barrierDismissible: false,
  );

  if (accepted == true) {
    try {
      await AiDisclosurePreferences.markAccepted(prefs);
    } catch (e, st) {
      logError(
        '$logTag: failed to save AI disclosure acceptance: $e',
        stackTrace: st,
        tag: logTag,
      );
      if (context.mounted) {
        if (onSaveFailure != null) {
          onSaveFailure(_saveFailureMessage);
        } else {
          DanioSnackBar.warning(context, _saveFailureMessage);
        }
      }
      return false;
    }
    return true;
  }
  return false;
}
