import 'package:flutter/material.dart';

import '../../models/analytics.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/app_card.dart';

/// Card displaying progress and XP for a single learning topic.
class AnalyticsTopicCard extends StatelessWidget {
  final TopicPerformance topic;

  const AnalyticsTopicCard({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: AppCardPadding.standard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    topic.topicName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  topic.trend.emoji,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm2),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(
                        value: topic.masteryPercentage,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? context.surfaceVariant
                            : context.borderColor,
                        color: topic.isStrong
                            ? DanioColors.emeraldGreen
                            : topic.needsWork
                            ? DanioColors.coralAccent
                            : AppColors.info,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${topic.lessonsCompleted}/${topic.totalLessons} lessons (${(topic.masteryPercentage * 100).toInt()}%)',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${topic.totalXP} XP',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: DanioColors.amberGold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${topic.timeSpentMinutes} min',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(153),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
