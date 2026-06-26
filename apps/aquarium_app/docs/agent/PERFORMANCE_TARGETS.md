# Danio Performance Targets

These are the complete-local performance targets for Android phone and tablet.
Use profile or release evidence for final judgement; debug mode is useful for
development signals but is not the final performance bar.

## Target Device Class

- Mid-range Android phone first.
- Android tablet second, with the same interaction targets unless a tablet-only
  layout requires extra evidence.
- Local emulator evidence is acceptable for early detection, but physical-device
  or Firebase Test Lab evidence is preferred before final release-readiness.

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

Performance work does not replace correctness, accessibility, visual QA, or data
resilience checks. It is an additional completion lane.
