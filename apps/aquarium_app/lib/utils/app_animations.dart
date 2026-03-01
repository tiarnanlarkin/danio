import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Extension methods for common app-wide animations.
///
/// Usage:
/// ```dart
/// MyWidget().animateIn(index: 2)
/// AchievementCard().celebrateBounce()
/// TankImage().waterRipple()
/// Button().pulseGlow()
/// ```
extension AppAnimations on Widget {
  /// Standard staggered entrance animation for list items.
  ///
  /// Combines fade-in with subtle slide-up for a polished list feel.
  /// [index] controls the stagger delay (50ms per index).
  Widget animateIn({int index = 0}) => animate()
      .fadeIn(
        delay: Duration(milliseconds: 50 * index),
        duration: const Duration(milliseconds: 300),
      )
      .slideY(
        begin: 0.1,
        end: 0,
        delay: Duration(milliseconds: 50 * index),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );

  /// Celebration bounce for achievements and rewards.
  ///
  /// Uses elastic curve for a satisfying "pop" effect.
  Widget celebrateBounce() => animate()
      .scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        curve: Curves.elasticOut,
        duration: const Duration(milliseconds: 600),
      )
      .fadeIn(duration: const Duration(milliseconds: 200));

  /// Water ripple/shimmer effect for aquatic theming.
  ///
  /// Creates a continuous shimmer that repeats indefinitely.
  /// Perfect for tank backgrounds, water surfaces, loading states.
  Widget waterRipple() => animate(onPlay: (controller) => controller.repeat())
      .shimmer(
        duration: const Duration(seconds: 2),
        color: Colors.white24,
      );

  /// Attention-grabbing pulse glow effect.
  ///
  /// Subtle scale pulse that draws user attention to important elements.
  /// Repeats indefinitely with a smooth ease-in-out curve.
  Widget pulseGlow() => animate(onPlay: (controller) => controller.repeat(reverse: true))
      .scale(
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.05, 1.05),
        duration: AppDurations.long3,
        curve: Curves.easeInOut,
      );

  /// Gentle fade-in for simple transitions.
  Widget fadeInSimple({Duration duration = const Duration(milliseconds: 300)}) =>
      animate().fadeIn(duration: duration);

  /// Slide in from the right (for forward navigation feel).
  Widget slideInFromRight({Duration duration = const Duration(milliseconds: 300)}) =>
      animate()
          .fadeIn(duration: duration)
          .slideX(
            begin: 0.2,
            end: 0,
            duration: duration,
            curve: Curves.easeOutCubic,
          );

  /// Slide in from the left (for back navigation feel).
  Widget slideInFromLeft({Duration duration = const Duration(milliseconds: 300)}) =>
      animate()
          .fadeIn(duration: duration)
          .slideX(
            begin: -0.2,
            end: 0,
            duration: duration,
            curve: Curves.easeOutCubic,
          );

  /// Subtle float animation for ambient elements.
  ///
  /// Perfect for decorative elements, mascots, bubbles.
  Widget floatGently() => animate(onPlay: (controller) => controller.repeat(reverse: true))
      .moveY(
        begin: 0,
        end: -5,
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
      );

  /// Quick attention shake for errors or warnings.
  Widget errorShake() => animate()
      .shake(
        hz: 4,
        duration: const Duration(milliseconds: 400),
      );
}
