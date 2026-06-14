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

  test('livestock removal feedback uses ASCII-safe count text', () {
    final source = File(
      'lib/screens/livestock/livestock_screen.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(r"'Removed ${livestock.count}x ${livestock.commonName}'"),
    );
    expect(
      source,
      contains(r"'${livestock.count}x ${livestock.commonName} removed'"),
    );
    expect(source, contains(r"'${l.count}x ${l.commonName}'"));
    expect(
      source,
      isNot(contains(r"'Removed ${livestock.count}× ${livestock.commonName}'")),
    );
    expect(
      source,
      isNot(contains(r"'${livestock.count}× ${livestock.commonName} removed'")),
    );
    expect(source, isNot(contains(r"'${l.count}× ${l.commonName}'")));
  });
}
