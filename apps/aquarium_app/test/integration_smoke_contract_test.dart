import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/tab_navigator.dart';

import '../integration_test/smoke_test_harness.dart';

class _MockNotificationsPlatform extends FlutterLocalNotificationsPlatform
    with MockPlatformInterfaceMixin {
  Future<bool?> initialize(
    dynamic settings, {
    dynamic onDidReceiveNotificationResponse,
    dynamic onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    String? payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async => null;
}

Future<void> _advance(WidgetTester tester) async {
  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterLocalNotificationsPlatform.instance = _MockNotificationsPlatform();
  });

  group('phone smoke selector contract', () {
    test('uses the production bottom dock key namespace', () {
      expect(smokeDockKey, const ValueKey('danio-bottom-dock'));
      expect(
        smokeTabIds.map(smokeTabKey),
        const [
          ValueKey('danio-bottom-dock-item-learn'),
          ValueKey('danio-bottom-dock-item-practice'),
          ValueKey('danio-bottom-dock-item-tank'),
          ValueKey('danio-bottom-dock-item-smart'),
          ValueKey('danio-bottom-dock-item-more'),
        ],
      );
    });

    testWidgets('all smoke tab keys exist in TabNavigator', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TabNavigator())),
      );
      await _advance(tester);

      expect(smokeDockFinder(), findsOneWidget);
      for (final tabId in smokeTabIds) {
        expect(
          smokeTabFinder(tabId),
          findsOneWidget,
          reason: 'Smoke tab selector for $tabId must match TabNavigator.',
        );
      }
    });
  });
}
