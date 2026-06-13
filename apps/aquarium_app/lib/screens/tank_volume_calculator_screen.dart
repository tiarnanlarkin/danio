import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/core/app_card.dart';

class TankVolumeCalculatorScreen extends ConsumerStatefulWidget {
  final String? tankId;

  const TankVolumeCalculatorScreen({super.key, this.tankId});

  @override
  ConsumerState<TankVolumeCalculatorScreen> createState() =>
      _TankVolumeCalculatorScreenState();
}

class _TankVolumeCalculatorScreenState
    extends ConsumerState<TankVolumeCalculatorScreen> {
  _TankShape _shape = _TankShape.rectangular;
  bool _isApplyingVolume = false;

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

  bool _isPositive(double? value) => value != null && value > 0;

  double? get _volume {
    switch (_shape) {
      case _TankShape.rectangular:
        if (_isPositive(_length) &&
            _isPositive(_width) &&
            _isPositive(_height)) {
          var l = _length!, w = _width!, h = _height!;
          if (!_useMetric) {
            l *= 2.54;
            w *= 2.54;
            h *= 2.54;
          }
          return (l * w * h) / 1000; // cubic cm to litres
        }
        break;
      case _TankShape.cylindrical:
        if (_isPositive(_diameter) && _isPositive(_cylinderHeight)) {
          var d = _diameter!, h = _cylinderHeight!;
          if (!_useMetric) {
            d *= 2.54;
            h *= 2.54;
          }
          return (pi * pow(d / 2, 2) * h) / 1000;
        }
        break;
      case _TankShape.bowFront:
        if (_isPositive(_bowLength) &&
            _isPositive(_bowWidth) &&
            _isPositive(_bowHeight) &&
            _isPositive(_bowDepth)) {
          var l = _bowLength!, w = _bowWidth!, h = _bowHeight!, d = _bowDepth!;
          if (!_useMetric) {
            l *= 2.54;
            w *= 2.54;
            h *= 2.54;
            d *= 2.54;
          }
          // Approximate: rectangular base + half-cylinder for the bow.
          // Bow protrudes `d` cm from the front panel; model as a
          // half-cylinder: V = (pi * r^2) / 2 * length, where r = d.
          final rectVolume = l * w * h;
          final bowVolume = (pi * pow(d, 2) / 2) * l;
          return (rectVolume + bowVolume) / 1000;
        }
        break;
      case _TankShape.hexagonal:
        if (_isPositive(_length) && _isPositive(_height)) {
          var s = _length!, h = _height!; // s = side length
          if (!_useMetric) {
            s *= 2.54;
            h *= 2.54;
          }
          // Area of regular hexagon = (3 * sqrt(3) / 2) * s^2
          final area = (3 * sqrt(3) / 2) * pow(s, 2);
          return (area * h) / 1000;
        }
        break;
      case _TankShape.corner:
        if (_isPositive(_length) && _isPositive(_height)) {
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

  bool get _canApplyToTank => widget.tankId != null && _volume != null;

  Future<void> _applyVolumeToTank() async {
    final tankId = widget.tankId;
    final volume = _volume;
    if (tankId == null || volume == null || volume <= 0 || _isApplyingVolume) {
      return;
    }

    setState(() => _isApplyingVolume = true);
    try {
      final tank = await ref.read(tankProvider(tankId).future);
      if (tank == null) {
        throw StateError('Tank not found');
      }

      await ref
          .read(tankActionsProvider)
          .updateTank(tank.copyWith(volumeLitres: volume));

      if (!mounted) return;
      AppFeedback.showSuccess(
        context,
        'Updated tank volume to ${volume.toStringAsFixed(1)} L.',
      );
    } catch (_) {
      if (!mounted) return;
      AppFeedback.showError(context, 'Could not update this tank volume.');
    } finally {
      if (mounted) {
        setState(() => _isApplyingVolume = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tank Volume Calculator')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unit toggle
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Units:', style: AppTypography.bodyMedium),
                  _selectorChip(
                    context: context,
                    label: 'Metric (cm)',
                    selected: _useMetric,
                    onSelected: (_) => setState(() => _useMetric = true),
                  ),
                  _selectorChip(
                    context: context,
                    label: 'Imperial (in)',
                    selected: !_useMetric,
                    onSelected: (_) => setState(() => _useMetric = false),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Shape selector
              Text('Tank Shape', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm2),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _TankShape.values
                    .map(
                      (s) => _selectorChip(
                        context: context,
                        label: s.label,
                        selected: _shape == s,
                        onSelected: (_) => setState(() => _shape = s),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Dimensions
              Text('Dimensions', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm2),
              _buildDimensionInputs(),

              const SizedBox(height: AppSpacing.xl),

              // Result
              if (_volume == null) ...[
                AppCard(
                  backgroundColor: AppOverlays.info10,
                  padding: AppCardPadding.spacious,
                  child: Column(
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        color: context.textHint,
                        size: AppIconSizes.lg,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Enter dimensions above to calculate',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textHint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                AppCard(
                  backgroundColor: AppOverlays.primary10,
                  padding: AppCardPadding.spacious,
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
                        '${(_volume! / 3.785).toStringAsFixed(1)} US gal - ${(_volume! / 4.546).toStringAsFixed(1)} UK gal',
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
              ],

              if (_canApplyToTank) ...[
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  backgroundColor: AppOverlays.info10,
                  padding: AppCardPadding.standard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.route_outlined,
                            color: AppColors.info,
                            size: AppIconSizes.sm,
                          ),
                          const SizedBox(width: AppSpacing.sm2),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Guided next step',
                                  style: AppTypography.labelLarge,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Apply this calculated volume to your tank profile so care tools use the same number.',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton.icon(
                        onPressed: _isApplyingVolume
                            ? null
                            : _applyVolumeToTank,
                        icon: _isApplyingVolume
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text('Apply to tank profile'),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Tips
              AppCard(
                padding: AppCardPadding.standard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tips', style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '- Actual water volume is about 90% of total (substrate, decor)',
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      '- 1 litre of water weighs 1 kg',
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      '- Add tank weight + stand capacity when planning placement',
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      '- Internal dimensions give more accurate results',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ChoiceChip _selectorChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.primaryAlpha08,
      checkmarkColor: AppColors.textPrimaryDark,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.primaryAlpha20,
      ),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: selected ? AppColors.textPrimaryDark : context.textPrimary,
        fontWeight: FontWeight.w700,
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
            const SizedBox(height: AppSpacing.sm2),
            _DimensionField(
              label: 'Width',
              unit: unit,
              onChanged: (v) => setState(() => _width = v),
            ),
            const SizedBox(height: AppSpacing.sm2),
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
            const SizedBox(height: AppSpacing.sm2),
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
            const SizedBox(height: AppSpacing.sm2),
            _DimensionField(
              label: 'Width (back)',
              unit: unit,
              onChanged: (v) => setState(() => _bowWidth = v),
            ),
            const SizedBox(height: AppSpacing.sm2),
            _DimensionField(
              label: 'Height',
              unit: unit,
              onChanged: (v) => setState(() => _bowHeight = v),
            ),
            const SizedBox(height: AppSpacing.sm2),
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
            const SizedBox(height: AppSpacing.sm2),
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
            const SizedBox(height: AppSpacing.sm2),
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
  corner('Corner (90 deg)');

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
