import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mechanical analogue temperature gauge used by the Phase 3R instrument.
///
/// The painter deliberately builds the bezel, dial, ticks, labels, needle, and
/// fasteners from primitives. The archived visual authority remains a
/// reference only and is never registered or shipped as an application asset.
class BrassGaugePainter extends CustomPainter {
  static const _brassLight = Color(0xFFFFD983);
  static const _brass = Color(0xFFC89B3C);
  static const _brassDark = Color(0xFF56330C);
  static const _ink = Color(0xFF202425);
  static const _teal = Color(0xFF3BBFB0);

  /// Normalized current temperature within the gauge range (0..1).
  /// Null means there is no manual reading and therefore no needle.
  final double? tempFraction;

  /// Normalized saved target range within the gauge range.
  final double? optFracMin;
  final double? optFracMax;
  final double gaugeMin;
  final double gaugeMax;

  const BrassGaugePainter({
    required this.tempFraction,
    required this.optFracMin,
    required this.optFracMax,
    this.gaugeMin = 18,
    this.gaugeMax = 30,
  });

  // 270° sweep starting at approximately 7:30, with a gap at the bottom.
  static const double _startAngle = math.pi * 3 / 4;
  static const double _sweep = math.pi * 3 / 2;

  double _angleFor(double fraction) =>
      _startAngle + _sweep * fraction.clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.max(
      0.0,
      math.min(size.width, size.height) / 2 - 2,
    );
    if (radius <= 0) return;

    canvas.drawCircle(
      center.translate(0, radius * 0.045),
      radius * 0.98,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.62)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.07),
    );

    final outerRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            _brassDark,
            _brassLight,
            _brass,
            Color(0xFF7E4F17),
            _brassLight,
            _brassDark,
          ],
          stops: [0, 0.18, 0.38, 0.58, 0.78, 1],
        ).createShader(outerRect),
    );

    canvas.drawCircle(
      center,
      radius * 0.88,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Color(0xFF171A1A), Color(0xFF030404)],
            ).createShader(
              Rect.fromCircle(center: center, radius: radius * 0.88),
            ),
    );

    canvas.drawCircle(
      center,
      radius * 0.83,
      Paint()
        ..shader =
            const SweepGradient(
              colors: [
                _brassDark,
                _brassLight,
                _brass,
                _brassDark,
                _brassLight,
              ],
            ).createShader(
              Rect.fromCircle(center: center, radius: radius * 0.83),
            ),
    );

    final dialRadius = radius * 0.75;
    canvas.drawCircle(
      center,
      dialRadius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.28, -0.32),
          radius: 0.96,
          colors: [
            Color(0xFFFFF8E8),
            Color(0xFFF1E4C4),
            Color(0xFFCDBB8D),
          ],
          stops: [0, 0.72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: dialRadius)),
    );
    canvas.drawCircle(
      center,
      dialRadius,
      Paint()
        ..color = _ink.withValues(alpha: 0.52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, radius * 0.014),
    );

    _paintTargetArc(canvas, center, radius);
    _paintTicksAndLabels(canvas, center, radius);
    _paintDialTitle(canvas, center, radius);
    _paintFasteners(canvas, center, radius);
    _paintNeedle(canvas, center, radius);
  }

  void _paintTargetArc(Canvas canvas, Offset center, double radius) {
    if (optFracMin == null || optFracMax == null) return;
    final start = _angleFor(optFracMin!);
    final end = _angleFor(optFracMax!);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.785),
      start,
      end - start,
      false,
      Paint()
        ..color = _teal.withValues(alpha: 0.88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.0, radius * 0.022)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintTicksAndLabels(Canvas canvas, Offset center, double radius) {
    const divisions = 30;
    for (var i = 0; i <= divisions; i++) {
      final fraction = i / divisions;
      final angle = _angleFor(fraction);
      final isMajor = i % 5 == 0;
      final outer = radius * 0.68;
      final inner = radius * (isMajor ? 0.54 : 0.61);
      canvas.drawLine(
        _polar(center, inner, angle),
        _polar(center, outer, angle),
        Paint()
          ..color = _ink.withValues(alpha: isMajor ? 0.94 : 0.72)
          ..strokeWidth = isMajor
              ? math.max(1.5, radius * 0.016)
              : math.max(0.8, radius * 0.008)
          ..strokeCap = StrokeCap.square,
      );

      if (!isMajor) continue;
      final value = gaugeMin + (gaugeMax - gaugeMin) * fraction;
      final label = value == value.roundToDouble()
          ? value.round().toString()
          : value.toStringAsFixed(1);
      final labelCenter = _polar(center, radius * 0.43, angle);
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: _ink,
            fontSize: math.max(9.0, radius * 0.115),
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        labelCenter - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  void _paintDialTitle(Canvas canvas, Offset center, double radius) {
    final painter = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'AQUARIUM\nTEMP (°C)',
        style: TextStyle(
          color: _ink.withValues(alpha: 0.9),
          fontSize: math.max(8.0, radius * 0.09),
          fontWeight: FontWeight.w800,
          height: 1.08,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 0.9);
    painter.paint(
      canvas,
      Offset(
        center.dx - painter.width / 2,
        center.dy + radius * 0.44,
      ),
    );
  }

  void _paintFasteners(Canvas canvas, Offset center, double radius) {
    for (final angle in const [
      math.pi / 4,
      math.pi * 3 / 4,
      math.pi * 5 / 4,
      math.pi * 7 / 4,
    ]) {
      final fastenerCenter = _polar(center, radius * 0.91, angle);
      final fastenerRadius = math.max(2.5, radius * 0.034);
      canvas.drawCircle(
        fastenerCenter,
        fastenerRadius,
        Paint()
          ..shader =
              const RadialGradient(
                center: Alignment(-0.35, -0.35),
                colors: [_brassLight, _brass, Color(0xFF2A1807)],
              ).createShader(
                Rect.fromCircle(
                  center: fastenerCenter,
                  radius: fastenerRadius,
                ),
              ),
      );
      canvas.drawLine(
        fastenerCenter.translate(-fastenerRadius * 0.55, 0),
        fastenerCenter.translate(fastenerRadius * 0.55, 0),
        Paint()
          ..color = const Color(0xFF241708)
          ..strokeWidth = math.max(0.7, fastenerRadius * 0.22),
      );
    }
  }

  void _paintNeedle(Canvas canvas, Offset center, double radius) {
    if (tempFraction == null) {
      _paintHub(canvas, center, radius);
      return;
    }
    final angle = _angleFor(tempFraction!);
    final direction = Offset(math.cos(angle), math.sin(angle));
    final perpendicular = Offset(-direction.dy, direction.dx);
    final tip = center + direction * radius * 0.5;
    final tail = center - direction * radius * 0.14;
    final halfWidth = math.max(2.2, radius * 0.026);
    final needle = Path()
      ..moveTo(tail.dx, tail.dy)
      ..lineTo(
        center.dx + perpendicular.dx * halfWidth,
        center.dy + perpendicular.dy * halfWidth,
      )
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(
        center.dx - perpendicular.dx * halfWidth,
        center.dy - perpendicular.dy * halfWidth,
      )
      ..close();
    canvas.drawPath(
      needle.shift(Offset(0, radius * 0.012)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.52)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.012),
    );
    canvas.drawPath(
      needle,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFD4523F), Color(0xFF7B2118), Color(0xFF32100C)],
          stops: [0, 0.54, 1],
        ).createShader(Rect.fromPoints(tail, tip)),
    );
    _paintHub(canvas, center, radius);
  }

  void _paintHub(Canvas canvas, Offset center, double radius) {
    final hubRadius = math.max(5.0, radius * 0.09);
    canvas.drawCircle(
      center,
      hubRadius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0xFF777B7A), Color(0xFF1A1D1D), Color(0xFF050606)],
        ).createShader(Rect.fromCircle(center: center, radius: hubRadius)),
    );
    canvas.drawCircle(
      center,
      hubRadius,
      Paint()
        ..color = _brass.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, radius * 0.012),
    );
    canvas.drawCircle(
      center,
      math.max(1.5, hubRadius * 0.24),
      Paint()..color = _brassLight.withValues(alpha: 0.82),
    );
  }

  Offset _polar(Offset center, double radius, double angle) => Offset(
    center.dx + radius * math.cos(angle),
    center.dy + radius * math.sin(angle),
  );

  @override
  bool shouldRepaint(covariant BrassGaugePainter old) =>
      old.tempFraction != tempFraction ||
      old.optFracMin != optFracMin ||
      old.optFracMax != optFracMax ||
      old.gaugeMin != gaugeMin ||
      old.gaugeMax != gaugeMax;
}
