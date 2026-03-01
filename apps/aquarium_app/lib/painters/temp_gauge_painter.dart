import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Upgraded brass instrument-style temperature gauge for the Swiss Army panel.
class TempGaugePainter extends CustomPainter {
  final double temperature;
  final double animationValue; // 0.0–1.0
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

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final startAngle = math.pi * 0.75;
    final sweepTotal = math.pi * 1.5;

    // --- Brass faceplate: radial gradient circle ---
    final facePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2),
        radius: 0.9,
        colors: [
          const Color(0xFF4A3D30),
          const Color(0xFF2C2418),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 8));
    canvas.drawCircle(center, radius + 8, facePaint);

    // --- Outer ring border ---
    canvas.drawCircle(
      center,
      radius + 8,
      Paint()
        ..color = const Color(0xFF6B5B4F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // --- Background arc ---
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..color = secondaryTextColor.withAlpha(38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    // --- Animated progress arc (sweep gradient) ---
    final progress = ((temperature - 15) / 20).clamp(0.0, 1.0);
    final animatedProgress = progress * animationValue;

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
            colors: [coldColor, warmColor, hotColor, dangerColor],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round,
      );
    }

    // --- Tick marks ---
    final tickPaint = Paint()
      ..color = const Color(0xFFAA9977)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i <= 20; i++) {
      final angle = startAngle + (sweepTotal * i / 20);
      final isMajor = i % 5 == 0;
      final innerR = radius - (isMajor ? 18 : 14);
      final outerR = radius - 8;

      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * innerR,
          center.dy + math.sin(angle) * innerR,
        ),
        Offset(
          center.dx + math.cos(angle) * outerR,
          center.dy + math.sin(angle) * outerR,
        ),
        isMajor ? (tickPaint..strokeWidth = 2) : (tickPaint..strokeWidth = 1),
      );
    }

    // --- Animated needle ---
    final needleAngle = startAngle + sweepTotal * animatedProgress;
    final needleLength = radius - 22;
    final needlePaint = Paint()
      ..color = const Color(0xFFE8734A)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(
        center.dx + math.cos(needleAngle + math.pi) * 8,
        center.dy + math.sin(needleAngle + math.pi) * 8,
      ),
      Offset(
        center.dx + math.cos(needleAngle) * needleLength,
        center.dy + math.sin(needleAngle) * needleLength,
      ),
      needlePaint,
    );

    // --- Centre hub ---
    canvas.drawCircle(
      center,
      6,
      Paint()..color = const Color(0xFF6B5B4F),
    );
    canvas.drawCircle(
      center,
      3,
      Paint()..color = const Color(0xFFAA9977),
    );
  }

  @override
  bool shouldRepaint(covariant TempGaugePainter old) =>
      old.temperature != temperature || old.animationValue != animationValue;
}
