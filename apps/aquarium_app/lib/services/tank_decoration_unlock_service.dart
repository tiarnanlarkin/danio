import '../data/species_unlock_map.dart';
import '../models/tank_decoration.dart';
import '../models/user_profile.dart';

class TankDecorationUnlockState {
  final TankDecorationDefinition definition;
  final bool isUnlocked;
  final String requirementLabel;

  const TankDecorationUnlockState({
    required this.definition,
    required this.isUnlocked,
    required this.requirementLabel,
  });

  TankDecorationType get type => definition.type;
}

class TankDecorationUnlockService {
  const TankDecorationUnlockService._();

  static Map<TankDecorationType, TankDecorationUnlockState> statesFor({
    required UserProfile? profile,
    required Set<String> unlockedSpecies,
    required Set<TankDecorationType> unlockedDecorations,
  }) {
    return {
      for (final definition in TankDecorationDefinition.all)
        definition.type: TankDecorationUnlockState(
          definition: definition,
          isUnlocked: _isUnlocked(
            type: definition.type,
            profile: profile,
            unlockedSpecies: unlockedSpecies,
            unlockedDecorations: unlockedDecorations,
          ),
          requirementLabel: _requirementLabel(definition.type),
        ),
    };
  }

  static bool _isUnlocked({
    required TankDecorationType type,
    required UserProfile? profile,
    required Set<String> unlockedSpecies,
    required Set<TankDecorationType> unlockedDecorations,
  }) {
    if (unlockedDecorations.contains(type)) return true;

    final totalXp = profile?.totalXp ?? 0;
    final completedLessons = profile?.completedLessons.length ?? 0;
    final achievements = profile?.achievements.toSet() ?? const <String>{};
    final earnedSpecies = unlockedSpecies.difference(
      defaultUnlockedSpecies.toSet(),
    );

    return switch (type) {
      TankDecorationType.riverStones => true,
      TankDecorationType.driftwoodArch => earnedSpecies.isNotEmpty,
      TankDecorationType.mossyHide =>
        completedLessons >= 10 ||
            achievements.contains('lessons_10') ||
            achievements.contains('plants_master'),
      TankDecorationType.ceramicShelter =>
        totalXp >= 1000 || achievements.contains('xp_1000'),
    };
  }

  static String _requirementLabel(TankDecorationType type) {
    return switch (type) {
      TankDecorationType.riverStones => 'Unlocked from the start.',
      TankDecorationType.driftwoodArch =>
        'Earn your first lesson species to unlock Driftwood Arch.',
      TankDecorationType.mossyHide =>
        'Complete 10 lessons to unlock Mossy Hide.',
      TankDecorationType.ceramicShelter =>
        'Reach 1000 XP to unlock Ceramic Shelter.',
    };
  }
}
