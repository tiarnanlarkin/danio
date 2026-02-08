/// Tests for Achievement Service

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/achievements.dart';
import 'package:aquarium_app/models/user_profile.dart';
import 'package:aquarium_app/models/tank.dart';
import 'package:aquarium_app/models/leaderboard.dart';
import 'package:aquarium_app/services/achievement_service.dart';
import 'package:aquarium_app/data/achievements.dart';

void main() {
  late UserProfile testProfile;

  setUp(() {
    testProfile = UserProfile(
      id: 'test_user',
      totalXp: 0,
      currentStreak: 0,
      longestStreak: 0,
      achievements: [],
      completedLessons: [],
      lessonProgress: {},
      primaryTankType: TankType.freshwater,
      goals: [UserGoal.keepFishAlive],
      league: League.bronze,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  group('AchievementService - Lesson Achievements', () {
    test('unlocks first lesson achievement', () {
      final stats = const AchievementStats(
        lessonsCompleted: 1,
        totalXp: 50,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final firstLessonResult = results.firstWhere(
        (r) => r.achievement.id == 'first_lesson',
        orElse: () => throw Exception('First lesson achievement not found'),
      );

      expect(firstLessonResult.wasJustUnlocked, true);
      expect(firstLessonResult.xpAwarded, 50); // Bronze rarity
    });

    test('tracks progress toward 10 lessons', () {
      final stats = const AchievementStats(
        lessonsCompleted: 5,
        totalXp: 250,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final lessons10Result = results.firstWhere(
        (r) => r.achievement.id == 'lessons_10',
        orElse: () => throw Exception('Lessons 10 achievement not found'),
      );

      expect(lessons10Result.progress.currentCount, 5);
      expect(lessons10Result.progress.getProgress(10), 0.5);
      expect(lessons10Result.wasJustUnlocked, false);
    });

    test('unlocks 10 lessons achievement', () {
      final stats = const AchievementStats(
        lessonsCompleted: 10,
        totalXp: 500,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final lessons10Result = results.firstWhere(
        (r) => r.achievement.id == 'lessons_10',
        orElse: () => throw Exception('Lessons 10 achievement not found'),
      );

      expect(lessons10Result.wasJustUnlocked, true);
      expect(lessons10Result.progress.isUnlocked, true);
    });
  });

  group('AchievementService - Streak Achievements', () {
    test('unlocks 3-day streak', () {
      final stats = const AchievementStats(
        currentStreak: 3,
        totalXp: 150,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final streak3Result = results.firstWhere(
        (r) => r.achievement.id == 'streak_3',
        orElse: () => throw Exception('Streak 3 achievement not found'),
      );

      expect(streak3Result.wasJustUnlocked, true);
    });

    test('unlocks multiple streak achievements at once', () {
      final stats = const AchievementStats(
        currentStreak: 7,
        totalXp: 350,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      // Should unlock both 3-day and 7-day streaks
      final streak3 = results.where((r) => r.achievement.id == 'streak_3');
      final streak7 = results.where((r) => r.achievement.id == 'streak_7');

      expect(streak3.length, 1);
      expect(streak7.length, 1);
      expect(streak3.first.wasJustUnlocked, true);
      expect(streak7.first.wasJustUnlocked, true);
    });
  });

  group('AchievementService - XP Milestones', () {
    test('unlocks 100 XP achievement', () {
      final stats = const AchievementStats(
        totalXp: 100,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final xp100Result = results.firstWhere(
        (r) => r.achievement.id == 'xp_100',
        orElse: () => throw Exception('XP 100 achievement not found'),
      );

      expect(xp100Result.wasJustUnlocked, true);
    });

    test('unlocks multiple XP milestones at once', () {
      final stats = const AchievementStats(
        totalXp: 1000,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      // Should unlock 100, 500, and 1000
      final xpAchievements = results.where((r) => 
        r.achievement.id == 'xp_100' ||
        r.achievement.id == 'xp_500' ||
        r.achievement.id == 'xp_1000'
      );

      expect(xpAchievements.length, 3);
      expect(xpAchievements.every((r) => r.wasJustUnlocked), true);
    });
  });

  group('AchievementService - Special Achievements', () {
    test('unlocks early bird achievement', () {
      final earlyMorning = DateTime(2024, 1, 1, 7, 30);
      
      final stats = AchievementStats(
        lastLessonCompletedAt: earlyMorning,
        totalXp: 50,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final earlyBirdResult = results.firstWhere(
        (r) => r.achievement.id == 'early_bird',
        orElse: () => throw Exception('Early bird achievement not found'),
      );

      expect(earlyBirdResult.wasJustUnlocked, true);
    });

    test('does not unlock early bird after 8am', () {
      final morning = DateTime(2024, 1, 1, 9, 0);
      
      final stats = AchievementStats(
        lastLessonCompletedAt: morning,
        totalXp: 50,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final earlyBirdResults = results.where((r) => r.achievement.id == 'early_bird');
      expect(earlyBirdResults.isEmpty, true);
    });

    test('unlocks night owl achievement', () {
      final lateNight = DateTime(2024, 1, 1, 23, 0);
      
      final stats = AchievementStats(
        lastLessonCompletedAt: lateNight,
        totalXp: 50,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final nightOwlResult = results.firstWhere(
        (r) => r.achievement.id == 'night_owl',
        orElse: () => throw Exception('Night owl achievement not found'),
      );

      expect(nightOwlResult.wasJustUnlocked, true);
    });

    test('unlocks speed demon achievement', () {
      final stats = const AchievementStats(
        lastLessonDuration: 100, // 100 seconds = 1:40
        totalXp: 50,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final speedDemonResult = results.firstWhere(
        (r) => r.achievement.id == 'speed_demon',
        orElse: () => throw Exception('Speed demon achievement not found'),
      );

      expect(speedDemonResult.wasJustUnlocked, true);
    });

    test('does not unlock speed demon if too slow', () {
      final stats = const AchievementStats(
        lastLessonDuration: 180, // 3 minutes
        totalXp: 50,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final speedDemonResults = results.where((r) => r.achievement.id == 'speed_demon');
      expect(speedDemonResults.isEmpty, true);
    });

    test('unlocks marathon learner achievement', () {
      final stats = const AchievementStats(
        todayLessonsCompleted: 5,
        totalXp: 250,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final marathonResult = results.firstWhere(
        (r) => r.achievement.id == 'marathon_learner',
        orElse: () => throw Exception('Marathon learner achievement not found'),
      );

      expect(marathonResult.wasJustUnlocked, true);
    });

    test('tracks perfectionist progress', () {
      final stats = const AchievementStats(
        perfectScores: 5,
        totalXp: 250,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final perfectionistResult = results.firstWhere(
        (r) => r.achievement.id == 'perfectionist',
        orElse: () => throw Exception('Perfectionist achievement not found'),
      );

      expect(perfectionistResult.progress.currentCount, 5);
      expect(perfectionistResult.progress.getProgress(10), 0.5);
      expect(perfectionistResult.wasJustUnlocked, false);
    });
  });

  group('AchievementService - Engagement Achievements', () {
    test('unlocks daily tips achievement', () {
      final stats = const AchievementStats(
        dailyTipsRead: 10,
        totalXp: 0,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final dailyTipsResult = results.firstWhere(
        (r) => r.achievement.id == 'daily_tips_10',
        orElse: () => throw Exception('Daily tips 10 achievement not found'),
      );

      expect(dailyTipsResult.wasJustUnlocked, true);
    });

    test('unlocks practice achievement', () {
      final stats = const AchievementStats(
        practiceSessions: 10,
        totalXp: 0,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final practiceResult = results.firstWhere(
        (r) => r.achievement.id == 'practice_10',
        orElse: () => throw Exception('Practice 10 achievement not found'),
      );

      expect(practiceResult.wasJustUnlocked, true);
    });
  });

  group('AchievementService - Edge Cases', () {
    test('does not re-unlock already unlocked achievement', () {
      final existingProgress = {
        'first_lesson': const AchievementProgress(
          achievementId: 'first_lesson',
          currentCount: 1,
          isUnlocked: true,
          unlockedAt: null,
        ),
      };

      final stats = const AchievementStats(
        lessonsCompleted: 5,
        totalXp: 250,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: existingProgress,
      );

      // First lesson should not appear in results since it's already unlocked
      final firstLessonResults = results.where((r) => r.achievement.id == 'first_lesson');
      expect(firstLessonResults.isEmpty, true);
    });

    test('calculates completion percentage correctly', () {
      final unlockedIds = ['first_lesson', 'streak_3', 'xp_100'];
      
      final percentage = AchievementService.getCompletionPercentage(unlockedIds);
      
      final expected = unlockedIds.length / AchievementDefinitions.all.length;
      expect(percentage, expected);
    });

    test('getNextAchievements returns closest to completion', () {
      final progressMap = {
        'lessons_10': const AchievementProgress(
          achievementId: 'lessons_10',
          currentCount: 9,
        ),
        'lessons_50': const AchievementProgress(
          achievementId: 'lessons_50',
          currentCount: 10,
        ),
        'xp_100': const AchievementProgress(
          achievementId: 'xp_100',
          currentCount: 50,
        ),
      };

      final next = AchievementService.getNextAchievements(
        progressMap: progressMap,
        limit: 2,
      );

      expect(next.length, 2);
      expect(next[0].id, 'lessons_10'); // 90% complete
      expect(next[1].id, 'xp_100'); // 50% complete
    });
  });
}
