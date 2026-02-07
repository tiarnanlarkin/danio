import '../models/shop_item.dart';

/// All shop items available in the game
class ShopCatalog {
  static final List<ShopItem> allItems = [
    // ==================== POWER-UPS ====================
    
    ShopItem(
      id: 'xp_boost_1h',
      name: '2x XP Boost',
      description: 'Double XP for 1 hour. Perfect for power learning sessions!',
      emoji: '⚡',
      category: ShopItemCategory.powerUps,
      type: ShopItemType.xpBoost,
      gemCost: 25,
      isConsumable: true,
      durationHours: 1,
      orderIndex: 1,
    ),

    ShopItem(
      id: 'lesson_hints',
      name: 'Lesson Helper',
      description: 'Get helpful hints during your next lesson',
      emoji: '💡',
      category: ShopItemCategory.powerUps,
      type: ShopItemType.lessonHelper,
      gemCost: 15,
      isConsumable: true,
      quantity: 1,
      orderIndex: 2,
    ),

    ShopItem(
      id: 'quiz_retry',
      name: 'Quiz Second Chance',
      description: 'Retry wrong answers in your next quiz',
      emoji: '🎯',
      category: ShopItemCategory.powerUps,
      type: ShopItemType.quizSecondChance,
      gemCost: 20,
      isConsumable: true,
      quantity: 1,
      orderIndex: 3,
    ),

    // ==================== EXTRAS ====================

    ShopItem(
      id: 'streak_freeze',
      name: 'Streak Freeze',
      description: 'Protect your streak for 1 missed day. Stacks with free weekly freeze.',
      emoji: '🧊',
      category: ShopItemCategory.extras,
      type: ShopItemType.streakFreeze,
      gemCost: 30,
      isConsumable: true,
      quantity: 1,
      orderIndex: 10,
    ),

    ShopItem(
      id: 'weekend_pass',
      name: 'Weekend Pass',
      description: 'Reduce your daily goal by 50% for the weekend',
      emoji: '🏖️',
      category: ShopItemCategory.extras,
      type: ShopItemType.goalAdjust,
      gemCost: 40,
      isConsumable: true,
      durationHours: 48,
      orderIndex: 11,
    ),

    ShopItem(
      id: 'daily_goal_shield',
      name: 'Goal Shield',
      description: 'Daily goal counts as complete even if not reached (1 day)',
      emoji: '🛡️',
      category: ShopItemCategory.extras,
      type: ShopItemType.goalAdjust,
      gemCost: 35,
      isConsumable: true,
      quantity: 1,
      orderIndex: 12,
    ),

    // ==================== COSMETICS ====================

    ShopItem(
      id: 'badge_early_bird',
      name: 'Early Bird Badge',
      description: 'Show off your dedication with this special badge',
      emoji: '🐦',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.profileBadge,
      gemCost: 50,
      isConsumable: false,
      orderIndex: 20,
    ),

    ShopItem(
      id: 'badge_night_owl',
      name: 'Night Owl Badge',
      description: 'For the late-night learners',
      emoji: '🦉',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.profileBadge,
      gemCost: 50,
      isConsumable: false,
      orderIndex: 21,
    ),

    ShopItem(
      id: 'celebration_confetti',
      name: 'Confetti Celebration',
      description: 'Unlock confetti effect when completing lessons',
      emoji: '🎉',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.celebrationEffect,
      gemCost: 75,
      isConsumable: false,
      orderIndex: 22,
    ),

    ShopItem(
      id: 'celebration_fireworks',
      name: 'Fireworks Celebration',
      description: 'Epic fireworks when you ace a quiz!',
      emoji: '🎆',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.celebrationEffect,
      gemCost: 100,
      isConsumable: false,
      orderIndex: 23,
    ),

    ShopItem(
      id: 'theme_ocean_depth',
      name: 'Ocean Depths Theme',
      description: 'Beautiful deep ocean background for your profile',
      emoji: '🌊',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.tankTheme,
      gemCost: 150,
      isConsumable: false,
      orderIndex: 24,
    ),

    ShopItem(
      id: 'theme_coral_reef',
      name: 'Coral Reef Theme',
      description: 'Vibrant coral reef background',
      emoji: '🪸',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.tankTheme,
      gemCost: 150,
      isConsumable: false,
      orderIndex: 25,
    ),

    ShopItem(
      id: 'theme_freshwater_zen',
      name: 'Zen Garden Theme',
      description: 'Peaceful planted tank aesthetic',
      emoji: '🌿',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.tankTheme,
      gemCost: 150,
      isConsumable: false,
      orderIndex: 26,
    ),
  ];

  /// Get item by ID
  static ShopItem? getById(String id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get items by category
  static List<ShopItem> getByCategory(ShopItemCategory category) {
    return allItems
        .where((item) => item.category == category && item.isAvailable)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  /// Get all available items
  static List<ShopItem> get availableItems {
    return allItems.where((item) => item.isAvailable).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }
}
