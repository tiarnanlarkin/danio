# Whole-App Phone Review - Phase 2

Date: 2026-05-17
Branch: `feature/quiet-guidance-notifications`
Target device: `SM F966B` / Android 16 / `RFCY8022D5R`

## Scope

Phase 2 covers the Tank and daily care workflow:

- Tank landing as a returning user with an existing tank.
- Quiet-guidance behavior on the Tank room screen.
- Today board, bottom activity panel, side handles, toolbox, tank settings.
- Daily care actions: add log, quick water test, feeding, water change.
- Notification safety during care actions.

## Device State

Physical-phone review completed on `SM F966B` / Android 16 / `RFCY8022D5R` after reinstalling the debug APK with app data preserved.

Returning-user app state had:

- `Betta Paradise` tank persisted.
- Betta livestock persisted.
- `scheduled_notifications` empty (`[]`) before and after Tank care actions.

## Findings And Fixes

| ID | Severity | Status | Finding |
| --- | --- | --- | --- |
| P2-01 | P2 | Fixed | Tank automatically showed first-entry welcome/comeback banners. `HomeScreen` no longer creates `WelcomeBanner` or `ComebackBanner`; the only remaining Tank first-visit prompt is the central guidance side-handle hint. |
| P2-02 | P1 | Fixed | Logging a water change scheduled a phone reminder directly through `NotificationService()`, bypassing explicit opt-in. The Add Log save path no longer schedules water-change notifications automatically. |
| P2-03 | P2 | Fixed | Quick Water Test could silently do nothing when no values were entered and silently save otherwise. It now warns on empty input, confirms save with `Water test logged! +10 XP`, and shows an error if saving fails. |
| P2-04 | P2 | Passed phone | Physical-phone care session covered Today board, side handles, toolbox, tank settings, quick water test, feeding, and water change on `RFCY8022D5R`. |
| P2-05 | P2 | Fixed | Tank Settings overflowed on the phone-width layout. The tank type dropdown now expands and truncates long menu labels safely. |
| P2-06 | P1 | Fixed | The quick-care speed dial had a zero-size hit-test/paint surface, so the action pills could be clipped or invisible. The menu now has a stable 360 x 560 surface and the phone UI tree exposes Quick Test, Feed, Water Change, Stats, and Add Tank. |
| P2-07 | P1 | Fixed | Filled Quick Water Test initially hit the app error screen. Root cause was local `TextEditingController`s being disposed by the modal future while Flutter was still rebuilding the closing sheet. The quick-test form is now a stateful sheet that owns and disposes its controllers through widget lifecycle. |
| P2-08 | P3 | Fixed | The Feed info sheet opened the Add Log flow with `initialType: Feeding`, but the selector did not include a Feeding chip and the title fell back to `Add Log`. Add Log now includes Feeding as a selector option, titles the flow `Log Feeding`, and scrolls the selected chip into view for preselected types. |

## Quiet Guidance Checks

- Removed automatic floating welcome/comeback Tank banners.
- Kept the optional Tank side-handle hint under the central guidance system.
- Confirmed source still excludes `DailyNudgeBanner`, `AmbientTipOverlay`, and `StreakHeartsOverlay`.
- Removed direct water-change reminder scheduling from the care-log path.
- Phone pass confirmed no XP nudge, no ambient overlay, and no welcome/comeback banner stack on Tank.

## Automated Verification

Latest passed:

- `flutter test test\screens\tank_daily_care_contract_test.dart --reporter expanded`
- `flutter test test\screens\home_guidance_contract_test.dart --reporter expanded`
- `flutter test test\widget_tests\tank_settings_screen_test.dart --reporter expanded`
- `flutter analyze --no-pub`
- `flutter build apk --debug --target-platform android-arm64`
- `git diff --check` (line-ending warnings only)

Phone verification passed:

- Installed debug APK on `RFCY8022D5R` with `adb install -r`.
- Quick Test empty input showed `Enter at least one test value.`
- Quick Test with pH `7.4` saved and returned to Tank with no filtered Flutter/ErrorBoundary logs.
- Feeding logged and returned to Tank with no filtered Flutter/ErrorBoundary logs.
- Water Change `25%` logged and returned to Tank with no filtered Flutter/ErrorBoundary logs.
- `shared_prefs/scheduled_notifications.xml` remained `[]`.

Not run in this Phase 2 closeout:

- Full `flutter test`; save this for Phase 5 release regression or run it at the start of Phase 3 if we want a broader gate before Learn/Practice work.

## Phone Review Checklist

1. Pass: app opened with existing tank state.
2. Pass: Tank tab loaded without floating XP nudge, ambient tip overlay, or welcome/comeback banner stack.
3. Pass: left temperature and right water-quality side handles opened.
4. Pass: bottom activity panel exposed Progress, Today, and Tools content.
5. Pass: Tank Toolbox navigation opened Reminders, Tank Journal, Analytics, and Species Search.
6. Pass: Tank Settings loaded without phone-width clipping after the dropdown fix.
7. Pass: Quick Test empty input warned in place.
8. Pass: Quick Test with one pH value saved and returned to Tank.
9. Pass: Feeding flow saved and returned to Tank.
10. Pass: Water Change flow saved and returned to Tank.
11. Pass: `scheduled_notifications.xml` remained `[]`.

## Post-Phase Add Log Polish

- Branch: `fix/add-log-initial-type-scroll`
- Root cause: `AddLogScreen` accepted `LogType.feeding`, but `AddLogTypeSelector` only exposed water test, water change, observation, and medication chips. Feeding therefore saved correctly but did not look selected in the header selector.
- Implementation: the selector now uses a shared option list with Feeding included, scrolls the selected chip into view after layout and selection changes, and `AddLogScreen` now titles feeding entries as `Log Feeding`.
- Regression coverage:
  - `flutter test test/widget_tests/add_log_screen_test.dart --plain-name "feeding entry opens with Feeding selected"` failed before the fix because `Log Feeding` was not rendered, then passed after the fix.
  - `flutter test test/widget_tests/add_log_screen_test.dart` passed with 10 tests.
  - `flutter analyze --no-pub` passed with no issues.
  - `flutter test` passed with 1,107 tests.
  - `flutter build apk --debug --target-platform android-x64 --target lib/main.dart` passed, installed on `emulator-5580`, and launched.
  - Emulator logcat scan for the running app process found no `FATAL EXCEPTION`, `AndroidRuntime`, `FlutterError`, unhandled exception, or widget exception markers.
  - `flutter build apk --debug --target-platform android-arm64 --target lib/main.dart` passed.
