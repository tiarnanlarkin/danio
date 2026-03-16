import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Perlin-noise-inspired leather grain for the Progress plate.
class LeatherGrainPainter extends CustomPainter {
  final Color baseColor;

  LeatherGrainPainter({this.baseColor = const Color(0xFFC68B3E)});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill with base cognac colour
    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);

    // 2. Edge burnishing — slightly darker at top and bottom, like worn leather
    _drawEdgeBurnishing(canvas, size);

    // 3. Random grain ellipses — fixed seed for deterministic appearance
    final rng = math.Random(42);
    final lighter = Color.lerp(baseColor, Colors.white, 0.22)!;
    final darker = Color.lerp(baseColor, Colors.black, 0.22)!;

    for (var i = 0; i < 420; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final w = rng.nextDouble() * 2.5 + 0.8;
      final h = rng.nextDouble() * 1.5 + 0.5;
      final angle = (rng.nextDouble() - 0.5) * 0.4; // slight random tilt
      final isLight = rng.nextBool();
      // opacity range 0.08–0.15 => alpha 20–38
      final alpha = rng.nextInt(18) + 20;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        Paint()..color = (isLight ? lighter : darker).withAlpha(alpha),
      );
      canvas.restore();
    }

    // 4. Subtle horizontal creasing lines — 3 lines for realistic leather look
    _drawCreasingLines(canvas, size);

    // 5. Corner vignette
    _drawVignette(canvas, size);
  }

  /// Subtle darker bands at top and bottom edges — like worn leather burnishing.
  void _drawEdgeBurnishing(Canvas canvas, Size size) {
    final burnColor = Color.lerp(baseColor, Colors.black, 0.35)!;

    // Top edge burnish
    final topGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [burnColor.withAlpha(60), Colors.transparent],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.18),
      Paint()..shader = topGradient.createShader(Offset.zero & size),
    );

    // Bottom edge burnish
    final bottomRect = Rect.fromLTWH(
      0,
      size.height * 0.82,
      size.width,
      size.height * 0.18,
    );
    final bottomGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [burnColor.withAlpha(60), Colors.transparent],
    );
    canvas.drawRect(
      bottomRect,
      Paint()..shader = bottomGradient.createShader(bottomRect),
    );
  }

  /// Faint horizontal creasing lines for realistic leather depth.
  void _drawCreasingLines(Canvas canvas, Size size) {
    final creasePaint = Paint()
      ..color = Colors.black.withAlpha(18)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    // 3 creases at roughly 30%, 55%, 75% height — slightly wavy
    final positions = [0.30, 0.55, 0.75];
    final rng = math.Random(99);

    for (final t in positions) {
      final path = Path();
      final y = size.height * t;
      path.moveTo(0, y);
      var x = 0.0;
      const step = 20.0;
      while (x < size.width) {
        final dy = (rng.nextDouble() - 0.5) * 1.5;
        path.lineTo(math.min(x + step, size.width), y + dy);
        x += step;
      }
      canvas.drawPath(path, creasePaint);
    }
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
        colors: [Colors.black.withAlpha(30), Colors.transparent],
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
