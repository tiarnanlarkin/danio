// R-058: Split from user_profile_provider.dart — derived providers and value types.
// Core notifier is in user_profile_notifier.dart.
// user_profile_provider.dart is a barrel that re-exports both.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/daily_goal.dart';
import 'user_profile_notifier.dart';

/// Provider to check if onboarding is needed
final needsOnboardingProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.when(
    loading: () => false, // Don't redirect while loading
    error: (_, __) => true, // Show onboarding on error
    data: (p) => p == null, // Need onboarding if no profile
  );
});

/// Provider for learning progress stats
final learningStatsProvider = Provider<LearningStats?>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return null;

  return LearningStats(
    totalXp: profile.totalXp,
    currentLevel: profile.currentLevel,
    levelTitle: profile.levelTitle,
    levelProgress: profile.levelProgress,
    xpToNextLevel: profile.xpToNextLevel,
    currentStreak: profile.currentStreak,
    longestStreak: profile.longestStreak,
    lessonsCompleted: profile.completedLessons.length,
    achievementsUnlocked: profile.achievements.length,
  );
});

/// Provider for today's daily goal
final todaysDailyGoalProvider = Provider<DailyGoal?>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return null;

  return DailyGoal.today(
    dailyXpGoal: profile.dailyXpGoal,
    dailyXpHistory: profile.dailyXpHistory,
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
