import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'water_param_card.dart';

// ── Sparkline Section ─────────────────────────────────────────────────────────

class WqSparklineSection extends StatelessWidget {
  final List<double> phData;
  final List<double> nitData;

  const WqSparklineSection({
    super.key,
    required this.phData,
    required this.nitData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm2),
      decoration: BoxDecoration(
        color: AppColors.whiteAlpha70,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(
          color: const Color(0xFF3BBFB0).withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-day trends',
            style: AppTypography.labelSmall.copyWith(
              color: kWqCharcoal.withAlpha(140),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (phData.length >= 2) ...[
            Row(
              children: [
                Text(
                  'pH  ',
                  style: AppTypography.labelSmall.copyWith(
                    color: kWqCharcoal.withAlpha(120),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: CustomPaint(
                      painter: WqSparklinePainter(
                        data: phData,
                        color: const Color(0xFF3BBFB0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (nitData.length >= 2 && phData.length >= 2)
            const SizedBox(height: AppSpacing.xs),
          if (nitData.length >= 2) ...[
            Row(
              children: [
                Text(
                  'NO₃ ',
                  style: AppTypography.labelSmall.copyWith(
                    color: kWqCharcoal.withAlpha(120),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: CustomPaint(
                      painter: WqSparklinePainter(data: nitData, color: kWqRed),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Sparkline Painter ─────────────────────────────────────────────────────────

class WqSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  const WqSparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).abs();
    final safeRange = range < 0.01 ? 1.0 : range;

    double xOf(int i) => size.width * i / (data.length - 1);
    double yOf(double v) =>
        size.height -
        (size.height * (v - minV) / safeRange).clamp(4.0, size.height - 4.0);

    // Fill
    final fillPath = Path()..moveTo(xOf(0), size.height);
    for (var i = 0; i < data.length; i++) {
      fillPath.lineTo(xOf(i), yOf(data[i]));
    }
    fillPath
      ..lineTo(xOf(data.length - 1), size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withAlpha(70), color.withAlpha(10)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // Line
    final linePath = Path()..moveTo(xOf(0), yOf(data[0]));
    for (var i = 1; i < data.length; i++) {
      final x0 = xOf(i - 1);
      final y0 = yOf(data[i - 1]);
      final x1 = xOf(i);
      final y1 = yOf(data[i]);
      final cpx = (x0 + x1) / 2;
      linePath.cubicTo(cpx, y0, cpx, y1, x1, y1);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (var i = 0; i < data.length; i++) {
      canvas.drawCircle(
        Offset(xOf(i), yOf(data[i])),
        3.0,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(xOf(i), yOf(data[i])),
        1.5,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WqSparklinePainter old) =>
      old.data != data || old.color != color;
}
