/// Enhanced quiz screen supporting all exercise types
/// Replaces the basic quiz functionality with multi-type support
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_constants.dart';
import '../utils/haptic_feedback.dart';
import '../models/exercises.dart';
import '../widgets/exercise_widgets.dart';
import '../widgets/hearts_widgets.dart';
import '../widgets/xp_award_animation.dart';
import '../widgets/level_up_dialog.dart';
import '../services/hearts_service.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';


class EnhancedQuizScreen extends ConsumerStatefulWidget {
  final EnhancedQuiz quiz;
  final VoidCallback onComplete;
  final Function(int score, int maxScore, int bonusXp)? onQuizComplete;
  final bool isPracticeMode;

  const EnhancedQuizScreen({
    super.key,
    required this.quiz,
    required this.onComplete,
    this.onQuizComplete,
    this.isPracticeMode = false,
  });

  @override
  ConsumerState<EnhancedQuizScreen> createState() => _EnhancedQuizScreenState();
}

class _EnhancedQuizScreenState extends ConsumerState<EnhancedQuizScreen>
    with TickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  int _correctAnswers = 0;
  final Map<int, dynamic> _userAnswers = {};
  final Map<int, bool> _answeredCorrectly = {};
  bool _currentAnswered = false;
  bool _quizComplete = false;
  bool _isSubmitting = false;
  bool _showHeartAnimation = false;
  bool _xpAnimationShown = false;
  int? _levelBeforeQuiz;

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
      duration: AppDurations.long1,
      vsync: this,
    );

    _progressAnimation =
        Tween<double>(begin: 0, end: 1 / widget.quiz.exercises.length).animate(
          CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
        );

    _feedbackScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    _progressController.forward();

    // Store current level for level-up detection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        setState(() {
          _levelBeforeQuiz = profile.currentLevel;
        });
      }
    });
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

  Future<void> _checkAnswer() async {
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

    // Consume heart on wrong answer (not in practice mode)
    if (!isCorrect && !widget.isPracticeMode) {
      final heartsService = ref.read(heartsServiceProvider);
      final heartLost = await heartsService.loseHeart();

      if (heartLost && mounted) {
        setState(() {
          _showHeartAnimation = true;
        });
      }

      // Check if out of hearts after losing one
      if (!heartsService.hasHeartsAvailable) {
        // Show out of hearts modal after animation
        Future.delayed(kQuizRevealDelay, () {
          if (mounted) {
            _showOutOfHeartsDialog();
          }
        });
      }
    }

    // Haptic feedback
    if (isCorrect) {
      AppHaptics.success();
    } else {
      AppHaptics.error();
    }
  }

  Future<void> _showOutOfHeartsDialog() async {
    final result = await showOutOfHeartsModal(context);

    if (result == 'practice') {
      // Navigate to practice mode or home
      if (mounted) {
        Navigator.of(context).pop(); // Exit quiz
      }
    } else {
      // User chose to wait - exit quiz
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _nextExercise() async {
    // Check if user has hearts before allowing next question (not in practice mode)
    if (!widget.isPracticeMode) {
      final heartsService = ref.read(heartsServiceProvider);
      if (!heartsService.hasHeartsAvailable) {
        await _showOutOfHeartsDialog();
        return;
      }
    }

    if (!mounted) return;

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
        _isSubmitting = true;
      });

      try {
        // Call completion callback
        final percentage = (_correctAnswers / widget.quiz.maxScore * 100)
            .round();
        final passed = percentage >= widget.quiz.passingScore;
        final bonusXp = passed ? widget.quiz.bonusXp : 0;

        widget.onQuizComplete?.call(
          _correctAnswers,
          widget.quiz.maxScore,
          bonusXp,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  /// Show XP animation and check for level-up
  void _showXpAnimation(int xpAmount) {
    if (!mounted) return;

    // Show XP animation overlay
    XpAwardOverlay.show(
      context,
      xpAmount: xpAmount,
      onComplete: () {
        if (!mounted) return;

        // Check for level up after XP animation
        final profile = ref.read(userProfileProvider).value;
        if (profile != null && _levelBeforeQuiz != null) {
          final currentLevel = profile.currentLevel;

          if (currentLevel > _levelBeforeQuiz!) {
            // Level up detected! Show celebration
            _showLevelUpCelebration(
              currentLevel,
              profile.levelTitle,
              profile.totalXp,
            );
          }
        }
      },
    );
  }

  /// Show level-up celebration dialog
  Future<void> _showLevelUpCelebration(
    int newLevel,
    String levelTitle,
    int totalXp,
  ) async {
    if (!mounted) return;

    await LevelUpDialog.show(
      context,
      newLevel: newLevel,
      levelTitle: levelTitle,
      totalXp: totalXp,
      unlockMessage: _getUnlockMessage(newLevel),
    );
  }

  /// Get unlock message for level milestone
  String? _getUnlockMessage(int level) {
    switch (level) {
      case 2:
        return 'You\'re making great progress!';
      case 3:
        return 'New lessons unlocked!';
      case 4:
        return 'You\'re becoming an aquarist!';
      case 5:
        return 'Expert status achieved!';
      case 6:
        return 'Master aquarist unlocked!';
      case 7:
        return 'You\'re a true guru!';
      default:
        return null;
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

    return Stack(
      children: [
        Column(
          children: [
            // Progress header
            _buildProgressHeader(),

            // Quiz content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExerciseTypeBadge(exercise.type),
                    const SizedBox(height: AppSpacing.md),
                    RepaintBoundary(
                      child: Text(
                        exercise.question,
                        key: ValueKey('question_${exercise.question.hashCode}'),
                        style: AppTypography.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DefaultTextStyle.merge(
                      style: TextStyle(color: AppColors.textPrimary),
                      child: ExerciseWidget(
                        exercise: exercise,
                        onAnswer: _onAnswer,
                        isAnswered: _currentAnswered,
                        isCorrect: isCorrect,
                        userAnswer: _userAnswers[_currentExerciseIndex],
                      ),
                    ),
                    if (_currentAnswered && exercise.explanation != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildExplanation(
                        exercise.explanation!,
                        isCorrect ?? false,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action button
            _buildBottomButton(hasAnswer),
          ],
        ),

        // Heart animation overlay
        if (_showHeartAnimation)
          Center(
            child: HeartAnimation(
              gained: false, // Always losing hearts on wrong answers
              onComplete: () {
                if (mounted) {
                  setState(() => _showHeartAnimation = false);
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    final progress = (_currentExerciseIndex + 1) / widget.quiz.exercises.length;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppOverlays.black5,
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
                Row(
                  children: [
                    // Hearts indicator (not shown in practice mode)
                    if (!widget.isPracticeMode) ...[
                      const HeartIndicator(compact: true),
                      const SizedBox(width: AppSpacing.sm2),
                    ],
                    // Score indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppOverlays.success10,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSpacing.xs),
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
              ],
            ),
            const SizedBox(height: AppSpacing.sm2),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: AppRadius.smallRadius,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 8,
                    semanticsLabel: 'Quiz progress',
                    semanticsValue: '${(progress * 100).round()}%',
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
        color = AppColors.primary;
        break;
      case ExerciseType.fillBlank:
        label = 'Fill in the Blank';
        icon = Icons.edit;
        color = AppColors.accentAlt;
        break;
      case ExerciseType.trueFalse:
        label = 'True or False';
        icon = Icons.check_circle_outline;
        color = AppColors.success;
        break;
      case ExerciseType.matching:
        label = 'Matching';
        icon = Icons.compare_arrows;
        color = AppColors.warning;
        break;
      case ExerciseType.ordering:
        label = 'Put in Order';
        icon = Icons.reorder;
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs2),
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
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppOverlays.success10
              : AppOverlays.info10,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(
            color: isCorrect
                ? AppOverlays.success30
                : AppOverlays.accent20,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCorrect ? Icons.celebration : Icons.lightbulb_outline,
              color: isCorrect ? AppColors.success : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? 'Correct!' : 'Learn from this',
                    style: AppTypography.labelLarge.copyWith(
                      color: isCorrect ? AppColors.success : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(explanation, style: AppTypography.bodyMedium),
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
      padding: EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppOverlays.black5,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: (!hasAnswer || _isSubmitting)
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
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
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
    final totalXp = widget.quiz.bonusXp + bonusXp;

    // Show XP animation once on first build of results
    if (!_xpAnimationShown && mounted) {
      _xpAnimationShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && totalXp > 0) {
          _showXpAnimation(totalXp);
        }
      });
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),

                // Result emoji with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: AppDurations.long3,
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: passed
                              ? AppColors.primaryGradient
                              : LinearGradient(
                                  colors: [
                                    AppColors.warning,
                                    AppColors.warningAlpha70,
                                  ],
                                ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: passed
                                  ? AppColors.primaryAlpha30
                                  : AppColors.warningAlpha30,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            passed ? '🎉' : '📚',
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 52),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  passed ? 'Excellent work!' : 'Keep learning!',
                  style: AppTypography.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),

                // Motivational subtext
                Text(
                  passed
                      ? '🐠 Your aquarium knowledge is growing!'
                      : '🐠 Every expert was once a beginner.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                // Score and percentage row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Percentage with circular progress
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: percentage / 100),
                            duration: AppDurations.celebration,
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 6,
                                backgroundColor: AppColors.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  passed ? AppColors.success : AppColors.warning,
                                ),
                              );
                            },
                          ),
                          Text(
                            '$percentage%',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Text(
                      '$_correctAnswers / ${widget.quiz.maxScore}\ncorrect',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // XP earned card
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppRadius.largeRadius,
                    boxShadow: [
                      BoxShadow(
                        color: AppOverlays.primary30,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppColors.onPrimary, size: 32),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '+${widget.quiz.bonusXp + (passed ? bonusXp : 0)} XP',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (bonusXp > 0) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppOverlays.white20,
                            borderRadius: AppRadius.mediumRadius,
                          ),
                          child: Text(
                            '+$bonusXp bonus!',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (!passed) ...[
                  const SizedBox(height: AppSpacing.md),
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

        // Bottom action
        Container(
          padding: EdgeInsets.all(AppSpacing.lg2),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : widget.onComplete,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Complete'),
            ),
          ),
        ),
      ],
    );
  }
}
