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

  test('local quality gate does not fail successful Flutter stderr warnings', () {
    final source = File(scriptPath).readAsStringSync();

    expect(source, contains('Get-Command flutter -ErrorAction Stop'));
    expect(
      source,
      contains(r'$previousErrorActionPreference = $ErrorActionPreference'),
    );
    expect(source, contains(r'$ErrorActionPreference = "Continue"'));
    expect(source, contains(r'$flutterExitCode = $global:LASTEXITCODE'));
    expect(
      source,
      contains(
        r"flutter $($Arguments -join ' ') failed with exit code $flutterExitCode",
      ),
    );
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
      expect(
        source,
        contains('test/scripts/external_quality_readiness_script_test.dart'),
      );
      expect(source, contains('test/quality/content_validation_test.dart'));
      expect(
        source,
        contains('test/quality/visual_baseline_manifest_test.dart'),
      );
      expect(source, contains('test/golden_tests/mc_card_golden_test.dart'));
      expect(
        source,
        contains('test/golden_tests/empty_room_scene_golden_test.dart'),
      );
    },
  );

  test('local quality gate keeps device and optional external tooling opt-in', () {
    final source = File(scriptPath).readAsStringSync();

    expect(File('.cspell.json').existsSync(), isTrue);
    expect(source, contains(r'[switch]$RunAndroidSmoke'));
    expect(source, contains('scripts/run_android_blackbox_smoke.ps1'));
    expect(source, contains(r'[switch]$RunOptionalTools'));
    expect(source, contains(r'[switch]$StrictOptionalTools'));
    expect(source, contains('osv-scanner'));
    expect(source, contains('cspell'));
    expect(source, contains('vale'));
    expect(source, isNot(contains('dcm')));
    expect(source, contains('Resolve-OsvScannerCommand'));
    expect(source, contains(r'Microsoft\WinGet\Packages'));
    expect(source, contains('Google.OSVScanner'));
    expect(
      source,
      contains(
        '@("scan", "source", "--format=vertical", "--verbosity=error", "--recursive", ".")',
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
    expect(source, contains('"--config", ".cspell.json"'));
    expect(source, contains('"docs/agent"'));
    expect(source, contains('"docs/design"'));
    expect(
      source,
      isNot(
        contains('Invoke-OptionalTool -CommandName "cspell" -Arguments @(".")'),
      ),
    );
    expect(source, isNot(contains('Maestro Cloud')));
    expect(source, isNot(contains('BrowserStack')));
    expect(source, isNot(contains('Firebase Test Lab')));
    expect(source, isNot(contains('Sentry')));
    expect(source, isNot(contains('OpenAI API')));
  });

  test('local prose lint has a narrow offline Vale configuration', () {
    final valeConfig = File('.vale.ini');
    final draftRule = File('.vale/styles/Danio/DraftLanguage.yml');
    final gateSource = File(scriptPath).readAsStringSync();

    expect(valeConfig.existsSync(), isTrue);
    expect(draftRule.existsSync(), isTrue);

    final configSource = valeConfig.readAsStringSync();
    final ruleSource = draftRule.readAsStringSync();

    expect(configSource, contains('StylesPath = .vale/styles'));
    expect(configSource, contains('BasedOnStyles = Danio'));
    expect(configSource, isNot(contains('Packages =')));
    expect(ruleSource, contains('extends: existence'));
    expect(ruleSource, contains('lorem ipsum'));
    expect(gateSource, contains('Resolve-ValeCommand'));
    expect(gateSource, contains('errata-ai.Vale'));
    expect(gateSource, contains('winget install --exact --id errata-ai.Vale'));
    expect(
      gateSource,
      contains(r'$arguments = @("docs/agent", "docs/design")'),
    );
  });

  test('local lint setup includes strict and Danio-specific checks', () {
    final appPubspec = File('pubspec.yaml').readAsStringSync();
    final analysisOptions = File('analysis_options.yaml').readAsStringSync();
    final dependencyValidatorConfig = File(
      'dart_dependency_validator.yaml',
    ).readAsStringSync();
    final gateSource = File(scriptPath).readAsStringSync();
    final normalizedGateSource = gateSource.replaceAll('\r\n', '\n');

    expect(appPubspec, contains('very_good_analysis:'));
    expect(appPubspec, contains('custom_lint:'));
    expect(appPubspec, contains('dependency_validator:'));
    expect(appPubspec, contains('danio_custom_lints:'));
    expect(appPubspec, isNot(contains('dependency_validator:\n  exclude:')));
    expect(dependencyValidatorConfig, contains('build/**'));
    expect(
      dependencyValidatorConfig,
      contains('ios/Flutter/ephemeral/**'),
    );
    expect(
      dependencyValidatorConfig,
      contains('linux/flutter/ephemeral/**'),
    );
    expect(
      dependencyValidatorConfig,
      contains('macos/Flutter/ephemeral/**'),
    );
    expect(dependencyValidatorConfig, contains('tool/danio_custom_lints/**'));
    expect(
      dependencyValidatorConfig,
      contains('windows/flutter/ephemeral/**'),
    );
    expect(dependencyValidatorConfig, contains('danio_custom_lints'));

    expect(
      analysisOptions,
      contains('include: package:very_good_analysis/analysis_options.yaml'),
    );
    expect(analysisOptions, contains('plugins:'));
    expect(analysisOptions, contains('custom_lint'));
    expect(analysisOptions, isNot(contains('dart_code_metrics:')));

    expect(
      File('tool/danio_custom_lints/pubspec.yaml').existsSync(),
      isTrue,
    );
    expect(
      File('tool/danio_custom_lints/lib/danio_custom_lints.dart').existsSync(),
      isTrue,
    );
    expect(gateSource, contains('dart run custom_lint'));
    expect(gateSource, contains('dart run dependency_validator'));
    expect(gateSource, contains('Invoke-DependencyValidator'));
    expect(gateSource, contains('Clear-CustomLintGeneratedOutputs'));
    expect(
      normalizedGateSource,
      contains(
        'function Invoke-DependencyValidator {\n'
        '  Invoke-Step -Name "Dependency validator" -Command {\n'
        '    Clear-CustomLintGeneratedOutputs',
      ),
    );
    expect(gateSource, contains('danio_aquarium_lint_root'));
    expect(gateSource, contains(r'android\app\mnt'));
    expect(gateSource, contains(r'ios\Flutter\ephemeral'));
    expect(gateSource, isNot(contains('dcm analyze lib')));
  });

  test('generated cleanup keeps robocopy output quiet but checks failures', () {
    final source = File(scriptPath).readAsStringSync();

    expect(
      source,
      contains(
        r'& robocopy $emptyDir $resolvedPath /MIR /R:0 /W:0 /NFL /NDL /NJH /NJS /NP | Out-Null',
      ),
    );
    expect(source, contains(r'$robocopyExitCode = $global:LASTEXITCODE'));
    expect(source, contains(r'if ($robocopyExitCode -gt 7)'));
    expect(source, contains(r'with exit code $robocopyExitCode'));
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
