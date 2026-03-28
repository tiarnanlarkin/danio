// Widget tests for ReviewSessionScreen.
//
// Run: flutter test test/widget_tests/review_session_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/spaced_repetition_practice/review_session_screen.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/providers/user_profile_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

ReviewCard _makeCard({String id = 'card-1', String concept = 'Nitrogen Cycle'}) {
  return ReviewCard(
    id: id,
    conceptId: 'concept-$id',
    conceptType: ConceptType.lesson,
    strength: 0.5,
    lastReviewed: _now.subtract(const Duration(days: 1)),
    nextReview: _now,
    reviewCount: 2,
    correctCount: 1,
    incorrectCount: 1,
    questionText: concept,
  );
}

ReviewSession _makeSession({int cardCount = 3}) {
  return ReviewSession(
    id: 'session-1',
    startTime: _now,
    cards: List.generate(
      cardCount,
      (i) => _makeCard(id: 'card-$i', concept: 'Concept $i'),
    ),
  );
}

final _prefsOverride = sharedPreferencesProvider.overrideWith((ref) async {
  return SharedPreferences.getInstance();
});

Widget _wrap(ReviewSession session) {
  return ProviderScope(
    overrides: [_prefsOverride],
    child: MaterialApp(
      home: ReviewSessionScreen(session: session),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ReviewSessionScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap(_makeSession()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ReviewSessionScreen), findsOneWidget);
    });

    testWidgets('shows Practice Session app bar', (tester) async {
      await tester.pumpWidget(_wrap(_makeSession()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Practice Session'), findsOneWidget);
    });

    testWidgets('shows progress indicator', (tester) async {
      await tester.pumpWidget(_wrap(_makeSession()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LinearProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('shows card counter (Card X of Y)', (tester) async {
      await tester.pumpWidget(_wrap(_makeSession(cardCount: 3)));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Card 1 of 3'), findsOneWidget);
    });

    testWidgets('shows answer buttons (Forgot and Remembered)', (tester) async {
      await tester.pumpWidget(_wrap(_makeSession()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Forgot'), findsOneWidget);
      expect(find.text('Remembered'), findsOneWidget);
    });
  });

  group('ReviewSessionScreen — card content', () {
    testWidgets('shows question text from card', (tester) async {
      final session = ReviewSession(
        id: 'session-1',
        startTime: _now,
        cards: [_makeCard(concept: 'Ammonia is toxic to fish')],
      );
      await tester.pumpWidget(_wrap(session));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Ammonia is toxic to fish'), findsOneWidget);
    });

    testWidgets('shows percent complete in progress row', (tester) async {
      await tester.pumpWidget(_wrap(_makeSession(cardCount: 5)));
      await tester.pump(const Duration(seconds: 1));
      // First card of 5 = 20% complete
      expect(find.text('20% complete'), findsOneWidget);
    });
  });
}
