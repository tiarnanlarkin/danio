# Danio CL-QA-002 Tablet Whole-App Map

Date: 2026-07-04
Branch: `qa/production-tool-audit-2026-05-25`
Commit tested: `20f14eee`
Device: `danio_tablet_api36`, `emulator-5556`, 2560x1600
Build: `build/app/outputs/flutter-apk/app-debug.apk`
Evidence root: `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`

## Result

Status: Coverage accounting complete; current visual capture gaps remain.

This pass captured a current 19-surface tablet screenshot/XML set through debug
QA deep links, plus pre-fix smoke-failure evidence. A follow-up hardened the
tablet route helper with selected-tab checks, outside-dock assertions, and
screen-relative swipes, then the tablet black-box smoke rerun passed. The full
`SCREEN_INVENTORY.md` surface set is now accounted for below with `Pass` or
`Gap` results. `Pass` means this slice has current paired screenshot/XML
evidence or a current black-box route assertion; `Gap` means the surface still
needs direct tablet capture or a dedicated route assertion before it can be
treated as current tablet visual evidence.

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

## Full Inventory Accounting

Summary: 96 `SCREEN_INVENTORY.md` rows checked; 29 current tablet passes; 67
tablet gaps remain for future capture.

| Surface | Result | Current tablet evidence or gap note |
| --- | --- | --- |
| App shell / tab navigator | Pass | Represented by the five current tablet tab root captures and selected-tab smoke checks. |
| Learn tab | Pass | Paired root capture: `tablet-01-learn-root.png` / `.xml`. |
| Practice tab | Pass | Paired root capture: `tablet-02-practice-root.png` / `.xml`. |
| Tank tab | Pass | Paired settled root capture: `tablet-03-tank-root.png` / `.xml`. |
| Smart tab | Pass | Paired root capture: `tablet-04-smart-root.png` / `.xml`. |
| More / settings hub | Pass | Paired root capture: `tablet-05-more-root.png` / `.xml`. |
| Onboarding coordinator | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Consent | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Age blocked | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Welcome | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Region and units | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Experience level | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Tank status | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Goals | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Micro lesson | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| XP celebration | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Fish select | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Aha moment | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Feature summary | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Push permission | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Warm entry | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Today Board | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Create Tank | Pass | Paired capture: `tablet-08-create-tank.png` / `.xml`. |
| Tank Detail | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Tank Settings | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Add Log | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Logs | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Log Detail | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Tank Journal | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Photo Gallery | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Water Charts | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Analytics | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Compare Tanks | Pass | Paired capture: `tablet-16-compare-tanks.png` / `.xml`. |
| Tasks | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Maintenance Checklist | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Equipment | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Livestock | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Livestock Detail | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Livestock Value | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Reminders | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Backup and Restore | Pass | Current tablet black-box smoke asserted Backup/Restore, Export Data, Import Data, and ZIP export entry; no paired PNG/XML in this map. |
| Learning path detail | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Lesson reader | Pass | Paired lesson capture plus quiz states: `tablet-09-lesson.png`, `tablet-10-lesson-quiz-hint.png`, `tablet-11-lesson-quiz-selected.png` with XML. |
| Unlock celebration | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Story Browser | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Story Play | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Spaced Repetition | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Review Session | Pass | Paired debug practice-session capture: `tablet-12-practice-session.png` / `.xml`. |
| Difficulty Settings | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Aquarium Intelligence | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Symptom Triage | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Weekly Plan | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Fish ID | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Workshop | Pass | Paired root capture: `tablet-06-workshop-root.png` / `.xml`. |
| Water Change | Pass | Current tablet black-box smoke opened Water Change Calculator; no paired PNG/XML in this map. |
| Tank Volume | Pass | Current tablet black-box smoke opened Tank Volume; no paired PNG/XML in this map. |
| Dosing | Pass | Current tablet black-box smoke opened Dosing; no paired PNG/XML in this map. |
| CO2 | Pass | Current tablet black-box smoke opened CO2 Calculator; no paired PNG/XML in this map. |
| Lighting | Pass | Current tablet black-box smoke opened Lighting; no paired PNG/XML in this map. |
| Stocking | Pass | Current tablet black-box smoke opened Stocking; no paired PNG/XML in this map. |
| Compatibility | Pass | Current tablet black-box smoke opened Compatibility; no paired PNG/XML in this map. |
| Cycling Assistant | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Unit Converter | Pass | Current tablet black-box smoke opened Unit Converter; no paired PNG/XML in this map. |
| Cost Tracker | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Fish Species Browser | Pass | Paired capture: `tablet-14-species-browser.png` / `.xml`. |
| Plant Browser | Pass | Paired capture: `tablet-15-plant-browser.png` / `.xml`. |
| Shop Street | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Wishlist | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Gem Shop | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Inventory | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Achievements | Pass | Paired capture: `tablet-13-achievements.png` / `.xml`; also smoke-opened from More. |
| Emergency Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Acclimation Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Feeding Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Quarantine Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Disease Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Parameter Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Equipment Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Algae Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Breeding Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Vacation Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Quick Start Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Nitrogen Cycle Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Substrate Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Hardscape Guide | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Troubleshooting | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Search | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Notification Settings | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| Account / Offline Data | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |
| About | Pass | Current tablet black-box smoke opened About and checked Privacy/Terms from it; no paired PNG/XML in this map. |
| FAQ | Pass | Paired capture: `tablet-18-faq.png` / `.xml`. |
| Privacy Policy | Pass | Current tablet black-box smoke opened Privacy Policy from About; no paired PNG/XML in this map. |
| Terms of Service | Pass | Current tablet black-box smoke opened Terms of Service from About; no paired PNG/XML in this map. |
| Glossary | Pass | Paired capture: `tablet-17-glossary.png` / `.xml`. |
| Debug Menu | Pass | Paired debug-only capture: `tablet-19-debug-menu.png` / `.xml`. |
| Debug QA Seeds | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |

## Gaps

- Full CL-QA-002 accounting is complete, but direct current tablet evidence is
  still missing for 67 inventory rows listed as `Gap` above.
- Calculator/tool detail screens beyond Workshop root were exercised by the
  passing black-box smoke rerun, but were not added as paired screenshot/XML
  inventory evidence in this map.
- Tablet-specific review remains pending for Tank detail, add-log, livestock,
  equipment, reminders, backup restore, guide detail screens, optional-AI
  detail screens, shop/wishlist/inventory, and data-resilience walkthroughs.
- The physical phone `RFCY8022D5R` remained unauthorized and was not used.
