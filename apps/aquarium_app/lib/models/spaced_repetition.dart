/// Comprehensive Spaced Repetition System Models
/// Implements forgetting curve algorithm with review cards and intelligent scheduling
library;

import 'package:flutter/foundation.dart';
import 'dart:math' as math;

// ==========================================
// REVIEW CARD - Core unit of spaced repetition
// ==========================================

/// A review card represents a learnable concept that needs periodic review
/// Tracks strength, intervals, and scheduling using forgetting curve
@immutable
class ReviewCard {
  final String id; // Unique card ID
  final String conceptId; // Reference to lesson/question/concept
  final ConceptType conceptType; // What kind of concept this is
  final double strength; // 0.0 - 1.0 (mastery level)
  final DateTime lastReviewed; // When last reviewed
  final DateTime nextReview; // When next review is due
  final int reviewCount; // Total number of reviews
  final int correctCount; // Number of correct answers
  final int incorrectCount; // Number of incorrect answers
  final ReviewInterval currentInterval; // Current review interval
  final List<ReviewAttempt> history; // Review history

  /// The actual content text shown on the flashcard front (e.g. key-point body,
  /// quiz question text). Populated at card-creation time so the practice
  /// screen doesn't need to reload lesson data on every render.
  final String? questionText;

  const ReviewCard({
    required this.id,
    required this.conceptId,
    required this.conceptType,
    this.strength = 0.0,
    required this.lastReviewed,
    required this.nextReview,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.currentInterval = ReviewInterval.day1,
    this.history = const [],
    this.questionText,
  });

  /// Check if card is due for review
  bool get isDue =>
      DateTime.now().isAfter(nextReview) ||
      DateTime.now().isAtSameMomentAs(nextReview);

  /// Check if card is weak (needs priority)
  bool get isWeak => strength < 0.5;

  /// Check if card is strong (mastered)
  bool get isStrong => strength >= 0.8;

  /// Get mastery level
  MasteryLevel get masteryLevel {
    if (strength >= 0.9) return MasteryLevel.mastered;
    if (strength >= 0.7) return MasteryLevel.proficient;
    if (strength >= 0.5) return MasteryLevel.familiar;
    if (strength >= 0.3) return MasteryLevel.learning;
    return MasteryLevel.new_;
  }

  /// Calculate success rate
  double get successRate {
    if (reviewCount == 0) return 0.0;
    return correctCount / reviewCount;
  }

  /// Create new card after a review attempt
  ReviewCard afterReview({required bool correct, DateTime? reviewedAt}) {
    final now = reviewedAt ?? DateTime.now();

    // Adjust strength based on correctness
    double newStrength = strength;
    if (correct) {
      newStrength = math.min(1.0, strength + 0.2); // +0.2 for correct
    } else {
      newStrength = math.max(0.0, strength - 0.3); // -0.3 for incorrect
    }

    // Calculate next interval based on new strength
    final newInterval = _calculateNextInterval(newStrength, correct);
    final nextReviewDate = now.add(newInterval.duration);

    // Create review attempt record
    final attempt = ReviewAttempt(
      timestamp: now,
      correct: correct,
      strengthBefore: strength,
      strengthAfter: newStrength,
      interval: newInterval,
    );

    // Cap history to 50 entries to prevent unbounded growth
    final newHistory = [...history, attempt];
    final cappedHistory = newHistory.length > 50
        ? newHistory.sublist(newHistory.length - 50)
        : newHistory;

    return ReviewCard(
      id: id,
      conceptId: conceptId,
      conceptType: conceptType,
      strength: newStrength,
      lastReviewed: now,
      nextReview: nextReviewDate,
      reviewCount: reviewCount + 1,
      correctCount: correctCount + (correct ? 1 : 0),
      incorrectCount: incorrectCount + (correct ? 0 : 1),
      currentInterval: newInterval,
      history: cappedHistory,
      questionText: questionText,
    );
  }

  /// Calculate next review interval based on strength
  ReviewInterval _calculateNextInterval(double strength, bool wasCorrect) {
    if (!wasCorrect) {
      // Failed review - start over with day 1
      return ReviewInterval.day1;
    }

    // Progressive intervals based on strength
    // Thresholds based on mastery levels
    if (strength >= 0.9) return ReviewInterval.day30;
    if (strength >= 0.8) return ReviewInterval.day14;
    if (strength >= 0.6) return ReviewInterval.day7;
    if (strength >= 0.4) return ReviewInterval.day3;
    // Below 0.4 stays at day1 until mastery improves
    return ReviewInterval.day1;
  }

  /// Calculate current strength using forgetting curve decay
  /// Strength decays over time since last review
  double calculateCurrentStrength() {
    final daysSinceReview = DateTime.now().difference(lastReviewed).inDays;

    // No decay if not yet due
    if (!isDue) return strength;

    // Forgetting curve: exponential decay
    // Formula: strength * e^(-decayRate * days)
    const decayRate = 0.1; // Adjust this to control decay speed
    final decayFactor = math.exp(-decayRate * daysSinceReview);

    return math.max(0.0, strength * decayFactor);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conceptId': conceptId,
    'conceptType': conceptType.toString().split('.').last,
    'strength': strength,
    'lastReviewed': lastReviewed.toIso8601String(),
    'nextReview': nextReview.toIso8601String(),
    'reviewCount': reviewCount,
    'correctCount': correctCount,
    'incorrectCount': incorrectCount,
    'currentInterval': currentInterval.toString().split('.').last,
    'history': history.map((h) => h.toJson()).toList(),
    if (questionText != null) 'questionText': questionText,
  };

  factory ReviewCard.fromJson(Map<String, dynamic> json) {
    return ReviewCard(
      id: json['id'],
      conceptId: json['conceptId'],
      conceptType: ConceptType.values.firstWhere(
        (t) => t.toString().split('.').last == json['conceptType'],
        orElse: () => ConceptType.lesson,
      ),
      strength: json['strength'],
      lastReviewed: DateTime.parse(json['lastReviewed']),
      nextReview: DateTime.parse(json['nextReview']),
      reviewCount: json['reviewCount'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      incorrectCount: json['incorrectCount'] ?? 0,
      currentInterval: ReviewInterval.values.firstWhere(
        (i) => i.toString().split('.').last == json['currentInterval'],
        orElse: () => ReviewInterval.day1,
      ),
      history:
          (json['history'] as List?)
              ?.map((h) => ReviewAttempt.fromJson(h))
              .toList() ??
          [],
      questionText: json['questionText'] as String?,
    );
  }

  /// Factory for creating a new card
  factory ReviewCard.newCard({
    required String conceptId,
    required ConceptType conceptType,
  }) {
    final now = DateTime.now();
    return ReviewCard(
      id: '${conceptId}_${now.millisecondsSinceEpoch}',
      conceptId: conceptId,
      conceptType: conceptType,
      strength: 0.0,
      lastReviewed: now,
      nextReview: now, // Due immediately for first review
      reviewCount: 0,
      correctCount: 0,
      incorrectCount: 0,
      currentInterval: ReviewInterval.day1,
      history: [],
    );
  }
}

// ==========================================
// REVIEW INTERVALS
// ==========================================

/// Predefined review intervals based on spaced repetition best practices
enum ReviewInterval {
  day1, // 1 day
  day3, // 3 days
  day7, // 7 days
  day14, // 14 days
  day30, // 30 days
}

extension ReviewIntervalExt on ReviewInterval {
  Duration get duration {
    switch (this) {
      case ReviewInterval.day1:
        return const Duration(days: 1);
      case ReviewInterval.day3:
        return const Duration(days: 3);
      case ReviewInterval.day7:
        return const Duration(days: 7);
      case ReviewInterval.day14:
        return const Duration(days: 14);
      case ReviewInterval.day30:
        return const Duration(days: 30);
    }
  }

  String get displayName {
    switch (this) {
      case ReviewInterval.day1:
        return '1 day';
      case ReviewInterval.day3:
        return '3 days';
      case ReviewInterval.day7:
        return '7 days';
      case ReviewInterval.day14:
        return '2 weeks';
      case ReviewInterval.day30:
        return '1 month';
    }
  }
}

// ==========================================
// CONCEPT TYPES
// ==========================================

/// Types of learnable concepts
enum ConceptType {
  lesson, // Full lesson
  quizQuestion, // Individual quiz question
  definition, // Terminology/definition
  procedure, // Step-by-step procedure
  fact, // Single fact
}

// ==========================================
// MASTERY LEVELS
// ==========================================

/// Visual representation of mastery progress
enum MasteryLevel {
  new_, // 0-30%: Just learning
  learning, // 30-50%: Making progress
  familiar, // 50-70%: Comfortable
  proficient, // 70-90%: Strong understanding
  mastered, // 90-100%: Mastered
}

extension MasteryLevelExt on MasteryLevel {
  String get displayName {
    switch (this) {
      case MasteryLevel.new_:
        return 'New';
      case MasteryLevel.learning:
        return 'Learning';
      case MasteryLevel.familiar:
        return 'Familiar';
      case MasteryLevel.proficient:
        return 'Proficient';
      case MasteryLevel.mastered:
        return 'Mastered';
    }
  }

  String get emoji {
    switch (this) {
      case MasteryLevel.new_:
        return '🌱';
      case MasteryLevel.learning:
        return '📚';
      case MasteryLevel.familiar:
        return '💡';
      case MasteryLevel.proficient:
        return '⭐';
      case MasteryLevel.mastered:
        return '🏆';
    }
  }

  double get minStrength {
    switch (this) {
      case MasteryLevel.new_:
        return 0.0;
      case MasteryLevel.learning:
        return 0.3;
      case MasteryLevel.familiar:
        return 0.5;
      case MasteryLevel.proficient:
        return 0.7;
      case MasteryLevel.mastered:
        return 0.9;
    }
  }
}

/// Record of a single review attempt
@immutable
class ReviewAttempt {
  final DateTime timestamp;
  final bool correct;
  final double strengthBefore;
  final double strengthAfter;
  final ReviewInterval interval;

  const ReviewAttempt({
    required this.timestamp,
    required this.correct,
    required this.strengthBefore,
    required this.strengthAfter,
    required this.interval,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'correct': correct,
    'strengthBefore': strengthBefore,
    'strengthAfter': strengthAfter,
    'interval': interval.toString().split('.').last,
  };

  factory ReviewAttempt.fromJson(Map<String, dynamic> json) {
    return ReviewAttempt(
      timestamp: DateTime.parse(json['timestamp']),
      correct: json['correct'],
      strengthBefore: json['strengthBefore'],
      strengthAfter: json['strengthAfter'],
      interval: ReviewInterval.values.firstWhere(
        (i) => i.toString().split('.').last == json['interval'],
        orElse: () => ReviewInterval.day1,
      ),
    );
  }
}

// ==========================================
// REVIEW SESSION
// ==========================================

/// A review session containing multiple cards
@immutable
class ReviewSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ReviewCard> cards;
  final List<ReviewSessionResult> results;
  final ReviewSessionMode mode;

  const ReviewSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.cards,
    this.results = const [],
    this.mode = ReviewSessionMode.standard,
  });

  /// Check if session is complete
  bool get isComplete => results.length == cards.length;

  /// Get number of cards remaining
  int get remainingCount => cards.length - results.length;

  /// Get current progress (0.0 - 1.0)
  double get progress => cards.isEmpty ? 1.0 : results.length / cards.length;

  /// Get score (percentage correct)
  double get score {
    if (results.isEmpty) return 0.0;
    final correct = results.where((r) => r.correct).length;
    return correct / results.length;
  }

  /// Get total XP earned
  int get totalXp => results.fold(0, (sum, r) => sum + r.xpEarned);

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'cards': cards.map((c) => c.toJson()).toList(),
    'results': results.map((r) => r.toJson()).toList(),
    'mode': mode.toString().split('.').last,
  };

  factory ReviewSession.fromJson(Map<String, dynamic> json) {
    return ReviewSession(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      cards: (json['cards'] as List)
          .map((c) => ReviewCard.fromJson(c))
          .toList(),
      results: (json['results'] as List)
          .map((r) => ReviewSessionResult.fromJson(r))
          .toList(),
      mode: ReviewSessionMode.values.firstWhere(
        (m) => m.toString().split('.').last == json['mode'],
        orElse: () => ReviewSessionMode.standard,
      ),
    );
  }
}

/// Result of reviewing a single card in a session
@immutable
class ReviewSessionResult {
  final String cardId;
  final bool correct;
  final DateTime timestamp;
  final int xpEarned;
  final Duration timeSpent;

  const ReviewSessionResult({
    required this.cardId,
    required this.correct,
    required this.timestamp,
    required this.xpEarned,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() => {
    'cardId': cardId,
    'correct': correct,
    'timestamp': timestamp.toIso8601String(),
    'xpEarned': xpEarned,
    'timeSpent': timeSpent.inSeconds,
  };

  factory ReviewSessionResult.fromJson(Map<String, dynamic> json) {
    return ReviewSessionResult(
      cardId: json['cardId'],
      correct: json['correct'],
      timestamp: DateTime.parse(json['timestamp']),
      xpEarned: json['xpEarned'],
      timeSpent: Duration(seconds: json['timeSpent']),
    );
  }
}

enum ReviewSessionMode {
  standard, // Regular review
  quick, // Quick 5-question review
  intensive, // Focus on weak cards
  mixed, // Mix of due + strong cards (spaced practice)
}

// ==========================================
// REVIEW STATISTICS
// ==========================================

/// Statistics for all review cards
@immutable
class ReviewStats {
  final int totalCards;
  final int dueCards;
  final int weakCards;
  final int masteredCards;
  final double averageStrength;
  final Map<MasteryLevel, int> cardsByMastery;
  final int reviewsToday;
  final int totalReviews;
  final int currentStreak;

  const ReviewStats({
    required this.totalCards,
    required this.dueCards,
    required this.weakCards,
    required this.masteredCards,
    required this.averageStrength,
    required this.cardsByMastery,
    required this.reviewsToday,
    this.totalReviews = 0,
    required this.currentStreak,
  });

  /// Calculate from list of cards
  factory ReviewStats.fromCards(
    List<ReviewCard> cards, {
    int reviewsToday = 0,
    int totalReviews = 0,
    int streak = 0,
  }) {
    if (cards.isEmpty) {
      return ReviewStats(
        totalCards: 0,
        dueCards: 0,
        weakCards: 0,
        masteredCards: 0,
        averageStrength: 0.0,
        cardsByMastery: {},
        reviewsToday: reviewsToday,
        totalReviews: totalReviews,
        currentStreak: streak,
      );
    }

    final due = cards.where((c) => c.isDue).length;
    final weak = cards.where((c) => c.isWeak).length;
    final mastered = cards
        .where((c) => c.masteryLevel == MasteryLevel.mastered)
        .length;
    final avgStrength =
        cards.fold(0.0, (sum, c) => sum + c.strength) / cards.length;

    final byMastery = <MasteryLevel, int>{};
    for (final level in MasteryLevel.values) {
      byMastery[level] = cards.where((c) => c.masteryLevel == level).length;
    }

    return ReviewStats(
      totalCards: cards.length,
      dueCards: due,
      weakCards: weak,
      masteredCards: mastered,
      averageStrength: avgStrength,
      cardsByMastery: byMastery,
      reviewsToday: reviewsToday,
      totalReviews: totalReviews,
      currentStreak: streak,
    );
  }
}
