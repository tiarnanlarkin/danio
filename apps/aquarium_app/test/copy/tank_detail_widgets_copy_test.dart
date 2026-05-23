import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tank detail widgets keep visible separator punctuation ASCII-safe', () {
    final files = [
      'lib/screens/tank_detail/widgets/alerts_card.dart',
      'lib/screens/tank_detail/widgets/logs_list.dart',
      'lib/screens/tank_detail/widgets/snapshot_card.dart',
      'lib/screens/tank_detail/widgets/task_preview.dart',
    ];
    final markers = [
      String.fromCharCode(0x2013),
      String.fromCharCode(0x2014),
    ];

    for (final path in files) {
      final source = File(path).readAsStringSync();
      for (final marker in markers) {
        expect(
          source,
          isNot(contains(marker)),
          reason: '$path contains ${marker.codeUnits.join()}',
        );
      }
    }
  });
}
