import '../models/user_profile.dart';

enum TankAchievementVisualCondition { clear, badgeShelf, trophyShelf }

class TankAchievementVisualState {
  final TankAchievementVisualCondition condition;
  final String semanticsLabel;

  const TankAchievementVisualState({
    required this.condition,
    required this.semanticsLabel,
  });

  bool get hasOverlay => condition != TankAchievementVisualCondition.clear;
}

class TankAchievementVisualService {
  const TankAchievementVisualService._();

  static TankAchievementVisualState fromProfile(UserProfile? profile) {
    return fromAchievementIds(profile?.achievements ?? const <String>[]);
  }

  static TankAchievementVisualState fromAchievementIds(
    Iterable<String> achievementIds,
  ) {
    final earnedCount = achievementIds.toSet().length;

    if (earnedCount >= 5) {
      return const TankAchievementVisualState(
        condition: TankAchievementVisualCondition.trophyShelf,
        semanticsLabel: 'Tank achievement cosmetic state: trophy shelf visible',
      );
    }

    if (earnedCount > 0) {
      return const TankAchievementVisualState(
        condition: TankAchievementVisualCondition.badgeShelf,
        semanticsLabel: 'Tank achievement cosmetic state: badge shelf visible',
      );
    }

    return clear;
  }

  static const clear = TankAchievementVisualState(
    condition: TankAchievementVisualCondition.clear,
    semanticsLabel: 'Tank achievement cosmetic state: clear',
  );
}
