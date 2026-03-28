/// Difficulty settings screen - View skill levels and manage difficulty preferences
/// Shows performance charts, skill levels by topic, and manual overrides
library;

import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

import 'package:flutter/material.dart';
import '../models/adaptive_difficulty.dart';
import '../services/difficulty_service.dart';

class DifficultySettingsScreen extends StatefulWidget {
  final UserSkillProfile skillProfile;
  final Function(UserSkillProfile) onProfileUpdated;

  const DifficultySettingsScreen({
    super.key,
    required this.skillProfile,
    required this.onProfileUpdated,
  });

  @override
  State<DifficultySettingsScreen> createState() =>
      _DifficultySettingsScreenState();
}

class _DifficultySettingsScreenState extends State<DifficultySettingsScreen> {
  final DifficultyService _difficultyService = DifficultyService();
  late UserSkillProfile _currentProfile;

  // Topic display names
  final Map<String, String> _topicNames = {
    'nitrogen_cycle': 'Nitrogen Cycle',
    'water_parameters': 'Water Parameters',
    'first_fish': 'First Fish',
    'maintenance': 'Maintenance',
    'planted_tank': 'Planted Tanks',
    'equipment': 'Equipment',
  };

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.skillProfile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Difficulty Settings'),
        elevation: AppElevation.level0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _buildItems().length,
        itemBuilder: (context, index) => _buildItems()[index],
      ),
    );
  }

  List<Widget> _buildItems() {
    return [
      _buildOverallSkillCard(),
      const SizedBox(height: AppSpacing.lg),
      _buildTopicSkillsSection(),
      const SizedBox(height: AppSpacing.lg),
      _buildPerformanceTrendsSection(),
      const SizedBox(height: AppSpacing.lg),
      _buildManualOverridesSection(),
      const SizedBox(height: AppSpacing.lg),
      _buildRecommendationsSection(),
    ];
  }

  /// Overall skill level card
  Widget _buildOverallSkillCard() {
    final overallSkill = _currentProfile.overallSkillLevel;
    final difficulty = _difficultyService.recommendDifficultyFromSkill(
      overallSkill,
    );

    return AppCard(
      padding: AppCardPadding.spacious,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Skill Level',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm2,
                  vertical: AppSpacing.xs2,
                ),
                decoration: BoxDecoration(
                  color: Color(
                    _difficultyService.getDifficultyColor(difficulty),
                  ).withAlpha(51),
                  borderRadius: AppRadius.largeRadius,
                  border: Border.all(
                    color: Color(
                      _difficultyService.getDifficultyColor(difficulty),
                    ),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      difficulty.emoji,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      difficulty.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(
                          _difficultyService.getDifficultyColor(difficulty),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSkillProgressBar(overallSkill),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${(overallSkill * 100).toInt()}% Mastery',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Topic-specific skill levels
  Widget _buildTopicSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills by Topic',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm2),
        ..._buildTopicSkillCards(),
      ],
    );
  }

  List<Widget> _buildTopicSkillCards() {
    final rankedTopics = _difficultyService.getTopicsRankedBySkill(
      profile: _currentProfile,
    );

    if (rankedTopics.isEmpty) {
      return [
        AppCard(
          padding: AppCardPadding.standard,
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: AppIconSizes.xl,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No lessons completed yet — start learning to see stats here!',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Complete a few lessons and your progress will appear here!',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return rankedTopics.map((entry) {
      final topicId = entry.key;
      final skillLevel = entry.value;
      final topicName = _topicNames[topicId] ?? topicId;
      final history = _currentProfile.getPerformanceHistory(topicId);
      final hasMastery =
          history != null &&
          _difficultyService.hasTopicMastery(
            history: history,
            skillLevel: skillLevel,
          );

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm2),
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
                      topicName,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (hasMastery)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppOverlays.amber20,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🏆',
                            style: Theme.of(context).textTheme.bodySmall!,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Mastered',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.xp,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm2),
              _buildSkillProgressBar(skillLevel),
              const SizedBox(height: AppSpacing.sm),
              if (history != null) _buildTopicStats(history),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTopicStats(PerformanceHistory history) {
    final summary = _difficultyService.getPerformanceSummary(history: history);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatChip(
          '${summary['attempts']} attempts',
          Icons.history,
          AppColors.primary,
        ),
        _buildStatChip(
          '${(summary['averageScore'] * 100).toInt()}% avg',
          Icons.score,
          AppColors.success,
        ),
        _buildStatChip(
          '${summary['trend'].emoji} ${summary['trend'].displayName}',
          Icons.trending_up,
          _getTrendColor(summary['trend'] as PerformanceTrend),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(PerformanceTrend trend) {
    switch (trend) {
      case PerformanceTrend.improving:
        return AppColors.success;
      case PerformanceTrend.stable:
        return AppColors.primary;
      case PerformanceTrend.declining:
        return AppColors.warning;
    }
  }

  /// Performance trends section
  Widget _buildPerformanceTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance History',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm2),
        _buildPerformanceHistoryCard(),
      ],
    );
  }

  Widget _buildPerformanceHistoryCard() {
    final allAttempts = <PerformanceRecord>[];
    for (final history in _currentProfile.performanceHistory.values) {
      allAttempts.addAll(history.recentAttempts);
    }

    if (allAttempts.isEmpty) {
      return AppCard(
        padding: AppCardPadding.standard,
        child: Center(
          child: Text(
            'Complete lessons to see your performance history',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    allAttempts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final recentFive = allAttempts.take(5).toList();

    return AppCard(
      padding: AppCardPadding.standard,
      child: Column(
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm2),
          ...recentFive.map((record) => _buildHistoryItem(record)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(PerformanceRecord record) {
    final topicName = _topicNames[record.topicId] ?? record.topicId;
    final scorePercent = (record.accuracy * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(
                _difficultyService.getDifficultyColor(record.difficulty),
              ).withAlpha(51),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Center(
              child: Text(
                record.difficulty.emoji,
                style: Theme.of(context).textTheme.titleLarge!,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topicName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatRelativeTime(record.timestamp),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: AppSpacing.xs2,
            ),
            decoration: BoxDecoration(
              color: _getScoreColor(scorePercent).withAlpha(51),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Text(
              '$scorePercent%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getScoreColor(scorePercent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int scorePercent) {
    if (scorePercent >= 90) return AppColors.success;
    if (scorePercent >= 70) return AppColors.primary;
    if (scorePercent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Manual overrides section
  Widget _buildManualOverridesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manual Difficulty Override',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Override automatic difficulty for specific topics',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.sm2),
        AppCard(
          padding: AppCardPadding.standard,
          child: Column(
            children: _topicNames.entries.map((entry) {
              return _buildOverrideRow(entry.key, entry.value);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOverrideRow(String topicId, String topicName) {
    final currentOverride = _currentProfile.getManualOverride(topicId);
    final recommendation = _difficultyService.getDifficultyRecommendation(
      topicId: topicId,
      profile: _currentProfile,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topicName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (currentOverride == null)
                  Text(
                    '${recommendation.suggestedLevel.emoji} ${recommendation.suggestedLevel.displayName} (Auto)',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: DropdownButton<DifficultyLevel?>(
              value: currentOverride,
              isExpanded: true,
              hint: const Text('Auto (Recommended)'),
              items: [
                const DropdownMenuItem<DifficultyLevel?>(
                  value: null,
                  child: Text('🤖 Auto (Recommended)'),
                ),
                ...DifficultyLevel.values.map((level) {
                  return DropdownMenuItem<DifficultyLevel>(
                    value: level,
                    child: Text('${level.emoji} ${level.displayName}'),
                  );
                }),
              ],
              onChanged: (newValue) {
                setState(() {
                  _currentProfile = _currentProfile.setManualOverride(
                    topicId,
                    newValue,
                  );
                  widget.onProfileUpdated(_currentProfile);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Recommendations section
  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Recommendations',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm2),
        ..._buildRecommendationCards(),
      ],
    );
  }

  List<Widget> _buildRecommendationCards() {
    final recommendations = <Widget>[];

    for (final entry in _topicNames.entries) {
      final topicId = entry.key;
      final topicName = entry.value;
      final recommendation = _difficultyService.getDifficultyRecommendation(
        topicId: topicId,
        profile: _currentProfile,
      );

      if (recommendation.shouldIncrease || recommendation.shouldDecrease) {
        recommendations.add(
          AppCard(
            backgroundColor: recommendation.shouldIncrease
                ? AppColors.successAlpha10
                : AppColors.warningAlpha10,
            padding: AppCardPadding.standard,
            child: Row(
              children: [
                Icon(
                  recommendation.shouldIncrease
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: recommendation.shouldIncrease
                      ? AppColors.success
                      : AppColors.warning,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topicName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(recommendation.reason),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Suggested: ${recommendation.suggestedLevel.emoji} ${recommendation.suggestedLevel.displayName}',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        AppCard(
          padding: AppCardPadding.standard,
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: AppIconSizes.lg,
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Text(
                  'No changes recommended. Keep up the great work!',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return recommendations;
  }

  /// Skill progress bar
  Widget _buildSkillProgressBar(double skillLevel) {
    return ClipRRect(
      borderRadius: AppRadius.smallRadius,
      child: LinearProgressIndicator(
        value: skillLevel,
        minHeight: 12,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? context.surfaceVariant
            : context.borderColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          _getSkillLevelColor(skillLevel),
        ),
      ),
    );
  }

  Color _getSkillLevelColor(double skillLevel) {
    if (skillLevel < 0.3) return AppColors.error;
    if (skillLevel < 0.6) return AppColors.warning;
    if (skillLevel < 0.8) return AppColors.primary;
    return AppColors.success;
  }
}
