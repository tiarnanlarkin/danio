import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/spaced_repetition_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/user_profile_provider.dart';
import 'notification_service.dart';
import '../utils/logger.dart';

abstract class ReminderNotificationService {
  Future<void> scheduleReviewReminder({
    required int dueCardsCount,
    TimeOfDay? time,
  });

  Future<void> cancelReviewReminder();

  Future<void> scheduleAllStreakNotifications({
    required int currentStreak,
    required int dailyXpGoal,
    required int todayXp,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    TimeOfDay? nightTime,
  });

  Future<void> cancelStreakNotifications();
}

class LocalReminderNotificationService implements ReminderNotificationService {
  final NotificationService _service;

  LocalReminderNotificationService(this._service);

  @override
  Future<void> cancelReviewReminder() => _service.cancelReviewReminder();

  @override
  Future<void> cancelStreakNotifications() =>
      _service.cancelStreakNotifications();

  @override
  Future<void> scheduleAllStreakNotifications({
    required int currentStreak,
    required int dailyXpGoal,
    required int todayXp,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    TimeOfDay? nightTime,
  }) {
    return _service.scheduleAllStreakNotifications(
      currentStreak: currentStreak,
      dailyXpGoal: dailyXpGoal,
      todayXp: todayXp,
      morningTime: morningTime,
      eveningTime: eveningTime,
      nightTime: nightTime,
    );
  }

  @override
  Future<void> scheduleReviewReminder({
    required int dueCardsCount,
    TimeOfDay? time,
  }) {
    return _service.scheduleReviewReminder(
      dueCardsCount: dueCardsCount,
      time: time,
    );
  }
}

final notificationServiceProvider = Provider<ReminderNotificationService>(
  (ref) => LocalReminderNotificationService(NotificationService()),
);

/// Service responsible for scheduling review and streak notifications.
///
/// Extracted from main.dart to keep the app shell lean.
/// All methods silently catch errors to avoid breaking app flow.
class NotificationScheduler {
  NotificationScheduler._();
  static final NotificationScheduler instance = NotificationScheduler._();

  /// Schedule review reminder notifications based on due cards.
  Future<void> scheduleReviewNotifications(WidgetRef ref) async {
    try {
      final srState = ref.read(spacedRepetitionProvider);
      final dueCount = srState.stats.dueCards;
      final profile = ref.read(userProfileProvider).value;
      final notificationsEnabled = ref
          .read(settingsProvider)
          .notificationsEnabled;
      final service = ref.read(notificationServiceProvider);

      await scheduleReviewNotificationsForState(
        service: service,
        notificationsEnabled: notificationsEnabled,
        reviewRemindersEnabled: profile?.reviewRemindersEnabled ?? false,
        dueCardsCount: dueCount,
      );
    } catch (e) {
      logError(
        'Failed to schedule review notifications: $e',
        tag: 'NotificationScheduler',
      );
    }
  }

  Future<void> scheduleReviewNotificationsForState({
    required ReminderNotificationService service,
    required bool notificationsEnabled,
    required bool reviewRemindersEnabled,
    required int dueCardsCount,
    TimeOfDay time = const TimeOfDay(hour: 9, minute: 0),
  }) async {
    if (!notificationsEnabled ||
        !reviewRemindersEnabled ||
        dueCardsCount <= 0) {
      await service.cancelReviewReminder();
      return;
    }

    await service.scheduleReviewReminder(
      dueCardsCount: dueCardsCount,
      time: time,
    );
  }

  /// Schedule streak nudge notifications based on current profile.
  /// Cancels existing streak notifications before re-scheduling to
  /// avoid duplicates. Silently skips if permission was not granted.
  Future<void> scheduleStreakNotifications(WidgetRef ref) async {
    try {
      final profile = ref.read(userProfileProvider).value;
      if (profile == null) return;

      final notificationsEnabled = ref
          .read(settingsProvider)
          .notificationsEnabled;
      final service = ref.read(notificationServiceProvider);
      final now = DateTime.now();
      final todayKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final todayXp = profile.dailyXpHistory[todayKey] ?? 0;

      await scheduleStreakNotificationsForState(
        service: service,
        notificationsEnabled: notificationsEnabled,
        streakRemindersEnabled: profile.streakRemindersEnabled,
        currentStreak: profile.currentStreak,
        dailyXpGoal: profile.dailyXpGoal,
        todayXp: todayXp,
        morningTime: _parseTime(profile.morningReminderTime, '09:00'),
        eveningTime: _parseTime(profile.eveningReminderTime, '19:00'),
        nightTime: _parseTime(profile.nightReminderTime, '23:00'),
      );
    } catch (e) {
      logError(
        'Failed to schedule streak notifications: $e',
        tag: 'NotificationScheduler',
      );
    }
  }

  Future<void> scheduleStreakNotificationsForState({
    required ReminderNotificationService service,
    required bool notificationsEnabled,
    required bool streakRemindersEnabled,
    required int currentStreak,
    required int dailyXpGoal,
    required int todayXp,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    TimeOfDay? nightTime,
  }) async {
    if (!notificationsEnabled || !streakRemindersEnabled) {
      await service.cancelStreakNotifications();
      return;
    }

    await service.scheduleAllStreakNotifications(
      currentStreak: currentStreak,
      dailyXpGoal: dailyXpGoal,
      todayXp: todayXp,
      morningTime: morningTime,
      eveningTime: eveningTime,
      nightTime: nightTime,
    );
  }

  TimeOfDay _parseTime(String? value, String fallback) {
    final parts = (value ?? fallback).split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 9;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }
}
