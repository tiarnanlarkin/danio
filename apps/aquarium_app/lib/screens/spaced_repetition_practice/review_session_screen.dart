import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/resolved_question.dart';
import '../../models/spaced_repetition.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/spaced_repetition_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/learning_visuals.dart';
import '../../utils/concept_display_names.dart';
import '../../utils/logger.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_dialog.dart';
import '../../widgets/core/bubble_loader.dart';
import '../../widgets/danio_snack_bar.dart';
import '../../widgets/hearts_widgets.dart';
import 'widgets/matching_card_widget.dart';
import 'widgets/mc_card_widget.dart';

/// The active review session screen — shown while a session is in progress.
class ReviewSessionScreen extends ConsumerStatefulWidget {
  final ReviewSession session;

  const ReviewSessionScreen({super.key, required this.session});

  @override
  ConsumerState<ReviewSessionScreen> createState() =>
      _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen> {
  int _currentCardIndex = 0;
  DateTime? _questionStartTime;
  String? _errorMessage;
  bool _isSubmitting = false;
  bool _isFallbackAnswerRevealed = false;
  late ReviewSession _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _questionStartTime = DateTime.now();
  }

  ReviewCard get _currentCard => _session.cards[_currentCardIndex];

  @override
  Widget build(BuildContext context) {
    final resolvedQuestions = ref
        .read(spacedRepetitionProvider)
        .resolvedQuestions;
    final currentQuestion = _currentCardIndex < resolvedQuestions.length
        ? resolvedQuestions[_currentCardIndex]
        : null;

    final progress = (_currentCardIndex + 1) / _session.cards.length;
    final cardsReviewed = _session.results.length;
    final correctSoFar = _session.results.where((r) => r.correct).length;
    final accuracy = cardsReviewed > 0
        ? (correctSoFar / cardsReviewed * 100).round()
        : 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (!didPop) {
          final shouldPop = await _showExitDialog();
          if (shouldPop == true && mounted && context.mounted) {
            ref.read(spacedRepetitionProvider.notifier).abandonSession();
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Practice Session'),
          actions: [
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: Center(child: HeartIndicator(compact: true)),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Exit Session',
              onPressed: () async {
                final shouldExit = await _showExitDialog();
                if (!context.mounted) return;
                if (shouldExit == true && mounted) {
                  ref.read(spacedRepetitionProvider.notifier).abandonSession();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Enhanced progress bar with stats
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: AppOverlays.black5,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Card ${_currentCardIndex + 1} of ${_session.cards.length}',
                        style: AppTypography.labelLarge,
                      ),
                      Text(
                        '${(progress * 100).round()}% complete',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: AppRadius.xsRadius,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: context.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  if (cardsReviewed > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: AppIconSizes.xs,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '$correctSoFar correct',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(
                          Icons.cancel,
                          size: AppIconSizes.xs,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${cardsReviewed - correctSoFar} incorrect',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '($accuracy% accuracy)',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Question content
            if (currentQuestion is MultipleChoiceQuestion)
              _buildResolvedQuestionBody(
                McCardWidget(
                  question: currentQuestion,
                  onAnswered: (correct) => _recordAnswer(correct),
                  onNext: _nextCard,
                  isLastCard: _currentCardIndex >= _session.cards.length - 1,
                ),
              )
            else if (currentQuestion is MatchingPairsQuestion)
              _buildResolvedQuestionBody(
                MatchingCardWidget(
                  question: currentQuestion,
                  onCompleted: (score) => _recordAnswer(score >= 0.5),
                  onNext: _nextCard,
                  isLastCard: _currentCardIndex >= _session.cards.length - 1,
                ),
              )
            else
            // Fallback: old self-assess UI for cards without resolved questions
            ...[
              Expanded(child: _buildCardContent()),
              _buildAnswerButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResolvedQuestionBody(Widget child) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg2),
        child: child,
      ),
    );
  }

  Widget _buildCardContent() {
    final questionText = _currentCard.questionText?.trim();
    final hasQuestionText = questionText != null && questionText.isNotEmpty;
    final conceptTitle = _getQuestionText();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mastery indicator
          Row(
            children: [
              Icon(
                LearningVisuals.masteryIcon(_currentCard.masteryLevel),
                color: LearningVisuals.masteryColor(
                  context,
                  _currentCard.masteryLevel,
                ),
                size: AppIconSizes.md,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _currentCard.masteryLevel.displayName,
                style: AppTypography.labelLarge.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${(_currentCard.strength * 100).round()}%',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Question card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: context.surfaceVariant),
              boxShadow: [
                BoxShadow(
                  color: AppOverlays.black5,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review this concept:',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm2),
                Text(conceptTitle, style: AppTypography.headlineMedium),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAlpha10,
                    borderRadius: AppRadius.smallRadius,
                    border: Border.all(color: AppColors.primaryAlpha15),
                  ),
                  child: Text(
                    _isFallbackAnswerRevealed
                        ? hasQuestionText
                              ? questionText
                              : 'No saved answer text is available for this older review card. Use your memory of the lesson, and choose Forgot if you are unsure.'
                        : 'Recall the main care point for $conceptTitle. When you are ready, reveal the answer and rate yourself. If you are unsure, choose Forgot so Danio brings it back sooner.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm2),
              decoration: BoxDecoration(
                color: AppOverlays.error10,
                borderRadius: AppRadius.smallRadius,
              ),
              child: Text(
                _errorMessage!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerButtons() {
    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How well did you remember this?',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm2),
            if (_isSubmitting)
              const Column(
                children: [
                  BubbleLoader(),
                  SizedBox(height: AppSpacing.sm),
                  Text('Saving your answer...'),
                ],
              )
            else if (!_isFallbackAnswerRevealed)
              AppButton(
                onPressed: () {
                  setState(() => _isFallbackAnswerRevealed = true);
                },
                variant: AppButtonVariant.primary,
                label: 'Reveal answer',
                leadingIcon: Icons.visibility,
                isFullWidth: true,
                size: AppButtonSize.large,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      onPressed: () => _recordAnswer(false, autoAdvance: true),
                      variant: AppButtonVariant.destructive,
                      label: 'Forgot',
                      leadingIcon: Icons.close,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm2),
                  Expanded(
                    child: AppButton(
                      onPressed: () => _recordAnswer(true, autoAdvance: true),
                      variant: AppButtonVariant.primary,
                      label: 'Remembered',
                      leadingIcon: Icons.check,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getQuestionText() => conceptDisplayName(_currentCard.conceptId);

  Future<void> _recordAnswer(bool correct, {bool autoAdvance = false}) async {
    if (_questionStartTime == null || _isSubmitting) return;

    final timeSpent = DateTime.now().difference(_questionStartTime!);

    setState(() => _isSubmitting = true);

    try {
      final result = await ref
          .read(spacedRepetitionProvider.notifier)
          .recordSessionResult(
            cardId: _currentCard.id,
            correct: correct,
            timeSpent: timeSpent,
          );

      final latestSession = ref.read(spacedRepetitionProvider).currentSession;
      final isBoostActive = ref.read(xpBoostActiveProvider);
      await ref
          .read(userProfileProvider.notifier)
          .addXp(result.xpEarned, xpBoostActive: isBoostActive);

      if (mounted) {
        setState(() {
          _session = latestSession ?? _appendResult(result);
          _errorMessage = null;
        });
        if (autoAdvance) {
          _nextCard();
        }
      }
    } catch (e, st) {
      logError(
        'SpacedRepetitionScreen: record answer failed: $e',
        stackTrace: st,
        tag: 'SpacedRepetitionScreen',
      );
      if (mounted) {
        setState(() {
          _errorMessage =
              'Couldn\'t save your answer. Your progress is still tracked.';
        });

        DanioSnackBar.error(
          context,
          'Couldn\'t record that answer, try again',
          onRetry: () => _recordAnswer(correct, autoAdvance: autoAdvance),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  ReviewSession _appendResult(ReviewSessionResult result) {
    final results = [..._session.results, result];
    return ReviewSession(
      id: _session.id,
      startTime: _session.startTime,
      endTime: results.length == _session.cards.length
          ? DateTime.now()
          : _session.endTime,
      cards: _session.cards,
      results: results,
      mode: _session.mode,
    );
  }

  void _nextCard() {
    if (_currentCardIndex < _session.cards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _questionStartTime = DateTime.now();
        _errorMessage = null;
        _isFallbackAnswerRevealed = false;
      });
    } else {
      _completeSession();
    }
  }

  Future<void> _completeSession() async {
    await ref.read(spacedRepetitionProvider.notifier).completeSession();

    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final totalCards = _session.cards.length;
    final correctCards = _session.results.where((r) => r.correct).length;
    final incorrectCards = totalCards - correctCards;
    final accuracy = (_session.score * 100).round();
    final totalXp = _session.totalXp;

    showAppDialog<void>(
      context: context,
      title: 'Session complete',
      barrierDismissible: false,
      actions: [
        AppButton(
          label: 'Done',
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          variant: AppButtonVariant.primary,
          isFullWidth: true,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg2),
              decoration: BoxDecoration(
                color: accuracy >= 80
                    ? AppOverlays.success10
                    : accuracy >= 60
                    ? AppOverlays.warning10
                    : AppOverlays.error10,
                borderRadius: AppRadius.mediumRadius,
              ),
              child: Column(
                children: [
                  Text(
                    '$accuracy%',
                    style: AppTypography.headlineLarge.copyWith(
                      color: accuracy >= 80
                          ? AppColors.success
                          : accuracy >= 60
                          ? AppColors.warning
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Accuracy',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg2),
          _buildStatRow('Cards Reviewed', '$totalCards'),
          const SizedBox(height: AppSpacing.sm),
          _buildStatRow(
            'Correct',
            '$correctCards',
            iconColor: AppColors.success,
            icon: Icons.check_circle,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildStatRow(
            'Incorrect',
            '$incorrectCards',
            iconColor: AppColors.error,
            icon: Icons.cancel,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _buildStatRow(
            'XP Earned',
            '+$totalXp',
            iconColor: AppColors.accent,
            icon: Icons.star,
            valueStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor ?? context.textSecondary),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style:
              valueStyle ??
              AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<bool?> _showExitDialog() {
    final cardsReviewed = _session.results.length;
    final cardsRemaining = _session.cards.length - cardsReviewed;
    final navigator = Navigator.of(context);

    return showAppDialog<bool>(
      context: context,
      title: 'Exit Session?',
      icon: Icons.exit_to_app,
      iconColor: AppColors.warning,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your progress will be saved, but you\'ll need to start a new session to continue practicing.',
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.smallRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: AppIconSizes.xs,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.xs2),
                    Text(
                      'Cards reviewed: $cardsReviewed',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.pending,
                      size: AppIconSizes.xs,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs2),
                    Text(
                      'Cards remaining: $cardsRemaining',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Continue Session',
          onPressed: () => navigator.pop(false),
          variant: AppButtonVariant.text,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: 'Exit',
          onPressed: () => navigator.pop(true),
          variant: AppButtonVariant.destructive,
          isFullWidth: true,
        ),
      ],
    );
  }
}
