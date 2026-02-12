import 'package:flutter/services.dart';

/// Centralized haptic feedback helper for consistent tactile responses.
///
/// Usage:
/// ```dart
/// HapticHelper.light();   // Taps, ripples, minor interactions
/// HapticHelper.medium();  // XP gain, feed fish, confirmations
/// HapticHelper.heavy();   // Achievements, streaks, major rewards
/// HapticHelper.selection(); // Selection changes, toggles
/// ```
///
/// All methods are fire-and-forget - they won't throw if haptics unavailable.
class HapticHelper {
  HapticHelper._();

  /// Light haptic feedback for minor interactions.
  ///
  /// Use for:
  /// - Button taps
  /// - Water ripple effects
  /// - Minor UI interactions
  /// - List item taps
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for moderate interactions.
  ///
  /// Use for:
  /// - XP gain confirmations
  /// - Feed fish action
  /// - Task completion
  /// - Successful form submission
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for major events.
  ///
  /// Use for:
  /// - Achievement unlocks
  /// - Streak milestones
  /// - Level up moments
  /// - Major rewards
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection change haptic feedback.
  ///
  /// Use for:
  /// - Toggle switches
  /// - Dropdown selections
  /// - Tab changes
  /// - Picker value changes
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for errors or warnings.
  ///
  /// Use for:
  /// - Form validation errors
  /// - Failed actions
  /// - Warnings
  static void error() {
    HapticFeedback.vibrate();
  }

  /// Success pattern - quick double tap feel.
  ///
  /// Use for:
  /// - Save successful
  /// - Action completed
  /// - Positive confirmations
  static Future<void> success() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }

  /// Celebration pattern for big moments.
  ///
  /// Use for:
  /// - First achievement
  /// - Completing onboarding
  /// - Reaching major milestones
  static Future<void> celebrate() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
  }

  /// Countdown tick - for timers and countdowns.
  ///
  /// Use for:
  /// - Timer ticks
  /// - Countdown moments
  static void tick() {
    HapticFeedback.selectionClick();
  }
}
