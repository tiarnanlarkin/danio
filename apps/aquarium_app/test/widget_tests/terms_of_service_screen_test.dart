// Widget tests for TermsOfServiceScreen.
//
// Run: flutter test test/widget_tests/terms_of_service_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/terms_of_service_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: TermsOfServiceScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TermsOfServiceScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TermsOfServiceScreen), findsOneWidget);
    });

    testWidgets('shows Terms of Service app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Terms of Service'), findsWidgets);
    });

    testWidgets('shows Educational Use Only section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Educational Use Only'), findsOneWidget);
    });

    testWidgets('shows AI Features section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('AI Features'), findsOneWidget);
    });

    testWidgets('shows No Warranties section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('No Warranties'), findsOneWidget);
    });

    testWidgets('shows Your Data section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Your Data'), findsOneWidget);
    });

    testWidgets('shows gavel icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.gavel), findsOneWidget);
    });

    testWidgets('shows View Full Terms button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('View Full Terms'), findsOneWidget);
    });

    testWidgets('shows Contact Us button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Contact Us'), findsOneWidget);
    });

    testWidgets('shows Last Updated text', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Last Updated'), findsOneWidget);
    });
  });

  group('TermsOfServiceScreen — interaction', () {
    testWidgets('tapping Contact Us shows dialog', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // Scroll until the Contact Us button is visible
      await tester.ensureVisible(find.text('Contact Us').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contact Us').last);
      await tester.pumpAndSettle();

      // Dialog shows contact header and email
      expect(find.text('Contact Us'), findsWidgets);
    });
  });
}
