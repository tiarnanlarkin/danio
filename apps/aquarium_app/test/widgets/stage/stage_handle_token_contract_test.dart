import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stage handle uses shared alpha tokens for glass colours', () {
    final source = File('lib/widgets/stage/stage_handle.dart').readAsStringSync();

    expect(source, contains('AppColors.whiteAlpha18'));
    expect(source, contains('AppColors.whiteAlpha20'));
    expect(source, contains('AppColors.whiteAlpha45'));
    expect(source, contains('AppColors.whiteAlpha70'));
    expect(source, contains('AppColors.whiteAlpha90'));
    expect(source, contains('AppColors.blackAlpha10'));
    expect(source, contains('AppColors.blackAlpha24'));
    expect(source, contains('AppColors.blackAlpha25'));

    expect(source, isNot(contains('Colors.white.withValues')));
    expect(source, isNot(contains('Colors.black.withValues')));
  });

  test('AppColors exposes exact handle alpha tokens', () {
    final source = File('lib/theme/app_colors.dart').readAsStringSync();

    expect(source, contains('0.18 = 0x2E'));
    expect(source, contains('0.24 = 0x3D'));
    expect(source, contains('0.45 = 0x73'));
    expect(
      source,
      contains('static const Color whiteAlpha18 = Color(0x2EFFFFFF);'),
    );
    expect(
      source,
      contains('static const Color whiteAlpha45 = Color(0x73FFFFFF);'),
    );
    expect(
      source,
      contains('static const Color blackAlpha24 = Color(0x3D000000);'),
    );
  });
}
