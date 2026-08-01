// Barrel re-export — keep the original import path working.
export 'temperature/temperature_gauge.dart';
export 'temperature/temperature_history.dart';
export 'temperature/heater_status.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/log_entry.dart';
import '../../models/tank.dart';
import '../../navigation/app_routes.dart';
import '../../providers/tank_provider.dart';
import '../../screens/charts_screen.dart';
import '../../screens/equipment_screen.dart';
import '../../screens/tank_settings_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import '../../utils/app_feedback.dart';
import '../../utils/haptic_feedback.dart';
import '../../utils/navigation_throttle.dart';
import '../danio_bottom_dock.dart';
import 'stage_provider.dart';
import 'temperature/heater_status.dart';
import 'temperature/temperature_gauge.dart';
import 'temperature/temperature_history.dart';

enum _TemperaturePreset { tropical, coldwater, custom }

const Color _temperatureInk = kTempCream;
const Color _temperatureMutedInk = Color(0xFFB4C4C4);
const Color _temperatureAccent = kTempTeal;
const Color _temperatureBrass = Color(0xFFC89B3C);
const Color _temperatureInset = Color(0xFF10272B);

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

  _TemperaturePreset? _optimisticPreset;
  bool _savingTarget = false;
  int _targetSaveEpoch = 0;

  static const double _tropicalMin = 24;
  static const double _tropicalMax = 28;
  static const double _coldwaterMin = 15;
  static const double _coldwaterMax = 22;
  static const double _defaultGaugeMin = 18;
  static const double _defaultGaugeMax = 30;

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
    _fillAnim.duration = disableMotion
        ? Duration.zero
        : const Duration(milliseconds: 1100);
  }

  @override
  void didUpdateWidget(covariant TempPanelContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tankId == widget.tankId) return;
    _targetSaveEpoch++;
    _optimisticPreset = null;
    _savingTarget = false;
  }

  @override
  void dispose() {
    _fillAnim.dispose();
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

  TempStatus _status(double temp, double optMin, double optMax) {
    if (temp >= optMin && temp <= optMax) return TempStatus.perfect;
    if (temp > optMax) {
      return (temp - optMax) > 2.0 ? TempStatus.tooHot : TempStatus.warm;
    }
    return (optMin - temp) > 2.0 ? TempStatus.tooCold : TempStatus.cool;
  }

  _TemperaturePreset _presetForTargets(WaterTargets targets) {
    if (targets.tempMin == _tropicalMin && targets.tempMax == _tropicalMax) {
      return _TemperaturePreset.tropical;
    }
    if (targets.tempMin == _coldwaterMin && targets.tempMax == _coldwaterMax) {
      return _TemperaturePreset.coldwater;
    }
    return _TemperaturePreset.custom;
  }

  ({double min, double max}) _gaugeBounds(
    double? temperature,
    double? targetMin,
    double? targetMax,
  ) {
    final lowest = <double>[
      _defaultGaugeMin,
      if (temperature != null) temperature,
      if (targetMin != null) targetMin,
    ].reduce(math.min);
    final highest = <double>[
      _defaultGaugeMax,
      if (temperature != null) temperature,
      if (targetMax != null) targetMax,
    ].reduce(math.max);
    return (
      min: lowest < _defaultGaugeMin ? (lowest - 2).floorToDouble() : lowest,
      max: highest > _defaultGaugeMax ? (highest + 2).ceilToDouble() : highest,
    );
  }

  Future<void> _selectPreset(
    _TemperaturePreset preset,
    Tank? tank,
  ) async {
    final tankId = widget.tankId;
    if (tank == null ||
        tank.id != tankId ||
        preset == _TemperaturePreset.custom ||
        _savingTarget ||
        _presetForTargets(tank.targets) == preset) {
      return;
    }

    final (min, max) = switch (preset) {
      _TemperaturePreset.tropical => (_tropicalMin, _tropicalMax),
      _TemperaturePreset.coldwater => (_coldwaterMin, _coldwaterMax),
      _TemperaturePreset.custom => throw StateError(
        'Custom is a derived target state, not a save action.',
      ),
    };

    setState(() {
      _optimisticPreset = preset;
      _savingTarget = true;
    });
    final saveEpoch = ++_targetSaveEpoch;

    try {
      await ref
          .read(tankActionsProvider)
          .updateTank(
            tank.copyWith(
              targets: tank.targets.copyWith(tempMin: min, tempMax: max),
            ),
          );
    } catch (_) {
      if (!mounted || !_isCurrentTargetSave(tankId, saveEpoch)) return;
      setState(() {
        _optimisticPreset = null;
        _savingTarget = false;
      });
      AppFeedback.showError(
        context,
        "Couldn't update temperature target. Try again.",
      );
      return;
    }

    if (!mounted || !_isCurrentTargetSave(tankId, saveEpoch)) return;
    setState(() => _savingTarget = false);

    try {
      await AppHaptics.selection(context);
    } catch (_) {
      // The target save is already complete; platform feedback is optional.
    }

    if (!_isCurrentTargetSave(tankId, saveEpoch)) return;
    try {
      await ref.read(tankProvider(tankId).future);
    } catch (_) {
      // A later provider error is rendered independently as unavailable.
    }
    if (!_isCurrentTargetSave(tankId, saveEpoch)) return;
    setState(() => _optimisticPreset = null);
  }

  bool _isCurrentTargetSave(String tankId, int saveEpoch) {
    return mounted && widget.tankId == tankId && _targetSaveEpoch == saveEpoch;
  }

  void _closePanel() {
    ref.read(stageProvider.notifier).close(StagePanel.temp);
  }

  void _openLog() {
    _closePanel();
    AppRoutes.toAddLog(
      context,
      widget.tankId,
      initialType: LogType.waterTest,
    );
  }

  void _openCharts() {
    _closePanel();
    unawaited(
      NavigationThrottle.push(
        context,
        ChartsScreen(tankId: widget.tankId, initialParam: 'temp'),
        rootNavigator: true,
      ),
    );
  }

  void _openEquipment() {
    _closePanel();
    unawaited(
      NavigationThrottle.push(
        context,
        EquipmentScreen(tankId: widget.tankId),
        rootNavigator: true,
      ),
    );
  }

  void _openAlerts() {
    _closePanel();
    AppRoutes.toTankDetail(context, widget.tankId);
  }

  void _openSettings() {
    _closePanel();
    unawaited(
      NavigationThrottle.push(
        context,
        TankSettingsScreen(tankId: widget.tankId),
        rootNavigator: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tankAsync = ref.watch(tankProvider(widget.tankId));
    final latestTestAsync = ref.watch(latestWaterTestProvider(widget.tankId));
    final latestEntryAsync = ref.watch(
      latestWaterTestEntryProvider(widget.tankId),
    );
    final streakAsync = ref.watch(testStreakProvider(widget.tankId));
    final logsAsync = ref.watch(logsProvider(widget.tankId));
    final tankData = tankAsync.asData;
    final tank = tankData?.value;
    final targetUnavailable =
        tankAsync.hasError || (tankData != null && tank == null);
    final persistedPreset = tank == null
        ? null
        : _presetForTargets(tank.targets);
    final selectedPreset = targetUnavailable
        ? null
        : (_optimisticPreset ?? persistedPreset);
    final savedTargetMin = tank?.targets.tempMin;
    final savedTargetMax = tank?.targets.tempMax;
    final hasCompleteTarget =
        savedTargetMin != null &&
        savedTargetMax != null &&
        savedTargetMin <= savedTargetMax;
    final targetMin = hasCompleteTarget ? savedTargetMin : null;
    final targetMax = hasCompleteTarget ? savedTargetMax : null;

    final waterTest = latestTestAsync.asData?.value;
    final temp = waterTest?.temperature;
    final streak = streakAsync.asData?.value ?? 0;
    final lastEntry = temp != null ? latestEntryAsync.asData?.value : null;
    final temperatureStreak = temp != null ? streak : 0;
    final status = temp != null && targetMin != null && targetMax != null
        ? _status(temp, targetMin, targetMax)
        : null;
    final gaugeBounds = _gaugeBounds(temp, targetMin, targetMax);

    final recentLogs = logsAsync.asData?.value ?? const <LogEntry>[];
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

    return SingleChildScrollView(
      key: const ValueKey('temperature-panel-scroll'),
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm4,
        AppSpacing.md,
        DanioBottomDock.contentClearance + AppSpacing.md,
      ),
      child: _TemperatureInstrumentChassis(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TempHeader(
                streak: temperatureStreak,
                foregroundColor: _temperatureInk,
              ),
              const SizedBox(height: AppSpacing.sm4),
              _TemperatureTargetSelector(
                targets: tank?.targets,
                selected: selectedPreset,
                isLoading: tankAsync.isLoading,
                isUnavailable: targetUnavailable,
                isSaving: _savingTarget,
                theme: widget.theme,
                onSelect: (preset) => _selectPreset(preset, tank),
              ),
              const SizedBox(height: AppSpacing.md),
              if (latestTestAsync.isLoading)
                _PanelNotice(
                  label: 'Loading temperature…',
                  icon: Icons.hourglass_top_rounded,
                  theme: widget.theme,
                )
              else if (latestTestAsync.hasError)
                _PanelNotice(
                  label: 'Temperature unavailable',
                  icon: Icons.thermostat_outlined,
                  theme: widget.theme,
                )
              else
                TempHeroSection(
                  temp: temp,
                  fillAnim: _fillAnim,
                  gaugeMin: gaugeBounds.min,
                  gaugeMax: gaugeBounds.max,
                  optimalMin: targetMin,
                  optimalMax: targetMax,
                  status: status,
                  lastEntry: lastEntry,
                  formatTimestamp: _formatTimestamp,
                ),
              if (logsAsync.isLoading)
                _PanelNotice(
                  label: 'Loading history…',
                  icon: Icons.show_chart_rounded,
                  theme: widget.theme,
                )
              else if (logsAsync.hasError)
                _PanelNotice(
                  label: 'History unavailable',
                  icon: Icons.show_chart_rounded,
                  theme: widget.theme,
                )
              else
                TempTrendSection(
                  sparkData: sparkData,
                  minTemp: minTemp,
                  maxTemp: maxTemp,
                  avgTemp: avgTemp,
                ),
              const SizedBox(height: AppSpacing.md),
              _TemperatureActionRail(
                theme: widget.theme,
                onLog: _openLog,
                onCharts: _openCharts,
                onEquipment: _openEquipment,
                onAlerts: _openAlerts,
                onSettings: _openSettings,
              ),
            ],
          ),
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
      }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (dayLogs.isNotEmpty) {
        result.add(dayLogs.first.waterTest!.temperature!);
      }
    }
    return result;
  }
}

class _TemperatureInstrumentChassis extends StatelessWidget {
  final Widget child;

  const _TemperatureInstrumentChassis({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('temperature-instrument-chassis'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF28454A), Color(0xFF102A2E), Color(0xFF07181B)],
          stops: [0, 0.54, 1],
        ),
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: _temperatureBrass.withValues(alpha: 0.68)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF020708).withValues(alpha: 0.48),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: kTempTeal.withValues(alpha: 0.14),
            blurRadius: 16,
            spreadRadius: -6,
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: const _TemperatureChassisHardwarePainter(),
        child: child,
      ),
    );
  }
}

class _TemperatureChassisHardwarePainter extends CustomPainter {
  const _TemperatureChassisHardwarePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final seamPaint = Paint()
      ..color = _temperatureBrass.withValues(alpha: 0.38)
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(12, 12),
      Offset(size.width - 12, 12),
      seamPaint,
    );

    final boltPaint = Paint()
      ..color = _temperatureBrass
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 1.5);
    for (final center in [
      const Offset(14, 14),
      Offset(size.width - 14, 14),
      Offset(14, size.height - 14),
      Offset(size.width - 14, size.height - 14),
    ]) {
      canvas.drawCircle(center, 4, boltPaint);
      canvas.drawCircle(
        center,
        1.5,
        Paint()..color = const Color(0xFF4F3914),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _TemperatureChassisHardwarePainter oldDelegate,
  ) => false;
}

class _TemperatureTargetSelector extends StatelessWidget {
  final WaterTargets? targets;
  final _TemperaturePreset? selected;
  final bool isLoading;
  final bool isUnavailable;
  final bool isSaving;
  final RoomTheme theme;
  final ValueChanged<_TemperaturePreset> onSelect;

  const _TemperatureTargetSelector({
    required this.targets,
    required this.selected,
    required this.isLoading,
    required this.isUnavailable,
    required this.isSaving,
    required this.theme,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = isUnavailable
        ? 'Target unavailable'
        : isLoading
        ? 'Loading target…'
        : isSaving
        ? 'Saving target…'
        : 'Saved to this tank';
    final canSelectNamed = !isLoading && !isUnavailable && !isSaving;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _temperatureInset.withValues(alpha: 0.92),
            const Color(0xFF091C20).withValues(alpha: 0.92),
          ],
        ),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: _temperatureBrass.withValues(alpha: 0.42),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: _temperatureAccent,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target range',
                        style: AppTypography.labelLarge.copyWith(
                          color: _temperatureInk,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        statusLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: _temperatureMutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _TargetOption(
              key: const ValueKey('temperature-target-tropical'),
              preset: _TemperaturePreset.tropical,
              label: 'Tropical',
              rangeLabel: '24–28°C',
              selected: selected == _TemperaturePreset.tropical,
              enabled: canSelectNamed,
              onTap: () => onSelect(_TemperaturePreset.tropical),
            ),
            const SizedBox(height: AppSpacing.xs),
            _TargetOption(
              key: const ValueKey('temperature-target-coldwater'),
              preset: _TemperaturePreset.coldwater,
              label: 'Coldwater',
              rangeLabel: '15–22°C',
              selected: selected == _TemperaturePreset.coldwater,
              enabled: canSelectNamed,
              onTap: () => onSelect(_TemperaturePreset.coldwater),
            ),
            const SizedBox(height: AppSpacing.xs),
            _TargetOption(
              key: const ValueKey('temperature-target-custom'),
              preset: _TemperaturePreset.custom,
              label: 'Custom',
              rangeLabel: _customRangeLabel(targets),
              selected: selected == _TemperaturePreset.custom,
              enabled: false,
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  static String _customRangeLabel(WaterTargets? targets) {
    final min = targets?.tempMin;
    final max = targets?.tempMax;
    if (min == null || max == null) return 'Saved range unavailable';
    return '${_formatTargetValue(min)}–${_formatTargetValue(max)}°C';
  }

  static String _formatTargetValue(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _TargetOption extends StatelessWidget {
  final _TemperaturePreset preset;
  final String label;
  final String rangeLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _TargetOption({
    super.key,
    required this.preset,
    required this.label,
    required this.rangeLabel,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isStateOnly = preset == _TemperaturePreset.custom;
    final borderColor = selected
        ? _temperatureAccent
        : _temperatureInk.withValues(alpha: 0.22);
    final backgroundColor = selected
        ? _temperatureAccent.withValues(alpha: 0.10)
        : Colors.transparent;

    return Semantics(
      label: '$label temperature target, $rangeLabel',
      selected: selected,
      button: !isStateOnly,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      child: ExcludeSemantics(
        child: Tooltip(
          message: isStateOnly
              ? 'The temperature range currently saved to this tank'
              : 'Use the $label temperature target',
          child: Material(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.smallRadius,
              side: BorderSide(color: borderColor),
            ),
            child: InkWell(
              onTap: enabled ? onTap : null,
              splashFactory: NoSplash.splashFactory,
              borderRadius: AppRadius.smallRadius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 52,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm2,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: selected
                            ? _temperatureAccent
                            : _temperatureMutedInk,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelMedium.copyWith(
                                color: _temperatureInk,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              rangeLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall.copyWith(
                                color: _temperatureMutedInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TemperatureActionRail extends StatelessWidget {
  final RoomTheme theme;
  final VoidCallback onLog;
  final VoidCallback onCharts;
  final VoidCallback onEquipment;
  final VoidCallback onAlerts;
  final VoidCallback onSettings;

  const _TemperatureActionRail({
    required this.theme,
    required this.onLog,
    required this.onCharts,
    required this.onEquipment,
    required this.onAlerts,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final primary = [
      _TemperatureActionData(
        keyName: 'temperature-action-log',
        label: 'Log Temperature',
        icon: Icons.add_rounded,
        onTap: onLog,
        emphasized: true,
      ),
      _TemperatureActionData(
        keyName: 'temperature-action-charts',
        label: 'Charts/History',
        icon: Icons.show_chart_rounded,
        onTap: onCharts,
      ),
      _TemperatureActionData(
        keyName: 'temperature-action-equipment',
        label: 'Equipment',
        icon: Icons.build_rounded,
        onTap: onEquipment,
      ),
      _TemperatureActionData(
        keyName: 'temperature-action-alerts',
        label: 'Alerts',
        icon: Icons.notifications_active_outlined,
        onTap: onAlerts,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tank tools',
          style: AppTypography.labelLarge.copyWith(
            color: _temperatureInk,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          key: const ValueKey('temperature-primary-actions'),
          decoration: BoxDecoration(
            color: _temperatureInset.withValues(alpha: 0.86),
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: _temperatureBrass.withValues(alpha: 0.38),
            ),
          ),
          child: Column(
            children: [
              for (var index = 0; index < primary.length; index++) ...[
                _TemperatureAction(
                  data: primary[index],
                  order: index.toDouble(),
                ),
                if (index < primary.length - 1)
                  ExcludeSemantics(
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: _temperatureBrass.withValues(alpha: 0.28),
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        KeyedSubtree(
          key: const ValueKey('temperature-secondary-actions'),
          child: _TemperatureAction(
            data: _TemperatureActionData(
              keyName: 'temperature-action-settings',
              label: 'Tank Settings',
              icon: Icons.settings_outlined,
              onTap: onSettings,
              secondary: true,
            ),
            order: 4,
          ),
        ),
      ],
    );
  }
}

class _TemperatureActionData {
  final String keyName;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasized;
  final bool secondary;

  const _TemperatureActionData({
    required this.keyName,
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
    this.secondary = false,
  });
}

class _TemperatureAction extends StatelessWidget {
  final _TemperatureActionData data;
  final double order;

  const _TemperatureAction({
    required this.data,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = data.secondary ? _temperatureMutedInk : _temperatureInk;
    final background = data.emphasized
        ? _temperatureAccent.withValues(alpha: 0.10)
        : Colors.transparent;

    return Semantics(
      key: ValueKey(data.keyName),
      label: data.label,
      button: true,
      sortKey: OrdinalSortKey(order),
      onTap: data.onTap,
      child: ExcludeSemantics(
        child: Tooltip(
          message: data.label,
          child: Material(
            color: background,
            borderRadius: data.secondary ? AppRadius.smallRadius : null,
            child: InkWell(
              onTap: data.onTap,
              borderRadius: data.secondary ? AppRadius.smallRadius : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 52,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm2,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(data.icon, size: 20, color: foreground),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          data.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMedium.copyWith(
                            color: foreground,
                            fontWeight: data.emphasized
                                ? FontWeight.w800
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: foreground.withValues(alpha: 0.72),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelNotice extends StatelessWidget {
  final String label;
  final IconData icon;
  final RoomTheme theme;

  const _PanelNotice({
    required this.label,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _temperatureInset.withValues(alpha: 0.86),
            borderRadius: AppRadius.smallRadius,
            border: Border.all(
              color: _temperatureBrass.withValues(alpha: 0.38),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm2,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: _temperatureMutedInk),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.labelMedium.copyWith(
                        color: _temperatureMutedInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
