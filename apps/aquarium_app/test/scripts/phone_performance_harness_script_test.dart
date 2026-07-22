import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile harness runner owns exact iterations and report inputs', () {
    final script = File(
      'scripts/run_phone_performance_harness.ps1',
    ).readAsStringSync();

    expect(script, contains('integration_test/phone_performance_test.dart'));
    expect(script, contains('--profile'));
    expect(script, contains('--keep-app-running'));
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

  test('profile runner owns a separate attribution-only evidence path', () {
    final script = File(
      'scripts/run_phone_performance_harness.ps1',
    ).readAsStringSync();

    expect(script, contains(r'[switch]$AttributionOnly'));
    expect(script, contains(r'$AttributionOutputPath'));
    expect(script, contains('DANIO_PERF_PHASE=attribution_image'));
    expect(script, contains('DANIO_PERF_PHASE=attribution_interactions'));
    expect(
      script,
      contains('tool/summarize_phone_performance_attribution.dart'),
    );
    expect(script, contains(r'attribution-image-$imageIteration.json'));
    expect(script, contains('attribution-interactions.json'));
    expect(script, contains('0..5'));
  });

  test(
    'ADB stderr is data while the native exit code remains authoritative',
    () {
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
    },
  );

  test('profile harness reads AVD identity from the boot property', () {
    final script = File(
      'scripts/run_phone_performance_harness.ps1',
    ).readAsStringSync();

    expect(
      script,
      contains(r'@("shell", "getprop", "ro.boot.qemu.avd_name")'),
    );
    expect(script, contains(r'if (-not $avdName)'));
    expect(script, contains('returned no AVD identity'));
    expect(script, contains(r'$avdName = $avdName.Trim()'));
    expect(script, contains(r'if ($avdName -cne "danio_api36")'));
    expect(script, isNot(contains(r'@("emu", "avd", "name")')));
  });

  test('profile timings avoid DDS and host-side hierarchy latency', () {
    final script = File(
      'scripts/run_phone_performance_harness.ps1',
    ).readAsStringSync();

    expect(script, contains('--no-dds'));
    expect(script, contains('DANIO_PROFILE_PERFORMANCE=true'));
    expect(script, contains('DANIO_PERF_LAUNCH'));
    expect(script, contains(r'DANIO_PERF_LAUNCH\|{0}\|'));
    expect(script, contains(r'read danioUptime danioIdle < /proc/uptime'));
    expect(script, contains(r'\|$danioUptime'));
    expect(script, isNot(contains('cut -d')));
    expect(script, contains('DANIO_PERF_READY'));
    expect(script, contains('/proc/uptime'));
    expect(script, contains('Wait-TankInteractive'));
    expect(script, contains(r'return $elapsedMilliseconds'));
    expect(script, isNot(contains('ActivityTaskManager:I')));
    expect(
      script,
      isNot(contains('[System.Diagnostics.Stopwatch]::StartNew()')),
    );
  });

  test('integration traces use live benchmark scheduling before tests', () {
    final target = File(
      'integration_test/phone_performance_test.dart',
    ).readAsStringSync();

    final bindingInitialization = target.indexOf(
      'IntegrationTestWidgetsFlutterBinding.ensureInitialized()',
    );
    final expectedFramePolicyAssignment = RegExp(
      r'binding\.framePolicy\s*=\s*'
      r'LiveTestWidgetsFlutterBindingFramePolicy\.benchmarkLive\s*;',
    );
    final framePolicyAssignment = expectedFramePolicyAssignment
        .firstMatch(target)
        ?.start;
    final testRegistration = target.indexOf("testWidgets('records");

    expect(bindingInitialization, greaterThanOrEqualTo(0));
    expect(framePolicyAssignment, isNotNull);
    expect(framePolicyAssignment!, greaterThan(bindingInitialization));
    expect(testRegistration, greaterThan(framePolicyAssignment));
    expect(
      RegExp(r'binding\.framePolicy\s*=').allMatches(target),
      hasLength(1),
    );
    expect(
      target,
      isNot(contains('LiveTestWidgetsFlutterBindingFramePolicy.fadePointers')),
    );
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
      expect(target, contains('const LearnScreen(key: _performanceLearnKey)'));
      expect(target, contains('rootNavigator: true'));
      expect(target, contains('phone-performance-learn-screen'));
      expect(target, contains('RenderImage'));
      expect(target, contains('renderImage.image != null'));
      expect(target, contains('!renderImage.paintBounds.isEmpty'));
      expect(target, contains('tankFeedingPulseProvider'));
      expect(target, contains('LivingRoomScene'));
      expect(target, isNot(contains('_waitForImageFrame')));
      expect(target, isNot(contains("find.text('Feed')")));
      expect(target, isNot(contains('Feeding logged')));
      expect(target, isNot(contains('TankTapInteractionLayer')));
      expect(target, isNot(contains('handleAppLifecycleStateChanged')));

      final imageFinderStart = target.indexOf('final imageFinder =');
      final rawImageFinderStart = target.indexOf('final rawImageFinder =');
      expect(imageFinderStart, greaterThanOrEqualTo(0));
      expect(rawImageFinderStart, greaterThan(imageFinderStart));
      final imageFinderSource = target.substring(
        imageFinderStart,
        rawImageFinderStart,
      );
      expect(imageFinderSource, isNot(contains('.hitTestable()')));
      expect(imageFinderSource, contains('isLearnHeaderAssetImage'));
      expect(imageFinderSource, isNot(contains('widget.image is AssetImage')));
    },
  );

  test(
    'attribution target pairs equal work and isolates test-only scrolling',
    () {
      final target = File(
        'integration_test/phone_performance_test.dart',
      ).readAsStringSync();

      expect(target, contains("'attribution_image'"));
      expect(target, contains("'attribution_interactions'"));
      expect(target, contains('paired_profile_attribution_image'));
      expect(target, contains('paired_profile_attribution_interactions'));
      expect(target, contains('durationPumps: 60'));
      expect(target, contains('durationPumps: 45'));
      expect(target, contains('const Offset(0, -700)'));
      expect(target, contains('const _MinimalPerformanceScrollSurface'));
      expect(target, contains('mount_ready_ms'));
      expect(target, contains('decode_ready_ms'));
      expect(target, contains('paint_ready_ms'));
      expect(target, contains('WidgetsBinding.instance.endOfFrame'));
    },
  );
}
