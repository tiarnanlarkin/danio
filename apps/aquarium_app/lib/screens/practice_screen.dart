import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning.dart';
import '../models/lesson_progress.dart';
import '../providers/lesson_provider.dart';
import '../providers/user_profile_provider.dart';
import '../utils/haptic_feedback.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import 'lesson_screen.dart';

/// Practice screen showing lessons that need review based on spaced repetition
class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  bool _pathsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRequiredPaths();
  }

  /// Ensure all paths containing weak lessons are loaded in the lesson provider.
  Future<void> _loadRequiredPaths() async {
    final weakLessons = ref
        .read(userProfileProvider.notifier)
        .getWeakestLessons();

    final neededPathIds = <String>{};
    for (final progress in weakLessons) {
      for (final meta in LessonProvider.allPathMetadata) {
        if (meta.lessonIds.contains(progress.lessonId)) {
          neededPathIds.add(meta.id);
          break;
        }
      }
    }

    final notifier = ref.read(lessonProvider.notifier);
    await notifier.loadPaths(neededPathIds.toList());
    if (mounted) setState(() => _pathsLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final weakLessons = ref
        .read(userProfileProvider.notifier)
        .getWeakestLessons();

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: weakLessons.isEmpty
          ? _buildEmptyState(context)
          : !_pathsLoaded
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _buildPracticeList(context, ref, weakLessons),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppOverlays.success10,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('🎯', style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 56)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('All caught up!', style: AppTypography.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No lessons need review right now. Your knowledge is fresh!',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Complete more lessons to build your practice queue.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeList(
    BuildContext context,
    WidgetRef ref,
    List<LessonProgress> weakLessons,
  ) {
    // Calculate total items: header + info + spacing + title + spacing + lesson cards
    final totalItems = 5 + weakLessons.length;

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg2),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Header
        if (index == 0) {
          return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.mediumRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: AppSpacing.sm2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Practice Mode',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Review lessons before you forget them',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          );
        }

        // Info card
        if (index == 1) {
          return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppOverlays.info10,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppOverlays.accent20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Lesson strength decays over time: 100% → 70% (1 day) → 40% (7 days) → 0% (30 days). Review before they\'re forgotten!',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          );
        }

        // Spacing
        if (index == 2) {
          return const SizedBox(height: AppSpacing.lg);
        }

        // Section title
        if (index == 3) {
          return Text(
            'Lessons needing review (${weakLessons.length})',
            style: AppTypography.headlineSmall,
          );
        }

        // Spacing
        if (index == 4) {
          return const SizedBox(height: AppSpacing.sm2);
        }

        // Lesson cards
        final lessonIndex = index - 5;
        final progress = weakLessons[lessonIndex];
        final lesson = _findLessonById(progress.lessonId, ref);
        if (lesson == null) return const SizedBox.shrink();

        final path = _findPathForLesson(lesson.id, ref);
        final strength = progress.currentStrength;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildLessonCard(
            context,
            ref,
            lesson,
            path?.title ?? 'Learning Path',
            strength,
            progress,
          ),
        );
      },
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
    String pathTitle,
    double strength,
    LessonProgress progress,
  ) {
    // Determine color based on strength
    Color strengthColor;
    if (strength >= 70) {
      strengthColor = AppColors.success;
    } else if (strength >= 40) {
      strengthColor = AppColors.warning;
    } else {
      strengthColor = AppColors.error;
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LessonScreen(
              lesson: lesson,
              pathTitle: pathTitle,
              isPracticeMode: true,
            ),
          ),
        );
      },
      borderRadius: AppRadius.mediumRadius,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        pathTitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppOverlays.accent20,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.accent),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '+${lesson.xpReward ~/ 2} XP',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm2),

            // Strength indicator
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Strength',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${strength.round()}%',
                            style: AppTypography.labelMedium.copyWith(
                              color: strengthColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs2),
                      ClipRRect(
                        borderRadius: AppRadius.xsRadius,
                        child: LinearProgressIndicator(
                          value: strength / 100,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            strengthColor,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Review stats
            Row(
              children: [
                Icon(Icons.refresh, size: 14, color: AppColors.textHint),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Reviewed ${progress.reviewCount} time${progress.reviewCount == 1 ? '' : 's'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm2),
                Icon(Icons.calendar_today, size: 14, color: AppColors.textHint),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _getTimeSinceReview(progress),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeSinceReview(LessonProgress progress) {
    final referenceDate = progress.lastReviewDate ?? progress.completedDate;
    final daysSince = DateTime.now().difference(referenceDate).inDays;

    if (daysSince == 0) return 'Today';
    if (daysSince == 1) return '1 day ago';
    if (daysSince < 7) return '$daysSince days ago';
    if (daysSince < 30) {
      final weeks = (daysSince / 7).round();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    }
    final months = (daysSince / 30).round();
    return '$months month${months == 1 ? '' : 's'} ago';
  }

  /// Find a lesson by ID from already-loaded paths in the lesson provider.
  /// Practice screen is reached after learn_screen, so paths with weak lessons
  /// should already be loaded.
  Lesson? _findLessonById(String lessonId, WidgetRef ref) {
    return ref.read(lessonProvider).getLesson(lessonId);
  }

  /// Find the path containing a lesson from already-loaded paths.
  LearningPath? _findPathForLesson(String lessonId, WidgetRef ref) {
    final state = ref.read(lessonProvider);
    for (final path in state.loadedPaths.values) {
      if (path.lessons.any((l) => l.id == lessonId)) {
        return path;
      }
    }
    return null;
  }
}
