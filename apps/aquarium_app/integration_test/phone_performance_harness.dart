import 'package:flutter/material.dart';

AssetImage? unwrapPhonePerformanceAssetImage(ImageProvider provider) {
  Object currentProvider = provider;
  while (currentProvider is ResizeImage) {
    currentProvider = currentProvider.imageProvider;
  }
  return currentProvider is AssetImage ? currentProvider : null;
}

bool isLearnHeaderAssetImage(Widget widget) {
  if (widget is! Image) return false;
  final asset = unwrapPhonePerformanceAssetImage(widget.image);
  return asset != null &&
      asset.assetName.startsWith('assets/images/headers/learn-header-') &&
      asset.assetName.endsWith('.webp');
}
