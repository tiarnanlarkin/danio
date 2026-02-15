/// Tests for Spaced Repetition Models
/// Validates forgetting curve, strength adjustments, and review scheduling
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/spaced_repetition.dart';

void main() {
  group('ReviewCard', () {
    test('new card should have 0 strength and be due immediately', () {
      final card = ReviewCard.newCard(
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
      );

      expect(card.strength, 0.0);
      expect(card.reviewCount, 0);
      expect(card.isDue, true);
      expect(card.masteryLevel, MasteryLevel.new_);
    });

    test('correct answer should increase strength by 0.2', () {
      final card = ReviewCard.newCard(
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
      );

      final updatedCard = card.afterReview(correct: true);

      expect(updatedCard.strength, 0.2);
      expect(updatedCard.correctCount, 1);
      expect(updatedCard.reviewCount, 1);
      expect(updatedCard.incorrectCount, 0);
    });

    test('incorrect answer should decrease strength by 0.3', () {
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final updatedCard = card.afterReview(correct: false);

      expect(updatedCard.strength, 0.2); // 0.5 - 0.3 = 0.2
      expect(updatedCard.incorrectCount, 1);
      expect(updatedCard.reviewCount, 1);
      expect(updatedCard.correctCount, 0);
    });

    test('strength should not exceed 1.0', () {
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.95,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final updatedCard = card.afterReview(correct: true);

      expect(updatedCard.strength, 1.0); // Capped at 1.0
      expect(updatedCard.strength, lessThanOrEqualTo(1.0));
    });

    test('strength should not go below 0.0', () {
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.1,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final updatedCard = card.afterReview(correct: false);

      expect(updatedCard.strength, 0.0); // Floored at 0.0
      expect(updatedCard.strength, greaterThanOrEqualTo(0.0));
    });

    test('review intervals should increase with strength', () {
      var card = ReviewCard.newCard(
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
      );

      // First correct answer (strength: 0.2) -> day1
      card = card.afterReview(correct: true);
      expect(card.currentInterval, ReviewInterval.day1);

      // More correct answers to increase strength
      card = card.afterReview(correct: true); // strength: 0.4
      expect(card.currentInterval, ReviewInterval.day1);

      card = card.afterReview(correct: true); // strength: 0.6
      expect(card.currentInterval, ReviewInterval.day7);

      card = card.afterReview(correct: true); // strength: 0.8
      expect(card.currentInterval, ReviewInterval.day14);

      card = card.afterReview(correct: true); // strength: 1.0
      expect(card.currentInterval, ReviewInterval.day30);
    });

    test('incorrect answer should reset interval to day1', () {
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.8,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now().add(const Duration(days: 14)),
        currentInterval: ReviewInterval.day14,
      );

      final updatedCard = card.afterReview(correct: false);

      expect(updatedCard.currentInterval, ReviewInterval.day1);
    });

    test('next review date should be calculated based on interval', () {
      final now = DateTime.now();
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.6,
        lastReviewed: now,
        nextReview: now,
      );

      final updatedCard = card.afterReview(correct: true, reviewedAt: now);

      // Strength 0.8 should give day14 interval
      final expectedDate = now.add(const Duration(days: 14));
      
      // Allow 1 second tolerance for test execution time
      expect(
        updatedCard.nextReview.difference(expectedDate).inSeconds.abs(),
        lessThan(2),
      );
    });

    test('isDue should return true when nextReview is in the past', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: pastDate,
        nextReview: pastDate,
      );

      expect(card.isDue, true);
    });

    test('isDue should return false when nextReview is in the future', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: futureDate,
      );

      expect(card.isDue, false);
    });

    test('isWeak should return true when strength < 0.5', () {
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.4,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      expect(card.isWeak, true);
    });

    test('isStrong should return true when strength >= 0.8', () {
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.85,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      expect(card.isStrong, true);
    });

    test('success rate should be calculated correctly', () {
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
        reviewCount: 10,
        correctCount: 7,
        incorrectCount: 3,
      );

      expect(card.successRate, 0.7);
    });

    test('mastery levels should be assigned correctly', () {
      expect(
        ReviewCard(
          id: 'test',
          conceptId: 'test',
          conceptType: ConceptType.lesson,
          strength: 0.1,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ).masteryLevel,
        MasteryLevel.new_,
      );

      expect(
        ReviewCard(
          id: 'test',
          conceptId: 'test',
          conceptType: ConceptType.lesson,
          strength: 0.4,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ).masteryLevel,
        MasteryLevel.learning,
      );

      expect(
        ReviewCard(
          id: 'test',
          conceptId: 'test',
          conceptType: ConceptType.lesson,
          strength: 0.6,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ).masteryLevel,
        MasteryLevel.familiar,
      );

      expect(
        ReviewCard(
          id: 'test',
          conceptId: 'test',
          conceptType: ConceptType.lesson,
          strength: 0.8,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ).masteryLevel,
        MasteryLevel.proficient,
      );

      expect(
        ReviewCard(
          id: 'test',
          conceptId: 'test',
          conceptType: ConceptType.lesson,
          strength: 0.95,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ).masteryLevel,
        MasteryLevel.mastered,
      );
    });

    test('review history should be recorded', () {
      final card = ReviewCard.newCard(
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
      );

      var updatedCard = card.afterReview(correct: true);
      expect(updatedCard.history.length, 1);
      expect(updatedCard.history.last.correct, true);
      expect(updatedCard.history.last.strengthBefore, 0.0);
      expect(updatedCard.history.last.strengthAfter, 0.2);

      updatedCard = updatedCard.afterReview(correct: false);
      expect(updatedCard.history.length, 2);
      expect(updatedCard.history.last.correct, false);
    });
  });

  group('ReviewInterval', () {
    test('intervals should have correct durations', () {
      expect(ReviewInterval.day1.duration, const Duration(days: 1));
      expect(ReviewInterval.day3.duration, const Duration(days: 3));
      expect(ReviewInterval.day7.duration, const Duration(days: 7));
      expect(ReviewInterval.day14.duration, const Duration(days: 14));
      expect(ReviewInterval.day30.duration, const Duration(days: 30));
    });

    test('intervals should have correct display names', () {
      expect(ReviewInterval.day1.displayName, '1 day');
      expect(ReviewInterval.day3.displayName, '3 days');
      expect(ReviewInterval.day7.displayName, '7 days');
      expect(ReviewInterval.day14.displayName, '2 weeks');
      expect(ReviewInterval.day30.displayName, '1 month');
    });
  });

  group('ReviewSession', () {
    test('new session should not be complete', () {
      final session = ReviewSession(
        id: 'test_session',
        startTime: DateTime.now(),
        cards: [
          ReviewCard.newCard(conceptId: 'c1', conceptType: ConceptType.lesson),
          ReviewCard.newCard(conceptId: 'c2', conceptType: ConceptType.lesson),
        ],
      );

      expect(session.isComplete, false);
      expect(session.remainingCount, 2);
      expect(session.progress, 0.0);
    });

    test('session progress should update correctly', () {
      final session = ReviewSession(
        id: 'test_session',
        startTime: DateTime.now(),
        cards: [
          ReviewCard.newCard(conceptId: 'c1', conceptType: ConceptType.lesson),
          ReviewCard.newCard(conceptId: 'c2', conceptType: ConceptType.lesson),
        ],
        results: [
          ReviewSessionResult(
            cardId: 'c1',
            correct: true,
            timestamp: DateTime.now(),
            xpEarned: 10,
            timeSpent: const Duration(seconds: 5),
          ),
        ],
      );

      expect(session.remainingCount, 1);
      expect(session.progress, 0.5);
      expect(session.isComplete, false);
    });

    test('session should be complete when all cards reviewed', () {
      final now = DateTime.now();
      final session = ReviewSession(
        id: 'test_session',
        startTime: now,
        cards: [
          ReviewCard.newCard(conceptId: 'c1', conceptType: ConceptType.lesson),
        ],
        results: [
          ReviewSessionResult(
            cardId: 'c1',
            correct: true,
            timestamp: now,
            xpEarned: 10,
            timeSpent: const Duration(seconds: 5),
          ),
        ],
      );

      expect(session.isComplete, true);
      expect(session.remainingCount, 0);
      expect(session.progress, 1.0);
    });

    test('session score should be calculated correctly', () {
      final now = DateTime.now();
      final session = ReviewSession(
        id: 'test_session',
        startTime: now,
        cards: [
          ReviewCard.newCard(conceptId: 'c1', conceptType: ConceptType.lesson),
          ReviewCard.newCard(conceptId: 'c2', conceptType: ConceptType.lesson),
          ReviewCard.newCard(conceptId: 'c3', conceptType: ConceptType.lesson),
          ReviewCard.newCard(conceptId: 'c4', conceptType: ConceptType.lesson),
        ],
        results: [
          ReviewSessionResult(
            cardId: 'c1',
            correct: true,
            timestamp: now,
            xpEarned: 10,
            timeSpent: const Duration(seconds: 5),
          ),
          ReviewSessionResult(
            cardId: 'c2',
            correct: true,
            timestamp: now,
            xpEarned: 10,
            timeSpent: const Duration(seconds: 5),
          ),
          ReviewSessionResult(
            cardId: 'c3',
            correct: false,
            timestamp: now,
            xpEarned: 3,
            timeSpent: const Duration(seconds: 5),
          ),
          ReviewSessionResult(
            cardId: 'c4',
            correct: true,
            timestamp: now,
            xpEarned: 10,
            timeSpent: const Duration(seconds: 5),
          ),
        ],
      );

      expect(session.score, 0.75); // 3/4 correct = 75%
    });

    test('session total XP should be sum of all results', () {
      final now = DateTime.now();
      final session = ReviewSession(
        id: 'test_session',
        startTime: now,
        cards: [
          ReviewCard.newCard(conceptId: 'c1', conceptType: ConceptType.lesson),
          ReviewCard.newCard(conceptId: 'c2', conceptType: ConceptType.lesson),
        ],
        results: [
          ReviewSessionResult(
            cardId: 'c1',
            correct: true,
            timestamp: now,
            xpEarned: 15,
            timeSpent: const Duration(seconds: 5),
          ),
          ReviewSessionResult(
            cardId: 'c2',
            correct: false,
            timestamp: now,
            xpEarned: 5,
            timeSpent: const Duration(seconds: 8),
          ),
        ],
      );

      expect(session.totalXp, 20);
    });
  });

  group('ReviewStats', () {
    test('stats should calculate correctly from cards', () {
      final cards = [
        ReviewCard.newCard(conceptId: 'c1', conceptType: ConceptType.lesson),
        ReviewCard(
          id: 'c2',
          conceptId: 'c2',
          conceptType: ConceptType.lesson,
          strength: 0.4,
          lastReviewed: DateTime.now().subtract(const Duration(days: 1)),
          nextReview: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ReviewCard(
          id: 'c3',
          conceptId: 'c3',
          conceptType: ConceptType.lesson,
          strength: 0.95,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now().add(const Duration(days: 30)),
        ),
      ];

      final stats = ReviewStats.fromCards(cards);

      expect(stats.totalCards, 3);
      expect(stats.dueCards, 2); // c1 and c2 are due
      expect(stats.weakCards, 2); // c1 and c2 are weak (< 0.5)
      expect(stats.masteredCards, 1); // c3 is mastered
      expect(stats.averageStrength, closeTo(0.45, 0.01)); // (0.0 + 0.4 + 0.95) / 3
    });

    test('empty stats should handle zero cards', () {
      final stats = ReviewStats.fromCards([]);

      expect(stats.totalCards, 0);
      expect(stats.dueCards, 0);
      expect(stats.weakCards, 0);
      expect(stats.masteredCards, 0);
      expect(stats.averageStrength, 0.0);
    });
  });

  group('JSON Serialization', () {
    test('ReviewCard should serialize and deserialize correctly', () {
      final card = ReviewCard(
        id: 'test_id',
        conceptId: 'concept_123',
        conceptType: ConceptType.quizQuestion,
        strength: 0.75,
        lastReviewed: DateTime(2024, 1, 1, 12, 0),
        nextReview: DateTime(2024, 1, 8, 12, 0),
        reviewCount: 5,
        correctCount: 4,
        incorrectCount: 1,
        currentInterval: ReviewInterval.day7,
      );

      final json = card.toJson();
      final restored = ReviewCard.fromJson(json);

      expect(restored.id, card.id);
      expect(restored.conceptId, card.conceptId);
      expect(restored.conceptType, card.conceptType);
      expect(restored.strength, card.strength);
      expect(restored.reviewCount, card.reviewCount);
      expect(restored.correctCount, card.correctCount);
      expect(restored.incorrectCount, card.incorrectCount);
      expect(restored.currentInterval, card.currentInterval);
    });
  });
}
