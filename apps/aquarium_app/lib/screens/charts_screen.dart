import 'dart:io';
import '../widgets/core/bubble_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';

class ChartsScreen extends ConsumerStatefulWidget {
  final String tankId;
  final String initialParam;

  const ChartsScreen({
    super.key,
    required this.tankId,
    this.initialParam = 'nitrate',
  });

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  late String _selectedParam;
  bool _multiParamMode = false;
  Set<String> _selectedParams = {};
  bool _showGoalZones = true;
  bool _showAlerts = true;

  @override
  void initState() {
    super.initState();
    _selectedParam = widget.initialParam;
    _selectedParams = {widget.initialParam};
  }

  @override
  Widget build(BuildContext context) {
    final tankAsync = ref.watch(tankProvider(widget.tankId));
    final logsAsync = ref.watch(allLogsProvider(widget.tankId));
    final tank = tankAsync.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Charts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () => _exportCsv(context, logsAsync),
          ),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: BubbleLoader()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (logs) {
          final waterTests =
              logs
                  .where(
                    (l) => l.type == LogType.waterTest && l.waterTest != null,
                  )
                  .toList()
                ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          if (waterTests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart, size: 64, color: AppColors.textHint),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No water tests yet',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Log some water tests to see trends',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parameter selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ParamChip(
                        label: 'Nitrate',
                        isSelected: _selectedParam == 'nitrate',
                        onTap: () => setState(() => _selectedParam = 'nitrate'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ParamChip(
                        label: 'Nitrite',
                        isSelected: _selectedParam == 'nitrite',
                        onTap: () => setState(() => _selectedParam = 'nitrite'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ParamChip(
                        label: 'Ammonia',
                        isSelected: _selectedParam == 'ammonia',
                        onTap: () => setState(() => _selectedParam = 'ammonia'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ParamChip(
                        label: 'pH',
                        isSelected: _selectedParam == 'ph',
                        onTap: () => setState(() => _selectedParam = 'ph'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ParamChip(
                        label: 'Temp',
                        isSelected: _selectedParam == 'temp',
                        onTap: () => setState(() => _selectedParam = 'temp'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ParamChip(
                        label: 'GH',
                        isSelected: _selectedParam == 'gh',
                        onTap: () => setState(() => _selectedParam = 'gh'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ParamChip(
                        label: 'KH',
                        isSelected: _selectedParam == 'kh',
                        onTap: () => setState(() => _selectedParam = 'kh'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ParamChip(
                        label: 'Phosphate',
                        isSelected: _selectedParam == 'phosphate',
                        onTap: () =>
                            setState(() => _selectedParam = 'phosphate'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Chart controls
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _ChartControlChip(
                      icon: Icons.layers_outlined,
                      label: 'Compare',
                      isActive: _multiParamMode,
                      onTap: () => _showMultiParamDialog(context, waterTests),
                    ),
                    _ChartControlChip(
                      icon: Icons.square,
                      label: 'Goal Zones',
                      isActive: _showGoalZones,
                      onTap: () =>
                          setState(() => _showGoalZones = !_showGoalZones),
                    ),
                    _ChartControlChip(
                      icon: Icons.notifications_outlined,
                      label: 'Alerts',
                      isActive: _showAlerts,
                      onTap: () => setState(() => _showAlerts = !_showAlerts),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Alerts banner (if enabled and issues found)
                if (_showAlerts && tank != null) ...[
                  _buildAlertsBanner(waterTests, tank),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Chart
                Text(
                  _multiParamMode
                      ? 'Multi-Parameter Comparison'
                      : _getParamTitle(_selectedParam),
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 250,
                  child: _multiParamMode
                      ? _buildMultiParamChart(
                          waterTests,
                          targets: tank?.targets,
                        )
                      : _buildChart(waterTests, targets: tank?.targets),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Summary stats
                Text('Summary', style: AppTypography.headlineSmall),
                const SizedBox(height: 12),
                _SummaryCard(logs: waterTests, param: _selectedParam),

                const SizedBox(height: AppSpacing.xl),

                // Recent values table
                Text('Recent Values', style: AppTypography.headlineSmall),
                const SizedBox(height: 12),
                _ValuesTable(logs: waterTests.reversed.take(10).toList()),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getParamTitle(String param) {
    switch (param) {
      case 'nitrate':
        return 'Nitrate (NO₃) ppm';
      case 'nitrite':
        return 'Nitrite (NO₂) ppm';
      case 'ammonia':
        return 'Ammonia (NH₃) ppm';
      case 'ph':
        return 'pH Level';
      case 'temp':
        return 'Temperature °C';
      case 'gh':
        return 'GH (dGH)';
      case 'kh':
        return 'KH (dKH)';
      case 'phosphate':
        return 'Phosphate (PO₄) ppm';
      default:
        return param;
    }
  }

  double? _getValue(WaterTestResults test, String param) {
    switch (param) {
      case 'nitrate':
        return test.nitrate;
      case 'nitrite':
        return test.nitrite;
      case 'ammonia':
        return test.ammonia;
      case 'ph':
        return test.ph;
      case 'temp':
        return test.temperature;
      case 'gh':
        return test.gh;
      case 'kh':
        return test.kh;
      case 'phosphate':
        return test.phosphate;
      default:
        return null;
    }
  }

  ({double? min, double? max}) _getTargetRange(
    WaterTargets targets,
    String param,
  ) {
    switch (param) {
      case 'temp':
        return (min: targets.tempMin, max: targets.tempMax);
      case 'ph':
        return (min: targets.phMin, max: targets.phMax);
      case 'gh':
        return (min: targets.ghMin, max: targets.ghMax);
      case 'kh':
        return (min: targets.khMin, max: targets.khMax);
      default:
        return (min: null, max: null);
    }
  }

  Color _getParamColor(String param) {
    switch (param) {
      case 'nitrate':
        return Colors.orange;
      case 'nitrite':
        return Colors.red;
      case 'ammonia':
        return Colors.purple;
      case 'ph':
        return AppColors.primary;
      case 'temp':
        return AppColors.secondary;
      case 'gh':
        return Colors.brown;
      case 'kh':
        return Colors.indigo;
      case 'phosphate':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildChart(List<LogEntry> logs, {WaterTargets? targets}) {
    final color = _getParamColor(_selectedParam);
    final spots = <FlSpot>[];

    for (int i = 0; i < logs.length; i++) {
      final value = _getValue(logs[i].waterTest!, _selectedParam);
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    if (spots.isEmpty) {
      return Center(
        child: Text(
          'No ${_getParamTitle(_selectedParam)} data',
          style: AppTypography.bodyMedium,
        ),
      );
    }

    final xMax = (logs.length <= 1) ? 0.0 : (logs.length - 1).toDouble();

    // Optional target lines (min/max), where relevant.
    final List<LineChartBarData> bars = [];

    bars.add(
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
      ),
    );

    if (targets != null) {
      final range = _getTargetRange(targets, _selectedParam);
      final targetColor = AppOverlays.textHintAlpha80;

      if (range.min != null) {
        bars.add(
          LineChartBarData(
            spots: [FlSpot(0, range.min!), FlSpot(xMax, range.min!)],
            isCurved: false,
            color: targetColor,
            barWidth: 1,
            dashArray: [6, 4],
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        );
      }

      if (range.max != null) {
        bars.add(
          LineChartBarData(
            spots: [FlSpot(0, range.max!), FlSpot(xMax, range.max!)],
            isCurved: false,
            color: targetColor,
            barWidth: 1,
            dashArray: [6, 4],
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        );
      }
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getInterval(_selectedParam),
          getDrawingHorizontalLine: (value) =>
              FlLine(color: AppColors.surfaceVariant, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(_selectedParam == 'ph' ? 1 : 0),
                style: AppTypography.bodySmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (logs.length / 5).ceilToDouble().clamp(1, 10),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < logs.length) {
                  return Text(
                    DateFormat('M/d').format(logs[index].timestamp),
                    style: AppTypography.bodySmall,
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: bars,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final date = index >= 0 && index < logs.length
                    ? DateFormat('MMM d').format(logs[index].timestamp)
                    : '';
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(2)}\n$date',
                  TextStyle(color: color, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _getInterval(String param) {
    switch (param) {
      case 'nitrate':
        return 10;
      case 'nitrite':
        return 0.5;
      case 'ammonia':
        return 0.5;
      case 'ph':
        return 0.5;
      case 'temp':
        return 2;
      case 'gh':
        return 2;
      case 'kh':
        return 2;
      case 'phosphate':
        return 0.5;
      default:
        return 5;
    }
  }

  Future<void> _exportCsv(
    BuildContext context,
    AsyncValue<List<LogEntry>> logsAsync,
  ) async {
    final logs = logsAsync.value;
    if (logs == null || logs.isEmpty) {
      AppFeedback.showInfo(context, 'No data to export');
      return;
    }

    final waterTests =
        logs
            .where((l) => l.type == LogType.waterTest && l.waterTest != null)
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (waterTests.isEmpty) {
      AppFeedback.showInfo(context, 'No water tests to export');
      return;
    }

    // Build CSV
    final buffer = StringBuffer();
    buffer.writeln(
      'Date,Time,Temp (°C),pH,Ammonia (ppm),Nitrite (ppm),Nitrate (ppm),GH (dGH),KH (dKH),Phosphate (ppm),CO2 (mg/L),Notes',
    );

    for (final log in waterTests) {
      final test = log.waterTest!;
      final date = DateFormat('yyyy-MM-dd').format(log.timestamp);
      final time = DateFormat('HH:mm').format(log.timestamp);
      buffer.writeln(
        [
          date,
          time,
          test.temperature?.toString() ?? '',
          test.ph?.toString() ?? '',
          test.ammonia?.toString() ?? '',
          test.nitrite?.toString() ?? '',
          test.nitrate?.toString() ?? '',
          test.gh?.toString() ?? '',
          test.kh?.toString() ?? '',
          test.phosphate?.toString() ?? '',
          test.co2?.toString() ?? '',
          (log.notes ?? '').replaceAll(',', ';').replaceAll('\n', ' '),
        ].join(','),
      );
    }

    if (!context.mounted) return;
    AppFeedback.showLoading(context, 'Preparing export…');
    var dismissLoadingInFinally = true;

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/water_tests_export.csv');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles([XFile(file.path)], subject: 'Water Test Export');
    } catch (e) {
      if (context.mounted) {
        AppFeedback.dismiss(context);
        dismissLoadingInFinally = false;
        AppFeedback.showError(context, 'Export failed: $e');
      }
    } finally {
      if (context.mounted && dismissLoadingInFinally) {
        AppFeedback.dismiss(context);
      }
    }
  }

  Widget _buildMultiParamChart(List<LogEntry> logs, {WaterTargets? targets}) {
    if (_selectedParams.isEmpty) {
      return const Center(child: Text('Select parameters to compare'));
    }

    final List<LineChartBarData> bars = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    // Normalize data for each selected parameter
    for (final param in _selectedParams) {
      final spots = <FlSpot>[];
      for (int i = 0; i < logs.length; i++) {
        final value = _getValue(logs[i].waterTest!, param);
        if (value != null) {
          spots.add(FlSpot(i.toDouble(), value));
          if (value < minY) minY = value;
          if (value > maxY) maxY = value;
        }
      }

      if (spots.isNotEmpty) {
        final color = _getParamColor(param);
        bars.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: 1,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        );
      }
    }

    if (bars.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final xMax = (logs.length <= 1) ? 0.0 : (logs.length - 1).toDouble();

    return LineChart(
      LineChartData(
        minY: minY * 0.9,
        maxY: maxY * 1.1,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < logs.length && index % 3 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('M/d').format(logs[index].timestamp),
                      style: AppTypography.bodySmall,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: bars,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final barIndex = touchedSpots.indexOf(spot);
                final param = _selectedParams.elementAt(
                  barIndex % _selectedParams.length,
                );
                final color = _getParamColor(param);
                return LineTooltipItem(
                  '${_getParamTitle(param)}\n${spot.y.toStringAsFixed(2)}',
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsBanner(List<LogEntry> logs, Tank tank) {
    if (logs.isEmpty) return const SizedBox.shrink();

    final latestTest = logs.last.waterTest;
    if (latestTest == null) return const SizedBox.shrink();

    final issues = <String>[];

    // Check ammonia
    if (latestTest.ammonia != null && latestTest.ammonia! > 0.5) {
      issues.add('⚠️ High ammonia (${latestTest.ammonia}ppm)');
    }

    // Check nitrite
    if (latestTest.nitrite != null && latestTest.nitrite! > 0.5) {
      issues.add('⚠️ High nitrite (${latestTest.nitrite}ppm)');
    }

    // Check nitrate
    if (latestTest.nitrate != null && latestTest.nitrate! > 40) {
      issues.add('⚠️ High nitrate (${latestTest.nitrate}ppm)');
    }

    // Check pH against targets
    if (tank.targets != null && latestTest.ph != null) {
      final targets = tank.targets!;
      if (targets.phMin != null && latestTest.ph! < targets.phMin!) {
        issues.add('📉 pH below target (${latestTest.ph})');
      } else if (targets.phMax != null && latestTest.ph! > targets.phMax!) {
        issues.add('📈 pH above target (${latestTest.ph})');
      }
    }

    // Check temperature against targets
    if (tank.targets != null && latestTest.temperature != null) {
      final targets = tank.targets!;
      if (targets.tempMin != null &&
          latestTest.temperature! < targets.tempMin!) {
        issues.add('🥶 Temperature too low (${latestTest.temperature}°C)');
      } else if (targets.tempMax != null &&
          latestTest.temperature! > targets.tempMax!) {
        issues.add('🥵 Temperature too high (${latestTest.temperature}°C)');
      }
    }

    if (issues.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppOverlays.success10,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(color: AppColors.successAlpha30),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'All parameters within safe ranges ✓',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppOverlays.warning10,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.warningAlpha30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Parameter Alerts',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...issues.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(issue, style: AppTypography.bodySmall),
            ),
          ),
        ],
      ),
    );
  }

  void _showMultiParamDialog(BuildContext context, List<LogEntry> logs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Compare Parameters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select 2-4 parameters to overlay on the same chart:'),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['nitrate', 'nitrite', 'ammonia', 'ph', 'temp'].map((
                param,
              ) {
                final isSelected = _selectedParams.contains(param);
                return FilterChip(
                  label: Text(_getParamTitle(param)),
                  selected: isSelected,
                  selectedColor: _getParamColor(param).withOpacity(0.3),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedParams.length < 4) {
                          _selectedParams.add(param);
                        }
                      } else {
                        _selectedParams.remove(param);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedParams.length >= 4)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Maximum 4 parameters',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _multiParamMode = false;
                _selectedParams.clear();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _selectedParams.length >= 2
                ? () {
                    setState(() {
                      _multiParamMode = true;
                    });
                    Navigator.pop(ctx);
                  }
                : null,
            child: const Text('Compare'),
          ),
        ],
      ),
    );
  }
}

class _ChartControlChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ChartControlChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.largeRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppOverlays.primary10
              : AppColors.surfaceVariant,
          borderRadius: AppRadius.largeRadius,
          border: isActive
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParamChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ParamChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<LogEntry> logs;
  final String param;

  const _SummaryCard({required this.logs, required this.param});

  double? _getValue(WaterTestResults test) {
    switch (param) {
      case 'nitrate':
        return test.nitrate;
      case 'nitrite':
        return test.nitrite;
      case 'ammonia':
        return test.ammonia;
      case 'ph':
        return test.ph;
      case 'temp':
        return test.temperature;
      case 'gh':
        return test.gh;
      case 'kh':
        return test.kh;
      case 'phosphate':
        return test.phosphate;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = logs
        .where((l) => _getValue(l.waterTest!) != null)
        .map((l) => _getValue(l.waterTest!)!)
        .toList();

    if (values.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'No data for this parameter',
            style: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final avg = values.reduce((a, b) => a + b) / values.length;
    final latest = values.last;

    String fmt(double v) {
      if (param == 'nitrate') return v.toStringAsFixed(0);
      if (param == 'temp') return v.toStringAsFixed(1);
      if (param == 'ph') return v.toStringAsFixed(1);
      return v.toStringAsFixed(2);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatColumn(label: 'Latest', value: fmt(latest)),
            _StatColumn(label: 'Average', value: fmt(avg)),
            _StatColumn(label: 'Min', value: fmt(min)),
            _StatColumn(label: 'Max', value: fmt(max)),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.headlineSmall),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _ValuesTable extends StatelessWidget {
  final List<LogEntry> logs;

  const _ValuesTable({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Temp'), numeric: true),
            DataColumn(label: Text('pH'), numeric: true),
            DataColumn(label: Text('NH₃'), numeric: true),
            DataColumn(label: Text('NO₂'), numeric: true),
            DataColumn(label: Text('NO₃'), numeric: true),
            DataColumn(label: Text('GH'), numeric: true),
            DataColumn(label: Text('KH'), numeric: true),
            DataColumn(label: Text('PO₄'), numeric: true),
          ],
          rows: logs.map((log) {
            final test = log.waterTest!;
            return DataRow(
              cells: [
                DataCell(Text(DateFormat('MMM d').format(log.timestamp))),
                DataCell(Text(test.temperature?.toStringAsFixed(1) ?? '-')),
                DataCell(Text(test.ph?.toStringAsFixed(1) ?? '-')),
                DataCell(Text(test.ammonia?.toStringAsFixed(2) ?? '-')),
                DataCell(Text(test.nitrite?.toStringAsFixed(2) ?? '-')),
                DataCell(Text(test.nitrate?.toStringAsFixed(0) ?? '-')),
                DataCell(Text(test.gh?.toStringAsFixed(0) ?? '-')),
                DataCell(Text(test.kh?.toStringAsFixed(0) ?? '-')),
                DataCell(Text(test.phosphate?.toStringAsFixed(2) ?? '-')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
