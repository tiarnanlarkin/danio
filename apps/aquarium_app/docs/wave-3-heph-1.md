# Wave 3 — Trivial Cleanup (Part 1)
**Date:** 2026-03-29  
**Agent:** Hephaestus

---

## FB-O1: Version strings centralised ✅

**Problem:** Three different hardcoded version strings across the codebase, all inconsistent:
- `about_screen.dart` → `'1.0.0'`
- `backup_restore_screen.dart` → `'1.0.0'`
- `settings_screen.dart` → `'0.1.0'` (in two places — version row subtitle + `_showAboutDialog`)

**Fix:**
1. Added `kAppVersion` constant to `lib/utils/app_constants.dart` — injected via `--dart-define=APP_VERSION` at build time, defaults to `'1.0.0'`.
2. Removed the duplicate `appVersion` const definition from `settings_hub_screen.dart`; replaced with an alias `const String appVersion = kAppVersion` for backward compatibility.
3. Updated all hardcoded strings to reference `kAppVersion`:
   - `about_screen.dart` — version display text + `showLicensePage` call
   - `backup_restore_screen.dart` — export metadata `'appVersion'` field
   - `settings_screen.dart` — version subtitle row + `showAboutDialog` call

---

## FB-O2: Duplicate About entry removed ✅

**Problem:** `lib/screens/settings/settings_screen.dart` had **two** "About" list entries in the "About & Privacy" section:
1. `AppListTile` → called `_showAboutDialog()` (a generic Flutter `showAboutDialog` popup — the duplicate)
2. `NavListTile` → navigated to the full `AboutScreen` widget (the correct one)

**Fix:**
- Removed the `AppListTile` that called `_showAboutDialog`.
- Removed the now-dead `_showAboutDialog` private method entirely.
- The `NavListTile → AboutScreen` entry is retained (located lower in the settings list under "Help & Support").

---

## FB-O7: Debug print statements removed ✅

**Problem:** 5 bare `print(...)` calls in `lib/services/debug_deep_link_service.dart`. The file suppressed the lint warning with `// ignore_for_file: avoid_print`.

**Fix:** Replaced all 5 `print(...)` calls with `debugPrint(...)` — which is a no-op in release builds by Flutter's default implementation. Removed the `// ignore_for_file: avoid_print` suppression comment.

Files changed:
- `lib/services/debug_deep_link_service.dart` — 5 prints → debugPrint, ignore comment removed

---

## Flutter Analyze Result

```
flutter analyze --no-pub  →  8 issues found (ran in ~24s)
```

All 8 issues are **pre-existing test file problems** unrelated to this wave:
- 3 errors in `test/widget_tests/theme_gallery_screen_test.dart` (missing `ThemeGalleryScreen` export — screen was removed/renamed)
- 3 infos + 1 warning in `test/widget_tests/tab_navigator_test.dart`

**Zero issues in `lib/`** — all production code is clean.

---

## Files Changed

| File | Change |
|------|--------|
| `lib/utils/app_constants.dart` | Added `kAppVersion` constant |
| `lib/screens/settings_hub_screen.dart` | Removed duplicate const definition; aliased to `kAppVersion` |
| `lib/screens/about_screen.dart` | Import updated; 2 hardcoded strings → `kAppVersion` |
| `lib/screens/backup_restore_screen.dart` | Import added; 1 hardcoded string → `kAppVersion` |
| `lib/screens/settings/settings_screen.dart` | 2 hardcoded strings → `kAppVersion`; duplicate About entry removed; dead `_showAboutDialog` method removed |
| `lib/services/debug_deep_link_service.dart` | 5× `print` → `debugPrint`; ignore_for_file comment removed |
