import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_scheduler.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/logger.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/core/app_list_tile.dart';
import '../notification_settings_screen.dart';
import '../../utils/navigation_throttle.dart';

/// Notifications section for the settings screen.
/// Contains the toggle, streak-reminder link, and test button.
class SettingsNotificationsSection extends ConsumerWidget {
  const SettingsNotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NavListTile(
          icon: Icons.notifications_active,
          title: 'Reminder Settings',
          subtitle: 'Choose review and streak reminders',
          onTap: () => NavigationThrottle.push(
            context,
            const NotificationSettingsScreen(),
          ),
        ),
        const _NotificationsToggle(),
      ],
    );
  }
}

/// Notifications enabled toggle + optional test button.
class _NotificationsToggle extends ConsumerWidget {
  const _NotificationsToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(
      settingsProvider.select((s) => s.notificationsEnabled),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Phone Notifications'),
          subtitle: Text(
            notificationsEnabled
                ? 'Allowed for reminders you turn on'
                : 'Allow notification permission for reminders',
          ),
          value: notificationsEnabled,
          onChanged: (value) => _toggleNotifications(context, ref, value),
        ),
        AppListTile(
          leading: const SizedBox(width: AppSpacing.lg),
          title: 'Test Notification',
          subtitle: notificationsEnabled
              ? 'Send a test notification'
              : 'Enable Phone Notifications to send a test notification',
          isDisabled: !notificationsEnabled,
          onTap: notificationsEnabled ? () => _testNotification(context) : null,
        ),
      ],
    );
  }
}

Future<void> _toggleNotifications(
  BuildContext context,
  WidgetRef ref,
  bool enable,
) async {
  if (enable) {
    final service = NotificationService();
    await service.initialize();
    final granted = await service.requestPermissions();

    if (!granted) {
      if (context.mounted) {
        AppFeedback.showWarning(context, 'Notification permission denied');
      }
      return;
    }
  }

  final saved = await ref
      .read(settingsProvider.notifier)
      .setNotificationsEnabled(enable);
  if (!saved) {
    if (context.mounted) {
      AppFeedback.showError(
        context,
        'Couldn\'t update phone notifications. Try again.',
      );
    }
    return;
  }

  if (!enable) {
    final service = ref.read(notificationServiceProvider);
    await service.cancelReviewReminder();
    await service.cancelStreakNotifications();
  }

  if (context.mounted) {
    if (enable) {
      AppFeedback.showSuccess(context, 'Phone notifications enabled');
    } else {
      AppFeedback.showInfo(context, 'Phone notifications disabled');
    }
  }
}

Future<void> _testNotification(BuildContext context) async {
  try {
    final service = NotificationService();
    await service.initialize();
    await service.showTestNotification();

    if (context.mounted) {
      AppFeedback.showSuccess(context, 'Test notification sent!');
    }
  } catch (e, st) {
    logError(
      'SettingsNotificationsSection: test notification failed: $e',
      stackTrace: st,
      tag: 'SettingsNotificationsSection',
    );
    if (context.mounted) {
      AppFeedback.showError(
        context,
        'Couldn\'t send test notification. Give it another go!',
      );
    }
  }
}
