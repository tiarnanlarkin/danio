import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
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
          title: 'Streak Reminders',
          subtitle: 'Daily notifications to maintain your streak',
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
          title: const Text('Task Reminders'),
          subtitle: const Text('Get notified when tasks are due'),
          value: notificationsEnabled,
          onChanged: (value) =>
              _toggleNotifications(context, ref, value),
        ),
        if (notificationsEnabled)
          AppListTile(
            leading: const SizedBox(width: AppSpacing.lg),
            title: 'Test Notification',
            subtitle: 'Send a test notification',
            onTap: () => _testNotification(context),
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

  await ref
      .read(settingsProvider.notifier)
      .setNotificationsEnabled(enable);

  if (context.mounted) {
    if (enable) {
      AppFeedback.showSuccess(context, 'Notifications enabled!');
    } else {
      AppFeedback.showInfo(context, 'Notifications disabled');
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
  } catch (e) {
    if (context.mounted) {
      AppFeedback.showError(
        context,
        'Couldn\'t send test notification. Give it another go!',
      );
    }
  }
}
