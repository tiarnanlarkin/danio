// Tests for UserProfileNotifier (provider-level persistence and state logic).
//
// Covers:
//   - Loading a profile from SharedPreferences
//   - Returning null when no saved profile exists
//   - Handling corrupted JSON gracefully (AsyncError, no crash)
//   - completeLesson and addXp modifying state correctly
//   - createProfile storing initial state
//
// Run: flutter test test/providers/user_profile_notifier_test.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/models/tank.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a minimal valid UserProfile JSON map for seeding SharedPreferences.
Map<String, dynamic> _profileJson({
  String id = 'test-user',
  String experienceLevel = 'beginner',
  String primaryTankType = 'freshwater',
  int totalXp = 150,
  int currentStreak = 3,
  List<String> completedLessons = const ['nc_intro'],
}) {
  final now = DateTime.now().toIso8601String();
  return {
    'id': id,
    'experienceLevel': experienceLevel,
    'primaryTankType': primaryTankType,
    'goals': ['keepFishAlive'],
    'totalXp': totalXp,
    'currentStreak': currentStreak,
    'longestStreak': currentStreak,
    'completedLessons': completedLessons,
    'achievements': <String>[],
    'lessonProgress': <String, dynamic>{},
    'completedStories': <String>[],
    'storyProgress': <String, dynamic>{},
    'hasCompletedPlacementTest': false,
    'hasSkippedPlacementTest': false,
    'dailyXpGoal': 50,
    'dailyXpHistory': <String, int>{},
    'hasStreakFreeze': true,
    'hearts': 5,
    'league': 'bronze',
    'weeklyXP': 0,
    'inventory': <dynamic>[],
    'dailyTipsEnabled': true,
    'streakRemindersEnabled': true,
    'hasSeenTutorial': false,
    'weekendActivityDates': <String>[],
    'fullHeartDates': <String>[],
    'perfectScoreCount': 0,
    'createdAt': now,
    'updatedAt': now,
  };
}

/// Waits for async providers to settle (loading -> data/error).
Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Ensure WidgetsBinding is available (UserProfileNotifier registers a
  // lifecycle observer in its constructor).
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Loading from SharedPreferences ─────────────────────────────────────────

  group('UserProfileNotifier - load from SharedPreferences', () {
    test('loads profile correctly when valid JSON exists in prefs', () async {
      final json = _profileJson(
        totalXp: 250,
        currentStreak: 5,
        completedLessons: ['nc_intro', 'nc_stages'],
      );
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(json),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger the provider and wait for it to load.
      container.read(userProfileProvider);
      await _settle();

      final state = container.read(userProfileProvider);
      expect(state, isA<AsyncData<UserProfile?>>());

      final profile = state.value;
      expect(profile, isNotNull);
      expect(profile!.totalXp, equals(250));
      expect(profile.currentStreak, equals(5));
      expect(profile.completedLessons, containsAll(['nc_intro', 'nc_stages']));
      expect(profile.experienceLevel, equals(ExperienceLevel.beginner));
    });

    test('returns AsyncData(null) when no saved profile exists', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      final state = container.read(userProfileProvider);
      expect(state, isA<AsyncData<UserProfile?>>());
      expect(state.value, isNull);
    });

    test('handles corrupted JSON gracefully (sets AsyncError)', () async {
      SharedPreferences.setMockInitialValues({
        'user_profile': '{not valid json!!!',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      final state = container.read(userProfileProvider);
      expect(state, isA<AsyncError<UserProfile?>>());
    });

    test('handles JSON with sparse fields by using defaults', () async {
      // Supply the list/map fields that fromJson casts (these trigger type
      // errors when null), and omit scalars (which use ?? defaults).
      final sparseJson = {
        'id': 'sparse-user',
        'goals': <String>[],
        'achievements': <String>[],
        'completedLessons': <String>[],
        'lessonProgress': <String, dynamic>{},
        'completedStories': <String>[],
        'storyProgress': <String, dynamic>{},
        'dailyXpHistory': <String, int>{},
        'inventory': <dynamic>[],
        'weekendActivityDates': <String>[],
        'fullHeartDates': <String>[],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(sparseJson),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      final state = container.read(userProfileProvider);
      expect(state, isA<AsyncData<UserProfile?>>());

      final profile = state.value!;
      expect(profile.experienceLevel, equals(ExperienceLevel.beginner));
      expect(profile.totalXp, equals(0));
      expect(profile.hearts, equals(5));
      expect(profile.dailyXpGoal, equals(50));
    });
  });

  // ── Profile creation ───────────────────────────────────────────────────────

  group('UserProfileNotifier - createProfile', () {
    test('creates a profile and sets state to AsyncData', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      // Profile should be null before creation.
      expect(container.read(userProfileProvider).value, isNull);

      await container.read(userProfileProvider.notifier).createProfile(
        experienceLevel: ExperienceLevel.intermediate,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive, UserGoal.learnTheScience],
      );
      await _settle();

      final state = container.read(userProfileProvider);
      expect(state, isA<AsyncData<UserProfile?>>());

      final profile = state.value!;
      expect(profile.experienceLevel, equals(ExperienceLevel.intermediate));
      expect(profile.goals, contains(UserGoal.learnTheScience));
      expect(profile.id, isNotEmpty);
    });
  });

  // ── completeLesson ─────────────────────────────────────────────────────────
  //
  // Note: completeLesson internally triggers SpacedRepetitionProvider which
  // calls NotificationService.initialize() — a platform plugin that is not
  // available in unit tests. We test the double-count guard (which returns
  // early before hitting the plugin code) and rely on the golden_path test
  // for the full integration path.

  group('UserProfileNotifier - completeLesson', () {
    test('does not double-count an already completed lesson', () async {
      final json = _profileJson(
        totalXp: 100,
        completedLessons: ['nc_intro'],
      );
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(json),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      await container
          .read(userProfileProvider.notifier)
          .completeLesson('nc_intro', 20);
      await _settle();

      final profile = container.read(userProfileProvider).value!;
      // XP should stay the same — lesson was already completed.
      expect(profile.totalXp, equals(100));
      // Should still have exactly one occurrence of the lesson.
      expect(
        profile.completedLessons.where((l) => l == 'nc_intro').length,
        equals(1),
      );
    });

    test('no-ops when profile is null', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      // Profile is null — completeLesson should return without error.
      await container
          .read(userProfileProvider.notifier)
          .completeLesson('nc_intro', 20);
      await _settle();

      expect(container.read(userProfileProvider).value, isNull);
    });
  });

  // ── addXp ──────────────────────────────────────────────────────────────────

  group('UserProfileNotifier - addXp', () {
    test('increases totalXp and updates dailyXpHistory', () async {
      final json = _profileJson(totalXp: 50);
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(json),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      await container.read(userProfileProvider.notifier).addXp(30);
      await _settle();

      final profile = container.read(userProfileProvider).value!;
      // totalXp should increase by at least 30 (streak bonuses may add more)
      expect(profile.totalXp, greaterThanOrEqualTo(80));
      // dailyXpHistory should have an entry for today
      expect(profile.dailyXpHistory, isNotEmpty);
    });

    test('ignores zero or negative XP amounts', () async {
      final json = _profileJson(totalXp: 100);
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(json),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      await container.read(userProfileProvider.notifier).addXp(0);
      await _settle();
      await container.read(userProfileProvider.notifier).addXp(-10);
      await _settle();

      final profile = container.read(userProfileProvider).value!;
      expect(profile.totalXp, equals(100));
    });

    test('doubles XP when xpBoostActive is true', () async {
      final json = _profileJson(totalXp: 100);
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(json),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      await container
          .read(userProfileProvider.notifier)
          .addXp(10, xpBoostActive: true);
      await _settle();

      final profile = container.read(userProfileProvider).value!;
      // With boost, 10 XP becomes 20. Plus any streak bonus.
      expect(profile.totalXp, greaterThanOrEqualTo(120));
    });
  });

  // ── updateProfile ──────────────────────────────────────────────────────────

  group('UserProfileNotifier - updateProfile', () {
    test('updates profile fields while preserving others', () async {
      final json = _profileJson(totalXp: 200);
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(json),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(userProfileProvider);
      await _settle();

      await container.read(userProfileProvider.notifier).updateProfile(
        dailyXpGoal: 100,
        hasSeenTutorial: true,
      );
      await _settle();

      final profile = container.read(userProfileProvider).value!;
      expect(profile.dailyXpGoal, equals(100));
      expect(profile.hasSeenTutorial, isTrue);
      // Unchanged field should be preserved.
      expect(profile.totalXp, equals(200));
    });
  });
}
