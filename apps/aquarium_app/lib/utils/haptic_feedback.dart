import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../providers/user_profile_provider.dart';

/// Sole product haptic boundary.
///
/// Every action reads the persisted preference before touching the platform.
/// A missing provider or preference read failure fails closed.
class AppHaptics {
  static Future<bool> _isEnabled(BuildContext context) async {
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final preferences = await container.read(
        sharedPreferencesProvider.future,
      );
      return preferences.getBool(hapticFeedbackPreferenceKey) ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Light tap - for subtle interactions (toggle, small button)
  static Future<void> light(BuildContext context) async {
    if (!await _isEnabled(context)) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium tap - for standard button presses
  static Future<void> medium(BuildContext context) async {
    if (!await _isEnabled(context)) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap - for important actions
  static Future<void> heavy(BuildContext context) async {
    if (!await _isEnabled(context)) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection - for picker/slider changes
  static Future<void> selection(BuildContext context) async {
    if (!await _isEnabled(context)) return;
    await HapticFeedback.selectionClick();
  }

  /// Success - for completed actions (save, create)
  static Future<void> success(BuildContext context) async {
    if (!await _isEnabled(context)) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error - for failed actions
  static Future<void> error(BuildContext context) async {
    if (!await _isEnabled(context)) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Vibrate - for warnings/alerts (use sparingly)
  static Future<void> vibrate(BuildContext context) async {
    if (!await _isEnabled(context)) return;
    await HapticFeedback.vibrate();
  }
}
