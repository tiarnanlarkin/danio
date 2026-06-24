import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/widgets/seasonal_tip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailingSetBoolPrefs implements SharedPreferences {
  _FailingSetBoolPrefs(this._delegate);

  final SharedPreferences _delegate;

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Function.apply(_delegate.noSuchMethod, [invocation]);
}

String _seasonalTipKey() {
  final now = DateTime.now();
  return 'seasonal_tip_dismissed_${now.year}_${now.month}';
}

void main() {
  testWidgets('saves the dismissed flag before hiding the seasonal tip', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SeasonalTipCard()),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('Tip'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Dismiss seasonal tip'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tip'), findsNothing);
    expect(prefs.getBool(_seasonalTipKey()), isTrue);
  });

  testWidgets(
    'keeps seasonal tip visible when the dismissal flag fails to save',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final delegate = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith(
              (ref) async => _FailingSetBoolPrefs(delegate),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SeasonalTipCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Tip'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Dismiss seasonal tip'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tip'), findsOneWidget);
    },
  );
}
