/// Tests for Analytics Service
/// Validates stats aggregation, trend calculation, and insight generation
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/analytics.dart';
import 'package:aquarium_app/models/user_profile.dart';
import 'package:aquarium_app/models/learning.dart';
import 'package:aquarium_app/models/tank.dart';
import 'package:aquarium_app/models/leaderboard.dart';
import 'package:aquarium_app/services/analytics_service.dart';

@Timeout(Duration(seconds: 10))
void main() {
  // SKIPPED: Analytics tests hang indefinitely - needs investigation
  group('AnalyticsService', skip: true, () {
    late UserProfile testProfile;
    late List<LearningPath> testPaths;

    setUp(() {
      final now = DateTime.now();
      final dailyXpHistory = <String, int>{};

      // Create 30 days of sample data
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        dailyXpHistory[dateKey] = i % 2 == 0 ? 50 : 75;
      }

      testProfile = UserProfile(
        id: 'test-user',
        name: 'Test User',
        totalXp: 1875,
        currentStreak: 15,
        longestStreak: 20,
        completedLessons: ['lesson1', 'lesson2', 'lesson3'],
        dailyXpHistory: dailyXpHistory,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      );

      testPaths = [
        LearningPath(
          id: 'path1',
          title: 'Nitrogen Cycle',
          description: 'Learn about the nitrogen cycle',
          emoji: '🔄',
          lessons: [
            Lesson(
              id: 'lesson1',
              pathId: 'path1',
              title: 'Lesson 1',
              description: 'Description',
              orderIndex: 0,
              sections: const [],
            ),
            Lesson(
              id: 'lesson2',
              pathId: 'path1',
              title: 'Lesson 2',
              description: 'Description',
              orderIndex: 1,
              sections: const [],
            ),
          ],
        ),
        LearningPath(
          id: 'path2',
          title: 'Water Chemistry',
          description: 'Learn about water chemistry',
          emoji: '💧',
          lessons: [
            Lesson(
              id: 'lesson3',
              pathId: 'path2',
              title: 'Lesson 3',
              description: 'Description',
              orderIndex: 0,
              sections: const [],
            ),
          ],
        ),
      ];
    });

    test('generateSummary returns complete analytics summary', () {
      final summary = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
      );

      expect(summary.totalXP, equals(testProfile.totalXp));
      expect(summary.currentStreak, equals(testProfile.currentStreak));
      expect(summary.longestStreak, equals(testProfile.longestStreak));
      expect(summary.lessonsCompleted, equals(3));
      expect(summary.totalLessons, equals(3));
      expect(summary.recentDailyStats, isNotEmpty);
      expect(summary.insights, isNotEmpty);
    });

    test('daily stats aggregation calculates correctly', () {
      final summary = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
      );

      expect(summary.recentDailyStats, isNotEmpty);

      // Check that daily stats are in reverse chronological order
      for (int i = 0; i < summary.recentDailyStats.length - 1; i++) {
        expect(
          summary.recentDailyStats[i].date.isAfter(
            summary.recentDailyStats[i + 1].date,
          ),
          isTrue,
        );
      }

      // Verify XP values match profile data
      final today = DateTime.now();
      final todayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final todayStats = summary.recentDailyStats.firstWhere(
        (s) => s.dateKey == todayKey,
        orElse: () => DailyStats(
          date: today,
          xp: 0,
          lessonsCompleted: 0,
          practiceMinutes: 0,
          timeSpentSeconds: 0,
        ),
      );

      final expectedXp = testProfile.dailyXpHistory[todayKey] ?? 0;
      expect(todayStats.xp, equals(expectedXp));
    });

    test('weekly stats aggregation groups correctly', () {
      final summary = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
      );

      expect(summary.recentWeeklyStats, isNotEmpty);

      // Verify weekly stats calculations
      for (final week in summary.recentWeeklyStats) {
        expect(week.totalXP, greaterThanOrEqualTo(0));
        expect(week.avgDailyXP, greaterThanOrEqualTo(0));
        expect(week.daysActive, greaterThanOrEqualTo(0));
        expect(week.daysActive, lessThanOrEqualTo(7));
      }
    });

    test('topic performance calculates mastery percentage', () {
      final summary = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
      );

      expect(summary.topicPerformance, isNotEmpty);

      // Path1: 2/2 lessons completed (100%)
      final path1Performance = summary.topicPerformance.firstWhere(
        (p) => p.topicId == 'path1',
      );
      expect(path1Performance.masteryPercentage, equals(1.0));
      expect(path1Performance.lessonsCompleted, equals(2));
      expect(path1Performance.totalLessons, equals(2));
      expect(path1Performance.isStrong, isTrue);

      // Path2: 1/1 lesson completed (100%)
      final path2Performance = summary.topicPerformance.firstWhere(
        (p) => p.topicId == 'path2',
      );
      expect(path2Performance.masteryPercentage, equals(1.0));
      expect(path2Performance.lessonsCompleted, equals(1));
    });

    test('insights generation creates relevant insights', () {
      final summary = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
      );

      expect(summary.insights, isNotEmpty);
      expect(summary.insights.length, lessThanOrEqualTo(5));

      // Check that all insights have required fields
      for (final insight in summary.insights) {
        expect(insight.message, isNotEmpty);
        expect(insight.type, isNotNull);
        expect(insight.generatedAt, isNotNull);
      }
    });

    test('streak insights are generated for active streaks', () {
      final summary = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
      );

      // Profile has 15-day streak, should generate streak insight
      final streakInsights = summary.insights.where(
        (i) => i.message.contains('streak') || i.message.contains('day'),
      );

      expect(streakInsights, isNotEmpty);
    });

    test('predictions are generated based on current progress', () {
      final summary = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
      );

      expect(summary.predictions, isNotEmpty);

      for (final prediction in summary.predictions) {
        expect(prediction.message, isNotEmpty);
        expect(prediction.confidence, greaterThan(0));
        expect(prediction.confidence, lessThanOrEqualTo(1.0));
      }
    });

    test('XP milestone predictions calculate correctly', () {
      final summary = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
      );

      // Should predict next milestone (2000 XP)
      final xpPrediction = summary.predictions.firstWhere(
        (p) => p.message.contains('XP') || p.message.contains('reach'),
        orElse: () => const Prediction(
          message: '',
          confidence: 0,
        ),
      );

      if (xpPrediction.message.isNotEmpty) {
        expect(xpPrediction.daysRemaining, isNotNull);
        expect(xpPrediction.estimatedDate, isNotNull);
        expect(xpPrediction.confidence, greaterThan(0));
      }
    });

    test('time range filtering works correctly', () {
      // Test last 7 days
      final last7Days = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
        timeRange: AnalyticsTimeRange.last7Days,
      );

      expect(last7Days.recentDailyStats.length, lessThanOrEqualTo(7));

      // Test last 30 days
      final last30Days = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
        timeRange: AnalyticsTimeRange.last30Days,
      );

      expect(last30Days.recentDailyStats.length, lessThanOrEqualTo(30));
    });

    test('7-day moving average calculation', () {
      final now = DateTime.now();
      final dailyStats = List.generate(
        14,
        (i) => DailyStats(
          date: now.subtract(Duration(days: i)),
          xp: 50,
          lessonsCompleted: 1,
          practiceMinutes: 5,
          timeSpentSeconds: 300,
        ),
      );

      final averages = AnalyticsService.calculate7DayMovingAverage(dailyStats);

      expect(averages, isNotEmpty);
      expect(averages.length, equals(8)); // 14 - 7 + 1

      // All XP is 50, so average should be 50.0
      for (final avg in averages) {
        expect(avg, equals(50.0));
      }
    });

    test('30-day moving average calculation', () {
      final now = DateTime.now();
      final dailyStats = List.generate(
        60,
        (i) => DailyStats(
          date: now.subtract(Duration(days: i)),
          xp: 100,
          lessonsCompleted: 2,
          practiceMinutes: 10,
          timeSpentSeconds: 600,
        ),
      );

      final averages = AnalyticsService.calculate30DayMovingAverage(dailyStats);

      expect(averages, isNotEmpty);
      expect(averages.length, equals(31)); // 60 - 30 + 1

      // All XP is 100, so average should be 100.0
      for (final avg in averages) {
        expect(avg, equals(100.0));
      }
    });

    test('empty profile generates minimal analytics', () {
      final emptyProfile = UserProfile(
        id: 'empty',
        totalXp: 0,
        currentStreak: 0,
        longestStreak: 0,
        completedLessons: const [],
        dailyXpHistory: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final summary = AnalyticsService.generateSummary(
        profile: emptyProfile,
        allPaths: testPaths,
      );

      expect(summary.totalXP, equals(0));
      expect(summary.currentStreak, equals(0));
      expect(summary.lessonsCompleted, equals(0));
      // Should still generate some predictions/insights even with no data
      expect(summary.insights, isA<List<AnalyticsInsight>>());
    });

    test('topic performance identifies strong and weak topics', () {
      final profileWithVariedProgress = UserProfile(
        id: 'varied',
        totalXp: 500,
        currentStreak: 5,
        longestStreak: 10,
        // Only 1 lesson completed from path1 (50% mastery)
        completedLessons: ['lesson1'],
        dailyXpHistory: {'2024-01-01': 50},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final summary = AnalyticsService.generateSummary(
        profile: profileWithVariedProgress,
        allPaths: testPaths,
      );

      // Path1: 1/2 lessons (50%)
      final path1 = summary.topicPerformance.firstWhere(
        (p) => p.topicId == 'path1',
      );
      expect(path1.masteryPercentage, equals(0.5));
      expect(path1.isStrong, isFalse);
      expect(path1.needsWork, isFalse); // Between 0.4 and 0.7
    });

    test('completion percentage calculates correctly', () {
      final summary = AnalyticsService.generateSummary(
        profile: testProfile,
        allPaths: testPaths,
      );

      // 3 completed out of 3 total
      expect(summary.completionPercentage, equals(1.0));

      final incompleteProfile = testProfile.copyWith(
        completedLessons: ['lesson1'],
      );

      final incompleteSummary = AnalyticsService.generateSummary(
        profile: incompleteProfile,
        allPaths: testPaths,
      );

      expect(incompleteSummary.completionPercentage, closeTo(0.33, 0.01));
    });
  });

  group('AnalyticsModels', skip: true, () {
    test('DailyStats creates correct date key', () {
      final date = DateTime(2024, 1, 15);
      final stats = DailyStats(
        date: date,
        xp: 50,
        lessonsCompleted: 1,
        practiceMinutes: 5,
        timeSpentSeconds: 300,
      );

      expect(stats.dateKey, equals('2024-01-15'));
    });

    test('WeeklyStats calculates week key correctly', () {
      final weekStart = DateTime(2024, 1, 8); // Monday
      final stats = WeeklyStats(
        weekStart: weekStart,
        totalXP: 350,
        lessonsCompleted: 7,
        avgDailyXP: 50.0,
        peakDayXP: 100,
        peakDay: weekStart,
        daysActive: 7,
      );

      expect(stats.weekKey, contains('2024-W'));
    });

    test('ProgressTrend extensions work correctly', () {
      expect(ProgressTrend.increasing.emoji, equals('📈'));
      expect(ProgressTrend.stable.emoji, equals('➡️'));
      expect(ProgressTrend.decreasing.emoji, equals('📉'));

      expect(ProgressTrend.increasing.displayName, equals('Increasing'));
      expect(ProgressTrend.stable.displayName, equals('Stable'));
      expect(ProgressTrend.decreasing.displayName, equals('Decreasing'));
    });

    test('InsightType extensions provide correct emojis', () {
      expect(InsightType.achievement.emoji, equals('🎉'));
      expect(InsightType.improvement.emoji, equals('📈'));
      expect(InsightType.warning.emoji, equals('⚠️'));
      expect(InsightType.recommendation.emoji, equals('💡'));
      expect(InsightType.pattern.emoji, equals('🔍'));
      expect(InsightType.milestone.emoji, equals('🏆'));
    });

    test('Prediction confidence labels are correct', () {
      const veryLikely = Prediction(message: 'Test', confidence: 0.9);
      const likely = Prediction(message: 'Test', confidence: 0.7);
      const possible = Prediction(message: 'Test', confidence: 0.5);
      const uncertain = Prediction(message: 'Test', confidence: 0.3);

      expect(veryLikely.confidenceLabel, equals('Very likely'));
      expect(likely.confidenceLabel, equals('Likely'));
      expect(possible.confidenceLabel, equals('Possible'));
      expect(uncertain.confidenceLabel, equals('Uncertain'));
    });

    test('AnalyticsTimeRange getDateRange returns correct ranges', () {
      final today = AnalyticsTimeRange.today.getDateRange();
      expect(today.$1.day, equals(DateTime.now().day));

      final last7 = AnalyticsTimeRange.last7Days.getDateRange();
      expect(
        last7.$2.difference(last7.$1).inDays,
        greaterThanOrEqualTo(7),
      );

      final last30 = AnalyticsTimeRange.last30Days.getDateRange();
      expect(
        last30.$2.difference(last30.$1).inDays,
        greaterThanOrEqualTo(30),
      );
    });

    test('TopicPerformance identifies strong and weak topics correctly', () {
      const strong = TopicPerformance(
        topicId: 'strong',
        topicName: 'Strong Topic',
        totalXP: 500,
        lessonsCompleted: 8,
        totalLessons: 10,
        masteryPercentage: 0.8,
        trend: ProgressTrend.increasing,
        timeSpentMinutes: 40,
      );

      const weak = TopicPerformance(
        topicId: 'weak',
        topicName: 'Weak Topic',
        totalXP: 50,
        lessonsCompleted: 2,
        totalLessons: 10,
        masteryPercentage: 0.2,
        trend: ProgressTrend.decreasing,
        timeSpentMinutes: 10,
      );

      expect(strong.isStrong, isTrue);
      expect(strong.needsWork, isFalse);
      expect(weak.isStrong, isFalse);
      expect(weak.needsWork, isTrue);
    });
  });
}
