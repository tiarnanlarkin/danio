import 'dart:math';
import '../models/leaderboard.dart';

/// Generate mock leaderboard data for demonstration
class MockLeaderboard {
  static final _random = Random();

  /// Creative fishkeeping-themed usernames
  static const _usernames = [
    'AquaAddict',
    'PlantedTankPro',
    'ShrimpsRule',
    'CichlidKing',
    'BettaBoss',
    'CoralReefDreamer',
    'GuppyGuru',
    'SnailWhisperer',
    'AlgaeAssassin',
    'TetraFanatic',
    'NeonNinja',
    'AngelFishAngel',
    'DiscusDoctor',
    'KoiKeeper',
    'TangTamer',
    'LoachLover',
    'CatfishCaptain',
    'GoldfishGod',
    'RasboraRanger',
    'PlecoPatrol',
    'DanioDriver',
    'BarbBuddy',
    'MolliesMaster',
    'SwordtailSage',
    'GouramiGang',
    'RainbowFishFan',
    'PufferPal',
    'KillifishKnight',
    'OscarOwner',
    'CrayfishCrew',
  ];

  /// Generate mock leaderboard entries
  /// 
  /// Creates 50 users with realistic XP distribution:
  /// - Current user placed in middle range
  /// - Top users have high XP (600-1200)
  /// - Middle users moderate XP (200-600)
  /// - Bottom users lower XP (50-200)
  static List<LeaderboardEntry> generate({
    required String currentUserId,
    required String currentUsername,
    required int currentUserXP,
    required League currentUserLeague,
  }) {
    final entries = <LeaderboardEntry>[];

    // Add current user
    entries.add(LeaderboardEntry(
      userId: currentUserId,
      username: currentUsername,
      weeklyXP: currentUserXP,
      rank: 0, // Will be calculated after sorting
      league: currentUserLeague,
      isCurrentUser: true,
    ));

    // Generate 49 mock users
    final usedNames = {currentUsername};
    for (var i = 0; i < 49; i++) {
      // Pick unique username
      String username;
      do {
        username = _usernames[_random.nextInt(_usernames.length)];
      } while (usedNames.contains(username));
      usedNames.add(username);

      // Generate XP based on position
      final int xp;
      if (i < 15) {
        // Top tier: 600-1200 XP
        xp = 600 + _random.nextInt(600);
      } else if (i < 35) {
        // Middle tier: 200-600 XP
        xp = 200 + _random.nextInt(400);
      } else {
        // Bottom tier: 50-200 XP
        xp = 50 + _random.nextInt(150);
      }

      // Determine league based on XP
      final league = _leagueForXP(xp);

      entries.add(LeaderboardEntry(
        userId: 'mock_${i + 1}',
        username: username,
        weeklyXP: xp,
        rank: 0,
        league: league,
      ));
    }

    // Sort by XP (descending) and assign ranks
    entries.sort((a, b) => b.weeklyXP.compareTo(a.weeklyXP));
    final rankedEntries = <LeaderboardEntry>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      rankedEntries.add(entry.copyWith(rank: i + 1));
    }

    return rankedEntries;
  }

  /// Determine league tier based on weekly XP
  static League _leagueForXP(int xp) {
    if (xp >= League.diamond.minWeeklyXP) return League.diamond;
    if (xp >= League.gold.minWeeklyXP) return League.gold;
    if (xp >= League.silver.minWeeklyXP) return League.silver;
    return League.bronze;
  }
}
