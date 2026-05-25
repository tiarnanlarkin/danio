import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tank care screen copy does not contain mojibake sequences', () {
    final files = [
      'lib/screens/add_log/add_log_screen.dart',
      'lib/screens/home/home_sheets_tank.dart',
      'lib/screens/tank_detail/tank_detail_screen.dart',
    ];

    final mojibakePattern = RegExp(r'(?:\u00c2|\u00c3|\u00e2)');
    final offenders = <String>[];

    for (final path in files) {
      final contents = File(path).readAsStringSync();
      if (mojibakePattern.hasMatch(contents)) {
        offenders.add(path);
      }
    }

    expect(offenders, isEmpty);
  });
}
