import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('integration smoke uses flutter drive with the shared driver', () {
    final source = File(
      'scripts/run_integration_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('"drive"'));
    expect(source, contains(r'--driver=$Driver'));
    expect(source, contains(r'--target=$Target'));
    expect(source, contains('test_driver\\integration_test.dart'));
    expect(source, contains('integration_test\\smoke_test_v2.dart'));
  });

  test('integration smoke restores a normal debug APK for APK smoke tests', () {
    final source = File(
      'scripts/run_integration_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains(r'[switch]$SkipDebugApkRebuild'));
    expect(source, contains(r'$driveExitCode = $LASTEXITCODE'));
    expect(source, contains('flutter drive so downstream APK-based smoke tests'));
    expect(source, contains(r'$rebuildArguments = @("build", "apk", "--debug")'));
    expect(source, contains(r'& $FlutterCommand @rebuildArguments'));
  });
}
