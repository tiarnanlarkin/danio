// Widget tests for SpacedRepetitionPracticeScreen.
//
// Run: flutter test test/widget_tests/spaced_repetition_practice_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/spaced_repetition_practice/spaced_repetition_practice_screen.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/models/spaced_repetition.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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
  });
}
