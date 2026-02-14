import 'package:flutter/material.dart';
import '../../../services/stocking_calculator.dart';
import '../../../theme/app_theme.dart';

class StockingIndicator extends StatelessWidget {
  final StockingResult result;

  const StockingIndicator({super.key, required this.result});

  Color _levelColor() {
    switch (result.level) {
      case StockingLevel.understocked:
        return AppColors.info;
      case StockingLevel.good:
        return AppColors.success;
      case StockingLevel.moderate:
        return AppColors.paramWarning;
      case StockingLevel.heavy:
        return AppColors.warning;
      case StockingLevel.overstocked:
        return AppColors.error;
    }
  }

  String _levelLabel() {
    switch (result.level) {
      case StockingLevel.understocked:
        return 'Understocked';
      case StockingLevel.good:
        return 'Good';
      case StockingLevel.moderate:
        return 'Moderate';
      case StockingLevel.heavy:
        return 'Heavy';
      case StockingLevel.overstocked:
        return 'Overstocked';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _levelColor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    'Stocking: ${_levelLabel()}',
                    style: AppTypography.labelLarge.copyWith(color: color),
                  ),
                  const Spacer(),
                  Text(
                    '${result.percentFull.toStringAsFixed(0)}%',
                    style: AppTypography.bodySmall.copyWith(color: color),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.xsRadius,
                child: LinearProgressIndicator(
                  value: (result.percentFull / 100).clamp(0, 1),
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(result.summary, style: AppTypography.bodySmall),
              if (result.warnings.isNotEmpty) ...[
                const SizedBox(height: 6),
                ...result.warnings.map(
                  (w) => Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          w,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
