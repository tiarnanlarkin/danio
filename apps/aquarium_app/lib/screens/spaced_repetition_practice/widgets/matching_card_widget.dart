import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:danio/models/resolved_question.dart';
import 'package:danio/theme/app_theme.dart';
import 'package:danio/widgets/core/app_button.dart';

/// A matching-pairs question widget for spaced-repetition practice sessions.
///
/// Displays two columns of items (concepts on the left, definitions on the
/// right) that the user must pair by tapping. Pairs are shuffled independently
/// so the user cannot simply match by position.
class MatchingCardWidget extends StatefulWidget {
  /// The matching-pairs question data.
  final MatchingPairsQuestion question;

  /// Called when all pairs have been matched. [score] is 0.0-1.0.
  final void Function(double score) onCompleted;

  /// Called when the user taps the "Next Card" / "Complete Session" button.
  final VoidCallback onNext;

  /// When true the final button reads "Complete Session" instead of "Next Card".
  final bool isLastCard;

  const MatchingCardWidget({
    super.key,
    required this.question,
    required this.onCompleted,
    required this.onNext,
    required this.isLastCard,
  });

  @override
  State<MatchingCardWidget> createState() => MatchingCardWidgetState();
}

@visibleForTesting
class MatchingCardWidgetState extends State<MatchingCardWidget> {
  /// Index into [leftOrder] that the user has selected, or null.
  int? selectedLeftIndex;

  /// Left items that have been correctly matched (indices into [leftOrder]).
  Set<int> matchedLeftIndices = {};

  /// Right items that have been correctly matched (indices into [rightOrder]).
  Set<int> matchedRightIndices = {};

  /// Right item to flash red for a wrong match (index into [rightOrder]).
  int? flashRedRightIndex;

  /// Number of incorrect match attempts.
  int mistakes = 0;

  /// Shuffled indices for the left column — values are pair indices.
  late List<int> leftOrder;

  /// Shuffled indices for the right column — values are pair indices.
  late List<int> rightOrder;

  Timer? _flashTimer;

  bool get isComplete => matchedLeftIndices.length == widget.question.pairs.length;

  @override
  void initState() {
    super.initState();
    _initOrders();
  }

  void _initOrders() {
    final count = widget.question.pairs.length;
    leftOrder = List<int>.generate(count, (i) => i)..shuffle();
    rightOrder = List<int>.generate(count, (i) => i)..shuffle();
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  // ─── Tap handlers ──────────────────────────────────────────────

  void _onLeftTap(int index) {
    if (isComplete) return;
    if (matchedLeftIndices.contains(index)) return;
    setState(() => selectedLeftIndex = index);
  }

  void _onRightTap(int index) {
    if (isComplete) return;
    if (matchedRightIndices.contains(index)) return;
    if (selectedLeftIndex == null) return;

    final leftPairIndex = leftOrder[selectedLeftIndex!];
    final rightPairIndex = rightOrder[index];

    if (leftPairIndex == rightPairIndex) {
      // Correct match.
      setState(() {
        matchedLeftIndices.add(selectedLeftIndex!);
        matchedRightIndices.add(index);
        selectedLeftIndex = null;
      });

      if (isComplete) {
        final score = math.max(
          0.0,
          (widget.question.pairs.length - mistakes) /
              widget.question.pairs.length,
        );
        widget.onCompleted(score);
      }
    } else {
      // Wrong match.
      setState(() {
        mistakes++;
        flashRedRightIndex = index;
      });
      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => flashRedRightIndex = null);
      });
    }
  }

  // ─── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Match the pairs',
          style: AppTypography.headlineMedium.copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Subtitle
        Text(
          'Tap a concept, then tap its match',
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Two columns side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column — concepts
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < leftOrder.length; i++)
                    _buildLeftItem(context, i),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Right column — definitions
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < rightOrder.length; i++)
                    _buildRightItem(context, i),
                ],
              ),
            ),
          ],
        ),

        // Completion section
        if (isComplete) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildCompletionSection(context),
        ],
      ],
    );
  }

  // ─── Item builders ─────────────────────────────────────────────

  Widget _buildLeftItem(BuildContext context, int index) {
    final pairIndex = leftOrder[index];
    final text = widget.question.pairs[pairIndex].left;
    final isMatched = matchedLeftIndices.contains(index);
    final isSelected = selectedLeftIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: _MatchItem(
        text: text,
        state: isMatched
            ? _MatchItemState.matched
            : isSelected
                ? _MatchItemState.selected
                : _MatchItemState.unselected,
        onTap: () => _onLeftTap(index),
      ),
    );
  }

  Widget _buildRightItem(BuildContext context, int index) {
    final pairIndex = rightOrder[index];
    final text = widget.question.pairs[pairIndex].right;
    final isMatched = matchedRightIndices.contains(index);
    final isFlashRed = flashRedRightIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: _MatchItem(
        text: text,
        state: isMatched
            ? _MatchItemState.matched
            : isFlashRed
                ? _MatchItemState.wrong
                : _MatchItemState.unselected,
        onTap: () => _onRightTap(index),
      ),
    );
  }

  Widget _buildCompletionSection(BuildContext context) {
    final score = math.max(
      0.0,
      (widget.question.pairs.length - mistakes) /
          widget.question.pairs.length,
    );
    final percent = (score * 100).round();

    return Column(
      children: [
        Text(
          'Score: $percent%',
          style: AppTypography.titleMedium.copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: widget.isLastCard ? 'Complete Session' : 'Next Card',
          onPressed: widget.onNext,
          isFullWidth: true,
        ),
      ],
    );
  }
}

// ─── Internal helpers ──────────────────────────────────────────────

enum _MatchItemState { unselected, selected, matched, wrong }

class _MatchItem extends StatelessWidget {
  final String text;
  final _MatchItemState state;
  final VoidCallback onTap;

  const _MatchItem({
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    Widget? trailing;

    switch (state) {
      case _MatchItemState.unselected:
        bgColor = context.surfaceColor;
        borderColor = context.borderColor;
      case _MatchItemState.selected:
        bgColor = AppColors.primaryAlpha10;
        borderColor = AppColors.primary;
      case _MatchItemState.matched:
        bgColor = AppOverlays.success10;
        borderColor = AppColors.success;
        trailing = const Icon(Icons.check, size: AppIconSizes.sm, color: AppColors.success);
      case _MatchItemState.wrong:
        bgColor = AppOverlays.error10;
        borderColor = AppColors.error;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: AppRadius.smallRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smallRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm2,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }
}
