# Phase 5 Whole-App Release Regression QA

Date: 2026-05-18

Branch: `feature/quiet-guidance-notifications`

Base commit tested: `1e1e701d` plus local Phase 5 fixes

Device: `SM F966B`, Android 16, `RFCY8022D5R`

Package: `com.tiarnanlarkin.danio`

Evidence folder: `apps/aquarium_app/docs/qa/screenshots/phase5-2026-05-18/`

## Automated Gates

| Gate | Result | Notes |
| --- | --- | --- |
| `flutter analyze --no-pub` | Pass | No issues found. |
| `flutter test` | Pass | `+1071`, all tests passed. |
| `flutter test integration_test/smoke_test_v2.dart -d RFCY8022D5R` | Pass | `+5`, all smoke checks passed on phone. |
| `flutter build apk --debug --target-platform android-arm64` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk`. |
| `./build-release.ps1` | Pass | Cleaned, restored packages, reran analyzer, reran all tests (`+1071`), and built `build/app/outputs/bundle/release/app-release.aab` at 69.3 MB. |
| Post-release `flutter test integration_test/smoke_test_v2.dart -d RFCY8022D5R` | Pass | `+5`, all smoke checks passed again after the release script. |

## Fixes Applied During Phase 5

- Fixed a date-sensitive `TankHealthService.calculateWaterChangeStreak` test. The test used "yesterday", which fails on Mondays because it does not create a water change in the current Monday-Sunday week. It now anchors sample changes to the current Monday and two previous Mondays.
- Renamed the old Settings "Task Reminders" switch to "Phone Notifications". Phone permission is a global prerequisite for reminders, while review/streak schedules are controlled in Notification Settings. This keeps the label aligned with what the switch actually controls.

## Phone Review

| Area | Result | Evidence |
| --- | --- | --- |
| Fresh privacy and first-run route | Pass | `01-launch.png`, `02-after-consent.png`, `03-post-onboarding-skip.png` |
| Learn | Pass | `04-learn-clean.png`; one compact first-visit hint seen, no XP floating nudge. |
| Practice | Pass | `05-practice.png`; empty state guides user to finish a lesson, no floating interruption. |
| Tank | Pass | `06-tank.png`; no `Start a quick lesson to earn XP today!`, no ambient tip overlay, no stacked tutorial banners. |
| Smart | Pass | `07-smart.png`; inline locked/fallback state, no pop-up prompt. |
| More | Pass | `08-more.png`; stable profile/progress UI, no disruptive guidance. |
| More lower entries | Pass | `20-more-lower-settings.png`; Preferences, Backup & Restore, and About entry points visible and tappable. |
| Backup & Restore | Pass | `21-backup-restore-entry.png`; export/import entry surface renders on phone. |
| About/legal | Pass | `22-about-legal-entry.png`, `23-about-legal-lower.png`; About renders and Privacy, Terms, and Licenses links are present. |
| Preferences | Pass | `18-final-phone-notifications.png`; Phone Notifications copy is explicit and default off. |
| Notification Settings | Pass | `19-final-reminder-settings-default.png`; review and streak reminders default off. |

## Notification Evidence

- Final Android permission: `POST_NOTIFICATIONS: granted=false` in `final-dumpsys-package.txt`.
- Final scheduled notifications: `scheduled_notifications` is `[]` in `final-scheduled-notifications.xml`.
- Final profile fields: `reviewRemindersEnabled:false` and `streakRemindersEnabled:false` in `final-flutter-shared-preferences.xml`.
- After the post-release smoke test, the test runner removed the app package. The current debug APK was reinstalled and launched manually so the phone is left with the app available.
- Post-reinstall notification state: `POST_NOTIFICATIONS: granted=false`, no `scheduled_notifications.xml` exists on fresh launch, and the current package UID (`10624`, `u0a624`) is not present in Android's pending alarm UID list.
- `dumpsys alarm` still contains historical Danio alarm-manager entries for old install UIDs (`u0a616`, `u0a618`, `u0a619`, `u0a621`, `u0a622`). These are alarm history, not current pending alarms for the active install.
- Manual opt-in path checked earlier in the same phone pass:
  - Review reminder toggle produced the Android permission prompt only after an explicit user action: `13-review-toggle-attempt.png`.
  - Enabling review reminders updated its label but did not schedule anything without due cards: `14-review-reminders-enabled.png`, scheduled notifications stayed `[]`.
  - Enabling streak reminders scheduled streak reminders: `15-streak-reminders-enabled.png`.
  - Disabling streak reminders cleared scheduled notifications back to `[]`: `16-reminders-disabled-final.png`.

## Log Review

`final-logcat-tail.txt` was scanned for:

- `FATAL EXCEPTION`
- `AndroidRuntime`
- `FlutterError`
- `Unhandled Exception`
- `Exception caught by widgets`

No matching crash or Flutter framework exception was found.

## Findings

- P0: none.
- P1: none.
- P2 fixed: Settings used to show the global notification permission gate as "Task Reminders", which made it look like task reminders were enabled after granting permission from review/streak settings. It now reads "Phone Notifications".
- P2 fixed: one Monday-only unit test flake in tank health streak coverage.
- P3 noted: the Samsung Edge Panel handle appears on the left edge of phone screenshots. This is a device overlay, not app UI.

## Final State

Phase 5 release regression is pass after the two small fixes above. The release AAB was built successfully, the post-release phone smoke passed, and the final installed debug candidate is in a quiet default state: phone notification permission denied, Phone Notifications off, review reminders off, streak reminders off, and no current scheduled notifications for the active install.
