import 'package:flutter/material.dart';

import '../../models/learning.dart';
import '../../theme/app_theme.dart';
import '../../theme/learning_visuals.dart';
import '../../utils/navigation_throttle.dart';
import '../../widgets/core/pressable_card.dart';
import '../../widgets/danio_snack_bar.dart';
import '../lesson_screen.dart';

/// Full-screen view for a learning path.
///
/// Keeps long paths readable without forcing users to work through a cramped
/// inline expansion tile.
class LearningPathDetailScreen extends StatelessWidget {
  final LearningPath path;
  final List<String> completedLessonIds;

  const LearningPathDetailScreen({
    super.key,
    required this.path,
    required this.completedLessonIds,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = path.lessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;
    final progress = path.lessons.isEmpty
        ? 0.0
        : completedCount / path.lessons.length;
    final visual = LearningVisuals.forPath(path.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(path.title),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          _PathOverview(
            path: path,
            visual: visual,
            completedCount: completedCount,
            progress: progress,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Lessons',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final lesson in path.lessons)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _LessonRow(
                lesson: lesson,
                pathTitle: path.title,
                isCompleted: completedLessonIds.contains(lesson.id),
                isUnlocked: lesson.isUnlocked(completedLessonIds),
              ),
            ),
        ],
      ),
    );
  }
}

class _PathOverview extends StatelessWidget {
  final LearningPath path;
  final LearningPathVisual visual;
  final int completedCount;
  final double progress;

  const _PathOverview({
    required this.path,
    required this.visual,
    required this.completedCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: context.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: visual.backgroundColor,
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(color: visual.color.withAlpha(42)),
                ),
                child: Icon(
                  visual.icon,
                  color: visual.color,
                  size: AppIconSizes.lg,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Path overview',
                      style: AppTypography.labelLarge.copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(path.description, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.xsRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: AppSpacing.sm,
              backgroundColor: context.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$completedCount of ${path.lessons.length} lessons complete',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final Lesson lesson;
  final String pathTitle;
  final bool isCompleted;
  final bool isUnlocked;

  const _LessonRow({
    required this.lesson,
    required this.pathTitle,
    required this.isCompleted,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      onTap: isUnlocked
          ? () {
              NavigationThrottle.push(
                context,
                LessonScreen(lesson: lesson, pathTitle: pathTitle),
              );
            }
          : () {
              DanioSnackBar.warning(
                context,
                'Complete the previous lesson to unlock this one.',
              );
            },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
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
        title: Text(
          lesson.title,
          style: AppTypography.bodyMedium.copyWith(
            color: isUnlocked ? null : context.textHint,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${lesson.estimatedMinutes} min | ${lesson.xpReward} XP',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
          ),
        ),
        trailing: isCompleted
            ? const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: AppIconSizes.sm,
              )
            : null,
      ),
    );
  }
}
