// Widget tests for McCardWidget.
//
// Run: flutter test test/widget_tests/mc_card_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/resolved_question.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/screens/spaced_repetition_practice/widgets/mc_card_widget.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now();

ReviewCard _makeReviewCard() {
  return ReviewCard(
    id: 'card-1',
    conceptId: 'concept-1',
    conceptType: ConceptType.lesson,
    strength: 0.5,
    lastReviewed: _now.subtract(const Duration(days: 1)),
    nextReview: _now,
    questionText: 'What is the nitrogen cycle?',
  );
}

MultipleChoiceQuestion _makeQuestion({
  int correctIndex = 2,
  String? explanation,
}) {
  return MultipleChoiceQuestion(
    card: _makeReviewCard(),
    questionText: 'What is the ideal pH for most tropical fish?',
    options: const [
      '5.0 - 5.5',
      '6.0 - 6.5',
      '6.5 - 7.5',
      '8.0 - 8.5',
    ],
    correctIndex: correctIndex,
    explanation: explanation,
  );
}

Widget _wrap({
  required MultipleChoiceQuestion question,
  required void Function(bool) onAnswered,
  required VoidCallback onNext,
  bool isLastCard = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: McCardWidget(
            question: question,
            onAnswered: onAnswered,
            onNext: onNext,
            isLastCard: isLastCard,
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('McCardWidget -- rendering', () {
    testWidgets('renders question text and 4 option buttons', (tester) async {
      await tester.pumpWidget(_wrap(
        question: _makeQuestion(),
        onAnswered: (_) {},
        onNext: () {},
      ));

      // Question text
      expect(
        find.text('What is the ideal pH for most tropical fish?'),
        findsOneWidget,
      );

      // All 4 options visible
      expect(find.text('5.0 - 5.5'), findsOneWidget);
      expect(find.text('6.0 - 6.5'), findsOneWidget);
      expect(find.text('6.5 - 7.5'), findsOneWidget);
      expect(find.text('8.0 - 8.5'), findsOneWidget);

      // Letter badges
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
    });

    testWidgets('does not show Next Card button before answering',
        (tester) async {
      await tester.pumpWidget(_wrap(
        question: _makeQuestion(),
        onAnswered: (_) {},
        onNext: () {},
      ));

      expect(find.text('Next Card'), findsNothing);
      expect(find.text('Complete Session'), findsNothing);
    });

    testWidgets('does not show explanation before answering', (tester) async {
      await tester.pumpWidget(_wrap(
        question: _makeQuestion(explanation: 'Most tropical fish thrive...'),
        onAnswered: (_) {},
        onNext: () {},
      ));

      expect(find.text('Most tropical fish thrive...'), findsNothing);
    });
  });

  group('McCardWidget -- correct answer', () {
    testWidgets('tapping correct option shows green highlight and check icon',
        (tester) async {
      final question = _makeQuestion(correctIndex: 2);

      await tester.pumpWidget(_wrap(
        question: question,
        onAnswered: (_) {},
        onNext: () {},
      ));

      // Tap the correct option (index 2 = "6.5 - 7.5")
      await tester.tap(find.text('6.5 - 7.5'));
      await tester.pumpAndSettle();

      // Check icon appears on correct answer
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      // No error icon
      expect(find.byIcon(Icons.cancel), findsNothing);
    });

    testWidgets('onAnswered fires with true for correct answer',
        (tester) async {
      bool? answeredCorrectly;
      final question = _makeQuestion(correctIndex: 2);

      await tester.pumpWidget(_wrap(
        question: question,
        onAnswered: (correct) => answeredCorrectly = correct,
        onNext: () {},
      ));

      await tester.tap(find.text('6.5 - 7.5'));
      await tester.pumpAndSettle();

      expect(answeredCorrectly, isTrue);
    });
  });

  group('McCardWidget -- wrong answer', () {
    testWidgets(
        'tapping wrong option shows red on selection and green on correct',
        (tester) async {
      final question = _makeQuestion(correctIndex: 2);

      await tester.pumpWidget(_wrap(
        question: question,
        onAnswered: (_) {},
        onNext: () {},
      ));

      // Tap wrong option (index 0 = "5.0 - 5.5")
      await tester.tap(find.text('5.0 - 5.5'));
      await tester.pumpAndSettle();

      // Both icons appear: check on correct, cancel on wrong
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('onAnswered fires with false for wrong answer',
        (tester) async {
      bool? answeredCorrectly;
      final question = _makeQuestion(correctIndex: 2);

      await tester.pumpWidget(_wrap(
        question: question,
        onAnswered: (correct) => answeredCorrectly = correct,
        onNext: () {},
      ));

      await tester.tap(find.text('5.0 - 5.5'));
      await tester.pumpAndSettle();

      expect(answeredCorrectly, isFalse);
    });
  });

  group('McCardWidget -- post-answer behaviour', () {
    testWidgets('Next Card button appears after answering', (tester) async {
      await tester.pumpWidget(_wrap(
        question: _makeQuestion(),
        onAnswered: (_) {},
        onNext: () {},
      ));

      await tester.tap(find.text('6.5 - 7.5'));
      await tester.pumpAndSettle();

      expect(find.text('Next Card'), findsOneWidget);
    });

    testWidgets('explanation appears after answering', (tester) async {
      await tester.pumpWidget(_wrap(
        question: _makeQuestion(explanation: 'Most tropical fish thrive...'),
        onAnswered: (_) {},
        onNext: () {},
      ));

      await tester.tap(find.text('6.5 - 7.5'));
      await tester.pumpAndSettle();

      expect(find.text('Most tropical fish thrive...'), findsOneWidget);
    });

    testWidgets('tapping Next Card calls onNext', (tester) async {
      bool nextCalled = false;

      await tester.pumpWidget(_wrap(
        question: _makeQuestion(),
        onAnswered: (_) {},
        onNext: () => nextCalled = true,
      ));

      await tester.tap(find.text('6.5 - 7.5'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next Card'));
      await tester.pumpAndSettle();

      expect(nextCalled, isTrue);
    });

    testWidgets('options are disabled after answering', (tester) async {
      int answerCount = 0;

      await tester.pumpWidget(_wrap(
        question: _makeQuestion(correctIndex: 2),
        onAnswered: (_) => answerCount++,
        onNext: () {},
      ));

      // First tap — should register
      await tester.tap(find.text('6.5 - 7.5'));
      await tester.pumpAndSettle();

      expect(answerCount, 1);

      // Second tap on a different option — should be a no-op
      await tester.tap(find.text('5.0 - 5.5'));
      await tester.pumpAndSettle();

      expect(answerCount, 1);
    });
  });

  group('McCardWidget -- isLastCard', () {
    testWidgets('when isLastCard is true, button says Complete Session',
        (tester) async {
      await tester.pumpWidget(_wrap(
        question: _makeQuestion(),
        onAnswered: (_) {},
        onNext: () {},
        isLastCard: true,
      ));

      await tester.tap(find.text('6.5 - 7.5'));
      await tester.pumpAndSettle();

      expect(find.text('Complete Session'), findsOneWidget);
      expect(find.text('Next Card'), findsNothing);
    });

    testWidgets('when isLastCard is false, button says Next Card',
        (tester) async {
      await tester.pumpWidget(_wrap(
        question: _makeQuestion(),
        onAnswered: (_) {},
        onNext: () {},
        isLastCard: false,
      ));

      await tester.tap(find.text('6.5 - 7.5'));
      await tester.pumpAndSettle();

      expect(find.text('Next Card'), findsOneWidget);
      expect(find.text('Complete Session'), findsNothing);
    });
  });
}
