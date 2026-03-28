import 'package:flutter/material.dart';

import '../../models/analytics.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_card.dart';
import 'analytics_stat_card.dart';

/// Card displaying a single analytics insight or recommendation.
class AnalyticsInsightCard extends StatelessWidget {
  final AnalyticsInsight insight;

  const AnalyticsInsightCard({super.key, required this.insight});

  Color _colorForType(InsightType type) {
    switch (type) {
      case InsightType.achievement:
      case InsightType.milestone:
        return DanioColors.amberGold;
      case InsightType.improvement:
        return DanioColors.emeraldGreen;
      case InsightType.warning:
        return DanioColors.coralAccent;
      case InsightType.recommendation:
        return AppColors.info;
      case InsightType.pattern:
        return AppColors.accentAlt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(insight.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: AppCardPadding.standard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  insight.type.emoji,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Text(
                    insight.message,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AnalyticsStatCard.ensureTextContrast(color),
                    ),
                  ),
                ),
                if (insight.trend != null) Text(insight.trend!.emoji),
              ],
            ),
            if (insight.detailedMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                insight.detailedMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                ),
              ),
            ],
            if (insight.recommendation != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm2),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(color: color.withAlpha(76)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: color,
                      size: AppIconSizes.sm,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        insight.recommendation!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
