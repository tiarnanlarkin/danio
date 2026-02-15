// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/foundation.dart';

/// Service for tracking user analytics and events with Firebase.
///
/// Provides convenient methods for logging common app events
/// and user properties.
///
/// **Note:** This service is currently disabled pending Firebase configuration.
/// To enable:
/// 1. Follow docs/setup/FIREBASE_SETUP_GUIDE.md
/// 2. Uncomment Firebase dependencies in pubspec.yaml
/// 3. Uncomment imports and implementation in this file
/// 4. Uncomment initialization in main.dart
class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService _instance =
      FirebaseAnalyticsService._internal();
  factory FirebaseAnalyticsService() => _instance;
  FirebaseAnalyticsService._internal();

  // late FirebaseAnalytics _analytics;
  // late FirebaseAnalyticsObserver _observer;

  /// Navigator observer for automatic screen tracking.
  /// FirebaseAnalyticsObserver get observer => _observer;

  /// Initialize analytics service.
  ///
  /// Must be called after Firebase.initializeApp().
  Future<void> initialize() async {
    // _analytics = FirebaseAnalytics.instance;
    // _observer = FirebaseAnalyticsObserver(analytics: _analytics);
    //
    // if (kDebugMode) {
    //   await _analytics.setAnalyticsCollectionEnabled(false);
    //   debugPrint('Firebase Analytics disabled in debug mode');
    // }
  }

  /// Log screen view.
  Future<void> logScreenView(String screenName) async {
    // await _analytics.logScreenView(screenName: screenName);
  }

  /// Log tank creation.
  Future<void> logTankCreated({
    required String tankType,
    required double size,
  }) async {
    // await _analytics.logEvent(
    //   name: 'tank_created',
    //   parameters: {
    //     'tank_type': tankType,
    //     'size': size,
    //   },
    // );
  }

  /// Log tank deletion.
  Future<void> logTankDeleted({
    required String tankId,
    required String tankType,
  }) async {
    // await _analytics.logEvent(
    //   name: 'tank_deleted',
    //   parameters: {
    //     'tank_id': tankId,
    //     'tank_type': tankType,
    //   },
    // );
  }

  /// Log tank edited.
  Future<void> logTankEdited({
    required String tankId,
    required String tankType,
  }) async {
    // await _analytics.logEvent(
    //   name: 'tank_edited',
    //   parameters: {
    //     'tank_id': tankId,
    //     'tank_type': tankType,
    //   },
    // );
  }

  /// Log lesson started.
  Future<void> logLessonStarted({
    required String lessonId,
    required String topic,
  }) async {
    // await _analytics.logEvent(
    //   name: 'lesson_started',
    //   parameters: {
    //     'lesson_id': lessonId,
    //     'topic': topic,
    //   },
    // );
  }

  /// Log lesson completion.
  Future<void> logLessonCompleted({
    required String lessonId,
    required String topic,
    required int score,
  }) async {
    // await _analytics.logEvent(
    //   name: 'lesson_completed',
    //   parameters: {
    //     'lesson_id': lessonId,
    //     'topic': topic,
    //     'score': score,
    //   },
    // );
  }

  /// Log quiz attempt.
  Future<void> logQuizAttempt({
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    // await _analytics.logEvent(
    //   name: 'quiz_attempt',
    //   parameters: {
    //     'quiz_id': quizId,
    //     'score': score,
    //     'total_questions': totalQuestions,
    //     'percentage': (score / totalQuestions * 100).round(),
    //   },
    // );
  }

  /// Log search performed.
  Future<void> logSearchPerformed({
    required String query,
    required int resultsCount,
  }) async {
    // await _analytics.logEvent(
    //   name: 'search_performed',
    //   parameters: {
    //     'query': query,
    //     'results_count': resultsCount,
    //   },
    // );
  }

  /// Log filter applied.
  Future<void> logFilterApplied({
    required String filterType,
    required String filterValue,
  }) async {
    // await _analytics.logEvent(
    //   name: 'filter_applied',
    //   parameters: {
    //     'filter_type': filterType,
    //     'filter_value': filterValue,
    //   },
    // );
  }

  /// Log settings changed.
  Future<void> logSettingsChanged({
    required String settingName,
    required String newValue,
  }) async {
    // await _analytics.logEvent(
    //   name: 'settings_changed',
    //   parameters: {
    //     'setting_name': settingName,
    //     'new_value': newValue,
    //   },
    // );
  }

  /// Log achievement unlocked.
  Future<void> logAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) async {
    // await _analytics.logEvent(
    //   name: 'achievement_unlocked',
    //   parameters: {
    //     'achievement_id': achievementId,
    //     'achievement_name': achievementName,
    //   },
    // );
  }

  /// Log streak milestone.
  Future<void> logStreakMilestone({
    required int streakDays,
  }) async {
    // await _analytics.logEvent(
    //   name: 'streak_milestone',
    //   parameters: {
    //     'streak_days': streakDays,
    //   },
    // );
  }

  /// Log XP milestone.
  Future<void> logXpMilestone({
    required int totalXp,
    required int milestone,
  }) async {
    // await _analytics.logEvent(
    //   name: 'xp_milestone',
    //   parameters: {
    //     'total_xp': totalXp,
    //     'milestone': milestone,
    //   },
    // );
  }

  /// Set user property.
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    // await _analytics.setUserProperty(name: name, value: value);
  }

  /// Set experience level user property.
  Future<void> setExperienceLevel(String level) async {
    // await setUserProperty(name: 'experience_level', value: level);
  }

  /// Set tank count user property.
  Future<void> setTankCount(int count) async {
    // await setUserProperty(name: 'tank_count', value: count.toString());
  }

  /// Set preferred tank type user property.
  Future<void> setPreferredTankType(String tankType) async {
    // await setUserProperty(name: 'preferred_tank_type', value: tankType);
  }

  /// Set user ID.
  Future<void> setUserId(String userId) async {
    // await _analytics.setUserId(id: userId);
  }

  /// Log app opened.
  Future<void> logAppOpen() async {
    // await _analytics.logAppOpen();
  }

  /// Log tutorial begin.
  Future<void> logTutorialBegin() async {
    // await _analytics.logTutorialBegin();
  }

  /// Log tutorial complete.
  Future<void> logTutorialComplete() async {
    // await _analytics.logTutorialComplete();
  }

  /// Log level up.
  Future<void> logLevelUp({
    required int level,
    required String character,
  }) async {
    // await _analytics.logLevelUp(
    //   level: level,
    //   character: character,
    // );
  }
}
