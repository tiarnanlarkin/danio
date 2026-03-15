import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

class TrendsRow extends StatelessWidget {
  final Tank tank;
  final List<LogEntry> logs;
  final ValueChanged<String> onOpenCharts;

  const TrendsRow({
    super.key,
    required this.tank,
    required this.logs,
    required this.onOpenCharts,
  });

  @override
  Widget build(BuildContext context) {
    final tests =
        logs
            .where((l) => l.type == LogType.waterTest && l.waterTest != null)
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (tests.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trends', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No trend data yet - log a few water tests.',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    const params = <String>[
      'temp',
      'ph',
      'ammonia',
      'nitrite',
      'nitrate',
      'gh',
      'kh',
      'phosphate',
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Trends', style: AppTypography.headlineSmall),
                const Spacer(),
                Text(
                  'last ${tests.length.clamp(0, 50)} tests',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm2),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: params.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm3),
                itemBuilder: (context, index) {
                  final p = params[index];
                  return SparklineCard(
                    param: p,
                    tests: tests,
                    onTap: () => onOpenCharts(p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SparklineCard extends StatelessWidget {
  final String param;
  final List<LogEntry> tests;
  final VoidCallback onTap;

  const SparklineCard({
    super.key,
    required this.param,
    required this.tests,
    required this.onTap,
  });

  String _label() {
    switch (param) {
      case 'temp':
        return 'Temp';
      case 'ph':
        return 'pH';
      case 'ammonia':
        return 'NH₃';
      case 'nitrite':
        return 'NO₂';
      case 'nitrate':
        return 'NO₃';
      case 'gh':
        return 'GH';
      case 'kh':
        return 'KH';
      case 'phosphate':
        return 'PO₄';
      default:
        return param;
    }
  }

  Color _color() {
    switch (param) {
      case 'nitrate':
        return AppColors.warning;
      case 'nitrite':
        return AppColors.error;
      case 'ammonia':
        return AppColors.accentAlt;
      case 'ph':
        return AppColors.primary;
      case 'temp':
        return AppColors.secondary;
      case 'gh':
        return AppColors.woodBrown;
      case 'kh':
        return AppColors.secondaryDark;
      case 'phosphate':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  double? _value(WaterTestResults t) {
    switch (param) {
      case 'temp':
        return t.temperature;
      case 'ph':
        return t.ph;
      case 'ammonia':
        return t.ammonia;
      case 'nitrite':
        return t.nitrite;
      case 'nitrate':
        return t.nitrate;
      case 'gh':
        return t.gh;
      case 'kh':
        return t.kh;
      case 'phosphate':
        return t.phosphate;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = <double>[];
    for (final l in tests) {
      final v = _value(l.waterTest!);
      if (v != null) values.add(v);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mediumRadius,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(AppSpacing.sm2),
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(color: AppOverlays.surfaceVariant60),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_label(), style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: values.length < 2
                  ? Center(child: Text('-', style: AppTypography.bodySmall))
                  : MiniSparkline(values: values, color: _color()),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniSparkline extends StatelessWidget {
  final List<double> values;
  final Color color;

  const MiniSparkline({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withAlpha(26),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
