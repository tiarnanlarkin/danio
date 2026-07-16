import 'dart:async';
import 'dart:convert';

import 'package:danio/models/achievements.dart';
import 'package:danio/models/learning.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/providers/achievement_provider.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/services/notification_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ThrowingSetStringPrefs implements SharedPreferences {
  _ThrowingSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, String value) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setString(key, value);
  }

  @override
  Future<bool> remove(String key) => _delegate.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FalseSetStringPrefs implements SharedPreferences {
  _FalseSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, String value) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      return Future<bool>.value(false);
    }
    return _delegate.setString(key, value);
  }

  @override
  Future<bool> remove(String key) => _delegate.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FalseRemovePrefs implements SharedPreferences {
  _FalseRemovePrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  Future<bool> setString(String key, String value) =>
      _delegate.setString(key, value);

  @override
  Future<bool> remove(String key) {
    if (_shouldFail(key)) {
      return Future<bool>.value(false);
    }
    return _delegate.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BlockingSetStringPrefs implements SharedPreferences {
  _BlockingSetStringPrefs(this._delegate);

  final SharedPreferences _delegate;
  final cardSaveStarted = Completer<void>();
  final releaseCardSave = Completer<void>();
  bool blockCardSaves = false;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  Future<bool> setString(String key, String value) async {
    if (blockCardSaves && key == 'spaced_repetition_cards') {
      if (!cardSaveStarted.isCompleted) cardSaveStarted.complete();
      await releaseCardSave.future;
    }
    return _delegate.setString(key, value);
  }

  @override
  Future<bool> remove(String key) => _delegate.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopReminderNotificationService implements ReminderNotificationService {
  @override
  Future<void> cancelReviewReminder() async {}

  @override
  Future<void> cancelStreakNotifications() async {}

  @override
  Future<void> scheduleAllStreakNotifications({
    required int currentStreak,
    required int dailyXpGoal,
    required int todayXp,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    TimeOfDay? nightTime,
  }) async {}

  @override
  Future<void> scheduleReviewReminder({
    required int dueCardsCount,
    TimeOfDay? time,
  }) async {}
}

class _NoopAchievementChecker extends AchievementChecker {
  _NoopAchievementChecker(super.ref);

  @override
  Future<List<AchievementUnlockResult>> checkAfterReview({
    required int reviewsCompleted,
    required int reviewStreak,
  }) async {
    return const [];
  }
}

Future<void> _waitForLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    if (!container.read(spacedRepetitionProvider).isLoading) return;
    await Future<void>.delayed(Duration.zero);
  }
}

ProviderContainer _containerWithPreferences(SharedPreferences prefs) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
      notificationServiceProvider.overrideWithValue(
        _NoopReminderNotificationService(),
      ),
      achievementCheckerProvider.overrideWith(_NoopAchievementChecker.new),
    ],
  );
}

ProviderContainer _containerWithFailingCardSaves(SharedPreferences prefs) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return _ThrowingSetStringPrefs(
          prefs,
          (key, _) => key == 'spaced_repetition_cards',
        );
      }),
      notificationServiceProvider.overrideWithValue(
        _NoopReminderNotificationService(),
      ),
      achievementCheckerProvider.overrideWith(_NoopAchievementChecker.new),
    ],
  );
}

ProviderContainer _containerWithFalseCardSaves(SharedPreferences prefs) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return _FalseSetStringPrefs(
          prefs,
          (key, _) => key == 'spaced_repetition_cards',
        );
      }),
      notificationServiceProvider.overrideWithValue(
        _NoopReminderNotificationService(),
      ),
      achievementCheckerProvider.overrideWith(_NoopAchievementChecker.new),
    ],
  );
}

ProviderContainer _containerWithFalseSavesForKey(
  SharedPreferences prefs,
  String failedKey,
) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return _FalseSetStringPrefs(prefs, (key, _) => key == failedKey);
      }),
      notificationServiceProvider.overrideWithValue(
        _NoopReminderNotificationService(),
      ),
      achievementCheckerProvider.overrideWith(_NoopAchievementChecker.new),
    ],
  );
}

ProviderContainer _containerWithFalseRemovesForKey(
  SharedPreferences prefs,
  String failedKey,
) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return _FalseRemovePrefs(prefs, (key) => key == failedKey);
      }),
      notificationServiceProvider.overrideWithValue(
        _NoopReminderNotificationService(),
      ),
      achievementCheckerProvider.overrideWith(_NoopAchievementChecker.new),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'createCard rolls back visible review progress when local save fails',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFailingCardSaves(prefs);
      addTearDown(container.dispose);

      container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);

      await expectLater(
        container
            .read(spacedRepetitionProvider.notifier)
            .createCard(
              conceptId: 'nitrogen_cycle_intro',
              conceptType: ConceptType.lesson,
            ),
        throwsA(isA<Exception>()),
      );

      final state = container.read(spacedRepetitionProvider);
      expect(state.cards, isEmpty);
      expect(state.stats.totalCards, 0);
      expect(state.errorMessage, contains("Couldn't create"));
      expect(prefs.getString('spaced_repetition_cards'), isNull);
    },
  );

  test(
    'autoSeedFromLesson rolls back visible review cards when local save fails',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFailingCardSaves(prefs);
      addTearDown(container.dispose);

      container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);

      await container
          .read(spacedRepetitionProvider.notifier)
          .autoSeedFromLesson(
            lessonId: 'nitrogen_cycle_intro',
            lessonSections: const [
              LessonSection(
                type: LessonSectionType.keyPoint,
                content: 'Ammonia and nitrite should both be zero.',
              ),
            ],
            quizQuestions: null,
          );

      final state = container.read(spacedRepetitionProvider);
      expect(state.cards, isEmpty);
      expect(state.stats.totalCards, 0);
      expect(state.errorMessage, contains("Couldn't set up"));
      expect(prefs.getString('spaced_repetition_cards'), isNull);
    },
  );

  test(
    'createCard treats false card saves as local save failures',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFalseCardSaves(prefs);
      addTearDown(container.dispose);

      container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);

      await expectLater(
        container
            .read(spacedRepetitionProvider.notifier)
            .createCard(
              conceptId: 'nitrogen_cycle_intro',
              conceptType: ConceptType.lesson,
            ),
        throwsA(isA<Exception>()),
      );

      final state = container.read(spacedRepetitionProvider);
      expect(state.cards, isEmpty);
      expect(state.stats.totalCards, 0);
      expect(state.errorMessage, contains("Couldn't create"));
      expect(prefs.getString('spaced_repetition_cards'), isNull);
    },
  );

  test(
    'autoSeedFromLesson treats false card saves as local save failures',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFalseCardSaves(prefs);
      addTearDown(container.dispose);

      container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);

      await container
          .read(spacedRepetitionProvider.notifier)
          .autoSeedFromLesson(
            lessonId: 'nitrogen_cycle_intro',
            lessonSections: const [
              LessonSection(
                type: LessonSectionType.keyPoint,
                content: 'Ammonia and nitrite should both be zero.',
              ),
            ],
            quizQuestions: null,
          );

      final state = container.read(spacedRepetitionProvider);
      expect(state.cards, isEmpty);
      expect(state.stats.totalCards, 0);
      expect(state.errorMessage, contains("Couldn't set up"));
      expect(prefs.getString('spaced_repetition_cards'), isNull);
    },
  );

  test(
    'deleteCard restores visible review card when local save fails',
    () async {
      final originalCard = ReviewCard.newCard(
        conceptId: 'nitrogen_cycle_intro',
        conceptType: ConceptType.lesson,
      );
      SharedPreferences.setMockInitialValues({
        'spaced_repetition_cards': jsonEncode([originalCard.toJson()]),
        'spaced_repetition_stats': jsonEncode({
          'reviewsToday': 0,
          'totalReviews': 0,
          'streak': 0,
          'lastReviewDate': DateTime(2026, 6, 24).toIso8601String(),
        }),
      });
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFailingCardSaves(prefs);
      addTearDown(container.dispose);

      container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);
      expect(container.read(spacedRepetitionProvider).cards, hasLength(1));

      await expectLater(
        container
            .read(spacedRepetitionProvider.notifier)
            .deleteCard(originalCard.id),
        throwsA(isA<Exception>()),
      );

      final state = container.read(spacedRepetitionProvider);
      expect(state.cards, hasLength(1));
      expect(state.cards.single.id, originalCard.id);
      expect(state.stats.totalCards, 1);
      expect(state.errorMessage, contains("Couldn't remove"));
      expect(
        prefs.getString('spaced_repetition_cards'),
        jsonEncode([originalCard.toJson()]),
      );
    },
  );

  test(
    'deleteCard treats false card saves as local save failures',
    () async {
      final originalCard = ReviewCard.newCard(
        conceptId: 'nitrogen_cycle_intro',
        conceptType: ConceptType.lesson,
      );
      SharedPreferences.setMockInitialValues({
        'spaced_repetition_cards': jsonEncode([originalCard.toJson()]),
        'spaced_repetition_stats': jsonEncode({
          'reviewsToday': 0,
          'totalReviews': 0,
          'streak': 0,
          'lastReviewDate': DateTime(2026, 6, 24).toIso8601String(),
        }),
      });
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFalseCardSaves(prefs);
      addTearDown(container.dispose);

      container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);
      expect(container.read(spacedRepetitionProvider).cards, hasLength(1));

      await expectLater(
        container
            .read(spacedRepetitionProvider.notifier)
            .deleteCard(originalCard.id),
        throwsA(isA<Exception>()),
      );

      final state = container.read(spacedRepetitionProvider);
      expect(state.cards, hasLength(1));
      expect(state.cards.single.id, originalCard.id);
      expect(state.stats.totalCards, 1);
      expect(state.errorMessage, contains("Couldn't remove"));
      expect(
        prefs.getString('spaced_repetition_cards'),
        jsonEncode([originalCard.toJson()]),
      );
    },
  );

  test(
    'resetAll keeps visible review progress when persisted reset fails',
    () async {
      final originalCard = ReviewCard.newCard(
        conceptId: 'nitrogen_cycle_intro',
        conceptType: ConceptType.lesson,
      );
      final cardsJson = jsonEncode([originalCard.toJson()]);
      final statsJson = jsonEncode({
        'reviewsToday': 1,
        'totalReviews': 3,
        'streak': 2,
        'lastReviewDate': DateTime(2026, 6, 24).toIso8601String(),
      });
      SharedPreferences.setMockInitialValues({
        'spaced_repetition_cards': cardsJson,
        'spaced_repetition_stats': statsJson,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFalseRemovesForKey(
        prefs,
        'spaced_repetition_cards',
      );
      addTearDown(container.dispose);

      final notifier = container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);
      expect(container.read(spacedRepetitionProvider).cards, hasLength(1));

      await expectLater(notifier.resetAll(), throwsA(isA<StateError>()));

      final state = container.read(spacedRepetitionProvider);
      expect(state.cards, hasLength(1));
      expect(state.cards.single.id, originalCard.id);
      expect(state.stats.totalCards, 1);
      expect(state.errorMessage, contains("Couldn't reset"));
      expect(prefs.getString('spaced_repetition_cards'), cardsJson);
      expect(prefs.getString('spaced_repetition_stats'), statsJson);
    },
  );

  test(
    'resetAll restores all practice keys when session removal fails',
    () async {
      final originalCard = ReviewCard.newCard(
        conceptId: 'nitrogen_cycle_intro',
        conceptType: ConceptType.lesson,
      );
      final cardsJson = jsonEncode([originalCard.toJson()]);
      final statsJson = jsonEncode({
        'reviewsToday': 1,
        'totalReviews': 3,
        'streak': 2,
        'lastReviewDate': DateTime(2026, 6, 24).toIso8601String(),
      });
      const streakJson = '{"currentStreak":2,"lastReviewDate":"2026-06-24"}';
      const sessionsJson = '{"count":4,"lastCompleted":"2026-06-24"}';
      SharedPreferences.setMockInitialValues({
        'spaced_repetition_cards': cardsJson,
        'spaced_repetition_stats': statsJson,
        'spaced_repetition_streak': streakJson,
        'spaced_repetition_sessions': sessionsJson,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFalseRemovesForKey(
        prefs,
        'spaced_repetition_sessions',
      );
      addTearDown(container.dispose);

      final notifier = container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);
      expect(container.read(spacedRepetitionProvider).cards, hasLength(1));

      await expectLater(notifier.resetAll(), throwsA(isA<StateError>()));

      final state = container.read(spacedRepetitionProvider);
      expect(state.cards, hasLength(1));
      expect(state.cards.single.id, originalCard.id);
      expect(state.stats.totalCards, 1);
      expect(state.errorMessage, contains("Couldn't reset"));
      expect(prefs.getString('spaced_repetition_cards'), cardsJson);
      expect(prefs.getString('spaced_repetition_stats'), statsJson);
      expect(prefs.getString('spaced_repetition_streak'), streakJson);
      expect(prefs.getString('spaced_repetition_sessions'), sessionsJson);
    },
  );

  test(
    'recordSessionResult keeps the answer pending when review-card save fails',
    () async {
      final originalCard = ReviewCard.newCard(
        conceptId: 'nitrogen_cycle_intro',
        conceptType: ConceptType.lesson,
      );
      final cardsJson = jsonEncode([originalCard.toJson()]);
      final statsJson = jsonEncode({
        'reviewsToday': 0,
        'totalReviews': 0,
        'streak': 0,
        'lastReviewDate': DateTime.now().toIso8601String(),
      });
      SharedPreferences.setMockInitialValues({
        'spaced_repetition_cards': cardsJson,
        'spaced_repetition_stats': statsJson,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFalseCardSaves(prefs);
      addTearDown(container.dispose);

      final notifier = container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);
      await notifier.startSession();

      final session = container.read(spacedRepetitionProvider).currentSession!;
      expect(session.results, isEmpty);

      await expectLater(
        notifier.recordSessionResult(
          cardId: session.cards.single.id,
          correct: true,
          timeSpent: const Duration(seconds: 3),
        ),
        throwsA(isA<Exception>()),
      );

      final state = container.read(spacedRepetitionProvider);
      expect(state.currentSession!.results, isEmpty);
      expect(state.cards.single.reviewCount, originalCard.reviewCount);
      expect(state.stats.reviewsToday, 0);
      expect(state.stats.totalReviews, 0);
      expect(prefs.getString('spaced_repetition_cards'), cardsJson);
      expect(prefs.getString('spaced_repetition_stats'), statsJson);
    },
  );

  test(
    'recordSessionResult restores the card when review-stats save fails',
    () async {
      final originalCard = ReviewCard.newCard(
        conceptId: 'nitrogen_cycle_intro',
        conceptType: ConceptType.lesson,
      );
      final cardsJson = jsonEncode([originalCard.toJson()]);
      final statsJson = jsonEncode({
        'reviewsToday': 0,
        'totalReviews': 0,
        'streak': 0,
        'lastReviewDate': DateTime.now().toIso8601String(),
      });
      SharedPreferences.setMockInitialValues({
        'spaced_repetition_cards': cardsJson,
        'spaced_repetition_stats': statsJson,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFalseSavesForKey(
        prefs,
        'spaced_repetition_stats',
      );
      addTearDown(container.dispose);

      final notifier = container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);
      await notifier.startSession();

      final session = container.read(spacedRepetitionProvider).currentSession!;
      await expectLater(
        notifier.recordSessionResult(
          cardId: session.cards.single.id,
          correct: true,
          timeSpent: const Duration(seconds: 3),
        ),
        throwsA(isA<Exception>()),
      );

      final state = container.read(spacedRepetitionProvider);
      expect(state.currentSession!.results, isEmpty);
      expect(state.cards.single.reviewCount, originalCard.reviewCount);
      expect(state.stats.reviewsToday, 0);
      expect(state.stats.totalReviews, 0);
      expect(prefs.getString('spaced_repetition_cards'), cardsJson);
      expect(prefs.getString('spaced_repetition_stats'), statsJson);
    },
  );

  test(
    'recordSessionResult rejects a session card missing from saved cards',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithPreferences(prefs);
      addTearDown(container.dispose);

      final notifier = container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);
      await notifier.createCard(
        conceptId: 'nitrogen_cycle_intro',
        conceptType: ConceptType.lesson,
      );
      await notifier.startSession();

      final session = container.read(spacedRepetitionProvider).currentSession!;
      await notifier.deleteCard(session.cards.single.id);

      await expectLater(
        notifier.recordSessionResult(
          cardId: session.cards.single.id,
          correct: true,
          timeSpent: const Duration(seconds: 3),
        ),
        throwsA(isA<StateError>()),
      );

      expect(
        container.read(spacedRepetitionProvider).currentSession!.results,
        isEmpty,
      );
      expect(prefs.getString('spaced_repetition_cards'), '[]');
    },
  );

  test(
    'recordSessionResult does not resurrect an abandoned session after save',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final blockingPrefs = _BlockingSetStringPrefs(prefs);
      final container = _containerWithPreferences(blockingPrefs);
      addTearDown(container.dispose);

      final notifier = container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);
      await notifier.createCard(
        conceptId: 'nitrogen_cycle_intro',
        conceptType: ConceptType.lesson,
      );
      await notifier.startSession();
      final session = container.read(spacedRepetitionProvider).currentSession!;

      blockingPrefs.blockCardSaves = true;
      final recordFuture = notifier.recordSessionResult(
        cardId: session.cards.single.id,
        correct: true,
        timeSpent: const Duration(seconds: 3),
      );
      await blockingPrefs.cardSaveStarted.future;

      notifier.abandonSession();
      blockingPrefs.releaseCardSave.complete();
      await recordFuture;

      expect(container.read(spacedRepetitionProvider).currentSession, isNull);
    },
  );

  test(
    'completeSession keeps active session when session count save returns false',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFalseSavesForKey(
        prefs,
        'spaced_repetition_sessions',
      );
      addTearDown(container.dispose);

      final notifier = container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);
      await notifier.createCard(
        conceptId: 'nitrogen_cycle_intro',
        conceptType: ConceptType.lesson,
      );
      await notifier.startSession();
      expect(
        container.read(spacedRepetitionProvider).currentSession,
        isNotNull,
      );

      await expectLater(notifier.completeSession(), throwsA(isA<StateError>()));

      final state = container.read(spacedRepetitionProvider);
      expect(state.currentSession, isNotNull);
      expect(state.stats.currentStreak, 0);
      expect(
        state.errorMessage,
        contains("Couldn't save your session results"),
      );
      expect(prefs.getString('spaced_repetition_sessions'), isNull);
      expect(prefs.getString('spaced_repetition_streak'), isNull);
    },
  );

  test(
    'completeSession preserves old streak when streak save returns false',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = _containerWithFalseSavesForKey(
        prefs,
        'spaced_repetition_streak',
      );
      addTearDown(container.dispose);

      final notifier = container.read(spacedRepetitionProvider.notifier);
      await _waitForLoad(container);
      await notifier.createCard(
        conceptId: 'nitrogen_cycle_intro',
        conceptType: ConceptType.lesson,
      );
      await notifier.startSession();

      await notifier.completeSession();

      final state = container.read(spacedRepetitionProvider);
      final statsJson = prefs.getString('spaced_repetition_stats');
      final statsData = jsonDecode(statsJson!) as Map<String, dynamic>;
      expect(state.currentSession, isNull);
      expect(state.stats.currentStreak, 0);
      expect(state.errorMessage, contains("Couldn't update your streak"));
      expect(prefs.getString('spaced_repetition_sessions'), isNotNull);
      expect(prefs.getString('spaced_repetition_streak'), isNull);
      expect(statsData['streak'], 0);
    },
  );
}
