# Danio Codex Setup

Status: supporting reference; not routine startup

## Startup

Routine development reads exactly:

1. root `AGENTS.md`
2. root `GIT_WORKFLOW.md`
3. `docs/agent/ACTIVE_HANDOFF.md`
4. `docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md`
5. `docs/agent/QUALITY_LADDER.md`

Read the Finish Map, closure ledger, source, tests, device docs, research docs,
archives, plans, and forecasts only when directly relevant.

## Local environment

Run Flutter commands from `apps/aquarium_app`. Prefer the repo's existing
Flutter, Dart, PowerShell, Gradle, ADB, and local screenshot tooling. Do not add
hosted runners, cloud projects, paid tools, accounts, or API keys without a
fresh explicit request. Never commit secrets.

Before edits:

```powershell
git fetch --all --prune --tags
git status --short -uall
git rev-list --left-right --count main...origin/main
git worktree list
flutter doctor
```

Preserve unrelated dirty work. One coordinator owns all repository writes;
auditors and reviewers remain read-only.

## Gates

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused -FocusedTests test/path/to/affected_test.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual -FocusedTests test/path/to/affected_widget_test.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
```

Focused and Visual require explicit affected paths. Ordinary behavior work uses
focused RED/GREEN plus analyze, then one Full gate on the final settled
product-code epoch tree. Docs-only epochs use one Docs gate and no Full gate.
Ordinary gates preserve the warm build cache.

`-RunAutonomyTests` opts into the retained autonomy Dart and PowerShell
behavior proof. `-ResetGeneratedOutputs` is the only gate path that removes
generated trees.

## Android and live preview

Read `DEVICE_OWNERSHIP.md` before any device-affecting command.
`LIVE_PREVIEW_WORKFLOW.md` is an observation lane for substantial app-facing
work when ownership is clear. It does not replace focused tests, analysis,
Visual, AndroidPrep, screenshots, or Full.

Use the dedicated Danio device documented there. Except for `adb devices`,
commands against an assigned device use `adb -s <assigned-serial>`. Skip
device work when ownership is unclear.

## Visual and content work

Ground UI changes in a current screenshot, golden, mockup, approved design doc,
Figma frame, or existing app surface. Use local screenshots and record asset
ownership/licensing. Run affected content validation when care data, lessons,
quizzes, species, plants, source trails, or product claims change.

Danio stays local-first, keyless-capable, and honest about optional AI. Do not
introduce fake premium, social, cloud, sync, or veterinary claims.

## Frozen autonomy

`docs/agent/autonomous_completion/README.md` marks the former autonomous
workflow as frozen historical material. It is outside routine startup and
ordinary gates. Reactivation requires a new explicit user request and a
reconciliation plan.

Never create an automatic successor task.
