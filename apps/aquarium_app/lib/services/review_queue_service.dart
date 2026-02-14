/// Review Queue Service
/// Implements intelligent review scheduling and prioritization algorithms
library;

import 'dart:math' as math;
import '../models/spaced_repetition.dart';

/// Service for intelligent review scheduling and prioritization.
///
/// Implements spaced repetition algorithms with priority scoring based on:
/// - Card strength and success rate
/// - Due date urgency
/// - Mixed practice sessions combining due and strong cards
class ReviewQueueService {
  /// Calculate priority score for a review card (higher = more urgent)
  /// Factors: due date, strength, review history
  static double calculatePriority(ReviewCard card) {
    double priority = 0.0;

    // Factor 1: How overdue is the card? (0-10 points)
    if (card.isDue) {
      final daysOverdue = DateTime.now().difference(card.nextReview).inDays;
      priority += math.min(10.0, daysOverdue.toDouble());
    }

    // Factor 2: How weak is the card? (0-10 points)
    // Weaker cards get higher priority
    priority += (1.0 - card.strength) * 10.0;

    // Factor 3: Success rate penalty (0-5 points)
    // Cards with low success rate get more priority
    if (card.reviewCount > 0) {
      priority += (1.0 - card.successRate) * 5.0;
    }

    // Factor 4: New cards get medium priority (5 points)
    if (card.reviewCount == 0) {
      priority += 5.0;
    }

    return priority;
  }

  /// Get cards that are due for review, sorted by priority
  static List<ReviewCard> getDueCards(
    List<ReviewCard> allCards, {
    int? limit,
    bool prioritizeWeak = true,
  }) {
    // Filter to only due cards
    var dueCards = allCards.where((card) => card.isDue).toList();

    if (prioritizeWeak) {
      // Sort by priority score (highest first)
      dueCards.sort((a, b) {
        final priorityA = calculatePriority(a);
        final priorityB = calculatePriority(b);
        return priorityB.compareTo(priorityA); // Descending
      });
    } else {
      // Random order for variety
      dueCards.shuffle();
    }

    // Apply limit if specified
    if (limit != null && dueCards.length > limit) {
      dueCards = dueCards.sublist(0, limit);
    }

    return dueCards;
  }

  /// Get a mixed practice session (due + strong cards for spaced practice)
  /// Mixes 80% due/weak cards with 20% strong cards to prevent over-forgetting
  static List<ReviewCard> getMixedPracticeCards(
    List<ReviewCard> allCards, {
    int sessionSize = 10,
  }) {
    // Get due cards
    final dueCards = getDueCards(allCards, limit: null);

    // Get strong cards (not due, but good to review occasionally)
    final strongCards =
        allCards.where((card) => !card.isDue && card.isStrong).toList()
          ..shuffle();

    // Mix: 80% due, 20% strong (or all due if not enough strong cards)
    final dueCount = (sessionSize * 0.8).round();
    final strongCount = sessionSize - dueCount;

    final mixed = <ReviewCard>[];

    // Add due cards
    mixed.addAll(dueCards.take(math.min(dueCount, dueCards.length)));

    // Add strong cards if we have room
    if (mixed.length < sessionSize && strongCards.isNotEmpty) {
      final remaining = sessionSize - mixed.length;
      mixed.addAll(strongCards.take(math.min(remaining, strongCards.length)));
    }

    // Shuffle the final list for variety
    mixed.shuffle();

    return mixed;
  }

  /// Get cards filtered by mastery level
  static List<ReviewCard> getCardsByMastery(
    List<ReviewCard> allCards,
    MasteryLevel level,
  ) {
    return allCards.where((card) => card.masteryLevel == level).toList();
  }

  /// Get weak cards (strength < 0.5) for intensive practice
  static List<ReviewCard> getWeakCards(
    List<ReviewCard> allCards, {
    int? limit,
  }) {
    var weakCards = allCards.where((card) => card.isWeak).toList();

    // Sort by strength (weakest first)
    weakCards.sort((a, b) => a.strength.compareTo(b.strength));

    if (limit != null && weakCards.length > limit) {
      weakCards = weakCards.sublist(0, limit);
    }

    return weakCards;
  }

  /// Create a review session based on mode
  static ReviewSession createSession({
    required List<ReviewCard> allCards,
    required ReviewSessionMode mode,
  }) {
    List<ReviewCard> sessionCards;

    switch (mode) {
      case ReviewSessionMode.standard:
        // 10 cards, prioritize due and weak
        sessionCards = getDueCards(allCards, limit: 10);
        break;

      case ReviewSessionMode.quick:
        // 5 cards, quick review
        sessionCards = getDueCards(allCards, limit: 5);
        break;

      case ReviewSessionMode.intensive:
        // Focus on weak cards only
        sessionCards = getWeakCards(allCards, limit: 10);
        break;

      case ReviewSessionMode.mixed:
        // Mix of due + strong cards
        sessionCards = getMixedPracticeCards(allCards, sessionSize: 10);
        break;
    }

    final now = DateTime.now();
    return ReviewSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      startTime: now,
      cards: sessionCards,
      mode: mode,
    );
  }

  /// Calculate adaptive difficulty adjustment
  /// If user is struggling (multiple wrong answers), suggest easier questions
  /// If user is doing well (multiple correct), suggest harder questions
  static DifficultyAdjustment calculateDifficultyAdjustment(
    List<ReviewSessionResult> recentResults,
  ) {
    if (recentResults.length < 3) {
      return DifficultyAdjustment.maintain;
    }

    // Look at last 5 results
    final recent = recentResults.reversed.take(5).toList();
    final correctCount = recent.where((r) => r.correct).length;
    final accuracy = correctCount / recent.length;

    if (accuracy >= 0.8) {
      return DifficultyAdjustment.increase; // Doing well, make it harder
    } else if (accuracy <= 0.4) {
      return DifficultyAdjustment.decrease; // Struggling, make it easier
    } else {
      return DifficultyAdjustment.maintain; // Just right
    }
  }

  /// Get next card to review based on adaptive difficulty
  static ReviewCard? getNextCardWithAdaptiveDifficulty(
    List<ReviewCard> remainingCards,
    DifficultyAdjustment adjustment,
  ) {
    if (remainingCards.isEmpty) return null;

    switch (adjustment) {
      case DifficultyAdjustment.decrease:
        // Return easier card (higher strength)
        remainingCards.sort((a, b) => b.strength.compareTo(a.strength));
        return remainingCards.first;

      case DifficultyAdjustment.increase:
        // Return harder card (lower strength)
        remainingCards.sort((a, b) => a.strength.compareTo(b.strength));
        return remainingCards.first;

      case DifficultyAdjustment.maintain:
        // Return highest priority card
        remainingCards.sort((a, b) {
          return calculatePriority(b).compareTo(calculatePriority(a));
        });
        return remainingCards.first;
    }
  }

  /// Calculate XP reward based on card difficulty and performance
  static int calculateXpReward({
    required ReviewCard card,
    required bool correct,
    required Duration timeSpent,
  }) {
    int baseXp = 10;

    // Bonus for difficulty (weaker cards = more XP)
    if (card.strength < 0.3) {
      baseXp += 5; // Very weak card
    } else if (card.strength < 0.5) {
      baseXp += 3; // Weak card
    }

    // Penalty for incorrect
    if (!correct) {
      baseXp = (baseXp * 0.3).round(); // 30% XP for incorrect
    }

    // Bonus for quick correct answers (under 10 seconds)
    if (correct && timeSpent.inSeconds < 10) {
      baseXp += 2; // Speed bonus
    }

    // Bonus for first-time correct
    if (correct && card.reviewCount == 0) {
      baseXp += 5; // New concept learned
    }

    return baseXp;
  }

  /// Generate daily notification message based on due cards
  static String generateNotificationMessage(int dueCount) {
    if (dueCount == 0) {
      return 'All caught up! 🎉';
    } else if (dueCount == 1) {
      return '1 card needs review 📚';
    } else if (dueCount <= 5) {
      return '$dueCount cards need review 📚';
    } else if (dueCount <= 10) {
      return '$dueCount cards waiting! Keep your knowledge fresh 💪';
    } else {
      return '$dueCount cards need attention! Time to practice 🔥';
    }
  }

  /// Calculate recommended session length based on available cards
  static int recommendSessionLength(List<ReviewCard> dueCards) {
    final count = dueCards.length;

    if (count == 0) return 0;
    if (count <= 5) return count;
    if (count <= 10) return 5;
    if (count <= 20) return 10;
    return 15; // Cap at 15 for long sessions
  }

  /// Get forecast: how many cards will be due in X days
  static Map<int, int> getForecast(
    List<ReviewCard> allCards, {
    int daysAhead = 7,
  }) {
    final forecast = <int, int>{};

    for (int day = 0; day <= daysAhead; day++) {
      final targetDate = DateTime.now().add(Duration(days: day));
      final dueByThen = allCards.where((card) {
        return card.nextReview.isBefore(targetDate) ||
            card.nextReview.isAtSameMomentAs(targetDate);
      }).length;

      forecast[day] = dueByThen;
    }

    return forecast;
  }
}

/// Adaptive difficulty adjustment recommendation
enum DifficultyAdjustment {
  decrease, // User is struggling - show easier cards
  maintain, // User is doing fine - maintain difficulty
  increase, // User is excelling - show harder cards
}
