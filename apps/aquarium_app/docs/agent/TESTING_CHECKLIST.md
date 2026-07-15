# Danio Testing Checklist

Status: active lean reference

Use `QUALITY_LADDER.md` for the executable profile matrix and
`VERIFIED_SLICE_EXECUTION_CONTRACT.md` for epoch cadence.

## Behavior RED/GREEN

1. Select the smallest affected test.
2. Add or update the assertion first.
3. Prove RED for the intended reason.
4. Make the smallest source change.
5. Run Focused once with the explicit path; that invocation proves GREEN and
   runs analyze, worktree visibility, and diff checks.

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused -FocusedTests test/widget_tests/search_screen_test.dart
```

Multiple closely related paths may be comma-separated. Never invoke Focused or
Visual without `-FocusedTests`.

## Epoch closeout

- Product-code epoch: one Full gate on the final settled tree.
- Docs-only epoch: one Docs gate and no Full gate.
- Visual product epoch: explicit Visual paths, then Full once on settled code.
- Android evidence: AndroidPrep after device ownership is clear.
- High-risk epoch: failure-path proof and one independent settled-diff review
  before Full.

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual -FocusedTests test/golden_tests/mc_card_golden_test.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
```

Full owns signing guard, dependency validation, custom lint, the complete
Flutter suite once, analyze, and debug APK. It does not repeat a preliminary
Focused or autonomy run. Docs owns the two current-doc guards and signing guard
only.

Ordinary profiles preserve the warm `build` cache.
`-ResetGeneratedOutputs` is the only path that removes generated trees.
Inspect `GATE_TIMING|...` and `GATE_TOTAL|...` for diagnostics, not
time-based acceptance.

## Opt-in autonomy proof

The former autonomy implementation and tests are retained but frozen.
`-RunAutonomyTests` runs the autonomy Dart contract and pure PowerShell
behavior suite. With Full, the targeted Dart rerun is skipped because that test
is already in the full suite.

Disposable activation/Git fixtures remain direct, manual checks only when work
changes frozen autonomy:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_activation_fixture_test.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_git_fixture_test.ps1
```

Reactivation requires a new explicit user request and reconciliation plan.

## Specialized checks

- Content changes: run the affected content tests and
  `test/quality/content_validation_test.dart`.
- Visual baseline changes: run affected widgets/goldens through Visual.
- Data/persistence changes: prove false-success, rollback, retry, and cleanup
  paths where applicable.
- Release claims: local Full/AndroidPrep do not prove Play, signing ownership,
  legal URLs, or other external/account truth.
- Optional AI: prove the no-key path and confirmation-before-write behavior.

## Live preview and Android

Read `DEVICE_OWNERSHIP.md` first. `LIVE_PREVIEW_WORKFLOW.md` is an
observation lane; it does not replace tests, analysis, Visual, AndroidPrep,
screenshots, or the Full gate. Use local evidence only and do not disturb a
shared emulator.

## Final checks

- `git diff --check` passes.
- Intended focused tests and selected gate pass.
- Status and staged paths contain only owned changes.
- Active Handoff and one concise Slice Log row reflect the epoch.
- Finish Map or closure ledger changes only if actual status changed.
- The tested tree ID matches the fast-forwarded/pushed tree.
- `main...origin/main = 0 0` and intended worktrees remain.

Never create an automatic successor task.
