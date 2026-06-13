import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bulk livestock feedback avoids raw emoji and fragile symbols', () {
    final source = File(
      'lib/screens/livestock/livestock_bulk_add_dialog.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(r"'Added ${livestock.count} ${livestock.commonName}'"),
    );
    expect(source, contains(r"'Added ${_items.length} livestock entries.'"));
    expect(source, contains(r"Text('x${i.count}'"));
    expect(source, isNot(contains(r"Text('×${i.count}'")));
    expect(
      source,
      isNot(contains(r"'Added ${livestock.count}× ${livestock.commonName}'")),
    );
    expect(source, isNot(contains(r'\u{1F420}')));
    expect(source, isNot(contains('Welcome aboard, new friends')));
  });
}
