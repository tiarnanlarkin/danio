import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ThemedAquarium uses shared shadow alpha tokens', () {
    final source = File(
      'lib/widgets/room/themed_aquarium.dart',
    ).readAsStringSync();

    expect(source, contains('AppColors.blackAlpha10'));
    expect(source, isNot(contains('Color(0x1A000000)')));
  });
}
