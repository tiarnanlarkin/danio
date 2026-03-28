import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

/// Full-size parameter field for the standard water test form.
class WaterParamField extends StatelessWidget {
  final String label;
  final String? unit;
  final double? value;
  final ValueChanged<double?> onChanged;
  final bool decimal;
  final double? warningThreshold;
  final double? dangerThreshold;
  final String? idealRange;
  final double? maxValue;

  const WaterParamField({
    super.key,
    required this.label,
    this.unit,
    required this.value,
    required this.onChanged,
    this.decimal = false,
    this.warningThreshold,
    this.dangerThreshold,
    this.idealRange,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return ParameterField(
      label: label,
      unit: unit,
      value: value,
      onChanged: onChanged,
      decimal: decimal,
      warningThreshold: warningThreshold,
      dangerThreshold: dangerThreshold,
      idealRange: idealRange,
      maxValue: maxValue,
    );
  }
}

/// Lays out a row of water param fields with consistent spacing.
/// Null entries become empty spacers for alignment.
class WaterParamRow extends StatelessWidget {
  final List<WaterParamField?> fields;

  const WaterParamRow({super.key, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm2),
          Expanded(child: fields[i] ?? const SizedBox()),
        ],
      ],
    );
  }
}

/// Core text field for a water parameter with status colour indicator.
class ParameterField extends StatelessWidget {
  final String label;
  final String? unit;
  final double? value;
  final ValueChanged<double?> onChanged;
  final bool decimal;
  final double? warningThreshold;
  final double? dangerThreshold;
  final String? idealRange;
  final double? maxValue;

  const ParameterField({
    super.key,
    required this.label,
    this.unit,
    required this.value,
    required this.onChanged,
    this.decimal = false,
    this.warningThreshold,
    this.dangerThreshold,
    this.idealRange,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    Color? statusColor;
    String? statusText;
    if (value != null) {
      if (dangerThreshold != null && value! >= dangerThreshold!) {
        statusColor = AppColors.paramDanger;
        statusText = '✕ Danger';
      } else if (warningThreshold != null && value! >= warningThreshold!) {
        statusColor = AppColors.paramWarning;
        statusText = '⚠ Warning';
      } else if (warningThreshold != null || dangerThreshold != null) {
        statusColor = AppColors.paramSafe;
        statusText = '✓ Safe';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          initialValue: value?.toString() ?? '',
          decoration: InputDecoration(
            labelText: label,
            suffixText: unit,
            suffixIcon: statusColor != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        statusText!,
                        style: AppTypography.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(Icons.circle, color: statusColor, size: 12),
                    ],
                  )
                : null,
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          onChanged: (v) => onChanged(double.tryParse(v)),
          validator: (v) {
            if (v != null && v.isNotEmpty) {
              final n = double.tryParse(v);
              if (n == null) return 'Enter a valid number';
              if (n < 0) return 'Must be ≥ 0';
              if (maxValue != null && n > maxValue!) {
                return 'Max: $maxValue ${unit ?? ''}';
              }
            }
            return null;
          },
        ),
        if (idealRange != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              idealRange!,
              style: AppTypography.bodySmall.copyWith(color: context.textHint),
            ),
          ),
      ],
    );
  }
}

/// Compact parameter field for the bulk/quick-entry grid.
class CompactParamField extends StatelessWidget {
  final String label;
  final String? unit;
  final double? value;
  final ValueChanged<double?> onChanged;
  final bool decimal;
  final double? warningThreshold;
  final double? dangerThreshold;
  final String? idealRange;
  final double? maxValue;

  const CompactParamField({
    super.key,
    required this.label,
    this.unit,
    required this.value,
    required this.onChanged,
    this.decimal = false,
    this.warningThreshold,
    this.dangerThreshold,
    this.idealRange,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    Color? statusColor;
    String? statusText;
    if (value != null) {
      if (dangerThreshold != null && value! >= dangerThreshold!) {
        statusColor = AppColors.paramDanger;
        statusText = '✕ Danger';
      } else if (warningThreshold != null && value! >= warningThreshold!) {
        statusColor = AppColors.paramWarning;
        statusText = '⚠ Warning';
      } else if (warningThreshold != null || dangerThreshold != null) {
        statusColor = AppColors.paramSafe;
        statusText = '✓ Safe';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (statusColor != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusText!,
                    style: AppTypography.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.circle, color: statusColor, size: 8),
                ],
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          initialValue: value?.toString() ?? '',
          decoration: InputDecoration(
            hintText: unit ?? '--',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: AppRadius.smallRadius),
          ),
          style: AppTypography.bodySmall.copyWith(),
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          onChanged: (v) => onChanged(double.tryParse(v)),
          validator: (v) {
            if (v != null && v.isNotEmpty) {
              final n = double.tryParse(v);
              if (n == null) return 'Invalid';
              if (n < 0) return '≥ 0';
              if (maxValue != null && n > maxValue!) return '≤ $maxValue';
            }
            return null;
          },
        ),
        if (idealRange != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Text(
              idealRange!,
              style: AppTypography.bodySmall.copyWith(color: context.textHint),
            ),
          ),
      ],
    );
  }
}
