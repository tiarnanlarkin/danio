// Smoke Test Suite — Danio Aquarium App (integration_test, no Patrol native deps)
//
// Run with:
//   flutter test integration_test/smoke_test_v2.dart -d emulator-5554
// Or:
//   flutter drive --driver=test_driver/integration_test.dart \
//                 --target=integration_test/smoke_test_v2.dart -d emulator-5554

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:danio/main.dart' as app;

Future<void> _launchApp(WidgetTester tester) async {
  app.main();
  await tester.pump();
  await tester.pump(const Duration(seconds: 5));
}

Future<void> _pumpAfterInput(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────────────────────
  // Test 1: App launches without crashing
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('App launches and displays initial screen', (tester) async {
    await _launchApp(tester);

    // The app should show SOMETHING — a Scaffold should be present
    expect(find.byType(Scaffold), findsWidgets);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 2: Bottom navigation tabs are accessible
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Can navigate through all bottom tabs without crash', (
    tester,
  ) async {
    await _launchApp(tester);

    // Check if we're on the main screen (has NavigationBar)
    final navBar = find.byType(NavigationBar);
    if (navBar.evaluate().isNotEmpty) {
      // Tap each NavigationDestination
      final destinations = find.byType(NavigationDestination);
      final count = destinations.evaluate().length;

      for (int i = 0; i < count; i++) {
        await tester.tap(destinations.at(i));
        await _pumpAfterInput(tester);
        expect(
          find.byType(Scaffold),
          findsWidgets,
          reason: 'Tab $i should display without crash',
        );
      }
    } else {
      // On onboarding — just verify no crash
      expect(find.byType(Scaffold), findsWidgets);
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 3: Learn tab loads content
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Learn tab displays content without crash', (tester) async {
    await _launchApp(tester);

    final navBar = find.byType(NavigationBar);
    if (navBar.evaluate().isNotEmpty) {
      // Learn tab = index 0
      await tester.tap(find.byType(NavigationDestination).at(0));
      await _pumpAfterInput(tester);
      expect(find.byType(Scaffold), findsWidgets);
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 4: Tank tab loads
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Tank tab loads without crash', (tester) async {
    await _launchApp(tester);

    final navBar = find.byType(NavigationBar);
    if (navBar.evaluate().isNotEmpty) {
      // Tank = index 2
      await tester.tap(find.byType(NavigationDestination).at(2));
      await _pumpAfterInput(tester);
      expect(find.byType(Scaffold), findsWidgets);
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 5: Settings (More) tab loads
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Settings (More) tab loads without crash', (tester) async {
    await _launchApp(tester);

    final navBar = find.byType(NavigationBar);
    if (navBar.evaluate().isNotEmpty) {
      // More/Settings = index 4
      await tester.tap(find.byType(NavigationDestination).at(4));
      await _pumpAfterInput(tester);
      expect(find.byType(Scaffold), findsWidgets);
    }
  });
}
