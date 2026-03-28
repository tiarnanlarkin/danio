// Widget tests for PracticeHubScreen.
//
// Run: flutter test test/widget_tests/practice_hub_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/practice_hub_screen.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/models/spaced_repetition.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// ignore: unused_element
final _emptyStats = ReviewStats(
  totalCards: 0,
  dueCards: 0,
  weakCards: 0,
  masteredCards: 0,
  averageStrength: 0.0,
  cardsByMastery: const {},
  reviewsToday: 0,
  currentStreak: 0,
);

// ignore: unused_element
final _emptySrState = SpacedRepetitionState(
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

Widget _wrap() {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
      spacedRepetitionProvider.overrideWith(
        (ref) => _FakeSrNotifier(),
      ),
    ],
    child: const MaterialApp(home: PracticeHubScreen()),
  );
}

class _FakeSrNotifier extends StateNotifier<SpacedRepetitionState>
    implements SpacedRepetitionNotifier {
  _FakeSrNotifier()
      : super(SpacedRepetitionState(
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
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

  group('PracticeHubScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(PracticeHubScreen), findsOneWidget);
    });

    testWidgets('shows Practice app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('🧪 Practice'), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
