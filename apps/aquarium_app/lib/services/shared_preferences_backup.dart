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
  /// Exact keys that are safe to export/import: user data and preferences,
  /// not device-specific secrets, legal consent flags, or transient queues.
  static const _exportableExactKeys = [
    'user_profile',
    'user_skill_profile',
    'gems_state',
    'gems_cumulative',
    'shop_inventory',
    'theme_mode',
    'use_metric',
    'notifications_enabled',
    'ambient_lighting_enabled',
    'haptic_feedback_enabled',
    'onboarding_completed',
    'ai_interaction_history',
    'anomaly_history',
    'weekly_plan_cache',
    'reduced_motion_override',
    'streak_freeze',
    'achievement_progress',
    'room_theme',
    'unlocked_species_v1',
    'wishlist_items',
    'shop_budget',
    'local_shops',
    'cost_tracker_expenses',
    'cost_tracker_currency',
    'aquarium_reminders',
  ];

  /// Prefixes for grouped user data keys.
  static const _exportablePrefixes = [
    'onboarding_',
    'daily_goal_',
    'spaced_repetition_',
    'daily_xp',
    'lesson_progress',
    'completed_lessons',
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

    _validateRestorableEntries(entries);

    final prefs = await SharedPreferences.getInstance();

    // Clear all existing exportable keys first so stale data from an older
    // profile or a backup with fewer keys cannot linger after restore.
    for (final key in prefs.getKeys().where(_isExportable).toList()) {
      await prefs.remove(key);
    }

    // Write each entry with the correct type.
    var restored = 0;
    for (final entry in entries.entries) {
      final key = entry.key;
      final value = entry.value;
      if (!_isExportable(key)) continue;
      if (value == null) continue;

      if (value is bool) {
        await prefs.setBool(key, value);
        restored++;
      } else if (value is int) {
        await prefs.setInt(key, value);
        restored++;
      } else if (value is double) {
        await prefs.setDouble(key, value);
        restored++;
      } else if (value is String) {
        await prefs.setString(key, value);
        restored++;
      } else if (value is List) {
        await prefs.setStringList(key, value.map((e) => e.toString()).toList());
        restored++;
      }
    }

    return restored;
  }

  static void _validateRestorableEntries(Map<String, dynamic> entries) {
    for (final entry in entries.entries) {
      final key = entry.key;
      final value = entry.value;
      if (!_isExportable(key)) continue;

      if (value is List) {
        if (value.any((item) => item is! String)) {
          throw FormatException(
            'Invalid backup: string list preference $key contains non-string values',
          );
        }
        continue;
      }

      if (value is! bool &&
          value is! int &&
          value is! double &&
          value is! String) {
        throw FormatException(
          'Invalid backup: unsupported preference value for $key',
        );
      }
    }
  }

  /// Check whether a given SharedPreferences key should be included in
  /// backups.
  static bool isExportableKey(String key) => _isExportable(key);

  static bool _isExportable(String key) {
    // Skip our own metadata key.
    if (key == _metadataKey) return false;
    // Skip internal/flutter keys.
    if (key.startsWith('flutter.') || key.startsWith('package:')) return false;

    return _exportableExactKeys.contains(key) ||
        _exportablePrefixes.any((prefix) => key.startsWith(prefix));
  }
}
