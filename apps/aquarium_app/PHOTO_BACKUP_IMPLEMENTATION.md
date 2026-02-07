# Photo Backup (ZIP Export/Import) — Implementation Notes

## Overview
This implementation upgrades the Aquarium App backup system from **JSON-only** exports to a **ZIP-based backup** that includes **all photos**.

A backup is now a single `*.zip` file containing:
- `backup.json` (all app data)
- `photos/` (all photo files referenced by the data, plus any other local photos found in the app photo directory)

## Why ZIP (not Base64)
- **Efficient size** (no Base64 overhead)
- **Fast I/O** and widely supported format
- **Stream-friendly** (avoid loading every image into memory)
- Easy for users to share/inspect

## ZIP Layout
Example:
```
aquarium_backup_2026-02-07T10-30-00.zip
├── backup.json
└── photos/
    ├── <uuid>.jpg
    ├── <uuid>.png
    └── ...
```

## Key Design Choice: Portable photo references
### Problem
Previously, JSON stored absolute device paths like:
```
/var/mobile/.../Documents/photos/<uuid>.jpg
```
Those paths are **not valid on another device**.

### Solution
During export, `BackupService.createBackup()` rewrites any local photo paths to:
```
photos/<filename>
```
This makes `backup.json` **device-independent**.

During import preview/loading, `BackupService.getBackupData()` automatically resolves those portable refs back into absolute paths for the current device:
```
<app_documents>/photos/<filename>
```

## Implementation

### 1) BackupService
**File:** `lib/services/backup_service.dart`

**Responsibilities**
- Build a ZIP backup containing JSON + photos
- Restore photos from a ZIP into the app’s `Documents/photos/` directory
- Read backup JSON for preview/import

**Important methods**
- `Future<String> createBackup(Map<String, dynamic> exportData)`
  - Deep-rewrites photo paths in `exportData` to portable `photos/<filename>` refs
  - Collects photo refs from JSON
  - Also scans the app photos directory to avoid missing unreferenced images
  - Creates `backup.json` in a temp file
  - Uses `archive_io` **ZipFileEncoder** to stream JSON + photo files into the ZIP (avoids reading whole image bytes into memory)

- `Future<int> restoreBackup(String zipPath)`
  - Decodes the ZIP
  - Extracts `photos/*` into the app photo directory
  - **Does not overwrite** existing files
  - Returns the number of tanks in the JSON (used only for UI messaging)

- `Future<Map<String, dynamic>> getBackupData(String zipPath)`
  - Reads `backup.json`
  - Resolves any `photos/<filename>` refs into absolute device paths under the current `Documents/photos/` directory
  - This means import code can treat image fields as normal local file paths

**Progress reporting**
`BackupService` accepts `onProgress(String status, double progress)` and reports granular stages:
- Preparing
- Collecting photos
- Adding photos (per-file)
- Finalizing
- Restoring photos (per-file)

### 2) Backup & Restore Screen
**File:** `lib/screens/backup_restore_screen.dart`

**Export flow**
- Collects comprehensive data across all tanks (tanks, livestock, equipment, logs, tasks)
- Calls `BackupService.createBackup(exportData)`
- Shares the generated ZIP via `share_plus`
- Deletes the temp ZIP after sharing (best-effort)

**Import flow**
- User picks a `.zip` via `file_picker`
- Calls `getBackupData()` to preview the tank count
- On confirmation:
  1) Calls `restoreBackup()` to extract photos
  2) Imports JSON entities into storage
     - Creates **new tank IDs** to avoid collisions
     - Remaps all related `tankId` references
- Invalidates providers to refresh UI

## Backward compatibility
- Old exports with absolute paths containing `/photos/` are still handled safely:
  - Export path rewrite uses `basename()` so old-style absolute paths become `photos/<filename>`
  - Import resolution always maps `photos/<filename>` into the current device photo directory

## Dependencies
`pubspec.yaml`:
```yaml
dependencies:
  archive: ^3.6.1
  file_picker: ^8.1.7
  share_plus: ^10.1.4
  path: ^1.9.0
```

## Files changed/added
- `lib/services/backup_service.dart` (ZIP creation/extraction + portable photo refs)
- `lib/screens/backup_restore_screen.dart` (uses ZIP backup; progress UI)
- `pubspec.yaml` (archive dependency)
- `PHOTO_BACKUP_IMPLEMENTATION.md` (this document)

## Manual test checklist
- Export a tank with a cover photo
- Export logs with multiple photos
- Import on another device/emulator:
  - Tanks and related entities appear
  - Photos render correctly
  - No crashes when a photo is missing
  - Existing photos are not overwritten

## Notes / Future improvements
- Optional encryption/password-protected backups
- Selective restore (choose tanks)
- Integrity checks (hashes)
- Deduplicate photo files by content hash
