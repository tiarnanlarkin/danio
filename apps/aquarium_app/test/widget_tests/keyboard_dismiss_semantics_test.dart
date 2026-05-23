import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keyboard-dismiss tap layers stay out of accessibility semantics', () {
    final libDir = Directory('lib');
    final offenders = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (!lines[i].contains(
          'onTap: () => FocusManager.instance.primaryFocus?.unfocus(),',
        )) {
          continue;
        }

        final start = math.max(0, i - 4);
        final window = lines.sublist(start, i + 1).join('\n');
        if (!window.contains('excludeFromSemantics: true')) {
          offenders.add('${entity.path}:${i + 1}');
        }
      }
    }

    expect(offenders, isEmpty);
  });
}
