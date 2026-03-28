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

  /// Check conditions and show the in-app review dialog if appropriate.
  ///
  /// Triggers when ANY of these conditions are met:
  /// - Completed >= [minLessons] lessons (default 5)
  /// - Reached >= [minLevel] user level (default 5)
  /// - Current streak >= [minStreak] days (default 7)
  ///
  /// Returns `true` if the review was shown, `false` otherwise.
  static Future<bool> maybeShowReview({
    int lessonsCompleted = 0,
    int userLevel = 0,
    int currentStreak = 0,
    int minLessons = _minLessons,
    int minLevel = _minLevel,
    int minStreak = _minStreak,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyRequested = prefs.getBool(_prefKey) ?? false;
      if (alreadyRequested) return false;

      final shouldShow = lessonsCompleted >= minLessons ||
          userLevel >= minLevel ||
          currentStreak >= minStreak;

      if (!shouldShow) return false;

      final inAppReview = InAppReview.instance;
      if (!await inAppReview.isAvailable()) return false;

      await inAppReview.requestReview();
      await prefs.setBool(_prefKey, true);
      return true;
    } catch (e) {
      logError('In-app review failed: $e', tag: 'RateService');
      return false;
    }
  }

  /// Check if the review prompt has already been shown.
  static Future<bool> hasRequestedReview() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Reset the review flag (for testing only).
  static Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
