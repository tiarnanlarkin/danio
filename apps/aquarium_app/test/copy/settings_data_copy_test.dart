import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Settings data section keeps backup import out of Preferences', () {
    final source = File(
      'lib/screens/settings/settings_data_section.dart',
    ).readAsStringSync();

    expect(source, contains('Photo Storage'));
    expect(source, contains('Photos are stored locally on your device'));
    expect(source, isNot(contains('Export All Data')));
    expect(source, isNot(contains('Import Data')));
    expect(source, isNot(contains('Share your aquarium data as JSON')));
    expect(source, isNot(contains('Replace all app data with a backup file')));
    expect(source, isNot(contains('Replace all data?')));
    expect(source, isNot(contains('FilePicker.platform.pickFiles')));
    expect(source, isNot(contains('writeAsString(contents)')));
    expect(source, isNot(contains('Invalid backup file')));
  });
}
