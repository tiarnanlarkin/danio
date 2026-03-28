import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spaced_repetition.dart';
import '../providers/spaced_repetition_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/hearts_widgets.dart';
import '../widgets/first_visit_tooltip.dart';
import 'spaced_repetition_practice_screen.dart';
import 'tab_navigator.dart';
import '../utils/navigation_throttle.dart';

/// Practice Hub - Central location for all quiz and practice activities
/// This is Tab 1 in the new navigation structure
class PracticeHubScreen extends ConsumerStatefulWidget {
  const PracticeHubScreen({super.key});

  @override
  ConsumerState<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends ConsumerState<PracticeHubScreen> {
  bool _showTooltip = true;

  @override
  void initState() {
    super.initState();
    _checkTooltip();
  }

  Future<void> _checkTooltip() async {
    final seen = await hasSeenTooltip('tooltip_seen_practice', ref);
    if (mounted) setState(() => _showTooltip = !seen);
  }

  @override
  Widget build(BuildContext context) {
    final srState = ref.watch(spacedRepetitionProvider);
    final profile = ref.watch(userProfileProvider.select((p) => p.value?.currentStreak));
    final dueCards = srState.stats.dueCards;
    final totalCards = srState.stats.totalCards;

    final body = Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Practice'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: Center(child: HeartIndicator(compact: true)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _getPracticeHubItemCount(dueCards, totalCards),
        itemBuilder: (context, index) => _buildPracticeHubItem(
          context,
          ref,
          index,
          dueCards,
          totalCards,
          srState,
          profile,
        ),
      ),
    );

    if (_showTooltip) {
      return Stack(
        children: [
          body,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: FirstVisitTooltip(
                prefsKey: 'tooltip_seen_practice',
                emoji: '🧪',
                message: 'Practice Hub — test your knowledge and review lessons here!',
                onDismissed: () => setState(() => _showTooltip = false),
              ),
            ),
          ),
        ],
      );
    }

    return body;
  }

  int _getPracticeHubItemCount(int dueCards, int totalCards) {
    // Hero (1) + spacer + stats row + spacer +
    // section header (Practice Modes) + spacer + SR card + spacer +
    // section header (Mastery Breakdown) + spacer + mastery widget + spacer +
    // section header (Your Progress) + spacer +
    // streak + spacer + mastered + spacer + accuracy = 19 items
    return 19;
  }

  Widget _buildPracticeHubItem(
    BuildContext context,
    WidgetRef ref,
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
            color: AppColors.error,
            onTap: () {
              NavigationThrottle.push(
                context,
                const SpacedRepetitionPracticeScreen(),
              );
            },
          );
        } else if (dueCards == 0 && totalCards > 0) {
          // Has cards but none are due — genuinely all caught up
          return _buildHeroCard(
            context,
            title: 'All Caught Up! 🎉',
            subtitle: 'No cards to review right now. Keep learning to unlock more!',
            icon: Icons.check_circle,
            color: AppColors.success,
            actionLabel: 'Try a new lesson',
            onTap: () {
              ref.read(currentTabProvider.notifier).state = 0;
            },
          );
        } else {
          // No cards at all — user hasn't started yet
          return _buildHeroCard(
            context,
            title: '🎴 No practice cards yet',
            subtitle: 'Complete lessons to unlock flashcards for review',
            icon: Icons.auto_stories,
            color: AppColors.primary,
            actionLabel: 'Start Learning →',
            onTap: () {
              ref.read(currentTabProvider.notifier).state = 0;
            },
          );
        }
      case 1:
        return const SizedBox(height: AppSpacing.lg);
      case 2: // Practice Stats — BUG-05: gray for zero values, semantic color only when >0
        return _buildStatsRow(
          context,
          stats: [
            _StatItem(
              label: 'Due Today',
              value: '$dueCards',
              color: dueCards > 0 ? AppColors.error : context.textSecondary,
            ),
            _StatItem(
              label: 'Mastered',
              value: '${srState.stats.masteredCards}',
              color: srState.stats.masteredCards > 0
                  ? AppColors.success
                  : context.textSecondary,
            ),
            _StatItem(
              label: 'Total Cards',
              value: '${srState.stats.totalCards}',
              color: context.textSecondary,
            ),
          ],
        );
      case 3:
        return const SizedBox(height: AppSpacing.lg);
      case 4: // Section: Practice Modes
        return Text('Practice Modes', style: AppTypography.headlineSmall);
      case 5:
        return const SizedBox(height: AppSpacing.sm2);
      case 6: // Spaced Repetition card — PRIMARY practice mode
        return _buildPracticeCard(
          context,
          title: 'Spaced Repetition',
          subtitle: 'Review cards based on memory strength — the most effective way to learn',
          icon: Icons.psychology,
          iconColor: AppColors.primary,
          onTap: () {
            NavigationThrottle.push(
              context,
              const SpacedRepetitionPracticeScreen(),
            );
          },
        );
      case 7:
        return const SizedBox(height: AppSpacing.lg);
      case 8: // Section: Mastery Breakdown
        return Text('Mastery Breakdown', style: AppTypography.headlineSmall);
      case 9:
        return const SizedBox(height: AppSpacing.sm2);
      case 10: // Mastery level breakdown
        return _buildMasteryBreakdown(context, srState);
      case 11:
        return const SizedBox(height: AppSpacing.lg);
      case 12: // Section: Your Progress
        return Text('Your Progress', style: AppTypography.headlineSmall);
      case 13:
        return const SizedBox(height: AppSpacing.sm2);
      case 14: // Study Streak card — BUG-06: neutral look when streak=0
        {
          final streak = profile ?? 0;
          return _buildProgressCard(
            context,
            title: 'Study Streak',
            value: streak > 0
                ? '${streak == 1 ? '1 day' : '$streak days'} 🔥'
                : '0 days',
            icon: streak > 0
                ? Icons.local_fire_department
                : Icons.local_fire_department_outlined,
            color: streak > 0 ? AppColors.warning : context.textSecondary,
          );
        }
      case 15:
        return const SizedBox(height: AppSpacing.sm2);
      case 16: // Cards Mastered card
        return _buildProgressCard(
          context,
          title: 'Cards Mastered',
          value: '${srState.stats.masteredCards}',
          icon: Icons.stars,
          color: AppColors.success,
        );
      case 17:
        return const SizedBox(height: AppSpacing.sm2);
      case 18: // Practice Accuracy — computed from ReviewCard history
        {
          final totalReviews = srState.stats.totalReviews;
          final allCards = srState.cards;
          final totalCorrect = allCards.fold<int>(
            0,
            (sum, card) => sum + card.correctCount,
          );
          if (totalReviews == 0) {
            return _buildProgressCard(
              context,
              title: 'Practice Accuracy',
              value: 'Complete a review session',
              icon: Icons.track_changes,
              color: context.textSecondary,
            );
          }
          final accuracyPct = allCards.isEmpty
              ? 0
              : (totalCorrect /
                    allCards.fold<int>(
                      0,
                      (sum, card) => sum + card.reviewCount,
                    ) *
                    100)
                  .round();
          final accuracyColor = accuracyPct >= 80
              ? AppColors.success
              : accuracyPct >= 60
              ? AppColors.warning
              : AppColors.error;
          return _buildProgressCard(
            context,
            title: 'Practice Accuracy',
            value: '$accuracyPct%',
            icon: Icons.track_changes,
            color: accuracyColor,
          );
        }
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
    String? actionLabel,
    required VoidCallback? onTap,
  }) {
    return Semantics(
      button: onTap != null,
      child: Card(
      elevation: AppElevation.level2,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mediumRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    if (actionLabel != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: color.withAlpha(26),
                          borderRadius: AppRadius.md2Radius,
                        ),
                        child: Text(
                          actionLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null) Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context, {
    required List<_StatItem> stats,
  }) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Text(
                    stat.value,
                    style: AppTypography.headlineMedium.copyWith(
                      color: stat.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    stat.label,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
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
          padding: const EdgeInsets.all(AppSpacing.sm),
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

  Widget _buildMasteryBreakdown(
    BuildContext context,
    SpacedRepetitionState srState,
  ) {
    if (srState.stats.totalCards == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Complete lessons to earn flashcards and track your mastery here.',
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final byMastery = srState.stats.cardsByMastery;
    final levels = [
      MasteryLevel.mastered,
      MasteryLevel.proficient,
      MasteryLevel.familiar,
      MasteryLevel.learning,
      MasteryLevel.new_,
    ];
    final levelColors = {
      MasteryLevel.mastered: AppColors.success,
      MasteryLevel.proficient: AppColors.primary,
      MasteryLevel.familiar: AppColors.warning,
      MasteryLevel.learning: AppColors.secondary,
      MasteryLevel.new_: context.textSecondary,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: levels.map((level) {
            final count = byMastery[level] ?? 0;
            final total = srState.stats.totalCards;
            final fraction = total > 0 ? count / total : 0.0;
            final color = levelColors[level] ?? context.textSecondary;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Text(
                    level.emoji,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 80,
                    child: Text(
                      level.displayName,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadius.xsRadius,
                      child: LinearProgressIndicator(
                        value: fraction,
                        backgroundColor: context.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.end,
                      style: AppTypography.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
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
}

class _StatItem {
  final String label;
  final String value;
  final Color color;

  _StatItem({required this.label, required this.value, required this.color});
}
