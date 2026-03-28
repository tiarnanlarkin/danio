import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

// ── Colour constants ──────────────────────────────────────────────────────────
const kWqCharcoal = Color(0xFF2D3436);
const kWqGreen = Color(0xFF1E8449);
const kWqAmber = Color(0xFFC99524);
const kWqRed = Color(0xFFC0392B);
const kWqGrey = Color(0xFF9E9E9E);

const kWqGreenBg = Color(0x1F1E8449);
const kWqAmberBg = Color(0x1FC99524);
const kWqRedBg = Color(0x1FC0392B);
const kWqGreyBg = Color(0x1F9E9E9E);

const kWqGreenBorder = Color(0x661E8449);
const kWqAmberBorder = Color(0x66C99524);
const kWqRedBorder = Color(0x66C0392B);
const kWqGreyBorder = Color(0x669E9E9E);

// ── Parameter status enum ─────────────────────────────────────────────────────
enum WqParamStatus { perfect, watch, danger, unknown }

// ── Parameter spec ────────────────────────────────────────────────────────────
class WqParamSpec {
  final String key;
  final String label;
  final String unit;
  final String idealRange;
  final double? value;
  final WqParamStatus status;

  const WqParamSpec({
    required this.key,
    required this.label,
    required this.unit,
    required this.idealRange,
    required this.value,
    required this.status,
  });
}

// ── Status helpers ────────────────────────────────────────────────────────────

WqParamStatus wqPhStatus(double? v) {
  if (v == null) return WqParamStatus.unknown;
  if (v >= 6.5 && v <= 7.8) return WqParamStatus.perfect;
  if (v >= 6.0 && v <= 8.2) return WqParamStatus.watch;
  return WqParamStatus.danger;
}

WqParamStatus wqAmmoniaStatus(double? v) {
  if (v == null) return WqParamStatus.unknown;
  if (v <= 0.25) return WqParamStatus.perfect;
  if (v <= 0.5) return WqParamStatus.watch;
  return WqParamStatus.danger;
}

WqParamStatus wqNitriteStatus(double? v) {
  if (v == null) return WqParamStatus.unknown;
  if (v <= 0.0) return WqParamStatus.perfect;
  if (v <= 0.25) return WqParamStatus.watch;
  return WqParamStatus.danger;
}

WqParamStatus wqNitrateStatus(double? v) {
  if (v == null) return WqParamStatus.unknown;
  if (v <= 20) return WqParamStatus.perfect;
  if (v <= 40) return WqParamStatus.watch;
  return WqParamStatus.danger;
}

WqParamStatus wqGhStatus(double? v) {
  if (v == null) return WqParamStatus.unknown;
  if (v >= 4 && v <= 12) return WqParamStatus.perfect;
  if (v >= 2 && v <= 20) return WqParamStatus.watch;
  return WqParamStatus.danger;
}

WqParamStatus wqKhStatus(double? v) {
  if (v == null) return WqParamStatus.unknown;
  if (v >= 3 && v <= 8) return WqParamStatus.perfect;
  if (v >= 1 && v <= 15) return WqParamStatus.watch;
  return WqParamStatus.danger;
}

Color wqStatusColor(WqParamStatus s) => switch (s) {
  WqParamStatus.perfect => kWqGreen,
  WqParamStatus.watch => kWqAmber,
  WqParamStatus.danger => kWqRed,
  WqParamStatus.unknown => kWqGrey,
};

Color wqStatusBg(WqParamStatus s) => switch (s) {
  WqParamStatus.perfect => kWqGreenBg,
  WqParamStatus.watch => kWqAmberBg,
  WqParamStatus.danger => kWqRedBg,
  WqParamStatus.unknown => kWqGreyBg,
};

Color wqStatusBorder(WqParamStatus s) => switch (s) {
  WqParamStatus.perfect => kWqGreenBorder,
  WqParamStatus.watch => kWqAmberBorder,
  WqParamStatus.danger => kWqRedBorder,
  WqParamStatus.unknown => kWqGreyBorder,
};

String wqStatusLabel(WqParamStatus s) => switch (s) {
  WqParamStatus.perfect => 'Perfect',
  WqParamStatus.watch => 'Watch',
  WqParamStatus.danger => 'Danger',
  WqParamStatus.unknown => 'No Data',
};

// ── Parameter Grid ────────────────────────────────────────────────────────────

class WqParamGrid extends StatelessWidget {
  final List<WqParamSpec> params;

  const WqParamGrid({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < params.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: WqParamCard(spec: params[i])),
                const SizedBox(width: AppSpacing.sm),
                if (i + 1 < params.length)
                  Expanded(child: WqParamCard(spec: params[i + 1]))
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Parameter Card ────────────────────────────────────────────────────────────

class WqParamCard extends StatelessWidget {
  final WqParamSpec spec;

  const WqParamCard({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final color = wqStatusColor(spec.status);
    final bg = wqStatusBg(spec.status);
    final border = wqStatusBorder(spec.status);

    final displayValue = spec.value != null
        ? spec.value!.toStringAsFixed(spec.value! < 10 ? 2 : 1)
        : '--';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status dot + label row
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  spec.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: kWqCharcoal.withAlpha(160),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Big value
          Text(
            displayValue,
            style: AppTypography.headlineSmall.copyWith(
              color: kWqCharcoal,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          if (spec.unit.isNotEmpty)
            Text(
              spec.unit,
              style: AppTypography.labelSmall.copyWith(
                color: kWqCharcoal.withAlpha(100),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs2,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.pillRadius,
            ),
            child: Text(
              wqStatusLabel(spec.status),
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Ideal range
          Text(
            spec.idealRange,
            style: AppTypography.labelSmall.copyWith(
              color: kWqCharcoal.withAlpha(100),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
