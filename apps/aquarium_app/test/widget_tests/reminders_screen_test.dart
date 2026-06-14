// Widget tests for RemindersScreen.
//
// Run: flutter test test/widget_tests/reminders_screen_test.dart
//
// Note: The EmptyState widget (contains MascotBubble) uses a repeating
// fish-bob animation, so pumpAndSettle never settles. We advance time
// with pump(Duration) calls instead.

import 'dart:io';

import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/reminders_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(child: MaterialApp(home: RemindersScreen()));
}

Widget _wrapWithFailingPrefs({
  required Map<String, Object> initialValues,
  required bool Function(String key, Object value) shouldFail,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        SharedPreferences.setMockInitialValues(initialValues);
        final prefs = await SharedPreferences.getInstance();
        return _ThrowingSetStringPrefs(prefs, shouldFail);
      }),
    ],
    child: const MaterialApp(home: RemindersScreen()),
  );
}

class _ThrowingSetStringPrefs implements SharedPreferences {
  _ThrowingSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockNotificationsPlatform extends FlutterLocalNotificationsPlatform
    with MockPlatformInterfaceMixin {
  Future<bool?> initialize(
    dynamic settings, {
    dynamic onDidReceiveNotificationResponse,
    dynamic onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async => null;

  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    String? payload,
  }) async {}
}

/// Advance far enough for async prefs load and animations to settle.
Future<void> _advance(WidgetTester tester) async {
  // First frame renders loading state
  await tester.pump();
  // Let the async prefs load complete and re-render
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterLocalNotificationsPlatform.instance = _MockNotificationsPlatform();
  });

  group('RemindersScreen — rendering', () {
    test(
      'source keeps reminder actions clear of the persistent bottom dock',
      () {
        final source = File(
          'lib/screens/reminders_screen.dart',
        ).readAsStringSync();

        expect(source, contains('DanioBottomDock.contentClearance'));
        expect(
          source,
          contains('MediaQuery.of(context).viewInsets.bottom'),
          reason: 'Add sheet should respect both the dock and keyboard.',
        );
      },
    );

    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(RemindersScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Reminders'), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows add button (FAB or icon)', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(
        find.byType(FloatingActionButton).evaluate().isNotEmpty ||
            find.byIcon(Icons.add).evaluate().isNotEmpty ||
            find.textContaining('Add').evaluate().isNotEmpty,
        isTrue,
        reason: 'Should have some way to add a reminder',
      );
    });

    testWidgets('empty state shows one add action', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Add Reminder'), findsOneWidget);
    });

    testWidgets('non-empty state uses dock-cleared FAB for adding', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'aquarium_reminders':
            '[{"id":"1","title":"Water Change","notes":null,"category":"water",'
            '"nextDue":"${DateTime.now().add(const Duration(days: 2)).toIso8601String()}",'
            '"lastCompleted":null,"isRecurring":true,"frequency":"weekly"}]',
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Reminder'), findsOneWidget);
    });

    testWidgets(
      'empty state title uses iconography instead of raw emoji text',
      (tester) async {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        expect(find.byIcon(Icons.notifications_none), findsWidgets);
        expect(find.text('Never miss a thing!'), findsOneWidget);
        expect(find.textContaining('Never miss a thing! 🔔'), findsNothing);
      },
    );

    testWidgets('shows reminder when data exists in prefs', (tester) async {
      // Use full JSON matching _Reminder.fromJson schema
      SharedPreferences.setMockInitialValues({
        'aquarium_reminders':
            '[{"id":"1","title":"Water Change","notes":null,"category":"water",'
            '"nextDue":"${DateTime.now().add(const Duration(days: 2)).toIso8601String()}",'
            '"lastCompleted":null,"isRecurring":true,"frequency":"weekly"}]',
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.text('Water Change'), findsOneWidget);
    });

    testWidgets(
      'undo restore failure shows feedback and keeps reminder deleted',
      (tester) async {
        final due = DateTime.now().add(const Duration(days: 2));
        final savedReminders =
            '[{"id":"1","title":"Water Change","notes":null,'
            '"category":"water","nextDue":"${due.toIso8601String()}",'
            '"lastCompleted":null,"isRecurring":true,"frequency":"weekly"}]';

        await tester.pumpWidget(
          _wrapWithFailingPrefs(
            initialValues: {'aquarium_reminders': savedReminders},
            shouldFail: (key, value) =>
                key == 'aquarium_reminders' && value != '[]',
          ),
        );
        await _advance(tester);

        await tester.drag(find.byType(Dismissible), const Offset(-800, 0));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Deleted: Water Change'), findsOneWidget);
        expect(find.widgetWithText(SnackBarAction, 'Undo'), findsOneWidget);

        tester
            .widget<SnackBarAction>(find.widgetWithText(SnackBarAction, 'Undo'))
            .onPressed();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(find.text('Water Change'), findsNothing);
        expect(
          find.text("Couldn't restore that reminder. Try again in a moment."),
          findsOneWidget,
        );
      },
    );
  });
}
