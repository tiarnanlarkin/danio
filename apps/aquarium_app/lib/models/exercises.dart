/// Interactive exercise types for Duolingo-style learning
/// Supports multiple choice, fill-in-blank, true/false, matching, and ordering exercises
library;

import 'package:flutter/foundation.dart';

/// Base class for all exercise types
/// Each exercise knows how to validate answers and provides metadata
@immutable
abstract class Exercise {
  final String id;
  final String question;
  final String? explanation;
  final ExerciseType type;

  const Exercise({
    required this.id,
    required this.question,
    this.explanation,
    required this.type,
  });

  /// Validates the user's answer and returns true if correct
  bool validate(dynamic answer);

  /// Returns a hint to help the user (optional)
  String? getHint() => null;

  /// Difficulty level for adaptive learning
  ExerciseDifficulty get difficulty => ExerciseDifficulty.medium;

  /// Serialization support
  Map<String, dynamic> toJson();

  /// Deserialization factory
  factory Exercise.fromJson(Map<String, dynamic> json) {
    final type = ExerciseType.values.firstWhere(
      (e) => e.toString() == 'ExerciseType.${json['type']}',
    );

    switch (type) {
      case ExerciseType.multipleChoice:
        return MultipleChoiceExercise.fromJson(json);
      case ExerciseType.fillBlank:
        return FillBlankExercise.fromJson(json);
      case ExerciseType.trueFalse:
        return TrueFalseExercise.fromJson(json);
      case ExerciseType.matching:
        return MatchingExercise.fromJson(json);
      case ExerciseType.ordering:
        return OrderingExercise.fromJson(json);
    }
  }
}

enum ExerciseType { multipleChoice, fillBlank, trueFalse, matching, ordering }

enum ExerciseDifficulty { easy, medium, hard }

// ==========================================
// 1. MULTIPLE CHOICE
// ==========================================

/// Traditional multiple choice question with 2-6 options
@immutable
class MultipleChoiceExercise extends Exercise {
  final List<String> options;
  final int correctIndex;
  final String? hint;

  const MultipleChoiceExercise({
    required super.id,
    required super.question,
    super.explanation,
    required this.options,
    required this.correctIndex,
    this.hint,
  }) : super(type: ExerciseType.multipleChoice);

  @override
  bool validate(dynamic answer) {
    if (answer is! int) return false;
    return answer == correctIndex;
  }

  @override
  String? getHint() => hint;

  String get correctAnswer => options[correctIndex];

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'multipleChoice',
    'question': question,
    'explanation': explanation,
    'options': options,
    'correctIndex': correctIndex,
    'hint': hint,
  };

  factory MultipleChoiceExercise.fromJson(Map<String, dynamic> json) =>
      MultipleChoiceExercise(
        id: json['id'],
        question: json['question'],
        explanation: json['explanation'],
        options: List<String>.from(json['options']),
        correctIndex: json['correctIndex'],
        hint: json['hint'],
      );
}

// ==========================================
// 2. FILL IN THE BLANK
// ==========================================

/// Fill-in-the-blank exercise with one or more blanks
/// Example: "The _____ cycle takes _____ weeks" → ["nitrogen", "4-6"]
@immutable
class FillBlankExercise extends Exercise {
  /// The sentence with blanks marked as ___
  final String sentenceTemplate;

  /// Correct answers for each blank (in order)
  final List<String> correctAnswers;

  /// Optional word bank to choose from
  final List<String>? wordBank;

  /// Whether to accept alternative spellings/case
  final bool caseSensitive;
  final bool acceptAlternatives;

  /// Alternative acceptable answers for each blank
  final List<List<String>>? alternatives;

  const FillBlankExercise({
    required super.id,
    required super.question,
    super.explanation,
    required this.sentenceTemplate,
    required this.correctAnswers,
    this.wordBank,
    this.caseSensitive = false,
    this.acceptAlternatives = true,
    this.alternatives,
  }) : super(type: ExerciseType.fillBlank);

  @override
  bool validate(dynamic answer) {
    if (answer is! List) return false;
    if (answer.length != correctAnswers.length) return false;

    for (int i = 0; i < correctAnswers.length; i++) {
      final userAnswer = answer[i] as String;
      final correct = correctAnswers[i];

      // Check main answer
      final match = caseSensitive
          ? userAnswer == correct
          : userAnswer.toLowerCase() == correct.toLowerCase();

      if (match) continue;

      // Check alternatives if allowed
      if (acceptAlternatives &&
          alternatives != null &&
          i < alternatives!.length) {
        final alts = alternatives![i];
        final altMatch = alts.any(
          (alt) => caseSensitive
              ? userAnswer == alt
              : userAnswer.toLowerCase() == alt.toLowerCase(),
        );
        if (altMatch) continue;
      }

      return false; // No match found for this blank
    }

    return true;
  }

  int get numberOfBlanks => correctAnswers.length;

  List<String> getSentenceParts() {
    return sentenceTemplate.split('___');
  }

  @override
  ExerciseDifficulty get difficulty {
    if (wordBank != null) return ExerciseDifficulty.easy;
    if (numberOfBlanks == 1) return ExerciseDifficulty.medium;
    return ExerciseDifficulty.hard;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'fillBlank',
    'question': question,
    'explanation': explanation,
    'sentenceTemplate': sentenceTemplate,
    'correctAnswers': correctAnswers,
    'wordBank': wordBank,
    'caseSensitive': caseSensitive,
    'acceptAlternatives': acceptAlternatives,
    'alternatives': alternatives,
  };

  factory FillBlankExercise.fromJson(Map<String, dynamic> json) =>
      FillBlankExercise(
        id: json['id'],
        question: json['question'],
        explanation: json['explanation'],
        sentenceTemplate: json['sentenceTemplate'],
        correctAnswers: List<String>.from(json['correctAnswers']),
        wordBank: json['wordBank'] != null
            ? List<String>.from(json['wordBank'])
            : null,
        caseSensitive: json['caseSensitive'] ?? false,
        acceptAlternatives: json['acceptAlternatives'] ?? true,
        alternatives: json['alternatives'] != null
            ? (json['alternatives'] as List)
                  .map((a) => List<String>.from(a))
                  .toList()
            : null,
      );
}

// ==========================================
// 3. TRUE/FALSE
// ==========================================

/// Simple true/false comprehension check
@immutable
class TrueFalseExercise extends Exercise {
  final bool correctAnswer;
  final String? hint;

  const TrueFalseExercise({
    required super.id,
    required super.question,
    super.explanation,
    required this.correctAnswer,
    this.hint,
  }) : super(type: ExerciseType.trueFalse);

  @override
  bool validate(dynamic answer) {
    if (answer is! bool) return false;
    return answer == correctAnswer;
  }

  @override
  String? getHint() => hint;

  @override
  ExerciseDifficulty get difficulty => ExerciseDifficulty.easy;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'trueFalse',
    'question': question,
    'explanation': explanation,
    'correctAnswer': correctAnswer,
    'hint': hint,
  };

  factory TrueFalseExercise.fromJson(Map<String, dynamic> json) =>
      TrueFalseExercise(
        id: json['id'],
        question: json['question'],
        explanation: json['explanation'],
        correctAnswer: json['correctAnswer'],
        hint: json['hint'],
      );
}

// ==========================================
// 4. MATCHING PAIRS
// ==========================================

/// Match items from left column to right column
/// Example: Match fish species to their water type
@immutable
class MatchingExercise extends Exercise {
  /// Left column items (keys)
  final List<String> leftItems;

  /// Right column items (values)
  final List<String> rightItems;

  /// Correct pairs: Map&lt;leftIndex, rightIndex&gt;
  final Map<int, int> correctPairs;

  /// Optional images for visual matching
  final List<String>? leftImages;
  final List<String>? rightImages;

  const MatchingExercise({
    required super.id,
    required super.question,
    super.explanation,
    required this.leftItems,
    required this.rightItems,
    required this.correctPairs,
    this.leftImages,
    this.rightImages,
  }) : super(type: ExerciseType.matching);

  @override
  bool validate(dynamic answer) {
    if (answer is! Map) return false;

    // Check all pairs are correct
    if (answer.length != correctPairs.length) return false;

    for (final entry in correctPairs.entries) {
      if (answer[entry.key] != entry.value) return false;
    }

    return true;
  }

  @override
  ExerciseDifficulty get difficulty {
    if (leftItems.length <= 3) return ExerciseDifficulty.easy;
    if (leftItems.length <= 5) return ExerciseDifficulty.medium;
    return ExerciseDifficulty.hard;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'matching',
    'question': question,
    'explanation': explanation,
    'leftItems': leftItems,
    'rightItems': rightItems,
    'correctPairs': correctPairs.map((k, v) => MapEntry(k.toString(), v)),
    'leftImages': leftImages,
    'rightImages': rightImages,
  };

  factory MatchingExercise.fromJson(Map<String, dynamic> json) =>
      MatchingExercise(
        id: json['id'],
        question: json['question'],
        explanation: json['explanation'],
        leftItems: List<String>.from(json['leftItems']),
        rightItems: List<String>.from(json['rightItems']),
        correctPairs: (json['correctPairs'] as Map).map(
          (k, v) => MapEntry(int.tryParse(k.toString()) ?? 0, v as int),
        ),
        leftImages: json['leftImages'] != null
            ? List<String>.from(json['leftImages'])
            : null,
        rightImages: json['rightImages'] != null
            ? List<String>.from(json['rightImages'])
            : null,
      );
}

// ==========================================
// 5. ORDERING/SEQUENCING
// ==========================================

/// Put items in the correct order
/// Example: Order the steps of the nitrogen cycle
@immutable
class OrderingExercise extends Exercise {
  /// Items to be ordered (shown shuffled)
  final List<String> items;

  /// Correct order (indices of items in correct sequence)
  /// If null, assumes items are already in correct order
  final List<int>? correctOrder;

  /// Optional: allow partial credit for partially correct sequences
  final bool allowPartialCredit;

  const OrderingExercise({
    required super.id,
    required super.question,
    super.explanation,
    required this.items,
    this.correctOrder,
    this.allowPartialCredit = false,
  }) : super(type: ExerciseType.ordering);

  List<int> get _correctSequence =>
      correctOrder ?? List.generate(items.length, (i) => i);

  @override
  bool validate(dynamic answer) {
    if (answer is! List) return false;
    if (answer.length != items.length) return false;

    // Exact match required (unless partial credit enabled elsewhere)
    for (int i = 0; i < answer.length; i++) {
      if (answer[i] != _correctSequence[i]) return false;
    }

    return true;
  }

  /// Calculate how many items are in the correct position (for partial credit)
  int calculateScore(List<int> userOrder) {
    int score = 0;
    for (int i = 0; i < userOrder.length && i < _correctSequence.length; i++) {
      if (userOrder[i] == _correctSequence[i]) score++;
    }
    return score;
  }

  /// Calculate percentage correct
  double calculatePercentage(List<int> userOrder) {
    return (calculateScore(userOrder) / items.length) * 100;
  }

  @override
  ExerciseDifficulty get difficulty {
    if (items.length <= 3) return ExerciseDifficulty.easy;
    if (items.length <= 5) return ExerciseDifficulty.medium;
    return ExerciseDifficulty.hard;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'ordering',
    'question': question,
    'explanation': explanation,
    'items': items,
    'correctOrder': correctOrder,
    'allowPartialCredit': allowPartialCredit,
  };

  factory OrderingExercise.fromJson(Map<String, dynamic> json) =>
      OrderingExercise(
        id: json['id'],
        question: json['question'],
        explanation: json['explanation'],
        items: List<String>.from(json['items']),
        correctOrder: json['correctOrder'] != null
            ? List<int>.from(json['correctOrder'])
            : null,
        allowPartialCredit: json['allowPartialCredit'] ?? false,
      );
}

// ==========================================
// ENHANCED QUIZ MODEL
// ==========================================

/// Enhanced quiz that supports mixed exercise types
@immutable
class EnhancedQuiz {
  final String id;
  final String lessonId;
  final List<Exercise> exercises;
  final int passingScore; // Percentage needed to pass
  final int bonusXp;
  final bool shuffleExercises;
  final QuizMode mode;

  const EnhancedQuiz({
    required this.id,
    required this.lessonId,
    required this.exercises,
    this.passingScore = 70,
    this.bonusXp = 25,
    this.shuffleExercises = false,
    this.mode = QuizMode.standard,
  });

  int get maxScore => exercises.length;

  /// Get exercises grouped by difficulty
  Map<ExerciseDifficulty, List<Exercise>> get exercisesByDifficulty {
    return {
      ExerciseDifficulty.easy: exercises
          .where((e) => e.difficulty == ExerciseDifficulty.easy)
          .toList(),
      ExerciseDifficulty.medium: exercises
          .where((e) => e.difficulty == ExerciseDifficulty.medium)
          .toList(),
      ExerciseDifficulty.hard: exercises
          .where((e) => e.difficulty == ExerciseDifficulty.hard)
          .toList(),
    };
  }

  /// Get exercises grouped by type
  Map<ExerciseType, List<Exercise>> get exercisesByType {
    return {
      for (final type in ExerciseType.values)
        type: exercises.where((e) => e.type == type).toList(),
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lessonId': lessonId,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'passingScore': passingScore,
    'bonusXp': bonusXp,
    'shuffleExercises': shuffleExercises,
    'mode': mode.toString().split('.').last,
  };

  factory EnhancedQuiz.fromJson(Map<String, dynamic> json) => EnhancedQuiz(
    id: json['id'],
    lessonId: json['lessonId'],
    exercises: (json['exercises'] as List)
        .map((e) => Exercise.fromJson(e))
        .toList(),
    passingScore: json['passingScore'] ?? 70,
    bonusXp: json['bonusXp'] ?? 25,
    shuffleExercises: json['shuffleExercises'] ?? false,
    mode: QuizMode.values.firstWhere(
      (m) => m.toString() == 'QuizMode.${json['mode']}',
      orElse: () => QuizMode.standard,
    ),
  );
}

enum QuizMode {
  /// Standard mode: all questions, show results at end
  standard,

  /// Practice mode: unlimited attempts, show hints
  practice,

  /// Adaptive mode: difficulty adjusts based on performance
  adaptive,

  /// Timed mode: race against the clock
  timed,
}
