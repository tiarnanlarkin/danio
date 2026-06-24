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
    'unlocked_tank_decorations_v1',
    'equipped_tank_decoration_v1',
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
    'checklist_',
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
    final previousEntries = _currentExportableEntries(prefs);

    try {
      return await _replaceExportableEntries(prefs, entries);
    } catch (error, stackTrace) {
      await _replaceExportableEntries(prefs, previousEntries);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  static Map<String, dynamic> _currentExportableEntries(
    SharedPreferences prefs,
  ) {
    final snapshot = <String, dynamic>{};
    for (final key in prefs.getKeys().where(_isExportable)) {
      final value = prefs.get(key);
      if (value == null) continue;
      if (value is List<String>) {
        snapshot[key] = value.toList();
      } else {
        snapshot[key] = value;
      }
    }
    return snapshot;
  }

  static Future<int> _replaceExportableEntries(
    SharedPreferences prefs,
    Map<String, dynamic> entries,
  ) async {
    for (final key in prefs.getKeys().where(_isExportable).toList()) {
      await _removePreference(prefs, key);
    }

    var restored = 0;
    for (final entry in entries.entries) {
      final key = entry.key;
      final value = entry.value;
      if (!_isExportable(key)) continue;
      if (value == null) continue;

      await _writePreference(prefs, key, value);
      restored++;
    }

    return restored;
  }

  static Future<void> _removePreference(
    SharedPreferences prefs,
    String key,
  ) async {
    final removed = await prefs.remove(key);
    if (!removed) {
      throw StateError('Could not clear preference $key');
    }
  }

  static Future<void> _writePreference(
    SharedPreferences prefs,
    String key,
    Object value,
  ) async {
    final saved = switch (value) {
      bool() => await prefs.setBool(key, value),
      int() => await prefs.setInt(key, value),
      double() => await prefs.setDouble(key, value),
      String() => await prefs.setString(key, value),
      List() => await prefs.setStringList(
        key,
        value.map((item) => item.toString()).toList(),
      ),
      _ => throw StateError('Unsupported preference value for $key'),
    };

    if (!saved) {
      throw StateError('Could not restore preference $key');
    }
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
