import 'package:flutter/foundation.dart';
import '../models/shop_item.dart';

/// All shop items available in the gem shop
/// Duolingo-inspired virtual currency economy
class ShopCatalog {
  static final List<ShopItem> allItems = [
    // ==================== POWER-UPS ====================
    ShopItem(
      id: 'timer_boost',
      name: 'Timer Boost',
      description: '+30 seconds on your next timed lesson. Beat the clock!',
      emoji: '⏱️',
      category: ShopItemCategory.powerUps,
      type: ShopItemType.lessonHelper,
      gemCost: 5,
      isConsumable: true,
      quantity: 1,
      orderIndex: 1,
    ),

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
      orderIndex: 2,
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
      orderIndex: 3,
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
      orderIndex: 4,
    ),

    ShopItem(
      id: 'bonus_skill',
      name: 'Bonus Skill Unlock',
      description: 'Unlock advanced content and bonus lessons',
      emoji: '🎓',
      category: ShopItemCategory.powerUps,
      type: ShopItemType.lessonHelper,
      gemCost: 15,
      isConsumable: false,
      orderIndex: 5,
    ),

    // ==================== EXTRAS ====================
    ShopItem(
      id: 'streak_freeze',
      name: 'Streak Freeze',
      description: 'Protect your streak for 1 missed day. One free skip!',
      emoji: '🧊',
      category: ShopItemCategory.extras,
      type: ShopItemType.streakFreeze,
      gemCost: 10,
      isConsumable: true,
      quantity: 1,
      orderIndex: 10,
    ),

    ShopItem(
      id: 'weekend_amulet',
      name: 'Weekend Amulet',
      description:
          "Weekend doesn't break your streak. Relax on Saturdays & Sundays!",
      emoji: '🏖️',
      category: ShopItemCategory.extras,
      type: ShopItemType.goalAdjust,
      gemCost: 20,
      isConsumable: true,
      durationHours: 48,
      orderIndex: 11,
    ),

    ShopItem(
      id: 'hearts_refill',
      name: 'Hearts Refill',
      description: 'Instantly restore all hearts to full',
      emoji: '❤️',
      category: ShopItemCategory.extras,
      type: ShopItemType.heartsRefill,
      gemCost: 50,
      isConsumable: true,
      quantity: 1,
      orderIndex: 12,
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
      orderIndex: 13,
    ),

    ShopItem(
      id: 'progress_protector',
      name: 'Progress Protector',
      description:
          'Wrong answers won\'t affect your lesson progress (1 lesson)',
      emoji: '🔒',
      category: ShopItemCategory.extras,
      type: ShopItemType.lessonHelper,
      gemCost: 40,
      isConsumable: true,
      quantity: 1,
      orderIndex: 14,
    ),

    // ==================== COSMETICS ====================
    ShopItem(
      id: 'badge_early_bird',
      name: 'Early Bird Badge',
      description: 'Show off your dedication with this special badge',
      emoji: '🐦',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.profileBadge,
      gemCost: 10,
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
      gemCost: 10,
      isConsumable: false,
      orderIndex: 21,
    ),

    ShopItem(
      id: 'badge_perfectionist',
      name: 'Perfectionist Badge',
      description: 'For those who ace every quiz',
      emoji: '💯',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.profileBadge,
      gemCost: 25,
      isConsumable: false,
      orderIndex: 22,
    ),

    ShopItem(
      id: 'celebration_confetti',
      name: 'Confetti Celebration',
      description: 'Unlock confetti effect when completing lessons',
      emoji: '🎉',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.celebrationEffect,
      gemCost: 30,
      isConsumable: false,
      orderIndex: 23,
    ),

    ShopItem(
      id: 'celebration_fireworks',
      name: 'Fireworks Celebration',
      description: 'Epic fireworks when you ace a quiz!',
      emoji: '🎆',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.celebrationEffect,
      gemCost: 50,
      isConsumable: false,
      orderIndex: 24,
    ),

    ShopItem(
      id: 'theme_ocean_depth',
      name: 'Ocean Depths Theme',
      description: 'Beautiful deep ocean background for your profile',
      emoji: '🌊',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.tankTheme,
      gemCost: 50,
      isConsumable: false,
      orderIndex: 25,
    ),

    ShopItem(
      id: 'theme_coral_reef',
      name: 'Coral Reef Theme',
      description: 'Vibrant coral reef background',
      emoji: '🪸',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.tankTheme,
      gemCost: 50,
      isConsumable: false,
      orderIndex: 26,
    ),

    ShopItem(
      id: 'theme_freshwater_zen',
      name: 'Zen Garden Theme',
      description: 'Peaceful planted tank aesthetic',
      emoji: '🌿',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.tankTheme,
      gemCost: 40,
      isConsumable: false,
      orderIndex: 27,
    ),

    ShopItem(
      id: 'theme_rainbow',
      name: 'Rainbow Paradise Theme',
      description: 'Colorful rainbow theme for your profile',
      emoji: '🌈',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.tankTheme,
      gemCost: 45,
      isConsumable: false,
      orderIndex: 28,
    ),

    ShopItem(
      id: 'theme_night_mode',
      name: 'Night Mode Theme',
      description: 'Sleek dark theme with bioluminescent effects',
      emoji: '🌙',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.tankTheme,
      gemCost: 50,
      isConsumable: false,
      orderIndex: 29,
    ),

    // ==================== PREMIUM COSMETICS ====================
    ShopItem(
      id: 'golden_tank_frame',
      name: 'Golden Tank Frame',
      description:
          'A luxurious golden frame for your tank display. Show everyone you mean business!',
      emoji: '🖼️',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.tankTheme,
      gemCost: 150,
      isConsumable: false,
      orderIndex: 30,
    ),

    ShopItem(
      id: 'legendary_badge_display',
      name: 'Legendary Badge Display',
      description:
          'An exclusive showcase for your achievements. Only the dedicated earn this.',
      emoji: '🏅',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.profileBadge,
      gemCost: 250,
      isConsumable: false,
      orderIndex: 31,
    ),

    ShopItem(
      id: 'master_aquarist_title',
      name: 'Master Aquarist Title',
      description:
          'The ultimate title. Displayed on your profile for all to see. True mastery.',
      emoji: '👑',
      category: ShopItemCategory.cosmetics,
      type: ShopItemType.profileBadge,
      gemCost: 500,
      isConsumable: false,
      orderIndex: 32,
    ),
  ];

  /// Get item by ID
  static ShopItem? getById(String id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      debugPrint('Shop item lookup failed for id "$id": $e');
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
