// Widget tests for InventoryScreen.
//
// Run: flutter test test/widget_tests/inventory_screen_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/data/shop_catalog.dart';
import 'package:danio/models/shop_item.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/inventory_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _ThrowingSetStringPrefs implements SharedPreferences {
  _ThrowingSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

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
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setString(key, value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

UserProfile _profile() {
  final now = DateTime(2026, 6, 19, 12);
  return UserProfile(
    id: 'profile-1',
    experienceLevel: ExperienceLevel.beginner,
    primaryTankType: TankType.freshwater,
    goals: const [UserGoal.keepFishAlive],
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrap({SharedPreferences? prefs}) {
  return ProviderScope(
    overrides: [
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ],
    child: const MaterialApp(home: InventoryScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
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
  });

  group('InventoryScreen - rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(InventoryScreen), findsOneWidget);
    });

    testWidgets('shows title text', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('My Items'), findsOneWidget);
    });

    testWidgets('shows tab bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('shows app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('empty inventory state does not render raw emoji', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      final emoji = RegExp(
        r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}]',
        unicode: true,
      );
      final renderedText = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) {
            return widget.data ?? widget.textSpan?.toPlainText() ?? '';
          })
          .where(emoji.hasMatch)
          .toList();

      expect(renderedText, isEmpty);
    });

    testWidgets('renders owned item icons instead of catalog emoji', (
      tester,
    ) async {
      final item = ShopCatalog.getById('xp_boost_1h')!;
      final owned = InventoryItem(
        itemId: item.id,
        quantity: 1,
        purchasedAt: DateTime(2026, 5, 3),
      );

      SharedPreferences.setMockInitialValues({
        'shop_inventory': jsonEncode([owned.toJson()]),
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.text(item.name), findsOneWidget);
      expect(find.text(item.emoji), findsNothing);
    });

    testWidgets('hides unavailable legacy catalog items', (tester) async {
      final hidden = ShopCatalog.getById('progress_protector')!;
      final owned = InventoryItem(
        itemId: hidden.id,
        quantity: 1,
        purchasedAt: DateTime(2026, 5, 3),
      );

      SharedPreferences.setMockInitialValues({
        'shop_inventory': jsonEncode([owned.toJson()]),
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.text(hidden.name), findsNothing);
    });

    testWidgets(
      'failed item use shows retry feedback and keeps the item visible',
      (tester) async {
        final item = ShopCatalog.getById('streak_freeze')!;
        final owned = InventoryItem(
          itemId: item.id,
          quantity: 1,
          purchasedAt: DateTime(2026, 6, 19, 12),
        );
        final inventoryJson = jsonEncode([owned.toJson()]);

        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(_profile().toJson()),
          'shop_inventory': inventoryJson,
        });
        final prefs = await SharedPreferences.getInstance();
        final throwingPrefs = _ThrowingSetStringPrefs(
          prefs,
          (key, _) => key == 'shop_inventory',
        );

        await tester.pumpWidget(_wrap(prefs: throwingPrefs));
        await _advance(tester);

        await tester.tap(find.text('USE'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Use Now'));
        await tester.pumpAndSettle();

        expect(
          find.text('Couldn\'t use that item. Try again.'),
          findsOneWidget,
        );
        expect(find.text(item.name), findsOneWidget);
        expect(prefs.getString('shop_inventory'), inventoryJson);
      },
    );
  });
}
