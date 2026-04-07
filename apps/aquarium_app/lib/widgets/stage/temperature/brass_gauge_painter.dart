import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular brass gauge painter for the Temperature "Gauge Instrument" panel.
///
/// Geometry (concept lock 2026-04-07):
/// - 270° sweep, gap at bottom
/// - Brass outer ring
/// - Optimal-range arc overlay (green)
/// - Tick marks every fractional step (7 total: 0..6 / 6)
/// - Analog needle from center to 85% radius (if [tempFraction] is non-null)
class BrassGaugePainter extends CustomPainter {
  static const _brass = Color(0xFFC89B3C);
  static const _ink = Color(0xFF2D3436);
  static const _green = Color(0xFF1E8449);

  /// Normalized current temperature within the gauge range (0..1).
  /// Null = no reading, no needle drawn.
  final double? tempFraction;

  /// Normalized optimal range within the gauge range.
  final double optFracMin;
  final double optFracMax;

  const BrassGaugePainter({
    required this.tempFraction,
    required this.optFracMin,
    required this.optFracMax,
  });

  // 270° sweep starting at ~7:30 o'clock (top-left of bottom gap)
  static const double _startAngle = math.pi * 3 / 4;
  static const double _sweep = math.pi * 3 / 2;

  double _angleFor(double fraction) =>
      _startAngle + _sweep * fraction.clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 6;

    // Inner track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      _startAngle,
      _sweep,
      false,
      Paint()
        ..color = _ink.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Optimal arc overlay
    final optStart = _angleFor(optFracMin);
    final optEnd = _angleFor(optFracMax);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      optStart,
      optEnd - optStart,
      false,
      Paint()
        ..color = _green.withValues(alpha: 0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Brass outer ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweep,
      false,
      Paint()
        ..color = _brass
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Tick marks every fractional step (1/6)
    for (var i = 0; i <= 6; i++) {
      final frac = i / 6;
      final angle = _angleFor(frac);
      final isMajor = i % 2 == 0;
      final tickIn = radius - 14;
      final tickOut = radius - (isMajor ? 6 : 9);
      canvas.drawLine(
        Offset(
          center.dx + tickIn * math.cos(angle),
          center.dy + tickIn * math.sin(angle),
        ),
        Offset(
          center.dx + tickOut * math.cos(angle),
          center.dy + tickOut * math.sin(angle),
        ),
        Paint()
          ..color = _ink.withValues(alpha: isMajor ? 0.7 : 0.4)
          ..strokeWidth = isMajor ? 2 : 1,
      );
    }

    // Needle
    if (tempFraction != null) {
      final angle = _angleFor(tempFraction!);
      final needleEnd = Offset(
        center.dx + (radius - 14) * 0.85 * math.cos(angle),
        center.dy + (radius - 14) * 0.85 * math.sin(angle),
      );
      canvas.drawLine(
        center,
        needleEnd,
        Paint()
          ..color = _ink
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    // Center cap
    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color = _brass
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant BrassGaugePainter old) =>
      old.tempFraction != tempFraction ||
      old.optFracMin != optFracMin ||
      old.optFracMax != optFracMax;
}
