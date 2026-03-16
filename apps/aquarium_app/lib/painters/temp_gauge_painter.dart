import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Gradient arc temperature gauge for the redesigned Temperature panel.
/// Draws a 240° arc with a blue→cyan→green→yellow→orange→red gradient,
/// a thin needle, tick marks, and a centre hub.  No opaque faceplate —
/// the widget layer behind this painter is fully visible through the centre.
class TempGaugePainter extends CustomPainter {
  /// Current temperature in °C.
  final double temperature;

  /// Animation progress 0.0 → 1.0 (eased by caller).
  final double animationValue;

  // Gradient stop colours (kept as named params so callers can override).
  final Color coldColor;
  final Color warmColor;
  final Color hotColor;
  final Color dangerColor;
  final Color textColor;
  final Color secondaryTextColor;

  TempGaugePainter({
    required this.temperature,
    required this.animationValue,
    required this.coldColor,
    required this.warmColor,
    required this.hotColor,
    required this.dangerColor,
    required this.textColor,
    required this.secondaryTextColor,
  });

  // Arc geometry constants
  static const double _minTemp = 18.0;
  static const double _maxTemp = 32.0;

  // 240° sweep, starting at 150° from positive-x (≈ bottom-left)
  static const double _startDeg = 150.0;
  static const double _sweepDeg = 240.0;

  static double _toRad(double deg) => deg * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    final startAngle = _toRad(_startDeg);
    final sweepTotal = _toRad(_sweepDeg);

    // ── Background arc ────────────────────────────────────────────────────
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..color = secondaryTextColor.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    // ── Gradient progress arc ─────────────────────────────────────────────
    final tempProgress = ((temperature - _minTemp) / (_maxTemp - _minTemp))
        .clamp(0.0, 1.0);
    final animatedProgress = tempProgress * animationValue;

    if (animatedProgress > 0.001) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepTotal * animatedProgress,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: startAngle,
            endAngle: startAngle + sweepTotal,
            colors: const [
              Color(0xFF42A5F5), // blue  (cold)
              Color(0xFF26C6DA), // cyan
              Color(0xFF66BB6A), // green (optimal)
              Color(0xFFFFEE58), // yellow
              Color(0xFFFF9800), // orange
              Color(0xFFEF5350), // red   (hot)
            ],
            stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── Tick marks ────────────────────────────────────────────────────────
    final tickPaint = Paint()
      ..color = secondaryTextColor.withAlpha(120)
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i <= 14; i++) {
      final angle = startAngle + sweepTotal * i / 14;
      final isMajor = i % 7 == 0;
      final innerR = radius - (isMajor ? 14 : 10);
      final outerR = radius - 4;

      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * innerR,
          center.dy + math.sin(angle) * innerR,
        ),
        Offset(
          center.dx + math.cos(angle) * outerR,
          center.dy + math.sin(angle) * outerR,
        ),
        tickPaint..strokeWidth = isMajor ? 2.0 : 1.0,
      );
    }

    // ── Needle ────────────────────────────────────────────────────────────
    final needleAngle = startAngle + sweepTotal * animatedProgress;
    final needleLength = radius - 22;
    final needleColor = _needleColor(temperature);

    canvas.drawLine(
      Offset(
        center.dx + math.cos(needleAngle + math.pi) * 6,
        center.dy + math.sin(needleAngle + math.pi) * 6,
      ),
      Offset(
        center.dx + math.cos(needleAngle) * needleLength,
        center.dy + math.sin(needleAngle) * needleLength,
      ),
      Paint()
        ..color = needleColor
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // ── Centre hub ────────────────────────────────────────────────────────
    canvas.drawCircle(
      center,
      5,
      Paint()..color = secondaryTextColor.withAlpha(80),
    );
    canvas.drawCircle(center, 3, Paint()..color = needleColor);
  }

  Color _needleColor(double temp) {
    if (temp >= 23 && temp <= 27) {
      return const Color(0xFFB45309); // amber/primary
    }
    if (temp < 20 || temp > 30) return const Color(0xFFEF5350); // red
    return const Color(0xFFFF9800); // orange
  }

  @override
  bool shouldRepaint(covariant TempGaugePainter old) =>
      old.temperature != temperature || old.animationValue != animationValue;
}
