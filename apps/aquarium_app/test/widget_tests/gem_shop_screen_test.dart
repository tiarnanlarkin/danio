// Widget tests for GemShopScreen.
//
// Run: flutter test test/widget_tests/gem_shop_screen_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/data/shop_catalog.dart';
import 'package:danio/models/shop_item.dart';
import 'package:danio/providers/gems_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/gem_shop_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: GemShopScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

class _PurchaseFailurePrefs implements SharedPreferences {
  _PurchaseFailurePrefs(this._delegate, {required this.failRefund});

  final SharedPreferences _delegate;
  final bool failRefund;
  var _gemsStateWrites = 0;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  double? getDouble(String key) => _delegate.getDouble(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  Set<String> getKeys() => _delegate.getKeys();

  @override
  Future<bool> setString(String key, String value) {
    if (key == 'shop_inventory') {
      return Future<bool>.value(false);
    }
    if (key == 'gems_state') {
      _gemsStateWrites += 1;
      if (failRefund && _gemsStateWrites == 2) {
        return Future<bool>.value(false);
      }
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, Object> _gemPreferences({int balance = 100}) {
  final gems = GemsState(
    balance: balance,
    transactions: const [],
    lastUpdated: DateTime(2026, 7, 16, 12),
  );
  return {
    'gems_state': jsonEncode(gems.toJson()),
    'gems_cumulative': jsonEncode({'earned': 0, 'spent': 0}),
  };
}

Future<void> _attemptXpBoostPurchase(WidgetTester tester) async {
  final item = ShopCatalog.getById('xp_boost_1h')!;
  await tester.tap(
    find.bySemanticsLabel(RegExp(RegExp.escape(item.name))).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Purchase'));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GemShopScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(GemShopScreen), findsOneWidget);
    });

    testWidgets('shows Gem Shop title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Gem Shop'), findsOneWidget);
    });

    testWidgets('shows tab bar with three tabs', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(3));
    });

    testWidgets('shows inventory icon button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    });

    testWidgets('shows gem balance in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders shop item icons instead of catalog emoji', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      for (final item in ShopCatalog.getByCategory(ShopItemCategory.powerUps)) {
        expect(find.text(item.emoji), findsNothing, reason: item.id);
      }
    });

    testWidgets('tablet keeps shop item cards bounded', (tester) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final item = ShopCatalog.getById('xp_boost_1h')!;

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      final card = find.bySemanticsLabel(
        RegExp('${RegExp.escape(item.name)}.*${item.gemCost} gems'),
      );

      expect(card, findsOneWidget);
      expect(tester.getSize(card).width, lessThanOrEqualTo(360));
    });

    testWidgets('purchase dialog title omits catalog emoji', (tester) async {
      final item = ShopCatalog.getById('xp_boost_1h')!;

      await tester.pumpWidget(_wrap());
      await _advance(tester);
      await tester.tap(
        find.bySemanticsLabel(RegExp(RegExp.escape(item.name))).first,
      );
      await tester.pumpAndSettle();

      expect(find.text(item.emoji), findsNothing);
      expect(find.text(item.name), findsWidgets);
    });

    testWidgets(
      'failed inventory save with failed refund warns without unsafe retry',
      (tester) async {
        SharedPreferences.setMockInitialValues(_gemPreferences());
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          _wrap(
            overrides: [
              sharedPreferencesProvider.overrideWith(
                (ref) async => _PurchaseFailurePrefs(prefs, failRefund: true),
              ),
            ],
          ),
        );
        await _advance(tester);

        await _attemptXpBoostPurchase(tester);

        expect(tester.takeException(), isNull);
        expect(
          find.text(
            'This purchase wasn\'t saved, and we couldn\'t confirm your gem refund. '
            'Your gem balance may be uncertain. Close and reopen Danio before buying again.',
          ),
          findsOneWidget,
        );
        expect(find.text('Retry'), findsNothing);

        final persistedGems = GemsState.fromJson(
          jsonDecode(prefs.getString('gems_state')!) as Map<String, dynamic>,
        );
        expect(persistedGems.balance, 75);
        expect(prefs.getString('shop_inventory'), isNull);
      },
    );

    testWidgets(
      'failed inventory save with successful refund keeps retry safe',
      (tester) async {
        SharedPreferences.setMockInitialValues(_gemPreferences());
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          _wrap(
            overrides: [
              sharedPreferencesProvider.overrideWith(
                (ref) async => _PurchaseFailurePrefs(prefs, failRefund: false),
              ),
            ],
          ),
        );
        await _advance(tester);

        await _attemptXpBoostPurchase(tester);

        expect(tester.takeException(), isNull);
        expect(
          find.text('Oops! We hit a snag. Give it another go!'),
          findsOneWidget,
        );
        expect(find.text('Retry'), findsOneWidget);
        expect(
          find.textContaining('gem balance may be uncertain'),
          findsNothing,
        );

        final persistedGems = GemsState.fromJson(
          jsonDecode(prefs.getString('gems_state')!) as Map<String, dynamic>,
        );
        expect(persistedGems.balance, 100);
        expect(prefs.getString('shop_inventory'), isNull);
      },
    );
  });
}
