# DCL-PERF-001 Dropped-Frame Formal Disposition

Epoch: `DR-2026-07-25-081`
Marker: `danio-dcl-perf-001-dropped-frame-formal-disposition-2026-07-25/1`

## Outcome

`DCL-PERF-001 is accepted` for the local Android phone candidate. The two raw
dropped-frame percentage budgets still fail and the machine-readable report
correctly remains `passed: false`. The budgets were not relaxed, the report was
not relabelled, and no product code changed.

The accepted limitation is the reproducible `danio_api36` raster floor for
these two percentage counters. Current and prior evidence isolates no
incremental product P1:

- paired Tank traces measured idle `15.998 ms` versus feeding `16.007 ms`, an
  incremental `0.009 ms`;
- paired scrolling measured Learn `15.924 ms` versus minimal `15.958 ms`, an
  incremental `-0.034 ms`;
- the current unchanged product commit passes both average-time budgets while
  only their strict per-frame percentage counters fail.

This disposition is bounded to the owned local emulator and the phone
complete-local candidate. It does not claim physical-phone, tablet, store, or
public-release performance, and it does not prevent reopening if a current
product-attributable trace, ANR, average-time regression, or contradictory
P0/P1 evidence appears.

## Current report

- Product commit: `574b28b92107368e987e267aa11135541b417255`
- Device: `danio_api36 (emulator-5554)`
- Report:
  `docs/qa/performance/2026-07-25/dcl-perf-001-phone-profile-current-rerun.json`
- SHA-256:
  `975F0A38723A417974AF3090A56C5521BC8DBA6AD812873CB96CCBD055C0810F`
- Cold start: `1203 ms` - pass
- Warm resume: `98 ms` - pass
- Tab switching: `226.942 ms` - pass
- Local-image first paint: `180.685 ms` - pass
- Tank feedback: `16.307 ms` average - pass; `37.186%` dropped - fail
- Scrolling: `17.198 ms` average - pass; `48.387%` dropped - fail

## Recovery and device controls

The first current-commit run was interrupted and the dedicated AVD later
failed to boot. With explicit user authorization, only `danio_api36` was wiped
and recreated. Its first run was restored through the product UI: adult
eligibility confirmed, terms accepted, optional crash reporting declined, and
`Skip setup, explore first` selected. The native build was recovered by
removing only the user-authorized generated
`rive_common-0.4.15/android/.cxx` cache after repository-generated resets
exposed its corrupt CMake fingerprint.

Reset-assisted AndroidPrep then passed:
`GATE_TOTAL|PASS|193098|AndroidPrep`. The final harness restored its preserved
product profile APK, stopped Danio, returned the launcher, and serial-pinned
CheckOnly passed.

## Release boundary

No performance target, report schema, product behavior, asset, account,
provider, cloud service, tablet path, or store path changed. The next and only
remaining phone-candidate epoch is `DCL-RC-001`.
