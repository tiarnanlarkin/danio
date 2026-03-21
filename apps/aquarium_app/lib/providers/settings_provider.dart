import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:danio/utils/logger.dart';
import 'user_profile_provider.dart';

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
  static const _hapticFeedbackKey = 'haptic_feedback_enabled';

  Future<void> _loadSettings() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);

      final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
      final useMetric = prefs.getBool(_useMetricKey) ?? true;
      final notificationsEnabled = prefs.getBool(_notificationsKey) ?? false;
      final ambientLightingEnabled = prefs.getBool(_ambientLightingKey) ?? true;
      final hapticFeedbackEnabled = prefs.getBool(_hapticFeedbackKey) ?? true;

      state = AppSettings(
        themeMode: AppThemeMode
            .values[themeModeIndex.clamp(0, AppThemeMode.values.length - 1)],
        useMetric: useMetric,
        notificationsEnabled: notificationsEnabled,
        ambientLightingEnabled: ambientLightingEnabled,
        hapticFeedbackEnabled: hapticFeedbackEnabled,
      );
    } catch (e, stackTrace) {
      logError('Failed to load app settings: $e\n$stackTrace', tag: 'SettingsProvider');
    }
  }

  Future<void> _persist(String key, dynamic value) async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e, stackTrace) {
      logError('Failed to persist setting "$key": $e\n$stackTrace', tag: 'SettingsProvider');
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist(_themeModeKey, mode.index);
  }

  Future<void> setUseMetric(bool useMetric) async {
    state = state.copyWith(useMetric: useMetric);
    await _persist(_useMetricKey, useMetric);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _persist(_notificationsKey, enabled);
  }

  Future<void> setAmbientLightingEnabled(bool enabled) async {
    state = state.copyWith(ambientLightingEnabled: enabled);
    await _persist(_ambientLightingKey, enabled);
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    state = state.copyWith(hapticFeedbackEnabled: enabled);
    await _persist(_hapticFeedbackKey, enabled);
  }
}

/// Provider for app settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier(ref);
});
