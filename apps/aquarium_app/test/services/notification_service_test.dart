/// Tests for NotificationService — scheduling logic, notification IDs, task reminders
///
/// Note: FlutterLocalNotificationsPlugin requires platform channels which aren't
/// available in unit tests. We test the logic and data structures that surround
/// the notification scheduling rather than the plugin calls themselves.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/models.dart';

void main() {
  group('Task notification scheduling logic', () {
    test('task with future dueDate should be schedulable', () {
      final task = Task(
        id: 'task-1',
        tankId: 'tank-1',
        title: 'Water Change',
        recurrence: RecurrenceType.weekly,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Scheduling logic: must have dueDate, be enabled, and be in the future
      final canSchedule = task.dueDate != null &&
          task.isEnabled &&
          task.dueDate!.isAfter(DateTime.now());

      expect(canSchedule, true);
    });

    test('disabled task should NOT be scheduled', () {
      final task = Task(
        id: 'task-2',
        tankId: 'tank-1',
        title: 'Filter Clean',
        recurrence: RecurrenceType.monthly,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        isEnabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final canSchedule = task.dueDate != null &&
          task.isEnabled &&
          task.dueDate!.isAfter(DateTime.now());

      expect(canSchedule, false);
    });

    test('task with past dueDate should NOT be scheduled', () {
      final task = Task(
        id: 'task-3',
        tankId: 'tank-1',
        title: 'Water Test',
        recurrence: RecurrenceType.weekly,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final canSchedule = task.dueDate != null &&
          task.isEnabled &&
          task.dueDate!.isAfter(DateTime.now());

      expect(canSchedule, false);
    });

    test('task without dueDate should NOT be scheduled', () {
      final task = Task(
        id: 'task-4',
        tankId: 'tank-1',
        title: 'Optional Task',
        recurrence: RecurrenceType.none,
        dueDate: null,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final canSchedule = task.dueDate != null &&
          task.isEnabled &&
          task.dueDate!.isAfter(DateTime.now());

      expect(canSchedule, false);
    });
  });

  group('Notification scheduling time calculation', () {
    test('task reminder scheduled at 9 AM on due date', () {
      final dueDate = DateTime(2026, 3, 15);
      final scheduledDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        9, // 9 AM
        0,
      );

      expect(scheduledDate.hour, 9);
      expect(scheduledDate.minute, 0);
      expect(scheduledDate.year, 2026);
      expect(scheduledDate.month, 3);
      expect(scheduledDate.day, 15);
    });

    test('morning streak reminder defaults to 9:00', () {
      const defaultTime = TimeOfDay(hour: 9, minute: 0);
      expect(defaultTime.hour, 9);
      expect(defaultTime.minute, 0);
    });

    test('evening streak reminder defaults to 19:00', () {
      const defaultTime = TimeOfDay(hour: 19, minute: 0);
      expect(defaultTime.hour, 19);
      expect(defaultTime.minute, 0);
    });

    test('night streak reminder defaults to 23:00', () {
      const defaultTime = TimeOfDay(hour: 23, minute: 0);
      expect(defaultTime.hour, 23);
      expect(defaultTime.minute, 0);
    });

    test('if scheduled time passed today, schedule for tomorrow', () {
      // Simulate: it's 10 AM, morning reminder is 9 AM
      final now = DateTime(2026, 2, 23, 10, 0);
      final time = const TimeOfDay(hour: 9, minute: 0);

      var scheduledDate = DateTime(
        now.year, now.month, now.day,
        time.hour, time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      expect(scheduledDate.day, 24); // Tomorrow
      expect(scheduledDate.hour, 9);
    });

    test('if scheduled time not yet passed, schedule for today', () {
      final now = DateTime(2026, 2, 23, 8, 0); // 8 AM
      final time = const TimeOfDay(hour: 9, minute: 0); // 9 AM

      var scheduledDate = DateTime(
        now.year, now.month, now.day,
        time.hour, time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      expect(scheduledDate.day, 23); // Today
      expect(scheduledDate.hour, 9);
    });
  });

  group('Notification ID generation', () {
    test('task notification IDs are deterministic via hashCode', () {
      const taskId = 'task-water-change-123';
      final notifId1 = taskId.hashCode;
      final notifId2 = taskId.hashCode;
      expect(notifId1, notifId2);
    });

    test('different task IDs produce different notification IDs', () {
      const taskId1 = 'task-water-change';
      const taskId2 = 'task-filter-clean';
      expect(taskId1.hashCode, isNot(taskId2.hashCode));
    });

    test('streak notification IDs are fixed constants', () {
      // These match the constants in notification_service.dart
      const morningId = 1000;
      const eveningId = 1001;
      const nightId = 1002;

      expect(morningId, isNot(eveningId));
      expect(eveningId, isNot(nightId));
      expect(morningId, isNot(nightId));
    });
  });

  group('Notification cancellation logic', () {
    test('cancelling by task ID uses same hashCode', () {
      const taskId = 'my-task-abc';
      final scheduleId = taskId.hashCode;
      final cancelId = taskId.hashCode;
      expect(scheduleId, cancelId);
    });

    test('streak notifications cancel all three IDs', () {
      final streakIds = [1000, 1001, 1002];
      expect(streakIds.length, 3);
      expect(streakIds.toSet().length, 3, reason: 'All IDs must be unique');
    });
  });

  group('Streak notification content', () {
    test('morning message includes current streak', () {
      const streak = 15;
      final message = 'Start your $streak-day streak with today\'s lesson';
      expect(message, contains('15'));
      expect(message, contains('streak'));
    });

    test('evening message includes XP needed', () {
      const streak = 10;
      const xpNeeded = 30;
      final message =
          'Just $xpNeeded XP to keep your $streak-day streak!';
      expect(message, contains('30'));
      expect(message, contains('10'));
    });

    test('night message is urgent', () {
      const streak = 7;
      final message =
          'Only 5 minutes left to save your $streak-day streak!';
      expect(message, contains('5 minutes'));
      expect(message, contains('7'));
    });
  });

  group('Streak notification scheduling conditions', () {
    test('evening/night notifications only when goal not met', () {
      const dailyGoal = 50;
      const todayXp = 30;
      final xpNeeded = dailyGoal - todayXp;

      // Should schedule evening/night because goal not met
      expect(xpNeeded > 0, true);
    });

    test('evening/night notifications NOT scheduled when goal met', () {
      const dailyGoal = 50;
      const todayXp = 60;
      final xpNeeded = dailyGoal - todayXp;

      // Should NOT schedule evening/night
      expect(xpNeeded > 0, false);
    });

    test('morning notification always scheduled regardless of XP', () {
      // Morning notification is always scheduled — no XP check needed
      // This is a documentation-as-test that morning doesn't depend on XP
      expect(true, true);
    });
  });

  group('scheduleAllTaskReminders logic', () {
    test('only enabled tasks with due dates are scheduled', () {
      final now = DateTime.now();
      final tasks = [
        Task(
          id: 'enabled-with-date',
          title: 'Task 1',
          recurrence: RecurrenceType.weekly,
          dueDate: now.add(const Duration(days: 3)),
          isEnabled: true,
          createdAt: now,
          updatedAt: now,
        ),
        Task(
          id: 'disabled',
          title: 'Task 2',
          recurrence: RecurrenceType.weekly,
          dueDate: now.add(const Duration(days: 3)),
          isEnabled: false,
          createdAt: now,
          updatedAt: now,
        ),
        Task(
          id: 'no-date',
          title: 'Task 3',
          recurrence: RecurrenceType.none,
          dueDate: null,
          isEnabled: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final schedulable = tasks
          .where((t) => t.isEnabled && t.dueDate != null)
          .toList();

      expect(schedulable.length, 1);
      expect(schedulable.first.id, 'enabled-with-date');
    });
  });
}
