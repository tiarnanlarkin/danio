import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/services/notification_scheduler.dart';

class _FakeReminderNotificationService implements ReminderNotificationService {
  int reviewScheduleCalls = 0;
  int reviewCancelCalls = 0;
  int streakScheduleCalls = 0;
  int streakCancelCalls = 0;

  @override
  Future<void> cancelReviewReminder() async {
    reviewCancelCalls++;
  }

  @override
  Future<void> cancelStreakNotifications() async {
    streakCancelCalls++;
  }

  @override
  Future<void> scheduleAllStreakNotifications({
    required int currentStreak,
    required int dailyXpGoal,
    required int todayXp,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    TimeOfDay? nightTime,
  }) async {
    streakScheduleCalls++;
  }

  @override
  Future<void> scheduleReviewReminder({
    required int dueCardsCount,
    TimeOfDay? time,
  }) async {
    reviewScheduleCalls++;
  }
}

void main() {
  group('NotificationScheduler', () {
    test(
      'does not schedule review reminders when notifications are disabled',
      () async {
        final service = _FakeReminderNotificationService();

        await NotificationScheduler.instance
            .scheduleReviewNotificationsForState(
              service: service,
              notificationsEnabled: false,
              reviewRemindersEnabled: true,
              dueCardsCount: 4,
            );

        expect(service.reviewScheduleCalls, 0);
        expect(service.reviewCancelCalls, 1);
      },
    );

    test(
      'does not schedule review reminders when review reminders are disabled',
      () async {
        final service = _FakeReminderNotificationService();

        await NotificationScheduler.instance
            .scheduleReviewNotificationsForState(
              service: service,
              notificationsEnabled: true,
              reviewRemindersEnabled: false,
              dueCardsCount: 4,
            );

        expect(service.reviewScheduleCalls, 0);
        expect(service.reviewCancelCalls, 1);
      },
    );

    test(
      'schedules review reminders only when enabled and cards are due',
      () async {
        final service = _FakeReminderNotificationService();

        await NotificationScheduler.instance
            .scheduleReviewNotificationsForState(
              service: service,
              notificationsEnabled: true,
              reviewRemindersEnabled: true,
              dueCardsCount: 4,
            );

        expect(service.reviewScheduleCalls, 1);
        expect(service.reviewCancelCalls, 0);
      },
    );

    test('cancels review reminders when no cards are due', () async {
      final service = _FakeReminderNotificationService();

      await NotificationScheduler.instance.scheduleReviewNotificationsForState(
        service: service,
        notificationsEnabled: true,
        reviewRemindersEnabled: true,
        dueCardsCount: 0,
      );

      expect(service.reviewScheduleCalls, 0);
      expect(service.reviewCancelCalls, 1);
    });

    test('does not schedule streak reminders when disabled', () async {
      final service = _FakeReminderNotificationService();

      await NotificationScheduler.instance.scheduleStreakNotificationsForState(
        service: service,
        notificationsEnabled: true,
        streakRemindersEnabled: false,
        currentStreak: 8,
        dailyXpGoal: 50,
        todayXp: 0,
      );

      expect(service.streakScheduleCalls, 0);
      expect(service.streakCancelCalls, 1);
    });

    test(
      'schedules streak reminders only when global and streak toggles are on',
      () async {
        final service = _FakeReminderNotificationService();

        await NotificationScheduler.instance
            .scheduleStreakNotificationsForState(
              service: service,
              notificationsEnabled: true,
              streakRemindersEnabled: true,
              currentStreak: 8,
              dailyXpGoal: 50,
              todayXp: 0,
            );

        expect(service.streakScheduleCalls, 1);
        expect(service.streakCancelCalls, 0);
      },
    );
  });
}
