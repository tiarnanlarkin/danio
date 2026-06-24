// Widget tests for TermsOfServiceScreen.
//
// Run: flutter test test/widget_tests/terms_of_service_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/terms_of_service_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() => const MaterialApp(home: TermsOfServiceScreen());

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TermsOfServiceScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(TermsOfServiceScreen), findsOneWidget);
    });

    testWidgets('shows Terms of Service app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Terms of Service'), findsWidgets);
    });

    testWidgets('shows Educational Use Only section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Educational Use Only'), findsOneWidget);
    });

    testWidgets('shows scrollable content', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('tablet centers terms content in a readable rail', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(
        tester.getTopLeft(find.text('Educational Use Only')).dx,
        greaterThan(700),
      );
    });

    testWidgets('shows View Full Terms button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('View Full Terms'), findsOneWidget);
    });
  });
}
