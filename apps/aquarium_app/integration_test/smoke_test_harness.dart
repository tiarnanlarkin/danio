import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const smokeDockKey = ValueKey('danio-bottom-dock');
const smokeTabIds = ['learn', 'practice', 'tank', 'smart', 'more'];

ValueKey<String> smokeTabKey(String tabId) {
  return ValueKey('danio-bottom-dock-item-$tabId');
}

Finder smokeDockFinder() => find.byKey(smokeDockKey);

Finder smokeTabFinder(String tabId) => find.byKey(smokeTabKey(tabId));

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
