# Phase 5 Whole-App Release Regression QA

## Goal
- Run the final whole-app regression gates after Phases 0-4.
- Validate the final debug candidate on `SM F966B` / Android 16 / `RFCY8022D5R`.
- Confirm the quiet-guidance and explicit-reminder policies still hold across the whole app.

## Environment
- Date: 2026-05-18
- Branch: `feature/quiet-guidance-notifications`
- Base commit: `1e1e701d`
- App package: `com.tiarnanlarkin.danio`
- Device: `SM F966B`
- Android: 16
- Device id: `RFCY8022D5R`
- Device state: returning user from Phase 4 unless a test explicitly resets state.

## Automated Gates
1. `flutter analyze --no-pub`
2. `flutter test`
3. `flutter test integration_test/smoke_test_v2.dart -d RFCY8022D5R`
4. `flutter build apk --debug --target-platform android-arm64`

## Phone Exploratory Pass
1. Install the debug APK with `adb install -r`.
2. Clear logcat and launch the app.
3. Review these tab surfaces on the phone:
   - Learn
   - Practice
   - Tank
   - Smart
   - More
4. Review key secondary flows:
   - Preferences
   - Notification Settings
   - Backup & Restore
   - About / Privacy / Terms
5. Confirm:
   - No floating Tank XP nudge.
   - No automatic ambient/bottom tips or stacked tutorial banners.
   - No phone reminders scheduled without explicit opt-in.
   - Navigation remains usable above Android system bars.
   - No crash, ANR, or Flutter framework exception appears in app logcat.
6. Capture screenshots, UI XML where useful, app-scoped logcat, full logcat tail, final scheduled notification state, and final notification permission state.

## Issue Policy
- P0: crash, data loss, cannot complete core flow. Fix before closing Phase 5.
- P1: major confusion or broken primary action. Fix before closing Phase 5 where practical.
- P2: polish/layout/copy issue that hurts trust. Record and fix if scoped/safe.
- P3: nice-to-have. Record for follow-up.

## Deliverable
- `apps/aquarium_app/docs/qa/whole-app-phone-review-phase5-2026-05-18.md`
- Screenshot/log evidence under `apps/aquarium_app/docs/qa/screenshots/phase5-2026-05-18/`.
