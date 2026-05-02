// Widget tests for SpacedRepetitionPracticeScreen.
//
// Run: flutter test test/widget_tests/spaced_repetition_practice_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/spaced_repetition_practice/spaced_repetition_practice_screen.dart';
import 'package:danio/screens/tab_navigator.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/models/spaced_repetition.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _FakeSrNotifier extends StateNotifier<SpacedRepetitionState>
    implements SpacedRepetitionNotifier {
  _FakeSrNotifier({SpacedRepetitionState? initialState})
    : super(initialState ?? _emptyState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SpacedRepetitionState _emptyState() {
  return SpacedRepetitionState(
    cards: const [],
    stats: ReviewStats(
      totalCards: 0,
      dueCards: 0,
      weakCards: 0,
      masteredCards: 0,
      averageStrength: 0.0,
      cardsByMastery: const {},
      reviewsToday: 0,
      currentStreak: 0,
    ),
  );
}

ReviewCard _card(String id, double strength) {
  final now = DateTime.now();
  return ReviewCard(
    id: id,
    conceptId: '${id}_concept',
    conceptType: ConceptType.lesson,
    strength: strength,
    lastReviewed: now.subtract(const Duration(days: 2)),
    nextReview: now.subtract(const Duration(minutes: 1)),
  );
}

SpacedRepetitionState _dueState() {
  final cards = [
    _card('new', 0.1),
    _card('learning', 0.35),
    _card('familiar', 0.55),
    _card('proficient', 0.75),
    _card('mastered', 0.95),
  ];
  return SpacedRepetitionState(
    cards: cards,
    stats: ReviewStats.fromCards(cards),
  );
}

List<Override> _overrides({SpacedRepetitionState? initialState, int? tab}) {
  return [
    sharedPreferencesProvider.overrideWith((ref) async {
      return SharedPreferences.getInstance();
    }),
    spacedRepetitionProvider.overrideWith(
      (ref) => _FakeSrNotifier(initialState: initialState),
    ),
    if (tab != null) currentTabProvider.overrideWith((ref) => tab),
  ];
}

Widget _wrap({SpacedRepetitionState? initialState}) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: _overrides(initialState: initialState),
    child: const MaterialApp(home: SpacedRepetitionPracticeScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SpacedRepetitionPracticeScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(SpacedRepetitionPracticeScreen), findsOneWidget);
    });

    testWidgets('shows Practice app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Practice'), findsOneWidget);
    });

    testWidgets('shows empty state when no cards due', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('All caught up!'), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows mastery breakdown when due cards exist', (tester) async {
      await tester.pumpWidget(_wrap(initialState: _dueState()));
      await _advance(tester);

      await tester.scrollUntilVisible(find.text('Mastery Progress'), 300);
      await tester.pumpAndSettle();

      expect(find.text('Mastery Progress'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('Familiar'), findsOneWidget);
      expect(find.text('Proficient'), findsOneWidget);
      expect(find.text('Mastered'), findsOneWidget);
    });

    testWidgets('Try a new lesson switches from Practice to Learn tab', (
      tester,
    ) async {
      final container = ProviderContainer(overrides: _overrides(tab: 1));
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SpacedRepetitionPracticeScreen()),
        ),
      );
      await _advance(tester);

      expect(container.read(currentTabProvider), 1);
      await tester.tap(find.text('Try a new lesson'));
      await tester.pumpAndSettle();

      expect(container.read(currentTabProvider), 0);
    });
  });
}
