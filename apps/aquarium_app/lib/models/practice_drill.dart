/// Practice drill models.
///
/// Skill drills group existing review cards into real aquarium-care workflows
/// without changing the spaced repetition card model.
library;

import 'package:flutter/foundation.dart';

enum PracticeDrillId {
  parameterInterpretation,
  diagnosis,
  compatibility,
  setupPlanning,
  emergencyDecision,
}

@immutable
class PracticeDrill {
  final PracticeDrillId id;
  final String title;
  final String subtitle;
  final List<String> pathIds;
  final int sessionLimit;

  const PracticeDrill({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pathIds,
    this.sessionLimit = 10,
  });
}

@immutable
class PracticeDrillSummary {
  final PracticeDrill drill;
  final int availableCardCount;
  final int dueCardCount;
  final int weakCardCount;
  final String statusLabel;
  final List<String> supportingPathTitles;

  const PracticeDrillSummary({
    required this.drill,
    required this.availableCardCount,
    required this.dueCardCount,
    required this.weakCardCount,
    required this.statusLabel,
    this.supportingPathTitles = const [],
  });

  bool get isUnlocked => availableCardCount > 0;
}
