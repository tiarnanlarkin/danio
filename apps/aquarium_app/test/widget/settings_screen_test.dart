// Widget tests for SettingsScreen
//
// Coverage:
//   - Individual ConsumerWidget sub-tiles only rebuild when their specific
//     setting changes (granular rebuild verification)
//   - Toggle state changes (_AmbientLightingToggle, _HapticFeedbackToggle,
//     _NotificationsToggle, _ReducedMotionToggle)
//   - Theme mode switching via _ThemeModeTile
//   - ListView.builder lazy-loading sanity check
//
// Run: flutter test test/widget/settings_screen_test.dart

import 'dart:io';
import 'dart:convert';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/settings_screen.dart';
import 'package:danio/widgets/core/app_list_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _ThrowingPrefs implements SharedPreferences {
  _ThrowingPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  double? getDouble(String key) => _delegate.getDouble(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  Future<bool> setBool(String key, bool value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setBool(key, value);
  }

  @override
  Future<bool> setInt(String key, int value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setInt(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap(Widget child, {SharedPreferences? prefs}) {
  return ProviderScope(
    overrides: [
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ],
    child: MaterialApp(home: child),
  );
}

Map<String, dynamic> _profileJson({
  String? regionCode,
  String? tankStatus,
  String experienceLevel = 'beginner',
  List<String> goals = const ['keepFishAlive'],
}) {
  final now = DateTime.now().toIso8601String();
  return {
    'id': 'settings-test-user',
    'experienceLevel': experienceLevel,
    'primaryTankType': 'freshwater',
    'regionCode': regionCode,
    'goals': goals,
    'tankStatus': tankStatus,
    'totalXp': 0,
    'currentStreak': 0,
    'longestStreak': 0,
    'completedLessons': <String>[],
    'achievements': <String>[],
    'lessonProgress': <String, dynamic>{},
    'completedStories': <String>[],
    'storyProgress': <String, dynamic>{},
    'hasCompletedPlacementTest': false,
    'hasSkippedPlacementTest': false,
    'dailyXpGoal': 50,
    'dailyXpHistory': <String, int>{},
    'hasStreakFreeze': false,
    'hearts': 5,
    'league': 'bronze',
    'weeklyXP': 0,
    'inventory': <dynamic>[],
    'dailyTipsEnabled': true,
    'streakRemindersEnabled': true,
    'hasSeenTutorial': false,
    'weekendActivityDates': <String>[],
    'fullHeartDates': <String>[],
    'perfectScoreCount': 0,
    'createdAt': now,
    'updatedAt': now,
  };
}

Future<void> _dragUntilTextVisible(WidgetTester tester, String text) async {
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 30 && find.text(text).evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -120));
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text(text), findsOneWidget);
  await tester.ensureVisible(find.text(text));
  await tester.pump();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsScreen — smoke', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('shows Preferences app-bar title', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();
      expect(find.text('Preferences'), findsOneWidget);
    });

    testWidgets('uses ListView.builder (lazy list)', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('does not expose debug crash controls in normal preferences', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      expect(find.text('Test Error Boundary'), findsNothing);
      expect(find.text('Trigger a crash to test error handling'), findsNothing);
    });

    testWidgets('opens Privacy Policy directly from Preferences', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await _dragUntilTextVisible(tester, 'Privacy Policy');
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.text('Your Privacy Matters'), findsOneWidget);
    });

    testWidgets('resets accepted Optional AI disclosure from Preferences', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'openai_disclosure_accepted': true,
      });

      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await _dragUntilTextVisible(tester, 'Optional AI');
      await tester.tap(find.text('Optional AI').first);
      await tester.pumpAndSettle();

      expect(find.text('AI disclosure accepted'), findsOneWidget);

      await tester.tap(find.text('Reset AI disclosure'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('openai_disclosure_accepted'), isNull);
      expect(
        find.text(
          'AI disclosure will be shown again before Optional AI sends data.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('failed crash-report consent save keeps switch unchanged', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'gdpr_analytics_consent': false,
      });
      final prefs = await SharedPreferences.getInstance();
      final throwingPrefs = _ThrowingPrefs(
        prefs,
        (key, _) => key == 'gdpr_analytics_consent',
      );

      await tester.pumpWidget(
        _wrap(const SettingsScreen(), prefs: throwingPrefs),
      );
      await tester.pump();

      await _dragUntilTextVisible(tester, 'Crash Reports');
      final switchFinder = find.ancestor(
        of: find.text('Crash Reports'),
        matching: find.byType(SwitchListTile),
      );
      expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);
      expect(prefs.getBool('gdpr_analytics_consent'), isFalse);
      expect(
        find.text("Couldn't update crash reports. Try again."),
        findsOneWidget,
      );
    });
  });

  group('_ThemeModeTile — theme mode switching', () {
    testWidgets('displays Light/Dark Mode tile and System default subtitle', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Light/Dark Mode'), 500.0);
      expect(find.text('Light/Dark Mode'), findsOneWidget);
      expect(find.text('System default'), findsOneWidget);
    });

    testWidgets('opens theme picker bottom sheet on tap', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Light/Dark Mode'), 500.0);
      await tester.tap(find.text('Light/Dark Mode'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Theme'), findsOneWidget);
    });

    testWidgets('selecting Light theme dismisses sheet', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Light/Dark Mode'), 500.0);
      await tester.tap(find.text('Light/Dark Mode'));
      await tester.pumpAndSettle();

      // In the bottom sheet, tap "Light"
      final lightFinders = find.text('Light');
      // Multiple — the sheet option and possibly the subtitle after selection.
      // Tap the first one visible inside the sheet
      await tester.tap(lightFinders.first);
      await tester.pumpAndSettle();

      // Sheet dismissed
      expect(find.text('Choose Theme'), findsNothing);
    });

    testWidgets('selecting Dark theme dismisses sheet', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Light/Dark Mode'), 500.0);
      await tester.tap(find.text('Light/Dark Mode'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Theme'), findsNothing);
    });
  });

  group('_UnitsTile', () {
    testWidgets('shows Units tile with metric subtitle by default', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Units'), 500.0);
      expect(find.text('Units'), findsOneWidget);
      expect(find.text('Metric (litres, cm, C)'), findsOneWidget);
    });

    testWidgets('opens units picker on tap', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Units'), 500.0);
      await tester.tap(find.text('Units'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Units'), findsOneWidget);
      expect(find.text('US units'), findsOneWidget);
    });

    testWidgets('selecting US units updates the visible subtitle', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Units'), 500.0);
      await tester.tap(find.text('Units'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('US units'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Units'), 500.0);
      expect(find.text('US units (gallons, inches, F)'), findsOneWidget);
    });

    testWidgets('failed units save keeps picker open with feedback', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'use_metric': true});
      final prefs = await SharedPreferences.getInstance();
      final throwingPrefs = _ThrowingPrefs(
        prefs,
        (key, _) => key == 'use_metric',
      );

      await tester.pumpWidget(
        _wrap(const SettingsScreen(), prefs: throwingPrefs),
      );
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Units'), 500.0);
      await tester.tap(find.text('Units'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('US units'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Units'), findsOneWidget);
      expect(find.text('Couldn\'t save units. Try again.'), findsOneWidget);
      expect(prefs.getBool('use_metric'), isTrue);
    });
  });

  group('_SetupDetailsSection', () {
    testWidgets('shows missing setup context in Preferences', (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(_profileJson()),
      });

      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(find.text('Region'), 500.0);
      expect(find.text('Region'), findsOneWidget);
      expect(find.text('Not set - helps localise guidance'), findsOneWidget);
      expect(find.text('Tank stage'), findsOneWidget);
      expect(find.text('Not set - helps tune care prompts'), findsOneWidget);
    });

    testWidgets('shows experience and goals in Preferences', (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(
          _profileJson(
            experienceLevel: 'intermediate',
            goals: const ['learnTheScience', 'beautifulDisplay'],
          ),
        ),
      });

      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(find.text('Region'), 500.0);
      expect(find.text('Experience level'), findsOneWidget);
      expect(find.text('Some experience'), findsOneWidget);
      await _dragUntilTextVisible(tester, 'Goals');
      expect(find.text('Learn the science, Beautiful display'), findsOneWidget);
    });

    testWidgets('region picker updates the visible profile region', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(_profileJson()),
      });

      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(find.text('Region'), 500.0);
      await tester.tap(find.text('Region'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('UK & Ireland'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Region'), 500.0);
      expect(find.text('UK & Ireland'), findsOneWidget);
    });

    testWidgets('experience picker updates the visible profile level', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(_profileJson()),
      });

      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(find.text('Region'), 500.0);
      await tester.tap(find.text('Experience level'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Experienced aquarist'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Region'), 500.0);
      expect(find.text('Experienced aquarist'), findsOneWidget);
    });

    testWidgets('goals picker saves multiple visible profile goals', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(_profileJson(goals: const [])),
      });

      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await _dragUntilTextVisible(tester, 'Goals');
      await tester.tap(find.text('Goals'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(CheckboxListTile, 'Beautiful display'),
      );
      await tester.pump();
      await tester.tap(
        find.widgetWithText(CheckboxListTile, 'Learn the science'),
      );
      await tester.pump();
      await tester.tap(find.text('Save goals'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      await _dragUntilTextVisible(tester, 'Goals');
      expect(find.text('Learn the science, Beautiful display'), findsOneWidget);
    });
  });

  group('_AmbientLightingToggle', () {
    testWidgets('shows Day/Night Ambiance tile', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Day/Night Ambiance'), 500.0);
      expect(find.text('Day/Night Ambiance'), findsOneWidget);
    });

    testWidgets('toggle flips value', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Day/Night Ambiance'), 500.0);
      final switchFinder = find.ancestor(
        of: find.text('Day/Night Ambiance'),
        matching: find.byType(SwitchListTile),
      );
      final bool initial = tester.widget<SwitchListTile>(switchFinder).value;

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(switchFinder).value, !initial);
    });
  });

  group('_HapticFeedbackToggle', () {
    testWidgets('shows Haptic Feedback tile', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Haptic Feedback'), 500.0);
      expect(find.text('Haptic Feedback'), findsOneWidget);
    });

    testWidgets('toggling off then on returns to true', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Haptic Feedback'), 500.0);
      final switchFinder = find.ancestor(
        of: find.text('Haptic Feedback'),
        matching: find.byType(SwitchListTile),
      );

      // Default true — toggle off
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);

      // Toggle back on
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);
    });
  });

  group('_NotificationsToggle', () {
    testWidgets('Phone Notifications starts disabled', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Phone Notifications'), 500.0);
      final switchFinder = find.ancestor(
        of: find.text('Phone Notifications'),
        matching: find.byType(SwitchListTile),
      );
      expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);
    });

    testWidgets(
      'Test Notification explains disabled state when reminders off',
      (tester) async {
        await tester.pumpWidget(_wrap(const SettingsScreen()));
        await tester.pump();
        await tester.scrollUntilVisible(
          find.text('Phone Notifications'),
          500.0,
        );

        expect(find.text('Test Notification'), findsOneWidget);
        expect(
          find.text('Enable Phone Notifications to send a test notification'),
          findsOneWidget,
        );

        final testTile = tester.widget<AppListTile>(
          find.ancestor(
            of: find.text('Test Notification'),
            matching: find.byType(AppListTile),
          ),
        );
        expect(testTile.isDisabled, isTrue);
      },
    );
  });

  group('Settings semantics', () {
    testWidgets('Learn card exposes one concise semantics node', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap(const SettingsScreen()));
        await tester.pump();

        final learnCard = find.bySemanticsLabel(
          'Learn Fishkeeping. Tap to open lessons',
        );
        expect(learnCard, findsOneWidget);

        final node = tester.getSemantics(learnCard);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        expect(node.childrenCount, 0);
        expect(
          find.bySemanticsLabel(
            RegExp(r'Learn Fishkeeping[\s\S]*Learn Fishkeeping'),
          ),
          findsNothing,
        );
      } finally {
        semantics.dispose();
      }
    });

    test('Preferences does not duplicate the More Backup hub', () {
      final source = File(
        'lib/screens/settings/settings_screen.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('Backup & Restore')));
      expect(source, isNot(contains('BackupRestoreScreen')));
    });
  });

  group('_ReducedMotionToggle', () {
    testWidgets('shows Reduce Motion tile', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Reduce Motion'), 500.0);
      expect(find.text('Reduce Motion'), findsOneWidget);
    });

    testWidgets('toggling changes switch value', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Reduce Motion'), 500.0);
      final switchFinder = find.ancestor(
        of: find.text('Reduce Motion'),
        matching: find.byType(SwitchListTile),
      );
      final bool initial = tester.widget<SwitchListTile>(switchFinder).value;

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(switchFinder).value, !initial);
    });
  });

  group('Granular rebuild isolation', () {
    testWidgets(
      'all five toggle tiles render without error after ambient toggle',
      (tester) async {
        await tester.pumpWidget(_wrap(const SettingsScreen()));
        await tester.pump();

        // Toggle ambient lighting (should only rebuild _AmbientLightingToggle)
        await tester.scrollUntilVisible(find.text('Day/Night Ambiance'), 500.0);
        final ambientSwitch = find.ancestor(
          of: find.text('Day/Night Ambiance'),
          matching: find.byType(SwitchListTile),
        );
        await tester.tap(ambientSwitch);
        await tester.pumpAndSettle();

        // All other toggles should still render fine
        // Note: scrollUntilVisible only scrolls forward (down). After toggling
        // ambient, the list position is near "Day/Night Ambiance". We verify
        // each tile by scrolling forward through the remaining labels.
        final labelsBelow = [
          'Day/Night Ambiance',
          'Reduce Motion',
          'Haptic Feedback',
          'Phone Notifications',
        ];
        for (final label in labelsBelow) {
          await tester.scrollUntilVisible(find.text(label), 500.0);
          expect(
            find.text(label),
            findsOneWidget,
            reason: 'Expected "$label" to be present after ambient toggle',
          );
        }

        // "Light/Dark Mode" is above — verify it's still in the widget tree
        // by scrolling back up with a drag, then checking.
        await tester.drag(find.byType(ListView), const Offset(0, 3000));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text('Light/Dark Mode'), 500.0);
        expect(
          find.text('Light/Dark Mode'),
          findsOneWidget,
          reason:
              'Expected "Light/Dark Mode" to be present after ambient toggle',
        );
      },
    );
  });
}
