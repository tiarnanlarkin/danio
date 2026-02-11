/// Complete social features models
/// Combines friend features, activity feed, and friend requests
library;

import 'package:flutter/foundation.dart';

// Re-export friend models for convenience
export 'friend.dart';

/// Friend request status
enum FriendRequestStatus {
  pending,
  accepted,
  rejected;

  String get displayName {
    switch (this) {
      case FriendRequestStatus.pending:
        return 'Pending';
      case FriendRequestStatus.accepted:
        return 'Accepted';
      case FriendRequestStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isPending => this == FriendRequestStatus.pending;
  bool get isAccepted => this == FriendRequestStatus.accepted;
  bool get isRejected => this == FriendRequestStatus.rejected;
}

/// Friend request model
@immutable
class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromUsername;
  final String fromDisplayName;
  final String? fromAvatarEmoji;
  final String toUserId;
  final String toUsername;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? message; // Optional message with request

  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    required this.fromDisplayName,
    this.fromAvatarEmoji,
    required this.toUserId,
    required this.toUsername,
    this.status = FriendRequestStatus.pending,
    required this.createdAt,
    this.respondedAt,
    this.message,
  });

  /// Check if request is from current user
  bool isFromUser(String userId) => fromUserId == userId;

  /// Check if request is to current user
  bool isToUser(String userId) => toUserId == userId;

  /// Get time ago string for request
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${(diff.inDays / 7).floor()}w ago';
    }
  }

  FriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? fromUsername,
    String? fromDisplayName,
    String? fromAvatarEmoji,
    String? toUserId,
    String? toUsername,
    FriendRequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? message,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUsername: fromUsername ?? this.fromUsername,
      fromDisplayName: fromDisplayName ?? this.fromDisplayName,
      fromAvatarEmoji: fromAvatarEmoji ?? this.fromAvatarEmoji,
      toUserId: toUserId ?? this.toUserId,
      toUsername: toUsername ?? this.toUsername,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUserId': fromUserId,
    'fromUsername': fromUsername,
    'fromDisplayName': fromDisplayName,
    'fromAvatarEmoji': fromAvatarEmoji,
    'toUserId': toUserId,
    'toUsername': toUsername,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'respondedAt': respondedAt?.toIso8601String(),
    'message': message,
  };

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUsername: json['fromUsername'] as String,
      fromDisplayName: json['fromDisplayName'] as String,
      fromAvatarEmoji: json['fromAvatarEmoji'] as String?,
      toUserId: json['toUserId'] as String,
      toUsername: json['toUsername'] as String,
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
      message: json['message'] as String?,
    );
  }
}

/// Weekly XP comparison data
@immutable
class WeeklyComparison {
  final String userId;
  final String username;
  final int weeklyXP;
  final int rank;
  final List<DailyXP> dailyBreakdown;

  const WeeklyComparison({
    required this.userId,
    required this.username,
    required this.weeklyXP,
    required this.rank,
    required this.dailyBreakdown,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'weeklyXP': weeklyXP,
    'rank': rank,
    'dailyBreakdown': dailyBreakdown.map((d) => d.toJson()).toList(),
  };

  factory WeeklyComparison.fromJson(Map<String, dynamic> json) {
    return WeeklyComparison(
      userId: json['userId'] as String,
      username: json['username'] as String,
      weeklyXP: json['weeklyXP'] as int,
      rank: json['rank'] as int,
      dailyBreakdown: (json['dailyBreakdown'] as List<dynamic>)
          .map((e) => DailyXP.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Daily XP data point
@immutable
class DailyXP {
  final DateTime date;
  final int xp;

  const DailyXP({required this.date, required this.xp});

  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'xp': xp};

  factory DailyXP.fromJson(Map<String, dynamic> json) {
    return DailyXP(
      date: DateTime.parse(json['date'] as String),
      xp: json['xp'] as int,
    );
  }
}

/// Challenge between friends
@immutable
class FriendChallenge {
  final String id;
  final String challengerId;
  final String challengerName;
  final String opponentId;
  final String opponentName;
  final ChallengeType type;
  final int targetValue;
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeStatus status;
  final int? challengerProgress;
  final int? opponentProgress;

  const FriendChallenge({
    required this.id,
    required this.challengerId,
    required this.challengerName,
    required this.opponentId,
    required this.opponentName,
    required this.type,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
    this.status = ChallengeStatus.active,
    this.challengerProgress,
    this.opponentProgress,
  });

  String? get winner {
    if (status != ChallengeStatus.completed) return null;
    if (challengerProgress == null || opponentProgress == null) return null;

    if (challengerProgress! > opponentProgress!) return challengerId;
    if (opponentProgress! > challengerProgress!) return opponentId;
    return null; // Tie
  }

  bool get isTie =>
      status == ChallengeStatus.completed &&
      challengerProgress == opponentProgress;

  Map<String, dynamic> toJson() => {
    'id': id,
    'challengerId': challengerId,
    'challengerName': challengerName,
    'opponentId': opponentId,
    'opponentName': opponentName,
    'type': type.name,
    'targetValue': targetValue,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'status': status.name,
    'challengerProgress': challengerProgress,
    'opponentProgress': opponentProgress,
  };

  factory FriendChallenge.fromJson(Map<String, dynamic> json) {
    return FriendChallenge(
      id: json['id'] as String,
      challengerId: json['challengerId'] as String,
      challengerName: json['challengerName'] as String,
      opponentId: json['opponentId'] as String,
      opponentName: json['opponentName'] as String,
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.weeklyXP,
      ),
      targetValue: json['targetValue'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChallengeStatus.active,
      ),
      challengerProgress: json['challengerProgress'] as int?,
      opponentProgress: json['opponentProgress'] as int?,
    );
  }
}

/// Types of challenges
enum ChallengeType {
  weeklyXP,
  dailyStreak,
  lessonsCompleted,
  achievementsUnlocked;

  String get displayName {
    switch (this) {
      case ChallengeType.weeklyXP:
        return 'Weekly XP';
      case ChallengeType.dailyStreak:
        return 'Daily Streak';
      case ChallengeType.lessonsCompleted:
        return 'Lessons Completed';
      case ChallengeType.achievementsUnlocked:
        return 'Achievements Unlocked';
    }
  }

  String get emoji {
    switch (this) {
      case ChallengeType.weeklyXP:
        return '⭐';
      case ChallengeType.dailyStreak:
        return '🔥';
      case ChallengeType.lessonsCompleted:
        return '📚';
      case ChallengeType.achievementsUnlocked:
        return '🏆';
    }
  }
}

/// Challenge status
enum ChallengeStatus {
  pending,
  active,
  completed,
  expired,
  declined;

  String get displayName {
    switch (this) {
      case ChallengeStatus.pending:
        return 'Pending';
      case ChallengeStatus.active:
        return 'Active';
      case ChallengeStatus.completed:
        return 'Completed';
      case ChallengeStatus.expired:
        return 'Expired';
      case ChallengeStatus.declined:
        return 'Declined';
    }
  }
}
