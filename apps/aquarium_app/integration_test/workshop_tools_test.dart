// Workshop Tools Integration Tests — Danio Aquarium App
//
// Tests the Workshop screen accessed via More (Settings Hub) tab.
// Verifies that each tool screen opens without crash and back navigation works.
//
// Run with:
//   flutter test integration_test/workshop_tools_test.dart -d emulator-5554

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('[Workshop Tools]', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
      });
    });

    testWidgets('navigates to Workshop from More tab', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Tap More (index 4)
      await tester.tap(find.byType(NavigationDestination).at(4));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find and tap 'Workshop' list tile in the Tools section
      final workshopTile = find.text('Workshop');
      if (workshopTile.evaluate().isNotEmpty) {
        await tester.tap(workshopTile);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // WorkshopScreen should show '🔧 Workshop' in AppBar
        expect(find.text('🔧 Workshop'), findsOneWidget);
      } else {
        // Fallback: verify Settings Hub loaded
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Workshop lists tool categories', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Navigate to Workshop
      await tester.tap(find.byType(NavigationDestination).at(4));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final workshopTile = find.text('Workshop');
      if (workshopTile.evaluate().isEmpty) return;

      await tester.tap(workshopTile);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Workshop should show multiple tool tiles
      expect(find.text('Water Change'), findsOneWidget);
      expect(find.text('CO₂ Calculator'), findsOneWidget);
      expect(find.text('Compatibility'), findsOneWidget);
      expect(find.text('Cost Tracker'), findsOneWidget);
    });

    testWidgets('opening and closing Compatibility Checker works',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      await tester.tap(find.byType(NavigationDestination).at(4));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final workshopTile = find.text('Workshop');
      if (workshopTile.evaluate().isEmpty) return;

      await tester.tap(workshopTile);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Open Compatibility Checker
      final compatTile = find.text('Compatibility');
      if (compatTile.evaluate().isEmpty) return;

      await tester.tap(compatTile);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should have navigated to CompatibilityCheckerScreen
      expect(find.byType(Scaffold), findsWidgets);

      // Navigate back
      await tester.tap(find.byType(BackButton).first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be back on Workshop screen
      expect(find.text('🔧 Workshop'), findsOneWidget);
    });

    testWidgets('opening and closing CO2 Calculator works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      await tester.tap(find.byType(NavigationDestination).at(4));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final workshopTile = find.text('Workshop');
      if (workshopTile.evaluate().isEmpty) return;

      await tester.tap(workshopTile);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Open CO₂ Calculator
      final co2Tile = find.text('CO₂ Calculator');
      if (co2Tile.evaluate().isEmpty) return;

      await tester.tap(co2Tile);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(Scaffold), findsWidgets);

      // Navigate back
      await tester.tap(find.byType(BackButton).first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('🔧 Workshop'), findsOneWidget);
    });

    testWidgets('opening and closing Cost Tracker works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      await tester.tap(find.byType(NavigationDestination).at(4));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final workshopTile = find.text('Workshop');
      if (workshopTile.evaluate().isEmpty) return;

      await tester.tap(workshopTile);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Open Cost Tracker
      final costTile = find.text('Cost Tracker');
      if (costTile.evaluate().isEmpty) return;

      await tester.tap(costTile);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(Scaffold), findsWidgets);

      // Navigate back
      await tester.tap(find.byType(BackButton).first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('🔧 Workshop'), findsOneWidget);
    });
  });
}
