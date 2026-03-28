// Tests for UserProfile model and UserProfileProvider.
//
// Tests the pure UserProfile model (no I/O required for most tests):
//   - Default profile values
//   - XP gain and level calculations
//   - Level thresholds
//   - Streak tracking logic
//   - Daily XP goal defaults
//
// Run: flutter test test/providers/user_profile_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/models/leaderboard.dart';

/// Build a minimal valid UserProfile for testing.
UserProfile _profile({
  int totalXp = 0,
  int currentStreak = 0,
  int longestStreak = 0,
  DateTime? lastActivityDate,
  int dailyXpGoal = 50,
  int hearts = 5,
  League league = League.bronze,
  int weeklyXP = 0,
  List<String> completedLessons = const [],
}) {
  final now = DateTime.now();
  return UserProfile(
    id: 'test-user',
    experienceLevel: ExperienceLevel.beginner,
    primaryTankType: TankType.freshwater,
    goals: [UserGoal.keepFishAlive],
    totalXp: totalXp,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    lastActivityDate: lastActivityDate,
    dailyXpGoal: dailyXpGoal,
    hearts: hearts,
    league: league,
    weeklyXP: weeklyXP,
    completedLessons: completedLessons,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('UserProfile — default values', () {
    test('default dailyXpGoal is 50', () {
      final profile = _profile();
      expect(profile.dailyXpGoal, equals(50));
    });

    test('default hearts is 5', () {
      final profile = _profile();
      expect(profile.hearts, equals(5));
    });

    test('default league is bronze', () {
      final profile = _profile();
      expect(profile.league, equals(League.bronze));
    });

    test('default weeklyXP is 0', () {
      final profile = _profile();
      expect(profile.weeklyXP, equals(0));
    });

    test('default totalXp is 0', () {
      final profile = _profile();
      expect(profile.totalXp, equals(0));
    });

    test('default hasStreakFreeze is true', () {
      final profile = _profile();
      expect(profile.hasStreakFreeze, isTrue);
    });

    test('default dailyTipsEnabled is true', () {
      final profile = _profile();
      expect(profile.dailyTipsEnabled, isTrue);
    });

    test('default streakRemindersEnabled is true', () {
      final profile = _profile();
      expect(profile.streakRemindersEnabled, isTrue);
    });

    test('default hasSeenTutorial is false', () {
      final profile = _profile();
      expect(profile.hasSeenTutorial, isFalse);
    });

    test('default completedLessons is empty', () {
      final profile = _profile();
      expect(profile.completedLessons, isEmpty);
    });
  });

  group('UserProfile — level calculation', () {
    test('0 XP is at least level 1 (Beginner threshold is 0)', () {
      // The levels map starts at 0 XP = 'Beginner', so level 1 at 0 XP
      expect(_profile(totalXp: 0).currentLevel, greaterThanOrEqualTo(1));
    });

    test('100 XP is level 2 (Novice threshold)', () {
      expect(_profile(totalXp: 100).currentLevel, equals(2));
    });

    test('250 XP is at least level 2', () {
      expect(_profile(totalXp: 250).currentLevel, greaterThanOrEqualTo(2));
    });

    test('0 XP level title is Beginner', () {
      expect(_profile(totalXp: 0).levelTitle, equals('Beginner'));
    });

    test('level 1 (100 XP) has a non-empty title', () {
      expect(_profile(totalXp: 100).levelTitle, isNotEmpty);
    });

    test('xpToNextLevel decreases as XP increases toward next threshold', () {
      final profile1 = _profile(totalXp: 0);
      final profile2 = _profile(totalXp: 50);
      expect(profile2.xpToNextLevel, lessThan(profile1.xpToNextLevel));
    });

    test('levelProgress is between 0.0 and 1.0', () {
      for (final xp in [0, 50, 100, 250, 500, 1000, 2500]) {
        final p = _profile(totalXp: xp);
        expect(
          p.levelProgress,
          inInclusiveRange(0.0, 1.0),
          reason: 'levelProgress out of range at $xp XP',
        );
      }
    });

    test('levels are monotonically non-decreasing with XP', () {
      int prevLevel = 0;
      for (final xp in [0, 100, 250, 500, 1000, 2500, 5000, 10000]) {
        final level = _profile(totalXp: xp).currentLevel;
        expect(
          level,
          greaterThanOrEqualTo(prevLevel),
          reason: 'Level dropped at $xp XP',
        );
        prevLevel = level;
      }
    });
  });

  group('UserProfile — streak tracking', () {
    test('profile with no activity has no active streak', () {
      final profile = _profile(currentStreak: 0, lastActivityDate: null);
      expect(profile.hasStreak, isFalse);
    });

    test('profile with streak > 0 has active streak', () {
      final profile = _profile(currentStreak: 5);
      expect(profile.hasStreak, isTrue);
    });

    test('isStreakActive is false with no lastActivityDate', () {
      final profile = _profile(currentStreak: 3, lastActivityDate: null);
      expect(profile.isStreakActive, isFalse);
    });

    test('isStreakActive is true when lastActivityDate is today', () {
      final profile = _profile(
        currentStreak: 3,
        lastActivityDate: DateTime.now(),
      );
      expect(profile.isStreakActive, isTrue);
    });

    test('isStreakActive is true when lastActivityDate was yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final profile = _profile(
        currentStreak: 3,
        lastActivityDate: yesterday,
      );
      expect(profile.isStreakActive, isTrue);
    });

    test('isStreakActive is false when lastActivityDate was 3 days ago', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final profile = _profile(
        currentStreak: 3,
        lastActivityDate: threeDaysAgo,
      );
      expect(profile.isStreakActive, isFalse);
    });
  });

  group('UserProfile — XP and daily goals', () {
    test('dailyXpHistory starts empty', () {
      final profile = _profile();
      expect(profile.dailyXpHistory, isEmpty);
    });

    test('shouldResetStreakFreeze returns true for profile with no grantedDate', () {
      final profile = _profile();
      // No streakFreezeGrantedDate triggers a reset (first-time grant)
      expect(profile.shouldResetStreakFreeze, isTrue);
    });

    test('completedLessons count matches input', () {
      final profile = _profile(
        completedLessons: ['nc_intro', 'nc_stages', 'nc_how_to'],
      );
      expect(profile.completedLessons.length, equals(3));
    });
  });

  group('UserProfile — copyWith', () {
    test('copyWith preserves unmodified fields', () {
      final original = _profile(totalXp: 100, currentStreak: 5);
      final copy = original.copyWith(totalXp: 200);
      expect(copy.currentStreak, equals(5));
      expect(copy.totalXp, equals(200));
    });

    test('copyWith creates new instance', () {
      final original = _profile();
      final copy = original.copyWith(totalXp: 1);
      expect(identical(original, copy), isFalse);
    });
  });

  group('UserProfile — levels map', () {
    test('levels map is non-empty', () {
      expect(UserProfile.levels, isNotEmpty);
    });

    test('levels map keys are in ascending order', () {
      final keys = UserProfile.levels.keys.toList();
      for (int i = 1; i < keys.length; i++) {
        expect(keys[i], greaterThan(keys[i - 1]));
      }
    });

    test('100 XP level title is non-empty', () {
      expect(_profile(totalXp: 100).levelTitle, isNotEmpty);
    });
  });
}
