import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/stories.dart';
import '../../models/story.dart';
import '../../navigation/app_routes.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/core/glass_card.dart';
import '../../widgets/danio_snack_bar.dart';

/// Browsable list of all available interactive stories.
/// Accessible from the Learn tab — lets users pick a story to play.
class StoryBrowserScreen extends ConsumerWidget {
  final List<Story>? stories;

  const StoryBrowserScreen({super.key, this.stories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select only the fields used in this screen to avoid spurious rebuilds
    // when unrelated profile fields (XP, gems, streak, etc.) change.
    final profileSlice = ref.watch(
      userProfileProvider.select((s) {
        final profile = s.valueOrNull;
        return (
          hasError: s.hasError,
          hasProfile: profile != null,
          completedStories: profile?.completedStories ?? const <String>[],
          currentLevel: profile?.currentLevel,
        );
      }),
    );

    final completedStories = profileSlice.completedStories;

    final allStories = stories ?? Stories.allStories;

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

          if (profileSlice.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: _ProfileErrorBanner(
                  onRetry: () => ref.invalidate(userProfileProvider),
                ),
              ),
            ),

          if (allStories.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyStoriesState(),
            )
          else
            // Stories list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final story = allStories[index];
                    final isCompleted = completedStories.contains(story.id);
                    final isUnlocked = profileSlice.hasProfile
                        ? (profileSlice.currentLevel! >= story.minLevel &&
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
                            ? () => AppRoutes.toStoryPlay(context, story)
                            : () => _showLockedStoryFeedback(
                                context,
                                story,
                                currentLevel: profileSlice.currentLevel ?? 0,
                                completedStories: completedStories,
                              ),
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

  void _showLockedStoryFeedback(
    BuildContext context,
    Story story, {
    required int currentLevel,
    required List<String> completedStories,
  }) {
    final missingPrerequisites = story.prerequisites
        .where((storyId) => !completedStories.contains(storyId))
        .length;
    final String message;

    if (story.minLevel > currentLevel) {
      message = 'Reach level ${story.minLevel} to unlock ${story.title}.';
    } else if (missingPrerequisites > 0) {
      final prerequisiteLabel = missingPrerequisites == 1
          ? '1 prerequisite story'
          : '$missingPrerequisites prerequisite stories';
      message = 'Complete $prerequisiteLabel to unlock ${story.title}.';
    } else {
      message = 'Keep playing stories to unlock ${story.title}.';
    }

    DanioSnackBar.info(context, message);
  }
}

class _EmptyStoriesState extends StatelessWidget {
  const _EmptyStoriesState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: AppIconSizes.xxl,
            color: context.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No stories available yet',
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Danio could not find any interactive stories. Lessons and practice are still available from the Learn tab.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProfileErrorBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.warningAlpha15,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sync_problem,
              color: AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Couldn\'t load your profile. Stories are still available, but unlock progress may be unavailable.',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
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
                const SizedBox(width: AppSpacing.xs),
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
                const SizedBox(width: AppSpacing.xs),
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
