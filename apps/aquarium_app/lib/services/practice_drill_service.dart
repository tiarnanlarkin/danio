/// Builds and filters workflow-based Practice drills from review cards.
library;

import '../models/practice_drill.dart';
import '../models/spaced_repetition.dart';
import '../providers/lesson_provider.dart';
import 'review_queue_service.dart';

class PracticeDrillService {
  static const List<PracticeDrill> catalog = [
    PracticeDrill(
      id: PracticeDrillId.parameterInterpretation,
      title: 'Parameter Reading',
      subtitle: 'Read test results and choose the safest next care action.',
      pathIds: ['water_parameters', 'nitrogen_cycle', 'maintenance'],
    ),
    PracticeDrill(
      id: PracticeDrillId.diagnosis,
      title: 'Diagnosis Practice',
      subtitle:
          'Connect symptoms, behaviour, and water clues to likely causes.',
      pathIds: ['fish_health', 'troubleshooting', 'water_parameters'],
    ),
    PracticeDrill(
      id: PracticeDrillId.compatibility,
      title: 'Compatibility Checks',
      subtitle:
          'Practise stocking, temperament, size, and tank-mate decisions.',
      pathIds: ['species_care', 'first_fish'],
    ),
    PracticeDrill(
      id: PracticeDrillId.setupPlanning,
      title: 'Setup Planning',
      subtitle: 'Plan equipment, plants, layout, and maintenance tradeoffs.',
      pathIds: ['equipment', 'planted', 'aquascaping', 'advanced_topics'],
    ),
    PracticeDrill(
      id: PracticeDrillId.emergencyDecision,
      title: 'Emergency Decisions',
      subtitle:
          'Prioritise immediate actions when fish or water conditions look unsafe.',
      pathIds: ['troubleshooting', 'fish_health', 'water_parameters'],
    ),
  ];

  static final Map<String, String> _pathTitleById = {
    for (final path in LessonProvider.allPathMetadata) path.id: path.title,
  };

  static final List<MapEntry<String, String>> _lessonToPathEntries =
      LessonProvider.allPathMetadata
          .expand(
            (path) =>
                path.lessonIds.map((lessonId) => MapEntry(lessonId, path.id)),
          )
          .toList()
        ..sort((a, b) => b.key.length.compareTo(a.key.length));

  static List<PracticeDrillSummary> buildSummaries({
    required List<ReviewCard> cards,
  }) {
    return [
      for (final drill in catalog) _buildSummary(drill: drill, cards: cards),
    ];
  }

  static List<ReviewCard> cardsForDrill({
    required List<ReviewCard> cards,
    required PracticeDrillId drillId,
    int? limit,
  }) {
    final drill = _drillById(drillId);
    final pathIds = drill.pathIds.toSet();
    final filtered = cards.where((card) {
      final pathId = resolvePathId(card.conceptId);
      return pathId != null && pathIds.contains(pathId);
    }).toList();

    filtered.sort(_compareCardsForDrill);
    final effectiveLimit = limit ?? drill.sessionLimit;
    return filtered.take(effectiveLimit).toList(growable: false);
  }

  static ReviewSession createSession({
    required List<ReviewCard> cards,
    required PracticeDrillId drillId,
  }) {
    final sessionCards = cardsForDrill(cards: cards, drillId: drillId);
    final now = DateTime.now();
    return ReviewSession(
      id: 'drill_${drillId.name}_${now.millisecondsSinceEpoch}',
      startTime: now,
      cards: sessionCards,
      mode: ReviewSessionMode.mixed,
    );
  }

  static String? resolvePathId(String conceptId) {
    for (final entry in _lessonToPathEntries) {
      final lessonId = entry.key;
      if (conceptId == lessonId || conceptId.startsWith('${lessonId}_')) {
        return entry.value;
      }
    }

    for (final path in LessonProvider.allPathMetadata) {
      if (conceptId == path.id || conceptId.startsWith('${path.id}_')) {
        return path.id;
      }
    }

    return null;
  }

  static PracticeDrill _drillById(PracticeDrillId drillId) {
    return catalog.firstWhere((drill) => drill.id == drillId);
  }

  static PracticeDrillSummary _buildSummary({
    required PracticeDrill drill,
    required List<ReviewCard> cards,
  }) {
    final drillCards = cardsForDrill(
      cards: cards,
      drillId: drill.id,
      limit: cards.length,
    );
    final dueCount = drillCards.where((card) => card.isDue).length;
    final weakCount = drillCards.where((card) => card.isWeak).length;

    return PracticeDrillSummary(
      drill: drill,
      availableCardCount: drillCards.length,
      dueCardCount: dueCount,
      weakCardCount: weakCount,
      statusLabel: _statusLabel(
        drill: drill,
        availableCardCount: drillCards.length,
        dueCardCount: dueCount,
      ),
      supportingPathTitles: [
        for (final pathId in drill.pathIds)
          if (_pathTitleById[pathId] != null) _pathTitleById[pathId]!,
      ],
    );
  }

  static String _statusLabel({
    required PracticeDrill drill,
    required int availableCardCount,
    required int dueCardCount,
  }) {
    if (availableCardCount == 0) {
      final firstPathTitle = _pathTitleById[drill.pathIds.first] ?? 'Learn';
      return 'Unlock through $firstPathTitle';
    }
    if (dueCardCount > 0) {
      return '$dueCardCount due now';
    }
    return '$availableCardCount card${availableCardCount == 1 ? '' : 's'} ready';
  }

  static int _compareCardsForDrill(ReviewCard a, ReviewCard b) {
    if (a.isDue != b.isDue) return a.isDue ? -1 : 1;

    final priority = ReviewQueueService.calculatePriority(
      b,
    ).compareTo(ReviewQueueService.calculatePriority(a));
    if (priority != 0) return priority;

    final strength = a.strength.compareTo(b.strength);
    if (strength != 0) return strength;

    return a.conceptId.compareTo(b.conceptId);
  }
}
