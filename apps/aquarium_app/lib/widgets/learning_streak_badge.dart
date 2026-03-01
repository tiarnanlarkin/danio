import 'package:flutter/material.dart';
import '../models/lesson_progress.dart';
import '../theme/app_theme.dart';

/// Displays a learning streak badge showing consecutive days
/// with at least 1 lesson completed. Separate from the general XP streak.
class LearningStreakBadge extends StatelessWidget {
  final Map<String, LessonProgress> lessonProgress;

  const LearningStreakBadge({super.key, required this.lessonProgress});

  /// Calculate consecutive days with at least 1 lesson completed,
  /// ending today or yesterday (to allow for timezone edge cases).
  static int calculateLearningStreak(
      Map<String, LessonProgress> lessonProgress) {
    if (lessonProgress.isEmpty) return 0;

    // Collect all unique dates where lessons were completed or reviewed
    final Set<String> activeDays = {};
    for (final progress in lessonProgress.values) {
      activeDays.add(_dateKey(progress.completedDate));
      if (progress.lastReviewDate != null) {
        activeDays.add(_dateKey(progress.lastReviewDate!));
      }
    }

    if (activeDays.isEmpty) return 0;

    // Check consecutive days ending today or yesterday
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final yesterdayKey =
        _dateKey(today.subtract(const Duration(days: 1)));

    // Must have activity today or yesterday to have an active streak
    if (!activeDays.contains(todayKey) &&
        !activeDays.contains(yesterdayKey)) {
      return 0;
    }

    // Count backwards from the most recent active day
    final startFromToday = activeDays.contains(todayKey);
    var checkDate = startFromToday
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;

    while (activeDays.contains(_dateKey(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final streak = calculateLearningStreak(lessonProgress);
    if (streak < 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppOverlays.primary10,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(
          color: AppOverlays.primary30,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('\u{1F4DA}', style: Theme.of(context).textTheme.bodyLarge!),
          const SizedBox(width: 4),
          Text(
            '$streak-day learning streak!',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
