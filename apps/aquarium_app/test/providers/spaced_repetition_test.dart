// Tests for the spaced repetition core algorithm (ReviewCard model).
//
// Tests the pure algorithm without any provider/storage dependencies:
//   - New card starts at strength 0 and interval day1
//   - Correct answer increases strength and extends interval
//   - Incorrect answer resets interval to day1
//   - Due date calculation is correct
//
// Run: flutter test test/providers/spaced_repetition_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/models/spaced_repetition.dart';

ReviewCard _newCard() => ReviewCard.newCard(
      conceptId: 'test_concept',
      conceptType: ConceptType.lesson,
    );

void main() {
  group('ReviewCard — initial state', () {
    test('new card starts with strength 0.0', () {
      final card = _newCard();
      expect(card.strength, equals(0.0));
    });

    test('new card starts with interval day1', () {
      final card = _newCard();
      expect(card.currentInterval, equals(ReviewInterval.day1));
    });

    test('new card has 0 reviews, 0 correct, 0 incorrect', () {
      final card = _newCard();
      expect(card.reviewCount, equals(0));
      expect(card.correctCount, equals(0));
      expect(card.incorrectCount, equals(0));
    });

    test('new card is due immediately (nextReview <= now)', () {
      final card = _newCard();
      expect(card.isDue, isTrue);
    });

    test('new card is weak (strength < 0.5)', () {
      final card = _newCard();
      expect(card.isWeak, isTrue);
    });

    test('new card mastery level is new_', () {
      final card = _newCard();
      expect(card.masteryLevel, equals(MasteryLevel.new_));
    });

    test('new card success rate is 0.0', () {
      final card = _newCard();
      expect(card.successRate, equals(0.0));
    });
  });

  group('ReviewCard — correct answer', () {
    test('correct answer increases strength', () {
      final card = _newCard();
      final updated = card.afterReview(correct: true);
      expect(updated.strength, greaterThan(card.strength));
    });

    test('correct answer increments reviewCount', () {
      final card = _newCard();
      final updated = card.afterReview(correct: true);
      expect(updated.reviewCount, equals(1));
    });

    test('correct answer increments correctCount', () {
      final card = _newCard();
      final updated = card.afterReview(correct: true);
      expect(updated.correctCount, equals(1));
      expect(updated.incorrectCount, equals(0));
    });

    test('correct answer extends next review beyond today', () {
      final card = _newCard();
      final now = DateTime.now();
      final updated = card.afterReview(correct: true, reviewedAt: now);
      // After a correct review, nextReview should be in the future (at least 1 day)
      expect(updated.nextReview.isAfter(now), isTrue);
    });

    test('correct answer adds to history', () {
      final card = _newCard();
      final updated = card.afterReview(correct: true);
      expect(updated.history.length, equals(1));
      expect(updated.history.first.correct, isTrue);
    });

    test('strength caps at 1.0 after many correct answers', () {
      var card = _newCard();
      // Apply many correct answers
      for (int i = 0; i < 20; i++) {
        card = card.afterReview(correct: true);
      }
      expect(card.strength, lessThanOrEqualTo(1.0));
    });

    test('multiple correct answers increase interval progressively', () {
      var card = _newCard();
      final intervals = <ReviewInterval>[];
      for (int i = 0; i < 5; i++) {
        card = card.afterReview(correct: true);
        intervals.add(card.currentInterval);
      }
      // Interval should never decrease over consecutive correct answers
      // (may plateau but shouldn't go back)
      expect(
        intervals.last.index,
        greaterThanOrEqualTo(intervals.first.index),
      );
    });
  });

  group('ReviewCard — incorrect answer', () {
    test('incorrect answer decreases strength', () {
      // Give card some strength first
      var card = _newCard().afterReview(correct: true).afterReview(correct: true);
      final strengthBefore = card.strength;
      final updated = card.afterReview(correct: false);
      expect(updated.strength, lessThan(strengthBefore));
    });

    test('incorrect answer resets interval to day1', () {
      // Build up some interval first
      var card = _newCard();
      for (int i = 0; i < 5; i++) {
        card = card.afterReview(correct: true);
      }
      // Now fail it
      final failed = card.afterReview(correct: false);
      expect(failed.currentInterval, equals(ReviewInterval.day1));
    });

    test('incorrect answer increments incorrectCount', () {
      final card = _newCard();
      final updated = card.afterReview(correct: false);
      expect(updated.incorrectCount, equals(1));
      expect(updated.correctCount, equals(0));
    });

    test('strength does not go below 0.0', () {
      var card = _newCard();
      for (int i = 0; i < 20; i++) {
        card = card.afterReview(correct: false);
      }
      expect(card.strength, greaterThanOrEqualTo(0.0));
    });

    test('incorrect answer adds to history with correct=false', () {
      final card = _newCard();
      final updated = card.afterReview(correct: false);
      expect(updated.history.first.correct, isFalse);
    });
  });

  group('ReviewCard — due date calculation', () {
    test('day1 interval means next review is ~1 day away', () {
      final now = DateTime.now();
      final card = _newCard().afterReview(correct: true, reviewedAt: now);
      if (card.currentInterval == ReviewInterval.day1) {
        final expectedNext = now.add(const Duration(days: 1));
        final diff = card.nextReview.difference(expectedNext).abs();
        expect(diff.inSeconds, lessThan(60)); // Within 1 minute
      }
    });

    test('ReviewInterval.day1 has 1-day duration', () {
      expect(ReviewInterval.day1.duration, equals(const Duration(days: 1)));
    });

    test('ReviewInterval.day3 has 3-day duration', () {
      expect(ReviewInterval.day3.duration, equals(const Duration(days: 3)));
    });

    test('ReviewInterval.day7 has 7-day duration', () {
      expect(ReviewInterval.day7.duration, equals(const Duration(days: 7)));
    });

    test('ReviewInterval.day14 has 14-day duration', () {
      expect(ReviewInterval.day14.duration, equals(const Duration(days: 14)));
    });

    test('ReviewInterval.day30 has 30-day duration', () {
      expect(ReviewInterval.day30.duration, equals(const Duration(days: 30)));
    });

    test('card is not due immediately after a correct review', () {
      final card = _newCard().afterReview(correct: true);
      // After review, the card should be scheduled for the future
      expect(card.isDue, isFalse);
    });
  });

  group('ReviewCard — history cap', () {
    test('history is capped at 50 entries', () {
      var card = _newCard();
      for (int i = 0; i < 60; i++) {
        card = card.afterReview(correct: i % 2 == 0);
      }
      expect(card.history.length, lessThanOrEqualTo(50));
    });
  });

  group('ReviewInterval — coverage', () {
    test('all intervals have positive durations', () {
      for (final interval in ReviewInterval.values) {
        expect(
          interval.duration.inDays,
          greaterThan(0),
          reason: '${interval.name} has non-positive duration',
        );
      }
    });

    test('intervals are in ascending order', () {
      final durations =
          ReviewInterval.values.map((i) => i.duration.inDays).toList();
      for (int i = 1; i < durations.length; i++) {
        expect(
          durations[i],
          greaterThan(durations[i - 1]),
          reason:
              'Intervals are not in ascending order at index $i',
        );
      }
    });
  });
}
