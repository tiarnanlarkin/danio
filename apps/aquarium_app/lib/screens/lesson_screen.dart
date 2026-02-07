import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';

/// Screen for viewing a single lesson and taking quizzes
class LessonScreen extends ConsumerStatefulWidget {
  final Lesson lesson;
  final String pathTitle;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.pathTitle,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pathTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.accent),
                    const SizedBox(width: 4),
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
      body: _showQuiz ? _buildQuiz() : _buildLesson(),
    );
  }

  Widget _buildLesson() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Lesson title
              Text(
                widget.lesson.title,
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.lesson.estimatedMinutes} min read',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lesson sections
              ...widget.lesson.sections.map((section) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSection(section),
                );
              }),

              const SizedBox(height: 40),
            ],
          ),
        ),

        // Bottom action
        Container(
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
              onPressed: () {
                if (widget.lesson.quiz != null) {
                  setState(() => _showQuiz = true);
                } else {
                  _completeLesson();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
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
        return Text(
          section.content,
          style: AppTypography.headlineMedium,
        );

      case LessonSectionType.text:
        return Text(
          section.content,
          style: AppTypography.bodyLarge.copyWith(
            height: 1.6,
          ),
        );

      case LessonSectionType.keyPoint:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tips_and_updates, color: AppColors.success, size: 24),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 4),
                    Text(section.content, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );

      case LessonSectionType.warning:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warning',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(section.content, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );

      case LessonSectionType.funFact:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🤓', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fun Fact',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.image,
              size: 48,
              color: AppColors.textHint,
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
          padding: const EdgeInsets.all(20),
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
                    '${_correctAnswers} correct',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 20),
              Text(
                question.question,
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: 24),

              // Answer options
              ...question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = _selectedAnswer == index;
                final isCorrect = index == question.correctIndex;

                Color? bgColor;
                Color? borderColor;
                IconData? icon;

                if (_answered) {
                  if (isCorrect) {
                    bgColor = AppColors.success.withOpacity(0.1);
                    borderColor = AppColors.success;
                    icon = Icons.check_circle;
                  } else if (isSelected && !isCorrect) {
                    bgColor = AppColors.error.withOpacity(0.1);
                    borderColor = AppColors.error;
                    icon = Icons.cancel;
                  }
                } else if (isSelected) {
                  bgColor = AppColors.primary.withOpacity(0.1);
                  borderColor = AppColors.primary;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: _answered
                        ? null
                        : () => setState(() => _selectedAnswer = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor ?? AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
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
                                      size: 20,
                                      color: isCorrect
                                          ? AppColors.success
                                          : AppColors.error,
                                    )
                                  : Text(
                                      String.fromCharCode(65 + index),
                                      style: AppTypography.labelLarge.copyWith(
                                        color: isSelected && !_answered
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: AppTypography.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Explanation (after answering)
              if (_answered && question.explanation != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question.explanation!,
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bottom action
        Container(
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
              onPressed: _selectedAnswer == null
                  ? null
                  : () {
                      if (!_answered) {
                        // Check answer
                        setState(() {
                          _answered = true;
                          if (_selectedAnswer == question.correctIndex) {
                            _correctAnswers++;
                          }
                        });
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
                    : _currentQuizQuestion < widget.lesson.quiz!.questions.length - 1
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
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: passed
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        passed ? '🎉' : '📚',
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    passed ? 'Great job!' : 'Keep learning!',
                    style: AppTypography.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You got $_correctAnswers out of ${quiz.questions.length} correct ($percentage%)',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // XP earned
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          '+$totalXp XP',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        if (bonusXp > 0) ...[
                          const SizedBox(height: 4),
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
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () => _completeLesson(bonusXp: bonusXp),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Complete Lesson'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _completeLesson({int bonusXp = 0}) async {
    final totalXp = widget.lesson.xpReward + bonusXp;

    // Calculate gem rewards
    int totalGems = 5; // Base lesson gems
    if (widget.lesson.quiz != null) {
      final quiz = widget.lesson.quiz!;
      final isPerfect = _correctAnswers == quiz.questions.length;
      totalGems += isPerfect ? 5 : 3; // Quiz gems
      
      // Award quiz gems
      await ref.read(userProfileProvider.notifier).awardQuizGems(isPerfect: isPerfect);
    }

    // Record completion and XP (also awards lesson gems automatically)
    await ref.read(userProfileProvider.notifier).completeLesson(
      widget.lesson.id,
      totalXp,
    );

    // Record activity for streak
    await ref.read(userProfileProvider.notifier).recordActivity();

    // Check for achievements
    final profile = ref.read(userProfileProvider).value;
    if (profile != null) {
      final notifier = ref.read(userProfileProvider.notifier);
      
      // First lesson achievement
      if (profile.completedLessons.isEmpty) {
        await notifier.unlockAchievement('first_lesson');
      }

      // Quiz ace (100%)
      if (widget.lesson.quiz != null) {
        final quiz = widget.lesson.quiz!;
        if (_correctAnswers == quiz.questions.length) {
          await notifier.unlockAchievement('quiz_ace');
        }
      }
    }

    if (mounted) {
      // Show success snackbar with XP and gems
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Lesson complete! +$totalXp XP, +$totalGems gems'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.of(context).pop();
    }
  }
}
