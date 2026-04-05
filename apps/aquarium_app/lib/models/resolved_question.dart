/// Models for resolved practice-session questions.
///
/// A [ResolvedQuestion] is the output of the QuestionResolver service:
/// a fully-formed question ready for the UI to render.
library;

import 'package:flutter/foundation.dart';

import 'package:danio/models/spaced_repetition.dart';

// ==========================================
// RESOLVED QUESTION — sealed hierarchy
// ==========================================

/// Base type for a question that has been resolved from a [ReviewCard].
///
/// Every resolved question carries the [card] it was derived from so the
/// practice session can update spaced-repetition state after the user answers.
@immutable
sealed class ResolvedQuestion {
  final ReviewCard card;

  const ResolvedQuestion({required this.card});
}

/// A four-option multiple-choice question.
@immutable
class MultipleChoiceQuestion extends ResolvedQuestion {
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const MultipleChoiceQuestion({
    required super.card,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}

/// A matching-pairs question where the user connects left items to right items.
@immutable
class MatchingPairsQuestion extends ResolvedQuestion {
  final List<ReviewCard> cards;
  final List<MatchPair> pairs;

  const MatchingPairsQuestion({
    required super.card,
    required this.cards,
    required this.pairs,
  });
}

// ==========================================
// MATCH PAIR — a single left/right association
// ==========================================

/// One pair in a matching-pairs question (e.g. term <-> definition).
@immutable
class MatchPair {
  final String left;
  final String right;

  const MatchPair({required this.left, required this.right});
}
