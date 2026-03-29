// Widget tests for TabNavigator.
//
// Run: flutter test test/widget_tests/tab_navigator_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/tab_navigator.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/models/spaced_repetition.dart';

// ---------------------------------------------------------------------------
// No-op platform implementation for FlutterLocalNotifications
// ---------------------------------------------------------------------------

class _MockNotificationsPlatform extends FlutterLocalNotificationsPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<bool?> initialize(dynamic settings,
          {dynamic onDidReceiveNotificationResponse,
          dynamic onDidReceiveBackgroundNotificationResponse}) async =>
      true;

  @override
  Future<void> show(int id, String? title, String? body,
          {String? payload}) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async => null;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Register the no-op notifications platform so initialize() never throws.
void _registerMockNotifications() {
  FlutterLocalNotificationsPlatform.instance = _MockNotificationsPlatform();
}

Widget _wrap() {
  return ProviderScope(
    overrides: [
      spacedRepetitionProvider.overrideWith(
        (ref) => _FrozenSpacedRepetitionNotifier(ref),
      ),
    ],
    child: const MaterialApp(home: TabNavigator()),
  );
}

/// Subclass that uses the real Ref but resets to empty state after init.
class _FrozenSpacedRepetitionNotifier extends SpacedRepetitionNotifier {
  _FrozenSpacedRepetitionNotifier(Ref ref) : super(ref) {
    state = SpacedRepetitionState(
      cards: const [],
      stats: ReviewStats(
        totalCards: 0,
        dueCards: 0,
        weakCards: 0,
        masteredCards: 0,
        averageStrength: 0.0,
        cardsByMastery: const {},
        reviewsToday: 0,
        currentStreak: 0,
      ),
    );
  }
}

Future<void> _advance(WidgetTester tester) async {
  // Pump through all async operations, provider loads, and animations.
  // We run multiple small increments to drain flutter_animate timers (which
  // restart on every pump) and also cover longer delays (HomeScreen 4s tooltip).
  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _registerMockNotifications();
  });

  group('TabNavigator — smoke tests', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(TabNavigator), findsOneWidget);
    });

    testWidgets('shows bottom NavigationBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('shows 5 navigation destinations', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('shows Learn tab label', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Learn'), findsWidgets);
    });

    testWidgets('shows Practice tab label', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Practice'), findsWidgets);
    });

    testWidgets('shows Tank tab label', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Tank'), findsWidgets);
    });

    testWidgets('shows More tab label', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('More'), findsWidgets);
    });

    testWidgets('tab 0 is selected by default', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0);
    });

    testWidgets('tapping Practice tab switches selectedIndex', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      await tester.tap(find.text('Practice').first);
      await _advance(tester);
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 1);
    });
  });
}
