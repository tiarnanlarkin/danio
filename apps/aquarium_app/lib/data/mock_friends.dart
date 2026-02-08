/// Mock friends data for demonstration and testing
/// Generates realistic friend profiles with varied progress levels
library;

import 'dart:math';
import '../models/social.dart';

/// Generate mock friends with diverse stats and activity levels
List<Friend> generateMockFriends({int count = 15}) {
  final random = Random();
  final now = DateTime.now();

  final mockProfiles = [
    // (username, displayName, emoji, xp, streak, longestStreak, level, levelNum)
    ('aqua_explorer', 'Alex Rivers', '🐠', 850, 12, 25, 'Hobbyist', 3),
    ('fish_whisperer', 'Jordan Lake', '🦈', 1200, 7, 30, 'Aquarist', 4),
    ('tank_master', 'Sam Ocean', '🐡', 2100, 45, 60, 'Master', 6),
    ('reef_keeper', 'Morgan Tide', '🪸', 650, 3, 15, 'Novice', 2),
    ('planted_pro', 'Taylor Green', '🌿', 1500, 21, 35, 'Expert', 5),
    ('cichlid_lover', 'Casey Stone', '🐟', 420, 5, 12, 'Hobbyist', 3),
    ('betta_buddy', 'Riley Finn', '🎏', 980, 14, 18, 'Aquarist', 4),
    ('guppy_guru', 'Avery Brook', '🐠', 1800, 28, 42, 'Master', 6),
    ('tetra_fan', 'Quinn Wave', '🐟', 550, 0, 8, 'Novice', 2),
    ('coral_crafter', 'Reese Marine', '🪸', 2500, 53, 70, 'Guru', 7),
    ('shrimp_squad', 'Dakota Shell', '🦐', 720, 9, 20, 'Hobbyist', 3),
    ('algae_hunter', 'Skyler Clean', '🧹', 390, 2, 10, 'Novice', 2),
    ('freshwater_pro', 'Parker Flow', '💧', 1650, 19, 28, 'Expert', 5),
    ('nano_tanker', 'Cameron Mini', '🔬', 880, 11, 16, 'Aquarist', 4),
    ('aquascape_artist', 'Drew Design', '🎨', 1950, 33, 48, 'Master', 6),
  ];

  final selectedProfiles = mockProfiles.take(count).toList();

  return selectedProfiles.asMap().entries.map((entry) {
    final index = entry.key;
    final data = entry.value;
    final (username, displayName, emoji, xp, streak, longestStreak, level, levelNum) = data;

    // Vary last active times realistically
    final lastActive = _generateLastActive(index, random, now);

    // Some are "online" (first 3 friends, 50% chance)
    final isOnline = index < 3 && random.nextBool();

    // Random friendship duration (1 week to 1 year ago)
    final friendsSince = now.subtract(Duration(days: 7 + random.nextInt(358)));

    // Random achievement count (3-17)
    final achievementCount = random.nextInt(15) + 3;

    // Generate random achievement IDs
    final achievementIds = _generateAchievementIds(achievementCount, random);

    return Friend(
      id: 'friend_$index',
      username: username,
      displayName: displayName,
      avatarEmoji: emoji,
      totalXp: xp,
      currentStreak: streak,
      longestStreak: longestStreak,
      levelTitle: level,
      currentLevel: levelNum,
      friendsSince: friendsSince,
      lastActiveDate: lastActive,
      isOnline: isOnline,
      achievements: achievementIds,
      totalAchievements: achievementCount,
    );
  }).toList();
}

/// Generate mock friend activities from a list of friends
List<FriendActivity> generateMockActivities(List<Friend> friends, {int activitiesPerFriend = 4}) {
  if (friends.isEmpty) return [];

  final random = Random();
  final now = DateTime.now();
  final activities = <FriendActivity>[];

  for (final friend in friends) {
    // Generate 3-5 activities per friend
    final activityCount = 3 + random.nextInt(3);

    for (int i = 0; i < activityCount; i++) {
      // Spread activities over last 7 days
      final timestamp = now.subtract(Duration(
        hours: random.nextInt(168), // 7 days = 168 hours
        minutes: random.nextInt(60),
      ));

      // Random activity type
      final activityType = FriendActivityType.values[
        random.nextInt(FriendActivityType.values.length)
      ];

      final (description, xpEarned) = _generateActivityDetails(activityType, random);

      activities.add(FriendActivity(
        id: 'activity_${friend.id}_${timestamp.millisecondsSinceEpoch}_$i',
        friendId: friend.id,
        friendUsername: friend.username,
        friendDisplayName: friend.displayName,
        friendAvatarEmoji: friend.avatarEmoji,
        type: activityType,
        description: description,
        xpEarned: xpEarned,
        timestamp: timestamp,
      ));
    }
  }

  // Sort by timestamp (most recent first)
  activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return activities;
}

/// Generate mock friend requests
List<FriendRequest> generateMockFriendRequests({
  required String currentUserId,
  int pendingCount = 2,
}) {
  final random = Random();
  final now = DateTime.now();
  final requests = <FriendRequest>[];

  final potentialFriends = [
    ('water_wizard', 'Water Wizard', '🧙'),
    ('fish_doctor', 'Dr. Finley', '🩺'),
    ('plant_master', 'Planty McPlantface', '🌱'),
    ('shrimp_keeper', 'Shrimp Lover', '🦐'),
    ('reef_boss', 'Reef Commander', '🪸'),
  ];

  for (int i = 0; i < pendingCount && i < potentialFriends.length; i++) {
    final (username, displayName, emoji) = potentialFriends[i];
    final createdAt = now.subtract(Duration(hours: random.nextInt(48)));

    requests.add(FriendRequest(
      id: 'request_$i',
      fromUserId: 'user_$i',
      fromUsername: username,
      fromDisplayName: displayName,
      fromAvatarEmoji: emoji,
      toUserId: currentUserId,
      toUsername: 'you',
      status: FriendRequestStatus.pending,
      createdAt: createdAt,
      message: i == 0 ? 'Hey! Let\'s be aquarium buddies!' : null,
    ));
  }

  return requests;
}

// ============================================================================
// Private Helper Functions
// ============================================================================

/// Generate realistic last active time based on friend index
DateTime _generateLastActive(int index, Random random, DateTime now) {
  if (index < 5) {
    // First 5 friends: very recent (0-12 hours ago)
    return now.subtract(Duration(hours: random.nextInt(12)));
  } else if (index < 10) {
    // Next 5 friends: recent (12-48 hours ago)
    return now.subtract(Duration(hours: 12 + random.nextInt(36)));
  } else {
    // Remaining friends: less active (2-9 days ago)
    return now.subtract(Duration(days: 2 + random.nextInt(7)));
  }
}

/// Generate random achievement IDs
List<String> _generateAchievementIds(int count, Random random) {
  const achievementPool = [
    'first_tank',
    'water_wizard',
    'fish_friend',
    'plant_parent',
    'streak_master',
    'early_bird',
    'night_owl',
    'community_helper',
    'lesson_complete_10',
    'lesson_complete_25',
    'lesson_complete_50',
    'xp_milestone_500',
    'xp_milestone_1000',
    'xp_milestone_2000',
    'streak_7',
    'streak_30',
    'streak_100',
  ];

  final shuffled = List<String>.from(achievementPool)..shuffle(random);
  return shuffled.take(count.clamp(0, achievementPool.length)).toList();
}

/// Generate activity description and XP based on type
(String, int?) _generateActivityDetails(FriendActivityType type, Random random) {
  switch (type) {
    case FriendActivityType.levelUp:
      final level = random.nextInt(7) + 1;
      return ('Reached Level $level', level * 50);

    case FriendActivityType.achievementUnlocked:
      const achievements = [
        'First Tank',
        'Water Wizard',
        'Fish Friend',
        'Plant Parent',
        'Streak Master',
        'Community Helper',
        'Early Bird',
        'Night Owl',
      ];
      final achievement = achievements[random.nextInt(achievements.length)];
      return (achievement, 100);

    case FriendActivityType.streakMilestone:
      const milestones = [7, 14, 30, 60, 100];
      final milestone = milestones[random.nextInt(milestones.length)];
      return ('$milestone day streak!', milestone);

    case FriendActivityType.lessonCompleted:
      const lessons = [
        'Water Chemistry',
        'Nitrogen Cycle',
        'Fish Compatibility',
        'Plant Care',
        'Filtration Basics',
        'Feeding Guide',
        'Disease Prevention',
        'Aquascaping 101',
      ];
      final lesson = lessons[random.nextInt(lessons.length)];
      return (lesson, 50);

    case FriendActivityType.tankCreated:
      const tankTypes = [
        'Community',
        'Planted',
        'Reef',
        'Nano',
        'Biotope',
        'Dutch Style',
        'Iwagumi',
      ];
      final tankType = tankTypes[random.nextInt(tankTypes.length)];
      return ('$tankType Tank', 25);

    case FriendActivityType.badgeEarned:
      const badges = [
        'Water Tester',
        'Early Bird',
        'Night Owl',
        'Streak Keeper',
        'Social Butterfly',
        'Knowledge Seeker',
      ];
      final badge = badges[random.nextInt(badges.length)];
      return (badge, 75);
  }
}

/// Create a new friend from username (for add friend feature)
Friend createMockFriend({
  required String username,
  String? displayName,
  String? emoji,
}) {
  final random = Random();
  final now = DateTime.now();

  return Friend(
    id: 'friend_${DateTime.now().millisecondsSinceEpoch}',
    username: username,
    displayName: displayName ?? username.replaceAll('_', ' ').titleCase(),
    avatarEmoji: emoji ?? _getRandomEmoji(random),
    totalXp: random.nextInt(2000) + 100,
    currentStreak: random.nextInt(30),
    longestStreak: random.nextInt(60) + 10,
    levelTitle: _getRandomLevel(random),
    currentLevel: random.nextInt(7) + 1,
    friendsSince: now,
    lastActiveDate: now.subtract(Duration(hours: random.nextInt(48))),
    isOnline: random.nextDouble() < 0.3, // 30% chance online
    achievements: _generateAchievementIds(random.nextInt(10) + 5, random),
    totalAchievements: random.nextInt(15) + 5,
  );
}

// ============================================================================
// Utility Functions
// ============================================================================

String _getRandomEmoji(Random random) {
  const emojis = [
    '🐠', '🐡', '🐟', '🦈', '🐙', '🦑', '🦞', '🦀', '🦐', '🐚',
    '🪸', '🌊', '🐬', '🐳', '🐋', '🦭', '🦦', '🪼', '🐢', '🦎',
  ];
  return emojis[random.nextInt(emojis.length)];
}

String _getRandomLevel(Random random) {
  const levels = ['Beginner', 'Novice', 'Hobbyist', 'Aquarist', 'Expert', 'Master', 'Guru'];
  return levels[random.nextInt(levels.length)];
}

// String extension for title case
extension StringExtension on String {
  String titleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}
