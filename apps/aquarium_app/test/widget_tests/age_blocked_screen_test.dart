// Widget tests for AgeBlockedScreen (COPPA compliance).
//
// Verifies the age-block hard-lock screen renders correctly,
// shows the privacy policy link, and has no back-navigation AppBar.
//
// Run: flutter test test/widget_tests/age_blocked_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/onboarding/age_blocked_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: AgeBlockedScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AgeBlockedScreen — COPPA compliance', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(AgeBlockedScreen), findsOneWidget);
    });

    testWidgets('shows age requirement text', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Age Requirement'), findsOneWidget);
    });

    testWidgets('shows under-13 message explaining requirement', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Should explain that user needs to be 13 or older
      expect(
        find.textContaining('13'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('shows Privacy Policy link', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Privacy Policy'), findsOneWidget);
    });

    testWidgets('Privacy Policy is a TextButton (tappable link)', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('has no AppBar — no back navigation possible', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // No AppBar means no back button
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('has no leading back arrow in navigation', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // BackButton widget should not be present
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('shows lock icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('rendered inside a Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('text is centered', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Should have center-aligned text — Column with mainAxisAlignment center
      final columns = tester.widgetList<Column>(find.byType(Column));
      final hasCenteredColumn = columns.any(
        (col) => col.mainAxisAlignment == MainAxisAlignment.center,
      );
      expect(hasCenteredColumn, isTrue);
    });
  });
}
