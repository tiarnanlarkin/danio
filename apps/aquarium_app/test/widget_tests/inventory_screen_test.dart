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
import 'package:danio/screens/inventory_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(child: MaterialApp(home: InventoryScreen()));
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
  });
}
