/// Placement test system for assessing user knowledge and skipping lessons
/// Duolingo-style onboarding to personalize the learning journey

import 'package:flutter/foundation.dart';
import 'learning.dart';
import 'user_profile.dart';

/// A placement test to assess user's existing knowledge
/// Contains 20 questions spanning all learning paths
@immutable
class PlacementTest {
  final String id;
  final String title;
  final String description;
  final List<PlacementQuestion> questions;
  final Duration? timeLimit;

  const PlacementTest({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.timeLimit,
  });

  int get totalQuestions => questions.length;

  /// Get questions grouped by learning path
  Map<String, List<PlacementQuestion>> get questionsByPath {
    final Map<String, List<PlacementQuestion>> grouped = {};
    for (final question in questions) {
      if (!grouped.containsKey(question.pathId)) {
        grouped[question.pathId] = [];
      }
      grouped[question.pathId]!.add(question);
    }
    return grouped;
  }

  /// Calculate score for a specific path (0-100%)
  double calculatePathScore(String pathId, Map<String, bool> answers) {
    final pathQuestions = questions.where((q) => q.pathId == pathId).toList();
    if (pathQuestions.isEmpty) return 0.0;

    int correct = 0;
    for (final question in pathQuestions) {
      if (answers[question.id] == true) {
        correct++;
      }
    }

    return (correct / pathQuestions.length) * 100;
  }

  /// Calculate overall score (0-100%)
  double calculateOverallScore(Map<String, bool> answers) {
    if (questions.isEmpty) return 0.0;

    int correct = 0;
    for (final question in questions) {
      if (answers[question.id] == true) {
        correct++;
      }
    }

    return (correct / questions.length) * 100;
  }
}

/// A single question in the placement test
@immutable
class PlacementQuestion {
  final String id;
  final String pathId; // Which learning path this tests
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final QuestionDifficulty difficulty;

  const PlacementQuestion({
    required this.id,
    required this.pathId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.difficulty = QuestionDifficulty.medium,
  });

  bool validateAnswer(int selectedIndex) {
    return selectedIndex == correctIndex;
  }

  String get correctAnswer => options[correctIndex];
}

enum QuestionDifficulty {
  beginner,  // Tests basic concepts (should know if completed beginner lessons)
  intermediate, // Tests deeper understanding
  advanced, // Tests expert knowledge
}

/// Result of a placement test with recommendations
@immutable
class PlacementResult {
  final String id;
  final String testId;
  final DateTime completedAt;
  final Map<String, bool> answers; // questionId -> isCorrect
  final double overallScore;
  final Map<String, double> pathScores; // pathId -> score (0-100)
  final Map<String, SkipRecommendation> recommendations; // pathId -> recommendation

  const PlacementResult({
    required this.id,
    required this.testId,
    required this.completedAt,
    required this.answers,
    required this.overallScore,
    required this.pathScores,
    required this.recommendations,
  });

  /// Get number of correct answers
  int get correctAnswers => answers.values.where((v) => v).length;

  /// Get total questions answered
  int get totalAnswers => answers.length;

  /// Get percentage score
  double get percentageScore => (correctAnswers / totalAnswers) * 100;

  /// Get suggested experience level based on overall score
  ExperienceLevel get suggestedExperienceLevel {
    if (overallScore >= 70) return ExperienceLevel.expert;
    if (overallScore >= 40) return ExperienceLevel.intermediate;
    return ExperienceLevel.beginner;
  }

  /// Get lessons to mark as completed (tested out)
  List<String> get lessonsToSkip {
    final List<String> skip = [];
    for (final entry in recommendations.entries) {
      skip.addAll(entry.value.lessonsToSkip);
    }
    return skip;
  }

  /// Get total XP to award for tested-out lessons
  int calculateSkipXp(List<LearningPath> allPaths) {
    int totalXp = 0;
    for (final entry in recommendations.entries) {
      final path = allPaths.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => throw Exception('Path not found: ${entry.key}'),
      );
      
      for (final lessonId in entry.value.lessonsToSkip) {
        final lesson = path.lessons.firstWhere(
          (l) => l.id == lessonId,
          orElse: () => throw Exception('Lesson not found: $lessonId'),
        );
        // Award 50% of lesson XP for testing out
        totalXp += (lesson.xpReward * 0.5).round();
      }
    }
    return totalXp;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'testId': testId,
        'completedAt': completedAt.toIso8601String(),
        'answers': answers,
        'overallScore': overallScore,
        'pathScores': pathScores,
        'recommendations': recommendations.map(
          (k, v) => MapEntry(k, v.toJson()),
        ),
      };

  factory PlacementResult.fromJson(Map<String, dynamic> json) {
    return PlacementResult(
      id: json['id'],
      testId: json['testId'],
      completedAt: DateTime.parse(json['completedAt']),
      answers: Map<String, bool>.from(json['answers']),
      overallScore: json['overallScore'],
      pathScores: Map<String, double>.from(json['pathScores']),
      recommendations: (json['recommendations'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, SkipRecommendation.fromJson(v)),
      ),
    );
  }
}

/// Recommendation for what to skip in a learning path
@immutable
class SkipRecommendation {
  final String pathId;
  final double score; // 0-100
  final SkipLevel skipLevel;
  final List<String> lessonsToSkip; // Lesson IDs to mark as completed
  final String? startFromLessonId; // Where to start in the path

  const SkipRecommendation({
    required this.pathId,
    required this.score,
    required this.skipLevel,
    required this.lessonsToSkip,
    this.startFromLessonId,
  });

  String get description {
    switch (skipLevel) {
      case SkipLevel.none:
        return 'Start from the beginning - these fundamentals are important!';
      case SkipLevel.beginner:
        return 'Skip beginner lessons - you know the basics!';
      case SkipLevel.advanced:
        return 'Skip to advanced - you\'re already knowledgeable!';
      case SkipLevel.complete:
        return 'Path completed - you\'re an expert here!';
    }
  }

  String get emoji {
    switch (skipLevel) {
      case SkipLevel.none:
        return '📚';
      case SkipLevel.beginner:
        return '⏭️';
      case SkipLevel.advanced:
        return '🚀';
      case SkipLevel.complete:
        return '🎓';
    }
  }

  Map<String, dynamic> toJson() => {
        'pathId': pathId,
        'score': score,
        'skipLevel': skipLevel.name,
        'lessonsToSkip': lessonsToSkip,
        'startFromLessonId': startFromLessonId,
      };

  factory SkipRecommendation.fromJson(Map<String, dynamic> json) {
    return SkipRecommendation(
      pathId: json['pathId'],
      score: json['score'],
      skipLevel: SkipLevel.values.firstWhere(
        (e) => e.name == json['skipLevel'],
      ),
      lessonsToSkip: List<String>.from(json['lessonsToSkip']),
      startFromLessonId: json['startFromLessonId'],
    );
  }
}

enum SkipLevel {
  none,      // < 50% - Start from beginning
  beginner,  // 50-79% - Skip beginner lessons
  advanced,  // 80-94% - Skip to advanced lessons
  complete,  // 95%+ - Mark entire path complete
}

/// Algorithm to generate recommendations based on path scores
class PlacementAlgorithm {
  /// Generate skip recommendations for each learning path
  static Map<String, SkipRecommendation> generateRecommendations({
    required Map<String, double> pathScores,
    required List<LearningPath> allPaths,
  }) {
    final Map<String, SkipRecommendation> recommendations = {};

    for (final path in allPaths) {
      final score = pathScores[path.id] ?? 0.0;
      final lessons = path.lessons;

      SkipLevel skipLevel;
      List<String> lessonsToSkip = [];
      String? startFromLessonId;

      if (score >= 95) {
        // Expert level - mark entire path complete
        skipLevel = SkipLevel.complete;
        lessonsToSkip = lessons.map((l) => l.id).toList();
      } else if (score >= 80) {
        // Advanced - skip to last 20% of lessons
        skipLevel = SkipLevel.advanced;
        final skipCount = (lessons.length * 0.8).floor();
        lessonsToSkip = lessons.take(skipCount).map((l) => l.id).toList();
        if (skipCount < lessons.length) {
          startFromLessonId = lessons[skipCount].id;
        }
      } else if (score >= 50) {
        // Intermediate - skip first 40% (beginner lessons)
        skipLevel = SkipLevel.beginner;
        final skipCount = (lessons.length * 0.4).floor();
        lessonsToSkip = lessons.take(skipCount).map((l) => l.id).toList();
        if (skipCount < lessons.length) {
          startFromLessonId = lessons[skipCount].id;
        }
      } else {
        // Beginner - start from the beginning
        skipLevel = SkipLevel.none;
        lessonsToSkip = [];
        startFromLessonId = lessons.isNotEmpty ? lessons.first.id : null;
      }

      recommendations[path.id] = SkipRecommendation(
        pathId: path.id,
        score: score,
        skipLevel: skipLevel,
        lessonsToSkip: lessonsToSkip,
        startFromLessonId: startFromLessonId,
      );
    }

    return recommendations;
  }

  /// Calculate placement result from test answers
  static PlacementResult calculateResult({
    required PlacementTest test,
    required Map<String, int> userAnswers, // questionId -> selectedIndex
    required List<LearningPath> allPaths,
  }) {
    // Validate answers and calculate correctness
    final Map<String, bool> answerCorrectness = {};
    for (final question in test.questions) {
      final selectedIndex = userAnswers[question.id];
      if (selectedIndex != null) {
        answerCorrectness[question.id] = question.validateAnswer(selectedIndex);
      }
    }

    // Calculate overall score
    final overallScore = test.calculateOverallScore(answerCorrectness);

    // Calculate per-path scores
    final Map<String, double> pathScores = {};
    for (final path in allPaths) {
      pathScores[path.id] = test.calculatePathScore(path.id, answerCorrectness);
    }

    // Generate recommendations
    final recommendations = generateRecommendations(
      pathScores: pathScores,
      allPaths: allPaths,
    );

    return PlacementResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testId: test.id,
      completedAt: DateTime.now(),
      answers: answerCorrectness,
      overallScore: overallScore,
      pathScores: pathScores,
      recommendations: recommendations,
    );
  }
}
