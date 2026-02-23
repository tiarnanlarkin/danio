import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

/// An aquarium-themed loading indicator with a swimming fish.
/// 
/// Creates a visual effect of a fish swimming back and forth
/// with a subtle wave motion.
/// 
/// Example:
/// ```dart
/// FishLoader()  // Default
/// FishLoader.small()  // Compact version
/// FishLoader(showBubbles: true)  // With trailing bubbles
/// ```
class FishLoader extends StatelessWidget {
  /// Overall size of the loader
  final double size;
  
  /// Fish color
  final Color? color;
  
  /// Whether to show trailing bubbles
  final bool showBubbles;
  
  /// Optional message below the loader
  final String? message;

  const FishLoader({
    super.key,
    this.size = 48,
    this.color,
    this.showBubbles = false,
    this.message,
  });

  /// Compact fish loader for inline use
  const FishLoader.small({
    Key? key,
    Color? color,
  }) : this(
    key: key,
    size: AppIconSizes.md,
    color: color,
    showBubbles: false,
  );

  /// Large fish loader with bubbles
  const FishLoader.large({
    Key? key,
    String? message,
    Color? color,
  }) : this(
    key: key,
    size: AppIconSizes.xxl,
    showBubbles: true,
    message: message,
    color: color,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fishColor = color ?? AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size * 2.5,
          height: size * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Trailing bubbles
              if (showBubbles) ...[
                Positioned(
                  left: size * 0.3,
                  child: _SmallBubble(color: fishColor, delay: 0.ms),
                ),
                Positioned(
                  left: size * 0.5,
                  top: size * 0.2,
                  child: _SmallBubble(color: fishColor, delay: 200.ms),
                ),
                Positioned(
                  left: size * 0.1,
                  bottom: size * 0.3,
                  child: _SmallBubble(color: fishColor, delay: 400.ms),
                ),
              ],
              // Swimming fish
              _SwimmingFish(size: size, color: fishColor),
            ],
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _SwimmingFish extends StatelessWidget {
  final double size;
  final Color color;

  const _SwimmingFish({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.set_meal, // Fish icon
      size: size,
      color: color,
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        // Swim back and forth
        .moveX(
          begin: -size * 0.5,
          end: size * 0.5,
          duration: 1500.ms,
          curve: AppCurves.standard,
        )
        // Subtle wave motion (up/down)
        .then()
        .moveY(
          begin: 0,
          end: -size * 0.15,
          duration: 750.ms,
          curve: AppCurves.standard,
        )
        .then()
        .moveY(
          begin: -size * 0.15,
          end: 0,
          duration: 750.ms,
          curve: AppCurves.standard,
        )
        // Flip when changing direction
        .animate(onPlay: (controller) => controller.repeat())
        .flipH(
          begin: 0,
          end: 1,
          duration: 3000.ms,
          curve: const _FlipCurve(),
        );
  }
}

/// Curve that stays at 0 for half, then jumps to 1
class _FlipCurve extends Curve {
  const _FlipCurve();
  
  @override
  double transform(double t) {
    return t < 0.5 ? 0.0 : 1.0;
  }
}

class _SmallBubble extends StatelessWidget {
  final Color color;
  final Duration delay;

  const _SmallBubble({
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(102),
        border: Border.all(
          color: color.withAlpha(153),
          width: 0.5,
        ),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
          delay: delay,
        )
        .fadeIn(duration: 200.ms)
        .then()
        .moveY(
          begin: 0,
          end: -20,
          duration: 1000.ms,
          curve: AppCurves.standardDecelerate,
        )
        .fadeOut(
          begin: 0.6,
          duration: 400.ms,
          delay: 600.ms,
        );
  }
}

/// A centered fish loader for full-screen loading states.
class FishLoadingScreen extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const FishLoadingScreen({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      color: backgroundColor ?? (isDark ? AppColors.backgroundDark : AppColors.background),
      child: Center(
        child: FishLoader.large(message: message),
      ),
    );
  }
}
