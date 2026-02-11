/// Friend model for social features
/// Enables users to follow friends, compare progress, and see activity
library;

import 'package:flutter/foundation.dart';

/// Friend user model
@immutable
class Friend {
  final String id;
  final String username;
  final String displayName;
  final String? avatarEmoji; // Optional emoji avatar (e.g., '🐠', '🦈')

  // Stats
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final String levelTitle; // 'Beginner', 'Expert', etc.
  final int currentLevel;

  // Social
  final DateTime friendsSince;
  final DateTime? lastActiveDate;
  final bool isOnline; // Mock field for UI

  // Achievements
  final List<String> achievements; // Achievement IDs
  final int totalAchievements;

  const Friend({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarEmoji,
    required this.totalXp,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.levelTitle,
    required this.currentLevel,
    required this.friendsSince,
    this.lastActiveDate,
    this.isOnline = false,
    this.achievements = const [],
    this.totalAchievements = 0,
  });

  /// Check if friend was active recently (within 24 hours)
  bool get isRecentlyActive {
    if (lastActiveDate == null) return false;
    final now = DateTime.now();
    return now.difference(lastActiveDate!) < const Duration(hours: 24);
  }

  /// Get status text for friend
  String get statusText {
    if (isOnline) return 'Online now';
    if (lastActiveDate == null) return 'Never active';

    final now = DateTime.now();
    final diff = now.difference(lastActiveDate!);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return 'Over a week ago';
    }
  }

  Friend copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarEmoji,
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    String? levelTitle,
    int? currentLevel,
    DateTime? friendsSince,
    DateTime? lastActiveDate,
    bool? isOnline,
    List<String>? achievements,
    int? totalAchievements,
  }) {
    return Friend(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      levelTitle: levelTitle ?? this.levelTitle,
      currentLevel: currentLevel ?? this.currentLevel,
      friendsSince: friendsSince ?? this.friendsSince,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      isOnline: isOnline ?? this.isOnline,
      achievements: achievements ?? this.achievements,
      totalAchievements: totalAchievements ?? this.totalAchievements,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'displayName': displayName,
    'avatarEmoji': avatarEmoji,
    'totalXp': totalXp,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'levelTitle': levelTitle,
    'currentLevel': currentLevel,
    'friendsSince': friendsSince.toIso8601String(),
    'lastActiveDate': lastActiveDate?.toIso8601String(),
    'isOnline': isOnline,
    'achievements': achievements,
    'totalAchievements': totalAchievements,
  };

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarEmoji: json['avatarEmoji'] as String?,
      totalXp: json['totalXp'] as int,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      levelTitle: json['levelTitle'] as String,
      currentLevel: json['currentLevel'] as int,
      friendsSince: DateTime.parse(json['friendsSince'] as String),
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      isOnline: json['isOnline'] as bool? ?? false,
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      totalAchievements: json['totalAchievements'] as int? ?? 0,
    );
  }
}

/// Types of friend activities
enum FriendActivityType {
  levelUp,
  achievementUnlocked,
  streakMilestone,
  lessonCompleted,
  tankCreated,
  badgeEarned;

  String get displayName {
    switch (this) {
      case FriendActivityType.levelUp:
        return 'leveled up';
      case FriendActivityType.achievementUnlocked:
        return 'unlocked achievement';
      case FriendActivityType.streakMilestone:
        return 'reached streak milestone';
      case FriendActivityType.lessonCompleted:
        return 'completed lesson';
      case FriendActivityType.tankCreated:
        return 'created new tank';
      case FriendActivityType.badgeEarned:
        return 'earned badge';
    }
  }

  String get emoji {
    switch (this) {
      case FriendActivityType.levelUp:
        return '⭐';
      case FriendActivityType.achievementUnlocked:
        return '🏆';
      case FriendActivityType.streakMilestone:
        return '🔥';
      case FriendActivityType.lessonCompleted:
        return '📚';
      case FriendActivityType.tankCreated:
        return '🐠';
      case FriendActivityType.badgeEarned:
        return '🎖️';
    }
  }
}

/// Individual friend activity entry
@immutable
class FriendActivity {
  final String id;
  final String friendId;
  final String friendUsername;
  final String friendDisplayName;
  final String? friendAvatarEmoji;
  final FriendActivityType type;
  final String description; // "Reached Level 5"
  final int? xpEarned; // Optional XP earned for this activity
  final DateTime timestamp;

  const FriendActivity({
    required this.id,
    required this.friendId,
    required this.friendUsername,
    required this.friendDisplayName,
    this.friendAvatarEmoji,
    required this.type,
    required this.description,
    this.xpEarned,
    required this.timestamp,
  });

  /// Get relative time string (e.g., "2h ago", "Just now")
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

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

  FriendActivity copyWith({
    String? id,
    String? friendId,
    String? friendUsername,
    String? friendDisplayName,
    String? friendAvatarEmoji,
    FriendActivityType? type,
    String? description,
    int? xpEarned,
    DateTime? timestamp,
  }) {
    return FriendActivity(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      friendUsername: friendUsername ?? this.friendUsername,
      friendDisplayName: friendDisplayName ?? this.friendDisplayName,
      friendAvatarEmoji: friendAvatarEmoji ?? this.friendAvatarEmoji,
      type: type ?? this.type,
      description: description ?? this.description,
      xpEarned: xpEarned ?? this.xpEarned,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'friendId': friendId,
    'friendUsername': friendUsername,
    'friendDisplayName': friendDisplayName,
    'friendAvatarEmoji': friendAvatarEmoji,
    'type': type.name,
    'description': description,
    'xpEarned': xpEarned,
    'timestamp': timestamp.toIso8601String(),
  };

  factory FriendActivity.fromJson(Map<String, dynamic> json) {
    return FriendActivity(
      id: json['id'] as String,
      friendId: json['friendId'] as String,
      friendUsername: json['friendUsername'] as String,
      friendDisplayName: json['friendDisplayName'] as String,
      friendAvatarEmoji: json['friendAvatarEmoji'] as String?,
      type: FriendActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FriendActivityType.levelUp,
      ),
      description: json['description'] as String,
      xpEarned: json['xpEarned'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Encouragement reaction that can be sent to friends
@immutable
class FriendEncouragement {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String emoji; // '👍', '🎉', '🔥', '❤️', etc.
  final String? message; // Optional text message
  final DateTime timestamp;
  final bool isRead;

  const FriendEncouragement({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.emoji,
    this.message,
    required this.timestamp,
    this.isRead = false,
  });

  FriendEncouragement copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? emoji,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return FriendEncouragement(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      emoji: emoji ?? this.emoji,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    'emoji': emoji,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory FriendEncouragement.fromJson(Map<String, dynamic> json) {
    return FriendEncouragement(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      emoji: json['emoji'] as String,
      message: json['message'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
