import '../data/species_unlock_map.dart';
import '../models/user_profile.dart';
import '../theme/room_themes.dart';

class RoomThemeUnlockState {
  final RoomThemeType type;
  final bool isUnlocked;
  final String requirementLabel;

  const RoomThemeUnlockState({
    required this.type,
    required this.isUnlocked,
    required this.requirementLabel,
  });
}

class RoomThemeUnlockService {
  const RoomThemeUnlockService._();

  static const Map<String, List<RoomThemeType>> _achievementRoomVibeUnlocks = {
    'streak_3': [RoomThemeType.eveningGlow],
    'streak_7': [RoomThemeType.midnight],
    'night_owl': [RoomThemeType.midnight],
    'lessons_10': [RoomThemeType.dreamy],
    'five_species': [RoomThemeType.forest],
    'plants_master': [RoomThemeType.forest],
    'xp_1000': [RoomThemeType.watercolor],
    'perfectionist': [RoomThemeType.cotton],
    'xp_2500': [RoomThemeType.aurora],
  };

  static Map<RoomThemeType, RoomThemeUnlockState> statesFor({
    required UserProfile? profile,
    required Set<String> unlockedSpecies,
  }) {
    return {
      for (final type in RoomThemeType.values)
        type: RoomThemeUnlockState(
          type: type,
          isUnlocked: _isUnlocked(
            type: type,
            profile: profile,
            unlockedSpecies: unlockedSpecies,
          ),
          requirementLabel: _requirementLabel(type),
        ),
    };
  }

  static List<RoomThemeType> roomVibesUnlockedByAchievementId(
    String achievementId,
  ) {
    return List.unmodifiable(
      _achievementRoomVibeUnlocks[achievementId] ?? const <RoomThemeType>[],
    );
  }

  static List<RoomThemeType> roomVibesUnlockedByAchievementIds(
    Iterable<String> achievementIds,
  ) {
    final unlocked = <RoomThemeType>{};
    for (final achievementId in achievementIds) {
      unlocked.addAll(roomVibesUnlockedByAchievementId(achievementId));
    }

    return RoomThemeType.values
        .where(unlocked.contains)
        .toList(growable: false);
  }

  static bool _isUnlocked({
    required RoomThemeType type,
    required UserProfile? profile,
    required Set<String> unlockedSpecies,
  }) {
    final totalXp = profile?.totalXp ?? 0;
    final currentStreak = profile?.currentStreak ?? 0;
    final achievements = profile?.achievements.toSet() ?? const <String>{};
    final completedLessons = profile?.completedLessons.length ?? 0;
    final perfectScores = profile?.perfectScoreCount ?? 0;
    final earnedSpecies = unlockedSpecies.difference(
      defaultUnlockedSpecies.toSet(),
    );

    switch (type) {
      case RoomThemeType.ocean:
      case RoomThemeType.cozyLiving:
      case RoomThemeType.golden:
        return true;
      case RoomThemeType.pastel:
        return earnedSpecies.isNotEmpty;
      case RoomThemeType.eveningGlow:
        return currentStreak >= 3 || achievements.contains('streak_3');
      case RoomThemeType.midnight:
        return currentStreak >= 7 ||
            achievements.contains('streak_7') ||
            achievements.contains('night_owl');
      case RoomThemeType.dreamy:
        return completedLessons >= 10 || achievements.contains('lessons_10');
      case RoomThemeType.sunset:
        return totalXp >= 300 || achievements.contains('xp_500');
      case RoomThemeType.forest:
        return unlockedSpecies.length >= 5 ||
            achievements.contains('five_species') ||
            achievements.contains('plants_master');
      case RoomThemeType.watercolor:
        return totalXp >= 1000 || achievements.contains('xp_1000');
      case RoomThemeType.cotton:
        return perfectScores >= 3 || achievements.contains('perfectionist');
      case RoomThemeType.aurora:
        return totalXp >= 2500 || achievements.contains('xp_2500');
    }
  }

  static String _requirementLabel(RoomThemeType type) {
    return switch (type) {
      RoomThemeType.ocean ||
      RoomThemeType.cozyLiving ||
      RoomThemeType.golden => 'Unlocked from the start.',
      RoomThemeType.pastel => 'Earn your first lesson species to unlock this.',
      RoomThemeType.eveningGlow =>
        'Reach a 3 day streak to unlock Evening Glow.',
      RoomThemeType.midnight => 'Reach a 7 day streak to unlock Midnight.',
      RoomThemeType.dreamy => 'Complete 10 lessons to unlock Dreamy.',
      RoomThemeType.sunset => 'Reach 300 XP to unlock Sunset.',
      RoomThemeType.forest =>
        'Unlock five species to unlock the Forest room vibe.',
      RoomThemeType.watercolor => 'Reach 1000 XP to unlock Watercolor.',
      RoomThemeType.cotton =>
        'Earn three perfect quiz scores to unlock Cotton Candy.',
      RoomThemeType.aurora => 'Reach 2500 XP to unlock Aurora.',
    };
  }
}
