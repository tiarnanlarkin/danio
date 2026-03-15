import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Centralised Firebase Analytics event logging.
///
/// All analytics calls are guarded — if Firebase is not initialised
/// (e.g. missing google-services.json) they silently no-op.
class FirebaseAnalyticsService {
  FirebaseAnalyticsService._();
  static final instance = FirebaseAnalyticsService._();

  /// Whether Firebase has been successfully initialised.
  bool get _isAvailable {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }

  FirebaseAnalytics? get _analytics =>
      _isAvailable ? FirebaseAnalytics.instance : null;

  // ── Key events ────────────────────────────────────────────────────────

  /// Fires when a lesson is completed.
  Future<void> logLessonComplete({required String lessonId}) =>
      _log('lesson_complete', {'lesson_id': lessonId});

  /// Fires when a new tank is created.
  Future<void> logTankCreated({required String tankType}) =>
      _log('tank_created', {'tank_type': tankType});

  /// Fires when a quiz is passed.
  Future<void> logQuizPassed({
    required String quizId,
    required int score,
  }) =>
      _log('quiz_passed', {'quiz_id': quizId, 'score': score});

  /// Fires when the Smart fish ID feature is used.
  Future<void> logFishIdUsed() => _log('fish_id_used');

  /// Fires when an achievement is unlocked.
  Future<void> logAchievementUnlocked({required String achievementId}) =>
      _log('achievement_unlocked', {'achievement_id': achievementId});

  /// Fires when onboarding finishes.
  Future<void> logOnboardingComplete() => _log('onboarding_complete');

  // ── Internal ──────────────────────────────────────────────────────────

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    try {
      await _analytics?.logEvent(name: name, parameters: params);
    } catch (e) {
      // Never crash the app because of analytics
      debugPrint('⚠️ Analytics event "$name" failed: $e');
    }
  }
}
