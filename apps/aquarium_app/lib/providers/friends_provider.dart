import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend.dart';
import '../data/mock_friends.dart';

/// Provider for friends list
final friendsProvider =
    StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friend>>>((ref) {
      return FriendsNotifier();
    });

/// Provider for friend activities feed
final friendActivitiesProvider =
    StateNotifierProvider<
      FriendActivitiesNotifier,
      AsyncValue<List<FriendActivity>>
    >((ref) {
      final notifier = FriendActivitiesNotifier();

      // Listen to friends changes to regenerate activities
      ref.listen<AsyncValue<List<Friend>>>(friendsProvider, (previous, next) {
        next.whenData((friends) {
          notifier.regenerateActivities(friends);
        });
      });

      return notifier;
    });

/// Provider for encouragements sent/received
final encouragementsProvider =
    StateNotifierProvider<
      EncouragementsNotifier,
      AsyncValue<List<FriendEncouragement>>
    >((ref) {
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
        friends = decoded
            .map((e) => Friend.fromJson(e as Map<String, dynamic>))
            .toList();
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
    return generateMockFriends(count: 15);
  }

  /// Add a new friend (mock implementation)
  Future<void> addFriend(String username) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Check if already friends
    if (currentState.any(
      (f) => f.username.toLowerCase() == username.toLowerCase(),
    )) {
      throw Exception('Already friends with $username');
    }

    // Create new mock friend using mock_friends.dart
    final newFriend = createMockFriend(username: username);

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
        .where(
          (f) =>
              f.username.toLowerCase().contains(lowercaseQuery) ||
              f.displayName.toLowerCase().contains(lowercaseQuery),
        )
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
}

class FriendActivitiesNotifier
    extends StateNotifier<AsyncValue<List<FriendActivity>>> {
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
        activities = decoded
            .map((e) => FriendActivity.fromJson(e as Map<String, dynamic>))
            .toList();
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

    // Use mock_friends.dart to generate activities
    final activities = generateMockActivities(friends, activitiesPerFriend: 4);

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

class EncouragementsNotifier
    extends StateNotifier<AsyncValue<List<FriendEncouragement>>> {
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
        encouragements = decoded
            .map((e) => FriendEncouragement.fromJson(e as Map<String, dynamic>))
            .toList();
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
    return currentState
        .where((e) => !e.isRead && e.toUserId == 'current_user')
        .length;
  }
}
