import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/learning.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/spaced_repetition_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../services/hearts_service.dart';
import '../../services/notification_scheduler.dart';
import '../../services/rate_service.dart';
import '../../widgets/hearts_widgets.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_feedback.dart';
import '../../utils/haptic_feedback.dart';
import '../../utils/navigation_throttle.dart';
import '../../utils/logger.dart';
import 'lesson_card_widget.dart';
import 'lesson_quiz_widget.dart';
import 'lesson_completion_flow.dart';
import '../../widgets/danio_snack_bar.dart';
import '../../widgets/core/app_dialog.dart';
import '../../providers/species_unlock_provider.dart';
import '../emergency_guide_screen.dart';
import '../learn/unlock_celebration_screen.dart';
import '../../providers/inventory_provider.dart';

export 'lesson_card_widget.dart';
export 'lesson_quiz_widget.dart';
export 'lesson_completion_flow.dart';
export 'lesson_hearts_modal.dart';

/// Screen for viewing a single lesson and taking quizzes.
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
  bool _isExitingDueToHearts = false;
  bool _isHeartsModalVisible = false;
  int? _levelBeforeLesson;
  DateTime? _lessonStartTime;
  bool _showHint = false;

  @override
  void dispose() {
    _isExitingDueToHearts = false;
    _isHeartsModalVisible = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _lessonStartTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        setState(() {
          _levelBeforeLesson = profile.currentLevel;
        });
      }
    });
  }

  /// Shows a confirmation dialog before discarding mid-quiz progress.
  Future<bool> _confirmExitQuiz() async {
    if (!_showQuiz || _quizComplete) return true;
    final confirmed = await showAppDestructiveDialog(
      context: context,
      title: 'Leave quiz?',
      message: 'Your quiz progress will be lost. You can retake it anytime.',
      destructiveLabel: 'Leave',
      cancelLabel: 'Keep going',
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isXpBoostActive = ref.watch(xpBoostActiveProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_isHeartsModalVisible) return;
        if (_isExitingDueToHearts) return;
        final nav = Navigator.of(context);
        final canExit = await _confirmExitQuiz();
        if (canExit && mounted) {
          nav.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Flexible(
                child: Text(widget.pathTitle, overflow: TextOverflow.ellipsis),
              ),
              if (widget.isPracticeMode) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppOverlays.accent20,
                    borderRadius: AppRadius.smallRadius,
                  ),
                  child: Text(
                    'PRACTICE',
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!widget.isPracticeMode) ...[
              IconButton(
                tooltip: 'Emergency Guide',
                icon: const Icon(
                  Icons.emergency_outlined,
                  color: AppColors.error,
                ),
                onPressed: () => NavigationThrottle.push(
                  context,
                  const EmergencyGuideScreen(),
                  rootNavigator: true,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: Center(child: HeartIndicator(compact: true)),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm2,
                    vertical: AppSpacing.xs2,
                  ),
                  decoration: BoxDecoration(
                    color: AppOverlays.accent20,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: AppIconSizes.xs,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _xpBadgeText(isXpBoostActive),
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.accentText,
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
            _buildBody(),
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
      ),
    );
  }

  String _xpBadgeText(bool isXpBoostActive) {
    final baseReward = widget.lesson.xpReward;
    final maxLessonReward = baseReward + (widget.lesson.quiz?.bonusXp ?? 0);

    if (widget.isPracticeMode) {
      final reward = (isXpBoostActive ? baseReward * 2 : baseReward) ~/ 2;
      return isXpBoostActive ? '+$reward XP (2x)' : '+$reward XP';
    }

    final reward = isXpBoostActive ? maxLessonReward * 2 : maxLessonReward;
    return isXpBoostActive ? 'up to +$reward XP (2x)' : 'up to +$reward XP';
  }

  Widget _buildBody() {
    if (_showQuiz && _quizComplete) {
      return LessonCompletionFlow(
        lesson: widget.lesson,
        pathTitle: widget.pathTitle,
        isPracticeMode: widget.isPracticeMode,
        correctAnswers: _correctAnswers,
        isCompletingLesson: _isCompletingLesson,
        onCompleteLesson: () {
          final quiz = widget.lesson.quiz;
          final bonusXp = quiz != null
              ? ((_correctAnswers / quiz.questions.length * 100).round() >=
                        quiz.passingScore
                    ? quiz.bonusXp
                    : 0)
              : 0;
          _completeLesson(bonusXp: bonusXp);
        },
      );
    }

    if (_showQuiz) {
      return LessonQuizWidget(
        lesson: widget.lesson,
        isPracticeMode: widget.isPracticeMode,
        currentQuizQuestion: _currentQuizQuestion,
        correctAnswers: _correctAnswers,
        selectedAnswer: _selectedAnswer,
        answered: _answered,
        showHint: _showHint,
        onSelectAnswer: (index) => setState(() => _selectedAnswer = index),
        onShowHint: () => setState(() => _showHint = true),
        onCheckOrAdvance: _handleQuizAction,
      );
    }

    return LessonCardWidget(
      lesson: widget.lesson,
      isCompletingLesson: _isCompletingLesson,
      onAction: () {
        if (widget.lesson.quiz != null) {
          setState(() => _showQuiz = true);
        } else {
          _completeLesson();
        }
      },
    );
  }

  /// Handles both "Check Answer" and "Next Question / See Results" taps.
  Future<void> _handleQuizAction({
    required int selectedAnswer,
    required bool isCorrect,
    required bool isLastQuestion,
  }) async {
    if (!_answered) {
      // First tap: check the answer
      setState(() {
        _answered = true;
        if (isCorrect) _correctAnswers++;
      });

      // Handle energy (only in non-practice mode)
      // Energy loss never blocks progression — it just means no bonus XP.
      if (!widget.isPracticeMode && !isCorrect) {
        final heartsService = ref.read(heartsServiceProvider);
        final lostEnergy = await heartsService.loseHeart();

        if (lostEnergy && mounted) {
          setState(() {
            _showHeartAnimation = true;
            _heartGained = false;
          });

          // Energy depleted: show a soft info snackbar but do NOT exit.
          // The user can still continue — they just won't earn bonus XP.
          if (!heartsService.hasHeartsAvailable && mounted) {
            await Future.delayed(kQuizRevealDelay);
            if (mounted) {
              DanioSnackBar.info(
                context,
                'Energy depleted - keep going. Bonus XP pauses until it refills.',
              );
            }
          }
        }
      }
    } else {
      // Second tap: advance or finish
      if (!isLastQuestion) {
        setState(() {
          _currentQuizQuestion++;
          _selectedAnswer = null;
          _answered = false;
          _showHint = false;
        });
      } else {
        setState(() => _quizComplete = true);
      }
    }
  }

  /// Show XP animation, then check for species unlock, then level-up/next.
  void _showXpAnimation(int xpAmount, {int unlockedAchievementCount = 0}) {
    if (!mounted) return;
    showLessonXpAnimation(
      context,
      ref,
      xpAmount,
      levelBeforeLesson: _levelBeforeLesson,
      onComplete: () async {
        if (!mounted) return;

        // Check if this lesson unlocked a new species
        final newSpeciesId = await ref
            .read(speciesUnlockProvider.notifier)
            .checkLessonUnlock(widget.lesson.id);

        if (!mounted) return;

        if (newSpeciesId != null) {
          // Show unlock celebration screen, then continue to next lesson flow
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UnlockCelebrationScreen(speciesId: newSpeciesId),
            ),
          );
          if (!mounted) return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showNextLessonOrPop(
              context,
              ref,
              widget.lesson,
              widget.pathTitle,
              widget.isPracticeMode,
              xpAmount: xpAmount,
              levelBeforeLesson: _levelBeforeLesson,
              unlockedAchievementCount: unlockedAchievementCount,
            );
          }
        });
      },
    );
  }

  Future<void> _completeLesson({int bonusXp = 0}) async {
    if (_isCompletingLesson) return;

    setState(() => _isCompletingLesson = true);
    var progressCommitted = false;
    var hasPostCommitWarning = false;
    var committedXp = 0;

    try {
      // FB-H4: Apply XP boost if active
      final isBoostActive = ref.read(xpBoostActiveProvider);
      final baseXp = widget.lesson.xpReward + bonusXp;
      final totalXp = isBoostActive ? baseXp * 2 : baseXp;

      // Handle practice mode rewards
      if (widget.isPracticeMode) {
        final practiceXp = totalXp ~/ 2;
        var xpSaved = true;
        final profileBeforePractice = ref.read(userProfileProvider).value;
        final canReviewLesson =
            profileBeforePractice?.lessonProgress.containsKey(
              widget.lesson.id,
            ) ??
            false;
        try {
          if (canReviewLesson) {
            await ref
                .read(userProfileProvider.notifier)
                .reviewLesson(widget.lesson.id, practiceXp);
          } else {
            await ref.read(userProfileProvider.notifier).addXp(practiceXp);
          }
        } catch (e) {
          logError(
            'LessonScreen: practice XP save failed: $e',
            tag: 'LessonScreen',
          );
          if (canReviewLesson) {
            try {
              await ref.read(userProfileProvider.notifier).addXp(practiceXp);
            } catch (e) {
              xpSaved = false;
              logError('Error awarding practice XP: $e', tag: 'LessonScreen');
            }
          } else {
            xpSaved = false;
          }
        }

        final heartsService = ref.read(heartsServiceProvider);
        final gainedHeart = await heartsService.gainHeart();

        if (gainedHeart && mounted) {
          setState(() {
            _showHeartAnimation = true;
            _heartGained = true;
          });
          await Future.delayed(kQuizRevealDelay);
        }

        if (mounted) {
          if (xpSaved) {
            final xpMsg = practiceXp > 0 ? ' +$practiceXp XP' : '';
            AppFeedback.showSuccess(
              context,
              gainedHeart
                  ? 'Practice complete!$xpMsg +1 energy'
                  : 'Practice complete!$xpMsg (energy full)',
            );
          } else {
            AppFeedback.showNeutralViaMessenger(
              ScaffoldMessenger.of(context),
              'Practice complete. XP could not be saved.',
            );
          }
          Navigator.of(context).pop();
        }
        return;
      }

      // PS-12 FIX: Capture lastActivityDate BEFORE completeLesson updates it
      final previousLastActivityDate = ref
          .read(userProfileProvider)
          .value
          ?.lastActivityDate;

      // Lesson completion owns the level-up dialog; suppress the global
      // listener before XP changes so it cannot schedule a duplicate overlay.
      ref.read(levelUpEventProvider.notifier).suppressNextLevelUp();

      // Record completion and XP
      final completion = await ref
          .read(userProfileProvider.notifier)
          .completeLesson(widget.lesson.id, totalXp);

      final completedProfile = ref.read(userProfileProvider).valueOrNull;
      if (completedProfile == null ||
          !completedProfile.completedLessons.contains(widget.lesson.id)) {
        throw StateError('Lesson progress was not persisted.');
      }

      if (!completion.newlyCompleted) {
        ref.read(levelUpEventProvider.notifier).allowLevelUpEvents();
        if (mounted) {
          AppFeedback.showNeutralViaMessenger(
            ScaffoldMessenger.of(context),
            'Lesson already completed. No new rewards were added.',
          );
        }
        return;
      }
      progressCommitted = true;
      committedXp = totalXp;
      hasPostCommitWarning = completion.hasPostCommitWarning;

      // Quiz rewards are committed only after lesson progress is durable. This
      // keeps a failed profile save retryable without duplicating gem rewards.
      final quiz = widget.lesson.quiz;
      if (quiz != null) {
        final isPerfect = _correctAnswers == quiz.questions.length;
        try {
          final quizRewardSaved = await ref
              .read(userProfileProvider.notifier)
              .awardQuizGems(isPerfect: isPerfect);
          hasPostCommitWarning = hasPostCommitWarning || !quizRewardSaved;
        } catch (e, st) {
          hasPostCommitWarning = true;
          logError(
            'Quiz reward failed after lesson progress saved: $e',
            stackTrace: st,
            tag: 'LessonScreen',
          );
        }
      }

      if (_levelBeforeLesson != null &&
          completedProfile.currentLevel <= _levelBeforeLesson!) {
        ref.read(levelUpEventProvider.notifier).allowLevelUpEvents();
      }

      // Auto-seed spaced repetition cards (non-critical)
      try {
        await ref
            .read(spacedRepetitionProvider.notifier)
            .autoSeedFromLesson(
              lessonId: widget.lesson.id,
              lessonSections: widget.lesson.sections,
              quizQuestions: widget.lesson.quiz?.questions,
            );
      } catch (e) {
        logError('Spaced repetition seeding failed: $e', tag: 'LessonScreen');
      }

      // Refresh review notifications if the user has opted into reminders.
      try {
        await NotificationScheduler.instance.scheduleReviewNotifications(ref);
      } catch (e) {
        logError('Notification scheduling failed: $e', tag: 'LessonScreen');
      }

      // Check achievements from profile state that has already been persisted.
      var unlockedAchievementCount = 0;
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        var achievementProfile = profile;
        final achievementChecker = ref.read(achievementCheckerProvider);
        final lessonQuiz = widget.lesson.quiz;
        final quizLen = lessonQuiz?.questions.length;
        final isPerfect = quizLen != null && _correctAnswers == quizLen;

        // PS-10 FIX: Increment persistent perfect-score counter
        if (isPerfect) {
          try {
            await ref
                .read(userProfileProvider.notifier)
                .incrementPerfectScoreCount();
            achievementProfile =
                ref.read(userProfileProvider).value ?? achievementProfile;
          } catch (e, st) {
            logError(
              'Perfect score count save failed: $e',
              stackTrace: st,
              tag: 'LessonScreen',
            );
          }
        }

        // PS-11 FIX: Use actual elapsed time
        final actualElapsedSeconds = _lessonStartTime != null
            ? DateTime.now().difference(_lessonStartTime!).inSeconds
            : widget.lesson.estimatedMinutes * 60;

        final todayKey = DateTime.now().toIso8601String().split('T')[0];
        final todayLessons = achievementProfile.completedLessons.where((id) {
          final progress = achievementProfile.lessonProgress[id];
          return progress != null &&
              progress.completedDate.toIso8601String().split('T')[0] ==
                  todayKey;
        }).length;

        try {
          final results = await achievementChecker.checkAfterLesson(
            lessonsCompleted: achievementProfile.completedLessons.length,
            currentStreak: achievementProfile.currentStreak,
            totalXp: achievementProfile.totalXp,
            perfectScores: achievementProfile.perfectScoreCount,
            lessonCompletedAt: DateTime.now(),
            lessonDuration: actualElapsedSeconds,
            lessonScore: quizLen != null
                ? (_correctAnswers * 100 ~/ quizLen)
                : 100,
            todayLessonsCompleted: todayLessons,
            completedLessonIds: achievementProfile.completedLessons,
            previousLastActivityDate: previousLastActivityDate,
            showCelebrations: false,
          );
          unlockedAchievementCount = results
              .where((result) => result.wasJustUnlocked)
              .length;
        } catch (e) {
          logError('Achievement check failed: $e', tag: 'LessonScreen');
        }
      }

      // P5-2: In-app review trigger
      final reviewProfile = ref.read(userProfileProvider).value;
      final quizForReview = widget.lesson.quiz;
      final quizLenForReview = quizForReview?.questions.length;
      final isPerfectForReview =
          quizLenForReview != null && _correctAnswers == quizLenForReview;
      final streakForReview = reviewProfile?.currentStreak ?? 0;
      if (isPerfectForReview || streakForReview >= 7) {
        unawaited(() async {
          await RateService.maybeShowReview(force: true);
        }());
      }

      if (mounted) {
        if (hasPostCommitWarning) {
          AppFeedback.showNeutralViaMessenger(
            ScaffoldMessenger.of(context),
            'Lesson saved, but some rewards or activity updates could not be completed.',
          );
        }
        AppHaptics.success();
        _showXpAnimation(
          totalXp,
          unlockedAchievementCount: unlockedAchievementCount,
        );
      }
    } catch (e, st) {
      ref.read(levelUpEventProvider.notifier).allowLevelUpEvents();
      logError(
        'Lesson completion error: $e',
        stackTrace: st,
        tag: 'LessonScreen',
      );
      if (mounted) {
        if (progressCommitted) {
          AppFeedback.showNeutralViaMessenger(
            ScaffoldMessenger.of(context),
            'Lesson saved, but some rewards or activity updates could not be completed.',
          );
          AppHaptics.success();
          _showXpAnimation(committedXp);
        } else {
          AppFeedback.showError(
            context,
            'Couldn\'t save your progress. Try again in a moment.',
            onRetry: () => _completeLesson(bonusXp: bonusXp),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isCompletingLesson = false);
      }
    }
  }
}
