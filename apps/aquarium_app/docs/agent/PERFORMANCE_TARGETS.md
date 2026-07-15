# Danio Performance Targets

Authority lock: `danio-completion-roadmap-authority-lock-2026-07-15/1`

These are the phone-only local completion boundary performance targets. Use
local profile or release evidence for final judgement; debug mode is useful for
development signals but is not the final performance bar.

## Target Device Class

- Mid-range Android phone first.
- Measure on the locally owned Danio Android phone target. Local emulator
  evidence is acceptable when that is the owned target.
- Tablet performance remains parked under `DCL-TAB-001`; no tablet or hosted
  device-lab evidence is required for phone complete-local.

## Budgets

| Scenario | Target |
| --- | --- |
| Cold start to visible Tank | <= 2500 ms |
| Warm resume to interactive | <= 1200 ms |
| Bottom-tab switch to settled content | <= 300 ms |
| Tank animation and care feedback | <= 16.667 ms average frame time and <= 5% dropped frames |
| Main list/content scrolling | <= 20 ms average frame time and <= 8% dropped frames |
| Local image first paint | <= 500 ms blank/placeholder time |

The source-of-truth constants live in
`lib/utils/performance_targets.dart`. Update the constants, tests, and this doc
together if a target changes.

## Measurement Workflow

1. Start from a clean worktree or clearly isolated slice.
2. Run focused tests for the changed code.
3. Use local profile/release evidence when measuring performance-sensitive
   changes.
4. Measure cold start, warm resume, tab switching, Tank animation, high-traffic
   scrolling, and local image-heavy screens.
5. Record only useful evidence under `docs/qa/screenshots/...` or the relevant
   QA notes; do not commit noisy raw logs.
6. Run the documented local gate before committing product behavior.

Focused performance-target example:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused -FocusedTests test/utils/performance_targets_test.dart
```

## Finite Completion Rule

`DCL-PERF-001` closes when cold start, warm resume, tab switching, tank
animation, representative scrolling, and local image first paint are measured
on the owned Android phone target and meet these budgets, or every reproducible
miss is fixed and remeasured. Unclear device ownership leaves the row open; it
does not authorize tablet, cloud, or account-backed measurement.

Performance work does not replace correctness, accessibility, visual QA, or data
resilience checks. It is an additional completion lane.
