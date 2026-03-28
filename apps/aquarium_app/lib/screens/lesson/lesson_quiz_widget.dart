import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/learning.dart';
import '../../models/user_profile.dart' show ExperienceLevel;
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/quiz/quiz_answer_option.dart';

/// Renders a single quiz question with answer options, hint support, and
/// the "Check Answer" / "Next Question" / "See Results" bottom action.
///
/// Callbacks are used for all state mutations so the parent
/// [_LessonScreenState] remains the single source of truth.
class LessonQuizWidget extends ConsumerWidget {
  final Lesson lesson;
  final bool isPracticeMode;
  final int currentQuizQuestion;
  final int correctAnswers;
  final int? selectedAnswer;
  final bool answered;
  final bool showHint;

  /// Called when the user selects an answer option (before checking).
  final ValueChanged<int> onSelectAnswer;

  /// Called when the user taps "Check Answer" or advances through the quiz.
  /// [answer] is the selected answer index, [isLastQuestion] indicates if
  /// this is the final question.
  final Future<void> Function({
    required int selectedAnswer,
    required bool isCorrect,
    required bool isLastQuestion,
  }) onCheckOrAdvance;

  /// Called to toggle the hint panel.
  final VoidCallback onShowHint;

  const LessonQuizWidget({
    super.key,
    required this.lesson,
    required this.isPracticeMode,
    required this.currentQuizQuestion,
    required this.correctAnswers,
    required this.selectedAnswer,
    required this.answered,
    required this.showHint,
    required this.onSelectAnswer,
    required this.onCheckOrAdvance,
    required this.onShowHint,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiz = lesson.quiz;
    if (quiz == null || quiz.questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz_outlined, size: 48, color: context.textHint),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Quiz coming soon!',
                style: AppTypography.titleMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = quiz.questions[currentQuizQuestion];

    // Personalisation: show hint for beginner users (not in practice mode)
    final profile = ref.watch(
      userProfileProvider.select((p) => p.value?.experienceLevel),
    );
    final isBeginner = profile == ExperienceLevel.beginner;
    final hintExtraItems = (isBeginner && !answered && !showHint) ? 1 : 0;

    return Column(
      children: [
        // Progress
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Question ${currentQuizQuestion + 1} of ${quiz.questions.length}',
                      style: AppTypography.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '$correctAnswers correct',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                label:
                    'Quiz progress: question ${currentQuizQuestion + 1} of ${quiz.questions.length}',
                child: ClipRRect(
                  borderRadius: AppRadius.xsRadius,
                  child: LinearProgressIndicator(
                    value: (currentQuizQuestion + 1) / quiz.questions.length,
                    backgroundColor: context.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                    semanticsLabel: '', // Exclude default semantics (handled by wrapper)
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg2),
            itemCount:
                3 +
                hintExtraItems +
                question.options.length +
                (answered && question.explanation != null
                    ? 2
                    : 0) + // spacing + explanation
                (showHint && !answered ? 1 : 0), // hint text
            itemBuilder: (context, index) {
              // Spacing at top
              if (index == 0) {
                return const SizedBox(height: AppSpacing.lg2);
              }

              // Question text
              if (index == 1) {
                return Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    question.question,
                    style: AppTypography.headlineMedium,
                  ),
                );
              }

              // Spacing after question
              if (index == 2) {
                return const SizedBox(height: AppSpacing.lg);
              }

              // Hint button (beginners only, before options)
              const hintButtonIndex = 3;
              const hintTextIndex = hintButtonIndex + 1;
              if (hintExtraItems > 0 && index == hintButtonIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      button: true,
                      label: 'Show hint',
                      child: ActionChip(
                        avatar:
                            const Icon(Icons.lightbulb_outline, size: 16),
                        label: const Text('Need a hint?'),
                        onPressed: onShowHint,
                      ),
                    ),
                  ),
                );
              }
              if (showHint &&
                  !answered &&
                  index == hintTextIndex &&
                  hintExtraItems > 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppOverlays.info10,
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(color: AppOverlays.info30),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Look for keywords in the question — the correct answer often relates directly to the lesson content you just read.',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Answer options — offset by hint items
              final optionsOffset =
                  3 +
                  hintExtraItems +
                  (showHint && !answered ? 1 : 0);
              if (index >= optionsOffset &&
                  index < optionsOffset + question.options.length) {
                final optionIndex = index - optionsOffset;
                final option = question.options[optionIndex];
                final isSelected = selectedAnswer == optionIndex;
                final isCorrect = optionIndex == question.correctIndex;

                return QuizAnswerOption(
                  key: ValueKey('quiz_option_${currentQuizQuestion}_$optionIndex'),
                  optionIndex: optionIndex,
                  option: option,
                  isSelected: isSelected,
                  isCorrect: isCorrect,
                  answered: answered,
                  onTap: () => onSelectAnswer(optionIndex),
                );
              }

              // Explanation (after answering)
              // When answered, hint items are gone (hintExtraItems=0, showHint
              // gated on !answered) so optionsOffset is always 3 in this branch.
              if (answered && question.explanation != null) {
                // Spacing before explanation
                if (index == 3 + question.options.length) {
                  return const SizedBox(height: AppSpacing.md);
                }

                // Explanation content
                if (index == 4 + question.options.length) {
                  return Semantics(
                    label: 'Explanation: ${question.explanation!}',
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppOverlays.info10,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: context.textSecondary,
                            semanticLabel: 'Explanation',
                          ),
                          const SizedBox(width: AppSpacing.sm2),
                          Expanded(
                            child: Text(
                              question.explanation!,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                        ],
                      ),
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
          padding: const EdgeInsets.all(AppSpacing.lg2),
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
            child: AppButton(
              onPressed: selectedAnswer == null
                  ? null
                  : () async {
                      final question =
                          quiz.questions[currentQuizQuestion];
                      final isCorrect =
                          selectedAnswer == question.correctIndex;
                      final isLastQuestion = currentQuizQuestion >=
                          quiz.questions.length - 1;

                      if (!answered) {
                        // Announce result to screen readers
                        SemanticsService.sendAnnouncement(
                          View.of(context),
                          isCorrect
                              ? 'Correct!'
                              : 'Incorrect. The correct answer is ${question.options[question.correctIndex]}.',
                          TextDirection.ltr,
                        );
                      }

                      await onCheckOrAdvance(
                        selectedAnswer: selectedAnswer!,
                        isCorrect: isCorrect,
                        isLastQuestion: isLastQuestion,
                      );
                    },
              label: !answered
                  ? 'Check Answer'
                  : currentQuizQuestion < quiz.questions.length - 1
                  ? 'Next Question'
                  : 'See Results',
              isFullWidth: true,
              size: AppButtonSize.large,
            ),
          ),
        ),
      ],
    );
  }
}
