// Tank Tab Integration Tests — Danio Aquarium App
//
// Tests the Learn tab (index 0), which renders LearnScreen with lesson cards
// and learning paths. (Note: The "Tank" physical screen is HomeScreen on
// tab 2, but the PRD maps this suite to tank/room functionality testing
// via the room scene on the HomeScreen.)
//
// Run with:
//   flutter test integration_test/tank_tab_test.dart -d emulator-5554

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('[Tank Tab]', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
      });
    });

    testWidgets('Tank tab (HomeScreen) renders without crash',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Tap Tank (index 2) — this is HomeScreen
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('tank room scene or empty state is visible',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // HomeScreen shows either a RoomScene or EmptyRoomScene
      // Both contain meaningful content — Scaffold body should be non-trivial
      final scaffold = tester.widgetList<Scaffold>(find.byType(Scaffold));
      expect(scaffold, isNotEmpty);
      expect(scaffold.first.body, isNotNull);
    });

    testWidgets('bottom navigation persists on Tank tab',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify the NavigationBar is visible and Tank is selected
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 2);
    });

    testWidgets('can navigate away from Tank and back', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Tank tab
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Smart tab
      await tester.tap(find.byType(NavigationDestination).at(3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Back to Tank
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 2);
    });
  });
}
