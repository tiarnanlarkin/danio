import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class Co2CalculatorScreen extends StatefulWidget {
  const Co2CalculatorScreen({super.key});

  @override
  State<Co2CalculatorScreen> createState() => _Co2CalculatorScreenState();
}

class _Co2CalculatorScreenState extends State<Co2CalculatorScreen> {
  final _phController = TextEditingController(text: '7.0');
  final _khController = TextEditingController(text: '4');

  double? _co2Level;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _phController.dispose();
    _khController.dispose();
    super.dispose();
  }

  // Validation error message (shown below the inputs)
  String? _validationError;

  void _calculate() {
    final ph = double.tryParse(_phController.text);
    final kh = double.tryParse(_khController.text);

    if (ph == null || kh == null) {
      setState(() {
        _co2Level = null;
        _validationError = null;
      });
      return;
    }

    // Bounds check: pH must be 0.1–14, KH must be 0.1–50
    if (ph < 0.1 || ph > 14.0) {
      setState(() {
        _co2Level = null;
        _validationError = 'pH must be between 0.1 and 14.0';
      });
      return;
    }
    if (kh <= 0 || kh > 50) {
      setState(() {
        _co2Level = null;
        _validationError = 'KH must be between 0.1 and 50 dKH';
      });
      return;
    }

    // CO2 (ppm) = 3 × KH × 10^(7-pH)
    final co2 = 3 * kh * _pow10(7 - ph);
    setState(() {
      _co2Level = co2;
      _validationError = null;
    });
  }

  double _pow10(double exp) {
    return math.pow(10, exp).toDouble();
  }

  String get _co2Status {
    if (_co2Level == null) return 'Enter values';
    if (_co2Level! < 10) return 'Too Low';
    if (_co2Level! < 20) return 'Low';
    if (_co2Level! <= 30) return 'Optimal';
    if (_co2Level! <= 40) return 'High';
    return 'Dangerous';
  }

  Color get _co2Color {
    if (_co2Level == null) return AppColors.textHint;
    if (_co2Level! < 20) return AppColors.warning;
    if (_co2Level! <= 30) return AppColors.success;
    if (_co2Level! <= 40) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
      appBar: AppBar(title: const Text('CO2 Calculator')),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: _buildItems().length,
        itemBuilder: (context, index) => _buildItems()[index],
      ),
    ),
    );
  }

  List<Widget> _buildItems() {
    return [
          AppCard(
            backgroundColor: AppOverlays.info10,
            padding: AppCardPadding.standard,
            child: Row(
              children: [
                Icon(Icons.bubble_chart, size: AppIconSizes.lg, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Text(
                    'Calculate dissolved CO2 from your pH and KH readings. Optimal range is 20-30 ppm for planted tanks.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text('Enter Your Readings', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phController,
                  decoration: const InputDecoration(
                    labelText: 'pH',
                    border: OutlineInputBorder(),
                    helperText: '0.1 – 14.0',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: (_) => _calculate(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _khController,
                  decoration: const InputDecoration(
                    labelText: 'KH (dKH)',
                    border: OutlineInputBorder(),
                    helperText: '0.1 – 50 dKH',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: (_) => _calculate(),
                ),
              ),
            ],
          ),

          // Validation error
          if (_validationError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: AppColors.error),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _validationError!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Result
          AppCard(
            backgroundColor: _co2Color.withAlpha(26),
            padding: AppCardPadding.spacious,
            child: Column(
              children: [
                Text('Estimated CO2 Level', style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _co2Level != null
                      ? '${_co2Level!.toStringAsFixed(1)} ppm'
                      : '-',
                  style: AppTypography.headlineLarge.copyWith(
                    color: _co2Color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _co2Status,
                  style: AppTypography.bodyMedium.copyWith(color: _co2Color),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Reference chart
          Text('CO2 Reference Chart', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm2),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              children: [
                _RefRow(
                  range: '< 10 ppm',
                  status: 'Too Low',
                  desc: 'Plants will struggle',
                  color: AppColors.warning,
                ),
                _RefRow(
                  range: '10-20 ppm',
                  status: 'Low',
                  desc: 'Acceptable for low-tech',
                  color: AppColors.warning,
                ),
                _RefRow(
                  range: '20-30 ppm',
                  status: 'Optimal',
                  desc: 'Ideal for planted tanks',
                  color: AppColors.success,
                ),
                _RefRow(
                  range: '30-40 ppm',
                  status: 'High',
                  desc: 'Monitor fish closely',
                  color: AppColors.warning,
                ),
                _RefRow(
                  range: '> 40 ppm',
                  status: 'Dangerous',
                  desc: 'Fish stress/death risk',
                  color: AppColors.error,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text('Drop Checker Colors', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm2),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              children: [
                _DropCheckerRow(
                  color: AppColors.info,
                  label: 'Blue',
                  meaning: 'CO2 too low (<20 ppm)',
                ),
                _DropCheckerRow(
                  color: AppColors.success,
                  label: 'Green',
                  meaning: 'CO2 optimal (20-30 ppm)',
                ),
                _DropCheckerRow(
                  color: AppColors.warning,
                  label: 'Yellow',
                  meaning: 'CO2 too high (>30 ppm)',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text('Tips', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm2),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TipRow(
                  text:
                      'Measure pH at the same time each day for consistency',
                ),
                _TipRow(
                  text: 'KH stabilizes pH - don\'t let it drop below 2 dKH',
                ),
                _TipRow(text: 'CO2 drops at night when plants respire'),
                _TipRow(text: 'Drop checkers lag ~2 hours behind actual CO2'),
                _TipRow(text: 'Surface agitation reduces CO2 levels'),
                _TipRow(
                  text: 'Increase CO2 slowly over days, not all at once',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // pH/KH/CO2 relationship table
          Text('pH/KH/CO2 Table', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm2),

          AppCard(
            padding: AppCardPadding.compact,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 40,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 32,
                columns: const [
                  DataColumn(label: Text('pH \\ KH')),
                  DataColumn(label: Text('2')),
                  DataColumn(label: Text('4')),
                  DataColumn(label: Text('6')),
                  DataColumn(label: Text('8')),
                  DataColumn(label: Text('10')),
                ],
                rows: [
                  _buildRow('6.0', [24, 48, 71, 95, 119]),
                  _buildRow('6.4', [9, 19, 28, 38, 48]),
                  _buildRow('6.8', [4, 8, 11, 15, 19]),
                  _buildRow('7.0', [2, 5, 7, 10, 12]),
                  _buildRow('7.2', [2, 3, 5, 6, 8]),
                  _buildRow('7.6', [1, 1, 2, 3, 3]),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
          Text(
            'Values in ppm. Green = optimal range.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl),
    ];
  }

  DataRow _buildRow(String ph, List<int> values) {
    return DataRow(
      cells: [
        DataCell(Text(ph, style: AppTypography.labelLarge)),
        ...values.map(
          (v) => DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: AppSpacing.xxs),
              decoration: BoxDecoration(
                color: v >= 20 && v <= 30
                    ? AppColors.successAlpha20
                    : null,
                borderRadius: AppRadius.xsRadius,
              ),
              child: Text('$v', style: AppTypography.bodySmall),
            ),
          ),
        ),
      ],
    );
  }
}

class _RefRow extends StatelessWidget {
  final String range;
  final String status;
  final String desc;
  final Color color;

  const _RefRow({
    required this.range,
    required this.status,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(range, style: AppTypography.bodySmall),
          ),
          SizedBox(
            width: 85,
            child: Text(
              status,
              style: AppTypography.labelLarge.copyWith(color: color),
            ),
          ),
          Expanded(child: Text(desc, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _DropCheckerRow extends StatelessWidget {
  final Color color;
  final String label;
  final String meaning;

  const _DropCheckerRow({
    required this.color,
    required this.label,
    required this.meaning,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs2),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(width: AppSpacing.sm2),
          SizedBox(
            width: 60,
            child: Text(label, style: AppTypography.labelLarge),
          ),
          Expanded(child: Text(meaning, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;

  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTypography.bodyMedium),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
