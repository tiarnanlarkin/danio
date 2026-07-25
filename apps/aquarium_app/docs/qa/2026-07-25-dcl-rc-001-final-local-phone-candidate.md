# DCL-RC-001 Final Local Android Phone Candidate

Epoch: `DR-2026-07-25-082`
Marker: `danio-dcl-rc-001-final-local-phone-candidate-2026-07-25/1`

## Candidate

- Product commit: `bc76532e90379a102598abf977f837d01709ed07`
- Product tree: `c726a04a7a72b51d00444c7122d6a8c04abb8896`
- Device: `danio_api36 (emulator-5554)`
- Debug APK SHA-256: `A63ADF60206AC44E918C6D363E917B9A84632685143C299F176673B915439BFD`
- Boundary: local Android phone candidate; not Play Store or public release.

## Final verification

- The 96-row `SCREEN_INVENTORY.md` phone accounting remains 96 Pass and zero
  current gaps. Final Full covers route/render, content/rule, and critical
  data/privacy contracts.
- Visual: `GATE_TOTAL|PASS|35254|Visual` across 237 affected phone-quality
  tests plus visual contracts/goldens and analysis.
- Full: initial generated-path traversal race; the sole sanctioned reset rerun
  passed dependency validation, custom lint, 2,399 tests, analysis, and debug
  APK build at `GATE_TOTAL|PASS|200040|Full`.
- AndroidPrep: the same generated-path race was cleared once through the
  sanctioned reset path; dependency validation, custom lint, analysis, debug
  APK build, and device visibility passed at
  `GATE_TOTAL|PASS|78784|AndroidPrep`.
- Current profile report:
  `build/qa-artifacts/dcl-rc-001/phone-performance.json`, SHA-256
  `B169752AC473D3EB00876A871926E219A7AC047ED86CF76DAC9A57527B0F753C`.
  Cold `1309 ms`, warm `97 ms`, tabs `221.707 ms`, image `164.99 ms`, Tank
  average `16.359 ms`, and scrolling average `16.332 ms` pass. Raw Tank
  `36.979%` and scrolling `36.032%` percentages reproduce only the
  `DCL-PERF-001 accepted limitation`; targets and failed counters remain honest.
- The compact serial-pinned suite completed first-run/shell, practice/Tank,
  and Learn/Smart/More journeys. The underlying smoke ended
  `ANDROID_USER_JOURNEYS|PASS|device=emulator-5554` with no crash signatures.
- Danio was stopped, the launcher restored, pinned CheckOnly passed, and the
  heavy lane was released.

## Disposition

Every preceding phone row is closed, accepted, or parked. There is no
unresolved P0/P1 in the local Android phone candidate, so `DCL-RC-001` is
closed. The accepted emulator dropped-frame percentage floor remains recorded
without being relabelled as passing.

Tablet, Play Store signing/submission, public release, cloud/accounts, paid
services, provider keys, and iOS are outside this candidate. They require
separate explicit authority and are not implied complete.
