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

    if (drillId == PracticeDrillId.parameterInterpretation) {
      return [
        for (var index = 0; index < cards.length; index++)
          _parameterQuestion(cards[index]) ?? fallback[index],
      ];
    }

    if (drillId == PracticeDrillId.diagnosis) {
      return [
        for (var index = 0; index < cards.length; index++)
          _diagnosisQuestion(cards[index]) ?? fallback[index],
      ];
    }

    if (drillId == PracticeDrillId.compatibility) {
      return [
        for (var index = 0; index < cards.length; index++)
          _compatibilityQuestion(cards[index]) ?? fallback[index],
      ];
    }

    return fallback;
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

  static MultipleChoiceQuestion? _diagnosisQuestion(ReviewCard card) {
    final conceptId = card.conceptId;

    if (conceptId.startsWith('fh_ich')) {
      return _mc(
        card: card,
        questionText:
            'Several fish have tiny white spots, are flashing against decor, and one is breathing faster. What is the best diagnosis step?',
        options: [
          'Test water, confirm the pattern fits ich, protect oxygen, and use an appropriate treatment plan',
          'Add three medications at once before checking water quality',
          'Move every fish between tanks repeatedly until the spots fall off',
          'Stop filtration because filters make white spots spread faster',
        ],
        correctIndex: 0,
        explanation:
            'White spots and flashing can fit ich, but water quality and oxygen still matter. Confirm signs before treating and avoid random medication mixes.',
      );
    }

    if (conceptId.startsWith('fh_fin_rot')) {
      return _mc(
        card: card,
        questionText:
            'A fish has ragged fins after a week of high nitrate and chasing from tank mates. What should you do first?',
        options: [
          'Test water, improve conditions, reduce stress, and isolate or treat if the damage worsens',
          'Trim the fins so they grow back evenly',
          'Add salt and antibiotics without checking the tank',
          'Ignore it because fins never indicate stress',
        ],
        correctIndex: 0,
        explanation:
            'Fin damage often involves water quality, stress, or injury. Stabilising conditions and watching progression comes before heavy treatment.',
      );
    }

    if (conceptId.startsWith('fh_fungal')) {
      return _mc(
        card: card,
        questionText:
            'A fish has a cottony patch where it was scraped during a netting attempt. What is the safest interpretation?',
        options: [
          'Treat it as a possible secondary infection, improve water, and isolate if needed',
          'Assume every cottony patch is harmless plant debris',
          'Dose the display tank blindly with several medications',
          'Raise temperature sharply to burn the patch away',
        ],
        correctIndex: 0,
        explanation:
            'Fungal-looking growth often follows injury or poor conditions. Clean water and careful isolation reduce risk while treatment is chosen.',
      );
    }

    if (conceptId.startsWith('fh_parasites')) {
      return _mc(
        card: card,
        questionText:
            'A new fish is losing weight, flashing, and producing stringy waste while the rest of the tank looks normal. What is the best next move?',
        options: [
          'Quarantine, record symptoms, check water, and choose treatment only after narrowing the cause',
          'Treat the whole tank for every parasite at once',
          'Add more food only, because all weight loss is hunger',
          'Move the fish into colder water to slow the symptoms',
        ],
        correctIndex: 0,
        explanation:
            'Parasite signs can overlap with stress and diet issues. Quarantine and evidence gathering make treatment safer.',
      );
    }

    if (conceptId.startsWith('tr_disease_diagnosis')) {
      return _mc(
        card: card,
        questionText:
            'You notice clamped fins, hiding, and one fish breathing quickly, but there are no obvious spots or wounds. What should come before treatment?',
        options: [
          'Run water tests, check recent history, and compare symptoms across fish',
          'Choose the strongest medication because the exact cause is unclear',
          'Stop feeding for a month to remove all disease risk',
          'Replace all substrate before taking any readings',
        ],
        correctIndex: 0,
        explanation:
            'A diagnosis starts with water, behaviour, affected fish, and recent history. That prevents treating the wrong problem.',
      );
    }

    if (conceptId.startsWith('fh_prevention') ||
        conceptId.startsWith('fh_hospital_tank') ||
        conceptId.startsWith('ff_quarantine')) {
      return _mc(
        card: card,
        questionText:
            'A new fish looks quiet on day two after purchase, with no single clear symptom yet. What is the safest prevention-minded response?',
        options: [
          'Keep it isolated if possible, test water, observe appetite and breathing, and avoid rushing medication',
          'Add it to the main tank so other fish can make it comfortable',
          'Medicate every tank immediately before symptoms exist',
          'Skip water tests because new fish always act quiet',
        ],
        correctIndex: 0,
        explanation:
            'Observation, quarantine, and water checks catch problems early without exposing the main tank or overusing treatments.',
      );
    }

    return _mc(
      card: card,
      questionText:
          'A fish shows a new symptom and you are not sure whether it is disease, stress, injury, or water quality. What is the best first step?',
      options: [
        'Check water, note recent changes, observe all fish, and isolate the affected fish if risk is high',
        'Treat with the strongest medication immediately',
        'Change every piece of equipment before testing',
        'Wait a week without observing because most symptoms disappear',
      ],
      correctIndex: 0,
      explanation:
          'Good diagnosis is evidence-led. Water, recent history, affected fish, and symptom pattern point to safer next actions.',
    );
  }

  static MultipleChoiceQuestion? _compatibilityQuestion(ReviewCard card) {
    final conceptId = card.conceptId;

    if (conceptId.startsWith('sc_betta')) {
      return _mc(
        card: card,
        questionText:
            'A user wants to add a betta to a busy community tank with fast fin-nipping fish. What is the safest compatibility advice?',
        options: [
          'Choose calm tank mates only if the tank size, layout, and individual temperament make it low risk',
          'Add two male bettas so they can keep each other company',
          'Pick the most active fin nippers because they will exercise the betta',
          'Ignore temperament because bettas always live peacefully in communities',
        ],
        correctIndex: 0,
        explanation:
            'Betta compatibility depends on temperament, tank layout, fin-nipping risk, and the individual fish. Calm tank mates are safer than busy or aggressive fish.',
      );
    }

    if (conceptId.startsWith('sc_goldfish')) {
      return _mc(
        card: card,
        questionText:
            'A keeper wants to add goldfish to a warm tropical community tank. What is the best response?',
        options: [
          'Plan a separate suitable setup because goldfish adult size, waste, and temperature needs do not fit most tropical communities',
          'Add them if they are small because they will stay the size of the tank',
          'Raise the tropical tank temperature so goldfish digest food faster',
          'Add extra tropical fish to dilute the goldfish waste',
        ],
        correctIndex: 0,
        explanation:
            'Goldfish are high-waste fish with different temperature and space needs from many tropical community fish. Small juveniles still grow.',
      );
    }

    if (conceptId.startsWith('sc_tetras') ||
        conceptId.startsWith('sc_rasboras') ||
        conceptId.startsWith('sc_corydoras') ||
        conceptId.startsWith('sc_loaches')) {
      return _mc(
        card: card,
        questionText:
            'A schooling species is being considered as a single show fish in a community tank. What should you check before buying?',
        options: [
          'Group size, adult size, temperament, water preferences, and whether the tank has enough open space',
          'Only the colour, because schooling fish do not have social needs',
          'Whether it can survive alone for the first year',
          'Whether it will clean the tank instead of needing care',
        ],
        correctIndex: 0,
        explanation:
            'Schooling and social species need suitable group size as well as compatible size, behaviour, water, and swimming space.',
      );
    }

    if (conceptId.startsWith('sc_cichlids') ||
        conceptId.startsWith('sc_angelfish') ||
        conceptId.startsWith('sc_gouramis')) {
      return _mc(
        card: card,
        questionText:
            'A semi-territorial fish is being added to a peaceful community tank. What makes the decision safer?',
        options: [
          'Check adult size, territory needs, tank layout, sex/temperament risk, and backup rehoming options',
          'Add it at night and assume darkness prevents aggression forever',
          'Crowd the tank so no fish can claim territory',
          'Choose the smallest juvenile and ignore adult behaviour',
        ],
        correctIndex: 0,
        explanation:
            'Territorial behaviour often increases with maturity. Adult size, layout, stocking density, and backup plans matter.',
      );
    }

    return _mc(
      card: card,
      questionText:
          'A new fish looks attractive for a community tank, but you have not checked compatibility yet. What is the best checklist?',
      options: [
        'Compare adult size, group size, temperament, temperature, water needs, diet, and tank space',
        'Buy it first and identify the species after it settles',
        'Only check whether the fish is currently small',
        'Assume all freshwater fish share the same needs',
      ],
      correctIndex: 0,
      explanation:
          'Compatibility is a whole-life decision. Adult size, group size, temperament, water, diet, and space prevent avoidable stress.',
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
