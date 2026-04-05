import 'dart:math';

import 'package:danio/models/learning.dart';
import 'package:danio/models/resolved_question.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/providers/lesson_provider.dart';
import 'package:danio/services/question_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

final _now = DateTime(2026, 4, 5);

ReviewCard _card(String conceptId, {ConceptType type = ConceptType.lesson}) {
  return ReviewCard(
    id: '${conceptId}_card',
    conceptId: conceptId,
    conceptType: type,
    lastReviewed: _now,
    nextReview: _now,
  );
}

LessonSection _keyPoint(String text) {
  return LessonSection(type: LessonSectionType.keyPoint, content: text);
}

LessonSection _text(String text) {
  return LessonSection(type: LessonSectionType.text, content: text);
}

Lesson _lesson(
  String id, {
  required String pathId,
  List<LessonSection> sections = const [],
  Quiz? quiz,
  int order = 0,
}) {
  return Lesson(
    id: id,
    pathId: pathId,
    title: 'Lesson $id',
    description: 'Desc for $id',
    orderIndex: order,
    sections: sections,
    quiz: quiz,
  );
}

LearningPath _path(String id, List<Lesson> lessons) {
  return LearningPath(
    id: id,
    title: 'Path $id',
    description: 'Desc for path $id',
    emoji: '📘',
    lessons: lessons,
  );
}

LessonState _state(List<LearningPath> paths) {
  return LessonState(
    loadedPaths: {for (final p in paths) p.id: p},
    pathLoadStates: {
      for (final p in paths) p.id: LessonLoadState.loaded,
    },
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('QuestionResolver.resolveQuestions', () {
    test('returns one ResolvedQuestion per input ReviewCard', () {
      final cards = [_card('nc_intro'), _card('nc_stages')];
      final path = _path('nc', [
        _lesson('nc_intro', pathId: 'nc', sections: [_text('hello')]),
        _lesson('nc_stages', pathId: 'nc', sections: [_text('stages')]),
      ]);
      final state = _state([path]);

      final result = QuestionResolver.resolveQuestions(
        cards: cards,
        lessonState: state,
      );

      expect(result.length, cards.length);
    });

    // -----------------------------------------------------------------------
    // Priority 2: Quiz MC
    // -----------------------------------------------------------------------
    group('quiz-sourced MC', () {
      test('creates MultipleChoiceQuestion from quiz data', () {
        final quiz = Quiz(
          id: 'q1',
          lessonId: 'nc_intro',
          questions: [
            const QuizQuestion(
              id: 'qq1',
              question: 'What is ammonia?',
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 0,
              explanation: 'Because A',
            ),
          ],
        );
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', quiz: quiz),
        ]);
        final state = _state([path]);
        final cards = [_card('nc_intro')];

        final result = QuestionResolver.resolveQuestions(
          cards: cards,
          lessonState: state,
          random: Random(42),
        );

        expect(result.length, 1);
        final q = result.first;
        expect(q, isA<MultipleChoiceQuestion>());
        final mc = q as MultipleChoiceQuestion;
        expect(mc.questionText, 'What is ammonia?');
        expect(mc.options, ['A', 'B', 'C', 'D']);
        expect(mc.correctIndex, 0);
        expect(mc.explanation, 'Because A');
      });
    });

    // -----------------------------------------------------------------------
    // Priority 3: Key-point auto-generated MC
    // -----------------------------------------------------------------------
    group('key-point MC', () {
      test('generates MC when lesson has key points but no quiz', () {
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', sections: [
            _keyPoint('Ammonia is toxic'),
          ]),
          _lesson('nc_stages', pathId: 'nc', sections: [
            _keyPoint('Nitrite is step 2'),
            _keyPoint('Nitrate is step 3'),
            _keyPoint('Bacteria do the work'),
          ]),
        ]);
        final state = _state([path]);
        final cards = [_card('nc_intro')];

        final result = QuestionResolver.resolveQuestions(
          cards: cards,
          lessonState: state,
          random: Random(42),
        );

        expect(result.length, 1);
        final q = result.first;
        expect(q, isA<MultipleChoiceQuestion>());
        final mc = q as MultipleChoiceQuestion;

        // Correct answer must be in the options
        expect(mc.options, contains('Ammonia is toxic'));
        // Should have 4 options (1 correct + 3 distractors)
        expect(mc.options.length, 4);
        // correctIndex should point to the right answer
        expect(mc.options[mc.correctIndex], 'Ammonia is toxic');
      });

      test('distractors come from sibling lessons, not the same lesson', () {
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', sections: [
            _keyPoint('Ammonia is toxic'),
            _keyPoint('Fish produce ammonia'),
          ]),
          _lesson('nc_stages', pathId: 'nc', sections: [
            _keyPoint('Nitrite is step 2'),
            _keyPoint('Nitrate is step 3'),
            _keyPoint('Bacteria do the work'),
          ]),
          _lesson('nc_how_to', pathId: 'nc', sections: [
            _keyPoint('Cycle takes 4-6 weeks'),
            _keyPoint('Add ammonia source'),
          ]),
        ]);
        final state = _state([path]);

        // Use a fixed seed so the result is deterministic.
        final cards = [_card('nc_intro')];
        final result = QuestionResolver.resolveQuestions(
          cards: cards,
          lessonState: state,
          random: Random(0),
        );

        final mc = result.first as MultipleChoiceQuestion;
        final correct = mc.options[mc.correctIndex];

        // The correct answer should be from nc_intro's key points.
        expect(
          ['Ammonia is toxic', 'Fish produce ammonia'],
          contains(correct),
        );

        // The other options (distractors) should NOT all be from nc_intro.
        final distractors = List<String>.from(mc.options)..remove(correct);
        final siblingKeyPoints = [
          'Nitrite is step 2',
          'Nitrate is step 3',
          'Bacteria do the work',
          'Cycle takes 4-6 weeks',
          'Add ammonia source',
        ];
        // At least one distractor must come from a sibling lesson.
        expect(
          distractors.any((d) => siblingKeyPoints.contains(d)),
          isTrue,
          reason: 'Distractors should include key points from sibling lessons',
        );
      });
    });

    // -----------------------------------------------------------------------
    // Priority 1: Matching pairs (every 5th card)
    // -----------------------------------------------------------------------
    group('matching pairs', () {
      test('every 5th card becomes MatchingPairsQuestion when 3+ siblings', () {
        // Build a path with 4 lessons, each having key points.
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', sections: [
            _keyPoint('Ammonia is toxic'),
          ]),
          _lesson('nc_stages', pathId: 'nc', sections: [
            _keyPoint('Nitrite is step 2'),
          ]),
          _lesson('nc_how_to', pathId: 'nc', sections: [
            _keyPoint('Cycle takes 4-6 weeks'),
          ]),
          _lesson('nc_testing', pathId: 'nc', sections: [
            _keyPoint('Test regularly'),
          ]),
        ]);
        final state = _state([path]);

        // Index 4 (5th card) should trigger matching pairs.
        final cards = [
          _card('nc_intro'),
          _card('nc_stages'),
          _card('nc_how_to'),
          _card('nc_testing'),
          _card('nc_intro'), // index 4 -> should be matching pairs
        ];

        final result = QuestionResolver.resolveQuestions(
          cards: cards,
          lessonState: state,
          random: Random(42),
        );

        expect(result.length, 5);
        expect(result[4], isA<MatchingPairsQuestion>());
        final mp = result[4] as MatchingPairsQuestion;
        expect(mp.pairs.length, greaterThanOrEqualTo(3));
        expect(mp.pairs.length, lessThanOrEqualTo(4));
      });

      test('falls through when fewer than 3 siblings have key points', () {
        // Path with only 2 lessons that have key points.
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', sections: [
            _keyPoint('Ammonia is toxic'),
          ]),
          _lesson('nc_stages', pathId: 'nc', sections: [
            _keyPoint('Nitrite is step 2'),
          ]),
        ]);
        final state = _state([path]);

        final cards = [
          _card('nc_intro'),
          _card('nc_stages'),
          _card('nc_intro'),
          _card('nc_stages'),
          _card('nc_intro'), // index 4 -> matching pairs attempted but < 3 siblings
        ];

        final result = QuestionResolver.resolveQuestions(
          cards: cards,
          lessonState: state,
          random: Random(42),
        );

        // Should NOT be matching pairs — falls through to key-point MC or fallback.
        expect(result[4], isNot(isA<MatchingPairsQuestion>()));
      });
    });

    // -----------------------------------------------------------------------
    // Priority 4: Fallback
    // -----------------------------------------------------------------------
    group('graceful fallback', () {
      test('returns self-assess MC when no lesson data exists', () {
        // Empty state — no paths loaded.
        const state = LessonState();
        final cards = [_card('unknown_concept')];

        final result = QuestionResolver.resolveQuestions(
          cards: cards,
          lessonState: state,
        );

        expect(result.length, 1);
        final q = result.first;
        expect(q, isA<MultipleChoiceQuestion>());
        final mc = q as MultipleChoiceQuestion;
        expect(mc.options, [
          'I remember this well',
          'I think I know this',
          "I'm not sure about this",
          "I've forgotten this",
        ]);
        expect(mc.correctIndex, 0);
      });

      test('uses conceptDisplayName for fallback questionText', () {
        const state = LessonState();
        final cards = [_card('nc_intro')];

        final result = QuestionResolver.resolveQuestions(
          cards: cards,
          lessonState: state,
        );

        final mc = result.first as MultipleChoiceQuestion;
        // nc_intro maps to 'Why New Tanks Kill Fish' in concept_display_names.
        expect(mc.questionText, 'Why New Tanks Kill Fish');
      });
    });

    // -----------------------------------------------------------------------
    // Option randomisation
    // -----------------------------------------------------------------------
    group('option randomisation', () {
      test('correct answer is not always at the same index', () {
        // Run with many different seeds and collect the correctIndex values.
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', sections: [
            _keyPoint('Ammonia is toxic'),
          ]),
          _lesson('nc_stages', pathId: 'nc', sections: [
            _keyPoint('Nitrite is step 2'),
            _keyPoint('Nitrate is step 3'),
            _keyPoint('Bacteria do the work'),
          ]),
        ]);
        final state = _state([path]);

        final indices = <int>{};
        for (var seed = 0; seed < 50; seed++) {
          final result = QuestionResolver.resolveQuestions(
            cards: [_card('nc_intro')],
            lessonState: state,
            random: Random(seed),
          );
          final mc = result.first as MultipleChoiceQuestion;
          indices.add(mc.correctIndex);
        }

        // With 50 different seeds, we should see at least 2 different positions.
        expect(
          indices.length,
          greaterThan(1),
          reason: 'Correct answer position should vary across runs',
        );
      });
    });

    // -----------------------------------------------------------------------
    // Concept-ID -> lesson lookup edge cases
    // -----------------------------------------------------------------------
    group('concept ID resolution', () {
      test('finds lesson from structured concept ID like nc_intro_section_2',
          () {
        final quiz = Quiz(
          id: 'q1',
          lessonId: 'nc_intro',
          questions: [
            const QuizQuestion(
              id: 'qq1',
              question: 'Question from quiz',
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 1,
            ),
          ],
        );
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', quiz: quiz),
        ]);
        final state = _state([path]);

        // Card has a section-style concept ID, not a bare lesson ID.
        final cards = [_card('nc_intro_section_2')];

        final result = QuestionResolver.resolveQuestions(
          cards: cards,
          lessonState: state,
          random: Random(42),
        );

        // Should resolve to nc_intro and use its quiz.
        expect(result.first, isA<MultipleChoiceQuestion>());
        final mc = result.first as MultipleChoiceQuestion;
        expect(mc.questionText, 'Question from quiz');
      });

      test('finds lesson from quiz-style concept ID like nc_intro_quiz_q1',
          () {
        final quiz = Quiz(
          id: 'q1',
          lessonId: 'nc_intro',
          questions: [
            const QuizQuestion(
              id: 'qq1',
              question: 'Quiz question text',
              options: ['X', 'Y', 'Z', 'W'],
              correctIndex: 2,
            ),
          ],
        );
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', quiz: quiz),
        ]);
        final state = _state([path]);

        final cards = [_card('nc_intro_quiz_q1')];

        final result = QuestionResolver.resolveQuestions(
          cards: cards,
          lessonState: state,
          random: Random(42),
        );

        expect(result.first, isA<MultipleChoiceQuestion>());
        final mc = result.first as MultipleChoiceQuestion;
        expect(mc.questionText, 'Quiz question text');
      });
    });

    // -----------------------------------------------------------------------
    // Priority cascade
    // -----------------------------------------------------------------------
    group('priority cascade', () {
      test('quiz takes priority over key points for non-5th cards', () {
        final quiz = Quiz(
          id: 'q1',
          lessonId: 'nc_intro',
          questions: [
            const QuizQuestion(
              id: 'qq1',
              question: 'Quiz Q',
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 0,
            ),
          ],
        );
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', sections: [
            _keyPoint('A key point'),
          ], quiz: quiz),
          _lesson('nc_stages', pathId: 'nc', sections: [
            _keyPoint('D1'),
            _keyPoint('D2'),
            _keyPoint('D3'),
          ]),
        ]);
        final state = _state([path]);

        // Index 0 — not a 5th card, has both quiz and key points.
        final result = QuestionResolver.resolveQuestions(
          cards: [_card('nc_intro')],
          lessonState: state,
          random: Random(42),
        );

        final mc = result.first as MultipleChoiceQuestion;
        expect(mc.questionText, 'Quiz Q',
            reason: 'Quiz should take priority over key-point MC');
      });

      test('matching pairs takes priority over quiz at index 4', () {
        final quiz = Quiz(
          id: 'q1',
          lessonId: 'nc_intro',
          questions: [
            const QuizQuestion(
              id: 'qq1',
              question: 'Quiz Q',
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 0,
            ),
          ],
        );
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', sections: [
            _keyPoint('KP1'),
          ], quiz: quiz),
          _lesson('nc_stages', pathId: 'nc', sections: [
            _keyPoint('KP2'),
          ]),
          _lesson('nc_how_to', pathId: 'nc', sections: [
            _keyPoint('KP3'),
          ]),
          _lesson('nc_testing', pathId: 'nc', sections: [
            _keyPoint('KP4'),
          ]),
        ]);
        final state = _state([path]);

        final cards = [
          _card('nc_intro'),
          _card('nc_stages'),
          _card('nc_how_to'),
          _card('nc_testing'),
          _card('nc_intro'), // index 4
        ];

        final result = QuestionResolver.resolveQuestions(
          cards: cards,
          lessonState: state,
          random: Random(42),
        );

        expect(result[4], isA<MatchingPairsQuestion>(),
            reason: 'Matching pairs should take priority at index 4');
      });
    });

    // -----------------------------------------------------------------------
    // Empty / edge cases
    // -----------------------------------------------------------------------
    group('edge cases', () {
      test('empty card list returns empty result', () {
        const state = LessonState();
        final result = QuestionResolver.resolveQuestions(
          cards: [],
          lessonState: state,
        );
        expect(result, isEmpty);
      });

      test('lesson with empty quiz falls through to key points', () {
        final quiz = Quiz(
          id: 'q1',
          lessonId: 'nc_intro',
          questions: const [], // empty quiz
        );
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', sections: [
            _keyPoint('A key point'),
          ], quiz: quiz),
          _lesson('nc_stages', pathId: 'nc', sections: [
            _keyPoint('D1'),
            _keyPoint('D2'),
            _keyPoint('D3'),
          ]),
        ]);
        final state = _state([path]);

        final result = QuestionResolver.resolveQuestions(
          cards: [_card('nc_intro')],
          lessonState: state,
          random: Random(42),
        );

        final mc = result.first as MultipleChoiceQuestion;
        // Should have used key-point MC, not quiz (quiz was empty).
        expect(mc.options, contains('A key point'));
      });

      test('lesson with no quiz and no key points uses fallback', () {
        final path = _path('nc', [
          _lesson('nc_intro', pathId: 'nc', sections: [
            _text('Just some text, no key points'),
          ]),
        ]);
        final state = _state([path]);

        final result = QuestionResolver.resolveQuestions(
          cards: [_card('nc_intro')],
          lessonState: state,
          random: Random(42),
        );

        final mc = result.first as MultipleChoiceQuestion;
        expect(mc.options.first, 'I remember this well');
      });
    });
  });
}
