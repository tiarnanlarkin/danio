// Widget tests for BreedingGuideScreen.
//
// Run: flutter test test/widget_tests/breeding_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/breeding_guide_screen.dart';

Widget _wrap() => const MaterialApp(home: BreedingGuideScreen());

void main() {
  group('BreedingGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(BreedingGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Fish Breeding Guide'), findsOneWidget);
    });

    testWidgets('shows Breeding Basics intro', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Breeding Basics'), findsOneWidget);
    });

    testWidgets('shows Breeding Methods section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Breeding Methods'), findsOneWidget);
    });

    testWidgets('shows Livebearers method card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Livebearers'), findsOneWidget);
    });
  });
}
