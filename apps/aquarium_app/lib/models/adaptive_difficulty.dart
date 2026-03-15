/// Adaptive difficulty models for AI-powered difficulty adjustment
/// Tracks user performance and provides dynamic difficulty recommendations
library;

import 'package:flutter/foundation.dart';

/// Difficulty levels available in the app
enum DifficultyLevel {
  easy,
  medium,
  hard,
  expert;

  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  String get emoji {
    switch (this) {
      case DifficultyLevel.easy:
        return '🌱';
      case DifficultyLevel.medium:
        return '⭐';
      case DifficultyLevel.hard:
        return '🔥';
      case DifficultyLevel.expert:
        return '💎';
    }
  }

  String get description {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Basic concepts with hints and guidance';
      case DifficultyLevel.medium:
        return 'Standard difficulty with moderate challenge';
      case DifficultyLevel.hard:
        return 'Advanced concepts requiring strong knowledge';
      case DifficultyLevel.expert:
        return 'Expert level with complex scenarios';
    }
  }
}

/// Performance trend indicators
enum PerformanceTrend {
  improving,
  stable,
  declining;

  String get displayName {
    switch (this) {
      case PerformanceTrend.improving:
        return 'Improving';
      case PerformanceTrend.stable:
        return 'Stable';
      case PerformanceTrend.declining:
        return 'Declining';
    }
  }

  String get emoji {
    switch (this) {
      case PerformanceTrend.improving:
        return '📈';
      case PerformanceTrend.stable:
        return '➡️';
      case PerformanceTrend.declining:
        return '📉';
    }
  }
}

/// A single performance record for an attempt
@immutable
class PerformanceRecord {
  final DateTime timestamp;
  final String topicId;
  final DifficultyLevel difficulty;
  final int score; // 0-100
  final int maxScore; // Total possible score
  final int mistakeCount;
  final Duration timeSpent;
  final bool completed;

  const PerformanceRecord({
    required this.timestamp,
    required this.topicId,
    required this.difficulty,
    required this.score,
    required this.maxScore,
    required this.mistakeCount,
    required this.timeSpent,
    required this.completed,
  });

  /// Accuracy percentage (0.0-1.0)
  double get accuracy => maxScore > 0 ? score / maxScore : 0.0;

  /// Time efficiency score (faster is better, but not too fast)
  /// Expects 30-60 seconds per question
  double get timeEfficiency {
    final questionsCount = maxScore;
    if (questionsCount == 0) return 0.0;

    final averageTimePerQuestion = timeSpent.inSeconds / questionsCount;

    // Optimal time: 30-60 seconds per question
    // Too fast (<20s) = likely guessing
    // Too slow (>120s) = struggling
    if (averageTimePerQuestion < 20) {
      return 0.7; // Penalize rushing
    } else if (averageTimePerQuestion <= 60) {
      return 1.0; // Optimal
    } else if (averageTimePerQuestion <= 120) {
      return 0.8; // Acceptable but slow
    } else {
      return 0.5; // Very slow, likely struggling
    }
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'topicId': topicId,
    'difficulty': difficulty.name,
    'score': score,
    'maxScore': maxScore,
    'mistakeCount': mistakeCount,
    'timeSpent': timeSpent.inSeconds,
    'completed': completed,
  };

  factory PerformanceRecord.fromJson(Map<String, dynamic> json) {
    return PerformanceRecord(
      timestamp: DateTime.parse(json['timestamp'] as String),
      topicId: json['topicId'] as String,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
      score: json['score'] as int,
      maxScore: json['maxScore'] as int,
      mistakeCount: json['mistakeCount'] as int,
      timeSpent: Duration(seconds: json['timeSpent'] as int),
      completed: json['completed'] as bool,
    );
  }
}

/// Performance history for a specific topic
@immutable
class PerformanceHistory {
  final String topicId;
  final List<PerformanceRecord> recentAttempts; // Rolling window of 10

  const PerformanceHistory({
    required this.topicId,
    required this.recentAttempts,
  });

  /// Add a new record (maintains rolling window of 10)
  PerformanceHistory addRecord(PerformanceRecord record) {
    final newAttempts = [...recentAttempts, record];
    if (newAttempts.length > 10) {
      newAttempts.removeAt(0); // Remove oldest
    }
    return PerformanceHistory(topicId: topicId, recentAttempts: newAttempts);
  }

  /// Average accuracy over recent attempts
  double get averageAccuracy {
    if (recentAttempts.isEmpty) return 0.0;
    return recentAttempts.map((r) => r.accuracy).reduce((a, b) => a + b) /
        recentAttempts.length;
  }

  /// Average time efficiency
  double get averageTimeEfficiency {
    if (recentAttempts.isEmpty) return 0.0;
    return recentAttempts.map((r) => r.timeEfficiency).reduce((a, b) => a + b) /
        recentAttempts.length;
  }

  /// Average mistakes per attempt
  double get averageMistakes {
    if (recentAttempts.isEmpty) return 0.0;
    return recentAttempts
            .map((r) => r.mistakeCount.toDouble())
            .reduce((a, b) => a + b) /
        recentAttempts.length;
  }

  /// Consecutive correct answers (at end of history)
  int get consecutiveCorrect {
    if (recentAttempts.isEmpty) return 0;

    int count = 0;
    for (int i = recentAttempts.length - 1; i >= 0; i--) {
      if (recentAttempts[i].accuracy >= 0.7) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Check if user is struggling (3+ high mistake attempts recently)
  bool get isStruggling {
    if (recentAttempts.length < 3) return false;

    final recentThree = recentAttempts.sublist(
      recentAttempts.length - 3,
      recentAttempts.length,
    );

    return recentThree.every((r) => r.mistakeCount >= 3 || r.accuracy < 0.5);
  }

  /// Performance trend (improving/stable/declining)
  PerformanceTrend get trend {
    if (recentAttempts.length < 3) return PerformanceTrend.stable;

    // Compare first half vs second half
    final midPoint = recentAttempts.length ~/ 2;
    final firstHalf = recentAttempts.sublist(0, midPoint);
    final secondHalf = recentAttempts.sublist(midPoint);

    final firstAvg =
        firstHalf.map((r) => r.accuracy).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((r) => r.accuracy).reduce((a, b) => a + b) /
        secondHalf.length;

    final difference = secondAvg - firstAvg;

    if (difference > 0.1) return PerformanceTrend.improving;
    if (difference < -0.1) return PerformanceTrend.declining;
    return PerformanceTrend.stable;
  }

  /// Standard deviation of scores (measures consistency)
  double get scoreStandardDeviation {
    if (recentAttempts.isEmpty) return 0.0;

    final mean = averageAccuracy;
    final variance =
        recentAttempts
            .map((r) => (r.accuracy - mean) * (r.accuracy - mean))
            .reduce((a, b) => a + b) /
        recentAttempts.length;

    return variance;
  }

  Map<String, dynamic> toJson() => {
    'topicId': topicId,
    'recentAttempts': recentAttempts.map((r) => r.toJson()).toList(),
  };

  factory PerformanceHistory.fromJson(Map<String, dynamic> json) {
    return PerformanceHistory(
      topicId: json['topicId'] as String,
      recentAttempts: (json['recentAttempts'] as List<dynamic>)
          .map((r) => PerformanceRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// User's skill profile across all topics
@immutable
class UserSkillProfile {
  final Map<String, double> skillLevels; // topic ID -> skill level (0.0-1.0)
  final Map<String, PerformanceHistory> performanceHistory;
  final Map<String, DifficultyLevel>
  manualOverrides; // User can override auto-difficulty

  const UserSkillProfile({
    required this.skillLevels,
    required this.performanceHistory,
    this.manualOverrides = const {},
  });

  /// Get skill level for a topic (0.0-1.0)
  double getSkillLevel(String topicId) {
    return skillLevels[topicId] ?? 0.3; // Default to beginner
  }

  /// Get performance history for a topic
  PerformanceHistory? getPerformanceHistory(String topicId) {
    return performanceHistory[topicId];
  }

  /// Update skill level for a topic
  UserSkillProfile updateSkillLevel(String topicId, double newLevel) {
    final newSkills = Map<String, double>.from(skillLevels);
    newSkills[topicId] = newLevel.clamp(0.0, 1.0);

    return UserSkillProfile(
      skillLevels: newSkills,
      performanceHistory: performanceHistory,
      manualOverrides: manualOverrides,
    );
  }

  /// Add a performance record
  UserSkillProfile addPerformanceRecord(PerformanceRecord record) {
    final newHistory = Map<String, PerformanceHistory>.from(performanceHistory);

    final currentHistory =
        newHistory[record.topicId] ??
        PerformanceHistory(topicId: record.topicId, recentAttempts: []);

    newHistory[record.topicId] = currentHistory.addRecord(record);

    return UserSkillProfile(
      skillLevels: skillLevels,
      performanceHistory: newHistory,
      manualOverrides: manualOverrides,
    );
  }

  /// Set manual difficulty override
  UserSkillProfile setManualOverride(
    String topicId,
    DifficultyLevel? difficulty,
  ) {
    final newOverrides = Map<String, DifficultyLevel>.from(manualOverrides);

    if (difficulty == null) {
      newOverrides.remove(topicId);
    } else {
      newOverrides[topicId] = difficulty;
    }

    return UserSkillProfile(
      skillLevels: skillLevels,
      performanceHistory: performanceHistory,
      manualOverrides: newOverrides,
    );
  }

  /// Get manual override for a topic (if set)
  DifficultyLevel? getManualOverride(String topicId) {
    return manualOverrides[topicId];
  }

  /// Overall skill level (average across all topics)
  double get overallSkillLevel {
    if (skillLevels.isEmpty) return 0.3;
    return skillLevels.values.reduce((a, b) => a + b) / skillLevels.length;
  }

  Map<String, dynamic> toJson() => {
    'skillLevels': skillLevels,
    'performanceHistory': performanceHistory.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'manualOverrides': manualOverrides.map(
      (key, value) => MapEntry(key, value.name),
    ),
  };

  factory UserSkillProfile.fromJson(Map<String, dynamic> json) {
    return UserSkillProfile(
      skillLevels: (json['skillLevels'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      performanceHistory: (json['performanceHistory'] as Map<String, dynamic>)
          .map(
            (key, value) => MapEntry(
              key,
              PerformanceHistory.fromJson(value as Map<String, dynamic>),
            ),
          ),
      manualOverrides:
          (json['manualOverrides'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              DifficultyLevel.values.firstWhere((e) => e.name == value, orElse: () => DifficultyLevel.easy),
            ),
          ) ??
          {},
    );
  }

  /// Create empty profile
  factory UserSkillProfile.empty() {
    return const UserSkillProfile(
      skillLevels: {},
      performanceHistory: {},
      manualOverrides: {},
    );
  }
}

/// Difficulty recommendation with confidence
@immutable
class DifficultyRecommendation {
  final DifficultyLevel suggestedLevel;
  final double confidence; // 0.0-1.0
  final String reason;
  final bool shouldIncrease;
  final bool shouldDecrease;

  const DifficultyRecommendation({
    required this.suggestedLevel,
    required this.confidence,
    required this.reason,
    this.shouldIncrease = false,
    this.shouldDecrease = false,
  });

  String get displayText {
    final emoji = suggestedLevel.emoji;
    final level = suggestedLevel.displayName;
    return '$emoji $level - $reason';
  }
}
