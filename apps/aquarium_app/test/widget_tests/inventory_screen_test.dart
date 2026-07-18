// Widget tests for InventoryScreen.
//
// Run: flutter test test/widget_tests/inventory_screen_test.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/data/shop_catalog.dart';
import 'package:danio/models/shop_item.dart';
import 'package:danio/models/tank_decoration.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/providers/inventory_provider.dart';
import 'package:danio/providers/room_theme_provider.dart';
import 'package:danio/providers/room_theme_unlock_provider.dart';
import 'package:danio/providers/tank_decoration_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/inventory_screen.dart';
import 'package:danio/services/room_theme_unlock_service.dart';
import 'package:danio/services/tank_decoration_unlock_service.dart';
import 'package:danio/theme/room_themes.dart';

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

Widget _wrap({
  SharedPreferences? prefs,
  RoomThemeType initialRoomTheme = RoomThemeType.golden,
  Map<RoomThemeType, RoomThemeUnlockState>? roomVibeStates,
  Map<TankDecorationType, TankDecorationUnlockState>? decorationStates,
}) {
  return ProviderScope(
    overrides: [
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
      roomThemeProvider.overrideWith(
        (ref) => _TestRoomThemeNotifier(ref, initialRoomTheme),
      ),
      if (roomVibeStates != null)
        roomThemeUnlockStatesProvider.overrideWith((ref) => roomVibeStates),
      if (decorationStates != null)
        tankDecorationUnlockStatesProvider.overrideWith(
          (ref) => decorationStates,
        ),
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

Map<RoomThemeType, RoomThemeUnlockState> _roomVibeStates({
  RoomThemeType locked = RoomThemeType.aurora,
}) {
  return {
    for (final type in RoomThemeType.values)
      type: RoomThemeUnlockState(
        type: type,
        isUnlocked: type != locked,
        requirementLabel: type == locked
            ? 'Reach 2500 XP to unlock Aurora.'
            : 'Unlocked from the start.',
      ),
  };
}

Map<TankDecorationType, TankDecorationUnlockState> _decorationStates({
  TankDecorationType locked = TankDecorationType.mossyHide,
}) {
  return {
    for (final type in TankDecorationType.values)
      type: TankDecorationUnlockState(
        definition: TankDecorationDefinition.fromType(type),
        isUnlocked: type != locked,
        requirementLabel: type == locked
            ? 'Complete 10 lessons to unlock Mossy Hide.'
            : 'Unlocked from the start.',
      ),
  };
}

class _TestRoomThemeNotifier extends RoomThemeNotifier {
  _TestRoomThemeNotifier(super.ref, RoomThemeType initial) {
    state = initial;
  }

  @override
  Future<bool> setTheme(RoomThemeType theme) async {
    state = theme;
    return true;
  }
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

    testWidgets('tablet keeps consumable inventory cards bounded', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

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

      final itemCard = find
          .ancestor(
            of: find.text(item.name),
            matching: find.byWidgetPredicate((widget) {
              if (widget is! Container) return false;
              final decoration = widget.decoration;
              return decoration is BoxDecoration && decoration.border != null;
            }),
          )
          .first;

      expect(tester.getSize(itemCard).width, lessThanOrEqualTo(340));
    });

    testWidgets(
      'tablet lays permanent reward collections out without sideways scroll',
      (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(2000, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap(
            roomVibeStates: _roomVibeStates(),
            decorationStates: _decorationStates(),
          ),
        );
        await _advance(tester);

        await tester.tap(find.text('Permanent'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        final horizontalScrollViews = tester
            .widgetList<SingleChildScrollView>(
              find.byType(SingleChildScrollView),
            )
            .where((widget) => widget.scrollDirection == Axis.horizontal);

        expect(horizontalScrollViews, isEmpty);
      },
    );

    testWidgets(
      'permanent tab shows earned room vibes without shop purchases',
      (tester) async {
        await tester.pumpWidget(_wrap(roomVibeStates: _roomVibeStates()));
        await _advance(tester);

        await tester.tap(find.text('Permanent'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        expect(find.text('Room vibes'), findsOneWidget);
        expect(find.text('Golden Hour'), findsOneWidget);
        expect(find.text('Aurora'), findsOneWidget);
        expect(find.text('Reach 2500 XP to unlock Aurora.'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('apply-room-vibe-golden')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('locked-room-vibe-aurora')),
          findsOneWidget,
        );
      },
    );

    testWidgets('applying an unlocked room vibe from inventory changes theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          initialRoomTheme: RoomThemeType.ocean,
          roomVibeStates: _roomVibeStates(),
        ),
      );
      await _advance(tester);

      await tester.tap(find.text('Permanent'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final applyPastel = find.byKey(const ValueKey('apply-room-vibe-pastel'));
      await tester.ensureVisible(applyPastel);
      await tester.pump();
      await tester.tap(applyPastel);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(InventoryScreen)),
      );
      expect(container.read(roomThemeProvider), RoomThemeType.pastel);
      expect(find.text('Whimsical applied to your tank.'), findsOneWidget);
    });

    testWidgets('permanent tab shows earned tank decorations', (tester) async {
      await tester.pumpWidget(
        _wrap(
          roomVibeStates: _roomVibeStates(),
          decorationStates: _decorationStates(),
        ),
      );
      await _advance(tester);

      await tester.tap(find.text('Permanent'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Tank decorations'), findsOneWidget);
      expect(find.text('River Stones'), findsOneWidget);
      expect(find.text('Mossy Hide'), findsOneWidget);
      expect(
        find.text('Complete 10 lessons to unlock Mossy Hide.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equip-tank-decoration-riverStones')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('locked-tank-decoration-mossyHide')),
        findsOneWidget,
      );
    });

    testWidgets('equipping a decoration from inventory updates tank cosmetic', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          roomVibeStates: _roomVibeStates(),
          decorationStates: _decorationStates(),
        ),
      );
      await _advance(tester);

      await tester.tap(find.text('Permanent'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final equipDriftwood = find.byKey(
        const ValueKey('equip-tank-decoration-driftwoodArch'),
      );
      await tester.ensureVisible(equipDriftwood);
      await tester.pump();
      await tester.tap(equipDriftwood);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(InventoryScreen)),
      );
      expect(
        container.read(equippedTankDecorationProvider),
        TankDecorationType.driftwoodArch,
      );
      expect(
        find.text('Driftwood Arch placed in your tank.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'expired item cleanup failure shows feedback without changing inventory',
      (tester) async {
        final item = ShopCatalog.getById('xp_boost_1h')!;
        final expiredItem = InventoryItem(
          itemId: item.id,
          quantity: 1,
          expiresAt: DateTime(2026, 6, 18, 12),
          purchasedAt: DateTime(2026, 6, 18, 11),
          isActive: true,
        );
        final inventoryJson = jsonEncode([expiredItem.toJson()]);

        SharedPreferences.setMockInitialValues({
          'shop_inventory': inventoryJson,
        });
        final prefs = await SharedPreferences.getInstance();
        final throwingPrefs = _ThrowingSetStringPrefs(
          prefs,
          (key, _) => key == 'shop_inventory',
        );
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith(
              (ref) async => throwingPrefs,
            ),
            roomThemeProvider.overrideWith(
              (ref) => _TestRoomThemeNotifier(ref, RoomThemeType.golden),
            ),
          ],
        );
        addTearDown(container.dispose);
        final inventorySub = container.listen(
          inventoryProvider,
          (_, __) {},
        );
        addTearDown(inventorySub.close);
        for (var i = 0; i < 20; i++) {
          if (container.read(inventoryProvider).hasValue) break;
          await tester.pump();
        }
        expect(container.read(inventoryProvider).hasValue, isTrue);

        Object? uncaughtError;
        await runZonedGuarded(
          () async {
            await tester.pumpWidget(
              UncontrolledProviderScope(
                container: container,
                child: const MaterialApp(home: InventoryScreen()),
              ),
            );
            await _advance(tester);
          },
          (error, _) {
            uncaughtError = error;
          },
        );

        expect(uncaughtError, isNull);
        expect(
          find.text('Couldn\'t update expired items. Try again.'),
          findsOneWidget,
        );
        expect(prefs.getString('shop_inventory'), inventoryJson);
      },
    );

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
