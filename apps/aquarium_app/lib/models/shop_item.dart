import 'package:flutter/foundation.dart';

enum ShopItemCategory {
  powerUps, // Lesson helpers, XP boosts
  extras, // Streak freeze, hearts refill
  cosmetics, // Profile themes, badges
}

enum ShopItemType {
  // Power-ups
  xpBoost, // 2x XP for 1 hour
  lessonHelper, // Show hints in lessons
  quizSecondChance, // Retry quiz questions
  // Extras
  streakFreeze, // Extra streak protection
  heartsRefill, // Refill practice hearts (if hearts system exists)
  goalAdjust, // Reduce daily goal temporarily
  // Cosmetics
  profileBadge, // Decorative badge on profile
  tankTheme, // Special tank background/theme
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
  final bool isConsumable; // Can be used multiple times vs. permanent
  final int? durationHours; // For time-based items (XP boost, etc.)
  final int? quantity; // For consumable stacks
  final bool isAvailable; // Can be toggled for seasonal items
  final String? imageUrl; // Optional custom image
  final int orderIndex; // Display order in shop

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
      type: ShopItemType.values.firstWhere((e) => e.name == json['type']),
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

@immutable
class InventoryItem {
  final String itemId;
  final int quantity; // For consumables
  final DateTime? expiresAt; // For time-based items
  final DateTime purchasedAt;
  final bool isActive; // Currently in use (for time-based items)

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
