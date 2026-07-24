import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void _expectAscii(String path) {
  final source = _source(path);
  expect(
    source.codeUnits.every((codeUnit) => codeUnit <= 0x7f),
    isTrue,
    reason: path,
  );
}

void main() {
  const livePreviewScript = 'scripts/run_danio_live_preview.ps1';
  const flutterWrapperScript = 'scripts/flutterw.ps1';
  const screenshotScript = 'scripts/capture_danio_screen.ps1';
  const workflowDoc = 'docs/agent/LIVE_PREVIEW_WORKFLOW.md';

  test('live preview scripts and workflow docs exist and stay ascii-only', () {
    for (final path in [
      livePreviewScript,
      flutterWrapperScript,
      screenshotScript,
      workflowDoc,
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
      _expectAscii(path);
    }
  });

  test('Flutter wrapper resolves the current checkout and installed SDK', () {
    final source = _source(flutterWrapperScript);

    expect(source, contains(r'$PSScriptRoot'));
    expect(source, contains(r'Get-Command flutter'));
    expect(source, contains(r'development\flutter\bin\flutter.bat'));
    expect(source, isNot(contains(r'C:\Users\larki\Documents')));
    expect(source, isNot(contains(r'C:\Users\larki\flutter')));
  });

  test('live preview script targets the dedicated Danio emulator safely', () {
    final source = _source(livePreviewScript);

    expect(source, contains('danio_api36'));
    expect(source, contains('com.tiarnanlarkin.danio'));
    expect(source, contains('flutter run'));
    expect(source, contains('adb devices'));
    expect(source, contains(r'@("emu", "avd", "name")'));
    expect(source, contains('-CheckOnly'));
    expect(source, contains('-LaunchEmulator'));
    expect(source, contains('-WaitSeconds'));
    expect(source, contains('mCurrentFocus'));
    expect(source, contains('mFocusedApp'));
    expect(source, contains('Refusing to take over'));
    expect(source, contains('Android window service is not ready'));
    expect(source, contains('r hot reload'));
    expect(source, contains('R hot restart'));
    expect(source, contains('q quit'));

    for (final forbidden in [
      'kill-server',
      'pm clear',
      'uninstall',
      'wipe-data',
      'emu kill',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('live preview preflight bounds ADB and owns explicit cold boot', () {
    final source = _source(livePreviewScript);

    expect(source, contains(r'[int]$AdbCommandTimeoutSeconds'));
    expect(source, contains(r'[int]$PreflightTimeoutSeconds'));
    expect(source, contains('ProcessStartInfo'));
    expect(source, contains('RedirectStandardError'));
    expect(source, contains('RedirectStandardOutput'));
    expect(source, contains(r'$process.WaitForExit($timeoutMilliseconds)'));
    expect(source, contains(r'$process.Kill()'));
    expect(source, contains('timed out after'));
    expect(source, contains('PREFLIGHT_PHASE|'));
    expect(source, contains('PREFLIGHT_TIMEOUT|phase='));
    expect(source, contains('PREFLIGHT_CLEANUP_TIMEOUT|phase='));
    expect(source, contains(r'@("start-server")'));
    expect(source, contains(r'[switch]$ColdBoot'));
    expect(source, contains(r'@("-list-avds")'));
    expect(
      source,
      contains(r'@("shell", "getprop", "ro.boot.qemu.avd_name")'),
    );
    expect(source, contains('not present in emulator -list-avds'));
    expect(
      source,
      contains(r'$deviceAvd = Get-DeviceAvdName -Serial $DeviceId'),
    );
    expect(source, contains(r'if ($deviceAvd -cne $AvdName)'));
    expect(source, contains("Requested device '\$DeviceId' is AVD"));
    expect(source, contains('ColdBoot requires -LaunchEmulator'));
    expect(source, contains('"-no-snapshot-load"'));
    expect(source, contains('"-no-snapshot-save"'));
    expect(
      source,
      contains('ColdBoot only applies when this script starts the AVD'),
    );
  });

  test('local screenshot script captures evidence from the owned app only', () {
    final source = _source(screenshotScript);

    expect(source, contains('com.tiarnanlarkin.danio'));
    expect(source, contains(r'docs\qa\screenshots\live-preview'));
    expect(source, contains('screencap'));
    expect(source, contains('logcat'));
    expect(source, contains('mCurrentFocus'));
    expect(source, contains('mFocusedApp'));
    expect(source, contains('foreground package'));
    expect(source, contains('Refusing to write outside'));
    expect(source, contains('ProcessStartInfo'));
    expect(source, contains('RedirectStandardError'));
    expect(source, contains('RedirectStandardOutput'));
    expect(source, contains(r'$process.ExitCode'));
    expect(source, isNot(contains(r'2>&1')));
    expect(source, contains(r'$safeDeviceId ='));
    expect(source, contains('HHmmssfff'));
    expect(source, contains(r'screen-$safeDeviceId-$timestamp.png'));
    expect(source, contains(r'focus-$safeDeviceId-$timestamp.txt'));
    expect(source, contains(r'logcat-$safeDeviceId-$timestamp.txt'));
    expect(
      source,
      contains(r'danio-live-preview-$safeDeviceId-$timestamp.png'),
    );
  });

  test('docs make live preview observational and keep gates authoritative', () {
    final workflow = _source(workflowDoc);
    final codexSetup = _source('docs/agent/CODEX_SETUP.md');
    final checklist = _source('docs/agent/TESTING_CHECKLIST.md');
    final multiAgent = _source('docs/agent/MULTI_AGENT_WORKFLOW.md');
    final deviceOwnership = _source('docs/agent/DEVICE_OWNERSHIP.md');
    final rootAgents = _source('../../AGENTS.md');

    for (final source in [
      workflow,
      codexSetup,
      checklist,
      multiAgent,
      rootAgents,
    ]) {
      expect(source, contains('LIVE_PREVIEW_WORKFLOW.md'));
    }

    expect(workflow, contains('observation lane'));
    expect(workflow, contains('does not replace'));
    expect(workflow, contains('Full gate'));
    expect(workflow, contains('danio_api36'));
    expect(workflow, contains('danio_tablet_api36'));
    expect(workflow, contains('Android 16 / API 36'));
    expect(workflow, contains('Pixel-class phone'));
    expect(workflow, contains('Quick Boot'));
    expect(workflow, contains('app-only'));
    expect(workflow, contains('API 24'));
    expect(workflow, contains('compatibility sweep'));
    expect(workflow, contains('not a day-to-day second emulator'));
    expect(workflow, contains('-AdbCommandTimeoutSeconds'));
    expect(workflow, contains('-PreflightTimeoutSeconds 30'));
    expect(workflow, contains('PREFLIGHT_PHASE|'));
    expect(workflow, contains('longer than the internal preflight deadline'));
    expect(workflow, contains('-ColdBoot'));
    expect(workflow, contains('-DeviceId'));
    expect(workflow, contains('does not restart'));
    expect(deviceOwnership, contains('-AdbCommandTimeoutSeconds'));
    expect(deviceOwnership, contains('-PreflightTimeoutSeconds 30'));
    expect(deviceOwnership, contains('-ColdBoot'));
    expect(deviceOwnership, contains('-DeviceId'));
    expect(deviceOwnership, contains('app-only'));
    expect(deviceOwnership, contains('Do not wipe the AVD'));
    expect(
      workflow,
      contains('Only the coordinator or danio_android_qa_owner'),
    );
    expect(checklist, contains('observation lane'));
    expect(checklist, contains('does not replace'));
    expect(multiAgent, contains('live preview'));
    expect(multiAgent, contains('danio_android_qa_owner'));
  });
}
