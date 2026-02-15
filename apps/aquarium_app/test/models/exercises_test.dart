/// Unit tests for all exercise types
/// Tests validation logic, serialization, and edge cases
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/exercises.dart';

void main() {
  group('MultipleChoiceExercise', () {
    late MultipleChoiceExercise exercise;

    setUp(() {
      exercise = const MultipleChoiceExercise(
        id: 'mc1',
        question: 'What is the ideal pH for most freshwater fish?',
        options: ['6.0-6.5', '6.5-7.5', '7.5-8.5', '8.5-9.0'],
        correctIndex: 1,
        explanation: 'Most freshwater fish thrive at pH 6.5-7.5',
        hint: 'Think about neutral pH',
      );
    });

    test('validates correct answer', () {
      expect(exercise.validate(1), isTrue);
    });

    test('validates incorrect answer', () {
      expect(exercise.validate(0), isFalse);
      expect(exercise.validate(2), isFalse);
      expect(exercise.validate(3), isFalse);
    });

    test('handles invalid answer type', () {
      expect(exercise.validate('1'), isFalse);
      expect(exercise.validate(null), isFalse);
      expect(exercise.validate([1]), isFalse);
    });

    test('returns correct answer text', () {
      expect(exercise.correctAnswer, equals('6.5-7.5'));
    });

    test('provides hint', () {
      expect(exercise.getHint(), equals('Think about neutral pH'));
    });

    test('serializes to JSON', () {
      final json = exercise.toJson();
      expect(json['id'], equals('mc1'));
      expect(json['type'], equals('multipleChoice'));
      expect(json['correctIndex'], equals(1));
      expect(json['options'], hasLength(4));
    });

    test('deserializes from JSON', () {
      final json = exercise.toJson();
      final restored = MultipleChoiceExercise.fromJson(json);
      expect(restored.id, equals(exercise.id));
      expect(restored.question, equals(exercise.question));
      expect(restored.correctIndex, equals(exercise.correctIndex));
      expect(restored.validate(1), isTrue);
    });

    test('has medium difficulty by default', () {
      expect(exercise.difficulty, equals(ExerciseDifficulty.medium));
    });
  });

  group('FillBlankExercise', () {
    group('Text Input Mode', () {
      late FillBlankExercise exercise;

      setUp(() {
        exercise = const FillBlankExercise(
          id: 'fb1',
          question: 'Complete the sentence about the nitrogen cycle',
          sentenceTemplate: 'The ___ cycle takes ___ weeks to complete.',
          correctAnswers: ['nitrogen', '4-6'],
          explanation: 'The nitrogen cycle typically takes 4-6 weeks',
        );
      });

      test('validates correct answers', () {
        expect(exercise.validate(['nitrogen', '4-6']), isTrue);
      });

      test('validates incorrect answers', () {
        expect(exercise.validate(['carbon', '4-6']), isFalse);
        expect(exercise.validate(['nitrogen', '2-3']), isFalse);
      });

      test('handles case insensitivity', () {
        expect(exercise.validate(['NITROGEN', '4-6']), isTrue);
        expect(exercise.validate(['Nitrogen', '4-6']), isTrue);
      });

      test('handles wrong number of answers', () {
        expect(exercise.validate(['nitrogen']), isFalse);
        expect(exercise.validate(['nitrogen', '4-6', 'extra']), isFalse);
      });

      test('handles invalid answer type', () {
        expect(exercise.validate('nitrogen'), isFalse);
        expect(exercise.validate(42), isFalse);
      });

      test('counts blanks correctly', () {
        expect(exercise.numberOfBlanks, equals(2));
      });

      test('splits sentence correctly', () {
        final parts = exercise.getSentenceParts();
        expect(parts, hasLength(3));
        expect(parts[0], equals('The '));
        expect(parts[1], equals(' cycle takes '));
        expect(parts[2], equals(' weeks to complete.'));
      });

      test('has hard difficulty without word bank (2 blanks)', () {
        // 2 blanks without word bank = hard difficulty per logic
        expect(exercise.difficulty, equals(ExerciseDifficulty.hard));
      });

      test('has hard difficulty with multiple blanks', () {
        final hardExercise = const FillBlankExercise(
          id: 'fb2',
          question: 'Test',
          sentenceTemplate: '___ ___ ___ ___',
          correctAnswers: ['one', 'two', 'three', 'four'],
        );
        expect(hardExercise.difficulty, equals(ExerciseDifficulty.hard));
      });
    });

    group('With Alternatives', () {
      late FillBlankExercise exercise;

      setUp(() {
        exercise = const FillBlankExercise(
          id: 'fb2',
          question: 'Fill in the scientific name',
          sentenceTemplate: 'The ___ is also called ___.',
          correctAnswers: ['Betta', 'Siamese Fighting Fish'],
          alternatives: [
            ['Betta splendens'],
            ['Fighting Fish', 'Betta Fish'],
          ],
          acceptAlternatives: true,
        );
      });

      test('validates main answers', () {
        expect(
          exercise.validate(['Betta', 'Siamese Fighting Fish']),
          isTrue,
        );
      });

      test('validates alternative answers', () {
        expect(
          exercise.validate(['Betta splendens', 'Fighting Fish']),
          isTrue,
        );
        expect(
          exercise.validate(['Betta', 'Betta Fish']),
          isTrue,
        );
      });

      test('rejects invalid alternatives', () {
        expect(
          exercise.validate(['Goldfish', 'Siamese Fighting Fish']),
          isFalse,
        );
      });
    });

    group('With Word Bank', () {
      late FillBlankExercise exercise;

      setUp(() {
        exercise = const FillBlankExercise(
          id: 'fb3',
          question: 'Choose the correct words',
          sentenceTemplate: 'Fish breathe through ___ and have ___.',
          correctAnswers: ['gills', 'scales'],
          wordBank: ['gills', 'scales', 'lungs', 'fur'],
        );
      });

      test('validates correct answers from word bank', () {
        expect(exercise.validate(['gills', 'scales']), isTrue);
      });

      test('has easy difficulty with word bank', () {
        expect(exercise.difficulty, equals(ExerciseDifficulty.easy));
      });

      test('serializes word bank', () {
        final json = exercise.toJson();
        expect(json['wordBank'], isNotNull);
        expect(json['wordBank'], hasLength(4));
      });
    });

    group('Case Sensitivity', () {
      test('case sensitive mode', () {
        final exercise = const FillBlankExercise(
          id: 'fb4',
          question: 'Test case sensitivity',
          sentenceTemplate: 'The genus is ___.',
          correctAnswers: ['Carassius'],
          caseSensitive: true,
        );

        expect(exercise.validate(['Carassius']), isTrue);
        expect(exercise.validate(['carassius']), isFalse);
        expect(exercise.validate(['CARASSIUS']), isFalse);
      });
    });

    test('serialization round-trip', () {
      final exercise = const FillBlankExercise(
        id: 'fb5',
        question: 'Test',
        sentenceTemplate: '___ ___',
        correctAnswers: ['one', 'two'],
        wordBank: ['one', 'two', 'three'],
        caseSensitive: true,
        acceptAlternatives: false,
      );

      final json = exercise.toJson();
      final restored = FillBlankExercise.fromJson(json);

      expect(restored.id, equals(exercise.id));
      expect(restored.caseSensitive, isTrue);
      expect(restored.acceptAlternatives, isFalse);
      expect(restored.wordBank, hasLength(3));
    });
  });

  group('TrueFalseExercise', () {
    late TrueFalseExercise trueExercise;
    late TrueFalseExercise falseExercise;

    setUp(() {
      trueExercise = const TrueFalseExercise(
        id: 'tf1',
        question: 'Fish need oxygen to survive',
        correctAnswer: true,
        explanation: 'All fish require oxygen, extracted from water via gills',
        hint: 'Think about what all living things need',
      );

      falseExercise = const TrueFalseExercise(
        id: 'tf2',
        question: 'Goldfish have a 3-second memory',
        correctAnswer: false,
        explanation: 'This is a myth - goldfish can remember for months',
      );
    });

    test('validates true answer correctly', () {
      expect(trueExercise.validate(true), isTrue);
      expect(trueExercise.validate(false), isFalse);
    });

    test('validates false answer correctly', () {
      expect(falseExercise.validate(false), isTrue);
      expect(falseExercise.validate(true), isFalse);
    });

    test('handles invalid answer type', () {
      expect(trueExercise.validate('true'), isFalse);
      expect(trueExercise.validate(1), isFalse);
      expect(trueExercise.validate(null), isFalse);
    });

    test('provides hint', () {
      expect(
        trueExercise.getHint(),
        equals('Think about what all living things need'),
      );
    });

    test('has easy difficulty', () {
      expect(trueExercise.difficulty, equals(ExerciseDifficulty.easy));
      expect(falseExercise.difficulty, equals(ExerciseDifficulty.easy));
    });

    test('serializes correctly', () {
      final json = trueExercise.toJson();
      expect(json['type'], equals('trueFalse'));
      expect(json['correctAnswer'], isTrue);

      final restored = TrueFalseExercise.fromJson(json);
      expect(restored.validate(true), isTrue);
    });
  });

  group('MatchingExercise', () {
    late MatchingExercise exercise;

    setUp(() {
      exercise = const MatchingExercise(
        id: 'm1',
        question: 'Match fish to their water type',
        leftItems: ['Goldfish', 'Clownfish', 'Betta'],
        rightItems: ['Freshwater', 'Saltwater', 'Freshwater'],
        correctPairs: {0: 0, 1: 1, 2: 2},
        explanation: 'Different fish species require different water types',
      );
    });

    test('validates correct pairs', () {
      expect(exercise.validate({0: 0, 1: 1, 2: 2}), isTrue);
    });

    test('validates incorrect pairs', () {
      expect(exercise.validate({0: 1, 1: 0, 2: 2}), isFalse);
      expect(exercise.validate({0: 0, 1: 2, 2: 1}), isFalse);
    });

    test('requires all pairs', () {
      expect(exercise.validate({0: 0, 1: 1}), isFalse); // Missing pair
      expect(exercise.validate({0: 0}), isFalse); // Only one pair
    });

    test('rejects extra pairs', () {
      expect(
        exercise.validate({0: 0, 1: 1, 2: 2, 3: 0}),
        isFalse,
      );
    });

    test('handles invalid answer type', () {
      expect(exercise.validate([0, 1, 2]), isFalse);
      expect(exercise.validate('pairs'), isFalse);
      expect(exercise.validate(null), isFalse);
    });

    test('difficulty scales with number of items', () {
      final easyExercise = const MatchingExercise(
        id: 'm2',
        question: 'Easy match',
        leftItems: ['A', 'B'],
        rightItems: ['1', '2'],
        correctPairs: {0: 0, 1: 1},
      );
      expect(easyExercise.difficulty, equals(ExerciseDifficulty.easy));

      final mediumExercise = const MatchingExercise(
        id: 'm3',
        question: 'Medium match',
        leftItems: ['A', 'B', 'C', 'D'],
        rightItems: ['1', '2', '3', '4'],
        correctPairs: {0: 0, 1: 1, 2: 2, 3: 3},
      );
      expect(mediumExercise.difficulty, equals(ExerciseDifficulty.medium));

      final hardExercise = const MatchingExercise(
        id: 'm4',
        question: 'Hard match',
        leftItems: ['A', 'B', 'C', 'D', 'E', 'F'],
        rightItems: ['1', '2', '3', '4', '5', '6'],
        correctPairs: {0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5},
      );
      expect(hardExercise.difficulty, equals(ExerciseDifficulty.hard));
    });

    test('serialization preserves pairs', () {
      final json = exercise.toJson();
      expect(json['type'], equals('matching'));
      expect(json['correctPairs'], isA<Map>());

      final restored = MatchingExercise.fromJson(json);
      expect(restored.correctPairs, equals(exercise.correctPairs));
      expect(restored.validate({0: 0, 1: 1, 2: 2}), isTrue);
    });

    test('supports images', () {
      final imageExercise = const MatchingExercise(
        id: 'm5',
        question: 'Match fish images to names',
        leftItems: ['Image 1', 'Image 2'],
        rightItems: ['Goldfish', 'Betta'],
        correctPairs: {0: 0, 1: 1},
        leftImages: ['goldfish.jpg', 'betta.jpg'],
      );

      final json = imageExercise.toJson();
      expect(json['leftImages'], isNotNull);
      expect(json['leftImages'], hasLength(2));
    });
  });

  group('OrderingExercise', () {
    late OrderingExercise exercise;

    setUp(() {
      exercise = const OrderingExercise(
        id: 'o1',
        question: 'Order the nitrogen cycle stages',
        items: [
          'Ammonia is produced',
          'Nitrite is formed',
          'Nitrate is formed',
          'Plants absorb nitrate',
        ],
        explanation: 'The nitrogen cycle follows this specific sequence',
      );
    });

    test('validates correct order', () {
      expect(exercise.validate([0, 1, 2, 3]), isTrue);
    });

    test('validates incorrect order', () {
      expect(exercise.validate([1, 0, 2, 3]), isFalse);
      expect(exercise.validate([3, 2, 1, 0]), isFalse);
      expect(exercise.validate([0, 2, 1, 3]), isFalse);
    });

    test('requires all items', () {
      expect(exercise.validate([0, 1, 2]), isFalse);
      expect(exercise.validate([0, 1]), isFalse);
    });

    test('rejects extra items', () {
      expect(exercise.validate([0, 1, 2, 3, 4]), isFalse);
    });

    test('handles invalid answer type', () {
      expect(exercise.validate('0123'), isFalse);
      expect(exercise.validate(null), isFalse);
      expect(exercise.validate({0: 0}), isFalse);
    });

    test('calculates score for partial credit', () {
      expect(exercise.calculateScore([0, 1, 2, 3]), equals(4)); // All correct
      expect(exercise.calculateScore([0, 1, 3, 2]), equals(2)); // First 2 correct (position 0 and 1 match)
      expect(exercise.calculateScore([1, 0, 2, 3]), equals(2)); // Position 2 and 3 are correct
    });

    test('calculates percentage', () {
      expect(exercise.calculatePercentage([0, 1, 2, 3]), equals(100.0));
      expect(exercise.calculatePercentage([0, 1, 3, 2]), equals(50.0));
      expect(exercise.calculatePercentage([1, 0, 2, 3]), equals(50.0));
    });

    test('supports custom correct order', () {
      final customExercise = const OrderingExercise(
        id: 'o2',
        question: 'Order by size',
        items: ['Small', 'Medium', 'Large'],
        correctOrder: [2, 1, 0], // Reverse order
      );

      expect(customExercise.validate([2, 1, 0]), isTrue);
      expect(customExercise.validate([0, 1, 2]), isFalse);
    });

    test('difficulty scales with number of items', () {
      final easyExercise = const OrderingExercise(
        id: 'o3',
        question: 'Easy order',
        items: ['First', 'Second'],
      );
      expect(easyExercise.difficulty, equals(ExerciseDifficulty.easy));

      final mediumExercise = const OrderingExercise(
        id: 'o4',
        question: 'Medium order',
        items: ['1', '2', '3', '4'],
      );
      expect(mediumExercise.difficulty, equals(ExerciseDifficulty.medium));

      final hardExercise = const OrderingExercise(
        id: 'o5',
        question: 'Hard order',
        items: ['1', '2', '3', '4', '5', '6'],
      );
      expect(hardExercise.difficulty, equals(ExerciseDifficulty.hard));
    });

    test('serialization preserves order', () {
      final json = exercise.toJson();
      expect(json['type'], equals('ordering'));
      expect(json['items'], hasLength(4));

      final restored = OrderingExercise.fromJson(json);
      expect(restored.items, equals(exercise.items));
      expect(restored.validate([0, 1, 2, 3]), isTrue);
    });

    test('supports partial credit flag', () {
      final partialExercise = const OrderingExercise(
        id: 'o6',
        question: 'Test partial credit',
        items: ['A', 'B', 'C'],
        allowPartialCredit: true,
      );

      final json = partialExercise.toJson();
      expect(json['allowPartialCredit'], isTrue);

      final restored = OrderingExercise.fromJson(json);
      expect(restored.allowPartialCredit, isTrue);
    });
  });

  group('EnhancedQuiz', () {
    late EnhancedQuiz quiz;

    setUp(() {
      quiz = EnhancedQuiz(
        id: 'quiz1',
        lessonId: 'lesson1',
        exercises: const [
          MultipleChoiceExercise(
            id: 'mc1',
            question: 'Test Q1',
            options: ['A', 'B', 'C'],
            correctIndex: 0,
          ),
          TrueFalseExercise(
            id: 'tf1',
            question: 'Test Q2',
            correctAnswer: true,
          ),
          FillBlankExercise(
            id: 'fb1',
            question: 'Test Q3',
            sentenceTemplate: '___',
            correctAnswers: ['answer'],
          ),
        ],
        passingScore: 75,
        bonusXp: 50,
        shuffleExercises: true,
        mode: QuizMode.practice,
      );
    });

    test('counts exercises correctly', () {
      expect(quiz.maxScore, equals(3));
    });

    test('groups exercises by difficulty', () {
      final byDifficulty = quiz.exercisesByDifficulty;
      expect(
        byDifficulty[ExerciseDifficulty.easy]!.length,
        equals(1), // TrueFalse
      );
      expect(
        byDifficulty[ExerciseDifficulty.medium]!.length,
        equals(2), // MCQ + FillBlank
      );
    });

    test('groups exercises by type', () {
      final byType = quiz.exercisesByType;
      expect(byType[ExerciseType.multipleChoice]!.length, equals(1));
      expect(byType[ExerciseType.trueFalse]!.length, equals(1));
      expect(byType[ExerciseType.fillBlank]!.length, equals(1));
      expect(byType[ExerciseType.matching]!.length, equals(0));
      expect(byType[ExerciseType.ordering]!.length, equals(0));
    });

    test('serializes quiz configuration', () {
      final json = quiz.toJson();
      expect(json['id'], equals('quiz1'));
      expect(json['lessonId'], equals('lesson1'));
      expect(json['exercises'], hasLength(3));
      expect(json['passingScore'], equals(75));
      expect(json['bonusXp'], equals(50));
      expect(json['shuffleExercises'], isTrue);
      expect(json['mode'], equals('practice'));
    });

    test('deserializes quiz with mixed exercise types', () {
      final json = quiz.toJson();
      final restored = EnhancedQuiz.fromJson(json);

      expect(restored.exercises.length, equals(3));
      expect(
        restored.exercises[0],
        isA<MultipleChoiceExercise>(),
      );
      expect(restored.exercises[1], isA<TrueFalseExercise>());
      expect(restored.exercises[2], isA<FillBlankExercise>());
      expect(restored.mode, equals(QuizMode.practice));
    });

    test('supports all quiz modes', () {
      for (final mode in QuizMode.values) {
        final testQuiz = EnhancedQuiz(
          id: 'test',
          lessonId: 'lesson',
          exercises: const [],
          mode: mode,
        );

        final json = testQuiz.toJson();
        final restored = EnhancedQuiz.fromJson(json);
        expect(restored.mode, equals(mode));
      }
    });
  });

  group('Exercise Factory', () {
    test('creates exercises from JSON', () {
      final mcJson = {
        'id': 'mc1',
        'type': 'multipleChoice',
        'question': 'Test',
        'options': ['A', 'B'],
        'correctIndex': 0,
      };
      expect(
        Exercise.fromJson(mcJson),
        isA<MultipleChoiceExercise>(),
      );

      final tfJson = {
        'id': 'tf1',
        'type': 'trueFalse',
        'question': 'Test',
        'correctAnswer': true,
      };
      expect(Exercise.fromJson(tfJson), isA<TrueFalseExercise>());

      final fbJson = {
        'id': 'fb1',
        'type': 'fillBlank',
        'question': 'Test',
        'sentenceTemplate': '___',
        'correctAnswers': ['test'],
      };
      expect(Exercise.fromJson(fbJson), isA<FillBlankExercise>());

      final mJson = {
        'id': 'm1',
        'type': 'matching',
        'question': 'Test',
        'leftItems': ['A'],
        'rightItems': ['1'],
        'correctPairs': {'0': 0},
      };
      expect(Exercise.fromJson(mJson), isA<MatchingExercise>());

      final oJson = {
        'id': 'o1',
        'type': 'ordering',
        'question': 'Test',
        'items': ['A', 'B'],
      };
      expect(Exercise.fromJson(oJson), isA<OrderingExercise>());
    });
  });

  group('Edge Cases', () {
    test('handles empty options in multiple choice', () {
      const exercise = MultipleChoiceExercise(
        id: 'mc1',
        question: 'Test',
        options: [],
        correctIndex: 0,
      );
      // Should handle gracefully even if malformed
      expect(exercise.options, isEmpty);
    });

    test('handles empty items in ordering', () {
      const exercise = OrderingExercise(
        id: 'o1',
        question: 'Test',
        items: [],
      );
      expect(exercise.items, isEmpty);
      expect(exercise.validate([]), isTrue); // Empty validates empty
    });

    test('handles empty word bank', () {
      const exercise = FillBlankExercise(
        id: 'fb1',
        question: 'Test',
        sentenceTemplate: '___',
        correctAnswers: ['test'],
        wordBank: [],
      );
      // Word bank exists but is empty
      expect(exercise.wordBank, isEmpty);
      expect(exercise.difficulty, equals(ExerciseDifficulty.easy));
    });

    test('handles null alternatives', () {
      const exercise = FillBlankExercise(
        id: 'fb1',
        question: 'Test',
        sentenceTemplate: '___',
        correctAnswers: ['test'],
        alternatives: null,
      );
      expect(exercise.validate(['test']), isTrue);
      expect(exercise.validate(['other']), isFalse);
    });
  });
}
