import 'package:flutter/foundation.dart';

enum GemTransactionType {
  earn, // Earned gems
  spend, // Spent gems on shop items
  refund, // Refunded purchase
  grant, // Admin/promotional grant
}

enum GemEarnReason {
  lessonComplete, // Completed a lesson
  quizPass, // Passed a quiz
  quizPerfect, // Got 100% on quiz
  dailyGoalMet, // Met daily XP goal
  streakMilestone, // Hit streak milestone (7, 30, 100 days)
  levelUp, // Reached new XP level
  achievementUnlock, // Unlocked an achievement
  placementTest, // Completed placement test
  weeklyBonus, // Weekly active user bonus
  referralBonus, // Referred a friend
  promotional, // Special event/promotion
}

@immutable
class GemTransaction {
  final String id;
  final GemTransactionType type;
  final int amount; // Positive for earn, negative for spend
  final String? reason; // GemEarnReason or item name
  final String? itemId; // If spending, which item was purchased
  final DateTime timestamp;
  final int balanceAfter; // Balance after this transaction

  const GemTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.reason,
    this.itemId,
    required this.timestamp,
    required this.balanceAfter,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'reason': reason,
    'itemId': itemId,
    'timestamp': timestamp.toIso8601String(),
    'balanceAfter': balanceAfter,
  };

  factory GemTransaction.fromJson(Map<String, dynamic> json) {
    return GemTransaction(
      id: json['id'] as String,
      type: GemTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GemTransactionType.earn,
      ),
      amount: json['amount'] as int,
      reason: json['reason'] as String?,
      itemId: json['itemId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      balanceAfter: json['balanceAfter'] as int,
    );
  }
}
