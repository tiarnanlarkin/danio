import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/models.dart' hide Achievement;
import '../models/achievements.dart';

// Notification IDs for streak reminders
const int _morningNotificationId = 1000;
const int _eveningNotificationId = 1001;
const int _nightNotificationId = 1002;

/// Service for managing local notifications for task reminders and streak reminders.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  // Cached schedule mode — resolved once on first scheduling call (P2-007).
  AndroidScheduleMode? _cachedScheduleMode;

  // Callback for handling notification taps
  Function(String?)? onNotificationTap;

  /// Initialize the notification service.
  Future<void> initialize({Function(String?)? onSelectNotification}) async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    // Store callback for notification taps
    if (onSelectNotification != null) {
      onNotificationTap = onSelectNotification;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        if (details.payload != null && onNotificationTap != null) {
          onNotificationTap!(details.payload);
        }
      },
    );
    _initialized = true;
  }

  /// Returns the best available AndroidScheduleMode (cached after first call).
  ///
  /// On Android 12+ (API 31+) SCHEDULE_EXACT_ALARM requires an explicit user
  /// grant via Settings → Alarms & Reminders.  If it has not been granted,
  /// zonedSchedule throws PlatformException("exact_alarms_not_permitted").
  /// We check at runtime and fall back to inexact alarms (P2-007).
  Future<AndroidScheduleMode> _resolveScheduleMode() async {
    if (_cachedScheduleMode != null) return _cachedScheduleMode!;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      _cachedScheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      return _cachedScheduleMode!;
    }
    try {
      final canExact = await android.canScheduleExactNotifications() ?? false;
      _cachedScheduleMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (_) {
      _cachedScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    }
    return _cachedScheduleMode!;
  }

  /// Request notification permissions (iOS mainly).
  Future<bool> requestPermissions() async {
    // Android 13+ requires explicit permission
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Schedule a notification for a task.
  Future<void> scheduleTaskReminder(Task task) async {
    if (!_initialized) await initialize();
    if (task.dueDate == null || !task.isEnabled) return;

    // Schedule for 9 AM on the due date
    final scheduledDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
      9, // 9 AM
      0,
    );

    // Don't schedule if in the past
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      task.id.hashCode,
      '✅ ${task.title} is due today',
      task.description ?? 'Tap to mark it done — your tank will thank you!',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for aquarium maintenance tasks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: await _resolveScheduleMode(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a specific task notification.
  Future<void> cancelTaskReminder(String taskId) async {
    if (!_initialized) await initialize();
    await _plugin.cancel(taskId.hashCode);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    if (!_initialized) await initialize();
    await _plugin.cancelAll();
  }

  /// Show an immediate notification (for testing).
  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();

    await _plugin.show(
      0,
      '🐟 Danio',
      'Notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Send notification for achievement unlock
  Future<void> sendAchievementNotification({
    required Achievement achievement,
    required int xpAwarded,
    required int gemsAwarded,
  }) async {
    if (!_initialized) await initialize();

    // Use achievement ID hash as notification ID to avoid duplicates
    final notificationId = achievement.id.hashCode;

    await _plugin.show(
      notificationId,
      '🎉 Achievement Unlocked!',
      '${achievement.icon} ${achievement.name} - +$xpAwarded XP, +$gemsAwarded 💎',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          channelDescription: 'Notifications for unlocked achievements',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'achievements', // Navigate to achievements screen when tapped
    );
  }

  /// Schedule notifications for all enabled tasks with due dates.
  Future<void> scheduleAllTaskReminders(List<Task> tasks) async {
    if (!_initialized) await initialize();

    // Cancel only existing task notifications (not streak/review/water reminders)
    for (final task in tasks) {
      await _plugin.cancel(task.id.hashCode);
    }

    // Reschedule enabled tasks
    for (final task in tasks) {
      if (task.isEnabled && task.dueDate != null) {
        await scheduleTaskReminder(task);
      }
    }
  }

  // ==================== STREAK NOTIFICATIONS ====================

  /// Schedule daily morning streak reminder (9 AM)
  Future<void> scheduleMorningStreakReminder({
    required int currentStreak,
    required TimeOfDay time,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      _morningNotificationId,
      '🐠 5 minutes to level up your fishkeeping today?',
      'Your 🔥 $currentStreak-day streak is waiting — let\'s keep it going!',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription:
              'Daily reminders to maintain your learning streak',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: await _resolveScheduleMode(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: 'learn', // Navigate to learn screen
    );
  }

  /// Schedule evening streak reminder if goal not met (7 PM)
  Future<void> scheduleEveningStreakReminder({
    required int currentStreak,
    required int xpNeeded,
    required TimeOfDay time,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      _eveningNotificationId,
      '🔥 Don\'t lose your streak! Complete a lesson today',
      'Just $xpNeeded XP away from keeping your 🔥 $currentStreak-day streak alive!',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription:
              'Daily reminders to maintain your learning streak',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: await _resolveScheduleMode(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: 'learn', // Navigate to learn screen
    );
  }

  /// Schedule late night streak reminder if goal not met (11 PM)
  Future<void> scheduleNightStreakReminder({
    required int currentStreak,
    required TimeOfDay time,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      _nightNotificationId,
      '⏰ Last call before midnight!',
      '🔥 Your $currentStreak-day streak ends at midnight. A 5-minute lesson is all it takes — you\'ve got this!',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription:
              'Daily reminders to maintain your learning streak',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          sound: RawResourceAndroidNotificationSound('notification'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: await _resolveScheduleMode(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: 'learn', // Navigate to learn screen
    );
  }

  /// Cancel all streak notifications
  Future<void> cancelStreakNotifications() async {
    if (!_initialized) await initialize();
    await _plugin.cancel(_morningNotificationId);
    await _plugin.cancel(_eveningNotificationId);
    await _plugin.cancel(_nightNotificationId);
  }

  /// Schedule all streak notifications based on user preferences
  /// This should be called when streak reminders are enabled or settings change
  Future<void> scheduleAllStreakNotifications({
    required int currentStreak,
    required int dailyXpGoal,
    required int todayXp,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    TimeOfDay? nightTime,
  }) async {
    if (!_initialized) await initialize();

    // Cancel existing streak notifications
    await cancelStreakNotifications();

    // Schedule morning notification
    await scheduleMorningStreakReminder(
      currentStreak: currentStreak,
      time: morningTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    // Only schedule evening/night notifications if goal not met today
    final xpNeeded = dailyXpGoal - todayXp;
    if (xpNeeded > 0) {
      await scheduleEveningStreakReminder(
        currentStreak: currentStreak,
        xpNeeded: xpNeeded,
        time: eveningTime ?? const TimeOfDay(hour: 19, minute: 0),
      );

      await scheduleNightStreakReminder(
        currentStreak: currentStreak,
        time: nightTime ?? const TimeOfDay(hour: 23, minute: 0),
      );
    }
  }

  // ==================== SPACED REPETITION REVIEW NOTIFICATIONS ====================

  /// Notification ID for review reminders
  static const int _reviewReminderNotificationId = 2000;

  /// Schedule daily review reminder if cards are due
  /// Shows "You have X cards ready to review!" at specified time
  Future<void> scheduleReviewReminder({
    required int dueCardsCount,
    TimeOfDay? time,
  }) async {
    if (!_initialized) await initialize();

    // Cancel existing review notification
    await _plugin.cancel(_reviewReminderNotificationId);

    // Don't schedule if no cards are due
    if (dueCardsCount == 0) return;

    final now = DateTime.now();
    final reviewTime = time ?? const TimeOfDay(hour: 9, minute: 0);

    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reviewTime.hour,
      reviewTime.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      _reviewReminderNotificationId,
      '📚 Review time — keep that knowledge sharp!',
      'You have $dueCardsCount card${dueCardsCount == 1 ? '' : 's'} ready to review. Takes just a few minutes!',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'review_reminders',
          'Review Reminders',
          channelDescription:
              'Daily reminders to review spaced repetition cards',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: await _resolveScheduleMode(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: 'review', // Navigate to review screen
    );
  }

  /// Cancel review reminder notification
  Future<void> cancelReviewReminder() async {
    if (!_initialized) await initialize();
    await _plugin.cancel(_reviewReminderNotificationId);
  }

  // ==================== WATER CHANGE REMINDERS ====================

  /// Notification ID for water change reminders
  static const int _waterChangeNotificationId = 3000;

  /// Schedule a water change reminder based on days since last water change.
  ///
  /// If [daysSinceLastChange] >= [reminderThresholdDays], schedules an
  /// immediate-ish notification. Otherwise, schedules for when the threshold
  /// will be reached.
  Future<void> scheduleWaterChangeReminder({
    required String tankName,
    required int daysSinceLastChange,
    int reminderThresholdDays = 7,
    int tankIndex = 0,
  }) async {
    if (!_initialized) await initialize();

    final notificationId = _waterChangeNotificationId + tankIndex;
    await _plugin.cancel(notificationId);

    final daysUntilReminder = reminderThresholdDays - daysSinceLastChange;

    // If overdue or due today, show within the hour
    final now = DateTime.now();
    DateTime scheduledDate;
    if (daysUntilReminder <= 0) {
      scheduledDate = now.add(const Duration(hours: 1));
    } else {
      // Schedule for 10 AM on the day the water change is due
      scheduledDate = DateTime(
        now.year, now.month, now.day + daysUntilReminder, 10, 0,
      );
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final isOverdue = daysSinceLastChange >= reminderThresholdDays;
    final title = isOverdue
        ? '💧 Your fish want fresh water!'
        : '💧 Water change coming up for $tankName';
    final body = isOverdue
        ? '$tankName is $daysSinceLastChange days overdue for a water change. A quick refresh makes a big difference!'
        : 'Staying on top of water changes keeps your fish happy and your tank balanced.';

    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_change_reminders',
          'Water Change Reminders',
          channelDescription: 'Reminders for aquarium water changes',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: await _resolveScheduleMode(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'water_change',
    );
  }

  /// Cancel water change reminder for a specific tank.
  Future<void> cancelWaterChangeReminder({int tankIndex = 0}) async {
    if (!_initialized) await initialize();
    await _plugin.cancel(_waterChangeNotificationId + tankIndex);
  }
}
