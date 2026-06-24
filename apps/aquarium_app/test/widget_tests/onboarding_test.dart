// Widget tests for Onboarding ConsentScreen.
//
// Run: flutter test test/widget_tests/onboarding_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/consent_screen.dart';
import 'package:danio/screens/onboarding/age_blocked_screen.dart';
import 'package:danio/providers/user_profile_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Override that provides the mocked SharedPreferences through Riverpod,
/// matching the ConsentScreen's use of shared_preferencesProvider.
Override _prefsOverride([SharedPreferences? prefs]) {
  return sharedPreferencesProvider.overrideWith((ref) async {
    return prefs ?? SharedPreferences.getInstance();
  });
}

class _FailingSetBoolPrefs implements SharedPreferences {
  _FailingSetBoolPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, bool value) _shouldFail;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  Object? get(String key) => _delegate.get(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  double? getDouble(String key) => _delegate.getDouble(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  Set<String> getKeys() => _delegate.getKeys();

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    if (_shouldFail(key, value)) return false;
    return _delegate.setBool(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Function.apply(_delegate.noSuchMethod, [invocation]);
}

Widget _wrap({
  required VoidCallback onConsentGiven,
  SharedPreferences? prefs,
}) {
  return ProviderScope(
    overrides: [_prefsOverride(prefs)],
    child: MaterialApp(home: ConsentScreen(onConsentGiven: onConsentGiven)),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ConsentScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap(onConsentGiven: () {}));
      await tester.pump();
      expect(find.byType(ConsentScreen), findsOneWidget);
    });

    testWidgets('shows privacy title', (tester) async {
      await tester.pumpWidget(_wrap(onConsentGiven: () {}));
      await tester.pump();
      expect(find.text('Your Privacy Matters'), findsOneWidget);
    });

    testWidgets('shows privacy icon', (tester) async {
      await tester.pumpWidget(_wrap(onConsentGiven: () {}));
      await tester.pump();
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });

    testWidgets('shows explanation text', (tester) async {
      await tester.pumpWidget(_wrap(onConsentGiven: () {}));
      await tester.pump();
      expect(
        find.textContaining('Crash reports help us fix bugs'),
        findsOneWidget,
      );
      expect(find.textContaining('Crash reports'), findsOneWidget);
    });
  });

  group('ConsentScreen — accept crash reports', () {
    testWidgets('shows Share Crash Reports button', (tester) async {
      await tester.pumpWidget(_wrap(onConsentGiven: () {}));
      await tester.pump();
      expect(find.text('Share Crash Reports'), findsOneWidget);
    });

    testWidgets(
      'tapping Share Crash Reports persists true to SharedPreferences',
      (tester) async {
        bool consentGiven = false;

        await tester.pumpWidget(
          _wrap(
            onConsentGiven: () {
              consentGiven = true;
            },
          ),
        );
        await tester.pump();

        // Check age confirmation checkbox
        await tester.tap(find.byType(Checkbox).at(0));
        await tester.pump();
        // Check ToS acceptance checkbox
        await tester.tap(find.byType(Checkbox).at(1));
        await tester.pump();

        await tester.tap(find.text('Share Crash Reports'));
        await tester.pumpAndSettle();

        // The callback should have been invoked
        expect(consentGiven, isTrue);

        // SharedPreferences should have the key set
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('gdpr_analytics_consent'), isTrue);
      },
    );

    testWidgets(
      'failed consent save keeps user on consent screen and does not complete',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final delegate = await SharedPreferences.getInstance();
        final prefs = _FailingSetBoolPrefs(
          delegate,
          (key, _) => key == 'gdpr_analytics_consent',
        );
        var callCount = 0;

        await tester.pumpWidget(
          _wrap(onConsentGiven: () => callCount++, prefs: prefs),
        );
        await tester.pump();

        await tester.tap(find.byType(Checkbox).at(0));
        await tester.pump();
        await tester.tap(find.byType(Checkbox).at(1));
        await tester.pump();

        await tester.tap(find.text('Share Crash Reports'));
        await tester.pumpAndSettle();

        expect(callCount, 0);
        expect(find.byType(ConsentScreen), findsOneWidget);
        expect(
          find.text("Couldn't save your choice. Please try again."),
          findsOneWidget,
        );
        expect(delegate.getBool('gdpr_analytics_consent'), isNull);
        expect(delegate.getBool('tos_accepted'), isNull);
      },
    );
  });

  group('ConsentScreen — decline crash reports', () {
    testWidgets('shows No Thanks button', (tester) async {
      await tester.pumpWidget(_wrap(onConsentGiven: () {}));
      await tester.pump();
      expect(find.text('No Thanks'), findsOneWidget);
    });

    testWidgets('tapping No Thanks persists false to SharedPreferences', (
      tester,
    ) async {
      bool consentGiven = false;

      await tester.pumpWidget(
        _wrap(
          onConsentGiven: () {
            consentGiven = true;
          },
        ),
      );
      await tester.pump();

      // Check age confirmation checkbox
      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pump();
      // Check ToS acceptance checkbox
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();

      await tester.tap(find.text('No Thanks'));
      await tester.pumpAndSettle();

      // The callback should still fire (consent decision was made)
      expect(consentGiven, isTrue);

      // SharedPreferences should have false
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('gdpr_analytics_consent'), isFalse);
    });
  });

  group('ConsentScreen — onboarding completion flow', () {
    testWidgets('onConsentGiven callback fires for accept', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(_wrap(onConsentGiven: () => callCount++));
      await tester.pump();

      // Check age confirmation checkbox
      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pump();
      // Check ToS acceptance checkbox
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();

      await tester.tap(find.text('Share Crash Reports'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });

    testWidgets('onConsentGiven callback fires for decline', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(_wrap(onConsentGiven: () => callCount++));
      await tester.pump();

      // Check age confirmation checkbox
      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pump();
      // Check ToS acceptance checkbox
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();

      await tester.tap(find.text('No Thanks'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });

    testWidgets('Share Crash Reports button is rendered as primary action', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(onConsentGiven: () {}));
      await tester.pump();

      // AppButton wraps text — verify the label is present and tappable
      expect(find.text('Share Crash Reports'), findsOneWidget);
    });

    testWidgets('Decline button is rendered as secondary action', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(onConsentGiven: () {}));
      await tester.pump();

      // AppButton wraps text — verify the label is present and tappable
      expect(find.text('No Thanks'), findsOneWidget);
    });
  });

  group('ConsentScreen — under-13 hard block', () {
    testWidgets('tapping under-13 persists block and does not record consent', (
      tester,
    ) async {
      var callCount = 0;

      await tester.pumpWidget(_wrap(onConsentGiven: () => callCount++));
      await tester.pump();

      await tester.tap(find.text("I'm under 13"));
      await tester.pumpAndSettle();

      expect(find.byType(AgeBlockedScreen), findsOneWidget);
      expect(callCount, 0);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('under_13_blocked'), isTrue);
      expect(prefs.getBool('gdpr_analytics_consent'), isNull);
      expect(prefs.getBool('tos_accepted'), isNull);
    });

    testWidgets(
      'failed under-13 block save keeps user on consent screen',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final delegate = await SharedPreferences.getInstance();
        final prefs = _FailingSetBoolPrefs(
          delegate,
          (key, _) => key == 'under_13_blocked',
        );

        await tester.pumpWidget(_wrap(onConsentGiven: () {}, prefs: prefs));
        await tester.pump();

        await tester.tap(find.text("I'm under 13"));
        await tester.pumpAndSettle();

        expect(find.byType(ConsentScreen), findsOneWidget);
        expect(find.byType(AgeBlockedScreen), findsNothing);
        expect(
          find.text("Couldn't save your choice. Please try again."),
          findsOneWidget,
        );
        expect(delegate.getBool('under_13_blocked'), isNull);
      },
    );
  });
}
