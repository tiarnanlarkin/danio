import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Types of wishlist items
enum WishlistCategory { fish, plant, equipment }

/// A wishlist item (fish, plant, or equipment the user wants)
class WishlistItem {
  final String id;
  final WishlistCategory category;
  final String name;
  final String? species; // Scientific name for fish/plants
  final String? notes;
  final double? estimatedPrice;
  final String? imageUrl;
  final int quantity;
  final bool purchased;
  final DateTime createdAt;
  final DateTime? purchasedAt;

  WishlistItem({
    String? id,
    required this.category,
    required this.name,
    this.species,
    this.notes,
    this.estimatedPrice,
    this.imageUrl,
    this.quantity = 1,
    this.purchased = false,
    DateTime? createdAt,
    this.purchasedAt,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now();

  WishlistItem copyWith({
    String? name,
    String? species,
    String? notes,
    double? estimatedPrice,
    String? imageUrl,
    int? quantity,
    bool? purchased,
    DateTime? purchasedAt,
  }) {
    return WishlistItem(
      id: id,
      category: category,
      name: name ?? this.name,
      species: species ?? this.species,
      notes: notes ?? this.notes,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      purchased: purchased ?? this.purchased,
      createdAt: createdAt,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'name': name,
    'species': species,
    'notes': notes,
    'estimatedPrice': estimatedPrice,
    'imageUrl': imageUrl,
    'quantity': quantity,
    'purchased': purchased,
    'createdAt': createdAt.toIso8601String(),
    'purchasedAt': purchasedAt?.toIso8601String(),
  };

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      category: WishlistCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => WishlistCategory.fish,
      ),
      name: json['name'] as String,
      species: json['species'] as String?,
      notes: json['notes'] as String?,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      purchased: json['purchased'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.parse(json['purchasedAt'] as String)
          : null,
    );
  }
}

/// Budget settings for the shop
class ShopBudget {
  final double monthlyBudget;
  final double spentThisMonth;
  final DateTime lastReset; // When the month counter was last reset

  ShopBudget({
    this.monthlyBudget = 100.0,
    this.spentThisMonth = 0.0,
    DateTime? lastReset,
  }) : lastReset = lastReset ?? DateTime.now();

  double get remaining =>
      (monthlyBudget - spentThisMonth).clamp(0, double.infinity);
  double get percentUsed =>
      monthlyBudget > 0 ? (spentThisMonth / monthlyBudget).clamp(0, 1) : 0;

  ShopBudget copyWith({
    double? monthlyBudget,
    double? spentThisMonth,
    DateTime? lastReset,
  }) {
    return ShopBudget(
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      spentThisMonth: spentThisMonth ?? this.spentThisMonth,
      lastReset: lastReset ?? this.lastReset,
    );
  }

  Map<String, dynamic> toJson() => {
    'monthlyBudget': monthlyBudget,
    'spentThisMonth': spentThisMonth,
    'lastReset': lastReset.toIso8601String(),
  };

  factory ShopBudget.fromJson(Map<String, dynamic> json) {
    return ShopBudget(
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? 100.0,
      spentThisMonth: (json['spentThisMonth'] as num?)?.toDouble() ?? 0.0,
      lastReset: json['lastReset'] != null
          ? DateTime.parse(json['lastReset'] as String)
          : DateTime.now(),
    );
  }
}

/// A local fish shop
@immutable
class LocalShop {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? website;
  final double? distanceMiles;
  final double? rating; // 1-5
  final String? notes;
  final DateTime createdAt;

  LocalShop({
    String? id,
    required this.name,
    this.address,
    this.phone,
    this.website,
    this.distanceMiles,
    this.rating,
    this.notes,
    DateTime? createdAt,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now();

  LocalShop copyWith({
    String? name,
    String? address,
    String? phone,
    String? website,
    double? distanceMiles,
    double? rating,
    String? notes,
  }) {
    return LocalShop(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      distanceMiles: distanceMiles ?? this.distanceMiles,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'phone': phone,
    'website': website,
    'distanceMiles': distanceMiles,
    'rating': rating,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LocalShop.fromJson(Map<String, dynamic> json) {
    return LocalShop(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      distanceMiles: (json['distanceMiles'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
