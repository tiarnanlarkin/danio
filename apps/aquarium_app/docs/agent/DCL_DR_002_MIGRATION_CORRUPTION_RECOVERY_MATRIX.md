# DCL-DR-002 Migration And Corruption Recovery Matrix

Status: open; no known current product gap; executable-evidence gaps remain
Latest epoch: `DR-2026-07-16-010`
Latest marker: `danio-dcl-dr-002-start-fresh-cancel-back-proof-2026-07-16/1`
Authority base: `dbc12209b9401a485f751a967248532c0cf232da`

## Scope

This is the ordered, phone-only source/test audit required by Phase 1 Task 1.2.
It covers legitimate first run, SharedPreferences and local-JSON migration,
idempotence, failed version stamps, malformed local JSON, failure propagation,
retry, and confirmed start-fresh behavior. It does not select `DCL-DR-003`,
`DCL-DR-004`, a later phone phase, frozen autonomy, tablet, AI, account, cloud,
signing, store, release, or iOS work.

## Current Matrix

| Path | Current source behavior | Named executable evidence | Audit result |
| --- | --- | --- | --- |
| Legitimate first run or empty local JSON file | `LocalJsonStorageService._loadFromDisk` reports loaded only when the data file is absent or its content is empty. | No direct file-backed first-run test. | Source-accounted but direct executable evidence is still required before row closure. |
| SharedPreferences first run and v0 data preservation | A missing `_schemaVersion` is v0. The v0-to-v1 migration is stamp-only and should leave every existing preference unchanged. | `stamps version key on first run (v0 → v1)`; `handles prefs with no prior version key gracefully` | First-run stamping is accounted for. Existing v0 preference preservation is not directly proven. |
| SharedPreferences idempotence | A stored version at or above the target returns before any migration write. | `is idempotent — second call does not change version`; `skips migration when already at target version` | Accounted for. |
| SharedPreferences failed version stamp | `_stampVersion` throws when `setInt` returns false, so the caller cannot observe migrated success. | `surfaces failed schema version stamp writes` | Accounted for; the version remains absent. |
| Unversioned local JSON migration | v0 JSON is copied, stamped through v1 and v2, parsed with safe defaults, then atomically persisted before loaded success. | `loads and persists migrated v0 local JSON data` | Accounted for; the legacy tank and current defaults survive and version 2 reaches disk. |
| Failed local-JSON migration stamp | A failed migrated-payload write clears the just-loaded maps, records `ioError`, and throws `StorageMigrationPersistenceException`. | `failed migration stamp write does not report loaded success` | Accounted for; the source file remains unstamped and no loaded success is exposed. |
| Malformed or structurally corrupted local JSON | Parse or entity-structure failure attempts a timestamped recovery copy, stores `corrupted`, and rethrows instead of becoming empty-data success. A recovery path is now recorded only after the copy completes; the UI and destructive dialog distinguish copy success from failure. | `malformed JSON copy failure does not advertise recovery path`; `malformed JSON reports only a recovery copy that exists`; `corruption without recovery path never claims a copy exists`; `shows local storage recovery actions when data is corrupted` | Accounted for. F2 proves file-backed malformed JSON, failed-copy honesty, original-file preservation, successful-copy preservation, and conditional user copy. |
| I/O failure propagation and user-visible retry | File I/O failures remain `ioError`; later reads rethrow until `retryLoad` resets and rereads. The recovery card now exposes that real retry for every service error while withholding start fresh unless the state is `corrupted`. | `load I/O errors stay in ioError instead of reporting empty success`; `I/O load error offers real retry without destructive start fresh` | Accounted for. `DCL-DR-002-F1` is locally fixed. |
| Retry after corruption | `retryLoad` clears the cached state/maps and rereads disk. An unchanged real malformed file remains `corrupted` and getters rethrow instead of exposing cleared maps; a schema-v2 repair remains blocked until retry, then loads without rewriting the repair or adding another corruption copy. | `try again reloads local storage and hides recovery card`; `unchanged malformed JSON retry stays corrupted and blocks empty success`; `repaired malformed JSON succeeds only through retry without rewriting repair` | Accounted for. F3 adds direct real-file repaired-versus-still-malformed service evidence. |
| Start-fresh cancel or back | The screen awaits an affirmative destructive dialog result before calling `recoverFromCorruption`. Explicit Cancel returns false and system back returns null, so neither path can recover, refresh the tanks provider, change the error state, or show success. | `canceling start fresh preserves corrupted storage and provider state`; `system back dismisses start fresh without recovery side effects` | Accounted for. F4 directly proves both dismissal paths. |
| Confirmed start fresh | After confirmation, the screen calls `recoverFromCorruption`; the service deletes the corrupt main file, clears local aquarium maps, and only then reports loaded/empty success. The confirmation now says a copy remains only when the service recorded one; otherwise it warns that no recovery copy will remain. | `start fresh confirms and clears corrupted local storage`; `corruption without recovery path never claims a copy exists` | Recovery-copy wording is accounted for. Actual scoped deletion still lacks direct service evidence. |
| Start-fresh failure | The screen catches recovery failure, retains the service-owned error state, and reports that start fresh did not complete. | No named failure test. | Retryable failure/no-false-success evidence is missing. |

## F1 Slice Boundary Before Code

`DCL-DR-002-F1` is the only selected gap for
`danio-dcl-dr-002-migration-corruption-recovery-audit-2026-07-16/1`.

- Begin with a recovery service in `StorageState.ioError` and require the
  Backup & Restore screen to expose the service's real `retryLoad` action.
- Do not offer destructive start fresh for an unclassified I/O failure; that
  action remains exclusive to confirmed corruption.
- Prove RED because the current recovery card is gated to `corrupted` and the
  generic tanks-provider retry does not reset the blocked storage singleton.
- Change only the recovery visibility/copy/action boundary in
  `lib/screens/backup_restore_screen.dart`, then prove the focused widget path
  GREEN.
- Do not change storage schemas, migration ordering, file deletion, provider
  ownership, dependencies, emulator/account/cloud/release configuration, or any
  later matrix gap.

No second product or executable-evidence gap is selected in this epoch.

## F1 Resolution And Verification

- RED: `I/O load error offers real retry without destructive start fresh`
  found zero `Local Data Needs Attention` recovery cards because the screen
  admitted only `StorageState.corrupted`.
- GREEN: the recovery surface now admits every `StorageRecoveryService`
  `hasError` state, invokes `retryLoad`, and hides again after successful retry.
- An `ioError` receives accurate non-destructive error copy and no start-fresh
  action. Confirmed corruption retains its existing retry and destructive
  confirmation flow; its separate recovery-copy assurance gap is recorded as
  F2 rather than bundled here.
- The complete affected widget file passes all 24 tests, the current-doc guard
  passes, the Focused profile including `flutter analyze` passes, an independent
  settled-diff review finds no blocking issue, and the final Full gate passes.
- `DCL-DR-002` remains open for the executable-evidence gaps in this matrix.

## F2 Slice Boundary Before Code

After a clean, pushed, aligned F1 checkpoint, continue only
`DCL-DR-002-F2` under marker
`danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1`.

- Force malformed local JSON detection and recovery-copy failure independently.
- Prove the resulting error cannot advertise a nonexistent recovery path and
  neither the recovery card nor destructive confirmation promises a copy that
  was not created.
- Preserve the original corrupt main file until the user explicitly confirms
  start fresh; successful recovery-copy behavior must remain unchanged.
- Do not bundle repaired retry, start-fresh cancellation/failure, scoped
  deletion, preference preservation, or legitimate-first-run evidence.

## F2 Resolution And Verification

- RED: the forced `File.copy` failure still produced a non-null
  `corruptedFilePath`, and the recovery card could not find the required
  no-copy warning.
- GREEN: the shared corruption-backup helper returns a path only after the copy
  completes. Both corruption handlers therefore expose null after copy failure,
  while the malformed original remains unchanged until explicit recovery.
- The recovery card and destructive confirmation now use that verified path.
  Copy-success wording and the destructive action remain unchanged when a real
  copy exists; copy failure receives an explicit permanent-clear warning.
- `malformed JSON reports only a recovery copy that exists` proves the copied
  bytes exist and the original bytes remain unchanged on the success path.
- All 45 affected service/widget tests pass, the current-doc guard passes, the
  Focused profile including `flutter analyze` passes, an independent settled-
  diff review finds no blocking issue, and the final Full gate passes.
- `DCL-DR-002` remains open for the executable-evidence gaps in this matrix.

## F3 Slice Boundary

After a clean, pushed, aligned F2 checkpoint, continue only
`DCL-DR-002-F3` under marker
`danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1`.

- Begin with real malformed local JSON and prove a repaired file succeeds only
  through `retryLoad`, while an unchanged malformed reread remains corrupted.
- Prove the retry performs no destructive write and cannot normalize a failed
  reread to empty-data success.
- Inspect source first and change product code only if direct service evidence
  proves a current retry defect.
- Do not bundle start-fresh cancel/failure/deletion, preference preservation,
  legitimate-first-run evidence, or a later ledger row.

## F3 Resolution

- No current product-code gap was found. `retryLoad` already resets the cached
  state, error, load future, and entity maps before rereading the real file.
- `unchanged malformed JSON retry stays corrupted and blocks empty success`
  proves two real malformed reads leave the main bytes intact, publish only
  existing recovery copies, retain `StorageState.corrupted`, and make the tank
  getter rethrow instead of returning an empty list.
- `repaired malformed JSON succeeds only through retry without rewriting repair`
  proves replacing the damaged main file is insufficient while the cached error
  remains. The next `retryLoad` reads the schema-v2 repair, exposes its tank,
  clears the error, preserves the repair bytes, preserves the earlier malformed
  copy, and creates no spurious new corruption copy.
- F3 changes tests and current controls only. `DCL-DR-002` remains open for the
  start-fresh and preference/first-run executable-evidence gaps in this matrix.

## F4 Slice Boundary

After a clean, pushed, aligned F3 checkpoint, continue only
`DCL-DR-002-F4` under marker
`danio-dcl-dr-002-start-fresh-cancel-back-proof-2026-07-16/1`.

- Begin with a corrupted recovery service and open the destructive start-fresh
  confirmation from the current recovery card.
- Prove cancel and back/dismiss perform no service clear, main-file deletion,
  provider refresh, or terminal success feedback.
- Inspect source first and change product code only if direct widget evidence
  proves a current cancellation defect.
- Do not bundle confirmed start-fresh deletion, start-fresh failure, preference
  preservation, legitimate-first-run evidence, or a later ledger row.

## F4 Resolution

- No current product-code gap was found. The destructive dialog returns false
  for Cancel and null for system-back dismissal; the screen returns unless the
  result is exactly true.
- `canceling start fresh preserves corrupted storage and provider state` proves
  the explicit Cancel action leaves recovery/retry counts at zero, preserves
  the same corruption error/state, performs no additional tanks-provider read,
  keeps the recovery card visible, and emits no start-fresh success feedback.
- `system back dismisses start fresh without recovery side effects` proves the
  same zero-side-effect boundary through the platform back route while keeping
  the Backup & Restore screen mounted.
- F4 changes tests and current controls only. `DCL-DR-002` remains open for
  confirmed scoped deletion, recovery failure, preference preservation, and
  legitimate-first-run executable evidence.

## F5 Slice Boundary

After a clean, pushed, aligned F4 checkpoint, continue only
`DCL-DR-002-F5` under marker
`danio-dcl-dr-002-start-fresh-scoped-deletion-proof-2026-07-16/1`.

- Use a real temporary local-storage directory with a corrupt main file, its
  recovery copy, and unrelated sibling content.
- Prove confirmed service recovery deletes only the corrupt main file, preserves
  the recovery copy and unrelated siblings, clears all entity maps, and reports
  healthy empty success only after deletion completes.
- Inspect source first and change product code only if direct service evidence
  proves a current scoped-deletion or false-success defect.
- Do not bundle start-fresh failure, preference preservation, legitimate-first-
  run evidence, or a later ledger row.
