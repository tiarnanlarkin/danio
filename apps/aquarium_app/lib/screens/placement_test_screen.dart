/// Placement test screen for assessing user knowledge
/// Duolingo-style onboarding experience
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/placement_test.dart';
import '../models/learning.dart';
import '../data/placement_test_content.dart';
import '../data/lesson_content.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';
import 'placement_result_screen.dart';

class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() =>
      _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen> {
  final PlacementTest _test = PlacementTestContent.defaultTest;
  final Map<String, int> _userAnswers = {}; // questionId -> selectedIndex
  final Map<String, bool> _answeredQuestions =
      {}; // Track which questions have been answered

  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;

  PlacementQuestion get _currentQuestion =>
      _test.questions[_currentQuestionIndex];
  bool get _isLastQuestion =>
      _currentQuestionIndex == _test.questions.length - 1;
  double get _progress => (_currentQuestionIndex + 1) / _test.questions.length;

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    setState(() {
      _userAnswers[_currentQuestion.id] = _selectedAnswer!;
      _answeredQuestions[_currentQuestion.id] = true;
      _showExplanation = true;
    });
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _completeTest();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer =
            _userAnswers[_test.questions[_currentQuestionIndex].id];
        _showExplanation = false;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswer =
            _userAnswers[_test.questions[_currentQuestionIndex].id];
        _showExplanation =
            _answeredQuestions[_test.questions[_currentQuestionIndex].id] ??
            false;
      });
    }
  }

  void _skipToResults() {
    // Fill remaining unanswered questions with incorrect answers
    for (final question in _test.questions) {
      if (!_userAnswers.containsKey(question.id)) {
        _userAnswers[question.id] = -1; // Invalid answer
      }
    }
    _completeTest();
  }

  void _completeTest() async {
    // Calculate result
    final result = PlacementAlgorithm.calculateResult(
      test: _test,
      userAnswers: _userAnswers,
      allPaths: LessonContent.allPaths,
    );

    // Save result to user profile
    final profileNotifier = ref.read(userProfileProvider.notifier);
    await profileNotifier.completePlacementTest(
      resultId: result.id,
      lessonsToSkip: result.lessonsToSkip,
      xpToAward: result.calculateSkipXp(LessonContent.allPaths),
    );

    if (!mounted) return;

    // Navigate to results screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PlacementResultScreen(result: result),
      ),
    );
  }

  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Placement Test?'),
        content: const Text(
          'You\'ve answered enough questions to get personalized recommendations. '
          'Do you want to skip to your results?\n\n'
          'You can also continue and answer all questions for a more accurate assessment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Going'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _skipToResults();
            },
            child: const Text('See Results'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAnswered = _answeredQuestions[_currentQuestion.id] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Assessment'),
        actions: [
          if (_currentQuestionIndex >= 10 && _userAnswers.length >= 10)
            TextButton(
              onPressed: _showSkipDialog,
              child: const Text('Skip to Results'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          _buildProgressBar(),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question number and path
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1} of ${_test.questions.length}',
                        style: theme.textTheme.titleSmall,
                      ),
                      Chip(
                        label: Text(_getPathName(_currentQuestion.pathId)),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Question text
                  AppCard(
                    padding: AppCardPadding.spacious,
                    child: Text(
                      _currentQuestion.question,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Answer options
                  ..._buildAnswerOptions(),

                  // Explanation (shown after answering)
                  if (_showExplanation &&
                      _currentQuestion.explanation != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildExplanation(),
                  ],
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(isAnswered),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          minHeight: 8,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_progress * 100).round()}% Complete',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_userAnswers.length}/${_test.questions.length} Answered',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAnswerOptions() {
    return List.generate(_currentQuestion.options.length, (index) {
      final isSelected = _selectedAnswer == index;
      final isCorrect = index == _currentQuestion.correctIndex;
      final showResult = _showExplanation;

      Color? backgroundColor;
      Color? borderColor;
      IconData? icon;

      if (showResult) {
        if (isCorrect) {
          backgroundColor = Colors.green[50];
          borderColor = Colors.green;
          icon = Icons.check_circle;
        } else if (isSelected && !isCorrect) {
          backgroundColor = Colors.red[50];
          borderColor = Colors.red;
          icon = Icons.cancel;
        }
      } else if (isSelected) {
        backgroundColor = AppOverlays.accent10;
        borderColor = AppColors.accent;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: showResult ? null : () => _selectAnswer(index),
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: borderColor ?? Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? (showResult && isCorrect
                              ? Colors.green
                              : AppColors.accent)
                        : Colors.grey[200],
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _currentQuestion.options[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(icon, color: borderColor),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExplanation() {
    final isCorrect = _selectedAnswer == _currentQuestion.correctIndex;

    return Card(
      color: isCorrect ? Colors.green[50] : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.info,
                  color: isCorrect ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isCorrect ? 'Correct!' : 'Not quite...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _currentQuestion.explanation!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isAnswered) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppOverlays.black10,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentQuestionIndex > 0)
            OutlinedButton(
              onPressed: _previousQuestion,
              child: const Text('Previous'),
            ),
          const Spacer(),

          // Submit/Next button
          if (!_showExplanation)
            FilledButton(
              onPressed: _selectedAnswer != null ? _submitAnswer : null,
              child: const Text('Submit Answer'),
            )
          else
            FilledButton(
              onPressed: _nextQuestion,
              child: Text(_isLastQuestion ? 'See Results' : 'Next Question'),
            ),
        ],
      ),
    );
  }

  String _getPathName(String pathId) {
    try {
      return LessonContent.allPaths.firstWhere((p) => p.id == pathId).title;
    } catch (_) {
      return pathId;
    }
  }
}
