import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/analytics.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_card.dart';

/// Card displaying a single prediction or goal in the analytics screen.
class AnalyticsPredictionCard extends StatelessWidget {
  final Prediction prediction;

  const AnalyticsPredictionCard({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm2),
      child: AppCard(
        padding: AppCardPadding.standard,
        backgroundColor: AppColors.infoAlpha10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_graph,
                  color: AppColors.info,
                  size: AppIconSizes.md,
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Text(
                    prediction.message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Text(
                    prediction.confidenceLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
                if (prediction.estimatedDate != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'ETA: ${DateFormat('d MMM').format(prediction.estimatedDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(178),
                    ),
                  ),
                ],
              ],
            ),
            if (prediction.recommendation != null) ...[
              const SizedBox(height: AppSpacing.sm2),
              Text(
                prediction.recommendation!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
