import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class TankVolumeCalculatorScreen extends StatefulWidget {
  const TankVolumeCalculatorScreen({super.key});

  @override
  State<TankVolumeCalculatorScreen> createState() =>
      _TankVolumeCalculatorScreenState();
}

class _TankVolumeCalculatorScreenState
    extends State<TankVolumeCalculatorScreen> {
  _TankShape _shape = _TankShape.rectangular;

  // Rectangular
  double? _length;
  double? _width;
  double? _height;

  // Cylindrical
  double? _diameter;
  double? _cylinderHeight;

  // Bow front
  double? _bowLength;
  double? _bowWidth;
  double? _bowHeight;
  double? _bowDepth; // How far the bow extends

  bool _useMetric = true;

  double? get _volume {
    switch (_shape) {
      case _TankShape.rectangular:
        if (_length != null && _width != null && _height != null) {
          var l = _length!, w = _width!, h = _height!;
          if (!_useMetric) {
            l *= 2.54;
            w *= 2.54;
            h *= 2.54;
          }
          return (l * w * h) / 1000; // cm³ to litres
        }
        break;
      case _TankShape.cylindrical:
        if (_diameter != null && _cylinderHeight != null) {
          var d = _diameter!, h = _cylinderHeight!;
          if (!_useMetric) {
            d *= 2.54;
            h *= 2.54;
          }
          return (pi * pow(d / 2, 2) * h) / 1000;
        }
        break;
      case _TankShape.bowFront:
        if (_bowLength != null &&
            _bowWidth != null &&
            _bowHeight != null &&
            _bowDepth != null) {
          var l = _bowLength!, w = _bowWidth!, h = _bowHeight!, d = _bowDepth!;
          if (!_useMetric) {
            l *= 2.54;
            w *= 2.54;
            h *= 2.54;
            d *= 2.54;
          }
          // Approximate: rectangular base + half cylinder for bow
          final rectVolume = l * w * h;
          final bowVolume = (pi * pow(d, 2) * l) / 4; // Approximate
          return (rectVolume + bowVolume / 2) / 1000;
        }
        break;
      case _TankShape.hexagonal:
        if (_length != null && _height != null) {
          var s = _length!, h = _height!; // s = side length
          if (!_useMetric) {
            s *= 2.54;
            h *= 2.54;
          }
          // Area of regular hexagon = (3√3/2) × s²
          final area = (3 * sqrt(3) / 2) * pow(s, 2);
          return (area * h) / 1000;
        }
        break;
      case _TankShape.corner:
        if (_length != null && _height != null) {
          var l = _length!, h = _height!;
          if (!_useMetric) {
            l *= 2.54;
            h *= 2.54;
          }
          // Quarter cylinder approximation
          return (pi * pow(l, 2) * h / 4) / 1000;
        }
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tank Volume Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit toggle
            Row(
              children: [
                Text('Units:', style: AppTypography.bodyMedium),
                const SizedBox(width: AppSpacing.md),
                ChoiceChip(
                  label: const Text('Metric (cm)'),
                  selected: _useMetric,
                  onSelected: (_) => setState(() => _useMetric = true),
                ),
                const SizedBox(width: AppSpacing.sm),
                ChoiceChip(
                  label: const Text('Imperial (in)'),
                  selected: !_useMetric,
                  onSelected: (_) => setState(() => _useMetric = false),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Shape selector
            Text('Tank Shape', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _TankShape.values
                  .map(
                    (s) => ChoiceChip(
                      label: Text(s.label),
                      selected: _shape == s,
                      onSelected: (_) => setState(() => _shape = s),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Dimensions
            Text('Dimensions', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            _buildDimensionInputs(),

            const SizedBox(height: AppSpacing.xl),

            // Result
            if (_volume != null) ...[
              Card(
                color: AppColors.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Estimated Volume', style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_volume!.toStringAsFixed(1)} L',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${(_volume! / 3.785).toStringAsFixed(1)} US gal  •  ${(_volume! / 4.546).toStringAsFixed(1)} UK gal',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _QuickStat(
                            label: 'Usable (~90%)',
                            value: '${(_volume! * 0.9).toStringAsFixed(0)} L',
                          ),
                          _QuickStat(
                            label: 'Weight (full)',
                            value: '${_volume!.toStringAsFixed(0)} kg',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Tips
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tips', style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '• Actual water volume is ~90% of total (substrate, decor)',
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      '• 1 litre of water weighs 1 kg',
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      '• Add tank weight + stand capacity when planning placement',
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      '• Internal dimensions give more accurate results',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionInputs() {
    final unit = _useMetric ? 'cm' : 'in';

    switch (_shape) {
      case _TankShape.rectangular:
        return Column(
          children: [
            _DimensionField(
              label: 'Length',
              unit: unit,
              onChanged: (v) => setState(() => _length = v),
            ),
            const SizedBox(height: 12),
            _DimensionField(
              label: 'Width',
              unit: unit,
              onChanged: (v) => setState(() => _width = v),
            ),
            const SizedBox(height: 12),
            _DimensionField(
              label: 'Height',
              unit: unit,
              onChanged: (v) => setState(() => _height = v),
            ),
          ],
        );

      case _TankShape.cylindrical:
        return Column(
          children: [
            _DimensionField(
              label: 'Diameter',
              unit: unit,
              onChanged: (v) => setState(() => _diameter = v),
            ),
            const SizedBox(height: 12),
            _DimensionField(
              label: 'Height',
              unit: unit,
              onChanged: (v) => setState(() => _cylinderHeight = v),
            ),
          ],
        );

      case _TankShape.bowFront:
        return Column(
          children: [
            _DimensionField(
              label: 'Length',
              unit: unit,
              onChanged: (v) => setState(() => _bowLength = v),
            ),
            const SizedBox(height: 12),
            _DimensionField(
              label: 'Width (back)',
              unit: unit,
              onChanged: (v) => setState(() => _bowWidth = v),
            ),
            const SizedBox(height: 12),
            _DimensionField(
              label: 'Height',
              unit: unit,
              onChanged: (v) => setState(() => _bowHeight = v),
            ),
            const SizedBox(height: 12),
            _DimensionField(
              label: 'Bow depth',
              unit: unit,
              hint: 'How far the bow extends',
              onChanged: (v) => setState(() => _bowDepth = v),
            ),
          ],
        );

      case _TankShape.hexagonal:
        return Column(
          children: [
            _DimensionField(
              label: 'Side length',
              unit: unit,
              onChanged: (v) => setState(() => _length = v),
            ),
            const SizedBox(height: 12),
            _DimensionField(
              label: 'Height',
              unit: unit,
              onChanged: (v) => setState(() => _height = v),
            ),
          ],
        );

      case _TankShape.corner:
        return Column(
          children: [
            _DimensionField(
              label: 'Side length',
              unit: unit,
              hint: 'Both sides equal',
              onChanged: (v) => setState(() => _length = v),
            ),
            const SizedBox(height: 12),
            _DimensionField(
              label: 'Height',
              unit: unit,
              onChanged: (v) => setState(() => _height = v),
            ),
          ],
        );
    }
  }
}

enum _TankShape {
  rectangular('Rectangular'),
  cylindrical('Cylindrical'),
  bowFront('Bow Front'),
  hexagonal('Hexagonal'),
  corner('Corner (90°)');

  final String label;
  const _TankShape(this.label);
}

class _DimensionField extends StatelessWidget {
  final String label;
  final String unit;
  final String? hint;
  final ValueChanged<double?> onChanged;

  const _DimensionField({
    required this.label,
    required this.unit,
    this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: unit,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      onChanged: (v) => onChanged(double.tryParse(v)),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;

  const _QuickStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.labelLarge),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}
