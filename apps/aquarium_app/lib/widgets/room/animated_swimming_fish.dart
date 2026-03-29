import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'fish_painter.dart';

/// Animated fish that swims smoothly across the tank.
///
/// Wraps [SoftFish] in a RepaintBoundary to prevent full-tree repaints on
/// every animation tick.
class AnimatedSwimmingFish extends StatefulWidget {
  final double size;
  final Color color;
  final double swimSpeed; // seconds for one swim cycle
  final double verticalBob; // how much to bob up/down
  final double startOffset; // 0-1, where in the animation to start
  final double tankWidth;
  final double tankHeight;
  final double baseTop; // base Y position (0-1 of tank height)

  const AnimatedSwimmingFish({
    super.key,
    required this.size,
    required this.color,
    required this.tankWidth,
    required this.tankHeight,
    this.swimSpeed = 8.0,
    this.verticalBob = 15.0,
    this.startOffset = 0.0,
    this.baseTop = 0.3,
  });

  @override
  State<AnimatedSwimmingFish> createState() => _AnimatedSwimmingFishState();
}

class _AnimatedSwimmingFishState extends State<AnimatedSwimmingFish>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swimAnimation;
  late Animation<double> _bobAnimation;
  bool _facingRight = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 8000), // updated in didChangeDependencies
      vsync: this,
    );

    // Swim horizontally across tank
    _swimAnimation = Tween<double>(
      begin: -0.1,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Gentle vertical bobbing
    _bobAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standardSine),
    );

    // Use repeat(reverse: true) for native ping-pong instead of manual
    // forward()/reverse() status listeners. The manual approach caused
    // stack overflow on relaunch when reduce-motion set duration to 16ms,
    // allowing the animation to complete within a single frame and
    // recurse infinitely via status callbacks.
    _controller.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableMotion = MediaQuery.of(context).disableAnimations;
    // When motion is reduced, use a very long duration so the fish barely
    // moves. Must not be Duration.zero to avoid internal Flutter assertions.
    final targetDuration = disableMotion
        ? const Duration(minutes: 5)
        : Duration(milliseconds: (widget.swimSpeed * 1000).toInt());
    if (_controller.duration != targetDuration) {
      _controller.duration = targetDuration;
    }
  }

  // Track the previous value to detect direction changes for flip.
  double _previousValue = 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;

        // Detect direction change for fish flip: when the animation
        // value was increasing and now decreases (or vice versa), flip.
        if (value >= _previousValue && _previousValue > 0.9) {
          _facingRight = false; // swimming left (reverse phase)
        } else if (value <= _previousValue && _previousValue < 0.1) {
          _facingRight = true; // swimming right (forward phase)
        }
        _previousValue = value;

        // R-088: Guard against non-finite values — can occur when tankWidth/
        // tankHeight are zero (widget not yet laid out) or when the animation
        // controller produces NaN/Infinity in reduced-motion edge cases.
        final rawSwimX = _swimAnimation.value * widget.tankWidth;
        final rawBobY = _bobAnimation.value * widget.verticalBob;
        if (!rawSwimX.isFinite || !rawBobY.isFinite) return const SizedBox.shrink();
        final swimX = rawSwimX;
        final bobY = rawBobY;
        final rawBaseY = widget.baseTop * widget.tankHeight;

        // BUG-08: clamp fish position to stay within tank glass bounds
        const glassBorder = 4.0;
        final sandBoundary = widget.tankHeight * 0.78;
        final clampedTop = (rawBaseY + bobY).clamp(
          glassBorder,
          sandBoundary - widget.size,
        );
        // Clamp X to keep fish within tank walls
        final clampedLeft = (swimX - widget.size / 2).clamp(
          glassBorder,
          widget.tankWidth - widget.size - glassBorder,
        );

        return Positioned(
          left: clampedLeft,
          top: clampedTop,
          child: RepaintBoundary(
            child: Transform.scale(
              scaleX: _facingRight ? 1 : -1,
              child: SoftFish(size: widget.size, color: widget.color),
            ),
          ),
        );
      },
    );
  }
}
