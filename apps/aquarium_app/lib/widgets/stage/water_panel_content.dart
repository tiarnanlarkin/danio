// Barrel re-export — keep the original import path working.
export 'water_quality/water_param_card.dart';
export 'water_quality/water_health_card.dart';
export 'water_quality/water_sparkline.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/log_entry.dart';
import '../../providers/tank_provider.dart';
import '../../screens/add_log_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import 'stage_provider.dart';
import 'water_quality/water_health_card.dart';
import 'water_quality/water_param_card.dart';
import 'water_quality/water_sparkline.dart';

// ── Colour constants ──────────────────────────────────────────────────────────
// _kCream removed — panels now use theme-derived gradient backgrounds

// ── Panel Content ─────────────────────────────────────────────────────────────

/// Content for the right (water quality) Swiss Army panel.
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableMotion = MediaQuery.of(context).disableAnimations;
    _ringAnim.duration = disableMotion ? Duration.zero : const Duration(milliseconds: 900);
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
      WqParamSpec(
        key: 'pH',
        label: 'pH',
        unit: '',
        idealRange: '6.5 – 7.8',
        value: ph,
        status: wqPhStatus(ph),
      ),
      WqParamSpec(
        key: 'NH₃',
        label: 'Ammonia',
        unit: 'ppm',
        idealRange: '< 0.25 ppm',
        value: ammonia,
        status: wqAmmoniaStatus(ammonia),
      ),
      WqParamSpec(
        key: 'NO₂',
        label: 'Nitrite',
        unit: 'ppm',
        idealRange: '0 ppm',
        value: nitrite,
        status: wqNitriteStatus(nitrite),
      ),
      WqParamSpec(
        key: 'NO₃',
        label: 'Nitrate',
        unit: 'ppm',
        idealRange: '< 20 ppm',
        value: nitrate,
        status: wqNitrateStatus(nitrate),
      ),
      WqParamSpec(
        key: 'GH',
        label: 'GH',
        unit: 'dGH',
        idealRange: '4 – 12 dGH',
        value: gh,
        status: wqGhStatus(gh),
      ),
      WqParamSpec(
        key: 'KH',
        label: 'KH',
        unit: 'dKH',
        idealRange: '3 – 8 dKH',
        value: kh,
        status: wqKhStatus(kh),
      ),
    ];

    final health = wqComputeHealth(params.map((p) => p.status).toList());
    final allPerfect =
        health == WqHealthStatus.excellent &&
        params.any((p) => p.status != WqParamStatus.unknown);

    final sparkPh = _buildSparkData(recentLogs, 'ph');
    final sparkNO3 = _buildSparkData(recentLogs, 'nitrate');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.theme.glassCard.withValues(alpha: 0.95),
            widget.theme.glassCard.withValues(alpha: 0.85),
          ],
        ),
      ),
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
            _WqHeader(theme: widget.theme),
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
                      color: kWqCharcoal.withAlpha(100),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Last tested: ${_formatTimestamp(lastEntry.timestamp)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: kWqCharcoal.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Health score ring ────────────────────────────────────────
            WqHealthScoreCard(health: health, ringAnim: _ringAnim),
            const SizedBox(height: AppSpacing.md),

            // ── Perfect! celebration badge ───────────────────────────────
            if (allPerfect) ...[
              const WqPerfectBadge(),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Parameter cards (2-column grid) ─────────────────────────
            WqParamGrid(params: params),
            const SizedBox(height: AppSpacing.md),

            // ── Sparklines (pH + Nitrate trend) ─────────────────────────
            if (sparkPh.length >= 2 || sparkNO3.length >= 2) ...[
              WqSparklineSection(phData: sparkPh, nitData: sparkNO3),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Log Water Test button ────────────────────────────────────
            _WqLogButton(tankId: widget.tankId),
          ],
        ),
      ),
    );
  }

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

class _WqHeader extends StatelessWidget {
  final RoomTheme theme;

  const _WqHeader({required this.theme});

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
          style: AppTypography.titleMedium.copyWith(color: kWqCharcoal),
        ),
      ],
    );
  }
}

// ── Log Button ────────────────────────────────────────────────────────────────

class _WqLogButton extends ConsumerWidget {
  final String tankId;

  const _WqLogButton({required this.tankId});

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
              builder: (_) => AddLogScreen(
                tankId: tankId,
                initialType: LogType.waterTest,
              ),
            ),
          );
        },
        icon: const Icon(Icons.science_rounded, size: 20),
        label: Text('Log Water Test', style: AppTypography.labelLarge),
        style: ElevatedButton.styleFrom(
          backgroundColor: kWqAmber,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
          textStyle: AppTypography.labelLarge,
        ),
      ),
    );
  }
}
