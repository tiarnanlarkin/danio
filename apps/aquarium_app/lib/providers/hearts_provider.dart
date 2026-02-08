/// Hearts Provider - Simplified wrapper around HeartsService
/// Provides reactive state management for hearts system
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hearts_service.dart';
import '../models/user_profile.dart';
import 'user_profile_provider.dart';

/// Hearts state model
class HeartsState {
  final int currentHearts;
  final int maxHearts;
  final bool hasHearts;
  final Duration? timeUntilNextRefill;
  final List<bool> heartsDisplay;

  const HeartsState({
    required this.currentHearts,
    required this.maxHearts,
    required this.hasHearts,
    this.timeUntilNextRefill,
    required this.heartsDisplay,
  });

  factory HeartsState.fromProfile(UserProfile? profile, HeartsService service) {
    if (profile == null) {
      return HeartsState(
        currentHearts: HeartsConfig.startingHearts,
        maxHearts: HeartsConfig.maxHearts,
        hasHearts: true,
        timeUntilNextRefill: null,
        heartsDisplay: List.generate(HeartsConfig.maxHearts, (_) => true),
      );
    }

    return HeartsState(
      currentHearts: profile.hearts,
      maxHearts: HeartsConfig.maxHearts,
      hasHearts: profile.hearts > 0,
      timeUntilNextRefill: service.getTimeUntilNextRefill(profile),
      heartsDisplay: service.getHeartsDisplay(),
    );
  }

  double get percentage => currentHearts / maxHearts;
  bool get isFull => currentHearts >= maxHearts;
  bool get isEmpty => currentHearts <= 0;
}

/// Provider that watches hearts state reactively
final heartsStateProvider = Provider<HeartsState>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  final service = ref.watch(heartsServiceProvider);
  return HeartsState.fromProfile(profile, service);
});

/// Provider for hearts actions
final heartsActionsProvider = Provider<HeartsActions>((ref) {
  return HeartsActions(ref);
});

class HeartsActions {
  final Ref ref;

  HeartsActions(this.ref);

  HeartsService get _service => ref.read(heartsServiceProvider);

  /// Lose a heart (returns true if successful)
  Future<bool> loseHeart() async {
    final success = await _service.loseHeart();
    if (success) {
      // Invalidate to trigger UI updates
      ref.invalidate(userProfileProvider);
    }
    return success;
  }

  /// Gain a heart (returns true if successful)
  Future<bool> gainHeart() async {
    final success = await _service.gainHeart();
    if (success) {
      ref.invalidate(userProfileProvider);
    }
    return success;
  }

  /// Refill all hearts to max
  Future<void> refillToMax() async {
    await _service.refillToMax();
    ref.invalidate(userProfileProvider);
  }

  /// Check and apply auto-refill
  Future<void> checkAutoRefill() async {
    await _service.checkAndApplyAutoRefill();
    ref.invalidate(userProfileProvider);
  }

  /// Check if user can start a lesson
  bool canStartLesson({bool isPracticeMode = false}) {
    return _service.canStartLesson(isPracticeMode: isPracticeMode);
  }
}
