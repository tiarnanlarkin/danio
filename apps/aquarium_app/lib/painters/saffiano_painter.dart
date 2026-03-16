import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Crosshatch leather pattern for the Tanks plate.
class SaffianoPainter extends CustomPainter {
  final Color baseColor;

  SaffianoPainter({this.baseColor = const Color(0xFF3D2416)});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill with dark espresso base
    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);

    // 2. Primary diagonal crosshatch grid (45° / 135°)
    final primaryPaint = Paint()
      ..color = Colors.white
          .withAlpha(30) // 12% opacity — was 6%
      ..strokeWidth =
          0.8 // was 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 8.0;
    final maxDim = math.max(size.width, size.height) * 2;

    // 45° lines
    for (var d = -maxDim; d < maxDim; d += spacing) {
      canvas.drawLine(
        Offset(d, 0),
        Offset(d + size.height, size.height),
        primaryPaint,
      );
    }

    // 135° lines
    for (var d = -maxDim; d < maxDim; d += spacing) {
      canvas.drawLine(
        Offset(d, size.height),
        Offset(d + size.height, 0),
        primaryPaint,
      );
    }

    // 3. Secondary crosshatch at ~30° offset for realistic crosshatch depth
    final secondaryPaint = Paint()
      ..color = Colors.white
          .withAlpha(14) // ~5% opacity — subtle accent layer
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacingB = 12.0; // slightly wider spacing for secondary
    final ext = maxDim / 2;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(30.0 * math.pi / 180.0);
    for (var d = -ext; d < ext; d += spacingB) {
      canvas.drawLine(Offset(d, -ext), Offset(d, ext), secondaryPaint);
    }
    canvas.rotate(math.pi / 2);
    for (var d = -ext; d < ext; d += spacingB) {
      canvas.drawLine(Offset(d, -ext), Offset(d, ext), secondaryPaint);
    }
    canvas.restore();

    // 4. Tiny dots at primary crosshatch intersections — authentic Saffiano diamond pattern
    _drawIntersectionDots(canvas, size, maxDim, spacing);

    // 5. Corner vignette
    _drawVignette(canvas, size);
  }

  /// Tiny dots at the crosshatch intersections for authentic Saffiano texture.
  void _drawIntersectionDots(
    Canvas canvas,
    Size size,
    double maxDim,
    double spacing,
  ) {
    final dotPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.fill;

    final h = size.height;
    for (var d1 = -maxDim; d1 < maxDim; d1 += spacing) {
      for (var d2 = -maxDim; d2 < maxDim; d2 += spacing) {
        // Intersection of 45° line offset d1 and 135° line offset d2:
        // 45° line: y = x - d1  =>  x - y = d1
        // 135° line: y = -x + d2 + h  =>  x + y = d2 + h
        final ix = (d1 + d2 + h) / 2;
        final iy = (d2 + h - d1) / 2;
        if (ix >= 0 && ix <= size.width && iy >= 0 && iy <= h) {
          canvas.drawCircle(Offset(ix, iy), 0.8, dotPaint);
        }
      }
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
        colors: [Colors.black.withAlpha(25), Colors.transparent],
      );
      canvas.drawRect(
        Offset.zero & size,
        Paint()..shader = gradient.createShader(Offset.zero & size),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SaffianoPainter old) =>
      old.baseColor != baseColor;
}
