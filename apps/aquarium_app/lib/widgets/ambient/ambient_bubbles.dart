import 'package:flutter/material.dart';
import 'package:floating_bubbles/floating_bubbles.dart';

/// Animated floating bubbles overlay for tank scenes.
/// Uses the floating_bubbles package for smooth, repeating bubble animations.
class AmbientBubbles extends StatelessWidget {
  final int bubbleCount;
  
  const AmbientBubbles({super.key, this.bubbleCount = 20});
  
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: FloatingBubbles.alwaysRepeating(
          noOfBubbles: bubbleCount,
          colorsOfBubbles: [
            AppOverlays.white30,
            Colors.lightBlue.withOpacity(0.2),
            Colors.cyan.withOpacity(0.15),
          ],
          sizeFactor: 0.12,
          speed: BubbleSpeed.slow,
          paintingStyle: PaintingStyle.fill,
        ),
      ),
    );
  }
}

/// Smaller bubble overlay for confined areas or subtle effects.
class AmbientBubblesSubtle extends StatelessWidget {
  final int bubbleCount;
  
  const AmbientBubblesSubtle({super.key, this.bubbleCount = 10});
  
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: FloatingBubbles.alwaysRepeating(
          noOfBubbles: bubbleCount,
          colorsOfBubbles: [
            AppOverlays.white20,
            Colors.lightBlue.withOpacity(0.15),
          ],
          sizeFactor: 0.08,
          speed: BubbleSpeed.slow,
          paintingStyle: PaintingStyle.fill,
        ),
      ),
    );
  }
}
