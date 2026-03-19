import 'dart:async';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/models.dart';
import 'package:danio/utils/logger.dart';

// Notification IDs for streak reminders
const int _morningNotificationId = 1000;
const int _eveningNotificationId = 1001;
const int _nightNotificationId = 1002;

// Notification IDs for onboarding sequence (Dionysus Day 1-3)
const int _onboardingWelcomeId = 4000;
const int _onboardingCareReminderId = 4001;
const int _onboardingDiscoveryHookId = 4002;
const int _onboardingStreakNudgeId = 4003;
const int _onboardingAchievementId = 4004;

// Notification IDs for weekly onboarding cadence (Day 7, 14, 21, 28)
const int _weeklyTipDay7Id = 4010;
const int _progressNudgeDay14Id = 4011;
const int _discoveryHookDay21Id = 4012;
const int _milestoneApproachDay28Id = 4013;

/// Service for managing local notifications for task reminders and streak reminders.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Completer<void>? _initCompleter;
  // Cached schedule mode — resolved once on first scheduling call (P2-007).
  AndroidScheduleMode? _cachedScheduleMode;

  // Callback for handling notification taps.
  // Updated: uses payload-based routing. Callers should set onNotificationTap
  // to a handler that switches tabs based on payload:
  //   'home'  → currentTabProvider = 0 (Home tab)
  //   'learn' → currentTabProvider = 1 (Learn tab)
  //   'care'  → currentTabProvider = 0 (Home tab, care/log view)
  //   'review'→ currentTabProvider = 1 (Learn tab, then push review screen)
  //   'achievements' → currentTabProvider = 2 (Profile tab, achievements)
  //   'water_change'  → currentTabProvider = 0 (Home tab)
  Function(String?)? onNotificationTap;

  /// Initialize the notification service.
  /// Safe to call multiple times — concurrent callers will await the same
  /// completer and only one initialization runs.
  Future<void> initialize({Function(String?)? onSelectNotification}) async {
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return;
    }

    _initCompleter = Completer<void>();

    try {
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
          if (details.payload != null && onNotificationTap != null) {
            onNotificationTap!(details.payload);
          } else if (details.payload != null) {
            // Fallback: attempt to navigate via the global navigator key
            // if no tap handler is set. This ensures notifications still
            // navigate somewhere useful even without provider access.
            _handleNotificationFallback(details.payload!);
          }
        },
      );
      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      rethrow;
    }
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
      if (!canExact) {
        // Attempt to request the permission if not yet granted.
        try {
          await android.requestExactAlarmsPermission();
          final retriedCanExact =
              await android.canScheduleExactNotifications() ?? false;
          _cachedScheduleMode = retriedCanExact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle;
        } catch (_) {
          _cachedScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
        }
      } else {
        _cachedScheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }
    } catch (e) {
      logError('Notification: failed to detect exact alarm support: $e', tag: 'NotificationService');
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

  /// Check whether exact alarm scheduling is available on Android 12+.
  ///
  /// If the user hasn't granted [SCHEDULE_EXACT_ALARM] permission, returns
  /// [false].  Callers can use [requestExactAlarmPermission] to show a
  /// dialog guiding the user to the system settings page.
  Future<bool> canScheduleExactAlarms() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true; // non-Android — not applicable
    try {
      return await android.canScheduleExactNotifications() ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Show a dialog prompting the user to grant exact alarm permission.
  ///
  /// Must be called from a widget that has access to a [BuildContext].
  /// Returns [true] if the user was sent to settings (caller should
  /// re-check permission afterwards).
  Future<bool> requestExactAlarmPermission(BuildContext context) async {
    final canExact = await canScheduleExactAlarms();
    if (canExact) return true;
    if (!context.mounted) return false;

    final openSettings = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reliable reminders'),
        content: const Text(
          'To send reminder notifications at the exact time you choose, '
          'Danio needs permission to schedule alarms. This ensures your '
          'streak reminders and task notifications arrive on time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              _openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );

    return openSettings ?? false;
  }

  Future<void> _openAppSettings() async {
    // Use the plugin's built-in method when available, otherwise fall back.
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.requestExactAlarmsPermission();
    }
  }

  /// Schedule a notification for a task.
  Future<void> scheduleTaskReminder(Task task) async {
    await initialize();
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
    await initialize();
    await _plugin.cancel(taskId.hashCode);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  /// Show an immediate notification (for testing).
  Future<void> showTestNotification() async {
    await initialize();

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

  /// Map a notification payload to a tab index for tab navigation.
  ///
  /// Use from the tap handler (e.g. in main.dart) with:
  /// ```dart
  /// final tabIndex = NotificationService.payloadToTabIndex(payload);
  /// if (tabIndex != null) {
  ///   ref.read(currentTabProvider.notifier).state = tabIndex;
  /// }
  /// ```
  /// Returns null if the payload doesn't map to a specific tab.
  static int? payloadToTabIndex(String? payload) {
    switch (payload) {
      case 'home':
      case 'care':
      case 'water_change':
        return 0; // Home tab
      case 'learn':
      case 'review':
        return 1; // Learn tab
      case 'achievements':
        return 2; // Profile tab
      default:
        return null;
    }
  }

  /// Fallback: no-op. The primary handler is set via [onNotificationTap].
  static void _handleNotificationFallback(String payload) {
    // Intentionally empty — onNotificationTap in main.dart handles this.
  }

  /// Send notification for achievement unlock
  Future<void> sendAchievementNotification({
    required Achievement achievement,
    required int xpAwarded,
    required int gemsAwarded,
  }) async {
    await initialize();

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
    await initialize();

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
    await initialize();

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
    await initialize();

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
    await initialize();

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
    await initialize();
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
    await initialize();

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
    await initialize();

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
    await initialize();
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
    await initialize();

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
        now.year,
        now.month,
        now.day + daysUntilReminder,
        10,
        0,
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
    await initialize();
    await _plugin.cancel(_waterChangeNotificationId + tankIndex);
  }

  // ==================== ONBOARDING SEQUENCE (Dionysus Day 1-3) ====================

  /// Schedule the Day 1-3 onboarding notification sequence.
  ///
  /// Called once when the user completes onboarding. Schedules 4 time-based
  /// notifications across the first 3 days. The 5th notification (achievement
  /// celebration) is event-driven — see [showOnboardingAchievement].
  Future<void> scheduleOnboardingSequence() async {
    await initialize();

    final now = DateTime.now();
    final scheduleMode = await _resolveScheduleMode();

    // --- Day 1: Welcome (1 hour after onboarding) ---
    final welcomeTime = tz.TZDateTime.from(
      now.add(const Duration(hours: 1)),
      tz.local,
    );
    await _plugin.zonedSchedule(
      _onboardingWelcomeId,
      'Welcome to Danio 🐠',
      'Your fishkeeping journey starts here. Let\'s meet your fish.',
      welcomeTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'onboarding',
          'Onboarding',
          channelDescription: 'Welcome messages and early guidance',
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
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'home',
    );

    // --- Day 1: First Care Reminder (6 hours after onboarding) ---
    final careTime = tz.TZDateTime.from(
      now.add(const Duration(hours: 6)),
      tz.local,
    );
    await _plugin.zonedSchedule(
      _onboardingCareReminderId,
      'Time to check in on your tank',
      'A quick look goes a long way. Tap to log today\'s care.',
      careTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'onboarding',
          'Onboarding',
          channelDescription: 'Welcome messages and early guidance',
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
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'care',
    );

    // --- Day 2: Discovery Hook (next day at 9 AM) ---
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9, 0);
    final discoveryTime = tz.TZDateTime.from(tomorrow, tz.local);
    await _plugin.zonedSchedule(
      _onboardingDiscoveryHookId,
      'Did you know? 🐟',
      'Most aquarium fish can recognise their owner\'s face. Your fish know you — time to learn about them.',
      discoveryTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'onboarding',
          'Onboarding',
          channelDescription: 'Welcome messages and early guidance',
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
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'learn',
    );

    // --- Day 3: Streak Nudge (day after next at 9 AM) ---
    // Cancel this via cancelOnboardingStreakNudge() if the user completes a
    // lesson on Day 2.
    final dayAfterTomorrow = DateTime(now.year, now.month, now.day + 2, 9, 0);
    final streakNudgeTime = tz.TZDateTime.from(dayAfterTomorrow, tz.local);
    await _plugin.zonedSchedule(
      _onboardingStreakNudgeId,
      'Day 3 — you\'re building a habit 💪',
      'Two days in and counting. Today\'s lesson takes just 3 minutes.',
      streakNudgeTime,
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
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'learn',
    );

    // --- Day 7-28: Weekly cadence to bridge the Day 4-30 gap ---
    await scheduleWeeklyOnboardingCadence(scheduleMode);
  }

  /// Cancel the Day 3 streak nudge notification.
  ///
  /// Call this when the user completes a lesson on Day 2 so they don't receive
  /// the "you're building a habit" nudge unnecessarily.
  Future<void> cancelOnboardingStreakNudge() async {
    await initialize();
    await _plugin.cancel(_onboardingStreakNudgeId);
  }

  /// Show the Day 3 achievement celebration notification immediately.
  ///
  /// Call this when [lessonsCompleted] reaches 3 — it's event-driven, not
  /// time-scheduled.
  Future<void> showOnboardingAchievement() async {
    await initialize();

    await _plugin.show(
      _onboardingAchievementId,
      'Getting Consistent! 🏆',
      '3 lessons done. You\'re already ahead of most fishkeepers.',
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
      payload: 'learn',
    );
  }

  /// Cancel all onboarding sequence notifications.
  Future<void> cancelOnboardingSequence() async {
    await initialize();
    await _plugin.cancel(_onboardingWelcomeId);
    await _plugin.cancel(_onboardingCareReminderId);
    await _plugin.cancel(_onboardingDiscoveryHookId);
    await _plugin.cancel(_onboardingStreakNudgeId);
    await _plugin.cancel(_onboardingAchievementId);
    await _plugin.cancel(_weeklyTipDay7Id);
    await _plugin.cancel(_progressNudgeDay14Id);
    await _plugin.cancel(_discoveryHookDay21Id);
    await _plugin.cancel(_milestoneApproachDay28Id);
  }

  // ==================== WEEKLY ONBOARDING CADENCE (Day 7-28) ====================

  /// Random fishkeeping tips for the Day 7 weekly notification.
  static const _weeklyTips = [
    'Overfeeding is the #1 mistake new fishkeepers make. Feed only what they can eat in 2 minutes.',
    'A water change of 25% per week keeps your tank healthy. More is not always better!',
    'Most aquarium fish need 8-10 hours of light daily. Too much light causes algae blooms.',
    'Let your tank cycle for 4-6 weeks before adding fish. Patience saves lives.',
    'Dechlorinate your tap water before adding it to the tank — chlorine is toxic to fish.',
    'A heater with a thermostat is essential for tropical fish. Temperature swings cause stress.',
    'Test your water weekly: pH, ammonia, nitrite, and nitrate are the big four.',
    'Live plants absorb nitrates and provide hiding spots. They\'re great for any tank.',
  ];

  /// Schedule weekly notifications for Day 7, 14, 21, and 28 to bridge
  /// the gap between Day 3 onboarding sequence and Day 30 milestone.
  Future<void> scheduleWeeklyOnboardingCadence(
    AndroidScheduleMode scheduleMode,
  ) async {
    await initialize();

    final now = DateTime.now();
    final details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'onboarding',
        'Onboarding',
        channelDescription: 'Welcome messages and early guidance',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // --- Day 7: Weekly fishkeeping tip ---
    final day7 = DateTime(now.year, now.month, now.day + 7, 9, 0);
    final day7Tz = tz.TZDateTime.from(day7, tz.local);
    final tip = _weeklyTips[DateTime.now().millisecondsSinceEpoch % _weeklyTips.length];
    await _plugin.zonedSchedule(
      _weeklyTipDay7Id,
      '🐠 Your weekly fishkeeping tip',
      tip,
      day7Tz,
      details,
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'learn',
    );

    // --- Day 14: Progress nudge ---
    final day14 = DateTime(now.year, now.month, now.day + 14, 9, 0);
    final day14Tz = tz.TZDateTime.from(day14, tz.local);
    await _plugin.zonedSchedule(
      _progressNudgeDay14Id,
      'Two weeks in — great progress! 📊',
      'Have you logged any water tests this week? Regular testing keeps your fish healthy.',
      day14Tz,
      details,
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'care',
    );

    // --- Day 21: Discovery hook ---
    final day21 = DateTime(now.year, now.month, now.day + 21, 9, 0);
    final day21Tz = tz.TZDateTime.from(day21, tz.local);
    await _plugin.zonedSchedule(
      _discoveryHookDay21Id,
      'Discover something new 🧠',
      'There are 44 bite-sized lessons waiting for you. Even 3 minutes a day builds expertise!',
      day21Tz,
      details,
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'learn',
    );

    // --- Day 28: Milestone approach ---
    final day28 = DateTime(now.year, now.month, now.day + 28, 9, 0);
    final day28Tz = tz.TZDateTime.from(day28, tz.local);
    await _plugin.zonedSchedule(
      _milestoneApproachDay28Id,
      'Almost a month! 🎉',
      'Your fish are thriving — and so are you. You\'re becoming a real aquarist!',
      day28Tz,
      details,
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'learn',
    );
  }
}
