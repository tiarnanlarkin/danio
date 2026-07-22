import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile harness runner owns exact iterations and report inputs', () {
    final script = File(
      'scripts/run_phone_performance_harness.ps1',
    ).readAsStringSync();

    expect(script, contains('integration_test/phone_performance_test.dart'));
    expect(script, contains('--profile'));
    expect(script, contains('flutter build apk --profile'));
    expect(script, contains('adb install -r'));
    expect(script, contains('"am", "force-stop"'));
    expect(script, contains('KEYCODE_HOME'));
    expect(script, contains('uiautomator'));
    expect(script, contains('DANIO_PRODUCT_COMMIT'));
    expect(script, contains('DANIO_PERF_DEVICE'));
    expect(script, contains('DANIO_PERF_PHASE=image'));
    expect(script, contains('DANIO_PERF_PHASE=interactions'));
    expect(script, contains('0..5'));
    expect(script, contains('tool/summarize_phone_performance.dart'));
    expect(script, contains('build\\integration_response_data.json'));
    expect(script, contains(r'$headCommit = (& git rev-parse HEAD).Trim()'));
    expect(script, contains(r'$ProductCommit -ne $headCommit'));
    expect(script, contains('product-profile.apk'));
    expect(script, contains('Copy-Item'));
    expect(script, contains(r'$restoreProductApk'));
    expect(script, contains(r'$gitStatus = @(& git status --short -uall)'));
    expect(script, contains('Git status failed'));
  });

  test('ADB stderr is data while the native exit code remains authoritative', () {
    final script = File(
      'scripts/run_phone_performance_harness.ps1',
    ).readAsStringSync();

    expect(
      script,
      contains(r'$previousErrorActionPreference = $ErrorActionPreference'),
    );
    expect(script, contains(r'$ErrorActionPreference = "Continue"'));
    expect(script, contains(r'$global:LASTEXITCODE = $null'));
    expect(script, contains(r'$adbExitCode = $global:LASTEXITCODE'));
    expect(
      script,
      contains(r'$ErrorActionPreference = $previousErrorActionPreference'),
    );
    expect(script, contains(r'$null -eq $adbExitCode'));
    expect(
      script,
      contains(r'Invoke-Adb -Arguments @("devices") -Global'),
    );
    expect(script, contains(r'& $AdbExe @adbArguments 2>&1'));
    expect(script, isNot(contains(r'& adb ')));
  });

  test(
    'integration target requires profile mode and real host lifecycle data',
    () {
      final target = File(
        'integration_test/phone_performance_test.dart',
      ).readAsStringSync();

      expect(target, contains('kProfileMode'));
      expect(target, contains("'image'"));
      expect(target, contains("'interactions'"));
      expect(target, contains('watchPerformance'));
      expect(target, contains('const LearnScreen()'));
      expect(target, contains('rootNavigator: true'));
      expect(target, contains('RenderImage'));
      expect(target, contains('renderImage.image != null'));
      expect(target, contains('tankFeedingPulseProvider'));
      expect(target, contains('LivingRoomScene'));
      expect(target, isNot(contains('_waitForImageFrame')));
      expect(target, isNot(contains("find.text('Feed')")));
      expect(target, isNot(contains('Feeding logged')));
      expect(target, isNot(contains('TankTapInteractionLayer')));
      expect(target, isNot(contains('handleAppLifecycleStateChanged')));
    },
  );
}
