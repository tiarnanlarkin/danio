# Danio Testing Checklist

Use this checklist before committing Danio changes. It is local-first and no-cost.

## Before Editing

- Run `git status --short -uall`.
- Identify unrelated dirty files and leave them alone.
- Read the relevant source and nearby tests before changing code.
- For behavior changes, write or update a focused failing test first.

## Focused Verification

Run focused tests for the changed area.

Examples:

```powershell
flutter test test/widget_tests/search_screen_test.dart
flutter test test/widget_tests/journal_screen_test.dart
flutter test test/widget_tests/backup_restore_screen_test.dart
flutter test test/widget/settings_screen_test.dart
flutter test test/services/backup_service_test.dart
flutter test test/copy/current_docs_local_truth_test.dart
flutter test test/quality/content_validation_test.dart
```

Use the smallest focused test first, then broaden.
For UI/settings/navigation changes, include the focused widget test that proves
the visible flow can be reached and interacted with.

The local quality gate gives Codex a repeatable default focused check:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused
```

Run the content validator whenever lessons, quizzes, care sources, species
data, plant data, or app copy claims are changed. It catches placeholder/draft
copy, fake feature claims, broken source references, weak quiz structure, and
basic care-range drift.

Run the visual baseline manifest validator whenever design baseline docs,
screenshot references, or golden-test names change:

```powershell
flutter test test/quality/visual_baseline_manifest_test.dart --reporter compact
```

## Standard Product Gates

Run from `apps/aquarium_app`:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
```

Expected:

- `flutter test` passes.
- `dart run custom_lint` reports no Danio-specific lint violations through the
  local gate's Windows-safe temporary path.
- `flutter analyze` reports no issues.
- Debug APK builds successfully.
- `git diff --check` prints no whitespace errors.

The debug APK build may report the known future Kotlin Gradle Plugin warning. That warning does not block the current local debug build unless it turns into a build failure.

Equivalent local gate profile:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
```

## Docs-Only Gates

For docs-only changes:

```powershell
git diff --check
flutter test test/copy/current_docs_local_truth_test.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
rg -n "Maestro Cloud|Vercel|Supabase|Sentry|OpenAI API calls|paid service|fake premium|fake social|fake cloud" AGENTS.md apps/aquarium_app/docs/agent
```

Equivalent local gate profile:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
```

Run `flutter test test/copy/current_docs_local_truth_test.dart` if the docs describe current app behavior.

Docs-only setup changes do not require a full Flutter suite or debug APK build
unless they alter product truth, test instructions, or launch/readiness claims.

## Dependabot PR Checks

Dependabot PRs are allowed only as free GitHub dependency-update automation.
Before merging one, run the smallest relevant local gate:

- Pub/Flutter dependency PRs: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android Gradle dependency PRs: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep`
- GitHub Actions dependency PRs: inspect workflow changes and run the local
  docs/focused gate at minimum.

Do not add private registries, tokens, or paid package feeds to
`.github/dependabot.yml` without a separate explicit request.

## Local Dependency Audit

When `osv-scanner` is installed locally, run the optional dependency audit with:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs -RunOptionalTools
```

The gate runs `osv-scanner scan source --format=vertical --verbosity=error
--recursive .`. This is no-cost and does not need an account or API key, but it
does query OSV public vulnerability data. Keep hosted scanners and paid security
dashboards out of the repo unless separately approved.

The optional spelling check is intentionally scoped:

```powershell
cspell --config .cspell.json --no-progress docs/agent docs/design
```

Do not replace it with a full-repo `cspell .` scan unless the dictionary and
ignore paths are expanded deliberately; generated/platform files make that output
too noisy to be useful today.

## Android QA Discipline

Use Android devices only when safe:

- Check `adb devices`.
- Confirm no other Codex session owns the emulator/device.
- Do not install, clear data, restart, wipe, or kill a device without ownership clarity.
- If ownership is unclear, stop at `flutter build apk --debug --target lib/main.dart`.

For local Patrol smoke, prefer:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep -RunPatrolSmoke -PatrolDeviceId emulator-5554
```

The Patrol wrapper uses `--no-uninstall` by default. Add `-PatrolUninstall`
only when using a dedicated emulator for this repo.

When Android QA is safe, capture:

- Device/emulator name.
- APK/build used.
- Screens tested.
- Screenshots or logcat snippets if they prove an issue or fix.

Store durable local evidence under:

```text
apps/aquarium_app/docs/qa/screenshots/<date-or-branch>/<slice>/
```

## Local Screenshot Checklist

- Use local capture only.
- Name files by screen and state.
- Avoid uploading screenshots to external services.
- Include enough context to reproduce the state.
- Do not commit temporary screenshots unless they are useful QA evidence.

## Optional Local Maestro CLI

Maestro is optional. Use it only as a local smoke-flow aid when it is already
installed or the user explicitly approves a local install.

Allowed:

```powershell
maestro test .\maestro\some_flow.yaml
```

Not allowed:

- Maestro Cloud.
- Hosted device farms.
- Remote uploads.
- Account setup.

If device ownership is unclear, skip Maestro and rely on Flutter tests,
`flutter analyze`, and the local debug APK build.

## Design And Visual Baseline Checks

Use `docs/design/BASELINES.md` to choose the minimum screenshot or golden-test
set for broad visual work and `docs/design/VISUAL_QA_CHECKLIST.md` for local
pass/fail criteria.

For focused Flutter golden checks:

```powershell
flutter test test/golden_tests/mc_card_golden_test.dart
flutter test test/golden_tests/empty_room_scene_golden_test.dart
```

Equivalent local gate profile:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual
```

Regenerate ignored local golden references only when intentionally reviewing
visual output:

```powershell
flutter test --update-goldens test/golden_tests/
```

For app-wide screenshot evidence, reuse committed local screenshot folders such
as `docs/qa/screenshots/whole-app-map-2026-05-18/` and capture new local
evidence only when device ownership is clear.

## Product Truth Checklist

Before committing product or docs changes, confirm:

- Smart Hub still works locally without AI.
- Optional AI absence is not presented as an app failure.
- No fake premium, social, cloud, leaderboard, referral, or subscription promises were introduced.
- Local backup/restore wording explains what happens in normal-user language.
- Educational care copy does not imply veterinary/professional replacement.

## Final Commit Checklist

- Focused tests passed.
- Required gates passed for the type of change.
- `git diff --check` passed.
- `git status --short` contains only files intended for the commit.
- Commit message is specific.
- Push only after the requested verification passes.

For the full autonomous setup rules, see
`docs/agent/AUTONOMOUS_QUALITY_SETUP.md`.
