import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('care sheets use icon widgets instead of raw emoji strings', () {
    final source = File(
      'lib/screens/home/home_sheets_care.dart',
    ).readAsStringSync();

    expect(source, isNot(contains(r'\u{1F')));
    expect(source, isNot(contains(r'\u{2728}')));
    expect(source, isNot(contains(String.fromCharCode(0x2014))));
  });
}
