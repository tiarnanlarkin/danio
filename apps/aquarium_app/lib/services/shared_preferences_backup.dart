import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Exports and restores SharedPreferences data so that learning progress,
/// gems, user profile, and other non-tank state survive data wipes or
/// device transfers.
///
/// Usage:
/// ```dart
/// final backup = SharedPreferencesBackup.export();
/// final map = jsonDecode(backup) as Map<String, dynamic>;
/// await SharedPreferencesBackup.restore(map);
/// ```
class SharedPreferencesBackup {
  /// Keys that are safe to export/import (user data, not device-specific
  /// settings or transient flags).
  static const _exportablePrefixes = [
    'user_profile',
    'gems_state',
    'gems_cumulative',
    'shop_inventory',
    'settings_',
    'onboarding_',
    'daily_goal_',
    'ai_interaction_history',
    'anomaly_history',
    'weekly_plan_cache',
    'spaced_repetition_',
    'reduced_motion',
    'haptic_feedback',
    'analytics_consent',
    'streak_freeze',
    'daily_xp',
    'lesson_progress',
    'completed_lessons',
    'cost_tracker',
  ];

  static const _metadataKey = '__backup_version';
  static const _currentVersion = 1;

  /// Export all exportable SharedPreferences as a JSON string.
  ///
  /// The result can be written to a file, shared, or stored remotely.
  static Future<String> exportAsJson() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final Map<String, dynamic> export = {
      _metadataKey: _currentVersion,
      'exportDate': DateTime.now().toUtc().toIso8601String(),
      'entries': <String, dynamic>{},
    };

    final entries = export['entries'] as Map<String, dynamic>;

    for (final key in keys) {
      if (_isExportable(key)) {
        entries[key] = prefs.get(key);
      }
    }

    return const JsonEncoder.withIndent('  ').convert(export);
  }

  /// Restore SharedPreferences from a previously exported JSON map.
  ///
  /// [warnCallback] is invoked with the number of entries that will be
  /// overwritten so the UI can show a confirmation dialog.
  ///
  /// Returns the number of entries restored.
  static Future<int> restoreFromJson(
    Map<String, dynamic> data, {
    bool skipConfirmation = false,
  }) async {
    final entries = data['entries'];
    if (entries == null || entries is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup: missing entries map');
    }

    final prefs = await SharedPreferences.getInstance();

    // Clear existing exportable keys first so stale data doesn't linger.
    for (final key in entries.keys) {
      if (_isExportable(key)) {
        await prefs.remove(key);
      }
    }

    // Write each entry with the correct type.
    for (final entry in entries.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value == null) continue;

      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List) {
        await prefs.setStringList(
          key,
          value.map((e) => e.toString()).toList(),
        );
      }
    }

    return entries.length;
  }

  /// Check whether a given SharedPreferences key should be included in
  /// backups.
  static bool _isExportable(String key) {
    // Skip our own metadata key.
    if (key == _metadataKey) return false;
    // Skip internal/flutter keys.
    if (key.startsWith('flutter.') || key.startsWith('package:')) return false;

    return _exportablePrefixes.any((prefix) => key.startsWith(prefix));
  }
}
