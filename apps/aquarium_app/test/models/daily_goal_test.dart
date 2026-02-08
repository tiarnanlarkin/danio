/// Unit tests for daily goal and streak calculation logic

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/daily_goal.dart';

void main() {
  group('DailyGoal', () {
    test('calculates progress correctly', () {
      final goal = DailyGoal(
        date: DateTime.now(),
        targetXp: 50,
        earnedXp: 25,
        isCompleted: false,
        isToday: true,
      );

      expect(goal.progress, 0.5);
      expect(goal.progressPercent, 50);
      expect(goal.remainingXp, 25);
      expect(goal.bonusXp, 0);
    });

    test('handles completed goals', () {
      final goal = DailyGoal(
        date: DateTime.now(),
        targetXp: 50,
        earnedXp: 75,
        isCompleted: true,
        isToday: true,
      );

      expect(goal.progress, 1.0);
      expect(goal.progressPercent, 150);
      expect(goal.remainingXp, 0);
      expect(goal.bonusXp, 25);
    });

    test('handles zero target XP', () {
      final goal = DailyGoal(
        date: DateTime.now(),
        targetXp: 0,
        earnedXp: 10,
        isCompleted: false,
        isToday: true,
      );

      expect(goal.progress, 0.0);
      expect(goal.progressPercent, 0);
    });

    test('fromUserProfile creates correct DailyGoal', () {
      final today = DateTime.now();
      final dateKey = formatDateKey(today);
      
      final history = {dateKey: 30};
      final goal = DailyGoal.fromUserProfile(
        date: today,
        dailyXpGoal: 50,
        dailyXpHistory: history,
      );

      expect(goal.targetXp, 50);
      expect(goal.earnedXp, 30);
      expect(goal.isCompleted, false);
      expect(goal.isToday, true);
    });

    test('getRecentDays returns correct number of days', () {
      final history = <String, int>{};
      final goals = DailyGoal.getRecentDays(
        days: 7,
        dailyXpGoal: 50,
        dailyXpHistory: history,
      );

      expect(goals.length, 7);
      expect(goals.last.isToday, true);
    });
  });

  group('StreakCalculator', () {
    test('calculates streak correctly for consecutive days', () {
      final today = DateTime.now();
      final history = <String, int>{};

      // Add 5 consecutive days meeting goal
      for (int i = 0; i < 5; i++) {
        final date = today.subtract(Duration(days: i));
        history[formatDateKey(date)] = 50; // Meets 50 XP goal
      }

      final streak = StreakCalculator.calculateCurrentStreak(
        dailyXpHistory: history,
        dailyXpGoal: 50,
        lastActivityDate: today,
      );

      expect(streak, 5);
    });

    test('streak breaks with missed day', () {
      final today = DateTime.now();
      final history = <String, int>{};

      // Today
      history[formatDateKey(today)] = 50;
      // Yesterday - missed
      // 2 days ago
      history[formatDateKey(today.subtract(const Duration(days: 2)))] = 50;

      final streak = StreakCalculator.calculateCurrentStreak(
        dailyXpHistory: history,
        dailyXpGoal: 50,
        lastActivityDate: today,
      );

      expect(streak, 1); // Only today counts
    });

    test('streak is zero with no recent activity', () {
      final today = DateTime.now();
      final history = <String, int>{};
      
      // Activity 3 days ago (too old)
      history[formatDateKey(today.subtract(const Duration(days: 3)))] = 50;

      final streak = StreakCalculator.calculateCurrentStreak(
        dailyXpHistory: history,
        dailyXpGoal: 50,
        lastActivityDate: today.subtract(const Duration(days: 3)),
      );

      expect(streak, 0);
    });

    test('requires meeting goal for streak', () {
      final today = DateTime.now();
      final history = <String, int>{};

      // Today - didn't meet goal
      history[formatDateKey(today)] = 25; // Only 25 of 50 XP goal
      // Yesterday - met goal
      history[formatDateKey(today.subtract(const Duration(days: 1)))] = 50;

      final streak = StreakCalculator.calculateCurrentStreak(
        dailyXpHistory: history,
        dailyXpGoal: 50,
        lastActivityDate: today,
      );

      expect(streak, 0); // Today doesn't count toward streak
    });

    test('handles null last activity date', () {
      final streak = StreakCalculator.calculateCurrentStreak(
        dailyXpHistory: {},
        dailyXpGoal: 50,
        lastActivityDate: null,
      );

      expect(streak, 0);
    });

    test('getIntensityLevel returns correct levels', () {
      expect(StreakCalculator.getIntensityLevel(earnedXp: 0, dailyXpGoal: 50), 0);   // 0% = none
      expect(StreakCalculator.getIntensityLevel(earnedXp: 10, dailyXpGoal: 50), 1);  // 20% = some
      expect(StreakCalculator.getIntensityLevel(earnedXp: 20, dailyXpGoal: 50), 2);  // 40% = halfway
      expect(StreakCalculator.getIntensityLevel(earnedXp: 30, dailyXpGoal: 50), 3);  // 60% = most
      expect(StreakCalculator.getIntensityLevel(earnedXp: 50, dailyXpGoal: 50), 4);  // 100% = complete
      expect(StreakCalculator.getIntensityLevel(earnedXp: 75, dailyXpGoal: 50), 4);  // 150% = still max
    });

    test('getStreakMilestones returns achieved milestones', () {
      expect(StreakCalculator.getStreakMilestones(0), []);
      expect(StreakCalculator.getStreakMilestones(3), [3]);
      expect(StreakCalculator.getStreakMilestones(7), [3, 7]);
      expect(StreakCalculator.getStreakMilestones(30), [3, 7, 14, 30]);
      expect(StreakCalculator.getStreakMilestones(100), [3, 7, 14, 30, 50, 100]);
    });
  });

  group('Date Key Formatting', () {
    test('formatDateKey formats correctly', () {
      final date = DateTime(2024, 1, 5);
      expect(formatDateKey(date), '2024-01-05');
    });

    test('formatDateKey pads single digits', () {
      final date = DateTime(2024, 3, 9);
      expect(formatDateKey(date), '2024-03-09');
    });

    test('getTodayKey returns today', () {
      final today = DateTime.now();
      final expected = formatDateKey(today);
      expect(getTodayKey(), expected);
    });
  });

  group('Edge Cases', () {
    test('handles very long streaks', () {
      final today = DateTime.now();
      final history = <String, int>{};

      // Add 365 consecutive days
      for (int i = 0; i < 365; i++) {
        final date = today.subtract(Duration(days: i));
        history[formatDateKey(date)] = 50;
      }

      final streak = StreakCalculator.calculateCurrentStreak(
        dailyXpHistory: history,
        dailyXpGoal: 50,
        lastActivityDate: today,
      );

      expect(streak, 365);
    });

    test('handles fractional progress correctly', () {
      final goal = DailyGoal(
        date: DateTime.now(),
        targetXp: 50,
        earnedXp: 33,
        isCompleted: false,
        isToday: true,
      );

      expect(goal.progress, closeTo(0.66, 0.01));
      expect(goal.progressPercent, 66);
    });

    test('progress never exceeds 1.0 when clamped', () {
      final goal = DailyGoal(
        date: DateTime.now(),
        targetXp: 50,
        earnedXp: 500,
        isCompleted: true,
        isToday: true,
      );

      expect(goal.progress, 1.0);
    });

    test('handles timezone edge cases', () {
      // Test that dates are normalized to midnight
      final date1 = DateTime(2024, 1, 5, 14, 30); // 2:30 PM
      final date2 = DateTime(2024, 1, 5, 23, 59); // 11:59 PM
      
      expect(formatDateKey(date1), formatDateKey(date2));
    });
  });
}
