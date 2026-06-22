import 'package:danio/data/species_unlock_map.dart';
import 'package:danio/models/tank_decoration.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/services/tank_decoration_unlock_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starter decoration is always unlocked', () {
    final states = TankDecorationUnlockService.statesFor(
      profile: null,
      unlockedSpecies: defaultUnlockedSpecies.toSet(),
      unlockedDecorations: const {},
    );

    expect(states[TankDecorationType.riverStones]!.isUnlocked, isTrue);
  });

  test('earned species unlocks driftwood arch', () {
    final states = TankDecorationUnlockService.statesFor(
      profile: null,
      unlockedSpecies: {...defaultUnlockedSpecies, 'betta'},
      unlockedDecorations: const {},
    );

    expect(states[TankDecorationType.driftwoodArch]!.isUnlocked, isTrue);
  });

  test('locked decorations expose plain requirement copy', () {
    final states = TankDecorationUnlockService.statesFor(
      profile: _profile(),
      unlockedSpecies: defaultUnlockedSpecies.toSet(),
      unlockedDecorations: const {},
    );

    expect(states[TankDecorationType.mossyHide]!.isUnlocked, isFalse);
    expect(
      states[TankDecorationType.mossyHide]!.requirementLabel,
      'Complete 10 lessons to unlock Mossy Hide.',
    );
  });

  test('progress unlocks advanced decorations', () {
    final states = TankDecorationUnlockService.statesFor(
      profile: _profile(
        totalXp: 1000,
        completedLessons: List.generate(10, (index) => 'lesson-$index'),
      ),
      unlockedSpecies: defaultUnlockedSpecies.toSet(),
      unlockedDecorations: const {},
    );

    expect(states[TankDecorationType.mossyHide]!.isUnlocked, isTrue);
    expect(states[TankDecorationType.ceramicShelter]!.isUnlocked, isTrue);
  });

  test('persisted earned decorations stay unlocked', () {
    final states = TankDecorationUnlockService.statesFor(
      profile: _profile(),
      unlockedSpecies: defaultUnlockedSpecies.toSet(),
      unlockedDecorations: const {TankDecorationType.ceramicShelter},
    );

    expect(states[TankDecorationType.ceramicShelter]!.isUnlocked, isTrue);
  });
}

UserProfile _profile({
  int totalXp = 0,
  List<String> completedLessons = const [],
}) {
  final now = DateTime(2026, 6, 22);
  return UserProfile(
    id: 'profile-1',
    totalXp: totalXp,
    completedLessons: completedLessons,
    createdAt: now,
    updatedAt: now,
  );
}
