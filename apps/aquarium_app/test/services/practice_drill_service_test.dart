// Tests for PracticeDrillService.
//
// Run: flutter test test/services/practice_drill_service_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/equipment.dart';
import 'package:danio/models/livestock.dart';
import 'package:danio/models/log_entry.dart';
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

LogEntry _waterTestLog(DateTime now, WaterTestResults results) {
  return LogEntry(
    id: 'log-water-${now.millisecondsSinceEpoch}',
    tankId: 'tank-1',
    type: LogType.waterTest,
    timestamp: now,
    waterTest: results,
    createdAt: now,
  );
}

Equipment _equipment(DateTime now, {required EquipmentType type}) {
  return Equipment(
    id: 'equipment-${type.name}',
    tankId: 'tank-1',
    type: type,
    name: type.name,
    createdAt: now,
    updatedAt: now,
  );
}

Livestock _livestock(
  DateTime now, {
  HealthStatus healthStatus = HealthStatus.healthy,
}) {
  return Livestock(
    id: 'livestock-${healthStatus.name}',
    tankId: 'tank-1',
    commonName: 'Neon tetra',
    count: 6,
    dateAdded: now.subtract(const Duration(days: 30)),
    healthStatus: healthStatus,
    createdAt: now,
    updatedAt: now,
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

    test('unsafe water context recommends emergency decisions first', () {
      final now = DateTime(2026, 6, 13, 12);
      final summaries = PracticeDrillService.buildSummaries(
        cards: [
          _card(id: 'water', conceptId: 'wp_ph_section_0'),
          _card(id: 'emergency', conceptId: 'tr_emergency_section_0'),
        ],
        context: PracticeDrillContext.fromTankData(
          logs: [
            _waterTestLog(now, WaterTestResults(ammonia: 0.25, nitrite: 0.1)),
          ],
          tasks: const [],
          livestock: const [],
          equipment: const [],
          now: now,
        ),
      );

      expect(summaries.first.drill.id, PracticeDrillId.emergencyDecision);
      final emergency = summaries.byId(PracticeDrillId.emergencyDecision);
      expect(emergency.contextHint, contains('Unsafe water'));
      expect(emergency.contextPriority, greaterThan(0));
    });

    test('missing water-test context recommends parameter reading', () {
      final now = DateTime(2026, 6, 13, 12);
      final summaries = PracticeDrillService.buildSummaries(
        cards: [_card(id: 'water', conceptId: 'wp_ph_section_0')],
        context: PracticeDrillContext.fromTankData(
          logs: const [],
          tasks: const [],
          livestock: const [],
          equipment: [_equipment(now, type: EquipmentType.filter)],
          now: now,
        ),
      );

      final parameter = summaries.byId(PracticeDrillId.parameterInterpretation);
      expect(parameter.contextHint, contains('No recent water test'));
      expect(summaries.first.drill.id, PracticeDrillId.parameterInterpretation);
    });

    test('health alerts recommend diagnosis practice', () {
      final now = DateTime(2026, 6, 13, 12);
      final summaries = PracticeDrillService.buildSummaries(
        cards: [_card(id: 'health', conceptId: 'fh_ich_section_0')],
        context: PracticeDrillContext.fromTankData(
          logs: [_waterTestLog(now, WaterTestResults(ammonia: 0, nitrite: 0))],
          tasks: const [],
          livestock: [_livestock(now, healthStatus: HealthStatus.quarantine)],
          equipment: [_equipment(now, type: EquipmentType.filter)],
          now: now,
        ),
      );

      final diagnosis = summaries.byId(PracticeDrillId.diagnosis);
      expect(diagnosis.contextHint, contains('health'));
      expect(summaries.first.drill.id, PracticeDrillId.diagnosis);
    });

    test('missing equipment context recommends setup planning', () {
      final now = DateTime(2026, 6, 13, 12);
      final summaries = PracticeDrillService.buildSummaries(
        cards: [_card(id: 'equipment', conceptId: 'eq_filters_section_0')],
        context: PracticeDrillContext.fromTankData(
          logs: [_waterTestLog(now, WaterTestResults(ammonia: 0, nitrite: 0))],
          tasks: const [],
          livestock: const [],
          equipment: const [],
          now: now,
        ),
      );

      final setup = summaries.byId(PracticeDrillId.setupPlanning);
      expect(setup.contextHint, contains('No equipment'));
      expect(summaries.first.drill.id, PracticeDrillId.setupPlanning);
    });
  });
}

extension on List<PracticeDrillSummary> {
  PracticeDrillSummary byId(PracticeDrillId id) {
    return firstWhere((summary) => summary.drill.id == id);
  }
}
