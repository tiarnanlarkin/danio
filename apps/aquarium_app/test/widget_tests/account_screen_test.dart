// Widget tests for AccountScreen.
//
// Run: flutter test test/widget_tests/account_screen_test.dart
//
// When SupabaseService is not initialised (test environment default),
// AccountScreen shows the offline-only message view.

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

    testWidgets('shows Account app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('shows Cloud Not Configured when Supabase uninitialised',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Cloud Not Configured'), findsOneWidget);
    });

    testWidgets('shows offline-only explanation text', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(
        find.textContaining('offline-only mode'),
        findsOneWidget,
      );
    });

    testWidgets('shows cloud_off icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });
  });
}
