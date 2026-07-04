# Danio CL-QA-001 Phone Whole-App Map

Date: 2026-07-04
Branch: `qa/production-tool-audit-2026-05-25`
Initial map source: `20f14eee`
Latest Smart recapture source: `273a9644`
Device: `danio_api36`, `emulator-5554`, 1080x2400
Build: `build/app/outputs/flutter-apk/app-debug.apk`
Evidence root: `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`

## Result

Status: In progress, not complete.

This pass captured a current 19-surface phone screenshot/XML set through debug
QA deep links, plus pre-fix smoke-failure evidence. A follow-up fixed the Smart
bottom-dock overlap and black-box helper false positives, then the phone
black-box smoke rerun passed. A later phone recapture confirmed Fish & Plant ID
now clears the dock on `danio_api36`. It does not close CL-QA-001 because the
full `SCREEN_INVENTORY.md` surface set still needs manual or scripted coverage.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| Device ownership | Pass | `run_danio_live_preview.ps1 -DeviceId emulator-5554 -CheckOnly -WaitSeconds 180` confirmed `danio_api36`, foreground package `com.tiarnanlarkin.danio`. |
| AndroidPrep | Pass | `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep` passed focused tests, dependency validation, custom lint, `flutter analyze`, debug APK build, and device visibility. Build emitted known Kotlin Gradle Plugin deprecation warnings only. |
| APK install/launch | Pass | `adb -s emulator-5554 install -r build\app\outputs\flutter-apk\app-debug.apk` and `adb -s emulator-5554 shell am start -n com.tiarnanlarkin.danio/.MainActivity` succeeded. |
| Phone black-box smoke with QA deep links | Pass after fix | Final rerun passed with `.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5554 -InstallApkPath build\app\outputs\flutter-apk\app-debug.apk -IncludeQaDeepLinks -ArtifactDir build\qa-artifacts\android-blackbox-phone-2026-07-04`. Earlier pre-fix failure evidence remains in `phone-smoke-failure.txt`, `phone-smoke-failure-smart-overlap.png`, and `phone-smoke-failure-smart-overlap.xml`. |
| Phone Smart root recapture | Pass | `phone-04b-smart-root-after-dock-fix.png` / `.xml` captured from `danio://qa/smart` after installing the current debug APK. XML bounds show Fish & Plant ID bottom `2080`, bottom dock top `2127`, for `47px` clearance. |
| Direct QA deep-link capture | Pass for captured set | 19 original `.png` files and 19 paired `.xml` files were saved, plus the after-fix Smart recapture; every XML contains a `<hierarchy>` root. |
| Narrow crash signature scan | Pass | No matches for `FATAL EXCEPTION`, `AndroidRuntime: FATAL`, `E/flutter`, `RenderFlex overflowed`, or `ANR in` in `phone-logcat-tail.txt` or `phone-smart-after-dock-fix-logcat-tail.txt`. |
| System transition warnings | Note | `phone-logcat-tail.txt` includes one `BLASTSyncEngine` `Application ANR likely to follow` transition warning. No `ANR in` or app fatal signature accompanied it. |

## Findings

| ID | Severity | Finding | Evidence | Follow-up |
| --- | --- | --- | --- | --- |
| CL-QA-001-F1 | P1 | Phone Smart root placed the `Fish & Plant ID` card partly behind the bottom dock. The smoke helper tapped the center of the card's semantics bounds, which landed on the dock/Tank tab and returned to Tank instead of opening the optional-AI setup path. | Pre-fix: `phone-04-smart-root.png`, `phone-smoke-failure-smart-overlap.png`, `phone-smoke-failure-smart-overlap.xml`. After fix: `phone-04b-smart-root-after-dock-fix.png`, `phone-04b-smart-root-after-dock-fix.xml`. | Resolved locally. Phone recapture shows Fish & Plant ID clears the dock by `47px`, and the phone black-box smoke rerun passed. |
| CL-QA-001-F2 | P2 | The black-box smoke helper could report a tab as loaded when only the bottom-nav content description matched. This allowed `Assert-Visible "Smart"` to pass while the next tap could still be captured by the dock. | `phone-smoke-failure.txt`; `phone-smoke-failure-smart-overlap.xml` | Resolved locally by using selected-tab assertions and screen-specific outside-dock checks in the smoke helper. |

## Captured Inventory

| Surface | Evidence | Result | Notes |
| --- | --- | --- | --- |
| Learn root | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-01-learn-root.png` / `.xml` | Pass | Learning root loads from `danio://qa/learn`. |
| Practice root | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-02-practice-root.png` / `.xml` | Pass | Practice root loads from `danio://qa/practice`; smoke skipped review session from normal state because no enabled mode was visible. |
| Tank root | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-03-tank-root.png` / `.xml` | Pass | Demo/sample tank root loads with tank controls and bottom dock. |
| Smart root | Pre-fix: `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-04-smart-root.png` / `.xml`; after fix: `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-04b-smart-root-after-dock-fix.png` / `.xml` | Pass after recapture | Smart root loads from `danio://qa/smart`; Fish & Plant ID now clears the bottom dock on phone by `47px`. Pre-fix failure evidence is preserved. |
| More root | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-05-more-root.png` / `.xml` | Pass | More root loads from `danio://qa/more`. |
| Workshop root | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-06-workshop-root.png` / `.xml` | Pass | Workshop root loads from `danio://qa/workshop`. |
| Preferences root | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-07-preferences-root.png` / `.xml` | Pass | Preferences opens from `danio://qa/settings`. |
| Create Tank | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-08-create-tank.png` / `.xml` | Pass | Create Tank opens with seeded initial name from `danio://qa/create-tank?name=Q`. |
| Lesson | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-09-lesson.png` / `.xml` | Pass | Nitrogen Cycle lesson opens through QA deep link. |
| Lesson quiz hint | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-10-lesson-quiz-hint.png` / `.xml` | Pass | Debug quiz hint state opens. |
| Lesson quiz selected | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-11-lesson-quiz-selected.png` / `.xml` | Pass | Debug selected-correct quiz state opens. |
| Practice session | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-12-practice-session.png` / `.xml` | Pass | Debug practice session opens through QA deep link. |
| Achievements | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-13-achievements.png` / `.xml` | Pass | Achievements opens through QA deep link. |
| Species browser | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-14-species-browser.png` / `.xml` | Pass | Species browser opens through QA deep link. |
| Plant browser | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-15-plant-browser.png` / `.xml` | Pass | Plant browser opens through QA deep link. |
| Compare Tanks | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-16-compare-tanks.png` / `.xml` | Pass | Compare Tanks opens through QA deep link. |
| Glossary | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-17-glossary.png` / `.xml` | Pass | Glossary opens through QA deep link. |
| FAQ | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-18-faq.png` / `.xml` | Pass | FAQ opens through QA deep link. |
| Debug Menu | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-19-debug-menu.png` / `.xml` | Pass | Debug Menu opens through QA deep link; debug-only surface, not normal-user product evidence. |

## Gaps

- Full CL-QA-001 is still open. Remaining inventory rows in
  `docs/agent/SCREEN_INVENTORY.md` need either direct current evidence or a
  specific `Gap` result in a later full map.
- Calculator/tool detail screens beyond Workshop root were exercised by the
  passing black-box smoke rerun, but were not added as paired screenshot/XML
  inventory evidence in this map.
- Tank detail, add-log, livestock, equipment, reminders, backup restore flows,
  guide detail screens, optional-AI detail screens, shop/wishlist/inventory, and
  data-resilience walkthroughs remain pending for a full phone map.
- The physical phone `RFCY8022D5R` remained unauthorized and was not used.
