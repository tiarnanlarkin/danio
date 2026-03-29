// Golden-path persistence tests.
//
// Covers three critical business flows:
//   1. Gem purchase → gems deducted, item added to inventory
//   2. Lesson complete → XP awarded, lesson marked complete
//   3. Tank create → tank persisted to storage
//
// Run: flutter test test/widget_tests/golden_path_persistence_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/gems_provider.dart';
import 'package:danio/providers/inventory_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/models/gem_transaction.dart';
import 'package:danio/models/shop_item.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/services/storage_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates an isolated ProviderContainer with mocked SharedPreferences and
/// an InMemoryStorageService so tests don't touch the filesystem.
ProviderContainer _makeContainer({InMemoryStorageService? storage}) {
  return ProviderContainer(
    overrides: [
      storageServiceProvider.overrideWithValue(
        storage ?? InMemoryStorageService(),
      ),
    ],
  );
}

/// Waits for a FutureProvider / AsyncNotifier to settle (loading → data).
Future<void> _settle(ProviderContainer c) async {
  // Pump the microtask queue a few times to let async providers resolve.
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Fresh SharedPreferences for every test.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Reset the InMemoryStorageService singleton state between tests.
    // The singleton is shared; calling saveTank etc. leaks across tests
    // unless we use a fresh instance per container.
  });

  // ── Test 1: Gem purchase ──────────────────────────────────────────────────
  group('Persistence: gem purchase', () {
    test('gems deducted and item appears in inventory after purchaseItem', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Seed the user with 100 gems so the purchase can succeed.
      await _settle(container);
      await container.read(gemsProvider.notifier).addGems(
        amount: 100,
        reason: GemEarnReason.lessonComplete,
      );
      await _settle(container);

      final balanceBefore =
          container.read(gemsProvider).valueOrNull?.balance ?? 0;
      expect(balanceBefore, greaterThanOrEqualTo(100));

      // Build a test ShopItem that costs 25 gems.
      const testItem = ShopItem(
        id: 'xp_boost_1h',
        name: '2x XP Boost',
        description: 'Test item',
        emoji: '⚡',
        category: ShopItemCategory.powerUps,
        type: ShopItemType.xpBoost,
        gemCost: 25,
        isConsumable: true,
        orderIndex: 0,
      );

      // Wait for inventory to load (autoDispose provider — read to instantiate).
      final inventoryNotifier = container.read(inventoryProvider.notifier);
      await _settle(container);

      // Perform the purchase.
      final success = await inventoryNotifier.purchaseItem(testItem);
      await _settle(container);

      // Assertions.
      expect(success, isTrue, reason: 'Purchase should succeed with sufficient gems');

      final balanceAfter =
          container.read(gemsProvider).valueOrNull?.balance ?? balanceBefore;
      expect(
        balanceAfter,
        equals(balanceBefore - 25),
        reason: 'Gem balance should be reduced by item cost',
      );

      final inventory = container.read(inventoryProvider).valueOrNull ?? [];
      final purchased = inventory.where((i) => i.itemId == 'xp_boost_1h');
      expect(
        purchased.isNotEmpty,
        isTrue,
        reason: 'Purchased item should appear in inventory',
      );
    });
  });

  // ── Test 2: Lesson complete ───────────────────────────────────────────────
  group('Persistence: lesson complete', () {
    test('XP awarded and lesson marked complete after completeLesson', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Wait for UserProfileNotifier to load from SharedPreferences.
      await _settle(container);
      // Trigger a read so the provider initialises.
      container.read(userProfileProvider);
      await _settle(container);

      const lessonId = 'nitrogen_cycle_1';
      const xpReward = 20;

      final profileBefore = container.read(userProfileProvider).valueOrNull;
      final xpBefore = profileBefore?.totalXp ?? 0;
      expect(
        profileBefore?.completedLessons.contains(lessonId),
        isFalse,
        reason: 'Lesson should not be complete yet',
      );

      // Complete the lesson.
      await container
          .read(userProfileProvider.notifier)
          .completeLesson(lessonId, xpReward);
      await _settle(container);

      final profileAfter = container.read(userProfileProvider).valueOrNull;

      expect(
        profileAfter?.completedLessons.contains(lessonId),
        isTrue,
        reason: 'Lesson should now be in completedLessons',
      );

      expect(
        profileAfter?.totalXp,
        greaterThanOrEqualTo(xpBefore + xpReward),
        reason: 'Total XP should increase by at least the lesson reward',
      );
    });
  });

  // ── Test 3: Tank create ───────────────────────────────────────────────────
  group('Persistence: tank create', () {
    test('tank persisted to storage after saveTank', () async {
      final storage = InMemoryStorageService();
      final container = _makeContainer(storage: storage);
      addTearDown(container.dispose);

      final now = DateTime.now();
      final tank = Tank(
        id: 'test-tank-001',
        name: 'Golden Path Tank',
        type: TankType.freshwater,
        volumeLitres: 100,
        startDate: now,
        targets: WaterTargets.freshwaterTropical(),
        createdAt: now,
        updatedAt: now,
      );

      // Persist directly via StorageService (mirrors CreateTankScreen flow).
      await storage.saveTank(tank);

      // Verify it can be retrieved.
      final retrieved = await storage.getTank(tank.id);
      expect(retrieved, isNotNull, reason: 'Tank should be retrievable after save');
      expect(retrieved!.id, equals(tank.id));
      expect(retrieved.name, equals('Golden Path Tank'));

      // Also verify it appears in getAllTanks.
      final allTanks = await storage.getAllTanks();
      expect(
        allTanks.any((t) => t.id == tank.id),
        isTrue,
        reason: 'Tank should appear in getAllTanks',
      );
    });
  });
}
