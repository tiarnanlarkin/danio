/// Difficulty settings screen - View skill levels and manage difficulty preferences
/// Shows performance charts, skill levels by topic, and manual overrides
library;
import 'package:aquarium_app/theme/app_theme.dart';
import 'package:aquarium_app/widgets/core/app_card.dart';

import 'package:flutter/material.dart';
import '../models/adaptive_difficulty.dart';
import '../services/difficulty_service.dart';

class DifficultySettingsScreen extends StatefulWidget {
  final UserSkillProfile skillProfile;
  final Function(UserSkillProfile) onProfileUpdated;

  const DifficultySettingsScreen({
    Key? key,
    required this.skillProfile,
    required this.onProfileUpdated,
  }) : super(key: key);

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
      appBar: AppBar(title: const Text('Difficulty Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildOverallSkillCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildTopicSkillsSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildPerformanceTrendsSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildManualOverridesSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildRecommendationsSection(),
        ],
      ),
    );
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
                const Text(
                  'Overall Skill Level',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      _difficultyService.getDifficultyColor(difficulty),
                    ).withOpacity(0.2),
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
                        style: const TextStyle(fontSize: 16),
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
              style: const TextStyle(fontSize: 16, color: Colors.grey),
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
        const Text(
          'Skills by Topic',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
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
              children: const [
                Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'No lesson data yet',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Complete lessons to see your skill progress',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
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
                      topicName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (hasMastery)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('🏆', style: TextStyle(fontSize: 12)),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Mastered',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
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
          Colors.blue,
        ),
        _buildStatChip(
          '${(summary['averageScore'] * 100).toInt()}% avg',
          Icons.score,
          Colors.green,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
        return Colors.green;
      case PerformanceTrend.stable:
        return Colors.blue;
      case PerformanceTrend.declining:
        return Colors.orange;
    }
  }

  /// Performance trends section
  Widget _buildPerformanceTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
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
            style: TextStyle(color: Colors.grey[600]),
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
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...recentFive.map((record) => _buildHistoryItem(record)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(PerformanceRecord record) {
    final topicName = _topicNames[record.topicId] ?? record.topicId;
    final scorePercent = (record.accuracy * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(
                _difficultyService.getDifficultyColor(record.difficulty),
              ).withOpacity(0.2),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Center(
              child: Text(
                record.difficulty.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor(scorePercent).withOpacity(0.2),
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
    if (scorePercent >= 90) return Colors.green;
    if (scorePercent >= 70) return Colors.blue;
    if (scorePercent >= 50) return Colors.orange;
    return Colors.red;
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
        const Text(
          'Manual Difficulty Override',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Override automatic difficulty for specific topics',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        const Text(
          'AI Recommendations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
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
                ? Colors.green.shade50
                : Colors.orange.shade50,
            padding: AppCardPadding.standard,
            child: Row(
                children: [
                  Icon(
                    recommendation.shouldIncrease
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: recommendation.shouldIncrease
                        ? Colors.green
                        : Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
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
              const Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No changes recommended. Keep up the great work!',
                  style: TextStyle(color: Colors.grey[700]),
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
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(
          _getSkillLevelColor(skillLevel),
        ),
      ),
    );
  }

  Color _getSkillLevelColor(double skillLevel) {
    if (skillLevel < 0.3) return Colors.red;
    if (skillLevel < 0.6) return Colors.orange;
    if (skillLevel < 0.8) return Colors.blue;
    return Colors.green;
  }
}
