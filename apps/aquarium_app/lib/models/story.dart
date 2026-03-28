// Story mode models for interactive narrative scenarios
// Duolingo-style stories with branching narratives and educational content

library;

import 'package:flutter/foundation.dart';
import 'user_profile.dart';
import '../utils/logger.dart';

/// Difficulty level for stories
enum StoryDifficulty { beginner, intermediate, advanced }

extension StoryDifficultyExt on StoryDifficulty {
  String get displayName {
    switch (this) {
      case StoryDifficulty.beginner:
        return 'Beginner';
      case StoryDifficulty.intermediate:
        return 'Intermediate';
      case StoryDifficulty.advanced:
        return 'Advanced';
    }
  }

  String get emoji {
    switch (this) {
      case StoryDifficulty.beginner:
        return '🌱';
      case StoryDifficulty.intermediate:
        return '🌿';
      case StoryDifficulty.advanced:
        return '🌳';
    }
  }

  ExperienceLevel get equivalentExperienceLevel {
    switch (this) {
      case StoryDifficulty.beginner:
        return ExperienceLevel.beginner;
      case StoryDifficulty.intermediate:
        return ExperienceLevel.intermediate;
      case StoryDifficulty.advanced:
        return ExperienceLevel.expert;
    }
  }
}

/// A complete interactive story
@immutable
class Story {
  final String id;
  final String title;
  final String description;
  final StoryDifficulty difficulty;
  final int estimatedMinutes;
  final int xpReward;
  final List<StoryScene> scenes;
  final String? thumbnailImage;
  final List<String> prerequisites; // Story IDs that must be completed first
  final int minLevel; // Minimum user level to unlock

  const Story({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.scenes,
    this.thumbnailImage,
    this.prerequisites = const [],
    this.minLevel = 0,
  });

  /// Check if story is unlocked for user
  bool isUnlocked(UserProfile profile, List<String> completedStories) {
    // Check level requirement
    if (profile.currentLevel < minLevel) return false;

    // Check prerequisites
    if (prerequisites.isNotEmpty) {
      return prerequisites.every((id) => completedStories.contains(id));
    }

    return true;
  }

  /// Get the starting scene (falls back to a placeholder if scenes is empty)
  StoryScene get startScene => scenes.isNotEmpty
      ? scenes.first
      : const StoryScene(
          id: 'empty',
          text: 'This story has no scenes yet.',
          choices: [],
        );

  /// Find a scene by ID
  StoryScene? getSceneById(String sceneId) {
    try {
      return scenes.firstWhere((s) => s.id == sceneId);
    } catch (e) {
      logError('Story scene lookup failed for sceneId "$sceneId": $e', tag: 'Story');
      return null;
    }
  }
}

/// A single scene in a story
@immutable
class StoryScene {
  final String id;
  final String text;
  final List<StoryChoice> choices;
  final String? imageUrl;
  final String? audioUrl;
  final bool isFinalScene;
  final String? successMessage; // Message shown on correct choice
  final String? failureMessage; // Message shown on wrong choice

  const StoryScene({
    required this.id,
    required this.text,
    required this.choices,
    this.imageUrl,
    this.audioUrl,
    this.isFinalScene = false,
    this.successMessage,
    this.failureMessage,
  });

  /// Check if this scene has any correct answers
  bool get hasCorrectAnswer => choices.any((c) => c.isCorrect);

  /// Get all correct choices
  List<StoryChoice> get correctChoices =>
      choices.where((c) => c.isCorrect).toList();
}

/// A choice option in a scene
@immutable
class StoryChoice {
  final String id;
  final String text;
  final String nextSceneId; // Empty string for ending scenes
  final bool isCorrect; // For educational stories (true if optimal choice)
  final String? feedback; // Immediate feedback after selection
  final int xpModifier; // XP adjustment for this choice (+/- from base)

  const StoryChoice({
    required this.id,
    required this.text,
    required this.nextSceneId,
    this.isCorrect = true, // Default to true for non-educational stories
    this.feedback,
    this.xpModifier = 0,
  });

  bool get endsStory => nextSceneId.isEmpty;
}

/// User's progress through a specific story
@immutable
class StoryProgress {
  final String storyId;
  final String currentSceneId;
  final List<String> visitedSceneIds;
  final List<String> choicesMade; // Choice IDs in order
  final int correctChoices;
  final int totalChoices;
  final bool completed;
  final int score; // Percentage (0-100)
  final DateTime? startedAt;
  final DateTime? completedAt;

  const StoryProgress({
    required this.storyId,
    required this.currentSceneId,
    this.visitedSceneIds = const [],
    this.choicesMade = const [],
    this.correctChoices = 0,
    this.totalChoices = 0,
    this.completed = false,
    this.score = 0,
    this.startedAt,
    this.completedAt,
  });

  /// Create a new progress for a story
  factory StoryProgress.start(String storyId, String startSceneId) {
    return StoryProgress(
      storyId: storyId,
      currentSceneId: startSceneId,
      visitedSceneIds: [startSceneId],
      startedAt: DateTime.now(),
    );
  }

  /// Make a choice and move to next scene
  StoryProgress makeChoice({
    required StoryChoice choice,
    required String nextSceneId,
    required bool isFinalScene,
  }) {
    final newCorrectChoices = correctChoices + (choice.isCorrect ? 1 : 0);
    final newTotalChoices = totalChoices + 1;
    final newScore = newTotalChoices > 0
        ? ((newCorrectChoices / newTotalChoices) * 100).round()
        : 0;

    return StoryProgress(
      storyId: storyId,
      currentSceneId: nextSceneId,
      visitedSceneIds: [
        ...visitedSceneIds,
        if (!visitedSceneIds.contains(nextSceneId)) nextSceneId,
      ],
      choicesMade: [...choicesMade, choice.id],
      correctChoices: newCorrectChoices,
      totalChoices: newTotalChoices,
      completed: isFinalScene || choice.endsStory,
      score: newScore,
      startedAt: startedAt,
      completedAt: (isFinalScene || choice.endsStory) ? DateTime.now() : null,
    );
  }

  /// Calculate final XP reward based on score
  int calculateXp(int baseXp) {
    if (!completed) return 0;

    // Base XP + bonus for high score
    double multiplier = 1.0;
    if (score >= 90) {
      multiplier = 1.5; // 50% bonus for 90%+
    } else if (score >= 70) {
      multiplier = 1.25; // 25% bonus for 70-89%
    } else if (score >= 50) {
      multiplier = 1.0; // Full XP for 50-69%
    } else {
      multiplier = 0.75; // 75% XP for below 50%
    }

    return (baseXp * multiplier).round();
  }

  Map<String, dynamic> toJson() => {
    'storyId': storyId,
    'currentSceneId': currentSceneId,
    'visitedSceneIds': visitedSceneIds,
    'choicesMade': choicesMade,
    'correctChoices': correctChoices,
    'totalChoices': totalChoices,
    'completed': completed,
    'score': score,
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory StoryProgress.fromJson(Map<String, dynamic> json) {
    return StoryProgress(
      storyId: json['storyId'] as String,
      currentSceneId: json['currentSceneId'] as String,
      visitedSceneIds:
          (json['visitedSceneIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      choicesMade:
          (json['choicesMade'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      correctChoices: json['correctChoices'] as int? ?? 0,
      totalChoices: json['totalChoices'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  StoryProgress copyWith({
    String? currentSceneId,
    List<String>? visitedSceneIds,
    List<String>? choicesMade,
    int? correctChoices,
    int? totalChoices,
    bool? completed,
    int? score,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return StoryProgress(
      storyId: storyId,
      currentSceneId: currentSceneId ?? this.currentSceneId,
      visitedSceneIds: visitedSceneIds ?? this.visitedSceneIds,
      choicesMade: choicesMade ?? this.choicesMade,
      correctChoices: correctChoices ?? this.correctChoices,
      totalChoices: totalChoices ?? this.totalChoices,
      completed: completed ?? this.completed,
      score: score ?? this.score,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
