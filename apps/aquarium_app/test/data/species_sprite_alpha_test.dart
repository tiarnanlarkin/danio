import 'dart:io';

import 'package:image/image.dart' as image;
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/data/species_unlock_map.dart';

void main() {
  group('species sprite alpha', () {
    for (final speciesId in speciesDisplayNames.keys) {
      test('$speciesId full sprite has transparent cutout edges', () {
        _expectTransparentCutout(speciesAssetPath(speciesId));
      });

      test('$speciesId thumbnail has transparent cutout edges', () {
        _expectTransparentCutout(speciesThumbPath(speciesId));
      });
    }
  });
}

void _expectTransparentCutout(String assetPath) {
  final file = File(assetPath);
  expect(file.existsSync(), isTrue, reason: 'Missing sprite $assetPath');

  final sprite = image.decodeImage(file.readAsBytesSync());
  expect(sprite, isNotNull, reason: 'Could not decode $assetPath');
  final decoded = sprite!;

  var transparentPixels = 0;
  var borderPixels = 0;
  var transparentBorderPixels = 0;

  for (var y = 0; y < decoded.height; y++) {
    for (var x = 0; x < decoded.width; x++) {
      final alpha = decoded.getPixel(x, y).a.toInt();
      if (alpha == 0) transparentPixels++;
      if (x == 0 ||
          y == 0 ||
          x == decoded.width - 1 ||
          y == decoded.height - 1) {
        borderPixels++;
        if (alpha == 0) transparentBorderPixels++;
      }
    }
  }

  expect(
    transparentPixels,
    greaterThan(0),
    reason: '$assetPath must include transparent pixels around the subject',
  );
  expect(
    transparentBorderPixels,
    equals(borderPixels),
    reason: '$assetPath should not carry an opaque rectangular background',
  );
}
