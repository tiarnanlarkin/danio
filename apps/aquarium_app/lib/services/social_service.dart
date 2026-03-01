/// Supabase-backed social service replacing all mock data.
///
/// Falls back to mock data when Supabase is unreachable or auth is not
/// configured, so the app works in offline/demo mode.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/social.dart';
import '../models/leaderboard.dart';
import '../data/mock_friends.dart';
import '../data/mock_leaderboard.dart';
import 'supabase_service.dart';

// ---------------------------------------------------------------------------
// Helper: convert a Supabase profile row + friendship timestamp → Friend
// ---------------------------------------------------------------------------

Friend _friendFromSupabase(
  Map<String, dynamic> profile,
  DateTime friendsSince,
) {
  final lastActive = DateTime.tryParse(profile['last_active_at'] ?? '');
  final isOnline =
      lastActive != null && DateTime.now().difference(lastActive).inMinutes < 5;

  return Friend(
    id: profile['id'] as String,
    username: profile['username'] as String? ?? 'unknown',
    displayName: profile['display_name'] as String? ?? 'Unknown',
    avatarEmoji: profile['avatar_emoji'] as String? ?? '🐠',
    totalXp: profile['total_xp'] as int? ?? 0,
    currentStreak: profile['current_streak'] as int? ?? 0,
    longestStreak: profile['longest_streak'] as int? ?? 0,
    levelTitle: profile['level_title'] as String? ?? 'Beginner',
    currentLevel: profile['current_level'] as int? ?? 1,
    friendsSince: friendsSince,
    lastActiveDate: lastActive,
    isOnline: isOnline,
    achievements: const [],
    totalAchievements: 0,
  );
}

// ---------------------------------------------------------------------------
// Helper: map activity_type string → FriendActivityType enum
// ---------------------------------------------------------------------------

FriendActivityType _parseActivityType(String type) {
  switch (type) {
    case 'level_up':
      return FriendActivityType.levelUp;
    case 'achievement_unlocked':
      return FriendActivityType.achievementUnlocked;
    case 'streak_milestone':
      return FriendActivityType.streakMilestone;
    case 'lesson_completed':
      return FriendActivityType.lessonCompleted;
    case 'tank_created':
      return FriendActivityType.tankCreated;
    case 'badge_earned':
      return FriendActivityType.badgeEarned;
    default:
      return FriendActivityType.levelUp;
  }
}

String _activityTypeToString(FriendActivityType type) {
  switch (type) {
    case FriendActivityType.levelUp:
      return 'level_up';
    case FriendActivityType.achievementUnlocked:
      return 'achievement_unlocked';
    case FriendActivityType.streakMilestone:
      return 'streak_milestone';
    case FriendActivityType.lessonCompleted:
      return 'lesson_completed';
    case FriendActivityType.tankCreated:
      return 'tank_created';
    case FriendActivityType.badgeEarned:
      return 'badge_earned';
  }
}

// ---------------------------------------------------------------------------
// Helper: current Monday as ISO date string (for weekly leagues)
// ---------------------------------------------------------------------------

String _getCurrentWeekStart() {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final start = DateTime(monday.year, monday.month, monday.day);
  return start.toIso8601String().split('T').first;
}

// ---------------------------------------------------------------------------
// SocialService
// ---------------------------------------------------------------------------

/// Supabase-backed social service with offline/mock fallback.
class SocialService {
  SocialService();

  /// Whether we can reach Supabase with an authenticated user.
  bool get _isLive {
    if (!SupabaseService.isInitialised) return false;
    return SupabaseService.instance.isSignedIn;
  }

  SupabaseClient get _client => SupabaseService.instance.client;
  String get _uid => _client.auth.currentUser!.id;

  /// Public accessor for the current user ID (falls back to 'anonymous' when offline).
  String get currentUserId => _isLive ? _uid : 'anonymous';

  // =========================================================================
  // Profile
  // =========================================================================

  /// Get current user's profile row.
  Future<Map<String, dynamic>?> getMyProfile() async {
    if (!_isLive) return null;
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', _uid)
          .maybeSingle();
      return res;
    } catch (e) {
      debugPrint('[SocialService] getMyProfile error: $e');
      return null;
    }
  }

  /// Update own profile fields.
  Future<void> updateProfile({
    String? username,
    String? displayName,
    String? avatarEmoji,
  }) async {
    if (!_isLive) return;
    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarEmoji != null) updates['avatar_emoji'] = avatarEmoji;
    if (updates.isEmpty) return;
    await _client.from('profiles').update(updates).eq('id', _uid);
  }

  /// Search users by username or display name (prefix match).
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (!_isLive) return [];
    try {
      final res = await _client
          .from('profiles')
          .select('id, username, display_name, avatar_emoji, current_level, level_title')
          .or('username.ilike.%$query%,display_name.ilike.%$query%')
          .neq('id', _uid)
          .limit(20);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('[SocialService] searchUsers error: $e');
      return [];
    }
  }

  // =========================================================================
  // Friends
  // =========================================================================

  /// Get accepted friends list. Falls back to mock data offline.
  Future<List<Friend>> getFriends() async {
    if (!_isLive) return generateMockFriends(count: 15);
    try {
      final res = await _client
          .from('friendships')
          .select('''
            id,
            created_at,
            requester_id,
            addressee_id,
            requester:profiles!friendships_requester_id_fkey(
              id, username, display_name, avatar_emoji, total_xp,
              current_streak, longest_streak, current_level, level_title,
              last_active_at
            ),
            addressee:profiles!friendships_addressee_id_fkey(
              id, username, display_name, avatar_emoji, total_xp,
              current_streak, longest_streak, current_level, level_title,
              last_active_at
            )
          ''')
          .eq('status', 'accepted')
          .or('requester_id.eq.$_uid,addressee_id.eq.$_uid');

      return List<Map<String, dynamic>>.from(res).map((row) {
        final isRequester = row['requester_id'] == _uid;
        final friendProfile =
            isRequester ? row['addressee'] : row['requester'];
        final friendsSince = DateTime.parse(row['created_at'] as String);
        return _friendFromSupabase(
          friendProfile as Map<String, dynamic>,
          friendsSince,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SocialService] getFriends error: $e');
      return generateMockFriends(count: 15);
    }
  }

  /// Send a friend request to another user by their user ID.
  Future<void> sendFriendRequest(String toUserId, {String? message}) async {
    if (!_isLive) return;
    await _client.from('friendships').insert({
      'requester_id': _uid,
      'addressee_id': toUserId,
      'status': 'pending',
      if (message != null) 'message': message,
    });
  }

  /// Accept a pending friend request.
  Future<void> acceptFriendRequest(String friendshipId) async {
    if (!_isLive) return;
    await _client.from('friendships').update({
      'status': 'accepted',
      'responded_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', friendshipId);
  }

  /// Reject / decline a friend request.
  Future<void> rejectFriendRequest(String friendshipId) async {
    if (!_isLive) return;
    await _client.from('friendships').delete().eq('id', friendshipId);
  }

  /// Get incoming pending requests.
  Future<List<FriendRequest>> getPendingRequests() async {
    if (!_isLive) {
      return generateMockFriendRequests(
        currentUserId: 'current_user',
        pendingCount: 2,
      );
    }
    try {
      final res = await _client
          .from('friendships')
          .select('''
            id, requester_id, addressee_id, status, message, created_at,
            requester:profiles!friendships_requester_id_fkey(
              id, username, display_name, avatar_emoji
            )
          ''')
          .eq('addressee_id', _uid)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res).map((row) {
        final from = row['requester'] as Map<String, dynamic>;
        return FriendRequest(
          id: row['id'] as String,
          fromUserId: row['requester_id'] as String,
          fromUsername: from['username'] as String? ?? '',
          fromDisplayName: from['display_name'] as String? ?? '',
          fromAvatarEmoji: from['avatar_emoji'] as String?,
          toUserId: _uid,
          toUsername: 'you',
          status: FriendRequestStatus.pending,
          createdAt: DateTime.parse(row['created_at'] as String),
          message: row['message'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SocialService] getPendingRequests error: $e');
      return [];
    }
  }

  /// Get outgoing sent requests.
  Future<List<FriendRequest>> getSentRequests() async {
    if (!_isLive) return [];
    try {
      final res = await _client
          .from('friendships')
          .select('''
            id, requester_id, addressee_id, status, message, created_at,
            addressee:profiles!friendships_addressee_id_fkey(
              id, username, display_name, avatar_emoji
            )
          ''')
          .eq('requester_id', _uid)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res).map((row) {
        final to = row['addressee'] as Map<String, dynamic>;
        return FriendRequest(
          id: row['id'] as String,
          fromUserId: _uid,
          fromUsername: 'you',
          fromDisplayName: 'You',
          toUserId: row['addressee_id'] as String,
          toUsername: to['username'] as String? ?? '',
          status: FriendRequestStatus.pending,
          createdAt: DateTime.parse(row['created_at'] as String),
          message: row['message'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SocialService] getSentRequests error: $e');
      return [];
    }
  }

  /// Remove a friendship (unfriend). Accepts either a friendship row ID or a user ID.
  Future<void> removeFriend(String friendOrUserId) async {
    if (!_isLive) return;
    // Try deleting where the given ID is the other user (most common call pattern)
    await _client
        .from('friendships')
        .delete()
        .or('and(requester_id.eq.$_uid,addressee_id.eq.$friendOrUserId),and(requester_id.eq.$friendOrUserId,addressee_id.eq.$_uid)');
  }

  /// Block a user.
  Future<void> blockUser(String userId) async {
    if (!_isLive) return;
    // Upsert as blocked regardless of whether friendship exists
    await _client.from('friendships').upsert({
      'requester_id': _uid,
      'addressee_id': userId,
      'status': 'blocked',
    });
  }

  /// Check if current user is friends with [userId].
  Future<bool> areFriends(String userId) async {
    if (!_isLive) return false;
    try {
      final res = await _client.rpc('are_friends', params: {
        'user_a': _uid,
        'user_b': userId,
      });
      return res == true;
    } catch (e) {
      return false;
    }
  }

  // =========================================================================
  // Activity Feed
  // =========================================================================

  /// Get activity feed (own + friends' activities).
  /// Falls back to mock activities when offline.
  Future<List<FriendActivity>> getActivityFeed({
    int limit = 50,
    DateTime? before,
  }) async {
    if (!_isLive) {
      final mockFriends = generateMockFriends(count: 10);
      return generateMockActivities(mockFriends, activitiesPerFriend: 4)
          .take(limit)
          .toList();
    }
    try {
      var filterQuery = _client.from('activity_feed').select('''
        id, user_id, activity_type, description, xp_earned, details, created_at,
        user:profiles!activity_feed_user_id_fkey(
          id, username, display_name, avatar_emoji
        )
      ''');

      if (before != null) {
        filterQuery = filterQuery.lt('created_at', before.toUtc().toIso8601String());
      }

      final res = await filterQuery.order('created_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(res).map((row) {
        final user = row['user'] as Map<String, dynamic>;
        return FriendActivity(
          id: row['id'] as String,
          friendId: row['user_id'] as String,
          friendUsername: user['username'] as String? ?? '',
          friendDisplayName: user['display_name'] as String? ?? '',
          friendAvatarEmoji: user['avatar_emoji'] as String?,
          type: _parseActivityType(row['activity_type'] as String),
          description: row['description'] as String,
          xpEarned: row['xp_earned'] as int?,
          timestamp: DateTime.parse(row['created_at'] as String),
        );
      }).toList();
    } catch (e) {
      debugPrint('[SocialService] getActivityFeed error: $e');
      final mockFriends = generateMockFriends(count: 10);
      return generateMockActivities(mockFriends, activitiesPerFriend: 4)
          .take(limit)
          .toList();
    }
  }

  /// Post a client-generated activity.
  Future<void> postActivity({
    required String activityType,
    required String description,
    int? xpEarned,
    Map<String, dynamic>? details,
  }) async {
    if (!_isLive) return;
    await _client.from('activity_feed').insert({
      'user_id': _uid,
      'activity_type': activityType,
      'description': description,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (details != null) 'details': details,
    });
  }

  // =========================================================================
  // Leaderboard
  // =========================================================================

  /// Get current week leaderboard for user's league.
  /// Falls back to mock leaderboard offline.
  Future<List<LeaderboardEntry>> getLeaderboard({
    required String currentUserId,
    required String currentUsername,
    required int currentUserXP,
    required League currentUserLeague,
  }) async {
    if (!_isLive) {
      return MockLeaderboard.generate(
        currentUserId: currentUserId,
        currentUsername: currentUsername,
        currentUserXP: currentUserXP,
        currentUserLeague: currentUserLeague,
      );
    }
    try {
      final weekStart = _getCurrentWeekStart();

      // Get user's current league from profile
      final profile = await _client
          .from('profiles')
          .select('league')
          .eq('id', _uid)
          .single();

      final league = profile['league'] as String? ?? 'bronze';

      final res = await _client
          .from('weekly_leagues')
          .select('''
            user_id, weekly_xp,
            user:profiles!weekly_leagues_user_id_fkey(
              display_name, avatar_emoji
            )
          ''')
          .eq('week_start', weekStart)
          .eq('league_tier', league)
          .order('weekly_xp', ascending: false)
          .limit(50);

      final rows = List<Map<String, dynamic>>.from(res);

      if (rows.isEmpty) {
        // No leaderboard data yet - fall back to mock
        return MockLeaderboard.generate(
          currentUserId: currentUserId,
          currentUsername: currentUsername,
          currentUserXP: currentUserXP,
          currentUserLeague: currentUserLeague,
        );
      }

      return rows.asMap().entries.map((entry) {
        final row = entry.value;
        final rank = entry.key + 1;
        final user = row['user'] as Map<String, dynamic>;
        return LeaderboardEntry(
          userId: row['user_id'] as String,
          displayName: user['display_name'] as String? ?? 'Unknown',
          weeklyXp: row['weekly_xp'] as int? ?? 0,
          rank: rank,
          avatarEmoji: user['avatar_emoji'] as String?,
          isCurrentUser: row['user_id'] == _uid,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SocialService] getLeaderboard error: $e');
      return MockLeaderboard.generate(
        currentUserId: currentUserId,
        currentUsername: currentUsername,
        currentUserXP: currentUserXP,
        currentUserLeague: currentUserLeague,
      );
    }
  }

  /// Get current user's league data.
  Future<LeaderboardUserData> getLeagueData() async {
    final now = DateTime.now();
    if (!_isLive) {
      return LeaderboardUserData(
        currentLeague: League.bronze,
        weeklyXpTotal: 0,
        lastResetDate: now,
      );
    }
    try {
      final profile = await _client
          .from('profiles')
          .select('league, weekly_xp')
          .eq('id', _uid)
          .single();

      final leagueName = profile['league'] as String? ?? 'bronze';
      final league = League.values.firstWhere(
        (l) => l.name == leagueName,
        orElse: () => League.bronze,
      );

      return LeaderboardUserData(
        currentLeague: league,
        weeklyXpTotal: profile['weekly_xp'] as int? ?? 0,
        lastResetDate: now,
      );
    } catch (e) {
      debugPrint('[SocialService] getLeagueData error: $e');
      return LeaderboardUserData(
        currentLeague: League.bronze,
        weeklyXpTotal: 0,
        lastResetDate: now,
      );
    }
  }

  /// Ensure user is enrolled in the current week's league.
  Future<void> ensureWeeklyEnrollment() async {
    if (!_isLive) return;
    try {
      final weekStart = _getCurrentWeekStart();
      final profile = await _client
          .from('profiles')
          .select('league')
          .eq('id', _uid)
          .single();

      await _client.from('weekly_leagues').upsert({
        'user_id': _uid,
        'league_tier': profile['league'] ?? 'bronze',
        'week_start': weekStart,
        'weekly_xp': 0,
      }, onConflict: 'user_id,week_start');
    } catch (e) {
      debugPrint('[SocialService] ensureWeeklyEnrollment error: $e');
    }
  }

  // =========================================================================
  // Encouragements
  // =========================================================================

  /// Send encouragement to a friend.
  Future<void> sendEncouragement({
    required String toUserId,
    required String emoji,
    String? message,
  }) async {
    if (!_isLive) return;
    await _client.from('encouragements').insert({
      'from_user_id': _uid,
      'to_user_id': toUserId,
      'emoji': emoji,
      if (message != null) 'message': message,
    });
  }

  /// Get unread encouragements.
  Future<List<FriendEncouragement>> getUnreadEncouragements() async {
    if (!_isLive) return [];
    try {
      final res = await _client
          .from('encouragements')
          .select('''
            id, from_user_id, to_user_id, emoji, message, is_read, created_at
          ''')
          .eq('to_user_id', _uid)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res).map((row) {
        return FriendEncouragement(
          id: row['id'] as String,
          fromUserId: row['from_user_id'] as String,
          toUserId: row['to_user_id'] as String,
          emoji: row['emoji'] as String,
          message: row['message'] as String?,
          timestamp: DateTime.parse(row['created_at'] as String),
          isRead: row['is_read'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SocialService] getUnreadEncouragements error: $e');
      return [];
    }
  }

  /// Mark a single encouragement as read.
  Future<void> markEncouragementRead(String encouragementId) async {
    if (!_isLive) return;
    await _client
        .from('encouragements')
        .update({'is_read': true})
        .eq('id', encouragementId);
  }

  /// Mark all encouragements as read.
  Future<void> markAllEncouragementsRead() async {
    if (!_isLive) return;
    await _client
        .from('encouragements')
        .update({'is_read': true})
        .eq('to_user_id', _uid)
        .eq('is_read', false);
  }

  // =========================================================================
  // Realtime streams
  // =========================================================================

  /// Stream of incoming pending friend requests.
  Stream<List<FriendRequest>> watchPendingRequests() {
    if (!_isLive) return Stream.value([]);
    return _client
        .from('friendships')
        .stream(primaryKey: ['id'])
        .eq('addressee_id', _uid)
        .map((rows) {
          return rows
              .where((r) => r['status'] == 'pending')
              .map((row) => FriendRequest(
                    id: row['id'] as String,
                    fromUserId: row['requester_id'] as String,
                    fromUsername: '',
                    fromDisplayName: '',
                    toUserId: _uid,
                    toUsername: 'you',
                    status: FriendRequestStatus.pending,
                    createdAt: DateTime.parse(row['created_at'] as String),
                    message: row['message'] as String?,
                  ))
              .toList();
        });
  }

  /// Stream of unread encouragements.
  Stream<List<FriendEncouragement>> watchEncouragements() {
    if (!_isLive) return Stream.value([]);
    return _client
        .from('encouragements')
        .stream(primaryKey: ['id'])
        .eq('to_user_id', _uid)
        .map((rows) {
          return rows
              .where((r) => r['is_read'] == false)
              .map((row) => FriendEncouragement(
                    id: row['id'] as String,
                    fromUserId: row['from_user_id'] as String,
                    toUserId: row['to_user_id'] as String,
                    emoji: row['emoji'] as String,
                    message: row['message'] as String?,
                    timestamp: DateTime.parse(row['created_at'] as String),
                    isRead: false,
                  ))
              .toList();
        });
  }
}
