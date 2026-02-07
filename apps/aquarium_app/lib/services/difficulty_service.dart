/// Service for adaptive difficulty adjustment based on user performance
/// Implements AI-powered difficulty recommendations

import 'dart:math';
import '../models/adaptive_difficulty.dart';

class DifficultyService {
  /// Calculate skill level for a topic based on performance history
  /// Returns a value between 0.0 (beginner) and 1.0 (expert)
  double calculateSkillLevel(PerformanceHistory history) {
    if (history.recentAttempts.isEmpty) {
      return 0.3; // Default beginner level
    }

    // Weight different factors:
    // - Accuracy: 40%
    // - Time efficiency: 20%
    // - Consistency (inverse of std dev): 20%
    // - Improvement trend: 20%

    final accuracy = history.averageAccuracy;
    final timeEfficiency = history.averageTimeEfficiency;
    final consistency = 1.0 - history.scoreStandardDeviation.clamp(0.0, 1.0);
    
    // Improvement bonus
    double improvementFactor = 1.0;
    if (history.trend == PerformanceTrend.improving) {
      improvementFactor = 1.15;
    } else if (history.trend == PerformanceTrend.declining) {
      improvementFactor = 0.85;
    }

    // Calculate weighted skill level
    double skillLevel = (
      accuracy * 0.4 +
      timeEfficiency * 0.2 +
      consistency * 0.2 +
      (history.consecutiveCorrect / 10.0) * 0.2
    ) * improvementFactor;

    return skillLevel.clamp(0.0, 1.0);
  }

  /// Recommend difficulty level based on skill level
  DifficultyLevel recommendDifficultyFromSkill(double skillLevel) {
    if (skillLevel < 0.3) {
      return DifficultyLevel.easy;
    } else if (skillLevel < 0.6) {
      return DifficultyLevel.medium;
    } else if (skillLevel < 0.8) {
      return DifficultyLevel.hard;
    } else {
      return DifficultyLevel.expert;
    }
  }

  /// Get comprehensive difficulty recommendation
  DifficultyRecommendation getDifficultyRecommendation({
    required String topicId,
    required UserSkillProfile profile,
    DifficultyLevel? currentDifficulty,
  }) {
    // Check for manual override first
    final manualOverride = profile.getManualOverride(topicId);
    if (manualOverride != null) {
      return DifficultyRecommendation(
        suggestedLevel: manualOverride,
        confidence: 1.0,
        reason: 'Manual override set by user',
      );
    }

    final history = profile.getPerformanceHistory(topicId);
    
    // If no history, start with easy/medium based on overall profile
    if (history == null || history.recentAttempts.isEmpty) {
      final overallSkill = profile.overallSkillLevel;
      final suggestedLevel = overallSkill < 0.5 
          ? DifficultyLevel.easy 
          : DifficultyLevel.medium;
      
      return DifficultyRecommendation(
        suggestedLevel: suggestedLevel,
        confidence: 0.5,
        reason: 'No performance history for this topic',
      );
    }

    // Calculate skill level
    final skillLevel = calculateSkillLevel(history);
    DifficultyLevel suggestedLevel = recommendDifficultyFromSkill(skillLevel);

    // Adjust based on recent performance patterns
    String reason = 'Based on your recent performance';
    bool shouldIncrease = false;
    bool shouldDecrease = false;
    double confidence = 0.7;

    // Check for consecutive success -> increase difficulty
    if (history.consecutiveCorrect >= 5) {
      final currentIndex = currentDifficulty?.index ?? suggestedLevel.index;
      if (currentIndex < DifficultyLevel.expert.index) {
        suggestedLevel = DifficultyLevel.values[currentIndex + 1];
        shouldIncrease = true;
        reason = 'Great streak! Ready for a challenge';
        confidence = 0.9;
      }
    }

    // Check for struggling -> decrease difficulty
    if (history.isStruggling) {
      final currentIndex = currentDifficulty?.index ?? suggestedLevel.index;
      if (currentIndex > DifficultyLevel.easy.index) {
        suggestedLevel = DifficultyLevel.values[currentIndex - 1];
        shouldDecrease = true;
        reason = 'Let\'s build confidence at an easier level';
        confidence = 0.85;
      }
    }

    // Check improvement trend
    if (history.trend == PerformanceTrend.improving && !shouldIncrease) {
      reason = 'You\'re improving! Keep it up';
      confidence = 0.8;
    } else if (history.trend == PerformanceTrend.declining && !shouldDecrease) {
      reason = 'Practice makes perfect';
      confidence = 0.75;
    }

    // Adjust confidence based on data volume
    final dataVolume = min(history.recentAttempts.length / 10.0, 1.0);
    confidence *= (0.5 + dataVolume * 0.5);

    return DifficultyRecommendation(
      suggestedLevel: suggestedLevel,
      confidence: confidence,
      reason: reason,
      shouldIncrease: shouldIncrease,
      shouldDecrease: shouldDecrease,
    );
  }

  /// Check if difficulty should be adjusted mid-lesson
  /// Returns new difficulty level if adjustment needed, null otherwise
  DifficultyLevel? checkForMidLessonAdjustment({
    required DifficultyLevel currentDifficulty,
    required List<PerformanceRecord> lessonAttempts,
  }) {
    if (lessonAttempts.length < 3) {
      return null; // Need at least 3 questions answered
    }

    final recentThree = lessonAttempts.sublist(
      max(0, lessonAttempts.length - 3),
      lessonAttempts.length,
    );

    // Check for consistent perfect performance -> increase
    final allPerfect = recentThree.every((r) => r.accuracy >= 0.95);
    if (allPerfect && currentDifficulty.index < DifficultyLevel.expert.index) {
      return DifficultyLevel.values[currentDifficulty.index + 1];
    }

    // Check for consistent failure -> decrease
    final allFailed = recentThree.every((r) => r.accuracy < 0.4);
    if (allFailed && currentDifficulty.index > DifficultyLevel.easy.index) {
      return DifficultyLevel.values[currentDifficulty.index - 1];
    }

    return null;
  }

  /// Update skill profile after a lesson
  UserSkillProfile updateProfileAfterLesson({
    required UserSkillProfile currentProfile,
    required PerformanceRecord lessonRecord,
  }) {
    // Add performance record
    var updatedProfile = currentProfile.addPerformanceRecord(lessonRecord);

    // Recalculate skill level for this topic
    final history = updatedProfile.getPerformanceHistory(lessonRecord.topicId);
    if (history != null) {
      final newSkillLevel = calculateSkillLevel(history);
      updatedProfile = updatedProfile.updateSkillLevel(
        lessonRecord.topicId,
        newSkillLevel,
      );
    }

    return updatedProfile;
  }

  /// Get skill level change message (for UI feedback)
  String? getSkillChangeMessage({
    required double oldSkill,
    required double newSkill,
    required String topicName,
  }) {
    final change = newSkill - oldSkill;
    
    if (change.abs() < 0.05) {
      return null; // No significant change
    }

    if (change > 0.15) {
      return '🎉 Huge improvement in $topicName! (+${(change * 100).toInt()}%)';
    } else if (change > 0.05) {
      return '📈 Your $topicName skill increased! (+${(change * 100).toInt()}%)';
    } else if (change < -0.15) {
      return '📚 $topicName needs practice (-${(change.abs() * 100).toInt()}%)';
    } else if (change < -0.05) {
      return '💪 Keep practicing $topicName (-${(change.abs() * 100).toInt()}%)';
    }

    return null;
  }

  /// Get difficulty badge color for UI
  int getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 0xFF4CAF50; // Green
      case DifficultyLevel.medium:
        return 0xFF2196F3; // Blue
      case DifficultyLevel.hard:
        return 0xFFFF9800; // Orange
      case DifficultyLevel.expert:
        return 0xFFE91E63; // Pink/Purple
    }
  }

  /// Calculate expected time for a lesson based on difficulty
  Duration getExpectedTime({
    required int questionCount,
    required DifficultyLevel difficulty,
  }) {
    // Base time per question
    int secondsPerQuestion;
    switch (difficulty) {
      case DifficultyLevel.easy:
        secondsPerQuestion = 30;
        break;
      case DifficultyLevel.medium:
        secondsPerQuestion = 45;
        break;
      case DifficultyLevel.hard:
        secondsPerQuestion = 60;
        break;
      case DifficultyLevel.expert:
        secondsPerQuestion = 90;
        break;
    }

    return Duration(seconds: questionCount * secondsPerQuestion);
  }

  /// Get performance summary for a topic
  Map<String, dynamic> getPerformanceSummary({
    required PerformanceHistory history,
  }) {
    if (history.recentAttempts.isEmpty) {
      return {
        'attempts': 0,
        'averageScore': 0.0,
        'trend': PerformanceTrend.stable,
        'bestScore': 0.0,
        'recentScore': 0.0,
      };
    }

    final attempts = history.recentAttempts;
    final scores = attempts.map((a) => a.accuracy).toList();
    
    return {
      'attempts': attempts.length,
      'averageScore': history.averageAccuracy,
      'trend': history.trend,
      'bestScore': scores.reduce(max),
      'recentScore': scores.last,
      'consecutiveCorrect': history.consecutiveCorrect,
      'isStruggling': history.isStruggling,
    };
  }

  /// Get all topics ranked by skill level (for leaderboard/progress view)
  List<MapEntry<String, double>> getTopicsRankedBySkill({
    required UserSkillProfile profile,
  }) {
    final entries = profile.skillLevels.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value)); // Descending
    return entries;
  }

  /// Determine if user has "mastered" a topic
  bool hasTopicMastery({
    required PerformanceHistory history,
    required double skillLevel,
  }) {
    // Mastery requires:
    // - Skill level > 0.85
    // - At least 5 attempts
    // - Last 3 attempts all > 80% accuracy
    // - Consistent performance (low std dev)

    if (skillLevel < 0.85) return false;
    if (history.recentAttempts.length < 5) return false;

    final lastThree = history.recentAttempts.sublist(
      history.recentAttempts.length - 3,
      history.recentAttempts.length,
    );

    final allHighScore = lastThree.every((r) => r.accuracy >= 0.8);
    final lowVariance = history.scoreStandardDeviation < 0.15;

    return allHighScore && lowVariance;
  }
}
