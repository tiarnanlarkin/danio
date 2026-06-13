// Tests for PracticeDrillQuestionService.
//
// Run: flutter test test/services/practice_drill_question_service_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/practice_drill.dart';
import 'package:danio/models/resolved_question.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/providers/lesson_provider.dart';
import 'package:danio/services/practice_drill_question_service.dart';

ReviewCard _card(String conceptId) {
  final now = DateTime.now();
  return ReviewCard(
    id: conceptId,
    conceptId: conceptId,
    conceptType: ConceptType.fact,
    lastReviewed: now.subtract(const Duration(days: 2)),
    nextReview: now.subtract(const Duration(minutes: 1)),
  );
}

void main() {
  group('PracticeDrillQuestionService', () {
    test('turns pH cards into a parameter-reading scenario', () {
      final questions = PracticeDrillQuestionService.resolveQuestions(
        drillId: PracticeDrillId.parameterInterpretation,
        cards: [_card('wp_ph_section_0')],
        lessonState: const LessonState(),
      );

      expect(questions, hasLength(1));
      expect(questions.first, isA<MultipleChoiceQuestion>());
      final question = questions.first as MultipleChoiceQuestion;

      expect(question.questionText, contains('pH'));
      expect(question.options, hasLength(4));
      expect(question.options[question.correctIndex], contains('KH'));
      expect(question.explanation, isNotNull);
      expect(question.explanation, contains('stability'));
    });

    test(
      'turns cycling spike cards into an immediate water-safety scenario',
      () {
        final questions = PracticeDrillQuestionService.resolveQuestions(
          drillId: PracticeDrillId.parameterInterpretation,
          cards: [_card('nc_spikes_section_0')],
          lessonState: const LessonState(),
        );

        final question = questions.single as MultipleChoiceQuestion;
        expect(question.questionText, contains('ammonia'));
        expect(
          question.options[question.correctIndex],
          contains('water change'),
        );
        expect(question.explanation, contains('ammonia'));
      },
    );

    test('non-parameter drills keep the normal fallback resolver', () {
      final questions = PracticeDrillQuestionService.resolveQuestions(
        drillId: PracticeDrillId.diagnosis,
        cards: [_card('fh_ich_section_0')],
        lessonState: const LessonState(),
      );

      expect(questions.single, isA<MultipleChoiceQuestion>());
      final question = questions.single as MultipleChoiceQuestion;
      expect(question.questionText, contains('Ich'));
    });
  });
}
