import 'package:flutter/foundation.dart';

/// Debug-only state overrides for QA testing.
/// All fields are no-ops in release builds (tree-shaken).
class DebugStateOverrides {
  DebugStateOverrides._();

  /// When true, async providers should return AsyncLoading state.
  static bool forceLoading = false;

  /// When true, async providers should return AsyncError state.
  static bool forceError = false;

  /// Custom error message for forceError.
  static String forceErrorMessage = 'QA simulated error';

  /// When true, tank list should appear empty regardless of data.
  static bool forceEmptyTanks = false;

  /// Reset all overrides to defaults.
  static void reset() {
    forceLoading = false;
    forceError = false;
    forceErrorMessage = 'QA simulated error';
    forceEmptyTanks = false;
  }

  /// Returns a list of currently active (non-default) override names.
  static List<String> get activeOverrides {
    if (!kDebugMode) return const [];
    final active = <String>[];
    if (forceLoading) active.add('forceLoading');
    if (forceError) active.add('forceError');
    if (forceEmptyTanks) active.add('forceEmptyTanks');
    return active;
  }

  /// Returns true if any override is active.
  static bool get hasActiveOverrides => activeOverrides.isNotEmpty;
}
