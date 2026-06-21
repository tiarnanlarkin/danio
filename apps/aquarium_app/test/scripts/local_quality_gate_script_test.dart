import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const scriptPath = 'scripts/quality_gates/run_local_quality_gate.ps1';

  test('local quality gate script exists and stays ascii-only', () {
    final script = File(scriptPath);

    expect(script.existsSync(), isTrue);

    final source = script.readAsStringSync();
    expect(source.codeUnits.every((codeUnit) => codeUnit <= 0x7f), isTrue);
  });

  test('local quality gate protects concurrent worktree ownership', () {
    final source = File(scriptPath).readAsStringSync();

    expect(source, contains(r'git status --short -uall'));
    expect(source, contains(r'[switch]$RequireCleanWorktree'));
    expect(source, contains('RequireCleanWorktree'));
  });

  test('local quality gate includes the standard local verification gates', () {
    final source = File(scriptPath).readAsStringSync();

    expect(source, contains('git diff --check'));
    expect(source, contains('"test"'));
    expect(source, contains('--reporter'));
    expect(source, contains('compact'));
    expect(source, contains('"analyze"'));
    expect(source, contains('"build", "apk", "--debug", "--target"'));
    expect(source, contains('lib/main.dart'));
  });

  test(
    'local quality gate can run focused, docs, full, and visual profiles',
    () {
      final source = File(scriptPath).readAsStringSync();

      expect(
        source,
        contains(
          r'[ValidateSet("Focused", "Docs", "Full", "Visual", "AndroidPrep")]',
        ),
      );
      expect(source, contains('test/copy/current_docs_local_truth_test.dart'));
      expect(
        source,
        contains('test/scripts/local_quality_gate_script_test.dart'),
      );
      expect(source, contains('test/golden_tests/mc_card_golden_test.dart'));
      expect(
        source,
        contains('test/golden_tests/empty_room_scene_golden_test.dart'),
      );
    },
  );

  test('local quality gate keeps device and optional paid tooling opt-in', () {
    final source = File(scriptPath).readAsStringSync();

    expect(source, contains(r'[switch]$RunAndroidSmoke'));
    expect(source, contains('scripts/run_android_blackbox_smoke.ps1'));
    expect(source, contains(r'[switch]$RunOptionalTools'));
    expect(source, contains(r'[switch]$StrictOptionalTools'));
    expect(source, contains('osv-scanner'));
    expect(source, contains('dcm'));
    expect(source, contains('cspell'));
    expect(source, contains('vale'));
    expect(source, isNot(contains('Maestro Cloud')));
    expect(source, isNot(contains('BrowserStack')));
    expect(source, isNot(contains('Firebase Test Lab')));
    expect(source, isNot(contains('Sentry')));
    expect(source, isNot(contains('OpenAI API')));
  });
}
