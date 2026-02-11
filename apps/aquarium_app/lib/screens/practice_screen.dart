import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning.dart';
import '../models/lesson_progress.dart';
import '../data/lesson_content.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import 'lesson_screen.dart';

/// Practice screen showing lessons that need review based on spaced repetition
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weakLessons = ref
        .read(userProfileProvider.notifier)
        .getWeakestLessons();

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: weakLessons.isEmpty
          ? _buildEmptyState(context)
          : _buildPracticeList(context, ref, weakLessons),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎯', style: TextStyle(fontSize: 56)),
              ),
            ),
            const SizedBox(height: 24),
            Text('All caught up!', style: AppTypography.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'No lessons need review right now. Your knowledge is fresh!',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Complete more lessons to build your practice queue.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeList(
    BuildContext context,
    WidgetRef ref,
    List<LessonProgress> weakLessons,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Practice Mode',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review lessons before you forget them',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Info card explaining spaced repetition
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.info),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lesson strength decays over time: 100% → 70% (1 day) → 40% (7 days) → 0% (30 days). Review before they\'re forgotten!',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Lessons to review
        Text(
          'Lessons needing review (${weakLessons.length})',
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: 12),

        ...weakLessons.map((progress) {
          final lesson = _findLessonById(progress.lessonId);
          if (lesson == null) return const SizedBox.shrink();

          final path = _findPathForLesson(lesson.id);
          final strength = progress.currentStrength;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildLessonCard(
              context,
              ref,
              lesson,
              path?.title ?? 'Unknown Path',
              strength,
              progress,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
    String pathTitle,
    double strength,
    LessonProgress progress,
  ) {
    // Determine color based on strength
    Color strengthColor;
    if (strength >= 70) {
      strengthColor = AppColors.success;
    } else if (strength >= 40) {
      strengthColor = AppColors.warning;
    } else {
      strengthColor = AppColors.error;
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LessonScreen(
              lesson: lesson,
              pathTitle: pathTitle,
              isPracticeMode: true,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pathTitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        '+${lesson.xpReward ~/ 2} XP',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Strength indicator
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Strength',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${strength.round()}%',
                            style: AppTypography.labelMedium.copyWith(
                              color: strengthColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: strength / 100,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            strengthColor,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Review stats
            Row(
              children: [
                Icon(Icons.refresh, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  'Reviewed ${progress.reviewCount} time${progress.reviewCount == 1 ? '' : 's'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  _getTimeSinceReview(progress),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeSinceReview(LessonProgress progress) {
    final referenceDate = progress.lastReviewDate ?? progress.completedDate;
    final daysSince = DateTime.now().difference(referenceDate).inDays;

    if (daysSince == 0) return 'Today';
    if (daysSince == 1) return '1 day ago';
    if (daysSince < 7) return '$daysSince days ago';
    if (daysSince < 30) {
      final weeks = (daysSince / 7).round();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    }
    final months = (daysSince / 30).round();
    return '$months month${months == 1 ? '' : 's'} ago';
  }

  Lesson? _findLessonById(String lessonId) {
    for (final path in LessonContent.allPaths) {
      for (final lesson in path.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  LearningPath? _findPathForLesson(String lessonId) {
    for (final path in LessonContent.allPaths) {
      if (path.lessons.any((l) => l.id == lessonId)) {
        return path;
      }
    }
    return null;
  }
}

/// Extended lesson screen that handles both initial completion and review
class PracticeLessonScreen extends LessonScreen {
  final bool isReview;

  const PracticeLessonScreen({
    super.key,
    required super.lesson,
    required super.pathTitle,
    this.isReview = false,
  });

  @override
  ConsumerState<LessonScreen> createState() => _PracticeLessonScreenState();
}

class _PracticeLessonScreenState extends ConsumerState<PracticeLessonScreen> {
  bool _showQuiz = false;
  // Unused quiz state variables - quiz functionality handled elsewhere
  // int _currentQuizQuestion = 0;
  // int _correctAnswers = 0;
  // int? _selectedAnswer;
  // bool _answered = false;
  // bool _quizComplete = false;

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                      widget.isReview
                          ? '+${widget.lesson.xpReward ~/ 2} XP'
                          : '+${widget.lesson.xpReward} XP',
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
        if (widget.isReview)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppColors.info.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 16, color: AppColors.info),
                const SizedBox(width: 8),
                Text(
                  'Review Mode - Half XP',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Lesson title
              Text(widget.lesson.title, style: AppTypography.headlineLarge),
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
                    : widget.isReview
                    ? 'Complete Review'
                    : 'Complete Lesson',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Section builder methods remain the same as LessonScreen
  Widget _buildSection(LessonSection section) {
    // Implementation same as original LessonScreen._buildSection
    // Copying the implementation here for completeness
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
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.image, size: 48, color: AppColors.textHint),
          ),
        );
    }
  }

  Widget _buildQuiz() {
    // Quiz implementation - would be same as original LessonScreen
    // Simplified here for brevity
    return Center(
      child: Text('Quiz implementation (same as original LessonScreen)'),
    );
  }

  Future<void> _completeLesson({int bonusXp = 0}) async {
    try {
      final xpReward = widget.isReview
          ? (widget.lesson.xpReward ~/ 2) + bonusXp
          : widget.lesson.xpReward + bonusXp;

      if (widget.isReview) {
        // Review mode - update lesson progress
        await ref
            .read(userProfileProvider.notifier)
            .reviewLesson(widget.lesson.id, xpReward);
      } else {
        // Initial completion
        await ref
            .read(userProfileProvider.notifier)
            .completeLesson(widget.lesson.id, xpReward);
      }

      // Record activity for streak
      await ref.read(userProfileProvider.notifier).recordActivity();

      if (mounted) {
        // Show success message
        final message = widget.isReview
            ? 'Review complete! +$xpReward XP'
            : 'Lesson complete! +$xpReward XP';
        AppFeedback.showSuccess(context, message);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Failed to save progress. Please try again.',
          onRetry: () => _completeLesson(bonusXp: bonusXp),
        );
      }
    }
  }
}
