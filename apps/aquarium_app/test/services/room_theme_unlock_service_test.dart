import 'package:danio/data/species_unlock_map.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/services/room_theme_unlock_service.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starter room vibes are always unlocked', () {
    final states = RoomThemeUnlockService.statesFor(
      profile: null,
      unlockedSpecies: defaultUnlockedSpecies.toSet(),
    );

    expect(states[RoomThemeType.ocean]!.isUnlocked, isTrue);
    expect(states[RoomThemeType.cozyLiving]!.isUnlocked, isTrue);
    expect(states[RoomThemeType.golden]!.isUnlocked, isTrue);
  });

  test('first earned species unlocks pastel', () {
    final states = RoomThemeUnlockService.statesFor(
      profile: null,
      unlockedSpecies: {...defaultUnlockedSpecies, 'betta'},
    );

    expect(states[RoomThemeType.pastel]!.isUnlocked, isTrue);
  });

  test('seven day streak unlocks midnight and evening glow', () {
    final profile = _profile(currentStreak: 7);
    final states = RoomThemeUnlockService.statesFor(
      profile: profile,
      unlockedSpecies: defaultUnlockedSpecies.toSet(),
    );

    expect(states[RoomThemeType.eveningGlow]!.isUnlocked, isTrue);
    expect(states[RoomThemeType.midnight]!.isUnlocked, isTrue);
  });

  test('locked themes expose plain requirement copy', () {
    final states = RoomThemeUnlockService.statesFor(
      profile: _profile(),
      unlockedSpecies: defaultUnlockedSpecies.toSet(),
    );

    expect(states[RoomThemeType.aurora]!.isUnlocked, isFalse);
    expect(states[RoomThemeType.aurora]!.requirementLabel, isNotEmpty);
    expect(states[RoomThemeType.aurora]!.requirementLabel, contains('2500 XP'));
  });

  test('achievement IDs expose room vibe cosmetic rewards', () {
    expect(
      RoomThemeUnlockService.roomVibesUnlockedByAchievementId('streak_7'),
      [RoomThemeType.midnight],
    );
    expect(
      RoomThemeUnlockService.roomVibesUnlockedByAchievementId('lessons_10'),
      [RoomThemeType.dreamy],
    );
    expect(RoomThemeUnlockService.roomVibesUnlockedByAchievementId('xp_2500'), [
      RoomThemeType.aurora,
    ]);
  });

  test('batch achievement room vibe rewards are unique and stable', () {
    expect(
      RoomThemeUnlockService.roomVibesUnlockedByAchievementIds([
        'night_owl',
        'streak_7',
        'xp_2500',
      ]),
      [RoomThemeType.midnight, RoomThemeType.aurora],
    );
  });

  test('unmapped achievements do not claim cosmetic rewards', () {
    expect(
      RoomThemeUnlockService.roomVibesUnlockedByAchievementId('first_lesson'),
      isEmpty,
    );
  });
}

UserProfile _profile({
  int totalXp = 0,
  int currentStreak = 0,
  int perfectScoreCount = 0,
  List<String> achievements = const [],
  List<String> completedLessons = const [],
}) {
  final now = DateTime(2026, 6, 13);
  return UserProfile(
    id: 'profile-1',
    totalXp: totalXp,
    currentStreak: currentStreak,
    achievements: achievements,
    completedLessons: completedLessons,
    perfectScoreCount: perfectScoreCount,
    createdAt: now,
    updatedAt: now,
  );
}
