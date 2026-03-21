import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// An animated number counter that smoothly transitions between values.
///
/// Perfect for displaying XP, gems, scores, or any numeric value that changes.
/// The animation creates a satisfying "counting up" effect.
///
/// Example:
/// ```dart
/// AnimatedCounter(
///   value: 1250,
///   prefix: '+',
///   style: AppTypography.headlineMedium,
/// )
/// ```
class AnimatedCounter extends StatefulWidget {
  /// The current value to display
  final int value;

  /// Text style for the number
  final TextStyle? style;

  /// Optional prefix (e.g., '+', '$')
  final String? prefix;

  /// Optional suffix (e.g., 'XP', 'pts')
  final String? suffix;

  /// Duration of the counting animation
  final Duration duration;

  /// Animation curve
  final Curve curve;

  /// Whether to format with thousand separators
  final bool formatNumber;

  /// Optional color override
  final Color? color;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix,
    this.suffix,
    this.duration = AppDurations.long3,
    this.curve = AppCurves.emphasized,
    this.formatNumber = true,
    this.color,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;
  bool _disableMotion = false;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.value.toDouble(),
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _controller.duration = _disableMotion ? Duration.zero : widget.duration;
      _controller.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newValue = MediaQuery.of(context).disableAnimations;
    if (newValue != _disableMotion) {
      _disableMotion = newValue;
      _controller.duration = _disableMotion ? Duration.zero : widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    if (!widget.formatNumber) return number.toString();

    final str = number.abs().toString();
    final result = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result.write(',');
      }
      result.write(str[i]);
      count++;
    }

    final formatted = result.toString().split('').reversed.join();
    return number < 0 ? '-$formatted' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (widget.style ?? AppTypography.bodyLarge).copyWith(
      color: widget.color,
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = _animation.value.round();
        final displayValue = _formatNumber(currentValue);

        return Text(
          '${widget.prefix ?? ''}$displayValue${widget.suffix ?? ''}',
          style: effectiveStyle,
        );
      },
    );
  }
}

/// A gem counter with icon and animated value
class GemCounter extends StatelessWidget {
  final int value;
  final bool compact;
  final bool animate;

  const GemCounter({
    super.key,
    required this.value,
    this.compact = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('💎', style: TextStyle(fontSize: compact ? 16 : 20)),
        SizedBox(width: compact ? 4 : 6),
        animate
            ? AnimatedCounter(
                value: value,
                style: compact
                    ? AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                formatNumber: true,
              )
            : Text(
                value.toString(),
                style: compact
                    ? AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
              ),
      ],
    );
  }
}

/// An XP counter with animated value and optional level indicator
class XpCounter extends StatelessWidget {
  final int currentXp;
  final int? xpToNextLevel;
  final bool showProgress;
  final bool compact;

  const XpCounter({
    super.key,
    required this.currentXp,
    this.xpToNextLevel,
    this.showProgress = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(compact ? 4 : 6),
          decoration: BoxDecoration(
            color: AppColors.xpAlpha20,
            shape: BoxShape.circle,
          ),
          child: Text('⭐', style: TextStyle(fontSize: compact ? 12 : 16)),
        ),
        SizedBox(width: compact ? 6 : 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCounter(
              value: currentXp,
              suffix: ' XP',
              style: compact
                  ? AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  : AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              color: AppColors.xp,
            ),
            if (showProgress && xpToNextLevel != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${xpToNextLevel! - currentXp} to next level',
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
