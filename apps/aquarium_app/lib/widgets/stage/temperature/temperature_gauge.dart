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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  key: const ValueKey('temperature-gauge-housing'),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.78),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color(
                          0xFFC89B3C,
                        ).withValues(alpha: 0.22),
                        blurRadius: 9,
                      ),
                    ],
                  ),
                  child: BrassGauge(
                    temp: temp,
                    gaugeMin: gaugeMin,
                    gaugeMax: gaugeMax,
                    optimalMin: optimalMin,
                    optimalMax: optimalMax,
                    showCenterLabel: false,
                  ),
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
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                if (optimalMin != null && optimalMax != null)
                  TempOptimalRangeRow(min: optimalMin!, max: optimalMax!),
              ],
            ),
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
    return DecoratedBox(
      key: const ValueKey('temperature-status-lamps'),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C0C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFC89B3C).withValues(alpha: 0.56),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatusLamp(label: 'LOW', color: kTempTealLight, active: lowActive),
            _StatusLamp(
              label: 'TARGET',
              color: kTempTeal,
              active: targetActive,
            ),
            _StatusLamp(label: 'HIGH', color: kTempRedWarn, active: highActive),
          ],
        ),
      ),
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
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.35),
              colors: active
                  ? [
                      Colors.white,
                      color,
                      color.withValues(alpha: 0.82),
                      const Color(0xFF111313),
                    ]
                  : const [
                      Color(0xFF4B3330),
                      Color(0xFF220909),
                      Color(0xFF080909),
                    ],
              stops: active ? const [0, 0.18, 0.6, 1] : const [0, 0.56, 1],
            ),
            border: Border.all(
              color: const Color(0xFFC89B3C).withValues(alpha: 0.7),
              width: 1.4,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.72),
                      blurRadius: 12,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.7),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: kTempCream.withValues(alpha: active ? 0.94 : 0.58),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
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
        ? '--°C'
        : '${temperature!.toStringAsFixed(1)}°C';
    return Container(
      key: const ValueKey('temperature-manual-readout'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF272B2B), Color(0xFF080A0A)],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFC89B3C).withValues(alpha: 0.8),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.68),
            blurRadius: 7,
            offset: const Offset(0, 4),
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
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs2,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF120B02), Color(0xFF301B02)],
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF8D5B13),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: kTempAmberGold.withValues(alpha: 0.24),
                  blurRadius: 9,
                ),
              ],
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: AppTypography.headlineLarge.copyWith(
                color: const Color(0xFFFFC548),
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                fontSize: 28,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: kTempAmberGold.withValues(alpha: 0.82),
                    blurRadius: 9,
                  ),
                ],
              ),
            ),
          ),
          if (lastEntry != null)
            Text(
              'Last logged ${formatTimestamp(lastEntry!.timestamp)}',
              style: AppTypography.labelSmall.copyWith(
                color: kTempCream.withValues(alpha: 0.78),
                fontSize: 9.5,
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
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF272A2A), Color(0xFF101212)],
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xFFC89B3C).withValues(alpha: 0.52),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: kTempTeal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kTempTeal.withValues(alpha: 0.55),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          Text(
            'Optimal ${_formatTemperatureValue(min)}–'
            '${_formatTemperatureValue(max)}°C',
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: kTempCream.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.3,
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
    final (statusColor, label) = switch (status) {
      TempStatus.perfect => (kTempTeal, 'Within target'),
      TempStatus.warm => (kTempAmberWarn, 'A little warm'),
      TempStatus.cool => (kTempAmberWarn, 'A little cool'),
      TempStatus.tooHot => (kTempRedWarn, 'Too hot'),
      TempStatus.tooCold => (kTempRedWarn, 'Too cold'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D3030), Color(0xFF111313)],
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.76),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.52),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.55),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: kTempCream.withValues(alpha: 0.92),
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.4,
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
