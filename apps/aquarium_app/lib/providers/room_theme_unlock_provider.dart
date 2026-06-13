import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/room_theme_unlock_service.dart';
import '../theme/room_themes.dart';
import 'species_unlock_provider.dart';
import 'user_profile_provider.dart';

final roomThemeUnlockStatesProvider =
    Provider<Map<RoomThemeType, RoomThemeUnlockState>>((ref) {
      final profile = ref.watch(userProfileProvider).valueOrNull;
      final unlockedSpecies = ref.watch(speciesUnlockProvider);

      return RoomThemeUnlockService.statesFor(
        profile: profile,
        unlockedSpecies: unlockedSpecies,
      );
    });
