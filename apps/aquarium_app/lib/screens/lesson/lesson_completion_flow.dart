import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/learning.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/level_up_dialog.dart';
import '../../widgets/xp_award_animation.dart';

import '../../navigation/app_routes.dart';
import '../../widgets/app_bottom_sheet.dart';

/// Renders the quiz results screen (score, XP earned, pass/fail state) and the
/// "Complete Lesson" action.  Also contains the helpers for showing the next-
/// lesson bottom sheet, level-up celebration, and XP animation.
class LessonCompletionFlow extends StatelessWidget {
  final Lesson lesson;
  final String pathTitle;
  final bool isPracticeMode;
  final int correctAnswers;
  final bool isCompletingLesson;
  final VoidCallback onCompleteLesson;

  /// Whether this is the very first lesson the user has ever completed.
  final bool isFirstLesson;

  /// Current day streak count (0 = no streak).
  final int streakDays;

  /// Gems earned during this lesson (0 = none).
  final int gemsEarned;

  const LessonCompletionFlow({
    super.key,
    required this.lesson,
    required this.pathTitle,
    required this.isPracticeMode,
    required this.correctAnswers,
    required this.isCompletingLesson,
    required this.onCompleteLesson,
    this.isFirstLesson = false,
    this.streakDays = 0,
    this.gemsEarned = 0,
  });

  @override
  Widget build(BuildContext context) {
    final quiz = lesson.quiz;
    if (quiz == null) return const SizedBox.shrink();
    final percentage = (correctAnswers / quiz.questions.length * 100).round();
    final passed = percentage >= quiz.passingScore;
    final bonusXp = passed ? quiz.bonusXp : 0;
    final totalXp = lesson.xpReward + bonusXp;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium!.copyWith(fontSize: 56),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Semantics(
                    liveRegion: true,
                    header: true,
                    child: Text(
                      passed
                          ? passedMessage(percentage)
                          : tryAgainMessage(),
                      style: AppTypography.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      'You got $correctAnswers out of ${quiz.questions.length} correct ($percentage%)',
                      style: AppTypography.bodyLarge.copyWith(
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // XP earned
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg2),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.onPrimary,
                          size: 40,
                        ),
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
                              color: AppOverlays.white70,
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
          padding: const EdgeInsets.all(AppSpacing.lg2),
          child: SafeArea(
            child: AppButton(
              onPressed: isCompletingLesson
                  ? null
                  : () => onCompleteLesson(),
              label: 'Complete Lesson',
              isLoading: isCompletingLesson,
              isFullWidth: true,
              size: AppButtonSize.large,
            ),
          ),
        ),
      ],
    );
  }

  // ── Static helpers ─────────────────────────────────────────────────────────

  /// Varied quiz passed messages based on score.
  static String passedMessage(int percentage) {
    final messages = percentage == 100
        ? const [
            "Perfect score! You're a natural!",
            "Flawless! Your fish would be proud!",
            "100%! Aquarium genius!",
          ]
        : percentage >= 80
        ? const [
            "Brilliant work!",
            "Nailed it!",
            "You're swimming through these!",
          ]
        : const [
            "Nice job - you passed!",
            "Well done, keep building!",
            "Solid effort!",
          ];
    return messages[math.Random().nextInt(messages.length)];
  }

  /// Encouraging try-again messages.
  static String tryAgainMessage() {
    const messages = [
      "Almost there - give it another go!",
      "Every expert was once a beginner!",
      "Review and try again - you've got this!",
    ];
    return messages[math.Random().nextInt(messages.length)];
  }

  /// Get unlock message for level milestone.
  static String? getUnlockMessage(int level) {
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
}

// ── Free functions used by _LessonScreenState ──────────────────────────────

/// Show XP animation and check for level-up.  Navigation happens inside
/// [onComplete] so the caller controls what happens after animations.
void showLessonXpAnimation(
  BuildContext context,
  WidgetRef ref,
  int xpAmount, {
  required int? levelBeforeLesson,
  required VoidCallback onComplete,
}) {
  if (!context.mounted) return;

  XpAwardOverlay.show(
    context,
    xpAmount: xpAmount,
    onComplete: () async {
      if (!context.mounted) return;

      // Check for level up after XP animation.
      // Guard: clear the global levelUpEventProvider event BEFORE showing
      // the lesson-scoped LevelUpDialog so LevelUpListener (tab navigator)
      // doesn't fire a second celebration for the same level-up event.
      final profile = ref.read(userProfileProvider).value;
      if (profile != null && levelBeforeLesson != null) {
        final currentLevel = profile.currentLevel;

        if (currentLevel > levelBeforeLesson) {
          // Consume the provider event so LevelUpListener stays silent.
          ref.read(levelUpEventProvider.notifier).clearEvent();

          await showLevelUpCelebration(
            context,
            currentLevel,
            profile.levelTitle,
            profile.totalXp,
          );
        }
      }

      onComplete();
    },
  );
}

/// Show level-up celebration dialog.
Future<void> showLevelUpCelebration(
  BuildContext context,
  int newLevel,
  String levelTitle,
  int totalXp,
) async {
  if (!context.mounted) return;

  await LevelUpDialog.show(
    context,
    newLevel: newLevel,
    levelTitle: levelTitle,
    totalXp: totalXp,
    unlockMessage: LessonCompletionFlow.getUnlockMessage(newLevel),
  );
}

/// Find and show the next lesson, or just pop back.
void showNextLessonOrPop(
  BuildContext context,
  WidgetRef ref,
  Lesson currentLesson,
  String pathTitle,
  bool isPracticeMode,
) {
  // R-090: Guard against calling Navigator.of(context) when the widget has
  // been disposed between the post-frame callback registration and execution.
  if (!context.mounted) return;

  final nextLesson = _findNextLesson(ref, currentLesson);
  if (nextLesson == null || isPracticeMode) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    return;
  }

  // Show next lesson bottom sheet
  showAppDragSheet<bool>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🎉',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(fontSize: 40),
            ),
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
              padding: const EdgeInsets.all(AppSpacing.md),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                      ),
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
                  child: AppButton(
                    label: 'Back to Path',
                    onPressed: () => Navigator.of(ctx).pop(false),
                    variant: AppButtonVariant.secondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: 'Start Next Lesson',
                    onPressed: () => Navigator.of(ctx).pop(true),
                    variant: AppButtonVariant.primary,
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
    if (!context.mounted) return;
    if (startNext == true) {
      // Replace current lesson screen with next lesson
      AppRoutes.toLessonReplacement(context, nextLesson, pathTitle);
    } else {
      // Go back to path
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  });
}

/// Find the next lesson in the current learning path.
Lesson? _findNextLesson(WidgetRef ref, Lesson currentLesson) {
  final lessonState = ref.read(lessonProvider);
  for (final path in lessonState.loadedPaths.values) {
    final lessons = path.lessons;
    for (int i = 0; i < lessons.length; i++) {
      if (lessons[i].id == currentLesson.id && i + 1 < lessons.length) {
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
