import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/learning.dart';
import '../../providers/lesson_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/learning_visuals.dart';
import '../../utils/navigation_throttle.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/bubble_loader.dart';
import '../../widgets/core/pressable_card.dart';
import '../../widgets/danio_snack_bar.dart';
import '../lesson_screen.dart';

/// Lazy-loading learning path card.
/// Shows metadata (title, description, progress) immediately.
/// Loads full LearningPath only when the user expands the card.
class LazyLearningPathCard extends ConsumerStatefulWidget {
  final PathMetadata metadata;
  final int completedLessons;
  final int totalLessons;
  final List<String> userCompletedLessons;

  /// All path metadata — needed to evaluate cross-path prerequisites.
  final List<PathMetadata> allPathMetadata;

  /// When true, renders a first-path badge to nudge new users.
  final bool showStartHereBadge;

  const LazyLearningPathCard({
    super.key,
    required this.metadata,
    required this.completedLessons,
    required this.totalLessons,
    required this.userCompletedLessons,
    this.allPathMetadata = const [],
    this.showStartHereBadge = false,
  });

  @override
  ConsumerState<LazyLearningPathCard> createState() =>
      _LazyLearningPathCardState();
}

class _LazyLearningPathCardState extends ConsumerState<LazyLearningPathCard> {
  @override
  Widget build(BuildContext context) {
    final meta = widget.metadata;
    final progress = widget.totalLessons > 0
        ? widget.completedLessons / widget.totalLessons
        : 0.0;
    final isComplete =
        widget.completedLessons == widget.totalLessons &&
        widget.totalLessons > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visual = LearningVisuals.forPath(meta.id);

    // Cross-path prerequisite locking
    final isPathLocked = !meta.isUnlocked(
      widget.userCompletedLessons,
      widget.allPathMetadata,
    );

    final lessonState = ref.watch(lessonProvider);
    final loadedPath = lessonState.getPath(meta.id);
    final isLoading = lessonState.isPathLoading(meta.id);

    return Opacity(
      opacity: isPathLocked ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: AppRadius.largeRadius,
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.blackAlpha30 : AppColors.blackAlpha05,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (isComplete)
              BoxShadow(
                color: isDark
                    ? AppColors.successAlpha20
                    : AppColors.successAlpha10,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: isPathLocked
              ? _buildPathLockedTile(context, meta)
              : ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.largeRadius,
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: AppRadius.largeRadius,
                  ),
                  onExpansionChanged: (expanded) {
                    if (expanded && loadedPath == null && !isLoading) {
                      ref.read(lessonProvider.notifier).loadPath(meta.id);
                    }
                  },
                  leading: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppColors.successAlpha10
                          : visual.backgroundColor,
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: isComplete
                            ? AppColors.successAlpha30
                            : visual.color.withAlpha(42),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      visual.icon,
                      color: isComplete ? AppColors.success : visual.color,
                      size: AppIconSizes.lg,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          meta.title,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.showStartHereBadge && !isComplete)
                        Container(
                          margin: const EdgeInsets.only(left: AppSpacing.xs),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAlpha15,
                            borderRadius: AppRadius.md2Radius,
                            border: Border.all(color: AppColors.primaryAlpha30),
                          ),
                          child: Text(
                            'Start here',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        meta.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: AppSpacing.sm,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.whiteAlpha10
                                    : AppColors.primaryAlpha20,
                                borderRadius: AppRadius.xsRadius,
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isComplete
                                          ? [
                                              AppColors.success,
                                              AppColors.successAlpha80,
                                            ]
                                          : [
                                              AppColors.primary,
                                              AppColors.secondary,
                                            ],
                                    ),
                                    borderRadius: AppRadius.xsRadius,
                                    boxShadow: progress > 0
                                        ? [
                                            BoxShadow(
                                              color: isComplete
                                                  ? AppColors.successAlpha40
                                                  : AppColors.primaryAlpha40,
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.whiteAlpha10
                                  : context.surfaceVariant,
                              borderRadius: AppRadius.md2Radius,
                            ),
                            child: Text(
                              '${widget.completedLessons}/${widget.totalLessons}',
                              style: AppTypography.labelSmall.copyWith(
                                color: context.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: _buildExpandedContent(
                    context,
                    meta,
                    loadedPath,
                    isLoading,
                    lessonState.pathLoadStates[meta.id] ==
                        LessonLoadState.error,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPathLockedTile(BuildContext context, PathMetadata meta) {
    final prereqNames = meta.prerequisitePathIds
        .map((id) {
          final found = widget.allPathMetadata.firstWhere(
            (m) => m.id == id,
            orElse: () => PathMetadata(
              id: id,
              title: id,
              description: '',
              emoji: '',
              orderIndex: 0,
              lessonIds: const [],
            ),
          );
          return '"${found.title}"';
        })
        .join(', ');

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: AppRadius.mediumRadius,
        ),
        child: const Center(child: Icon(Icons.lock, size: 26)),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              meta.title,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.surfaceVariant,
              borderRadius: AppRadius.md2Radius,
            ),
            child: Text(
              'Locked',
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          'Complete $prereqNames first to unlock this path.',
          style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        DanioSnackBar.warning(
          context,
          'Complete $prereqNames first to unlock ${meta.title}.',
        );
      },
    );
  }

  List<Widget> _buildExpandedContent(
    BuildContext context,
    PathMetadata meta,
    LearningPath? path,
    bool isLoading,
    bool hasError,
  ) {
    if (hasError) {
      return [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: context.textSecondary,
                size: AppIconSizes.xl,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Couldn\'t load this path',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Check your connection and try again.',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Try again',
                leadingIcon: Icons.refresh,
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  ref.read(lessonProvider.notifier).loadPath(meta.id);
                },
              ),
            ],
          ),
        ),
      ];
    }

    if (isLoading || path == null) {
      return [
        const Divider(height: 1),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Center(child: BubbleLoader.small()),
        ),
      ];
    }

    return [
      const Divider(height: 1),
      ...path.lessons.map((lesson) {
        final isCompleted = widget.userCompletedLessons.contains(lesson.id);
        final isUnlocked = lesson.isUnlocked(widget.userCompletedLessons);

        return PressableCard(
          onTap: isUnlocked
              ? () {
                  NavigationThrottle.push(
                    context,
                    LessonScreen(lesson: lesson, pathTitle: path.title),
                  );
                }
              : () {
                  DanioSnackBar.warning(
                    context,
                    'Complete the previous lesson to unlock this one.',
                  );
                },
          child: ListTile(
            leading: Hero(
              tag: 'lesson-${lesson.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: AppSpacing.xl,
                  height: AppSpacing.xl,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppOverlays.success20
                        : isUnlocked
                        ? AppOverlays.primary10
                        : context.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : isUnlocked
                        ? Icons.play_arrow
                        : Icons.lock,
                    size: 18,
                    color: isCompleted
                        ? AppColors.success
                        : isUnlocked
                        ? AppColors.primary
                        : context.textHint,
                  ),
                ),
              ),
            ),
            title: Text(
              lesson.title,
              style: AppTypography.bodyMedium.copyWith(
                color: isUnlocked ? null : context.textHint,
              ),
            ),
            subtitle: Text(
              '${lesson.estimatedMinutes} min • ${lesson.xpReward} XP',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            trailing: isCompleted
                ? Text(
                    '+${lesson.xpReward} XP',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : null,
            enabled: isUnlocked,
            onTap: null, // handled by PressableCard
          ),
        );
      }),
    ];
  }
}
