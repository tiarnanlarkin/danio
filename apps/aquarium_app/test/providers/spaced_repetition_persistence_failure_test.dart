import 'dart:convert';

import 'package:danio/models/learning.dart';
import 'package:danio/models/spaced_repetition.dart';
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

Future<void> _waitForLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    if (!container.read(spacedRepetitionProvider).isLoading) return;
    await Future<void>.delayed(Duration.zero);
  }
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
        container.read(spacedRepetitionProvider.notifier).createCard(
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
}
