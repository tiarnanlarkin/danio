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
  const screenshotScript = 'scripts/capture_danio_screen.ps1';
  const workflowDoc = 'docs/agent/LIVE_PREVIEW_WORKFLOW.md';

  test('live preview scripts and workflow docs exist and stay ascii-only', () {
    for (final path in [
      livePreviewScript,
      screenshotScript,
      workflowDoc,
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
      _expectAscii(path);
    }
  });

  test('live preview script targets the dedicated Danio emulator safely', () {
    final source = _source(livePreviewScript);

    expect(source, contains('danio_api36'));
    expect(source, contains('com.tiarnanlarkin.danio'));
    expect(source, contains('flutter run'));
    expect(source, contains('adb devices'));
    expect(source, contains('emu avd name'));
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
