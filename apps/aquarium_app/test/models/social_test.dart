/// Tests for social models - Friend, FriendRequest, FriendActivity
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/social.dart';
import 'package:aquarium_app/models/friend.dart';

void main() {
  group('Friend Model', () {
    test('creates friend with required fields', () {
      final friend = Friend(
        id: 'friend_1',
        username: 'test_user',
        displayName: 'Test User',
        totalXp: 500,
        levelTitle: 'Hobbyist',
        currentLevel: 3,
        friendsSince: DateTime(2024, 1, 1),
      );

      expect(friend.id, 'friend_1');
      expect(friend.username, 'test_user');
      expect(friend.displayName, 'Test User');
      expect(friend.totalXp, 500);
      expect(friend.levelTitle, 'Hobbyist');
      expect(friend.currentLevel, 3);
    });

    test('statusText returns correct online status', () {
      final onlineFriend = Friend(
        id: 'friend_1',
        username: 'test_user',
        displayName: 'Test User',
        totalXp: 500,
        levelTitle: 'Hobbyist',
        currentLevel: 3,
        friendsSince: DateTime.now(),
        isOnline: true,
      );

      expect(onlineFriend.statusText, 'Online now');
    });

    test('statusText returns time since last active', () {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));

      final friend = Friend(
        id: 'friend_1',
        username: 'test_user',
        displayName: 'Test User',
        totalXp: 500,
        levelTitle: 'Hobbyist',
        currentLevel: 3,
        friendsSince: DateTime.now(),
        lastActiveDate: twoHoursAgo,
        isOnline: false,
      );

      expect(friend.statusText, '2h ago');
    });

    test('isRecentlyActive returns true for activity within 24 hours', () {
      final now = DateTime.now();
      final twelveHoursAgo = now.subtract(const Duration(hours: 12));

      final friend = Friend(
        id: 'friend_1',
        username: 'test_user',
        displayName: 'Test User',
        totalXp: 500,
        levelTitle: 'Hobbyist',
        currentLevel: 3,
        friendsSince: DateTime.now(),
        lastActiveDate: twelveHoursAgo,
      );

      expect(friend.isRecentlyActive, true);
    });

    test('isRecentlyActive returns false for activity over 24 hours', () {
      final now = DateTime.now();
      final twoDaysAgo = now.subtract(const Duration(days: 2));

      final friend = Friend(
        id: 'friend_1',
        username: 'test_user',
        displayName: 'Test User',
        totalXp: 500,
        levelTitle: 'Hobbyist',
        currentLevel: 3,
        friendsSince: DateTime.now(),
        lastActiveDate: twoDaysAgo,
      );

      expect(friend.isRecentlyActive, false);
    });

    test('toJson and fromJson work correctly', () {
      final original = Friend(
        id: 'friend_1',
        username: 'test_user',
        displayName: 'Test User',
        avatarEmoji: '🐠',
        totalXp: 500,
        currentStreak: 5,
        longestStreak: 10,
        levelTitle: 'Hobbyist',
        currentLevel: 3,
        friendsSince: DateTime(2024, 1, 1),
        lastActiveDate: DateTime(2024, 2, 1),
        isOnline: true,
        achievements: ['achievement_1', 'achievement_2'],
        totalAchievements: 5,
      );

      final json = original.toJson();
      final restored = Friend.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.username, original.username);
      expect(restored.displayName, original.displayName);
      expect(restored.avatarEmoji, original.avatarEmoji);
      expect(restored.totalXp, original.totalXp);
      expect(restored.currentStreak, original.currentStreak);
      expect(restored.longestStreak, original.longestStreak);
      expect(restored.levelTitle, original.levelTitle);
      expect(restored.currentLevel, original.currentLevel);
      expect(restored.isOnline, original.isOnline);
      expect(restored.achievements.length, original.achievements.length);
      expect(restored.totalAchievements, original.totalAchievements);
    });
  });

  group('FriendActivity Model', () {
    test('creates activity with required fields', () {
      final activity = FriendActivity(
        id: 'activity_1',
        friendId: 'friend_1',
        friendUsername: 'test_user',
        friendDisplayName: 'Test User',
        type: FriendActivityType.levelUp,
        description: 'Reached Level 5',
        timestamp: DateTime.now(),
      );

      expect(activity.id, 'activity_1');
      expect(activity.friendId, 'friend_1');
      expect(activity.type, FriendActivityType.levelUp);
      expect(activity.description, 'Reached Level 5');
    });

    test('timeAgo returns "Just now" for recent activity', () {
      final activity = FriendActivity(
        id: 'activity_1',
        friendId: 'friend_1',
        friendUsername: 'test_user',
        friendDisplayName: 'Test User',
        type: FriendActivityType.levelUp,
        description: 'Reached Level 5',
        timestamp: DateTime.now(),
      );

      expect(activity.timeAgo, 'Just now');
    });

    test('timeAgo returns minutes for recent activity', () {
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));

      final activity = FriendActivity(
        id: 'activity_1',
        friendId: 'friend_1',
        friendUsername: 'test_user',
        friendDisplayName: 'Test User',
        type: FriendActivityType.levelUp,
        description: 'Reached Level 5',
        timestamp: fiveMinutesAgo,
      );

      expect(activity.timeAgo, '5m ago');
    });

    test('FriendActivityType has correct display names', () {
      expect(FriendActivityType.levelUp.displayName, 'leveled up');
      expect(FriendActivityType.achievementUnlocked.displayName, 'unlocked achievement');
      expect(FriendActivityType.streakMilestone.displayName, 'reached streak milestone');
      expect(FriendActivityType.lessonCompleted.displayName, 'completed lesson');
    });

    test('FriendActivityType has emojis', () {
      expect(FriendActivityType.levelUp.emoji, '⭐');
      expect(FriendActivityType.achievementUnlocked.emoji, '🏆');
      expect(FriendActivityType.streakMilestone.emoji, '🔥');
      expect(FriendActivityType.lessonCompleted.emoji, '📚');
    });

    test('toJson and fromJson work correctly', () {
      final original = FriendActivity(
        id: 'activity_1',
        friendId: 'friend_1',
        friendUsername: 'test_user',
        friendDisplayName: 'Test User',
        friendAvatarEmoji: '🐠',
        type: FriendActivityType.levelUp,
        description: 'Reached Level 5',
        xpEarned: 100,
        timestamp: DateTime(2024, 2, 1, 10, 30),
      );

      final json = original.toJson();
      final restored = FriendActivity.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.friendId, original.friendId);
      expect(restored.friendUsername, original.friendUsername);
      expect(restored.type, original.type);
      expect(restored.description, original.description);
      expect(restored.xpEarned, original.xpEarned);
    });
  });

  group('FriendRequest Model', () {
    test('creates request with required fields', () {
      final request = FriendRequest(
        id: 'request_1',
        fromUserId: 'user_1',
        fromUsername: 'sender',
        fromDisplayName: 'Sender Name',
        toUserId: 'user_2',
        toUsername: 'receiver',
        createdAt: DateTime.now(),
      );

      expect(request.id, 'request_1');
      expect(request.fromUserId, 'user_1');
      expect(request.toUserId, 'user_2');
      expect(request.status, FriendRequestStatus.pending);
    });

    test('isFromUser returns correct value', () {
      final request = FriendRequest(
        id: 'request_1',
        fromUserId: 'user_1',
        fromUsername: 'sender',
        fromDisplayName: 'Sender Name',
        toUserId: 'user_2',
        toUsername: 'receiver',
        createdAt: DateTime.now(),
      );

      expect(request.isFromUser('user_1'), true);
      expect(request.isFromUser('user_2'), false);
    });

    test('isToUser returns correct value', () {
      final request = FriendRequest(
        id: 'request_1',
        fromUserId: 'user_1',
        fromUsername: 'sender',
        fromDisplayName: 'Sender Name',
        toUserId: 'user_2',
        toUsername: 'receiver',
        createdAt: DateTime.now(),
      );

      expect(request.isToUser('user_2'), true);
      expect(request.isToUser('user_1'), false);
    });

    test('FriendRequestStatus has correct properties', () {
      expect(FriendRequestStatus.pending.isPending, true);
      expect(FriendRequestStatus.accepted.isAccepted, true);
      expect(FriendRequestStatus.rejected.isRejected, true);
      
      expect(FriendRequestStatus.accepted.isPending, false);
      expect(FriendRequestStatus.pending.isAccepted, false);
    });

    test('timeAgo returns correct relative time', () {
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));

      final request = FriendRequest(
        id: 'request_1',
        fromUserId: 'user_1',
        fromUsername: 'sender',
        fromDisplayName: 'Sender Name',
        toUserId: 'user_2',
        toUsername: 'receiver',
        createdAt: twoHoursAgo,
      );

      expect(request.timeAgo, '2h ago');
    });

    test('toJson and fromJson work correctly', () {
      final original = FriendRequest(
        id: 'request_1',
        fromUserId: 'user_1',
        fromUsername: 'sender',
        fromDisplayName: 'Sender Name',
        fromAvatarEmoji: '🐠',
        toUserId: 'user_2',
        toUsername: 'receiver',
        status: FriendRequestStatus.pending,
        createdAt: DateTime(2024, 2, 1, 10, 30),
        message: 'Let\'s be friends!',
      );

      final json = original.toJson();
      final restored = FriendRequest.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.fromUserId, original.fromUserId);
      expect(restored.fromUsername, original.fromUsername);
      expect(restored.toUserId, original.toUserId);
      expect(restored.status, original.status);
      expect(restored.message, original.message);
    });
  });

  group('FriendEncouragement Model', () {
    test('creates encouragement with required fields', () {
      final encouragement = FriendEncouragement(
        id: 'enc_1',
        fromUserId: 'user_1',
        toUserId: 'user_2',
        emoji: '👍',
        timestamp: DateTime.now(),
      );

      expect(encouragement.id, 'enc_1');
      expect(encouragement.fromUserId, 'user_1');
      expect(encouragement.toUserId, 'user_2');
      expect(encouragement.emoji, '👍');
      expect(encouragement.isRead, false);
    });

    test('copyWith updates isRead', () {
      final original = FriendEncouragement(
        id: 'enc_1',
        fromUserId: 'user_1',
        toUserId: 'user_2',
        emoji: '👍',
        timestamp: DateTime.now(),
        isRead: false,
      );

      final updated = original.copyWith(isRead: true);

      expect(updated.isRead, true);
      expect(updated.id, original.id);
      expect(updated.emoji, original.emoji);
    });

    test('toJson and fromJson work correctly', () {
      final original = FriendEncouragement(
        id: 'enc_1',
        fromUserId: 'user_1',
        toUserId: 'user_2',
        emoji: '🎉',
        message: 'Great job!',
        timestamp: DateTime(2024, 2, 1, 10, 30),
        isRead: true,
      );

      final json = original.toJson();
      final restored = FriendEncouragement.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.fromUserId, original.fromUserId);
      expect(restored.toUserId, original.toUserId);
      expect(restored.emoji, original.emoji);
      expect(restored.message, original.message);
      expect(restored.isRead, original.isRead);
    });
  });

  group('FriendChallenge Model', () {
    test('creates challenge with required fields', () {
      final challenge = FriendChallenge(
        id: 'challenge_1',
        challengerId: 'user_1',
        challengerName: 'User One',
        opponentId: 'user_2',
        opponentName: 'User Two',
        type: ChallengeType.weeklyXP,
        targetValue: 500,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
      );

      expect(challenge.id, 'challenge_1');
      expect(challenge.type, ChallengeType.weeklyXP);
      expect(challenge.targetValue, 500);
      expect(challenge.status, ChallengeStatus.active);
    });

    test('winner returns correct user when completed', () {
      final challenge = FriendChallenge(
        id: 'challenge_1',
        challengerId: 'user_1',
        challengerName: 'User One',
        opponentId: 'user_2',
        opponentName: 'User Two',
        type: ChallengeType.weeklyXP,
        targetValue: 500,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        status: ChallengeStatus.completed,
        challengerProgress: 600,
        opponentProgress: 400,
      );

      expect(challenge.winner, 'user_1');
    });

    test('isTie returns true for equal scores', () {
      final challenge = FriendChallenge(
        id: 'challenge_1',
        challengerId: 'user_1',
        challengerName: 'User One',
        opponentId: 'user_2',
        opponentName: 'User Two',
        type: ChallengeType.weeklyXP,
        targetValue: 500,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        status: ChallengeStatus.completed,
        challengerProgress: 500,
        opponentProgress: 500,
      );

      expect(challenge.isTie, true);
    });

    test('ChallengeType has correct display names and emojis', () {
      expect(ChallengeType.weeklyXP.displayName, 'Weekly XP');
      expect(ChallengeType.weeklyXP.emoji, '⭐');
      
      expect(ChallengeType.dailyStreak.displayName, 'Daily Streak');
      expect(ChallengeType.dailyStreak.emoji, '🔥');
    });
  });
}
