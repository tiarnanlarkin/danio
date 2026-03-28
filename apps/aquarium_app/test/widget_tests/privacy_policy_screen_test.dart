// Widget tests for PrivacyPolicyScreen.
//
// Run: flutter test test/widget_tests/privacy_policy_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/privacy_policy_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: PrivacyPolicyScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PrivacyPolicyScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    });

    testWidgets('shows Privacy Policy app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Privacy Policy'), findsWidgets);
    });

    testWidgets('shows Your Privacy Matters heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Your Privacy Matters'), findsOneWidget);
    });

    testWidgets('shows shield icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('shows transparency subtitle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.textContaining('Transparency'),
        findsOneWidget,
      );
    });

    testWidgets('shows Summary section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Summary'), findsOneWidget);
    });

    testWidgets('shows open in new icon button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    });
  });

  group('PrivacyPolicyScreen — policy content', () {
    testWidgets('contains Introduction section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Scroll to find content
      expect(find.text('1. Introduction'), findsOneWidget);
    });

    testWidgets('mentions Firebase Analytics', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.textContaining('Firebase Analytics'),
        findsWidgets,
      );
    });
  });
}
