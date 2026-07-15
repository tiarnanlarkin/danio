# Danio Quality Ladder

Status: active lean profiles
Run from: `apps/aquarium_app`

Use the smallest profile that proves the current epoch. Gate output includes
`GATE_TIMING|...` per step and `GATE_TOTAL|...` overall; timings are
diagnostic and never pass/fail thresholds.

## Profiles

| Profile | Contract |
| --- | --- |
| `Focused` | Requires explicit `-FocusedTests`; runs those tests once, `flutter analyze`, worktree visibility, and diff checks. |
| `Docs` | Runs the two current-doc workflow guards, signing-secret guard, worktree visibility, and diff checks only. |
| `Full` | Runs signing guard, dependency validation, custom lint, the full Flutter suite once, analyze, debug APK, worktree visibility, and diff checks. It does not run a preliminary Focused or autonomy suite. |
| `Visual` | Requires explicit `-FocusedTests`; runs affected tests, visual contracts/goldens, analyze, visual checks, worktree visibility, and diff checks. |
| `AndroidPrep` | Runs dependency validation, custom lint, analyze, debug APK, device visibility, worktree visibility, and diff checks. It does not duplicate Focused or autonomy tests. |

Examples:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused -FocusedTests test/widget_tests/search_screen_test.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual -FocusedTests test/widget_tests/search_screen_test.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
```

## Epoch policy

- Every changed behavior gets focused RED/GREEN proof and analyze.
- Run one Full gate on the final settled tree of a product-code epoch.
- A docs-only epoch uses one Docs gate and no Full gate.
- High-risk work remains a single-slice epoch and gets an independent
  settled-diff review before Full.
- After an identical fast-forward or push, compare tree IDs and Git alignment
  instead of rerunning Full.
- A release candidate may also require AndroidPrep and owned-device evidence;
  local gates do not prove Play/account/external readiness.

## Opt-in checks

`-RunAutonomyTests` runs the retained autonomy Dart contract and pure
PowerShell behavior suite. With Full, the targeted Dart rerun is skipped because
the full Flutter suite already contains it. Frozen-autonomy checks are not part
of ordinary profiles.

`-ResetGeneratedOutputs` is the only gate path allowed to remove generated
trees. Ordinary profiles preserve the warm `build` cache. The dependency
validator excludes generated paths, including `android/app/mnt/**`.

Optional local tools remain opt-in with `-RunOptionalTools`. Paid, hosted,
account-backed, device-affecting, Patrol, or external lanes require their
separate approval and ownership conditions.

## Change selection

- Docs/workflow only: Docs.
- Product behavior: explicit Focused during RED/GREEN, then one final Full.
- Data safety/persistence/security/lifecycle/destructive work: focused
  failure-path proof, independent review, then one final Full.
- UI/visual: current visual target, explicit Visual paths, and Full if product
  code changed.
- Android device evidence: read `DEVICE_OWNERSHIP.md`, then AndroidPrep and
  only the authorized device steps.
- Frozen autonomy changes: targeted tests plus `-RunAutonomyTests`; use Full
  only if product/gate code also requires it.

Always finish with `git diff --check` (included by the wrapper) and inspect the
intended staged files before commit.
