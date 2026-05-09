import 'dart:typed_data';

import 'package:image/image.dart' as image;

class ImageSanitizationException implements Exception {
  const ImageSanitizationException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'ImageSanitizationException: $message';
}

Uint8List sanitizeFishIdImageBytes(Uint8List bytes, {int quality = 90}) {
  try {
    final decoded = image.decodeImage(bytes);
    if (decoded == null) {
      throw const ImageSanitizationException(
        'Could not decode the selected image.',
      );
    }

    decoded.exif = image.ExifData();
    final encoded = image.encodeJpg(decoded, quality: quality);
    if (encoded.isEmpty) {
      throw const ImageSanitizationException(
        'Could not encode the sanitized image.',
      );
    }

    return Uint8List.fromList(encoded);
  } on ImageSanitizationException {
    rethrow;
  } catch (e) {
    throw ImageSanitizationException(
      'Could not sanitize the selected image.',
      cause: e,
    );
  }
}
