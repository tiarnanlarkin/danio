// Smoke Test Suite - Danio Aquarium App (integration_test, no Patrol native deps)
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

import 'smoke_test_harness.dart';

Future<void> _launchApp(WidgetTester tester) async {
  await app.main();
  await waitForSmokeReady(tester);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches and displays initial screen', (tester) async {
    await _launchApp(tester);

    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Can navigate through all bottom tabs without crash', (
    tester,
  ) async {
    await _launchApp(tester);

    expectSmokeMainTabsReady();
    for (final tabId in smokeTabIds) {
      await tapSmokeTabAndExpectScaffold(tester, tabId);
    }
  });

  testWidgets('Learn tab displays content without crash', (tester) async {
    await _launchApp(tester);

    await tapSmokeTabAndExpectScaffold(tester, 'learn');
  });

  testWidgets('Tank tab loads without crash', (tester) async {
    await _launchApp(tester);

    await tapSmokeTabAndExpectScaffold(tester, 'tank');
  });

  testWidgets('Settings (More) tab loads without crash', (tester) async {
    await _launchApp(tester);

    await tapSmokeTabAndExpectScaffold(tester, 'more');
  });
}
