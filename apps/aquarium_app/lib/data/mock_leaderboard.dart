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
    entries.add(
      LeaderboardEntry(
        userId: currentUserId,
        displayName: currentUsername,
        weeklyXp: currentUserXP,
        rank: 0, // Will be calculated after sorting
        isCurrentUser: true,
      ),
    );

    // Generate 49 mock users
    // Shuffle usernames and use them in order to avoid infinite loop
    final availableNames = List<String>.from(_usernames)..shuffle(_random);
    int nameIndex = 0;

    for (var i = 0; i < 49; i++) {
      // Pick username - cycle through shuffled list if needed
      String username;
      if (nameIndex < availableNames.length) {
        username = availableNames[nameIndex];
        nameIndex++;
      } else {
        // Ran out of unique names - add number suffix
        username =
            '${availableNames[i % availableNames.length]}${i ~/ availableNames.length + 1}';
      }

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

      entries.add(
        LeaderboardEntry(
          userId: 'mock_${i + 1}',
          displayName: username,
          weeklyXp: xp,
          rank: 0,
        ),
      );
    }

    // Sort by XP (descending) and assign ranks
    entries.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
    final rankedEntries = <LeaderboardEntry>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      rankedEntries.add(entry.copyWith(rank: i + 1));
    }

    return rankedEntries;
  }
}
