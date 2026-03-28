// Widget tests for ParameterGuideScreen.
//
// Run: flutter test test/widget_tests/parameter_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/parameter_guide_screen.dart';

Widget _wrap() => const MaterialApp(home: ParameterGuideScreen());

void main() {
  group('ParameterGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(ParameterGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Water Parameters Guide'), findsOneWidget);
    });

    testWidgets('shows Ammonia parameter section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Ammonia'), findsWidgets);
    });

    testWidgets('shows Nitrite parameter section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Nitrite'), findsWidgets);
    });

    testWidgets('shows pH section by scrolling', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('pH'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('pH'), findsOneWidget);
    });
  });
}
