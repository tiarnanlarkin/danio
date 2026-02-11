/// Achievement provider - Manages achievement state and checking
/// Integrates with user profile to track and unlock achievements
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievements.dart';
import '../models/gem_economy.dart';
import '../models/gem_transaction.dart';
import '../data/achievements.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';
import '../widgets/achievement_unlocked_dialog.dart';
import '../main.dart'; // For navigatorKey
import 'user_profile_provider.dart';
import 'gems_provider.dart';

/// Provider for achievement progress map
final achievementProgressProvider =
    StateNotifierProvider<
      AchievementProgressNotifier,
      Map<String, AchievementProgress>
    >((ref) {
      return AchievementProgressNotifier(ref);
    });

class AchievementProgressNotifier
    extends StateNotifier<Map<String, AchievementProgress>> {
  AchievementProgressNotifier(this.ref) : super({}) {
    _load();
  }

  final Ref ref;
  static const _key = 'achievement_progress';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);

      if (json != null) {
        final Map<String, dynamic> decoded = jsonDecode(json);
        final Map<String, AchievementProgress> progressMap = {};

        decoded.forEach((key, value) {
          progressMap[key] = AchievementProgress.fromJson(value);
        });

        state = progressMap;
      }
    } catch (e, st) {
      // Log error but start with empty map to not block app
      debugPrint('Error loading achievement progress: $e');
      debugPrint('Stack trace: $st');
      state = {};
      // Rethrow to surface the error
      rethrow;
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toSave = {};

      state.forEach((key, value) {
        toSave[key] = value.toJson();
      });

      await prefs.setString(_key, jsonEncode(toSave));
    } catch (e) {
      throw Exception('Failed to save achievement progress: $e');
    }
  }

  /// Update progress for a single achievement
  /// Will throw exception on failure - does not fail silently
  Future<void> updateProgress(
    String achievementId,
    AchievementProgress progress,
  ) async {
    try {
      state = {...state, achievementId: progress};
      await _save();
    } catch (e, st) {
      // Log the error with full context
      debugPrint(
        'ACHIEVEMENT ERROR: Failed to update progress for $achievementId',
      );
      debugPrint('Error: $e');
      debugPrint('Stack trace: $st');
      rethrow; // Never fail silently
    }
  }

  /// Update multiple achievements at once
  /// Will throw exception on failure - does not fail silently
  Future<void> updateMultiple(Map<String, AchievementProgress> updates) async {
    try {
      state = {...state, ...updates};
      await _save();
    } catch (e, st) {
      // Log the error with full context
      debugPrint('ACHIEVEMENT ERROR: Failed to update multiple achievements');
      debugPrint('Achievement IDs: ${updates.keys.join(", ")}');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $st');
      rethrow; // Never fail silently
    }
  }

  /// Reset all progress (for testing or reset functionality)
  Future<void> resetAll() async {
    state = {};
    await _save();
  }
}

/// Provider for checking achievements
final achievementCheckerProvider = Provider<AchievementChecker>((ref) {
  return AchievementChecker(ref);
});

class AchievementChecker {
  AchievementChecker(this.ref);

  final Ref ref;

  /// Check achievements and return newly unlocked ones
  /// Will throw exception on failure - does not fail silently
  Future<List<AchievementUnlockResult>> checkAchievements(
    AchievementStats stats,
  ) async {
    try {
      final userProfileAsync = ref.read(userProfileProvider);
      final userProfile = userProfileAsync.value;

      if (userProfile == null) {
        throw Exception('Cannot check achievements: User profile not loaded');
      }

      final progressMap = ref.read(achievementProgressProvider);

      final results = AchievementService.checkAchievements(
        userProfile: userProfile,
        stats: stats,
        progressMap: progressMap,
      );

      // Update progress for all changed achievements
      if (results.isNotEmpty) {
        final Map<String, AchievementProgress> updates = {};

        for (final result in results) {
          updates[result.achievement.id] = result.progress;
        }

        await ref
            .read(achievementProgressProvider.notifier)
            .updateMultiple(updates);

        // Update user profile with newly unlocked achievement IDs and award XP
        final newlyUnlocked = results.where((r) => r.wasJustUnlocked).toList();

        if (newlyUnlocked.isNotEmpty) {
          final newAchievementIds = newlyUnlocked
              .map((r) => r.achievement.id)
              .toList();
          final totalXpAwarded = newlyUnlocked.fold<int>(
            0,
            (sum, r) => sum + r.xpAwarded,
          );

          // Update user profile
          final currentAchievements = userProfile.achievements;
          final updatedAchievements = [
            ...currentAchievements,
            ...newAchievementIds,
          ];

          await ref
              .read(userProfileProvider.notifier)
              .updateAchievements(
                achievements: updatedAchievements,
                xpToAdd: totalXpAwarded,
              );

          // Award gems and show celebration for each unlocked achievement
          for (final result in newlyUnlocked) {
            final gemReward = _getGemReward(result.achievement.rarity);

            // Award gems
            try {
              await ref
                  .read(gemsProvider.notifier)
                  .addGems(
                    amount: gemReward,
                    reason: GemEarnReason.achievementUnlock,
                    customReason: result.achievement.name,
                  );
            } catch (e) {
              debugPrint('Warning: Failed to award gems for achievement: $e');
              // Continue even if gem award fails
            }

            // Show celebration dialog
            final context = navigatorKey.currentContext;
            if (context != null && context.mounted) {
              await showAchievementUnlockedDialog(
                context: context,
                achievement: result.achievement,
                xpAwarded: result.xpAwarded,
              );
            }

            // Send notification
            try {
              await NotificationService().sendAchievementNotification(
                achievement: result.achievement,
                xpAwarded: result.xpAwarded,
                gemsAwarded: gemReward,
              );
            } catch (e) {
              debugPrint(
                'Warning: Failed to send achievement notification: $e',
              );
              // Continue even if notification fails
            }
          }
        }
      }

      return results;
    } catch (e, st) {
      // Log comprehensive error information
      debugPrint('ACHIEVEMENT ERROR: Failed to check achievements');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $st');
      rethrow; // Never fail silently
    }
  }

  /// Check after lesson completion
  Future<List<AchievementUnlockResult>> checkAfterLesson({
    required int lessonsCompleted,
    required int currentStreak,
    required int totalXp,
    required int perfectScores,
    required DateTime lessonCompletedAt,
    required int lessonDuration,
    required int lessonScore,
    required int todayLessonsCompleted,
    required List<String> completedLessonIds,
  }) async {
    final userProfileAsync = ref.read(userProfileProvider);
    final stats = AchievementStats(
      lessonsCompleted: lessonsCompleted,
      currentStreak: currentStreak,
      totalXp: totalXp,
      perfectScores: perfectScores,
      lastLessonCompletedAt: lessonCompletedAt,
      lastLessonDuration: lessonDuration,
      lastLessonScore: lessonScore,
      todayLessonsCompleted: todayLessonsCompleted,
      completedLessonIds: completedLessonIds,
      hasCompletedPlacementTest:
          userProfileAsync.value?.hasCompletedPlacementTest ?? false,
    );

    return await checkAchievements(stats);
  }

  /// Check after daily tip read
  Future<List<AchievementUnlockResult>> checkAfterDailyTip({
    required int dailyTipsRead,
  }) async {
    final userProfileAsync = ref.read(userProfileProvider);
    final stats = AchievementStats(
      dailyTipsRead: dailyTipsRead,
      totalXp: userProfileAsync.value?.totalXp ?? 0,
      currentStreak: userProfileAsync.value?.currentStreak ?? 0,
      hasCompletedPlacementTest:
          userProfileAsync.value?.hasCompletedPlacementTest ?? false,
    );

    return await checkAchievements(stats);
  }

  /// Check after practice session
  Future<List<AchievementUnlockResult>> checkAfterPractice({
    required int practiceSessions,
  }) async {
    final userProfileAsync = ref.read(userProfileProvider);
    final stats = AchievementStats(
      practiceSessions: practiceSessions,
      totalXp: userProfileAsync.value?.totalXp ?? 0,
      currentStreak: userProfileAsync.value?.currentStreak ?? 0,
      hasCompletedPlacementTest:
          userProfileAsync.value?.hasCompletedPlacementTest ?? false,
    );

    return await checkAchievements(stats);
  }

  /// Check after friend added
  Future<List<AchievementUnlockResult>> checkAfterFriendAdded({
    required int friendsCount,
  }) async {
    final userProfileAsync = ref.read(userProfileProvider);
    final stats = AchievementStats(
      friendsCount: friendsCount,
      totalXp: userProfileAsync.value?.totalXp ?? 0,
      currentStreak: userProfileAsync.value?.currentStreak ?? 0,
      hasCompletedPlacementTest:
          userProfileAsync.value?.hasCompletedPlacementTest ?? false,
    );

    return await checkAchievements(stats);
  }

  /// Check after shop visit
  Future<List<AchievementUnlockResult>> checkAfterShopVisit({
    required int shopVisits,
  }) async {
    final userProfileAsync = ref.read(userProfileProvider);
    final stats = AchievementStats(
      shopVisits: shopVisits,
      totalXp: userProfileAsync.value?.totalXp ?? 0,
      currentStreak: userProfileAsync.value?.currentStreak ?? 0,
      hasCompletedPlacementTest:
          userProfileAsync.value?.hasCompletedPlacementTest ?? false,
    );

    return await checkAchievements(stats);
  }

  /// Check streak-related achievements
  Future<List<AchievementUnlockResult>> checkStreakAchievements() async {
    final userProfileAsync = ref.read(userProfileProvider);
    final userProfile = userProfileAsync.value;

    if (userProfile == null) return [];

    final stats = AchievementStats(
      currentStreak: userProfile.currentStreak,
      totalXp: userProfile.totalXp,
      hasCompletedPlacementTest: userProfile.hasCompletedPlacementTest,
    );

    return await checkAchievements(stats);
  }

  /// Check all achievements with full stats
  Future<List<AchievementUnlockResult>> checkAllAchievements({
    required AchievementStats stats,
  }) async {
    return await checkAchievements(stats);
  }

  /// Get gem reward based on achievement rarity
  int _getGemReward(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.bronze:
        return GemRewards.achievementBronze;
      case AchievementRarity.silver:
        return GemRewards.achievementSilver;
      case AchievementRarity.gold:
        return GemRewards.achievementGold;
      case AchievementRarity.platinum:
        return GemRewards.achievementPlatinum;
    }
  }
}

/// Provider for filtered achievements
final filteredAchievementsProvider =
    Provider.family<List<Achievement>, AchievementFilter>((ref, filter) {
      final progressMap = ref.watch(achievementProgressProvider);

      List<Achievement> achievements = AchievementDefinitions.all;

      // Filter by lock status
      if (filter.showUnlockedOnly) {
        achievements = achievements.where((a) {
          final progress = progressMap[a.id];
          return progress?.isUnlocked ?? false;
        }).toList();
      } else if (filter.showLockedOnly) {
        achievements = achievements.where((a) {
          final progress = progressMap[a.id];
          return !(progress?.isUnlocked ?? false);
        }).toList();
      }

      // Filter by category
      if (filter.category != null) {
        achievements = achievements
            .where((a) => a.category == filter.category)
            .toList();
      }

      // Filter by rarity
      if (filter.rarity != null) {
        achievements = achievements
            .where((a) => a.rarity == filter.rarity)
            .toList();
      }

      // Sort
      switch (filter.sortBy) {
        case AchievementSortBy.rarity:
          achievements.sort((a, b) => b.rarity.index.compareTo(a.rarity.index));
          break;
        case AchievementSortBy.dateUnlocked:
          achievements.sort((a, b) {
            final aProgress = progressMap[a.id];
            final bProgress = progressMap[b.id];
            final aDate = aProgress?.unlockedAt;
            final bDate = bProgress?.unlockedAt;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });
          break;
        case AchievementSortBy.progress:
          achievements.sort((a, b) {
            final aProgress = progressMap[a.id];
            final bProgress = progressMap[b.id];
            final aPercent = aProgress?.getProgress(a.targetCount) ?? 0.0;
            final bPercent = bProgress?.getProgress(b.targetCount) ?? 0.0;
            return bPercent.compareTo(aPercent);
          });
          break;
        case AchievementSortBy.name:
          achievements.sort((a, b) => a.name.compareTo(b.name));
          break;
      }

      return achievements;
    });

/// Filter configuration for achievements
class AchievementFilter {
  final bool showUnlockedOnly;
  final bool showLockedOnly;
  final AchievementCategory? category;
  final AchievementRarity? rarity;
  final AchievementSortBy sortBy;

  const AchievementFilter({
    this.showUnlockedOnly = false,
    this.showLockedOnly = false,
    this.category,
    this.rarity,
    this.sortBy = AchievementSortBy.rarity,
  });
}

enum AchievementSortBy { rarity, dateUnlocked, progress, name }

/// Provider for completion percentage
final achievementCompletionProvider = Provider<double>((ref) {
  final progressMap = ref.watch(achievementProgressProvider);
  final unlockedCount = progressMap.values.where((p) => p.isUnlocked).length;
  return unlockedCount / AchievementDefinitions.all.length;
});
