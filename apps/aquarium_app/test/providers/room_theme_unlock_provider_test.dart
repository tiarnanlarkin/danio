import 'dart:convert';

import 'package:danio/data/species_unlock_map.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/providers/room_theme_unlock_provider.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('derives unlocked room vibes from persisted species unlocks', () async {
    SharedPreferences.setMockInitialValues({
      'unlocked_species_v1': jsonEncode([...defaultUnlockedSpecies, 'betta']),
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final sub = container.listen(roomThemeUnlockStatesProvider, (_, __) {});
    addTearDown(sub.close);
    await _settle();

    final states = container.read(roomThemeUnlockStatesProvider);

    expect(states[RoomThemeType.pastel]!.isUnlocked, isTrue);
  });

  test(
    'derives unlocked room vibes from persisted user profile progress',
    () async {
      final now = DateTime(2026, 6, 13);
      final profile = UserProfile(
        id: 'profile-1',
        totalXp: 2500,
        createdAt: now,
        updatedAt: now,
      );

      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(profile.toJson()),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sub = container.listen(roomThemeUnlockStatesProvider, (_, __) {});
      addTearDown(sub.close);
      await _settle();

      final states = container.read(roomThemeUnlockStatesProvider);

      expect(states[RoomThemeType.aurora]!.isUnlocked, isTrue);
    },
  );
}

Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
