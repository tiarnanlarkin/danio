import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import 'user_profile_provider.dart';

const hapticFeedbackPreferenceKey = 'haptic_feedback_enabled';

/// Theme mode preference
enum AppThemeMode { system, light, dark }

/// Settings state
class AppSettings {
  final AppThemeMode themeMode;
  final bool useMetric;
  final bool notificationsEnabled;
  final bool ambientLightingEnabled;
  final bool hapticFeedbackEnabled;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.useMetric = true,
    this.notificationsEnabled = false,
    this.ambientLightingEnabled = true,
    this.hapticFeedbackEnabled = true,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? useMetric,
    bool? notificationsEnabled,
    bool? ambientLightingEnabled,
    bool? hapticFeedbackEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      useMetric: useMetric ?? this.useMetric,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      ambientLightingEnabled:
          ambientLightingEnabled ?? this.ambientLightingEnabled,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
    );
  }

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Settings notifier for managing app preferences
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._ref) : super(const AppSettings()) {
    _loadSettings();
  }

  final Ref _ref;

  static const _themeModeKey = 'theme_mode';
  static const _useMetricKey = 'use_metric';
  static const _notificationsKey = 'notifications_enabled';
  static const _ambientLightingKey = 'ambient_lighting_enabled';

  Future<void> _loadSettings() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);

      final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
      final useMetric = prefs.getBool(_useMetricKey) ?? true;
      final notificationsEnabled = prefs.getBool(_notificationsKey) ?? false;
      final ambientLightingEnabled = prefs.getBool(_ambientLightingKey) ?? true;
      final hapticFeedbackEnabled =
          prefs.getBool(hapticFeedbackPreferenceKey) ?? true;

      state = AppSettings(
        themeMode: AppThemeMode
            .values[themeModeIndex.clamp(0, AppThemeMode.values.length - 1)],
        useMetric: useMetric,
        notificationsEnabled: notificationsEnabled,
        ambientLightingEnabled: ambientLightingEnabled,
        hapticFeedbackEnabled: hapticFeedbackEnabled,
      );
    } catch (e, stackTrace) {
      logError(
        'Failed to load app settings: $e\n$stackTrace',
        tag: 'SettingsProvider',
      );
    }
  }

  Future<bool> _persist(String key, dynamic value) async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      if (value is int) {
        return prefs.setInt(key, value);
      } else if (value is bool) {
        return prefs.setBool(key, value);
      } else if (value is String) {
        return prefs.setString(key, value);
      }
      return false;
    } catch (e, stackTrace) {
      logError(
        'Failed to persist setting "$key": $e\n$stackTrace',
        tag: 'SettingsProvider',
      );
      return false;
    }
  }

  Future<bool> setThemeMode(AppThemeMode mode) async {
    if (await _persist(_themeModeKey, mode.index)) {
      state = state.copyWith(themeMode: mode);
      return true;
    }
    return false;
  }

  Future<bool> setUseMetric(bool useMetric) async {
    if (await _persist(_useMetricKey, useMetric)) {
      state = state.copyWith(useMetric: useMetric);
      return true;
    }
    return false;
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (await _persist(_notificationsKey, enabled)) {
      state = state.copyWith(notificationsEnabled: enabled);
      return true;
    }
    return false;
  }

  Future<bool> setAmbientLightingEnabled(bool enabled) async {
    if (await _persist(_ambientLightingKey, enabled)) {
      state = state.copyWith(ambientLightingEnabled: enabled);
      return true;
    }
    return false;
  }

  Future<bool> setHapticFeedbackEnabled(bool enabled) async {
    if (await _persist(hapticFeedbackPreferenceKey, enabled)) {
      state = state.copyWith(hapticFeedbackEnabled: enabled);
      return true;
    }
    return false;
  }
}

/// Provider for app settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier(ref);
});
