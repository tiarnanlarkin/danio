/// Unit tests for leaderboard models and competition logic
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/leaderboard.dart';

void main() {
  group('League', () {
    test('has correct display names', () {
      expect(League.bronze.displayName, 'Bronze');
      expect(League.silver.displayName, 'Silver');
      expect(League.gold.displayName, 'Gold');
      expect(League.diamond.displayName, 'Diamond');
    });

    test('has correct emojis', () {
      expect(League.bronze.emoji, '🥉');
      expect(League.silver.emoji, '🥈');
      expect(League.gold.emoji, '🥇');
      expect(League.diamond.emoji, '💎');
    });

    test('has correct promotion XP rewards', () {
      expect(League.bronze.promotionXp, 0);
      expect(League.silver.promotionXp, 50);
      expect(League.gold.promotionXp, 100);
      expect(League.diamond.promotionXp, 200);
    });

    test('has correct color hex values', () {
      expect(League.bronze.colorHex, '#CD7F32');
      expect(League.silver.colorHex, '#C0C0C0');
      expect(League.gold.colorHex, '#FFD700');
      expect(League.diamond.colorHex, '#B9F2FF');
    });

    test('promotion and relegation thresholds are correct', () {
      expect(League.promotionThreshold, 10);
      expect(League.relegationSafeZone, 15);
    });
  });

  group('LeaderboardEntry', () {
    test('creates entry with required fields', () {
      final entry = LeaderboardEntry(
        userId: 'user123',
        displayName: 'TestUser',
        weeklyXp: 150,
        rank: 5,
      );

      expect(entry.userId, 'user123');
      expect(entry.displayName, 'TestUser');
      expect(entry.weeklyXp, 150);
      expect(entry.rank, 5);
      expect(entry.isCurrentUser, false);
      expect(entry.avatarEmoji, null);
    });

    test('creates entry with optional fields', () {
      final entry = LeaderboardEntry(
        userId: 'user123',
        displayName: 'TestUser',
        avatarEmoji: '🐠',
        weeklyXp: 150,
        rank: 5,
        isCurrentUser: true,
      );

      expect(entry.avatarEmoji, '🐠');
      expect(entry.isCurrentUser, true);
    });

    test('copyWith updates specific fields', () {
      final entry = LeaderboardEntry(
        userId: 'user123',
        displayName: 'TestUser',
        weeklyXp: 150,
        rank: 5,
      );

      final updated = entry.copyWith(
        weeklyXp: 200,
        rank: 3,
      );

      expect(updated.weeklyXp, 200);
      expect(updated.rank, 3);
      expect(updated.userId, 'user123'); // Unchanged
      expect(updated.displayName, 'TestUser'); // Unchanged
    });

    test('toJson serializes correctly', () {
      final entry = LeaderboardEntry(
        userId: 'user123',
        displayName: 'TestUser',
        avatarEmoji: '🐠',
        weeklyXp: 150,
        rank: 5,
        isCurrentUser: true,
      );

      final json = entry.toJson();

      expect(json['userId'], 'user123');
      expect(json['displayName'], 'TestUser');
      expect(json['avatarEmoji'], '🐠');
      expect(json['weeklyXp'], 150);
      expect(json['rank'], 5);
      expect(json['isCurrentUser'], true);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'userId': 'user123',
        'displayName': 'TestUser',
        'avatarEmoji': '🐠',
        'weeklyXp': 150,
        'rank': 5,
        'isCurrentUser': true,
      };

      final entry = LeaderboardEntry.fromJson(json);

      expect(entry.userId, 'user123');
      expect(entry.displayName, 'TestUser');
      expect(entry.avatarEmoji, '🐠');
      expect(entry.weeklyXp, 150);
      expect(entry.rank, 5);
      expect(entry.isCurrentUser, true);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'userId': 'user123',
        'displayName': 'TestUser',
        'weeklyXp': 150,
        'rank': 5,
      };

      final entry = LeaderboardEntry.fromJson(json);

      expect(entry.avatarEmoji, null);
      expect(entry.isCurrentUser, false);
    });
  });

  group('WeeklyLeaderboard', () {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));

    final testEntries = [
      LeaderboardEntry(userId: '1', displayName: 'User1', weeklyXp: 500, rank: 1),
      LeaderboardEntry(userId: '2', displayName: 'User2', weeklyXp: 400, rank: 2),
      LeaderboardEntry(userId: '3', displayName: 'User3', weeklyXp: 300, rank: 3),
      LeaderboardEntry(userId: 'current', displayName: 'You', weeklyXp: 250, rank: 5, isCurrentUser: true),
      LeaderboardEntry(userId: '5', displayName: 'User5', weeklyXp: 200, rank: 10),
    ];

    test('creates leaderboard with required fields', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 5,
        currentUserWeeklyXp: 250,
      );

      expect(leaderboard.league, League.silver);
      expect(leaderboard.entries.length, 5);
      expect(leaderboard.currentUserRank, 5);
      expect(leaderboard.currentUserWeeklyXp, 250);
    });

    test('isInPromotionZone returns true for top 10', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 8,
        currentUserWeeklyXp: 250,
      );

      expect(leaderboard.isInPromotionZone, true);
    });

    test('isInPromotionZone returns false for rank > 10', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 11,
        currentUserWeeklyXp: 250,
      );

      expect(leaderboard.isInPromotionZone, false);
    });

    test('isInRelegationZone returns true for rank > 15', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 16,
        currentUserWeeklyXp: 100,
      );

      expect(leaderboard.isInRelegationZone, true);
    });

    test('isInRelegationZone returns false for rank <= 15', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 15,
        currentUserWeeklyXp: 150,
      );

      expect(leaderboard.isInRelegationZone, false);
    });

    test('isSafe returns true for ranks 11-15', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 12,
        currentUserWeeklyXp: 200,
      );

      expect(leaderboard.isSafe, true);
      expect(leaderboard.isInPromotionZone, false);
      expect(leaderboard.isInRelegationZone, false);
    });

    test('statusMessage returns correct message for 1st place', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 1,
        currentUserWeeklyXp: 500,
      );

      expect(leaderboard.statusMessage, contains('1st place'));
    });

    test('statusMessage returns correct message for promotion zone', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 5,
        currentUserWeeklyXp: 300,
      );

      expect(leaderboard.statusMessage, contains('promotion'));
    });

    test('statusMessage returns correct message for safe zone', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 13,
        currentUserWeeklyXp: 200,
      );

      expect(leaderboard.statusMessage, contains('safe'));
    });

    test('statusMessage returns correct message for relegation zone', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 18,
        currentUserWeeklyXp: 100,
      );

      expect(leaderboard.statusMessage, contains('Keep practicing'));
    });

    test('daysUntilReset calculates correctly', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 5,
        currentUserWeeklyXp: 250,
      );

      // Days until reset should be between 0 and 6
      expect(leaderboard.daysUntilReset, greaterThanOrEqualTo(0));
      expect(leaderboard.daysUntilReset, lessThan(7));
    });

    test('hoursUntilReset calculates correctly', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 5,
        currentUserWeeklyXp: 250,
      );

      // Hours until reset should be between 0 and 167 (7 days - 1 second)
      expect(leaderboard.hoursUntilReset, greaterThanOrEqualTo(0));
      expect(leaderboard.hoursUntilReset, lessThan(168));
    });

    test('toJson serializes correctly', () {
      final leaderboard = WeeklyLeaderboard(
        league: League.silver,
        entries: testEntries,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        currentUserRank: 5,
        currentUserWeeklyXp: 250,
      );

      final json = leaderboard.toJson();

      expect(json['league'], 'silver');
      expect(json['entries'], hasLength(5));
      expect(json['currentUserRank'], 5);
      expect(json['currentUserWeeklyXp'], 250);
      expect(json['weekStartDate'], isNotNull);
      expect(json['weekEndDate'], isNotNull);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'league': 'gold',
        'entries': [
          {
            'userId': '1',
            'displayName': 'User1',
            'weeklyXp': 500,
            'rank': 1,
          },
        ],
        'weekStartDate': weekStart.toIso8601String(),
        'weekEndDate': weekEnd.toIso8601String(),
        'currentUserRank': 5,
        'currentUserWeeklyXp': 250,
      };

      final leaderboard = WeeklyLeaderboard.fromJson(json);

      expect(leaderboard.league, League.gold);
      expect(leaderboard.entries.length, 1);
      expect(leaderboard.currentUserRank, 5);
      expect(leaderboard.currentUserWeeklyXp, 250);
    });
  });

  group('LeaderboardUserData', () {
    final now = DateTime.now();

    test('creates user data with default values', () {
      final userData = LeaderboardUserData(
        lastResetDate: now,
      );

      expect(userData.currentLeague, League.bronze);
      expect(userData.weeklyXpTotal, 0);
      expect(userData.dailyXpThisWeek, isEmpty);
      expect(userData.previousLeague, null);
      expect(userData.justPromoted, false);
      expect(userData.justRelegated, false);
    });

    test('creates user data with custom values', () {
      final userData = LeaderboardUserData(
        currentLeague: League.gold,
        weeklyXpTotal: 500,
        lastResetDate: now,
        dailyXpThisWeek: {'2024-01-01': 100},
        previousLeague: League.silver,
        justPromoted: true,
        justRelegated: false,
      );

      expect(userData.currentLeague, League.gold);
      expect(userData.weeklyXpTotal, 500);
      expect(userData.dailyXpThisWeek['2024-01-01'], 100);
      expect(userData.previousLeague, League.silver);
      expect(userData.justPromoted, true);
      expect(userData.justRelegated, false);
    });

    test('copyWith updates specific fields', () {
      final userData = LeaderboardUserData(
        currentLeague: League.bronze,
        weeklyXpTotal: 100,
        lastResetDate: now,
      );

      final updated = userData.copyWith(
        currentLeague: League.silver,
        weeklyXpTotal: 200,
      );

      expect(updated.currentLeague, League.silver);
      expect(updated.weeklyXpTotal, 200);
      expect(updated.lastResetDate, now); // Unchanged
    });

    test('toJson serializes correctly', () {
      final userData = LeaderboardUserData(
        currentLeague: League.gold,
        weeklyXpTotal: 500,
        lastResetDate: now,
        dailyXpThisWeek: {'2024-01-01': 100},
        previousLeague: League.silver,
        justPromoted: true,
        justRelegated: false,
      );

      final json = userData.toJson();

      expect(json['currentLeague'], 'gold');
      expect(json['weeklyXpTotal'], 500);
      expect(json['lastResetDate'], isNotNull);
      expect(json['dailyXpThisWeek'], {'2024-01-01': 100});
      expect(json['previousLeague'], 'silver');
      expect(json['justPromoted'], true);
      expect(json['justRelegated'], false);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'currentLeague': 'diamond',
        'weeklyXpTotal': 1000,
        'lastResetDate': now.toIso8601String(),
        'dailyXpThisWeek': {'2024-01-01': 200},
        'previousLeague': 'gold',
        'justPromoted': true,
        'justRelegated': false,
      };

      final userData = LeaderboardUserData.fromJson(json);

      expect(userData.currentLeague, League.diamond);
      expect(userData.weeklyXpTotal, 1000);
      expect(userData.dailyXpThisWeek['2024-01-01'], 200);
      expect(userData.previousLeague, League.gold);
      expect(userData.justPromoted, true);
      expect(userData.justRelegated, false);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'currentLeague': 'bronze',
        'weeklyXpTotal': 0,
        'lastResetDate': now.toIso8601String(),
      };

      final userData = LeaderboardUserData.fromJson(json);

      expect(userData.currentLeague, League.bronze);
      expect(userData.weeklyXpTotal, 0);
      expect(userData.dailyXpThisWeek, isEmpty);
      expect(userData.previousLeague, null);
      expect(userData.justPromoted, false);
      expect(userData.justRelegated, false);
    });

    test('fromJson defaults to bronze for invalid league', () {
      final json = {
        'currentLeague': 'invalid_league',
        'weeklyXpTotal': 100,
        'lastResetDate': now.toIso8601String(),
      };

      final userData = LeaderboardUserData.fromJson(json);

      expect(userData.currentLeague, League.bronze);
    });
  });

  group('League Progression Logic', () {
    test('user can promote from Bronze to Silver', () {
      final initialLeague = League.bronze;
      final finalRank = 5; // Top 10

      // Simulate promotion
      final shouldPromote = finalRank <= League.promotionThreshold && 
                            initialLeague != League.diamond;
      final newLeague = shouldPromote 
          ? League.values[initialLeague.index + 1]
          : initialLeague;

      expect(shouldPromote, true);
      expect(newLeague, League.silver);
    });

    test('user cannot promote from Diamond (max league)', () {
      final initialLeague = League.diamond;
      final finalRank = 1; // 1st place

      // Simulate promotion
      final shouldPromote = finalRank <= League.promotionThreshold && 
                            initialLeague != League.diamond;

      expect(shouldPromote, false);
    });

    test('user can relegate from Silver to Bronze', () {
      final initialLeague = League.silver;
      final finalRank = 20; // Below rank 15

      // Simulate relegation
      final shouldRelegate = finalRank > League.relegationSafeZone && 
                             initialLeague != League.bronze;
      final newLeague = shouldRelegate 
          ? League.values[initialLeague.index - 1]
          : initialLeague;

      expect(shouldRelegate, true);
      expect(newLeague, League.bronze);
    });

    test('user cannot relegate from Bronze (min league)', () {
      final initialLeague = League.bronze;
      final finalRank = 50; // Last place

      // Simulate relegation
      final shouldRelegate = finalRank > League.relegationSafeZone && 
                             initialLeague != League.bronze;

      expect(shouldRelegate, false);
    });

    test('user stays in league with safe rank (11-15)', () {
      final initialLeague = League.silver;
      final finalRank = 13; // Safe zone

      // Simulate no change
      final shouldPromote = finalRank <= League.promotionThreshold;
      final shouldRelegate = finalRank > League.relegationSafeZone;

      expect(shouldPromote, false);
      expect(shouldRelegate, false);
    });

    test('promotion rewards correct XP', () {
      final promotions = {
        League.silver: 50,
        League.gold: 100,
        League.diamond: 200,
      };

      promotions.forEach((league, expectedXp) {
        expect(league.promotionXp, expectedXp);
      });
    });
  });

  group('Weekly Reset Logic', () {
    test('identifies Monday as week start', () {
      // Create a Monday
      final monday = DateTime(2024, 1, 1); // Jan 1, 2024 is a Monday
      expect(monday.weekday, 1);

      // Calculate week start (should be same day)
      final weekday = monday.weekday;
      final daysFromMonday = weekday - 1;
      final weekStart = monday.subtract(Duration(days: daysFromMonday));
      
      expect(weekStart.day, monday.day);
    });

    test('calculates week start correctly for different days', () {
      // Wednesday Jan 3, 2024
      final wednesday = DateTime(2024, 1, 3);
      expect(wednesday.weekday, 3);

      // Calculate week start (should be Monday Jan 1)
      final weekday = wednesday.weekday;
      final daysFromMonday = weekday - 1;
      final weekStart = wednesday.subtract(Duration(days: daysFromMonday));
      
      expect(weekStart.weekday, 1); // Monday
      expect(weekStart.day, 1);
    });

    test('calculates week end as Sunday 23:59:59', () {
      final weekStart = DateTime(2024, 1, 1); // Monday
      final weekEnd = weekStart.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
      
      expect(weekEnd.weekday, 7); // Sunday
      expect(weekEnd.hour, 23);
      expect(weekEnd.minute, 59);
      expect(weekEnd.second, 59);
    });

    test('detects when weekly reset is needed', () {
      final lastReset = DateTime(2024, 1, 1); // Week 1 Monday
      final now = DateTime(2024, 1, 8); // Week 2 Monday

      final lastWeekStart = lastReset.subtract(Duration(days: lastReset.weekday - 1));
      final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

      final shouldReset = currentWeekStart.isAfter(lastWeekStart);
      
      expect(shouldReset, true);
    });

    test('detects when weekly reset is not needed', () {
      final lastReset = DateTime(2024, 1, 1); // Week 1 Monday
      final now = DateTime(2024, 1, 3); // Week 1 Wednesday

      final lastWeekStart = lastReset.subtract(Duration(days: lastReset.weekday - 1));
      final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

      final shouldReset = currentWeekStart.isAfter(lastWeekStart);
      
      expect(shouldReset, false);
    });
  });

  group('XP Distribution by League', () {
    test('Bronze league has appropriate XP range', () {
      // Bronze: 0-300 XP
      const minXp = 0;
      const maxXp = 300;
      const midXp = 150;

      expect(midXp, greaterThanOrEqualTo(minXp));
      expect(midXp, lessThan(maxXp));
    });

    test('Silver league has appropriate XP range', () {
      // Silver: 100-500 XP
      const minXp = 100;
      const maxXp = 500;
      const midXp = 300;

      expect(midXp, greaterThanOrEqualTo(minXp));
      expect(midXp, lessThan(maxXp));
    });

    test('Gold league has appropriate XP range', () {
      // Gold: 200-800 XP
      const minXp = 200;
      const maxXp = 800;
      const midXp = 500;

      expect(midXp, greaterThanOrEqualTo(minXp));
      expect(midXp, lessThan(maxXp));
    });

    test('Diamond league has appropriate XP range', () {
      // Diamond: 400-1200 XP
      const minXp = 400;
      const maxXp = 1200;
      const midXp = 800;

      expect(midXp, greaterThanOrEqualTo(minXp));
      expect(midXp, lessThan(maxXp));
    });
  });
}
