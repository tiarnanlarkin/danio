// Widget tests for TroubleshootingScreen.
//
// Run: flutter test test/widget_tests/troubleshooting_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/troubleshooting_screen.dart';

Widget _wrap() => const MaterialApp(home: TroubleshootingScreen());

void main() {
  group('TroubleshootingScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(TroubleshootingScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Troubleshooting'), findsOneWidget);
    });

    testWidgets('shows Common Problems & Solutions heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Common Problems & Solutions'), findsOneWidget);
    });

    testWidgets('shows Cloudy Water problem card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Cloudy Water'), findsOneWidget);
    });

    testWidgets('shows General Tips section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('General Tips'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('General Tips'), findsOneWidget);
    });
  });
}
