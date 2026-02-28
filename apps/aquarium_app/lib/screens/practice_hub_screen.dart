import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/spaced_repetition_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/hearts_widgets.dart';
import 'spaced_repetition_practice_screen.dart';
import 'practice_screen.dart';
import 'achievements_screen.dart';

/// Practice Hub - Central location for all quiz and practice activities
/// This is Tab 1 in the new navigation structure
class PracticeHubScreen extends ConsumerWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final srState = ref.watch(spacedRepetitionProvider);
    final profile = ref.watch(userProfileProvider).value;
    final dueCards = srState.stats.dueCards;
    final totalCards = srState.stats.totalCards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Practice'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Center(child: HeartIndicator(compact: true)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _getPracticeHubItemCount(dueCards, totalCards),
        itemBuilder: (context, index) => _buildPracticeHubItem(
          context,
          index,
          dueCards,
          totalCards,
          srState,
          profile,
        ),
      ),
    );
  }

  int _getPracticeHubItemCount(int dueCards, int totalCards) {
    // Hero card (1) + spacer + stats row + spacer + 
    // section header + spacer + 3 practice cards + 2 spacers +
    // section header + spacer + 3 progress cards + 2 spacers = 19 items
    return 19;
  }

  Widget _buildPracticeHubItem(
    BuildContext context,
    int index,
    int dueCards,
    int totalCards,
    SpacedRepetitionState srState,
    dynamic profile,
  ) {
    switch (index) {
      case 0: // Hero card
        if (dueCards > 0) {
          return _buildHeroCard(
            context,
            title: 'Review Due Cards',
            subtitle: '$dueCards cards waiting for review',
            icon: Icons.replay,
            color: AppColors.warning,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpacedRepetitionPracticeScreen(),
                ),
              );
            },
          );
        } else if (totalCards > 0) {
          return _buildHeroCard(
            context,
            title: 'Continue Learning',
            subtitle: '$totalCards cards to practice',
            icon: Icons.auto_stories,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpacedRepetitionPracticeScreen(),
                ),
              );
            },
          );
        } else {
          return _buildHeroCard(
            context,
            title: 'All Caught Up! 🎉',
            subtitle: 'No cards due right now. Great job!',
            icon: Icons.check_circle,
            color: AppColors.success,
            onTap: null,
          );
        }
      case 1:
        return const SizedBox(height: 24);
      case 2: // Practice Stats
        return _buildStatsRow(
          context,
          stats: [
            _StatItem(
              label: 'Due Today',
              value: '$dueCards',
              color: dueCards == 0 ? AppColors.textSecondary : AppColors.warning,
            ),
            _StatItem(
              label: 'Mastered',
              value: '${srState.stats.masteredCards}',
              color: srState.stats.masteredCards == 0 ? AppColors.textSecondary : AppColors.success,
            ),
            _StatItem(
              label: 'Total Cards',
              value: '${srState.stats.totalCards}',
              color: AppColors.info,
            ),
          ],
        );
      case 3:
        return const SizedBox(height: 24);
      case 4: // Section: Practice Modes
        return Text('Practice Modes', style: AppTypography.headlineSmall);
      case 5:
        return const SizedBox(height: 12);
      case 6: // Spaced Repetition card
        return _buildPracticeCard(
          context,
          title: 'Spaced Repetition',
          subtitle: 'Review cards based on memory strength',
          icon: Icons.psychology,
          iconColor: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SpacedRepetitionPracticeScreen(),
              ),
            );
          },
        );
      case 7:
        return const SizedBox(height: 12);
      case 8: // Quick Practice card
        return _buildPracticeCard(
          context,
          title: 'Quick Practice',
          subtitle: 'Test your knowledge with random questions',
          icon: Icons.flash_on,
          iconColor: AppColors.warning,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PracticeScreen(),
              ),
            );
          },
        );
      case 9:
        return const SizedBox(height: 12);
      case 10: // Achievements card
        return _buildPracticeCard(
          context,
          title: 'Achievements',
          subtitle: 'View your practice milestones and badges',
          icon: Icons.emoji_events,
          iconColor: AppColors.success,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AchievementsScreen(),
              ),
            );
          },
        );
      case 11:
        return const SizedBox(height: 24);
      case 12: // Section: Your Progress
        return Text('Your Progress', style: AppTypography.headlineSmall);
      case 13:
        return const SizedBox(height: 12);
      case 14: // Study Streak card
        return _buildProgressCard(
          context,
          title: 'Study Streak',
          value: '${profile?.currentStreak ?? 0} ${(profile?.currentStreak ?? 0) == 1 ? "day" : "days"}',
          icon: Icons.local_fire_department,
          color: AppColors.warning,
        );
      case 15:
        return const SizedBox(height: 12);
      case 16: // Cards Mastered card
        return _buildProgressCard(
          context,
          title: 'Cards Mastered',
          value: '${srState.stats.masteredCards}',
          icon: Icons.stars,
          color: AppColors.success,
        );
      case 17:
        return const SizedBox(height: 12);
      case 18: // Practice Accuracy card
        return _buildProgressCard(
          context,
          title: 'Practice Accuracy',
          value: '${_calculateAccuracy(srState)}%',
          icon: Icons.track_changes,
          color: AppColors.info,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      elevation: AppElevation.level2,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mediumRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, {required List<_StatItem> stats}) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                children: [
                  Text(
                    stat.value,
                    style: AppTypography.headlineMedium.copyWith(
                      color: stat.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.label,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPracticeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(26),
            borderRadius: AppRadius.smallRadius,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: AppIconSizes.lg),
        title: Text(title),
        trailing: Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  int _calculateAccuracy(SpacedRepetitionState state) {
    final total = state.stats.reviewsToday;
    if (total == 0) return 0;
    // This is a placeholder - actual accuracy calculation would need
    // to track correct/incorrect answers in the state
    return 85; // Placeholder value
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;

  _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });
}
