/// Placement test result screen showing score and recommendations
/// Displays what lessons will be skipped and where to start
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/placement_test.dart';
import '../models/learning.dart';
import '../models/user_profile.dart';
import '../data/lesson_content.dart';
import '../theme/app_theme.dart';

class PlacementResultScreen extends ConsumerWidget {
  final PlacementResult result;

  const PlacementResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allPaths = LessonContent.allPaths;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Overall score card
            _buildOverallScoreCard(theme),

            const SizedBox(height: 24),

            // Per-path recommendations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Learning Path',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on your score, here\'s what we recommend:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recommendations for each path
                  ...allPaths.map((path) {
                    final recommendation = result.recommendations[path.id];
                    if (recommendation == null) return const SizedBox.shrink();
                    return _buildPathRecommendation(theme, path, recommendation);
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // XP earned card
            _buildXpEarnedCard(theme, allPaths),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Start Learning!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      _showDetailedBreakdown(context, theme);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('View Detailed Breakdown'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard(ThemeData theme) {
    final percentage = result.percentageScore.round();
    final level = result.suggestedExperienceLevel;

    String message;
    Color color;
    IconData icon;

    if (percentage >= 80) {
      message = 'Excellent! You\'re clearly experienced!';
      color = Colors.green;
      icon = Icons.emoji_events;
    } else if (percentage >= 60) {
      message = 'Great job! You know your stuff!';
      color = Colors.blue;
      icon = Icons.thumb_up;
    } else if (percentage >= 40) {
      message = 'Good start! You have some knowledge.';
      color = Colors.orange;
      icon = Icons.school;
    } else {
      message = 'No worries! We\'ll teach you everything.';
      color = AppColors.primary;
      icon = Icons.lightbulb;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You scored ${result.correctAnswers}/${result.totalAnswers} ($percentage%)',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Chip(
            label: Text(
              'Recommended Level: ${_getLevelName(level)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: color.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildPathRecommendation(
    ThemeData theme,
    LearningPath path,
    SkipRecommendation recommendation,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  path.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recommendation.score.round()}% correct',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSkipLevelColor(recommendation.skipLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recommendation.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getSkipLevelLabel(recommendation.skipLevel),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getSkipLevelColor(recommendation.skipLevel),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                recommendation.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (recommendation.lessonsToSkip.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Skipping ${recommendation.lessonsToSkip.length} of ${path.lessons.length} lessons',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildXpEarnedCard(ThemeData theme, List<LearningPath> allPaths) {
    final xpEarned = result.calculateSkipXp(allPaths);
    final lessonsSkipped = result.lessonsToSkip.length;

    if (xpEarned == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: AppColors.accent,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+$xpEarned XP Earned!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'For testing out of $lessonsSkipped lessons',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedBreakdown(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detailed Breakdown',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: LessonContent.allPaths.length,
                  itemBuilder: (context, index) {
                    final path = LessonContent.allPaths[index];
                    final score = result.pathScores[path.id] ?? 0.0;
                    final recommendation = result.recommendations[path.id];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Text(path.emoji, style: const TextStyle(fontSize: 32)),
                        title: Text(path.title),
                        subtitle: LinearProgressIndicator(
                          value: score / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                            _getScoreColor(score),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${score.round()}%',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(score),
                              ),
                            ),
                            if (recommendation != null)
                              Text(
                                recommendation.emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLevelName(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'Beginner';
      case ExperienceLevel.intermediate:
        return 'Intermediate';
      case ExperienceLevel.expert:
        return 'Expert';
    }
  }

  String _getSkipLevelLabel(SkipLevel level) {
    switch (level) {
      case SkipLevel.none:
        return 'Start Fresh';
      case SkipLevel.beginner:
        return 'Skip Basics';
      case SkipLevel.advanced:
        return 'Skip Ahead';
      case SkipLevel.complete:
        return 'Complete';
    }
  }

  Color _getSkipLevelColor(SkipLevel level) {
    switch (level) {
      case SkipLevel.none:
        return Colors.blue;
      case SkipLevel.beginner:
        return Colors.green;
      case SkipLevel.advanced:
        return Colors.orange;
      case SkipLevel.complete:
        return Colors.purple;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.grey;
  }
}
