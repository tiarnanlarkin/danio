import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('product haptics use only the preference-aware adapter', () {
    const adapterPath = 'lib/utils/haptic_feedback.dart';
    final platformTypePattern = RegExp(r'\bHapticFeedback\b');
    final violations = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final relativePath = entity.path.replaceAll('\\', '/');
      if (relativePath == adapterPath) continue;

      final lines = entity.readAsLinesSync();
      for (var index = 0; index < lines.length; index += 1) {
        if (platformTypePattern.hasMatch(lines[index])) {
          violations.add('$relativePath:${index + 1}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Direct platform haptics bypass the persisted user preference. '
          'Route every call through $adapterPath.\n${violations.join('\n')}',
    );
  });
}
