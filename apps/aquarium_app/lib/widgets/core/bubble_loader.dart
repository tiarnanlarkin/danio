import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

/// An aquarium-themed loading indicator with rising bubbles.
///
/// Creates a visual effect of multiple bubbles rising and fading,
/// matching the aquatic theme of the app.
///
/// Example:
/// ```dart
/// BubbleLoader()  // Default size
/// BubbleLoader.small()  // Compact version
/// BubbleLoader(size: 80, bubbleCount: 8)  // Custom
/// ```
class BubbleLoader extends StatefulWidget {
  /// Overall size of the loader
  final double size;

  /// Number of bubbles
  final int bubbleCount;

  /// Primary bubble color
  final Color? color;

  /// Optional message below the loader
  final String? message;

  const BubbleLoader({
    super.key,
    this.size = 60,
    this.bubbleCount = 5,
    this.color,
    this.message,
  });

  /// Compact bubble loader for inline use
  const BubbleLoader.small({Key? key, Color? color})
    : this(key: key, size: 32, bubbleCount: 3, color: color);

  /// Large bubble loader for full-screen loading
  const BubbleLoader.large({Key? key, String? message, Color? color})
    : this(key: key, size: 100, bubbleCount: 7, message: message, color: color);

  @override
  State<BubbleLoader> createState() => _BubbleLoaderState();
}

class _BubbleLoaderState extends State<BubbleLoader> {
  late final List<_BubbleData> _bubbles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bubbles = List.generate(widget.bubbleCount, (index) {
      return _BubbleData(
        x: _random.nextDouble() * 0.8 + 0.1, // 10-90% horizontal position
        size: _random.nextDouble() * 0.4 + 0.3, // 30-70% of max bubble size
        delay: Duration(milliseconds: _random.nextInt(800)),
        duration: Duration(milliseconds: 1200 + _random.nextInt(600)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.color ?? AppColors.accent;

    return Semantics(
      liveRegion: true,
      label: widget.message ?? 'Loading',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              children: _bubbles.map((bubble) {
                final bubbleSize = widget.size * 0.2 * bubble.size;

                return Positioned(
                  left: bubble.x * widget.size - bubbleSize / 2,
                  bottom: 0,
                  child: _Bubble(
                    size: bubbleSize,
                    color: bubbleColor,
                    delay: bubble.delay,
                    duration: bubble.duration,
                    riseHeight: widget.size,
                  ),
                );
              }).toList(),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.message!,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _BubbleData {
  final double x;
  final double size;
  final Duration delay;
  final Duration duration;

  _BubbleData({
    required this.x,
    required this.size,
    required this.delay,
    required this.duration,
  });
}

class _Bubble extends StatelessWidget {
  final double size;
  final Color color;
  final Duration delay;
  final Duration duration;
  final double riseHeight;

  const _Bubble({
    required this.size,
    required this.color,
    required this.delay,
    required this.duration,
    required this.riseHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withAlpha(204), color.withAlpha(102)],
              center: const Alignment(-0.3, -0.3),
            ),
            border: Border.all(color: color.withAlpha(153), width: 1),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(), delay: delay)
        .fadeIn(duration: 200.ms)
        .then()
        .moveY(
          begin: 0,
          end: -riseHeight * 0.9,
          duration: duration,
          curve: AppCurves.standardDecelerate,
        )
        .fadeOut(begin: 0.8, duration: duration * 0.3, delay: duration * 0.7)
        .scaleXY(
          begin: 1.0,
          end: 0.6,
          duration: duration,
          curve: AppCurves.standardAccelerate,
        );
  }
}

/// A centered bubble loader for full-screen loading states.
class BubbleLoadingScreen extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const BubbleLoadingScreen({super.key, this.message, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color:
          backgroundColor ??
          (isDark ? AppColors.backgroundDark : AppColors.background),
      child: Center(child: BubbleLoader.large(message: message)),
    );
  }
}
