/// Riverpod providers for the social service layer.
///
/// These provide access to [SocialService] and its derived data throughout
/// the widget tree. Screens should prefer watching these providers rather
/// than calling SocialService directly.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/social.dart';
import '../models/leaderboard.dart';
import '../services/social_service.dart';

// ---------------------------------------------------------------------------
// Core service singleton
// ---------------------------------------------------------------------------

/// Single shared instance of [SocialService].
final socialServiceProvider = Provider<SocialService>((ref) {
  return SocialService();
});

// ---------------------------------------------------------------------------
// Friends
// ---------------------------------------------------------------------------

/// Async list of accepted friends (auto-fetched).
final socialFriendsProvider =
    FutureProvider.autoDispose<List<Friend>>((ref) async {
  final social = ref.watch(socialServiceProvider);
  return social.getFriends();
});

/// Incoming pending friend requests.
final pendingRequestsProvider =
    FutureProvider.autoDispose<List<FriendRequest>>((ref) async {
  final social = ref.watch(socialServiceProvider);
  return social.getPendingRequests();
});

/// Outgoing sent requests.
final sentRequestsProvider =
    FutureProvider.autoDispose<List<FriendRequest>>((ref) async {
  final social = ref.watch(socialServiceProvider);
  return social.getSentRequests();
});

// ---------------------------------------------------------------------------
// Activity Feed
// ---------------------------------------------------------------------------

/// Activity feed (own + friends' activities), most recent first.
final socialActivityFeedProvider =
    FutureProvider.autoDispose<List<FriendActivity>>((ref) async {
  final social = ref.watch(socialServiceProvider);
  return social.getActivityFeed(limit: 50);
});

// ---------------------------------------------------------------------------
// Leaderboard
// ---------------------------------------------------------------------------

/// Leaderboard entries for current week + league.
///
/// Requires passing current user info; use [leaderboardFamilyProvider] or
/// build a dedicated notifier that reads the user profile.
final leaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, LeaderboardParams>((ref, params) async {
  final social = ref.watch(socialServiceProvider);
  return social.getLeaderboard(
    currentUserId: params.userId,
    currentUsername: params.username,
    currentUserXP: params.weeklyXp,
    currentUserLeague: params.league,
  );
});

/// Parameter object for [leaderboardProvider].
class LeaderboardParams {
  final String userId;
  final String username;
  final int weeklyXp;
  final League league;

  const LeaderboardParams({
    required this.userId,
    required this.username,
    required this.weeklyXp,
    required this.league,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardParams &&
          userId == other.userId &&
          username == other.username &&
          weeklyXp == other.weeklyXp &&
          league == other.league;

  @override
  int get hashCode => Object.hash(userId, username, weeklyXp, league);
}

// ---------------------------------------------------------------------------
// Encouragements
// ---------------------------------------------------------------------------

/// Unread encouragements.
final unreadEncouragementsProvider =
    FutureProvider.autoDispose<List<FriendEncouragement>>((ref) async {
  final social = ref.watch(socialServiceProvider);
  return social.getUnreadEncouragements();
});

/// Realtime stream of pending friend requests.
final pendingRequestsStreamProvider =
    StreamProvider.autoDispose<List<FriendRequest>>((ref) {
  final social = ref.watch(socialServiceProvider);
  return social.watchPendingRequests();
});

/// Realtime stream of unread encouragements.
final encouragementsStreamProvider =
    StreamProvider.autoDispose<List<FriendEncouragement>>((ref) {
  final social = ref.watch(socialServiceProvider);
  return social.watchEncouragements();
});
