import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Perlin-noise-inspired leather grain for the Progress plate.
class LeatherGrainPainter extends CustomPainter {
  final Color baseColor;

  LeatherGrainPainter({this.baseColor = const Color(0xFFC68B3E)});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill with base cognac colour
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = baseColor,
    );

    // 2. Random grain ellipses — fixed seed for deterministic appearance
    final rng = math.Random(42);
    final lighter = Color.lerp(baseColor, Colors.white, 0.15)!;
    final darker = Color.lerp(baseColor, Colors.black, 0.15)!;

    for (var i = 0; i < 200; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final w = rng.nextDouble() * 2 + 1;
      final h = rng.nextDouble() * 2 + 1;
      final isLight = rng.nextBool();
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: w, height: h),
        Paint()
          ..color = (isLight ? lighter : darker).withAlpha(rng.nextInt(10) + 8),
      );
    }

    // 3. Corner vignette
    _drawVignette(canvas, size);
  }

  void _drawVignette(Canvas canvas, Size size) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    for (final corner in corners) {
      final gradient = RadialGradient(
        center: Alignment(
          (corner.dx / size.width) * 2 - 1,
          (corner.dy / size.height) * 2 - 1,
        ),
        radius: 1.2,
        colors: [Colors.black.withAlpha(25), Colors.transparent],
      );
      canvas.drawRect(
        Offset.zero & size,
        Paint()..shader = gradient.createShader(Offset.zero & size),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LeatherGrainPainter old) =>
      old.baseColor != baseColor;
}
