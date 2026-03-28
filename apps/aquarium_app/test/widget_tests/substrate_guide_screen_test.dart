// Widget tests for SubstrateGuideScreen.
//
// Run: flutter test test/widget_tests/substrate_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/substrate_guide_screen.dart';

Widget _wrap() => const MaterialApp(home: SubstrateGuideScreen());

void main() {
  group('SubstrateGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(SubstrateGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Substrate Guide'), findsOneWidget);
    });

    testWidgets('shows Why Substrate Matters intro card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Why Substrate Matters'), findsOneWidget);
    });

    testWidgets('shows Substrate Types section heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Substrate Types'), findsOneWidget);
    });

    testWidgets('shows Gravel substrate card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Gravel'), findsOneWidget);
    });
  });
}
