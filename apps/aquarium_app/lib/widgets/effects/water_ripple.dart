import 'package:flutter/material.dart';

/// A single animated water ripple effect that expands from a tap point
class WaterRipple extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;

  const WaterRipple({
    super.key,
    required this.position,
    required this.onComplete,
  });

  @override
  State<WaterRipple> createState() => _WaterRippleState();
}

class _WaterRippleState extends State<WaterRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RipplePainter(
            center: widget.position,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

/// Custom painter that draws expanding concentric ripple circles
class RipplePainter extends CustomPainter {
  final Offset center;
  final double progress;

  RipplePainter({required this.center, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha((0.3 * (1 - progress) * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw multiple expanding circles with staggered delays
    for (int i = 0; i < 3; i++) {
      final delay = i * 0.15;
      final adjustedProgress = (progress - delay).clamp(0.0, 1.0);
      if (adjustedProgress > 0) {
        final radius = adjustedProgress * 60;
        final opacity = 0.3 * (1 - adjustedProgress);
        canvas.drawCircle(
          center,
          radius,
          paint..color = Colors.white.withAlpha((opacity * 255).round()),
        );
      }
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
