/// Hearts/Lives system service
/// Manages heart deduction, auto-refill, and practice mode rewards
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';

/// Constants for hearts system
class HeartsConfig {
  static const int maxHearts = 5;
  static const int startingHearts = 5;
  static const Duration refillInterval = Duration(
    minutes: 60,
  ); // 1 hour per heart (5 hours for full refill)
  static const int practiceReward = 1; // Hearts earned for completing practice
}

/// Provider for hearts service
final heartsServiceProvider = Provider<HeartsService>((ref) {
  return HeartsService(ref);
});

/// Service for managing the hearts/lives system.
///
/// Handles heart deduction on incorrect answers, auto-refill timing,
/// and practice mode rewards. Integrates with user profile state.
class HeartsService {
  final Ref ref;

  HeartsService(this.ref);

  /// Get current user profile
  UserProfile? get _profile => ref.read(userProfileProvider).value;

  /// Check if user has hearts available
  bool get hasHeartsAvailable {
    final profile = _profile;
    if (profile == null) return true; // Default to true if no profile
    return profile.hearts > 0;
  }

  /// Get current hearts count
  int get currentHearts {
    final profile = _profile;
    if (profile == null) return HeartsConfig.startingHearts;
    return profile.hearts;
  }

  /// Calculate how many hearts should be auto-refilled
  int calculateAutoRefill(UserProfile profile) {
    if (profile.hearts >= HeartsConfig.maxHearts) return 0;
    if (profile.lastHeartRefill == null) return 0;

    final now = DateTime.now();
    final timeSinceRefill = now.difference(profile.lastHeartRefill!);
    final intervalsPassed =
        timeSinceRefill.inMinutes ~/ HeartsConfig.refillInterval.inMinutes;

    if (intervalsPassed <= 0) return 0;

    // Calculate how many hearts to refill (max out at 5)
    final heartsToRefill = intervalsPassed.clamp(
      0,
      HeartsConfig.maxHearts - profile.hearts,
    );
    return heartsToRefill;
  }

  /// Get time remaining until next heart refill
  Duration? getTimeUntilNextRefill(UserProfile profile) {
    if (profile.hearts >= HeartsConfig.maxHearts) return null;
    if (profile.lastHeartRefill == null) {
      // If no refill time, hearts were just lost - start timer
      return HeartsConfig.refillInterval;
    }

    final now = DateTime.now();
    final timeSinceRefill = now.difference(profile.lastHeartRefill!);
    final nextRefillIn = HeartsConfig.refillInterval - timeSinceRefill;

    return nextRefillIn.isNegative ? Duration.zero : nextRefillIn;
  }

  /// Apply auto-refill if time has passed
  Future<void> checkAndApplyAutoRefill() async {
    final profile = _profile;
    if (profile == null) return;

    final heartsToRefill = calculateAutoRefill(profile);
    if (heartsToRefill > 0) {
      await _updateHearts(
        profile.hearts + heartsToRefill,
        updateRefillTime: true,
      );
    }
  }

  /// Lose a heart (e.g., wrong answer in lesson)
  Future<bool> loseHeart() async {
    final profile = _profile;
    if (profile == null) return false;

    // Check auto-refill first
    await checkAndApplyAutoRefill();

    final updatedProfile = ref.read(userProfileProvider).value;
    if (updatedProfile == null) return false;

    if (updatedProfile.hearts <= 0) return false;

    final newHearts = updatedProfile.hearts - 1;

    // Start the refill timer when losing a heart if not at max
    // or if there's no existing refill time tracked
    final shouldStartTimer = newHearts < HeartsConfig.maxHearts &&
        (updatedProfile.lastHeartRefill == null ||
            updatedProfile.hearts >= HeartsConfig.maxHearts);

    await _updateHearts(
      newHearts,
      updateRefillTime: shouldStartTimer,
    );

    return true;
  }

  /// Gain a heart (e.g., completing practice mode)
  Future<bool> gainHeart() async {
    final profile = _profile;
    if (profile == null) return false;

    // Check auto-refill first
    await checkAndApplyAutoRefill();

    final updatedProfile = ref.read(userProfileProvider).value;
    if (updatedProfile == null) return false;

    if (updatedProfile.hearts >= HeartsConfig.maxHearts) return false;

    await _updateHearts(updatedProfile.hearts + 1);
    return true;
  }

  /// Refill hearts to max (e.g., shop purchase, daily reward)
  Future<void> refillToMax() async {
    final profile = _profile;
    if (profile == null) return;

    // Clear the refill timer — hearts are full, no timer needed
    final notifier = ref.read(userProfileProvider.notifier);
    await notifier.updateHearts(
      hearts: HeartsConfig.maxHearts,
      lastHeartRefill: null,
      clearLastHeartRefill: true,
    );
  }

  /// Internal method to update hearts count
  Future<void> _updateHearts(
    int newHearts, {
    bool updateRefillTime = false,
  }) async {
    final notifier = ref.read(userProfileProvider.notifier);
    await notifier.updateHearts(
      hearts: newHearts.clamp(0, HeartsConfig.maxHearts),
      lastHeartRefill: updateRefillTime ? DateTime.now() : null,
    );
  }

  /// Check if user can start a lesson (has hearts or is practice mode)
  bool canStartLesson({bool isPracticeMode = false}) {
    if (isPracticeMode) return true;
    return hasHeartsAvailable;
  }

  /// Format time remaining as string (e.g., "3h 45m" or "4m 32s")
  String formatTimeRemaining(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      // Only show seconds if non-zero
      if (seconds > 0) {
        return '${minutes}m ${seconds}s';
      } else {
        return '${minutes}m';
      }
    } else {
      return '${seconds}s';
    }
  }

  /// Get all hearts as a list for UI display (filled/empty)
  List<bool> getHeartsDisplay() {
    final hearts = currentHearts;
    return List.generate(HeartsConfig.maxHearts, (index) => index < hearts);
  }
}
