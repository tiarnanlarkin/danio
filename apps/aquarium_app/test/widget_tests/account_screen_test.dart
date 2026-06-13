// Widget tests for AccountScreen.
//
// Run: flutter test test/widget_tests/account_screen_test.dart
//
// When SupabaseService is not initialised (test environment default),
// AccountScreen shows the offline-only message view.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/account_screen.dart';
import 'package:danio/providers/user_profile_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
    ],
    child: const MaterialApp(home: AccountScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AccountScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(AccountScreen), findsOneWidget);
    });

    testWidgets('shows Offline Data app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Offline Data'), findsOneWidget);
    });

    testWidgets('shows local data status when Supabase uninitialised', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Offline data is active'), findsOneWidget);
    });

    testWidgets('shows local storage explanation text', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('storing your tanks'), findsOneWidget);
    });

    testWidgets('points offline users to More for portable backups', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(
        find.textContaining('Use Backup & Restore from More'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Use Backup & Restore from Preferences'),
        findsNothing,
      );
    });

    testWidgets('shows cloud_off icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('account danger zone exposes cloud account deletion action', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AccountDangerZone(onDeleteAccount: () {})),
        ),
      );

      expect(find.text('Danger Zone'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    test('Google sign-in does not use the generic g_mobiledata icon', () {
      final source = File('lib/screens/account_screen.dart').readAsStringSync();

      expect(source, isNot(contains('Icons.g_mobiledata')));
      expect(source, contains('GoogleSignInMark'));
    });

    test('optional account copy does not promise background sync', () {
      final source = File('lib/screens/account_screen.dart').readAsStringSync();
      const oldSyncPromise =
          'Sync your aquarium data across'
          ' devices';
      const oldUploadCopy =
          'Encrypt & upload'
          ' to cloud';
      const oldRestoreCopy =
          'Download & decrypt'
          ' from cloud';
      const oldSignOutCopy = 'resume syncing';
      const oldSyncedDataCopy = 'synced cloud data';

      expect(source, isNot(contains(oldSyncPromise)));
      expect(source, isNot(contains(oldUploadCopy)));
      expect(source, isNot(contains(oldRestoreCopy)));
      expect(source, isNot(contains(oldSignOutCopy)));
      expect(source, isNot(contains(oldSyncedDataCopy)));
      expect(source, contains('Optional cloud backup'));
      expect(source, contains('Local use still works without an account'));
      expect(source, contains('use cloud backup again'));
      expect(source, contains('cloud-stored account data'));
    });
  });
}
