import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/learning.dart';

const _uuid = Uuid();

/// Provider for user profile management
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

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
    bool? dailyTipsEnabled,
    bool? streakRemindersEnabled,
    String? reminderTime,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      name: name ?? current.name,
      experienceLevel: experienceLevel ?? current.experienceLevel,
      primaryTankType: primaryTankType ?? current.primaryTankType,
      goals: goals ?? current.goals,
      dailyTipsEnabled: dailyTipsEnabled ?? current.dailyTipsEnabled,
      streakRemindersEnabled: streakRemindersEnabled ?? current.streakRemindersEnabled,
      reminderTime: reminderTime ?? current.reminderTime,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);
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

    final updated = current.copyWith(
      totalXp: current.totalXp + xp + bonusXp,
      currentStreak: newStreak,
      longestStreak: longestStreak,
      lastActivityDate: now,
      hasStreakFreeze: usedFreeze ? false : current.hasStreakFreeze,
      streakFreezeUsedDate: usedFreeze ? now : current.streakFreezeUsedDate,
      updatedAt: now,
    );

    await _save(updated);
    state = AsyncValue.data(updated);
  }

  /// Normalize a DateTime to midnight local time for consistent date comparisons
  /// This prevents timezone and DST issues when comparing dates
  DateTime _normalizeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Add XP without streak update (for lesson completion, etc.)
  Future<void> addXp(int amount) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      totalXp: current.totalXp + amount,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);
  }

  /// Mark a lesson as completed
  Future<void> completeLesson(String lessonId, int xpReward) async {
    final current = state.value;
    if (current == null) return;

    // Don't double-count
    if (current.completedLessons.contains(lessonId)) return;

    final updated = current.copyWith(
      completedLessons: [...current.completedLessons, lessonId],
      totalXp: current.totalXp + xpReward,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);
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
  }

  /// Check if profile exists (for routing)
  bool get hasProfile => state.value != null;

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
