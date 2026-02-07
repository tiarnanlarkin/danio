/// Spaced Repetition Provider
/// Manages review cards, sessions, and scheduling

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/spaced_repetition.dart';
import '../services/review_queue_service.dart';

// Provider for spaced repetition state
final spacedRepetitionProvider = StateNotifierProvider<SpacedRepetitionNotifier, SpacedRepetitionState>(
  (ref) => SpacedRepetitionNotifier(),
);

/// State for spaced repetition system
class SpacedRepetitionState {
  final List<ReviewCard> cards;
  final ReviewSession? currentSession;
  final ReviewStats stats;
  final bool isLoading;

  const SpacedRepetitionState({
    this.cards = const [],
    this.currentSession,
    required this.stats,
    this.isLoading = false,
  });

  SpacedRepetitionState copyWith({
    List<ReviewCard>? cards,
    ReviewSession? currentSession,
    ReviewStats? stats,
    bool? isLoading,
    bool clearSession = false,
  }) {
    return SpacedRepetitionState(
      cards: cards ?? this.cards,
      currentSession: clearSession ? null : (currentSession ?? this.currentSession),
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SpacedRepetitionNotifier extends StateNotifier<SpacedRepetitionState> {
  static const String _storageKey = 'spaced_repetition_cards';
  static const String _statsKey = 'spaced_repetition_stats';

  SpacedRepetitionNotifier() : super(
    SpacedRepetitionState(
      stats: ReviewStats.fromCards([]),
    )
  ) {
    _loadData();
  }

  /// Load cards from storage
  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load cards
      final cardsJson = prefs.getString(_storageKey);
      List<ReviewCard> cards = [];
      
      if (cardsJson != null) {
        final decoded = jsonDecode(cardsJson) as List;
        cards = decoded.map((c) => ReviewCard.fromJson(c)).toList();
      }

      // Load stats data
      final statsJson = prefs.getString(_statsKey);
      int reviewsToday = 0;
      int streak = 0;
      
      if (statsJson != null) {
        final statsData = jsonDecode(statsJson);
        reviewsToday = statsData['reviewsToday'] ?? 0;
        streak = statsData['streak'] ?? 0;
        
        // Reset reviews today if it's a new day
        final lastReviewDate = statsData['lastReviewDate'] as String?;
        if (lastReviewDate != null) {
          final lastDate = DateTime.parse(lastReviewDate);
          if (!_isSameDay(lastDate, DateTime.now())) {
            reviewsToday = 0;
          }
        }
      }

      // Calculate stats
      final stats = ReviewStats.fromCards(
        cards,
        reviewsToday: reviewsToday,
        streak: streak,
      );

      state = state.copyWith(
        cards: cards,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Error loading spaced repetition data: $e');
    }
  }

  /// Save cards to storage
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save cards
      final cardsJson = jsonEncode(
        state.cards.map((c) => c.toJson()).toList()
      );
      await prefs.setString(_storageKey, cardsJson);

      // Save stats
      final statsData = {
        'reviewsToday': state.stats.reviewsToday,
        'streak': state.stats.currentStreak,
        'lastReviewDate': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_statsKey, jsonEncode(statsData));
    } catch (e) {
      print('Error saving spaced repetition data: $e');
    }
  }

  /// Create a review card for a concept (lesson, quiz question, etc.)
  Future<void> createCard({
    required String conceptId,
    required ConceptType conceptType,
  }) async {
    // Check if card already exists
    if (state.cards.any((c) => c.conceptId == conceptId)) {
      return; // Card already exists
    }

    final newCard = ReviewCard.newCard(
      conceptId: conceptId,
      conceptType: conceptType,
    );

    final updatedCards = [...state.cards, newCard];
    final updatedStats = ReviewStats.fromCards(
      updatedCards,
      reviewsToday: state.stats.reviewsToday,
      streak: state.stats.currentStreak,
    );

    state = state.copyWith(
      cards: updatedCards,
      stats: updatedStats,
    );

    await _saveData();
  }

  /// Update a review card after an attempt
  Future<void> reviewCard({
    required String cardId,
    required bool correct,
  }) async {
    final cardIndex = state.cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) return;

    final oldCard = state.cards[cardIndex];
    final updatedCard = oldCard.afterReview(correct: correct);

    final updatedCards = List<ReviewCard>.from(state.cards);
    updatedCards[cardIndex] = updatedCard;

    // Update reviews today count
    final reviewsToday = state.stats.reviewsToday + 1;

    // Update streak
    final streak = _calculateStreak();

    final updatedStats = ReviewStats.fromCards(
      updatedCards,
      reviewsToday: reviewsToday,
      streak: streak,
    );

    state = state.copyWith(
      cards: updatedCards,
      stats: updatedStats,
    );

    await _saveData();
  }

  /// Start a new review session
  Future<void> startSession({
    ReviewSessionMode mode = ReviewSessionMode.standard,
  }) async {
    final session = ReviewQueueService.createSession(
      allCards: state.cards,
      mode: mode,
    );

    state = state.copyWith(currentSession: session);
  }

  /// Record result for current session card
  Future<ReviewSessionResult> recordSessionResult({
    required String cardId,
    required bool correct,
    required Duration timeSpent,
  }) async {
    if (state.currentSession == null) {
      throw Exception('No active session');
    }

    // Find the card
    final card = state.currentSession!.cards.firstWhere(
      (c) => c.id == cardId,
    );

    // Calculate XP
    final xp = ReviewQueueService.calculateXpReward(
      card: card,
      correct: correct,
      timeSpent: timeSpent,
    );

    // Create result
    final result = ReviewSessionResult(
      cardId: cardId,
      correct: correct,
      timestamp: DateTime.now(),
      xpEarned: xp,
      timeSpent: timeSpent,
    );

    // Update session
    final updatedResults = [...state.currentSession!.results, result];
    final updatedSession = ReviewSession(
      id: state.currentSession!.id,
      startTime: state.currentSession!.startTime,
      endTime: updatedResults.length == state.currentSession!.cards.length
          ? DateTime.now()
          : null,
      cards: state.currentSession!.cards,
      results: updatedResults,
      mode: state.currentSession!.mode,
    );

    state = state.copyWith(currentSession: updatedSession);

    // Update the card itself
    await reviewCard(cardId: cardId, correct: correct);

    return result;
  }

  /// Complete current session
  Future<void> completeSession() async {
    if (state.currentSession == null) return;

    // Session is complete, clear it
    state = state.copyWith(clearSession: true);
    await _saveData();
  }

  /// Get due cards count
  int getDueCount() {
    return state.cards.where((c) => c.isDue).length;
  }

  /// Get weak cards count
  int getWeakCount() {
    return state.cards.where((c) => c.isWeak).length;
  }

  /// Get cards by concept ID
  List<ReviewCard> getCardsByConceptId(String conceptId) {
    return state.cards.where((c) => c.conceptId == conceptId).toList();
  }

  /// Get forecast for next X days
  Map<int, int> getForecast({int days = 7}) {
    return ReviewQueueService.getForecast(state.cards, daysAhead: days);
  }

  /// Calculate current streak
  int _calculateStreak() {
    // TODO: Implement streak calculation based on review history
    // For now, just return current streak
    return state.stats.currentStreak;
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Delete a card (for testing/debugging)
  Future<void> deleteCard(String cardId) async {
    final updatedCards = state.cards.where((c) => c.id != cardId).toList();
    final updatedStats = ReviewStats.fromCards(
      updatedCards,
      reviewsToday: state.stats.reviewsToday,
      streak: state.stats.currentStreak,
    );

    state = state.copyWith(
      cards: updatedCards,
      stats: updatedStats,
    );

    await _saveData();
  }

  /// Reset all data (for testing)
  Future<void> resetAll() async {
    state = SpacedRepetitionState(
      stats: ReviewStats.fromCards([]),
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove(_statsKey);
  }
}
