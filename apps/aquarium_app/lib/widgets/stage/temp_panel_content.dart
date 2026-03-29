// Barrel re-export — keep the original import path working.
export 'temperature/temperature_gauge.dart';
export 'temperature/temperature_history.dart';
export 'temperature/heater_status.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/log_entry.dart';
import '../../providers/tank_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import 'temperature/heater_status.dart';
import 'temperature/temperature_gauge.dart';
import 'temperature/temperature_history.dart';

// ── Panel content ─────────────────────────────────────────────────────────────

/// Rich, fully-packed temperature panel for the Swiss Army stage system.
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
  late final AnimationController _fillAnim;

  static const double _defaultOptimalMin = 24.0;
  static const double _defaultOptimalMax = 26.0;
  static const double _gaugeMin = 18.0;
  static const double _gaugeMax = 30.0;

  @override
  void initState() {
    super.initState();
    _fillAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fillAnim.forward(from: 0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableMotion = MediaQuery.of(context).disableAnimations;
    _fillAnim.duration = disableMotion ? Duration.zero : const Duration(milliseconds: 1100);
  }

  @override
  void dispose() {
    _fillAnim.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatTimestamp(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  TempStatus _status(double temp, double optMin, double optMax) {
    if (temp >= optMin && temp <= optMax) return TempStatus.perfect;
    if (temp > optMax) {
      return (temp - optMax) > 2.0 ? TempStatus.tooHot : TempStatus.warm;
    }
    return (optMin - temp) > 2.0 ? TempStatus.tooCold : TempStatus.cool;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final latestTestAsync = ref.watch(latestWaterTestProvider(widget.tankId));
    final latestEntryAsync = ref.watch(
      latestWaterTestEntryProvider(widget.tankId),
    );
    final streakAsync = ref.watch(testStreakProvider(widget.tankId));
    final logsAsync = ref.watch(logsProvider(widget.tankId));
    final heaterAsync = ref.watch(tankHeaterProvider(widget.tankId));

    final temp = latestTestAsync.value?.temperature;
    final lastEntry = latestEntryAsync.value;
    final streak = streakAsync.value ?? 0;

    final heater = heaterAsync.value;
    final optimalMin =
        (heater?.settings?['optimalMin'] as num?)?.toDouble() ??
        _defaultOptimalMin;
    final optimalMax =
        (heater?.settings?['optimalMax'] as num?)?.toDouble() ??
        _defaultOptimalMax;

    final status = temp != null ? _status(temp, optimalMin, optimalMax) : null;

    final recentLogs = logsAsync.value ?? [];
    final sparkData = _buildSparkData(recentLogs);

    final double? minTemp = sparkData.isNotEmpty
        ? sparkData.reduce(math.min)
        : null;
    final double? maxTemp = sparkData.isNotEmpty
        ? sparkData.reduce(math.max)
        : null;
    final double? avgTemp = sparkData.isNotEmpty
        ? sparkData.reduce((a, b) => a + b) / sparkData.length
        : null;

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
          AppSpacing.sm4,
          AppSpacing.md,
          AppSpacing.lg2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TempHeader(streak: streak),
            const SizedBox(height: AppSpacing.sm4),

            TempHeroSection(
              temp: temp,
              fillAnim: _fillAnim,
              gaugeMin: _gaugeMin,
              gaugeMax: _gaugeMax,
              optimalMin: optimalMin,
              optimalMax: optimalMax,
              status: status,
              lastEntry: lastEntry,
              formatTimestamp: _formatTimestamp,
            ),
            const SizedBox(height: AppSpacing.sm4),

            Container(height: 1, color: kTempTeal.withAlpha(40)),
            const SizedBox(height: AppSpacing.sm4),

            TempTrendSection(
              sparkData: sparkData,
              minTemp: minTemp,
              maxTemp: maxTemp,
              avgTemp: avgTemp,
            ),
            const SizedBox(height: AppSpacing.sm4),

            TempLogButton(tankId: widget.tankId),
          ],
        ),
      ),
    );
  }

  List<double> _buildSparkData(List<LogEntry> logs) {
    final now = DateTime.now();
    final result = <double>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final dayLogs = logs.where((l) {
        if (l.type != LogType.waterTest) return false;
        final t = l.waterTest?.temperature;
        if (t == null) return false;
        final ld = DateTime(
          l.timestamp.year,
          l.timestamp.month,
          l.timestamp.day,
        );
        return ld == day;
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (dayLogs.isNotEmpty) {
        result.add(dayLogs.first.waterTest!.temperature!);
      }
    }
    return result;
  }
}
