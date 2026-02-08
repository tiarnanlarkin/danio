/// Tests for Review Queue Service
/// Validates intelligent scheduling, prioritization, and adaptive algorithms

import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/spaced_repetition.dart';
import 'package:aquarium_app/services/review_queue_service.dart';

void main() {
  group('ReviewQueueService - Priority Calculation', () {
    test('overdue cards should have higher priority', () {
      final overdueCard = ReviewCard(
        id: 'overdue',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now().subtract(const Duration(days: 10)),
        nextReview: DateTime.now().subtract(const Duration(days: 5)),
      );

      final dueCard = ReviewCard(
        id: 'due',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final overduePriority = ReviewQueueService.calculatePriority(overdueCard);
      final duePriority = ReviewQueueService.calculatePriority(dueCard);

      expect(overduePriority, greaterThan(duePriority));
    });

    test('weaker cards should have higher priority', () {
      final weakCard = ReviewCard(
        id: 'weak',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.2,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final strongCard = ReviewCard(
        id: 'strong',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.8,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final weakPriority = ReviewQueueService.calculatePriority(weakCard);
      final strongPriority = ReviewQueueService.calculatePriority(strongCard);

      expect(weakPriority, greaterThan(strongPriority));
    });

    test('cards with low success rate should have higher priority', () {
      final strugglingCard = ReviewCard(
        id: 'struggling',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
        reviewCount: 10,
        correctCount: 3, // 30% success rate
        incorrectCount: 7,
      );

      final consistentCard = ReviewCard(
        id: 'consistent',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
        reviewCount: 10,
        correctCount: 9, // 90% success rate
        incorrectCount: 1,
      );

      final strugglingPriority = ReviewQueueService.calculatePriority(strugglingCard);
      final consistentPriority = ReviewQueueService.calculatePriority(consistentCard);

      expect(strugglingPriority, greaterThan(consistentPriority));
    });

    test('new cards should get medium priority', () {
      final newCard = ReviewCard.newCard(
        conceptId: 'test',
        conceptType: ConceptType.lesson,
      );

      final priority = ReviewQueueService.calculatePriority(newCard);

      // New cards get 5 points for being new + 10 points for weak (0 strength)
      // Total should be around 15
      expect(priority, greaterThan(10));
      expect(priority, lessThan(20));
    });
  });

  group('ReviewQueueService - Due Cards', () {
    test('getDueCards should return only due cards', () {
      final cards = [
        ReviewCard(
          id: 'due1',
          conceptId: 'test1',
          conceptType: ConceptType.lesson,
          strength: 0.5,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        ReviewCard(
          id: 'not_due',
          conceptId: 'test2',
          conceptType: ConceptType.lesson,
          strength: 0.5,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now().add(const Duration(days: 1)),
        ),
        ReviewCard(
          id: 'due2',
          conceptId: 'test3',
          conceptType: ConceptType.lesson,
          strength: 0.5,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
      ];

      final dueCards = ReviewQueueService.getDueCards(cards);

      expect(dueCards.length, 2);
      expect(dueCards.any((c) => c.id == 'due1'), true);
      expect(dueCards.any((c) => c.id == 'due2'), true);
      expect(dueCards.any((c) => c.id == 'not_due'), false);
    });

    test('getDueCards should respect limit parameter', () {
      final cards = List.generate(
        10,
        (i) => ReviewCard(
          id: 'card_$i',
          conceptId: 'test_$i',
          conceptType: ConceptType.lesson,
          strength: 0.5,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
      );

      final dueCards = ReviewQueueService.getDueCards(cards, limit: 5);

      expect(dueCards.length, 5);
    });

    test('getDueCards should prioritize by priority score when prioritizeWeak is true', () {
      final cards = [
        ReviewCard(
          id: 'strong',
          conceptId: 'test1',
          conceptType: ConceptType.lesson,
          strength: 0.8,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
        ReviewCard(
          id: 'weak',
          conceptId: 'test2',
          conceptType: ConceptType.lesson,
          strength: 0.2,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
        ReviewCard(
          id: 'medium',
          conceptId: 'test3',
          conceptType: ConceptType.lesson,
          strength: 0.5,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
      ];

      final dueCards = ReviewQueueService.getDueCards(
        cards,
        prioritizeWeak: true,
      );

      // Weak card should be first
      expect(dueCards.first.id, 'weak');
    });
  });

  group('ReviewQueueService - Mixed Practice', () {
    test('getMixedPracticeCards should include both due and strong cards', () {
      final cards = [
        // Due weak cards
        ...List.generate(
          5,
          (i) => ReviewCard(
            id: 'due_$i',
            conceptId: 'test_due_$i',
            conceptType: ConceptType.lesson,
            strength: 0.3,
            lastReviewed: DateTime.now(),
            nextReview: DateTime.now(),
          ),
        ),
        // Strong not-due cards
        ...List.generate(
          5,
          (i) => ReviewCard(
            id: 'strong_$i',
            conceptId: 'test_strong_$i',
            conceptType: ConceptType.lesson,
            strength: 0.9,
            lastReviewed: DateTime.now(),
            nextReview: DateTime.now().add(const Duration(days: 10)),
          ),
        ),
      ];

      final mixed = ReviewQueueService.getMixedPracticeCards(
        cards,
        sessionSize: 10,
      );

      expect(mixed.length, 10);
      
      // Should have mostly due cards (80%)
      final dueCount = mixed.where((c) => c.id.startsWith('due_')).length;
      expect(dueCount, greaterThanOrEqualTo(5)); // At least some due cards
      
      // Should have some strong cards (20%)
      final strongCount = mixed.where((c) => c.id.startsWith('strong_')).length;
      expect(strongCount, greaterThan(0)); // At least one strong card
    });

    test('getMixedPracticeCards should handle insufficient strong cards', () {
      final cards = [
        // Only due cards, no strong cards
        ...List.generate(
          3,
          (i) => ReviewCard(
            id: 'due_$i',
            conceptId: 'test_$i',
            conceptType: ConceptType.lesson,
            strength: 0.3,
            lastReviewed: DateTime.now(),
            nextReview: DateTime.now(),
          ),
        ),
      ];

      final mixed = ReviewQueueService.getMixedPracticeCards(
        cards,
        sessionSize: 10,
      );

      // Should return all available cards (3) even though session size is 10
      expect(mixed.length, 3);
    });
  });

  group('ReviewQueueService - Weak Cards', () {
    test('getWeakCards should return only weak cards (strength < 0.5)', () {
      final cards = [
        ReviewCard(
          id: 'weak1',
          conceptId: 'test1',
          conceptType: ConceptType.lesson,
          strength: 0.2,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
        ReviewCard(
          id: 'strong',
          conceptId: 'test2',
          conceptType: ConceptType.lesson,
          strength: 0.8,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
        ReviewCard(
          id: 'weak2',
          conceptId: 'test3',
          conceptType: ConceptType.lesson,
          strength: 0.4,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
      ];

      final weakCards = ReviewQueueService.getWeakCards(cards);

      expect(weakCards.length, 2);
      expect(weakCards.every((c) => c.strength < 0.5), true);
    });

    test('getWeakCards should sort by strength (weakest first)', () {
      final cards = [
        ReviewCard(
          id: 'medium',
          conceptId: 'test1',
          conceptType: ConceptType.lesson,
          strength: 0.4,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
        ReviewCard(
          id: 'weakest',
          conceptId: 'test2',
          conceptType: ConceptType.lesson,
          strength: 0.1,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
        ReviewCard(
          id: 'weak',
          conceptId: 'test3',
          conceptType: ConceptType.lesson,
          strength: 0.3,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
      ];

      final weakCards = ReviewQueueService.getWeakCards(cards);

      expect(weakCards.first.id, 'weakest');
      expect(weakCards.last.id, 'medium');
    });
  });

  group('ReviewQueueService - Adaptive Difficulty', () {
    test('high accuracy should recommend increase difficulty', () {
      final results = [
        _createResult(correct: true),
        _createResult(correct: true),
        _createResult(correct: true),
        _createResult(correct: true),
        _createResult(correct: true),
      ];

      final adjustment = ReviewQueueService.calculateDifficultyAdjustment(results);

      expect(adjustment, DifficultyAdjustment.increase);
    });

    test('low accuracy should recommend decrease difficulty', () {
      final results = [
        _createResult(correct: false),
        _createResult(correct: false),
        _createResult(correct: true),
        _createResult(correct: false),
        _createResult(correct: false),
      ];

      final adjustment = ReviewQueueService.calculateDifficultyAdjustment(results);

      expect(adjustment, DifficultyAdjustment.decrease);
    });

    test('medium accuracy should recommend maintain difficulty', () {
      final results = [
        _createResult(correct: true),
        _createResult(correct: false),
        _createResult(correct: true),
        _createResult(correct: true),
        _createResult(correct: false),
      ];

      final adjustment = ReviewQueueService.calculateDifficultyAdjustment(results);

      expect(adjustment, DifficultyAdjustment.maintain);
    });

    test('insufficient data should recommend maintain', () {
      final results = [
        _createResult(correct: true),
        _createResult(correct: false),
      ];

      final adjustment = ReviewQueueService.calculateDifficultyAdjustment(results);

      expect(adjustment, DifficultyAdjustment.maintain);
    });
  });

  group('ReviewQueueService - XP Calculation', () {
    test('correct answer should give base XP', () {
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final xp = ReviewQueueService.calculateXpReward(
        card: card,
        correct: true,
        timeSpent: const Duration(seconds: 15),
      );

      expect(xp, greaterThanOrEqualTo(10)); // Base XP
    });

    test('incorrect answer should give reduced XP', () {
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final xp = ReviewQueueService.calculateXpReward(
        card: card,
        correct: false,
        timeSpent: const Duration(seconds: 15),
      );

      expect(xp, lessThan(10)); // Should be 30% of base = 3
    });

    test('weak cards should give bonus XP', () {
      final weakCard = ReviewCard(
        id: 'test',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.2,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final strongCard = ReviewCard(
        id: 'test',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.8,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final weakXp = ReviewQueueService.calculateXpReward(
        card: weakCard,
        correct: true,
        timeSpent: const Duration(seconds: 15),
      );

      final strongXp = ReviewQueueService.calculateXpReward(
        card: strongCard,
        correct: true,
        timeSpent: const Duration(seconds: 15),
      );

      expect(weakXp, greaterThan(strongXp));
    });

    test('quick correct answers should get speed bonus', () {
      final card = ReviewCard(
        id: 'test',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
      );

      final quickXp = ReviewQueueService.calculateXpReward(
        card: card,
        correct: true,
        timeSpent: const Duration(seconds: 5),
      );

      final slowXp = ReviewQueueService.calculateXpReward(
        card: card,
        correct: true,
        timeSpent: const Duration(seconds: 20),
      );

      expect(quickXp, greaterThan(slowXp));
    });

    test('first-time correct should get new concept bonus', () {
      final newCard = ReviewCard.newCard(
        conceptId: 'test',
        conceptType: ConceptType.lesson,
      );

      final reviewedCard = ReviewCard(
        id: 'test',
        conceptId: 'test',
        conceptType: ConceptType.lesson,
        strength: 0.5,
        lastReviewed: DateTime.now(),
        nextReview: DateTime.now(),
        reviewCount: 5,
      );

      final newXp = ReviewQueueService.calculateXpReward(
        card: newCard,
        correct: true,
        timeSpent: const Duration(seconds: 10),
      );

      final reviewedXp = ReviewQueueService.calculateXpReward(
        card: reviewedCard,
        correct: true,
        timeSpent: const Duration(seconds: 10),
      );

      expect(newXp, greaterThan(reviewedXp));
    });
  });

  group('ReviewQueueService - Session Creation', () {
    test('createSession should create standard session with 10 cards', () {
      final cards = List.generate(
        20,
        (i) => ReviewCard(
          id: 'card_$i',
          conceptId: 'test_$i',
          conceptType: ConceptType.lesson,
          strength: 0.5,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
      );

      final session = ReviewQueueService.createSession(
        allCards: cards,
        mode: ReviewSessionMode.standard,
      );

      expect(session.cards.length, 10);
      expect(session.mode, ReviewSessionMode.standard);
    });

    test('createSession should create quick session with 5 cards', () {
      final cards = List.generate(
        20,
        (i) => ReviewCard(
          id: 'card_$i',
          conceptId: 'test_$i',
          conceptType: ConceptType.lesson,
          strength: 0.5,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
      );

      final session = ReviewQueueService.createSession(
        allCards: cards,
        mode: ReviewSessionMode.quick,
      );

      expect(session.cards.length, 5);
      expect(session.mode, ReviewSessionMode.quick);
    });

    test('createSession intensive mode should only include weak cards', () {
      final cards = [
        ...List.generate(
          5,
          (i) => ReviewCard(
            id: 'weak_$i',
            conceptId: 'test_weak_$i',
            conceptType: ConceptType.lesson,
            strength: 0.3,
            lastReviewed: DateTime.now(),
            nextReview: DateTime.now(),
          ),
        ),
        ...List.generate(
          5,
          (i) => ReviewCard(
            id: 'strong_$i',
            conceptId: 'test_strong_$i',
            conceptType: ConceptType.lesson,
            strength: 0.8,
            lastReviewed: DateTime.now(),
            nextReview: DateTime.now(),
          ),
        ),
      ];

      final session = ReviewQueueService.createSession(
        allCards: cards,
        mode: ReviewSessionMode.intensive,
      );

      expect(session.mode, ReviewSessionMode.intensive);
      expect(session.cards.every((c) => c.strength < 0.5), true);
    });
  });

  group('ReviewQueueService - Forecast', () {
    test('getForecast should calculate due cards for future dates', () {
      final cards = [
        ReviewCard(
          id: 'due_today',
          conceptId: 'test1',
          conceptType: ConceptType.lesson,
          strength: 0.5,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now(),
        ),
        ReviewCard(
          id: 'due_3_days',
          conceptId: 'test2',
          conceptType: ConceptType.lesson,
          strength: 0.5,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now().add(const Duration(days: 3)),
        ),
        ReviewCard(
          id: 'due_7_days',
          conceptId: 'test3',
          conceptType: ConceptType.lesson,
          strength: 0.5,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now().add(const Duration(days: 7)),
        ),
      ];

      final forecast = ReviewQueueService.getForecast(cards, daysAhead: 7);

      expect(forecast[0], 1); // 1 due today
      expect(forecast[3], 2); // 2 due by day 3
      expect(forecast[7], 3); // 3 due by day 7
    });
  });
}

// Helper function to create review session results
ReviewSessionResult _createResult({required bool correct}) {
  return ReviewSessionResult(
    cardId: 'test',
    correct: correct,
    timestamp: DateTime.now(),
    xpEarned: 10,
    timeSpent: const Duration(seconds: 5),
  );
}
