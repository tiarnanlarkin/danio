import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/tank.dart'; // For TankType enum
import '../models/user_profile.dart';
import '../models/learning.dart';
import '../models/daily_goal.dart';
import '../models/lesson_progress.dart';
import '../models/gem_economy.dart';
import '../models/gem_transaction.dart';
import '../models/leaderboard.dart'; // For League and WeekPeriod
import '../models/shop_item.dart'; // For InventoryItem
import 'gems_provider.dart';

const _uuid = Uuid();

/// Provider for user profile management
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref ref;
  static const _key = 'user_profile';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      
      if (json != null) {
        final profile = UserProfile.fromJson(jsonDecode(json));
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  /// Create initial profile during onboarding
  Future<void> createProfile({
    String? name,
    required ExperienceLevel experienceLevel,
    required TankType primaryTankType,
    required List<UserGoal> goals,
  }) async {
    final now = DateTime.now();
    final profile = UserProfile(
      id: _uuid.v4(),
      name: name,
      experienceLevel: experienceLevel,
      primaryTankType: primaryTankType,
      goals: goals,
      createdAt: now,
      updatedAt: now,
    );
    
    await _save(profile);
    state = AsyncValue.data(profile);
  }

  /// Update profile settings
  Future<void> updateProfile({
    String? name,
    ExperienceLevel? experienceLevel,
    TankType? primaryTankType,
    List<UserGoal>? goals,
    int? dailyXpGoal,
    List<InventoryItem>? inventory,
    bool? dailyTipsEnabled,
    bool? streakRemindersEnabled,
    String? reminderTime,
    String? morningReminderTime,
    String? eveningReminderTime,
    String? nightReminderTime,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      name: name ?? current.name,
      experienceLevel: experienceLevel ?? current.experienceLevel,
      primaryTankType: primaryTankType ?? current.primaryTankType,
      goals: goals ?? current.goals,
      dailyXpGoal: dailyXpGoal ?? current.dailyXpGoal,
      inventory: inventory ?? current.inventory,
      dailyTipsEnabled: dailyTipsEnabled ?? current.dailyTipsEnabled,
      streakRemindersEnabled: streakRemindersEnabled ?? current.streakRemindersEnabled,
      reminderTime: reminderTime ?? current.reminderTime,
      morningReminderTime: morningReminderTime ?? current.morningReminderTime,
      eveningReminderTime: eveningReminderTime ?? current.eveningReminderTime,
      nightReminderTime: nightReminderTime ?? current.nightReminderTime,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);
  }
  
  /// Get today's XP progress
  int getTodayXp() {
    final current = state.value;
    if (current == null) return 0;
    
    final today = _formatDate(DateTime.now());
    return current.dailyXpHistory[today] ?? 0;
  }
  
  /// Format date as YYYY-MM-DD for dailyXpHistory key
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Set daily XP goal (25, 50, 100, or 200)
  Future<void> setDailyGoal(int goal) async {
    await updateProfile(dailyXpGoal: goal);
  }

  /// Award XP and handle streak logic (with streak freeze support)
  Future<void> recordActivity({int xp = 0}) async {
    var current = state.value;
    if (current == null) return;

    // Reset streak freeze weekly if needed
    if (current.shouldResetStreakFreeze) {
      current = current.copyWith(
        hasStreakFreeze: true,
        streakFreezeGrantedDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final now = DateTime.now();
    final today = _normalizeDate(now);
    
    int newStreak = current.currentStreak;
    int longestStreak = current.longestStreak;
    bool usedFreeze = false;

    if (current.lastActivityDate != null) {
      final lastDate = _normalizeDate(current.lastActivityDate!);
      final dayDifference = today.difference(lastDate).inDays;

      if (dayDifference == 0) {
        // Same day - keep current streak, no increment
        newStreak = current.currentStreak;
      } else if (dayDifference == 1) {
        // Consecutive day - increment streak
        newStreak = current.currentStreak + 1;
      } else if (dayDifference == 2 && current.hasStreakFreeze && !current.streakFreezeUsedThisWeek) {
        // 1 day gap + freeze available = use freeze to save streak
        newStreak = current.currentStreak + 1; // Continue streak
        usedFreeze = true;
      } else {
        // Gap in activity - reset streak
        newStreak = 1;
      }
    } else {
      // First activity ever
      newStreak = 1;
    }

    if (newStreak > longestStreak) {
      longestStreak = newStreak;
    }

    // Bonus XP for streak milestones (only when streak increases)
    int bonusXp = 0;
    if (newStreak > current.currentStreak) {
      bonusXp = XpRewards.dailyStreak;
    }
    
    // Update daily XP history
    final todayKey = _formatDate(today);
    final previousTodayXp = current.dailyXpHistory[todayKey] ?? 0;
    final todayXp = previousTodayXp + xp + bonusXp;
    final updatedHistory = {...current.dailyXpHistory, todayKey: todayXp};

    final updated = current.copyWith(
      totalXp: current.totalXp + xp + bonusXp,
      currentStreak: newStreak,
      longestStreak: longestStreak,
      lastActivityDate: now,
      dailyXpHistory: updatedHistory,
      hasStreakFreeze: usedFreeze ? false : current.hasStreakFreeze,
      streakFreezeUsedDate: usedFreeze ? now : current.streakFreezeUsedDate,
      updatedAt: now,
    );

    await _save(updated);
    state = AsyncValue.data(updated);

    // Award gems for milestones
    final gemsNotifier = ref.read(gemsProvider.notifier);

    // Streak milestone gems (7, 14, 30, 50, 100 days)
    if (newStreak > current.currentStreak) {
      final streakGems = GemRewards.getStreakMilestoneReward(newStreak);
      if (streakGems > 0) {
        await gemsNotifier.addGems(
          amount: streakGems,
          reason: GemEarnReason.streakMilestone,
          customReason: '$newStreak day streak!',
        );
      }
    }

    // Daily goal completion gems (first time reaching goal today)
    if (previousTodayXp < current.dailyXpGoal && todayXp >= current.dailyXpGoal) {
      await gemsNotifier.addGems(
        amount: GemRewards.dailyGoalMet,
        reason: GemEarnReason.dailyGoalMet,
      );
    }
  }

  /// Normalize a DateTime to midnight local time for consistent date comparisons
  /// This prevents timezone and DST issues when comparing dates
  DateTime _normalizeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Add XP and update daily progress
  Future<void> addXp(int amount) async {
    if (amount <= 0) return;
    
    final current = state.value;
    if (current == null) return;

    // Check and reset weekly XP if needed
    final currentWeek = WeekPeriod.current();
    final weekStart = current.weekStartDate;
    int weeklyXP = current.weeklyXP;
    DateTime? newWeekStart = weekStart;

    if (weekStart == null || !_isSameWeek(weekStart, currentWeek.start)) {
      // Week changed - reset weekly XP
      weeklyXP = 0;
      newWeekStart = currentWeek.start;
    }

    // Add to weekly XP
    weeklyXP += amount;

    // Determine league based on weekly XP
    final newLeague = _calculateLeagueFromXP(weeklyXP);

    // Update today's XP in history
    final todayKey = getTodayKey();
    final updatedHistory = Map<String, int>.from(current.dailyXpHistory);
    updatedHistory[todayKey] = (updatedHistory[todayKey] ?? 0) + amount;

    final updated = current.copyWith(
      totalXp: current.totalXp + amount,
      weeklyXP: weeklyXP,
      weekStartDate: newWeekStart,
      league: newLeague,
      dailyXpHistory: updatedHistory,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);

    // Record activity for streak tracking
    await recordActivity(xp: 0); // XP already added above
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

  /// Determine league based on weekly XP
  League _calculateLeagueFromXP(int weeklyXP) {
    if (weeklyXP >= League.diamond.minWeeklyXP) return League.diamond;
    if (weeklyXP >= League.gold.minWeeklyXP) return League.gold;
    if (weeklyXP >= League.silver.minWeeklyXP) return League.silver;
    return League.bronze;
  }

  /// Mark a lesson as completed
  Future<void> completeLesson(String lessonId, int xpReward) async {
    final current = state.value;
    if (current == null) return;

    // Don't double-count if already completed
    if (current.completedLessons.contains(lessonId)) return;

    // Create new lesson progress entry
    final now = DateTime.now();
    final progress = LessonProgress(
      lessonId: lessonId,
      completedDate: now,
      lastReviewDate: null,
      reviewCount: 0,
      strength: 100.0,
    );

    // Update lesson progress map
    final updatedProgress = Map<String, LessonProgress>.from(current.lessonProgress);
    updatedProgress[lessonId] = progress;

    // Update today's XP in history
    final todayKey = getTodayKey();
    final updatedHistory = Map<String, int>.from(current.dailyXpHistory);
    updatedHistory[todayKey] = (updatedHistory[todayKey] ?? 0) + xpReward;

    // Track previous level for level-up detection
    final previousLevel = current.currentLevel;

    final updated = current.copyWith(
      completedLessons: [...current.completedLessons, lessonId],
      lessonProgress: updatedProgress,
      totalXp: current.totalXp + xpReward,
      dailyXpHistory: updatedHistory,
      updatedAt: now,
    );

    await _save(updated);
    state = AsyncValue.data(updated);

    // Award gems for lesson completion
    final gemsNotifier = ref.read(gemsProvider.notifier);
    await gemsNotifier.addGems(
      amount: GemRewards.lessonComplete,
      reason: GemEarnReason.lessonComplete,
    );

    // Check for level up and award bonus gems
    if (updated.currentLevel > previousLevel) {
      final levelUpGems = GemRewards.getLevelUpReward(updated.currentLevel);
      await gemsNotifier.addGems(
        amount: levelUpGems,
        reason: GemEarnReason.levelUp,
        customReason: 'Level up to ${updated.levelTitle}',
      );
    }

    // Record activity for streak tracking
    await recordActivity(xp: 0); // XP already added above
  }

  /// Complete placement test and apply results
  Future<void> completePlacementTest({
    required String resultId,
    required List<String> lessonsToSkip,
    required int xpToAward,
  }) async {
    final current = state.value;
    if (current == null) return;

    // Mark lessons as completed (tested out)
    final now = DateTime.now();
    final updatedCompletedLessons = [
      ...current.completedLessons,
      ...lessonsToSkip.where((id) => !current.completedLessons.contains(id)),
    ];

    // Create lesson progress entries for skipped lessons
    final updatedProgress = Map<String, LessonProgress>.from(current.lessonProgress);
    for (final lessonId in lessonsToSkip) {
      if (!updatedProgress.containsKey(lessonId)) {
        updatedProgress[lessonId] = LessonProgress(
          lessonId: lessonId,
          completedDate: now,
          lastReviewDate: null,
          reviewCount: 0,
          strength: 75.0, // Lower strength since they tested out
        );
      }
    }

    // Update today's XP in history
    final todayKey = getTodayKey();
    final updatedHistory = Map<String, int>.from(current.dailyXpHistory);
    updatedHistory[todayKey] = (updatedHistory[todayKey] ?? 0) + xpToAward;

    final updated = current.copyWith(
      hasCompletedPlacementTest: true,
      placementResultId: resultId,
      placementTestDate: now,
      completedLessons: updatedCompletedLessons,
      lessonProgress: updatedProgress,
      totalXp: current.totalXp + xpToAward,
      dailyXpHistory: updatedHistory,
      updatedAt: now,
    );

    await _save(updated);
    state = AsyncValue.data(updated);

    // Award gems for placement test
    final gemsNotifier = ref.read(gemsProvider.notifier);
    await gemsNotifier.addGems(
      amount: GemRewards.placementTest,
      reason: GemEarnReason.placementTest,
    );

    // Record activity for streak tracking
    await recordActivity(xp: 0); // XP already added above
  }

  /// Mark a lesson as reviewed (for spaced repetition)
  Future<void> reviewLesson(String lessonId, int xpReward) async {
    final current = state.value;
    if (current == null) return;

    // Check if lesson exists in progress
    final progress = current.lessonProgress[lessonId];
    if (progress == null) return; // Can't review if never completed

    // Update lesson progress with review
    final updatedProgressEntry = progress.reviewed();
    final updatedProgress = Map<String, LessonProgress>.from(current.lessonProgress);
    updatedProgress[lessonId] = updatedProgressEntry;

    // Update today's XP in history
    final todayKey = getTodayKey();
    final updatedHistory = Map<String, int>.from(current.dailyXpHistory);
    updatedHistory[todayKey] = (updatedHistory[todayKey] ?? 0) + xpReward;

    final now = DateTime.now();
    final updated = current.copyWith(
      lessonProgress: updatedProgress,
      totalXp: current.totalXp + xpReward,
      dailyXpHistory: updatedHistory,
      updatedAt: now,
    );

    await _save(updated);
    state = AsyncValue.data(updated);

    // Award gems for review
    final gemsNotifier = ref.read(gemsProvider.notifier);
    await gemsNotifier.addGems(
      amount: GemRewards.reviewLesson,
      reason: GemEarnReason.lessonComplete,
      customReason: 'Lesson review',
    );

    // Record activity for streak tracking
    await recordActivity(xp: 0); // XP already added above
  }

  /// Award gems for quiz performance
  Future<void> awardQuizGems({required bool isPerfect}) async {
    final gemsNotifier = ref.read(gemsProvider.notifier);
    if (isPerfect) {
      await gemsNotifier.addGems(
        amount: GemRewards.quizPerfect,
        reason: GemEarnReason.quizPerfect,
      );
    } else {
      await gemsNotifier.addGems(
        amount: GemRewards.quizPass,
        reason: GemEarnReason.quizPass,
      );
    }
  }

  /// Get today's date key for dailyXpHistory
  String getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get lessons that need review (strength < 50)
  List<LessonProgress> getLessonsNeedingReview() {
    final current = state.value;
    if (current == null) return [];

    return current.lessonProgress.values
        .where((progress) => progress.needsReview)
        .toList()
      ..sort((a, b) => a.currentStrength.compareTo(b.currentStrength));
  }

  /// Get the 5 weakest lessons for review
  List<LessonProgress> getWeakestLessons({int count = 5}) {
    final needingReview = getLessonsNeedingReview();
    return needingReview.take(count).toList();
  }

  /// Award an achievement
  Future<void> unlockAchievement(String achievementId) async {
    final current = state.value;
    if (current == null) return;

    // Don't double-count
    if (current.achievements.contains(achievementId)) return;

    // Get bonus XP from achievement tier
    final achievement = Achievements.getById(achievementId);
    final bonusXp = achievement?.tier.xpBonus ?? 0;

    final updated = current.copyWith(
      achievements: [...current.achievements, achievementId],
      totalXp: current.totalXp + bonusXp,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);

    // Award gems for achievement
    if (achievement != null) {
      final gemsNotifier = ref.read(gemsProvider.notifier);
      final gemReward = GemRewards.getAchievementReward(achievement.tier);
      await gemsNotifier.addGems(
        amount: gemReward,
        reason: GemEarnReason.achievementUnlock,
        customReason: 'Achievement: ${achievement.title}',
      );
    }
  }

  /// Update achievements list and award XP (for new achievement system)
  Future<void> updateAchievements({
    required List<String> achievements,
    int xpToAdd = 0,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      achievements: achievements,
      totalXp: current.totalXp + xpToAdd,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);
  }

  /// Update hearts count (for hearts/lives system)
  Future<void> updateHearts({
    required int hearts,
    DateTime? lastHeartRefill,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      hearts: hearts,
      lastHeartRefill: lastHeartRefill ?? current.lastHeartRefill,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);
  }

  /// Check if profile exists (for routing)
  bool get hasProfile => state.value != null;

  /// Update story progress
  Future<void> updateStoryProgress({
    required String storyId,
    required Map<String, dynamic> progressData,
    bool isCompleted = false,
    int xpReward = 0,
  }) async {
    final current = state.value;
    if (current == null) return;

    // Update story progress map
    final updatedProgress = Map<String, dynamic>.from(current.storyProgress);
    updatedProgress[storyId] = progressData;

    // Add to completed stories if newly completed
    List<String> completedStories = List.from(current.completedStories);
    bool newlyCompleted = false;
    
    if (isCompleted && !completedStories.contains(storyId)) {
      completedStories.add(storyId);
      newlyCompleted = true;
    }

    // Update profile
    final updated = current.copyWith(
      storyProgress: updatedProgress,
      completedStories: completedStories,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);

    // Award XP if newly completed
    if (newlyCompleted && xpReward > 0) {
      await recordActivity(xp: xpReward);
    }
  }

  /// Reset profile (for testing/debugging)
  Future<void> resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = const AsyncValue.data(null);
  }
}

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

/// Provider for recent daily goals (for streak calendar)
final recentDailyGoalsProvider = Provider<List<DailyGoal>>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return [];

  return DailyGoal.getRecentDays(
    days: 90, // Last 3 months
    dailyXpGoal: profile.dailyXpGoal,
    dailyXpHistory: profile.dailyXpHistory,
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
