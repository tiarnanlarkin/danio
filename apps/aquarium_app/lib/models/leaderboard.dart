/// Leaderboard models for weekly competition system
/// Duolingo-style social competition to boost engagement
library;

import 'package:flutter/foundation.dart';

/// League tiers (Bronze → Silver → Gold → Diamond)
enum League {
  bronze,
  silver,
  gold,
  diamond;

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

  /// Color for league badge
  String get colorHex {
    switch (this) {
      case League.bronze:
        return '#CD7F32'; // Bronze
      case League.silver:
        return '#C0C0C0'; // Silver
      case League.gold:
        return '#FFD700'; // Gold
      case League.diamond:
        return '#B9F2FF'; // Diamond blue
    }
  }

  /// XP reward for promotion to this league
  int get promotionXp {
    switch (this) {
      case League.bronze:
        return 0; // Starting league
      case League.silver:
        return 50;
      case League.gold:
        return 100;
      case League.diamond:
        return 200;
    }
  }

  /// Minimum rank needed to promote (top 10)
  static const int promotionThreshold = 10;

  /// Minimum rank to stay safe (top 15)
  static const int relegationSafeZone = 15;
}

/// Individual entry in the leaderboard
@immutable
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? avatarEmoji; // Optional emoji avatar (e.g., '🐠', '🦈')
  final int weeklyXp;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.avatarEmoji,
    required this.weeklyXp,
    required this.rank,
    this.isCurrentUser = false,
  });

  LeaderboardEntry copyWith({
    String? userId,
    String? displayName,
    String? avatarEmoji,
    int? weeklyXp,
    int? rank,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      weeklyXp: weeklyXp ?? this.weeklyXp,
      rank: rank ?? this.rank,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'avatarEmoji': avatarEmoji,
        'weeklyXp': weeklyXp,
        'rank': rank,
        'isCurrentUser': isCurrentUser,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarEmoji: json['avatarEmoji'] as String?,
      weeklyXp: json['weeklyXp'] as int,
      rank: json['rank'] as int,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}

/// Weekly leaderboard state
@immutable
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

  /// Check if current user is in relegation danger zone (below 15)
  bool get isInRelegationZone => currentUserRank > League.relegationSafeZone;

  /// Check if current user is safe (11-15)
  bool get isSafe => !isInPromotionZone && !isInRelegationZone;

  /// Days until weekly reset
  int get daysUntilReset {
    final now = DateTime.now();
    return weekEndDate.difference(now).inDays;
  }

  /// Hours until weekly reset
  int get hoursUntilReset {
    final now = DateTime.now();
    final diff = weekEndDate.difference(now);
    return diff.inHours;
  }

  /// Get status message for current user
  String get statusMessage {
    if (currentUserRank == 1) {
      return '🏆 You\'re in 1st place!';
    } else if (isInPromotionZone) {
      return '🔥 On track for promotion!';
    } else if (isSafe) {
      return '✅ You\'re safe this week';
    } else {
      return '⚠️ Keep practicing to stay up';
    }
  }

  WeeklyLeaderboard copyWith({
    League? league,
    List<LeaderboardEntry>? entries,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
    int? currentUserRank,
    int? currentUserWeeklyXp,
  }) {
    return WeeklyLeaderboard(
      league: league ?? this.league,
      entries: entries ?? this.entries,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      currentUserRank: currentUserRank ?? this.currentUserRank,
      currentUserWeeklyXp: currentUserWeeklyXp ?? this.currentUserWeeklyXp,
    );
  }

  Map<String, dynamic> toJson() => {
        'league': league.name,
        'entries': entries.map((e) => e.toJson()).toList(),
        'weekStartDate': weekStartDate.toIso8601String(),
        'weekEndDate': weekEndDate.toIso8601String(),
        'currentUserRank': currentUserRank,
        'currentUserWeeklyXp': currentUserWeeklyXp,
      };

  factory WeeklyLeaderboard.fromJson(Map<String, dynamic> json) {
    return WeeklyLeaderboard(
      league: League.values.firstWhere(
        (e) => e.name == json['league'],
        orElse: () => League.bronze,
      ),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      currentUserRank: json['currentUserRank'] as int,
      currentUserWeeklyXp: json['currentUserWeeklyXp'] as int,
    );
  }
}

/// Leaderboard user data (stored locally)
@immutable
class LeaderboardUserData {
  final League currentLeague;
  final int weeklyXpTotal;
  final DateTime lastResetDate;
  final Map<String, int> dailyXpThisWeek; // 'YYYY-MM-DD' -> XP
  final League? previousLeague; // For tracking promotions/relegations
  final bool justPromoted; // Did user just get promoted this week
  final bool justRelegated; // Did user just get relegated this week

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
        'currentLeague': currentLeague.name,
        'weeklyXpTotal': weeklyXpTotal,
        'lastResetDate': lastResetDate.toIso8601String(),
        'dailyXpThisWeek': dailyXpThisWeek,
        'previousLeague': previousLeague?.name,
        'justPromoted': justPromoted,
        'justRelegated': justRelegated,
      };

  factory LeaderboardUserData.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserData(
      currentLeague: League.values.firstWhere(
        (e) => e.name == json['currentLeague'],
        orElse: () => League.bronze,
      ),
      weeklyXpTotal: json['weeklyXpTotal'] as int? ?? 0,
      lastResetDate: DateTime.parse(json['lastResetDate'] as String),
      dailyXpThisWeek: (json['dailyXpThisWeek'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          {},
      previousLeague: json['previousLeague'] != null
          ? League.values.firstWhere(
              (e) => e.name == json['previousLeague'],
              orElse: () => League.bronze,
            )
          : null,
      justPromoted: json['justPromoted'] as bool? ?? false,
      justRelegated: json['justRelegated'] as bool? ?? false,
    );
  }
}
