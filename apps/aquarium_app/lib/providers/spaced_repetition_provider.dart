/// Spaced Repetition Provider
/// Manages review cards, sessions, and scheduling
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/spaced_repetition.dart';
import '../models/achievements.dart';
import '../services/review_queue_service.dart';
import '../services/notification_service.dart';
import 'achievement_provider.dart';
import 'package:flutter/material.dart';

// Provider for spaced repetition state
final spacedRepetitionProvider =
    StateNotifierProvider<SpacedRepetitionNotifier, SpacedRepetitionState>(
      (ref) => SpacedRepetitionNotifier(ref),
    );

/// State for spaced repetition system
class SpacedRepetitionState {
  final List<ReviewCard> cards;
  final ReviewSession? currentSession;
  final ReviewStats stats;
  final bool isLoading;
  final String? errorMessage; // Track errors without breaking flow

  const SpacedRepetitionState({
    this.cards = const [],
    this.currentSession,
    required this.stats,
    this.isLoading = false,
    this.errorMessage,
  });

  SpacedRepetitionState copyWith({
    List<ReviewCard>? cards,
    ReviewSession? currentSession,
    ReviewStats? stats,
    bool? isLoading,
    bool clearSession = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SpacedRepetitionState(
      cards: cards ?? this.cards,
      currentSession: clearSession
          ? null
          : (currentSession ?? this.currentSession),
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SpacedRepetitionNotifier extends StateNotifier<SpacedRepetitionState> {
  static const String _storageKey = 'spaced_repetition_cards';
  static const String _statsKey = 'spaced_repetition_stats';
  static const String _streakKey = 'spaced_repetition_streak';
  static const String _sessionsKey = 'spaced_repetition_sessions';

  final Ref _ref;

  SpacedRepetitionNotifier(this._ref)
    : super(SpacedRepetitionState(stats: ReviewStats.fromCards([]))) {
    _loadData();
    _scheduleNotifications();
  }

  /// Load cards from storage
  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, clearError: true);

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
        clearError: true,
      );
    } catch (e) {
      // Initialize with empty state on error, but keep flow going
      final stats = ReviewStats.fromCards([]);
      state = state.copyWith(
        cards: [],
        stats: stats,
        isLoading: false,
        errorMessage: 'Failed to load review data: ${e.toString()}',
      );
    }
  }

  /// Save cards to storage
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save cards
      final cardsJson = jsonEncode(state.cards.map((c) => c.toJson()).toList());
      await prefs.setString(_storageKey, cardsJson);

      // Save stats
      final statsData = {
        'reviewsToday': state.stats.reviewsToday,
        'streak': state.stats.currentStreak,
        'lastReviewDate': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_statsKey, jsonEncode(statsData));
    } catch (e) {
      throw Exception('Failed to save review data: $e');
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

    try {
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
        clearError: true,
      );

      await _saveData();
      await _scheduleNotifications();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to create review card: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Auto-seed review cards from lesson content
  /// Extracts key facts from lesson sections and quiz questions
  Future<void> autoSeedFromLesson({
    required String lessonId,
    required List<dynamic> lessonSections, // List<LessonSection>
    required List<dynamic>? quizQuestions, // List<QuizQuestion>?
  }) async {
    try {
      final cardsToCreate = <ReviewCard>[];
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      // Extract key facts from lesson sections
      int sectionIndex = 0;
      for (final section in lessonSections) {
        // Only create cards for key points, tips, warnings, and fun facts
        final sectionType = section.type.toString();
        if (sectionType.contains('keyPoint') ||
            sectionType.contains('tip') ||
            sectionType.contains('warning') ||
            sectionType.contains('funFact')) {
          final conceptId = '${lessonId}_section_$sectionIndex';

          // Check if card already exists
          if (!state.cards.any((c) => c.conceptId == conceptId)) {
            // Populate questionText from section content so the practice
            // screen can display real content without re-loading lesson data.
            final String? questionText = _safeStringField(section, 'content');
            final card = ReviewCard(
              id: '${conceptId}_${now.millisecondsSinceEpoch}_$sectionIndex',
              conceptId: conceptId,
              conceptType: ConceptType.fact,
              strength: 0.0,
              lastReviewed: now,
              nextReview: tomorrow, // Schedule for tomorrow
              reviewCount: 0,
              correctCount: 0,
              incorrectCount: 0,
              currentInterval: ReviewInterval.day1,
              history: [],
              questionText: questionText,
            );
            cardsToCreate.add(card);
          }
        }
        sectionIndex++;
      }

      // Extract quiz questions as review cards (limit to 5 to avoid overwhelming)
      if (quizQuestions != null && quizQuestions.isNotEmpty) {
        int questionIndex = 0;
        for (final q in quizQuestions.take(5)) {
          final conceptId = '${lessonId}_quiz_q$questionIndex';

          // Check if card already exists
          if (!state.cards.any((c) => c.conceptId == conceptId)) {
            // Populate questionText from quiz question text.
            final String? questionText = _safeStringField(q, 'question');
            final card = ReviewCard(
              id: '${conceptId}_${now.millisecondsSinceEpoch}_$questionIndex',
              conceptId: conceptId,
              conceptType: ConceptType.quizQuestion,
              strength: 0.0,
              lastReviewed: now,
              nextReview: tomorrow, // Schedule for tomorrow
              reviewCount: 0,
              correctCount: 0,
              incorrectCount: 0,
              currentInterval: ReviewInterval.day1,
              history: [],
              questionText: questionText,
            );
            cardsToCreate.add(card);
          }
          questionIndex++;
        }
      }

      // Limit total cards to 5 per lesson to avoid overwhelming
      final cardsToAdd = cardsToCreate.take(5).toList();

      if (cardsToAdd.isEmpty) {
        return; // No new cards to create
      }

      // Add cards to state
      final updatedCards = [...state.cards, ...cardsToAdd];
      final updatedStats = ReviewStats.fromCards(
        updatedCards,
        reviewsToday: state.stats.reviewsToday,
        streak: state.stats.currentStreak,
      );

      state = state.copyWith(
        cards: updatedCards,
        stats: updatedStats,
        clearError: true,
      );

      await _saveData();
      await _scheduleNotifications();
    } catch (e) {
      // Log error but don't break lesson completion flow
      state = state.copyWith(
        errorMessage: 'Failed to auto-seed review cards: ${e.toString()}',
      );
      // Don't rethrow - lesson completion should still succeed
    }
  }

  /// Safely read a named String field from a dynamic object (LessonSection /
  /// QuizQuestion) without introducing a circular import.
  /// Uses dynamic dispatch — returns null if the access throws or is non-String.
  String? _safeStringField(dynamic obj, String fieldName) {
    try {
      // ignore: avoid_dynamic_calls
      final dynamic value = fieldName == 'content'
          // ignore: avoid_dynamic_calls
          ? (obj as dynamic).content
          // ignore: avoid_dynamic_calls
          : (obj as dynamic).question;
      return value is String ? value : null;
    } catch (_) {
      return null;
    }
  }

  /// Update a review card after an attempt
  /// Card scheduling errors will not break review flow
  Future<void> reviewCard({
    required String cardId,
    required bool correct,
  }) async {
    final cardIndex = state.cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) {
      state = state.copyWith(errorMessage: 'Card not found: $cardId');
      return; // Don't break flow
    }

    // Store original state for potential rollback
    final originalCards = state.cards;
    final originalStats = state.stats;

    try {
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
        clearError: true,
      );

      await _saveData();
    } catch (e) {
      // Rollback on save failure, but don't break review flow
      state = state.copyWith(
        cards: originalCards,
        stats: originalStats,
        errorMessage:
            'Failed to save card review (will retry): ${e.toString()}',
      );
      // Don't rethrow - let review flow continue
    }
  }

  /// Start a new review session
  Future<void> startSession({
    ReviewSessionMode mode = ReviewSessionMode.standard,
  }) async {
    try {
      final session = ReviewQueueService.createSession(
        allCards: state.cards,
        mode: mode,
      );

      state = state.copyWith(currentSession: session, clearError: true);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to start review session: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Record result for current session card
  /// Errors in card scheduling will not break the session
  Future<ReviewSessionResult> recordSessionResult({
    required String cardId,
    required bool correct,
    required Duration timeSpent,
  }) async {
    if (state.currentSession == null) {
      throw Exception('No active session');
    }

    try {
      // Find the card
      final card = state.currentSession!.cards.firstWhere(
        (c) => c.id == cardId,
        orElse: () => throw Exception('Card not found in session: $cardId'),
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

      state = state.copyWith(currentSession: updatedSession, clearError: true);

      // Update the card itself (this has its own error handling)
      await reviewCard(cardId: cardId, correct: correct);

      return result;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error recording result: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Complete current session
  Future<void> completeSession() async {
    if (state.currentSession == null) return;

    try {
      // Update review streak
      await _updateReviewStreak();

      // Load and update session count
      final prefs = await SharedPreferences.getInstance();
      final sessionCountJson = prefs.getString(_sessionsKey);
      int sessionCount = 1;

      if (sessionCountJson != null) {
        final data = jsonDecode(sessionCountJson);
        sessionCount = (data['count'] ?? 0) + 1;
      }

      // Save session count
      await prefs.setString(_sessionsKey, jsonEncode({'count': sessionCount}));

      // Check session count achievements
      await _checkSessionCountAchievements(sessionCount);

      // Session is complete, clear it
      state = state.copyWith(clearSession: true, clearError: true);
      await _saveData();

      // Refresh notifications for next review
      await _scheduleNotifications();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to save session completion: ${e.toString()}',
      );
      rethrow;
    }
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
    // Load streak data from storage
    return state.stats.currentStreak;
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Update review streak after completing a session
  Future<void> _updateReviewStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Load streak data
      final streakJson = prefs.getString(_streakKey);
      int currentStreak = 0;
      DateTime? lastReviewDate;

      if (streakJson != null) {
        final streakData = jsonDecode(streakJson);
        currentStreak = streakData['currentStreak'] ?? 0;
        final lastDateStr = streakData['lastReviewDate'] as String?;
        if (lastDateStr != null) {
          lastReviewDate = DateTime.parse(lastDateStr);
        }
      }

      // Check if we've already reviewed today
      if (lastReviewDate != null && _isSameDay(lastReviewDate, now)) {
        return; // Streak already updated today
      }

      // Calculate new streak
      int newStreak;
      if (lastReviewDate == null) {
        // First review ever
        newStreak = 1;
      } else {
        final yesterday = now.subtract(const Duration(days: 1));
        if (_isSameDay(lastReviewDate, yesterday)) {
          // Reviewed yesterday - continue streak
          newStreak = currentStreak + 1;
        } else {
          // Missed a day - reset streak
          newStreak = 1;
        }
      }

      // Save updated streak
      final streakData = {
        'currentStreak': newStreak,
        'lastReviewDate': now.toIso8601String(),
      };
      await prefs.setString(_streakKey, jsonEncode(streakData));

      // Update stats
      final updatedStats = ReviewStats.fromCards(
        state.cards,
        reviewsToday: state.stats.reviewsToday,
        streak: newStreak,
      );
      state = state.copyWith(stats: updatedStats);

      // Check for streak achievements
      await _checkStreakAchievements(newStreak);
    } catch (e) {
      // Don't break flow on streak update failure
      state = state.copyWith(
        errorMessage: 'Failed to update review streak: ${e.toString()}',
      );
    }
  }

  /// Check for streak achievements
  Future<void> _checkStreakAchievements(int streak) async {
    try {
      final progressNotifier = _ref.read(achievementProgressProvider.notifier);
      final progressMap = _ref.read(achievementProgressProvider);

      // Check each streak milestone
      final milestones = [
        {'id': 'review_streak_3', 'target': 3},
        {'id': 'review_streak_7', 'target': 7},
        {'id': 'review_streak_14', 'target': 14},
        {'id': 'review_streak_30', 'target': 30},
      ];

      for (final milestone in milestones) {
        final id = milestone['id'] as String;
        final target = milestone['target'] as int;

        if (streak >= target) {
          final currentProgress = progressMap[id];
          if (currentProgress == null || !currentProgress.isUnlocked) {
            // Create or update progress
            final newProgress = AchievementProgress(
              achievementId: id,
              currentCount: target,
              isUnlocked: true,
              unlockedAt: DateTime.now(),
            );
            await progressNotifier.updateProgress(id, newProgress);
          }
        }
      }
    } catch (e) {
      // Don't break flow on achievement check failure
      state = state.copyWith(
        errorMessage: 'Failed to check achievements: ${e.toString()}',
      );
    }
  }

  /// Check for review session count achievements
  Future<void> _checkSessionCountAchievements(int sessionCount) async {
    try {
      final progressNotifier = _ref.read(achievementProgressProvider.notifier);
      final progressMap = _ref.read(achievementProgressProvider);

      // Check each session milestone
      final milestones = [
        {'id': 'first_review', 'target': 1},
        {'id': 'reviews_10', 'target': 10},
        {'id': 'reviews_50', 'target': 50},
        {'id': 'reviews_100', 'target': 100},
      ];

      for (final milestone in milestones) {
        final id = milestone['id'] as String;
        final target = milestone['target'] as int;

        if (sessionCount >= target) {
          final currentProgress = progressMap[id];
          if (currentProgress == null || !currentProgress.isUnlocked) {
            // Create or update progress
            final newProgress = AchievementProgress(
              achievementId: id,
              currentCount: target,
              isUnlocked: true,
              unlockedAt: DateTime.now(),
            );
            await progressNotifier.updateProgress(id, newProgress);
          }
        }
      }
    } catch (e) {
      // Don't break flow on achievement check failure
      state = state.copyWith(
        errorMessage: 'Failed to check achievements: ${e.toString()}',
      );
    }
  }

  /// Schedule notifications for due reviews
  Future<void> _scheduleNotifications() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Schedule review reminder if cards are due
      final dueCount = getDueCount();
      if (dueCount > 0) {
        await notificationService.scheduleReviewReminder(
          dueCardsCount: dueCount,
          time: const TimeOfDay(hour: 9, minute: 0), // 9 AM
        );
      }
    } catch (e) {
      // Don't break flow on notification scheduling failure
      state = state.copyWith(
        errorMessage: 'Failed to schedule notifications: ${e.toString()}',
      );
    }
  }

  /// Public method to refresh notifications (call when cards change)
  Future<void> refreshNotifications() async {
    await _scheduleNotifications();
  }

  /// Delete a card (for testing/debugging)
  Future<void> deleteCard(String cardId) async {
    try {
      final updatedCards = state.cards.where((c) => c.id != cardId).toList();
      final updatedStats = ReviewStats.fromCards(
        updatedCards,
        reviewsToday: state.stats.reviewsToday,
        streak: state.stats.currentStreak,
      );

      state = state.copyWith(
        cards: updatedCards,
        stats: updatedStats,
        clearError: true,
      );

      await _saveData();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete card: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Reset all data (for testing)
  Future<void> resetAll() async {
    state = SpacedRepetitionState(stats: ReviewStats.fromCards([]));

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove(_statsKey);
  }
}
