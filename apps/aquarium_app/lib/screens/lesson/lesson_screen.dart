import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/learning.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/spaced_repetition_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../services/hearts_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/hearts_widgets.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_feedback.dart';
import '../../utils/haptic_feedback.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../utils/logger.dart';
import 'lesson_card_widget.dart';
import 'lesson_quiz_widget.dart';
import 'lesson_completion_flow.dart';
import 'lesson_hearts_modal.dart';
import '../../widgets/core/app_dialog.dart';

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
      maybeExplainHearts(
        context,
        ref,
        isPracticeMode: widget.isPracticeMode,
      );
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
                    horizontal: 8,
                    vertical: 4,
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
                      const Icon(
                        Icons.star,
                        size: AppIconSizes.xs,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        widget.isPracticeMode
                            ? '+${widget.lesson.xpReward ~/ 2} XP'
                            : 'up to +${widget.lesson.xpReward + (widget.lesson.quiz?.bonusXp ?? 0)} XP',
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

      // Handle hearts (only in non-practice mode)
      if (!widget.isPracticeMode && !isCorrect) {
        final heartsService = ref.read(heartsServiceProvider);
        final lostHeart = await heartsService.loseHeart();

        if (lostHeart && mounted) {
          setState(() {
            _showHeartAnimation = true;
            _heartGained = false;
          });

          // Check if out of hearts
          if (!heartsService.hasHeartsAvailable) {
            await Future.delayed(kQuizRevealDelay);
            if (mounted) {
              setState(() => _isHeartsModalVisible = true);
              try {
                final result = await showOutOfHeartsModal(context);
                if (result == 'practice' && mounted) {
                  setState(() => _isHeartsModalVisible = false);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(
                        lesson: widget.lesson,
                        pathTitle: widget.pathTitle,
                        isPracticeMode: true,
                      ),
                    ),
                  );
                } else if (mounted) {
                  _isExitingDueToHearts = true;
                  Navigator.of(context).pop();
                }
              } finally {
                if (mounted) {
                  setState(() => _isHeartsModalVisible = false);
                }
              }
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

  /// Show XP animation and check for level-up.
  void _showXpAnimation(int xpAmount) {
    if (!mounted) return;
    showLessonXpAnimation(
      context,
      ref,
      xpAmount,
      levelBeforeLesson: _levelBeforeLesson,
      onComplete: () {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showNextLessonOrPop(
                context,
                ref,
                widget.lesson,
                widget.pathTitle,
                widget.isPracticeMode,
              );
            }
          });
        }
      },
    );
  }

  Future<void> _completeLesson({int bonusXp = 0}) async {
    if (_isCompletingLesson) return;

    setState(() => _isCompletingLesson = true);

    try {
      final totalXp = widget.lesson.xpReward + bonusXp;

      // Handle practice mode rewards
      if (widget.isPracticeMode) {
        final practiceXp = totalXp ~/ 2;
        try {
          await ref
              .read(userProfileProvider.notifier)
              .reviewLesson(widget.lesson.id, practiceXp);
        } catch (e) {
          logError('LessonScreen: reviewLesson failed, falling back to addXp: $e', tag: 'LessonScreen');
          try {
            await ref.read(userProfileProvider.notifier).addXp(practiceXp);
          } catch (e) {
            logError('Error awarding practice XP: $e', tag: 'LessonScreen');
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
          final xpMsg = practiceXp > 0 ? ' +$practiceXp XP' : '';
          AppFeedback.showSuccess(
            context,
            gainedHeart
                ? 'Practice complete!$xpMsg +1 heart ❤️'
                : 'Practice complete!$xpMsg (hearts full)',
          );
          Navigator.of(context).pop();
        }
        return;
      }

      // Calculate gem rewards (non-practice mode only)
      final quiz = widget.lesson.quiz;
      if (quiz != null) {
        final isPerfect = _correctAnswers == quiz.questions.length;
        await ref
            .read(userProfileProvider.notifier)
            .awardQuizGems(isPerfect: isPerfect);
      }

      // PS-12 FIX: Capture lastActivityDate BEFORE completeLesson updates it
      final previousLastActivityDate = ref
          .read(userProfileProvider)
          .value
          ?.lastActivityDate;

      // Record completion and XP
      await ref
          .read(userProfileProvider.notifier)
          .completeLesson(widget.lesson.id, totalXp);

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

      // Schedule review notifications (non-critical)
      try {
        final srState = ref.read(spacedRepetitionProvider);
        final dueCount = srState.stats.dueCards;
        if (dueCount > 0) {
          final notificationService = NotificationService();
          await notificationService.scheduleReviewReminder(
            dueCardsCount: dueCount,
            time: const TimeOfDay(hour: 9, minute: 0),
          );
        }
      } catch (e) {
        logError('Notification scheduling failed: $e', tag: 'LessonScreen');
      }

      // Dionysus Day 3: onboarding achievement at 3rd lesson
      try {
        final currentProfile = ref.read(userProfileProvider).value;
        if (currentProfile != null) {
          final totalCompleted = currentProfile.completedLessons.length + 1;
          if (totalCompleted == 3) {
            final notificationService = NotificationService();
            await notificationService.showOnboardingAchievement();
          }
        }
      } catch (e) {
        logError('Onboarding achievement notification failed: $e',
            tag: 'LessonScreen');
      }

      // Check for achievements (fire-and-forget — see comment in original)
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        final achievementChecker = ref.read(achievementCheckerProvider);
        final lessonQuiz = widget.lesson.quiz;
        final quizLen = lessonQuiz?.questions.length;
        final isPerfect = quizLen != null && _correctAnswers == quizLen;

        // PS-10 FIX: Increment persistent perfect-score counter
        if (isPerfect) {
          unawaited(ref.read(userProfileProvider.notifier).incrementPerfectScoreCount());
        }

        // PS-11 FIX: Use actual elapsed time
        final actualElapsedSeconds = _lessonStartTime != null
            ? DateTime.now().difference(_lessonStartTime!).inSeconds
            : widget.lesson.estimatedMinutes * 60;

        final todayKey = DateTime.now().toIso8601String().split('T')[0];
        final todayLessons =
            profile.completedLessons.where((id) {
              final progress = profile.lessonProgress[id];
              return progress != null &&
                  progress.completedDate.toIso8601String().split('T')[0] ==
                      todayKey;
            }).length +
            1;

        final updatedPerfectScores = isPerfect
            ? profile.perfectScoreCount + 1
            : profile.perfectScoreCount;

        unawaited(() async {
          try {
            await achievementChecker.checkAfterLesson(
              lessonsCompleted: profile.completedLessons.length + 1,
              currentStreak: profile.currentStreak,
              totalXp: profile.totalXp,
              perfectScores: updatedPerfectScores,
              lessonCompletedAt: DateTime.now(),
              lessonDuration: actualElapsedSeconds,
              lessonScore: quizLen != null
                  ? (_correctAnswers * 100 ~/ quizLen)
                  : 100,
              todayLessonsCompleted: todayLessons,
              completedLessonIds: [
                ...profile.completedLessons,
                widget.lesson.id,
              ],
              previousLastActivityDate: previousLastActivityDate,
            );
          } catch (e) {
            logError('Achievement check failed: $e', tag: 'LessonScreen');
          }
        }());
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
          try {
            final prefs = await ref.read(sharedPreferencesProvider.future);
            final alreadyRequested =
                prefs.getBool('review_requested') ?? false;
            if (!alreadyRequested) {
              final inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                await inAppReview.requestReview();
                await prefs.setBool('review_requested', true);
              }
            }
          } catch (e) {
            logError('In-app review failed: $e', tag: 'LessonScreen');
          }
        }());
      }

      if (mounted) {
        AppHaptics.success();
        _showXpAnimation(totalXp);
      }
    } catch (e, st) {
      logError('Lesson completion error: $e',
          stackTrace: st, tag: 'LessonScreen');
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


