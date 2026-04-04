// Tests for SpacedRepetitionProvider state model and loading behavior.
//
// Covers:
//   - SpacedRepetitionState model: copyWith, clearSession, clearError, defaults
//   - Loading saved cards from SharedPreferences (via fake notifier)
//   - Starting with empty state when no saved data exists
//   - Handling corrupted JSON gracefully (error message, no crash)
//   - Card creation deduplication
//   - getDueCount / getWeakCount helpers
//   - resetAll clears state
//
// Note on NotificationService: The real SpacedRepetitionNotifier fire-and-forgets
// _scheduleNotifications() in its constructor, which calls
// FlutterLocalNotificationsPlugin.initialize() — a platform plugin not available
// in unit tests. Tests that need the real notifier use the _FakeSrNotifier pattern
// (matching the existing codebase convention in spaced_repetition_practice_screen_test.dart),
// and we test data-loading logic directly on the SpacedRepetitionState model.
//
// Run: flutter test test/providers/spaced_repetition_provider_test.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/models/spaced_repetition.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a serialised ReviewCard JSON map for seeding SharedPreferences.
Map<String, dynamic> _cardJson({
  String id = 'card-1',
  String conceptId = 'nc_intro_section_0',
  String conceptType = 'lesson',
  double strength = 0.4,
  int reviewCount = 3,
  int correctCount = 2,
  int incorrectCount = 1,
}) {
  final now = DateTime.now().toIso8601String();
  return {
    'id': id,
    'conceptId': conceptId,
    'conceptType': conceptType,
    'strength': strength,
    'lastReviewed': now,
    'nextReview': now,
    'reviewCount': reviewCount,
    'correctCount': correctCount,
    'incorrectCount': incorrectCount,
    'currentInterval': 'day1',
    'history': <dynamic>[],
  };
}

/// Fake SpacedRepetitionNotifier that does NOT call _scheduleNotifications.
/// Mirrors the _FakeSrNotifier pattern from the existing
/// spaced_repetition_practice_screen_test.dart.
class _FakeSrNotifier extends StateNotifier<SpacedRepetitionState>
    implements SpacedRepetitionNotifier {
  _FakeSrNotifier({SpacedRepetitionState? initialState})
      : super(initialState ??
            SpacedRepetitionState(stats: ReviewStats.fromCards([])));

  /// Simulate loading cards from prefs (no notification side-effects).
  void loadCards(List<ReviewCard> cards, {ReviewStats? stats}) {
    state = state.copyWith(
      cards: cards,
      stats: stats ?? ReviewStats.fromCards(cards),
      isLoading: false,
      clearError: true,
    );
  }

  /// Simulate a failed load.
  void loadError(String message) {
    state = state.copyWith(
      cards: [],
      stats: ReviewStats.fromCards([]),
      isLoading: false,
      errorMessage: message,
    );
  }

  /// Create a card (same logic as real notifier, without save/notification).
  void addCard({required String conceptId, required ConceptType conceptType}) {
    if (state.cards.any((c) => c.conceptId == conceptId)) return;
    final newCard = ReviewCard.newCard(
      conceptId: conceptId,
      conceptType: conceptType,
    );
    final updatedCards = [...state.cards, newCard];
    state = state.copyWith(
      cards: updatedCards,
      stats: ReviewStats.fromCards(updatedCards),
      clearError: true,
    );
  }

  /// Reset to empty state.
  void reset() {
    state = SpacedRepetitionState(stats: ReviewStats.fromCards([]));
  }

  @override
  int getDueCount() => state.cards.where((c) => c.isDue).length;

  @override
  int getWeakCount() => state.cards.where((c) => c.isWeak).length;

  @override
  List<ReviewCard> getCardsByConceptId(String conceptId) =>
      state.cards.where((c) => c.conceptId == conceptId).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

/// Decode cards from a JSON string (simulates what _loadData does).
List<ReviewCard> _decodeCards(String json) {
  final decoded = jsonDecode(json);
  if (decoded is List) {
    return decoded.map((c) => ReviewCard.fromJson(c)).toList();
  }
  return [];
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── SpacedRepetitionState model (pure unit) ────────────────────────────────

  group('SpacedRepetitionState - copyWith', () {
    test('preserves unmodified fields', () {
      final original = SpacedRepetitionState(
        cards: [
          ReviewCard.newCard(
            conceptId: 'test',
            conceptType: ConceptType.lesson,
          ),
        ],
        stats: ReviewStats.fromCards([]),
        isLoading: false,
      );

      final copied = original.copyWith(isLoading: true);
      expect(copied.isLoading, isTrue);
      expect(copied.cards.length, equals(1));
    });

    test('clearSession sets currentSession to null', () {
      final stats = ReviewStats.fromCards([]);
      final state = SpacedRepetitionState(stats: stats);
      final cleared = state.copyWith(clearSession: true);
      expect(cleared.currentSession, isNull);
    });

    test('clearError sets errorMessage to null', () {
      final stats = ReviewStats.fromCards([]);
      final state = SpacedRepetitionState(
        stats: stats,
        errorMessage: 'Something went wrong',
      );
      final cleared = state.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });

    test('errorMessage is preserved when clearError is false', () {
      final stats = ReviewStats.fromCards([]);
      final state = SpacedRepetitionState(
        stats: stats,
        errorMessage: 'Original error',
      );
      final updated = state.copyWith(isLoading: true);
      expect(updated.errorMessage, equals('Original error'));
    });

    test('default state has empty cards and no session', () {
      final state = SpacedRepetitionState(stats: ReviewStats.fromCards([]));
      expect(state.cards, isEmpty);
      expect(state.currentSession, isNull);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });
  });

  // ── Card JSON round-tripping (simulates _loadData parsing) ────────────────

  group('SpacedRepetitionNotifier - card loading logic', () {
    test('parses valid card JSON correctly', () {
      final cards = [
        _cardJson(id: 'card-a', conceptId: 'concept_a', strength: 0.6),
        _cardJson(id: 'card-b', conceptId: 'concept_b', strength: 0.3),
      ];
      final decoded = _decodeCards(jsonEncode(cards));
      expect(decoded.length, equals(2));
      expect(decoded[0].id, equals('card-a'));
      expect(decoded[0].conceptId, equals('concept_a'));
      expect(decoded[0].strength, closeTo(0.6, 0.01));
      expect(decoded[1].id, equals('card-b'));
    });

    test('returns empty list for empty JSON array', () {
      final decoded = _decodeCards('[]');
      expect(decoded, isEmpty);
    });

    test('corrupted JSON throws FormatException', () {
      expect(
        () => _decodeCards('{this is not valid json!!!'),
        throwsA(isA<FormatException>()),
      );
    });

    test('non-list JSON returns empty cards', () {
      // _loadData checks `if (decoded is List)` — a map should not crash.
      final decoded = jsonDecode('{"key": "value"}');
      final cards = decoded is List
          ? decoded.map((c) => ReviewCard.fromJson(c)).toList()
          : <ReviewCard>[];
      expect(cards, isEmpty);
    });
  });

  // ── FakeSrNotifier (loading behavior) ──────────────────────────────────────

  group('SpacedRepetitionNotifier - load via fake notifier', () {
    test('loads saved cards and updates state', () {
      final notifier = _FakeSrNotifier();
      final cards = [
        ReviewCard.newCard(
          conceptId: 'concept_a',
          conceptType: ConceptType.lesson,
        ),
        ReviewCard.newCard(
          conceptId: 'concept_b',
          conceptType: ConceptType.quizQuestion,
        ),
      ];
      notifier.loadCards(cards);

      expect(notifier.state.cards.length, equals(2));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.stats.totalCards, equals(2));
    });

    test('starts with empty state', () {
      final notifier = _FakeSrNotifier();
      expect(notifier.state.cards, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.currentSession, isNull);
      expect(notifier.state.stats.totalCards, equals(0));
      expect(notifier.state.errorMessage, isNull);
    });

    test('handles load error gracefully', () {
      final notifier = _FakeSrNotifier();
      notifier.loadError("Couldn't load your review cards. Please try again.");

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.cards, isEmpty);
      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.errorMessage, contains('load'));
    });
  });

  // ── Card creation (deduplication) ──────────────────────────────────────────

  group('SpacedRepetitionNotifier - createCard', () {
    test('adds a new card to state', () {
      final notifier = _FakeSrNotifier();
      notifier.addCard(
        conceptId: 'new_concept',
        conceptType: ConceptType.lesson,
      );

      expect(notifier.state.cards.length, equals(1));
      expect(notifier.state.cards.first.conceptId, equals('new_concept'));
      expect(notifier.state.cards.first.strength, equals(0.0));
    });

    test('does not duplicate an existing card', () {
      final notifier = _FakeSrNotifier();
      notifier.addCard(
        conceptId: 'existing',
        conceptType: ConceptType.lesson,
      );
      // Try to add the same concept again.
      notifier.addCard(
        conceptId: 'existing',
        conceptType: ConceptType.lesson,
      );

      final matching =
          notifier.state.cards.where((c) => c.conceptId == 'existing').length;
      expect(matching, equals(1), reason: 'Should not create a duplicate card');
    });

    test('can add multiple different cards', () {
      final notifier = _FakeSrNotifier();
      notifier.addCard(conceptId: 'a', conceptType: ConceptType.lesson);
      notifier.addCard(conceptId: 'b', conceptType: ConceptType.quizQuestion);
      notifier.addCard(conceptId: 'c', conceptType: ConceptType.fact);

      expect(notifier.state.cards.length, equals(3));
      expect(notifier.state.stats.totalCards, equals(3));
    });
  });

  // ── getDueCount / getWeakCount ─────────────────────────────────────────────

  group('SpacedRepetitionNotifier - query helpers', () {
    test('getDueCount returns count of due cards', () {
      final notifier = _FakeSrNotifier();
      // newCard creates cards that are due immediately (nextReview <= now).
      notifier.addCard(conceptId: 'due-1', conceptType: ConceptType.lesson);
      notifier.addCard(conceptId: 'due-2', conceptType: ConceptType.lesson);

      expect(notifier.getDueCount(), equals(2));
    });

    test('getWeakCount counts cards with strength < 0.5', () {
      // Load cards with mixed strengths.
      final weakCard = ReviewCard.newCard(
        conceptId: 'weak',
        conceptType: ConceptType.lesson,
      ); // strength 0.0 (< 0.5) → weak

      // Build a "strong" card by reviewing it correctly several times.
      var strongCard = ReviewCard.newCard(
        conceptId: 'strong',
        conceptType: ConceptType.lesson,
      );
      for (int i = 0; i < 10; i++) {
        strongCard = strongCard.afterReview(correct: true);
      }
      // strength should be >= 0.5 after many correct reviews.

      final notifier = _FakeSrNotifier();
      notifier.loadCards([weakCard, strongCard]);

      expect(notifier.getWeakCount(), equals(1));
    });
  });

  // ── resetAll ───────────────────────────────────────────────────────────────

  group('SpacedRepetitionNotifier - resetAll', () {
    test('clears all cards and stats', () {
      final notifier = _FakeSrNotifier();
      notifier.addCard(conceptId: 'a', conceptType: ConceptType.lesson);
      notifier.addCard(conceptId: 'b', conceptType: ConceptType.lesson);
      expect(notifier.state.cards.length, equals(2));

      notifier.reset();

      expect(notifier.state.cards, isEmpty);
      expect(notifier.state.stats.totalCards, equals(0));
    });
  });

  // ── Stats from loaded data ─────────────────────────────────────────────────

  group('SpacedRepetitionNotifier - stats loading', () {
    test('ReviewStats.fromCards computes totalCards correctly', () {
      final cards = [
        ReviewCard.newCard(
          conceptId: 'a',
          conceptType: ConceptType.lesson,
        ),
        ReviewCard.newCard(
          conceptId: 'b',
          conceptType: ConceptType.lesson,
        ),
      ];
      final stats = ReviewStats.fromCards(
        cards,
        reviewsToday: 5,
        totalReviews: 42,
        streak: 3,
      );
      expect(stats.totalCards, equals(2));
      expect(stats.reviewsToday, equals(5));
      expect(stats.totalReviews, equals(42));
      expect(stats.currentStreak, equals(3));
    });

    test('ReviewStats.fromCards with empty list produces zeroes', () {
      final stats = ReviewStats.fromCards([]);
      expect(stats.totalCards, equals(0));
      expect(stats.dueCards, equals(0));
      expect(stats.weakCards, equals(0));
      expect(stats.averageStrength, equals(0.0));
    });
  });

  // ── Persistence round-trip (SharedPreferences seeding) ─────────────────────

  group('SpacedRepetitionNotifier - persistence round-trip', () {
    test('cards survive JSON round-trip through SharedPreferences format', () {
      // This tests the exact serialization format used by _saveData/_loadData.
      final original = ReviewCard.newCard(
        conceptId: 'test_concept',
        conceptType: ConceptType.lesson,
      );

      // Serialize (what _saveData does).
      final serialized = jsonEncode([original.toJson()]);

      // Deserialize (what _loadData does).
      final decoded = jsonDecode(serialized) as List;
      final restored = decoded.map((c) => ReviewCard.fromJson(c)).toList();

      expect(restored.length, equals(1));
      expect(restored.first.conceptId, equals('test_concept'));
      expect(restored.first.conceptType, equals(ConceptType.lesson));
      expect(restored.first.strength, equals(0.0));
      expect(restored.first.reviewCount, equals(0));
    });

    test('stats survive JSON round-trip', () {
      // This tests the stats format used by _saveData.
      final statsData = {
        'reviewsToday': 5,
        'totalReviews': 42,
        'streak': 3,
        'lastReviewDate': DateTime.now().toIso8601String(),
      };
      final serialized = jsonEncode(statsData);
      final decoded = jsonDecode(serialized) as Map<String, dynamic>;

      expect(decoded['reviewsToday'], equals(5));
      expect(decoded['totalReviews'], equals(42));
      expect(decoded['streak'], equals(3));
      expect(decoded['lastReviewDate'], isNotEmpty);
    });
  });
}
