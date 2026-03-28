import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// An animated quiz answer option.
///
/// When [isCorrect] becomes true after [answered], the option performs a brief
/// scale bounce (1.0 → 1.05 → 1.0 over 300ms) and the checkmark fades in.
/// Respects [MediaQuery.disableAnimations].
class QuizAnswerOption extends StatefulWidget {
  final int optionIndex;
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool answered;
  final VoidCallback? onTap;

  const QuizAnswerOption({
    super.key,
    required this.optionIndex,
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.answered,
    this.onTap,
  });

  @override
  State<QuizAnswerOption> createState() => _QuizAnswerOptionState();
}

class _QuizAnswerOptionState extends State<QuizAnswerOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scale;
  late Animation<double> _checkFade;

  bool _bouncePlayed = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_bounceController);

    _checkFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(QuizAnswerOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Play bounce once when the question is answered AND this is the correct option
    if (!_bouncePlayed &&
        widget.answered &&
        widget.isCorrect &&
        !oldWidget.answered) {
      _bouncePlayed = true;
      final reduceMotion = MediaQuery.of(context).disableAnimations;
      if (!reduceMotion) {
        _bounceController.forward(from: 0.0);
      }
    }
    // Reset for next question
    if (!widget.answered && oldWidget.answered) {
      _bouncePlayed = false;
      _bounceController.reset();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isCorrect = widget.isCorrect;
    final answered = widget.answered;
    final optionIndex = widget.optionIndex;

    Color? bgColor;
    Color? borderColor;
    IconData? icon;

    if (answered) {
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

    Widget cardContent = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor ?? context.surfaceColor,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: borderColor ?? context.surfaceVariant,
          width: borderColor != null ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected && !answered
                  ? AppColors.primary
                  : context.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: icon != null
                  ? (answered && isCorrect
                      ? AnimatedBuilder(
                          animation: _checkFade,
                          builder: (context, child) => Opacity(
                            opacity: _checkFade.value.clamp(0.0, 1.0),
                            child: child,
                          ),
                          child: Icon(
                            icon,
                            size: AppIconSizes.sm,
                            color: AppColors.success,
                          ),
                        )
                      : Icon(
                          icon,
                          size: AppIconSizes.sm,
                          color: AppColors.error,
                        ))
                  : Text(
                      String.fromCharCode(65 + optionIndex),
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected && !answered
                            ? AppColors.onPrimary
                            : context.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Text(
              widget.option,
              style: AppTypography.bodyLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
          ),
        ],
      ),
    );

    // Wrap correct answer in scale bounce
    if (answered && isCorrect) {
      cardContent = AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: cardContent,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm2),
      child: Semantics(
        button: true,
        label: 'Option ${String.fromCharCode(65 + optionIndex)}: ${widget.option}',
        selected: isSelected,
        child: GestureDetector(
          onTap: answered ? null : widget.onTap,
          child: cardContent,
        ),
      ),
    );
  }
}
