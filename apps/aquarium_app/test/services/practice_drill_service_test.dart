// Tests for PracticeDrillService.
//
// Run: flutter test test/services/practice_drill_service_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/practice_drill.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/services/practice_drill_service.dart';

ReviewCard _card({
  required String id,
  required String conceptId,
  double strength = 0.2,
  bool due = true,
}) {
  final now = DateTime.now();
  return ReviewCard(
    id: id,
    conceptId: conceptId,
    conceptType: ConceptType.fact,
    strength: strength,
    lastReviewed: now.subtract(const Duration(days: 2)),
    nextReview: due
        ? now.subtract(const Duration(minutes: 1))
        : now.add(const Duration(days: 2)),
  );
}

void main() {
  group('PracticeDrillService', () {
    test('catalog includes the five core skill drill tracks', () {
      final ids = PracticeDrillService.catalog.map((drill) => drill.id);

      expect(ids, contains(PracticeDrillId.parameterInterpretation));
      expect(ids, contains(PracticeDrillId.diagnosis));
      expect(ids, contains(PracticeDrillId.compatibility));
      expect(ids, contains(PracticeDrillId.setupPlanning));
      expect(ids, contains(PracticeDrillId.emergencyDecision));
      expect(PracticeDrillService.catalog, hasLength(5));
    });

    test('summaries unlock drills from related lesson review cards', () {
      final summaries = PracticeDrillService.buildSummaries(
        cards: [
          _card(id: 'water', conceptId: 'wp_ph_section_0'),
          _card(id: 'health', conceptId: 'fh_ich_quiz_q0'),
          _card(id: 'species', conceptId: 'sc_betta_section_1', due: false),
        ],
      );

      final parameter = summaries.byId(PracticeDrillId.parameterInterpretation);
      final diagnosis = summaries.byId(PracticeDrillId.diagnosis);
      final compatibility = summaries.byId(PracticeDrillId.compatibility);

      expect(parameter.isUnlocked, isTrue);
      expect(parameter.availableCardCount, 1);
      expect(parameter.dueCardCount, 1);
      expect(diagnosis.isUnlocked, isTrue);
      expect(compatibility.isUnlocked, isTrue);
      expect(compatibility.statusLabel, '1 card ready');
    });

    test(
      'filtered drill cards stay within the drill path set and due cards win',
      () {
        final cards = [
          _card(id: 'species', conceptId: 'sc_betta_section_1'),
          _card(id: 'water-due', conceptId: 'wp_ph_section_0'),
          _card(
            id: 'water-strong',
            conceptId: 'wp_temp_section_0',
            strength: 0.9,
            due: false,
          ),
          _card(id: 'equipment', conceptId: 'eq_filters_section_0'),
        ];

        final selected = PracticeDrillService.cardsForDrill(
          cards: cards,
          drillId: PracticeDrillId.parameterInterpretation,
        );

        expect(selected.map((card) => card.id), ['water-due', 'water-strong']);
      },
    );

    test('locked summaries name the first path that can unlock the drill', () {
      final summary = PracticeDrillService.buildSummaries(
        cards: const [],
      ).byId(PracticeDrillId.setupPlanning);

      expect(summary.isUnlocked, isFalse);
      expect(summary.statusLabel, 'Unlock through Equipment Guide');
    });
  });
}

extension on List<PracticeDrillSummary> {
  PracticeDrillSummary byId(PracticeDrillId id) {
    return firstWhere((summary) => summary.drill.id == id);
  }
}
