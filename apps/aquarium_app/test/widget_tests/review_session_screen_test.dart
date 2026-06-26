// Widget tests for ReviewSessionScreen.
//
// Run: flutter test test/widget_tests/review_session_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/spaced_repetition_practice/review_session_screen.dart';
import 'package:danio/models/resolved_question.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Fake SpacedRepetitionNotifier that does NOT call _scheduleNotifications.
/// Mirrors the _FakeSrNotifier pattern from
/// spaced_repetition_practice_screen_test.dart to avoid
/// LateInitializationError from NotificationService in tests.
class _FakeSrNotifier extends StateNotifier<SpacedRepetitionState>
    implements SpacedRepetitionNotifier {
  _FakeSrNotifier(
    ReviewSession session, {
    List<ResolvedQuestion> resolvedQuestions = const [],
  }) : super(
         SpacedRepetitionState(
           cards: session.cards,
           currentSession: session,
           resolvedQuestions: resolvedQuestions,
           stats: ReviewStats(
             totalCards: session.cards.length,
             dueCards: session.cards.length,
             weakCards: session.cards.length,
             masteredCards: 0,
             averageStrength: 0.0,
             cardsByMastery: const {},
             reviewsToday: 0,
             currentStreak: 0,
           ),
         ),
       );

  @override
  Future<ReviewSessionResult> recordSessionResult({
    required String cardId,
    required bool correct,
    required Duration timeSpent,
  }) async {
    final session = state.currentSession;
    if (session == null) {
      throw StateError('No active session');
    }

    final result = ReviewSessionResult(
      cardId: cardId,
      correct: correct,
      timestamp: DateTime.now(),
      xpEarned: correct ? 12 : 4,
      timeSpent: timeSpent,
    );
    final results = [...session.results, result];
    final updatedSession = ReviewSession(
      id: session.id,
      startTime: session.startTime,
      endTime: results.length == session.cards.length ? DateTime.now() : null,
      cards: session.cards,
      results: results,
      mode: session.mode,
    );

    state = state.copyWith(currentSession: updatedSession, clearError: true);
    return result;
  }

  @override
  Future<void> completeSession() async {
    state = state.copyWith(clearSession: true);
  }

  @override
  void abandonSession() {
    state = state.copyWith(clearSession: true, clearResolvedQuestions: true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _now = DateTime.now();

ReviewCard _makeCard({
  String id = 'card-1',
  String? conceptId,
  String concept = 'Nitrogen Cycle',
  bool includeQuestionText = true,
}) {
  return ReviewCard(
    id: id,
    conceptId: conceptId ?? 'concept-$id',
    conceptType: ConceptType.lesson,
    strength: 0.5,
    lastReviewed: _now.subtract(const Duration(days: 1)),
    nextReview: _now,
    reviewCount: 2,
    correctCount: 1,
    incorrectCount: 1,
    questionText: includeQuestionText ? concept : null,
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

MultipleChoiceQuestion _makeMultipleChoiceQuestion(ReviewCard card) {
  return MultipleChoiceQuestion(
    card: card,
    questionText:
        'Which water reading should stay at zero before adding sensitive fish?',
    options: const [
      'Ammonia',
      'Nitrate',
      'General hardness',
      'Carbonate hardness',
    ],
    correctIndex: 0,
    explanation: 'Ammonia should stay at zero in a cycled aquarium.',
  );
}

final _prefsOverride = sharedPreferencesProvider.overrideWith((ref) async {
  return SharedPreferences.getInstance();
});

Widget _wrap(
  ReviewSession session, {
  List<ResolvedQuestion> resolvedQuestions = const [],
  double textScale = 1,
}) {
  return ProviderScope(
    overrides: [
      _prefsOverride,
      spacedRepetitionProvider.overrideWith(
        (ref) => _FakeSrNotifier(session, resolvedQuestions: resolvedQuestions),
      ),
    ],
    child: MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
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

    testWidgets('shows recall guidance when card has no question text', (
      tester,
    ) async {
      final session = ReviewSession(
        id: 'session-1',
        startTime: _now,
        cards: [
          _makeCard(
            id: 'legacy-card',
            conceptId: 'tm_filter_section_0',
            includeQuestionText: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(session));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Filter Maintenance - Key Point 1'), findsOneWidget);
      expect(
        find.textContaining('Recall the main care point'),
        findsOneWidget,
      );
      expect(find.textContaining('choose Forgot'), findsOneWidget);
    });

    testWidgets('shows percent complete in progress row', (tester) async {
      await tester.pumpWidget(_wrap(_makeSession(cardCount: 5)));
      await tester.pump(const Duration(seconds: 1));
      // First card of 5 = 20% complete
      expect(find.text('20% complete'), findsOneWidget);
    });

    testWidgets('records fallback answer and advances using returned result', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_makeSession(cardCount: 2)));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Remembered'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Card 2 of 2'), findsOneWidget);
      expect(find.text('1 correct'), findsOneWidget);
      expect(find.textContaining('Couldn\'t record'), findsNothing);
    });

    testWidgets(
      'resolved multiple-choice question has horizontal padding at text scale 1.3',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 560));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final card = _makeCard(id: 'card-0', concept: 'Ammonia safety');
        final session = ReviewSession(
          id: 'session-1',
          startTime: _now,
          cards: [card],
        );
        final question = _makeMultipleChoiceQuestion(card);

        await tester.pumpWidget(
          _wrap(session, resolvedQuestions: [question], textScale: 1.3),
        );
        await tester.pump(const Duration(seconds: 1));

        expect(tester.takeException(), isNull);
        final questionFinder = find.text(question.questionText);
        expect(questionFinder, findsOneWidget);
        expect(tester.getTopLeft(questionFinder).dx, greaterThanOrEqualTo(16));
      },
    );

    testWidgets('exit dialog abandons active session before popping', (
      tester,
    ) async {
      final session = _makeSession(cardCount: 1);
      late _FakeSrNotifier notifier;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _prefsOverride,
            spacedRepetitionProvider.overrideWith((ref) {
              notifier = _FakeSrNotifier(session);
              return notifier;
            }),
          ],
          child: MaterialApp(home: ReviewSessionScreen(session: session)),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byTooltip('Exit Session'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(notifier.state.currentSession, isNull);
    });
  });
}
