# DS-2026-07-05-040 - Ignore Unreferenced Duplicate Backup Photos

Status: Completed
Date: 2026-07-05
Branch: `ds-2026-07-05-040-ignore-unreferenced-duplicate-photos`

## Goal

Allow otherwise valid backups to preview and restore when duplicate photo
filenames exist only in archive entries that validated backup data does not
reference.

## Evidence

DS-2026-07-05-039 made `BackupService.restoreBackup` restore only archive
`photos/` entries whose basenames are referenced by validated backup data.
Fresh source review found that `_readValidatedBackupData` still calls
`_validatePhotoArchiveEntries` before referenced photo validation, and that
validation rejects duplicate basenames across all `photos/` archive entries.
That can block a valid backup because stale or archive-only duplicate photo
files are ignored by restore behavior but still fail preview validation.

## Intended Behavior

- Duplicate archive photo basenames must still fail when the duplicate basename
  is referenced by backup data, because restore would have ambiguous source
  content.
- Duplicate archive photo basenames must not fail when backup data does not
  reference that basename.
- Restore must continue to extract only referenced photos and track only newly
  restored referenced paths.

## Files

- `lib/services/backup_service.dart`
- `test/services/backup_service_photo_restore_test.dart`
- `docs/agent/ACTIVE_HANDOFF.md`
- `docs/agent/FINISH_MAP.md`
- `docs/agent/SLICE_LOG.md`
- `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

## Risk

Tier 2 data safety. Backup preview and restore validation are local data
resilience boundaries.

## RED/GREEN Plan

1. Add a focused test proving a backup with one referenced photo and duplicate
   unreferenced archive-only photo basenames currently fails preview/restore.
2. Run the named test and verify RED for the duplicate-photo validation reason.
3. Restrict duplicate-photo filename validation to referenced photo basenames.
4. Re-run the named test, then the full
   `test/services/backup_service_photo_restore_test.dart` file.

## Gate Plan

- `dart format lib\services\backup_service.dart test\services\backup_service_photo_restore_test.dart`
- `flutter test test/services/backup_service_photo_restore_test.dart --reporter compact`
- `flutter analyze lib/services/backup_service.dart test/services/backup_service_photo_restore_test.dart`
- `git diff --check`
- `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`

## Verification

- RED:
  `flutter test test/services/backup_service_photo_restore_test.dart --plain-name "getBackupData ignores duplicate unreferenced archive photo filenames" --reporter compact`
  failed with `Invalid backup: duplicate photo filename "orphan.jpg"`.
- GREEN: the same named test passed after duplicate archive-photo filename
  validation was restricted to referenced photo filenames.
- `dart format lib\services\backup_service.dart test\services\backup_service_photo_restore_test.dart`
  checked both changed Dart files.
- `flutter test test/services/backup_service_photo_restore_test.dart --reporter compact`
  passed with 135 tests.
- `flutter analyze lib/services/backup_service.dart test/services/backup_service_photo_restore_test.dart`
  passed with no issues.
- `git diff --check` passed.
- Dirty-branch `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
  passed, including focused tests, dependency validation, custom lint, the full
  Flutter suite, `flutter analyze`, and the debug APK build.

## Stop Conditions

Stop if the focused test passes before production changes, if the fix requires
changing backup schema/import ownership, or if validation behavior conflicts
with existing documented restore safety requirements.
