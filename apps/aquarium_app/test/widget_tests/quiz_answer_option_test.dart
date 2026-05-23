// Widget tests for QuizAnswerOption.
//
// Run: flutter test test/widget_tests/quiz_answer_option_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/widgets/quiz/quiz_answer_option.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void main() {
  testWidgets('long answer text is not truncated', (tester) async {
    const longAnswer =
        'Use a liquid ammonia test kit because clear water can still contain '
        'dangerous ammonia; compare the reading with nitrite and nitrate before '
        'deciding whether the cycle is stable enough for fish.';

    await tester.pumpWidget(
      _wrap(
        const QuizAnswerOption(
          optionIndex: 0,
          option: longAnswer,
          isSelected: false,
          isCorrect: false,
          answered: false,
        ),
      ),
    );

    final optionText = tester.widget<Text>(find.text(longAnswer));
    expect(optionText.maxLines, isNull);
    expect(optionText.overflow, isNot(TextOverflow.ellipsis));
  });
}
