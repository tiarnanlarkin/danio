# DS-2026-07-05-041 - Scope Backup Photo References To Photo Fields

Status: In progress
Date: 2026-07-05
Branch: `ds-2026-07-05-041-backup-photo-field-scope`

## Goal

Prevent BackupService preview, export, and restore from treating normal free-text
fields as required photo references merely because the text contains a
`photos/<name>.<ext>`-shaped string.

## Evidence

Fresh source review after DS-2026-07-05-040 found that BackupService walks every
string in the backup payload when collecting, validating, making portable, and
resolving photo references. That means a normal `notes` or `title` value such as
`See photos/orphan.jpg later` can be treated as a required bundled photo even
though only `imageUrl` and `photoUrls` fields are user photo references in the
current exported tank-scoped data model.

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

## RED/GREEN Plan

1. Add focused tests proving BackupService rejects or rewrites free-text
   `notes` containing `photos/orphan.jpg` even though the actual `imageUrl`
   reference is valid.
2. Run the named tests and verify RED for the current missing-archive-photo
   validation or unwanted free-text rewrite behavior.
3. Restrict photo reference traversal to photo-bearing fields.
4. Re-run the named tests, then the full
   `test/services/backup_service_photo_restore_test.dart` file.

## Gate Plan

- `dart format lib\services\backup_service.dart test\services\backup_service_photo_restore_test.dart`
- `flutter test test/services/backup_service_photo_restore_test.dart --reporter compact`
- `flutter analyze lib/services/backup_service.dart test/services/backup_service_photo_restore_test.dart`
- `git diff --check`
- `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`

## Stop Conditions

Stop if the focused tests pass before production changes, if the fix needs a
new backup schema, if current source shows additional photo-bearing fields that
cannot be handled narrowly, or if the change would weaken existing missing-photo
or duplicate referenced-photo validation.
