import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration_test/phone_performance_harness.dart';

void main() {
  test('performance finder recognizes resized Learn header assets', () {
    final image = Image.asset(
      'assets/images/headers/learn-header-ocean.webp',
      cacheWidth: 800,
      cacheHeight: 480,
    );

    expect(image.image, isA<ResizeImage>());
    expect(
      unwrapPhonePerformanceAssetImage(image.image)?.assetName,
      'assets/images/headers/learn-header-ocean.webp',
    );
    expect(isLearnHeaderAssetImage(image), isTrue);
    expect(
      isLearnHeaderAssetImage(
        Image.asset('assets/images/headers/practice-header-ocean.webp'),
      ),
      isFalse,
    );
  });
}
