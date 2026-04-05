import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/resolved_question.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/screens/spaced_repetition_practice/widgets/matching_card_widget.dart';

// ─── Helpers ──────────────────────────────────────────────────────

ReviewCard _card() => ReviewCard(
      id: 'card-1',
      conceptId: 'concept-1',
      conceptType: ConceptType.fact,
      lastReviewed: DateTime(2025, 1, 1),
      nextReview: DateTime(2025, 1, 2),
    );

MatchingPairsQuestion _question({List<MatchPair>? pairs}) =>
    MatchingPairsQuestion(
      card: _card(),
      cards: [_card()],
      pairs: pairs ??
          const [
            MatchPair(left: 'Nitrogen Cycle', right: 'Converts ammonia to nitrate'),
            MatchPair(left: 'pH', right: 'Measure of acidity'),
            MatchPair(left: 'Hardness', right: 'Mineral content of water'),
          ],
    );

Widget _wrap({
  MatchingPairsQuestion? question,
  void Function(double)? onCompleted,
  VoidCallback? onNext,
  bool isLastCard = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: MatchingCardWidget(
          question: question ?? _question(),
          onCompleted: onCompleted ?? (_) {},
          onNext: onNext ?? () {},
          isLastCard: isLastCard,
        ),
      ),
    ),
  );
}

// ─── Tests ────────────────────────────────────────────────────────

void main() {
  group('MatchingCardWidget', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(_wrap());

      expect(find.text('Match the pairs'), findsOneWidget);
      expect(find.text('Tap a concept, then tap its match'), findsOneWidget);
    });

    testWidgets('renders left and right columns with correct number of items',
        (tester) async {
      final pairs = [
        const MatchPair(left: 'A', right: '1'),
        const MatchPair(left: 'B', right: '2'),
        const MatchPair(left: 'C', right: '3'),
      ];
      await tester.pumpWidget(_wrap(question: _question(pairs: pairs)));

      // Left items
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);

      // Right items
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tapping a left item highlights it', (tester) async {
      final pairs = [
        const MatchPair(left: 'Concept', right: 'Definition'),
      ];
      await tester.pumpWidget(_wrap(question: _question(pairs: pairs)));

      // Tap the left item
      await tester.tap(find.text('Concept'));
      await tester.pump();

      // The state should have selectedLeftIndex set
      final state = tester.state<MatchingCardWidgetState>(
        find.byType(MatchingCardWidget),
      );
      expect(state.selectedLeftIndex, isNotNull);
    });

    testWidgets('tapping matching right item locks the pair green',
        (tester) async {
      // Use a single pair so we can deterministically match
      final pairs = [
        const MatchPair(left: 'Term', right: 'Def'),
      ];
      await tester.pumpWidget(_wrap(question: _question(pairs: pairs)));

      // Tap left then right
      await tester.tap(find.text('Term'));
      await tester.pump();
      await tester.tap(find.text('Def'));
      await tester.pump();

      final state = tester.state<MatchingCardWidgetState>(
        find.byType(MatchingCardWidget),
      );
      expect(state.matchedLeftIndices.length, 1);
      expect(state.matchedRightIndices.length, 1);

      // Checkmark should appear
      expect(find.byIcon(Icons.check), findsNWidgets(2)); // one per matched column
    });

    testWidgets('tapping wrong right item flashes red briefly',
        (tester) async {
      final pairs = [
        const MatchPair(left: 'A', right: '1'),
        const MatchPair(left: 'B', right: '2'),
      ];
      await tester.pumpWidget(_wrap(question: _question(pairs: pairs)));

      final state = tester.state<MatchingCardWidgetState>(
        find.byType(MatchingCardWidget),
      );

      // Tap left item for pair 0
      final leftPair0Index = state.leftOrder.indexOf(0);
      // Tap the left text for pair index 0
      await tester.tap(find.text(pairs[state.leftOrder[leftPair0Index]].left));
      await tester.pump();

      // Tap wrong right item — find the right text for a different pair
      final rightPair1Index = state.rightOrder.indexOf(1);
      await tester.tap(find.text(pairs[state.rightOrder[rightPair1Index]].right));
      await tester.pump();

      // flashRedRightIndex should be set
      expect(state.flashRedRightIndex, isNotNull);
      expect(state.mistakes, 1);

      // After 300ms, flash should clear
      await tester.pump(const Duration(milliseconds: 300));
      expect(state.flashRedRightIndex, isNull);
    });

    testWidgets('completes when all pairs matched', (tester) async {
      final pairs = [
        const MatchPair(left: 'A', right: '1'),
      ];
      bool completed = false;
      await tester.pumpWidget(_wrap(
        question: _question(pairs: pairs),
        onCompleted: (_) => completed = true,
      ));

      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(completed, isTrue);

      final state = tester.state<MatchingCardWidgetState>(
        find.byType(MatchingCardWidget),
      );
      expect(state.isComplete, isTrue);
    });

    testWidgets('onCompleted fires with proportional score', (tester) async {
      final pairs = [
        const MatchPair(left: 'A', right: '1'),
      ];
      double? receivedScore;
      await tester.pumpWidget(_wrap(
        question: _question(pairs: pairs),
        onCompleted: (s) => receivedScore = s,
      ));

      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(receivedScore, 1.0); // no mistakes => perfect score
    });

    testWidgets('score accounts for mistakes', (tester) async {
      final pairs = [
        const MatchPair(left: 'A', right: '1'),
        const MatchPair(left: 'B', right: '2'),
        const MatchPair(left: 'C', right: '3'),
      ];
      double? receivedScore;
      await tester.pumpWidget(_wrap(
        question: _question(pairs: pairs),
        onCompleted: (s) => receivedScore = s,
      ));

      final state = tester.state<MatchingCardWidgetState>(
        find.byType(MatchingCardWidget),
      );

      // Match all correctly but make 1 mistake first.
      // Select left item for pair 0.
      final leftIdx0 = state.leftOrder.indexOf(0);
      await tester.tap(find.text(pairs[state.leftOrder[leftIdx0]].left));
      await tester.pump();

      // Tap the wrong right item — pair 1 right.
      final rightIdx1 = state.rightOrder.indexOf(1);
      await tester.tap(find.text(pairs[state.rightOrder[rightIdx1]].right));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // clear flash

      expect(state.mistakes, 1);

      // Now match all three pairs correctly.
      for (int pairIdx = 0; pairIdx < 3; pairIdx++) {
        final li = state.leftOrder.indexOf(pairIdx);
        if (state.matchedLeftIndices.contains(li)) continue;
        await tester.tap(find.text(pairs[state.leftOrder[li]].left));
        await tester.pump();
        final ri = state.rightOrder.indexOf(pairIdx);
        await tester.tap(find.text(pairs[state.rightOrder[ri]].right));
        await tester.pump();
      }

      expect(state.isComplete, isTrue);
      // 3 pairs, 1 mistake => (3-1)/3 ≈ 0.6667
      expect(receivedScore, closeTo(2 / 3, 0.01));
    });

    testWidgets('items are shuffled (left and right order differ from input)',
        (tester) async {
      // With enough pairs the chance of both orderings being identical to
      // input is negligible. Use 6 pairs to make a false positive vanishingly
      // unlikely (1/720 * 1/720 ≈ 2e-6).
      final pairs = List.generate(
        6,
        (i) => MatchPair(left: 'L$i', right: 'R$i'),
      );
      await tester.pumpWidget(_wrap(question: _question(pairs: pairs)));

      final state = tester.state<MatchingCardWidgetState>(
        find.byType(MatchingCardWidget),
      );

      final identity = List.generate(6, (i) => i);
      final leftIsIdentity = _listEquals(state.leftOrder, identity);
      final rightIsIdentity = _listEquals(state.rightOrder, identity);

      // At least one of the two orderings should differ from the identity.
      expect(leftIsIdentity && rightIsIdentity, isFalse);
    });

    testWidgets('shows "Next Card" button after completion when not last card',
        (tester) async {
      final pairs = [const MatchPair(left: 'A', right: '1')];
      await tester.pumpWidget(_wrap(
        question: _question(pairs: pairs),
        isLastCard: false,
      ));

      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(find.text('Next Card'), findsOneWidget);
    });

    testWidgets('shows "Complete Session" button when last card',
        (tester) async {
      final pairs = [const MatchPair(left: 'X', right: 'Y')];
      await tester.pumpWidget(_wrap(
        question: _question(pairs: pairs),
        isLastCard: true,
      ));

      await tester.tap(find.text('X'));
      await tester.pump();
      await tester.tap(find.text('Y'));
      await tester.pump();

      expect(find.text('Complete Session'), findsOneWidget);
    });

    testWidgets('onNext fires when button tapped', (tester) async {
      final pairs = [const MatchPair(left: 'A', right: '1')];
      bool nextCalled = false;
      await tester.pumpWidget(_wrap(
        question: _question(pairs: pairs),
        onNext: () => nextCalled = true,
      ));

      // Complete the question first
      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();

      await tester.tap(find.text('Next Card'));
      await tester.pump();

      expect(nextCalled, isTrue);
    });

    testWidgets('tapping already-matched left item does nothing',
        (tester) async {
      final pairs = [
        const MatchPair(left: 'A', right: '1'),
        const MatchPair(left: 'B', right: '2'),
      ];
      await tester.pumpWidget(_wrap(question: _question(pairs: pairs)));

      final state = tester.state<MatchingCardWidgetState>(
        find.byType(MatchingCardWidget),
      );

      // Match pair 0.
      final li0 = state.leftOrder.indexOf(0);
      final ri0 = state.rightOrder.indexOf(0);
      await tester.tap(find.text(pairs[state.leftOrder[li0]].left));
      await tester.pump();
      await tester.tap(find.text(pairs[state.rightOrder[ri0]].right));
      await tester.pump();

      // Tap the matched left item again.
      await tester.tap(find.text(pairs[state.leftOrder[li0]].left));
      await tester.pump();

      // selectedLeftIndex should NOT point to the matched item.
      expect(state.selectedLeftIndex, isNot(li0));
    });

    testWidgets('tapping right item with no left selected does nothing',
        (tester) async {
      final pairs = [const MatchPair(left: 'A', right: '1')];
      await tester.pumpWidget(_wrap(question: _question(pairs: pairs)));

      final state = tester.state<MatchingCardWidgetState>(
        find.byType(MatchingCardWidget),
      );

      // Tap right without selecting left first.
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(state.matchedLeftIndices, isEmpty);
      expect(state.matchedRightIndices, isEmpty);
      expect(state.mistakes, 0);
    });
  });
}

bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
