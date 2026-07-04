import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('root lifecycle flushes pending gem writes when app detaches', () {
    final source = File('lib/main.dart').readAsStringSync();
    final lifecycleMatch = RegExp(
      r'void didChangeAppLifecycleState\(AppLifecycleState state\) \{'
      r'([\s\S]*?)'
      r'\n  @override\s*\n  Widget build',
    ).firstMatch(source);

    expect(lifecycleMatch, isNotNull);
    final lifecycleBlock = lifecycleMatch!.group(1)!;

    expect(lifecycleBlock, contains('AppLifecycleState.paused'));
    expect(lifecycleBlock, contains('AppLifecycleState.inactive'));
    expect(lifecycleBlock, contains('AppLifecycleState.detached'));
    expect(lifecycleBlock, contains('flushPendingWrite()'));
  });
}
