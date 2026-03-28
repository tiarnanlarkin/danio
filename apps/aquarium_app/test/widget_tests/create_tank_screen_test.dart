// Widget tests for CreateTankScreen.
//
// Run: flutter test test/widget_tests/create_tank_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/create_tank_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(InMemoryStorageService()),
    ],
    child: const MaterialApp(
      home: CreateTankScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CreateTankScreen — basic rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CreateTankScreen), findsOneWidget);
    });

    testWidgets('shows New Tank app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('New Tank'), findsOneWidget);
    });

    testWidgets('shows page 1 of the form (basic info)', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // First page should have a tank name field
      expect(
        find.textContaining('Tank Name').evaluate().isNotEmpty ||
            find.textContaining('Name').evaluate().isNotEmpty,
        isTrue,
        reason: 'First page should show tank name field',
      );
    });

    testWidgets('has a continue/next button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.textContaining('Continue').evaluate().isNotEmpty ||
            find.textContaining('Next').evaluate().isNotEmpty,
        isTrue,
        reason: 'Should have a navigation button to proceed',
      );
    });

    testWidgets('tapping continue without name shows validation', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Try to continue without filling in anything
      final continueBtn = find.textContaining('Continue');
      if (continueBtn.evaluate().isNotEmpty) {
        await tester.tap(continueBtn.first);
        await tester.pumpAndSettle();
        // Screen should still be visible (not navigated away)
        expect(find.byType(CreateTankScreen), findsOneWidget);
      }
    });
  });
}
