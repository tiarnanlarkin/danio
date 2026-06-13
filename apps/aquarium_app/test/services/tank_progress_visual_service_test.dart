import 'package:danio/data/species_unlock_map.dart';
import 'package:danio/services/tank_progress_visual_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default starter species return clear', () {
    final state = TankProgressVisualService.fromUnlockedSpecies(
      defaultUnlockedSpecies.toSet(),
    );

    expect(state.condition, TankProgressVisualCondition.clear);
    expect(state.hasOverlay, isFalse);
  });

  test('one earned species returns species unlocked cue', () {
    final state = TankProgressVisualService.fromUnlockedSpecies({
      ...defaultUnlockedSpecies,
      'betta',
    });

    expect(state.condition, TankProgressVisualCondition.speciesUnlocked);
    expect(
      state.semanticsLabel,
      'Tank progression visual state: species unlocks visible',
    );
  });

  test('three earned species returns growing collection cue', () {
    final state = TankProgressVisualService.fromUnlockedSpecies({
      ...defaultUnlockedSpecies,
      'betta',
      'molly',
      'platy',
    });

    expect(state.condition, TankProgressVisualCondition.collectionGrowing);
    expect(
      state.semanticsLabel,
      'Tank progression visual state: growing species collection',
    );
  });
}
