import 'package:flutter/services.dart';

/// Centralized haptic feedback for consistent tactile responses
///
/// Usage:
/// ```dart
/// AppHaptics.light(); // Subtle tap
/// AppHaptics.medium(); // Button press
/// AppHaptics.success(); // Success action
/// ```
class AppHaptics {
  /// Light tap - for subtle interactions (toggle, small button)
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium tap - for standard button presses
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap - for important actions
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection - for picker/slider changes
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Success - for completed actions (save, create)
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error - for failed actions
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Vibrate - for warnings/alerts (use sparingly)
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
