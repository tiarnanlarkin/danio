import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Settings data feedback uses plain sentence copy', () {
    final source = File(
      'lib/screens/settings/settings_data_section.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('Nothing to export yet. Start logging to build your data!'),
    );
    expect(
      source,
      contains('Invalid backup file. Expected Danio export format'),
    );
    expect(
      source,
      isNot(
        contains(
          'Nothing to export yet ${String.fromCharCode(0x2014)} '
          'start logging to build your data!',
        ),
      ),
    );
    expect(
      source,
      isNot(
        contains(
          'Invalid backup file ${String.fromCharCode(0x2014)} '
          'expected Danio export format',
        ),
      ),
    );
  });
}
