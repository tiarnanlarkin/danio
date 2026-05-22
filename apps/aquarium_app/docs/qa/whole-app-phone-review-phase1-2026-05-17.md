# Whole-App Phone Review - Phase 1

Date: 2026-05-17
Branch: `feature/quiet-guidance-notifications`
Device: `SM F966B` / Android 16 / `RFCY8022D5R`

## Scope

Phase 1 covered the fresh-install first-run path:

- Consent and privacy choice.
- Welcome, experience level, tank situation.
- Mandatory first micro-lesson.
- XP celebration, fish selection, care profile reveal.
- Feature summary, optional reminders, warm entry.
- First main-app landing and Tank readiness.

## Phone Review State

The first phone pass reached main app and exposed real onboarding issues. After fixes, the patched APK was built, installed, and app data was cleared for a fresh rerun.

Final fresh phone rerun completed from consent through first main-app landing:

- Chose `No Thanks` for crash sharing after age/terms consent.
- Chose `Just starting out` and `Already up and running`.
- Answered the micro-lesson with `Uncycled water`; feedback and `Got it` auto-scrolled into view.
- Selected `Betta`; the care reveal auto-scrolled to `Start your journey`.
- Feature summary advanced to optional reminders.
- Chose `Set up reminders later`.
- Skipped optional name.
- Landed on Tank, not Learn, with persisted `Betta Paradise` tank and Betta livestock.

No Danio crash was seen in the crash buffer. `scheduled_notifications.xml` contained an empty `[]` list after choosing reminders later.

## Findings And Fixes

| ID | Severity | Status | Finding |
| --- | --- | --- | --- |
| P1-01 | P1 | Fixed | Feature summary CTA could fail to advance. `FeatureSummaryScreen` now guards duplicate completion and has a fallback body tap; onboarding jumps explicitly to the reminders step. |
| P1-02 | P1 | Fixed | Creating/updating a profile could make the root router leave onboarding before tank creation ran. Completion now captures notifiers up front, finishes species unlock, XP, tank creation, livestock creation, and then completes onboarding. |
| P1-03 | P1 | Fixed | After first-run setup, users should land on Tank and see the tank they just created. Completion now sets `currentTabProvider` to Tank. |
| P1-04 | P2 | Fixed | Micro-lesson feedback and `Got it` action were below the fold after answering. The lesson now scrolls to feedback/action after answer reveal. |
| P1-05 | P2 | Fixed | Fish profile reveal CTA was below the fold. The reveal now scrolls to the invite/CTA after the final phase appears. |
| P1-06 | P2 | Fixed | Full-width buttons could overflow on narrow layouts. `AppButton` now flexes and ellipsizes long full-width labels while preserving short-button rendering. |
| P1-07 | P2 | Fixed | Fish picker card titles could truncate on phone (`Bronze Co...`, `Dwarf Gou...`, etc.). Popular fish names now wrap to two lines before the scientific name. |
| P1-08 | P2 | Fixed in Phase 2 | First Tank landing still showed a dismissible welcome banner during Phase 1. Phase 2 P2-01 removed the automatic welcome/comeback Tank banners; `home_guidance_contract_test.dart` keeps `WelcomeBanner` and `ComebackBanner` out of `HomeScreen`. |
| P1-09 | P3 | Not app | The pink left-edge handle seen in screenshots is the phone OS edge panel, not Danio UI. |

## Quiet Guidance Checks

- Optional reminders copy was reached and confirmed as opt-in copy: no enablement from onboarding copy path.
- Phone storage confirmed `scheduled_notifications` was `[]`, with `streakRemindersEnabled: false` and `reviewRemindersEnabled: false` in the saved user profile.
- Tank first landing showed no removed XP floating nudge, no automatic ambient tip, and no setup selector after onboarding completion.
- Tank still showed a small first-entry welcome banner during this Phase 1 run; this was carried into Phase 2 and fixed under P2-01.
- Learn first-visit guidance appeared as a compact top hint.

## Automated Verification

Passed:

- `flutter test test\widget_tests\micro_lesson_screen_test.dart test\widget_tests\aha_moment_screen_test.dart test\widget_tests\feature_summary_screen_test.dart`
- `flutter test test\golden_tests\mc_card_golden_test.dart --reporter expanded`
- `flutter test`
- `flutter analyze --no-pub`
- `flutter build apk --debug --target-platform android-arm64`

Full-suite status:

- Initial `flutter test` after the broad `AppButton` change found one `mc_card_answered.png` golden diff.
- `AppButton` was narrowed to constrain only long full-width labels/icons/loading states.
- The isolated McCard golden now passes.
- A final full `flutter test` rerun passed: 1,067 tests.

## Post-Phase Fish Picker Polish

- Branch: `fix/fish-picker-title-wrap`
- Root cause: popular fish tile common names were hard-limited to one line with ellipsis inside the 3-column picker grid.
- Implementation: common names now wrap to two lines, while scientific names use one line to keep card height stable.
- Regression coverage:
  - `flutter test test/widget_tests/fish_select_screen_test.dart --plain-name "popular fish names can wrap instead of truncating"` failed on the old one-line contract, then passed after the fix.
  - `flutter test test/widget_tests/fish_select_screen_test.dart` passed with 10 tests.
  - `flutter test test/widget_tests/tank_status_screen_test.dart --plain-name "selecting a status and tapping Continue calls onSelected"` passed, preserving the preceding onboarding step's continue contract.
  - `flutter test test/widget_tests/fish_select_screen_test.dart test/widget_tests/tank_status_screen_test.dart` passed with 16 tests.
  - `flutter analyze --no-pub` passed with no issues.
  - `flutter test` passed with 1,106 tests.
  - `flutter build apk --debug --target-platform android-x64 --target lib/main.dart` passed and installed on `emulator-5580`.
  - `flutter build apk --debug --target-platform android-arm64 --target lib/main.dart` passed.
  - Emulator logcat scan for the running app process found no `FATAL EXCEPTION`, `AndroidRuntime`, `FlutterError`, unhandled exception, or widget exception markers.
- Original evidence: [fish picker truncation](screenshots/phase1-2026-05-17/18_betta_picker.png).

## Screenshot Artifacts

Screenshots and UI dumps are under:

`docs/qa/screenshots/phase1-2026-05-17/`

Key artifacts:

- `17_tank_situation_continue_stuck.png`
- `18_betta_picker.png`
- `19_first_main_learn.png`
- `20_tank_after_deeplink.png`
- `fish_picker_after_patch.png`
- `tank_landing_after_onboarding.png`

## Phone Rerun Checklist

Completed on `SM F966B` after app-data reset:

1. Clear app data for `com.tiarnanlarkin.danio`. Pass.
2. Run normal debug build. Pass.
3. Complete consent and onboarding naturally. Pass.
4. Choose `Just starting out`, `Already up and running`, answer `Uncycled water`, choose `Betta`. Pass.
5. Confirm lesson feedback auto-scrolls to `Got it`. Pass.
6. Confirm profile reveal auto-scrolls to `Start your journey`. Pass.
7. Confirm feature summary advances to optional reminders. Pass.
8. Choose `Set up reminders later`. Pass.
9. Skip optional name. Pass.
10. Confirm first main screen is Tank with the created tank and no removed floating XP nudge/tutorial stack. Pass during Phase 1, with the remaining welcome banner later fixed under Phase 2 P2-01.
