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
        drillId: PracticeDrillId.setupPlanning,
        cards: [_card('fh_ich_section_0')],
        lessonState: const LessonState(),
      );

      expect(questions.single, isA<MultipleChoiceQuestion>());
      final question = questions.single as MultipleChoiceQuestion;
      expect(question.questionText, contains('Ich'));
    });

    test('turns ich cards into a diagnosis scenario', () {
      final questions = PracticeDrillQuestionService.resolveQuestions(
        drillId: PracticeDrillId.diagnosis,
        cards: [_card('fh_ich_section_0')],
        lessonState: const LessonState(),
      );

      final question = questions.single as MultipleChoiceQuestion;
      expect(question.questionText, contains('white spots'));
      expect(question.questionText, contains('flashing'));
      expect(question.options[question.correctIndex], contains('Test water'));
      expect(question.explanation, contains('ich'));
    });

    test('turns troubleshooting diagnosis cards into a triage scenario', () {
      final questions = PracticeDrillQuestionService.resolveQuestions(
        drillId: PracticeDrillId.diagnosis,
        cards: [_card('tr_disease_diagnosis_section_0')],
        lessonState: const LessonState(),
      );

      final question = questions.single as MultipleChoiceQuestion;
      expect(question.questionText, contains('clamped fins'));
      expect(question.options[question.correctIndex], contains('water tests'));
      expect(question.explanation, contains('history'));
    });

    test('uses a general diagnosis scenario for other diagnosis cards', () {
      final questions = PracticeDrillQuestionService.resolveQuestions(
        drillId: PracticeDrillId.diagnosis,
        cards: [_card('fh_hospital_tank_section_0')],
        lessonState: const LessonState(),
      );

      final question = questions.single as MultipleChoiceQuestion;
      expect(question.questionText, contains('symptom'));
      expect(question.options[question.correctIndex], contains('water'));
    });

    test('turns betta cards into a compatibility scenario', () {
      final questions = PracticeDrillQuestionService.resolveQuestions(
        drillId: PracticeDrillId.compatibility,
        cards: [_card('sc_betta_section_0')],
        lessonState: const LessonState(),
      );

      final question = questions.single as MultipleChoiceQuestion;
      expect(question.questionText, contains('betta'));
      expect(question.questionText, contains('fin'));
      expect(question.options[question.correctIndex], contains('calm'));
      expect(question.explanation, contains('temperament'));
    });

    test('turns goldfish cards into a mismatch scenario', () {
      final questions = PracticeDrillQuestionService.resolveQuestions(
        drillId: PracticeDrillId.compatibility,
        cards: [_card('sc_goldfish_section_0')],
        lessonState: const LessonState(),
      );

      final question = questions.single as MultipleChoiceQuestion;
      expect(question.questionText, contains('goldfish'));
      expect(question.options[question.correctIndex], contains('separate'));
      expect(question.explanation, contains('waste'));
    });

    test('uses a general compatibility checklist for other species cards', () {
      final questions = PracticeDrillQuestionService.resolveQuestions(
        drillId: PracticeDrillId.compatibility,
        cards: [_card('ff_choosing_section_0')],
        lessonState: const LessonState(),
      );

      final question = questions.single as MultipleChoiceQuestion;
      expect(question.questionText, contains('community tank'));
      expect(question.options[question.correctIndex], contains('adult size'));
      expect(question.options[question.correctIndex], contains('group size'));
    });
  });
}
