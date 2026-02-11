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

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.useMetric = true,
    this.notificationsEnabled = false,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? useMetric,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      useMetric: useMetric ?? this.useMetric,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
    final useMetric = prefs.getBool(_useMetricKey) ?? true;
    final notificationsEnabled = prefs.getBool(_notificationsKey) ?? false;

    state = AppSettings(
      themeMode: AppThemeMode
          .values[themeModeIndex.clamp(0, AppThemeMode.values.length - 1)],
      useMetric: useMetric,
      notificationsEnabled: notificationsEnabled,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> setUseMetric(bool useMetric) async {
    state = state.copyWith(useMetric: useMetric);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useMetricKey, useMetric);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }
}

/// Provider for app settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});
