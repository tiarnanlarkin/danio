import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lab vial display for water quality parameters.
///
/// Set [bubbleAnim] to a looping 0.0→1.0 value to animate bubbles rising
/// through the liquid fill in each tube.
class WaterVialPainter extends CustomPainter {
  final double? phValue;
  final double? ammoniaValue;
  final double? nitrateValue;
  final double? nitriteValue;
  final double animationValue; // 0.0–1.0 (fill-in animation)
  final double bubbleAnim;    // 0.0–1.0 (looping, drives bubble rise)

  WaterVialPainter({
    this.phValue,
    this.ammoniaValue,
    this.nitrateValue,
    this.nitriteValue,
    required this.animationValue,
    this.bubbleAnim = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const vialCount = 4;
    final spacing = size.width / (vialCount + 1);
    final vialWidth = spacing * 0.5;
    // Taller tubes: ~82% of container height ≈ 180 px for a 220 px container
    final vialHeight = size.height * 0.82;
    final vialTop = size.height * 0.04;

    final params = [
      _VialData('pH', phValue, _phColor(phValue), _phLevel(phValue)),
      _VialData('NH₃', ammoniaValue, _ammoniaColor(ammoniaValue),
          _ammoniaLevel(ammoniaValue)),
      _VialData('NO₃', nitrateValue, _nitrateColor(nitrateValue),
          _nitrateLevel(nitrateValue)),
      _VialData('NO₂', nitriteValue, _nitriteColor(nitriteValue),
          _nitriteLevel(nitriteValue)),
    ];

    for (var i = 0; i < params.length; i++) {
      final cx = spacing * (i + 1);
      final param = params[i];
      // Stagger fill animation per tube
      final staggerOffset = i * 0.15;
      final localAnim =
          ((animationValue - staggerOffset) / (1.0 - staggerOffset))
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

    // Glass highlight (thin stripe on left edge)
    final highlightRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(cx - width / 2 + 2, top + height * 0.1, 3, height * 0.5),
      topLeft: const Radius.circular(2),
      bottomLeft: const Radius.circular(2),
    );
    canvas.drawRRect(
      highlightRect,
      Paint()..color = const Color(0x20FFFFFF),
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

      // Animated rising bubbles (2–3 per tube, staggered offsets)
      final rng = math.Random(param.label.hashCode);
      const bubbleCount = 3;
      for (var b = 0; b < bubbleCount; b++) {
        // Each bubble has its own horizontal position (deterministic)
        final bx = cx + (rng.nextDouble() - 0.5) * width * 0.55;
        final bubbleRadius = rng.nextDouble() * 2.0 + 1.5;

        // Stagger: bubble 0 leads, 1 is 1/3 behind, 2 is 2/3 behind
        final stagger = b / bubbleCount;
        final t = (bubbleAnim + stagger) % 1.0;
        final tubeBottom = top + height;
        final bubbleY = tubeBottom - t * fillHeight;

        // Only draw bubbles within the liquid fill region
        if (fillHeight > 4 && bubbleY >= fillTop && bubbleY <= tubeBottom) {
          canvas.drawCircle(
            Offset(bx, bubbleY),
            bubbleRadius,
            Paint()..color = const Color(0x50FFFFFF),
          );
        }
      }

      canvas.restore();
    }
  }

  // ── Color scales ──────────────────────────────────────────────────────────

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

  double _phLevel(double? v) =>
      v != null ? ((v - 5) / 4).clamp(0.15, 1.0) : 0.15;
  double _ammoniaLevel(double? v) =>
      v != null ? (v / 2).clamp(0.15, 1.0) : 0.15;
  double _nitrateLevel(double? v) =>
      v != null ? (v / 80).clamp(0.15, 1.0) : 0.15;
  double _nitriteLevel(double? v) =>
      v != null ? (v / 1).clamp(0.15, 1.0) : 0.15;

  @override
  bool shouldRepaint(covariant WaterVialPainter old) =>
      old.animationValue != animationValue ||
      old.bubbleAnim != bubbleAnim ||
      old.phValue != phValue ||
      old.ammoniaValue != ammoniaValue ||
      old.nitrateValue != nitrateValue ||
      old.nitriteValue != nitriteValue;
}

class _VialData {
  final String label;
  final double? value;
  final Color color;
  final double level; // 0.0–1.0

  const _VialData(this.label, this.value, this.color, this.level);
}
