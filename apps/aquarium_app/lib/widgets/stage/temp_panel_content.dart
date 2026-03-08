import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../painters/temp_gauge_painter.dart';
import '../../providers/tank_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';

/// Redesigned temperature panel for the Swiss Army stage panel.
/// Fetches its own data via Riverpod so the caller only needs to pass [tankId].
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
  late final AnimationController _gaugeAnim;
  late final AnimationController _waveAnim;

  // Default optimal range (tropical community fish)
  static const double _optimalMin = 24.0;
  static const double _optimalMax = 26.0;

  @override
  void initState() {
    super.initState();

    _gaugeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _waveAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _gaugeAnim.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _gaugeAnim.dispose();
    _waveAnim.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatTimestamp(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  /// 1–5 heart score based on temperature proximity to optimal range.
  int _heartScore(double temp) {
    if (temp >= _optimalMin && temp <= _optimalMax) return 5;
    if (temp >= _optimalMin - 1 && temp <= _optimalMax + 1) return 4;
    if (temp >= _optimalMin - 2 && temp <= _optimalMax + 2) return 3;
    if (temp >= _optimalMin - 4 && temp <= _optimalMax + 4) return 2;
    return 1;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final latestTestAsync = ref.watch(latestWaterTestProvider(widget.tankId));
    final latestEntryAsync = ref.watch(latestWaterTestEntryProvider(widget.tankId));
    final streakAsync = ref.watch(testStreakProvider(widget.tankId));
    final heaterAsync = ref.watch(tankHeaterProvider(widget.tankId));

    final temp = latestTestAsync.value?.temperature;
    final isInRange = temp != null
        ? (temp >= _optimalMin - 1 && temp <= _optimalMax + 1)
        : null;
    final accentColor =
        (isInRange == false) ? AppColors.error : AppColors.primary;

    // Last reading timestamp
    final lastEntry = latestEntryAsync.value;
    final lastReadingStr = lastEntry != null
        ? _formatTimestamp(lastEntry.timestamp)
        : '--';

    // Heater: extract target temp from settings
    final heater = heaterAsync.value;
    final targetTempRaw = heater?.settings?['targetTemp'];
    final targetTemp = targetTempRaw is num ? targetTempRaw.toDouble() : null;
    final heaterOn = targetTemp != null && temp != null && temp < targetTemp - 0.5;

    // Streak
    final streak = streakAsync.value ?? 0;

    // Heart score
    final hearts = temp != null ? _heartScore(temp) : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.thermostat_rounded, color: accentColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Temperature',
                style: AppTypography.titleMedium
                    .copyWith(color: widget.theme.textPrimary),
              ),
              const Spacer(),
              // Heart score (1–5 filled hearts)
              if (temp != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < hearts ? Icons.favorite : Icons.favorite_border,
                      size: 12,
                      color: i < hearts
                          ? const Color(0xFFE8734A)
                          : widget.theme.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Circular gauge ───────────────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_gaugeAnim, _waveAnim]),
              builder: (context, _) {
                return SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sine wave background (inside gauge circle, behind arc)
                      ClipOval(
                        child: CustomPaint(
                          size: const Size(140, 140),
                          painter: _SineWavePainter(
                            phase: _waveAnim.value * 2 * math.pi,
                          ),
                        ),
                      ),

                      // Gauge arcs + needle
                      CustomPaint(
                        size: const Size(180, 180),
                        painter: TempGaugePainter(
                          temperature: temp ?? 25.0,
                          animationValue: Curves.easeOutBack
                              .transform(_gaugeAnim.value.clamp(0.0, 1.0)),
                          coldColor: const Color(0xFF42A5F5),
                          warmColor: const Color(0xFF66BB6A),
                          hotColor: const Color(0xFFFF9800),
                          dangerColor: const Color(0xFFEF5350),
                          textColor: widget.theme.textPrimary,
                          secondaryTextColor: widget.theme.textSecondary,
                        ),
                      ),

                      // Centre text (on top of wave and arc)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            temp != null
                                ? '${temp.toStringAsFixed(1)}°C'
                                : '--°C',
                            style: AppTypography.headlineMedium.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Current',
                            style: AppTypography.labelSmall
                                .copyWith(color: widget.theme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Data rows ────────────────────────────────────────────────────
          _DataRow(
            label: 'Last reading',
            value: lastReadingStr,
            theme: widget.theme,
          ),
          _HeaterRow(
            heaterFound: heater != null,
            heaterOn: heaterOn,
            theme: widget.theme,
          ),
          _DataRow(
            label: 'Test streak',
            value: streak > 0
                ? '🔥 $streak day${streak == 1 ? '' : 's'}'
                : '—',
            theme: widget.theme,
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Pill badges ──────────────────────────────────────────────────
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _PillBadge(
                label: 'Optimal ${_optimalMin.toInt()}–${_optimalMax.toInt()}°C',
                color: widget.theme.gaugeColor2,
              ),
              _PillBadge(
                label: temp != null ? 'Now ${temp.toStringAsFixed(1)}°C' : 'No reading',
                color: accentColor,
              ),
              if (targetTemp != null)
                _PillBadge(
                  label: 'Target ${targetTemp.toStringAsFixed(1)}°C',
                  color: widget.theme.gaugeColor3,
                ),
            ],
          ),

          const Spacer(),

          // ── Streak card ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm2,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: widget.theme.glassCard,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: widget.theme.glassBorder),
            ),
            child: streak > 0
                ? Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$streak day streak',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'No streak yet — log a reading!',
                    style: AppTypography.bodySmall
                        .copyWith(color: widget.theme.textSecondary),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Private widgets ────────────────────────────────────────────────────────────

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final RoomTheme theme;

  const _DataRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: theme.textSecondary),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: theme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Heater row: shows "Heater: ON ●" or "Heater: OFF ●" or "Heater: —"
class _HeaterRow extends StatelessWidget {
  final bool heaterFound;
  final bool heaterOn;
  final RoomTheme theme;

  const _HeaterRow({
    required this.heaterFound,
    required this.heaterOn,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = heaterFound ? (heaterOn ? 'ON' : 'OFF') : '—';
    final dotColor = heaterFound
        ? (heaterOn ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E))
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Heater',
            style: AppTypography.bodySmall.copyWith(color: theme.textSecondary),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                statusText,
                style: AppTypography.bodySmall.copyWith(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (dotColor != null) ...[
                const SizedBox(width: 5),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _PillBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

// ── Sine wave painter ──────────────────────────────────────────────────────────

class _SineWavePainter extends CustomPainter {
  final double phase; // 0 → 2π

  const _SineWavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x26B45309) // amber at ~15% opacity
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const amplitude = 8.0;
    const frequency = 1.5; // waves across the width

    final path = Path();
    const steps = 60;
    for (var i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y = size.height / 2 +
          amplitude * math.sin(frequency * 2 * math.pi * i / steps + phase);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Second offset wave for depth
    final path2 = Path();
    for (var i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y = size.height / 2 +
          (amplitude * 0.6) *
              math.sin(
                  frequency * 2 * math.pi * i / steps + phase + math.pi * 0.7);
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(
        path2, paint..color = const Color(0x1AB45309));
  }

  @override
  bool shouldRepaint(covariant _SineWavePainter old) => old.phase != phase;
}
