# Danio CL-QA-002 Tablet Whole-App Map

Date: 2026-07-04
Branch: `qa/production-tool-audit-2026-05-25`
Commit tested: `20f14eee`
Device: `danio_tablet_api36`, `emulator-5556`, 2560x1600
Build: `build/app/outputs/flutter-apk/app-debug.apk`
Evidence root: `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`

## Result

Status: In progress, not complete.

This pass captured a current 19-surface tablet screenshot/XML set through debug
QA deep links, plus pre-fix smoke-failure evidence. A follow-up hardened the
tablet route helper with selected-tab checks, outside-dock assertions, and
screen-relative swipes, then the tablet black-box smoke rerun passed. It does
not close CL-QA-002 because the full tablet inventory still needs
route-by-route layout review.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| Device ownership | Pass | `run_danio_live_preview.ps1 -AvdName danio_tablet_api36 -DeviceId emulator-5556 -CheckOnly -WaitSeconds 180` confirmed `danio_tablet_api36`, foreground package `com.tiarnanlarkin.danio`. |
| AndroidPrep | Pass | `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep` passed focused tests, dependency validation, custom lint, `flutter analyze`, debug APK build, and device visibility. Build emitted known Kotlin Gradle Plugin deprecation warnings only. |
| APK install/launch | Pass | `adb -s emulator-5556 install -r build\app\outputs\flutter-apk\app-debug.apk` and `adb -s emulator-5556 shell am start -n com.tiarnanlarkin.danio/.MainActivity` succeeded. |
| Tablet black-box smoke with QA deep links | Pass after fix | Final rerun passed with `.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5556 -InstallApkPath build\app\outputs\flutter-apk\app-debug.apk -IncludeQaDeepLinks -ArtifactDir build\qa-artifacts\android-blackbox-tablet-2026-07-04`. Earlier pre-fix failure evidence remains in `tablet-smoke-failure.txt`, `tablet-smoke-failure-workshop-route.png`, and `tablet-smoke-failure-workshop-route.xml`. |
| Direct QA deep-link capture | Pass for captured set | 19 `.png` files and 19 paired `.xml` files were saved; every XML contains a `<hierarchy>` root. `tablet-03-tank-root` was recaptured after the tablet root finished loading. |
| Narrow crash signature scan | Pass | No matches for `FATAL EXCEPTION`, `AndroidRuntime: FATAL`, `E/flutter`, `RenderFlex overflowed`, or `ANR in` in `tablet-logcat-tail.txt`. |
| System transition warnings | Note | `tablet-logcat-tail.txt` includes two `BLASTSyncEngine` `Application ANR likely to follow` transition warnings. No `ANR in` or app fatal signature accompanied them. |

## Findings

| ID | Severity | Finding | Evidence | Follow-up |
| --- | --- | --- | --- | --- |
| CL-QA-002-F1 | P1 | Tablet black-box smoke failed before Workshop route verification. Follow-up reruns also showed lower More hub items present in the UI hierarchy while partly behind the persistent dock. | `tablet-smoke-failure.txt`; `tablet-smoke-failure-workshop-route.png`; `tablet-smoke-failure-workshop-route.xml` | Resolved locally with selected-tab assertions, outside-dock route checks, dock-aware tap centers, and screen-relative More hub swipes; final tablet black-box smoke rerun passed. |
| CL-QA-002-F2 | P2 | Tablet Tank can show an app splash/loading state for several seconds after a force-start before the Tank hierarchy is available. The settled Tank root did load after waiting and was recaptured. | Earlier replaced capture; final evidence `tablet-03-tank-root.png` / `.xml` | Use condition-based waits for selected tab or screen-specific semantics instead of fixed sleeps in tablet capture scripts. |

## Captured Inventory

| Surface | Evidence | Result | Notes |
| --- | --- | --- | --- |
| Learn root | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-01-learn-root.png` / `.xml` | Pass | Learning root loads from `danio://qa/learn`. |
| Practice root | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-02-practice-root.png` / `.xml` | Pass | Practice root loads from `danio://qa/practice`; smoke skipped normal review mode because no enabled mode was visible. |
| Tank root | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-03-tank-root.png` / `.xml` | Pass after wait | Recaptured after the tablet root finished loading. |
| Smart root | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-04-smart-root.png` / `.xml` | Pass | Smart root loads on tablet without the phone-height card overlap seen in CL-QA-001. |
| More root | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-05-more-root.png` / `.xml` | Pass | More root loads from `danio://qa/more`. |
| Workshop root | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-06-workshop-root.png` / `.xml` | Pass | Workshop root loads by direct QA deep link, despite the smoke helper failure. |
| Preferences root | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-07-preferences-root.png` / `.xml` | Pass | Preferences opens from `danio://qa/settings`. |
| Create Tank | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-08-create-tank.png` / `.xml` | Pass | Create Tank opens with seeded initial name from `danio://qa/create-tank?name=Q`. |
| Lesson | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-09-lesson.png` / `.xml` | Pass | Nitrogen Cycle lesson opens through QA deep link. |
| Lesson quiz hint | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-10-lesson-quiz-hint.png` / `.xml` | Pass | Debug quiz hint state opens. |
| Lesson quiz selected | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-11-lesson-quiz-selected.png` / `.xml` | Pass | Debug selected-correct quiz state opens. |
| Practice session | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-12-practice-session.png` / `.xml` | Pass | Debug practice session opens through QA deep link. |
| Achievements | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-13-achievements.png` / `.xml` | Pass | Achievements opens through QA deep link. |
| Species browser | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-14-species-browser.png` / `.xml` | Pass | Species browser opens through QA deep link. |
| Plant browser | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-15-plant-browser.png` / `.xml` | Pass | Plant browser opens through QA deep link. |
| Compare Tanks | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-16-compare-tanks.png` / `.xml` | Pass | Compare Tanks opens through QA deep link. |
| Glossary | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-17-glossary.png` / `.xml` | Pass | Glossary opens through QA deep link. |
| FAQ | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-18-faq.png` / `.xml` | Pass | FAQ opens through QA deep link. |
| Debug Menu | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-19-debug-menu.png` / `.xml` | Pass | Debug Menu opens through QA deep link; debug-only surface, not normal-user product evidence. |

## Gaps

- Full CL-QA-002 is still open. Remaining inventory rows in
  `docs/agent/SCREEN_INVENTORY.md` need either direct current tablet evidence
  or a specific `Gap` result in a later full map.
- Calculator/tool detail screens beyond Workshop root were exercised by the
  passing black-box smoke rerun, but were not added as paired screenshot/XML
  inventory evidence in this map.
- Tablet-specific review remains pending for Tank detail, add-log, livestock,
  equipment, reminders, backup restore, guide detail screens, optional-AI
  detail screens, shop/wishlist/inventory, and data-resilience walkthroughs.
- The physical phone `RFCY8022D5R` remained unauthorized and was not used.
