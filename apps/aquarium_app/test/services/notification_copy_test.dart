// Tests for notification reminder copy.
//
// Run: flutter test test/services/notification_copy_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:danio/services/notification_copy.dart';

void main() {
  group('NotificationCopy', () {
    test('formats task reminders without decorative prefixes', () {
      expect(
        NotificationCopy.taskReminderTitle('Feed the community tank'),
        'Feed the community tank is due today',
      );
      expect(
        NotificationCopy.taskReminderBody(null),
        'Tap to mark it done. Your tank will thank you.',
      );
      expect(
        NotificationCopy.taskReminderBody('Dose fertiliser after lights on'),
        'Dose fertiliser after lights on',
      );
    });

    test('formats review reminders as quiet plain text', () {
      expect(NotificationCopy.reviewReminderTitle(), 'Review time');
      expect(
        NotificationCopy.reviewReminderBody(1),
        '1 card is ready to review.',
      );
      expect(
        NotificationCopy.reviewReminderBody(4),
        '4 cards are ready to review.',
      );
    });

    test('formats user-created reminders without decorative prefixes', () {
      expect(
        NotificationCopy.userReminderTitle('Trim plants'),
        'Trim plants',
      );
      expect(
        NotificationCopy.userReminderTitle('   '),
        'Aquarium reminder',
      );
      expect(
        NotificationCopy.userReminderBody('Check the inlet sponge'),
        'Check the inlet sponge',
      );
      expect(
        NotificationCopy.userReminderBody(null),
        "It's time for your aquarium task.",
      );
    });

    test('formats water-change reminders without hype copy', () {
      expect(
        NotificationCopy.waterChangeTitle(
          tankName: 'Rio 180',
          isOverdue: true,
        ),
        'Water change due for Rio 180',
      );
      expect(
        NotificationCopy.waterChangeTitle(
          tankName: 'Rio 180',
          isOverdue: false,
        ),
        'Water change coming up for Rio 180',
      );
      expect(
        NotificationCopy.waterChangeBody(
          tankName: 'Rio 180',
          daysSinceLastChange: 1,
          isOverdue: true,
        ),
        'Rio 180 is 1 day overdue for a water change.',
      );
      expect(
        NotificationCopy.waterChangeBody(
          tankName: 'Rio 180',
          daysSinceLastChange: 9,
          isOverdue: true,
        ),
        'Rio 180 is 9 days overdue for a water change.',
      );
      expect(
        NotificationCopy.waterChangeBody(
          tankName: 'Rio 180',
          daysSinceLastChange: 3,
          isOverdue: false,
        ),
        'Staying on top of water changes keeps your tank balanced.',
      );
    });
  });
}
