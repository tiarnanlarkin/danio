import 'package:flutter/foundation.dart';

/// Leaderboard and competitive ranking models
library;

/// League tier for competitive ranking
enum League {
  bronze,
  silver,
  gold,
  diamond;

  /// Promotion and relegation constants
  static const int promotionThreshold = 10;
  static const int relegationSafeZone = 15;

  String get displayName {
    switch (this) {
      case League.bronze:
        return 'Bronze League';
      case League.silver:
        return 'Silver League';
      case League.gold:
        return 'Gold League';
      case League.diamond:
        return 'Diamond League';
    }
  }

  String get emoji {
    switch (this) {
      case League.bronze:
        return '🥉';
      case League.silver:
        return '🥈';
      case League.gold:
        return '🥇';
      case League.diamond:
        return '💎';
    }
  }

  String get colorHex {
    switch (this) {
      case League.bronze:
        return '#CD7F32';
      case League.silver:
        return '#C0C0C0';
      case League.gold:
        return '#FFD700';
      case League.diamond:
        return '#B9F2FF';
    }
  }

  int get promotionXp {
    switch (this) {
      case League.bronze:
        return 0;
      case League.silver:
        return 50;
      case League.gold:
        return 100;
      case League.diamond:
        return 200;
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
    return League.values.firstWhere(
      (e) => e.name == value,
      orElse: () => League.bronze,
    );
  }
}

/// Entry in the weekly leaderboard
@immutable
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int weeklyXp;
  final int rank;
  final String? avatarEmoji;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.weeklyXp,
    required this.rank,
    this.avatarEmoji,
    this.isCurrentUser = false,
  });

  LeaderboardEntry copyWith({
    String? userId,
    String? displayName,
    int? weeklyXp,
    int? rank,
    String? avatarEmoji,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      weeklyXp: weeklyXp ?? this.weeklyXp,
      rank: rank ?? this.rank,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'displayName': displayName,
    'weeklyXp': weeklyXp,
    'rank': rank,
    'avatarEmoji': avatarEmoji,
    'isCurrentUser': isCurrentUser,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      weeklyXp: json['weeklyXp'] as int,
      rank: json['rank'] as int,
      avatarEmoji: json['avatarEmoji'] as String?,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}

/// Weekly leaderboard data
class WeeklyLeaderboard {
  final League league;
  final List<LeaderboardEntry> entries;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final int currentUserRank;
  final int currentUserWeeklyXp;

  const WeeklyLeaderboard({
    required this.league,
    required this.entries,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.currentUserRank,
    required this.currentUserWeeklyXp,
  });

  /// Check if current user is in promotion zone (top 10)
  bool get isInPromotionZone => currentUserRank <= League.promotionThreshold;

  /// Check if current user is in relegation zone (below rank 15)
  bool get isInRelegationZone => currentUserRank > League.relegationSafeZone;

  /// Check if current user is in safe zone (ranks 11-15)
  bool get isSafe => !isInPromotionZone && !isInRelegationZone;

  /// Get status message based on current rank
  String get statusMessage {
    if (currentUserRank == 1) {
      return '🏆 You\'re in 1st place! Keep it up!';
    } else if (isInPromotionZone) {
      return '⬆️ You\'re on track for promotion to ${_nextLeague()}!';
    } else if (isSafe) {
      return '✅ You\'re safe this week';
    } else {
      return '⚠️ Keep practicing to avoid relegation';
    }
  }

  /// Days until weekly reset
  int get daysUntilReset {
    final now = DateTime.now();
    final diff = weekEndDate.difference(now);
    return diff.inDays;
  }

  /// Hours until weekly reset
  int get hoursUntilReset {
    final now = DateTime.now();
    final diff = weekEndDate.difference(now);
    return diff.inHours;
  }

  String _nextLeague() {
    final leagues = League.values;
    final currentIndex = leagues.indexOf(league);
    if (currentIndex < leagues.length - 1) {
      return leagues[currentIndex + 1].displayName;
    }
    return league.displayName;
  }

  Map<String, dynamic> toJson() => {
    'league': league.toJson(),
    'entries': entries.map((e) => e.toJson()).toList(),
    'weekStartDate': weekStartDate.toIso8601String(),
    'weekEndDate': weekEndDate.toIso8601String(),
    'currentUserRank': currentUserRank,
    'currentUserWeeklyXp': currentUserWeeklyXp,
  };

  factory WeeklyLeaderboard.fromJson(Map<String, dynamic> json) {
    return WeeklyLeaderboard(
      league: League.fromJson(json['league'] as String),
      entries: (json['entries'] as List)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      currentUserRank: json['currentUserRank'] as int,
      currentUserWeeklyXp: json['currentUserWeeklyXp'] as int,
    );
  }
}

/// User's leaderboard data
class LeaderboardUserData {
  final League currentLeague;
  final int weeklyXpTotal;
  final DateTime lastResetDate;
  final Map<String, int> dailyXpThisWeek;
  final League? previousLeague;
  final bool justPromoted;
  final bool justRelegated;

  const LeaderboardUserData({
    this.currentLeague = League.bronze,
    this.weeklyXpTotal = 0,
    required this.lastResetDate,
    this.dailyXpThisWeek = const {},
    this.previousLeague,
    this.justPromoted = false,
    this.justRelegated = false,
  });

  LeaderboardUserData copyWith({
    League? currentLeague,
    int? weeklyXpTotal,
    DateTime? lastResetDate,
    Map<String, int>? dailyXpThisWeek,
    League? previousLeague,
    bool? justPromoted,
    bool? justRelegated,
  }) {
    return LeaderboardUserData(
      currentLeague: currentLeague ?? this.currentLeague,
      weeklyXpTotal: weeklyXpTotal ?? this.weeklyXpTotal,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      dailyXpThisWeek: dailyXpThisWeek ?? this.dailyXpThisWeek,
      previousLeague: previousLeague ?? this.previousLeague,
      justPromoted: justPromoted ?? this.justPromoted,
      justRelegated: justRelegated ?? this.justRelegated,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentLeague': currentLeague.toJson(),
    'weeklyXpTotal': weeklyXpTotal,
    'lastResetDate': lastResetDate.toIso8601String(),
    'dailyXpThisWeek': dailyXpThisWeek,
    'previousLeague': previousLeague?.toJson(),
    'justPromoted': justPromoted,
    'justRelegated': justRelegated,
  };

  factory LeaderboardUserData.fromJson(Map<String, dynamic> json) {
    League? parseLeague(String? value) {
      if (value == null) return null;
      try {
        return League.fromJson(value);
      } catch (e) {
        return null;
      }
    }

    return LeaderboardUserData(
      currentLeague:
          parseLeague(json['currentLeague'] as String?) ?? League.bronze,
      weeklyXpTotal: json['weeklyXpTotal'] as int? ?? 0,
      lastResetDate: DateTime.parse(json['lastResetDate'] as String),
      dailyXpThisWeek: json['dailyXpThisWeek'] != null
          ? Map<String, int>.from(json['dailyXpThisWeek'] as Map)
          : const {},
      previousLeague: parseLeague(json['previousLeague'] as String?),
      justPromoted: json['justPromoted'] as bool? ?? false,
      justRelegated: json['justRelegated'] as bool? ?? false,
    );
  }
}

/// Weekly competition period
class WeekPeriod {
  final DateTime start;
  final DateTime end;

  const WeekPeriod({required this.start, required this.end});

  /// Get current week period (Monday 00:00 to Sunday 23:59)
  static WeekPeriod current() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);
    final end = start
        .add(const Duration(days: 7))
        .subtract(const Duration(microseconds: 1));
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
@immutable
class LeagueThresholds {
  static const int topPromotion = 3; // Top 3 users get promoted
  static const int bottomDemotion = 3; // Bottom 3 users get demoted

  /// Calculate new league based on rank and current league
  static League? calculateNewLeague(
    int rank,
    int totalUsers,
    League currentLeague,
  ) {
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
