/// Daily goal tracking for habit formation
/// Tracks progress toward daily XP goals and manages streak logic
library;


import 'package:flutter/foundation.dart';

/// Represents the daily goal progress for a specific date
@immutable
class DailyGoal {
  final DateTime date;
  final int targetXp;
  final int earnedXp;
  final bool isCompleted;
  final bool isToday;

  const DailyGoal({
    required this.date,
    required this.targetXp,
    required this.earnedXp,
    required this.isCompleted,
    required this.isToday,
  });

  /// Progress as a value between 0.0 and 1.0
  double get progress {
    if (targetXp == 0) return 0.0;
    return (earnedXp / targetXp).clamp(0.0, 1.0);
  }

  /// Progress as a percentage (0-100+)
  int get progressPercent {
    if (targetXp == 0) return 0;
    return ((earnedXp / targetXp) * 100).round();
  }

  /// XP remaining to reach goal
  int get remainingXp {
    final remaining = targetXp - earnedXp;
    return remaining > 0 ? remaining : 0;
  }

  /// Bonus XP earned beyond goal
  int get bonusXp {
    final bonus = earnedXp - targetXp;
    return bonus > 0 ? bonus : 0;
  }

  /// Create a daily goal from user profile data
  factory DailyGoal.fromUserProfile({
    required DateTime date,
    required int dailyXpGoal,
    required Map<String, int> dailyXpHistory,
  }) {
    final dateKey = _formatDateKey(date);
    final earnedXp = dailyXpHistory[dateKey] ?? 0;
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    return DailyGoal(
      date: date,
      targetXp: dailyXpGoal,
      earnedXp: earnedXp,
      isCompleted: earnedXp >= dailyXpGoal,
      isToday: isToday,
    );
  }

  /// Create today's daily goal
  static DailyGoal today({
    required int dailyXpGoal,
    required Map<String, int> dailyXpHistory,
  }) {
    return DailyGoal.fromUserProfile(
      date: DateTime.now(),
      dailyXpGoal: dailyXpGoal,
      dailyXpHistory: dailyXpHistory,
    );
  }

  /// Get daily goals for the last N days (for streak calendar)
  static List<DailyGoal> getRecentDays({
    required int days,
    required int dailyXpGoal,
    required Map<String, int> dailyXpHistory,
  }) {
    final now = DateTime.now();
    final goals = <DailyGoal>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      goals.add(DailyGoal.fromUserProfile(
        date: date,
        dailyXpGoal: dailyXpGoal,
        dailyXpHistory: dailyXpHistory,
      ));
    }

    return goals;
  }

  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Streak calculation utilities
class StreakCalculator {
  /// Calculate current streak from daily XP history
  /// Returns the number of consecutive days with activity (meeting daily goal)
  static int calculateCurrentStreak({
    required Map<String, int> dailyXpHistory,
    required int dailyXpGoal,
    required DateTime? lastActivityDate,
  }) {
    if (lastActivityDate == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );

    // Streak is broken if last activity was more than 1 day ago
    final daysSinceActivity = today.difference(lastDate).inDays;
    if (daysSinceActivity > 1) return 0;

    // Count consecutive days backward from last activity date
    int streak = 0;
    DateTime checkDate = lastDate;

    while (true) {
      final dateKey = _formatDateKey(checkDate);
      final xpEarned = dailyXpHistory[dateKey] ?? 0;

      // Day must meet goal to count toward streak
      if (xpEarned >= dailyXpGoal) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }

      // Safety limit to prevent infinite loops
      if (streak > 1000) break;
    }

    return streak;
  }

  /// Check if user should earn a streak milestone achievement
  static List<int> getStreakMilestones(int currentStreak) {
    const milestones = [3, 7, 14, 30, 50, 100, 365];
    return milestones.where((m) => currentStreak >= m).toList();
  }

  /// Calculate intensity level for streak calendar visualization
  /// Returns 0-4 based on how much of the goal was completed
  static int getIntensityLevel({
    required int earnedXp,
    required int dailyXpGoal,
  }) {
    if (earnedXp == 0) return 0;
    if (dailyXpGoal == 0) return 0;

    final progress = earnedXp / dailyXpGoal;
    if (progress < 0.25) return 1; // Some activity
    if (progress < 0.50) return 2; // Halfway
    if (progress < 0.75) return 3; // Most of goal
    return 4; // Goal met or exceeded
  }

  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Helper to format date key for daily XP history
String formatDateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Get today's date key
String getTodayKey() {
  return formatDateKey(DateTime.now());
}
