import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend.dart';

/// Provider for friends list
final friendsProvider = StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friend>>>((ref) {
  return FriendsNotifier();
});

/// Provider for friend activities feed
final friendActivitiesProvider = StateNotifierProvider<FriendActivitiesNotifier, AsyncValue<List<FriendActivity>>>((ref) {
  final notifier = FriendActivitiesNotifier();
  
  // Listen to friends changes to regenerate activities
  ref.listen<AsyncValue<List<Friend>>>(
    friendsProvider,
    (previous, next) {
      next.whenData((friends) {
        notifier.regenerateActivities(friends);
      });
    },
  );
  
  return notifier;
});

/// Provider for encouragements sent/received
final encouragementsProvider = StateNotifierProvider<EncouragementsNotifier, AsyncValue<List<FriendEncouragement>>>((ref) {
  return EncouragementsNotifier();
});

class FriendsNotifier extends StateNotifier<AsyncValue<List<Friend>>> {
  FriendsNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  static const _key = 'friends_list';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);

      List<Friend> friends;
      if (json != null) {
        final List<dynamic> decoded = jsonDecode(json);
        friends = decoded.map((e) => Friend.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        // Generate initial mock friends
        friends = _generateMockFriends();
        await _save(friends);
      }

      state = AsyncValue.data(friends);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _save(List<Friend> friends) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(friends.map((f) => f.toJson()).toList());
    await prefs.setString(_key, json);
  }

  /// Generate 15 mock friends with diverse stats
  List<Friend> _generateMockFriends() {
    final random = Random();
    final now = DateTime.now();

    final mockData = [
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

    return mockData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final (username, displayName, emoji, xp, streak, longestStreak, level, levelNum) = data;

      // Vary last active times
      final lastActive = index < 5
          ? now.subtract(Duration(hours: random.nextInt(12))) // Very recent (5 friends)
          : index < 10
              ? now.subtract(Duration(hours: 12 + random.nextInt(36))) // 12-48h ago (5 friends)
              : now.subtract(Duration(days: 2 + random.nextInt(7))); // 2-9 days ago (5 friends)

      // Some are "online"
      final isOnline = index < 3 && random.nextBool();

      // Random friendship duration (1-365 days ago)
      final friendsSince = now.subtract(Duration(days: 7 + random.nextInt(358)));

      // Random achievement count
      final achievementCount = random.nextInt(15) + 3;

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
        achievements: [], // IDs would go here
        totalAchievements: achievementCount,
      );
    }).toList();
  }

  /// Add a new friend (mock implementation)
  Future<void> addFriend(String username) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Check if already friends
    if (currentState.any((f) => f.username.toLowerCase() == username.toLowerCase())) {
      throw Exception('Already friends with $username');
    }

    final random = Random();
    final now = DateTime.now();

    // Create new mock friend
    final newFriend = Friend(
      id: 'friend_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      displayName: username.replaceAll('_', ' '),
      avatarEmoji: _getRandomEmoji(random),
      totalXp: random.nextInt(2000) + 100,
      currentStreak: random.nextInt(30),
      longestStreak: random.nextInt(60) + 10,
      levelTitle: _getRandomLevel(random),
      currentLevel: random.nextInt(7) + 1,
      friendsSince: now,
      lastActiveDate: now.subtract(Duration(hours: random.nextInt(48))),
      isOnline: random.nextDouble() < 0.3, // 30% chance online
      totalAchievements: random.nextInt(15) + 5,
    );

    final updatedFriends = [...currentState, newFriend];
    await _save(updatedFriends);
    state = AsyncValue.data(updatedFriends);
  }

  /// Remove a friend
  Future<void> removeFriend(String friendId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedFriends = currentState.where((f) => f.id != friendId).toList();
    await _save(updatedFriends);
    state = AsyncValue.data(updatedFriends);
  }

  /// Search friends by username
  List<Friend> searchFriends(String query) {
    final currentState = state.valueOrNull;
    if (currentState == null) return [];

    final lowercaseQuery = query.toLowerCase();
    return currentState
        .where((f) =>
            f.username.toLowerCase().contains(lowercaseQuery) ||
            f.displayName.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Reload friends
  Future<void> reload() async {
    await _load();
  }

  /// Reset to mock data (for testing)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await _load();
  }

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
}

class FriendActivitiesNotifier extends StateNotifier<AsyncValue<List<FriendActivity>>> {
  FriendActivitiesNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  static const _key = 'friend_activities';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);

      List<FriendActivity> activities;
      if (json != null) {
        final List<dynamic> decoded = jsonDecode(json);
        activities = decoded.map((e) => FriendActivity.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        // Will be generated when friends load
        activities = [];
      }

      state = AsyncValue.data(activities);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _save(List<FriendActivity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(activities.map((a) => a.toJson()).toList());
    await prefs.setString(_key, json);
  }

  /// Generate activities from friends list
  Future<void> regenerateActivities(List<Friend> friends) async {
    if (friends.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    final random = Random();
    final now = DateTime.now();
    final activities = <FriendActivity>[];

    // Generate 3-5 activities per friend (recent ones)
    for (final friend in friends) {
      final activityCount = 3 + random.nextInt(3); // 3-5 activities
      
      for (int i = 0; i < activityCount; i++) {
        // Activities spread over last 7 days
        final timestamp = now.subtract(Duration(
          hours: random.nextInt(168), // 7 days in hours
          minutes: random.nextInt(60),
        ));

        final activityType = FriendActivityType.values[random.nextInt(FriendActivityType.values.length)];
        
        String description;
        int? xpEarned;

        switch (activityType) {
          case FriendActivityType.levelUp:
            final level = random.nextInt(7) + 1;
            description = 'Reached Level $level';
            xpEarned = level * 50;
            break;
          case FriendActivityType.achievementUnlocked:
            final achievements = ['First Tank', 'Water Wizard', 'Fish Friend', 'Plant Parent', 'Streak Master'];
            description = achievements[random.nextInt(achievements.length)];
            xpEarned = 100;
            break;
          case FriendActivityType.streakMilestone:
            final milestone = [7, 14, 30, 60, 100][random.nextInt(5)];
            description = '$milestone day streak!';
            xpEarned = milestone;
            break;
          case FriendActivityType.lessonCompleted:
            final lessons = ['Water Chemistry', 'Nitrogen Cycle', 'Fish Compatibility', 'Plant Care'];
            description = lessons[random.nextInt(lessons.length)];
            xpEarned = 50;
            break;
          case FriendActivityType.tankCreated:
            final tankTypes = ['Community', 'Planted', 'Reef', 'Nano'];
            description = '${tankTypes[random.nextInt(tankTypes.length)]} Tank';
            xpEarned = 25;
            break;
          case FriendActivityType.badgeEarned:
            final badges = ['Water Tester', 'Early Bird', 'Night Owl', 'Streak Keeper'];
            description = badges[random.nextInt(badges.length)];
            xpEarned = 75;
            break;
        }

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

    // Keep only last 50 activities
    final trimmedActivities = activities.take(50).toList();

    await _save(trimmedActivities);
    state = AsyncValue.data(trimmedActivities);
  }

  /// Reload activities
  Future<void> reload() async {
    await _load();
  }
}

class EncouragementsNotifier extends StateNotifier<AsyncValue<List<FriendEncouragement>>> {
  EncouragementsNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  static const _key = 'encouragements';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);

      List<FriendEncouragement> encouragements;
      if (json != null) {
        final List<dynamic> decoded = jsonDecode(json);
        encouragements = decoded.map((e) => FriendEncouragement.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        encouragements = [];
      }

      state = AsyncValue.data(encouragements);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _save(List<FriendEncouragement> encouragements) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(encouragements.map((e) => e.toJson()).toList());
    await prefs.setString(_key, json);
  }

  /// Send encouragement to a friend
  Future<void> sendEncouragement({
    required String toUserId,
    required String emoji,
    String? message,
  }) async {
    final currentState = state.valueOrNull ?? [];

    final encouragement = FriendEncouragement(
      id: 'enc_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: 'current_user',
      toUserId: toUserId,
      emoji: emoji,
      message: message,
      timestamp: DateTime.now(),
    );

    final updated = [encouragement, ...currentState];
    await _save(updated);
    state = AsyncValue.data(updated);
  }

  /// Mark encouragement as read
  Future<void> markAsRead(String encouragementId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updated = currentState.map((e) {
      if (e.id == encouragementId) {
        return e.copyWith(isRead: true);
      }
      return e;
    }).toList();

    await _save(updated);
    state = AsyncValue.data(updated);
  }

  /// Get unread count
  int get unreadCount {
    final currentState = state.valueOrNull;
    if (currentState == null) return 0;
    return currentState.where((e) => !e.isRead && e.toUserId == 'current_user').length;
  }
}
