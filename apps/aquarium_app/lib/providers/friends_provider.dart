import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend.dart';
import '../data/mock_friends.dart';
import '../services/social_service.dart';
import 'social_provider.dart';

/// Provider for friends list
final friendsProvider =
    StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friend>>>((ref) {
      return FriendsNotifier(ref);
    });

/// Provider for friend activities feed
final friendActivitiesProvider =
    StateNotifierProvider<
      FriendActivitiesNotifier,
      AsyncValue<List<FriendActivity>>
    >((ref) {
      final notifier = FriendActivitiesNotifier(ref);

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
      return EncouragementsNotifier(ref);
    });

class FriendsNotifier extends StateNotifier<AsyncValue<List<Friend>>> {
  FriendsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  SocialService get _social => _ref.read(socialServiceProvider);

  static const _key = 'friends_list';

  Future<void> _load() async {
    try {
      // Try Supabase first; falls back to mock internally
      final friends = await _social.getFriends();

      // Cache locally for next cold-start
      await _saveToCache(friends);

      state = AsyncValue.data(friends);
    } catch (e, st) {
      // If even the service fails, try local cache
      try {
        final cached = await _loadFromCache();
        if (cached != null && cached.isNotEmpty) {
          state = AsyncValue.data(cached);
          return;
        }
      } catch (e) { debugPrint('Error loading friends cache: $e'); }
      state = AsyncValue.error(e, st);
    }
  }

  // -- Local cache helpers (SharedPreferences) --

  Future<void> _saveToCache(List<Friend> friends) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(friends.map((f) => f.toJson()).toList());
    await prefs.setString(_key, json);
  }

  Future<List<Friend>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      if (json == null) return null;
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((e) => Friend.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to load friends cache: $e');
      return null;
    }
  }

  /// Add a new friend by username.
  ///
  /// When live, this searches Supabase for the user and sends a friend
  /// request. When offline/demo, it creates a mock friend locally.
  Future<void> addFriend(String username) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Check if already friends
    if (currentState.any(
      (f) => f.username.toLowerCase() == username.toLowerCase(),
    )) {
      throw Exception('Already friends with $username');
    }

    // Try real search + request
    final results = await _social.searchUsers(username);
    if (results.isNotEmpty) {
      await _social.sendFriendRequest(results.first['id'] as String);
      // Refresh list (request is pending; it won't show until accepted,
      // but this keeps state fresh).
      await _load();
      return;
    }

    // Fallback: create mock friend locally
    final newFriend = createMockFriend(username: username);
    final updatedFriends = [...currentState, newFriend];
    await _saveToCache(updatedFriends);
    state = AsyncValue.data(updatedFriends);
  }

  /// Remove a friend.
  Future<void> removeFriend(String friendId) async {
    // Try removing via Supabase
    await _social.removeFriend(friendId);

    // Also remove locally
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final updatedFriends = currentState.where((f) => f.id != friendId).toList();
    await _saveToCache(updatedFriends);
    state = AsyncValue.data(updatedFriends);
  }

  /// Search friends by username (client-side filter on current list).
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

  /// Reload friends from source.
  Future<void> reload() async {
    await _load();
  }

  /// Reset to mock data (for testing).
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await _load();
  }
}

class FriendActivitiesNotifier
    extends StateNotifier<AsyncValue<List<FriendActivity>>> {
  FriendActivitiesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  SocialService get _social => _ref.read(socialServiceProvider);

  static const _key = 'friend_activities';

  Future<void> _load() async {
    try {
      final activities = await _social.getActivityFeed(limit: 50);
      await _saveToCache(activities);
      state = AsyncValue.data(activities);
    } catch (e, st) {
      try {
        final cached = await _loadFromCache();
        if (cached != null && cached.isNotEmpty) {
          state = AsyncValue.data(cached);
          return;
        }
      } catch (e) { debugPrint('Error loading activity cache: $e'); }
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _saveToCache(List<FriendActivity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(activities.map((a) => a.toJson()).toList());
    await prefs.setString(_key, json);
  }

  Future<List<FriendActivity>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      if (json == null) return null;
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((e) => FriendActivity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to load activity feed cache: $e');
      return null;
    }
  }

  /// Regenerate activities from friends list.
  ///
  /// When live, this fetches from Supabase. When offline, it generates
  /// mock activities from the provided friends list.
  Future<void> regenerateActivities(List<Friend> friends) async {
    if (friends.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      final activities = await _social.getActivityFeed(limit: 50);
      if (activities.isNotEmpty) {
        await _saveToCache(activities);
        state = AsyncValue.data(activities);
        return;
      }
    } catch (e) { debugPrint('Error fetching activity feed: $e'); }

    // Fallback: generate mock activities from provided friends
    final activities = generateMockActivities(friends, activitiesPerFriend: 4);
    final trimmedActivities = activities.take(50).toList();
    await _saveToCache(trimmedActivities);
    state = AsyncValue.data(trimmedActivities);
  }

  /// Reload activities.
  Future<void> reload() async {
    await _load();
  }
}

class EncouragementsNotifier
    extends StateNotifier<AsyncValue<List<FriendEncouragement>>> {
  EncouragementsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  SocialService get _social => _ref.read(socialServiceProvider);

  static const _key = 'encouragements';

  Future<void> _load() async {
    try {
      final encouragements = await _social.getUnreadEncouragements();
      await _saveToCache(encouragements);
      state = AsyncValue.data(encouragements);
    } catch (e, st) {
      try {
        final cached = await _loadFromCache();
        if (cached != null) {
          state = AsyncValue.data(cached);
          return;
        }
      } catch (e) { debugPrint('Error loading encouragements cache: $e'); }
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _saveToCache(List<FriendEncouragement> encouragements) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(encouragements.map((e) => e.toJson()).toList());
    await prefs.setString(_key, json);
  }

  Future<List<FriendEncouragement>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      if (json == null) return null;
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((e) => FriendEncouragement.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to load encouragement cache: $e');
      return null;
    }
  }

  /// Send encouragement to a friend.
  Future<void> sendEncouragement({
    required String toUserId,
    required String emoji,
    String? message,
  }) async {
    await _social.sendEncouragement(
      toUserId: toUserId,
      emoji: emoji,
      message: message,
    );

    // Also store locally for immediate UI feedback
    final currentState = state.valueOrNull ?? [];
    final encouragement = FriendEncouragement(
      id: 'enc_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: _social.currentUserId,
      toUserId: toUserId,
      emoji: emoji,
      message: message,
      timestamp: DateTime.now(),
    );
    final updated = [encouragement, ...currentState];
    await _saveToCache(updated);
    state = AsyncValue.data(updated);
  }

  /// Mark encouragement as read.
  Future<void> markAsRead(String encouragementId) async {
    await _social.markEncouragementRead(encouragementId);

    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final updated = currentState.map((e) {
      if (e.id == encouragementId) return e.copyWith(isRead: true);
      return e;
    }).toList();
    await _saveToCache(updated);
    state = AsyncValue.data(updated);
  }

  /// Get unread count.
  int get unreadCount {
    final currentState = state.valueOrNull;
    if (currentState == null) return 0;
    return currentState
        .where((e) => !e.isRead && e.toUserId == _social.currentUserId)
        .length;
  }
}
