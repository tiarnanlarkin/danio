/// Golden tests for [McCardWidget].
///
/// Captures the card in two visual states:
/// - **Unanswered:** all four options neutral, no explanation, no Next button.
/// - **Answered (correct):** correct option highlighted green, incorrect
///   selection red, explanation revealed, Next button visible.
///
/// Run:
///   flutter test test/golden_tests/mc_card_golden_test.dart
///
/// Regenerate reference images after intentional UI changes:
///   flutter test --update-goldens test/golden_tests/mc_card_golden_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/resolved_question.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/screens/spaced_repetition_practice/widgets/mc_card_widget.dart';

import 'golden_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _now = DateTime(2025, 1, 1); // Fixed date for deterministic output.

ReviewCard _makeCard() {
  return ReviewCard(
    id: 'golden-card-1',
    conceptId: 'concept-1',
    conceptType: ConceptType.lesson,
    strength: 0.5,
    lastReviewed: _now.subtract(const Duration(days: 1)),
    nextReview: _now,
    questionText: 'What is the nitrogen cycle?',
  );
}

MultipleChoiceQuestion _makeQuestion() {
  return MultipleChoiceQuestion(
    card: _makeCard(),
    questionText: 'What is the ideal pH range for most tropical freshwater fish?',
    options: const [
      '5.0 - 5.5',
      '6.0 - 6.5',
      '6.5 - 7.5',
      '8.0 - 8.5',
    ],
    correctIndex: 2,
    explanation:
        'Most tropical freshwater fish thrive in a pH range of 6.5 to 7.5, '
        'which is close to neutral.',
  );
}

// ---------------------------------------------------------------------------
// Golden tests
// ---------------------------------------------------------------------------

void main() {
  group('McCardWidget golden tests', () {
    testWidgets('unanswered state', (tester) async {
      tester.view.physicalSize = kGoldenTestSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        goldenWrapper(
          McCardWidget(
            question: _makeQuestion(),
            onAnswered: (_) {},
            onNext: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(McCardWidget),
        matchesGoldenFile('goldens/mc_card_unanswered.png'),
      );
    });

    testWidgets('answered state (correct selection)', (tester) async {
      tester.view.physicalSize = kGoldenTestSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        goldenWrapper(
          McCardWidget(
            question: _makeQuestion(),
            onAnswered: (_) {},
            onNext: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the correct option (index 2 → "6.5 - 7.5").
      await tester.tap(find.text('6.5 - 7.5'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(McCardWidget),
        matchesGoldenFile('goldens/mc_card_answered.png'),
      );
    });
  });
}
