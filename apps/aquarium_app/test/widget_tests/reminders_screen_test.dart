// Widget tests for RemindersScreen.
//
// Run: flutter test test/widget_tests/reminders_screen_test.dart
//
// Note: The EmptyState widget (contains MascotBubble) uses a repeating
// fish-bob animation, so pumpAndSettle never settles. We advance time
// with pump(Duration) calls instead.

import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';

import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/reminders_screen.dart';
import 'package:danio/widgets/core/app_button.dart';

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

Widget _wrapWithFalseSetStringPrefs({
  required Map<String, Object> initialValues,
  required bool Function(String key, Object value) shouldFail,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        SharedPreferences.setMockInitialValues(initialValues);
        final prefs = await SharedPreferences.getInstance();
        return _FalseSetStringPrefs(prefs, shouldFail);
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

class _FalseSetStringPrefs implements SharedPreferences {
  _FalseSetStringPrefs(this._delegate, this._shouldFail);

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
      return Future.value(false);
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockNotificationsPlatform extends AndroidFlutterLocalNotificationsPlugin
    with MockPlatformInterfaceMixin {
  int canceledCount = 0;
  int scheduledCount = 0;

  @override
  Future<bool> initialize(
    AndroidInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  @override
  Future<bool?> canScheduleExactNotifications() async => true;

  @override
  Future<void> cancel(int id, {String? tag}) async {
    canceledCount++;
  }

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
    AndroidNotificationDetails? notificationDetails,
    String? payload,
  }) async {}

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    AndroidNotificationDetails? notificationDetails, {
    required AndroidScheduleMode scheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduledCount++;
  }
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

late _MockNotificationsPlatform _notificationsPlatform;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _notificationsPlatform = _MockNotificationsPlatform();
    FlutterLocalNotificationsPlatform.instance = _notificationsPlatform;
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

    testWidgets('tablet keeps reminder cards in a readable rail', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({
        'aquarium_reminders':
            '[{"id":"1","title":"Water Change","notes":null,"category":"water",'
            '"nextDue":"${DateTime.now().add(const Duration(days: 2)).toIso8601String()}",'
            '"lastCompleted":null,"isRecurring":true,"frequency":"weekly"}]',
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(
        tester.getSize(find.byType(Card).first).width,
        lessThanOrEqualTo(720),
      );
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

    testWidgets('add save failure shows feedback and keeps reminder unsaved', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithFailingPrefs(
          initialValues: {},
          shouldFail: (key, value) =>
              key == 'aquarium_reminders' && value != '[]',
        ),
      );
      await _advance(tester);

      await tester.tap(find.text('Add Reminder'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'Clean prefilter',
      );
      final saveButton = find.widgetWithText(AppButton, 'Save Reminder');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      tester.widget<AppButton>(saveButton).onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(ListTile, 'Clean prefilter'), findsNothing);
      expect(_notificationsPlatform.scheduledCount, 0);
      expect(
        find.text("Couldn't save that reminder. Try again in a moment."),
        findsOneWidget,
      );
    });

    testWidgets(
      'add false save result shows feedback and keeps reminder unsaved',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithFalseSetStringPrefs(
            initialValues: {},
            shouldFail: (key, value) =>
                key == 'aquarium_reminders' && value != '[]',
          ),
        );
        await _advance(tester);

        await tester.tap(find.text('Add Reminder'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.enterText(
          find.widgetWithText(TextField, 'Title'),
          'Clean prefilter',
        );
        final saveButton = find.widgetWithText(AppButton, 'Save Reminder');
        await tester.ensureVisible(saveButton);
        await tester.pump();
        tester.widget<AppButton>(saveButton).onPressed!();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        expect(find.widgetWithText(ListTile, 'Clean prefilter'), findsNothing);
        expect(_notificationsPlatform.scheduledCount, 0);
        expect(
          find.text("Couldn't save that reminder. Try again in a moment."),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'complete save failure shows feedback and keeps one-time reminder active',
      (tester) async {
        final due = DateTime.now().add(const Duration(days: 2));
        final savedReminders =
            '[{"id":"1","title":"Dose fertiliser","notes":null,'
            '"category":"maintenance","nextDue":"${due.toIso8601String()}",'
            '"lastCompleted":null,"isRecurring":false,"frequency":"once"}]';

        await tester.pumpWidget(
          _wrapWithFailingPrefs(
            initialValues: {'aquarium_reminders': savedReminders},
            shouldFail: (key, value) =>
                key == 'aquarium_reminders' && value == '[]',
          ),
        );
        await _advance(tester);

        await tester.tap(find.byTooltip('Mark reminder as done'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        expect(
          find.widgetWithText(ListTile, 'Dose fertiliser'),
          findsOneWidget,
        );
        expect(_notificationsPlatform.canceledCount, 0);
        expect(
          find.text("Couldn't complete that reminder. Try again in a moment."),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'complete false save result keeps one-time reminder active',
      (tester) async {
        final due = DateTime.now().add(const Duration(days: 2));
        final savedReminders =
            '[{"id":"1","title":"Dose fertiliser","notes":null,'
            '"category":"maintenance","nextDue":"${due.toIso8601String()}",'
            '"lastCompleted":null,"isRecurring":false,"frequency":"once"}]';

        await tester.pumpWidget(
          _wrapWithFalseSetStringPrefs(
            initialValues: {'aquarium_reminders': savedReminders},
            shouldFail: (key, value) =>
                key == 'aquarium_reminders' && value == '[]',
          ),
        );
        await _advance(tester);

        await tester.tap(find.byTooltip('Mark reminder as done'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        expect(
          find.widgetWithText(ListTile, 'Dose fertiliser'),
          findsOneWidget,
        );
        expect(_notificationsPlatform.canceledCount, 0);
        expect(
          find.text("Couldn't complete that reminder. Try again in a moment."),
          findsOneWidget,
        );
      },
    );
  });
}
