import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/widgets/first_visit_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailingSetBoolPrefs implements SharedPreferences {
  _FailingSetBoolPrefs(this._delegate);

  final SharedPreferences _delegate;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Function.apply(_delegate.noSuchMethod, [invocation]);
}

class _ThrowingSetBoolPrefs implements SharedPreferences {
  _ThrowingSetBoolPrefs(this._delegate);

  final SharedPreferences _delegate;

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    throw StateError('setBool failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Function.apply(_delegate.noSuchMethod, [invocation]);
}

void main() {
  testWidgets('reports tooltip dismissed after the dismissal flag is saved', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    var dismissed = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FirstVisitTooltip(
              prefsKey: 'guidance_seen_learnFirstVisit',
              message: 'Use Learn to build safe aquarium habits.',
              autoDismissDuration: const Duration(minutes: 5),
              onDismissed: () => dismissed = true,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Use Learn to build safe aquarium habits.'));
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
    expect(prefs.getBool('guidance_seen_learnFirstVisit'), isTrue);
  });

  testWidgets(
    'does not report tooltip dismissed when the dismissal flag fails to save',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final delegate = await SharedPreferences.getInstance();
      var dismissed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith(
              (ref) async => _FailingSetBoolPrefs(delegate),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: FirstVisitTooltip(
                prefsKey: 'guidance_seen_learnFirstVisit',
                message: 'Use Learn to build safe aquarium habits.',
                autoDismissDuration: const Duration(minutes: 5),
                onDismissed: () => dismissed = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.text('Use Learn to build safe aquarium habits.'));
      await tester.pumpAndSettle();

      expect(dismissed, isFalse);
      expect(delegate.getBool('guidance_seen_learnFirstVisit'), isNull);
    },
  );

  testWidgets(
    'does not report tooltip dismissed when the dismissal flag throws',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final delegate = await SharedPreferences.getInstance();
      var dismissed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith(
              (ref) async => _ThrowingSetBoolPrefs(delegate),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: FirstVisitTooltip(
                prefsKey: 'guidance_seen_learnFirstVisit',
                message: 'Use Learn to build safe aquarium habits.',
                autoDismissDuration: const Duration(minutes: 5),
                onDismissed: () => dismissed = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.text('Use Learn to build safe aquarium habits.'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(dismissed, isFalse);
      expect(delegate.getBool('guidance_seen_learnFirstVisit'), isNull);
    },
  );
}
