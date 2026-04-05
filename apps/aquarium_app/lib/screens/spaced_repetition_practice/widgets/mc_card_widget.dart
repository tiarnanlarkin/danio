/// Multiple-choice question card widget for spaced-repetition practice.
///
/// Displays a question with 4 tappable options. After the user selects an
/// answer, correct/incorrect feedback is shown and an explanation (if any)
/// is revealed.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:danio/models/resolved_question.dart';
import 'package:danio/theme/app_theme.dart';
import 'package:danio/widgets/core/app_button.dart';

/// Letters shown alongside each option.
const _optionLetters = ['A', 'B', 'C', 'D'];

/// A card that renders a [MultipleChoiceQuestion] with 4 tappable options.
///
/// After the user taps an option the card:
/// - highlights the correct answer in green
/// - highlights an incorrect selection in red
/// - greys out the remaining options
/// - reveals the explanation (if present)
/// - shows a "Next Card" or "Complete Session" button
class McCardWidget extends StatefulWidget {
  /// The question data to display.
  final MultipleChoiceQuestion question;

  /// Called when the user taps an option.
  ///
  /// The boolean indicates whether the selected answer was correct.
  final void Function(bool correct) onAnswered;

  /// Called when the user taps the "Next Card" / "Complete Session" button.
  final VoidCallback onNext;

  /// When `true` the bottom button reads "Complete Session" instead of
  /// "Next Card".
  final bool isLastCard;

  const McCardWidget({
    super.key,
    required this.question,
    required this.onAnswered,
    required this.onNext,
    this.isLastCard = false,
  });

  @override
  State<McCardWidget> createState() => _McCardWidgetState();
}

class _McCardWidgetState extends State<McCardWidget> {
  /// Index of the option the user tapped, or `null` if they haven't yet.
  int? selectedIndex;

  /// Convenience getter.
  bool get hasAnswered => selectedIndex != null;

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  void _handleOptionTap(int index) {
    if (hasAnswered) return;
    HapticFeedback.lightImpact();
    setState(() => selectedIndex = index);
    widget.onAnswered(index == widget.question.correctIndex);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Question text ──────────────────────────────────────────────
        Text(
          widget.question.questionText,
          style: AppTypography.headlineMedium.copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Option buttons ─────────────────────────────────────────────
        ...List.generate(widget.question.options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _OptionTile(
              letter: _optionLetters[index],
              text: widget.question.options[index],
              state: _optionState(index),
              onTap: () => _handleOptionTap(index),
            ),
          );
        }),

        // ── Explanation (shown after answering) ────────────────────────
        if (hasAnswered && widget.question.explanation != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Text(
              widget.question.explanation!,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textPrimary,
              ),
            ),
          ),
        ],

        // ── Next / Complete button (shown after answering) ─────────────
        if (hasAnswered) ...[
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: widget.isLastCard ? 'Complete Session' : 'Next Card',
            onPressed: widget.onNext,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  _OptionState _optionState(int index) {
    if (!hasAnswered) return _OptionState.neutral;
    if (index == widget.question.correctIndex) return _OptionState.correct;
    if (index == selectedIndex) return _OptionState.incorrect;
    return _OptionState.dimmed;
  }
}

// =============================================================================
// _OptionState — visual state for a single option tile
// =============================================================================

enum _OptionState { neutral, correct, incorrect, dimmed }

// =============================================================================
// _OptionTile — a single tappable answer option
// =============================================================================

class _OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = state == _OptionState.dimmed;

    return Semantics(
      button: true,
      enabled: state == _OptionState.neutral,
      label: '$letter: $text',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state == _OptionState.neutral ? onTap : null,
          borderRadius: AppRadius.mediumRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm2,
            ),
            decoration: BoxDecoration(
              color: _backgroundColor(context),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: _borderColor(context), width: 1.5),
            ),
            child: Row(
              children: [
                // Letter badge
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _badgeColor(context),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    letter,
                    style: AppTypography.labelLarge.copyWith(
                      color: _badgeTextColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm2),
                // Option text
                Expanded(
                  child: Text(
                    text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: disabled
                          ? context.textHint
                          : context.textPrimary,
                    ),
                  ),
                ),
                // Trailing icon for feedback
                if (state == _OptionState.correct)
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                if (state == _OptionState.incorrect)
                  Icon(Icons.cancel, color: AppColors.error, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Colour helpers
  // ---------------------------------------------------------------------------

  Color _backgroundColor(BuildContext context) {
    switch (state) {
      case _OptionState.neutral:
        return context.surfaceColor;
      case _OptionState.correct:
        return AppOverlays.success10;
      case _OptionState.incorrect:
        return AppOverlays.error10;
      case _OptionState.dimmed:
        return context.surfaceColor;
    }
  }

  Color _borderColor(BuildContext context) {
    switch (state) {
      case _OptionState.neutral:
        return context.borderColor;
      case _OptionState.correct:
        return AppColors.success;
      case _OptionState.incorrect:
        return AppColors.error;
      case _OptionState.dimmed:
        return context.borderColor;
    }
  }

  Color _badgeColor(BuildContext context) {
    switch (state) {
      case _OptionState.neutral:
        return context.surfaceVariant;
      case _OptionState.correct:
        return AppColors.success;
      case _OptionState.incorrect:
        return AppColors.error;
      case _OptionState.dimmed:
        return context.surfaceVariant;
    }
  }

  Color _badgeTextColor(BuildContext context) {
    switch (state) {
      case _OptionState.neutral:
        return context.textPrimary;
      case _OptionState.correct:
        return Colors.white;
      case _OptionState.incorrect:
        return Colors.white;
      case _OptionState.dimmed:
        return context.textHint;
    }
  }
}
