// Widget tests for AcclimationGuideScreen.
//
// Run: flutter test test/widget_tests/acclimation_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/acclimation_guide_screen.dart';
import 'package:danio/theme/app_theme.dart';

Widget _wrap() => const MaterialApp(home: AcclimationGuideScreen());

void main() {
  group('AcclimationGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(AcclimationGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Fish Acclimation Guide'), findsOneWidget);
    });

    testWidgets('shows Why Acclimate intro card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Why Acclimate?'), findsOneWidget);
    });

    testWidgets('shows Method 1 Float and Release heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Method 1: Float & Release'), findsOneWidget);
    });

    testWidgets('shows float bag step card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Float the bag'), findsOneWidget);
    });

    testWidgets('duration icons use the minimum legible app size',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      final timerIcon = tester.widget<Icon>(find.byIcon(Icons.timer).first);
      expect(timerIcon.size, greaterThanOrEqualTo(AppIconSizes.xs));
    });
  });
}
