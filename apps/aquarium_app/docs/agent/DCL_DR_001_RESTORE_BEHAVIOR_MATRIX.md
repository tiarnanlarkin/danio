# DCL-DR-001 Restore Behavior Matrix

Status: advanced; `DCL-DR-001` remains open
Latest epoch: `DR-2026-07-16-005`
Latest marker: `danio-dcl-dr-001-tank-import-rollback-failure-proof-2026-07-16/1`
Initial marker: `danio-dcl-dr-001-restore-matrix-audit-2026-07-15/1`
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
| Export partial-file cleanup and user feedback | `BackupService.createBackup` closes the encoder and deletes a partial ZIP on creation failure, then always attempts temporary-JSON cleanup. After successful ZIP creation, the screen shares before setting `_lastBackup`; only `success` records that state. Dismissed and unavailable outcomes get distinct warnings, thrown share errors keep error feedback, and one outer `finally` makes completed-ZIP cleanup best effort across success, returned non-success, throw, and unmount. | `createBackup rejects missing referenced photo files`; `dismissed export leaves no Last backup and explains it was not saved`; `unavailable export explains that saved status could not be confirmed`; `share failure cleans the ZIP and keeps error feedback honest`; `successful share records Last backup and cleans the ZIP`; `unmount while sharing still cleans the completed ZIP` | Accounted for. `DCL-DR-001-F2` is locally fixed with returned-status, throw, success, and lifecycle cleanup proof. |
| File selection cancel or inaccessible selection | A cancelled or empty picker result returns to idle before preview with no feedback or writes. A selected item without a path returns to idle with access-specific feedback. The pinned Android picker's realistic `unknown_path` platform error receives the same feedback. Neither access failure is mislabeled as backup corruption. | `picker cancel returns idle without restore writes`; `empty picker result returns idle without restore writes`; `pathless selection returns idle with access feedback and no writes`; `unknown-path picker error returns idle with access feedback and no writes` | Accounted for. `DCL-DR-001-F3` proves custom ZIP selection parameters, idle restoration, zero tank/preference writes, and accurate access feedback. |
| Preview | `getBackupData` checks file existence, decodes the ZIP, requires and validates `backup.json`, validates tanks, children, relationships, preferences, and referenced photos, then resolves portable photo paths without writing files. | `restores same-basename photos without overwriting local files`; all named `getBackupData rejects ...` cases in `backup_service_photo_restore_test.dart` | Accounted for; preview is read-only. |
| Invalid ZIP or malformed backup | ZIP decode or any validation failure propagates to the screen catch, which performs best-effort photo cleanup if needed and shows `Import failed. The file may be invalid or corrupted.` Validation covers root/tank/child structure, required data, dates, enums, numeric ranges, recurrence, relationships, preferences, and photo archive integrity. | `import failure path cleans newly restored photos`; `restore screen cleanup helper keeps cleanup failures best effort`; the named `getBackupData rejects ...` families | Accounted for; validation occurs before restore writes. |
| Confirmation and cancel | The preview tank count and merge/replace effects are shown before the confirm dialog. Any result other than explicit confirmation returns before photo extraction, tank writes, preference replacement, or provider invalidation. | `canceling a valid preview returns idle without restore writes`; `shows clear import safety copy`; `user-facing copy describes local ZIP backup only` | Accounted for. `DCL-DR-001-F4` drives a valid referenced-photo ZIP to the dialog and proves Cancel preserves the selected ZIP, performs zero storage and preference-platform writes, creates no photo directory, emits no import outcome, and restores idle UI. |
| Confirmed photo restore | `restoreBackup` revalidates the archive, returns early for zero tanks, extracts only referenced photos under deterministic import-prefixed names, never overwrites existing files, and records only newly created paths. | `restores same-basename photos without overwriting local files`; `restoreBackup restores Windows-style photo archive entries`; `restoreBackup ignores archive photos that backup data does not reference` | Accounted for. |
| Successful tank import | Backup tank and child IDs are preflighted and remapped, relationships remain tank-local, each imported tank is recorded before its save, and success is returned only after all tank-scoped writes finish. | `imports tank-scoped backup data with remapped relationships`; `regenerates imported tank ids that already exist locally`; `regenerates imported child ids that already exist locally` | Accounted for. |
| No-tank import | Photo extraction returns zero without creating files, tank import returns zero, preference replacement and provider invalidation are skipped, and the screen warns `No tanks found in this backup file.` | `restoreBackup skips photo extraction when a backup has no tanks`; `skips preference restore when backup imports no tanks` | Accounted for; no app-wide preference false write remains. |
| Tank/child partial write | Any tank-scoped import exception triggers `deleteAllTanks` for the recorded imported IDs, which removes imported parents and children before an import exception is surfaced. A tank ID is recorded before `saveTank` so persist-then-fail is also rolled back. | `rolls back imported tanks and children when a later save fails`; `rolls back a tank when saveTank persists then reports failure` | Accounted for. |
| Tank rollback failure | `BackupImportException` preserves the initiating error and original stack, separately records `rollbackError`, and exposes both errors in its combined diagnostic string, so rollback failure cannot replace the import failure. | `preserves tank import failure when tank rollback also fails` | Accounted for. `DCL-DR-001-F5` forces the initiating save failure and `deleteAllTanks` failure, proves the exact two error objects and original stack remain inspectable, and confirms rollback was attempted for the imported tank. |
| Preference validation and successful replacement | Restorable entries are type-validated before any clear, existing exportable preferences are snapshotted, current exportable keys are cleared, backup entries are written, and non-exportable keys are ignored. | `restore clears all current exportable keys before writing backup`; `restore ignores non-exportable entries from backup files`; named `restore rejects ... before clearing ...` cases | Accounted for. |
| Preference partial write and rollback | A failed preference write triggers replacement from the pre-restore snapshot. If snapshot rollback also fails, `SharedPreferencesRestoreException` preserves the initiating and rollback errors with both original stacks. | `restore rolls back previous preferences when a write fails mid-restore`; `restore preserves the initiating error when snapshot rollback also fails` | Accounted for. `DCL-DR-001-F1` closed the error-replacement gap without changing replacement order. |
| Preference restore failure after tank success | Imported tanks remain, preference failure is returned as a warning state, preference providers are not invalidated, and the screen reports that tanks imported but profile/preferences could not be restored. | `reports malformed preference payloads after importing tanks` | Accounted for; no false all-data success is shown. |
| Tank-import failure photo cleanup | The import flow calls restored-photo cleanup before rethrowing the original tank import failure. Cleanup failure is logged and cannot replace that original failure. The screen catch repeats only the best-effort helper. | `runs restored photo cleanup when tank import fails`; `preserves tank import failure when restored photo cleanup also fails`; `import failure path cleans newly restored photos`; `restore screen cleanup helper keeps cleanup failures best effort` | Accounted for. |
| Photo extraction failure cleanup | `restoreBackup` records a destination before writing and deletes all newly recorded paths if extraction throws. `cleanupLastRestoredPhotos` never removes pre-existing local files. | `cleanupLastRestoredPhotos removes only newly restored photos`; `restores same-basename photos without overwriting local files`; no named current test forces extraction to throw after creating a destination. | Source-explained with cleanup identity proof, but the mid-extraction failure branch lacks direct executable evidence before closure. |
| User-visible terminal states | Export success feedback and `Last backup` are conditional on affirmative share success. Dismissed sharing says no backup was saved; unavailable sharing says saved status could not be confirmed; thrown export errors remain errors. Cancelled file selection and cancelled confirmation are silent no-ops; inaccessible selection gets actionable access feedback; invalid/corrupt content remains an import error. Preference partial success and no-tank import are warnings; full import is success; all busy/progress state is cleared in `finally`. | The five named export-outcome tests above; the four named file-selection tests above; `canceling a valid preview returns idle without restore writes`; `user-facing copy describes local ZIP backup only`; `shows clear import safety copy`; `reports malformed preference payloads after importing tanks`; `skips preference restore when backup imports no tanks`; `import failure path cleans newly restored photos` | Accounted for through confirmation cancellation. Returned non-success sharing, inaccessible selection, and cancelled confirmation do not create false or misleading terminal state. |

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

## F2 Finding Recorded After F1

`DCL-DR-001-F2`: after a ZIP is created, `_lastBackup` is updated before
`Share.shareXFiles` returns. A dismissed or unavailable share result then
deletes the only temporary ZIP, shows no terminal warning, and leaves the
green `Last backup` timestamp visible. That can imply a usable backup exists
when it does not. No named current test executes this branch.

This finding was identified after the F1 implementation boundary had already
been selected, so it was deliberately not bundled into that high-risk slice.
It was selected next under marker
`danio-dcl-dr-001-export-share-outcome-2026-07-16/1`, began with a focused
failing widget test, and included the directly adjacent completed-ZIP cleanup
branches.

The matrix also records later executable-evidence gaps for picker cancellation,
confirmation cancellation, mid-extraction cleanup, and simultaneous tank-import
and rollback failure. Source explains the current control flow, but those paths
must receive direct focused proof before the row can close. They are not
selected ahead of the user-visible F2 boundary.

## F2 Slice Boundary Before Code

`DCL-DR-001-F2` is the only implementation gap selected for
`danio-dcl-dr-001-export-share-outcome-2026-07-16/1`.

- User-visible behavior: a returned dismissed or unavailable share outcome
  must not set the green `Last backup` state and must show honest terminal
  feedback; only a successful share may set `Last backup` and report success.
- Cleanup boundary: once ZIP creation completes, the temporary ZIP must receive
  one best-effort cleanup attempt after share success, returned non-success,
  a thrown share error, or an unmount before/while sharing.
- Focused RED/GREEN path:
  `test/widget_tests/backup_restore_screen_test.dart` proves the returned
  non-success false-success boundary before production code changes, then
  accounts for the adjacent completed-ZIP terminal paths.
- Expected production path:
  `lib/screens/backup_restore_screen.dart` only. No import, preference,
  schema, dependency, provider, device, cloud, account, or release behavior
  changes.
- Verification: one Focused profile for the affected widget test, one
  independent read-only settled-diff review, and one Full profile on the final
  settled tree. Cleanup remains best effort so a cleanup failure cannot replace
  the share outcome.

## F2 Resolution And Verification

- RED: the dismissed method-channel result produced one visible green
  `Last backup` timestamp and no terminal warning.
- GREEN: only `ShareResultStatus.success` records `Last backup`; dismissed and
  unavailable statuses show distinct honest warnings.
- Completed-ZIP cleanup moved to the outer export `finally`, so it remains best
  effort and executes after success, returned non-success, a thrown share
  error, and unmount while sharing.
- The affected Focused profile passes all 18
  `backup_restore_screen_test.dart` tests plus `flutter analyze`.
- `DCL-DR-001` remains open because picker cancellation/pathlessness,
  confirmation cancellation, simultaneous tank-import/rollback failure, and
  mid-extraction cleanup still lack direct executable evidence.

## F3 Slice Boundary Before Code

`DCL-DR-001-F3` is the only selected gap for
`danio-dcl-dr-001-file-selection-outcome-proof-2026-07-16/1`.

- Drive null cancellation, an empty result, a selected item without a path, and
  Android's realistic `unknown_path` platform failure through the screen.
- Prove every path returns to an idle selection screen before preview, photo
  extraction, tank writes, or preference writes.
- Keep silent cancellation unchanged. If inaccessible-file proof reveals
  misleading feedback, change only that feedback boundary.
- Do not change picker type, ZIP validation, restore ordering, photo cleanup,
  import services, schemas, dependencies, providers, or device behavior.

## F3 Resolution And Verification

- RED: the selected pathless item returned idle without writes, but the screen
  omitted access-specific feedback and showed the generic invalid/corrupt
  backup message instead.
- GREEN: null cancellation and empty results remain silent no-ops; pathless
  results and `PlatformException(code: 'unknown_path')` show
  `Danio couldn't access that backup file. Choose it again or try another ZIP.`
- All four tests prove no tank writes, no preference writes, no confirmation
  dialog, no lingering progress state, and the existing custom single-ZIP
  picker contract.
- The complete `backup_restore_screen_test.dart` file passes all 22 tests.
- `DCL-DR-001` remains open because confirmation cancellation, simultaneous
  tank-import/rollback failure, and mid-extraction cleanup still lack direct
  executable evidence.

## F4 Slice Boundary Before Code

`DCL-DR-001-F4` is the only selected evidence gap for
`danio-dcl-dr-001-confirmation-cancel-proof-2026-07-16/1`.

- Drive a structurally valid ZIP with one referenced photo and one conflicting
  exportable preference through preview to the `Import Backup?` dialog.
- Cancel explicitly and prove the selected ZIP remains, no photo directory is
  created, storage and preference-platform write counts remain zero, no import
  outcome is shown, and the screen returns idle.
- Implement product code only if current executable evidence exposes one
  concrete false-success, cleanup, or feedback gap.

## F4 Resolution And Verification

- The focused proof passed on unchanged product code; no current F4 product gap
  was found.
- `canceling a valid preview returns idle without restore writes` confirms the
  one-tank preview and Cancel action, then proves zero storage mutations, zero
  SharedPreferences platform writes, no restored-photo directory, unchanged
  `use_metric`, no success/error feedback, and cleared busy/progress state.
- The picker, path-provider channel, preference platform, ZIP fixture, and
  temporary directory are all restored or removed by test teardown.
- `DCL-DR-001` remains open because simultaneous tank-import/rollback failure
  and mid-extraction cleanup still lack direct executable evidence.

## F5 Slice Boundary Before Code

`DCL-DR-001-F5` is the only selected evidence gap for
`danio-dcl-dr-001-tank-import-rollback-failure-proof-2026-07-16/1`.

- Force a later tank-scoped save to fail after one imported tank is recorded.
- Force the resulting `deleteAllTanks` rollback attempt to fail independently.
- Prove the initiating error, its original stack, the rollback error, and a
  diagnostic containing both failures remain inspectable.
- Implement product code only if executable evidence exposes one concrete
  error-replacement or rollback-attempt gap.

## F5 Resolution And Verification

- The focused proof passed on unchanged product code; no current F5 product gap
  was found.
- `preserves tank import failure when tank rollback also fails` proves the
  initiating log-save error and tank-rollback error remain the exact separately
  inspectable objects, the initiating stack remains populated, and the combined
  diagnostic contains both messages.
- The proof also confirms one rollback attempt for the recorded imported tank.
- `DCL-DR-001` remains open only because mid-extraction photo cleanup still
  lacks direct executable evidence.

## Next Ordered Evidence Gap

`DCL-DR-001-F6` is the mid-extraction cleanup proof slice with marker
`danio-dcl-dr-001-mid-extraction-cleanup-proof-2026-07-16/1`. It must force
photo extraction to fail after at least one destination is created, then prove
all paths newly created by that attempt are removed without deleting a
pre-existing local file. Implement only if that executable proof exposes one
concrete cleanup-identity or partial-file gap.

## F1 Resolution And Verification

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
