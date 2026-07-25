import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compact Android journey suite is local, pinned, and inspectable', () {
    final source = File(
      'scripts/run_android_user_journeys.ps1',
    ).readAsStringSync();

    expect(source, contains(r'[string]$DeviceId = ""'));
    expect(source, contains('DeviceId is required unless ListOnly is used.'));
    expect(source, contains(r'[switch]$ListOnly'));
    expect(source, contains('JOURNEY|first-run-and-shell'));
    expect(source, contains('JOURNEY|practice-and-tank'));
    expect(source, contains('JOURNEY|learn-smart-and-more'));
    expect(source, contains('run_danio_live_preview.ps1'));
    expect(source, contains('-CheckOnly'));
    expect(source, contains('run_android_blackbox_smoke.ps1'));
    expect(source, contains('-IncludeQaDeepLinks'));
    expect(source, isNot(contains('Maestro Cloud')));
  });

  test('current workflow docs define ownership and non-device inspection', () {
    final source = File(
      'docs/agent/ANDROID_USER_JOURNEY_SUITE.md',
    ).readAsStringSync();

    expect(source, contains(r'.\scripts\run_android_user_journeys.ps1 -ListOnly'));
    expect(source, contains('-DeviceId emulator-5554'));
    expect(source, contains('ClaimHeavy'));
    expect(source, contains('DEVICE_OWNERSHIP.md'));
    expect(source, contains('does not replace'));
  });
}
