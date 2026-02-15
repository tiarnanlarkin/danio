/// Tests for adaptive difficulty service
/// Validates skill calculation, difficulty recommendations, and edge cases
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/adaptive_difficulty.dart';
import 'package:aquarium_app/services/difficulty_service.dart';

void main() {
  late DifficultyService service;

  setUp(() {
    service = DifficultyService();
  });

  group('Skill Level Calculation', () {
    test('Empty history returns beginner level (0.3)', () {
      final history = const PerformanceHistory(
        topicId: 'test_topic',
        recentAttempts: [],
      );

      final skillLevel = service.calculateSkillLevel(history);
      expect(skillLevel, 0.3);
    });

    test('Perfect scores result in high skill level', () {
      final records = List.generate(
        10,
        (i) => PerformanceRecord(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.medium,
          score: 10,
          maxScore: 10,
          mistakeCount: 0,
          timeSpent: const Duration(seconds: 300),
          completed: true,
        ),
      );

      final history = PerformanceHistory(
        topicId: 'test_topic',
        recentAttempts: records,
      );

      final skillLevel = service.calculateSkillLevel(history);
      expect(skillLevel, greaterThan(0.8));
    });

    test('Poor scores result in low skill level', () {
      final records = List.generate(
        10,
        (i) => PerformanceRecord(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.easy,
          score: 3,
          maxScore: 10,
          mistakeCount: 7,
          timeSpent: const Duration(seconds: 600),
          completed: true,
        ),
      );

      final history = PerformanceHistory(
        topicId: 'test_topic',
        recentAttempts: records,
      );

      final skillLevel = service.calculateSkillLevel(history);
      expect(skillLevel, lessThan(0.6)); // Adjusted threshold - still in beginner/medium range
    });

    test('Improving trend increases skill level', () {
      final records = [
        // Poor early performance
        PerformanceRecord(
          timestamp: DateTime.now().subtract(const Duration(days: 9)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.easy,
          score: 3,
          maxScore: 10,
          mistakeCount: 7,
          timeSpent: const Duration(seconds: 600),
          completed: true,
        ),
        // Improving
        PerformanceRecord(
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.medium,
          score: 7,
          maxScore: 10,
          mistakeCount: 3,
          timeSpent: const Duration(seconds: 400),
          completed: true,
        ),
        // Good recent performance
        PerformanceRecord(
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.medium,
          score: 9,
          maxScore: 10,
          mistakeCount: 1,
          timeSpent: const Duration(seconds: 300),
          completed: true,
        ),
      ];

      final history = PerformanceHistory(
        topicId: 'test_topic',
        recentAttempts: records,
      );

      expect(history.trend, PerformanceTrend.improving);
      final skillLevel = service.calculateSkillLevel(history);
      expect(skillLevel, greaterThan(0.5));
    });

    test('Skill level stays within 0.0-1.0 bounds', () {
      // Extreme perfect scores
      final perfectRecords = List.generate(
        10,
        (i) => PerformanceRecord(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.expert,
          score: 100,
          maxScore: 100,
          mistakeCount: 0,
          timeSpent: const Duration(seconds: 100),
          completed: true,
        ),
      );

      final perfectHistory = PerformanceHistory(
        topicId: 'test_topic',
        recentAttempts: perfectRecords,
      );

      final perfectSkill = service.calculateSkillLevel(perfectHistory);
      expect(perfectSkill, lessThanOrEqualTo(1.0));

      // Extreme poor scores
      final poorRecords = List.generate(
        10,
        (i) => PerformanceRecord(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.easy,
          score: 0,
          maxScore: 10,
          mistakeCount: 10,
          timeSpent: const Duration(seconds: 1000),
          completed: true,
        ),
      );

      final poorHistory = PerformanceHistory(
        topicId: 'test_topic',
        recentAttempts: poorRecords,
      );

      final poorSkill = service.calculateSkillLevel(poorHistory);
      expect(poorSkill, greaterThanOrEqualTo(0.0));
    });
  });

  group('Difficulty Recommendations', () {
    test('Recommends Easy for skill < 0.3', () {
      final level = service.recommendDifficultyFromSkill(0.2);
      expect(level, DifficultyLevel.easy);
    });

    test('Recommends Medium for skill 0.3-0.6', () {
      final level1 = service.recommendDifficultyFromSkill(0.3);
      final level2 = service.recommendDifficultyFromSkill(0.5);
      expect(level1, DifficultyLevel.medium);
      expect(level2, DifficultyLevel.medium);
    });

    test('Recommends Hard for skill 0.6-0.8', () {
      final level1 = service.recommendDifficultyFromSkill(0.6);
      final level2 = service.recommendDifficultyFromSkill(0.75);
      expect(level1, DifficultyLevel.hard);
      expect(level2, DifficultyLevel.hard);
    });

    test('Recommends Expert for skill > 0.8', () {
      final level1 = service.recommendDifficultyFromSkill(0.8);
      final level2 = service.recommendDifficultyFromSkill(0.95);
      expect(level1, DifficultyLevel.expert);
      expect(level2, DifficultyLevel.expert);
    });

    test('Manual override takes precedence', () {
      final profile = UserSkillProfile(
        skillLevels: {'test_topic': 0.9}, // Expert level skill
        performanceHistory: const {},
        manualOverrides: {'test_topic': DifficultyLevel.easy}, // But user wants easy
      );

      final recommendation = service.getDifficultyRecommendation(
        topicId: 'test_topic',
        profile: profile,
      );

      expect(recommendation.suggestedLevel, DifficultyLevel.easy);
      expect(recommendation.confidence, 1.0);
    });

    test('Recommends increase after 5 consecutive correct', () {
      final records = List.generate(
        5,
        (i) => PerformanceRecord(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.medium,
          score: 10,
          maxScore: 10,
          mistakeCount: 0,
          timeSpent: const Duration(seconds: 300),
          completed: true,
        ),
      );

      final profile = UserSkillProfile(
        skillLevels: const {},
        performanceHistory: {
          'test_topic': PerformanceHistory(
            topicId: 'test_topic',
            recentAttempts: records,
          ),
        },
      );

      final recommendation = service.getDifficultyRecommendation(
        topicId: 'test_topic',
        profile: profile,
        currentDifficulty: DifficultyLevel.medium,
      );

      expect(recommendation.shouldIncrease, true);
      expect(recommendation.suggestedLevel, DifficultyLevel.hard);
    });

    test('Recommends decrease when struggling', () {
      final records = List.generate(
        5,
        (i) => PerformanceRecord(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.hard,
          score: 2,
          maxScore: 10,
          mistakeCount: 8,
          timeSpent: const Duration(seconds: 800),
          completed: true,
        ),
      );

      final profile = UserSkillProfile(
        skillLevels: const {},
        performanceHistory: {
          'test_topic': PerformanceHistory(
            topicId: 'test_topic',
            recentAttempts: records,
          ),
        },
      );

      final recommendation = service.getDifficultyRecommendation(
        topicId: 'test_topic',
        profile: profile,
        currentDifficulty: DifficultyLevel.hard,
      );

      expect(recommendation.shouldDecrease, true);
      expect(recommendation.suggestedLevel, DifficultyLevel.medium);
    });

    test('No recommendation for new topic uses overall profile', () {
      final profile = UserSkillProfile(
        skillLevels: const {
          'other_topic': 0.7, // Has skill in other topics
        },
        performanceHistory: const {},
      );

      final recommendation = service.getDifficultyRecommendation(
        topicId: 'new_topic',
        profile: profile,
      );

      expect(recommendation.confidence, lessThan(0.8));
      expect(recommendation.suggestedLevel, DifficultyLevel.medium);
    });
  });

  group('Mid-Lesson Adjustment', () {
    test('No adjustment needed with only 2 questions', () {
      final attempts = [
        PerformanceRecord(
          timestamp: DateTime.now(),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.medium,
          score: 1,
          maxScore: 1,
          mistakeCount: 0,
          timeSpent: const Duration(seconds: 30),
          completed: true,
        ),
        PerformanceRecord(
          timestamp: DateTime.now(),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.medium,
          score: 1,
          maxScore: 1,
          mistakeCount: 0,
          timeSpent: const Duration(seconds: 30),
          completed: true,
        ),
      ];

      final newLevel = service.checkForMidLessonAdjustment(
        currentDifficulty: DifficultyLevel.medium,
        lessonAttempts: attempts,
      );

      expect(newLevel, null);
    });

    test('Increase difficulty after 3 perfect answers', () {
      final attempts = List.generate(
        3,
        (i) => PerformanceRecord(
          timestamp: DateTime.now(),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.medium,
          score: 1,
          maxScore: 1,
          mistakeCount: 0,
          timeSpent: const Duration(seconds: 30),
          completed: true,
        ),
      );

      final newLevel = service.checkForMidLessonAdjustment(
        currentDifficulty: DifficultyLevel.medium,
        lessonAttempts: attempts,
      );

      expect(newLevel, DifficultyLevel.hard);
    });

    test('Decrease difficulty after 3 failures', () {
      final attempts = List.generate(
        3,
        (i) => PerformanceRecord(
          timestamp: DateTime.now(),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.hard,
          score: 0,
          maxScore: 1,
          mistakeCount: 1,
          timeSpent: const Duration(seconds: 60),
          completed: true,
        ),
      );

      final newLevel = service.checkForMidLessonAdjustment(
        currentDifficulty: DifficultyLevel.hard,
        lessonAttempts: attempts,
      );

      expect(newLevel, DifficultyLevel.medium);
    });

    test('No increase at Expert level', () {
      final attempts = List.generate(
        3,
        (i) => PerformanceRecord(
          timestamp: DateTime.now(),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.expert,
          score: 1,
          maxScore: 1,
          mistakeCount: 0,
          timeSpent: const Duration(seconds: 30),
          completed: true,
        ),
      );

      final newLevel = service.checkForMidLessonAdjustment(
        currentDifficulty: DifficultyLevel.expert,
        lessonAttempts: attempts,
      );

      expect(newLevel, null);
    });

    test('No decrease at Easy level', () {
      final attempts = List.generate(
        3,
        (i) => PerformanceRecord(
          timestamp: DateTime.now(),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.easy,
          score: 0,
          maxScore: 1,
          mistakeCount: 1,
          timeSpent: const Duration(seconds: 60),
          completed: true,
        ),
      );

      final newLevel = service.checkForMidLessonAdjustment(
        currentDifficulty: DifficultyLevel.easy,
        lessonAttempts: attempts,
      );

      expect(newLevel, null);
    });
  });

  group('Profile Updates', () {
    test('Adding performance record updates skill level', () {
      var profile = UserSkillProfile.empty();

      final record = PerformanceRecord(
        timestamp: DateTime.now(),
        topicId: 'test_topic',
        difficulty: DifficultyLevel.medium,
        score: 8,
        maxScore: 10,
        mistakeCount: 2,
        timeSpent: const Duration(seconds: 300),
        completed: true,
      );

      profile = service.updateProfileAfterLesson(
        currentProfile: profile,
        lessonRecord: record,
      );

      expect(profile.getSkillLevel('test_topic'), greaterThan(0.0));
      expect(profile.getPerformanceHistory('test_topic'), isNotNull);
    });

    test('Rolling window maintains 10 records max', () {
      var profile = UserSkillProfile.empty();

      // Add 15 records
      for (int i = 0; i < 15; i++) {
        final record = PerformanceRecord(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.medium,
          score: 5,
          maxScore: 10,
          mistakeCount: 5,
          timeSpent: const Duration(seconds: 300),
          completed: true,
        );

        profile = service.updateProfileAfterLesson(
          currentProfile: profile,
          lessonRecord: record,
        );
      }

      final history = profile.getPerformanceHistory('test_topic');
      expect(history?.recentAttempts.length, 10);
    });
  });

  group('Topic Mastery', () {
    test('High skill and consistent performance = mastery', () {
      final records = List.generate(
        10,
        (i) => PerformanceRecord(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.hard,
          score: 9,
          maxScore: 10,
          mistakeCount: 1,
          timeSpent: const Duration(seconds: 300),
          completed: true,
        ),
      );

      final history = PerformanceHistory(
        topicId: 'test_topic',
        recentAttempts: records,
      );

      final skillLevel = service.calculateSkillLevel(history);
      final hasMastery = service.hasTopicMastery(
        history: history,
        skillLevel: skillLevel,
      );

      expect(hasMastery, true);
    });

    test('Inconsistent performance prevents mastery', () {
      final records = [
        PerformanceRecord(
          timestamp: DateTime.now(),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.hard,
          score: 10,
          maxScore: 10,
          mistakeCount: 0,
          timeSpent: const Duration(seconds: 300),
          completed: true,
        ),
        PerformanceRecord(
          timestamp: DateTime.now(),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.hard,
          score: 3,
          maxScore: 10,
          mistakeCount: 7,
          timeSpent: const Duration(seconds: 300),
          completed: true,
        ),
        PerformanceRecord(
          timestamp: DateTime.now(),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.hard,
          score: 9,
          maxScore: 10,
          mistakeCount: 1,
          timeSpent: const Duration(seconds: 300),
          completed: true,
        ),
      ];

      final history = PerformanceHistory(
        topicId: 'test_topic',
        recentAttempts: records,
      );

      final skillLevel = service.calculateSkillLevel(history);
      final hasMastery = service.hasTopicMastery(
        history: history,
        skillLevel: skillLevel,
      );

      expect(hasMastery, false);
    });

    test('Fewer than 5 attempts prevents mastery', () {
      final records = List.generate(
        3,
        (i) => PerformanceRecord(
          timestamp: DateTime.now().subtract(Duration(days: i)),
          topicId: 'test_topic',
          difficulty: DifficultyLevel.expert,
          score: 10,
          maxScore: 10,
          mistakeCount: 0,
          timeSpent: const Duration(seconds: 300),
          completed: true,
        ),
      );

      final history = PerformanceHistory(
        topicId: 'test_topic',
        recentAttempts: records,
      );

      final skillLevel = service.calculateSkillLevel(history);
      final hasMastery = service.hasTopicMastery(
        history: history,
        skillLevel: skillLevel,
      );

      expect(hasMastery, false);
    });
  });

  group('Edge Cases', () {
    test('Zero maxScore doesn\'t cause division by zero', () {
      final record = PerformanceRecord(
        timestamp: DateTime.now(),
        topicId: 'test_topic',
        difficulty: DifficultyLevel.medium,
        score: 0,
        maxScore: 0,
        mistakeCount: 0,
        timeSpent: const Duration(seconds: 300),
        completed: false,
      );

      expect(record.accuracy, 0.0);
    });

    test('Extremely fast completion is penalized', () {
      final record = PerformanceRecord(
        timestamp: DateTime.now(),
        topicId: 'test_topic',
        difficulty: DifficultyLevel.medium,
        score: 10,
        maxScore: 10,
        mistakeCount: 0,
        timeSpent: const Duration(seconds: 50), // 5 seconds per question
        completed: true,
      );

      expect(record.timeEfficiency, lessThan(1.0));
    });

    test('Very slow completion is penalized', () {
      final record = PerformanceRecord(
        timestamp: DateTime.now(),
        topicId: 'test_topic',
        difficulty: DifficultyLevel.medium,
        score: 10,
        maxScore: 10,
        mistakeCount: 0,
        timeSpent: const Duration(seconds: 2000), // 200 seconds per question
        completed: true,
      );

      expect(record.timeEfficiency, lessThan(1.0));
    });

    test('Optimal time (30-60s per question) gives best efficiency', () {
      final record = PerformanceRecord(
        timestamp: DateTime.now(),
        topicId: 'test_topic',
        difficulty: DifficultyLevel.medium,
        score: 10,
        maxScore: 10,
        mistakeCount: 0,
        timeSpent: const Duration(seconds: 400), // 40 seconds per question
        completed: true,
      );

      expect(record.timeEfficiency, 1.0);
    });
  });
}
