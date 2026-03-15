import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/log_entry.dart';
import '../../providers/tank_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';

// ── Colour constants ──────────────────────────────────────────────────────────
const _kTeal = Color(0xFF3BBFB0);
const _kTealLight = Color(0xFF5DD4C8);
const _kTealDark = Color(0xFF279E91);
const _kAmberGold = Color(0xFFD97706);
const _kAmberGoldLight = Color(0xFFF59E0B);
const _kCharcoal = Color(0xFF2D3436);
const _kCream = Color(0xFFFFF5E8);
const _kGreen = Color(0xFF22C55E);
const _kGreenDark = Color(0xFF16A34A);
const _kAmberWarn = Color(0xFFF59E0B);
const _kBlueWarn = Color(0xFF3B82F6);

// ── Panel content ─────────────────────────────────────────────────────────────

/// Illustrated temperature panel — redesigned for the Swiss Army stage system.
/// Keeps all existing Riverpod provider wiring; only the visual layer changed.
class TempPanelContent extends ConsumerStatefulWidget {
  final String tankId;
  final RoomTheme theme;

  const TempPanelContent({
    super.key,
    required this.tankId,
    required this.theme,
  });

  @override
  ConsumerState<TempPanelContent> createState() => _TempPanelContentState();
}

class _TempPanelContentState extends ConsumerState<TempPanelContent>
    with TickerProviderStateMixin {
  late final AnimationController _fillAnim;

  static const double _optimalMin = 24.0;
  static const double _optimalMax = 26.0;
  static const double _gaugeMin = 20.0;
  static const double _gaugeMax = 30.0;

  @override
  void initState() {
    super.initState();
    _fillAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fillAnim.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _fillAnim.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatTimestamp(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  _TempStatus _status(double temp) {
    if (temp >= _optimalMin && temp <= _optimalMax) return _TempStatus.perfect;
    if (temp > _optimalMax) return _TempStatus.warm;
    return _TempStatus.cool;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final latestTestAsync = ref.watch(latestWaterTestProvider(widget.tankId));
    final latestEntryAsync =
        ref.watch(latestWaterTestEntryProvider(widget.tankId));
    final streakAsync = ref.watch(testStreakProvider(widget.tankId));
    final logsAsync = ref.watch(logsProvider(widget.tankId));

    final temp = latestTestAsync.value?.temperature;
    final status = temp != null ? _status(temp) : null;
    final lastEntry = latestEntryAsync.value;
    final streak = streakAsync.value ?? 0;

    // Build 7-day sparkline data from recent logs
    final recentLogs = logsAsync.value ?? [];
    final sparkData = _buildSparkData(recentLogs);

    return Container(
      color: _kCream,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────
            _Header(theme: widget.theme, streak: streak),
            const SizedBox(height: AppSpacing.md),

            // ── Thermometer + temperature display ────────────────────────
            _ThermometerSection(
              temp: temp,
              fillAnim: _fillAnim,
              gaugeMin: _gaugeMin,
              gaugeMax: _gaugeMax,
              optimalMin: _optimalMin,
              optimalMax: _optimalMax,
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Status badge ─────────────────────────────────────────────
            if (status != null) _StatusBadge(status: status),
            const SizedBox(height: AppSpacing.md),

            // ── Last reading ─────────────────────────────────────────────
            if (lastEntry != null)
              _InfoRow(
                label: 'Last reading',
                value: _formatTimestamp(lastEntry.timestamp),
                icon: Icons.access_time_rounded,
              ),
            const SizedBox(height: AppSpacing.xs),

            // ── 7-day sparkline ──────────────────────────────────────────
            if (sparkData.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _SparklineCard(data: sparkData),
              const SizedBox(height: AppSpacing.sm),
            ],

            // ── Log Temperature button ───────────────────────────────────
            const SizedBox(height: AppSpacing.sm),
            _LogButton(tankId: widget.tankId),
          ],
        ),
      ),
    );
  }

  /// Extract the last 7 days of temperature readings (one per day, latest).
  List<double> _buildSparkData(List<LogEntry> logs) {
    final now = DateTime.now();
    final result = <double>[];
    for (var i = 6; i >= 0; i--) {
      final day =
          DateTime(now.year, now.month, now.day - i);
      final dayLogs = logs.where((l) {
        if (l.type != LogType.waterTest) return false;
        final t = l.waterTest?.temperature;
        if (t == null) return false;
        final ld = DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day);
        return ld == day;
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (dayLogs.isNotEmpty) {
        result.add(dayLogs.first.waterTest!.temperature!);
      }
    }
    return result;
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final RoomTheme theme;
  final int streak;

  const _Header({required this.theme, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: _kTeal,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.thermostat_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Temperature',
          style: AppTypography.titleMedium.copyWith(color: _kCharcoal),
        ),
        const Spacer(),
        if (streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(
              color: _kAmberGold.withAlpha(30),
              borderRadius: AppRadius.pillRadius,
              border: Border.all(color: _kAmberGold.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 3),
                Text(
                  '$streak',
                  style: AppTypography.labelSmall.copyWith(
                    color: _kAmberGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Thermometer Section ───────────────────────────────────────────────────────

class _ThermometerSection extends StatelessWidget {
  final double? temp;
  final AnimationController fillAnim;
  final double gaugeMin;
  final double gaugeMax;
  final double optimalMin;
  final double optimalMax;

  const _ThermometerSection({
    required this.temp,
    required this.fillAnim,
    required this.gaugeMin,
    required this.gaugeMax,
    required this.optimalMin,
    required this.optimalMax,
  });

  @override
  Widget build(BuildContext context) {
    const thermometerH = 220.0;
    const thermometerW = 52.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Illustrated thermometer ──────────────────────────────────────
        SizedBox(
          width: thermometerW,
          height: thermometerH,
          child: AnimatedBuilder(
            animation: fillAnim,
            builder: (context, _) {
              final fillFraction = temp != null
                  ? ((temp! - gaugeMin) / (gaugeMax - gaugeMin)).clamp(0.0, 1.0)
                  : 0.0;
              final animatedFill =
                  Curves.easeOutCubic.transform(fillAnim.value) * fillFraction;
              return CustomPaint(
                painter: _ThermometerPainter(
                  fillFraction: animatedFill,
                  optimalMin: optimalMin,
                  optimalMax: optimalMax,
                  gaugeMin: gaugeMin,
                  gaugeMax: gaugeMax,
                ),
              );
            },
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // ── Range tick labels ────────────────────────────────────────────
        SizedBox(
          height: thermometerH,
          child: _RangeLabels(
            gaugeMin: gaugeMin,
            gaugeMax: gaugeMax,
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // ── Temperature readout ──────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temp != null ? '${temp!.toStringAsFixed(1)}°C' : '--°C',
                  style: AppTypography.headlineLarge.copyWith(
                    color: _kCharcoal,
                    fontWeight: FontWeight.w800,
                    fontSize: 38,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Current',
                  style: AppTypography.bodySmall
                      .copyWith(color: _kCharcoal.withAlpha(100)),
                ),
                const SizedBox(height: AppSpacing.md),
                _OptimalRangeChip(
                  min: optimalMin,
                  max: optimalMax,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Range Labels ──────────────────────────────────────────────────────────────

class _RangeLabels extends StatelessWidget {
  final double gaugeMin;
  final double gaugeMax;

  const _RangeLabels({required this.gaugeMin, required this.gaugeMax});

  @override
  Widget build(BuildContext context) {
    // Labels at 20, 22, 24, 26, 28, 30
    final labels = <double>[];
    for (var t = gaugeMax; t >= gaugeMin; t -= 2) {
      labels.add(t);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        // Thermometer bulb area: ~36px at bottom, tube top ~20px from top
        const topPad = 20.0;
        const bottomPad = 38.0;
        final usableH = h - topPad - bottomPad;

        return Stack(
          children: List.generate(labels.length, (i) {
            final temp = labels[i];
            final fraction = (temp - gaugeMin) / (gaugeMax - gaugeMin);
            final y = topPad + usableH * (1.0 - fraction) - 7;
            return Positioned(
              top: y,
              child: Text(
                '${temp.toInt()}°',
                style: AppTypography.labelSmall.copyWith(
                  color: _kCharcoal.withAlpha(140),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Optimal Range Chip ────────────────────────────────────────────────────────

class _OptimalRangeChip extends StatelessWidget {
  final double min;
  final double max;

  const _OptimalRangeChip({required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: _kTeal.withAlpha(25),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: _kTeal.withAlpha(80)),
      ),
      child: Text(
        'Optimal ${min.toInt()}–${max.toInt()}°C',
        style: AppTypography.labelSmall.copyWith(
          color: _kTealDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _TempStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPerfect = status == _TempStatus.perfect;
    final isWarm = status == _TempStatus.warm;

    final bgColor = isPerfect
        ? _kGreen
        : isWarm
            ? _kAmberWarn
            : _kBlueWarn;
    final label = isPerfect
        ? 'Perfect!'
        : isWarm
            ? 'A little warm'
            : 'A little cool';
    final icon = isPerfect ? '🐟' : isWarm ? '☀️' : '❄️';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: bgColor.withAlpha(100),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _kCharcoal.withAlpha(100)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmall
              .copyWith(color: _kCharcoal.withAlpha(120)),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: _kCharcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Sparkline Card ────────────────────────────────────────────────────────────

class _SparklineCard extends StatelessWidget {
  final List<double> data;

  const _SparklineCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: _kTeal.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-day trend',
            style: AppTypography.labelSmall.copyWith(
              color: _kCharcoal.withAlpha(140),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 48,
            child: CustomPaint(
              size: const Size(double.infinity, 48),
              painter: _SparklinePainter(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Log Button ────────────────────────────────────────────────────────────────

class _LogButton extends StatelessWidget {
  final String tankId;

  const _LogButton({required this.tankId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to log temperature flow
          // The home screen's bottom nav or modal handles this;
          // for now we show a snack confirming tap.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Log temperature — coming soon!'),
              backgroundColor: _kAmberGold,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mediumRadius),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.thermostat_rounded, size: 20),
        label: Text(
          'Log Temperature',
          style: AppTypography.labelLarge,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAmberGold,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.largeRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),
    );
  }
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum _TempStatus { perfect, warm, cool }

// ── ThermometerPainter ────────────────────────────────────────────────────────

class _ThermometerPainter extends CustomPainter {
  final double fillFraction; // 0.0 – 1.0
  final double optimalMin;
  final double optimalMax;
  final double gaugeMin;
  final double gaugeMax;

  const _ThermometerPainter({
    required this.fillFraction,
    required this.optimalMin,
    required this.optimalMax,
    required this.gaugeMin,
    required this.gaugeMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Geometry constants ───────────────────────────────────────────────
    const bulbRadius = 17.0;
    const tubeHalfW = 8.0;
    const tubeTopRadius = 8.0;
    final bulbCy = h - bulbRadius - 2;
    final tubePaddingBottom = bulbCy - bulbRadius - tubeHalfW;
    final tubeTop = 14.0;
    const tubeLeft = 0.0;
    // Tube centre X
    final cx = w / 2;

    // ── Background shapes ────────────────────────────────────────────────

    // Tube (outer — light grey)
    final tubeOuterPaint = Paint()
      ..color = _kCharcoal.withAlpha(18)
      ..style = PaintingStyle.fill;
    final tubeOuter = RRect.fromRectAndCorners(
      Rect.fromLTWH(
          cx - tubeHalfW - 2, tubeTop, (tubeHalfW + 2) * 2, tubePaddingBottom - tubeTop),
      topLeft: const Radius.circular(tubeTopRadius),
      topRight: const Radius.circular(tubeTopRadius),
    );
    canvas.drawRRect(tubeOuter, tubeOuterPaint);

    // Bulb (outer — light grey)
    canvas.drawCircle(
      Offset(cx, bulbCy),
      bulbRadius,
      tubeOuterPaint,
    );

    // ── Optimal range zone on tube ───────────────────────────────────────
    final zoneMinFrac =
        (optimalMin - gaugeMin) / (gaugeMax - gaugeMin);
    final zoneMaxFrac =
        (optimalMax - gaugeMin) / (gaugeMax - gaugeMin);
    final tubeUsable = tubePaddingBottom - tubeTop;
    final zoneTop =
        tubePaddingBottom - zoneMaxFrac * tubeUsable;
    final zoneBottom =
        tubePaddingBottom - zoneMinFrac * tubeUsable;

    final zonePaint = Paint()
      ..color = _kGreen.withAlpha(55)
      ..style = PaintingStyle.fill;
    final zoneRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(
          cx - tubeHalfW + 1, zoneTop, cx + tubeHalfW - 1, zoneBottom),
    );
    canvas.drawRRect(zoneRect, zonePaint);

    // ── Fill (teal liquid) ───────────────────────────────────────────────
    final fillH = (tubePaddingBottom - tubeTop) * fillFraction;
    final fillTop = tubePaddingBottom - fillH;

    final liquidPaint = Paint()
      ..color = _kTeal
      ..style = PaintingStyle.fill;

    if (fillH > 0) {
      final fillRRect = RRect.fromRectAndCorners(
        Rect.fromLTRB(
            cx - tubeHalfW + 1, fillTop, cx + tubeHalfW - 1, tubePaddingBottom),
        topLeft: Radius.circular(fillH > 10 ? 6 : 0),
        topRight: Radius.circular(fillH > 10 ? 6 : 0),
      );
      canvas.drawRRect(fillRRect, liquidPaint);
    }

    // Bulb fill (always full teal when any temp present)
    final bulbFillPaint = Paint()
      ..color = fillFraction > 0 ? _kTeal : _kCharcoal.withAlpha(30)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, bulbCy), bulbRadius - 2, bulbFillPaint);

    // Bulb highlight
    canvas.drawCircle(
      Offset(cx - bulbRadius * 0.25, bulbCy - bulbRadius * 0.25),
      bulbRadius * 0.22,
      Paint()
        ..color = Colors.white.withAlpha(120)
        ..style = PaintingStyle.fill,
    );

    // ── Tube outline stroke ──────────────────────────────────────────────
    final outlinePaint = Paint()
      ..color = _kCharcoal.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(tubeOuter, outlinePaint);
    canvas.drawCircle(Offset(cx, bulbCy), bulbRadius, outlinePaint);

    // ── Tick marks on the tube ───────────────────────────────────────────
    final tickPaint = Paint()
      ..color = _kCharcoal.withAlpha(60)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (var t = gaugeMin; t <= gaugeMax; t += 2) {
      final frac = (t - gaugeMin) / (gaugeMax - gaugeMin);
      final ty = tubePaddingBottom - frac * tubeUsable;
      final isMajor = t % 4 == 0;
      final tickLength = isMajor ? 7.0 : 4.0;
      canvas.drawLine(
        Offset(cx + tubeHalfW - 1, ty),
        Offset(cx + tubeHalfW + tickLength - 1, ty),
        tickPaint..strokeWidth = isMajor ? 1.5 : 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ThermometerPainter old) =>
      old.fillFraction != fillFraction;
}

// ── SparklinePainter ──────────────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  final List<double> data;

  const _SparklinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).abs();
    final safeRange = range < 0.5 ? 1.0 : range;

    double xOf(int i) => size.width * i / (data.length - 1);
    double yOf(double v) =>
        size.height - (size.height * (v - minV) / safeRange).clamp(4, size.height - 4);

    // Fill
    final fillPath = Path();
    fillPath.moveTo(xOf(0), size.height);
    for (var i = 0; i < data.length; i++) {
      fillPath.lineTo(xOf(i), yOf(data[i]));
    }
    fillPath.lineTo(xOf(data.length - 1), size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kTeal.withAlpha(80), _kTeal.withAlpha(10)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // Line
    final linePath = Path();
    linePath.moveTo(xOf(0), yOf(data[0]));
    for (var i = 1; i < data.length; i++) {
      // Smooth with simple catmull-rom shortcut
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
        ..color = _kTeal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (var i = 0; i < data.length; i++) {
      canvas.drawCircle(
        Offset(xOf(i), yOf(data[i])),
        3.5,
        Paint()..color = _kTealDark,
      );
      canvas.drawCircle(
        Offset(xOf(i), yOf(data[i])),
        2.0,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.data != data;
}
