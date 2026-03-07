import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning.dart';
import '../providers/lesson_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/spaced_repetition_provider.dart';
import '../providers/achievement_provider.dart';
import '../services/achievement_service.dart';
import '../services/hearts_service.dart';
import '../services/notification_service.dart';
import '../widgets/hearts_widgets.dart';
import '../widgets/xp_award_animation.dart';
import '../widgets/level_up_dialog.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/haptic_feedback.dart';

/// Screen for viewing a single lesson and taking quizzes
class LessonScreen extends ConsumerStatefulWidget {
  final Lesson lesson;
  final String pathTitle;
  final bool isPracticeMode;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.pathTitle,
    this.isPracticeMode = false,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  bool _showQuiz = false;
  int _currentQuizQuestion = 0;
  int _correctAnswers = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _quizComplete = false;
  bool _showHeartAnimation = false;
  bool _heartGained = false;
  bool _isCompletingLesson = false;
  int? _levelBeforeLesson;

  @override
  void initState() {
    super.initState();
    // Capture current level for level-up detection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        setState(() {
          _levelBeforeLesson = profile.currentLevel;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                widget.pathTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.isPracticeMode) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppOverlays.accent20,
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Text(
                  'PRACTICE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!widget.isPracticeMode) ...[
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(child: HeartIndicator(compact: true)),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppOverlays.accent20,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: AppIconSizes.xs, color: AppColors.accent),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${widget.lesson.xpReward} XP',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _showQuiz ? _buildQuiz() : _buildLesson(),
          // Heart animation overlay
          if (_showHeartAnimation)
            Center(
              child: HeartAnimation(
                gained: _heartGained,
                onComplete: () {
                  setState(() => _showHeartAnimation = false);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLesson() {
    // Calculate total items: title + spacing + time row + spacing + sections + final spacing
    final totalItems = 4 + widget.lesson.sections.length + 1;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg2, AppSpacing.lg2, AppSpacing.lg2, 100),
            itemCount: totalItems,
            itemBuilder: (context, index) {
              // Lesson title with Hero animation
              if (index == 0) {
                return Hero(
                  tag: 'lesson-${widget.lesson.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      widget.lesson.title,
                      style: AppTypography.headlineLarge,
                    ),
                  ),
                );
              }

              // Spacing after title
              if (index == 1) {
                return const SizedBox(height: AppSpacing.sm);
              }

              // Time estimate row
              if (index == 2) {
                return Row(
                  children: [
                    Icon(Icons.timer, size: AppIconSizes.xs, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${widget.lesson.estimatedMinutes} min read',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }

              // Spacing before sections
              if (index == 3) {
                return const SizedBox(height: AppSpacing.lg);
              }

              // Lesson sections
              if (index < 4 + widget.lesson.sections.length) {
                final sectionIndex = index - 4;
                final section = widget.lesson.sections[sectionIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSection(section),
                );
              }

              // Final spacing
              return const SizedBox(height: AppSpacing.xl2);
            },
          ),
        ),

        // Bottom action
        Container(
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
              onPressed: _isCompletingLesson
                  ? null
                  : () {
                      if (widget.lesson.quiz != null) {
                        setState(() => _showQuiz = true);
                      } else {
                        _completeLesson();
                      }
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isCompletingLesson
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm2),
                        Text('Completing...'),
                      ],
                    )
                  : Text(
                      widget.lesson.quiz != null
                          ? 'Take Quiz'
                          : 'Complete Lesson',
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(LessonSection section) {
    switch (section.type) {
      case LessonSectionType.heading:
        return Text(section.content, style: AppTypography.headlineMedium);

      case LessonSectionType.text:
        return Text(
          section.content,
          style: AppTypography.bodyLarge.copyWith(height: 1.6),
        );

      case LessonSectionType.keyPoint:
        return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppOverlays.primary10,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppOverlays.primary30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb, color: AppColors.primary, size: AppIconSizes.md),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Text(
                  section.content,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

      case LessonSectionType.tip:
        return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppOverlays.success10,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppOverlays.success30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tips_and_updates, color: AppColors.success, size: AppIconSizes.md),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tip',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(section.content, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );

      case LessonSectionType.warning:
        return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppOverlays.warning10,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppOverlays.warning30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning, size: AppIconSizes.md),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Heads up',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(section.content, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );

      case LessonSectionType.funFact:
        return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppOverlays.purple10,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppOverlays.purple30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🤓', style: Theme.of(context).textTheme.headlineSmall!),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fun Fact',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.accentAlt,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(section.content, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );

      case LessonSectionType.bulletList:
        final items = section.content.split('\n');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: AppTypography.bodyLarge.copyWith(height: 1.5),
              ),
            );
          }).toList(),
        );

      case LessonSectionType.numberedList:
        final items = section.content.split('\n');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: AppTypography.bodyLarge.copyWith(height: 1.5),
              ),
            );
          }).toList(),
        );

      case LessonSectionType.image:
        // Placeholder for future image support
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.mediumRadius,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image_outlined, size: AppIconSizes.xl, color: AppColors.textHint),
                const SizedBox(height: 8),
                Text(
                  'Illustration coming soon',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildQuiz() {
    if (_quizComplete) {
      return _buildQuizResults();
    }

    final quiz = widget.lesson.quiz!;
    final question = quiz.questions[_currentQuizQuestion];

    return Column(
      children: [
        // Progress
        Padding(
          padding: EdgeInsets.all(AppSpacing.lg2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuizQuestion + 1} of ${quiz.questions.length}',
                    style: AppTypography.labelLarge,
                  ),
                  Text(
                    '$_correctAnswers correct',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.xsRadius,
                child: LinearProgressIndicator(
                  value: (_currentQuizQuestion + 1) / quiz.questions.length,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3 + question.options.length + (_answered && question.explanation != null ? 2 : 0), // spacing + question + spacing + options + (spacing + explanation if answered)
            itemBuilder: (context, index) {
              // Spacing at top
              if (index == 0) {
                return const SizedBox(height: AppSpacing.lg2);
              }

              // Question text
              if (index == 1) {
                return Text(question.question, style: AppTypography.headlineMedium);
              }

              // Spacing after question
              if (index == 2) {
                return const SizedBox(height: AppSpacing.lg);
              }

              // Answer options
              if (index >= 3 && index < 3 + question.options.length) {
                final optionIndex = index - 3;
                final option = question.options[optionIndex];
              final isSelected = _selectedAnswer == optionIndex;
              final isCorrect = optionIndex == question.correctIndex;

              Color? bgColor;
              Color? borderColor;
              IconData? icon;

              if (_answered) {
                if (isCorrect) {
                  bgColor = AppOverlays.success10;
                  borderColor = AppColors.success;
                  icon = Icons.check_circle;
                } else if (isSelected && !isCorrect) {
                  bgColor = AppOverlays.error10;
                  borderColor = AppColors.error;
                  icon = Icons.cancel;
                }
              } else if (isSelected) {
                bgColor = AppOverlays.primary10;
                borderColor = AppColors.primary;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: _answered
                      ? null
                      : () => setState(() => _selectedAnswer = optionIndex),
                    borderRadius: AppRadius.mediumRadius,
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: bgColor ?? AppColors.surface,
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: borderColor ?? AppColors.surfaceVariant,
                        width: borderColor != null ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected && !_answered
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: icon != null
                                ? Icon(
                                    icon,
                                    size: AppIconSizes.sm,
                                    color: isCorrect
                                        ? AppColors.success
                                        : AppColors.error,
                                  )
                                : Text(
                                    String.fromCharCode(65 + optionIndex),
                                    style: AppTypography.labelLarge.copyWith(
                                      color: isSelected && !_answered
                                          ? AppColors.onPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm2),
                          Expanded(
                            child: Text(option, style: AppTypography.bodyLarge),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Explanation (after answering)
              if (_answered && question.explanation != null) {
                // Spacing before explanation
                if (index == 3 + question.options.length) {
                  return const SizedBox(height: AppSpacing.md);
                }

                // Explanation content
                if (index == 4 + question.options.length) {
                  return Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppOverlays.info10,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.sm2),
                        Expanded(
                          child: Text(
                            question.explanation!,
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }

              return const SizedBox.shrink();
            },
          ),
        ),

        // Bottom action
        Container(
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
              onPressed: _selectedAnswer == null
                  ? null
                  : () async {
                      if (!_answered) {
                        // Check answer
                        final isCorrect =
                            _selectedAnswer == question.correctIndex;
                        setState(() {
                          _answered = true;
                          if (isCorrect) {
                            _correctAnswers++;
                          }
                        });

                        // Handle hearts (only in non-practice mode)
                        if (!widget.isPracticeMode && !isCorrect) {
                          final heartsService = ref.read(heartsServiceProvider);
                          final lostHeart = await heartsService.loseHeart();

                          if (lostHeart) {
                            // Show heart loss animation
                            setState(() {
                              _showHeartAnimation = true;
                              _heartGained = false;
                            });

                            // Check if out of hearts
                            if (!heartsService.hasHeartsAvailable) {
                              // Wait for animation to finish
                              await Future.delayed(
                                const Duration(milliseconds: 1200),
                              );
                              if (mounted) {
                                final result = await showOutOfHeartsModal(
                                  context,
                                );
                                if (result == 'practice' && mounted) {
                                  // Navigate to practice mode - pop and push again with practice flag
                                  Navigator.of(context).pop();
                                } else if (mounted) {
                                  // Wait or go back
                                  Navigator.of(context).pop();
                                }
                              }
                            }
                          }
                        }
                      } else {
                        // Next question or finish
                        if (_currentQuizQuestion < quiz.questions.length - 1) {
                          setState(() {
                            _currentQuizQuestion++;
                            _selectedAnswer = null;
                            _answered = false;
                          });
                        } else {
                          setState(() => _quizComplete = true);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
                !_answered
                    ? 'Check Answer'
                    : _currentQuizQuestion <
                          widget.lesson.quiz!.questions.length - 1
                    ? 'Next Question'
                    : 'See Results',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizResults() {
    final quiz = widget.lesson.quiz!;
    final percentage = (_correctAnswers / quiz.questions.length * 100).round();
    final passed = percentage >= quiz.passingScore;
    final bonusXp = passed ? quiz.bonusXp : 0;
    final totalXp = widget.lesson.xpReward + bonusXp;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: passed
                          ? AppOverlays.success10
                          : AppOverlays.warning10,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        passed ? '🎉' : '📚',
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 56),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    passed ? _passedMessage(percentage) : _tryAgainMessage(),
                    style: AppTypography.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'You got $_correctAnswers out of ${quiz.questions.length} correct ($percentage%)',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // XP earned
                  Container(
                    padding: EdgeInsets.all(AppSpacing.lg2),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.star, color: AppColors.onPrimary, size: 40),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '+$totalXp XP',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                        if (bonusXp > 0) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'includes +$bonusXp quiz bonus!',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom action
        Container(
          padding: EdgeInsets.all(AppSpacing.lg2),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _isCompletingLesson
                  ? null
                  : () => _completeLesson(bonusXp: bonusXp),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isCompletingLesson
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm2),
                        Text('Completing...'),
                      ],
                    )
                  : const Text('Complete Lesson'),
            ),
          ),
        ),
      ],
    );
  }

  /// Show XP animation and check for level-up
  void _showXpAnimation(int xpAmount) {
    if (!mounted) return;

    // Show XP animation overlay
    XpAwardOverlay.show(
      context,
      xpAmount: xpAmount,
      onComplete: () async {
        if (!mounted) return;

        // Check for level up after XP animation
        final profile = ref.read(userProfileProvider).value;
        if (profile != null && _levelBeforeLesson != null) {
          final currentLevel = profile.currentLevel;

          if (currentLevel > _levelBeforeLesson!) {
            // Level up detected! Show celebration
            await _showLevelUpCelebration(
              currentLevel,
              profile.levelTitle,
              profile.totalXp,
            );
          }
        }

        // Show next lesson CTA or navigate back
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showNextLessonOrPop();
            }
          });
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


  /// Varied quiz passed messages based on score
    static String _passedMessage(int percentage) {
    final messages = percentage == 100
        ? const ["Perfect score! You're a natural!", "Flawless! Your fish would be proud!", "100%! Aquarium genius!"]
        : percentage >= 80
            ? const ["Brilliant work!", "Nailed it!", "You're swimming through these!"]
            : const ["Nice job - you passed!", "Well done, keep building!", "Solid effort!"];
    return messages[math.Random().nextInt(messages.length)];
  }

  /// Encouraging try-again messages
    static String _tryAgainMessage() {
    const messages = ["Almost there - give it another go!", "Every expert was once a beginner!", "Review and try again - you've got this!"];
    return messages[math.Random().nextInt(messages.length)];
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

  /// Find and show the next lesson, or just pop back
  void _showNextLessonOrPop() {
    final nextLesson = _findNextLesson();
    if (nextLesson == null || widget.isPracticeMode) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    // Show next lesson bottom sheet
    showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('🎉', style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 40)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Lesson Complete!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppOverlays.primary20,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready for the next one?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            nextLesson.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Back to Path'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Start Next Lesson'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    ).then((startNext) {
      if (!mounted) return;
      if (startNext == true) {
        // Replace current lesson screen with next lesson
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LessonScreen(
              lesson: nextLesson,
              pathTitle: widget.pathTitle,
            ),
          ),
        );
      } else {
        // Go back to path
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  /// Find the next lesson in the current learning path
  Lesson? _findNextLesson() {
    final lessonState = ref.read(lessonProvider);
    // Search all loaded paths for the current lesson
    for (final path in lessonState.loadedPaths.values) {
      final lessons = path.lessons;
      for (int i = 0; i < lessons.length; i++) {
        if (lessons[i].id == widget.lesson.id && i + 1 < lessons.length) {
          final nextLesson = lessons[i + 1];
          // Check if user has already completed it
          final profile = ref.read(userProfileProvider).value;
          if (profile != null &&
              profile.completedLessons.contains(nextLesson.id)) {
            return null; // Already completed next lesson
          }
          return nextLesson;
        }
      }
    }
    return null;
  }

  Future<void> _completeLesson({int bonusXp = 0}) async {
    if (_isCompletingLesson) return;

    setState(() => _isCompletingLesson = true);

    try {
      final totalXp = widget.lesson.xpReward + bonusXp;

      // Handle practice mode rewards
      if (widget.isPracticeMode) {
        final heartsService = ref.read(heartsServiceProvider);
        final gainedHeart = await heartsService.gainHeart();

        if (gainedHeart && mounted) {
          // Show heart gain animation
          setState(() {
            _showHeartAnimation = true;
            _heartGained = true;
          });
          await Future.delayed(const Duration(milliseconds: 1200));
        }

        if (mounted) {
          AppFeedback.showSuccess(
            context,
            gainedHeart
                ? 'Practice complete! +1 heart ❤️'
                : 'Practice complete! (hearts full)',
          );
          Navigator.of(context).pop();
        }
        return; // Don't record progress for practice mode
      }

      // Calculate gem rewards (non-practice mode only)
      // Note: Gems are awarded by completeLesson() and awardQuizGems() automatically
      // int totalGems = 5; // Base lesson gems
      if (widget.lesson.quiz != null) {
        final quiz = widget.lesson.quiz!;
        final isPerfect = _correctAnswers == quiz.questions.length;
        // totalGems += isPerfect ? 5 : 3; // Quiz gems

        // Award quiz gems
        await ref
            .read(userProfileProvider.notifier)
            .awardQuizGems(isPerfect: isPerfect);
      }

      // Record completion and XP (also awards lesson gems automatically)
      await ref
          .read(userProfileProvider.notifier)
          .completeLesson(widget.lesson.id, totalXp);

      // Auto-seed spaced repetition cards from lesson content (non-critical)
      try {
        await ref
            .read(spacedRepetitionProvider.notifier)
            .autoSeedFromLesson(
              lessonId: widget.lesson.id,
              lessonSections: widget.lesson.sections,
              quizQuestions: widget.lesson.quiz?.questions,
            );
      } catch (e) {
        // Don't fail lesson completion if card seeding fails
        debugPrint('Spaced repetition seeding failed: $e');
      }

      // Record activity for streak (non-critical)
      try {
        await ref.read(userProfileProvider.notifier).recordActivity();
      } catch (e) {
        // Don't fail lesson completion if activity recording fails
        debugPrint('Activity recording failed: $e');
      }

      // Schedule review notifications for newly created cards (non-critical)
      try {
        final srState = ref.read(spacedRepetitionProvider);
        final dueCount = srState.stats.dueCards;
        if (dueCount > 0) {
          final notificationService = NotificationService();
          await notificationService.scheduleReviewReminder(
            dueCardsCount: dueCount,
            time: const TimeOfDay(hour: 9, minute: 0), // Default 9 AM
          );
        }
      } catch (e) {
        // Don't fail lesson completion if notification scheduling fails
        debugPrint('Notification scheduling failed: $e');
      }

      // Check for achievements using the full achievement checker
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        try {
          final achievementChecker = ref.read(achievementCheckerProvider);
          final isPerfect = widget.lesson.quiz != null &&
              _correctAnswers == widget.lesson.quiz!.questions.length;

          // Calculate today's lessons completed
          final todayKey = DateTime.now().toIso8601String().split('T')[0];
          final todayLessons = profile.completedLessons
              .where((id) {
                final progress = profile.lessonProgress[id];
                return progress != null &&
                    progress.completedDate.toIso8601String().split('T')[0] ==
                        todayKey;
              })
              .length +
              1; // +1 for this lesson

          await achievementChecker.checkAfterLesson(
            lessonsCompleted: profile.completedLessons.length + 1,
            currentStreak: profile.currentStreak,
            totalXp: profile.totalXp + totalXp,
            perfectScores: isPerfect
                ? (profile.achievements.where((a) => a == 'perfectionist').length + 1)
                : profile.achievements.where((a) => a == 'perfectionist').length,
            lessonCompletedAt: DateTime.now(),
            lessonDuration: widget.lesson.estimatedMinutes * 60,
            lessonScore: widget.lesson.quiz != null
                ? (_correctAnswers * 100 ~/ widget.lesson.quiz!.questions.length)
                : 100,
            todayLessonsCompleted: todayLessons,
            completedLessonIds: [...profile.completedLessons, widget.lesson.id],
          );
        } catch (e) {
          // Don't fail the lesson completion if achievement check fails
          debugPrint('Achievement check failed: $e');
        }
      }

      if (mounted) {
        // Show XP animation and check for level-up
        // Navigation happens in onComplete callback after all animations
        AppHaptics.success();
        _showXpAnimation(totalXp);
      }
    } catch (e, st) {
      debugPrint('Lesson completion error: $e');
      debugPrint('Stack trace: $st');
      if (mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t save your progress. Try again in a moment.',
          onRetry: () => _completeLesson(bonusXp: bonusXp),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCompletingLesson = false);
      }
    }
  }
}
