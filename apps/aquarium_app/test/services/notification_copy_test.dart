// Tests for notification reminder copy.
//
// Run: flutter test test/services/notification_copy_test.dart

import 'dart:io';

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

    test('formats streak reminders without pressure or decorative prefixes', () {
      expect(NotificationCopy.morningStreakTitle(), 'Learning reminder');
      expect(
        NotificationCopy.morningStreakBody(3),
        'Your 3-day streak is active. A short lesson keeps it going.',
      );
      expect(NotificationCopy.eveningStreakTitle(), 'Daily goal reminder');
      expect(
        NotificationCopy.eveningStreakBody(xpNeeded: 15),
        '15 XP left to meet today\'s goal.',
      );
      expect(NotificationCopy.nightStreakTitle(), 'Daily goal closes soon');
      expect(
        NotificationCopy.nightStreakBody(currentStreak: 7),
        'Your 7-day streak is active. Complete a short lesson before midnight if you want to keep it going.',
      );
    });

    test('streak notifications route through quiet copy helper', () {
      final source = File(
        'lib/services/notification_service.dart',
      ).readAsStringSync();

      expect(source, contains('NotificationCopy.morningStreakTitle'));
      expect(source, contains('NotificationCopy.eveningStreakTitle'));
      expect(source, contains('NotificationCopy.nightStreakTitle'));
      expect(source, isNot(contains('5 minutes to level up')));
      expect(source, isNot(contains('Don\\\'t lose your streak')));
      expect(source, isNot(contains('Last call before midnight')));
    });

    test('notification service titles avoid decorative emoji', () {
      final source = File(
        'lib/services/notification_service.dart',
      ).readAsStringSync();
      final decorativeCodePoints = [
        0x1F41F, // fish
        0x1F420, // tropical fish
        0x1F4AA, // flexed biceps
        0x1F389, // party popper
        0x1F9E0, // brain
        0x1F4CA, // bar chart
        0x1F3C6, // trophy
      ];

      for (final codePoint in decorativeCodePoints) {
        expect(source, isNot(contains(String.fromCharCode(codePoint))));
      }
    });

    test('formats user-created reminders without decorative prefixes', () {
      expect(NotificationCopy.userReminderTitle('Trim plants'), 'Trim plants');
      expect(NotificationCopy.userReminderTitle('   '), 'Aquarium reminder');
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
        NotificationCopy.waterChangeTitle(tankName: 'Rio 180', isOverdue: true),
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
