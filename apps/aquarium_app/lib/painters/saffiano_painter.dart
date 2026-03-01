import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Crosshatch leather pattern for the Tanks plate.
class SaffianoPainter extends CustomPainter {
  final Color baseColor;

  SaffianoPainter({this.baseColor = const Color(0xFF3D2416)});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill with dark espresso base
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = baseColor,
    );

    // 2. Diagonal crosshatch grid
    final linePaint = Paint()
      ..color = Colors.white.withAlpha(15) // 6% opacity
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 8.0;
    final maxDim = math.max(size.width, size.height) * 2;

    // 45° lines
    for (var d = -maxDim; d < maxDim; d += spacing) {
      canvas.drawLine(
        Offset(d, 0),
        Offset(d + size.height, size.height),
        linePaint,
      );
    }

    // 135° lines
    for (var d = -maxDim; d < maxDim; d += spacing) {
      canvas.drawLine(
        Offset(d, size.height),
        Offset(d + size.height, 0),
        linePaint,
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
  bool shouldRepaint(covariant SaffianoPainter old) =>
      old.baseColor != baseColor;
}
