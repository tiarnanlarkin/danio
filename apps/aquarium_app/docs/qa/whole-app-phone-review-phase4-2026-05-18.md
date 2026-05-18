# Whole-App Phone Review - Phase 4 Smart, More, Settings, Notifications, Backup

## Scope
- Smart fallback states and AI setup entry point.
- More navigation, profile/rewards/tools/settings entry points.
- Preferences notification entries, Smart Hub configuration, backup/restore, About and legal screens.
- Notification scheduling remains explicit opt-in only.

## Environment
- Date: 2026-05-18
- Branch: `feature/quiet-guidance-notifications`
- Build/commit: `1e1e701d` plus current uncommitted Phase 0-4 QA/worktree changes.
- App package: `com.tiarnanlarkin.danio`
- Phone: `SM F966B`
- Android: 16
- Device id: `RFCY8022D5R`
- Device state: returning user from Phase 3.

## Automated Baseline
- `flutter test test\widget_tests\smart_screen_test.dart --reporter expanded`: pass
- `flutter test test\widget_tests\settings_hub_screen_test.dart --reporter expanded`: pass
- `flutter test test\widget\settings_screen_test.dart --reporter expanded`: pass
- `flutter test test\widget_tests\notification_settings_screen_test.dart --reporter expanded`: pass
- `flutter test test\widget_tests\backup_restore_screen_test.dart test\widget_tests\backup_restore_screen_empty_state_test.dart --reporter expanded`: pass
- `flutter test test\widget_tests\about_screen_test.dart test\widget_tests\privacy_policy_screen_test.dart test\widget_tests\terms_of_service_screen_test.dart --reporter expanded`: pass
- `flutter test test\services\notification_scheduler_test.dart test\services\shared_preferences_backup_test.dart test\services\cloud_backup_service_test.dart test\services\backup_service_photo_restore_test.dart test\services\backup_import_relationships_test.dart test\model_tests\serialization_test.dart --reporter expanded`: pass
- `flutter analyze --no-pub`: pass
- `flutter build apk --debug --target-platform android-arm64`: pass
- `adb -s RFCY8022D5R install -r build\app\outputs\flutter-apk\app-debug.apk`: pass

## Phone Checklist
- Smart opens with stable setup/locked states and no floating tutorial interruption.
- More opens with normal navigation and no automatic tip overlay.
- Preferences exposes reminder settings clearly.
- Notification Settings starts with Review and Streak reminders disabled.
- Enabling a reminder requests Android notification permission.
- Streak notification schedules are created only after enabling Streak Reminders.
- Disabling Review and Streak reminders clears scheduled notifications.
- Backup & Restore opens and shows export/import options for the existing tank.
- About, Privacy Policy, and Terms of Service open and remain readable on the phone.
- No app crash, Flutter framework exception, or ANR appears in app logcat.

## Phone Evidence
- `docs/qa/screenshots/phase4-2026-05-18/smart.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/more.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/preferences.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/preferences-scroll2.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/notification-settings.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/review-toggle.png`: captured Android permission prompt
- `docs/qa/screenshots/phase4-2026-05-18/review-enabled.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/streak-enabled.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/reminders-disabled-final.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/backup-restore.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/about.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/privacy.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/terms.png`: captured
- `docs/qa/screenshots/phase4-2026-05-18/scheduled-notifications-final.xml`: captured
- `docs/qa/screenshots/phase4-2026-05-18/reminder-profile-final.txt`: captured
- `docs/qa/screenshots/phase4-2026-05-18/notification-permission-final.txt`: captured
- `docs/qa/screenshots/phase4-2026-05-18/phase4-app-logcat.txt`: captured
- `docs/qa/screenshots/phase4-2026-05-18/phase4-logcat.txt`: captured

## Findings
- Pass: Smart opened from `danio://qa/smart` with a stable AI setup card and locked AI feature cards. No floating tutorial, ambient tip, or XP nudge appeared.
- Pass: More opened from `danio://qa/more` with profile, Shop & Rewards, Tank Tools, and Preferences entry points. No automatic pop-up guidance appeared.
- Pass: Preferences showed `Reminder Settings` with the subtitle `Choose review and streak reminders`, plus the separate task-reminder section.
- Pass: Notification Settings copy said `Danio only schedules phone reminders you turn on here`; Review and Streak reminders started disabled.
- Pass: Enabling Review Reminders requested Android notification permission. With no due cards, `scheduled_notifications.xml` remained `[]`.
- Pass: Enabling Streak Reminders scheduled three streak reminders only after explicit opt-in.
- Pass: Turning Review and Streak reminders off restored `streakRemindersEnabled:false`, `reviewRemindersEnabled:false`, and `scheduled_notifications: []`.
- Pass: Android `POST_NOTIFICATIONS` permission was revoked after the opt-in test; final permission state is `granted=false`.
- Pass: Backup & Restore opened and showed one tank available for ZIP export plus the backup-file import flow.
- Pass: About, Privacy Policy, and Terms of Service opened from the phone and were scrollable/readable.
- Observation: screenshots still show the phone's Samsung Edge panel handle at the far-left edge. It is not part of Danio's UI tree.
- Observation: full device logcat contains Samsung/vendor network and notification-service noise. App-scoped logcat showed no Flutter framework crash or Danio error from the Phase 4 flow.

## Fixes
- No product-code fix needed in Phase 4.
- Added this Phase 4 QA record and the executable plan at `docs/superpowers/plans/2026-05-18-phase4-smart-more-settings-qa.md`.

## Final Result
- Automated checks: targeted Phase 4 tests, `flutter analyze --no-pub`, debug APK build, and phone install passed.
- Phone review: pass for Smart, More, Preferences, notification opt-in/off cleanup, Backup & Restore, About, Privacy, and Terms.
- Reminder state: final scheduled notifications are `[]`; final profile fields are `streakRemindersEnabled:false` and `reviewRemindersEnabled:false`.
- Permission state: Android notification permission restored to `granted=false` after testing the opt-in prompt.
- Issues fixed: none in product code.
- Carry-forward: Phase 5 should run the whole-app release regression, final debug APK smoke test on `RFCY8022D5R`, and a 20-30 minute exploratory pass across every tab.
