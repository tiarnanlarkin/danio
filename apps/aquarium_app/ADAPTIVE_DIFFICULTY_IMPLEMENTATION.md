# Adaptive Difficulty System Implementation

## Overview

This document outlines the implementation of an AI-driven adaptive difficulty system for the Aquarium App's learning platform. The system personalizes the learning experience by tracking user performance and dynamically adjusting lesson difficulty.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Activity                             │
│           (Quiz answers, time spent, reviews)                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Extended LessonProgress Model                   │
│   • Quiz accuracy • Time metrics • Streak tracking           │
│   • Suggested difficulty • Performance history               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  DifficultyEngine                            │
│   • calculateDifficulty() - Analyzes recent performance      │
│   • recommendNextLesson() - Suggests easier/harder content   │
│   • selectQuestions() - Picks from difficulty-specific pools │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│            Difficulty-Aware Quiz Generation                  │
│   • Easy: 4 choices, obvious distractors                     │
│   • Medium: 4 choices, plausible distractors                 │
│   • Hard: 4 choices + fill-in-blank variants                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  UI Feedback Loop                            │
│   • Difficulty badges • Performance analytics                │
│   • User override controls • Progress visualization          │
└─────────────────────────────────────────────────────────────┘
```

---

## 1. Extended LessonProgress Model

### Current Model
```dart
class LessonProgress {
  final String lessonId;
  final DateTime completedDate;
  final DateTime? lastReviewDate;
  final int reviewCount;
  final double strength;  // 0-100, forgetting curve
}
```

### New Extended Model

**File**: `lib/models/lesson_progress.dart`

```dart
import 'package:flutter/foundation.dart';

enum LessonDifficulty {
  easy,
  medium,
  hard,
}

extension LessonDifficultyExt on LessonDifficulty {
  String get displayName {
    switch (this) {
      case LessonDifficulty.easy:
        return 'Easy';
      case LessonDifficulty.medium:
        return 'Medium';
      case LessonDifficulty.hard:
        return 'Hard';
    }
  }
  
  String get emoji {
    switch (this) {
      case LessonDifficulty.easy:
        return '🌱';
      case LessonDifficulty.medium:
        return '🌿';
      case LessonDifficulty.hard:
        return '🌳';
    }
  }
}

@immutable
class LessonProgress {
  // Existing fields
  final String lessonId;
  final DateTime completedDate;
  final DateTime? lastReviewDate;
  final int reviewCount;
  final double strength;

  // NEW: Performance tracking
  final double averageAccuracy;           // 0-100%, rolling average
  final int averageTimeSeconds;           // Average time to complete quiz
  final int consecutiveCorrect;           // Current streak of correct answers
  final int consecutiveIncorrect;         // Current streak of incorrect answers
  final LessonDifficulty suggestedDifficulty;  // AI-calculated difficulty
  final LessonDifficulty? userOverrideDifficulty;  // Manual user preference
  final List<QuizAttempt> attemptHistory; // Last 5 attempts for analysis
  
  const LessonProgress({
    required this.lessonId,
    required this.completedDate,
    this.lastReviewDate,
    this.reviewCount = 0,
    this.strength = 100.0,
    this.averageAccuracy = 0.0,
    this.averageTimeSeconds = 0,
    this.consecutiveCorrect = 0,
    this.consecutiveIncorrect = 0,
    this.suggestedDifficulty = LessonDifficulty.medium,
    this.userOverrideDifficulty,
    this.attemptHistory = const [],
  });

  /// Calculate current strength based on forgetting curve (existing logic)
  double get currentStrength {
    final referenceDate = lastReviewDate ?? completedDate;
    final daysSinceReview = DateTime.now().difference(referenceDate).inDays;
    
    if (daysSinceReview == 0) return strength;
    if (daysSinceReview == 1) return 70.0;
    if (daysSinceReview <= 7) {
      return 70.0 - ((daysSinceReview - 1) / 6) * 30.0;
    }
    if (daysSinceReview <= 30) {
      return 40.0 - ((daysSinceReview - 7) / 23) * 40.0;
    }
    return 0.0;
  }

  /// Check if lesson needs review (existing)
  bool get needsReview => currentStrength < 50.0;
  bool get isWeak => currentStrength < 70.0;

  /// NEW: Get effective difficulty (user override takes precedence)
  LessonDifficulty get effectiveDifficulty => 
      userOverrideDifficulty ?? suggestedDifficulty;

  /// NEW: Is user struggling? (used for adaptive recommendations)
  bool get isStruggling => 
      consecutiveIncorrect >= 2 || averageAccuracy < 60.0;

  /// NEW: Is user excelling? (ready for harder content)
  bool get isExcelling => 
      consecutiveCorrect >= 3 && averageAccuracy >= 90.0;

  /// NEW: Record a quiz attempt
  LessonProgress recordAttempt({
    required int correctAnswers,
    required int totalQuestions,
    required int timeSeconds,
    required LessonDifficulty attemptedDifficulty,
  }) {
    final accuracy = (correctAnswers / totalQuestions) * 100;
    
    // Update attempt history (keep last 5)
    final newAttempt = QuizAttempt(
      date: DateTime.now(),
      accuracy: accuracy,
      timeSeconds: timeSeconds,
      difficulty: attemptedDifficulty,
    );
    final updatedHistory = [...attemptHistory, newAttempt];
    if (updatedHistory.length > 5) {
      updatedHistory.removeAt(0);
    }

    // Calculate new rolling average accuracy
    final allAccuracies = updatedHistory.map((a) => a.accuracy).toList();
    final newAvgAccuracy = allAccuracies.isEmpty 
        ? accuracy 
        : allAccuracies.reduce((a, b) => a + b) / allAccuracies.length;

    // Calculate new average time
    final allTimes = updatedHistory.map((a) => a.timeSeconds).toList();
    final newAvgTime = allTimes.isEmpty
        ? timeSeconds
        : (allTimes.reduce((a, b) => a + b) / allTimes.length).round();

    // Update consecutive streaks
    final allCorrect = correctAnswers == totalQuestions;
    final newConsecutiveCorrect = allCorrect ? consecutiveCorrect + 1 : 0;
    final newConsecutiveIncorrect = !allCorrect ? consecutiveIncorrect + 1 : 0;

    return copyWith(
      lastReviewDate: DateTime.now(),
      reviewCount: reviewCount + 1,
      strength: 100.0,
      averageAccuracy: newAvgAccuracy,
      averageTimeSeconds: newAvgTime,
      consecutiveCorrect: newConsecutiveCorrect,
      consecutiveIncorrect: newConsecutiveIncorrect,
      attemptHistory: updatedHistory,
    );
  }

  /// Create a copy with updated review (existing, extended)
  LessonProgress reviewed() {
    return copyWith(
      lastReviewDate: DateTime.now(),
      reviewCount: reviewCount + 1,
      strength: 100.0,
    );
  }

  LessonProgress copyWith({
    String? lessonId,
    DateTime? completedDate,
    DateTime? lastReviewDate,
    int? reviewCount,
    double? strength,
    double? averageAccuracy,
    int? averageTimeSeconds,
    int? consecutiveCorrect,
    int? consecutiveIncorrect,
    LessonDifficulty? suggestedDifficulty,
    LessonDifficulty? userOverrideDifficulty,
    List<QuizAttempt>? attemptHistory,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      completedDate: completedDate ?? this.completedDate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      reviewCount: reviewCount ?? this.reviewCount,
      strength: strength ?? this.strength,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      averageTimeSeconds: averageTimeSeconds ?? this.averageTimeSeconds,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      consecutiveIncorrect: consecutiveIncorrect ?? this.consecutiveIncorrect,
      suggestedDifficulty: suggestedDifficulty ?? this.suggestedDifficulty,
      userOverrideDifficulty: userOverrideDifficulty ?? this.userOverrideDifficulty,
      attemptHistory: attemptHistory ?? this.attemptHistory,
    );
  }

  Map<String, dynamic> toJson() => {
    'lessonId': lessonId,
    'completedDate': completedDate.toIso8601String(),
    'lastReviewDate': lastReviewDate?.toIso8601String(),
    'reviewCount': reviewCount,
    'strength': strength,
    'averageAccuracy': averageAccuracy,
    'averageTimeSeconds': averageTimeSeconds,
    'consecutiveCorrect': consecutiveCorrect,
    'consecutiveIncorrect': consecutiveIncorrect,
    'suggestedDifficulty': suggestedDifficulty.index,
    'userOverrideDifficulty': userOverrideDifficulty?.index,
    'attemptHistory': attemptHistory.map((a) => a.toJson()).toList(),
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
      averageAccuracy: (json['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      averageTimeSeconds: json['averageTimeSeconds'] as int? ?? 0,
      consecutiveCorrect: json['consecutiveCorrect'] as int? ?? 0,
      consecutiveIncorrect: json['consecutiveIncorrect'] as int? ?? 0,
      suggestedDifficulty: json['suggestedDifficulty'] != null
          ? LessonDifficulty.values[json['suggestedDifficulty'] as int]
          : LessonDifficulty.medium,
      userOverrideDifficulty: json['userOverrideDifficulty'] != null
          ? LessonDifficulty.values[json['userOverrideDifficulty'] as int]
          : null,
      attemptHistory: (json['attemptHistory'] as List<dynamic>?)
              ?.map((a) => QuizAttempt.fromJson(a as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

/// Individual quiz attempt record
@immutable
class QuizAttempt {
  final DateTime date;
  final double accuracy;  // 0-100%
  final int timeSeconds;
  final LessonDifficulty difficulty;

  const QuizAttempt({
    required this.date,
    required this.accuracy,
    required this.timeSeconds,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'accuracy': accuracy,
    'timeSeconds': timeSeconds,
    'difficulty': difficulty.index,
  };

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      date: DateTime.parse(json['date'] as String),
      accuracy: (json['accuracy'] as num).toDouble(),
      timeSeconds: json['timeSeconds'] as int,
      difficulty: LessonDifficulty.values[json['difficulty'] as int],
    );
  }
}
```

---

## 2. DifficultyEngine Class

**File**: `lib/services/difficulty_engine.dart`

```dart
import '../models/lesson_progress.dart';
import '../models/learning.dart';
import '../models/user_profile.dart';

/// Core algorithm for adaptive difficulty adjustment
class DifficultyEngine {
  // Adjustment thresholds
  static const double _accuracyThresholdHard = 90.0;      // 90%+ → harder
  static const double _accuracyThresholdEasy = 60.0;      // <60% → easier
  static const int _timeThresholdFast = 120;              // <2min → may be too easy
  static const int _streakThresholdExcel = 3;             // 3 correct → excelling
  static const int _streakThresholdStruggle = 2;          // 2 incorrect → struggling

  /// Calculate suggested difficulty based on performance history
  static LessonDifficulty calculateDifficulty({
    required LessonProgress? progress,
    required UserProfile userProfile,
    LessonDifficulty? currentDifficulty,
  }) {
    // New users start at medium (unless beginner experience level)
    if (progress == null || progress.attemptHistory.isEmpty) {
      return userProfile.experienceLevel == ExperienceLevel.beginner
          ? LessonDifficulty.easy
          : LessonDifficulty.medium;
    }

    final current = currentDifficulty ?? progress.suggestedDifficulty;

    // Check if user is excelling (ready for harder content)
    if (progress.isExcelling && current != LessonDifficulty.hard) {
      return _increasedifficulty(current);
    }

    // Check if user is struggling (need easier content)
    if (progress.isStruggling && current != LessonDifficulty.easy) {
      return _decreasedifficulty(current);
    }

    // Additional checks based on time spent
    if (progress.averageAccuracy >= _accuracyThresholdHard &&
        progress.averageTimeSeconds < _timeThresholdFast &&
        current != LessonDifficulty.hard) {
      // Fast + accurate = ready for challenge
      return _increasedifficulty(current);
    }

    // Keep current difficulty if performance is stable
    return current;
  }

  /// Recommend next lesson based on user performance across all lessons
  static String? recommendNextLesson({
    required List<Lesson> availableLessons,
    required Map<String, LessonProgress> progressMap,
    required List<String> completedLessonIds,
  }) {
    // 1. Prioritize weak lessons that need review
    final weakLessons = progressMap.entries
        .where((e) => e.value.needsReview)
        .map((e) => e.key)
        .toList();
    
    if (weakLessons.isNotEmpty) {
      return weakLessons.first;  // Return oldest weak lesson
    }

    // 2. Next uncompleted lesson in sequence
    for (final lesson in availableLessons) {
      if (!completedLessonIds.contains(lesson.id) &&
          lesson.isUnlocked(completedLessonIds)) {
        return lesson.id;
      }
    }

    // 3. All lessons complete - suggest reviewing oldest
    if (progressMap.isNotEmpty) {
      final sortedByDate = progressMap.entries.toList()
        ..sort((a, b) => a.value.lastReviewDate?.compareTo(
                b.value.lastReviewDate ?? DateTime(2000)) ?? 0);
      return sortedByDate.first.key;
    }

    return null;  // No recommendations
  }

  /// Select questions from difficulty-specific pool
  static List<QuizQuestion> selectQuestions({
    required Lesson lesson,
    required LessonDifficulty difficulty,
    int count = 5,
  }) {
    // Get base quiz questions
    final baseQuiz = lesson.quiz;
    if (baseQuiz == null) return [];

    // In a full implementation, you'd have separate question pools
    // For now, we'll modify question complexity on the fly
    
    return baseQuiz.questions.take(count).map((q) {
      return _adjustQuestionDifficulty(q, difficulty);
    }).toList();
  }

  /// Adjust question based on difficulty level
  static QuizQuestion _adjustQuestionDifficulty(
    QuizQuestion original,
    LessonDifficulty difficulty,
  ) {
    switch (difficulty) {
      case LessonDifficulty.easy:
        // Easy: Reduce options, make distractors more obvious
        return original;  // For now, keep as-is
        
      case LessonDifficulty.medium:
        // Medium: Standard question
        return original;
        
      case LessonDifficulty.hard:
        // Hard: Could add more nuanced distractors
        // Or convert to fill-in-blank in future
        return original;
    }
  }

  static LessonDifficulty _increasedifficulty(LessonDifficulty current) {
    switch (current) {
      case LessonDifficulty.easy:
        return LessonDifficulty.medium;
      case LessonDifficulty.medium:
        return LessonDifficulty.hard;
      case LessonDifficulty.hard:
        return LessonDifficulty.hard;  // Already at max
    }
  }

  static LessonDifficulty _decreasedifficulty(LessonDifficulty current) {
    switch (current) {
      case LessonDifficulty.easy:
        return LessonDifficulty.easy;  // Already at min
      case LessonDifficulty.medium:
        return LessonDifficulty.easy;
      case LessonDifficulty.hard:
        return LessonDifficulty.medium;
    }
  }

  /// Get user-friendly feedback message
  static String getDifficultyFeedback({
    required LessonProgress progress,
    required LessonDifficulty newDifficulty,
    required LessonDifficulty oldDifficulty,
  }) {
    if (newDifficulty.index > oldDifficulty.index) {
      return "Great job! 🎉 Your performance is excellent. Let's try harder questions!";
    } else if (newDifficulty.index < oldDifficulty.index) {
      return "Let's practice some easier questions to build confidence. 💪";
    } else {
      return "You're doing well! Keep it up! 🌟";
    }
  }
}
```

---

## 3. Question Pool Structure

### Difficulty-Specific Question Design

Each lesson quiz should have 3 parallel question pools:

#### **Easy Questions**
- **4 multiple choice options** (down from 5-6)
- **Obvious distractors** - clearly wrong answers
- **Direct recall** - questions match lesson content exactly
- **Visual hints** - emoji or formatting clues

#### **Medium Questions**
- **4 multiple choice options**
- **Plausible distractors** - all answers sound reasonable
- **Application** - require understanding, not just recall
- **Standard formatting**

#### **Hard Questions**
- **4 multiple choice options with subtle differences**
- **All plausible distractors** - expert-level discrimination
- **Synthesis** - combine multiple concepts
- **OR fill-in-blank variants** - no multiple choice hints

### Example: Nitrogen Cycle Question Pools

**Easy:**
```dart
QuizQuestion(
  id: 'nc_easy_1',
  question: 'What do fish produce that creates ammonia? 💩',
  options: [
    'Waste',           // ✓ Correct
    'Oxygen',          // Clearly wrong
    'Carbon dioxide',  // Clearly wrong
    'Light',           // Clearly wrong
  ],
  correctIndex: 0,
  difficulty: LessonDifficulty.easy,
  explanation: 'Fish waste breaks down into toxic ammonia.',
),
```

**Medium:**
```dart
QuizQuestion(
  id: 'nc_medium_1',
  question: 'What is the correct order of the nitrogen cycle?',
  options: [
    'Ammonia → Nitrite → Nitrate',      // ✓ Correct
    'Nitrite → Ammonia → Nitrate',      // Plausible
    'Ammonia → Nitrate → Nitrite',      // Plausible
    'Nitrate → Nitrite → Ammonia',      // Plausible
  ],
  correctIndex: 0,
  difficulty: LessonDifficulty.medium,
  explanation: 'Ammonia is produced first, then bacteria convert it to nitrite, then to nitrate.',
),
```

**Hard:**
```dart
QuizQuestion(
  id: 'nc_hard_1',
  question: 'Why is the nitrite spike often more dangerous than the initial ammonia spike?',
  options: [
    'Nitrite causes "brown blood disease" which damages oxygen transport',  // ✓ Correct
    'Nitrite is more toxic in lower concentrations than ammonia',           // Plausible
    'Beneficial bacteria take longer to process nitrite',                   // Plausible
    'Fish cannot sense nitrite in the water as easily',                     // Plausible
  ],
  correctIndex: 0,
  difficulty: LessonDifficulty.hard,
  explanation: 'Nitrite binds to hemoglobin, preventing oxygen transport (methemoglobinemia).',
),
```

### Extended Quiz Model

**File**: `lib/models/learning.dart` (extend existing)

```dart
/// Quiz at the end of a lesson (EXTENDED)
@immutable
class Quiz {
  final String id;
  final String lessonId;
  final List<QuizQuestion> questions;
  final int passingScore;
  final int bonusXp;
  
  // NEW: Difficulty-specific question pools
  final List<QuizQuestion>? easyQuestions;
  final List<QuizQuestion>? mediumQuestions;
  final List<QuizQuestion>? hardQuestions;

  const Quiz({
    required this.id,
    required this.lessonId,
    required this.questions,  // Default/medium questions
    this.passingScore = 70,
    this.bonusXp = 25,
    this.easyQuestions,
    this.mediumQuestions,
    this.hardQuestions,
  });

  int get maxScore => questions.length;
  
  /// Get questions for specific difficulty level
  List<QuizQuestion> getQuestionsForDifficulty(LessonDifficulty difficulty) {
    switch (difficulty) {
      case LessonDifficulty.easy:
        return easyQuestions ?? questions;
      case LessonDifficulty.medium:
        return mediumQuestions ?? questions;
      case LessonDifficulty.hard:
        return hardQuestions ?? questions;
    }
  }
}

/// A single quiz question (EXTENDED)
@immutable
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final LessonDifficulty difficulty;  // NEW

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.difficulty = LessonDifficulty.medium,  // NEW
  });
}
```

---

## 4. UI Components

### A. Difficulty Badge (Lesson Cards)

**File**: `lib/widgets/difficulty_badge.dart`

```dart
import 'package:flutter/material.dart';
import '../models/lesson_progress.dart';

class DifficultyBadge extends StatelessWidget {
  final LessonDifficulty difficulty;
  final bool isUserOverride;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.isUserOverride = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getColor(),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            difficulty.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            difficulty.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getColor(),
            ),
          ),
          if (isUserOverride) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.settings,
              size: 12,
              color: _getColor(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColor() {
    switch (difficulty) {
      case LessonDifficulty.easy:
        return Colors.green;
      case LessonDifficulty.medium:
        return Colors.orange;
      case LessonDifficulty.hard:
        return Colors.red;
    }
  }
}
```

### B. Performance Analytics Screen

**File**: `lib/screens/performance_analytics_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/lesson_progress.dart';
import '../models/user_profile.dart';

class PerformanceAnalyticsScreen extends StatelessWidget {
  final UserProfile profile;

  const PerformanceAnalyticsScreen({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final progressList = profile.lessonProgress.values.toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall stats card
            _buildOverallStatsCard(progressList),
            const SizedBox(height: 24),
            
            // Accuracy trend chart
            _buildAccuracyTrendChart(progressList),
            const SizedBox(height: 24),
            
            // Difficulty distribution
            _buildDifficultyDistribution(progressList),
            const SizedBox(height: 24),
            
            // Recent adjustments
            _buildRecentAdjustments(progressList),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(List<LessonProgress> progressList) {
    final avgAccuracy = progressList.isEmpty
        ? 0.0
        : progressList
            .map((p) => p.averageAccuracy)
            .reduce((a, b) => a + b) / progressList.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Overall Performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '${avgAccuracy.toStringAsFixed(1)}%',
                  'Avg Accuracy',
                  Icons.assessment,
                ),
                _buildStatItem(
                  '${progressList.length}',
                  'Lessons',
                  Icons.book,
                ),
                _buildStatItem(
                  '${_countByDifficulty(progressList, LessonDifficulty.hard)}',
                  'Hard Mode',
                  Icons.whatshot,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAccuracyTrendChart(List<LessonProgress> progressList) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accuracy Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  // Chart implementation here
                  // Would plot attemptHistory over time
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyDistribution(List<LessonProgress> progressList) {
    final easy = _countByDifficulty(progressList, LessonDifficulty.easy);
    final medium = _countByDifficulty(progressList, LessonDifficulty.medium);
    final hard = _countByDifficulty(progressList, LessonDifficulty.hard);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Difficulty Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDifficultyBar(LessonDifficulty.easy, easy, progressList.length),
            const SizedBox(height: 8),
            _buildDifficultyBar(LessonDifficulty.medium, medium, progressList.length),
            const SizedBox(height: 8),
            _buildDifficultyBar(LessonDifficulty.hard, hard, progressList.length),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBar(LessonDifficulty difficulty, int count, int total) {
    final percentage = total == 0 ? 0.0 : (count / total);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${difficulty.emoji} ${difficulty.displayName}'),
            const Spacer(),
            Text('$count lessons'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          color: _getDifficultyColor(difficulty),
        ),
      ],
    );
  }

  Widget _buildRecentAdjustments(List<LessonProgress> progressList) {
    // Show lessons where difficulty changed recently
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Difficulty Adjustments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'System automatically adjusts based on your performance',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // List adjustment history here
            const Text('(List of recent changes would appear here)'),
          ],
        ),
      ),
    );
  }

  int _countByDifficulty(List<LessonProgress> progressList, LessonDifficulty difficulty) {
    return progressList
        .where((p) => p.effectiveDifficulty == difficulty)
        .length;
  }

  Color _getDifficultyColor(LessonDifficulty difficulty) {
    switch (difficulty) {
      case LessonDifficulty.easy:
        return Colors.green;
      case LessonDifficulty.medium:
        return Colors.orange;
      case LessonDifficulty.hard:
        return Colors.red;
    }
  }
}
```

### C. Settings Toggle (Adaptive Learning)

**File**: `lib/screens/settings_screen.dart` (extend existing)

```dart
// Add to existing settings screen

class AdaptiveLearningSettings extends StatelessWidget {
  final bool adaptiveLearningEnabled;
  final Function(bool) onToggle;

  const AdaptiveLearningSettings({
    super.key,
    required this.adaptiveLearningEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adaptive Learning',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AI adjusts quiz difficulty based on your performance',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: adaptiveLearningEnabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            if (adaptiveLearningEnabled) ...[
              const Divider(height: 24),
              const Text(
                'How it works:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('90%+ accuracy → Harder questions'),
              _buildBulletPoint('60% or below → Easier questions'),
              _buildBulletPoint('3+ correct streak → Level up'),
              _buildBulletPoint('2+ incorrect streak → Level down'),
              const SizedBox(height: 12),
              const Text(
                'You can always override the difficulty manually on each lesson.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          const Text('•', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
```

---

## 5. Integration with Existing Code

### Update UserProfileProvider

**File**: `lib/providers/user_profile_provider.dart` (extend)

```dart
// Add new method to UserProfileNotifier

/// Update lesson progress after quiz completion with performance tracking
Future<void> recordQuizCompletion({
  required String lessonId,
  required int correctAnswers,
  required int totalQuestions,
  required int timeSeconds,
  required LessonDifficulty attemptedDifficulty,
}) async {
  final current = state.value;
  if (current == null) return;

  // Get or create lesson progress
  final existingProgress = current.lessonProgress[lessonId];
  final isFirstCompletion = existingProgress == null;

  final updatedProgress = existingProgress?.recordAttempt(
    correctAnswers: correctAnswers,
    totalQuestions: totalQuestions,
    timeSeconds: timeSeconds,
    attemptedDifficulty: attemptedDifficulty,
  ) ?? LessonProgress(
    lessonId: lessonId,
    completedDate: DateTime.now(),
    lastReviewDate: DateTime.now(),
    reviewCount: 1,
    strength: 100.0,
  ).recordAttempt(
    correctAnswers: correctAnswers,
    totalQuestions: totalQuestions,
    timeSeconds: timeSeconds,
    attemptedDifficulty: attemptedDifficulty,
  );

  // Calculate new suggested difficulty
  final newSuggestedDifficulty = DifficultyEngine.calculateDifficulty(
    progress: updatedProgress,
    userProfile: current,
    currentDifficulty: attemptedDifficulty,
  );

  final finalProgress = updatedProgress.copyWith(
    suggestedDifficulty: newSuggestedDifficulty,
  );

  // Update profile
  final updatedProgressMap = Map<String, LessonProgress>.from(current.lessonProgress);
  updatedProgressMap[lessonId] = finalProgress;

  final completedLessons = isFirstCompletion
      ? [...current.completedLessons, lessonId]
      : current.completedLessons;

  final updated = current.copyWith(
    lessonProgress: updatedProgressMap,
    completedLessons: completedLessons,
    updatedAt: DateTime.now(),
  );

  await _save(updated);
  state = AsyncValue.data(updated);
}

/// Override difficulty manually
Future<void> overrideLessonDifficulty({
  required String lessonId,
  LessonDifficulty? difficulty,  // null = clear override
}) async {
  final current = state.value;
  if (current == null) return;

  final progress = current.lessonProgress[lessonId];
  if (progress == null) return;

  final updated = progress.copyWith(
    userOverrideDifficulty: difficulty,
  );

  final updatedProgressMap = Map<String, LessonProgress>.from(current.lessonProgress);
  updatedProgressMap[lessonId] = updated;

  final profile = current.copyWith(
    lessonProgress: updatedProgressMap,
    updatedAt: DateTime.now(),
  );

  await _save(profile);
  state = AsyncValue.data(profile);
}
```

---

## 6. Example Question Pools (Complete)

### Nitrogen Cycle - Lesson 1 (nc_intro)

```dart
// EASY POOL
final easyQuestions = [
  QuizQuestion(
    id: 'nc_intro_easy_1',
    question: 'What do fish produce that creates ammonia? 💩',
    options: ['Waste', 'Oxygen', 'Light', 'Heat'],
    correctIndex: 0,
    difficulty: LessonDifficulty.easy,
  ),
  QuizQuestion(
    id: 'nc_intro_easy_2',
    question: 'Is ammonia visible in aquarium water? 👀',
    options: ['No, it\'s invisible', 'Yes, it\'s green', 'Yes, it\'s cloudy', 'Yes, it sparkles'],
    correctIndex: 0,
    difficulty: LessonDifficulty.easy,
  ),
  QuizQuestion(
    id: 'nc_intro_easy_3',
    question: 'How long does cycling a new tank usually take? ⏰',
    options: ['2-6 weeks', '1 hour', '1 day', '1 year'],
    correctIndex: 0,
    difficulty: LessonDifficulty.easy,
  ),
];

// MEDIUM POOL (current quiz questions)
final mediumQuestions = [
  QuizQuestion(
    id: 'nc_intro_q1',
    question: 'What is "New Tank Syndrome"?',
    options: [
      'When a tank leaks water',
      'Fish dying due to lack of beneficial bacteria',
      'Algae growing too fast',
      'The tank being too cold',
    ],
    correctIndex: 1,
    difficulty: LessonDifficulty.medium,
  ),
  // ... existing questions
];

// HARD POOL
final hardQuestions = [
  QuizQuestion(
    id: 'nc_intro_hard_1',
    question: 'Why is New Tank Syndrome particularly dangerous in heavily stocked new aquariums?',
    options: [
      'More fish produce waste faster than bacterial colonies can establish',
      'Heavy stocking depletes oxygen needed by bacteria',
      'Fish competition weakens immune systems making them vulnerable',
      'Dense populations prevent water circulation to biofilm surfaces',
    ],
    correctIndex: 0,
    difficulty: LessonDifficulty.hard,
  ),
  QuizQuestion(
    id: 'nc_intro_hard_2',
    question: 'Which factor most directly accelerates beneficial bacteria colonization?',
    options: [
      'Surface area of biological media in the filter',
      'Water temperature above 25°C',
      'Elevated pH above 7.5',
      'Presence of live plants',
    ],
    correctIndex: 0,
    difficulty: LessonDifficulty.hard,
  ),
];
```

### Water Parameters - pH Lesson

```dart
// EASY
final easyQuestions = [
  QuizQuestion(
    id: 'wp_ph_easy_1',
    question: 'What pH number is neutral? ⚖️',
    options: ['7', '0', '14', '10'],
    correctIndex: 0,
    difficulty: LessonDifficulty.easy,
  ),
  QuizQuestion(
    id: 'wp_ph_easy_2',
    question: 'Should you use chemicals to constantly adjust pH? ❌',
    options: [
      'No, stable pH is better',
      'Yes, every day',
      'Yes, twice a day',
      'Only on weekends',
    ],
    correctIndex: 0,
    difficulty: LessonDifficulty.easy,
  ),
];

// MEDIUM
final mediumQuestions = [
  QuizQuestion(
    id: 'wp_ph_q1',
    question: 'What pH is considered neutral?',
    options: ['0', '5', '7', '14'],
    correctIndex: 2,
    difficulty: LessonDifficulty.medium,
  ),
  QuizQuestion(
    id: 'wp_ph_q2',
    question: 'What\'s more important for fish health?',
    options: [
      'Having exactly pH 7.0',
      'Stable pH with minimal fluctuations',
      'Low pH below 6.0',
      'High pH above 8.0',
    ],
    correctIndex: 1,
    difficulty: LessonDifficulty.medium,
  ),
];

// HARD
final hardQuestions = [
  QuizQuestion(
    id: 'wp_ph_hard_1',
    question: 'Why do pH crashes occur more readily in soft water (low KH) systems?',
    options: [
      'Lack of carbonate buffers allows acids to freely lower pH',
      'Soft water has higher dissolved CO2 concentration',
      'Beneficial bacteria produce more acid in soft water',
      'Soft water increases fish waste acidity',
    ],
    correctIndex: 0,
    difficulty: LessonDifficulty.hard,
  ),
  QuizQuestion(
    id: 'wp_ph_hard_2',
    question: 'How does nitrification affect pH over time in established aquariums?',
    options: [
      'Nitric acid production gradually lowers pH',
      'Oxygen consumption raises pH',
      'Bacterial respiration stabilizes pH',
      'No effect - pH remains constant',
    ],
    correctIndex: 0,
    difficulty: LessonDifficulty.hard,
  ),
];
```

---

## 7. Algorithm Summary

### Decision Tree

```
User completes quiz
    │
    ├─→ Record attempt (accuracy, time, difficulty)
    │
    ├─→ Update streaks (consecutive correct/incorrect)
    │
    ├─→ Calculate new suggested difficulty:
    │       │
    │       ├─→ If averageAccuracy ≥ 90% AND consecutiveCorrect ≥ 3
    │       │       └─→ INCREASE difficulty (Easy → Medium → Hard)
    │       │
    │       ├─→ If averageAccuracy < 60% OR consecutiveIncorrect ≥ 2
    │       │       └─→ DECREASE difficulty (Hard → Medium → Easy)
    │       │
    │       ├─→ If averageAccuracy ≥ 90% AND averageTime < 120s
    │       │       └─→ INCREASE difficulty (too easy + fast)
    │       │
    │       └─→ Otherwise
    │               └─→ MAINTAIN current difficulty
    │
    └─→ Show feedback message and update badge
```

### Performance Metrics

- **averageAccuracy**: Rolling average of last 5 attempts
- **consecutiveCorrect**: Reset to 0 on any incorrect answer
- **consecutiveIncorrect**: Reset to 0 on any correct answer
- **averageTimeSeconds**: Average quiz completion time
- **suggestedDifficulty**: AI-calculated from algorithm
- **userOverrideDifficulty**: Manual override (always takes precedence)

---

## 8. Implementation Checklist

### Phase 1: Core Models (Week 1)
- [ ] Extend `LessonProgress` with performance metrics
- [ ] Add `QuizAttempt` model
- [ ] Add `LessonDifficulty` enum and extensions
- [ ] Update JSON serialization/deserialization
- [ ] Add migration logic for existing users

### Phase 2: Engine (Week 2)
- [ ] Create `DifficultyEngine` class
- [ ] Implement `calculateDifficulty()` algorithm
- [ ] Implement `recommendNextLesson()`
- [ ] Implement `selectQuestions()`
- [ ] Add unit tests for engine logic

### Phase 3: Question Pools (Week 3)
- [ ] Create easy variants for all existing quizzes
- [ ] Create hard variants for all existing quizzes
- [ ] Extend `Quiz` model with difficulty pools
- [ ] Update lesson_content.dart with new pools

### Phase 4: UI Components (Week 4)
- [ ] Create `DifficultyBadge` widget
- [ ] Add difficulty indicators to lesson cards
- [ ] Create `PerformanceAnalyticsScreen`
- [ ] Add adaptive learning toggle to settings
- [ ] Add manual difficulty override UI

### Phase 5: Integration (Week 5)
- [ ] Update `UserProfileProvider` with new methods
- [ ] Update `EnhancedQuizScreen` to use difficulty system
- [ ] Add performance tracking on quiz completion
- [ ] Add difficulty adjustment feedback messages
- [ ] Hook up analytics screen navigation

### Phase 6: Testing & Polish (Week 6)
- [ ] Test difficulty progression edge cases
- [ ] Test manual override functionality
- [ ] Add onboarding tutorial for adaptive learning
- [ ] Performance optimization
- [ ] User feedback collection

---

## 9. Future Enhancements

### V2 Features
- **Fill-in-blank questions** for hard mode (no multiple choice hints)
- **Spaced repetition integration** - difficulty affects review schedule
- **Learning style detection** - visual vs. text-based preference
- **Confidence rating** - user self-reports certainty after answer
- **Peer comparison** - "You're performing better than 75% of users at this level"

### V3 Features
- **Adaptive lesson length** - struggling users get shorter sessions
- **Micro-lessons** - 2-minute quick reviews for weak topics
- **Gamification** - "Hard Mode Streak" badges
- **AI-generated explanations** - personalized based on mistakes
- **Voice mode** - audio quizzes for auditory learners

---

## 10. Privacy & Data

All performance data is stored **locally** using SharedPreferences. No quiz answers or performance metrics are sent to external servers. Users can clear their performance history at any time in settings.

---

## Conclusion

This adaptive difficulty system transforms the Aquarium App from a static learning platform into a personalized education experience. By tracking quiz accuracy, time, and streaks, the system dynamically adjusts to each user's skill level—keeping beginners engaged without overwhelming them, and challenging experts without boring them.

The implementation is **backwards compatible** (existing users start at medium difficulty), **user-controllable** (manual override available), and **transparent** (analytics show why adjustments happen). 

**Next Steps:**
1. Implement Phase 1 (models) and test with sample data
2. Build Phase 2 (engine) and validate algorithm with real scenarios
3. Create Phase 3 (question pools) for 2-3 lessons as proof-of-concept
4. Design Phase 4 (UI) and get user feedback on mockups
5. Roll out gradually with A/B testing

---

**Document Version:** 1.0  
**Last Updated:** 2024-02-07  
**Author:** AI Subagent (adaptive-difficulty-sonnet)
