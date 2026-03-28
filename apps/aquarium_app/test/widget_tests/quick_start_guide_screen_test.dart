// Widget tests for QuickStartGuideScreen.
//
// Run: flutter test test/widget_tests/quick_start_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/quick_start_guide_screen.dart';

Widget _wrap() => const MaterialApp(home: QuickStartGuideScreen());

void main() {
  group('QuickStartGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(QuickStartGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Quick Start Guide'), findsOneWidget);
    });

    testWidgets('shows hero card with Your First Aquarium', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Your First Aquarium'), findsOneWidget);
    });

    testWidgets('shows step 1 Choose Your Tank', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Choose Your Tank'), findsOneWidget);
    });

    testWidgets('shows step 2 Get Your Equipment by scrolling', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Get Your Equipment'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('Get Your Equipment'), findsOneWidget);
    });
  });
}
