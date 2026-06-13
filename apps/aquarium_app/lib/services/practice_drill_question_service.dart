/// Resolves skill-drill sessions into scenario-style practice questions.
library;

import '../models/practice_drill.dart';
import '../models/resolved_question.dart';
import '../models/spaced_repetition.dart';
import '../providers/lesson_provider.dart';
import 'question_resolver.dart';

class PracticeDrillQuestionService {
  static List<ResolvedQuestion> resolveQuestions({
    required PracticeDrillId drillId,
    required List<ReviewCard> cards,
    required LessonState lessonState,
  }) {
    final fallback = QuestionResolver.resolveQuestions(
      cards: cards,
      lessonState: lessonState,
    );

    if (drillId != PracticeDrillId.parameterInterpretation) {
      return fallback;
    }

    return [
      for (var index = 0; index < cards.length; index++)
        _parameterQuestion(cards[index]) ?? fallback[index],
    ];
  }

  static MultipleChoiceQuestion? _parameterQuestion(ReviewCard card) {
    final conceptId = card.conceptId;

    if (conceptId.startsWith('wp_ph')) {
      return _mc(
        card: card,
        questionText:
            'Your tank pH has moved from 7.4 to 6.4 since yesterday. Fish are active, but the change is sudden. What is the best first response?',
        options: [
          'Check KH, retest pH, and make a partial water change if fish show stress',
          'Add a strong pH-up chemical until the number returns to 7.4',
          'Ignore it because any pH value below 7 is always safer',
          'Replace all filter media so the water can reset',
        ],
        correctIndex: 0,
        explanation:
            'A sudden pH shift is a stability problem. KH helps explain whether the tank has lost buffering, and any correction should be gradual.',
      );
    }

    if (conceptId.startsWith('wp_temp')) {
      return _mc(
        card: card,
        questionText:
            'A tropical tank that normally sits at 25C now reads 21C after a cold night. What should you do first?',
        options: [
          'Raise the temperature gradually and check the heater is working',
          'Pour in hot water so the tank reaches 25C immediately',
          'Feed extra food because colder fish need more calories',
          'Turn the filter off until the water warms up',
        ],
        correctIndex: 0,
        explanation:
            'Temperature corrections should be gradual. Sudden heating can shock fish, and filtration/oxygen should stay protected.',
      );
    }

    if (conceptId.startsWith('wp_chlorine')) {
      return _mc(
        card: card,
        questionText:
            'You have just filled a bucket for a water change and realise no conditioner was added. What is the safest next step?',
        options: [
          'Dose water conditioner before the new water reaches the tank',
          'Use the water anyway because chlorine evaporates instantly',
          'Add the water, then replace all filter media',
          'Skip every future water change to avoid tap-water risk',
        ],
        correctIndex: 0,
        explanation:
            'Chlorine and chloramine can harm fish and filter bacteria. Treat tap water before it enters the aquarium.',
      );
    }

    if (conceptId.startsWith('nc_spikes') ||
        conceptId.startsWith('nc_minicycle') ||
        conceptId.startsWith('nc_testing')) {
      return _mc(
        card: card,
        questionText:
            'A test shows ammonia at 0.5 ppm and nitrite at 0.25 ppm in a stocked tank. Fish are breathing faster than usual. What should happen now?',
        options: [
          'Do an immediate partial water change, condition new water, increase aeration, and retest',
          'Add more fish so the filter bacteria have more food',
          'Deep-clean all filter media under tap water',
          'Stop testing until nitrate appears',
        ],
        correctIndex: 0,
        explanation:
            'Any measurable ammonia or nitrite in a stocked tank can be unsafe. Dilution, conditioned water, oxygen, and retesting are the first priorities.',
      );
    }

    if (conceptId.startsWith('maint_water_changes') ||
        conceptId.startsWith('maint_schedule') ||
        conceptId.startsWith('wp_tds') ||
        conceptId.startsWith('wp_seasonal')) {
      return _mc(
        card: card,
        questionText:
            'Nitrate has climbed to 60 ppm and the tank has not had a water change for three weeks. What is the best care decision?',
        options: [
          'Do a partial water change and review stocking, feeding, and the maintenance schedule',
          'Clean the filter with tap water until nitrate reads zero',
          'Add medication because nitrate is a parasite',
          'Leave it because nitrate is never relevant in freshwater tanks',
        ],
        correctIndex: 0,
        explanation:
            'High nitrate usually points to waste load and maintenance rhythm. Partial water changes and habit checks are safer than drastic filter cleaning.',
      );
    }

    return _mc(
      card: card,
      questionText:
          'A water test looks unusual compared with this tank\'s normal pattern. What is the safest way to interpret it?',
      options: [
        'Retest, compare against recent results, then make the smallest safe corrective action',
        'Change every parameter at once so the tank reaches a textbook number',
        'Ignore the test because fishkeeping is only visual',
        'Add medication before checking water or behaviour',
      ],
      correctIndex: 0,
      explanation:
          'Good parameter reading is trend-based. Confirm the result, look at fish behaviour, and avoid sudden changes unless there is an emergency.',
    );
  }

  static MultipleChoiceQuestion _mc({
    required ReviewCard card,
    required String questionText,
    required List<String> options,
    required int correctIndex,
    required String explanation,
  }) {
    return MultipleChoiceQuestion(
      card: card,
      questionText: questionText,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
    );
  }
}
