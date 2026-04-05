/// Resolves [ReviewCard]s into fully-formed [ResolvedQuestion]s for practice
/// sessions. Each card is mapped to a question type based on available lesson
/// data, following a priority cascade: matching pairs -> quiz -> key-point MC
/// -> self-assess fallback.
library;

import 'dart:math';

import 'package:danio/models/learning.dart';
import 'package:danio/models/resolved_question.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/providers/lesson_provider.dart';
import 'package:danio/utils/concept_display_names.dart';

class QuestionResolver {
  /// Resolve a list of review cards into ready-to-render questions.
  ///
  /// Resolution priority per card (by index in [cards]):
  /// 1. Every 5th card (index % 5 == 4): matching-pairs if 3+ siblings exist.
  /// 2. If the card's lesson has a [Quiz], pick one [QuizQuestion] -> MC.
  /// 3. If the lesson has keyPoint sections, auto-generate MC with distractors.
  /// 4. Fallback: self-assess MC with generic confidence options.
  static List<ResolvedQuestion> resolveQuestions({
    required List<ReviewCard> cards,
    required LessonState lessonState,
    Random? random,
  }) {
    final rng = random ?? Random();
    final results = <ResolvedQuestion>[];

    for (var i = 0; i < cards.length; i++) {
      final card = cards[i];
      final lesson = _findLesson(card.conceptId, lessonState);

      // Priority 1: every 5th card -> matching pairs
      if (i % 5 == 4 && lesson != null) {
        final path = lessonState.getPath(lesson.pathId);
        if (path != null) {
          final matchingQuestion = _tryMatchingPairs(
            card,
            path,
            lessonState,
            rng,
          );
          if (matchingQuestion != null) {
            results.add(matchingQuestion);
            continue;
          }
        }
      }

      // Priority 2: quiz match
      if (lesson != null && lesson.quiz != null) {
        final quizQuestion = _fromQuiz(card, lesson.quiz!, rng);
        if (quizQuestion != null) {
          results.add(quizQuestion);
          continue;
        }
      }

      // Priority 3: key point MC
      if (lesson != null) {
        final keyPointMc = _fromKeyPoints(card, lesson, lessonState, rng);
        if (keyPointMc != null) {
          results.add(keyPointMc);
          continue;
        }
      }

      // Priority 4: graceful fallback
      results.add(_fallback(card));
    }

    return results;
  }

  /// Locate a lesson for the given [conceptId].
  ///
  /// First tries a direct lookup. If that fails, extracts a candidate path ID
  /// from the first segment of the concept ID (e.g. "nc" from "nc_intro_section_2")
  /// and scans that path's lessons for a prefix match.
  static Lesson? _findLesson(String conceptId, LessonState lessonState) {
    // Direct lookup — works when conceptId IS a lesson ID.
    final direct = lessonState.getLesson(conceptId);
    if (direct != null) return direct;

    // Try extracting a lesson ID from structured concept IDs like
    // "nc_intro_section_2" or "nc_intro_quiz_q1".
    // Strategy: walk the concept ID segments, building progressively longer
    // candidate IDs and checking each one.
    final parts = conceptId.split('_');
    for (var len = parts.length - 1; len >= 1; len--) {
      final candidate = parts.sublist(0, len).join('_');
      final found = lessonState.getLesson(candidate);
      if (found != null) return found;
    }

    // Last resort: check if the first segment is a known path ID, and if so
    // try matching the concept against its lesson IDs by prefix.
    if (parts.isNotEmpty) {
      final path = lessonState.getPath(parts.first);
      if (path != null && path.lessons.isNotEmpty) {
        // Return the first lesson whose id is a prefix of the conceptId.
        for (final lesson in path.lessons) {
          if (conceptId.startsWith(lesson.id)) return lesson;
        }
        // If nothing matched by prefix, just return the first lesson in the
        // path so we have *some* context for question generation.
      }
    }

    return null;
  }

  /// Attempt to build a [MatchingPairsQuestion] from sibling lessons in the
  /// same learning path. Returns null if fewer than 3 siblings with key points
  /// are available.
  static MatchingPairsQuestion? _tryMatchingPairs(
    ReviewCard card,
    LearningPath path,
    LessonState lessonState,
    Random rng,
  ) {
    // Collect sibling concepts that have at least one key point.
    final siblings = <_SiblingInfo>[];
    for (final lesson in path.lessons) {
      final keyPoints = lesson.sections
          .where((s) => s.type == LessonSectionType.keyPoint)
          .toList();
      if (keyPoints.isNotEmpty) {
        siblings.add(_SiblingInfo(
          conceptId: lesson.id,
          displayName: conceptDisplayName(lesson.id),
          firstKeyPoint: keyPoints.first.content,
        ));
      }
    }

    if (siblings.length < 3) return null;

    // Shuffle and pick up to 4 pairs (or all if fewer).
    final shuffled = List<_SiblingInfo>.from(siblings)..shuffle(rng);
    final selected = shuffled.take(4).toList();

    final pairs = selected
        .map((s) => MatchPair(left: s.displayName, right: s.firstKeyPoint))
        .toList();

    // Build placeholder ReviewCards for the grouped concepts.
    final groupCards = selected.map((s) {
      return ReviewCard(
        id: s.conceptId,
        conceptId: s.conceptId,
        conceptType: ConceptType.lesson,
        lastReviewed: card.lastReviewed,
        nextReview: card.nextReview,
      );
    }).toList();

    return MatchingPairsQuestion(
      card: card,
      cards: groupCards,
      pairs: pairs,
    );
  }

  /// Pick a random [QuizQuestion] from the lesson's quiz and wrap it as a
  /// [MultipleChoiceQuestion].
  static MultipleChoiceQuestion? _fromQuiz(
    ReviewCard card,
    Quiz quiz,
    Random rng,
  ) {
    if (quiz.questions.isEmpty) return null;
    final q = quiz.questions[rng.nextInt(quiz.questions.length)];
    return MultipleChoiceQuestion(
      card: card,
      questionText: q.question,
      options: q.options,
      correctIndex: q.correctIndex,
      explanation: q.explanation,
    );
  }

  /// Build a MC question from a lesson's key points. The correct answer is one
  /// of the current lesson's key points; distractors come from OTHER lessons in
  /// the same learning path.
  static MultipleChoiceQuestion? _fromKeyPoints(
    ReviewCard card,
    Lesson lesson,
    LessonState lessonState,
    Random rng,
  ) {
    final keyPoints = lesson.sections
        .where((s) => s.type == LessonSectionType.keyPoint)
        .toList();
    if (keyPoints.isEmpty) return null;

    // Pick a random key point as the correct answer.
    final correctKp = keyPoints[rng.nextInt(keyPoints.length)];
    final correctText = correctKp.content;

    // Gather distractors from sibling lessons in the same path.
    final distractors = <String>[];
    final path = lessonState.getPath(lesson.pathId);
    if (path != null) {
      for (final sibling in path.lessons) {
        if (sibling.id == lesson.id) continue;
        for (final section in sibling.sections) {
          if (section.type == LessonSectionType.keyPoint) {
            distractors.add(section.content);
          }
        }
      }
    }

    // If we don't have enough external distractors, pull from the same lesson's
    // other key points.
    if (distractors.length < 3) {
      for (final kp in keyPoints) {
        if (kp.content != correctText && !distractors.contains(kp.content)) {
          distractors.add(kp.content);
        }
      }
    }

    // Shuffle distractors and take up to 3.
    distractors.shuffle(rng);
    final selectedDistractors = distractors.take(3).toList();

    // Build options: correct + distractors, then shuffle.
    final options = [correctText, ...selectedDistractors];
    // Track correct answer before shuffle.
    final correctAnswer = correctText;
    options.shuffle(rng);
    final correctIndex = options.indexOf(correctAnswer);

    return MultipleChoiceQuestion(
      card: card,
      questionText: conceptDisplayName(card.conceptId),
      options: options,
      correctIndex: correctIndex,
    );
  }

  /// Self-assess fallback when no lesson data is available.
  static MultipleChoiceQuestion _fallback(ReviewCard card) {
    return MultipleChoiceQuestion(
      card: card,
      questionText: conceptDisplayName(card.conceptId),
      options: [
        'I remember this well',
        'I think I know this',
        "I'm not sure about this",
        "I've forgotten this",
      ],
      correctIndex: 0,
    );
  }
}

/// Internal helper to hold sibling concept info for matching-pairs generation.
class _SiblingInfo {
  final String conceptId;
  final String displayName;
  final String firstKeyPoint;

  const _SiblingInfo({
    required this.conceptId,
    required this.displayName,
    required this.firstKeyPoint,
  });
}
