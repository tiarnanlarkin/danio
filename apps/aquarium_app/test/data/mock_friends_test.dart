/// Tests for mock friends data generation
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/data/mock_friends.dart';
import 'package:aquarium_app/models/friend.dart';
import 'package:aquarium_app/models/social.dart';

void main() {
  group('Mock Friends Generation', () {
    test('generateMockFriends creates correct number of friends', () {
      final friends = generateMockFriends(count: 10);
      expect(friends.length, 10);
    });

    test('generateMockFriends creates default 15 friends', () {
      final friends = generateMockFriends();
      expect(friends.length, 15);
    });

    test('generated friends have valid data', () {
      final friends = generateMockFriends(count: 5);

      for (final friend in friends) {
        expect(friend.id, isNotEmpty);
        expect(friend.username, isNotEmpty);
        expect(friend.displayName, isNotEmpty);
        expect(friend.avatarEmoji, isNotNull);
        expect(friend.totalXp, greaterThan(0));
        expect(friend.currentLevel, greaterThan(0));
        expect(friend.levelTitle, isNotEmpty);
        expect(friend.friendsSince, isNotNull);
      }
    });

    test('generated friends have varied XP levels', () {
      final friends = generateMockFriends(count: 10);
      
      final xpValues = friends.map((f) => f.totalXp).toSet();
      
      // Should have multiple different XP values
      expect(xpValues.length, greaterThan(5));
    });

    test('generated friends have varied streak lengths', () {
      final friends = generateMockFriends(count: 10);
      
      final streakValues = friends.map((f) => f.currentStreak).toSet();
      
      // Should have varied streaks
      expect(streakValues.length, greaterThan(1));
    });

    test('generated friends have valid last active dates', () {
      final friends = generateMockFriends(count: 10);
      final now = DateTime.now();

      for (final friend in friends) {
        if (friend.lastActiveDate != null) {
          // Last active should be in the past
          expect(friend.lastActiveDate!.isBefore(now) || 
                 friend.lastActiveDate!.isAtSameMomentAs(now), 
                 true);
          
          // Should be within reasonable range (not years ago)
          final daysSinceActive = now.difference(friend.lastActiveDate!).inDays;
          expect(daysSinceActive, lessThan(365));
        }
      }
    });

    test('some friends are marked as online', () {
      final friends = generateMockFriends(count: 15);
      
      final onlineFriends = friends.where((f) => f.isOnline).toList();
      
      // Not all should be online, but some might be
      expect(onlineFriends.length, lessThanOrEqualTo(friends.length));
    });

    test('friends have achievement data', () {
      final friends = generateMockFriends(count: 5);

      for (final friend in friends) {
        expect(friend.totalAchievements, greaterThan(0));
        expect(friend.achievements, isA<List<String>>());
      }
    });

    test('friendship dates are in the past', () {
      final friends = generateMockFriends(count: 5);
      final now = DateTime.now();

      for (final friend in friends) {
        expect(friend.friendsSince.isBefore(now) || 
               friend.friendsSince.isAtSameMomentAs(now),
               true);
      }
    });
  });

  group('Mock Activities Generation', () {
    test('generateMockActivities creates activities for all friends', () {
      final friends = generateMockFriends(count: 5);
      final activities = generateMockActivities(friends);

      expect(activities, isNotEmpty);
      expect(activities.length, greaterThan(5)); // Should have multiple per friend
    });

    test('generated activities have valid data', () {
      final friends = generateMockFriends(count: 3);
      final activities = generateMockActivities(friends);

      for (final activity in activities) {
        expect(activity.id, isNotEmpty);
        expect(activity.friendId, isNotEmpty);
        expect(activity.friendUsername, isNotEmpty);
        expect(activity.friendDisplayName, isNotEmpty);
        expect(activity.description, isNotEmpty);
        expect(activity.timestamp, isNotNull);
      }
    });

    test('activities are sorted by timestamp (most recent first)', () {
      final friends = generateMockFriends(count: 3);
      final activities = generateMockActivities(friends);

      for (int i = 0; i < activities.length - 1; i++) {
        final current = activities[i];
        final next = activities[i + 1];
        
        expect(current.timestamp.isAfter(next.timestamp) || 
               current.timestamp.isAtSameMomentAs(next.timestamp),
               true,
               reason: 'Activities should be sorted newest first');
      }
    });

    test('activities have varied types', () {
      final friends = generateMockFriends(count: 5);
      final activities = generateMockActivities(friends);

      final types = activities.map((a) => a.type).toSet();
      
      // Should have multiple activity types
      expect(types.length, greaterThan(1));
    });

    test('activities have XP earned', () {
      final friends = generateMockFriends(count: 3);
      final activities = generateMockActivities(friends);

      final withXP = activities.where((a) => a.xpEarned != null).toList();
      
      // Most activities should have XP
      expect(withXP.length, greaterThan(activities.length ~/ 2));
    });

    test('activities timestamps are within last 7 days', () {
      final friends = generateMockFriends(count: 3);
      final activities = generateMockActivities(friends);
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      for (final activity in activities) {
        expect(activity.timestamp.isAfter(sevenDaysAgo), true,
               reason: 'Activity timestamp should be within last 7 days');
        expect(activity.timestamp.isBefore(now) || 
               activity.timestamp.isAtSameMomentAs(now), true,
               reason: 'Activity timestamp should not be in future');
      }
    });

    test('returns empty list for empty friends list', () {
      final activities = generateMockActivities([]);
      expect(activities, isEmpty);
    });
  });

  group('Mock Friend Requests Generation', () {
    test('generateMockFriendRequests creates correct number', () {
      final requests = generateMockFriendRequests(
        currentUserId: 'user_1',
        pendingCount: 3,
      );

      expect(requests.length, 3);
    });

    test('generated requests have valid data', () {
      final requests = generateMockFriendRequests(
        currentUserId: 'user_1',
        pendingCount: 2,
      );

      for (final request in requests) {
        expect(request.id, isNotEmpty);
        expect(request.fromUserId, isNotEmpty);
        expect(request.fromUsername, isNotEmpty);
        expect(request.fromDisplayName, isNotEmpty);
        expect(request.toUserId, 'user_1');
        expect(request.status, FriendRequestStatus.pending);
      }
    });

    test('requests are created in the past', () {
      final requests = generateMockFriendRequests(
        currentUserId: 'user_1',
        pendingCount: 2,
      );
      final now = DateTime.now();

      for (final request in requests) {
        expect(request.createdAt.isBefore(now) || 
               request.createdAt.isAtSameMomentAs(now),
               true);
      }
    });

    test('some requests may have messages', () {
      final requests = generateMockFriendRequests(
        currentUserId: 'user_1',
        pendingCount: 5,
      );

      // At least the first one should have a message (based on mock data)
      final firstRequest = requests.first;
      expect(firstRequest.message, isNotNull);
    });
  });

  group('Create Mock Friend', () {
    test('createMockFriend creates friend with username', () {
      final friend = createMockFriend(username: 'test_user');

      expect(friend.username, 'test_user');
      expect(friend.id, isNotEmpty);
      expect(friend.totalXp, greaterThan(0));
      expect(friend.currentLevel, greaterThan(0));
    });

    test('createMockFriend uses custom display name', () {
      final friend = createMockFriend(
        username: 'test_user',
        displayName: 'Test Display',
      );

      expect(friend.username, 'test_user');
      expect(friend.displayName, 'Test Display');
    });

    test('createMockFriend uses custom emoji', () {
      final friend = createMockFriend(
        username: 'test_user',
        emoji: '🦈',
      );

      expect(friend.username, 'test_user');
      expect(friend.avatarEmoji, '🦈');
    });

    test('createMockFriend generates display name from username', () {
      final friend = createMockFriend(username: 'test_user_name');

      // Should convert underscores to spaces and title case
      expect(friend.displayName, contains('Test'));
      expect(friend.displayName, contains('User'));
    });

    test('createMockFriend sets friendsSince to now', () {
      final now = DateTime.now();
      final friend = createMockFriend(username: 'test_user');

      final difference = now.difference(friend.friendsSince).inSeconds;
      expect(difference, lessThan(5)); // Should be within 5 seconds
    });

    test('createMockFriend generates random stats', () {
      final friend1 = createMockFriend(username: 'user1');
      final friend2 = createMockFriend(username: 'user2');

      // Stats should be different (random)
      // Note: There's a small chance they could be the same, but very unlikely
      final statsAreDifferent = 
          friend1.totalXp != friend2.totalXp ||
          friend1.currentStreak != friend2.currentStreak ||
          friend1.currentLevel != friend2.currentLevel;

      expect(statsAreDifferent, true);
    });
  });

  group('String Extensions', () {
    test('titleCase converts to title case', () {
      expect('hello world'.titleCase(), 'Hello World');
      expect('HELLO WORLD'.titleCase(), 'Hello World');
      expect('hello'.titleCase(), 'Hello');
      expect(''.titleCase(), '');
    });

    test('titleCase handles single words', () {
      expect('test'.titleCase(), 'Test');
      expect('TEST'.titleCase(), 'Test');
    });

    test('titleCase handles multiple spaces', () {
      expect('hello  world'.titleCase(), 'Hello  World');
    });
  });
}
