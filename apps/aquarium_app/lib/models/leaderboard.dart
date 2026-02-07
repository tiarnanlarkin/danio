/// Leaderboard and competitive ranking models
library;


/// League tier for competitive ranking
enum League {
  bronze,
  silver,
  gold,
  diamond;

  String get displayName {
    switch (this) {
      case League.bronze:
        return 'Bronze';
      case League.silver:
        return 'Silver';
      case League.gold:
        return 'Gold';
      case League.diamond:
        return 'Diamond';
    }
  }

  /// XP threshold to enter this league
  int get minWeeklyXP {
    switch (this) {
      case League.bronze:
        return 0;
      case League.silver:
        return 300;
      case League.gold:
        return 800;
      case League.diamond:
        return 1500;
    }
  }

  String toJson() => name;
  
  static League fromJson(String value) {
    return League.values.firstWhere((e) => e.name == value);
  }
}

/// Entry in the weekly leaderboard
class LeaderboardEntry {
  final String userId;
  final String username;
  final int weeklyXP;
  final int rank;
  final League league;
  final String? avatarUrl;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.weeklyXP,
    required this.rank,
    required this.league,
    this.avatarUrl,
    this.isCurrentUser = false,
  });

  LeaderboardEntry copyWith({
    String? userId,
    String? username,
    int? weeklyXP,
    int? rank,
    League? league,
    String? avatarUrl,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      weeklyXP: weeklyXP ?? this.weeklyXP,
      rank: rank ?? this.rank,
      league: league ?? this.league,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'weeklyXP': weeklyXP,
        'rank': rank,
        'league': league.toJson(),
        'avatarUrl': avatarUrl,
        'isCurrentUser': isCurrentUser,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      username: json['username'] as String,
      weeklyXP: json['weeklyXP'] as int,
      rank: json['rank'] as int,
      league: League.fromJson(json['league'] as String),
      avatarUrl: json['avatarUrl'] as String?,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}

/// Weekly competition period
class WeekPeriod {
  final DateTime start;
  final DateTime end;

  const WeekPeriod({
    required this.start,
    required this.end,
  });

  /// Get current week period (Monday 00:00 to Sunday 23:59)
  static WeekPeriod current() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);
    final end = start.add(const Duration(days: 7)).subtract(const Duration(microseconds: 1));
    return WeekPeriod(start: start, end: end);
  }

  /// Time remaining until week ends
  Duration get timeRemaining => end.difference(DateTime.now());

  /// Whether this period is the current week
  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  factory WeekPeriod.fromJson(Map<String, dynamic> json) {
    return WeekPeriod(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }
}

/// Promotion/demotion thresholds
class LeagueThresholds {
  static const int topPromotion = 3; // Top 3 users get promoted
  static const int bottomDemotion = 3; // Bottom 3 users get demoted

  /// Calculate new league based on rank and current league
  static League? calculateNewLeague(int rank, int totalUsers, League currentLeague) {
    // Promote top 3 (unless already in Diamond)
    if (rank <= topPromotion && currentLeague != League.diamond) {
      final leagues = League.values;
      final currentIndex = leagues.indexOf(currentLeague);
      if (currentIndex < leagues.length - 1) {
        return leagues[currentIndex + 1];
      }
    }

    // Demote bottom 3 (unless already in Bronze)
    if (rank > totalUsers - bottomDemotion && currentLeague != League.bronze) {
      final leagues = League.values;
      final currentIndex = leagues.indexOf(currentLeague);
      if (currentIndex > 0) {
        return leagues[currentIndex - 1];
      }
    }

    // No change
    return null;
  }
}
