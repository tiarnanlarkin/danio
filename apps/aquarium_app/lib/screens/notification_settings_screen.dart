import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../providers/settings_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/notification_scheduler.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/core/app_states.dart';
import '../widgets/core/app_list_tile.dart';
import '../widgets/core/bubble_loader.dart';

/// Screen for configuring explicit opt-in reminder notifications.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: profileAsync.when(
        loading: () => const Center(child: BubbleLoader()),
        error: (e, _) => AppErrorState(
          title: 'Couldn\'t load your settings',
          message: 'Give it another try!',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }

          return ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + AppSpacing.lg,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      size: AppIconSizes.xl,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Reminders', style: AppTypography.headlineMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Danio only schedules phone reminders you turn on here.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              AppListTile(
                leading: const Icon(Icons.tune_outlined),
                title: 'Reminder Intensity',
                subtitle: _reminderIntensityFor(profile).subtitle,
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _showReminderIntensityPicker(context, ref, profile),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.repeat_rounded),
                title: const Text('Review Reminders'),
                subtitle: Text(
                  profile.reviewRemindersEnabled
                      ? 'Enabled - reminders when cards are due'
                      : 'Disabled - no review reminders',
                ),
                value: profile.reviewRemindersEnabled,
                onChanged: (value) => _setReviewReminders(context, ref, value),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.local_fire_department_outlined),
                title: const Text('Streak Reminders'),
                subtitle: Text(
                  profile.streakRemindersEnabled
                      ? 'Enabled - daily streak reminders'
                      : 'Disabled - no streak reminders',
                ),
                value: profile.streakRemindersEnabled,
                onChanged: (value) => _setStreakReminders(context, ref, value),
              ),
              if (profile.streakRemindersEnabled) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'Reminder Times',
                    style: AppTypography.labelLarge.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
                _timeTile(
                  context,
                  ref,
                  icon: Icons.wb_sunny,
                  title: 'Morning Reminder',
                  subtitle:
                      '${profile.morningReminderTime ?? '09:00'} - Start your day with a lesson',
                  currentTime: profile.morningReminderTime ?? '09:00',
                  fieldName: 'morningReminderTime',
                ),
                _timeTile(
                  context,
                  ref,
                  icon: Icons.wb_twilight,
                  title: 'Evening Reminder',
                  subtitle:
                      '${profile.eveningReminderTime ?? '19:00'} - Only if you haven\'t met your goal',
                  currentTime: profile.eveningReminderTime ?? '19:00',
                  fieldName: 'eveningReminderTime',
                ),
                _timeTile(
                  context,
                  ref,
                  icon: Icons.nightlight,
                  title: 'Late Night Reminder',
                  subtitle:
                      '${profile.nightReminderTime ?? '23:00'} - Last chance to save your streak',
                  currentTime: profile.nightReminderTime ?? '23:00',
                  fieldName: 'nightReminderTime',
                ),
                const Divider(),
                _infoPanel(context),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Send Test Notification'),
                    onPressed: () => _sendTestNotification(context),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showReminderIntensityPicker(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    final current = _reminderIntensityFor(profile);

    showAppDragSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Text(
                    'Choose Reminder Intensity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Pick how much Danio should nudge you. You can still fine-tune review and streak reminders below.',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            for (final intensity in _ReminderIntensity.values)
              AppListTile(
                leading: Icon(intensity.icon),
                title: intensity.title,
                subtitle: intensity.description,
                isSelected: intensity == current,
                trailing: intensity == current
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  final applied = await _setReminderIntensity(
                    context,
                    ref,
                    intensity,
                  );
                  if (applied && sheetContext.mounted) {
                    Navigator.maybePop(sheetContext);
                  }
                },
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _timeTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String currentTime,
    required String fieldName,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.access_time),
      onTap: () => _selectTime(context, ref, title, currentTime, fieldName),
    );
  }

  Widget _infoPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppOverlays.primary10,
          borderRadius: AppRadius.mediumRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'How it works',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm2),
            _buildInfoRow('Morning reminder goes out every day'),
            _buildInfoRow('Evening reminder only if your goal is not met'),
            _buildInfoRow('Night reminder only if your goal is not met'),
            _buildInfoRow('Disabling a reminder cancels its scheduled alerts'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }

  Future<void> _setReviewReminders(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    if (value && !await _ensureNotificationsEnabled(context, ref)) return;

    await ref
        .read(userProfileProvider.notifier)
        .updateProfile(reviewRemindersEnabled: value);
    await NotificationScheduler.instance.scheduleReviewNotifications(ref);

    if (!context.mounted) return;
    AppFeedback.showInfo(
      context,
      value ? 'Review reminders enabled' : 'Review reminders disabled',
    );
  }

  Future<void> _setStreakReminders(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    if (value && !await _ensureNotificationsEnabled(context, ref)) return;

    await ref
        .read(userProfileProvider.notifier)
        .updateProfile(streakRemindersEnabled: value);
    await NotificationScheduler.instance.scheduleStreakNotifications(ref);

    if (!context.mounted) return;
    AppFeedback.showInfo(
      context,
      value ? 'Streak reminders enabled' : 'Streak reminders disabled',
    );
  }

  Future<bool> _setReminderIntensity(
    BuildContext context,
    WidgetRef ref,
    _ReminderIntensity intensity,
  ) async {
    if (intensity.needsPhoneNotifications &&
        !await _ensureNotificationsEnabled(context, ref)) {
      return false;
    }

    await ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          reviewRemindersEnabled: intensity.reviewRemindersEnabled,
          streakRemindersEnabled: intensity.streakRemindersEnabled,
        );
    await NotificationScheduler.instance.scheduleReviewNotifications(ref);
    await NotificationScheduler.instance.scheduleStreakNotifications(ref);

    if (context.mounted) {
      AppFeedback.showInfo(context, '${intensity.title} reminders selected');
    }
    return true;
  }

  Future<bool> _ensureNotificationsEnabled(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (ref.read(settingsProvider).notificationsEnabled) return true;

    final service = NotificationService();
    await service.initialize();
    final granted = await service.requestPermissions();
    if (!granted) {
      if (context.mounted) {
        AppFeedback.showWarning(
          context,
          'Notification permission denied. Please enable it in settings.',
        );
      }
      return false;
    }

    await ref.read(settingsProvider.notifier).setNotificationsEnabled(true);
    return true;
  }

  Future<void> _selectTime(
    BuildContext context,
    WidgetRef ref,
    String title,
    String currentTime,
    String fieldName,
  ) async {
    final parts = currentTime.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 9;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: hour.clamp(0, 23),
        minute: minute.clamp(0, 59),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    await ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          morningReminderTime: fieldName == 'morningReminderTime'
              ? timeString
              : null,
          eveningReminderTime: fieldName == 'eveningReminderTime'
              ? timeString
              : null,
          nightReminderTime: fieldName == 'nightReminderTime'
              ? timeString
              : null,
        );

    await NotificationScheduler.instance.scheduleStreakNotifications(ref);

    if (context.mounted) {
      AppFeedback.showInfo(context, '$title updated to $timeString');
    }
  }

  Future<void> _sendTestNotification(BuildContext context) async {
    final service = NotificationService();
    await service.initialize();
    await service.showTestNotification();

    if (context.mounted) {
      AppFeedback.showSuccess(context, 'Test notification sent!');
    }
  }
}

enum _ReminderIntensity { quiet, reviewOnly, dailyHabit, fullSupport }

_ReminderIntensity _reminderIntensityFor(UserProfile profile) {
  if (profile.reviewRemindersEnabled && profile.streakRemindersEnabled) {
    return _ReminderIntensity.fullSupport;
  }
  if (profile.reviewRemindersEnabled) {
    return _ReminderIntensity.reviewOnly;
  }
  if (profile.streakRemindersEnabled) {
    return _ReminderIntensity.dailyHabit;
  }
  return _ReminderIntensity.quiet;
}

extension _ReminderIntensityDetails on _ReminderIntensity {
  String get title {
    switch (this) {
      case _ReminderIntensity.quiet:
        return 'Quiet';
      case _ReminderIntensity.reviewOnly:
        return 'Review only';
      case _ReminderIntensity.dailyHabit:
        return 'Daily habit';
      case _ReminderIntensity.fullSupport:
        return 'Full support';
    }
  }

  String get subtitle {
    switch (this) {
      case _ReminderIntensity.quiet:
        return 'Quiet - no review or streak nudges';
      case _ReminderIntensity.reviewOnly:
        return 'Review only - due-card reminders';
      case _ReminderIntensity.dailyHabit:
        return 'Daily habit - streak and goal nudges';
      case _ReminderIntensity.fullSupport:
        return 'Full support - reviews and daily habit nudges';
    }
  }

  String get description {
    switch (this) {
      case _ReminderIntensity.quiet:
        return 'No review or streak phone nudges.';
      case _ReminderIntensity.reviewOnly:
        return 'A reminder when review cards are due.';
      case _ReminderIntensity.dailyHabit:
        return 'Daily streak and goal reminders only.';
      case _ReminderIntensity.fullSupport:
        return 'Review reminders plus daily streak and goal nudges.';
    }
  }

  IconData get icon {
    switch (this) {
      case _ReminderIntensity.quiet:
        return Icons.notifications_off_outlined;
      case _ReminderIntensity.reviewOnly:
        return Icons.repeat_rounded;
      case _ReminderIntensity.dailyHabit:
        return Icons.local_fire_department_outlined;
      case _ReminderIntensity.fullSupport:
        return Icons.notifications_active_outlined;
    }
  }

  bool get reviewRemindersEnabled {
    switch (this) {
      case _ReminderIntensity.quiet:
      case _ReminderIntensity.dailyHabit:
        return false;
      case _ReminderIntensity.reviewOnly:
      case _ReminderIntensity.fullSupport:
        return true;
    }
  }

  bool get streakRemindersEnabled {
    switch (this) {
      case _ReminderIntensity.quiet:
      case _ReminderIntensity.reviewOnly:
        return false;
      case _ReminderIntensity.dailyHabit:
      case _ReminderIntensity.fullSupport:
        return true;
    }
  }

  bool get needsPhoneNotifications =>
      reviewRemindersEnabled || streakRemindersEnabled;
}
