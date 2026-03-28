import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_profile_provider.dart';
import '../utils/logger.dart';

/// Reduced motion state and configuration
class ReducedMotionState {
  /// Whether reduced motion is enabled (system OR user preference)
  final bool isEnabled;

  /// System-level reduced motion setting
  final bool systemPreference;

  /// User's manual override (null = follow system)
  final bool? userOverride;

  const ReducedMotionState({
    required this.isEnabled,
    required this.systemPreference,
    this.userOverride,
  });

  ReducedMotionState copyWith({
    bool? isEnabled,
    bool? systemPreference,
    bool? userOverride,
  }) {
    return ReducedMotionState(
      isEnabled: isEnabled ?? this.isEnabled,
      systemPreference: systemPreference ?? this.systemPreference,
      userOverride: userOverride ?? this.userOverride,
    );
  }

  /// Get effective duration multiplier for animations
  /// Returns 1.0 for normal, 0.0 for instant (disabled), 0.3 for reduced
  double get durationMultiplier => isEnabled ? 0.3 : 1.0;

  /// Get whether to show simplified animations vs disabled completely
  bool get useSimplifiedAnimations => isEnabled;

  /// Get whether to disable decorative animations completely
  bool get disableDecorativeAnimations => isEnabled;
}

/// Notifier for managing reduced motion settings
class ReducedMotionNotifier extends StateNotifier<ReducedMotionState> {
  final Ref ref;
  ReducedMotionNotifier(this.ref)
    : super(
        const ReducedMotionState(isEnabled: false, systemPreference: false),
      ) {
    _initialize();
  }

  static const _userOverrideKey = 'reduced_motion_override';

  Future<void> _initialize() async {
    // Load saved user preference
    await _loadUserPreference();

    // Check system setting
    await _checkSystemSetting();
  }

  /// Load user's manual override from storage
  Future<void> _loadUserPreference() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);

      // Check if user has set a manual override
      if (prefs.containsKey(_userOverrideKey)) {
        final override = prefs.getBool(_userOverrideKey);
        state = state.copyWith(
          userOverride: override,
          isEnabled: override ?? state.systemPreference,
        );
      }
    } catch (e) {
      logError('Failed to load reduced motion preference: $e', tag: 'ReducedMotionProvider');
    }
  }

  /// Check Android system setting for reduced motion
  Future<void> _checkSystemSetting() async {
    try {
      // Access Android's ANIMATOR_DURATION_SCALE setting
      // When animations are disabled system-wide, this returns 0.0
      final systemSetting = await _getSystemAnimationScale();
      final systemPreference = systemSetting == 0.0;

      state = state.copyWith(
        systemPreference: systemPreference,
        isEnabled: state.userOverride ?? systemPreference,
      );
    } catch (e) {
      logError('Failed to check system animation setting: $e', tag: 'ReducedMotionProvider');
      // Fall back to user preference or default
    }
  }

  /// Get system animation scale via platform channel
  Future<double> _getSystemAnimationScale() async {
    try {
      const platform = MethodChannel(
        'com.tiarnanlarkin.aquarium/accessibility',
      );
      final result = await platform.invokeMethod<double>('getAnimationScale');
      return result ?? 1.0;
    } catch (e) {
      // If platform channel not implemented, fall back to default
      appLog('ReducedMotionProvider: platform channel unavailable, defaulting to 1.0: $e', tag: 'ReducedMotionProvider');
      return 1.0;
    }
  }

  /// Set user's manual override preference
  Future<void> setUserPreference(bool? enabled) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);

      if (enabled == null) {
        // Clear override - follow system
        await prefs.remove(_userOverrideKey);
        state = state.copyWith(
          userOverride: null,
          isEnabled: state.systemPreference,
        );
      } else {
        // Set manual override
        await prefs.setBool(_userOverrideKey, enabled);
        state = state.copyWith(userOverride: enabled, isEnabled: enabled);
      }
    } catch (e) {
      logError('Failed to save reduced motion preference: $e', tag: 'ReducedMotionProvider');
    }
  }

  /// Refresh system setting (call when app resumes)
  Future<void> refresh() async {
    await _checkSystemSetting();
  }
}

/// Provider for reduced motion state
final reducedMotionProvider =
    StateNotifierProvider<ReducedMotionNotifier, ReducedMotionState>(
      (ref) => ReducedMotionNotifier(ref),
    );

/// Extension to get reduced motion state easily in widgets
extension ReducedMotionBuildContext on BuildContext {
  /// Quick access to reduced motion state
  ReducedMotionState get reducedMotion {
    // Note: This requires ProviderScope to be available
    // Use WidgetRef.read(reducedMotionProvider) in ConsumerWidget instead
    throw UnimplementedError(
      'Use ref.watch(reducedMotionProvider) in ConsumerWidget instead',
    );
  }
}

/// Helper functions for animation durations
class ReducedMotionHelper {
  /// Get duration adjusted for reduced motion
  static Duration duration(
    Duration normal,
    ReducedMotionState state, {
    bool canDisable = false,
  }) {
    if (!state.isEnabled) return normal;

    if (canDisable) {
      // For decorative animations, disable completely
      return Duration.zero;
    } else {
      // For functional animations, reduce duration
      return normal * state.durationMultiplier;
    }
  }

  /// Get curve adjusted for reduced motion
  static Curve curve(Curve normal, ReducedMotionState state) {
    if (state.isEnabled) {
      // Use linear curve for reduced motion (less jarring)
      return Curves.linear;
    }
    return normal;
  }
}
