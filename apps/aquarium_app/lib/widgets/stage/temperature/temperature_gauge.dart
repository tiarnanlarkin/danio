import 'dart:math' as math;
// dart:ui import removed — BackdropFilter replaced (perf: T-D-270)

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../models/log_entry.dart';

// ── Colour constants (shared within temperature package) ─────────────────────
const kTempTeal = Color(0xFF3BBFB0);
const kTempTealDark = Color(0xFF2D7A94);
const kTempTealLight = Color(0xFF9ED8EC);
const kTempCharcoal = Color(0xFF2D3436);
const kTempGreen = Color(0xFF1E8449);
const kTempAmberWarn = Color(0xFFC99524);
const kTempRedWarn = Color(0xFFC0392B);
const kTempAmberGold = Color(0xFFD97706);
const kTempCream = Color(0xFFFFF8F0);

// ── Status enum ───────────────────────────────────────────────────────────────

enum TempStatus { perfect, warm, cool, tooHot, tooCold }

// ── Hero Section ──────────────────────────────────────────────────────────────

class TempHeroSection extends StatelessWidget {
  final double? temp;
  final AnimationController fillAnim;
  final double gaugeMin;
  final double gaugeMax;
  final double optimalMin;
  final double optimalMax;
  final TempStatus? status;
  final LogEntry? lastEntry;
  final String Function(DateTime) formatTimestamp;

  const TempHeroSection({
    super.key,
    required this.temp,
    required this.fillAnim,
    required this.gaugeMin,
    required this.gaugeMax,
    required this.optimalMin,
    required this.optimalMax,
    required this.status,
    required this.lastEntry,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed thermometer dimensions — nice and large
    const thermW = 56.0;
    const thermH = 300.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Large thermometer ────────────────────────────────────────────
        SizedBox(
          width: thermW,
          height: thermH,
          child: AnimatedBuilder(
            animation: fillAnim,
            builder: (context, _) {
              final fillFraction = temp != null
                  ? ((temp! - gaugeMin) / (gaugeMax - gaugeMin)).clamp(0.0, 1.0)
                  : 0.0;
              final animatedFill =
                  Curves.easeOutCubic.transform(fillAnim.value) * fillFraction;
              return CustomPaint(
                painter: ThermometerPainter(
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

        const SizedBox(width: 8),

        // ── Scale labels on the LEFT of gauge ───────────────────────────
        SizedBox(
          width: 28,
          height: thermH,
          child: TempScaleLabels(gaugeMin: gaugeMin, gaugeMax: gaugeMax),
        ),

        const SizedBox(width: 12),

        // ── Right column: big temp + badge + info ────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Big temp display with fish emoji
              Text(
                temp != null ? '🐟 ${temp!.toStringAsFixed(1)}°C' : '🐟 --°C',
                style: AppTypography.headlineLarge.copyWith(
                  color: temp != null ? kTempCharcoal : kTempCharcoal.withAlpha(100),
                  fontWeight: FontWeight.w800,
                  fontSize: 42,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                temp != null ? 'current temperature' : 'no data yet',
                style: AppTypography.labelSmall.copyWith(
                  color: kTempCharcoal.withAlpha(110),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.sm4),

              // Status badge
              if (status != null) TempStatusBadge(status: status!),

              const SizedBox(height: AppSpacing.sm4),

              // Optimal range indicator
              TempOptimalRangeRow(min: optimalMin, max: optimalMax),
              const SizedBox(height: AppSpacing.sm2),

              // Fish decorations
              const TempFishDecorations(),
              const SizedBox(height: AppSpacing.sm2),

              // Last logged timestamp
              if (lastEntry != null)
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: kTempCharcoal.withAlpha(100),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last logged: ${formatTimestamp(lastEntry!.timestamp)}',
                      style: AppTypography.labelSmall.copyWith(
                        color: kTempCharcoal.withAlpha(120),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Scale Labels ──────────────────────────────────────────────────────────────

class TempScaleLabels extends StatelessWidget {
  final double gaugeMin;
  final double gaugeMax;

  const TempScaleLabels({
    super.key,
    required this.gaugeMin,
    required this.gaugeMax,
  });

  @override
  Widget build(BuildContext context) {
    final labels = <double>[];
    for (var t = gaugeMax; t >= gaugeMin; t -= 2) {
      labels.add(t);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        const bulbRadius = 20.0;
        const tubeTopPad = 16.0;
        final bulbCy = h - bulbRadius - 4;
        final tubeBotY = bulbCy - bulbRadius - 2;
        const tubeTopY = tubeTopPad;
        final usableH = tubeBotY - tubeTopY;

        return Stack(
          children: List.generate(labels.length, (i) {
            final t = labels[i];
            final frac = (t - gaugeMin) / (gaugeMax - gaugeMin);
            final y = tubeTopY + usableH * (1.0 - frac) - 7;
            final isMajor = t % 4 == 0;
            return Positioned(
              top: y,
              right: 0,
              child: Text(
                '${t.toInt()}°',
                style: AppTypography.labelSmall.copyWith(
                  color: isMajor
                      ? kTempCharcoal.withAlpha(180)
                      : kTempCharcoal.withAlpha(110),
                  fontSize: isMajor ? 10 : 9,
                  fontWeight: isMajor ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Optimal Range Row ─────────────────────────────────────────────────────────

class TempOptimalRangeRow extends StatelessWidget {
  final double min;
  final double max;

  const TempOptimalRangeRow({super.key, required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm3,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: kTempGreen.withAlpha(20),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: kTempGreen.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: kTempGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Optimal ${min.toInt()}–${max.toInt()}°C',
            style: AppTypography.labelSmall.copyWith(
              color: kTempGreen,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fish Decorations ──────────────────────────────────────────────────────────

class TempFishDecorations extends StatelessWidget {
  const TempFishDecorations({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TempFishChip(label: '🐟', opacity: 1.0),
        const SizedBox(width: 6),
        TempFishChip(label: '🐠', opacity: 0.85),
        const SizedBox(width: 6),
        TempFishChip(label: '🐡', opacity: 0.7),
      ],
    );
  }
}

class TempFishChip extends StatelessWidget {
  final String label;
  final double opacity;

  const TempFishChip({super.key, required this.label, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: kTempTeal.withAlpha(25),
          shape: BoxShape.circle,
          border: Border.all(color: kTempTeal.withAlpha(60)),
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTypography.titleSmall),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class TempStatusBadge extends StatelessWidget {
  final TempStatus status;

  const TempStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bgColor, label, icon) = switch (status) {
      TempStatus.perfect => (kTempGreen, 'Perfect!', '🐟'),
      TempStatus.warm => (kTempAmberWarn, 'A little warm', '☀️'),
      TempStatus.cool => (kTempAmberWarn, 'A little cool', '❄️'),
      TempStatus.tooHot => (kTempRedWarn, 'Too hot!', '🔥'),
      TempStatus.tooCold => (kTempRedWarn, 'Too cold!', '🥶'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: bgColor.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ThermometerPainter ────────────────────────────────────────────────────────

/// Large thermometer CustomPainter.
class ThermometerPainter extends CustomPainter {
  final double fillFraction; // 0.0 – 1.0
  final double optimalMin;
  final double optimalMax;
  final double gaugeMin;
  final double gaugeMax;

  const ThermometerPainter({
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

    const bulbRadius = 20.0;
    const tubeHalfW = 13.0;
    const tubeTopRadius = 13.0;
    const tubeTopPad = 16.0;
    final cx = w / 2;
    final bulbCy = h - bulbRadius - 4;
    final tubeBotY = bulbCy - bulbRadius - 2;
    const tubeTopY = tubeTopPad;
    final tubeUsable = tubeBotY - tubeTopY;

    // Background fill (light grey tube)
    final bgPaint = Paint()
      ..color = kTempCharcoal.withAlpha(15)
      ..style = PaintingStyle.fill;

    final tubeRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        cx - tubeHalfW,
        tubeTopY,
        tubeHalfW * 2,
        tubeBotY - tubeTopY,
      ),
      topLeft: const Radius.circular(tubeTopRadius),
      topRight: const Radius.circular(tubeTopRadius),
    );
    canvas.drawRRect(tubeRect, bgPaint);
    canvas.drawCircle(Offset(cx, bulbCy), bulbRadius, bgPaint);

    // Optimal zone overlay
    final zoneMinFrac = (optimalMin - gaugeMin) / (gaugeMax - gaugeMin);
    final zoneMaxFrac = (optimalMax - gaugeMin) / (gaugeMax - gaugeMin);
    final zoneTop = tubeBotY - zoneMaxFrac * tubeUsable;
    final zoneBot = tubeBotY - zoneMinFrac * tubeUsable;

    final zonePaint = Paint()
      ..color = kTempGreen.withAlpha(55)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(cx - tubeHalfW + 2, zoneTop, cx + tubeHalfW - 2, zoneBot),
      ),
      zonePaint,
    );

    // "OPT" label inside zone
    final optTP = TextPainter(
      text: TextSpan(
        text: 'OPT',
        style: TextStyle(
          color: kTempGreen.withAlpha(220),
          fontSize: 7,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: tubeHalfW * 2 - 4);
    optTP.paint(
      canvas,
      Offset(cx - optTP.width / 2, (zoneTop + zoneBot) / 2 - optTP.height / 2),
    );

    // Liquid fill (teal gradient)
    final fillH = tubeUsable * fillFraction;
    final fillTopY = tubeBotY - fillH;

    if (fillH > 0) {
      final liquidShader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kTempTealLight, kTempTealDark],
          ).createShader(
            Rect.fromLTRB(
              cx - tubeHalfW + 2,
              fillTopY,
              cx + tubeHalfW - 2,
              tubeBotY,
            ),
          );
      final fillPaint = Paint()
        ..shader = liquidShader
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(
            cx - tubeHalfW + 2,
            fillTopY,
            cx + tubeHalfW - 2,
            tubeBotY,
          ),
          topLeft: Radius.circular(fillH > 10 ? 8 : 0),
          topRight: Radius.circular(fillH > 10 ? 8 : 0),
        ),
        fillPaint,
      );
    }

    // Bulb fill
    canvas.drawCircle(
      Offset(cx, bulbCy),
      bulbRadius - 2,
      Paint()
        ..color = fillFraction > 0 ? kTempTealDark : kTempCharcoal.withAlpha(30)
        ..style = PaintingStyle.fill,
    );
    // Bulb shine
    canvas.drawCircle(
      Offset(cx - bulbRadius * 0.28, bulbCy - bulbRadius * 0.28),
      bulbRadius * 0.2,
      Paint()
        ..color = AppColors.whiteAlpha50
        ..style = PaintingStyle.fill,
    );

    // Tube outline stroke
    final strokePaint = Paint()
      ..color = kTempCharcoal.withAlpha(45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(tubeRect, strokePaint);
    canvas.drawCircle(Offset(cx, bulbCy), bulbRadius, strokePaint);

    // Tick marks (right side of tube)
    for (var t = gaugeMin; t <= gaugeMax; t += 2) {
      final frac = (t - gaugeMin) / (gaugeMax - gaugeMin);
      final ty = tubeBotY - frac * tubeUsable;
      final isMajor = (t.toInt() % 4 == 0);
      final tickLen = isMajor ? 6.0 : 4.0;
      final tickPaint = Paint()
        ..color = kTempCharcoal.withAlpha(isMajor ? 90 : 55)
        ..strokeWidth = isMajor ? 1.5 : 1.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + tubeHalfW - 1, ty),
        Offset(cx + tubeHalfW + tickLen, ty),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ThermometerPainter old) =>
      old.fillFraction != fillFraction ||
      old.optimalMin != optimalMin ||
      old.optimalMax != optimalMax;
}

// ── Coloured Arc Indicator ────────────────────────────────────────────────────

/// A semicircular arc that sweeps from blue (cold) → green (ideal) → red (hot).
/// The current temperature position is marked with a small pointer dot.
class TempArcIndicator extends StatelessWidget {
  final double? temp;
  final double gaugeMin;
  final double gaugeMax;
  final double optimalMin;
  final double optimalMax;
  final Animation<double> fillAnim;

  const TempArcIndicator({
    super.key,
    required this.temp,
    required this.gaugeMin,
    required this.gaugeMax,
    required this.optimalMin,
    required this.optimalMax,
    required this.fillAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fillAnim,
      builder: (context, _) {
        final fraction = temp != null
            ? ((temp! - gaugeMin) / (gaugeMax - gaugeMin)).clamp(0.0, 1.0)
            : null;
        final animFraction = fraction != null
            ? Curves.easeOutCubic.transform(fillAnim.value) * fraction
            : null;
        return CustomPaint(
          painter: _ArcPainter(
            tempFraction: animFraction,
            optFracMin: (optimalMin - gaugeMin) / (gaugeMax - gaugeMin),
            optFracMax: (optimalMax - gaugeMin) / (gaugeMax - gaugeMin),
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double? tempFraction;
  final double optFracMin;
  final double optFracMax;

  const _ArcPainter({
    required this.tempFraction,
    required this.optFracMin,
    required this.optFracMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height * 0.88);
    final radius = size.width * 0.44;
    const startAngle = math.pi; // left side
    const sweepAngle = math.pi; // half circle

    // Track background
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = kTempCharcoal.withAlpha(18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    // Gradient arc: blue → green → red
    final gradientShader = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        Color(0xFF3B9FE0), // cold blue
        Color(0xFF3B9FE0),
        Color(0xFF1E8449), // ideal green
        Color(0xFFE8B800), // warm amber
        Color(0xFFC0392B), // hot red
      ],
      stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
    ).createShader(Rect.fromCircle(center: centre, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = gradientShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    // Pointer dot at current temperature position
    if (tempFraction != null) {
      final angle = startAngle + sweepAngle * tempFraction!;
      final dx = centre.dx + radius * math.cos(angle);
      final dy = centre.dy + radius * math.sin(angle);
      canvas.drawCircle(
        Offset(dx, dy),
        7,
        Paint()..color = Colors.white..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(dx, dy),
        7,
        Paint()
          ..color = kTempCharcoal.withAlpha(80)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.tempFraction != tempFraction;
}

// ── Pulsing Glow ──────────────────────────────────────────────────────────────

/// Wraps [child] in a gentle pulsing green glow when [active] is true.
/// Respects reduced motion — shows static glow when animations disabled.
class TempPulsingGlow extends StatefulWidget {
  final bool active;
  final Widget child;

  const TempPulsingGlow({super.key, required this.active, required this.child});

  @override
  State<TempPulsingGlow> createState() => _TempPulsingGlowState();
}

class _TempPulsingGlowState extends State<TempPulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.largeRadius,
          boxShadow: [
            BoxShadow(
              color: kTempGreen.withAlpha(60),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: widget.child,
      );
    }
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.largeRadius,
            boxShadow: [
              BoxShadow(
                color: kTempGreen.withAlpha((30 + 50 * _pulse.value).round()),
                blurRadius: 12 + 12 * _pulse.value,
                spreadRadius: _pulse.value * 3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ── Glass Panel Container ─────────────────────────────────────────────────────

/// Glassmorphism container for the temperature panel.
/// Blur sigma 8, white 12% fill, 20px radius.
class TempGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const TempGlassPanel({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51), // 20% fill — slightly brighter without blur
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(
            color: Colors.white.withAlpha(51), // 20% border
            width: 1.0,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ── Slide+Fade Entry Animation ────────────────────────────────────────────────

/// Wraps a panel widget in a slide-from-right + fade entry animation.
/// Duration 300ms, easeOutCubic. Respects reduced motion.
class TempPanelEntryAnimation extends StatefulWidget {
  final Widget child;

  const TempPanelEntryAnimation({super.key, required this.child});

  @override
  State<TempPanelEntryAnimation> createState() =>
      _TempPanelEntryAnimationState();
}

class _TempPanelEntryAnimationState extends State<TempPanelEntryAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.medium4,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0.12, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) return widget.child;
    return SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _fade, child: widget.child),
    );
  }
}
