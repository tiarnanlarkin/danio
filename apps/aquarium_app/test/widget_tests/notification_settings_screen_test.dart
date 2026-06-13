// Widget tests for NotificationSettingsScreen.
//
// Run: flutter test test/widget_tests/notification_settings_screen_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/notification_settings_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/notification_scheduler.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/user_profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

UserProfile _fakeProfile({
  bool streakRemindersEnabled = false,
  bool reviewRemindersEnabled = false,
}) => UserProfile(
  id: 'u1',
  name: 'Test User',
  streakRemindersEnabled: streakRemindersEnabled,
  reviewRemindersEnabled: reviewRemindersEnabled,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

class _FakeReminderNotificationService implements ReminderNotificationService {
  @override
  Future<void> cancelReviewReminder() async {}

  @override
  Future<void> cancelStreakNotifications() async {}

  @override
  Future<void> scheduleAllStreakNotifications({
    required int currentStreak,
    required int dailyXpGoal,
    required int todayXp,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    TimeOfDay? nightTime,
  }) async {}

  @override
  Future<void> scheduleReviewReminder({
    required int dueCardsCount,
    TimeOfDay? time,
  }) async {}
}

Widget _wrap({UserProfile? profile}) {
  final memStorage = InMemoryStorageService();
  // Pre-load profile into SharedPreferences so the notifier can read it
  SharedPreferences.setMockInitialValues({
    'user_profile': jsonEncode((profile ?? _fakeProfile()).toJson()),
  });
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      notificationServiceProvider.overrideWithValue(
        _FakeReminderNotificationService(),
      ),
    ],
    child: const MaterialApp(home: NotificationSettingsScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(seconds: 1));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NotificationSettingsScreen', () {
    testWidgets('renders without throwing', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(NotificationSettingsScreen), findsOneWidget);
    });

    testWidgets('shows Notification Settings title in AppBar', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Notification Settings'), findsOneWidget);
    });

    testWidgets('shows reminder toggles', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Streak Reminders'), findsWidgets);
      expect(find.text('Review Reminders'), findsOneWidget);
    });

    testWidgets('shows a SwitchListTile for reminders toggle', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets('renders with reminders enabled profile', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        _wrap(
          profile: _fakeProfile(
            streakRemindersEnabled: true,
            reviewRemindersEnabled: true,
          ),
        ),
      );
      await _advance(tester);
      expect(find.byType(NotificationSettingsScreen), findsOneWidget);
      expect(find.text('Reminder Times'), findsOneWidget);
    });

    testWidgets('reminder intensity can quiet all reminder nudges', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        _wrap(
          profile: _fakeProfile(
            streakRemindersEnabled: true,
            reviewRemindersEnabled: true,
          ),
        ),
      );
      await _advance(tester);

      expect(find.text('Reminder Intensity'), findsOneWidget);
      expect(
        find.text('Full support - reviews and daily habit nudges'),
        findsOneWidget,
      );

      await tester.tap(find.text('Reminder Intensity'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Reminder Intensity'), findsOneWidget);
      await tester.tap(find.text('Quiet'));
      await tester.pumpAndSettle();

      expect(find.text('Quiet - no review or streak nudges'), findsOneWidget);

      final reviewToggle = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Review Reminders'),
      );
      final streakToggle = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Streak Reminders'),
      );
      expect(reviewToggle.value, isFalse);
      expect(streakToggle.value, isFalse);
    });
  });
}
