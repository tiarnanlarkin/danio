import '../data/species_unlock_map.dart';

enum TankProgressVisualCondition { clear, speciesUnlocked, collectionGrowing }

class TankProgressVisualState {
  final TankProgressVisualCondition condition;
  final String semanticsLabel;

  const TankProgressVisualState({
    required this.condition,
    required this.semanticsLabel,
  });

  bool get hasOverlay => condition != TankProgressVisualCondition.clear;
}

class TankProgressVisualService {
  const TankProgressVisualService._();

  static TankProgressVisualState fromUnlockedSpecies(
    Set<String> unlockedSpecies,
  ) {
    final earnedSpecies = unlockedSpecies.difference(
      defaultUnlockedSpecies.toSet(),
    );

    if (earnedSpecies.length >= 3) {
      return const TankProgressVisualState(
        condition: TankProgressVisualCondition.collectionGrowing,
        semanticsLabel:
            'Tank progression visual state: growing species collection',
      );
    }

    if (earnedSpecies.isNotEmpty) {
      return const TankProgressVisualState(
        condition: TankProgressVisualCondition.speciesUnlocked,
        semanticsLabel:
            'Tank progression visual state: species unlocks visible',
      );
    }

    return clear;
  }

  static const clear = TankProgressVisualState(
    condition: TankProgressVisualCondition.clear,
    semanticsLabel: 'Tank progression visual state: clear',
  );
}
