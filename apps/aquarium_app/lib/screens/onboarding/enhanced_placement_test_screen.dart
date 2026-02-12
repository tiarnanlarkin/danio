/// Enhanced placement test screen with animations and celebrations
/// Duolingo-style onboarding experience
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../models/placement_test.dart';
import '../../models/learning.dart';
import '../../data/placement_test_content.dart';
import '../../data/lesson_content.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../placement_result_screen.dart';

class EnhancedPlacementTestScreen extends ConsumerStatefulWidget {
  const EnhancedPlacementTestScreen({super.key});

  @override
  ConsumerState<EnhancedPlacementTestScreen> createState() =>
      _EnhancedPlacementTestScreenState();
}

class _EnhancedPlacementTestScreenState
    extends ConsumerState<EnhancedPlacementTestScreen>
    with TickerProviderStateMixin {
  final PlacementTest _test = PlacementTestContent.defaultTest;
  final Map<String, int> _userAnswers = {}; // questionId -> selectedIndex
  final Map<String, bool> _answeredQuestions = {}; // Track answered questions

  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;

  late ConfettiController _confettiController;
  late AnimationController _celebrationController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  PlacementQuestion get _currentQuestion =>
      _test.questions[_currentQuestionIndex];
  bool get _isLastQuestion =>
      _currentQuestionIndex == _test.questions.length - 1;
  double get _progress => (_currentQuestionIndex + 1) / _test.questions.length;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 800),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _celebrationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_showExplanation) return;
    setState(() => _selectedAnswer = index);
  }

  void _submitAnswer() async {
    if (_selectedAnswer == null) return;

    setState(() {
      _userAnswers[_currentQuestion.id] = _selectedAnswer!;
      _answeredQuestions[_currentQuestion.id] = true;
      _showExplanation = true;
    });

    // Show celebration or shake based on correctness
    final isCorrect = _selectedAnswer == _currentQuestion.correctIndex;
    if (isCorrect) {
      _confettiController.play();
      _celebrationController.forward().then(
        (_) => _celebrationController.reverse(),
      );
    } else {
      _shakeController.forward().then((_) => _shakeController.reverse());
    }
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _completeTest();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer =
            _userAnswers[_test.questions[_currentQuestionIndex].id];
        _showExplanation =
            _answeredQuestions[_test.questions[_currentQuestionIndex].id] ??
            false;
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
    for (final question in _test.questions) {
      if (!_userAnswers.containsKey(question.id)) {
        _userAnswers[question.id] = -1;
      }
    }
    _completeTest();
  }

  void _completeTest() async {
    final result = PlacementAlgorithm.calculateResult(
      test: _test,
      userAnswers: _userAnswers,
      allPaths: LessonContent.allPaths,
    );

    final profileNotifier = ref.read(userProfileProvider.notifier);
    await profileNotifier.completePlacementTest(
      resultId: result.id,
      lessonsToSkip: result.lessonsToSkip,
      xpToAward: result.calculateSkipXp(LessonContent.allPaths),
    );

    if (!mounted) return;

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
      body: Stack(
        children: [
          Column(
            children: [
              // Animated progress bar
              _buildAnimatedProgressBar(),

              // Question content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question header
                      _buildQuestionHeader(theme),
                      const SizedBox(height: AppSpacing.md),

                      // Question card with shake animation
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            _shakeAnimation.value *
                                ((_currentQuestionIndex % 2 == 0) ? 1 : -1),
                            0,
                          ),
                          child: child,
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mediumRadius,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              _currentQuestion.question,
                              style: theme.textTheme.titleLarge?.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Answer options
                      ..._buildAnimatedAnswerOptions(),

                      // Explanation with animation
                      if (_showExplanation &&
                          _currentQuestion.explanation != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _buildAnimatedExplanation(),
                      ],
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(isAnswered),
            ],
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.15,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.orange,
                AppColors.accent,
                AppColors.primary,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProgressBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _progress),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) => Column(
        children: [
          Stack(
            children: [
              LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accent,
                ),
              ),
              // Shimmer effect on progress
              if (value < 1.0)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: 0.3,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppOverlays.white30,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.quiz, size: 16, color: AppColors.accent),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${(_progress * 100).round()}% Complete',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppOverlays.accent10,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Text(
                    '${_userAnswers.length}/${_test.questions.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'of ${_test.questions.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Chip(
          avatar: const Icon(Icons.category, size: 18),
          label: Text(
            _getPathName(_currentQuestion.pathId),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          backgroundColor: _getPathColor(
            _currentQuestion.pathId,
          ).withOpacity(0.1),
          side: BorderSide(color: _getPathColor(_currentQuestion.pathId)),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  List<Widget> _buildAnimatedAnswerOptions() {
    return List.generate(_currentQuestion.options.length, (index) {
      final isSelected = _selectedAnswer == index;
      final isCorrect = index == _currentQuestion.correctIndex;
      final showResult = _showExplanation;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 100)),
        curve: Curves.easeOut,
        builder: (context, value, child) => Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        ),
        child: _buildAnswerOption(index, isSelected, isCorrect, showResult),
      );
    });
  }

  Widget _buildAnswerOption(
    int index,
    bool isSelected,
    bool isCorrect,
    bool showResult,
  ) {
    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;
    Color? iconColor;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green[50];
        borderColor = Colors.green;
        icon = Icons.check_circle;
        iconColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red[50];
        borderColor = Colors.red;
        icon = Icons.cancel;
        iconColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = AppOverlays.accent10;
      borderColor = AppColors.accent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: showResult ? null : () => _selectAnswer(index),
          borderRadius: AppRadius.mediumRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: borderColor ?? Colors.grey[300]!,
                width: isSelected || showResult ? 2 : 1,
              ),
              boxShadow: isSelected && !showResult
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Letter indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: showResult && isCorrect
                        ? Colors.green
                        : (isSelected ? AppColors.accent : Colors.grey[200]),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: isSelected || (showResult && isCorrect)
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _currentQuestion.options[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  ScaleTransition(
                    scale: _celebrationController,
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedExplanation() {
    final isCorrect = _selectedAnswer == _currentQuestion.correctIndex;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.scale(
        scale: 0.95 + (0.05 * value),
        child: Opacity(opacity: value, child: child),
      ),
      child: Card(
        elevation: 4,
        color: isCorrect ? Colors.green[50] : Colors.blue[50],
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mediumRadius,
          side: BorderSide(
            color: isCorrect ? Colors.green : Colors.blue,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.celebration : Icons.school,
                    color: isCorrect ? Colors.green : Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    isCorrect ? 'Excellent! 🎉' : 'Good to know! 💡',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Text(
                  _currentQuestion.explanation!,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isAnswered) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            OutlinedButton.icon(
              onPressed: _previousQuestion,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back'),
            ),
          const Spacer(),

          // Submit/Next button
          if (!_showExplanation)
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _selectedAnswer != null ? _submitAnswer : null,
                icon: const Icon(Icons.check),
                label: const Text('Check Answer'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            )
          else
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _nextQuestion,
                icon: Icon(
                  _isLastQuestion ? Icons.emoji_events : Icons.arrow_forward,
                ),
                label: Text(_isLastQuestion ? 'See Results!' : 'Next'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
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

  Color _getPathColor(String pathId) {
    final index = LessonContent.allPaths.indexWhere((p) => p.id == pathId);
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      Colors.orange,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
}
