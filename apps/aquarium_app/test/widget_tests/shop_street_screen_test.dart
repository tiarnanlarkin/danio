// Widget tests for ShopStreetScreen.
//
// Run: flutter test test/widget_tests/shop_street_screen_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/wishlist.dart';
import 'package:danio/providers/wishlist_provider.dart';
import 'package:danio/screens/shop_street_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: ShopStreetScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(seconds: 1));
}

class _FailingRemoveLocalShopsNotifier extends LocalShopsNotifier {
  _FailingRemoveLocalShopsNotifier(super.ref);

  @override
  Future<void> removeShop(String id) async {
    throw StateError('remove shop save failed');
  }
}

class _FailingUndoLocalShopsNotifier extends LocalShopsNotifier {
  _FailingUndoLocalShopsNotifier(super.ref);

  @override
  Future<void> addShop(LocalShop shop) async {
    throw StateError('restore shop save failed');
  }
}

class _DeleteBeforeUpdateLocalShopsNotifier extends LocalShopsNotifier {
  _DeleteBeforeUpdateLocalShopsNotifier(super.ref);

  @override
  Future<void> updateShop(LocalShop shop) async {
    await super.removeShop(shop.id);
    await super.updateShop(shop);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ShopStreetScreen — renders', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(ShopStreetScreen), findsOneWidget);
    });

    testWidgets('shows Shop Street app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Shop Street'), findsWidgets);
    });

    testWidgets('shows fish wishlist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Fish Wishlist'), findsWidgets);
    });

    testWidgets('shows plant wishlist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Plant Wishlist'), findsWidgets);
    });

    testWidgets('shows equipment wishlist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Equipment Wishlist'), findsWidgets);
    });

    testWidgets('uses honest local planning copy, not planned-feature copy', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.text('Gear to compare before buying'), findsOneWidget);
      expect(find.text('Useful boosts and collectible badges'), findsOneWidget);
      expect(find.text('Wishlists, budget, and shops'), findsOneWidget);
      expect(find.textContaining('planned'), findsNothing);
      expect(find.textContaining('coming soon'), findsNothing);
    });

    testWidgets('tablet centers shopping surfaces in a readable rail', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(
        tester.getTopLeft(find.text('Fish Wishlist')).dx,
        greaterThan(650),
      );

      await tester.scrollUntilVisible(
        find.text('Monthly Budget'),
        500,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('Monthly Budget')).dx,
        greaterThan(650),
      );
    });

    testWidgets('saving monthly budget persists it and confirms the save', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      await tester.scrollUntilVisible(
        find.text('Monthly Budget'),
        500,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monthly Budget'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Budget amount'),
        '150',
      );
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Monthly budget saved.'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final savedBudget =
          jsonDecode(prefs.getString('shop_budget')!) as Map<String, dynamic>;
      expect(savedBudget['monthlyBudget'], 150.0);
    });

    testWidgets('adding a local shop saves it and confirms the add', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      await tester.scrollUntilVisible(
        find.text('Local Fish Shops'),
        500,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add a shop'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Shop name'),
        'Coral Corner',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Address (optional)'),
        '4 Reef Lane',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Distance (miles)'),
        '2.4',
      );

      await tester.tap(find.text('Add Shop'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Coral Corner'), findsOneWidget);
      expect(find.text('2.4 miles'), findsOneWidget);
      expect(find.text('Coral Corner added.'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final savedShops =
          jsonDecode(prefs.getString('local_shops')!) as List<dynamic>;
      final savedShop = savedShops.single as Map<String, dynamic>;
      expect(savedShop['name'], 'Coral Corner');
      expect(savedShop['address'], '4 Reef Lane');
      expect(savedShop['distanceMiles'], 2.4);
    });

    testWidgets(
      'editing a stale local shop shows error instead of false success',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'local_shops':
              '[{"id":"shop-stale-edit","name":"Aquatic World",'
              '"address":"12 River Road","phone":null,"website":null,'
              '"distanceMiles":3.5,"rating":4.5,'
              '"notes":"Good plant section",'
              '"createdAt":"${DateTime.now().toIso8601String()}"}]',
        });

        await tester.pumpWidget(
          _wrap(
            overrides: [
              localShopsProvider.overrideWith(
                (ref) => _DeleteBeforeUpdateLocalShopsNotifier(ref),
              ),
            ],
          ),
        );
        await _advance(tester);
        await tester.scrollUntilVisible(
          find.text('Local Fish Shops'),
          500,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Aquatic World'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Shop name'),
          'Reef House',
        );
        await tester.tap(find.text('Save Changes'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(
          find.text('Could not save that shop. Try again in a moment.'),
          findsOneWidget,
        );
        expect(find.text('Reef House saved.'), findsNothing);
        expect(find.text('Edit Shop'), findsOneWidget);
        expect(find.text('Save Changes'), findsOneWidget);

        final prefs = await SharedPreferences.getInstance();
        final savedShops =
            jsonDecode(prefs.getString('local_shops')!) as List<dynamic>;
        expect(savedShops, isEmpty);
      },
    );

    testWidgets('deleting a local shop shows undo and restores it', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'local_shops':
            '[{"id":"shop-undo","name":"Aquatic World",'
            '"address":"12 River Road","phone":null,"website":null,'
            '"distanceMiles":3.5,"rating":4.5,'
            '"notes":"Good plant section",'
            '"createdAt":"${DateTime.now().toIso8601String()}"}]',
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);
      await tester.scrollUntilVisible(
        find.text('Local Fish Shops'),
        500,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aquatic World'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Shop'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aquatic World'), findsNothing);
      expect(find.text('Aquatic World removed'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aquatic World'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final restoredShops =
          jsonDecode(prefs.getString('local_shops')!) as List<dynamic>;
      final restoredShop = restoredShops.single as Map<String, dynamic>;
      expect(restoredShop['id'], 'shop-undo');
      expect(restoredShop['distanceMiles'], 3.5);
      expect(restoredShop['notes'], 'Good plant section');
    });

    testWidgets('failed delete keeps local shop visible with error feedback', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'local_shops':
            '[{"id":"shop-delete-failure","name":"Aquatic World",'
            '"address":"12 River Road","phone":null,"website":null,'
            '"distanceMiles":3.5,"rating":4.5,'
            '"notes":"Good plant section",'
            '"createdAt":"${DateTime.now().toIso8601String()}"}]',
      });

      await tester.pumpWidget(
        _wrap(
          overrides: [
            localShopsProvider.overrideWith(
              (ref) => _FailingRemoveLocalShopsNotifier(ref),
            ),
          ],
        ),
      );
      await _advance(tester);
      await tester.scrollUntilVisible(
        find.text('Local Fish Shops'),
        500,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Shop'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Aquatic World'), findsOneWidget);
      expect(
        find.text('Could not remove Aquatic World. Try again in a moment.'),
        findsOneWidget,
      );
      expect(find.text('Aquatic World removed'), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      final savedShops =
          jsonDecode(prefs.getString('local_shops')!) as List<dynamic>;
      final savedShop = savedShops.single as Map<String, dynamic>;
      expect(savedShop['id'], 'shop-delete-failure');
      expect(savedShop['distanceMiles'], 3.5);
    });

    testWidgets(
      'failed delete undo keeps local shop deleted with error feedback',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'local_shops':
              '[{"id":"shop-undo-failure","name":"Aquatic World",'
              '"address":"12 River Road","phone":null,"website":null,'
              '"distanceMiles":3.5,"rating":4.5,'
              '"notes":"Good plant section",'
              '"createdAt":"${DateTime.now().toIso8601String()}"}]',
        });

        await tester.pumpWidget(
          _wrap(
            overrides: [
              localShopsProvider.overrideWith(
                (ref) => _FailingUndoLocalShopsNotifier(ref),
              ),
            ],
          ),
        );
        await _advance(tester);
        await tester.scrollUntilVisible(
          find.text('Local Fish Shops'),
          500,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Remove Shop'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Aquatic World'), findsNothing);
        expect(find.text('Undo'), findsOneWidget);

        await tester.tap(find.text('Undo'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(find.text('Aquatic World'), findsNothing);
        expect(
          find.text('Could not restore Aquatic World. Try again in a moment.'),
          findsOneWidget,
        );

        final prefs = await SharedPreferences.getInstance();
        final savedShops =
            jsonDecode(prefs.getString('local_shops')!) as List<dynamic>;
        expect(savedShops, isEmpty);
      },
    );
  });
}
