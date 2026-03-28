// Widget tests for the data deletion flow in SettingsScreen.
//
// Coverage:
//   - "Delete My Data" tile exists and is visible
//   - Tapping it opens a confirmation AlertDialog
//   - Dialog shows "Delete Everything" and "Cancel" actions
//   - Tapping "Cancel" dismisses dialog without deletion
//   - Tapping "Delete Everything" proceeds with deletion flow
//     (SharedPreferences cleared, calls progress measured via UI state)
//
// Run:
//   flutter test test/screens/data_deletion_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/settings_screen.dart';
import 'package:danio/widgets/core/app_dialog.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: child),
  );
}

/// Scrolls down the settings list until "Delete My Data" is visible.
Future<void> _scrollToDeleteMyData(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Delete My Data'),
    500.0,
    scrollable: find.byType(Scrollable).first,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    // Minimal prefs — avoid setting 'theme_mode' as a String here since
    // SettingsProvider also reads int-typed keys from the same namespace,
    // and a type mismatch triggers a logged warning (not a failure).
    SharedPreferences.setMockInitialValues({});
  });

  group('Data Deletion Flow', () {
    testWidgets('Delete My Data tile is present in settings', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await _scrollToDeleteMyData(tester);

      expect(find.text('Delete My Data'), findsOneWidget);
    });

    testWidgets('Delete My Data tile subtitle is visible', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await _scrollToDeleteMyData(tester);

      expect(
        find.text('Erase all data & exercise your privacy rights'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Delete My Data shows confirmation dialog',
        (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await _scrollToDeleteMyData(tester);
      await tester.tap(find.text('Delete My Data'));
      await tester.pumpAndSettle();

      // Dialog title
      expect(find.text('Delete My Data'), findsWidgets);
      // At least one in the dialog title
      expect(
        find.descendant(
          of: find.byType(AppDialog),
          matching: find.text('Delete My Data'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('confirmation dialog contains warning text', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await _scrollToDeleteMyData(tester);
      await tester.tap(find.text('Delete My Data'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('permanently delete all your local data'),
        findsOneWidget,
      );
    });

    testWidgets('confirmation dialog has Delete Everything and Cancel buttons',
        (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await _scrollToDeleteMyData(tester);
      await tester.tap(find.text('Delete My Data'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Everything'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('tapping Cancel dismisses dialog without deleting',
        (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await _scrollToDeleteMyData(tester);
      await tester.tap(find.text('Delete My Data'));
      await tester.pumpAndSettle();

      // Dialog is present
      expect(find.byType(AppDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed
      expect(find.byType(AppDialog), findsNothing);
      // Settings screen still showing
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets(
        'dialog mentions email address for server-side data deletion',
        (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await _scrollToDeleteMyData(tester);
      await tester.tap(find.text('Delete My Data'));
      await tester.pumpAndSettle();

      // The dialog should mention the contact email per GDPR compliance
      expect(
        find.textContaining('larkintiarnanbizz@gmail.com'),
        findsOneWidget,
      );
    });

    testWidgets(
        'tapping Delete Everything triggers deletion '
        '(SharedPreferences cleared, dialog dismissed)',
        (tester) async {
      // Pre-seed some preferences to verify they get cleared.
      // Use int/bool types to avoid type-cast warnings from SettingsProvider.
      SharedPreferences.setMockInitialValues({
        'has_completed_onboarding': true,
        'haptic_feedback': true,
        'user_tanks_count': 3,
        'some_progress_key': 'some_value',
      });

      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await _scrollToDeleteMyData(tester);
      await tester.tap(find.text('Delete My Data'));
      await tester.pumpAndSettle();

      expect(find.byType(AppDialog), findsOneWidget);

      // Tap confirm — this triggers the deletion flow which calls:
      //   1. SharedPreferences.getInstance() + prefs.clear()
      //   2. File deletion (gracefully handled if files don't exist in test)
      //   3. OnboardingService.getInstance() + resetOnboarding()
      //   4. ref.invalidate(onboardingCompletedProvider)
      //   5. Navigator.popUntil(isFirst)
      await tester.tap(find.text('Delete Everything'));
      // Let async operations settle — use multiple pumps for async chains
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog should be gone after confirmation
      expect(find.byType(AppDialog), findsNothing);

      // Verify SharedPreferences was cleared
      final prefs = await SharedPreferences.getInstance();
      // After deletion, the pref we seeded should be gone
      expect(prefs.getString('some_progress_key'), isNull);
      expect(prefs.getInt('user_tanks_count'), isNull);
    });
  });

  group('Clear All Data tile (separate from Delete My Data)', () {
    testWidgets('Clear All Data tile is also present', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Clear All Data'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Clear All Data'), findsOneWidget);
    });

    testWidgets('Clear All Data subtitle is visible', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Clear All Data'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.text('Delete all tanks, logs, and settings'),
        findsOneWidget,
      );
    });
  });
}
