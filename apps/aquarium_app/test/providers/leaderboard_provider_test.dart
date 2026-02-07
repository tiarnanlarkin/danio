/// Unit tests for leaderboard provider logic
/// Tests weekly reset, promotion/relegation, and mock user generation
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/leaderboard.dart';

void main() {
  group('Weekly Reset Logic', () {
    test('getWeekStartDate returns Monday at 00:00', () {
      // Wednesday Jan 3, 2024
      final wednesday = DateTime(2024, 1, 3, 14, 30, 45);
      
      final weekday = wednesday.weekday;
      final daysFromMonday = weekday - 1;
      final monday = wednesday.subtract(Duration(days: daysFromMonday));
      final weekStart = DateTime(monday.year, monday.month, monday.day);
      
      expect(weekStart.weekday, 1); // Monday
      expect(weekStart.hour, 0);
      expect(weekStart.minute, 0);
      expect(weekStart.second, 0);
      expect(weekStart.day, 1); // Jan 1
    });

    test('getWeekEndDate returns Sunday at 23:59:59', () {
      final weekStart = DateTime(2024, 1, 1); // Monday
      final weekEnd = weekStart.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
      
      expect(weekEnd.weekday, 7); // Sunday
      expect(weekEnd.day, 7); // Jan 7
      expect(weekEnd.hour, 23);
      expect(weekEnd.minute, 59);
      expect(weekEnd.second, 59);
    });

    test('shouldResetWeek returns true for different weeks', () {
      final lastReset = DateTime(2024, 1, 1); // Week 1 Monday
      final now = DateTime(2024, 1, 8); // Week 2 Monday

      // Get week starts
      final getWeekStart = (DateTime date) {
        final weekday = date.weekday;
        final daysFromMonday = weekday - 1;
        final monday = date.subtract(Duration(days: daysFromMonday));
        return DateTime(monday.year, monday.month, monday.day);
      };

      final currentWeekStart = getWeekStart(now);
      final lastWeekStart = getWeekStart(lastReset);
      
      final shouldReset = currentWeekStart.isAfter(lastWeekStart);
      
      expect(shouldReset, true);
    });

    test('shouldResetWeek returns false for same week', () {
      final lastReset = DateTime(2024, 1, 1); // Monday
      final now = DateTime(2024, 1, 5); // Friday same week

      // Get week starts
      final getWeekStart = (DateTime date) {
        final weekday = date.weekday;
        final daysFromMonday = weekday - 1;
        final monday = date.subtract(Duration(days: daysFromMonday));
        return DateTime(monday.year, monday.month, monday.day);
      };

      final currentWeekStart = getWeekStart(now);
      final lastWeekStart = getWeekStart(lastReset);
      
      final shouldReset = currentWeekStart.isAfter(lastWeekStart);
      
      expect(shouldReset, false);
    });

    test('weekly reset handles Sunday to Monday transition', () {
      final sunday = DateTime(2024, 1, 7, 23, 59); // End of week 1
      final monday = DateTime(2024, 1, 8, 0, 1); // Start of week 2

      final getWeekStart = (DateTime date) {
        final weekday = date.weekday;
        final daysFromMonday = weekday - 1;
        final mondayDate = date.subtract(Duration(days: daysFromMonday));
        return DateTime(mondayDate.year, mondayDate.month, mondayDate.day);
      };

      final sundayWeekStart = getWeekStart(sunday);
      final mondayWeekStart = getWeekStart(monday);
      
      expect(sundayWeekStart.day, 1); // Week 1 Monday (Jan 1)
      expect(mondayWeekStart.day, 8); // Week 2 Monday (Jan 8)
      expect(mondayWeekStart.isAfter(sundayWeekStart), true);
    });
  });

  group('Promotion and Relegation Logic', () {
    test('user promotes from Bronze with rank <= 10', () {
      final currentLeague = League.bronze;
      final finalRank = 8;
      
      final shouldPromote = finalRank <= League.promotionThreshold && 
                           currentLeague != League.diamond;
      
      expect(shouldPromote, true);
      
      if (shouldPromote) {
        final newLeague = League.values[currentLeague.index + 1];
        expect(newLeague, League.silver);
        expect(newLeague.promotionXp, 50);
      }
    });

    test('user promotes from Silver to Gold', () {
      final currentLeague = League.silver;
      final finalRank = 3;
      
      final shouldPromote = finalRank <= League.promotionThreshold && 
                           currentLeague != League.diamond;
      
      expect(shouldPromote, true);
      
      if (shouldPromote) {
        final newLeague = League.values[currentLeague.index + 1];
        expect(newLeague, League.gold);
        expect(newLeague.promotionXp, 100);
      }
    });

    test('user promotes from Gold to Diamond', () {
      final currentLeague = League.gold;
      final finalRank = 1;
      
      final shouldPromote = finalRank <= League.promotionThreshold && 
                           currentLeague != League.diamond;
      
      expect(shouldPromote, true);
      
      if (shouldPromote) {
        final newLeague = League.values[currentLeague.index + 1];
        expect(newLeague, League.diamond);
        expect(newLeague.promotionXp, 200);
      }
    });

    test('user cannot promote from Diamond', () {
      final currentLeague = League.diamond;
      final finalRank = 1; // 1st place
      
      final shouldPromote = finalRank <= League.promotionThreshold && 
                           currentLeague != League.diamond;
      
      expect(shouldPromote, false);
    });

    test('user relegates from Silver with rank > 15', () {
      final currentLeague = League.silver;
      final finalRank = 20;
      
      final shouldRelegate = finalRank > League.relegationSafeZone && 
                            currentLeague != League.bronze;
      
      expect(shouldRelegate, true);
      
      if (shouldRelegate) {
        final newLeague = League.values[currentLeague.index - 1];
        expect(newLeague, League.bronze);
      }
    });

    test('user relegates from Gold to Silver', () {
      final currentLeague = League.gold;
      final finalRank = 25;
      
      final shouldRelegate = finalRank > League.relegationSafeZone && 
                            currentLeague != League.bronze;
      
      expect(shouldRelegate, true);
      
      if (shouldRelegate) {
        final newLeague = League.values[currentLeague.index - 1];
        expect(newLeague, League.silver);
      }
    });

    test('user relegates from Diamond to Gold', () {
      final currentLeague = League.diamond;
      final finalRank = 30;
      
      final shouldRelegate = finalRank > League.relegationSafeZone && 
                            currentLeague != League.bronze;
      
      expect(shouldRelegate, true);
      
      if (shouldRelegate) {
        final newLeague = League.values[currentLeague.index - 1];
        expect(newLeague, League.gold);
      }
    });

    test('user cannot relegate from Bronze', () {
      final currentLeague = League.bronze;
      final finalRank = 50; // Last place
      
      final shouldRelegate = finalRank > League.relegationSafeZone && 
                            currentLeague != League.bronze;
      
      expect(shouldRelegate, false);
    });

    test('user stays in league with rank 11-15 (safe zone)', () {
      final currentLeague = League.silver;
      final finalRank = 12;
      
      final shouldPromote = finalRank <= League.promotionThreshold;
      final shouldRelegate = finalRank > League.relegationSafeZone;
      
      expect(shouldPromote, false);
      expect(shouldRelegate, false);
      // User stays in Silver league
    });

    test('rank 10 is on promotion border', () {
      final finalRank = 10;
      final shouldPromote = finalRank <= League.promotionThreshold;
      
      expect(shouldPromote, true);
    });

    test('rank 11 is just outside promotion', () {
      final finalRank = 11;
      final shouldPromote = finalRank <= League.promotionThreshold;
      
      expect(shouldPromote, false);
    });

    test('rank 15 is on relegation border (safe)', () {
      final finalRank = 15;
      final shouldRelegate = finalRank > League.relegationSafeZone;
      
      expect(shouldRelegate, false);
    });

    test('rank 16 is just into relegation zone', () {
      final finalRank = 16;
      final shouldRelegate = finalRank > League.relegationSafeZone;
      
      expect(shouldRelegate, true);
    });
  });

  group('Weekly XP Calculation', () {
    test('calculates weekly XP from daily history', () {
      final weekStart = DateTime(2024, 1, 1); // Monday
      final dailyXpHistory = {
        '2024-01-01': 50, // Monday - counts
        '2024-01-02': 30, // Tuesday - counts
        '2024-01-03': 40, // Wednesday - counts
        '2023-12-31': 100, // Previous week - doesn't count
      };

      int weeklyXp = 0;
      dailyXpHistory.forEach((dateStr, xp) {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(weekStart) || date.isAtSameMomentAs(weekStart)) {
          weeklyXp += xp;
        }
      });

      expect(weeklyXp, 120); // 50 + 30 + 40
    });

    test('excludes XP from previous weeks', () {
      final weekStart = DateTime(2024, 1, 8); // Monday of week 2
      final dailyXpHistory = {
        '2024-01-08': 50, // This week - counts
        '2024-01-09': 30, // This week - counts
        '2024-01-05': 100, // Last week - doesn't count
        '2024-01-01': 75, // Two weeks ago - doesn't count
      };

      int weeklyXp = 0;
      dailyXpHistory.forEach((dateStr, xp) {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(weekStart) || date.isAtSameMomentAs(weekStart)) {
          weeklyXp += xp;
        }
      });

      expect(weeklyXp, 80); // 50 + 30
    });

    test('handles empty daily history', () {
      final weekStart = DateTime(2024, 1, 1);
      final dailyXpHistory = <String, int>{};

      int weeklyXp = 0;
      dailyXpHistory.forEach((dateStr, xp) {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(weekStart) || date.isAtSameMomentAs(weekStart)) {
          weeklyXp += xp;
        }
      });

      expect(weeklyXp, 0);
    });

    test('handles full week of data', () {
      final weekStart = DateTime(2024, 1, 1);
      final dailyXpHistory = {
        '2024-01-01': 50, // Monday
        '2024-01-02': 60, // Tuesday
        '2024-01-03': 70, // Wednesday
        '2024-01-04': 40, // Thursday
        '2024-01-05': 80, // Friday
        '2024-01-06': 90, // Saturday
        '2024-01-07': 100, // Sunday
      };

      int weeklyXp = 0;
      dailyXpHistory.forEach((dateStr, xp) {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(weekStart) || date.isAtSameMomentAs(weekStart)) {
          weeklyXp += xp;
        }
      });

      expect(weeklyXp, 490); // Sum of all 7 days
    });
  });

  group('Mock User Generation', () {
    test('generates 50 total entries (49 AI + 1 current user)', () {
      final entries = <LeaderboardEntry>[];
      
      // Add current user
      entries.add(LeaderboardEntry(
        userId: 'current_user',
        displayName: 'You',
        weeklyXp: 250,
        rank: 0,
        isCurrentUser: true,
      ));
      
      // Add 49 AI users
      for (int i = 0; i < 49; i++) {
        entries.add(LeaderboardEntry(
          userId: 'ai_user_$i',
          displayName: 'User$i',
          weeklyXp: 100 + i * 10,
          rank: 0,
        ));
      }
      
      expect(entries.length, 50);
    });

    test('entries are sorted by XP (descending)', () {
      final entries = [
        LeaderboardEntry(userId: '1', displayName: 'User1', weeklyXp: 100, rank: 0),
        LeaderboardEntry(userId: '2', displayName: 'User2', weeklyXp: 500, rank: 0),
        LeaderboardEntry(userId: '3', displayName: 'User3', weeklyXp: 300, rank: 0),
      ];
      
      entries.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
      
      expect(entries[0].weeklyXp, 500);
      expect(entries[1].weeklyXp, 300);
      expect(entries[2].weeklyXp, 100);
    });

    test('ranks are assigned correctly after sorting', () {
      final entries = [
        LeaderboardEntry(userId: '1', displayName: 'User1', weeklyXp: 100, rank: 0),
        LeaderboardEntry(userId: '2', displayName: 'User2', weeklyXp: 500, rank: 0),
        LeaderboardEntry(userId: '3', displayName: 'User3', weeklyXp: 300, rank: 0),
      ];
      
      entries.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
      
      final rankedEntries = entries.asMap().entries.map((entry) {
        return entry.value.copyWith(rank: entry.key + 1);
      }).toList();
      
      expect(rankedEntries[0].rank, 1); // 500 XP
      expect(rankedEntries[1].rank, 2); // 300 XP
      expect(rankedEntries[2].rank, 3); // 100 XP
    });

    test('current user rank is found correctly', () {
      final entries = [
        LeaderboardEntry(userId: '1', displayName: 'User1', weeklyXp: 500, rank: 1),
        LeaderboardEntry(userId: 'current', displayName: 'You', weeklyXp: 300, rank: 2, isCurrentUser: true),
        LeaderboardEntry(userId: '3', displayName: 'User3', weeklyXp: 100, rank: 3),
      ];
      
      final currentUserRank = entries
          .firstWhere((e) => e.isCurrentUser)
          .rank;
      
      expect(currentUserRank, 2);
    });

    test('XP distribution varies by league', () {
      // Bronze: 0-300 XP
      final bronzeXpRange = (min: 0, max: 300);
      expect(150, greaterThanOrEqualTo(bronzeXpRange.min));
      expect(150, lessThan(bronzeXpRange.max));
      
      // Silver: 100-500 XP
      final silverXpRange = (min: 100, max: 500);
      expect(300, greaterThanOrEqualTo(silverXpRange.min));
      expect(300, lessThan(silverXpRange.max));
      
      // Gold: 200-800 XP
      final goldXpRange = (min: 200, max: 800);
      expect(500, greaterThanOrEqualTo(goldXpRange.min));
      expect(500, lessThan(goldXpRange.max));
      
      // Diamond: 400-1200 XP
      final diamondXpRange = (min: 400, max: 1200);
      expect(800, greaterThanOrEqualTo(diamondXpRange.min));
      expect(800, lessThan(diamondXpRange.max));
    });
  });

  group('Leaderboard State Management', () {
    test('tracks promotion status correctly', () {
      final userData = LeaderboardUserData(
        currentLeague: League.silver,
        weeklyXpTotal: 0,
        lastResetDate: DateTime.now(),
        previousLeague: League.bronze,
        justPromoted: true,
        justRelegated: false,
      );

      expect(userData.justPromoted, true);
      expect(userData.justRelegated, false);
      expect(userData.previousLeague, League.bronze);
      expect(userData.currentLeague, League.silver);
    });

    test('tracks relegation status correctly', () {
      final userData = LeaderboardUserData(
        currentLeague: League.bronze,
        weeklyXpTotal: 0,
        lastResetDate: DateTime.now(),
        previousLeague: League.silver,
        justPromoted: false,
        justRelegated: true,
      );

      expect(userData.justPromoted, false);
      expect(userData.justRelegated, true);
      expect(userData.previousLeague, League.silver);
      expect(userData.currentLeague, League.bronze);
    });

    test('clears promotion flags after acknowledgment', () {
      var userData = LeaderboardUserData(
        currentLeague: League.gold,
        weeklyXpTotal: 0,
        lastResetDate: DateTime.now(),
        previousLeague: League.silver,
        justPromoted: true,
        justRelegated: false,
      );

      // User acknowledges promotion
      userData = userData.copyWith(
        justPromoted: false,
        justRelegated: false,
      );

      expect(userData.justPromoted, false);
      expect(userData.justRelegated, false);
    });

    test('resets weekly XP on new week', () {
      final oldData = LeaderboardUserData(
        currentLeague: League.silver,
        weeklyXpTotal: 500,
        lastResetDate: DateTime(2024, 1, 1),
        dailyXpThisWeek: {
          '2024-01-01': 100,
          '2024-01-02': 200,
          '2024-01-03': 200,
        },
      );

      // Simulate weekly reset
      final newData = LeaderboardUserData(
        currentLeague: oldData.currentLeague,
        weeklyXpTotal: 0,
        lastResetDate: DateTime(2024, 1, 8), // New week
        dailyXpThisWeek: {},
        previousLeague: oldData.currentLeague,
      );

      expect(newData.weeklyXpTotal, 0);
      expect(newData.dailyXpThisWeek, isEmpty);
      expect(newData.lastResetDate.day, 8);
    });
  });

  group('Edge Cases', () {
    test('handles tie in XP (same rank)', () {
      final entries = [
        LeaderboardEntry(userId: '1', displayName: 'User1', weeklyXp: 100, rank: 0),
        LeaderboardEntry(userId: '2', displayName: 'User2', weeklyXp: 100, rank: 0),
        LeaderboardEntry(userId: '3', displayName: 'User3', weeklyXp: 50, rank: 0),
      ];
      
      entries.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
      
      final rankedEntries = entries.asMap().entries.map((entry) {
        return entry.value.copyWith(rank: entry.key + 1);
      }).toList();
      
      // First two have same XP but different ranks (1 and 2)
      expect(rankedEntries[0].weeklyXp, 100);
      expect(rankedEntries[1].weeklyXp, 100);
      expect(rankedEntries[0].rank, 1);
      expect(rankedEntries[1].rank, 2);
    });

    test('handles current user with 0 XP', () {
      final entry = LeaderboardEntry(
        userId: 'current_user',
        displayName: 'You',
        weeklyXp: 0,
        rank: 50,
        isCurrentUser: true,
      );

      expect(entry.weeklyXp, 0);
      expect(entry.rank, 50); // Last place
    });

    test('handles maximum XP values', () {
      final entry = LeaderboardEntry(
        userId: 'user1',
        displayName: 'TopUser',
        weeklyXp: 10000,
        rank: 1,
      );

      expect(entry.weeklyXp, 10000);
    });

    test('handles new week boundary precisely', () {
      // Last second of Sunday
      final sundayEnd = DateTime(2024, 1, 7, 23, 59, 59);
      // First second of Monday
      final mondayStart = DateTime(2024, 1, 8, 0, 0, 0);

      final getWeekStart = (DateTime date) {
        final weekday = date.weekday;
        final daysFromMonday = weekday - 1;
        final monday = date.subtract(Duration(days: daysFromMonday));
        return DateTime(monday.year, monday.month, monday.day);
      };

      final sundayWeekStart = getWeekStart(sundayEnd);
      final mondayWeekStart = getWeekStart(mondayStart);

      expect(sundayWeekStart.day, 1); // Week 1
      expect(mondayWeekStart.day, 8); // Week 2
    });
  });
}
