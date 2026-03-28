/// Provider that tracks which fish species the user has unlocked.
///
/// Species are unlocked in two ways:
/// 1. Default species — always unlocked (see [defaultUnlockedSpecies]).
/// 2. Lesson-gated species — unlocked when the corresponding lesson is
///    completed (see [speciesLessonMap]).
///
/// Unlocked species are persisted to SharedPreferences so they survive
/// app restarts.
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/species_unlock_map.dart';
import '../providers/user_profile_provider.dart';
import '../utils/logger.dart';

const _kUnlockedSpeciesKey = 'unlocked_species_v1';

// ── State ───────────────────────────────────────────────────────────────────

class SpeciesUnlockNotifier extends StateNotifier<Set<String>> {
  SpeciesUnlockNotifier(this._ref) : super(Set.unmodifiable(defaultUnlockedSpecies)) {
    _load();
  }

  final Ref _ref;

  // ── Load / Save ──────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final raw = prefs.getString(_kUnlockedSpeciesKey);
      if (raw != null) {
        final list = (jsonDecode(raw) as List).cast<String>();
        // Always include defaults even if persisted data pre-dates them
        state = {...defaultUnlockedSpecies, ...list};
      } else {
        // First launch — seed defaults and also unlock species for any lessons
        // already completed (handles upgrades from older app versions).
        state = {...defaultUnlockedSpecies};
        await _syncFromCompletedLessons();
      }
    } catch (e, st) {
      logError('SpeciesUnlockProvider: load failed: $e', stackTrace: st, tag: 'SpeciesUnlockProvider');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_kUnlockedSpeciesKey, jsonEncode(state.toList()));
    } catch (e, st) {
      logError('SpeciesUnlockProvider: save failed: $e', stackTrace: st, tag: 'SpeciesUnlockProvider');
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns true if the species with [speciesId] is unlocked.
  bool isUnlocked(String speciesId) => state.contains(speciesId);

  /// Unlock a species by its ID.  No-op if already unlocked.
  /// Returns true if this was a new unlock.
  Future<bool> unlockSpecies(String speciesId) async {
    if (state.contains(speciesId)) return false;
    state = {...state, speciesId};
    await _save();
    return true;
  }

  /// Check whether completing [lessonId] unlocks a new species.
  /// Returns the newly-unlocked species ID, or null if none.
  Future<String?> checkLessonUnlock(String lessonId) async {
    final speciesId = speciesForLesson(lessonId);
    if (speciesId == null) return null;
    final isNew = await unlockSpecies(speciesId);
    return isNew ? speciesId : null;
  }

  /// Sync unlocked species against the user's already-completed lessons.
  /// Called once on first launch so existing users get retroactive unlocks.
  Future<void> _syncFromCompletedLessons() async {
    try {
      final profile = _ref.read(userProfileProvider).value;
      if (profile == null) return;

      bool changed = false;
      for (final lessonId in profile.completedLessons) {
        final speciesId = speciesForLesson(lessonId);
        if (speciesId != null && !state.contains(speciesId)) {
          state = {...state, speciesId};
          changed = true;
        }
      }
      if (changed) await _save();
    } catch (e) {
      // Non-fatal — defaults are still set
      logError('SpeciesUnlockProvider: _syncFromCompletedLessons failed: $e', tag: 'SpeciesUnlockProvider');
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

/// The main species unlock provider.
final speciesUnlockProvider =
    StateNotifierProvider<SpeciesUnlockNotifier, Set<String>>((ref) {
      return SpeciesUnlockNotifier(ref);
    });

/// Convenience provider: is a specific species unlocked?
final isSpeciesUnlockedProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(speciesUnlockProvider).contains(id);
});

/// All unlocked species as a sorted list.
final unlockedSpeciesListProvider = Provider<List<String>>((ref) {
  return ref.watch(speciesUnlockProvider).toList()..sort();
});
