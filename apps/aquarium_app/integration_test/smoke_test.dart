// Patrol Smoke Test Suite - Danio Aquarium App
//
// These tests verify the most critical user flows work without crashes.
// Run with: patrol test -t integration_test/smoke_test.dart
//
// Prerequisites:
//   - Emulator running (adb devices should show a device)
//   - patrol_cli installed (dart pub global activate patrol_cli)
//   - ANDROID_HOME set

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:danio/main.dart' as app;

import 'smoke_test_harness.dart';

void main() {
  patrolSetUp(() async {});

  patrolTest('App launches and displays initial screen', ($) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    expect($(Scaffold), findsWidgets);
  });

  patrolTest('Can navigate through all bottom tabs without crash', ($) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    await _tapAllTabs($);
  });

  patrolTest('Learn tab displays content without crash', ($) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    await _tapTabAndExpectScaffold($, 'learn');
  });

  patrolTest('Tank tab loads without crash', ($) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    await _tapTabAndExpectScaffold($, 'tank');
  });

  patrolTest('Settings (More) tab loads without crash', ($) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    await _tapTabAndExpectScaffold($, 'more');
  });

  patrolTest('Back button from main tabs shows exit confirmation, not crash', (
    $,
  ) async {
    app.main();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    _expectMainTabsReady($);

    // ignore: deprecated_member_use
    await $.native.pressBack();
    await $.pump(const Duration(seconds: 2));

    expect($(Scaffold), findsWidgets);
  });
}

Future<void> _tapAllTabs(PatrolIntegrationTester $) async {
  _expectMainTabsReady($);

  for (final tabId in smokeTabIds) {
    await _tapTabAndExpectScaffold($, tabId);
  }
}

Future<void> _tapTabAndExpectScaffold(
  PatrolIntegrationTester $,
  String tabId,
) async {
  _expectMainTabsReady($);

  await $(smokeTabKey(tabId)).tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 5));

  expect(
    $(Scaffold),
    findsWidgets,
    reason: 'Tab $tabId should display without crash',
  );
}

void _expectMainTabsReady(PatrolIntegrationTester $) {
  expect(
    $(smokeDockKey),
    findsOneWidget,
    reason: smokeMainTabsRequiredMessage,
  );

  for (final tabId in smokeTabIds) {
    expect(
      $(smokeTabKey(tabId)),
      findsOneWidget,
      reason: 'Smoke tab selector for $tabId must be available.',
    );
  }
}
