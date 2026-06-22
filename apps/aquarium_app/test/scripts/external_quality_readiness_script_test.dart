import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const scriptPath =
      'scripts/quality_gates/check_external_quality_readiness.ps1';

  test('external quality readiness script exists and stays ascii-only', () {
    final script = File(scriptPath);

    expect(script.existsSync(), isTrue);

    final source = script.readAsStringSync();
    expect(source.codeUnits.every((codeUnit) => codeUnit <= 0x7f), isTrue);
  });

  test(
    'external quality readiness checks credentials without exposing values',
    () {
      final source = File(scriptPath).readAsStringSync();

      expect(source, contains('BROWSERSTACK_USERNAME'));
      expect(source, contains('BROWSERSTACK_ACCESS_KEY'));
      expect(source, contains('PERCY_TOKEN'));
      expect(source, contains('Test-EnvPresent'));
      expect(source, contains('never commit it'));
      expect(source, isNot(contains(r'Write-Host $value')));
      expect(source, isNot(contains('ConvertTo-SecureString')));
    },
  );

  test('external quality readiness is a preflight, not a cloud runner', () {
    final source = File(scriptPath).readAsStringSync();

    expect(source, contains('gcloud CLI'));
    expect(source, contains('curl.exe'));
    expect(source, contains('Debug APK artifact'));
    expect(source, contains('Android test-suite APK artifact'));
    expect(source, contains('runner compatibility'));
    expect(source, isNot(contains('firebase test android run')));
    expect(source, isNot(contains('api-cloud.browserstack.com')));
    expect(source, isNot(contains('percy exec')));
    expect(source, isNot(contains('maestro cloud')));
  });

  test(
    'external quality readiness can emit json and fail on missing prereqs',
    () {
      final source = File(scriptPath).readAsStringSync();

      expect(source, contains(r'[switch]$Json'));
      expect(source, contains('ConvertTo-Json'));
      expect(source, contains(r'[switch]$RequireReady'));
      expect(source, contains('Missing required external readiness checks'));
      expect(source, contains('exit 1'));
    },
  );
}
