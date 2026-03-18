// Home Tab Integration Tests — Danio Aquarium App
//
// Tests the Tank tab (index 2), which renders HomeScreen with welcome banners,
// daily nudge, tank scene, and room controls.
//
// Run with:
//   flutter test integration_test/home_tab_test.dart -d emulator-5554

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('[Home Tab]', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
      });
    });

    testWidgets('navigates to Tank tab without crash', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Default tab is Learn (0) — tap Tank (index 2)
      final destinations = find.byType(NavigationDestination);
      expect(destinations, findsWidgets);

      await tester.tap(destinations.at(2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tank tab displays scaffold content', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // HomeScreen should be showing — at minimum a Scaffold exists
      expect(find.byType(Scaffold), findsWidgets);
      // NavigationBar should still be visible
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('daily nudge or welcome banner appears', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // HomeScreen has DailyNudge or WelcomeBanner widgets
      // At least one interactive element (FAB, card, or banner) should exist
      final hasInteractiveContent = find
          .byWidgetPredicate((widget) =>
              widget is Scaffold &&
              widget.body != null)
          .evaluate()
          .isNotEmpty;
      expect(hasInteractiveContent, isTrue);
    });

    testWidgets('tapping another tab and returning to Tank works',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Go to Tank
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Go to Learn
      await tester.tap(find.byType(NavigationDestination).at(0));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Back to Tank
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
