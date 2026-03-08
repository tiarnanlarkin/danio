import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/log_entry.dart';
import '../../painters/water_vial_painter.dart';
import '../../providers/tank_provider.dart';
import '../../screens/add_log_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import 'stage_provider.dart';

/// Content for the right (water quality) Swiss Army panel.
/// Self-fetches water test data; caller only needs to pass [tankId] and [theme].
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
  late final AnimationController _vialAnim;
  late final AnimationController _bubbleAnim;

  @override
  void initState() {
    super.initState();
    _vialAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bubbleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _vialAnim.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _vialAnim.dispose();
    _bubbleAnim.dispose();
    super.dispose();
  }

  // ── Status helpers ────────────────────────────────────────────────────────

  Color _statusColor(String param, double? value) {
    if (value == null) return const Color(0xFF9E9E9E);
    switch (param) {
      case 'pH':
        if (value >= 6.5 && value <= 7.8) return const Color(0xFF4CAF50);
        if (value >= 6.0 && value <= 8.2) return const Color(0xFFFFA726);
        return const Color(0xFFEF5350);
      case 'NH₃':
        if (value <= 0.25) return const Color(0xFF4CAF50);
        if (value <= 0.5) return const Color(0xFFFFA726);
        return const Color(0xFFEF5350);
      case 'NO₃':
        if (value <= 20) return const Color(0xFF4CAF50);
        if (value <= 40) return const Color(0xFFFFA726);
        return const Color(0xFFEF5350);
      case 'NO₂':
        if (value <= 0) return const Color(0xFF4CAF50);
        if (value <= 0.25) return const Color(0xFFFFA726);
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Determine overall water quality status from worst parameter.
  _WaterStatus _overallStatus(
      double? ph, double? ammonia, double? nitrate, double? nitrite) {
    if (ph == null && ammonia == null && nitrate == null && nitrite == null) {
      return _WaterStatus.unknown;
    }

    bool hasRed = false;
    bool hasYellow = false;

    final phColor = _statusColor('pH', ph);
    final nhColor = _statusColor('NH₃', ammonia);
    final noThreeColor = _statusColor('NO₃', nitrate);
    final noTwoColor = _statusColor('NO₂', nitrite);

    for (final c in [phColor, nhColor, noThreeColor, noTwoColor]) {
      if (c == const Color(0xFFEF5350)) hasRed = true;
      if (c == const Color(0xFFFFA726)) hasYellow = true;
    }

    if (hasRed) return _WaterStatus.action;
    if (hasYellow) return _WaterStatus.check;
    return _WaterStatus.clear;
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
    final latestEntryAsync = ref.watch(latestWaterTestEntryProvider(widget.tankId));

    final ph = latestTestAsync.value?.ph;
    final ammonia = latestTestAsync.value?.ammonia;
    final nitrate = latestTestAsync.value?.nitrate;
    final nitrite = latestTestAsync.value?.nitrite;

    final lastEntry = latestEntryAsync.value;
    final lastTestedStr = lastEntry != null
        ? 'Last tested: ${_formatTimestamp(lastEntry.timestamp)}'
        : 'No tests logged yet';

    final status = _overallStatus(ph, ammonia, nitrate, nitrite);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.water_drop,
                  color: widget.theme.textSecondary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Water Quality',
                style: AppTypography.titleMedium.copyWith(
                  color: widget.theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Last tested ──────────────────────────────────────────────────
          Text(
            lastTestedStr,
            style: AppTypography.bodySmall
                .copyWith(color: widget.theme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Test tubes ───────────────────────────────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([_vialAnim, _bubbleAnim]),
            builder: (context, _) {
              return SizedBox(
                width: double.infinity,
                height: 220,
                child: CustomPaint(
                  painter: WaterVialPainter(
                    phValue: ph,
                    ammoniaValue: ammonia,
                    nitrateValue: nitrate,
                    nitriteValue: nitrite,
                    animationValue:
                        Curves.easeOutCubic.transform(_vialAnim.value),
                    bubbleAnim: _bubbleAnim.value,
                  ),
                ),
              );
            },
          ),

          // ── Value labels ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _VialLabel('pH', ph, _statusColor('pH', ph), widget.theme),
              _VialLabel(
                  'NH₃', ammonia, _statusColor('NH₃', ammonia), widget.theme),
              _VialLabel(
                  'NO₃', nitrate, _statusColor('NO₃', nitrate), widget.theme),
              _VialLabel(
                  'NO₂', nitrite, _statusColor('NO₂', nitrite), widget.theme),
            ],
          ),

          const Spacer(),

          // ── Overall status badge ──────────────────────────────────────────
          if (status != _WaterStatus.unknown)
            _StatusBadge(status: status, theme: widget.theme),

          const SizedBox(height: AppSpacing.sm),

          // ── Log Test button (full-width) ──────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(stageProvider.notifier)
                    .close(StagePanel.waterQuality);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddLogScreen(
                      tankId: widget.tankId,
                      initialType: LogType.waterTest,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.science, size: 18),
              label: const Text('Log Test'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status enum ───────────────────────────────────────────────────────────────

enum _WaterStatus { unknown, clear, check, action }

// ── Status badge widget ───────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _WaterStatus status;
  final RoomTheme theme;

  const _StatusBadge({required this.status, required this.theme});

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, textColor) = switch (status) {
      _WaterStatus.clear => (
          'All Clear ✓',
          const Color(0xFF4CAF50),
          Colors.white
        ),
      _WaterStatus.check => (
          'Check params ⚠️',
          const Color(0xFFFFA726),
          Colors.white
        ),
      _WaterStatus.action => (
          'Action needed 🚨',
          const Color(0xFFEF5350),
          Colors.white
        ),
      _WaterStatus.unknown => ('—', theme.glassCard, theme.textSecondary),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor.withAlpha(38),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: bgColor.withAlpha(100)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.labelMedium.copyWith(color: bgColor),
      ),
    );
  }
}

// ── Vial label widget ─────────────────────────────────────────────────────────

class _VialLabel extends StatelessWidget {
  final String label;
  final double? value;
  final Color statusColor;
  final RoomTheme theme;

  const _VialLabel(this.label, this.value, this.statusColor, this.theme);

  @override
  Widget build(BuildContext context) {
    final displayValue = value != null
        ? value!.toStringAsFixed(value! < 10 ? 1 : 0)
        : '--';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          displayValue,
          style: AppTypography.labelLarge.copyWith(
            color: theme.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }
}
