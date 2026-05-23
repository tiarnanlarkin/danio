/// Plain-text copy used by scheduled reminders.
///
/// Keep this helper free of platform notification dependencies so reminder copy
/// can be tested without invoking local notification plugins.
class NotificationCopy {
  const NotificationCopy._();

  static String taskReminderTitle(String taskTitle) =>
      '${taskTitle.trim()} is due today';

  static String taskReminderBody(String? description) {
    final trimmed = description?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return 'Tap to mark it done. Your tank will thank you.';
  }

  static String userReminderTitle(String title) {
    final trimmed = title.trim();
    return trimmed.isEmpty ? 'Aquarium reminder' : trimmed;
  }

  static String userReminderBody(String? notes) {
    final trimmed = notes?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return "It's time for your aquarium task.";
  }

  static String reviewReminderTitle() => 'Review time';

  static String reviewReminderBody(int dueCardsCount) {
    final noun = dueCardsCount == 1 ? 'card is' : 'cards are';
    return '$dueCardsCount $noun ready to review.';
  }

  static String morningStreakTitle() => 'Learning reminder';

  static String morningStreakBody(int currentStreak) {
    return 'Your $currentStreak-day streak is active. A short lesson keeps it going.';
  }

  static String eveningStreakTitle() => 'Daily goal reminder';

  static String eveningStreakBody({required int xpNeeded}) {
    return '$xpNeeded XP left to meet today\'s goal.';
  }

  static String nightStreakTitle() => 'Daily goal closes soon';

  static String nightStreakBody({required int currentStreak}) {
    return 'Your $currentStreak-day streak is active. Complete a short lesson before midnight if you want to keep it going.';
  }

  static String waterChangeTitle({
    required String tankName,
    required bool isOverdue,
  }) {
    final name = tankName.trim().isEmpty ? 'your tank' : tankName.trim();
    return isOverdue
        ? 'Water change due for $name'
        : 'Water change coming up for $name';
  }

  static String waterChangeBody({
    required String tankName,
    required int daysSinceLastChange,
    required bool isOverdue,
  }) {
    if (!isOverdue) {
      return 'Staying on top of water changes keeps your tank balanced.';
    }

    final name = tankName.trim().isEmpty ? 'Your tank' : tankName.trim();
    final dayLabel = daysSinceLastChange == 1 ? 'day' : 'days';
    return '$name is $daysSinceLastChange $dayLabel overdue for a water change.';
  }
}
