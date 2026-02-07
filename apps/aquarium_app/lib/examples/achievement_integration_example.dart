/// Achievement Integration Example
/// Shows how to integrate achievements into existing app flows
library;


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/achievement_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/achievement_service.dart';
import '../widgets/achievement_notification.dart';

/// Example: Check achievements after completing a lesson
class LessonCompletionExample {
  static Future<void> onLessonCompleted({
    required BuildContext context,
    required WidgetRef ref,
    required String lessonId,
    required int score,
    required int durationSeconds,
  }) async {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile == null) return;

    // Calculate stats
    final lessonsCompleted = userProfile.completedLessons.length + 1;
    final isPerfect = score == 100;
    final perfectScores = _countPerfectScores(userProfile) + (isPerfect ? 1 : 0);
    
    // Get today's lesson count
    final today = DateTime.now();
    final todayLessons = _getTodayLessonCount(userProfile) + 1;

    // Get all completed lesson IDs
    final completedLessonIds = [...userProfile.completedLessons, lessonId];

    // Check achievements
    final achievementChecker = ref.read(achievementCheckerProvider);
    final newAchievements = await achievementChecker.checkAfterLesson(
      lessonsCompleted: lessonsCompleted,
      currentStreak: userProfile.currentStreak,
      totalXp: userProfile.totalXp,
      perfectScores: perfectScores,
      lessonCompletedAt: DateTime.now(),
      lessonDuration: durationSeconds,
      lessonScore: score,
      todayLessonsCompleted: todayLessons,
      completedLessonIds: completedLessonIds,
    );

    // Show notifications for newly unlocked achievements
    if (context.mounted) {
      for (final result in newAchievements.where((r) => r.wasJustUnlocked)) {
        await Future.delayed(const Duration(milliseconds: 500));
        AchievementNotification.show(
          context,
          result.achievement,
          result.xpAwarded,
        );
      }
    }
  }

  static int _countPerfectScores(dynamic userProfile) {
    // Implementation would count perfect scores from lesson progress
    // This is a placeholder
    return 0;
  }

  static int _getTodayLessonCount(dynamic userProfile) {
    // Implementation would count today's lessons from dailyXpHistory
    // This is a placeholder
    return 0;
  }
}

/// Example: Check achievements after reading daily tip
class DailyTipExample {
  static Future<void> onDailyTipRead({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    // Track daily tip reading (would need to add this to UserProfile)
    final achievementChecker = ref.read(achievementCheckerProvider);
    
    // For this example, assume we're tracking tips read in a separate counter
    const tipsRead = 10; // Would come from actual tracking
    
    final newAchievements = await achievementChecker.checkAfterDailyTip(
      dailyTipsRead: tipsRead,
    );

    // Show notifications
    if (context.mounted) {
      for (final result in newAchievements.where((r) => r.wasJustUnlocked)) {
        AchievementNotification.show(
          context,
          result.achievement,
          result.xpAwarded,
        );
      }
    }
  }
}

/// Example: Check achievements after practice session
class PracticeSessionExample {
  static Future<void> onPracticeCompleted({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final achievementChecker = ref.read(achievementCheckerProvider);
    
    // Track practice sessions (would need to add this to UserProfile)
    const practiceSessions = 10; // Would come from actual tracking
    
    final newAchievements = await achievementChecker.checkAfterPractice(
      practiceSessions: practiceSessions,
    );

    // Show notifications
    if (context.mounted) {
      for (final result in newAchievements.where((r) => r.wasJustUnlocked)) {
        AchievementNotification.show(
          context,
          result.achievement,
          result.xpAwarded,
        );
      }
    }
  }
}

/// Example: Check achievements after adding friend
class FriendAddExample {
  static Future<void> onFriendAdded({
    required BuildContext context,
    required WidgetRef ref,
    required int totalFriends,
  }) async {
    final achievementChecker = ref.read(achievementCheckerProvider);
    
    final newAchievements = await achievementChecker.checkAfterFriendAdded(
      friendsCount: totalFriends,
    );

    // Show notifications
    if (context.mounted) {
      for (final result in newAchievements.where((r) => r.wasJustUnlocked)) {
        AchievementNotification.show(
          context,
          result.achievement,
          result.xpAwarded,
        );
      }
    }
  }
}

/// Example: Check streak achievements daily
class StreakCheckExample {
  static Future<void> checkStreakAchievements({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final achievementChecker = ref.read(achievementCheckerProvider);
    
    final newAchievements = await achievementChecker.checkStreakAchievements();

    // Show notifications
    if (context.mounted) {
      for (final result in newAchievements.where((r) => r.wasJustUnlocked)) {
        AchievementNotification.show(
          context,
          result.achievement,
          result.xpAwarded,
        );
      }
    }
  }
}

/// Example: Widget that shows achievement progress in UI
class AchievementProgressWidget extends ConsumerWidget {
  const AchievementProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionPercent = ref.watch(achievementCompletionProvider);
    final progressMap = ref.watch(achievementProgressProvider);
    
    final unlockedCount = progressMap.values.where((p) => p.isUnlocked).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🏆 Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(completionPercent * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completionPercent,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$unlockedCount unlocked',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example: How to add achievements screen to navigation
/// 
/// In your router configuration (go_router):
/// 
/// ```dart
/// GoRoute(
///   path: '/achievements',
///   name: 'achievements',
///   builder: (context, state) => const AchievementsScreen(),
/// ),
/// ```
/// 
/// Then navigate with:
/// ```dart
/// context.go('/achievements');
/// // or
/// context.pushNamed('achievements');
/// ```

/// Example: Add achievement button to app bar
/// 
/// ```dart
/// AppBar(
///   title: Text('Home'),
///   actions: [
///     IconButton(
///       icon: Stack(
///         children: [
///           Icon(Icons.emoji_events),
///           // Optional: Show badge with new achievements count
///           Positioned(
///             right: 0,
///             top: 0,
///             child: Container(
///               padding: EdgeInsets.all(2),
///               decoration: BoxDecoration(
///                 color: Colors.red,
///                 shape: BoxShape.circle,
///               ),
///               child: Text(
///                 '3',
///                 style: TextStyle(fontSize: 10, color: Colors.white),
///               ),
///             ),
///           ),
///         ],
///       ),
///       onPressed: () => context.pushNamed('achievements'),
///     ),
///   ],
/// ),
/// ```

/// Example: Comprehensive achievement check after any XP-earning activity
class ComprehensiveAchievementCheck {
  static Future<void> checkAll({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile == null) return;

    final achievementChecker = ref.read(achievementCheckerProvider);

    // Build comprehensive stats
    final stats = AchievementStats(
      lessonsCompleted: userProfile.completedLessons.length,
      currentStreak: userProfile.currentStreak,
      totalXp: userProfile.totalXp,
      hasCompletedPlacementTest: userProfile.hasCompletedPlacementTest,
      // Add more stats as needed
    );

    final newAchievements = await achievementChecker.checkAllAchievements(
      stats: stats,
    );

    // Show notifications
    if (context.mounted) {
      for (final result in newAchievements.where((r) => r.wasJustUnlocked)) {
        await Future.delayed(const Duration(milliseconds: 500));
        AchievementNotification.show(
          context,
          result.achievement,
          result.xpAwarded,
        );
      }
    }
  }
}
