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
import 'temperature/brass_gauge.dart';
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

    final Widget readingAssembly;
    if (latestTestAsync.isLoading) {
      readingAssembly = _PanelNotice(
        label: 'Loading temperature…',
        icon: Icons.hourglass_top_rounded,
        theme: widget.theme,
      );
    } else if (latestTestAsync.hasError) {
      readingAssembly = _PanelNotice(
        label: 'Temperature unavailable',
        icon: Icons.thermostat_outlined,
        theme: widget.theme,
      );
    } else {
      readingAssembly = TempHeroSection(
        temp: temp,
        fillAnim: _fillAnim,
        gaugeMin: gaugeBounds.min,
        gaugeMax: gaugeBounds.max,
        optimalMin: targetMin,
        optimalMax: targetMax,
        status: status,
        lastEntry: lastEntry,
        formatTimestamp: _formatTimestamp,
      );
    }

    final canUseHybridInstrument =
        temp != null &&
        hasCompleteTarget &&
        !tankAsync.isLoading &&
        !targetUnavailable &&
        !latestTestAsync.isLoading &&
        !latestTestAsync.hasError &&
        !logsAsync.isLoading &&
        !logsAsync.hasError &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.2;

    return DecoratedBox(
      key: const ValueKey('temperature-panel-backdrop'),
      decoration: const BoxDecoration(color: Color(0xFF111414)),
      child: SingleChildScrollView(
        key: const ValueKey('temperature-panel-scroll'),
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm4,
          AppSpacing.md,
          DanioBottomDock.contentClearance + AppSpacing.md,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useHybridInstrument =
                canUseHybridInstrument &&
                constraints.maxWidth >=
                    _TemperatureHybridInstrument._designWidth;
            return useHybridInstrument
                ? _TemperatureHybridInstrument(
                    temp: temp,
                    gaugeBounds: gaugeBounds,
                    targetMin: targetMin!,
                    targetMax: targetMax!,
                    status: status,
                    lastEntry: lastEntry,
                    streak: temperatureStreak,
                    sparkData: sparkData,
                    minTemp: minTemp,
                    maxTemp: maxTemp,
                    avgTemp: avgTemp,
                    targets: tank!.targets,
                    selected: selectedPreset,
                    isSaving: _savingTarget,
                    formatTimestamp: _formatTimestamp,
                    onSelect: (preset) => _selectPreset(preset, tank),
                    onLog: _openLog,
                    onCharts: _openCharts,
                    onEquipment: _openEquipment,
                    onAlerts: _openAlerts,
                    onSettings: _openSettings,
                  )
                : _TemperatureInstrumentChassis(
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
                          _TemperatureInstrumentCore(
                            reading: readingAssembly,
                            targetBuilder: (compactLayout) =>
                                _TemperatureTargetSelector(
                                  targets: tank?.targets,
                                  selected: selectedPreset,
                                  isLoading: tankAsync.isLoading,
                                  isUnavailable: targetUnavailable,
                                  isSaving: _savingTarget,
                                  compactLayout: compactLayout,
                                  theme: widget.theme,
                                  onSelect: (preset) =>
                                      _selectPreset(preset, tank),
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),
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
                  );
          },
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

/// A deliberately small, one-coordinate-system version of the approved
/// instrument for Danio's real 66% stage drawer. The chassis image is purely
/// decorative; every reading, state, label, and control remains native.
class _TemperatureHybridInstrument extends StatelessWidget {
  static const _designWidth = 220.0;
  static const _designHeight = 476.0;

  final double temp;
  final ({double min, double max}) gaugeBounds;
  final double targetMin;
  final double targetMax;
  final TempStatus? status;
  final LogEntry? lastEntry;
  final int streak;
  final List<double> sparkData;
  final double? minTemp;
  final double? maxTemp;
  final double? avgTemp;
  final WaterTargets targets;
  final _TemperaturePreset? selected;
  final bool isSaving;
  final String Function(DateTime) formatTimestamp;
  final ValueChanged<_TemperaturePreset> onSelect;
  final VoidCallback onLog;
  final VoidCallback onCharts;
  final VoidCallback onEquipment;
  final VoidCallback onAlerts;
  final VoidCallback onSettings;

  const _TemperatureHybridInstrument({
    required this.temp,
    required this.gaugeBounds,
    required this.targetMin,
    required this.targetMax,
    required this.status,
    required this.lastEntry,
    required this.streak,
    required this.sparkData,
    required this.minTemp,
    required this.maxTemp,
    required this.avgTemp,
    required this.targets,
    required this.selected,
    required this.isSaving,
    required this.formatTimestamp,
    required this.onSelect,
    required this.onLog,
    required this.onCharts,
    required this.onEquipment,
    required this.onAlerts,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / _designWidth;
        final displayWidth = _designWidth * scale;
        final displayHeight = _designHeight * scale;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            key: const ValueKey('temperature-hybrid-skin'),
            width: displayWidth,
            height: displayHeight,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              child: SizedBox(
                key: const ValueKey('temperature-instrument-core'),
                width: _designWidth,
                height: _designHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned.fill(
                      child: ExcludeSemantics(
                        child: Image(
                          image: AssetImage(
                            'assets/images/illustrations/'
                            'temperature_instrument_chassis.png',
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 10,
                      width: 132,
                      height: 24,
                      child: _HybridInstrumentHeader(streak: streak),
                    ),
                    Positioned(
                      left: 10,
                      top: 32,
                      width: 146,
                      height: 146,
                      child: Semantics(
                        label: _gaugeSemantics(),
                        readOnly: true,
                        child: ExcludeSemantics(
                          child: BrassGauge(
                            temp: temp,
                            gaugeMin: gaugeBounds.min,
                            gaugeMax: gaugeBounds.max,
                            optimalMin: targetMin,
                            optimalMax: targetMax,
                            showCenterLabel: false,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 124,
                      top: 43,
                      width: 34,
                      height: 14,
                      child: ExcludeSemantics(
                        child: _HybridStatusLamps(status: status),
                      ),
                    ),
                    Positioned(
                      left: 162,
                      top: 52,
                      width: 54,
                      height: 168,
                      child: _HybridTargetAssembly(
                        targets: targets,
                        selected: selected,
                        isSaving: isSaving,
                        onSelect: onSelect,
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 218,
                      width: 150,
                      height: 74,
                      child: Semantics(
                        label: _manualSemantics(),
                        readOnly: true,
                        child: ExcludeSemantics(
                          child: _HybridManualReadout(
                            temp: temp,
                            lastEntry: lastEntry,
                            formatTimestamp: formatTimestamp,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 13,
                      top: 305,
                      width: 194,
                      height: 74,
                      child: Semantics(
                        label: 'Seven day manual temperature history',
                        readOnly: true,
                        child: ExcludeSemantics(
                          child: _HybridTemperatureTrend(
                            sparkData: sparkData,
                            minTemp: minTemp,
                            maxTemp: maxTemp,
                            avgTemp: avgTemp,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: KeyedSubtree(
                        key: const ValueKey('temperature-primary-actions'),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 166,
                              top: 231,
                              width: 48,
                              height: 48,
                              child: _HybridActionButton(
                                label: 'Log Temperature',
                                displayLabel: 'Log',
                                icon: Icons.add_rounded,
                                order: 0,
                                emphasized: true,
                                onTap: onLog,
                              ),
                            ),
                            Positioned(
                              left: 13,
                              top: 395,
                              width: 48,
                              height: 48,
                              child: _HybridActionButton(
                                label: 'Charts/History',
                                icon: Icons.show_chart_rounded,
                                order: 1,
                                onTap: onCharts,
                              ),
                            ),
                            Positioned(
                              left: 64,
                              top: 395,
                              width: 48,
                              height: 48,
                              child: _HybridActionButton(
                                label: 'Equipment',
                                icon: Icons.build_rounded,
                                order: 2,
                                onTap: onEquipment,
                              ),
                            ),
                            Positioned(
                              left: 115,
                              top: 395,
                              width: 48,
                              height: 48,
                              child: _HybridActionButton(
                                label: 'Alerts',
                                icon: Icons.notifications_active_outlined,
                                order: 3,
                                onTap: onAlerts,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 166,
                      top: 395,
                      width: 48,
                      height: 48,
                      child: KeyedSubtree(
                        key: const ValueKey('temperature-secondary-actions'),
                        child: _HybridActionButton(
                          label: 'Tank Settings',
                          icon: Icons.settings_outlined,
                          order: 4,
                          secondary: true,
                          onTap: onSettings,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _manualSemantics() {
    final timestamp = lastEntry == null
        ? ''
        : ', last logged ${formatTimestamp(lastEntry!.timestamp)}';
    return 'Latest manually logged temperature ${temp.toStringAsFixed(1)} '
        'degrees Celsius$timestamp';
  }

  String _gaugeSemantics() {
    final target =
        '${_formatTargetValue(targetMin)} to '
        '${_formatTargetValue(targetMax)} degrees Celsius';
    final statusLabel = switch (status) {
      TempStatus.perfect => 'within the saved target',
      TempStatus.warm => 'a little warm',
      TempStatus.cool => 'a little cool',
      TempStatus.tooHot => 'too hot',
      TempStatus.tooCold => 'too cold',
      null => 'unavailable',
    };
    return 'Manual temperature gauge. Saved target $target. '
        'Current comparison is $statusLabel.';
  }

  static String _formatTargetValue(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _HybridInstrumentHeader extends StatelessWidget {
  final int streak;

  const _HybridInstrumentHeader({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temperature',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelLarge.copyWith(
            color: _temperatureInk,
            fontSize: 12,
            height: 0.95,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        Text(
          streak == 1 ? '1-day manual streak' : '$streak-day manual streak',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: _temperatureMutedInk,
            fontSize: 6.5,
            height: 0.9,
          ),
        ),
      ],
    );
  }
}

class _HybridStatusLamps extends StatelessWidget {
  final TempStatus? status;

  const _HybridStatusLamps({required this.status});

  @override
  Widget build(BuildContext context) {
    final activeIndex = switch (status) {
      TempStatus.cool || TempStatus.tooCold => 0,
      TempStatus.perfect => 1,
      TempStatus.warm || TempStatus.tooHot => 2,
      null => -1,
    };
    const colors = [kTempTealLight, kTempTeal, kTempRedWarn];
    return SizedBox(
      key: const ValueKey('temperature-status-lamps'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var index = 0; index < colors.length; index++)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeIndex == index
                    ? colors[index]
                    : const Color(0xFF211D19),
                border: Border.all(
                  color: _temperatureBrass.withValues(alpha: 0.78),
                ),
                boxShadow: activeIndex == index
                    ? [
                        BoxShadow(
                          color: colors[index].withValues(alpha: 0.78),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _HybridTargetAssembly extends StatelessWidget {
  final WaterTargets targets;
  final _TemperaturePreset? selected;
  final bool isSaving;
  final ValueChanged<_TemperaturePreset> onSelect;

  const _HybridTargetAssembly({
    required this.targets,
    required this.selected,
    required this.isSaving,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('temperature-target-assembly'),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 19,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Target range',
                      style: AppTypography.labelSmall.copyWith(
                        color: _temperatureInk,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isSaving ? 'Saving target' : 'Saved to this tank',
                      style: AppTypography.labelSmall.copyWith(
                        color: _temperatureAccent,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 3,
            top: 22,
            width: 48,
            height: 48,
            child: _HybridPresetButton(
              preset: _TemperaturePreset.tropical,
              label: 'Tropical',
              rangeLabel: '24\u201328\u00b0C',
              selected: selected == _TemperaturePreset.tropical,
              enabled: !isSaving,
              onTap: () => onSelect(_TemperaturePreset.tropical),
            ),
          ),
          Positioned(
            left: 3,
            top: 72,
            width: 48,
            height: 48,
            child: _HybridPresetButton(
              preset: _TemperaturePreset.coldwater,
              label: 'Coldwater',
              rangeLabel: '15\u201322\u00b0C',
              selected: selected == _TemperaturePreset.coldwater,
              enabled: !isSaving,
              onTap: () => onSelect(_TemperaturePreset.coldwater),
            ),
          ),
          Positioned(
            left: 1,
            top: 123,
            width: 52,
            height: 36,
            child: Semantics(
              label:
                  'Custom temperature target, '
                  '${_TemperatureTargetSelector._customRangeLabel(targets)}',
              selected: selected == _TemperaturePreset.custom,
              readOnly: true,
              child: ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF101414).withValues(alpha: 0.85),
                    border: Border.all(
                      color: _temperatureBrass.withValues(alpha: 0.52),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Custom',
                          maxLines: 1,
                          style: AppTypography.labelSmall.copyWith(
                            color: _temperatureMutedInk,
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _TemperatureTargetSelector._customRangeLabel(
                              targets,
                            ),
                            maxLines: 1,
                            style: AppTypography.labelSmall.copyWith(
                              color: _temperatureMutedInk,
                              fontSize: 6.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HybridPresetButton extends StatelessWidget {
  final _TemperaturePreset preset;
  final String label;
  final String rangeLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _HybridPresetButton({
    required this.preset,
    required this.label,
    required this.rangeLabel,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label temperature target, $rangeLabel',
      selected: selected,
      button: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      child: ExcludeSemantics(
        child: Tooltip(
          message: 'Use the $label temperature target',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? _temperatureAccent.withValues(alpha: 0.24)
                      : const Color(0xFF171B1B).withValues(alpha: 0.88),
                  border: Border.all(
                    color: selected ? _temperatureAccent : _temperatureBrass,
                    width: selected ? 2 : 1.2,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _temperatureAccent.withValues(alpha: 0.42),
                            blurRadius: 7,
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: AppTypography.labelSmall.copyWith(
                            color: _temperatureInk,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        rangeLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: selected
                              ? _temperatureAccent
                              : _temperatureMutedInk,
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
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

class _HybridManualReadout extends StatelessWidget {
  final double temp;
  final LogEntry? lastEntry;
  final String Function(DateTime) formatTimestamp;

  const _HybridManualReadout({
    required this.temp,
    required this.lastEntry,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('temperature-manual-readout'),
      decoration: BoxDecoration(
        color: const Color(0xFF191408).withValues(alpha: 0.88),
        border: Border.all(
          color: _temperatureBrass.withValues(alpha: 0.76),
          width: 1.1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LATEST MANUAL',
              style: AppTypography.labelSmall.copyWith(
                color: _temperatureMutedInk,
                fontSize: 7,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${temp.toStringAsFixed(1)}\u00b0C',
                style: AppTypography.headlineLarge.copyWith(
                  color: _temperatureInk,
                  fontWeight: FontWeight.w900,
                  height: 0.92,
                ),
              ),
            ),
            if (lastEntry != null)
              Text(
                'Logged ${formatTimestamp(lastEntry!.timestamp)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: _temperatureAccent,
                  fontSize: 7,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HybridTemperatureTrend extends StatelessWidget {
  final List<double> sparkData;
  final double? minTemp;
  final double? maxTemp;
  final double? avgTemp;

  const _HybridTemperatureTrend({
    required this.sparkData,
    required this.minTemp,
    required this.maxTemp,
    required this.avgTemp,
  });

  @override
  Widget build(BuildContext context) {
    final hasSummary = minTemp != null && maxTemp != null && avgTemp != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF071719).withValues(alpha: 0.72),
        border: Border.all(
          color: _temperatureBrass.withValues(alpha: 0.56),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 5, 7, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart_rounded,
                  size: 10,
                  color: kTempTealLight,
                ),
                const SizedBox(width: 3),
                Text(
                  '7-day trend',
                  style: AppTypography.labelSmall.copyWith(
                    color: _temperatureInk,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (hasSummary)
                  Flexible(
                    child: Text(
                      '${minTemp!.toStringAsFixed(1)} / '
                      '${avgTemp!.toStringAsFixed(1)} / '
                      '${maxTemp!.toStringAsFixed(1)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTypography.labelSmall.copyWith(
                        color: _temperatureMutedInk,
                        fontSize: 7,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Expanded(
              child: sparkData.length >= 2
                  ? CustomPaint(painter: TempSparklinePainter(data: sparkData))
                  : Center(
                      child: Text(
                        sparkData.isEmpty
                            ? 'No data yet'
                            : 'Add another reading to see a trend',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSmall.copyWith(
                          color: _temperatureMutedInk,
                          fontSize: 8,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HybridActionButton extends StatelessWidget {
  final String label;
  final String? displayLabel;
  final IconData icon;
  final double order;
  final bool emphasized;
  final bool secondary;
  final VoidCallback onTap;

  const _HybridActionButton({
    required this.label,
    required this.icon,
    required this.order,
    required this.onTap,
    this.displayLabel,
    this.emphasized = false,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = secondary ? _temperatureMutedInk : _temperatureInk;
    return Semantics(
      label: label,
      button: true,
      sortKey: OrdinalSortKey(order),
      onTap: onTap,
      child: ExcludeSemantics(
        child: Tooltip(
          message: label,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Ink(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: emphasized
                      ? _temperatureAccent.withValues(alpha: 0.20)
                      : const Color(0xFF15191A).withValues(alpha: 0.82),
                  border: Border.all(
                    color: emphasized
                        ? _temperatureAccent
                        : _temperatureBrass.withValues(alpha: 0.78),
                    width: emphasized ? 1.8 : 1.1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 15, color: foreground),
                      const SizedBox(height: 1),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          displayLabel ?? label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: AppTypography.labelSmall.copyWith(
                            color: foreground,
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                          ),
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

class _TemperatureInstrumentCore extends StatelessWidget {
  final Widget reading;
  final Widget Function(bool compactLayout) targetBuilder;

  const _TemperatureInstrumentCore({
    required this.reading,
    required this.targetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('temperature-instrument-core'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF202425), Color(0xFF0E1112), Color(0xFF171B1C)],
          stops: [0, 0.58, 1],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _temperatureBrass.withValues(alpha: 0.78),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.62),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _temperatureBrass.withValues(alpha: 0.12),
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 360) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: reading),
                  const SizedBox(width: AppSpacing.sm2),
                  Flexible(flex: 4, child: targetBuilder(false)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                reading,
                const SizedBox(height: AppSpacing.xs),
                targetBuilder(true),
              ],
            );
          },
        ),
      ),
    );
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
          colors: [Color(0xFF2A2D2D), Color(0xFF111414), Color(0xFF050707)],
          stops: [0, 0.46, 1],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE0B95F).withValues(alpha: 0.82),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.72),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: _temperatureBrass.withValues(alpha: 0.16),
            blurRadius: 8,
            spreadRadius: -2,
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
      ..color = _temperatureBrass.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
        const Radius.circular(16),
      ),
      seamPaint,
    );

    final brushedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.7;
    for (var y = 24.0; y < size.height - 20; y += 18) {
      canvas.drawLine(
        Offset(18, y),
        Offset(size.width - 18, y + 1.5),
        brushedPaint,
      );
    }

    for (final center in [
      const Offset(17, 17),
      Offset(size.width - 17, 17),
      Offset(17, size.height - 17),
      Offset(size.width - 17, size.height - 17),
    ]) {
      canvas.drawCircle(
        center,
        7,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.35, -0.35),
            colors: [Color(0xFFFFD983), Color(0xFF9A6721), Color(0xFF38220B)],
          ).createShader(Rect.fromCircle(center: center, radius: 7)),
      );
      canvas.drawCircle(
        center,
        3.5,
        Paint()
          ..color = const Color(0xFF151515)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.drawLine(
        center.translate(-3, 0),
        center.translate(3, 0),
        Paint()
          ..color = const Color(0xFF3A280F)
          ..strokeWidth = 1.2,
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
  final bool compactLayout;
  final RoomTheme theme;
  final ValueChanged<_TemperaturePreset> onSelect;

  const _TemperatureTargetSelector({
    required this.targets,
    required this.selected,
    required this.isLoading,
    required this.isUnavailable,
    required this.isSaving,
    required this.compactLayout,
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
      key: const ValueKey('temperature-target-assembly'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF25292A), Color(0xFF090B0C)],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: _temperatureBrass.withValues(alpha: 0.72),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.58),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs2,
              children: [
                const Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: _temperatureBrass,
                ),
                Text(
                  'Target range',
                  style: AppTypography.labelMedium.copyWith(
                    color: _temperatureInk,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  statusLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: _temperatureAccent,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final compactOption = constraints.maxWidth < 310;
                final tropical = _TargetOption(
                  key: const ValueKey('temperature-target-tropical'),
                  preset: _TemperaturePreset.tropical,
                  label: 'Tropical',
                  rangeLabel: '24–28°C',
                  selected: selected == _TemperaturePreset.tropical,
                  enabled: canSelectNamed,
                  onTap: () => onSelect(_TemperaturePreset.tropical),
                  compact: compactOption,
                );
                final coldwater = _TargetOption(
                  key: const ValueKey('temperature-target-coldwater'),
                  preset: _TemperaturePreset.coldwater,
                  label: 'Coldwater',
                  rangeLabel: '15–22°C',
                  selected: selected == _TemperaturePreset.coldwater,
                  enabled: canSelectNamed,
                  onTap: () => onSelect(_TemperaturePreset.coldwater),
                  compact: compactOption,
                );
                final custom = _TargetOption(
                  key: const ValueKey('temperature-target-custom'),
                  preset: _TemperaturePreset.custom,
                  label: 'Custom',
                  rangeLabel: _customRangeLabel(targets),
                  selected: selected == _TemperaturePreset.custom,
                  enabled: false,
                  onTap: null,
                  compact: compactOption,
                );
                if (compactLayout && compactOption) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: tropical),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(child: coldwater),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      custom,
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    tropical,
                    const SizedBox(height: AppSpacing.xs),
                    coldwater,
                    const SizedBox(height: AppSpacing.xs),
                    custom,
                  ],
                );
              },
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
  final bool compact;

  const _TargetOption({
    super.key,
    required this.preset,
    required this.label,
    required this.rangeLabel,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isStateOnly = preset == _TemperaturePreset.custom;
    final borderColor = selected
        ? _temperatureAccent
        : _temperatureBrass.withValues(alpha: isStateOnly ? 0.22 : 0.48);

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
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: enabled ? onTap : null,
              splashFactory: NoSplash.splashFactory,
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isStateOnly
                        ? const [Color(0xFF151718), Color(0xFF080909)]
                        : const [Color(0xFF303435), Color(0xFF111314)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: selected
                          ? _temperatureAccent.withValues(alpha: 0.28)
                          : Colors.black.withValues(alpha: 0.48),
                      blurRadius: selected ? 8 : 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
                      vertical: compact ? AppSpacing.xs2 : AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: compact ? 14 : 20,
                          height: compact ? 14 : 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: selected
                                  ? const [
                                      Color(0xFFFFFFFF),
                                      Color(0xFF3BFFE7),
                                      Color(0xFF05796E),
                                      Color(0xFF0A1717),
                                    ]
                                  : const [
                                      Color(0xFF3B4141),
                                      Color(0xFF141718),
                                    ],
                              stops: selected
                                  ? const [0, 0.18, 0.58, 1]
                                  : const [0, 1],
                            ),
                            border: Border.all(
                              color: selected
                                  ? _temperatureAccent
                                  : _temperatureBrass.withValues(alpha: 0.45),
                              width: 1.4,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: _temperatureAccent.withValues(
                                        alpha: 0.55,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        SizedBox(
                          width: compact ? AppSpacing.xs2 : AppSpacing.sm,
                        ),
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
                                  color: isStateOnly
                                      ? _temperatureMutedInk
                                      : _temperatureInk,
                                  fontWeight: FontWeight.w800,
                                  fontSize: compact ? 11 : null,
                                ),
                              ),
                              Text(
                                rangeLabel,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: selected
                                      ? _temperatureAccent
                                      : _temperatureMutedInk,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: compact ? 9.5 : null,
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
