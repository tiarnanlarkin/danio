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

const _dockKey = ValueKey('danio-bottom-dock');
const _tabIds = ['learn', 'practice', 'tank', 'smart', 'more'];

Finder _dockFinder() => find.byKey(_dockKey);

Finder _tabFinder(String tabId) {
  return find.byKey(ValueKey('danio-bottom-dock-item-$tabId'));
}

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

    // Check if we're on the main screen (has Danio bottom dock)
    final dock = _dockFinder();
    if (dock.evaluate().isNotEmpty) {
      for (final tabId in _tabIds) {
        await tester.tap(_tabFinder(tabId));
        await _pumpAfterInput(tester);
        expect(
          find.byType(Scaffold),
          findsWidgets,
          reason: 'Tab $tabId should display without crash',
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

    final dock = _dockFinder();
    if (dock.evaluate().isNotEmpty) {
      await tester.tap(_tabFinder('learn'));
      await _pumpAfterInput(tester);
      expect(find.byType(Scaffold), findsWidgets);
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 4: Tank tab loads
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Tank tab loads without crash', (tester) async {
    await _launchApp(tester);

    final dock = _dockFinder();
    if (dock.evaluate().isNotEmpty) {
      await tester.tap(_tabFinder('tank'));
      await _pumpAfterInput(tester);
      expect(find.byType(Scaffold), findsWidgets);
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 5: Settings (More) tab loads
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Settings (More) tab loads without crash', (tester) async {
    await _launchApp(tester);

    final dock = _dockFinder();
    if (dock.evaluate().isNotEmpty) {
      await tester.tap(_tabFinder('more'));
      await _pumpAfterInput(tester);
      expect(find.byType(Scaffold), findsWidgets);
    }
  });
}
