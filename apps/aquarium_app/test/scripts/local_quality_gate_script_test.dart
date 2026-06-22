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
      expect(source, contains('test/quality/content_validation_test.dart'));
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
    expect(
      source,
      contains(
        'Invoke-OptionalTool -CommandName "osv-scanner" -Arguments @("scan", "source", "--format=vertical", "--verbosity=error", "--recursive", ".")',
      ),
    );
    expect(
      source,
      isNot(
        contains(
          'Invoke-OptionalTool -CommandName "osv-scanner" -Arguments @("--offline", "--recursive", ".")',
        ),
      ),
    );
    expect(source, isNot(contains('Maestro Cloud')));
    expect(source, isNot(contains('BrowserStack')));
    expect(source, isNot(contains('Firebase Test Lab')));
    expect(source, isNot(contains('Sentry')));
    expect(source, isNot(contains('OpenAI API')));
  });

  test('local lint setup includes strict and Danio-specific checks', () {
    final appPubspec = File('pubspec.yaml').readAsStringSync();
    final analysisOptions = File('analysis_options.yaml').readAsStringSync();
    final gateSource = File(scriptPath).readAsStringSync();

    expect(appPubspec, contains('very_good_analysis:'));
    expect(appPubspec, contains('custom_lint:'));
    expect(appPubspec, contains('dart_code_metrics_presets:'));
    expect(appPubspec, contains('danio_custom_lints:'));

    expect(
      analysisOptions,
      contains('include: package:very_good_analysis/analysis_options.yaml'),
    );
    expect(analysisOptions, contains('plugins:'));
    expect(analysisOptions, contains('custom_lint'));
    expect(analysisOptions, contains('dart_code_metrics:'));
    expect(
      analysisOptions,
      contains('package:dart_code_metrics_presets/recommended.yaml'),
    );

    expect(
      File('tool/danio_custom_lints/pubspec.yaml').existsSync(),
      isTrue,
    );
    expect(
      File('tool/danio_custom_lints/lib/danio_custom_lints.dart').existsSync(),
      isTrue,
    );
    expect(gateSource, contains('dart run custom_lint'));
    expect(gateSource, contains('Clear-CustomLintGeneratedOutputs'));
    expect(gateSource, contains('danio_aquarium_lint_root'));
    expect(gateSource, contains(r'android\app\mnt'));
    expect(gateSource, contains('dcm analyze lib'));
  });

  test('dependabot setup monitors free public dependency ecosystems', () {
    final config = File('../../.github/dependabot.yml');

    expect(config.existsSync(), isTrue);

    final source = config.readAsStringSync();
    expect(source, contains('version: 2'));
    expect(source, contains('package-ecosystem: "pub"'));
    expect(source, contains('directory: "/apps/aquarium_app"'));
    expect(
      source,
      contains('directory: "/apps/aquarium_app/tool/danio_custom_lints"'),
    );
    expect(source, contains('package-ecosystem: "gradle"'));
    expect(source, contains('directory: "/apps/aquarium_app/android"'));
    expect(source, contains('package-ecosystem: "github-actions"'));
    expect(source, contains('directory: "/"'));
    expect(source, contains('open-pull-requests-limit:'));
    expect(source, isNot(contains('registries:')));
    expect(source, isNot(contains('secrets.')));
    expect(source, isNot(contains('token:')));
  });

  test('local quality gate exposes disciplined Patrol smoke checks', () {
    final source = File(scriptPath).readAsStringSync();

    expect(source, contains(r'[switch]$RunPatrolSmoke'));
    expect(source, contains(r'[string]$PatrolDeviceId'));
    expect(source, contains('Resolve-PatrolCommand'));
    expect(source, contains(r'Pub\Cache\bin\patrol.bat'));
    expect(source, contains('integration_test/smoke_test.dart'));
    expect(source, contains('patrol test'));
    expect(source, contains('--device'));
    expect(source, contains('--no-uninstall'));
    expect(source, contains('PATROL_ANALYTICS_ENABLED'));
  });
}
