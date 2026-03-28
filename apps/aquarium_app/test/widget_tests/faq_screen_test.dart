// Widget tests for FaqScreen.
//
// Run: flutter test test/widget_tests/faq_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/faq_screen.dart';

Widget _wrap() => const MaterialApp(home: FaqScreen());

void main() {
  group('FaqScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(FaqScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('FAQ'), findsOneWidget);
    });

    testWidgets('shows Getting Started section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Getting Started'), findsOneWidget);
    });

    testWidgets('shows first FAQ question about cycling', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.text('How long should I wait before adding fish?'),
        findsOneWidget,
      );
    });

    testWidgets('shows Water Quality section by scrolling', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Water Quality'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('Water Quality'), findsOneWidget);
    });
  });
}
