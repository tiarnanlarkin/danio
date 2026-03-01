/// Shimmer Glow Effect
/// Adds a shimmering gradient sweep to newly-unlocked achievements.
library;

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Wraps a child widget with a repeating shimmer/glow sweep effect.
///
/// The shimmer is a diagonal gradient that sweeps across the card
/// in a 2-second loop. Respects `disableAnimations` for accessibility.
class ShimmerGlow extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final Duration duration;

  const ShimmerGlow({
    super.key,
    required this.child,
    this.glowColor,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<ShimmerGlow> createState() => _ShimmerGlowState();
}

class _ShimmerGlowState extends State<ShimmerGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) return widget.child;

    final color = widget.glowColor ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Positioned.fill(
              child: ClipRRect(
                borderRadius: AppRadius.mediumRadius,
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(-1.0 + 3.0 * _controller.value, -0.3),
                      end: Alignment(
                          -1.0 + 3.0 * _controller.value + 0.6, 0.3),
                      colors: [
                        Colors.transparent,
                        color.withAlpha(40),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
