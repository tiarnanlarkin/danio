import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tank_decoration.dart';
import '../services/tank_decoration_unlock_service.dart';
import '../utils/logger.dart';
import 'species_unlock_provider.dart';
import 'user_profile_provider.dart';

const kUnlockedTankDecorationsKey = 'unlocked_tank_decorations_v1';
const kEquippedTankDecorationKey = 'equipped_tank_decoration_v1';

final unlockedTankDecorationsProvider =
    StateNotifierProvider<
      TankDecorationInventoryNotifier,
      Set<TankDecorationType>
    >(
      (ref) => TankDecorationInventoryNotifier(ref),
    );

final tankDecorationUnlockStatesProvider =
    Provider<Map<TankDecorationType, TankDecorationUnlockState>>((ref) {
      final profile = ref.watch(userProfileProvider).valueOrNull;
      final unlockedSpecies = ref.watch(speciesUnlockProvider);
      final unlockedDecorations = ref.watch(unlockedTankDecorationsProvider);

      return TankDecorationUnlockService.statesFor(
        profile: profile,
        unlockedSpecies: unlockedSpecies,
        unlockedDecorations: unlockedDecorations,
      );
    });

final equippedTankDecorationProvider =
    StateNotifierProvider<TankDecorationEquipNotifier, TankDecorationType?>(
      (ref) => TankDecorationEquipNotifier(ref),
    );

class TankDecorationInventoryNotifier
    extends StateNotifier<Set<TankDecorationType>> {
  TankDecorationInventoryNotifier(this.ref)
    : super(const {TankDecorationType.riverStones}) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final raw = prefs.getString(kUnlockedTankDecorationsKey);
      if (raw == null) {
        state = const {TankDecorationType.riverStones};
        return;
      }

      final decoded = jsonDecode(raw) as List<dynamic>;
      state = {
        TankDecorationType.riverStones,
        for (final value in decoded)
          if (value is String) _typeFromName(value),
      }.whereType<TankDecorationType>().toSet();
    } catch (e, st) {
      logError(
        'TankDecorationProvider: unlocked decoration load failed: $e',
        stackTrace: st,
        tag: 'TankDecorationProvider',
      );
      state = const {TankDecorationType.riverStones};
    }
  }

  Future<bool> unlockDecoration(TankDecorationType type) async {
    if (state.contains(type)) return false;
    final updated = {...state, type};
    final saved = await _save(updated);
    if (!saved) return false;
    state = updated;
    return true;
  }

  Future<bool> _save(Set<TankDecorationType> decorations) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      return prefs.setString(
        kUnlockedTankDecorationsKey,
        jsonEncode(decorations.map((type) => type.name).toList()..sort()),
      );
    } catch (e, st) {
      logError(
        'TankDecorationProvider: unlocked decoration save failed: $e',
        stackTrace: st,
        tag: 'TankDecorationProvider',
      );
      return false;
    }
  }
}

class TankDecorationEquipNotifier extends StateNotifier<TankDecorationType?> {
  TankDecorationEquipNotifier(this.ref) : super(null) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      state = _typeFromName(prefs.getString(kEquippedTankDecorationKey));
    } catch (e, st) {
      logError(
        'TankDecorationProvider: equipped decoration load failed: $e',
        stackTrace: st,
        tag: 'TankDecorationProvider',
      );
    }
  }

  Future<bool> equipDecoration(TankDecorationType? type) async {
    if (type != null) {
      final unlockState = ref.read(tankDecorationUnlockStatesProvider)[type];
      if (unlockState == null || !unlockState.isUnlocked) return false;
    }

    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final saved = type == null
          ? await prefs.remove(kEquippedTankDecorationKey)
          : await prefs.setString(kEquippedTankDecorationKey, type.name);
      if (!saved) return false;
      state = type;
      return true;
    } catch (e, st) {
      logError(
        'TankDecorationProvider: equipped decoration save failed: $e',
        stackTrace: st,
        tag: 'TankDecorationProvider',
      );
      return false;
    }
  }
}

TankDecorationType? _typeFromName(String? value) {
  if (value == null) return null;
  for (final type in TankDecorationType.values) {
    if (type.name == value) return type;
  }
  return null;
}
