// dart:ui import removed — BackdropFilter replaced (perf: T-D-270)
// dart:math import removed — _ArcPainter deleted in Task 14

import 'package:flutter/material.dart';

import '../../../models/log_entry.dart';
import '../../../theme/app_theme.dart';
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

String _formatTemperatureValue(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

// ── Status enum ───────────────────────────────────────────────────────────────

enum TempStatus { perfect, warm, cool, tooHot, tooCold }

// ── Hero Section ──────────────────────────────────────────────────────────────

class TempHeroSection extends StatelessWidget {
  final double? temp;
  final AnimationController fillAnim;
  final double gaugeMin;
  final double gaugeMax;
  final double? optimalMin;
  final double? optimalMax;
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
    assert(
      (optimalMin == null && optimalMax == null) ||
          (optimalMin != null &&
              optimalMax != null &&
              optimalMin! <= optimalMax!),
      'optimalMin and optimalMax must both be null or form a valid range',
    );
    assert(
      gaugeMin < gaugeMax,
      'gaugeMin ($gaugeMin) must be < gaugeMax ($gaugeMax)',
    );

    final readingSemantics = temp == null
        ? 'No manually logged temperature yet'
        : 'Latest manually logged temperature ${temp!.toStringAsFixed(1)} degrees Celsius'
              '${lastEntry == null ? '' : ', last logged ${formatTimestamp(lastEntry!.timestamp)}'}';
    final targetSemantics = optimalMin == null || optimalMax == null
        ? 'Temperature target unavailable'
        : 'Saved target ${_formatTemperatureValue(optimalMin!)} to ${_formatTemperatureValue(optimalMax!)} degrees Celsius';
    final statusSemantics = switch (status) {
      TempStatus.perfect => 'Temperature is within the saved target',
      TempStatus.warm => 'Temperature is a little warm',
      TempStatus.cool => 'Temperature is a little cool',
      TempStatus.tooHot => 'Temperature is too hot',
      TempStatus.tooCold => 'Temperature is too cold',
      null => 'Temperature status unavailable',
    };

    return Semantics(
      label: '$readingSemantics. $targetSemantics. $statusSemantics.',
      readOnly: true,
      child: ExcludeSemantics(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.2,
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
            _ManualTemperatureReadout(
              temperature: temp,
              lastEntry: lastEntry,
              formatTimestamp: formatTimestamp,
            ),
            const SizedBox(height: AppSpacing.sm),
            _TemperatureStatusLamps(status: status),
            const SizedBox(height: AppSpacing.xs),
            if (status != null) TempStatusBadge(status: status!),
            if (optimalMin != null && optimalMax != null) ...[
              const SizedBox(height: AppSpacing.xs),
              TempOptimalRangeRow(min: optimalMin!, max: optimalMax!),
            ],
          ],
        ),
      ),
    );
  }
}

class _TemperatureStatusLamps extends StatelessWidget {
  final TempStatus? status;

  const _TemperatureStatusLamps({required this.status});

  @override
  Widget build(BuildContext context) {
    final lowActive = status == TempStatus.cool || status == TempStatus.tooCold;
    final targetActive = status == TempStatus.perfect;
    final highActive = status == TempStatus.warm || status == TempStatus.tooHot;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatusLamp(label: 'LOW', color: kTempTealLight, active: lowActive),
        const SizedBox(width: AppSpacing.md),
        _StatusLamp(label: 'TARGET', color: kTempGreen, active: targetActive),
        const SizedBox(width: AppSpacing.md),
        _StatusLamp(label: 'HIGH', color: kTempRedWarn, active: highActive),
      ],
    );
  }
}

class _StatusLamp extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;

  const _StatusLamp({
    required this.label,
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? color : const Color(0xFF243235),
            border: Border.all(color: kTempCream.withValues(alpha: 0.28)),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.62),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: kTempCream.withValues(alpha: active ? 0.92 : 0.52),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _ManualTemperatureReadout extends StatelessWidget {
  final double? temperature;
  final LogEntry? lastEntry;
  final String Function(DateTime) formatTimestamp;

  const _ManualTemperatureReadout({
    required this.temperature,
    required this.lastEntry,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final value = temperature == null
        ? '--Â°C'
        : '${temperature!.toStringAsFixed(1)}Â°C';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2D09), Color(0xFF221504)],
        ),
        borderRadius: AppRadius.smallRadius,
        border: Border.all(color: kTempAmberGold.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: kTempAmberGold.withValues(alpha: 0.2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'LATEST MANUAL LOG',
            style: AppTypography.labelSmall.copyWith(
              color: kTempCream.withValues(alpha: 0.72),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(
              color: const Color(0xFFFFC861),
              fontWeight: FontWeight.w800,
            ),
          ),
          if (lastEntry != null)
            Text(
              'Last logged ${formatTimestamp(lastEntry!.timestamp)}',
              style: AppTypography.labelSmall.copyWith(
                color: kTempCream.withValues(alpha: 0.78),
              ),
            ),
        ],
      ),
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
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: kTempGreen,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            'Optimal ${_formatTemperatureValue(min)}–'
            '${_formatTemperatureValue(max)}°C',
            textAlign: TextAlign.center,
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
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          Text(
            label,
            textAlign: TextAlign.center,
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
