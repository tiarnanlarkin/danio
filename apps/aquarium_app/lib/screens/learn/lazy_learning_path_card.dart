import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/learning.dart';
import '../../providers/lesson_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/navigation_throttle.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_dialog.dart';
import '../../widgets/core/bubble_loader.dart';
import '../../widgets/danio_snack_bar.dart';
import '../lesson_screen.dart';

/// Path IDs with mostly stub/empty content — gated as "Coming Soon".
const comingSoonPathIds = <String>{};

/// Lazy-loading learning path card.
/// Shows metadata (emoji, title, description, progress) immediately.
/// Loads full LearningPath only when the user expands the card.
class LazyLearningPathCard extends ConsumerStatefulWidget {
  final PathMetadata metadata;
  final int completedLessons;
  final int totalLessons;
  final List<String> userCompletedLessons;

  const LazyLearningPathCard({
    super.key,
    required this.metadata,
    required this.completedLessons,
    required this.totalLessons,
    required this.userCompletedLessons,
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
    final isComingSoon = comingSoonPathIds.contains(meta.id);

    final lessonState = ref.watch(lessonProvider);
    final loadedPath = lessonState.getPath(meta.id);
    final isLoading = lessonState.isPathLoading(meta.id);

    return Opacity(
      opacity: isComingSoon ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
          child: isComingSoon
              ? _buildComingSoonTile(context, meta, isDark)
              : ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
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
                      gradient: isComplete
                          ? LinearGradient(
                              colors: [
                                AppColors.successAlpha20,
                                AppColors.successAlpha10,
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                AppColors.primaryAlpha15,
                                AppColors.primaryAlpha10,
                              ],
                            ),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: isComplete
                            ? AppColors.successAlpha30
                            : AppColors.primaryAlpha15,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        meta.emoji,
                        style: Theme.of(context).textTheme.headlineSmall!,
                      ),
                    ),
                  ),
                  title: Text(
                    meta.title,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
                              height: 8,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.whiteAlpha10
                                    : AppColors.primaryAlpha15,
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
                  children: _buildExpandedContent(loadedPath, isLoading),
                ),
        ),
      ),
    );
  }

  Widget _buildComingSoonTile(
    BuildContext context,
    PathMetadata meta,
    bool isDark,
  ) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryAlpha15, AppColors.primaryAlpha10],
          ),
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(color: AppColors.primaryAlpha15, width: 1),
        ),
        child: Center(
          child: Text(
            meta.emoji,
            style: Theme.of(context).textTheme.headlineSmall!,
          ),
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: DanioColors.amberGold.withValues(alpha: 0.15),
              borderRadius: AppRadius.md2Radius,
              border: Border.all(
                color: DanioColors.amberGold.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'Coming Soon 🚧',
              style: AppTypography.labelSmall.copyWith(
                color: DanioColors.amberGoldText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          meta.description,
          style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        showAppDialog(
          context: context,
          title: '${meta.emoji} Coming Soon!',
          child: Text(
            'The "${meta.title}" path is coming soon — we\'re crafting something great! '
            'Stay tuned 🐟',
            style: AppTypography.bodyLarge,
          ),
          actions: [
            AppButton(
              label: 'Got it!',
              onPressed: () => Navigator.of(context).pop(),
              variant: AppButtonVariant.text,
              isFullWidth: true,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildExpandedContent(LearningPath? path, bool isLoading) {
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

        return ListTile(
          leading: Hero(
            tag: 'lesson-${lesson.id}',
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: 32,
                height: 32,
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
                    'Complete the previous lesson to unlock this one 🔒',
                  );
                },
        );
      }),
    ];
  }
}
