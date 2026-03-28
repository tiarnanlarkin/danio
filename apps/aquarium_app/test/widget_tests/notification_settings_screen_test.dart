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
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/user_profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

UserProfile _fakeProfile({bool remindersEnabled = false}) => UserProfile(
      id: 'u1',
      name: 'Test User',
      streakRemindersEnabled: remindersEnabled,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

Widget _wrap({UserProfile? profile}) {
  final memStorage = InMemoryStorageService();
  // Pre-load profile into SharedPreferences so the notifier can read it
  SharedPreferences.setMockInitialValues({
    'user_profile': jsonEncode((profile ?? _fakeProfile()).toJson()),
  });
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
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

    testWidgets('shows Streak Reminders header', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Streak Reminders'), findsWidgets);
    });

    testWidgets('shows a SwitchListTile for reminders toggle', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets('renders with reminders enabled profile', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_wrap(profile: _fakeProfile(remindersEnabled: true)));
      await _advance(tester);
      expect(find.byType(NotificationSettingsScreen), findsOneWidget);
    });
  });
}
