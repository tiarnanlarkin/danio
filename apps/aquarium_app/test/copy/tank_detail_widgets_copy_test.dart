import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tank detail widgets keep visible separator punctuation ASCII-safe', () {
    final files = [
      'lib/screens/tank_detail/widgets/alerts_card.dart',
      'lib/screens/tank_detail/widgets/logs_list.dart',
      'lib/screens/tank_detail/widgets/snapshot_card.dart',
      'lib/screens/tank_detail/widgets/task_preview.dart',
      'lib/screens/tank_detail/widgets/trends_section.dart',
    ];
    final markers = [String.fromCharCode(0x2013), String.fromCharCode(0x2014)];

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

  test('daily care feedback stays quiet and non-decorative', () {
    final files = [
      'lib/screens/tank_detail/tank_detail_screen.dart',
      'lib/screens/tank_detail/widgets/quick_stats.dart',
      'lib/screens/livestock/livestock_screen.dart',
      'lib/screens/livestock/livestock_add_dialog.dart',
    ];
    final disallowed = [
      String.fromCharCode(0x2013),
      String.fromCharCode(0x2014),
      '🐟',
      '🐠',
      r'\u{1F41F}',
      r'\u26a0',
      r'\ufe0f',
      'Feeding logged!',
    ];

    for (final path in files) {
      final source = File(path).readAsStringSync();
      for (final marker in disallowed) {
        expect(
          source,
          isNot(contains(marker)),
          reason: '$path contains noisy daily-care copy: $marker',
        );
      }
    }
  });
}
