// Widget tests for AboutScreen.
//
// Run: flutter test test/widget_tests/about_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/about_screen.dart';

Widget _wrap() => const MaterialApp(home: AboutScreen());

void main() {
  group('AboutScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(AboutScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('shows app name Danio', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Danio'), findsOneWidget);
    });

    testWidgets('shows version info', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });

    testWidgets('shows app tagline about fishkeeping', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Duolingo for Fishkeeping'), findsOneWidget);
    });
  });
}
