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
      final normalized = source.replaceAll('\r\n', '\n');

      expect(
        source,
        contains(
          r'[ValidateSet("Focused", "Docs", "Full", "Visual", "AndroidPrep")]',
        ),
      );
      expect(source, contains(r'[string[]]$FocusedTests = @()'));
      expect(source, contains('test/copy/current_docs_local_truth_test.dart'));
      expect(
        source,
        contains('test/copy/lean_workflow_contract_test.dart'),
      );
      expect(
        source,
        contains('test/quality/visual_baseline_manifest_test.dart'),
      );
      expect(source, contains('test/golden_tests/mc_card_golden_test.dart'));
      expect(
        source,
        contains('test/golden_tests/empty_room_scene_golden_test.dart'),
      );
      expect(
        normalized,
        contains(
          'if (\$Profile -eq "Focused" -or \$Profile -eq "Visual") {\n'
          '  if (\$FocusedTests.Count -eq 0) {',
        ),
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
    expect(dependencyValidatorConfig, contains('android/app/mnt/**'));
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
    expect(gateSource, contains(r'[switch]$ResetGeneratedOutputs'));
    expect(
      normalizedGateSource,
      isNot(
        contains(
          'function Invoke-DependencyValidator {\n'
          '  Invoke-Step -Name "Dependency validator" -Command {\n'
          '    Clear-CustomLintGeneratedOutputs',
        ),
      ),
    );
    final customLintFunction = RegExp(
      r'function Invoke-CustomLint \{([\s\S]*?)\n\}',
    ).firstMatch(normalizedGateSource);
    final dependencyFunction = RegExp(
      r'function Invoke-DependencyValidator \{([\s\S]*?)\n\}',
    ).firstMatch(normalizedGateSource);
    expect(customLintFunction, isNotNull);
    expect(dependencyFunction, isNotNull);
    expect(
      customLintFunction!.group(1),
      isNot(contains('Clear-CustomLintGeneratedOutputs')),
    );
    expect(
      dependencyFunction!.group(1),
      isNot(contains('Clear-CustomLintGeneratedOutputs')),
    );
    expect(
      normalizedGateSource,
      contains(
        'if (\$ResetGeneratedOutputs) {\n'
        '  Invoke-Step -Name "Reset generated outputs" -Command {\n'
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
    final normalized = source.replaceAll('\r\n', '\n');

    expect(
      source,
      contains(
        r'& robocopy $emptyDir $resolvedPath /MIR /R:0 /W:0 /NFL /NDL /NJH /NJS /NP | Out-Null',
      ),
    );
    expect(source, contains(r'$robocopyExitCode = $global:LASTEXITCODE'));
    expect(source, contains(r'if ($robocopyExitCode -gt 7)'));
    expect(source, contains(r'with exit code $robocopyExitCode'));
    expect(
      normalized,
      contains(
        '    Remove-Item -LiteralPath \$resolvedPath -Force '
        '-ErrorAction Stop\n'
        '    \$global:LASTEXITCODE = 0',
      ),
    );
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

  test('autonomous completion proof is explicit and never implicit', () {
    final source = File(scriptPath).readAsStringSync();
    final normalized = source.replaceAll('\r\n', '\n');

    expect(source, contains(r'[switch]$RunAutonomyTests'));
    expect(
      source,
      contains('test/scripts/autonomous_completion_script_test.dart'),
    );
    expect(
      normalized,
      contains(
        'function Invoke-AutonomousCompletionBehaviorTests {\n'
        '  Invoke-Step -Name "Autonomous completion behavior tests" -Command {\n'
        '    & powershell -NoProfile -ExecutionPolicy Bypass -File `\n'
        '      "test/scripts/autonomous_completion_behavior_test.ps1"\n'
        '    if (\$global:LASTEXITCODE -ne 0) {\n'
        '      throw "Autonomous completion behavior tests failed."\n'
        '    }\n'
        '  }\n'
        '}',
      ),
    );
    expect(source, contains('function Invoke-AutonomousCompletionDartTests'));
    final docsProfile = RegExp(
      r'  "Docs" \{\n([\s\S]*?)\n  \}\n  "Full" \{',
    ).firstMatch(normalized);
    final fullProfile = RegExp(
      r'  "Full" \{\n([\s\S]*?)\n  \}\n  "Visual" \{',
    ).firstMatch(normalized);
    expect(docsProfile, isNotNull, reason: 'Docs profile block');
    expect(fullProfile, isNotNull, reason: 'Full profile block');
    expect(
      docsProfile!.group(1),
      isNot(contains('Invoke-AutonomousCompletion')),
    );
    expect(
      fullProfile!.group(1),
      isNot(contains('Invoke-AutonomousCompletion')),
    );
    expect(
      normalized,
      contains(
        'if (\$RunAutonomyTests) {\n'
        '  if (\$Profile -ne "Full") {\n'
        '    Invoke-AutonomousCompletionDartTests\n'
        '  }\n'
        '  Invoke-AutonomousCompletionBehaviorTests\n'
        '}',
      ),
    );
    expect(
      source,
      isNot(contains('autonomous_completion_git_fixture_test.ps1')),
      reason: 'Git fixtures remain tier-selected disposable proof',
    );
  });

  test('profile guards preserve PowerShell case-insensitive semantics', () {
    final source = File(scriptPath).readAsStringSync();

    expect(source, contains(r'$Profile -eq "Focused"'));
    expect(source, contains(r'$Profile -eq "Visual"'));
    expect(source, contains(r'$Profile -ne "Full"'));
    expect(source, isNot(contains(r'$Profile -ceq')));
    expect(source, isNot(contains(r'$Profile -cne')));
  });

  test('profile composition avoids duplicate work and reports timings', () {
    final source = File(scriptPath).readAsStringSync();
    final normalized = source.replaceAll('\r\n', '\n');
    final docsProfile = RegExp(
      r'  "Docs" \{\n([\s\S]*?)\n  \}\n  "Full" \{',
    ).firstMatch(normalized)!.group(1)!;
    final fullProfile = RegExp(
      r'  "Full" \{\n([\s\S]*?)\n  \}\n  "Visual" \{',
    ).firstMatch(normalized)!.group(1)!;
    final visualProfile = RegExp(
      r'  "Visual" \{\n([\s\S]*?)\n  \}\n  "AndroidPrep" \{',
    ).firstMatch(normalized)!.group(1)!;
    final androidProfile = RegExp(
      r'  "AndroidPrep" \{\n([\s\S]*?)\n  \}\n\}',
    ).firstMatch(normalized)!.group(1)!;

    expect(docsProfile, contains('Invoke-DocsTests'));
    expect(docsProfile, contains('Invoke-TrackedSigningCredentialGuard'));
    expect(docsProfile, isNot(contains('Invoke-Analyze')));
    expect(docsProfile, isNot(contains('Invoke-DependencyValidator')));
    expect(docsProfile, isNot(contains('Invoke-CustomLint')));

    expect(fullProfile, contains('Invoke-FullTests'));
    expect(fullProfile, isNot(contains('Invoke-FocusedTests')));
    expect(fullProfile, contains('Invoke-DependencyValidator'));
    expect(fullProfile, contains('Invoke-CustomLint'));
    expect(fullProfile, contains('Invoke-Analyze'));
    expect(fullProfile, contains('Invoke-DebugApkBuild'));

    expect(visualProfile, contains('Invoke-VisualTests'));
    expect(visualProfile, contains('Invoke-Analyze'));
    expect(visualProfile, isNot(contains('Invoke-DependencyValidator')));
    expect(androidProfile, isNot(contains('Invoke-FocusedTests')));
    expect(androidProfile, contains('Invoke-AndroidDeviceVisibility'));

    expect(source, contains('System.Diagnostics.Stopwatch'));
    expect(source, contains('GATE_TIMING|'));
    expect(source, contains('GATE_TOTAL|'));
    expect(
      normalized.indexOf('GATE_TOTAL|'),
      lessThan(normalized.lastIndexOf('if (\$script:Failures.Count -gt 0)')),
    );
  });

  test('docs and full gates reject tracked Android signing credentials', () {
    final source = File(scriptPath).readAsStringSync();
    final normalized = source.replaceAll('\r\n', '\n');

    expect(
      source,
      contains('scripts/quality_gates/check_tracked_signing_credentials.ps1'),
    );
    expect(
      RegExp(r'\bInvoke-TrackedSigningCredentialGuard\b').allMatches(source),
      hasLength(3),
      reason: 'one function plus Docs and Full invocations',
    );
    final docsProfile = RegExp(
      r'  "Docs" \{\n([\s\S]*?)\n  \}\n  "Full" \{',
    ).firstMatch(normalized);
    final fullProfile = RegExp(
      r'  "Full" \{\n([\s\S]*?)\n  \}\n  "Visual" \{',
    ).firstMatch(normalized);
    expect(docsProfile, isNotNull, reason: 'Docs profile block');
    expect(fullProfile, isNotNull, reason: 'Full profile block');
    expect(
      docsProfile!.group(1),
      contains('Invoke-TrackedSigningCredentialGuard'),
    );
    expect(
      fullProfile!.group(1),
      contains('Invoke-TrackedSigningCredentialGuard'),
    );
  });
}
