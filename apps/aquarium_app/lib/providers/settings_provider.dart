import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode preference
enum AppThemeMode { system, light, dark }

/// Settings state
class AppSettings {
  final AppThemeMode themeMode;
  final bool useMetric;
  final bool notificationsEnabled;
  final bool ambientLightingEnabled;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.useMetric = true,
    this.notificationsEnabled = false,
    this.ambientLightingEnabled = true,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? useMetric,
    bool? notificationsEnabled,
    bool? ambientLightingEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      useMetric: useMetric ?? this.useMetric,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      ambientLightingEnabled: ambientLightingEnabled ?? this.ambientLightingEnabled,
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
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  static const _themeModeKey = 'theme_mode';
  static const _useMetricKey = 'use_metric';
  static const _notificationsKey = 'notifications_enabled';
  static const _ambientLightingKey = 'ambient_lighting_enabled';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
      final useMetric = prefs.getBool(_useMetricKey) ?? true;
      final notificationsEnabled = prefs.getBool(_notificationsKey) ?? false;
      final ambientLightingEnabled = prefs.getBool(_ambientLightingKey) ?? true;

      state = AppSettings(
        themeMode: AppThemeMode
            .values[themeModeIndex.clamp(0, AppThemeMode.values.length - 1)],
        useMetric: useMetric,
        notificationsEnabled: notificationsEnabled,
        ambientLightingEnabled: ambientLightingEnabled,
      );
    } catch (e) {
      // If loading fails, keep default settings
      // Don't crash the app - user can still use it with defaults
      debugPrint('Failed to load app settings: $e');
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      debugPrint('Failed to save theme mode setting: $e');
      // Setting is applied in-memory, just won't persist
    }
  }

  Future<void> setUseMetric(bool useMetric) async {
    state = state.copyWith(useMetric: useMetric);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useMetricKey, useMetric);
    } catch (e) {
      debugPrint('Failed to save metric preference: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);
    } catch (e) {
      debugPrint('Failed to save notification preference: $e');
    }
  }

  Future<void> setAmbientLightingEnabled(bool enabled) async {
    state = state.copyWith(ambientLightingEnabled: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_ambientLightingKey, enabled);
    } catch (e) {
      debugPrint('Failed to save ambient lighting preference: $e');
    }
  }
}

/// Provider for app settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});
