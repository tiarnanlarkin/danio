import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/models.dart';

// Notification IDs for streak reminders
const int _morningNotificationId = 1000;
const int _eveningNotificationId = 1001;
const int _nightNotificationId = 1002;

/// Service for managing local notifications for task reminders and streak reminders.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  
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

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

  /// Request notification permissions (iOS mainly).
  Future<bool> requestPermissions() async {
    // Android 13+ requires explicit permission
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
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
      '🐟 Task Due: ${task.title}',
      task.description ?? 'Time to complete this task!',
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
      '🐟 Aquarium App',
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

  /// Schedule notifications for all enabled tasks with due dates.
  Future<void> scheduleAllTaskReminders(List<Task> tasks) async {
    if (!_initialized) await initialize();

    // Cancel existing and reschedule
    await cancelAll();

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
      '🔥 Good morning!',
      'Start your $currentStreak-day streak with today\'s lesson',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription: 'Daily reminders to maintain your learning streak',
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
      '⏰ Keep your streak alive!',
      'Just $xpNeeded XP to keep your $currentStreak-day streak!',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription: 'Daily reminders to maintain your learning streak',
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
      '⚠️ Don\'t lose your streak!',
      'Only 5 minutes left to save your $currentStreak-day streak!',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription: 'Daily reminders to maintain your learning streak',
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
}
