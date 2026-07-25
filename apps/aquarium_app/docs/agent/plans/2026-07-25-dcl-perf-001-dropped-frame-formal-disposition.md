# DCL-PERF-001 Dropped-Frame Formal Disposition

Epoch: `DR-2026-07-25-081`
Marker: `danio-dcl-perf-001-dropped-frame-formal-disposition-2026-07-25/1`
Risk: release truth / high

## Scope

Reconcile only the remaining Tank and representative-scrolling dropped-frame
percentage failures. Preserve all five phone-quality clusters and every
performance budget. Do not change product code, emulator targets, provider,
account, cloud, tablet, store, or later release-candidate scope.

## Evidence plan

1. Re-run the unchanged profile harness on the owned, serial-pinned
   `danio_api36`.
2. Preserve the raw current report and compare it with the existing paired
   Tank idle/feeding and Learn/minimal-scroll attribution.
3. If no incremental product P1 is isolated, record the unresolved emulator
   dropped-frame percentage floor as an explicit accepted phone-candidate
   limitation without relaxing a target or claiming that the raw report passed.
4. Prove the documentation transition with the exact current-doc guard, one
   independent repository-read-only settled-diff review, and the Docs gate.

## Stop boundary

Stop before `DCL-RC-001`. A product-code optimization requires a new focused
RED that isolates a product cause; the prior blur experiment and paired
diagnostics do not authorize speculative rendering changes.
