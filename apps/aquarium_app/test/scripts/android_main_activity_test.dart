import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debug QA deep links bypass FlutterActivity route forwarding', () {
    final source = File(
      'android/app/src/main/kotlin/com/tiarnanlarkin/danio/MainActivity.kt',
    ).readAsStringSync();

    final qaCheck = source.indexOf('isDebugQaIntent(intent)');
    final qaDispatch = source.indexOf('qaLinksChannel?.invokeMethod');
    final qaReturn = source.indexOf('return', qaDispatch);
    final superDispatch = source.indexOf('super.onNewIntent(intent)');

    expect(qaCheck, greaterThanOrEqualTo(0));
    expect(qaDispatch, greaterThan(qaCheck));
    expect(qaReturn, greaterThan(qaDispatch));
    expect(superDispatch, greaterThan(qaReturn));
  });

  test('debug QA cold-start links bypass Flutter deep-link route parsing', () {
    final source = File(
      'android/app/src/main/kotlin/com/tiarnanlarkin/danio/MainActivity.kt',
    ).readAsStringSync();

    expect(source, contains('override fun shouldHandleDeeplinking()'));
    expect(source, contains('override fun getInitialRoute()'));
    expect(source, contains('if (isDebugQaIntent(intent)) return false'));
    expect(source, contains('if (isDebugQaIntent(intent)) return "/"'));
  });

  test('profile readiness uses the Android monotonic device clock', () {
    final source = File(
      'android/app/src/main/kotlin/com/tiarnanlarkin/danio/MainActivity.kt',
    ).readAsStringSync();

    expect(
      source,
      contains('SystemClock.elapsedRealtimeNanos() / 1_000_000'),
    );
    expect(source, isNot(contains('1_000_000.0')));
    expect(source, contains('override fun onResume()'));
    expect(source, contains('DANIO_PERF_READY'));
    expect(source, contains('readyReportedForResume'));
    expect(source, isNot(contains('reportFullyDrawn()')));
  });
}
