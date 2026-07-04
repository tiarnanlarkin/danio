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
`Gap` results. A follow-up QA-006 route batch added 39 more tablet
screenshot/XML pairs for standalone normal-user routes that do not require
seeded tank IDs. QA-007 added 24 more fixed-build tablet screenshot/XML pairs
for seeded tank, learning, story, and cycling routes. `Pass` means this slice
has current paired screenshot/XML evidence or a current black-box route
assertion; `Gap` means the surface still needs direct tablet capture or a
dedicated route assertion before it can be treated as current tablet visual
evidence.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| Device ownership | Pass | `run_danio_live_preview.ps1 -AvdName danio_tablet_api36 -DeviceId emulator-5556 -CheckOnly -WaitSeconds 180` confirmed `danio_tablet_api36`, foreground package `com.tiarnanlarkin.danio`. |
| AndroidPrep | Pass | `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep` passed focused tests, dependency validation, custom lint, `flutter analyze`, debug APK build, and device visibility. Build emitted known Kotlin Gradle Plugin deprecation warnings only. |
| APK install/launch | Pass | `adb -s emulator-5556 install -r build\app\outputs\flutter-apk\app-debug.apk` and `adb -s emulator-5556 shell am start -n com.tiarnanlarkin.danio/.MainActivity` succeeded. |
| Tablet black-box smoke with QA deep links | Pass after fix | Final rerun passed with `.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5556 -InstallApkPath build\app\outputs\flutter-apk\app-debug.apk -IncludeQaDeepLinks -ArtifactDir build\qa-artifacts\android-blackbox-tablet-2026-07-04`. Earlier pre-fix failure evidence remains in `tablet-smoke-failure.txt`, `tablet-smoke-failure-workshop-route.png`, and `tablet-smoke-failure-workshop-route.xml`. |
| Direct QA deep-link capture | Pass for captured set | 19 `.png` files and 19 paired `.xml` files were saved; every XML contains a `<hierarchy>` root. `tablet-03-tank-root` was recaptured after the tablet root finished loading. |
| QA-006 standalone route capture | Pass | Added 39 paired tablet PNG/XML captures, `tablet-20` through `tablet-58`, using new `danio://qa/...` routes. Every new XML contains a `<hierarchy>` root. |
| QA-007 seeded route capture | Pass | Added 24 paired fixed-build tablet PNG/XML captures, `tablet-59` through `tablet-82`, using seeded `danio://qa/...` routes for tank, care, learning, story, and cycling surfaces. Every new XML contains a `<hierarchy>` root. |
| Narrow crash signature scan | Pass | No matches for `FATAL EXCEPTION`, `AndroidRuntime: FATAL`, `E/flutter`, `RenderFlex overflowed`, or `ANR in` in `tablet-logcat-tail.txt`. |
| QA-006 crash signature scan | Pass | No matches for `FATAL EXCEPTION`, `AndroidRuntime: FATAL`, `E/flutter`, `RenderFlex overflowed`, or `ANR in` in `tablet-route-batch-qa-006-logcat-tail.txt`. |
| QA-007 crash signature scan | Pass | No matches for `FATAL EXCEPTION`, `AndroidRuntime: FATAL`, `E/flutter`, `RenderFlex overflowed`, `ANR in`, app error-boundary text, or the duplicate-Hero signature in `tablet-route-batch-qa-007-logcat-tail.txt`; XML validation also rejected error-boundary text in the 24 new states. |
| System transition warnings | Note | `tablet-logcat-tail.txt` includes two `BLASTSyncEngine` `Application ANR likely to follow` transition warnings. No `ANR in` or app fatal signature accompanied them. |

## Findings

| ID | Severity | Finding | Evidence | Follow-up |
| --- | --- | --- | --- | --- |
| CL-QA-002-F1 | P1 | Tablet black-box smoke failed before Workshop route verification. Follow-up reruns also showed lower More hub items present in the UI hierarchy while partly behind the persistent dock. | `tablet-smoke-failure.txt`; `tablet-smoke-failure-workshop-route.png`; `tablet-smoke-failure-workshop-route.xml` | Resolved locally with selected-tab assertions, outside-dock route checks, dock-aware tap centers, and screen-relative More hub swipes; final tablet black-box smoke rerun passed. |
| CL-QA-002-F2 | P2 | Tablet Tank can show an app splash/loading state for several seconds after a force-start before the Tank hierarchy is available. The settled Tank root did load after waiting and was recaptured. | Earlier replaced capture; final evidence `tablet-03-tank-root.png` / `.xml` | Use condition-based waits for selected tab or screen-specific semantics instead of fixed sleeps in tablet capture scripts. |
| CL-QA-002-F3 | P1 | The initial QA-007 `danio://qa/livestock` tablet capture hit Flutter's duplicate `Hero` tag assertion because loading skeleton livestock rows reused the same placeholder ID. | Pre-fix diagnostics were captured under `build/qa-artifacts/qa-007-livestock-error.*`; fixed-build evidence is `tablet-72-livestock.png` / `.xml`. | Resolved locally by giving skeleton livestock placeholders unique IDs and adding a regression widget test for loading-skeleton route transitions. |

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

## QA-006 Route Batch Inventory

| Surface | Evidence | Result | Notes |
| --- | --- | --- | --- |
| Backup and Restore | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-20-backup-restore.png` / `.xml` | Pass | Opened from `danio://qa/backup`. |
| Search | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-21-search.png` / `.xml` | Pass | Opened from `danio://qa/search`. |
| Notification Settings | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-22-notification-settings.png` / `.xml` | Pass | Opened from `danio://qa/notification-settings`. |
| Account / Offline Data | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-23-account-offline-data.png` / `.xml` | Pass | Opened from `danio://qa/account`. |
| About | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-24-about.png` / `.xml` | Pass | Opened from `danio://qa/about`. |
| Privacy Policy | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-25-privacy-policy.png` / `.xml` | Pass | Opened from `danio://qa/privacy`. |
| Terms of Service | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-26-terms-of-service.png` / `.xml` | Pass | Opened from `danio://qa/terms`. |
| Shop Street | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-27-shop-street.png` / `.xml` | Pass | Opened from `danio://qa/shop`. |
| Wishlist | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-28-wishlist.png` / `.xml` | Pass | Opened from `danio://qa/wishlist`. |
| Gem Shop | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-29-gem-shop.png` / `.xml` | Pass | Opened from `danio://qa/gem-shop`. |
| Inventory | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-30-inventory.png` / `.xml` | Pass | Opened from `danio://qa/inventory`. |
| Aquarium Intelligence | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-31-aquarium-intelligence.png` / `.xml` | Pass | Opened from `danio://qa/aquarium-intelligence`. |
| Symptom Triage | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-32-symptom-triage.png` / `.xml` | Pass | Opened from `danio://qa/symptom-triage`. |
| Weekly Plan | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-33-weekly-plan.png` / `.xml` | Pass | Opened from `danio://qa/weekly-plan`. |
| Fish ID | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-34-fish-id.png` / `.xml` | Pass | Opened from `danio://qa/fish-id`. |
| Water Change | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-35-water-change.png` / `.xml` | Pass | Opened from `danio://qa/water-change`. |
| Tank Volume | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-36-tank-volume.png` / `.xml` | Pass | Opened from `danio://qa/tank-volume`. |
| Dosing | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-37-dosing.png` / `.xml` | Pass | Opened from `danio://qa/dosing`. |
| CO2 | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-38-co2.png` / `.xml` | Pass | Opened from `danio://qa/co2`. |
| Lighting | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-39-lighting.png` / `.xml` | Pass | Opened from `danio://qa/lighting`. |
| Stocking | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-40-stocking.png` / `.xml` | Pass | Opened from `danio://qa/stocking`. |
| Compatibility | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-41-compatibility.png` / `.xml` | Pass | Opened from `danio://qa/compatibility`. |
| Unit Converter | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-42-unit-converter.png` / `.xml` | Pass | Opened from `danio://qa/unit-converter`. |
| Cost Tracker | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-43-cost-tracker.png` / `.xml` | Pass | Opened from `danio://qa/cost-tracker`. |
| Emergency Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-44-emergency-guide.png` / `.xml` | Pass | Opened from `danio://qa/emergency-guide`. |
| Quick Start Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-45-quick-start-guide.png` / `.xml` | Pass | Opened from `danio://qa/quick-start-guide`. |
| Nitrogen Cycle Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-46-nitrogen-cycle-guide.png` / `.xml` | Pass | Opened from `danio://qa/nitrogen-cycle-guide`. |
| Parameter Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-47-parameter-guide.png` / `.xml` | Pass | Opened from `danio://qa/parameter-guide`. |
| Algae Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-48-algae-guide.png` / `.xml` | Pass | Opened from `danio://qa/algae-guide`. |
| Disease Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-49-disease-guide.png` / `.xml` | Pass | Opened from `danio://qa/disease-guide`. |
| Feeding Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-50-feeding-guide.png` / `.xml` | Pass | Opened from `danio://qa/feeding-guide`. |
| Acclimation Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-51-acclimation-guide.png` / `.xml` | Pass | Opened from `danio://qa/acclimation-guide`. |
| Quarantine Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-52-quarantine-guide.png` / `.xml` | Pass | Opened from `danio://qa/quarantine-guide`. |
| Breeding Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-53-breeding-guide.png` / `.xml` | Pass | Opened from `danio://qa/breeding-guide`. |
| Equipment Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-54-equipment-guide.png` / `.xml` | Pass | Opened from `danio://qa/equipment-guide`. |
| Substrate Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-55-substrate-guide.png` / `.xml` | Pass | Opened from `danio://qa/substrate-guide`. |
| Hardscape Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-56-hardscape-guide.png` / `.xml` | Pass | Opened from `danio://qa/hardscape-guide`. |
| Vacation Guide | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-57-vacation-guide.png` / `.xml` | Pass | Opened from `danio://qa/vacation-guide`. |
| Troubleshooting | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-58-troubleshooting.png` / `.xml` | Pass | Opened from `danio://qa/troubleshooting`. |

## QA-007 Route Batch Inventory

| Surface | Evidence | Result | Notes |
| --- | --- | --- | --- |
| Today Board | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-59-today-board.png` / `.xml` | Pass | Opened from `danio://qa/today-board` with seeded demo tank data. |
| Tank Detail | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-60-tank-detail.png` / `.xml` | Pass | Opened from `danio://qa/tank-detail` with seeded demo tank data. |
| Tank Settings | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-61-tank-settings.png` / `.xml` | Pass | Opened from `danio://qa/tank-settings` with seeded demo tank data. |
| Add Log | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-62-add-log.png` / `.xml` | Pass | Opened from `danio://qa/add-log` with seeded demo tank data. |
| Logs | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-63-logs.png` / `.xml` | Pass | Opened from `danio://qa/logs` with seeded demo tank data. |
| Log Detail | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-64-log-detail.png` / `.xml` | Pass | Opened from `danio://qa/log-detail` with seeded demo log data. |
| Tank Journal | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-65-tank-journal.png` / `.xml` | Pass | Opened from `danio://qa/tank-journal` with seeded demo tank data. |
| Photo Gallery | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-66-photo-gallery.png` / `.xml` | Pass | Opened from `danio://qa/photo-gallery` with seeded demo tank data. |
| Water Charts | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-67-water-charts.png` / `.xml` | Pass | Opened from `danio://qa/water-charts` with seeded demo tank data. |
| Analytics | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-68-analytics.png` / `.xml` | Pass | Opened from `danio://qa/analytics` with seeded demo tank data. |
| Tasks | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-69-tasks.png` / `.xml` | Pass | Opened from `danio://qa/tasks` with seeded demo task data. |
| Maintenance Checklist | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-70-maintenance-checklist.png` / `.xml` | Pass | Opened from `danio://qa/maintenance-checklist` with seeded demo task data. |
| Equipment | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-71-equipment.png` / `.xml` | Pass | Opened from `danio://qa/equipment` with seeded demo equipment data. |
| Livestock | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-72-livestock.png` / `.xml` | Pass | Opened from `danio://qa/livestock` after the fixed-build skeleton Hero regression fix. |
| Livestock Detail | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-73-livestock-detail.png` / `.xml` | Pass | Opened from `danio://qa/livestock-detail` with seeded demo livestock data. |
| Livestock Value | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-74-livestock-value.png` / `.xml` | Pass | Opened from `danio://qa/livestock-value` with seeded demo livestock data. |
| Reminders | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-75-reminders.png` / `.xml` | Pass | Opened from `danio://qa/reminders` with seeded demo tank data. |
| Learning path detail | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-76-learning-path-detail.png` / `.xml` | Pass | Opened from `danio://qa/learning-path-detail`. |
| Unlock celebration | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-77-unlock-celebration.png` / `.xml` | Pass | Opened from `danio://qa/unlock-celebration`. |
| Story Browser | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-78-story-browser.png` / `.xml` | Pass | Opened from `danio://qa/story-browser`. |
| Story Play | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-79-story-play.png` / `.xml` | Pass | Opened from `danio://qa/story-play`. |
| Spaced Repetition | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-80-spaced-repetition.png` / `.xml` | Pass | Opened from `danio://qa/spaced-repetition`. |
| Difficulty Settings | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-81-difficulty-settings.png` / `.xml` | Pass | Opened from `danio://qa/difficulty-settings`. |
| Cycling Assistant | `screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-82-cycling-assistant.png` / `.xml` | Pass | Opened from `danio://qa/cycling-assistant`. |

## Full Inventory Accounting

Summary: 96 `SCREEN_INVENTORY.md` rows checked; 80 current tablet passes; 16
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
| Today Board | Pass | Paired QA-007 capture: `tablet-59-today-board.png` / `.xml`. |
| Create Tank | Pass | Paired capture: `tablet-08-create-tank.png` / `.xml`. |
| Tank Detail | Pass | Paired QA-007 capture: `tablet-60-tank-detail.png` / `.xml`. |
| Tank Settings | Pass | Paired QA-007 capture: `tablet-61-tank-settings.png` / `.xml`. |
| Add Log | Pass | Paired QA-007 capture: `tablet-62-add-log.png` / `.xml`. |
| Logs | Pass | Paired QA-007 capture: `tablet-63-logs.png` / `.xml`. |
| Log Detail | Pass | Paired QA-007 capture: `tablet-64-log-detail.png` / `.xml`. |
| Tank Journal | Pass | Paired QA-007 capture: `tablet-65-tank-journal.png` / `.xml`. |
| Photo Gallery | Pass | Paired QA-007 capture: `tablet-66-photo-gallery.png` / `.xml`. |
| Water Charts | Pass | Paired QA-007 capture: `tablet-67-water-charts.png` / `.xml`. |
| Analytics | Pass | Paired QA-007 capture: `tablet-68-analytics.png` / `.xml`. |
| Compare Tanks | Pass | Paired capture: `tablet-16-compare-tanks.png` / `.xml`. |
| Tasks | Pass | Paired QA-007 capture: `tablet-69-tasks.png` / `.xml`. |
| Maintenance Checklist | Pass | Paired QA-007 capture: `tablet-70-maintenance-checklist.png` / `.xml`. |
| Equipment | Pass | Paired QA-007 capture: `tablet-71-equipment.png` / `.xml`. |
| Livestock | Pass | Paired QA-007 capture: `tablet-72-livestock.png` / `.xml`. |
| Livestock Detail | Pass | Paired QA-007 capture: `tablet-73-livestock-detail.png` / `.xml`. |
| Livestock Value | Pass | Paired QA-007 capture: `tablet-74-livestock-value.png` / `.xml`. |
| Reminders | Pass | Paired QA-007 capture: `tablet-75-reminders.png` / `.xml`. |
| Backup and Restore | Pass | Paired capture: `tablet-20-backup-restore.png` / `.xml`. |
| Learning path detail | Pass | Paired QA-007 capture: `tablet-76-learning-path-detail.png` / `.xml`. |
| Lesson reader | Pass | Paired lesson capture plus quiz states: `tablet-09-lesson.png`, `tablet-10-lesson-quiz-hint.png`, `tablet-11-lesson-quiz-selected.png` with XML. |
| Unlock celebration | Pass | Paired QA-007 capture: `tablet-77-unlock-celebration.png` / `.xml`. |
| Story Browser | Pass | Paired QA-007 capture: `tablet-78-story-browser.png` / `.xml`. |
| Story Play | Pass | Paired QA-007 capture: `tablet-79-story-play.png` / `.xml`. |
| Spaced Repetition | Pass | Paired QA-007 capture: `tablet-80-spaced-repetition.png` / `.xml`. |
| Review Session | Pass | Paired debug practice-session capture: `tablet-12-practice-session.png` / `.xml`. |
| Difficulty Settings | Pass | Paired QA-007 capture: `tablet-81-difficulty-settings.png` / `.xml`. |
| Aquarium Intelligence | Pass | Paired capture: `tablet-31-aquarium-intelligence.png` / `.xml`. |
| Symptom Triage | Pass | Paired capture: `tablet-32-symptom-triage.png` / `.xml`. |
| Weekly Plan | Pass | Paired capture: `tablet-33-weekly-plan.png` / `.xml`. |
| Fish ID | Pass | Paired capture: `tablet-34-fish-id.png` / `.xml`. |
| Workshop | Pass | Paired root capture: `tablet-06-workshop-root.png` / `.xml`. |
| Water Change | Pass | Paired capture: `tablet-35-water-change.png` / `.xml`. |
| Tank Volume | Pass | Paired capture: `tablet-36-tank-volume.png` / `.xml`. |
| Dosing | Pass | Paired capture: `tablet-37-dosing.png` / `.xml`. |
| CO2 | Pass | Paired capture: `tablet-38-co2.png` / `.xml`. |
| Lighting | Pass | Paired capture: `tablet-39-lighting.png` / `.xml`. |
| Stocking | Pass | Paired capture: `tablet-40-stocking.png` / `.xml`. |
| Compatibility | Pass | Paired capture: `tablet-41-compatibility.png` / `.xml`. |
| Cycling Assistant | Pass | Paired QA-007 capture: `tablet-82-cycling-assistant.png` / `.xml`. |
| Unit Converter | Pass | Paired capture: `tablet-42-unit-converter.png` / `.xml`. |
| Cost Tracker | Pass | Paired capture: `tablet-43-cost-tracker.png` / `.xml`. |
| Fish Species Browser | Pass | Paired capture: `tablet-14-species-browser.png` / `.xml`. |
| Plant Browser | Pass | Paired capture: `tablet-15-plant-browser.png` / `.xml`. |
| Shop Street | Pass | Paired capture: `tablet-27-shop-street.png` / `.xml`. |
| Wishlist | Pass | Paired capture: `tablet-28-wishlist.png` / `.xml`. |
| Gem Shop | Pass | Paired capture: `tablet-29-gem-shop.png` / `.xml`. |
| Inventory | Pass | Paired capture: `tablet-30-inventory.png` / `.xml`. |
| Achievements | Pass | Paired capture: `tablet-13-achievements.png` / `.xml`; also smoke-opened from More. |
| Emergency Guide | Pass | Paired capture: `tablet-44-emergency-guide.png` / `.xml`. |
| Acclimation Guide | Pass | Paired capture: `tablet-51-acclimation-guide.png` / `.xml`. |
| Feeding Guide | Pass | Paired capture: `tablet-50-feeding-guide.png` / `.xml`. |
| Quarantine Guide | Pass | Paired capture: `tablet-52-quarantine-guide.png` / `.xml`. |
| Disease Guide | Pass | Paired capture: `tablet-49-disease-guide.png` / `.xml`. |
| Parameter Guide | Pass | Paired capture: `tablet-47-parameter-guide.png` / `.xml`. |
| Equipment Guide | Pass | Paired capture: `tablet-54-equipment-guide.png` / `.xml`. |
| Algae Guide | Pass | Paired capture: `tablet-48-algae-guide.png` / `.xml`. |
| Breeding Guide | Pass | Paired capture: `tablet-53-breeding-guide.png` / `.xml`. |
| Vacation Guide | Pass | Paired capture: `tablet-57-vacation-guide.png` / `.xml`. |
| Quick Start Guide | Pass | Paired capture: `tablet-45-quick-start-guide.png` / `.xml`. |
| Nitrogen Cycle Guide | Pass | Paired capture: `tablet-46-nitrogen-cycle-guide.png` / `.xml`. |
| Substrate Guide | Pass | Paired capture: `tablet-55-substrate-guide.png` / `.xml`. |
| Hardscape Guide | Pass | Paired capture: `tablet-56-hardscape-guide.png` / `.xml`. |
| Troubleshooting | Pass | Paired capture: `tablet-58-troubleshooting.png` / `.xml`. |
| Search | Pass | Paired capture: `tablet-21-search.png` / `.xml`. |
| Notification Settings | Pass | Paired capture: `tablet-22-notification-settings.png` / `.xml`. |
| Account / Offline Data | Pass | Paired capture: `tablet-23-account-offline-data.png` / `.xml`. |
| About | Pass | Paired capture: `tablet-24-about.png` / `.xml`. |
| FAQ | Pass | Paired capture: `tablet-18-faq.png` / `.xml`. |
| Privacy Policy | Pass | Paired capture: `tablet-25-privacy-policy.png` / `.xml`. |
| Terms of Service | Pass | Paired capture: `tablet-26-terms-of-service.png` / `.xml`. |
| Glossary | Pass | Paired capture: `tablet-17-glossary.png` / `.xml`. |
| Debug Menu | Pass | Paired debug-only capture: `tablet-19-debug-menu.png` / `.xml`. |
| Debug QA Seeds | Gap | No current CL-QA-002 tablet evidence captured; keep as a target for route/deep-link or manual capture. |

## Gaps

- Full CL-QA-002 accounting is complete, but direct current tablet evidence is
  still missing for 16 inventory rows listed as `Gap` above.
- The QA-006 route batch added paired tablet evidence for standalone Smart
  detail, Workshop tool, guide, legal/settings, shop/reward, and search
  surfaces.
- The QA-007 route batch added fixed-build paired tablet evidence for seeded
  tank/detail, add-log, livestock, equipment, reminders, learning/story, SRS,
  and Cycling Assistant surfaces.
- Remaining tablet gaps are onboarding/first-run states plus Debug QA Seeds.
- The physical phone `RFCY8022D5R` remained unauthorized and was not used.
