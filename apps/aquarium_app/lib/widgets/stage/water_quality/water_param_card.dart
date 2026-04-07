// dart:ui import removed — BackdropFilter replaced (perf: T-D-270)

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'brass_medallion.dart';

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
    // Priority: first 3 params (pH, NH₃, NO₂)
    // Secondary: next 3 (NO₃, GH, KH)
    final priority = params.take(3).toList();
    final secondary = params.skip(3).take(3).toList();

    return Column(
      children: [
        _MedallionRow(params: priority),
        const SizedBox(height: AppSpacing.sm),
        _MedallionRow(params: secondary),
      ],
    );
  }
}

class _MedallionRow extends StatelessWidget {
  final List<WqParamSpec> params;
  const _MedallionRow({required this.params});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: i < params.length
                ? BrassMedallion(
                    label: _shortLabel(params[i].label),
                    value: params[i].value?.toStringAsFixed(
                      (params[i].value ?? 0) < 10 ? 2 : 1,
                    ),
                    unit: params[i].unit,
                    status: params[i].status,
                  )
                : const SizedBox.shrink(),
          ),
          if (i < 2) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }

  String _shortLabel(String long) {
    switch (long) {
      case 'Ammonia':
        return 'NH₃';
      case 'Nitrite':
        return 'NO₂';
      case 'Nitrate':
        return 'NO₃';
      default:
        return long;
    }
  }
}

// Task 14: Removed legacy WqParamCard / _WqStatusBar / _Segment /
// WqGlassPanel / WqPanelEntryAnimation — replaced by BrassMedallion
// (Task 5) and the slim WqParamGrid layout above.
