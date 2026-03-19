import 'package:flutter/services.dart';

/// Centralized haptic feedback for consistent tactile responses
///
/// Each method accepts [enabled] which should be read from the user's
/// haptic feedback setting. Falls back to true for backward compatibility
/// but all new call sites MUST pass the setting explicitly.
///
/// Usage:
/// ```dart
/// final enabled = ref.read(settingsProvider).hapticFeedbackEnabled;
/// AppHaptics.light(enabled: enabled);
/// ```
class AppHaptics {
  /// Light tap - for subtle interactions (toggle, small button)
  static Future<void> light({bool enabled = true}) async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium tap - for standard button presses
  static Future<void> medium({bool enabled = true}) async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap - for important actions
  static Future<void> heavy({bool enabled = true}) async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection - for picker/slider changes
  static Future<void> selection({bool enabled = true}) async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Success - for completed actions (save, create)
  static Future<void> success({bool enabled = true}) async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error - for failed actions
  static Future<void> error({bool enabled = true}) async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Vibrate - for warnings/alerts (use sparingly)
  static Future<void> vibrate({bool enabled = true}) async {
    if (!enabled) return;
    await HapticFeedback.vibrate();
  }
}
