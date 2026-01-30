import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedParam = widget.initialParam;
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (logs) {
          final waterTests = logs
              .where((l) => l.type == LogType.waterTest && l.waterTest != null)
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          if (waterTests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No water tests yet', style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Log some water tests to see trends', style: AppTypography.bodyMedium),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                      const SizedBox(width: 8),
                      _ParamChip(
                        label: 'Nitrite',
                        isSelected: _selectedParam == 'nitrite',
                        onTap: () => setState(() => _selectedParam = 'nitrite'),
                      ),
                      const SizedBox(width: 8),
                      _ParamChip(
                        label: 'Ammonia',
                        isSelected: _selectedParam == 'ammonia',
                        onTap: () => setState(() => _selectedParam = 'ammonia'),
                      ),
                      const SizedBox(width: 8),
                      _ParamChip(
                        label: 'pH',
                        isSelected: _selectedParam == 'ph',
                        onTap: () => setState(() => _selectedParam = 'ph'),
                      ),
                      const SizedBox(width: 8),
                      _ParamChip(
                        label: 'Temp',
                        isSelected: _selectedParam == 'temp',
                        onTap: () => setState(() => _selectedParam = 'temp'),
                      ),
                      const SizedBox(width: 8),
                      _ParamChip(
                        label: 'GH',
                        isSelected: _selectedParam == 'gh',
                        onTap: () => setState(() => _selectedParam = 'gh'),
                      ),
                      const SizedBox(width: 8),
                      _ParamChip(
                        label: 'KH',
                        isSelected: _selectedParam == 'kh',
                        onTap: () => setState(() => _selectedParam = 'kh'),
                      ),
                      const SizedBox(width: 8),
                      _ParamChip(
                        label: 'Phosphate',
                        isSelected: _selectedParam == 'phosphate',
                        onTap: () => setState(() => _selectedParam = 'phosphate'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Chart
                Text(
                  _getParamTitle(_selectedParam),
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: _buildChart(
                    waterTests,
                    targets: tank?.targets,
                  ),
                ),

                const SizedBox(height: 32),

                // Summary stats
                Text('Summary', style: AppTypography.headlineSmall),
                const SizedBox(height: 12),
                _SummaryCard(
                  logs: waterTests,
                  param: _selectedParam,
                ),

                const SizedBox(height: 32),

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

  ({double? min, double? max}) _getTargetRange(WaterTargets targets, String param) {
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

    final xMax = (logs.length - 1).toDouble().clamp(0, double.infinity);

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
        belowBarData: BarAreaData(
          show: true,
          color: color.withOpacity(0.1),
        ),
      ),
    );

    if (targets != null) {
      final range = _getTargetRange(targets, _selectedParam);
      final targetColor = AppColors.textHint.withOpacity(0.8);

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
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.surfaceVariant,
            strokeWidth: 1,
          ),
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  Future<void> _exportCsv(BuildContext context, AsyncValue<List<LogEntry>> logsAsync) async {
    final logs = logsAsync.value;
    if (logs == null || logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    final waterTests = logs
        .where((l) => l.type == LogType.waterTest && l.waterTest != null)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (waterTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No water tests to export')),
      );
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
      buffer.writeln([
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
      ].join(','));
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/water_tests_export.csv');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Water Test Export',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

class _ParamChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ParamChip({required this.label, required this.isSelected, required this.onTap});

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
          padding: const EdgeInsets.all(16),
          child: Text('No data for this parameter', style: AppTypography.bodyMedium),
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
        padding: const EdgeInsets.all(16),
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
            return DataRow(cells: [
              DataCell(Text(DateFormat('MMM d').format(log.timestamp))),
              DataCell(Text(test.temperature?.toStringAsFixed(1) ?? '-')),
              DataCell(Text(test.ph?.toStringAsFixed(1) ?? '-')),
              DataCell(Text(test.ammonia?.toStringAsFixed(2) ?? '-')),
              DataCell(Text(test.nitrite?.toStringAsFixed(2) ?? '-')),
              DataCell(Text(test.nitrate?.toStringAsFixed(0) ?? '-')),
              DataCell(Text(test.gh?.toStringAsFixed(0) ?? '-')),
              DataCell(Text(test.kh?.toStringAsFixed(0) ?? '-')),
              DataCell(Text(test.phosphate?.toStringAsFixed(2) ?? '-')),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
