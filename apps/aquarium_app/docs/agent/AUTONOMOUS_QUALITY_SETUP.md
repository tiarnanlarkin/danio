# Danio Autonomous Quality Setup

This setup gives Codex a repeatable local quality workflow for finishing Danio
without silently depending on paid services, cloud runners, external accounts,
or API keys.

## Active Local Gate

Run from `apps/aquarium_app`:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused
```

Profiles:

- `Focused`: worktree visibility, whitespace diff check, current docs truth
  test, local content validation, visual baseline manifest validation, and the
  local gate contract test.
- `Docs`: `Focused` plus Danio custom lint and `flutter analyze`.
- `Full`: `Focused`, Danio custom lint, full `flutter test`,
  `flutter analyze`, and debug APK build.
- `Visual`: `Focused`, the current focused golden tests, and
  `flutter analyze`, with Danio custom lint before visual checks.
- `AndroidPrep`: `Focused`, Danio custom lint, `flutter analyze`, debug APK
  build, and read-only `adb devices` visibility. It does not install, wipe,
  tap, or capture device state.

Useful switches:

- `-RequireCleanWorktree`: fail if any dirty file is present.
- `-SkipApkBuild`: skip the debug APK build when a full/device-prep profile is
  being run only for a quick local check.
- `-RunAndroidSmoke`: run the existing local blackbox smoke script. Use only
  when emulator/device ownership is clear.
- `-RunPatrolSmoke`: run the existing local Patrol smoke test. Use only when
  emulator/device ownership is clear. Pass `-PatrolDeviceId` when more than one
  device is attached. The wrapper resolves `patrol.bat` from the Pub cache when
  the current shell has not picked up the global Dart bin path.
- `-PatrolUninstall`: allow Patrol to uninstall before/after the test. Omit by
  default to avoid disturbing another active session's emulator state.
- `-RunOptionalTools`: run optional local tools when they are installed.
- `-StrictOptionalTools`: fail if an optional tool is missing or fails.

## Default Autonomous Flow

Use this order for normal implementation slices:

1. `git status --short -uall` before editing.
2. Focused failing test for behavior changes.
3. Small implementation slice.
4. `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`.
5. Broaden to `-Profile Docs`, `-Profile Visual`, `-Profile Full`, or
   `-Profile AndroidPrep` based on the files changed.
6. Commit only the intended files.
7. Push after the relevant local gates pass.

## Optional Local Tools

The gate can detect and run these tools when installed locally:

- `osv-scanner scan source --format=vertical --verbosity=error --recursive .`
  for no-cost dependency vulnerability checks. This uses OSV's public
  vulnerability data and requires the local `osv-scanner` binary, but no
  account, key, or paid service.
- `dcm analyze lib` for stricter Dart/Flutter quality rules. Keep this scoped
  to production app code unless a DCM Teams or larger license is explicitly
  provided; DCM Pro is currently the intended paid path.
- `cspell --config .cspell.json --no-progress docs/agent docs/design` for
  scoped spelling checks on the authored agent/design guidance.
- `vale docs/agent docs/design` for scoped prose linting of the authored
  agent/design guidance. Danio keeps a narrow offline Vale config under
  `.vale.ini` and `.vale/styles/Danio/`; do not add downloaded Vale packages or
  hosted prose services without separate approval.

These tools are optional. Missing tools must not block ordinary product work
unless `-StrictOptionalTools` is explicitly supplied.

Install OSV Scanner only as a local CLI binary. Do not add OSV GitHub Actions,
hosted scans, dashboards, or account-backed security products unless the user
explicitly asks for that external setup.

On Windows, the local gate resolves `osv-scanner` from PATH first and then from
the standard winget package folder for `Google.OSVScanner`. This keeps fresh
Codex shells working even when winget installed the binary before PATH updated.
The same pattern is used for Vale through the winget package folder for
`errata-ai.Vale`.

## Local Content Validation

`test/quality/content_validation_test.dart` is part of the default focused
gate. It is deterministic and runs without network access. The validator checks:

- learning content for draft placeholders and fake feature/premium copy;
- lesson quizzes for quiz presence, valid IDs, explanatory answer notes, and
  duplicate answer options;
- lesson and browser care sources for traceable HTTPS references;
- species data for breadth, unique common names, sane care ranges, and
  compatible/avoid-list overlap;
- plant data for breadth, unique names, sane height ranges, known difficulty
  labels, and enough care tips.

When expanding lessons, species, or plant data, run:

```powershell
flutter test test/quality/content_validation_test.dart --reporter compact
```

If a new validator failure points to real content drift, fix the content. If it
points to an intentionally broader content model, update the validator and docs
in the same slice.

## Local Visual Baseline Validation

`test/quality/visual_baseline_manifest_test.dart` is part of the default
focused gate. It checks `docs/design/BASELINES.md` stays limited to the agreed
small visual surface set and that referenced local screenshot/golden evidence
still exists.

When changing visual baseline paths, design docs, or golden-test names, run:

```powershell
flutter test test/quality/visual_baseline_manifest_test.dart --reporter compact
```

If the test fails because a referenced screenshot was intentionally replaced,
update `docs/design/BASELINES.md` and the local evidence in the same slice.

## Local Patrol Android Smoke

Patrol is available as a local-only Android smoke layer for real-device or
emulator confidence. It is not part of the default gate because emulator state
may be shared with other Codex sessions on this machine.

Use:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep -RunPatrolSmoke -PatrolDeviceId emulator-5554
```

The gate runs `patrol test -t integration_test/smoke_test.dart --device <id>
--package-name com.tiarnanlarkin.danio --no-uninstall` by default. Use
`-PatrolUninstall` only when the device is dedicated to this repo and a clean
Patrol install cycle is intended.

## Free GitHub Dependency Updates

`.github/dependabot.yml` is configured after explicit user approval to open
free GitHub pull requests for:

- Flutter/Pub dependencies in `apps/aquarium_app`.
- Pub dependencies in the local `tool/danio_custom_lints` package.
- Android Gradle dependencies in `apps/aquarium_app/android`.
- GitHub Actions used by `.github/workflows`.

The config uses public package ecosystems only. Do not add private registries,
tokens, paid package feeds, or account-specific credentials without a separate
explicit request. Dependabot PRs are review inputs, not automatic approvals:
run the relevant local quality gate before merging any dependency update.

## Static Analysis Stack

Danio uses a layered local lint setup:

- `flutter analyze` with `very_good_analysis` as the baseline lint package.
- `dart run custom_lint` for Danio-specific local rules that generic Flutter
  lints cannot know about.
- Local `danio_custom_lints` rules under `tool/danio_custom_lints/`.
- Optional DCM Pro support through the `dart_code_metrics` configuration in
  `analysis_options.yaml` and the local gate's optional `dcm analyze lib` step.

Use `scripts/quality_gates/run_local_quality_gate.ps1` for the custom-lint
step on Windows. The wrapper clears generated Flutter output that can confuse
workspace discovery and runs `dart run custom_lint` through a temporary
no-space junction because this local repo path contains spaces.

Do not require a DCM license, CI key, dashboard, or cloud account for normal
work. DCM Teams and hosted dashboards remain separate paid upgrades.

## Account-Backed Upgrade Lane

No account-backed service is configured by this setup pass. If the user later
approves a paid or external quality layer, keep it separate from the local core
and do not commit secrets.

Recommended escalation order:

- AI PR review: CodeRabbit or Qodo after changes are in pull requests.
- Independent mobile CI: Codemagic or an equivalent mobile CI runner after the
  user explicitly approves hosted builds.
- Device matrix testing: Firebase Test Lab, BrowserStack, or a similar service
  only after the user approves account setup and upload behavior.
- Release telemetry: Crashlytics or Sentry only after the local app is polished
  and the user explicitly approves runtime reporting.

These services can improve review coverage, but they do not replace the local
Flutter gates. Danio must remain useful and testable locally.

## Product Rules Protected By The Gate

- Smart Hub must work locally first.
- Optional AI must never make the app feel broken without keys.
- Do not add fake premium, social, cloud, leaderboard, or subscription
  behavior.
- Do not add hidden network behavior.
- Care guidance must remain educational and not imply veterinary/professional
  replacement.

## Research References Checked

Checked on 2026-06-21:

- Flutter integration testing:
  https://docs.flutter.dev/testing/integration-tests
- Flutter widget and golden-test APIs:
  https://docs.flutter.dev/cookbook/testing/widget/introduction
  and https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html
- Flutter Android build guidance:
  https://docs.flutter.dev/deployment/android
- Patrol native automation:
  https://patrol.leancode.co/
- Maestro local CLI:
  https://docs.maestro.dev/maestro-cli
- OSV-Scanner:
  https://google.github.io/osv-scanner/
- DCM:
  https://dcm.dev/
- CodeRabbit:
  https://docs.coderabbit.ai/guides/code-review-overview
- Qodo code review:
  https://docs.qodo.ai/code-review
- Codemagic Flutter builds:
  https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/

Checked on 2026-06-22:

- GitHub Dependabot configuration options:
  https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference
- About the Dependabot configuration file:
  https://docs.github.com/en/code-security/concepts/supply-chain-security/about-the-dependabot-yml-file
