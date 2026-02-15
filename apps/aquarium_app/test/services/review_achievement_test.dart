/// Tests for review-related achievement unlocking
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/services/achievement_service.dart';
import 'package:aquarium_app/models/achievements.dart';
import 'package:aquarium_app/models/user_profile.dart';

void main() {
  group('AchievementService - Review Achievements', () {
    late UserProfile testProfile;

    setUp(() {
      testProfile = UserProfile(
        id: 'test-user-123',
        name: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('unlocks first review achievement', () {
      final stats = AchievementStats(
        reviewsCompleted: 1,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final firstReview = results.where((r) => r.achievement.id == 'first_review').toList();
      expect(firstReview.length, 1);
      expect(firstReview.first.wasJustUnlocked, isTrue);
    });

    test('unlocks reviews_10 achievement', () {
      final stats = AchievementStats(
        reviewsCompleted: 10,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final reviews10 = results.where((r) => r.achievement.id == 'reviews_10').toList();
      expect(reviews10.length, 1);
      expect(reviews10.first.wasJustUnlocked, isTrue);
    });

    test('unlocks review streak achievements', () {
      final stats = AchievementStats(
        reviewStreak: 7,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      final streakAchievements = results.where(
        (r) => r.achievement.id == 'review_streak_3' || r.achievement.id == 'review_streak_7'
      ).toList();

      expect(streakAchievements.length, 2);
      expect(streakAchievements.every((a) => a.wasJustUnlocked), isTrue);
    });

    test('unlocks multiple review achievements at once', () {
      final stats = AchievementStats(
        reviewsCompleted: 50,
        reviewStreak: 14,
      );

      final results = AchievementService.checkAchievements(
        userProfile: testProfile,
        stats: stats,
        progressMap: {},
      );

      // Should unlock: first_review, reviews_10, reviews_50
      // And: review_streak_3, review_streak_7, review_streak_14
      final reviewAchievementIds = results
          .where((r) => r.achievement.id.contains('review'))
          .map((r) => r.achievement.id)
          .toSet();

      expect(reviewAchievementIds.contains('first_review'), isTrue);
      expect(reviewAchievementIds.contains('reviews_10'), isTrue);
      expect(reviewAchievementIds.contains('reviews_50'), isTrue);
      expect(reviewAchievementIds.contains('review_streak_3'), isTrue);
      expect(reviewAchievementIds.contains('review_streak_7'), isTrue);
      expect(reviewAchievementIds.contains('review_streak_14'), isTrue);
    });
  });
}
