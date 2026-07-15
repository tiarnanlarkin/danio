# DCL-DR-001 Restore Behavior Matrix

Status: advanced; `DCL-DR-001` remains open
Epoch: `DR-2026-07-16-001`
Marker: `danio-dcl-dr-001-restore-matrix-audit-2026-07-15/1`
Authority base: `ea0d3c41ad94a90ecc785e34c571eb0839fe558f`

## Scope

This is the ordered, phone-only source/test audit required by Phase 1 Task 1.1.
It covers the current local ZIP export, preview, confirmation, import, preference
replacement, rollback, restored-photo cleanup, and user feedback paths. It does
not select another ledger row or reopen frozen autonomy, tablet, AI, account,
cloud, signing, store, release, or iOS work.

## Current Matrix

| Path | Current source behavior | Named executable evidence | Audit result |
| --- | --- | --- | --- |
| Export with no tanks | `BackupRestoreScreen` shows the zero-tank state, disables ZIP export, and offers `Go to Tank`. | `empty export state explains next step and links to Tank tab` | Accounted for; no write starts. |
| Export data collection and ZIP creation | Tank-scoped children and exportable preferences are collected, photo references are made portable, referenced/local photos are added, and the ZIP path is returned only after the encoder closes. | `exports app preferences and progress keys used in production`; `createBackup ignores free-text photo-like strings outside photo fields`; `createBackup rejects missing referenced photo files` | Accounted for; missing referenced photos fail before a usable ZIP is returned. |
| Export partial-file cleanup and user feedback | `BackupService.createBackup` closes the encoder and deletes a partial ZIP on creation failure, then always attempts temporary-JSON cleanup. After successful ZIP creation, the screen sets `_lastBackup` before sharing. Any returned share status reaches deletion of the only temporary ZIP, but only `success` gets terminal feedback. If sharing throws, screen-level error feedback is shown but completed-ZIP cleanup is bypassed. An unmount after creation or sharing also returns before cleanup. | `createBackup rejects missing referenced photo files`; `user-facing copy describes local ZIP backup only`; no named current test executes share dismissal/unavailability, a share exception, or post-creation unmount cleanup. | Not closure-ready. `DCL-DR-001-F2` records the dismissed/unavailable false-success state. Adjacent completed-ZIP cleanup paths must be accounted for before row closure. |
| File selection cancel or inaccessible selection | A cancelled/empty picker result returns before preview; a selected item without a path throws into the generic import-failure path. The import busy state is cleared in both cases. | No named current test drives picker cancellation or a selected file without a path; `shows import/restore button` and `import failure path cleans newly restored photos` cover the surrounding surface/catch contract only. | Source-explained, but direct executable cancellation evidence remains before closure. Neither path reaches restore writes in current control flow. |
| Preview | `getBackupData` checks file existence, decodes the ZIP, requires and validates `backup.json`, validates tanks, children, relationships, preferences, and referenced photos, then resolves portable photo paths without writing files. | `restores same-basename photos without overwriting local files`; all named `getBackupData rejects ...` cases in `backup_service_photo_restore_test.dart` | Accounted for; preview is read-only. |
| Invalid ZIP or malformed backup | ZIP decode or any validation failure propagates to the screen catch, which performs best-effort photo cleanup if needed and shows `Import failed. The file may be invalid or corrupted.` Validation covers root/tank/child structure, required data, dates, enums, numeric ranges, recurrence, relationships, preferences, and photo archive integrity. | `import failure path cleans newly restored photos`; `restore screen cleanup helper keeps cleanup failures best effort`; the named `getBackupData rejects ...` families | Accounted for; validation occurs before restore writes. |
| Confirmation and cancel | The preview tank count and merge/replace effects are shown before the confirm dialog. Any result other than explicit confirmation returns before photo extraction, tank writes, or preference replacement. | No named current test dismisses the confirm dialog; `shows clear import safety copy` and `user-facing copy describes local ZIP backup only` cover the copy contract only. | Source-explained, but direct executable confirmation-cancel evidence remains before closure. |
| Confirmed photo restore | `restoreBackup` revalidates the archive, returns early for zero tanks, extracts only referenced photos under deterministic import-prefixed names, never overwrites existing files, and records only newly created paths. | `restores same-basename photos without overwriting local files`; `restoreBackup restores Windows-style photo archive entries`; `restoreBackup ignores archive photos that backup data does not reference` | Accounted for. |
| Successful tank import | Backup tank and child IDs are preflighted and remapped, relationships remain tank-local, each imported tank is recorded before its save, and success is returned only after all tank-scoped writes finish. | `imports tank-scoped backup data with remapped relationships`; `regenerates imported tank ids that already exist locally`; `regenerates imported child ids that already exist locally` | Accounted for. |
| No-tank import | Photo extraction returns zero without creating files, tank import returns zero, preference replacement and provider invalidation are skipped, and the screen warns `No tanks found in this backup file.` | `restoreBackup skips photo extraction when a backup has no tanks`; `skips preference restore when backup imports no tanks` | Accounted for; no app-wide preference false write remains. |
| Tank/child partial write | Any tank-scoped import exception triggers `deleteAllTanks` for the recorded imported IDs, which removes imported parents and children before an import exception is surfaced. A tank ID is recorded before `saveTank` so persist-then-fail is also rolled back. | `rolls back imported tanks and children when a later save fails`; `rolls back a tank when saveTank persists then reports failure` | Accounted for. |
| Tank rollback failure | `BackupImportException` preserves the initiating error and separately records `rollbackError`, so source control flow says rollback failure cannot replace the import failure. | No named current test forces both an initiating import failure and `deleteAllTanks` failure; the named rollback tests exercise successful rollback only. | Source-explained but not executable closure evidence. This remains an evidence gap after F2. |
| Preference validation and successful replacement | Restorable entries are type-validated before any clear, existing exportable preferences are snapshotted, current exportable keys are cleared, backup entries are written, and non-exportable keys are ignored. | `restore clears all current exportable keys before writing backup`; `restore ignores non-exportable entries from backup files`; named `restore rejects ... before clearing ...` cases | Accounted for. |
| Preference partial write and rollback | A failed preference write triggers replacement from the pre-restore snapshot. | `restore rolls back previous preferences when a write fails mid-restore` | Accounted for only when rollback succeeds. One gap is selected below. |
| Preference restore failure after tank success | Imported tanks remain, preference failure is returned as a warning state, preference providers are not invalidated, and the screen reports that tanks imported but profile/preferences could not be restored. | `reports malformed preference payloads after importing tanks` | Accounted for; no false all-data success is shown. |
| Tank-import failure photo cleanup | The import flow calls restored-photo cleanup before rethrowing the original tank import failure. Cleanup failure is logged and cannot replace that original failure. The screen catch repeats only the best-effort helper. | `runs restored photo cleanup when tank import fails`; `preserves tank import failure when restored photo cleanup also fails`; `import failure path cleans newly restored photos`; `restore screen cleanup helper keeps cleanup failures best effort` | Accounted for. |
| Photo extraction failure cleanup | `restoreBackup` records a destination before writing and deletes all newly recorded paths if extraction throws. `cleanupLastRestoredPhotos` never removes pre-existing local files. | `cleanupLastRestoredPhotos removes only newly restored photos`; `restores same-basename photos without overwriting local files`; no named current test forces extraction to throw after creating a destination. | Source-explained with cleanup identity proof, but the mid-extraction failure branch lacks direct executable evidence before closure. |
| User-visible terminal states | Export success feedback is conditional on share success, but dismissed/unavailable sharing has no terminal feedback and retains the pre-share `Last backup` timestamp after deleting the ZIP. Export exceptions are errors; preference partial success and no-tank import are warnings; full import is success; invalid/corrupt/import failure is an error; all busy/progress state is cleared in `finally`. | `user-facing copy describes local ZIP backup only`; `shows clear import safety copy`; `reports malformed preference payloads after importing tanks`; `skips preference restore when backup imports no tanks`; `import failure path cleans newly restored photos`; no named current test covers a non-success returned share result. | Not closure-ready because the returned non-success share path is a current false-success/failure-feedback gap. |

## Selected Finding Before Code

`DCL-DR-001-F1`: `SharedPreferencesBackup.restoreFromJson` catches an
initiating replacement error, awaits snapshot rollback, and rethrows the
initiating error only after rollback returns. If rollback also throws, the
rollback exception escapes directly and replaces the original restore failure.
That differs from the tank-import path, which preserves both errors, and leaves
diagnostics unable to identify the operation that first failed.

Boundary for this single high-risk slice:

- Add one focused test that forces the backup write and rollback write to fail
  separately and requires both errors to remain inspectable.
- Prove the test RED because the current API exposes only the rollback failure.
- Add the smallest preference-restore exception representation and nested
  rollback handling needed to preserve both errors and their stack traces.
- Do not change preference selection, replacement order, rollback attempts,
  tank import behavior, photo behavior, UI, schema, or dependencies.

No second implementation gap is selected in this epoch.

## Future Finding

`DCL-DR-001-F2`: after a ZIP is created, `_lastBackup` is updated before
`Share.shareXFiles` returns. A dismissed or unavailable share result then
deletes the only temporary ZIP, shows no terminal warning, and leaves the
green `Last backup` timestamp visible. That can imply a usable backup exists
when it does not. No named current test executes this branch.

This finding was identified after the F1 implementation boundary had already
been selected, so it is deliberately not bundled into this high-risk slice.
The exact next marker is
`danio-dcl-dr-001-export-share-outcome-2026-07-16/1`. That slice must begin
with one focused failing widget test for the dismissed/unavailable result and
must inspect the directly adjacent completed-ZIP cleanup branches before
claiming DCL-DR-001 closure.

The matrix also records later executable-evidence gaps for picker cancellation,
confirmation cancellation, mid-extraction cleanup, and simultaneous tank-import
and rollback failure. Source explains the current control flow, but those paths
must receive direct focused proof before the row can close. They are not
selected ahead of the user-visible F2 boundary.

## Resolution And Verification

- RED: the focused rollback-failure test received only
  `simulated rollback preference write failure`; the initiating restore failure
  was absent.
- GREEN: `SharedPreferencesRestoreException` now retains the initiating error,
  rollback error, and both original stack traces. Successful rollback behavior
  and preference replacement order are unchanged.
- The affected Focused profile passes all 10
  `shared_preferences_backup_test.dart` tests plus `flutter analyze`.
- The current-doc guard was updated test-first for the initially proposed
  closure. Independent review then disproved that closure by finding F2, so the
  final guard instead preserves the open row and exact next marker.
- One pre-existing E0 `no_adjacent_strings_in_list` analyzer blocker in the
  current-doc guard was fixed by joining the same path literal; no assertion or
  product behavior changed.
- One independent read-only review covers the final settled diff and prevents
  the inaccurate closure claim, followed by one Full profile on that same tree.
