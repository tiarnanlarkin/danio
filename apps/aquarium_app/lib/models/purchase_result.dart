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
    return PurchaseResult._(success: true, item: item);
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
    return PurchaseResult._(success: false, errorMessage: message);
  }
}
