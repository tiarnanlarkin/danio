import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquarium_app/models/user_profile.dart';
import 'package:aquarium_app/models/tank.dart';
import 'package:aquarium_app/services/hearts_service.dart';
import 'package:aquarium_app/providers/user_profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HeartsService', () {
    late ProviderContainer container;
    late UserProfile testProfile;

    setUp(() async {
      // Initialize SharedPreferences with mock values
      SharedPreferences.setMockInitialValues({});
      
      container = ProviderContainer();
      
      // Create test profile
      final now = DateTime.now();
      testProfile = UserProfile(
        id: 'test-user',
        name: 'Test User',
        hearts: HeartsConfig.maxHearts,
        lastHeartRefill: now,
        createdAt: now,
        updatedAt: now,
      );
      
      // Set the profile in the provider
      await container.read(userProfileProvider.notifier).createProfile(
        name: 'Test User',
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('starts with 5 hearts', () {
      final heartsService = container.read(heartsServiceProvider);
      expect(heartsService.currentHearts, equals(5));
      expect(heartsService.hasHeartsAvailable, isTrue);
    });

    test('loses a heart on wrong answer', () async {
      final heartsService = container.read(heartsServiceProvider);
      final initialHearts = heartsService.currentHearts;
      
      final success = await heartsService.loseHeart();
      
      expect(success, isTrue);
      expect(heartsService.currentHearts, equals(initialHearts - 1));
    });

    test('cannot lose hearts when at 0', () async {
      final heartsService = container.read(heartsServiceProvider);
      
      // Lose all hearts
      for (int i = 0; i < HeartsConfig.maxHearts; i++) {
        await heartsService.loseHeart();
      }
      
      expect(heartsService.currentHearts, equals(0));
      expect(heartsService.hasHeartsAvailable, isFalse);
      
      // Try to lose another heart
      final success = await heartsService.loseHeart();
      expect(success, isFalse);
      expect(heartsService.currentHearts, equals(0));
    });

    test('gains a heart from practice', () async {
      final heartsService = container.read(heartsServiceProvider);
      
      // First lose a heart
      await heartsService.loseHeart();
      final heartsBeforeGain = heartsService.currentHearts;
      
      // Gain it back
      final success = await heartsService.gainHeart();
      
      expect(success, isTrue);
      expect(heartsService.currentHearts, equals(heartsBeforeGain + 1));
    });

    test('cannot gain hearts when at max', () async {
      final heartsService = container.read(heartsServiceProvider);
      
      expect(heartsService.currentHearts, equals(HeartsConfig.maxHearts));
      
      final success = await heartsService.gainHeart();
      
      expect(success, isFalse);
      expect(heartsService.currentHearts, equals(HeartsConfig.maxHearts));
    });

    test('refills to max', () async {
      final heartsService = container.read(heartsServiceProvider);
      
      // Lose some hearts
      await heartsService.loseHeart();
      await heartsService.loseHeart();
      await heartsService.loseHeart();
      
      expect(heartsService.currentHearts, lessThan(HeartsConfig.maxHearts));
      
      // Refill to max
      await heartsService.refillToMax();
      
      expect(heartsService.currentHearts, equals(HeartsConfig.maxHearts));
    });

    test('can start lesson with hearts available', () {
      final heartsService = container.read(heartsServiceProvider);
      expect(heartsService.canStartLesson(isPracticeMode: false), isTrue);
    });

    test('cannot start lesson without hearts (non-practice)', () async {
      final heartsService = container.read(heartsServiceProvider);
      
      // Lose all hearts
      for (int i = 0; i < HeartsConfig.maxHearts; i++) {
        await heartsService.loseHeart();
      }
      
      expect(heartsService.canStartLesson(isPracticeMode: false), isFalse);
    });

    test('can always start practice mode', () async {
      final heartsService = container.read(heartsServiceProvider);
      
      // Lose all hearts
      for (int i = 0; i < HeartsConfig.maxHearts; i++) {
        await heartsService.loseHeart();
      }
      
      expect(heartsService.canStartLesson(isPracticeMode: true), isTrue);
    });

    test('calculates hearts display correctly', () {
      final heartsService = container.read(heartsServiceProvider);
      final display = heartsService.getHeartsDisplay();
      
      expect(display.length, equals(HeartsConfig.maxHearts));
      expect(display.where((filled) => filled).length, equals(5));
    });

    test('formats time remaining correctly', () {
      final heartsService = container.read(heartsServiceProvider);
      
      expect(
        heartsService.formatTimeRemaining(const Duration(hours: 3, minutes: 45)),
        equals('3h 45m'),
      );
      
      expect(
        heartsService.formatTimeRemaining(const Duration(minutes: 30)),
        equals('30m'),
      );
      
      expect(
        heartsService.formatTimeRemaining(const Duration(hours: 1, minutes: 0)),
        equals('1h 0m'),
      );
    });
  });

  group('Auto-refill', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      
      await container.read(userProfileProvider.notifier).createProfile(
        name: 'Test User',
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('calculates auto-refill after 4 hours', () async {
      final heartsService = container.read(heartsServiceProvider);
      final notifier = container.read(userProfileProvider.notifier);
      
      // Lose a heart and set refill time to 4 hours ago
      await heartsService.loseHeart();
      final fourHoursAgo = DateTime.now().subtract(const Duration(hours: 4, minutes: 1));
      await notifier.updateHearts(
        hearts: 4,
        lastHeartRefill: fourHoursAgo,
      );
      
      final profile = container.read(userProfileProvider).value!;
      final heartsToRefill = heartsService.calculateAutoRefill(profile);
      
      expect(heartsToRefill, equals(1));
    });

    test('calculates multiple hearts refill after 8 hours', () async {
      final heartsService = container.read(heartsServiceProvider);
      final notifier = container.read(userProfileProvider.notifier);
      
      // Lose 3 hearts and set refill time to 8 hours ago
      await notifier.updateHearts(hearts: 2, lastHeartRefill: null);
      final eightHoursAgo = DateTime.now().subtract(const Duration(hours: 8, minutes: 1));
      await notifier.updateHearts(
        hearts: 2,
        lastHeartRefill: eightHoursAgo,
      );
      
      final profile = container.read(userProfileProvider).value!;
      final heartsToRefill = heartsService.calculateAutoRefill(profile);
      
      expect(heartsToRefill, equals(2));
    });

    test('does not refill beyond max hearts', () async {
      final heartsService = container.read(heartsServiceProvider);
      final notifier = container.read(userProfileProvider.notifier);
      
      // Lose 2 hearts and set refill time to 20 hours ago (would be 5 hearts)
      await notifier.updateHearts(hearts: 3, lastHeartRefill: null);
      final twentyHoursAgo = DateTime.now().subtract(const Duration(hours: 20));
      await notifier.updateHearts(
        hearts: 3,
        lastHeartRefill: twentyHoursAgo,
      );
      
      final profile = container.read(userProfileProvider).value!;
      final heartsToRefill = heartsService.calculateAutoRefill(profile);
      
      // Should only refill 2 hearts to reach max of 5
      expect(heartsToRefill, equals(2));
    });

    test('does not refill if already at max', () async {
      final heartsService = container.read(heartsServiceProvider);
      final notifier = container.read(userProfileProvider.notifier);
      
      await notifier.updateHearts(
        hearts: HeartsConfig.maxHearts,
        lastHeartRefill: DateTime.now().subtract(const Duration(hours: 10)),
      );
      
      final profile = container.read(userProfileProvider).value!;
      final heartsToRefill = heartsService.calculateAutoRefill(profile);
      
      expect(heartsToRefill, equals(0));
    });

    test('calculates time until next refill correctly', () async {
      final heartsService = container.read(heartsServiceProvider);
      final notifier = container.read(userProfileProvider.notifier);
      
      // Set refill time to 2 hours ago
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      await notifier.updateHearts(
        hearts: 4,
        lastHeartRefill: twoHoursAgo,
      );
      
      final profile = container.read(userProfileProvider).value!;
      final timeUntilRefill = heartsService.getTimeUntilNextRefill(profile);
      
      expect(timeUntilRefill, isNotNull);
      // Should be approximately 2 hours (within a minute of tolerance)
      expect(
        timeUntilRefill!.inMinutes,
        closeTo(120, 1),
      );
    });

    test('returns null time until refill when at max hearts', () async {
      final heartsService = container.read(heartsServiceProvider);
      final profile = container.read(userProfileProvider).value!;
      
      expect(profile.hearts, equals(HeartsConfig.maxHearts));
      
      final timeUntilRefill = heartsService.getTimeUntilNextRefill(profile);
      expect(timeUntilRefill, isNull);
    });

    test('applies auto-refill when checking', () async {
      final heartsService = container.read(heartsServiceProvider);
      final notifier = container.read(userProfileProvider.notifier);
      
      // Set up: 3 hearts, last refill 8 hours ago (should refill 2)
      await notifier.updateHearts(
        hearts: 3,
        lastHeartRefill: DateTime.now().subtract(const Duration(hours: 8, minutes: 1)),
      );
      
      await heartsService.checkAndApplyAutoRefill();
      
      final profile = container.read(userProfileProvider).value!;
      expect(profile.hearts, equals(5)); // 3 + 2 = 5
    });
  });

  group('UserProfile hearts persistence', () {
    test('hearts are saved and loaded correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      
      // Create profile with custom hearts value
      await container.read(userProfileProvider.notifier).createProfile(
        name: 'Test User',
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );
      
      // Update hearts
      await container.read(userProfileProvider.notifier).updateHearts(
        hearts: 3,
        lastHeartRefill: DateTime.now(),
      );
      
      final profile = container.read(userProfileProvider).value!;
      expect(profile.hearts, equals(3));
      expect(profile.lastHeartRefill, isNotNull);
      
      container.dispose();
    });

    test('toJson and fromJson preserve hearts data', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 'test',
        name: 'Test',
        hearts: 3,
        lastHeartRefill: now,
        createdAt: now,
        updatedAt: now,
      );
      
      final json = profile.toJson();
      expect(json['hearts'], equals(3));
      expect(json['lastHeartRefill'], equals(now.toIso8601String()));
      
      final restored = UserProfile.fromJson(json);
      expect(restored.hearts, equals(3));
      expect(
        restored.lastHeartRefill?.toIso8601String(),
        equals(now.toIso8601String()),
      );
    });

    test('defaults to 5 hearts when not specified in JSON', () {
      final now = DateTime.now();
      final json = <String, dynamic>{
        'id': 'test',
        'name': 'Test',
        'experienceLevel': 'beginner',
        'primaryTankType': 'freshwater',
        'goals': <String>['keepFishAlive'],
        'totalXp': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'achievements': <String>[],
        'completedLessons': <String>[],
        'lessonProgress': <String, dynamic>{},
        'hasCompletedPlacementTest': false,
        'dailyXpGoal': 50,
        'dailyXpHistory': <String, int>{},
        'hasStreakFreeze': true,
        'dailyTipsEnabled': true,
        'streakRemindersEnabled': true,
        'morningReminderTime': '09:00',
        'eveningReminderTime': '19:00',
        'nightReminderTime': '23:00',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      
      final profile = UserProfile.fromJson(json);
      expect(profile.hearts, equals(5));
    });
  });
}
