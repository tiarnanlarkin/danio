import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquarium_app/models/shop_item.dart';
import 'package:aquarium_app/data/shop_catalog.dart';
import 'package:aquarium_app/services/shop_service.dart';
import 'package:aquarium_app/providers/gems_provider.dart';
import 'package:aquarium_app/providers/user_profile_provider.dart';
import 'package:aquarium_app/models/user_profile.dart';
import 'package:aquarium_app/models/tank.dart';
import 'package:aquarium_app/models/gem_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    
    // Create a test profile
    await container.read(userProfileProvider.notifier).createProfile(
      name: 'Test User',
      experienceLevel: ExperienceLevel.beginner,
      primaryTankType: TankType.freshwater,
      goals: [UserGoal.keepFishAlive],
    );
    
    // Wait for gems provider to initialize by checking the state
    int attempts = 0;
    while (container.read(gemsProvider).isLoading && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    // Grant some initial gems for testing
    await container.read(gemsProvider.notifier).grantGems(
      amount: 100,
      reason: 'Test gems',
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Shop Service - Item Ownership', () {
    test('User does not own item initially', () {
      final shopService = container.read(shopServiceProvider);
      final owned = shopService.ownsItem('streak_freeze');
      expect(owned, isFalse);
    });

    test('User owns item after purchase', () async {
      final shopService = container.read(shopServiceProvider);
      final item = ShopCatalog.getById('streak_freeze')!;
      
      final result = await shopService.purchaseItem(item);
      expect(result.success, isTrue);
      
      final owned = shopService.ownsItem('streak_freeze');
      expect(owned, isTrue);
    });

    test('Consumable item quantity increases on multiple purchases', () async {
      final shopService = container.read(shopServiceProvider);
      final item = ShopCatalog.getById('streak_freeze')!;
      
      // Purchase twice
      await shopService.purchaseItem(item);
      await shopService.purchaseItem(item);
      
      final quantity = shopService.getItemQuantity('streak_freeze');
      expect(quantity, equals(2));
    });

    test('Cannot purchase non-consumable item twice', () async {
      final shopService = container.read(shopServiceProvider);
      final item = ShopCatalog.getById('theme_ocean_depth')!;
      
      // First purchase succeeds
      final firstResult = await shopService.purchaseItem(item);
      expect(firstResult.success, isTrue);
      
      // Second purchase fails
      final secondResult = await shopService.purchaseItem(item);
      expect(secondResult.success, isFalse);
      expect(secondResult.errorMessage, contains('already own'));
    });
  });

  group('Shop Service - Gem Balance', () {
    test('Gems are deducted on purchase', () async {
      final initialBalance = container.read(gemBalanceProvider);
      final shopService = container.read(shopServiceProvider);
      final item = ShopCatalog.getById('timer_boost')!;
      
      await shopService.purchaseItem(item);
      
      final newBalance = container.read(gemBalanceProvider);
      expect(newBalance, equals(initialBalance - item.gemCost));
    });

    test('Cannot purchase item without enough gems', () async {
      final shopService = container.read(shopServiceProvider);
      
      // Find an expensive item
      final expensiveItem = ShopItem(
        id: 'test_expensive',
        name: 'Expensive Item',
        description: 'Too expensive',
        emoji: '💰',
        category: ShopItemCategory.cosmetics,
        type: ShopItemType.profileBadge,
        gemCost: 10000,
        isConsumable: false,
      );
      
      final result = await shopService.purchaseItem(expensiveItem);
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Not enough gems'));
    });

    test('Purchase validation checks gem balance', () {
      final shopService = container.read(shopServiceProvider);
      final currentBalance = container.read(gemBalanceProvider);
      
      // Item we can afford
      final affordableItem = ShopCatalog.getById('timer_boost')!;
      final canPurchaseAffordable = shopService.canPurchase(affordableItem);
      expect(canPurchaseAffordable.success, isTrue);
      
      // Item we cannot afford (create a test one)
      final expensiveItem = ShopItem(
        id: 'test_expensive',
        name: 'Expensive',
        description: 'Too pricey',
        emoji: '💎',
        category: ShopItemCategory.cosmetics,
        type: ShopItemType.profileBadge,
        gemCost: currentBalance + 1000,
        isConsumable: false,
      );
      
      final canPurchaseExpensive = shopService.canPurchase(expensiveItem);
      expect(canPurchaseExpensive.success, isFalse);
    });
  });

  group('Shop Service - Item Usage', () {
    test('Using consumable item decrements quantity', () async {
      final shopService = container.read(shopServiceProvider);
      final item = ShopCatalog.getById('streak_freeze')!;
      
      // Purchase item
      await shopService.purchaseItem(item);
      expect(shopService.getItemQuantity('streak_freeze'), equals(1));
      
      // Use item
      final used = await shopService.useItem('streak_freeze');
      expect(used, isTrue);
      
      // Quantity should be 0 and item removed
      expect(shopService.getItemQuantity('streak_freeze'), equals(0));
      expect(shopService.ownsItem('streak_freeze'), isFalse);
    });

    test('Cannot use item you do not own', () async {
      final shopService = container.read(shopServiceProvider);
      
      final used = await shopService.useItem('nonexistent_item');
      expect(used, isFalse);
    });

    test('Multiple consumable items can be used', () async {
      final shopService = container.read(shopServiceProvider);
      final item = ShopCatalog.getById('streak_freeze')!;
      
      // Purchase 3 items
      await shopService.purchaseItem(item);
      await shopService.purchaseItem(item);
      await shopService.purchaseItem(item);
      expect(shopService.getItemQuantity('streak_freeze'), equals(3));
      
      // Use one
      await shopService.useItem('streak_freeze');
      expect(shopService.getItemQuantity('streak_freeze'), equals(2));
      
      // Use another
      await shopService.useItem('streak_freeze');
      expect(shopService.getItemQuantity('streak_freeze'), equals(1));
    });
  });

  group('Shop Catalog', () {
    test('Shop has minimum required items', () {
      final allItems = ShopCatalog.availableItems;
      expect(allItems.length, greaterThanOrEqualTo(15));
    });

    test('Shop has items in all categories', () {
      final powerUps = ShopCatalog.getByCategory(ShopItemCategory.powerUps);
      final extras = ShopCatalog.getByCategory(ShopItemCategory.extras);
      final cosmetics = ShopCatalog.getByCategory(ShopItemCategory.cosmetics);
      
      expect(powerUps.isNotEmpty, isTrue);
      expect(extras.isNotEmpty, isTrue);
      expect(cosmetics.isNotEmpty, isTrue);
    });

    test('All required Duolingo-style items exist', () {
      // Streak Freeze (10 gems)
      final streakFreeze = ShopCatalog.getById('streak_freeze');
      expect(streakFreeze, isNotNull);
      expect(streakFreeze!.gemCost, equals(10));
      
      // Weekend Amulet (20 gems)
      final weekendAmulet = ShopCatalog.getById('weekend_amulet');
      expect(weekendAmulet, isNotNull);
      expect(weekendAmulet!.gemCost, equals(20));
      
      // Timer Boost (5 gems)
      final timerBoost = ShopCatalog.getById('timer_boost');
      expect(timerBoost, isNotNull);
      expect(timerBoost!.gemCost, equals(5));
      
      // Bonus Skill (15 gems)
      final bonusSkill = ShopCatalog.getById('bonus_skill');
      expect(bonusSkill, isNotNull);
      expect(bonusSkill!.gemCost, equals(15));
    });

    test('Shop items have proper pricing range', () {
      final items = ShopCatalog.availableItems;
      
      // Check for variety in pricing
      final prices = items.map((item) => item.gemCost).toSet();
      expect(prices.length, greaterThan(3)); // At least 4 different price points
      
      // Verify price range
      final minPrice = prices.reduce((a, b) => a < b ? a : b);
      final maxPrice = prices.reduce((a, b) => a > b ? a : b);
      expect(minPrice, greaterThanOrEqualTo(5));
      expect(maxPrice, lessThanOrEqualTo(100));
    });
  });

  group('Inventory Management', () {
    test('User inventory is empty initially', () {
      final profile = container.read(userProfileProvider).value;
      expect(profile?.inventory, isEmpty);
    });

    test('Inventory updates after purchase', () async {
      final shopService = container.read(shopServiceProvider);
      final item = ShopCatalog.getById('streak_freeze')!;
      
      await shopService.purchaseItem(item);
      
      final profile = container.read(userProfileProvider).value;
      expect(profile?.inventory.length, equals(1));
      expect(profile?.inventory.first.itemId, equals('streak_freeze'));
    });

    test('Inventory persists purchased items', () async {
      final shopService = container.read(shopServiceProvider);
      
      // Purchase multiple different items
      await shopService.purchaseItem(ShopCatalog.getById('streak_freeze')!);
      await shopService.purchaseItem(ShopCatalog.getById('timer_boost')!);
      await shopService.purchaseItem(ShopCatalog.getById('badge_early_bird')!);
      
      final inventory = shopService.getInventory();
      expect(inventory.length, equals(3));
    });
  });

  group('Gem Economy Integration', () {
    test('Earning gems through lesson completion', () async {
      final initialBalance = container.read(gemBalanceProvider);
      
      // Simulate lesson completion (via user profile)
      await container.read(userProfileProvider.notifier).completeLesson(
        'test_lesson_1',
        20,
      );
      
      final newBalance = container.read(gemBalanceProvider);
      expect(newBalance, greaterThan(initialBalance));
    });

    test('Earning gems through streak milestones', () async {
      final gemsNotifier = container.read(gemsProvider.notifier);
      final initialBalance = container.read(gemBalanceProvider);
      
      // Award streak milestone gems
      await gemsNotifier.addGems(
        amount: 50,
        reason: GemEarnReason.streakMilestone,
        customReason: '7 day streak',
      );
      
      final newBalance = container.read(gemBalanceProvider);
      expect(newBalance, equals(initialBalance + 50));
    });
  });
}
