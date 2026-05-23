import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Confetti overlay token contracts', () {
    test('shared confetti palettes use named decorative tokens', () {
      final themeSource = File('lib/theme/app_colors.dart').readAsStringSync();
      final overlaySource = File(
        'lib/widgets/celebrations/confetti_overlay.dart',
      ).readAsStringSync();

      expect(
        themeSource,
        contains('static const Color confettiLightGold = Color(0xFFFFE082)'),
      );
      expect(
        themeSource,
        contains('static const Color confettiViolet = Color(0xFFA855F7)'),
      );
      expect(
        themeSource,
        contains('static const Color confettiCyan = Color(0xFF22D3EE)'),
      );

      expect(overlaySource, contains('DanioColors.confettiLightGold'));
      expect(overlaySource, contains('DanioColors.confettiViolet'));
      expect(overlaySource, contains('DanioColors.confettiCyan'));
      expect(overlaySource, isNot(contains('Color(0xFFFFE082)')));
      expect(overlaySource, isNot(contains('Color(0xFFA855F7)')));
      expect(overlaySource, isNot(contains('Color(0xFF22D3EE)')));
      expect(overlaySource, isNot(contains('no exact token')));
    });
  });
}
