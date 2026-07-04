import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const smokeDockKey = ValueKey('danio-bottom-dock');
const smokeTabIds = ['learn', 'practice', 'tank', 'smart', 'more'];
const smokeMainTabsRequiredMessage =
    'Smoke main tabs must be visible before tab-flow checks.';

ValueKey<String> smokeTabKey(String tabId) {
  return ValueKey('danio-bottom-dock-item-$tabId');
}

Finder smokeDockFinder() => find.byKey(smokeDockKey);

Finder smokeTabFinder(String tabId) => find.byKey(smokeTabKey(tabId));

void expectSmokeMainTabsReady() {
  expect(
    smokeDockFinder(),
    findsOneWidget,
    reason: smokeMainTabsRequiredMessage,
  );

  for (final tabId in smokeTabIds) {
    expect(
      smokeTabFinder(tabId),
      findsOneWidget,
      reason: 'Smoke tab selector for $tabId must be available.',
    );
  }
}

Future<void> tapSmokeTabAndExpectScaffold(
  WidgetTester tester,
  String tabId,
) async {
  expectSmokeMainTabsReady();

  await tester.tap(smokeTabFinder(tabId));
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));

  expect(
    find.byType(Scaffold),
    findsWidgets,
    reason: 'Tab $tabId should display without crash',
  );
}

Future<void> waitForSmokeReady(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(Scaffold).evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Timed out waiting for the app to render an initial Scaffold.');
}
