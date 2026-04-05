// Tests for ResolvedQuestion model hierarchy.
//
// Verifies that MultipleChoiceQuestion, MatchingPairsQuestion, and MatchPair
// store their data correctly and that the sealed class carries the ReviewCard.
//
// Run: flutter test test/models/resolved_question_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/models/resolved_question.dart';
import 'package:danio/models/spaced_repetition.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ReviewCard _testCard({String id = 'card-1', String conceptId = 'concept-1'}) {
  final now = DateTime.utc(2025, 6, 15);
  return ReviewCard(
    id: id,
    conceptId: conceptId,
    conceptType: ConceptType.quizQuestion,
    lastReviewed: now,
    nextReview: now.add(const Duration(days: 1)),
    questionText: 'What is the nitrogen cycle?',
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MultipleChoiceQuestion', () {
    test('holds all fields correctly', () {
      final card = _testCard();
      final question = MultipleChoiceQuestion(
        card: card,
        questionText: 'What converts ammonia to nitrite?',
        options: const [
          'Nitrosomonas',
          'Nitrobacter',
          'E. coli',
          'Daphnia',
        ],
        correctIndex: 0,
        explanation: 'Nitrosomonas bacteria oxidise ammonia to nitrite.',
      );

      expect(question.card, same(card));
      expect(question.questionText, 'What converts ammonia to nitrite?');
      expect(question.options, hasLength(4));
      expect(question.options[0], 'Nitrosomonas');
      expect(question.correctIndex, 0);
      expect(
        question.explanation,
        'Nitrosomonas bacteria oxidise ammonia to nitrite.',
      );
    });

    test('explanation defaults to null', () {
      final question = MultipleChoiceQuestion(
        card: _testCard(),
        questionText: 'Q?',
        options: const ['A', 'B', 'C', 'D'],
        correctIndex: 2,
      );

      expect(question.explanation, isNull);
    });

    test('is a ResolvedQuestion', () {
      final question = MultipleChoiceQuestion(
        card: _testCard(),
        questionText: 'Q?',
        options: const ['A', 'B', 'C', 'D'],
        correctIndex: 1,
      );

      expect(question, isA<ResolvedQuestion>());
    });
  });

  group('MatchingPairsQuestion', () {
    test('holds cards and pairs correctly', () {
      final primaryCard = _testCard(id: 'card-primary');
      final cards = [
        _testCard(id: 'card-1', conceptId: 'c1'),
        _testCard(id: 'card-2', conceptId: 'c2'),
        _testCard(id: 'card-3', conceptId: 'c3'),
      ];
      final pairs = const [
        MatchPair(left: 'Ammonia', right: 'NH3'),
        MatchPair(left: 'Nitrite', right: 'NO2'),
        MatchPair(left: 'Nitrate', right: 'NO3'),
      ];

      final question = MatchingPairsQuestion(
        card: primaryCard,
        cards: cards,
        pairs: pairs,
      );

      expect(question.card.id, 'card-primary');
      expect(question.cards, hasLength(3));
      expect(question.pairs, hasLength(3));
      expect(question.pairs[0].left, 'Ammonia');
      expect(question.pairs[2].right, 'NO3');
    });

    test('is a ResolvedQuestion', () {
      final question = MatchingPairsQuestion(
        card: _testCard(),
        cards: const [],
        pairs: const [],
      );

      expect(question, isA<ResolvedQuestion>());
    });
  });

  group('MatchPair', () {
    test('stores left and right correctly', () {
      const pair = MatchPair(left: 'pH', right: '6.5 - 7.5');

      expect(pair.left, 'pH');
      expect(pair.right, '6.5 - 7.5');
    });

    test('can be const-constructed', () {
      // Compile-time const — will fail at analysis time if const is broken.
      const pair1 = MatchPair(left: 'a', right: 'b');
      const pair2 = MatchPair(left: 'a', right: 'b');

      expect(identical(pair1, pair2), isTrue);
    });
  });
}
