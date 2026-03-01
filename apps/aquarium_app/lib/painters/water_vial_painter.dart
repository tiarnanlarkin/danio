import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lab vial display for water quality parameters.
class WaterVialPainter extends CustomPainter {
  final double? phValue;
  final double? ammoniaValue;
  final double? nitrateValue;
  final double? nitriteValue;
  final double animationValue; // 0.0–1.0

  WaterVialPainter({
    this.phValue,
    this.ammoniaValue,
    this.nitrateValue,
    this.nitriteValue,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final vialCount = 4;
    final spacing = size.width / (vialCount + 1);
    final vialWidth = spacing * 0.5;
    final vialHeight = size.height * 0.6;
    final vialTop = size.height * 0.1;

    final params = [
      _VialData('pH', phValue, _phColor(phValue), _phLevel(phValue)),
      _VialData('NH₃', ammoniaValue, _ammoniaColor(ammoniaValue), _ammoniaLevel(ammoniaValue)),
      _VialData('NO₃', nitrateValue, _nitrateColor(nitrateValue), _nitrateLevel(nitrateValue)),
      _VialData('NO₂', nitriteValue, _nitriteColor(nitriteValue), _nitriteLevel(nitriteValue)),
    ];

    for (var i = 0; i < params.length; i++) {
      final cx = spacing * (i + 1);
      final param = params[i];
      // Stagger animation: 0ms, 100ms, 200ms, 300ms → offset in 0.0–1.0 range
      final staggerOffset = i * 0.15;
      final localAnim = ((animationValue - staggerOffset) / (1.0 - staggerOffset))
          .clamp(0.0, 1.0);

      _drawVial(
        canvas,
        cx,
        vialTop,
        vialWidth,
        vialHeight,
        param,
        localAnim,
      );
    }
  }

  void _drawVial(
    Canvas canvas,
    double cx,
    double top,
    double width,
    double height,
    _VialData param,
    double anim,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, top + height / 2),
        width: width,
        height: height,
      ),
      Radius.circular(width / 2),
    );

    // Vial outline
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0x40FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Liquid fill
    if (param.level > 0) {
      final fillHeight = height * param.level * anim;
      final fillTop = top + height - fillHeight;
      final fillRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - width / 2, fillTop, width, fillHeight),
        bottomLeft: Radius.circular(width / 2),
        bottomRight: Radius.circular(width / 2),
        topLeft: fillHeight >= height * 0.95
            ? Radius.circular(width / 2)
            : Radius.zero,
        topRight: fillHeight >= height * 0.95
            ? Radius.circular(width / 2)
            : Radius.zero,
      );

      canvas.save();
      canvas.clipRRect(rect);
      canvas.drawRRect(
        fillRect,
        Paint()..color = param.color.withAlpha(200),
      );

      // Bubbles near top of liquid
      final rng = math.Random(param.label.hashCode);
      for (var b = 0; b < 3; b++) {
        final bx = cx + (rng.nextDouble() - 0.5) * width * 0.6;
        final by = fillTop + rng.nextDouble() * 12 + 4;
        canvas.drawCircle(
          Offset(bx, by),
          rng.nextDouble() * 2 + 1,
          Paint()..color = const Color(0x40FFFFFF),
        );
      }
      canvas.restore();
    }
  }

  // --- Color scales ---
  Color _phColor(double? v) {
    if (v == null) return const Color(0xFF9E9E9E);
    if (v < 6.0) return const Color(0xFF42A5F5); // acidic blue
    if (v < 7.0) return const Color(0xFF66BB6A); // neutral green
    if (v < 8.0) return const Color(0xFFFFA726); // slightly alkaline
    return const Color(0xFFEF5350); // very alkaline
  }

  Color _ammoniaColor(double? v) {
    if (v == null) return const Color(0xFF9E9E9E);
    if (v <= 0.25) return const Color(0xFFFFF176); // safe yellow
    if (v <= 0.5) return const Color(0xFF66BB6A); // warning green
    return const Color(0xFFEF5350); // danger
  }

  Color _nitrateColor(double? v) {
    if (v == null) return const Color(0xFF9E9E9E);
    if (v <= 20) return const Color(0xFFFFF176); // safe
    if (v <= 40) return const Color(0xFFFFA726); // caution
    return const Color(0xFFEF5350);
  }

  Color _nitriteColor(double? v) {
    if (v == null) return const Color(0xFF9E9E9E);
    if (v <= 0) return const Color(0xFFE0E0E0); // clear
    if (v <= 0.25) return const Color(0xFFF48FB1); // light pink
    return const Color(0xFFEF5350);
  }

  double _phLevel(double? v) => v != null ? ((v - 5) / 4).clamp(0.15, 1.0) : 0.15;
  double _ammoniaLevel(double? v) => v != null ? (v / 2).clamp(0.15, 1.0) : 0.15;
  double _nitrateLevel(double? v) => v != null ? (v / 80).clamp(0.15, 1.0) : 0.15;
  double _nitriteLevel(double? v) => v != null ? (v / 1).clamp(0.15, 1.0) : 0.15;

  @override
  bool shouldRepaint(covariant WaterVialPainter old) =>
      old.animationValue != animationValue ||
      old.phValue != phValue ||
      old.ammoniaValue != ammoniaValue;
}

class _VialData {
  final String label;
  final double? value;
  final Color color;
  final double level; // 0.0–1.0

  const _VialData(this.label, this.value, this.color, this.level);
}
