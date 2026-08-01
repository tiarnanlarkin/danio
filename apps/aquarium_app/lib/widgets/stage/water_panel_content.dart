// Barrel re-export — keep the original import path working.
export 'water_quality/water_param_card.dart';
export 'water_quality/water_health_card.dart';
export 'water_quality/water_sparkline.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/log_entry.dart';
import '../../providers/tank_provider.dart';
import '../../navigation/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import 'stage_provider.dart';
import 'water_quality/water_health_card.dart';
import 'water_quality/water_hybrid_instrument.dart';
import 'water_quality/water_param_card.dart';

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

class _WaterPanelContentState extends ConsumerState<WaterPanelContent> {
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

    final test = latestTestAsync.hasValue ? latestTestAsync.value : null;
    final lastEntry = latestEntryAsync.hasValue ? latestEntryAsync.value : null;
    final recentLogs = logsAsync.when(
      data: (logs) => logs,
      loading: () => <LogEntry>[],
      error: (_, _) => <LogEntry>[],
    );

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
    final dataUnavailable =
        latestTestAsync.hasError || latestEntryAsync.hasError;
    final historyUnavailable = logsAsync.hasError;
    final sparkPh = _buildSparkData(recentLogs, 'ph');
    final sparkNO3 = _buildSparkData(recentLogs, 'nitrate');

    return SingleChildScrollView(
      key: const ValueKey('water-panel-scroll'),
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useHybrid =
              MediaQuery.textScalerOf(context).scale(1) <= 1.2 &&
              constraints.maxWidth >= WaterHybridInstrument.designWidth;
          if (useHybrid) {
            return WaterHybridInstrument(
              params: params,
              health: health,
              lastEntry: lastEntry,
              phHistory: sparkPh,
              nitrateHistory: sparkNO3,
              dataUnavailable: dataUnavailable,
              historyUnavailable: historyUnavailable,
              formatTimestamp: _formatTimestamp,
              onLog: () {
                ref.read(stageProvider.notifier).close(StagePanel.waterQuality);
                AppRoutes.toAddLog(
                  context,
                  widget.tankId,
                  initialType: LogType.waterTest,
                );
              },
            );
          }
          return _WaterResponsivePanel(
            params: params,
            health: health,
            lastEntry: lastEntry,
            dataUnavailable: dataUnavailable,
            historyUnavailable: historyUnavailable,
            formatTimestamp: _formatTimestamp,
            onLog: () {
              ref.read(stageProvider.notifier).close(StagePanel.waterQuality);
              AppRoutes.toAddLog(
                context,
                widget.tankId,
                initialType: LogType.waterTest,
              );
            },
          );
        },
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

/// Readable native fallback for large text and drawers narrower than the
/// 220dp authored hybrid coordinate system.
class _WaterResponsivePanel extends StatelessWidget {
  final List<WqParamSpec> params;
  final WqHealthStatus health;
  final LogEntry? lastEntry;
  final bool dataUnavailable;
  final bool historyUnavailable;
  final String Function(DateTime) formatTimestamp;
  final VoidCallback onLog;

  const _WaterResponsivePanel({
    required this.params,
    required this.health,
    required this.lastEntry,
    required this.dataUnavailable,
    required this.historyUnavailable,
    required this.formatTimestamp,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Water Quality',
          style: AppTypography.titleLarge.copyWith(
            color: kWqCharcoal,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (dataUnavailable)
          const _WaterResponsiveNotice(
            label: 'Water test data unavailable',
            detail: 'Check the local test log or add a new manual test.',
          )
        else
          _WaterResponsiveNotice(
            label: wqHealthLabel(health),
            detail: lastEntry == null
                ? 'No manual water test logged yet.'
                : 'Last manual test: ${formatTimestamp(lastEntry!.timestamp)}',
            accent: wqHealthColor(health),
          ),
        const SizedBox(height: AppSpacing.md),
        for (final param in params) ...[
          _WaterResponsiveParameter(param: param),
          const SizedBox(height: AppSpacing.sm),
        ],
        _WaterResponsiveNotice(
          label: historyUnavailable
              ? 'History unavailable'
              : 'Seven-day local history',
          detail: historyUnavailable
              ? 'The manual-log history could not be read.'
              : 'pH and nitrate use only logged water-test entries.',
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 52,
          child: Semantics(
            label: 'Log Water Test',
            button: true,
            onTap: onLog,
            child: ExcludeSemantics(
              child: OutlinedButton.icon(
                key: const ValueKey('water-responsive-log-test-action'),
                onPressed: onLog,
                icon: const Icon(Icons.science_outlined),
                label: const Text('Log Water Test'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kWqCharcoal,
                  side: const BorderSide(color: kWqAmber, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WaterResponsiveNotice extends StatelessWidget {
  final String label;
  final String detail;
  final Color accent;

  const _WaterResponsiveNotice({
    required this.label,
    required this.detail,
    this.accent = kWqCharcoal,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label. $detail',
      readOnly: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.titleSmall.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(detail, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaterResponsiveParameter extends StatelessWidget {
  final WqParamSpec param;

  const _WaterResponsiveParameter({required this.param});

  @override
  Widget build(BuildContext context) {
    final value = param.value == null
        ? '—'
        : (param.value! == param.value!.roundToDouble()
              ? param.value!.toStringAsFixed(0)
              : param.value!.toStringAsFixed(2));
    return Semantics(
      label:
          '${param.label}, $value ${param.unit}, expected ${param.idealRange}, ${wqStatusLabel(param.status)}',
      readOnly: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            border: Border.all(
              color: wqStatusColor(param.status).withValues(alpha: 0.45),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  param.label,
                  style: AppTypography.titleSmall.copyWith(
                    color: kWqCharcoal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$value ${param.unit}'.trim(),
                  style: AppTypography.headlineSmall.copyWith(
                    color: wqStatusColor(param.status),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Expected ${param.idealRange}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
