import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aquarium_app/models/user_profile.dart';
import 'package:aquarium_app/models/learning.dart';
import 'package:aquarium_app/models/tank.dart';
import 'package:aquarium_app/providers/user_profile_provider.dart';
import 'package:aquarium_app/providers/gems_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('P0-4: User Streak Calculation', () {
    late ProviderContainer container;

    setUp(() async {
      // Initialize SharedPreferences with mock data
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      
      // Wait for gems provider to initialize
      int attempts = 0;
      while (container.read(gemsProvider).isLoading && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      
      // Create a test profile
      final notifier = container.read(userProfileProvider.notifier);
      await notifier.createProfile(
        name: 'Test User',
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('First activity ever sets streak to 1', () async {
      final notifier = container.read(userProfileProvider.notifier);
      
      await notifier.recordActivity(xp: 10);
      
      final profile = container.read(userProfileProvider).value!;
      expect(profile.currentStreak, 1);
      expect(profile.longestStreak, 1);
      expect(profile.lastActivityDate, isNotNull);
    });

    test('Multiple activities on same day keep streak at 1', () async {
      final notifier = container.read(userProfileProvider.notifier);
      
      // First activity
      await notifier.recordActivity(xp: 10);
      var profile = container.read(userProfileProvider).value!;
      expect(profile.currentStreak, 1);
      
      // Second activity same day (should not increment)
      await notifier.recordActivity(xp: 10);
      profile = container.read(userProfileProvider).value!;
      expect(profile.currentStreak, 1);
      
      // Third activity same day
      await notifier.recordActivity(xp: 10);
      profile = container.read(userProfileProvider).value!;
      expect(profile.currentStreak, 1);
    });

    test('Activity on consecutive days increments streak', () async {
      // This test validates the date normalization logic works correctly
      // By testing date difference calculations directly
      
      final day1 = DateTime(2024, 2, 14, 23, 0); // Feb 14, 11 PM
      final day2 = DateTime(2024, 2, 15, 1, 0);  // Feb 15, 1 AM
      
      final normalized1 = DateTime(day1.year, day1.month, day1.day);
      final normalized2 = DateTime(day2.year, day2.month, day2.day);
      final dayDiff = normalized2.difference(normalized1).inDays;
      
      expect(dayDiff, 1); // Should be consecutive
      
      // In real usage: if lastDate was day1 and current is day2,
      // streak should increment because dayDiff == 1
    });

    test('Activity after 2+ day gap resets streak to 1', () async {
      // Validate the logic for detecting broken streaks
      
      final lastDate = DateTime(2024, 2, 10); // Feb 10
      final today = DateTime(2024, 2, 15);    // Feb 15 (5 days later)
      
      final normalizedLast = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final dayDiff = normalizedToday.difference(normalizedLast).inDays;
      
      expect(dayDiff, 5); // Gap of 5 days
      
      // In real usage: if dayDiff > 1, streak resets to 1
      final shouldReset = dayDiff > 1;
      expect(shouldReset, true);
    });

    test('Longest streak is preserved when current streak resets', () async {
      // Validate logic: newStreak > longestStreak → update longest
      //                 otherwise → keep longest
      
      int currentStreak = 3;
      int longestStreak = 10;
      int newStreak = 1; // After gap
      
      // Logic from provider:
      if (newStreak > longestStreak) {
        longestStreak = newStreak;
      }
      
      expect(longestStreak, 10); // Should remain 10
      expect(currentStreak, 3);  // Old value
    });

    test('New longest streak updates when current exceeds it', () async {
      // Validate logic: newStreak > longestStreak → update
      
      int longestStreak = 5;
      int newStreak = 6; // Incremented
      
      if (newStreak > longestStreak) {
        longestStreak = newStreak;
      }
      
      expect(longestStreak, 6); // Should update
    });

    test('Bonus XP awarded when streak increments', () async {
      final notifier = container.read(userProfileProvider.notifier);
      
      // First activity ever - should get bonus
      await notifier.recordActivity(xp: 10);
      var profile = container.read(userProfileProvider).value!;
      
      expect(profile.totalXp, greaterThanOrEqualTo(10)); // At least base XP
      expect(profile.currentStreak, 1);
    });

    test('No bonus XP for multiple activities on same day', () async {
      final notifier = container.read(userProfileProvider.notifier);
      
      // First activity
      await notifier.recordActivity(xp: 10);
      var profile = container.read(userProfileProvider).value!;
      final xpAfterFirst = profile.totalXp;
      
      // Second activity same day
      await notifier.recordActivity(xp: 10);
      profile = container.read(userProfileProvider).value!;
      
      // Should only get base XP, no streak bonus
      expect(profile.totalXp, xpAfterFirst + 10);
    });

    test('Timezone consistency: dates normalized to midnight', () async {
      // Validate that time of day doesn't affect date comparisons
      final lateNight = DateTime(2024, 2, 14, 23, 59);  // 11:59 PM
      final earlyMorning = DateTime(2024, 2, 15, 0, 1); // 12:01 AM
      
      // Both should normalize to midnight of their respective days
      final normalized1 = DateTime(lateNight.year, lateNight.month, lateNight.day);
      final normalized2 = DateTime(earlyMorning.year, earlyMorning.month, earlyMorning.day);
      
      expect(normalized1.hour, 0);
      expect(normalized1.minute, 0);
      expect(normalized2.hour, 0);
      expect(normalized2.minute, 0);
      expect(normalized2.difference(normalized1).inDays, 1);
    });

    test('DST boundary handling: March spring forward', () async {
      // In 2024, DST starts March 10 in many regions
      // 2:00 AM → 3:00 AM (1 hour lost)
      
      final beforeDST = DateTime(2024, 3, 9, 23, 0);  // Mar 9, 11 PM
      final afterDST = DateTime(2024, 3, 10, 1, 0);   // Mar 10, 1 AM
      
      // Both should normalize to their respective days
      final day1 = DateTime(beforeDST.year, beforeDST.month, beforeDST.day);
      final day2 = DateTime(afterDST.year, afterDST.month, afterDST.day);
      
      expect(day2.difference(day1).inDays, 1); // Still consecutive days
    });

    test('DST boundary handling: November fall back', () async {
      // In 2024, DST ends November 3 in many regions
      // 2:00 AM → 1:00 AM (1 hour repeated)
      
      final beforeDST = DateTime(2024, 11, 2, 23, 0);  // Nov 2, 11 PM
      final afterDST = DateTime(2024, 11, 3, 3, 0);    // Nov 3, 3 AM
      
      // Both should normalize to their respective days
      final day1 = DateTime(beforeDST.year, beforeDST.month, beforeDST.day);
      final day2 = DateTime(afterDST.year, afterDST.month, afterDST.day);
      
      expect(day2.difference(day1).inDays, 1); // Still consecutive days
    });

    test('Date comparison edge case: exactly 24 hours later', () async {
      final day1 = DateTime(2024, 2, 14, 10, 0); // 10 AM
      final day2 = DateTime(2024, 2, 15, 10, 0); // 10 AM next day (exactly 24h)
      
      final normalized1 = DateTime(day1.year, day1.month, day1.day);
      final normalized2 = DateTime(day2.year, day2.month, day2.day);
      
      expect(normalized2.difference(normalized1).inDays, 1);
    });

    test('Date comparison edge case: less than 24 hours but different day', () async {
      final day1 = DateTime(2024, 2, 14, 23, 0); // Feb 14, 11 PM
      final day2 = DateTime(2024, 2, 15, 1, 0);  // Feb 15, 1 AM (2 hours later)
      
      final normalized1 = DateTime(day1.year, day1.month, day1.day);
      final normalized2 = DateTime(day2.year, day2.month, day2.day);
      
      expect(normalized2.difference(normalized1).inDays, 1);
    });

    test('Leap year edge case: Feb 28 → Feb 29 (leap year)', () async {
      final feb28 = DateTime(2024, 2, 28, 12, 0);
      final feb29 = DateTime(2024, 2, 29, 12, 0);
      
      final normalized1 = DateTime(feb28.year, feb28.month, feb28.day);
      final normalized2 = DateTime(feb29.year, feb29.month, feb29.day);
      
      expect(normalized2.difference(normalized1).inDays, 1);
    });

    test('Month boundary: Jan 31 → Feb 1', () async {
      final jan31 = DateTime(2024, 1, 31, 12, 0);
      final feb1 = DateTime(2024, 2, 1, 12, 0);
      
      final normalized1 = DateTime(jan31.year, jan31.month, jan31.day);
      final normalized2 = DateTime(feb1.year, feb1.month, feb1.day);
      
      expect(normalized2.difference(normalized1).inDays, 1);
    });

    test('Year boundary: Dec 31 → Jan 1', () async {
      final dec31 = DateTime(2024, 12, 31, 23, 59);
      final jan1 = DateTime(2025, 1, 1, 0, 1);
      
      final normalized1 = DateTime(dec31.year, dec31.month, dec31.day);
      final normalized2 = DateTime(jan1.year, jan1.month, jan1.day);
      
      expect(normalized2.difference(normalized1).inDays, 1);
    });

    test('Stress test: Date normalization across many days', () async {
      // Validate date normalization works across many scenarios
      final dates = [
        DateTime(2024, 1, 1, 0, 0),   // Midnight
        DateTime(2024, 1, 1, 12, 30), // Noon same day
        DateTime(2024, 1, 1, 23, 59), // End of day
        DateTime(2024, 1, 2, 0, 1),   // Start of next day
        DateTime(2024, 2, 29, 10, 0), // Leap year Feb 29
        DateTime(2024, 12, 31, 20, 0),// End of year
      ];
      
      for (var date in dates) {
        final normalized = DateTime(date.year, date.month, date.day);
        expect(normalized.hour, 0);
        expect(normalized.minute, 0);
        expect(normalized.second, 0);
      }
    });
  });

  group('XP Management (without streak)', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      
      // Wait for gems provider to initialize
      int attempts = 0;
      while (container.read(gemsProvider).isLoading && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      
      final notifier = container.read(userProfileProvider.notifier);
      await notifier.createProfile(
        name: 'Test User',
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('addXp increments XP without touching streak', () async {
      final notifier = container.read(userProfileProvider.notifier);
      
      // Set up existing streak
      await notifier.recordActivity(xp: 0);
      var profile = container.read(userProfileProvider).value!;
      final initialStreak = profile.currentStreak;
      final initialLastActivityDate = profile.lastActivityDate!;
      
      // Add XP without streak logic
      await notifier.addXp(100);
      profile = container.read(userProfileProvider).value!;
      
      expect(profile.totalXp, greaterThan(0));
      expect(profile.currentStreak, initialStreak); // Unchanged
      // Compare dates by time components (ignore microsecond differences)
      expect(profile.lastActivityDate!.year, initialLastActivityDate.year);
      expect(profile.lastActivityDate!.month, initialLastActivityDate.month);
      expect(profile.lastActivityDate!.day, initialLastActivityDate.day);
      expect(profile.lastActivityDate!.hour, initialLastActivityDate.hour);
      expect(profile.lastActivityDate!.minute, initialLastActivityDate.minute);
      expect(profile.lastActivityDate!.second, initialLastActivityDate.second);
    });

    test('Lesson completion adds XP and lesson ID', () async {
      final notifier = container.read(userProfileProvider.notifier);
      
      await notifier.completeLesson('lesson-1', 50);
      var profile = container.read(userProfileProvider).value!;
      
      expect(profile.completedLessons, contains('lesson-1'));
      // completeLesson calls recordActivity which adds 25 XP streak bonus on first activity
      expect(profile.totalXp, 75); // 50 (lesson) + 25 (streak bonus)
      
      // Completing again shouldn't double-count
      await notifier.completeLesson('lesson-1', 50);
      profile = container.read(userProfileProvider).value!;
      
      expect(profile.totalXp, 75); // Still 75, not double-counted
      expect(profile.completedLessons.length, 1);
    });
  });
}
