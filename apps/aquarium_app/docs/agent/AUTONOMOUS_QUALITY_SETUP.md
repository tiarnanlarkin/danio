# Danio Autonomous Quality Setup

This setup gives Codex a repeatable local quality workflow for finishing Danio.
Danio stays local-first and must not silently depend on paid services, cloud
runners, external accounts, or API keys. Paid/account-backed quality tools are
allowed only when the user explicitly approves the exact purpose and the
decision is recorded in `PAID_TOOL_APPROVAL_LEDGER.md`.

## Active Local Gate

Run from `apps/aquarium_app`:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused
```

Profiles:

- `Focused`: worktree visibility, whitespace diff check, current docs truth
  test, local content validation, visual baseline manifest validation, external
  quality preflight contract test, and the local gate contract test.
- `Docs`: `Focused` plus dependency validation, Danio custom lint, and
  `flutter analyze`.
- `Full`: `Focused`, dependency validation, Danio custom lint, full `flutter test`,
  `flutter analyze`, and debug APK build.
- `Visual`: `Focused`, dependency validation, Danio custom lint, the current
  focused golden tests, and `flutter analyze`.
- `AndroidPrep`: `Focused`, dependency validation, Danio custom lint,
  `flutter analyze`, debug APK build, and read-only `adb devices` visibility.
  It does not install, wipe, tap, or capture device state.

## Operating Docs

Use `WORKFLOW_CHARTER.md` as the master working agreement,
`RESEARCH_PROTOCOL.md` for planning research, `ACTIVE_HANDOFF.md` for current
session state, `SCREEN_INVENTORY.md` for no-guessing visual/page coverage,
`SLICE_LOG.md` for breadcrumbs, `HOUSEKEEPING.md` for repo hygiene, and
`QUALITY_LADDER.md` for the required checks by change type.

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
2. Check `FINISH_MAP.md` and create a slice contract from
   `SLICE_CONTRACT_TEMPLATE.md` for non-trivial work.
3. For substantial implementation, do a research-first planning pass before
   editing. Rebuild current repo context, decide whether the work needs a fresh
   session, compare the intended approach against current primary sources when
   technology or quality practice matters, and record any decision-changing
   sources in the slice contract or handoff.
4. For substantial app work, especially UI, navigation, product behavior,
   Android, or visual slices, attempt `docs/agent/LIVE_PREVIEW_WORKFLOW.md`
   so the user can follow along on the dedicated Danio emulator. Skip only for
   docs-only, tests-only, refactor-only, or device-unsafe slices, and state why.
5. Focused failing test for behavior changes.
6. Small implementation slice.
7. `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`.
8. Broaden to `-Profile Docs`, `-Profile Visual`, `-Profile Full`, or
   `-Profile AndroidPrep` based on the files changed.
9. For external-account work, confirm approval in
   `PAID_TOOL_APPROVAL_LEDGER.md`, then run
   `.\scripts\quality_gates\check_external_quality_readiness.ps1 -Target All`
   before opening dashboards, uploading artifacts, or touching tokens.
10. Commit only the intended files.
11. Push after the relevant local gates pass.

## Multi-Agent Completion Flow

For larger autonomous passes, keep one coordinator in the real checkout and use
project-scoped agents from `.codex/` in this order:

1. `danio_product_auditor` for product/content gaps.
2. `danio_ui_auditor` for visual, accessibility, and baseline gaps.
3. `danio_quality_auditor` for missing tests and gate coverage.
4. `danio_worker` only for one bounded slice in an explicitly assigned git
   worktree with disjoint file/module ownership.
5. `danio_reviewer` after each completed slice.
6. `danio_android_qa_owner` only when emulator/device ownership is clear.

The coordinator remains responsible for integration, local gates, commits, and
pushes. External-account services remain optional after local gates and must not
receive committed secrets or billing upgrades without an approval ledger entry
covering the exact use.

## Current Setup Status

Verified on 2026-06-22:

- `AndroidPrep` passed and built the debug APK locally.
- `Visual` passed with the focused golden tests.
- `Full -SkipApkBuild` passed after the fresh AndroidPrep APK build.
- `Docs -RunOptionalTools` passed after the Vale setup; OSV, cspell, and Vale
  ran successfully.
- `dependency_validator 5.0.5` replaced the optional DCM path as the standard
  no-cost dependency hygiene check in non-focused profiles.
- `osv-scanner` and Vale resolve from their winget package folders when PATH
  has not refreshed.
- `patrol_cli 4.2.0` is installed in the Dart pub cache and matches the app's
  current `patrol 4.3.0` range according to the Patrol compatibility table.
- Firebase account setup is active for project `danio-b1b70`. Crashlytics is
  recognized for `com.tiarnanlarkin.danio`; Firebase Test Lab ran one
  Spark/no-cost Robo test on Pixel 5 API 30 and passed.
- App Percy account setup is active for project `Danio Aquarium Android`.
  The Percy GitHub integration is enabled, linked only to
  `tiarnanlarkin/danio`, and its health check passed.
- CodeRabbit GitHub app setup was completed by the user. Treat its first pull
  request review as the practical verification point.
- Percy/BrowserStack tokens and account keys are intentionally not committed or
  stored in this repo. Use local shell/session secrets only when running an
  external build.
- `check_external_quality_readiness.ps1` documents and checks the Firebase,
  BrowserStack, and Percy prerequisites without uploading builds, starting cloud
  runs, or printing secret values.
- Sentry and Qodo are not configured.

## Optional Local Tools

The gate can detect and run these tools when installed locally:

- `osv-scanner scan source --format=vertical --verbosity=error --recursive .`
  for no-cost dependency vulnerability checks. This uses OSV's public
  vulnerability data and requires the local `osv-scanner` binary, but no
  account, key, or paid service.
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
- `dart run dependency_validator` for missing, unused, under-promoted, and
  over-promoted dependency checks. Danio excludes generated Flutter `build/**`
  output plus the nested `tool/danio_custom_lints/**` package, and ignores the
  local `danio_custom_lints` analyzer plugin path dependency because it is used
  by analyzer configuration rather than normal imports. Keep that allowlist in
  `dart_dependency_validator.yaml`.
- `dart run custom_lint` for Danio-specific local rules that generic Flutter
  lints cannot know about.
- Local `danio_custom_lints` rules under `tool/danio_custom_lints/`.

Use `scripts/quality_gates/run_local_quality_gate.ps1` for dependency
validation and custom lint on Windows. The wrapper clears generated Flutter
output that can confuse dependency/workspace discovery and runs
`dart run custom_lint` through a temporary no-space junction because this local
repo path contains spaces.

Do not require a DCM license, CI key, dashboard, or cloud account for normal
work. DCM is not part of the active quality path; use dependency validation,
Very Good Analysis, custom lint, and focused tests instead unless a future
approved review proves DCM would add material value.

## Account-Backed Quality Lane

Some account-backed services are now connected, but they remain outside the
local core. Do not commit secrets, tokens, dashboard exports, generated account
config, or paid-service workflow files. Do not configure, upgrade, or run a
paid/account-backed lane unless `PAID_TOOL_APPROVAL_LEDGER.md` records approval
for that exact use.

Current account-side setup:

- Firebase project `danio-b1b70`
  - Spark/no-cost plan during setup.
  - Crashlytics recognized the Android app `com.tiarnanlarkin.danio`.
  - Test Lab single-device Robo smoke passed on Pixel 5 API 30.
- Percy / BrowserStack
  - App project: `Danio Aquarium Android`.
  - GitHub integration: enabled for `tiarnanlarkin/danio` only.
  - Health check: successful.
  - Project token: not stored in repo.
- CodeRabbit
  - GitHub app setup completed by the user.
  - Verify on the first PR review before relying on it as a quality signal.

Use these services in this order:

1. Local gates first: `Focused`, `Docs`, `Visual`, `AndroidPrep`, or `Full`.
2. Firebase Test Lab for occasional device smoke or matrix checks after a local
   APK build passes.
3. CodeRabbit for pull-request review after the branch is pushed.
4. Percy/App Percy only after local visual baselines are stable and a
   `PERCY_TOKEN` has been supplied through a local shell/session secret.

Do not upgrade Firebase billing, run paid BrowserStack device sessions, enable
Sentry billing, configure Qodo, use paid Figma features, or add hosted CI
without fresh explicit approval or a matching approval ledger entry. These
services can improve review coverage, but they do not replace the local Flutter
gates. Danio must remain useful and testable locally.

Before using any account-backed lane, run the no-upload preflight:

```powershell
.\scripts\quality_gates\check_external_quality_readiness.ps1 -Target All
```

To make missing prerequisites fail the command:

```powershell
.\scripts\quality_gates\check_external_quality_readiness.ps1 -Target BrowserStack -RequireReady
```

The preflight intentionally checks only local artifacts, local CLI availability,
and whether required environment variables are present. It does not run
`firebase test android run`, call BrowserStack APIs, run `percy exec`, or reveal
credential values. BrowserStack Flutter execution still needs runner
compatibility verified before using the existing Android instrumentation shell
as a cloud test suite.

When running Percy locally, set the token outside Git, for the current shell
only:

```powershell
$env:PERCY_TOKEN = "<token from Percy project settings>"
```

Remove it from the shell when finished:

```powershell
Remove-Item Env:PERCY_TOKEN
```

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
- Dependency Validator:
  https://pub.dev/packages/dependency_validator
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
