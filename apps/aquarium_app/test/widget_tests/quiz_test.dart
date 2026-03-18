// Widget tests for Quiz logic inside LessonScreen.
//
// Rather than testing the full LessonScreen (which depends on many providers),
// we test quiz behaviour through the key state transitions:
//   - question renders with all options
//   - selecting an answer locks it
//   - correct/incorrect feedback is displayed
//   - quiz completion shows results
//
// Run: flutter test test/widget_tests/quiz_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/learning.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _testQuestions = [
  QuizQuestion(
    id: 'q1',
    question: 'What is the nitrogen cycle?',
    options: [
      'A process that converts ammonia to nitrite to nitrate',
      'A way to filter water',
      'A type of fish food',
      'A water change schedule',
    ],
    correctIndex: 0,
    explanation: 'The nitrogen cycle converts toxic ammonia to less harmful nitrate.',
  ),
  QuizQuestion(
    id: 'q2',
    question: 'What is a safe temperature range for tropical fish?',
    options: ['15-18°C', '24-28°C', '30-35°C', '35-40°C'],
    correctIndex: 1,
  ),
];

final _testQuiz = Quiz(
  id: 'quiz1',
  lessonId: 'lesson1',
  questions: _testQuestions,
  passingScore: 70,
  bonusXp: 25,
);

final _testLesson = Lesson(
  id: 'lesson1',
  title: 'The Nitrogen Cycle',
  pathId: 'path1',
  description: 'Learn about the nitrogen cycle',
  orderIndex: 1,
  xpReward: 50,
  sections: const [],
  quiz: _testQuiz,
);

// ---------------------------------------------------------------------------
// Helper: build a minimal quiz widget that mirrors LessonScreen quiz logic
// ---------------------------------------------------------------------------

/// Stripped-down quiz widget for isolated testing of quiz state machine.
class _TestQuizWidget extends StatefulWidget {
  final Quiz quiz;

  const _TestQuizWidget({required this.quiz});

  @override
  State<_TestQuizWidget> createState() => _TestQuizWidgetState();
}

class _TestQuizWidgetState extends State<_TestQuizWidget> {
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _quizComplete = false;

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == widget.quiz.questions[_currentQuestion].correctIndex) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      setState(() => _quizComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: _quizComplete
            ? _buildResults()
            : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = widget.quiz.questions[_currentQuestion];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Question ${_currentQuestion + 1} of ${widget.quiz.questions.length}'),
          const SizedBox(height: 16),
          Text(question.question, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          ...question.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            final isCorrect = idx == question.correctIndex;
            final isSelected = idx == _selectedAnswer;

            Color? bgColor;
            if (_answered && isCorrect) bgColor = Colors.green.shade100;
            if (_answered && isSelected && !isCorrect) bgColor = Colors.red.shade100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: bgColor),
                onPressed: _answered ? null : () => _selectAnswer(idx),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(option),
                ),
              ),
            );
          }),
          const Spacer(),
          if (_answered)
            FilledButton(
              onPressed: _nextQuestion,
              child: Text(
                _currentQuestion < widget.quiz.questions.length - 1
                    ? 'Next'
                    : 'See Results',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final passed = (_correctAnswers / widget.quiz.questions.length * 100) >=
        widget.quiz.passingScore;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            passed ? '🎉 Passed!' : '❌ Not quite',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('$_correctAnswers / ${widget.quiz.questions.length} correct'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Quiz — rendering', () {
    testWidgets('renders question text and all options', (tester) async {
      await tester.pumpWidget(_TestQuizWidget(quiz: _testQuiz));
      await tester.pump();

      expect(find.text('What is the nitrogen cycle?'), findsOneWidget);
      expect(find.text('A process that converts ammonia to nitrite to nitrate'), findsOneWidget);
      expect(find.text('A way to filter water'), findsOneWidget);
      expect(find.text('A type of fish food'), findsOneWidget);
      expect(find.text('A water change schedule'), findsOneWidget);
    });

    testWidgets('shows question progress counter', (tester) async {
      await tester.pumpWidget(_TestQuizWidget(quiz: _testQuiz));
      await tester.pump();

      expect(find.text('Question 1 of 2'), findsOneWidget);
    });
  });

  group('Quiz — answer selection', () {
    testWidgets('can select an answer option', (tester) async {
      await tester.pumpWidget(_TestQuizWidget(quiz: _testQuiz));
      await tester.pump();

      await tester.tap(find.text('A type of fish food'));
      await tester.pump();

      // After selecting, buttons should be disabled
      final buttons = find.byType(ElevatedButton);
      for (int i = 0; i < buttons.evaluate().length; i++) {
        expect(
          tester.widget<ElevatedButton>(buttons.at(i)).onPressed,
          isNull,
          reason: 'Buttons should be disabled after answering',
        );
      }
    });

    testWidgets('correct answer shows green highlight', (tester) async {
      await tester.pumpWidget(_TestQuizWidget(quiz: _testQuiz));
      await tester.pump();

      // Select wrong answer
      await tester.tap(find.text('A way to filter water'));
      await tester.pump();

      // The correct answer button should have green background
      final correctButton = find.widgetWithText(
        ElevatedButton,
        'A process that converts ammonia to nitrite to nitrate',
      );
      expect(
        tester.widget<ElevatedButton>(correctButton).style?.backgroundColor?.resolve({}),
        Colors.green.shade100,
      );
    });

    testWidgets('wrong answer shows red highlight on selection', (tester) async {
      await tester.pumpWidget(_TestQuizWidget(quiz: _testQuiz));
      await tester.pump();

      // Select wrong answer
      await tester.tap(find.text('A type of fish food'));
      await tester.pump();

      // The selected wrong answer should have red background
      final wrongButton = find.widgetWithText(
        ElevatedButton,
        'A type of fish food',
      );
      expect(
        tester.widget<ElevatedButton>(wrongButton).style?.backgroundColor?.resolve({}),
        Colors.red.shade100,
      );
    });

    testWidgets('selecting correct answer directly shows green', (tester) async {
      await tester.pumpWidget(_TestQuizWidget(quiz: _testQuiz));
      await tester.pump();

      await tester.tap(
        find.text('A process that converts ammonia to nitrite to nitrate'),
      );
      await tester.pump();

      final correctButton = find.widgetWithText(
        ElevatedButton,
        'A process that converts ammonia to nitrite to nitrate',
      );
      expect(
        tester.widget<ElevatedButton>(correctButton).style?.backgroundColor?.resolve({}),
        Colors.green.shade100,
      );
    });
  });

  group('Quiz — navigation', () {
    testWidgets('Next button appears after answering', (tester) async {
      await tester.pumpWidget(_TestQuizWidget(quiz: _testQuiz));
      await tester.pump();

      expect(find.text('Next'), findsNothing);

      await tester.tap(find.text('A type of fish food'));
      await tester.pump();

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('advances to next question on Next tap', (tester) async {
      await tester.pumpWidget(_TestQuizWidget(quiz: _testQuiz));
      await tester.pump();

      await tester.tap(find.text('A type of fish food'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(find.text('Question 2 of 2'), findsOneWidget);
      expect(find.text('What is a safe temperature range for tropical fish?'), findsOneWidget);
    });
  });

  group('Quiz — completion', () {
    testWidgets('shows results after last question', (tester) async {
      await tester.pumpWidget(_TestQuizWidget(quiz: _testQuiz));
      await tester.pump();

      // Answer Q1 correctly
      await tester.tap(find.text('A process that converts ammonia to nitrite to nitrate'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pump();

      // Answer Q2 correctly
      await tester.tap(find.text('24-28°C'));
      await tester.pump();
      await tester.tap(find.text('See Results'));
      await tester.pump();

      expect(find.text('🎉 Passed!'), findsOneWidget);
      expect(find.text('2 / 2 correct'), findsOneWidget);
    });

    testWidgets('shows failure when score below passing threshold', (tester) async {
      await tester.pumpWidget(_TestQuizWidget(quiz: _testQuiz));
      await tester.pump();

      // Answer Q1 wrong
      await tester.tap(find.text('A way to filter water'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pump();

      // Answer Q2 wrong
      await tester.tap(find.text('30-35°C'));
      await tester.pump();
      await tester.tap(find.text('See Results'));
      await tester.pump();

      expect(find.text('❌ Not quite'), findsOneWidget);
      expect(find.text('0 / 2 correct'), findsOneWidget);
    });
  });

  group('Quiz model — data integrity', () {
    test('quiz has correct number of questions', () {
      expect(_testQuiz.questions.length, 2);
      expect(_testQuiz.maxScore, 2);
    });

    test('passing score is set correctly', () {
      expect(_testQuiz.passingScore, 70);
    });

    test('lesson references quiz correctly', () {
      expect(_testLesson.quiz, isNotNull);
      expect(_testLesson.quiz!.questions.length, 2);
    });
  });
}
