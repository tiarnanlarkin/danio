import 'package:flutter/material.dart';
import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reduced_motion_provider.dart';
import '../../theme/app_theme.dart';

/// Animated floating bubbles overlay for tank scenes.
/// Uses the floating_bubbles package for smooth, repeating bubble animations.
/// Respects reduced motion preferences — returns SizedBox.shrink() when
/// system or user prefers reduced motion.
class AmbientBubbles extends ConsumerWidget {
  final int bubbleCount;

  const AmbientBubbles({super.key, this.bubbleCount = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableDecorative = ref.watch(
      reducedMotionProvider.select((s) => s.disableDecorativeAnimations),
    );
    if (disableDecorative ||
        MediaQuery.of(context).disableAnimations) {
      return const SizedBox.shrink();
    }

    return ExcludeSemantics(
      child: Positioned.fill(
        child: RepaintBoundary(
          child: IgnorePointer(
            child: FloatingBubbles.alwaysRepeating(
              noOfBubbles: bubbleCount,
              colorsOfBubbles: [
                AppOverlays.white30,
                AppOverlays.lightBlue20,
                AppOverlays.cyan15,
              ],
              sizeFactor: 0.12,
              speed: BubbleSpeed.slow,
              paintingStyle: PaintingStyle.fill,
            ),
          ),
        ),
      ),
    );
  }
}

/// Smaller bubble overlay for confined areas or subtle effects.
/// Respects reduced motion preferences.
class AmbientBubblesSubtle extends ConsumerWidget {
  final int bubbleCount;

  const AmbientBubblesSubtle({super.key, this.bubbleCount = 10});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableDecorative = ref.watch(
      reducedMotionProvider.select((s) => s.disableDecorativeAnimations),
    );
    if (disableDecorative ||
        MediaQuery.of(context).disableAnimations) {
      return const SizedBox.shrink();
    }

    // RepaintBoundary lives INSIDE Positioned.fill so that:
    // (a) Positioned.fill is a direct Stack child (gets StackParentData correctly),
    // (b) the expensive bubble animation is still isolated for repaint perf.
    // DO NOT wrap this widget externally in RepaintBoundary — Positioned.fill
    // cannot find a Stack ancestor through a RepaintBoundary.
    return ExcludeSemantics(
      child: Positioned.fill(
        child: RepaintBoundary(
          child: IgnorePointer(
            child: FloatingBubbles.alwaysRepeating(
              noOfBubbles: bubbleCount,
              colorsOfBubbles: [AppOverlays.white20, AppOverlays.lightBlue15],
              sizeFactor: 0.08,
              speed: BubbleSpeed.slow,
              paintingStyle: PaintingStyle.fill,
            ),
          ),
        ),
      ),
    );
  }
}
