/// Confetti Overlay Widget
/// Shows celebration animation when completing sessions
library;

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Wrapper widget that displays celebratory confetti animation over its child.
///
/// Triggers particle animation when [show] is true. Particles fall with physics-based
/// motion including gravity, rotation, and randomized colors. Calls [onComplete]
/// when animation finishes.
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool show;
  final VoidCallback? onComplete;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.show = false,
    this.onComplete,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final int _particleCount = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
        setState(() => _particles.clear());
      }
    });

    if (widget.show) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _startConfetti();
    }
  }

  void _startConfetti() {
    _particles.clear();
    final random = math.Random();

    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        ConfettiParticle(
          color: _getRandomColor(random),
          position: Offset(
            random.nextDouble(),
            -0.1, // Start above screen
          ),
          velocity: Offset(
            (random.nextDouble() - 0.5) * 2, // -1 to 1
            random.nextDouble() * 2 + 1, // 1 to 3
          ),
          rotation: random.nextDouble() * math.pi * 2,
          rotationSpeed: (random.nextDouble() - 0.5) * 4,
          size: random.nextDouble() * 8 + 4, // 4 to 12
        ),
      );
    }

    _controller.forward(from: 0);
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.show && _particles.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ConfettiPainter(
                      particles: _particles,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Data model for a single confetti particle with physics properties.
///
/// Stores position, velocity, rotation, and visual properties for
/// physics-based animation calculations.
class ConfettiParticle {
  final Color color;
  final Offset position; // 0-1 normalized
  final Offset velocity;
  final double rotation;
  final double rotationSpeed;
  final double size;

  ConfettiParticle({
    required this.color,
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });
}

/// Custom painter that renders confetti particles with rotation and fading.
///
/// Draws each particle as a small rotated rectangle with opacity based on
/// animation progress. Skips off-screen particles for performance.
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - progress)
        ..style = PaintingStyle.fill;

      // Calculate position
      final x =
          particle.position.dx * size.width +
          particle.velocity.dx * progress * 100;
      final y =
          particle.position.dy * size.height +
          particle.velocity.dy * progress * size.height;

      // Skip if off screen
      if (y > size.height) continue;

      // Calculate rotation
      final rotation = particle.rotation + particle.rotationSpeed * progress;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw confetti piece (small rectangle)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size / 2,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
