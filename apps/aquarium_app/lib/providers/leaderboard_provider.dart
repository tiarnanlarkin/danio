import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../models/user_profile.dart';
import 'user_profile_provider.dart';

/// Provider for weekly leaderboard reset logic
final leaderboardResetProvider = Provider<LeaderboardReset>((ref) {
  return LeaderboardReset(ref);
});

class LeaderboardReset {
  final Ref ref;

  LeaderboardReset(this.ref);

  /// Check if week has changed and reset weekly XP if needed
  Future<void> checkAndResetWeek() async {
    final profileNotifier = ref.read(userProfileProvider.notifier);
    final profile = await ref.read(userProfileProvider.future);
    
    if (profile == null) return;

    final currentWeek = WeekPeriod.current();
    final weekStart = profile.weekStartDate;

    // First time or week has changed
    if (weekStart == null || !_isSameWeek(weekStart, currentWeek.start)) {
      // Calculate new league based on final rank (would need full leaderboard data)
      // For now, just reset XP
      await profileNotifier.updateProfile(
        profile.copyWith(
          weeklyXP: 0,
          weekStartDate: currentWeek.start,
        ),
      );
    }
  }

  /// Check if two dates are in the same week (Monday-Sunday)
  bool _isSameWeek(DateTime date1, DateTime date2) {
    final monday1 = _getMondayOfWeek(date1);
    final monday2 = _getMondayOfWeek(date2);
    
    return monday1.year == monday2.year &&
           monday1.month == monday2.month &&
           monday1.day == monday2.day;
  }

  /// Get the Monday of the week containing the given date
  DateTime _getMondayOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(
      Duration(days: daysFromMonday),
    );
  }

  /// Add XP and update weekly total
  Future<void> addXP(int amount) async {
    await checkAndResetWeek(); // Ensure week is current
    
    final profileNotifier = ref.read(userProfileProvider.notifier);
    final profile = await ref.read(userProfileProvider.future);
    
    if (profile == null) return;

    final newWeeklyXP = profile.weeklyXP + amount;
    final newTotalXP = profile.totalXp + amount;

    // Check if XP crossed league threshold
    final newLeague = _calculateLeagueFromXP(newWeeklyXP);

    await profileNotifier.updateProfile(
      profile.copyWith(
        weeklyXP: newWeeklyXP,
        totalXp: newTotalXP,
        league: newLeague,
      ),
    );
  }

  /// Determine league based on weekly XP
  League _calculateLeagueFromXP(int weeklyXP) {
    if (weeklyXP >= League.diamond.minWeeklyXP) return League.diamond;
    if (weeklyXP >= League.gold.minWeeklyXP) return League.gold;
    if (weeklyXP >= League.silver.minWeeklyXP) return League.silver;
    return League.bronze;
  }
}
