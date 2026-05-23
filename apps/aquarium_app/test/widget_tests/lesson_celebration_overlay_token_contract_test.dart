import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LessonCelebrationOverlay uses shared black alpha tokens', () {
    final themeSource = File('lib/theme/app_colors.dart').readAsStringSync();
    final overlaySource = File(
      'lib/widgets/lesson_celebration_overlay.dart',
    ).readAsStringSync();

    expect(themeSource, contains('blackAlpha18'));
    expect(themeSource, contains('blackAlpha45'));
    expect(overlaySource, contains('AppColors.blackAlpha18'));
    expect(overlaySource, contains('AppColors.blackAlpha45'));
    expect(
      overlaySource,
      isNot(contains('Colors.black.withValues(alpha: 0.18)')),
    );
    expect(
      overlaySource,
      isNot(contains('Colors.black.withValues(alpha: 0.45)')),
    );
  });
}
