# Danio Android Phone Release-Candidate Finalization Plan

Status: current ordered phone release-candidate authority
Authorized: 2026-07-19
Marker: `danio-phone-rc-authority-reset-2026-07-19/1`
Authority epoch: `DR-2026-07-19-057`

## Outcome

Danio is substantially built. The main product journeys, accepted content
breadth, and 96-screen phone map already exist. This plan closes the Android
phone release candidate; it does not begin another open-ended development
cycle.

The target is:

- a locally signed-off Android debug APK;
- clean, pushed, aligned `main`;
- no unresolved P0 or P1 defect;
- every current phone-finish row closed, explicitly accepted, or parked;
- repeatable emulator, accessibility, visual, performance, and data-safety
  evidence.

Play Store signing and submission, iOS, tablet, cloud/accounts, hosted
services, public release, and new product expansion remain separate.

## Fixed Product Decisions

- Deleted-livestock removal logs remain tombstone history and never recreate
  livestock during backup import.
- User Optional-AI keys move to Android Keystore-backed secure storage.
- The final device is the repo-approved `danio_api36` emulator.
- Work uses one repository-writing coordinator. Up to three parallel agents
  may perform read-only data/privacy, product/content, and phone-quality audits.
- The current 82 lessons, 75+ species, and 40+ plants are accepted breadth.
  Only a proven defect or validator failure can require a correction.

## P0/P1 Release Selector

This P0/P1 release selector is the only severity selector for this plan.

- **P0:** crash or ANR; corruption or data loss; serious privacy/security
  failure; unreachable critical journey; or a required-gate failure.
- **P1:** uncertain durability or duplicate risk; false success; broken core
  journey; wrong safety-critical calculation/advice; essential accessibility
  failure; reduced-motion or haptic-preference bypass; material clipping; or a
  reproducible performance-budget miss.
- **P2/P3:** non-critical edge cases, polish, breadth, and future expansion.
  Record these as accepted limitations or post-v1 work. They do not extend this
  release unless the user explicitly reopens scope.

A wishlist probe or later audit discovery adds an implementation epoch only
when a focused RED test proves a P0/P1 defect. Do not continuously reopen the
backlog, infer new breadth requirements, or rank speculative work.

## Epoch Contract

Every epoch begins from fetched, clean, aligned `main`, one worktree, and no
competing repository writer. Allocate the next unused `DR` identifier from the
live handoff. Use one temporary branch and one product finding per
implementation epoch.

Product work follows:

1. focused RED for the expected reason;
2. the smallest correct fix;
3. focused GREEN;
4. independent read-only review of the settled diff;
5. Full gate;
6. fast-forward local `main`;
7. push once and prove `main...origin/main = 0 0`;
8. prove clean status and one worktree, then remove the safely merged branch.

Documentation-only closure follows documentation-guard RED, documentation
edit, guard GREEN, independent read-only review, and the Docs gate. Visual code
changes additionally require the Visual gate. Only the coordinator runs
Flutter, Gradle, Git integration, or device commands. Auditors inspect source,
tests, screenshots, and settled diffs without writing.

Standard commands run from `apps/aquarium_app`:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused -FocusedTests @('<affected-tests>')
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual -FocusedTests @('<affected-visual-tests>')
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
```

## Baseline Authority Reset

`DR-2026-07-19-057` replaces the older open-ended routing rule with this finite
program. It does not change product behavior.

The unchanged checkpoint `ded4771a` (tree
`e59ea2ca36abac3b512cd2e6b8196a6f7a369982`) passed a fresh post-F34 Full gate
on 2026-07-19: signing-secret guard, dependency validation, custom lint, 2,263
tests, analyze, and debug APK build all passed; total gate time was 183,016 ms.
This is the release-finalization baseline. A later gate failure becomes a new
bounded P0/P1 only when current evidence proves a repository defect.

## Fixed Product/Test Sequence

There are ten planned product/test epochs. They are completed in this order.
Wishlist or an audit discovery may add one epoch only under the focused-RED
rule above.

### 1. Tasks completion compensation

If completion logging and task restoration both fail, preserve both failures,
reload authoritative task/tank/log state, block stale callbacks, describe the
uncertain completion honestly, and omit unsafe Retry.

### 2. Equipment Mark Serviced compensation

Prove service-log failure plus equipment/task rollback failure. Preserve both
causes and identifiers, prevent duplicate service history, refresh authority,
and show honest uncertain-state feedback without unsafe Retry.

### 3. Single livestock-add compensation

Prove add-log failure plus deletion rollback failure. Preserve the uncertain
livestock identifier, lock repeated submission and stale callbacks, refresh
authority, and omit unsafe Retry.

After these three epochs, run the Wishlist replay probe across double-tap,
captured stale callback, rebuild, persistence failure, and retry paths. Add a
product epoch only if RED proves duplicate or replay behavior; otherwise record
`no current finding` without product changes.

Reinspect the complete current `DCL-DR-003` matrix after the probes. Close the
row only when all current P0/P1 paths are resolved. Keep `DCL-DR-003-F34`
closed unless contradictory live evidence exists. Park lower-severity
missing-catalog and residual edge cases; do not infer row closure.

### 4. Backup tombstone relationship

For `livestockRemoved` logs only, accept a nonblank deleted livestock ID as an
opaque tombstone. Preserve it verbatim through backup preview/import, never add
it to a live livestock ID map, and never resurrect livestock. All other
dangling, cross-tank, malformed, or invalid relationships still fail. Close
`DCL-DR-004` only after a self-generated backup round trip passes.

### 5. Fish ID activity consent

Keep the result visible. Decline or dismissal writes no AI history;
confirmation writes exactly once. Add an internal injectable image-picker seam
so widget tests never invoke the platform picker.

### 6. Compatibility activity consent

Apply the same cancel/no-write and confirm/write-once contract. A history-save
failure must not hide the compatibility result. Verify every already-gated AI
surface before closing `DCL-AI-001`.

### 7. Secure Optional-AI key storage

Introduce internal `ApiKeyStore` read/write/delete operations. Production uses
a no-cost Android Keystore-backed secure-storage dependency; tests use an
in-memory fake. Migration reads the legacy encrypted SharedPreferences value,
writes secure storage, and removes the legacy value only after secure
persistence succeeds. Failed migration retains the legacy value and reports an
honest error. Deletion clears secure and legacy locations. No plaintext key may
appear in preferences, logs, backups, errors, or diagnostics.

Close `DCL-PREF-001` only after secure migration, deletion, keyless behavior,
and the current privacy/provider paths pass. Keep provider-dialog dismissal
refresh as P2/P3 unless current evidence elevates it.

### 8. Compatibility and calculation rule coverage

First prove the existing Workshop, Journal, Learning, species, plant, content,
and source paths described in the ledger. Do not expand accepted breadth.

Add executable coverage for:

- `CompatibilityService`: temperature, pH, GH, tank size, school size,
  conflicts, temperament, predation, and severity precedence;
- all five Tank Volume shapes with numeric expected values;
- complete length, volume, hardness, and existing temperature Unit Converter
  assertions.

If a test exposes wrong behavior, fix that one P1 in its own implementation
epoch. Then close `DCL-P1-003` through `DCL-P1-006`, `DCL-CONTENT-001`, and
`DCL-RULE-001` only through documentation checkpoints backed by executable
evidence.

### 9. Global haptic-preference enforcement

Route every product haptic through one preference-aware feedback adapter. Add a
source guard forbidding direct platform haptic calls outside that adapter.
Prove disabled means zero platform calls and enabled actions emit no more than
their intended calls.

Then run the five phone-quality clusters: tank/daily care; Learn/Practice/
stories; Smart/no-key/Optional-AI; More/tools/species/rewards/preferences; and
first run plus destructive/data-recovery dialogs. Check 48dp targets, semantic
labels, contrast, non-colour state, 2.0x text reflow, reduced motion, disabled
haptics, affected screenshots/goldens, and asset provenance. Select screenshots
from the source delta since visual baseline `6fa6ae2f`; do not recapture all 96
screens without evidence. Unknown asset rights block the candidate until
proven or replaced.

### 10. Profile performance harness

Add `integration_test/phone_performance_test.dart` and a local report
summarizer. Emit machine-readable product commit, device, scenario, samples,
median/frame statistics, budget, and pass/fail. Use one warm-up plus five
measured latency iterations and three animation/scroll traces.

Budgets:

- cold start <= 2500 ms;
- warm resume <= 1200 ms;
- tab switch <= 300 ms;
- tank feedback <= 16.667 ms average and <= 5% dropped frames;
- main scrolling <= 20 ms average and <= 8% dropped frames;
- local-image first paint <= 500 ms.

Run on `danio_api36` after ownership preflight:

```powershell
adb devices
.\scripts\run_danio_live_preview.ps1 -DeviceId <emulator-serial> -CheckOnly
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
flutter drive --driver=test_driver/integration_test.dart `
  --target=integration_test/phone_performance_test.dart `
  --profile -d <emulator-serial>
```

Close `DCL-A11Y-001`, `DCL-VIS-001`, `DCL-VIS-002`, `DCL-MOTION-001`, and
`DCL-PERF-001` only when their evidence is current.

## Final Local Release Candidate

After the ten planned epochs and any focused-RED additions, freeze product
changes and:

1. recompute the 96-screen map delta and run route/render coverage for all
   mapped routes;
2. run final content/rule suites and critical data/privacy journeys;
3. run Visual, Full, and AndroidPrep on clean `main`;
4. run performance and affected-state emulator checks;
5. run the Android black-box smoke flow;
6. after any code change, repeat affected focused/Visual checks, Full,
   AndroidPrep, performance, and device recheck;
7. record product commit/tree, final documentation commit, emulator/API,
   gates, performance, APK SHA-256, closed rows, and explicit P2/P3 limits;
8. add the final QA note as a documentation-only commit, prove the app source
   tree is unchanged, and run Docs;
9. push clean `main`, prove `main...origin/main = 0 0`, one worktree, and no
   safely merged temporary branch.

Preserve unrelated branch `docs/danio-live-dev-workflow-spec-20260719` unless
it is separately reviewed and approved for cleanup.

`DCL-RC-001` closes only when every preceding phone row is closed, accepted, or
parked; all required checks pass; artifact/evidence records are current; and no
P0/P1 remains. Stop at that point. Do not begin another finding hunt or create
a successor task.

## Internal Interfaces Introduced By This Program

- `ApiKeyStore`: secure read, write, delete, and safe legacy migration.
- Backup relationship validation: tombstone exception only for
  livestock-removal history.
- Fish ID image-picker provider: internal testing seam.
- Preference-aware feedback adapter: sole permitted haptic interface.
- Performance report schema: commit, device, scenario, statistics, budget, and
  result.

No public network API, account, cloud service, or paid dependency is introduced.
