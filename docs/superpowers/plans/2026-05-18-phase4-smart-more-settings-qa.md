# Phase 4 Smart, More, Settings, Notifications, And Backup QA

## Goal
- Review Smart, More, Preferences, notification settings, backup/restore, and legal/about surfaces on the connected Android phone.
- Keep the quiet-guidance policy intact: Smart and More may use inline first-visit help, but there should be no floating tutorial stack, XP nudge, or automatic phone reminder.
- Verify reminder scheduling remains explicit opt-in only and clears schedules when reminders are disabled.

## Environment
- Date: 2026-05-18
- Branch: `feature/quiet-guidance-notifications`
- Base commit: `1e1e701d`
- App package: `com.tiarnanlarkin.danio`
- Device: `SM F966B`
- Android: 16
- Device id: `RFCY8022D5R`
- Device state: returning user from Phase 3.

## Automated Checks
- Run focused widget/service/model checks for:
  - Smart screen
  - More/settings hub
  - Preferences
  - Notification settings
  - Backup/restore
  - About/privacy/terms
  - Notification scheduler
  - SharedPreferences backup and profile serialization
- Run `flutter analyze --no-pub`.

## Phone Review Steps
1. Build a debug APK and install it with `adb install -r`.
2. Launch the app as a returning user.
3. Open `danio://qa/smart` and inspect Smart fallback/locked states.
4. Open `danio://qa/more` and inspect More navigation and inline guidance behavior.
5. Open `danio://qa/settings`, then inspect Preferences notification entries.
6. Open Notification Settings.
7. Confirm Review and Streak reminders are disabled by default.
8. Enable Review Reminders once and allow Android notification permission when prompted.
9. Enable Streak Reminders once and confirm schedules are created only after explicit opt-in.
10. Disable both reminder toggles and confirm scheduled notifications are cleared.
11. Revoke Android notification permission after the opt-in test to restore the phone to its pre-test permission state.
12. Open Backup & Restore and verify export/import entry points are clear.
13. Open About, Privacy Policy, and Terms of Service.
14. Pull screenshots, UI XML, final reminder prefs, final permission state, and logcat.

## Expected Results
- Smart shows stable AI setup/locked state without transient tutorial overlays.
- More opens without floating nudges or stacked prompts.
- Notification Settings copy states that only enabled reminders are scheduled.
- Review and Streak reminders default to off.
- Android notification permission appears only when the user enables a reminder.
- Scheduled notifications remain `[]` until explicit opt-in.
- Disabling reminders returns `scheduled_notifications` to `[]`.
- Final Android notification permission is restored to `granted=false`.
- Backup/restore, About, Privacy, and Terms screens fit the phone and remain navigable.
- App logcat contains no Flutter framework errors, crash, or ANR from the reviewed flow.

## Result
- No product-code fix was required in Phase 4.
- Evidence and final notes are recorded in `apps/aquarium_app/docs/qa/whole-app-phone-review-phase4-2026-05-18.md`.
