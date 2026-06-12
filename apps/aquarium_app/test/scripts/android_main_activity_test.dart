import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debug QA deep links bypass FlutterActivity route forwarding', () {
    final source = File(
      'android/app/src/main/kotlin/com/tiarnanlarkin/danio/MainActivity.kt',
    ).readAsStringSync();

    final qaCheck = source.indexOf('uri.startsWith("danio://qa")');
    final qaDispatch = source.indexOf('qaLinksChannel?.invokeMethod');
    final qaReturn = source.indexOf('return', qaDispatch);
    final superDispatch = source.indexOf('super.onNewIntent(intent)');

    expect(qaCheck, greaterThanOrEqualTo(0));
    expect(qaDispatch, greaterThan(qaCheck));
    expect(qaReturn, greaterThan(qaDispatch));
    expect(superDispatch, greaterThan(qaReturn));
  });
}
