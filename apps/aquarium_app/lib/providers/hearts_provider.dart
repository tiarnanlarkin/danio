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

  /// Build from just the hearts count — avoids watching the full UserProfile.
  factory HeartsState.fromHearts(int? hearts, HeartsService service) {
    final h = hearts ?? HeartsConfig.startingHearts;
    return HeartsState(
      currentHearts: h,
      maxHearts: HeartsConfig.maxHearts,
      hasHearts: h > 0,
      timeUntilNextRefill: null, // refill timer checked on-demand
      heartsDisplay: service.getHeartsDisplay(),
    );
  }

  double get percentage => currentHearts / maxHearts;
  bool get isFull => currentHearts >= maxHearts;
  bool get isEmpty => currentHearts <= 0;
}

/// Provider that watches hearts state reactively
/// Uses .select() to only rebuild when hearts-related fields change,
/// not on every XP gain or other profile update.
final heartsStateProvider = Provider<HeartsState>((ref) {
  final hearts = ref.watch(userProfileProvider.select((a) => a.value?.hearts));
  final service = ref.watch(heartsServiceProvider);
  return HeartsState.fromHearts(hearts, service);
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
    return await _service.loseHeart();
  }

  /// Gain a heart (returns true if successful)
  Future<bool> gainHeart() async {
    return await _service.gainHeart();
  }

  /// Refill all hearts to max
  Future<void> refillToMax() async {
    await _service.refillToMax();
  }

  /// Check and apply auto-refill
  Future<void> checkAutoRefill() async {
    await _service.checkAndApplyAutoRefill();
  }

  /// Check if user can start a lesson
  bool canStartLesson({bool isPracticeMode = false}) {
    return _service.canStartLesson(isPracticeMode: isPracticeMode);
  }
}
