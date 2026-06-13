// Widget tests for PracticeHubScreen.
//
// Run: flutter test test/widget_tests/practice_hub_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/practice_hub_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/models/log_entry.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/models/tank.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ReviewStats _stats({
  int totalCards = 0,
  int dueCards = 0,
  int weakCards = 0,
  int masteredCards = 0,
}) {
  return ReviewStats(
    totalCards: totalCards,
    dueCards: dueCards,
    weakCards: weakCards,
    masteredCards: masteredCards,
    averageStrength: 0.0,
    cardsByMastery: const {},
    reviewsToday: 0,
    currentStreak: 0,
  );
}

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

Widget _wrap({
  ReviewStats? stats,
  List<ReviewCard> cards = const [],
  List<Override> overrides = const [],
}) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
      spacedRepetitionProvider.overrideWith(
        (ref) => _FakeSrNotifier(stats ?? ReviewStats.fromCards(cards), cards),
      ),
      ...overrides,
    ],
    child: const MaterialApp(home: PracticeHubScreen()),
  );
}

class _FakeSrNotifier extends StateNotifier<SpacedRepetitionState>
    implements SpacedRepetitionNotifier {
  _FakeSrNotifier(ReviewStats stats, List<ReviewCard> cards)
    : super(SpacedRepetitionState(cards: cards, stats: stats));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));
}

Tank _tank(DateTime now) {
  return Tank(
    id: 'tank-1',
    name: 'Main tank',
    type: TankType.freshwater,
    volumeLitres: 90,
    startDate: now.subtract(const Duration(days: 120)),
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

LogEntry _waterTestLog(DateTime now, WaterTestResults results) {
  return LogEntry(
    id: 'water-log',
    tankId: 'tank-1',
    type: LogType.waterTest,
    timestamp: now,
    waterTest: results,
    createdAt: now,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PracticeHubScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(PracticeHubScreen), findsOneWidget);
    });

    testWidgets('shows Practice app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Title is now in the illustrated header (no AppBar), text reads 'Practice'
      expect(find.text('Practice'), findsWidgets);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });
    testWidgets('empty deck explains the Learn to Practice mastery loop', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.text('Build your review deck'), findsOneWidget);
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Practice'), findsWidgets);
      expect(find.text('Mastery'), findsOneWidget);
      expect(find.text('Review Sessions'), findsNothing);
      expect(find.text('Standard Review'), findsNothing);
    });

    testWidgets('empty deck keeps Learn-to-Practice copy', (tester) async {
      await tester.pumpWidget(_wrap(stats: _stats(totalCards: 0)));
      await _advance(tester);

      expect(find.text('Build your review deck'), findsOneWidget);
      expect(
        find.text('Finish one Learn lesson to create Practice cards.'),
        findsOneWidget,
      );
    });

    testWidgets('no due cards with no weak cards stays all caught up', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(stats: _stats(totalCards: 12, dueCards: 0, weakCards: 0)),
      );
      await _advance(tester);

      expect(find.text('All caught up'), findsOneWidget);
      expect(find.text('Learn Next'), findsOneWidget);
    });

    testWidgets('no due cards with weak cards points to weak spots', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(stats: _stats(totalCards: 12, dueCards: 0, weakCards: 3)),
      );
      await _advance(tester);

      expect(find.text('All caught up'), findsNothing);
      expect(find.text('Weak spots available'), findsOneWidget);
      expect(find.text('Practice Weak Spots'), findsOneWidget);
    });

    testWidgets('no due review modes do not draw action chevrons', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(stats: _stats(totalCards: 12, dueCards: 0, weakCards: 3)),
      );
      await _advance(tester);

      final standardTile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('Standard Review'),
          matching: find.byType(ListTile),
        ),
      );
      final quickTile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('Quick Review'),
          matching: find.byType(ListTile),
        ),
      );

      expect(standardTile.onTap, isNull);
      expect(standardTile.trailing, isNull);
      expect(quickTile.onTap, isNull);
      expect(quickTile.trailing, isNull);
    });

    testWidgets('shows unlocked skill drills from related review cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          cards: [
            _card(id: 'water', conceptId: 'wp_ph_section_0'),
            _card(id: 'health', conceptId: 'fh_ich_quiz_q0'),
          ],
        ),
      );
      await _advance(tester);

      await tester.scrollUntilVisible(
        find.text('Skill Drills'),
        320,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(find.text('Skill Drills'), findsOneWidget);
      expect(find.text('Parameter Reading'), findsOneWidget);
      expect(find.text('Diagnosis Practice'), findsOneWidget);
      expect(find.text('1 due now'), findsAtLeastNWidgets(1));
    });

    testWidgets('skill drills show tank-context recommendation hints', (
      tester,
    ) async {
      final now = DateTime(2026, 6, 13, 12);

      await tester.pumpWidget(
        _wrap(
          cards: [
            _card(id: 'water', conceptId: 'wp_ph_section_0'),
            _card(id: 'emergency', conceptId: 'tr_emergency_section_0'),
          ],
          overrides: [
            tanksProvider.overrideWith((ref) async => [_tank(now)]),
            logsProvider('tank-1').overrideWith(
              (ref) async => [
                _waterTestLog(
                  now,
                  WaterTestResults(ammonia: 0.25, nitrite: 0.1),
                ),
              ],
            ),
            tasksProvider('tank-1').overrideWith((ref) async => const []),
            livestockProvider('tank-1').overrideWith((ref) async => const []),
            equipmentProvider('tank-1').overrideWith((ref) async => const []),
          ],
        ),
      );
      await _advance(tester);

      await tester.scrollUntilVisible(
        find.text('Emergency Decisions'),
        320,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Unsafe water logged. Practise emergency actions first.'),
        findsOneWidget,
      );
    });
  });
}
