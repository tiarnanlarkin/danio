import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EmptyRoomScene uses shared alpha tokens for ghost glass styling', () {
    final source = File(
      'lib/screens/home/widgets/empty_room_scene.dart',
    ).readAsStringSync();

    expect(source, contains('AppColors.whiteAlpha15'));
    expect(source, contains('AppColors.whiteAlpha65'));
    expect(source, contains('AppColors.whiteAlpha70'));
    expect(source, contains('AppColors.blackAlpha10'));
    expect(source, contains('AppColors.blackAlpha25'));

    expect(source, isNot(contains('Color(0x26FFFFFF)')));
    expect(source, isNot(contains('Color(0xB3FFFFFF)')));
    expect(source, isNot(contains('Color(0x40000000)')));
    expect(source, isNot(contains('Color(0x1A000000)')));
    expect(source, isNot(contains('Colors.white.withValues')));
  });

  test('AppColors exposes a 65 percent white alpha token', () {
    final source = File('lib/theme/app_colors.dart').readAsStringSync();

    expect(source, contains('0.65 = 0xA6'));
    expect(
      source,
      contains('static const Color whiteAlpha65 = Color(0xA6FFFFFF);'),
    );
  });
}
