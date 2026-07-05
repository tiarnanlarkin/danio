# DS-2026-07-05-041 - Scope Backup Photo References To Photo Fields

Status: Complete
Date: 2026-07-05
Branch: `ds-2026-07-05-041-backup-photo-field-scope`

## Goal

Prevent BackupService preview, export, and restore from treating normal free-text
fields as required photo references merely because the text contains a
`photos/<name>.<ext>`-shaped string.

## Evidence

Fresh source review after DS-2026-07-05-040 found that BackupService walked every
string in the backup payload when collecting, validating, making portable, and
resolving photo references. That meant a normal `notes` or `title` value such as
`C:/old/photos/orphan.jpg` could be treated as a required bundled photo even
though source review found only `imageUrl` and `photoUrls` as current exported
user photo reference fields.

## Intended Behavior

- Backup preview/restore should validate, resolve, and extract files referenced
  by current photo fields: `imageUrl` and `photoUrls`.
- Normal string fields such as `notes`, `title`, `name`, or descriptions should
  remain unchanged even when their text includes a photo-like path.
- Referenced photo fields should keep the DS-039 and DS-040 behavior: missing
  referenced photos fail safely, referenced duplicate basenames fail safely, and
  archive-only or free-text-only photo-like strings do not block valid restores.

## Files

- `lib/services/backup_service.dart`
- `test/services/backup_service_photo_restore_test.dart`
- `docs/agent/ACTIVE_HANDOFF.md`
- `docs/agent/FINISH_MAP.md`
- `docs/agent/SLICE_LOG.md`
- `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

## Risk

Tier 2 data safety. Backup export, preview, and restore validation are local
data-resilience boundaries.

## RED/GREEN Proof

1. RED:
   `flutter test test/services/backup_service_photo_restore_test.dart --plain-name "createBackup ignores free-text photo-like strings outside photo fields" --reporter compact`
   failed with `Cannot create backup: referenced photo "orphan.jpg" was not found`.
2. RED:
   `flutter test test/services/backup_service_photo_restore_test.dart --plain-name "getBackupData ignores free-text photo-like strings outside photo fields" --reporter compact`
   failed with `Invalid backup: referenced photo "orphan.jpg" is missing from archive`.
3. GREEN: the same named tests passed after photo reference extraction,
   portability conversion, and restore resolution were scoped to `imageUrl` and
   `photoUrls`.
4. GREEN:
   `flutter test test/services/backup_service_photo_restore_test.dart --reporter compact`
   passed with 137 tests.

## Gate Evidence

- `dart format lib\services\backup_service.dart test\services\backup_service_photo_restore_test.dart`
- `flutter test test/services/backup_service_photo_restore_test.dart --reporter compact`
- `flutter analyze lib/services/backup_service.dart test/services/backup_service_photo_restore_test.dart`
- `git diff --check`
- Dirty-branch `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
  from `apps\aquarium_app` passed after the behavior change.
- Branch clean-worktree and clean-main Full gates are required before the slice
  is pushed to `origin/main`.

## Stop Conditions

Stop if the focused tests pass before production changes, if the fix needs a
new backup schema, if current source shows additional photo-bearing fields that
cannot be handled narrowly, or if the change would weaken existing missing-photo
or duplicate referenced-photo validation.
