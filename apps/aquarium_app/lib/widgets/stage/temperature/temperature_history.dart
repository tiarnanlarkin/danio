import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'temperature_gauge.dart';

// ── Trend Section ─────────────────────────────────────────────────────────────

class TempTrendSection extends StatelessWidget {
  final List<double> sparkData;
  final double? minTemp;
  final double? maxTemp;
  final double? avgTemp;

  const TempTrendSection({
    super.key,
    required this.sparkData,
    required this.minTemp,
    required this.maxTemp,
    required this.avgTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.show_chart_rounded, size: 14, color: kTempTealDark),
            const SizedBox(width: 6),
            Text(
              '7-day trend',
              style: AppTypography.labelSmall.copyWith(
                color: kTempCharcoal.withAlpha(160),
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (minTemp != null && maxTemp != null && avgTemp != null)
              Flexible(
                child: Text(
                  'min ${minTemp!.toStringAsFixed(1)}° · avg ${avgTemp!.toStringAsFixed(1)}° · max ${maxTemp!.toStringAsFixed(1)}°',
                  style: AppTypography.labelSmall.copyWith(
                    color: kTempCharcoal.withAlpha(120),
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 32,
          child: sparkData.length >= 2
              ? CustomPaint(
                  size: const Size(double.infinity, 32),
                  painter: TempSparklinePainter(data: sparkData),
                )
              : Center(
                  child: Text(
                    'No data yet',
                    style: AppTypography.labelSmall.copyWith(
                      color: kTempCharcoal.withAlpha(100),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class TempStatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const TempStatCell({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: kTempCharcoal.withAlpha(120),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class TempStatDivider extends StatelessWidget {
  const TempStatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: kTempCharcoal.withAlpha(30),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    );
  }
}

// ── Day Labels ────────────────────────────────────────────────────────────────

class TempDayLabels extends StatelessWidget {
  final int count;

  const TempDayLabels({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(count, (i) {
      final d = now.subtract(Duration(days: count - 1 - i));
      if (i == count - 1) return 'Today';
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return names[(d.weekday - 1) % 7];
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (d) => Text(
              d,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 9,
                color: kTempCharcoal.withAlpha(100),
                fontWeight: d == 'Today' ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── SparklinePainter ──────────────────────────────────────────────────────────

class TempSparklinePainter extends CustomPainter {
  final List<double> data;

  const TempSparklinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).abs();
    final safeRange = range < 0.5 ? 1.0 : range;
    const vPad = 6.0;

    double xOf(int i) => size.width * i / (data.length - 1);
    double yOf(double v) {
      final norm = (v - minV) / safeRange;
      return size.height - vPad - norm * (size.height - vPad * 2);
    }

    // Filled area
    final fillPath = Path()..moveTo(xOf(0), size.height);
    for (var i = 0; i < data.length; i++) {
      final x0 = i == 0 ? xOf(0) : xOf(i - 1);
      final y0 = i == 0 ? yOf(data[0]) : yOf(data[i - 1]);
      final x1 = xOf(i);
      final y1 = yOf(data[i]);
      if (i == 0) {
        fillPath.lineTo(x1, y1);
      } else {
        final cpx = (x0 + x1) / 2;
        fillPath.cubicTo(cpx, y0, cpx, y1, x1, y1);
      }
    }
    fillPath.lineTo(xOf(data.length - 1), size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kTempTeal.withAlpha(100), kTempTeal.withAlpha(8)],
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
        ..color = kTempTeal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dot markers
    for (var i = 0; i < data.length; i++) {
      canvas.drawCircle(
        Offset(xOf(i), yOf(data[i])),
        4.0,
        Paint()..color = kTempTealDark,
      );
      canvas.drawCircle(
        Offset(xOf(i), yOf(data[i])),
        2.2,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TempSparklinePainter old) => old.data != data;
}
