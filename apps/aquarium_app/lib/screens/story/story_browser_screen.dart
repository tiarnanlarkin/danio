import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/stories.dart';
import '../../models/story.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/glass_card.dart';
import 'story_play_screen.dart';

/// Browsable list of all available interactive stories.
/// Accessible from the Learn tab — lets users pick a story to play.
class StoryBrowserScreen extends ConsumerWidget {
  const StoryBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select only the fields used in this screen to avoid spurious rebuilds
    // when unrelated profile fields (XP, gems, streak, etc.) change.
    final profileSlice = ref.watch(
      userProfileProvider.select(
        (s) => s.value == null
            ? null
            : (
                completedStories: s.value!.completedStories,
                currentLevel: s.value!.currentLevel,
              ),
      ),
    );

    final completedStories = profileSlice?.completedStories ?? [];

    final allStories = Stories.allStories;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Interactive Stories'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your adventure',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Learn aquarium keeping through branching stories. Your choices shape the outcome.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stories list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final story = allStories[index];
                  final isCompleted = completedStories.contains(story.id);
                  final isUnlocked = profileSlice != null
                      ? (profileSlice.currentLevel >= story.minLevel &&
                          (story.prerequisites.isEmpty ||
                              story.prerequisites.every(
                                (id) => completedStories.contains(id),
                              )))
                      : story.minLevel == 0 && story.prerequisites.isEmpty;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _StoryCard(
                      story: story,
                      isCompleted: isCompleted,
                      isUnlocked: isUnlocked,
                      onTap: isUnlocked
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      StoryPlayScreen(story: story),
                                ),
                              )
                          : null,
                    ),
                  );
                },
                childCount: allStories.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final bool isCompleted;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _StoryCard({
    required this.story,
    required this.isCompleted,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _difficultyColor(story.difficulty);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Thumbnail emoji
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.15),
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Center(
                    child: Text(
                      story.thumbnailImage ?? '📖',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Title + difficulty
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              story.title,
                              style: AppTypography.titleMedium.copyWith(
                                color: isUnlocked
                                    ? null
                                    : context.textSecondary,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 20,
                            ),
                          if (!isUnlocked)
                            const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.15),
                          borderRadius: AppRadius.xsRadius,
                        ),
                        child: Text(
                          '${story.difficulty.emoji} ${story.difficulty.displayName}',
                          style: AppTypography.labelSmall.copyWith(
                            color: difficultyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              story.description,
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Meta row: time + XP
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 14,
                  color: context.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${story.estimatedMinutes} min',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.star_outline,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  '${story.xpReward} XP',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isUnlocked && story.prerequisites.isNotEmpty) ...[
                  const Spacer(),
                  Text(
                    'Complete prerequisites first',
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(StoryDifficulty difficulty) {
    switch (difficulty) {
      case StoryDifficulty.beginner:
        return AppColors.success;
      case StoryDifficulty.intermediate:
        return AppColors.warning;
      case StoryDifficulty.advanced:
        return AppColors.error;
    }
  }
}
