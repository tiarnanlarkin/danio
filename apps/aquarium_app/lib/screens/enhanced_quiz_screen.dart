/// Enhanced quiz screen supporting all exercise types
/// Replaces the basic quiz functionality with multi-type support

import 'package:flutter/material.dart';
import '../models/exercises.dart';
import '../widgets/exercise_widgets.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class EnhancedQuizScreen extends StatefulWidget {
  final EnhancedQuiz quiz;
  final VoidCallback onComplete;
  final Function(int score, int maxScore, int bonusXp)? onQuizComplete;

  const EnhancedQuizScreen({
    super.key,
    required this.quiz,
    required this.onComplete,
    this.onQuizComplete,
  });

  @override
  State<EnhancedQuizScreen> createState() => _EnhancedQuizScreenState();
}

class _EnhancedQuizScreenState extends State<EnhancedQuizScreen>
    with TickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  int _correctAnswers = 0;
  final Map<int, dynamic> _userAnswers = {};
  final Map<int, bool> _answeredCorrectly = {};
  bool _currentAnswered = false;
  bool _quizComplete = false;
  
  late AnimationController _progressController;
  late AnimationController _feedbackController;
  late Animation<double> _progressAnimation;
  late Animation<double> _feedbackScale;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1 / widget.quiz.exercises.length,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _feedbackScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _feedbackController,
        curve: Curves.elasticOut,
      ),
    );
    
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _onAnswer(dynamic answer) {
    if (_currentAnswered) return;
    
    setState(() {
      _userAnswers[_currentExerciseIndex] = answer;
    });
  }

  void _checkAnswer() {
    if (_currentAnswered) return;
    
    final exercise = widget.quiz.exercises[_currentExerciseIndex];
    final isCorrect = exercise.validate(_userAnswers[_currentExerciseIndex]);
    
    setState(() {
      _currentAnswered = true;
      _answeredCorrectly[_currentExerciseIndex] = isCorrect;
      if (isCorrect) _correctAnswers++;
    });
    
    // Play feedback animation
    _feedbackController.forward(from: 0);
    
    // Haptic feedback
    // HapticFeedback.lightImpact(); // Uncomment if you want haptics
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.quiz.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentAnswered = false;
      });
      
      // Animate progress
      _progressController.animateTo(
        (_currentExerciseIndex + 1) / widget.quiz.exercises.length,
      );
    } else {
      setState(() {
        _quizComplete = true;
      });
      
      // Call completion callback
      final percentage = (_correctAnswers / widget.quiz.maxScore * 100).round();
      final passed = percentage >= widget.quiz.passingScore;
      final bonusXp = passed ? widget.quiz.bonusXp : 0;
      
      widget.onQuizComplete?.call(_correctAnswers, widget.quiz.maxScore, bonusXp);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quizComplete) {
      return _buildResults();
    }
    
    return _buildQuiz();
  }

  Widget _buildQuiz() {
    final exercise = widget.quiz.exercises[_currentExerciseIndex];
    final hasAnswer = _userAnswers.containsKey(_currentExerciseIndex);
    final isCorrect = _answeredCorrectly[_currentExerciseIndex];

    return Column(
      children: [
        // Progress header
        _buildProgressHeader(),
        
        // Quiz content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Exercise type badge
              _buildExerciseTypeBadge(exercise.type),
              const SizedBox(height: 16),
              
              // Question
              Text(
                exercise.question,
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: 24),
              
              // Exercise widget
              ExerciseWidget(
                exercise: exercise,
                onAnswer: _onAnswer,
                isAnswered: _currentAnswered,
                isCorrect: isCorrect,
                userAnswer: _userAnswers[_currentExerciseIndex],
              ),
              
              // Explanation (after answering)
              if (_currentAnswered && exercise.explanation != null) ...[
                const SizedBox(height: 24),
                _buildExplanation(exercise.explanation!, isCorrect ?? false),
              ],
              
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
        
        // Bottom action button
        _buildBottomButton(hasAnswer),
      ],
    );
  }

  Widget _buildProgressHeader() {
    final progress = (_currentExerciseIndex + 1) / widget.quiz.exercises.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentExerciseIndex + 1} of ${widget.quiz.exercises.length}',
                  style: AppTypography.labelLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        '$_correctAnswers correct',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTypeBadge(ExerciseType type) {
    String label;
    IconData icon;
    Color color;
    
    switch (type) {
      case ExerciseType.multipleChoice:
        label = 'Multiple Choice';
        icon = Icons.radio_button_checked;
        color = Colors.blue;
        break;
      case ExerciseType.fillBlank:
        label = 'Fill in the Blank';
        icon = Icons.edit;
        color = Colors.purple;
        break;
      case ExerciseType.trueFalse:
        label = 'True or False';
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case ExerciseType.matching:
        label = 'Matching';
        icon = Icons.compare_arrows;
        color = Colors.orange;
        break;
      case ExerciseType.ordering:
        label = 'Put in Order';
        icon = Icons.reorder;
        color = Colors.red;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation(String explanation, bool isCorrect) {
    return ScaleTransition(
      scale: _feedbackScale,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.success.withOpacity(0.1)
              : AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCorrect
                ? AppColors.success.withOpacity(0.3)
                : AppColors.info.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCorrect ? Icons.celebration : Icons.lightbulb_outline,
              color: isCorrect ? AppColors.success : AppColors.info,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? 'Correct!' : 'Learn from this',
                    style: AppTypography.labelLarge.copyWith(
                      color: isCorrect ? AppColors.success : AppColors.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    explanation,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(bool hasAnswer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: !hasAnswer
              ? null
              : () {
                  if (!_currentAnswered) {
                    _checkAnswer();
                  } else {
                    _nextExercise();
                  }
                },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: Text(
            !_currentAnswered
                ? 'Check Answer'
                : _currentExerciseIndex < widget.quiz.exercises.length - 1
                    ? 'Next Question'
                    : 'See Results',
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final percentage = (_correctAnswers / widget.quiz.maxScore * 100).round();
    final passed = percentage >= widget.quiz.passingScore;
    final bonusXp = passed ? widget.quiz.bonusXp : 0;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Result emoji with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: passed
                                ? AppColors.primaryGradient
                                : LinearGradient(
                                    colors: [
                                      AppColors.warning,
                                      AppColors.warning.withOpacity(0.7),
                                    ],
                                  ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (passed ? AppColors.primary : AppColors.warning)
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              passed ? '🎉' : '📚',
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    passed ? 'Excellent work!' : 'Keep learning!',
                    style: AppTypography.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Score
                  Text(
                    'You got $_correctAnswers out of ${widget.quiz.maxScore} correct',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Percentage with circular progress
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: percentage / 100),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 8,
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                passed ? AppColors.success : AppColors.warning,
                              ),
                            );
                          },
                        ),
                        Text(
                          '$percentage%',
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // XP earned card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          '+${widget.quiz.bonusXp + (passed ? bonusXp : 0)} XP',
                          style: AppTypography.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (bonusXp > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'includes +$bonusXp passing bonus!',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  if (!passed) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Pass with ${widget.quiz.passingScore}% to earn bonus XP!',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        
        // Bottom action
        Container(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: widget.onComplete,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Complete'),
            ),
          ),
        ),
      ],
    );
  }
}
