import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Systematic in-app review prompt service.
///
/// Triggers at positive moments: after completing lessons, reaching levels,
/// or achieving streaks. Shows at most once per user.
///
/// Usage:
/// ```dart
/// await RateService.maybeShowReview(
///   lessonsCompleted: 5,
///   userLevel: 3,
///   currentStreak: 2,
/// );
/// ```
class RateService {
  static const _prefKey = 'review_requested';
  static const _minLessons = 5;
  static const _minLevel = 5;
  static const _minStreak = 7;

  static Future<SharedPreferences> Function() _sharedPreferencesFactory =
      SharedPreferences.getInstance;
  static Future<bool> Function() _isReviewAvailable = () {
    return InAppReview.instance.isAvailable();
  };
  static Future<void> Function() _requestReview = () {
    return InAppReview.instance.requestReview();
  };

  @visibleForTesting
  static void overrideDependenciesForTesting({
    Future<SharedPreferences> Function()? sharedPreferencesFactory,
    Future<bool> Function()? isReviewAvailable,
    Future<void> Function()? requestReview,
  }) {
    _sharedPreferencesFactory =
        sharedPreferencesFactory ?? _sharedPreferencesFactory;
    _isReviewAvailable = isReviewAvailable ?? _isReviewAvailable;
    _requestReview = requestReview ?? _requestReview;
  }

  @visibleForTesting
  static void resetDependenciesForTesting() {
    _sharedPreferencesFactory = SharedPreferences.getInstance;
    _isReviewAvailable = () => InAppReview.instance.isAvailable();
    _requestReview = () => InAppReview.instance.requestReview();
  }

  /// Check conditions and show the in-app review dialog if appropriate.
  ///
  /// Triggers when ANY of these conditions are met:
  /// - Completed >= [minLessons] lessons (default 5)
  /// - Reached >= [minLevel] user level (default 5)
  /// - Current streak >= [minStreak] days (default 7)
  ///
  /// Returns `true` if the review was requested and the local tracking flag was
  /// saved, `false` otherwise.
  static Future<bool> maybeShowReview({
    int lessonsCompleted = 0,
    int userLevel = 0,
    int currentStreak = 0,
    int minLessons = _minLessons,
    int minLevel = _minLevel,
    int minStreak = _minStreak,
    bool force = false,
  }) async {
    try {
      final prefs = await _sharedPreferencesFactory();
      final alreadyRequested = prefs.getBool(_prefKey) ?? false;
      if (alreadyRequested) return false;

      final shouldShow =
          force ||
          lessonsCompleted >= minLessons ||
          userLevel >= minLevel ||
          currentStreak >= minStreak;

      if (!shouldShow) return false;

      if (!await _isReviewAvailable()) return false;

      await _requestReview();
      final saved = await prefs.setBool(_prefKey, true);
      if (!saved) {
        throw StateError('SharedPreferences returned false for $_prefKey');
      }
      return true;
    } catch (e) {
      logError('In-app review failed: $e', tag: 'RateService');
      return false;
    }
  }

  /// Check if the review prompt has already been shown.
  static Future<bool> hasRequestedReview() async {
    final prefs = await _sharedPreferencesFactory();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Reset the review flag (for testing only).
  static Future<void> resetForTesting() async {
    final prefs = await _sharedPreferencesFactory();
    if (!prefs.containsKey(_prefKey)) return;
    final removed = await prefs.remove(_prefKey);
    if (!removed) {
      throw StateError('SharedPreferences returned false for $_prefKey');
    }
  }
}
