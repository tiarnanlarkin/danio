import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:danio/services/fish_id_image_sanitizer.dart';

void main() {
  test('re-encodes images without EXIF application markers', () {
    final source = image.Image(width: 2, height: 2);
    source.clear(image.ColorRgb8(40, 120, 200));
    final jpeg = image.encodeJpg(source, quality: 95);
    final withExif = _insertApp1Segment(
      jpeg,
      utf8.encode('Exif\u0000\u0000GPSLatitude=51.5074;GPSLongitude=-0.1278'),
    );

    expect(_containsAscii(withExif, 'GPSLatitude'), isTrue);

    final sanitized = sanitizeFishIdImageBytes(Uint8List.fromList(withExif));

    expect(image.decodeImage(sanitized), isNotNull);
    expect(_containsAscii(sanitized, 'GPSLatitude'), isFalse);
    expect(_containsAscii(sanitized, 'Exif'), isFalse);
  });

  test('throws instead of returning original bytes when decoding fails', () {
    final invalid = Uint8List.fromList([1, 2, 3, 4]);

    expect(
      () => sanitizeFishIdImageBytes(invalid),
      throwsA(isA<ImageSanitizationException>()),
    );
  });
}

List<int> _insertApp1Segment(List<int> jpeg, List<int> payload) {
  final length = payload.length + 2;
  return [
    jpeg[0],
    jpeg[1],
    0xff,
    0xe1,
    (length >> 8) & 0xff,
    length & 0xff,
    ...payload,
    ...jpeg.skip(2),
  ];
}

bool _containsAscii(List<int> bytes, String needle) {
  return latin1.decode(bytes, allowInvalid: true).contains(needle);
}
