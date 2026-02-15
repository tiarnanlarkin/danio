import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../models/user_profile.dart';
import 'user_profile_provider.dart';

/// NOTE: This provider is currently unused and contains duplicate functionality.
///
/// The functionality for weekly leaderboard resets and XP tracking already exists
/// in user_profile_provider.dart via the UserProfileNotifier.addXp() method, which:
/// - Automatically checks and resets weekly XP when a new week starts
/// - Updates weekly XP totals
/// - Calculates and updates league based on weekly XP
///
/// This file is kept for reference but should be removed in future cleanup.
/// See user_profile_provider.dart lines ~200-250 for the working implementation.

/// Provider for weekly leaderboard reset logic (UNUSED - See note above)
final leaderboardResetProvider = Provider<LeaderboardReset>((ref) {
  return LeaderboardReset(ref);
});

class LeaderboardReset {
  final Ref ref;

  LeaderboardReset(this.ref);

  /* COMMENTED OUT - Functionality exists in UserProfileNotifier.addXp()
  
  /// Check if week has changed and reset weekly XP if needed
  Future<void> checkAndResetWeek() async {
    final profileNotifier = ref.read(userProfileProvider.notifier);
    final asyncProfile = ref.read(userProfileProvider);
    
    // Extract profile from AsyncValue
    final profile = asyncProfile.value;
    if (profile == null) return;

    final currentWeek = WeekPeriod.current();
    final weekStart = profile.weekStartDate;

    // First time or week has changed
    if (weekStart == null || !_isSameWeek(weekStart, currentWeek.start)) {
      // Calculate new league based on final rank (would need full leaderboard data)
      // For now, just reset XP
      
      // ERROR: updateProfile doesn't accept these parameters
      // Use UserProfileNotifier.addXp() instead which handles this automatically
      await profileNotifier.updateProfile(
        profile.copyWith(
          weeklyXP: 0,
          weekStartDate: currentWeek.start,
        ),
      );
    }
  }

  /// Add XP and update weekly total
  Future<void> addXP(int amount) async {
    await checkAndResetWeek(); // Ensure week is current
    
    final profileNotifier = ref.read(userProfileProvider.notifier);
    final asyncProfile = ref.read(userProfileProvider);
    
    // Extract profile from AsyncValue
    final profile = asyncProfile.value;
    if (profile == null) return;

    final newWeeklyXP = profile.weeklyXP + amount;
    final newTotalXP = profile.totalXp + amount;

    // Check if XP crossed league threshold
    final newLeague = _calculateLeagueFromXP(newWeeklyXP);

    // ERROR: updateProfile doesn't accept these parameters
    // Use UserProfileNotifier.addXp() instead
    await profileNotifier.updateProfile(
      profile.copyWith(
        weeklyXP: newWeeklyXP,
        totalXp: newTotalXP,
        league: newLeague,
      ),
    );
  }
  */

}
