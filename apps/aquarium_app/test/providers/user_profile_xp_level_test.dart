// Tests for UserProfile XP, level thresholds, and streak logic.
//
// These test the pure model calculations (no I/O, no async required).
//
// Run: flutter test test/providers/user_profile_xp_level_test.dart

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
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('UserProfile — XP level thresholds', () {
    test('0 XP → Beginner', () {
      expect(_profile(totalXp: 0).levelTitle, equals('Beginner'));
    });

    test('100 XP → Novice', () {
      expect(_profile(totalXp: 100).levelTitle, equals('Novice'));
    });

    test('300 XP → Hobbyist', () {
      expect(_profile(totalXp: 300).levelTitle, equals('Hobbyist'));
    });

    test('600 XP → Aquarist', () {
      expect(_profile(totalXp: 600).levelTitle, equals('Aquarist'));
    });

    test('1000 XP → Expert', () {
      expect(_profile(totalXp: 1000).levelTitle, equals('Expert'));
    });

    test('1500 XP → Master', () {
      expect(_profile(totalXp: 1500).levelTitle, equals('Master'));
    });

    test('2500 XP → Guru', () {
      expect(_profile(totalXp: 2500).levelTitle, equals('Guru'));
    });

    test('5000 XP → Sage', () {
      expect(_profile(totalXp: 5000).levelTitle, equals('Sage'));
    });

    test('10000 XP → Grandmaster', () {
      expect(_profile(totalXp: 10000).levelTitle, equals('Grandmaster'));
    });

    test('99 XP → still Beginner (below Novice threshold)', () {
      expect(_profile(totalXp: 99).levelTitle, equals('Beginner'));
    });

    test('299 XP → still Novice (below Hobbyist threshold)', () {
      expect(_profile(totalXp: 299).levelTitle, equals('Novice'));
    });
  });

  group('UserProfile — currentLevel progression', () {
    test('0 XP → level 1', () {
      expect(_profile(totalXp: 0).currentLevel, equals(1));
    });

    test('100 XP → level 2', () {
      expect(_profile(totalXp: 100).currentLevel, equals(2));
    });

    test('levels increase monotonically with XP', () {
      final xpValues = [0, 100, 300, 600, 1000, 1500, 2500, 5000, 10000];
      int prev = 0;
      for (final xp in xpValues) {
        final level = _profile(totalXp: xp).currentLevel;
        expect(
          level,
          greaterThanOrEqualTo(prev),
          reason: 'Level regressed at $xp XP',
        );
        prev = level;
      }
    });
  });

  group('UserProfile — xpToNextLevel', () {
    test('at 0 XP: xpToNextLevel = 100 (to reach Novice)', () {
      expect(_profile(totalXp: 0).xpToNextLevel, equals(100));
    });

    test('at 50 XP: xpToNextLevel = 50', () {
      expect(_profile(totalXp: 50).xpToNextLevel, equals(50));
    });

    test('at 100 XP: xpToNextLevel = 200 (to reach Hobbyist at 300)', () {
      expect(_profile(totalXp: 100).xpToNextLevel, equals(200));
    });

    test('xpToNextLevel decreases as XP increases within a tier', () {
      final low = _profile(totalXp: 0).xpToNextLevel;
      final high = _profile(totalXp: 50).xpToNextLevel;
      expect(high, lessThan(low));
    });

    test('at max level (10000 XP): xpToNextLevel = 0', () {
      expect(_profile(totalXp: 10000).xpToNextLevel, equals(0));
    });
  });

  group('UserProfile — levelProgress', () {
    test('levelProgress is between 0 and 1 at all XP milestones', () {
      final xpValues = [0, 50, 100, 250, 600, 1000, 2500, 5000, 10000];
      for (final xp in xpValues) {
        final progress = _profile(totalXp: xp).levelProgress;
        expect(
          progress,
          inInclusiveRange(0.0, 1.0),
          reason: 'levelProgress out of range at $xp XP',
        );
      }
    });

    test('at exact threshold XP: levelProgress = 0 or 1', () {
      // At 100 XP (Novice threshold) progress within the Novice-to-Hobbyist band starts at 0
      final p = _profile(totalXp: 100).levelProgress;
      expect(p, inInclusiveRange(0.0, 1.0));
    });

    test('levelProgress increases within a tier', () {
      final low = _profile(totalXp: 100).levelProgress;
      final high = _profile(totalXp: 200).levelProgress;
      expect(high, greaterThan(low));
    });
  });

  group('UserProfile — streak tracking', () {
    test('currentStreak = 0 → hasStreak is false', () {
      expect(_profile(currentStreak: 0).hasStreak, isFalse);
    });

    test('currentStreak = 5 → hasStreak is true', () {
      expect(_profile(currentStreak: 5).hasStreak, isTrue);
    });

    test('isStreakActive is false when no lastActivityDate', () {
      expect(_profile().isStreakActive, isFalse);
    });

    test('isStreakActive is true when lastActivityDate is today', () {
      final profile = _profile(
        currentStreak: 3,
        lastActivityDate: DateTime.now(),
      );
      expect(profile.isStreakActive, isTrue);
    });

    test('isStreakActive is true when lastActivityDate was yesterday', () {
      final profile = _profile(
        currentStreak: 3,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(profile.isStreakActive, isTrue);
    });

    test('isStreakActive is false when lastActivityDate was 3 days ago', () {
      final profile = _profile(
        currentStreak: 3,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 3)),
      );
      expect(profile.isStreakActive, isFalse);
    });

    test('longestStreak stored correctly', () {
      final profile = _profile(currentStreak: 7, longestStreak: 14);
      expect(profile.longestStreak, equals(14));
      expect(profile.currentStreak, equals(7));
    });
  });

  group('UserProfile — copyWith XP', () {
    test('copyWith totalXp increases level when crossing threshold', () {
      final before = _profile(totalXp: 99);
      expect(before.levelTitle, equals('Beginner'));

      // We can simulate what addXp would do: increment XP
      final after = before.copyWith(totalXp: 100);
      expect(after.levelTitle, equals('Novice'));
    });

    test('copyWith preserves streak when only XP changes', () {
      final before = _profile(totalXp: 0, currentStreak: 5);
      final after = before.copyWith(totalXp: 50);
      expect(after.currentStreak, equals(5));
    });

    test('copyWith increments streak independently of XP', () {
      final before = _profile(totalXp: 100, currentStreak: 3);
      final after = before.copyWith(currentStreak: 4);
      expect(after.currentStreak, equals(4));
      expect(after.totalXp, equals(100));
    });
  });

  group('UserProfile — levels map integrity', () {
    test('levels map has 9 entries', () {
      expect(UserProfile.levels.length, equals(9));
    });

    test('levels map keys are in ascending order', () {
      final keys = UserProfile.levels.keys.toList();
      for (int i = 1; i < keys.length; i++) {
        expect(
          keys[i],
          greaterThan(keys[i - 1]),
          reason: 'Keys not in ascending order at index $i',
        );
      }
    });

    test('all level titles are non-empty strings', () {
      for (final title in UserProfile.levels.values) {
        expect(title, isNotEmpty);
      }
    });
  });
}
