// R-058: Split from user_profile_provider.dart — derived providers and value types.
// Core notifier is in user_profile_notifier.dart.
// user_profile_provider.dart is a barrel that re-exports both.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/daily_goal.dart';
import 'user_profile_notifier.dart';
import 'inventory_provider.dart';

/// Provider to check if onboarding is needed
final needsOnboardingProvider = Provider<bool>((ref) {
  // Use .select() to avoid rebuilding on unrelated profile changes
  final isLoading = ref.watch(userProfileProvider.select((a) => a.isLoading));
  if (isLoading) return false;
  final hasError = ref.watch(userProfileProvider.select((a) => a.hasError));
  if (hasError) return true;
  final profileIsNull = ref.watch(
    userProfileProvider.select((a) => a.value == null),
  );
  return profileIsNull;
});

/// Provider for learning progress stats
final learningStatsProvider = Provider<LearningStats?>((ref) {
  // Use .select() to only rebuild when learning-relevant fields change
  final totalXp = ref.watch(userProfileProvider.select((a) => a.value?.totalXp));
  if (totalXp == null) return null;
  final currentLevel = ref.watch(userProfileProvider.select((a) => a.value?.currentLevel ?? 1));
  final levelTitle = ref.watch(userProfileProvider.select((a) => a.value?.levelTitle ?? ''));
  final levelProgress = ref.watch(userProfileProvider.select((a) => a.value?.levelProgress ?? 0.0));
  final xpToNextLevel = ref.watch(userProfileProvider.select((a) => a.value?.xpToNextLevel ?? 0));
  final currentStreak = ref.watch(userProfileProvider.select((a) => a.value?.currentStreak ?? 0));
  final longestStreak = ref.watch(userProfileProvider.select((a) => a.value?.longestStreak ?? 0));
  final lessonsCompleted = ref.watch(userProfileProvider.select((a) => a.value?.completedLessons.length ?? 0));
  final achievementsUnlocked = ref.watch(userProfileProvider.select((a) => a.value?.achievements.length ?? 0));

  return LearningStats(
    totalXp: totalXp,
    currentLevel: currentLevel,
    levelTitle: levelTitle,
    levelProgress: levelProgress,
    xpToNextLevel: xpToNextLevel,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    lessonsCompleted: lessonsCompleted,
    achievementsUnlocked: achievementsUnlocked,
  );
});

/// Provider for today's daily goal.
///
/// FB-H3: When the Weekend Amulet is active and today is Saturday or Sunday,
/// the daily XP target is halved (minimum 5 XP) to give users a meaningful
/// break while still encouraging light engagement.
final todaysDailyGoalProvider = Provider<DailyGoal?>((ref) {
  // Use .select() to only rebuild when goal-relevant fields change
  final dailyXpGoal = ref.watch(userProfileProvider.select((a) => a.value?.dailyXpGoal));
  if (dailyXpGoal == null) return null;
  final dailyXpHistory = ref.watch(userProfileProvider.select((a) => a.value?.dailyXpHistory));
  if (dailyXpHistory == null) return null;

  // Weekend Amulet: halve the daily goal on Sat/Sun when the item is active.
  final inventory = ref.watch(inventoryProvider);
  final isWeekendAmuletActive = inventory.when(
    loading: () => false,
    error: (_, __) => false,
    data: (items) {
      final item = items.where((i) => i.itemId == 'weekend_amulet').firstOrNull;
      return item != null && item.isActive && !item.isExpired;
    },
  );

  final today = DateTime.now();
  final isWeekend = today.weekday == DateTime.saturday || today.weekday == DateTime.sunday;
  final effectiveGoal = (isWeekendAmuletActive && isWeekend)
      ? (dailyXpGoal ~/ 2).clamp(5, dailyXpGoal)
      : dailyXpGoal;

  return DailyGoal.today(
    dailyXpGoal: effectiveGoal,
    dailyXpHistory: dailyXpHistory,
  );
});

/// Provider for recent daily goals (for streak calendar).
/// Uses select() to only recompute when dailyXpHistory or dailyXpGoal
/// actually change, not on every profile update.
final recentDailyGoalsProvider = Provider<List<DailyGoal>>((ref) {
  final dailyXpHistory = ref.watch(
    userProfileProvider.select((p) => p.value?.dailyXpHistory),
  );
  final dailyXpGoal = ref.watch(
    userProfileProvider.select((p) => p.value?.dailyXpGoal),
  );
  if (dailyXpHistory == null || dailyXpGoal == null) return [];

  return DailyGoal.getRecentDays(
    days: 90, // Last 3 months
    dailyXpGoal: dailyXpGoal,
    dailyXpHistory: dailyXpHistory,
  );
});

class LearningStats {
  final int totalXp;
  final int currentLevel;
  final String levelTitle;
  final double levelProgress;
  final int xpToNextLevel;
  final int currentStreak;
  final int longestStreak;
  final int lessonsCompleted;
  final int achievementsUnlocked;

  const LearningStats({
    required this.totalXp,
    required this.currentLevel,
    required this.levelTitle,
    required this.levelProgress,
    required this.xpToNextLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.lessonsCompleted,
    required this.achievementsUnlocked,
  });
}

/// Level up event data
class LevelUpEvent {
  final int newLevel;
  final String levelTitle;
  final DateTime timestamp;

  const LevelUpEvent({
    required this.newLevel,
    required this.levelTitle,
    required this.timestamp,
  });
}

/// Provider that tracks level changes and emits level-up events
/// Use this in UI widgets to trigger level-up celebrations
final levelUpEventProvider =
    StateNotifierProvider<LevelUpEventNotifier, LevelUpEvent?>((ref) {
      return LevelUpEventNotifier(ref);
    });

class LevelUpEventNotifier extends StateNotifier<LevelUpEvent?> {
  LevelUpEventNotifier(this.ref) : super(null) {
    // Watch for profile changes and detect level ups
    ref.listen<AsyncValue<UserProfile?>>(userProfileProvider, (previous, next) {
      final prevProfile = previous?.value;
      final nextProfile = next.value;

      if (prevProfile != null && nextProfile != null) {
        final prevLevel = prevProfile.currentLevel;
        final nextLevel = nextProfile.currentLevel;

        // Level up detected!
        if (nextLevel > prevLevel) {
          state = LevelUpEvent(
            newLevel: nextLevel,
            levelTitle: nextProfile.levelTitle,
            timestamp: DateTime.now(),
          );
        }
      }
    });
  }

  final Ref ref;

  /// Clear the level up event after it's been handled
  void clearEvent() {
    state = null;
  }

  /// Manually trigger a level up event (for testing)
  void triggerLevelUp(int level, String title) {
    state = LevelUpEvent(
      newLevel: level,
      levelTitle: title,
      timestamp: DateTime.now(),
    );
  }
}
