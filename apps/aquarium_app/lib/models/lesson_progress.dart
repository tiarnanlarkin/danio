/// Model for tracking individual lesson progress with spaced repetition
/// Implements a forgetting curve algorithm to help users review forgotten lessons
library;


import 'package:flutter/foundation.dart';

@immutable
class LessonProgress {
  final String lessonId;
  final DateTime completedDate;      // When first completed
  final DateTime? lastReviewDate;    // Most recent review (null if never reviewed)
  final int reviewCount;             // Number of times reviewed
  final double strength;             // 0-100, decays over time based on forgetting curve

  const LessonProgress({
    required this.lessonId,
    required this.completedDate,
    this.lastReviewDate,
    this.reviewCount = 0,
    this.strength = 100.0,
  });

  /// Calculate current strength based on forgetting curve
  /// Strength decays: 100 → 70 (24h) → 40 (7d) → 0 (30d)
  double get currentStrength {
    final referenceDate = lastReviewDate ?? completedDate;
    final daysSinceReview = DateTime.now().difference(referenceDate).inDays;
    
    // Forgetting curve decay algorithm
    // - 0 days: 100%
    // - 1 day: 70%
    // - 7 days: 40%
    // - 30 days: 0%
    
    if (daysSinceReview == 0) {
      return strength;
    } else if (daysSinceReview == 1) {
      return 70.0;
    } else if (daysSinceReview <= 7) {
      // Linear interpolation between 70% (day 1) and 40% (day 7)
      return 70.0 - ((daysSinceReview - 1) / 6) * 30.0;
    } else if (daysSinceReview <= 30) {
      // Linear interpolation between 40% (day 7) and 0% (day 30)
      return 40.0 - ((daysSinceReview - 7) / 23) * 40.0;
    } else {
      // After 30 days, strength is 0
      return 0.0;
    }
  }

  /// Check if lesson needs review (strength below 50%)
  bool get needsReview => currentStrength < 50.0;

  /// Check if lesson is weak (strength below 70%)
  bool get isWeak => currentStrength < 70.0;

  /// Create a copy with updated review
  LessonProgress reviewed() {
    return LessonProgress(
      lessonId: lessonId,
      completedDate: completedDate,
      lastReviewDate: DateTime.now(),
      reviewCount: reviewCount + 1,
      strength: 100.0, // Reset to full strength
    );
  }

  LessonProgress copyWith({
    String? lessonId,
    DateTime? completedDate,
    DateTime? lastReviewDate,
    int? reviewCount,
    double? strength,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      completedDate: completedDate ?? this.completedDate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      reviewCount: reviewCount ?? this.reviewCount,
      strength: strength ?? this.strength,
    );
  }

  Map<String, dynamic> toJson() => {
    'lessonId': lessonId,
    'completedDate': completedDate.toIso8601String(),
    'lastReviewDate': lastReviewDate?.toIso8601String(),
    'reviewCount': reviewCount,
    'strength': strength,
  };

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lessonId'] as String,
      completedDate: DateTime.parse(json['completedDate'] as String),
      lastReviewDate: json['lastReviewDate'] != null
          ? DateTime.parse(json['lastReviewDate'] as String)
          : null,
      reviewCount: json['reviewCount'] as int? ?? 0,
      strength: (json['strength'] as num?)?.toDouble() ?? 100.0,
    );
  }
}
