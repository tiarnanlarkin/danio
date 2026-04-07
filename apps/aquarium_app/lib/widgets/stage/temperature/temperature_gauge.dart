// dart:ui import removed — BackdropFilter replaced (perf: T-D-270)
// dart:math import removed — _ArcPainter deleted in Task 14

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../models/log_entry.dart';
import 'brass_gauge.dart';

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
    // Enforce gauge precondition: optimal range must be inside gauge range
    // and min <= max. This prevents negative-sweep in BrassGaugePainter.
    assert(
      optimalMin <= optimalMax,
      'optimalMin ($optimalMin) must be <= optimalMax ($optimalMax)',
    );
    assert(
      gaugeMin < gaugeMax,
      'gaugeMin ($gaugeMin) must be < gaugeMax ($gaugeMax)',
    );

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: BrassGauge(
              temp: temp,
              gaugeMin: gaugeMin,
              gaugeMax: gaugeMax,
              optimalMin: optimalMin,
              optimalMax: optimalMax,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (status != null) TempStatusBadge(status: status!),
        const SizedBox(height: AppSpacing.xs),
        TempOptimalRangeRow(min: optimalMin, max: optimalMax),
        if (lastEntry != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
      ],
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

// Task 14: Removed legacy TempGlassPanel + TempPanelEntryAnimation — these
// glass/animation wrappers were unused after Tasks 10 and 13 stripped the
// TempPanelContent outer chrome.
