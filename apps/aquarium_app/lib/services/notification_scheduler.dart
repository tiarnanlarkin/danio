import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/spaced_repetition_provider.dart';
import '../providers/user_profile_provider.dart';
import 'notification_service.dart';
import '../utils/logger.dart';

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

      final notificationService = NotificationService();
      await notificationService.scheduleReviewReminder(
        dueCardsCount: dueCount,
        time: const TimeOfDay(hour: 9, minute: 0),
      );
    } catch (e) {
      logError(kDebugMode, tag: 'NotificationScheduler');
    }
  }

  /// Schedule streak nudge notifications based on current profile.
  /// Cancels existing streak notifications before re-scheduling to
  /// avoid duplicates. Silently skips if permission was not granted.
  Future<void> scheduleStreakNotifications(WidgetRef ref) async {
    try {
      final profile = ref.read(userProfileProvider).value;
      if (profile == null) return;

      final notificationService = NotificationService();
      final now = DateTime.now();
      final todayKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final todayXp = profile.dailyXpHistory[todayKey] ?? 0;

      await notificationService.scheduleAllStreakNotifications(
        currentStreak: profile.currentStreak,
        dailyXpGoal: profile.dailyXpGoal,
        todayXp: todayXp,
      );
    } catch (e) {
      logError(kDebugMode, tag: 'NotificationScheduler');
    }
  }
}
