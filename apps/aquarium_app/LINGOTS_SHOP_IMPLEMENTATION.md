# Lingots/Gems Economy & Shop System Implementation Guide

## 🎯 Overview

This guide details the implementation of a Duolingo-style gem economy and shop system for the Aquarium App. Users earn gems through learning activities and can spend them on power-ups, cosmetics, and utility items.

---

## 📐 Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                     Gem Economy System                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │ Gem Balance  │    │  Shop Items  │    │ Transactions │  │
│  │   Tracking   │◄───┤   Catalog    │◄───┤   History    │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         ▲                    │                    │          │
│         │                    │                    │          │
│         │            ┌───────▼────────┐          │          │
│  ┌──────┴──────┐    │  Purchase Flow │          │          │
│  │ Gem Rewards │    │  & Validation  │          │          │
│  │   System    │    └────────────────┘          │          │
│  └─────────────┘                                 │          │
│         ▲                                        │          │
│         │                                        │          │
│  ┌──────┴────────────────────────────────────────▼──────┐  │
│  │         Integration with XP/Streak System            │  │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Earning Gems**: User actions → XP/Achievement system → Gem rewards
2. **Spending Gems**: Shop interaction → Purchase validation → Balance deduction → Item activation
3. **Persistence**: All transactions logged for audit trail and support

---

## 📊 Data Models

### 1. GemTransaction

```dart
import 'package:flutter/foundation.dart';

enum GemTransactionType {
  earn,        // Earned gems
  spend,       // Spent gems on shop items
  refund,      // Refunded purchase
  grant,       // Admin/promotional grant
  expire,      // Expired item (not used currently)
}

enum GemEarnReason {
  lessonComplete,      // Completed a lesson
  quizPass,           // Passed a quiz
  quizPerfect,        // Got 100% on quiz
  dailyGoalMet,       // Met daily XP goal
  streakMilestone,    // Hit streak milestone (7, 30, 100 days)
  levelUp,            // Reached new XP level
  achievementUnlock,  // Unlocked an achievement
  placementTest,      // Completed placement test
  weeklyBonus,        // Weekly active user bonus
  referralBonus,      // Referred a friend
  promotional,        // Special event/promotion
}

@immutable
class GemTransaction {
  final String id;
  final GemTransactionType type;
  final int amount;              // Positive for earn, negative for spend
  final String? reason;          // GemEarnReason or item name
  final String? itemId;          // If spending, which item was purchased
  final DateTime timestamp;
  final int balanceAfter;        // Balance after this transaction

  const GemTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.reason,
    this.itemId,
    required this.timestamp,
    required this.balanceAfter,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'reason': reason,
    'itemId': itemId,
    'timestamp': timestamp.toIso8601String(),
    'balanceAfter': balanceAfter,
  };

  factory GemTransaction.fromJson(Map<String, dynamic> json) {
    return GemTransaction(
      id: json['id'] as String,
      type: GemTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      amount: json['amount'] as int,
      reason: json['reason'] as String?,
      itemId: json['itemId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      balanceAfter: json['balanceAfter'] as int,
    );
  }
}
```

### 2. ShopItem

```dart
import 'package:flutter/foundation.dart';

enum ShopItemCategory {
  powerUps,      // Lesson helpers, XP boosts
  extras,        // Streak freeze, hearts refill
  cosmetics,     // Profile themes, badges
}

enum ShopItemType {
  // Power-ups
  xpBoost,           // 2x XP for 1 hour
  lessonHelper,      // Show hints in lessons
  quizSecondChance,  // Retry quiz questions
  
  // Extras
  streakFreeze,      // Extra streak protection
  heartsRefill,      // Refill practice hearts (if hearts system exists)
  goalAdjust,        // Reduce daily goal temporarily
  
  // Cosmetics
  profileBadge,      // Decorative badge on profile
  tankTheme,         // Special tank background/theme
  celebrationEffect, // Special completion animations
}

@immutable
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final ShopItemCategory category;
  final ShopItemType type;
  final int gemCost;
  final bool isConsumable;       // Can be used multiple times vs. permanent
  final int? durationHours;      // For time-based items (XP boost, etc.)
  final int? quantity;           // For consumable stacks
  final bool isAvailable;        // Can be toggled for seasonal items
  final String? imageUrl;        // Optional custom image
  final int orderIndex;          // Display order in shop

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.type,
    required this.gemCost,
    this.isConsumable = true,
    this.durationHours,
    this.quantity,
    this.isAvailable = true,
    this.imageUrl,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'emoji': emoji,
    'category': category.name,
    'type': type.name,
    'gemCost': gemCost,
    'isConsumable': isConsumable,
    'durationHours': durationHours,
    'quantity': quantity,
    'isAvailable': isAvailable,
    'imageUrl': imageUrl,
    'orderIndex': orderIndex,
  };

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      category: ShopItemCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      type: ShopItemType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      gemCost: json['gemCost'] as int,
      isConsumable: json['isConsumable'] as bool? ?? true,
      durationHours: json['durationHours'] as int?,
      quantity: json['quantity'] as int?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }
}
```

### 3. UserInventory

```dart
import 'package:flutter/foundation.dart';

@immutable
class InventoryItem {
  final String itemId;
  final int quantity;           // For consumables
  final DateTime? expiresAt;    // For time-based items
  final DateTime purchasedAt;
  final bool isActive;          // Currently in use (for time-based items)

  const InventoryItem({
    required this.itemId,
    this.quantity = 1,
    this.expiresAt,
    required this.purchasedAt,
    this.isActive = false,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid => !isExpired || !isActive;

  InventoryItem copyWith({
    String? itemId,
    int? quantity,
    DateTime? expiresAt,
    DateTime? purchasedAt,
    bool? isActive,
  }) {
    return InventoryItem(
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      expiresAt: expiresAt ?? this.expiresAt,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'quantity': quantity,
    'expiresAt': expiresAt?.toIso8601String(),
    'purchasedAt': purchasedAt.toIso8601String(),
    'isActive': isActive,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      itemId: json['itemId'] as String,
      quantity: json['quantity'] as int? ?? 1,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
```

### 4. Extended UserProfile

Add the following fields to the existing `UserProfile` model:

```dart
// Add to UserProfile class in lib/models/user_profile.dart

class UserProfile {
  // ... existing fields ...
  
  // Gem Economy fields
  final int gems;                                    // Current gem balance
  final List<GemTransaction> gemTransactions;        // Transaction history
  final Map<String, InventoryItem> inventory;        // Owned items
  final List<String> activeEffects;                  // Currently active power-ups

  const UserProfile({
    // ... existing parameters ...
    
    // New parameters with defaults
    this.gems = 0,
    this.gemTransactions = const [],
    this.inventory = const {},
    this.activeEffects = const [],
  });

  // Update copyWith to include new fields
  UserProfile copyWith({
    // ... existing parameters ...
    int? gems,
    List<GemTransaction>? gemTransactions,
    Map<String, InventoryItem>? inventory,
    List<String>? activeEffects,
  }) {
    return UserProfile(
      // ... existing fields ...
      gems: gems ?? this.gems,
      gemTransactions: gemTransactions ?? this.gemTransactions,
      inventory: inventory ?? this.inventory,
      activeEffects: activeEffects ?? this.activeEffects,
    );
  }

  // Update toJson/fromJson to include new fields
  Map<String, dynamic> toJson() => {
    // ... existing fields ...
    'gems': gems,
    'gemTransactions': gemTransactions.map((t) => t.toJson()).toList(),
    'inventory': inventory.map((k, v) => MapEntry(k, v.toJson())),
    'activeEffects': activeEffects,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      // ... existing fields ...
      gems: json['gems'] as int? ?? 0,
      gemTransactions: (json['gemTransactions'] as List<dynamic>?)
          ?.map((t) => GemTransaction.fromJson(t as Map<String, dynamic>))
          .toList() ?? [],
      inventory: (json['inventory'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, InventoryItem.fromJson(v as Map<String, dynamic>)))
          ?? {},
      activeEffects: (json['activeEffects'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }
}
```

---

## 💎 Gem Economy Configuration

### Gem Earning Rates

```dart
// Add to lib/models/learning.dart or create lib/models/gem_economy.dart

class GemRewards {
  // Lesson & Learning
  static const int lessonComplete = 5;
  static const int quizPass = 3;
  static const int quizPerfect = 5;
  static const int placementTest = 10;
  static const int reviewLesson = 2;

  // Daily Goals & Streaks
  static const int dailyGoalMet = 5;
  static const int streak7Days = 10;
  static const int streak30Days = 25;
  static const int streak100Days = 100;

  // Level Progression
  static const int levelUp = 10;
  static const int reachExpert = 50;
  static const int reachMaster = 100;
  static const int reachGuru = 200;

  // Achievements
  static const int achievementBronze = 5;
  static const int achievementSilver = 10;
  static const int achievementGold = 20;
  static const int achievementPlatinum = 50;

  // Bonuses
  static const int weeklyActive = 10;      // Logged in 5+ days this week
  static const int perfectWeek = 25;       // Met daily goal all 7 days
  static const int referralBonus = 50;     // Friend completes onboarding

  /// Calculate gems for streak milestone
  static int getStreakMilestoneReward(int streakDays) {
    if (streakDays == 7) return streak7Days;
    if (streakDays == 14) return streak7Days;
    if (streakDays == 30) return streak30Days;
    if (streakDays == 50) return streak30Days;
    if (streakDays == 100) return streak100Days;
    if (streakDays == 365) return 365;
    return 0;
  }

  /// Calculate gems for level milestone
  static int getLevelUpReward(int newLevel) {
    // Levels from UserProfile.levels map
    if (newLevel == 4) return levelUp;        // Aquarist
    if (newLevel == 5) return reachExpert;    // Expert
    if (newLevel == 6) return reachMaster;    // Master
    if (newLevel == 7) return reachGuru;      // Guru
    return levelUp; // Default for other levels
  }

  /// Calculate gems for achievement tier
  static int getAchievementReward(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return achievementBronze;
      case AchievementTier.silver:
        return achievementSilver;
      case AchievementTier.gold:
        return achievementGold;
      case AchievementTier.platinum:
        return achievementPlatinum;
    }
  }
}
```

### Shop Item Catalog

Create `lib/data/shop_catalog.dart`:

```dart
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
```

---

## 🔌 Integration Points

### 1. UserProfileProvider Extensions

Add to `lib/providers/user_profile_provider.dart`:

```dart
// ==================== GEM ECONOMY METHODS ====================

/// Award gems for an action
Future<void> awardGems({
  required int amount,
  required GemEarnReason reason,
}) async {
  final current = state.value;
  if (current == null || amount <= 0) return;

  final transaction = GemTransaction(
    id: _uuid.v4(),
    type: GemTransactionType.earn,
    amount: amount,
    reason: reason.name,
    timestamp: DateTime.now(),
    balanceAfter: current.gems + amount,
  );

  final updated = current.copyWith(
    gems: current.gems + amount,
    gemTransactions: [...current.gemTransactions, transaction],
    updatedAt: DateTime.now(),
  );

  await _save(updated);
  state = AsyncValue.data(updated);
}

/// Purchase a shop item
Future<PurchaseResult> purchaseItem(ShopItem item) async {
  final current = state.value;
  if (current == null) {
    return PurchaseResult.error('No user profile');
  }

  // Validate purchase
  if (current.gems < item.gemCost) {
    return PurchaseResult.insufficientGems(
      required: item.gemCost,
      available: current.gems,
    );
  }

  // Check if already owned (for non-consumables)
  if (!item.isConsumable && current.inventory.containsKey(item.id)) {
    return PurchaseResult.error('Already owned');
  }

  // Create transaction
  final transaction = GemTransaction(
    id: _uuid.v4(),
    type: GemTransactionType.spend,
    amount: -item.gemCost,
    reason: item.name,
    itemId: item.id,
    timestamp: DateTime.now(),
    balanceAfter: current.gems - item.gemCost,
  );

  // Add/update inventory
  final updatedInventory = Map<String, InventoryItem>.from(current.inventory);
  final now = DateTime.now();
  
  if (item.isConsumable) {
    // Add to existing stack or create new
    final existing = updatedInventory[item.id];
    if (existing != null) {
      updatedInventory[item.id] = existing.copyWith(
        quantity: existing.quantity + (item.quantity ?? 1),
      );
    } else {
      updatedInventory[item.id] = InventoryItem(
        itemId: item.id,
        quantity: item.quantity ?? 1,
        purchasedAt: now,
      );
    }
  } else {
    // Permanent item
    updatedInventory[item.id] = InventoryItem(
      itemId: item.id,
      purchasedAt: now,
    );
  }

  final updated = current.copyWith(
    gems: current.gems - item.gemCost,
    gemTransactions: [...current.gemTransactions, transaction],
    inventory: updatedInventory,
    updatedAt: now,
  );

  await _save(updated);
  state = AsyncValue.data(updated);

  return PurchaseResult.success(item);
}

/// Activate a consumable item
Future<bool> activateItem(String itemId) async {
  final current = state.value;
  if (current == null) return false;

  final inventoryItem = current.inventory[itemId];
  if (inventoryItem == null || inventoryItem.quantity <= 0) {
    return false;
  }

  final shopItem = ShopCatalog.getById(itemId);
  if (shopItem == null) return false;

  final now = DateTime.now();
  final updatedInventory = Map<String, InventoryItem>.from(current.inventory);

  // Decrement quantity
  if (shopItem.isConsumable) {
    final newQuantity = inventoryItem.quantity - 1;
    if (newQuantity <= 0) {
      updatedInventory.remove(itemId);
    } else {
      updatedInventory[itemId] = inventoryItem.copyWith(quantity: newQuantity);
    }
  }

  // Add to active effects if time-based
  final updatedEffects = [...current.activeEffects];
  if (shopItem.durationHours != null) {
    updatedEffects.add('${itemId}:${now.millisecondsSinceEpoch}:${shopItem.durationHours}');
  }

  final updated = current.copyWith(
    inventory: updatedInventory,
    activeEffects: updatedEffects,
    updatedAt: now,
  );

  await _save(updated);
  state = AsyncValue.data(updated);

  return true;
}

/// Check if an effect is currently active
bool hasActiveEffect(ShopItemType effectType) {
  final current = state.value;
  if (current == null) return false;

  final now = DateTime.now().millisecondsSinceEpoch;
  
  for (final effect in current.activeEffects) {
    final parts = effect.split(':');
    if (parts.length != 3) continue;
    
    final itemId = parts[0];
    final startTime = int.tryParse(parts[1]) ?? 0;
    final duration = int.tryParse(parts[2]) ?? 0;
    final endTime = startTime + (duration * 60 * 60 * 1000);
    
    if (now < endTime) {
      final shopItem = ShopCatalog.getById(itemId);
      if (shopItem?.type == effectType) {
        return true;
      }
    }
  }
  
  return false;
}

/// Clean up expired effects
Future<void> cleanupExpiredEffects() async {
  final current = state.value;
  if (current == null) return;

  final now = DateTime.now().millisecondsSinceEpoch;
  final activeEffects = current.activeEffects.where((effect) {
    final parts = effect.split(':');
    if (parts.length != 3) return false;
    
    final startTime = int.tryParse(parts[1]) ?? 0;
    final duration = int.tryParse(parts[2]) ?? 0;
    final endTime = startTime + (duration * 60 * 60 * 1000);
    
    return now < endTime;
  }).toList();

  if (activeEffects.length != current.activeEffects.length) {
    final updated = current.copyWith(
      activeEffects: activeEffects,
      updatedAt: DateTime.now(),
    );
    await _save(updated);
    state = AsyncValue.data(updated);
  }
}
```

### 2. Purchase Result Helper

Create `lib/models/purchase_result.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'shop_item.dart';

@immutable
class PurchaseResult {
  final bool success;
  final String? errorMessage;
  final ShopItem? item;
  final int? requiredGems;
  final int? availableGems;

  const PurchaseResult._({
    required this.success,
    this.errorMessage,
    this.item,
    this.requiredGems,
    this.availableGems,
  });

  factory PurchaseResult.success(ShopItem item) {
    return PurchaseResult._(
      success: true,
      item: item,
    );
  }

  factory PurchaseResult.insufficientGems({
    required int required,
    required int available,
  }) {
    return PurchaseResult._(
      success: false,
      errorMessage: 'Not enough gems',
      requiredGems: required,
      availableGems: available,
    );
  }

  factory PurchaseResult.error(String message) {
    return PurchaseResult._(
      success: false,
      errorMessage: message,
    );
  }
}
```

### 3. Integration with Learning Actions

Update existing methods in `UserProfileNotifier`:

```dart
// In completeLesson method, add:
await awardGems(
  amount: GemRewards.lessonComplete,
  reason: GemEarnReason.lessonComplete,
);

// After quiz with 100% score, add:
if (score == maxScore) {
  await awardGems(
    amount: GemRewards.quizPerfect,
    reason: GemEarnReason.quizPerfect,
  );
} else if (passed) {
  await awardGems(
    amount: GemRewards.quizPass,
    reason: GemEarnReason.quizPass,
  );
}

// In recordActivity, after streak milestone:
final streakReward = GemRewards.getStreakMilestoneReward(newStreak);
if (streakReward > 0) {
  await awardGems(
    amount: streakReward,
    reason: GemEarnReason.streakMilestone,
  );
}

// After meeting daily goal:
final todayGoal = DailyGoal.today(
  dailyXpGoal: current.dailyXpGoal,
  dailyXpHistory: current.dailyXpHistory,
);
if (todayGoal.isCompleted && !wasCompletedBefore) {
  await awardGems(
    amount: GemRewards.dailyGoalMet,
    reason: GemEarnReason.dailyGoalMet,
  );
}

// In unlockAchievement, add:
final achievement = Achievements.getById(achievementId);
if (achievement != null) {
  await awardGems(
    amount: GemRewards.getAchievementReward(achievement.tier),
    reason: GemEarnReason.achievementUnlock,
  );
}
```

---

## 🎨 UI Implementation

### 1. Shop Screen

Create `lib/screens/gem_shop_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_item.dart';
import '../data/shop_catalog.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/shop_item_card.dart';
import 'package:confetti/confetti.dart';

/// Colors for the gem shop
class ShopTheme {
  static const gemGold = Color(0xFFFFD700);
  static const gemGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
  );
  static const shopBackground = Color(0xFF1A1A2E);
  static const cardBackground = Color(0xFF16213E);
  static const accent = Color(0xFF0F3460);
}

class GemShopScreen extends ConsumerStatefulWidget {
  const GemShopScreen({super.key});

  @override
  ConsumerState<GemShopScreen> createState() => _GemShopScreenState();
}

class _GemShopScreenState extends ConsumerState<GemShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    final gemBalance = profile?.gems ?? 0;

    return Scaffold(
      backgroundColor: ShopTheme.shopBackground,
      appBar: AppBar(
        title: const Text('Gem Shop'),
        backgroundColor: ShopTheme.accent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '⚡ Power-Ups'),
            Tab(text: '✨ Extras'),
            Tab(text: '🎨 Cosmetics'),
          ],
        ),
        actions: [
          // Gem balance display
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: ShopTheme.gemGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$gemBalance',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryView(ShopItemCategory.powerUps),
              _buildCategoryView(ShopItemCategory.extras),
              _buildCategoryView(ShopItemCategory.cosmetics),
            ],
          ),
          // Confetti overlay for purchases
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryView(ShopItemCategory category) {
    final items = ShopCatalog.getByCategory(category);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No items available',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ShopItemCard(
          item: item,
          onPurchase: () => _handlePurchase(item),
        );
      },
    );
  }

  Future<void> _handlePurchase(ShopItem item) async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.diamond, color: ShopTheme.gemGold),
                const SizedBox(width: 8),
                Text(
                  '${item.gemCost} gems',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your balance: ${profile.gems} gems',
              style: TextStyle(
                color: profile.gems >= item.gemCost
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: profile.gems >= item.gemCost
                ? () => Navigator.pop(context, true)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ShopTheme.gemGold,
              foregroundColor: Colors.black,
            ),
            child: const Text('Purchase'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Process purchase
    final result = await ref.read(userProfileProvider.notifier).purchaseItem(item);

    if (!mounted) return;

    if (result.success) {
      // Show success feedback
      _confettiController.play();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.emoji} Purchased ${item.name}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Purchase failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### 2. Shop Item Card Widget

Create `lib/widgets/shop_item_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_item.dart';
import '../providers/user_profile_provider.dart';
import '../screens/gem_shop_screen.dart';

class ShopItemCard extends ConsumerWidget {
  final ShopItem item;
  final VoidCallback onPurchase;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final isOwned = profile?.inventory.containsKey(item.id) ?? false;
    final canAfford = (profile?.gems ?? 0) >= item.gemCost;
    final quantity = profile?.inventory[item.id]?.quantity ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: ShopTheme.cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isOwned
            ? const BorderSide(color: ShopTheme.gemGold, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: !isOwned || item.isConsumable ? onPurchase : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Item icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: ShopTheme.gemGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.durationHours != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '⏱️ ${item.durationHours}h duration',
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (isOwned && item.isConsumable) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Owned: $quantity',
                        style: const TextStyle(
                          color: ShopTheme.gemGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Price/status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isOwned || item.isConsumable) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: canAfford
                            ? ShopTheme.gemGradient
                            : const LinearGradient(
                                colors: [Colors.grey, Colors.grey],
                              ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.diamond,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.gemCost}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ShopTheme.gemGold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check, color: Colors.black, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'OWNED',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 3. Gem Balance Widget (for Home Screen)

Create `lib/widgets/gem_balance_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../screens/gem_shop_screen.dart';

class GemBalanceWidget extends ConsumerWidget {
  final bool showShopButton;

  const GemBalanceWidget({
    super.key,
    this.showShopButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final gems = profile?.gems ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Gems',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$gems',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (showShopButton) ...[
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GemShopScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFFA500),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.store, size: 18),
                  SizedBox(width: 6),
                  Text('Shop', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

### 4. Gem Reward Animation

Create `lib/widgets/gem_reward_animation.dart`:

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class GemRewardAnimation extends StatefulWidget {
  final int gemAmount;
  final VoidCallback? onComplete;

  const GemRewardAnimation({
    super.key,
    required this.gemAmount,
    this.onComplete,
  });

  @override
  State<GemRewardAnimation> createState() => _GemRewardAnimationState();
}

class _GemRewardAnimationState extends State<GemRewardAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 40,
      ),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.diamond, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    '+${widget.gemAmount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Show gem reward overlay
void showGemReward(BuildContext context, int amount) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.4,
      left: 0,
      right: 0,
      child: Center(
        child: GemRewardAnimation(
          gemAmount: amount,
          onComplete: () => entry.remove(),
        ),
      ),
    ),
  );

  overlay.insert(entry);
}
```

---

## 🧪 Testing Strategy

### Unit Tests

Create `test/models/gem_economy_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/models/gem_transaction.dart';
import 'package:aquarium_app/models/shop_item.dart';
import 'package:aquarium_app/data/shop_catalog.dart';

void main() {
  group('GemTransaction', () {
    test('serialization works correctly', () {
      final transaction = GemTransaction(
        id: 'test-123',
        type: GemTransactionType.earn,
        amount: 50,
        reason: 'lesson_complete',
        timestamp: DateTime(2024, 1, 1),
        balanceAfter: 150,
      );

      final json = transaction.toJson();
      final restored = GemTransaction.fromJson(json);

      expect(restored.id, transaction.id);
      expect(restored.type, transaction.type);
      expect(restored.amount, transaction.amount);
    });
  });

  group('ShopItem', () {
    test('consumable items can be purchased multiple times', () {
      final item = ShopCatalog.getById('xp_boost_1h')!;
      expect(item.isConsumable, true);
    });

    test('permanent items should not be consumable', () {
      final item = ShopCatalog.getById('badge_early_bird')!;
      expect(item.isConsumable, false);
    });
  });

  group('ShopCatalog', () {
    test('all items have valid configurations', () {
      for (final item in ShopCatalog.allItems) {
        expect(item.id, isNotEmpty);
        expect(item.name, isNotEmpty);
        expect(item.gemCost, greaterThan(0));
      }
    });

    test('getByCategory returns correct items', () {
      final powerUps = ShopCatalog.getByCategory(ShopItemCategory.powerUps);
      expect(powerUps.every((i) => i.category == ShopItemCategory.powerUps), true);
    });
  });
}
```

### Integration Tests

Create `test/providers/gem_economy_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquarium_app/providers/user_profile_provider.dart';
import 'package:aquarium_app/models/gem_economy.dart';
import 'package:aquarium_app/data/shop_catalog.dart';

void main() {
  group('Gem Economy Integration', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('awarding gems increases balance', () async {
      final notifier = container.read(userProfileProvider.notifier);
      
      // Create profile first
      await notifier.createProfile(
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );

      final initialBalance = container.read(userProfileProvider).value?.gems ?? 0;

      await notifier.awardGems(
        amount: 50,
        reason: GemEarnReason.lessonComplete,
      );

      final newBalance = container.read(userProfileProvider).value?.gems ?? 0;
      expect(newBalance, initialBalance + 50);
    });

    test('purchasing item deducts gems and adds to inventory', () async {
      final notifier = container.read(userProfileProvider.notifier);
      
      await notifier.createProfile(
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );

      // Award enough gems
      await notifier.awardGems(amount: 100, reason: GemEarnReason.promotional);

      final item = ShopCatalog.getById('xp_boost_1h')!;
      final result = await notifier.purchaseItem(item);

      expect(result.success, true);
      
      final profile = container.read(userProfileProvider).value!;
      expect(profile.gems, 100 - item.gemCost);
      expect(profile.inventory.containsKey(item.id), true);
    });

    test('insufficient gems prevents purchase', () async {
      final notifier = container.read(userProfileProvider.notifier);
      
      await notifier.createProfile(
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );

      final item = ShopCatalog.getById('xp_boost_1h')!;
      final result = await notifier.purchaseItem(item);

      expect(result.success, false);
      expect(result.errorMessage, contains('gems'));
    });
  });
}
```

---

## 📱 UI/UX Best Practices

### Visual Feedback

1. **Gem Earnings**: Show animated overlay when gems are earned
2. **Purchase Success**: Confetti animation + sound effect (optional)
3. **Balance Display**: Always visible in app bar or prominent location
4. **Active Effects**: Visual indicator when power-ups are active

### User Guidance

1. **First-time Shop Visit**: Show tutorial overlay
2. **Insufficient Gems**: Suggest ways to earn more (lessons, streaks)
3. **Item Tooltips**: Long-press for detailed item information
4. **Transaction History**: Accessible from settings for transparency

### Accessibility

1. **Color Blind Friendly**: Use icons + text, not just color coding
2. **Screen Reader Support**: Proper semantic labels
3. **Font Scaling**: Respect system font size settings

---

## 🚀 Implementation Checklist

### Phase 1: Data Models (Week 1)
- [ ] Create `GemTransaction` model
- [ ] Create `ShopItem` model
- [ ] Create `InventoryItem` model
- [ ] Create `PurchaseResult` helper
- [ ] Extend `UserProfile` with gem fields
- [ ] Add serialization tests

### Phase 2: Shop Catalog (Week 1)
- [ ] Define `GemRewards` constants
- [ ] Create `ShopCatalog` with 12+ items
- [ ] Balance item prices and earn rates
- [ ] Add catalog validation tests

### Phase 3: Provider Integration (Week 2)
- [ ] Add `awardGems` method
- [ ] Add `purchaseItem` method
- [ ] Add `activateItem` method
- [ ] Add `hasActiveEffect` check
- [ ] Integrate with existing learning methods
- [ ] Add provider tests

### Phase 4: UI Implementation (Week 2-3)
- [ ] Build `GemShopScreen` with tabs
- [ ] Create `ShopItemCard` widget
- [ ] Create `GemBalanceWidget`
- [ ] Create `GemRewardAnimation`
- [ ] Add confetti effects
- [ ] Responsive design for tablets

### Phase 5: Integration (Week 3)
- [ ] Hook gem rewards into lesson completion
- [ ] Hook gem rewards into quiz completion
- [ ] Hook gem rewards into streaks
- [ ] Hook gem rewards into achievements
- [ ] Hook gem rewards into daily goals
- [ ] Add shop access from home screen

### Phase 6: Polish & Testing (Week 4)
- [ ] Add transaction history screen
- [ ] Add first-time tutorial
- [ ] Comprehensive integration testing
- [ ] Performance testing (large inventories)
- [ ] User acceptance testing
- [ ] Balance adjustments based on feedback

---

## 🔧 Configuration & Tuning

### Gem Balance Guidelines

**Target Economy:**
- Average user earns 20-30 gems/day (1 lesson + daily goal)
- Power-ups: 15-25 gems (affordable, encourage use)
- Extras: 30-40 gems (special occasions)
- Cosmetics: 50-150 gems (aspirational, collectible)

**Avoid:**
- ❌ Gems too easy to earn → items feel worthless
- ❌ Gems too hard to earn → frustration, abandonment
- ❌ Items too expensive → never purchased
- ❌ Items too cheap → no excitement

**Monitor:**
- Average gem balance per user
- Purchase frequency by item
- Conversion rate (gems earned → gems spent)
- Time to first purchase

### Seasonal Events

Consider adding limited-time items:
```dart
ShopItem(
  id: 'winter_theme',
  name: 'Winter Wonderland',
  emoji: '❄️',
  category: ShopItemCategory.cosmetics,
  type: ShopItemType.tankTheme,
  gemCost: 100,
  isAvailable: _isWinterSeason(), // Custom logic
),
```

---

## 📊 Analytics & Monitoring

### Key Metrics

1. **Gem Earning Rate**
   - Average gems earned per user per day
   - Breakdown by source (lessons, streaks, achievements)

2. **Gem Spending Rate**
   - Average gems spent per user per day
   - Most/least popular items

3. **Inventory Stats**
   - Average inventory size
   - Most commonly owned items
   - Unused item rate

4. **Economy Health**
   - Inflation/deflation indicators
   - Gem sink effectiveness
   - User satisfaction surveys

### Recommended Logging

```dart
// Log gem earnings
analytics.logEvent(
  name: 'gem_earned',
  parameters: {
    'amount': amount,
    'reason': reason.name,
    'total_balance': balanceAfter,
  },
);

// Log purchases
analytics.logEvent(
  name: 'shop_purchase',
  parameters: {
    'item_id': item.id,
    'item_category': item.category.name,
    'gem_cost': item.gemCost,
    'gems_remaining': balanceAfter,
  },
);
```

---

## 🛡️ Security Considerations

### Client-Side Validation

All implemented validation is **client-side only**. For production:

1. **Never trust client data**: Assume users can modify their local state
2. **Server-side validation**: Implement backend verification for:
   - Gem balance accuracy
   - Purchase legitimacy
   - Transaction audit trail
3. **Checksums**: Consider adding data integrity checks
4. **Rate limiting**: Prevent rapid-fire purchases

### Migration Path to Server

When backend is ready:
1. Replace `SharedPreferences` with API calls
2. Maintain local cache for offline support
3. Sync on app launch and after actions
4. Handle conflict resolution (server wins)

---

## 🎓 User Education

### Onboarding Tips

After first lesson completion:
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Row(
      children: [
        Icon(Icons.diamond, color: Colors.amber),
        SizedBox(width: 8),
        Text('You Earned Gems!'),
      ],
    ),
    content: const Text(
      'Completing lessons, maintaining streaks, and unlocking achievements '
      'earns you gems. Spend them in the Gem Shop on power-ups and cosmetics!',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Got it!'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GemShopScreen()),
          );
        },
        child: const Text('Visit Shop'),
      ),
    ],
  ),
);
```

---

## 📝 Future Enhancements

### Possible Additions

1. **Gift Gems**: Send gems to friends
2. **Daily Gem Bonus**: Login rewards
3. **Gem Challenges**: Special quests for bonus gems
4. **Gem Bundles**: Purchase gems (IAP monetization)
5. **Trading System**: Trade cosmetics with friends
6. **Gem Leaderboard**: Top earners this week
7. **Charity Donations**: Spend gems on real-world impact
8. **Time-Limited Sales**: Flash sales, discounts

---

## 📚 References

### Duolingo Inspiration

- **Lingots/Gems**: Virtual currency earned through learning
- **Streak Freeze**: Protect your streak (available in shop)
- **Power-Ups**: XP boost, timer freeze, etc.
- **Cosmetics**: Outfits, profile themes

### Key Differences for Aquarium App

- **No IAP (Initially)**: Earn gems only through learning (more rewarding)
- **Hobby Focus**: Cosmetics tie to fishkeeping (tank themes, fish badges)
- **Educational Items**: Power-ups enhance learning, not bypass it
- **Generous Economy**: Encourage engagement over monetization

---

## ✅ Success Criteria

The gem shop system is successful if:

1. **Engagement**: 60%+ of active users make at least one purchase
2. **Balance**: Users earn enough gems to purchase 1-2 items/week
3. **Satisfaction**: Positive feedback on item value and pricing
4. **Retention**: Gem system contributes to daily return rate
5. **Learning**: Doesn't detract from educational focus

---

## 🆘 Support & Troubleshooting

### Common Issues

**Issue**: Gems not awarded after lesson
- **Fix**: Check `completeLesson` integration, ensure `awardGems` is called

**Issue**: Purchase succeeds but item not in inventory
- **Fix**: Verify `inventory` serialization in `UserProfile.toJson/fromJson`

**Issue**: Negative gem balance
- **Fix**: Add validation in `purchaseItem` to prevent over-spending

**Issue**: Confetti animation not showing
- **Fix**: Ensure `confetti` package is added to `pubspec.yaml`

---

## 📞 Contact

For implementation questions or design feedback:
- **Developer**: Tiarnan Larkin
- **Repo**: `/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app`

---

**End of Implementation Guide**

*This document should be treated as a living guide—update it as the implementation evolves and user feedback is gathered.*
