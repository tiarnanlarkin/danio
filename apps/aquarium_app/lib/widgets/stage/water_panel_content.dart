import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/log_entry.dart';
import '../../providers/tank_provider.dart';
import '../../screens/add_log_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import 'stage_provider.dart';

// ── Colour constants ──────────────────────────────────────────────────────────
const _kCream = Color(0xFFFFF5E8);
const _kCharcoal = Color(0xFF2D3436);
const _kGreen = Color(0xFF1E8449);
const _kAmber = Color(0xFFC99524);
const _kRed = Color(0xFFC0392B);
const _kGrey = Color(0xFF9E9E9E);

const _kGreenBg = Color(0x1F1E8449); // ~12%
const _kAmberBg = Color(0x1FC99524);
const _kRedBg = Color(0x1FC0392B);
const _kGreyBg = Color(0x1F9E9E9E);

const _kGreenBorder = Color(0x661E8449); // ~40%
const _kAmberBorder = Color(0x66C99524);
const _kRedBorder = Color(0x66C0392B);
const _kGreyBorder = Color(0x669E9E9E);

// ── Parameter status enum ─────────────────────────────────────────────────────
enum _ParamStatus { perfect, watch, danger, unknown }

// ── Parameter spec ────────────────────────────────────────────────────────────
class _ParamSpec {
  final String key;
  final String label;
  final String unit;
  final String idealRange;
  final double? value;
  final _ParamStatus status;

  const _ParamSpec({
    required this.key,
    required this.label,
    required this.unit,
    required this.idealRange,
    required this.value,
    required this.status,
  });
}

// ── Status helpers ────────────────────────────────────────────────────────────

_ParamStatus _phStatus(double? v) {
  if (v == null) return _ParamStatus.unknown;
  if (v >= 6.5 && v <= 7.8) return _ParamStatus.perfect;
  if (v >= 6.0 && v <= 8.2) return _ParamStatus.watch;
  return _ParamStatus.danger;
}

_ParamStatus _ammoniaStatus(double? v) {
  if (v == null) return _ParamStatus.unknown;
  if (v <= 0.25) return _ParamStatus.perfect;
  if (v <= 0.5) return _ParamStatus.watch;
  return _ParamStatus.danger;
}

_ParamStatus _nitriteStatus(double? v) {
  if (v == null) return _ParamStatus.unknown;
  if (v <= 0.0) return _ParamStatus.perfect;
  if (v <= 0.25) return _ParamStatus.watch;
  return _ParamStatus.danger;
}

_ParamStatus _nitrateStatus(double? v) {
  if (v == null) return _ParamStatus.unknown;
  if (v <= 20) return _ParamStatus.perfect;
  if (v <= 40) return _ParamStatus.watch;
  return _ParamStatus.danger;
}

_ParamStatus _ghStatus(double? v) {
  if (v == null) return _ParamStatus.unknown;
  if (v >= 4 && v <= 12) return _ParamStatus.perfect;
  if (v >= 2 && v <= 20) return _ParamStatus.watch;
  return _ParamStatus.danger;
}

_ParamStatus _khStatus(double? v) {
  if (v == null) return _ParamStatus.unknown;
  if (v >= 3 && v <= 8) return _ParamStatus.perfect;
  if (v >= 1 && v <= 15) return _ParamStatus.watch;
  return _ParamStatus.danger;
}

Color _statusColor(_ParamStatus s) => switch (s) {
  _ParamStatus.perfect => _kGreen,
  _ParamStatus.watch => _kAmber,
  _ParamStatus.danger => _kRed,
  _ParamStatus.unknown => _kGrey,
};

Color _statusBg(_ParamStatus s) => switch (s) {
  _ParamStatus.perfect => _kGreenBg,
  _ParamStatus.watch => _kAmberBg,
  _ParamStatus.danger => _kRedBg,
  _ParamStatus.unknown => _kGreyBg,
};

Color _statusBorder(_ParamStatus s) => switch (s) {
  _ParamStatus.perfect => _kGreenBorder,
  _ParamStatus.watch => _kAmberBorder,
  _ParamStatus.danger => _kRedBorder,
  _ParamStatus.unknown => _kGreyBorder,
};

String _statusLabel(_ParamStatus s) => switch (s) {
  _ParamStatus.perfect => 'Perfect',
  _ParamStatus.watch => 'Watch',
  _ParamStatus.danger => 'Danger',
  _ParamStatus.unknown => 'No Data',
};

// ── Overall health ────────────────────────────────────────────────────────────

enum _HealthStatus { excellent, good, needsAttention, noData }

_HealthStatus _computeHealth(List<_ParamStatus> statuses) {
  final known = statuses.where((s) => s != _ParamStatus.unknown).toList();
  if (known.isEmpty) return _HealthStatus.noData;
  if (known.any((s) => s == _ParamStatus.danger)) {
    return _HealthStatus.needsAttention;
  }
  if (known.any((s) => s == _ParamStatus.watch)) return _HealthStatus.good;
  return _HealthStatus.excellent;
}

String _healthLabel(_HealthStatus h) => switch (h) {
  _HealthStatus.excellent => 'Excellent',
  _HealthStatus.good => 'Good',
  _HealthStatus.needsAttention => 'Needs Attention',
  _HealthStatus.noData => 'No Data',
};

Color _healthColor(_HealthStatus h) => switch (h) {
  _HealthStatus.excellent => _kGreen,
  _HealthStatus.good => _kAmber,
  _HealthStatus.needsAttention => _kRed,
  _HealthStatus.noData => _kGrey,
};

double _healthScore(_HealthStatus h) => switch (h) {
  _HealthStatus.excellent => 1.0,
  _HealthStatus.good => 0.65,
  _HealthStatus.needsAttention => 0.3,
  _HealthStatus.noData => 0.0,
};

// ── Panel Content ─────────────────────────────────────────────────────────────

/// Content for the right (water quality) Swiss Army panel.
/// Redesigned with parameter cards, health score ring, and celebration badge.
/// Keeps all existing Riverpod provider wiring; only the visual layer changed.
class WaterPanelContent extends ConsumerStatefulWidget {
  final String tankId;
  final RoomTheme theme;

  const WaterPanelContent({
    super.key,
    required this.tankId,
    required this.theme,
  });

  @override
  ConsumerState<WaterPanelContent> createState() => _WaterPanelContentState();
}

class _WaterPanelContentState extends ConsumerState<WaterPanelContent>
    with TickerProviderStateMixin {
  late final AnimationController _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _ringAnim.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _ringAnim.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final latestTestAsync = ref.watch(latestWaterTestProvider(widget.tankId));
    final latestEntryAsync = ref.watch(
      latestWaterTestEntryProvider(widget.tankId),
    );
    final logsAsync = ref.watch(logsProvider(widget.tankId));

    final test = latestTestAsync.value;
    final lastEntry = latestEntryAsync.value;
    final recentLogs = logsAsync.value ?? [];

    final ph = test?.ph;
    final ammonia = test?.ammonia;
    final nitrite = test?.nitrite;
    final nitrate = test?.nitrate;
    final gh = test?.gh;
    final kh = test?.kh;

    final params = [
      _ParamSpec(
        key: 'pH',
        label: 'pH',
        unit: '',
        idealRange: '6.5 – 7.8',
        value: ph,
        status: _phStatus(ph),
      ),
      _ParamSpec(
        key: 'NH₃',
        label: 'Ammonia',
        unit: 'ppm',
        idealRange: '< 0.25 ppm',
        value: ammonia,
        status: _ammoniaStatus(ammonia),
      ),
      _ParamSpec(
        key: 'NO₂',
        label: 'Nitrite',
        unit: 'ppm',
        idealRange: '0 ppm',
        value: nitrite,
        status: _nitriteStatus(nitrite),
      ),
      _ParamSpec(
        key: 'NO₃',
        label: 'Nitrate',
        unit: 'ppm',
        idealRange: '< 20 ppm',
        value: nitrate,
        status: _nitrateStatus(nitrate),
      ),
      _ParamSpec(
        key: 'GH',
        label: 'GH',
        unit: 'dGH',
        idealRange: '4 – 12 dGH',
        value: gh,
        status: _ghStatus(gh),
      ),
      _ParamSpec(
        key: 'KH',
        label: 'KH',
        unit: 'dKH',
        idealRange: '3 – 8 dKH',
        value: kh,
        status: _khStatus(kh),
      ),
    ];

    final health = _computeHealth(params.map((p) => p.status).toList());
    final allPerfect =
        health == _HealthStatus.excellent &&
        params.any((p) => p.status != _ParamStatus.unknown);

    // Build 7-day sparkline data per param
    final sparkPh = _buildSparkData(recentLogs, 'ph');
    final sparkNO3 = _buildSparkData(recentLogs, 'nitrate');

    return Container(
      color: _kCream,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────
            _Header(theme: widget.theme),
            const SizedBox(height: AppSpacing.sm),

            // ── Last tested ──────────────────────────────────────────────
            if (lastEntry != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: _kCharcoal.withAlpha(100),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Last tested: ${_formatTimestamp(lastEntry.timestamp)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: _kCharcoal.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Health score ring ────────────────────────────────────────
            _HealthScoreCard(health: health, ringAnim: _ringAnim),
            const SizedBox(height: AppSpacing.md),

            // ── Perfect! celebration badge ───────────────────────────────
            if (allPerfect) ...[
              _PerfectBadge(),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Parameter cards (2-column grid) ─────────────────────────
            _ParamGrid(params: params),
            const SizedBox(height: AppSpacing.md),

            // ── Sparklines (pH + Nitrate trend) ─────────────────────────
            if (sparkPh.length >= 2 || sparkNO3.length >= 2) ...[
              _SparklineSection(phData: sparkPh, nitData: sparkNO3),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Log Water Test button ────────────────────────────────────
            _LogButton(tankId: widget.tankId),
          ],
        ),
      ),
    );
  }

  /// Extract 7-day trend data for a given parameter.
  List<double> _buildSparkData(List<LogEntry> logs, String param) {
    final now = DateTime.now();
    final result = <double>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final dayLogs = logs.where((l) {
        if (l.type != LogType.waterTest) return false;
        final wt = l.waterTest;
        if (wt == null) return false;
        final v = switch (param) {
          'ph' => wt.ph,
          'ammonia' => wt.ammonia,
          'nitrite' => wt.nitrite,
          'nitrate' => wt.nitrate,
          'gh' => wt.gh,
          'kh' => wt.kh,
          _ => null,
        };
        if (v == null) return false;
        final ld = DateTime(
          l.timestamp.year,
          l.timestamp.month,
          l.timestamp.day,
        );
        return ld == day;
      }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (dayLogs.isNotEmpty) {
        final wt = dayLogs.first.waterTest!;
        final v = switch (param) {
          'ph' => wt.ph,
          'ammonia' => wt.ammonia,
          'nitrite' => wt.nitrite,
          'nitrate' => wt.nitrate,
          'gh' => wt.gh,
          'kh' => wt.kh,
          _ => null,
        };
        if (v != null) result.add(v);
      }
    }
    return result;
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final RoomTheme theme;

  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFF3BBFB0),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Water Quality',
          style: AppTypography.titleMedium.copyWith(color: _kCharcoal),
        ),
      ],
    );
  }
}

// ── Health Score Card ─────────────────────────────────────────────────────────

class _HealthScoreCard extends StatelessWidget {
  final _HealthStatus health;
  final AnimationController ringAnim;

  const _HealthScoreCard({required this.health, required this.ringAnim});

  @override
  Widget build(BuildContext context) {
    final color = _healthColor(health);
    final score = _healthScore(health);
    final label = _healthLabel(health);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: color.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 72,
            height: 72,
            child: AnimatedBuilder(
              animation: ringAnim,
              builder: (context, _) {
                final animScore =
                    Curves.easeOutCubic.transform(ringAnim.value) * score;
                return CustomPaint(
                  painter: _ProgressRingPainter(
                    progress: animScore,
                    color: color,
                  ),
                  child: Center(
                    child: Text(
                      health == _HealthStatus.noData
                          ? '--'
                          : '${(score * 100).round()}%',
                      style: AppTypography.labelLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Health',
                  style: AppTypography.bodySmall.copyWith(
                    color: _kCharcoal.withAlpha(120),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppTypography.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  health == _HealthStatus.noData
                      ? 'Log a water test to get started'
                      : health == _HealthStatus.excellent
                      ? 'All parameters in range 🎉'
                      : health == _HealthStatus.good
                      ? 'Some parameters need watching'
                      : 'Action required — check parameters',
                  style: AppTypography.bodySmall.copyWith(
                    color: _kCharcoal.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Perfect Badge ─────────────────────────────────────────────────────────────

class _PerfectBadge extends StatelessWidget {
  const _PerfectBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: _kGreen.withAlpha(100),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🐟', style: TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Perfect!',
            style: AppTypography.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text('✨', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

// ── Parameter Grid ────────────────────────────────────────────────────────────

class _ParamGrid extends StatelessWidget {
  final List<_ParamSpec> params;

  const _ParamGrid({required this.params});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < params.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: _ParamCard(spec: params[i])),
                const SizedBox(width: AppSpacing.sm),
                if (i + 1 < params.length)
                  Expanded(child: _ParamCard(spec: params[i + 1]))
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

class _ParamCard extends StatelessWidget {
  final _ParamSpec spec;

  const _ParamCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(spec.status);
    final bg = _statusBg(spec.status);
    final border = _statusBorder(spec.status);

    final displayValue = spec.value != null
        ? '${spec.value!.toStringAsFixed(spec.value! < 10 ? 2 : 1)}${spec.unit.isNotEmpty ? '' : ''}'
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
                    color: _kCharcoal.withAlpha(160),
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
              color: _kCharcoal,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          if (spec.unit.isNotEmpty)
            Text(
              spec.unit,
              style: AppTypography.labelSmall.copyWith(
                color: _kCharcoal.withAlpha(100),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs2,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.pillRadius,
            ),
            child: Text(
              _statusLabel(spec.status),
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
              color: _kCharcoal.withAlpha(100),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sparkline Section ─────────────────────────────────────────────────────────

class _SparklineSection extends StatelessWidget {
  final List<double> phData;
  final List<double> nitData;

  const _SparklineSection({required this.phData, required this.nitData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm2),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: const Color(0xFF3BBFB0).withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-day trends',
            style: AppTypography.labelSmall.copyWith(
              color: _kCharcoal.withAlpha(140),
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
                    color: _kCharcoal.withAlpha(120),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: CustomPaint(
                      painter: _SparklinePainter(
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
                    color: _kCharcoal.withAlpha(120),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: CustomPaint(
                      painter: _SparklinePainter(data: nitData, color: _kRed),
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

// ── Log Button ────────────────────────────────────────────────────────────────

class _LogButton extends ConsumerWidget {
  final String tankId;

  const _LogButton({required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          ref.read(stageProvider.notifier).close(StagePanel.waterQuality);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  AddLogScreen(tankId: tankId, initialType: LogType.waterTest),
            ),
          );
        },
        icon: const Icon(Icons.science_rounded, size: 20),
        label: Text('Log Water Test', style: AppTypography.labelLarge),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAmber,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),
    );
  }
}

// ── Progress Ring Painter ─────────────────────────────────────────────────────

class _ProgressRingPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color color;

  const _ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = color.withAlpha(30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius),
        startAngle,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Sparkline Painter ─────────────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  const _SparklinePainter({required this.data, required this.color});

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
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.data != data || old.color != color;
}
