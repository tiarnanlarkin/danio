import 'package:flutter/material.dart';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';

/// Screen for configuring streak reminder notifications
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: profileAsync.when(
        loading: () => const Center(child: BubbleLoader()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }

          // Build item list based on whether reminders are enabled
          final baseItems = 3; // Header, divider, main toggle
          final additionalItems = profile.streakRemindersEnabled ? 10 : 0; // Divider, section header, 3 time settings, divider, info, test button, spacing
          final totalItems = baseItems + additionalItems;

          return ListView.builder(
            itemCount: totalItems,
            itemBuilder: (context, index) {
              // Header
              if (index == 0) {
                return Padding(
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
                      Text(
                        'Streak Reminders',
                        style: AppTypography.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Get daily notifications to help maintain your learning streak.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Divider
              if (index == 1) {
                return const Divider();
              }

              // Main toggle
              if (index == 2) {
                return SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Streak Reminders'),
                  subtitle: Text(
                    profile.streakRemindersEnabled
                        ? 'Enabled - You\'ll get daily reminders'
                        : 'Disabled - No streak reminders',
                  ),
                  value: profile.streakRemindersEnabled,
                  onChanged: (value) async {
                    if (value) {
                      // Request permission when enabling
                      final service = NotificationService();
                      await service.initialize();
                      final granted = await service.requestPermissions();

                      if (!granted) {
                        if (context.mounted) {
                          AppFeedback.showWarning(
                            context,
                            'Notification permission denied. Please enable in settings.',
                          );
                        }
                        return;
                      }
                    }

                    await ref
                        .read(userProfileProvider.notifier)
                        .updateProfile(streakRemindersEnabled: value);

                    // Reschedule notifications
                    await _updateNotifications(ref);

                    if (context.mounted) {
                      if (value) {
                        AppFeedback.showSuccess(
                          context,
                          'Streak reminders enabled!',
                        );
                      } else {
                        AppFeedback.showInfo(
                          context,
                          'Streak reminders disabled',
                        );
                      }
                    }
                  },
                );
              }

              // If reminders disabled, we're done
              if (!profile.streakRemindersEnabled) {
                return const SizedBox.shrink();
              }

              // Additional items when enabled
              final enabledIndex = index - baseItems;

              // Divider
              if (enabledIndex == 0) {
                return const Divider();
              }

              // Notification times section header
              if (enabledIndex == 1) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Reminder Times',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              // Morning notification
              if (enabledIndex == 2) {
                return ListTile(
                  leading: const Icon(Icons.wb_sunny),
                  title: const Text('Morning Reminder'),
                  subtitle: Text(
                    '${profile.morningReminderTime} - Start your day with a lesson',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(
                    context,
                    ref,
                    'Morning Reminder',
                    profile.morningReminderTime ?? '09:00',
                    'morningReminderTime',
                  ),
                );
              }

              // Evening notification
              if (enabledIndex == 3) {
                return ListTile(
                  leading: const Icon(Icons.wb_twilight),
                  title: const Text('Evening Reminder'),
                  subtitle: Text(
                    '${profile.eveningReminderTime} - Only if you haven\'t met your goal',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(
                    context,
                    ref,
                    'Evening Reminder',
                    profile.eveningReminderTime ?? '19:00',
                    'eveningReminderTime',
                  ),
                );
              }

              // Night notification
              if (enabledIndex == 4) {
                return ListTile(
                  leading: const Icon(Icons.nightlight),
                  title: const Text('Late Night Reminder'),
                  subtitle: Text(
                    '${profile.nightReminderTime} - Last chance to save your streak',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(
                    context,
                    ref,
                    'Late Night Reminder',
                    profile.nightReminderTime ?? '23:00',
                    'nightReminderTime',
                  ),
                );
              }

              // Divider
              if (enabledIndex == 5) {
                return const Divider();
              }

              // Info section
              if (enabledIndex == 6) {
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
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          '🌅',
                          'Morning reminder goes out every day',
                        ),
                        _buildInfoRow(
                          '🌆',
                          'Evening reminder only if goal not met',
                        ),
                        _buildInfoRow(
                          '🌙',
                          'Night reminder only if goal not met',
                        ),
                        _buildInfoRow(
                          '✅',
                          'Notifications auto-cancel when you complete your goal',
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Test notification button
              if (enabledIndex == 7) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Send Test Notification'),
                    onPressed: () async {
                      final service = NotificationService();
                      await service.initialize();
                      await service.showTestNotification();

                      if (context.mounted) {
                        AppFeedback.showSuccess(
                          context,
                          'Test notification sent!',
                        );
                      }
                    },
                  ),
                );
              }

              // Final spacing
              return const SizedBox(height: AppSpacing.md);
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    WidgetRef ref,
    String title,
    String currentTime,
    String fieldName,
  ) async {
    final parts = currentTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
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

    // Update the appropriate field
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

    // Reschedule notifications
    await _updateNotifications(ref);

    if (context.mounted) {
      AppFeedback.showInfo(context, '$title updated to $timeString');
    }
  }

  Future<void> _updateNotifications(WidgetRef ref) async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) return;

    final service = NotificationService();
    await service.initialize();

    if (!profile.streakRemindersEnabled) {
      // Cancel all streak notifications
      await service.cancelStreakNotifications();
      return;
    }

    // Parse times
    final morningParts = (profile.morningReminderTime ?? '09:00').split(':');
    final eveningParts = (profile.eveningReminderTime ?? '19:00').split(':');
    final nightParts = (profile.nightReminderTime ?? '23:00').split(':');

    final morningTime = TimeOfDay(
      hour: int.parse(morningParts[0]),
      minute: int.parse(morningParts[1]),
    );
    final eveningTime = TimeOfDay(
      hour: int.parse(eveningParts[0]),
      minute: int.parse(eveningParts[1]),
    );
    final nightTime = TimeOfDay(
      hour: int.parse(nightParts[0]),
      minute: int.parse(nightParts[1]),
    );

    // Get today's XP
    final todayXp = ref.read(userProfileProvider.notifier).getTodayXp();

    // Schedule notifications
    await service.scheduleAllStreakNotifications(
      currentStreak: profile.currentStreak,
      dailyXpGoal: profile.dailyXpGoal,
      todayXp: todayXp,
      morningTime: morningTime,
      eveningTime: eveningTime,
      nightTime: nightTime,
    );
  }
}
