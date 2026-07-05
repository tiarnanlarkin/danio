# Danio Testing Checklist

Use this checklist before committing Danio changes. It is local-first and
quality-first: local gates are mandatory, and paid/account-backed checks are
optional evidence only after explicit approval.

For the full operating rules, use `WORKFLOW_CHARTER.md`. For verified slices,
use `VERIFIED_SLICE_EXECUTION_CONTRACT.md`. For remaining gap IDs, use
`COMPLETE_LOCAL_CLOSURE_LEDGER.md` and `COMPLETE_LOCAL_FORECAST.md`. For
research gates, use `RESEARCH_PROTOCOL.md`. For current dirty files and active
blockers, check `ACTIVE_HANDOFF.md`. For change-type gates, use
`QUALITY_LADDER.md`. For visual and page evidence gaps, use
`SCREEN_INVENTORY.md`.

## Before Editing

- Run `git status --short -uall`.
- Check `docs/agent/FINISH_MAP.md` and identify the row this slice advances.
- Check `docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md` and identify the finding
  ID this slice advances. Add new findings to the ledger before implementing
  them.
- Check `docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md` for the current local
  proof contract.
- Start from `docs/agent/SLICE_CONTRACT_TEMPLATE.md` for non-trivial slices.
- For substantial implementation, complete the slice contract's research and
  planning section before editing. Current best-practice checks should use
  primary sources when framework, platform, testing, accessibility, AI,
  security, or workflow choices matter.
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
- `dart run dependency_validator` reports no dependency hygiene issues.
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
`.github/dependabot.yml` without a separate explicit request and approval
ledger entry.

## Local Dependency Audit

The standard non-focused local gate runs `dart run dependency_validator`.
This catches missing, unused, under-promoted, and over-promoted packages without
needing DCM, a cloud account, or a paid license. The current config excludes
generated Flutter `build/**` output plus the nested local lint package, and it
ignores the `danio_custom_lints` analyzer plugin path dependency in
`dart_dependency_validator.yaml` because it is consumed through analyzer
configuration.

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

The optional prose lint is also intentionally scoped:

```powershell
vale docs/agent docs/design
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

Live preview is an observation lane for user-visible feedback. Use
`docs/agent/LIVE_PREVIEW_WORKFLOW.md` and the dedicated `danio_api36` emulator
when the user wants to see the app while it is being built.
Live preview does not replace focused tests, the Visual gate, AndroidPrep,
Patrol, screenshots, or the Full gate.

For performance-sensitive changes, use `docs/agent/PERFORMANCE_TARGETS.md` as
the budget source before recording Android evidence or claiming the surface is
smooth enough for the complete-local bar.

Safe preflight:

```powershell
.\scripts\run_danio_live_preview.ps1 -CheckOnly
```

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

## Multi-Agent Verification Handoff

When subagents are used, the coordinator must keep verification ownership clear:

- Read-only auditors may identify missing checks but must not edit files.
- Implementation workers must report their assigned worktree, changed files,
  focused tests, and local gate results.
- `danio_reviewer` should review the final diff before staging when a worker
  contributed code or docs.
- `danio_android_qa_owner` is the only role that should run Android device
  interaction, Patrol, Firebase Test Lab, or screenshot capture for a slice.
- Live preview from `docs/agent/LIVE_PREVIEW_WORKFLOW.md` belongs to the
  coordinator or `danio_android_qa_owner` only.
- The coordinator must rerun the relevant local gate in the integration checkout
  before committing.

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

## External Account Checks

External checks are optional and must follow local gates. They are useful for
release confidence, not a replacement for local verification. Use
`docs/agent/PAID_TOOL_APPROVAL_LEDGER.md` before configuring, upgrading, or
running a paid/account-backed lane.

Configured account-side services:

- Firebase project `danio-b1b70`.
- Firebase Test Lab Spark/no-cost Robo smoke has passed once on Pixel 5 API 30.
- Crashlytics recognizes `com.tiarnanlarkin.danio`.
- Percy/App Percy project `Danio Aquarium Android` is linked to
  `tiarnanlarkin/danio` through GitHub integration.
- CodeRabbit setup was completed by the user; verify on the first PR review.

Run the no-upload external readiness preflight before any dashboard upload,
cloud device run, or Percy visual build:

```powershell
.\scripts\quality_gates\check_external_quality_readiness.ps1 -Target All
```

Rules:

- Do not commit Firebase, Percy, BrowserStack, CodeRabbit, Qodo, Sentry,
  OpenAI, or Figma secrets.
- Do not upgrade Firebase billing, start paid BrowserStack/Percy runs, enable
  Sentry billing, configure Qodo, or use paid Figma features without fresh
  explicit approval or an existing approval ledger entry for that exact use.
- Do not add hosted CI workflow files unless the user separately approves hosted
  builds and the approval ledger records the decision.
- Use `PERCY_TOKEN` only as a local shell/session environment variable when
  running an external Percy build.
- Treat BrowserStack/App Percy as account-linked but execution-gated until the
  relevant Android test-runner compatibility has been checked for the exact
  cloud lane being used.

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
- Finish Map, closure ledger, paid-tool ledger, or device ownership docs were
  updated when the slice changed completion status, changed a finding
  disposition, used an external tool, or captured Android evidence.
- Research that changed implementation direction was recorded in the slice
  contract, active handoff, or relevant agent docs.
- Commit message is specific.
- Push only after the requested verification passes.

For the full autonomous setup rules, see
`docs/agent/AUTONOMOUS_QUALITY_SETUP.md`.
