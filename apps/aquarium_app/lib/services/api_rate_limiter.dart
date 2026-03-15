import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-feature rate limiter for AI API calls.
///
/// Enforces a maximum of [maxRequestsPerHour] requests per feature per hour.
/// State persists across app restarts via SharedPreferences.
class ApiRateLimiter {
  static const int maxRequestsPerHour = 10;
  static const String _prefsPrefix = 'rate_limit_';

  /// In-memory cache of timestamps per feature.
  final Map<String, List<DateTime>> _timestamps = {};

  ApiRateLimiter() {
    _loadFromPrefs();
  }

  /// Check whether a request is allowed for [feature].
  /// Returns `true` if under the limit, `false` if rate-limited.
  bool canRequest(String feature) {
    _pruneOld(feature);
    final count = _timestamps[feature]?.length ?? 0;
    return count < maxRequestsPerHour;
  }

  /// How many requests remain for [feature] this hour.
  int remainingRequests(String feature) {
    _pruneOld(feature);
    final count = _timestamps[feature]?.length ?? 0;
    return (maxRequestsPerHour - count).clamp(0, maxRequestsPerHour);
  }

  /// Record a request for [feature]. Call AFTER a successful API call.
  void recordRequest(String feature) {
    _pruneOld(feature);
    _timestamps.putIfAbsent(feature, () => []);
    _timestamps[feature]!.add(DateTime.now());
    _saveToPrefs(feature);
  }

  /// How long until the next request slot opens for [feature].
  /// Returns [Duration.zero] if requests are available now.
  Duration timeUntilNextSlot(String feature) {
    _pruneOld(feature);
    final stamps = _timestamps[feature];
    if (stamps == null || stamps.length < maxRequestsPerHour) {
      return Duration.zero;
    }
    // The oldest timestamp in the window determines when a slot frees up.
    final oldest = stamps.first;
    final freeAt = oldest.add(const Duration(hours: 1));
    final remaining = freeAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // -- Private helpers --------------------------------------------------------

  void _pruneOld(String feature) {
    final stamps = _timestamps[feature];
    if (stamps == null) return;
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    stamps.removeWhere((t) => t.isBefore(cutoff));
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefsPrefix));
      final cutoff = DateTime.now().subtract(const Duration(hours: 1));
      for (final key in keys) {
        final feature = key.substring(_prefsPrefix.length);
        final raw = prefs.getStringList(key) ?? [];
        final stamps = raw
            .map((s) => DateTime.tryParse(s))
            .whereType<DateTime>()
            .where((t) => t.isAfter(cutoff))
            .toList()
          ..sort();
        if (stamps.isNotEmpty) {
          _timestamps[feature] = stamps;
        }
      }
    } catch (_) {
      // Non-critical — start with empty state.
    }
  }

  Future<void> _saveToPrefs(String feature) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stamps = _timestamps[feature] ?? [];
      await prefs.setStringList(
        '$_prefsPrefix$feature',
        stamps.map((t) => t.toIso8601String()).toList(),
      );
    } catch (_) {
      // Non-critical.
    }
  }
}

/// Well-known feature keys for rate limiting.
class AIFeature {
  static const String fishId = 'fish_id';
  static const String symptomTriage = 'symptom_triage';
  static const String weeklyPlan = 'weekly_plan';
  static const String anomalyDetector = 'anomaly_detector';
  static const String askDanio = 'ask_danio';
  static const String stockingSuggestion = 'stocking_suggestion';
  static const String compatibilityCheck = 'compatibility_check';
}

/// Singleton Riverpod provider for the rate limiter.
final apiRateLimiterProvider = Provider<ApiRateLimiter>((ref) {
  return ApiRateLimiter();
});
