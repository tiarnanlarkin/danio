/// Tests for Achievement models
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/achievements.dart';

void main() {
  group('AchievementRarity', () {
    test('xpReward returns correct values', () {
      expect(AchievementRarity.bronze.xpReward, 50);
      expect(AchievementRarity.silver.xpReward, 100);
      expect(AchievementRarity.gold.xpReward, 150);
      expect(AchievementRarity.platinum.xpReward, 200);
    });

    test('displayName returns correct values', () {
      expect(AchievementRarity.bronze.displayName, 'Bronze');
      expect(AchievementRarity.silver.displayName, 'Silver');
      expect(AchievementRarity.gold.displayName, 'Gold');
      expect(AchievementRarity.platinum.displayName, 'Platinum');
    });
  });

  group('Achievement', () {
    test('serializes to JSON correctly', () {
      final achievement = const Achievement(
        id: 'test_achievement',
        name: 'Test Achievement',
        description: 'This is a test',
        icon: '🎯',
        rarity: AchievementRarity.gold,
        category: AchievementCategory.learningProgress,
        targetCount: 10,
      );

      final json = achievement.toJson();

      expect(json['id'], 'test_achievement');
      expect(json['name'], 'Test Achievement');
      expect(json['description'], 'This is a test');
      expect(json['icon'], '🎯');
      expect(json['rarity'], 'gold');
      expect(json['category'], 'learningProgress');
      expect(json['targetCount'], 10);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'test_achievement',
        'name': 'Test Achievement',
        'description': 'This is a test',
        'icon': '🎯',
        'rarity': 'gold',
        'category': 'learningProgress',
        'targetCount': 10,
        'isHidden': false,
      };

      final achievement = Achievement.fromJson(json);

      expect(achievement.id, 'test_achievement');
      expect(achievement.name, 'Test Achievement');
      expect(achievement.description, 'This is a test');
      expect(achievement.icon, '🎯');
      expect(achievement.rarity, AchievementRarity.gold);
      expect(achievement.category, AchievementCategory.learningProgress);
      expect(achievement.targetCount, 10);
      expect(achievement.isHidden, false);
    });
  });

  group('AchievementProgress', () {
    test('getProgress returns 0.0 when not started', () {
      const progress = AchievementProgress(
        achievementId: 'test',
        currentCount: 0,
      );

      expect(progress.getProgress(10), 0.0);
    });

    test('getProgress returns correct percentage', () {
      const progress = AchievementProgress(
        achievementId: 'test',
        currentCount: 5,
      );

      expect(progress.getProgress(10), 0.5);
    });

    test('getProgress returns 1.0 when complete', () {
      const progress = AchievementProgress(
        achievementId: 'test',
        currentCount: 10,
      );

      expect(progress.getProgress(10), 1.0);
    });

    test('getProgress clamps above 1.0', () {
      const progress = AchievementProgress(
        achievementId: 'test',
        currentCount: 15,
      );

      expect(progress.getProgress(10), 1.0);
    });

    test('getProgress handles null targetCount for one-time achievements', () {
      const progress = AchievementProgress(
        achievementId: 'test',
        currentCount: 0,
        isUnlocked: false,
      );

      expect(progress.getProgress(null), 0.0);
    });

    test('getProgress returns 1.0 for unlocked one-time achievements', () {
      const progress = AchievementProgress(
        achievementId: 'test',
        currentCount: 0,
        isUnlocked: true,
      );

      expect(progress.getProgress(null), 1.0);
    });

    test('copyWith updates values correctly', () {
      final progress = const AchievementProgress(
        achievementId: 'test',
        currentCount: 5,
      );

      final updated = progress.copyWith(
        currentCount: 10,
        isUnlocked: true,
      );

      expect(updated.currentCount, 10);
      expect(updated.isUnlocked, true);
      expect(updated.achievementId, 'test'); // Unchanged
    });

    test('serializes and deserializes correctly', () {
      final now = DateTime.now();
      final progress = AchievementProgress(
        achievementId: 'test',
        currentCount: 5,
        unlockedAt: now,
        isUnlocked: true,
      );

      final json = progress.toJson();
      final deserialized = AchievementProgress.fromJson(json);

      expect(deserialized.achievementId, progress.achievementId);
      expect(deserialized.currentCount, progress.currentCount);
      expect(deserialized.isUnlocked, progress.isUnlocked);
      expect(
        deserialized.unlockedAt?.toIso8601String(),
        progress.unlockedAt?.toIso8601String(),
      );
    });
  });
}
