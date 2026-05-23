import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Glass card token contracts', () {
    test('SoftCard light shadows use named opacity tokens', () {
      final source = File(
        'lib/widgets/core/glass_card.dart',
      ).readAsStringSync();
      final softCardStart = source.indexOf('class SoftCard');
      expect(softCardStart, isNonNegative);

      final softCardSource = source.substring(softCardStart);

      expect(softCardSource, contains('AppColors.blackAlpha03'));
      expect(softCardSource, contains('AppColors.blackAlpha02'));
      expect(softCardSource, isNot(contains('const Color(0x08000000)')));
      expect(softCardSource, isNot(contains('const Color(0x05000000)')));
    });
  });
}
