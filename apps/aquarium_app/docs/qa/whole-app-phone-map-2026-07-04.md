# Danio CL-QA-001 Phone Whole-App Map

Date: 2026-07-04
Branch: `qa/production-tool-audit-2026-05-25`
Initial map source: `20f14eee`
Latest Smart recapture source: `273a9644`
Device: `danio_api36`, `emulator-5554`, 1080x2400
Build: `build/app/outputs/flutter-apk/app-debug.apk`
Evidence root: `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`

## Result

Status: Coverage accounting complete; current visual capture gaps remain.

This pass captured a current 19-surface phone screenshot/XML set through debug
QA deep links, plus pre-fix smoke-failure evidence. A follow-up fixed the Smart
bottom-dock overlap and black-box helper false positives, then the phone
black-box smoke rerun passed. A later phone recapture confirmed Fish & Plant ID
now clears the dock on `danio_api36`. The full `SCREEN_INVENTORY.md` surface set
is now accounted for below with `Pass` or `Gap` results. A follow-up QA-006
route batch added 39 more phone screenshot/XML pairs for standalone normal-user
routes that do not require seeded tank IDs. `Pass` means this slice
has current paired screenshot/XML evidence or a current black-box route
assertion; `Gap` means the surface still needs direct phone capture or a
dedicated route assertion before it can be treated as current visual evidence.

## Checks

| Check | Result | Notes |
| --- | --- | --- |
| Device ownership | Pass | `run_danio_live_preview.ps1 -DeviceId emulator-5554 -CheckOnly -WaitSeconds 180` confirmed `danio_api36`, foreground package `com.tiarnanlarkin.danio`. |
| AndroidPrep | Pass | `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep` passed focused tests, dependency validation, custom lint, `flutter analyze`, debug APK build, and device visibility. Build emitted known Kotlin Gradle Plugin deprecation warnings only. |
| APK install/launch | Pass | `adb -s emulator-5554 install -r build\app\outputs\flutter-apk\app-debug.apk` and `adb -s emulator-5554 shell am start -n com.tiarnanlarkin.danio/.MainActivity` succeeded. |
| Phone black-box smoke with QA deep links | Pass after fix | Final rerun passed with `.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5554 -InstallApkPath build\app\outputs\flutter-apk\app-debug.apk -IncludeQaDeepLinks -ArtifactDir build\qa-artifacts\android-blackbox-phone-2026-07-04`. Earlier pre-fix failure evidence remains in `phone-smoke-failure.txt`, `phone-smoke-failure-smart-overlap.png`, and `phone-smoke-failure-smart-overlap.xml`. |
| Phone Smart root recapture | Pass | `phone-04b-smart-root-after-dock-fix.png` / `.xml` captured from `danio://qa/smart` after installing the current debug APK. XML bounds show Fish & Plant ID bottom `2080`, bottom dock top `2127`, for `47px` clearance. |
| Direct QA deep-link capture | Pass for captured set | 19 original `.png` files and 19 paired `.xml` files were saved, plus the after-fix Smart recapture; every XML contains a `<hierarchy>` root. |
| QA-006 standalone route capture | Pass | Added 39 paired phone PNG/XML captures, `phone-20` through `phone-58`, using new `danio://qa/...` routes. Every new XML contains a `<hierarchy>` root. |
| Narrow crash signature scan | Pass | No matches for `FATAL EXCEPTION`, `AndroidRuntime: FATAL`, `E/flutter`, `RenderFlex overflowed`, or `ANR in` in `phone-logcat-tail.txt` or `phone-smart-after-dock-fix-logcat-tail.txt`. |
| QA-006 crash signature scan | Pass | No matches for `FATAL EXCEPTION`, `AndroidRuntime: FATAL`, `E/flutter`, `RenderFlex overflowed`, or `ANR in` in `phone-route-batch-qa-006-logcat-tail.txt`. |
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

## QA-006 Route Batch Inventory

| Surface | Evidence | Result | Notes |
| --- | --- | --- | --- |
| Backup and Restore | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-20-backup-restore.png` / `.xml` | Pass | Opened from `danio://qa/backup`. |
| Search | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-21-search.png` / `.xml` | Pass | Opened from `danio://qa/search`. |
| Notification Settings | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-22-notification-settings.png` / `.xml` | Pass | Opened from `danio://qa/notification-settings`. |
| Account / Offline Data | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-23-account-offline-data.png` / `.xml` | Pass | Opened from `danio://qa/account`. |
| About | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-24-about.png` / `.xml` | Pass | Opened from `danio://qa/about`. |
| Privacy Policy | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-25-privacy-policy.png` / `.xml` | Pass | Opened from `danio://qa/privacy`. |
| Terms of Service | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-26-terms-of-service.png` / `.xml` | Pass | Opened from `danio://qa/terms`. |
| Shop Street | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-27-shop-street.png` / `.xml` | Pass | Opened from `danio://qa/shop`. |
| Wishlist | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-28-wishlist.png` / `.xml` | Pass | Opened from `danio://qa/wishlist`. |
| Gem Shop | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-29-gem-shop.png` / `.xml` | Pass | Opened from `danio://qa/gem-shop`. |
| Inventory | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-30-inventory.png` / `.xml` | Pass | Opened from `danio://qa/inventory`. |
| Aquarium Intelligence | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-31-aquarium-intelligence.png` / `.xml` | Pass | Opened from `danio://qa/aquarium-intelligence`. |
| Symptom Triage | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-32-symptom-triage.png` / `.xml` | Pass | Opened from `danio://qa/symptom-triage`. |
| Weekly Plan | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-33-weekly-plan.png` / `.xml` | Pass | Opened from `danio://qa/weekly-plan`. |
| Fish ID | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-34-fish-id.png` / `.xml` | Pass | Opened from `danio://qa/fish-id`. |
| Water Change | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-35-water-change.png` / `.xml` | Pass | Opened from `danio://qa/water-change`. |
| Tank Volume | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-36-tank-volume.png` / `.xml` | Pass | Opened from `danio://qa/tank-volume`. |
| Dosing | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-37-dosing.png` / `.xml` | Pass | Opened from `danio://qa/dosing`. |
| CO2 | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-38-co2.png` / `.xml` | Pass | Opened from `danio://qa/co2`. |
| Lighting | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-39-lighting.png` / `.xml` | Pass | Opened from `danio://qa/lighting`. |
| Stocking | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-40-stocking.png` / `.xml` | Pass | Opened from `danio://qa/stocking`. |
| Compatibility | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-41-compatibility.png` / `.xml` | Pass | Opened from `danio://qa/compatibility`. |
| Unit Converter | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-42-unit-converter.png` / `.xml` | Pass | Opened from `danio://qa/unit-converter`. |
| Cost Tracker | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-43-cost-tracker.png` / `.xml` | Pass | Opened from `danio://qa/cost-tracker`. |
| Emergency Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-44-emergency-guide.png` / `.xml` | Pass | Opened from `danio://qa/emergency-guide`. |
| Quick Start Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-45-quick-start-guide.png` / `.xml` | Pass | Opened from `danio://qa/quick-start-guide`. |
| Nitrogen Cycle Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-46-nitrogen-cycle-guide.png` / `.xml` | Pass | Opened from `danio://qa/nitrogen-cycle-guide`. |
| Parameter Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-47-parameter-guide.png` / `.xml` | Pass | Opened from `danio://qa/parameter-guide`. |
| Algae Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-48-algae-guide.png` / `.xml` | Pass | Opened from `danio://qa/algae-guide`. |
| Disease Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-49-disease-guide.png` / `.xml` | Pass | Opened from `danio://qa/disease-guide`. |
| Feeding Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-50-feeding-guide.png` / `.xml` | Pass | Opened from `danio://qa/feeding-guide`. |
| Acclimation Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-51-acclimation-guide.png` / `.xml` | Pass | Opened from `danio://qa/acclimation-guide`. |
| Quarantine Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-52-quarantine-guide.png` / `.xml` | Pass | Opened from `danio://qa/quarantine-guide`. |
| Breeding Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-53-breeding-guide.png` / `.xml` | Pass | Opened from `danio://qa/breeding-guide`. |
| Equipment Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-54-equipment-guide.png` / `.xml` | Pass | Opened from `danio://qa/equipment-guide`. |
| Substrate Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-55-substrate-guide.png` / `.xml` | Pass | Opened from `danio://qa/substrate-guide`. |
| Hardscape Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-56-hardscape-guide.png` / `.xml` | Pass | Opened from `danio://qa/hardscape-guide`. |
| Vacation Guide | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-57-vacation-guide.png` / `.xml` | Pass | Opened from `danio://qa/vacation-guide`. |
| Troubleshooting | `screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-58-troubleshooting.png` / `.xml` | Pass | Opened from `danio://qa/troubleshooting`. |

## Full Inventory Accounting

Summary: 96 `SCREEN_INVENTORY.md` rows checked; 56 current phone passes; 40
phone gaps remain for future capture.

| Surface | Result | Current phone evidence or gap note |
| --- | --- | --- |
| App shell / tab navigator | Pass | Represented by the five current tab root captures and selected-tab smoke checks. |
| Learn tab | Pass | Paired root capture: `phone-01-learn-root.png` / `.xml`. |
| Practice tab | Pass | Paired root capture: `phone-02-practice-root.png` / `.xml`. |
| Tank tab | Pass | Paired root capture: `phone-03-tank-root.png` / `.xml`. |
| Smart tab | Pass | After-fix paired capture: `phone-04b-smart-root-after-dock-fix.png` / `.xml`. |
| More / settings hub | Pass | Paired root capture: `phone-05-more-root.png` / `.xml`. |
| Onboarding coordinator | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Consent | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Age blocked | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Welcome | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Region and units | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Experience level | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Tank status | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Goals | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Micro lesson | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| XP celebration | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Fish select | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Aha moment | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Feature summary | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Push permission | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Warm entry | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Today Board | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Create Tank | Pass | Paired capture: `phone-08-create-tank.png` / `.xml`. |
| Tank Detail | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Tank Settings | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Add Log | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Logs | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Log Detail | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Tank Journal | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Photo Gallery | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Water Charts | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Analytics | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Compare Tanks | Pass | Paired capture: `phone-16-compare-tanks.png` / `.xml`. |
| Tasks | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Maintenance Checklist | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Equipment | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Livestock | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Livestock Detail | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Livestock Value | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Reminders | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Backup and Restore | Pass | Paired capture: `phone-20-backup-restore.png` / `.xml`. |
| Learning path detail | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Lesson reader | Pass | Paired lesson capture plus quiz states: `phone-09-lesson.png`, `phone-10-lesson-quiz-hint.png`, `phone-11-lesson-quiz-selected.png` with XML. |
| Unlock celebration | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Story Browser | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Story Play | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Spaced Repetition | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Review Session | Pass | Paired debug practice-session capture: `phone-12-practice-session.png` / `.xml`. |
| Difficulty Settings | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Aquarium Intelligence | Pass | Paired capture: `phone-31-aquarium-intelligence.png` / `.xml`. |
| Symptom Triage | Pass | Paired capture: `phone-32-symptom-triage.png` / `.xml`. |
| Weekly Plan | Pass | Paired capture: `phone-33-weekly-plan.png` / `.xml`. |
| Fish ID | Pass | Paired capture: `phone-34-fish-id.png` / `.xml`. |
| Workshop | Pass | Paired root capture: `phone-06-workshop-root.png` / `.xml`. |
| Water Change | Pass | Paired capture: `phone-35-water-change.png` / `.xml`. |
| Tank Volume | Pass | Paired capture: `phone-36-tank-volume.png` / `.xml`. |
| Dosing | Pass | Paired capture: `phone-37-dosing.png` / `.xml`. |
| CO2 | Pass | Paired capture: `phone-38-co2.png` / `.xml`. |
| Lighting | Pass | Paired capture: `phone-39-lighting.png` / `.xml`. |
| Stocking | Pass | Paired capture: `phone-40-stocking.png` / `.xml`. |
| Compatibility | Pass | Paired capture: `phone-41-compatibility.png` / `.xml`. |
| Cycling Assistant | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Unit Converter | Pass | Paired capture: `phone-42-unit-converter.png` / `.xml`. |
| Cost Tracker | Pass | Paired capture: `phone-43-cost-tracker.png` / `.xml`. |
| Fish Species Browser | Pass | Paired capture: `phone-14-species-browser.png` / `.xml`. |
| Plant Browser | Pass | Paired capture: `phone-15-plant-browser.png` / `.xml`. |
| Shop Street | Pass | Paired capture: `phone-27-shop-street.png` / `.xml`. |
| Wishlist | Pass | Paired capture: `phone-28-wishlist.png` / `.xml`. |
| Gem Shop | Pass | Paired capture: `phone-29-gem-shop.png` / `.xml`. |
| Inventory | Pass | Paired capture: `phone-30-inventory.png` / `.xml`. |
| Achievements | Pass | Paired capture: `phone-13-achievements.png` / `.xml`; also smoke-opened from More. |
| Emergency Guide | Pass | Paired capture: `phone-44-emergency-guide.png` / `.xml`. |
| Acclimation Guide | Pass | Paired capture: `phone-51-acclimation-guide.png` / `.xml`. |
| Feeding Guide | Pass | Paired capture: `phone-50-feeding-guide.png` / `.xml`. |
| Quarantine Guide | Pass | Paired capture: `phone-52-quarantine-guide.png` / `.xml`. |
| Disease Guide | Pass | Paired capture: `phone-49-disease-guide.png` / `.xml`. |
| Parameter Guide | Pass | Paired capture: `phone-47-parameter-guide.png` / `.xml`. |
| Equipment Guide | Pass | Paired capture: `phone-54-equipment-guide.png` / `.xml`. |
| Algae Guide | Pass | Paired capture: `phone-48-algae-guide.png` / `.xml`. |
| Breeding Guide | Pass | Paired capture: `phone-53-breeding-guide.png` / `.xml`. |
| Vacation Guide | Pass | Paired capture: `phone-57-vacation-guide.png` / `.xml`. |
| Quick Start Guide | Pass | Paired capture: `phone-45-quick-start-guide.png` / `.xml`. |
| Nitrogen Cycle Guide | Pass | Paired capture: `phone-46-nitrogen-cycle-guide.png` / `.xml`. |
| Substrate Guide | Pass | Paired capture: `phone-55-substrate-guide.png` / `.xml`. |
| Hardscape Guide | Pass | Paired capture: `phone-56-hardscape-guide.png` / `.xml`. |
| Troubleshooting | Pass | Paired capture: `phone-58-troubleshooting.png` / `.xml`. |
| Search | Pass | Paired capture: `phone-21-search.png` / `.xml`. |
| Notification Settings | Pass | Paired capture: `phone-22-notification-settings.png` / `.xml`. |
| Account / Offline Data | Pass | Paired capture: `phone-23-account-offline-data.png` / `.xml`. |
| About | Pass | Paired capture: `phone-24-about.png` / `.xml`. |
| FAQ | Pass | Paired capture: `phone-18-faq.png` / `.xml`. |
| Privacy Policy | Pass | Paired capture: `phone-25-privacy-policy.png` / `.xml`. |
| Terms of Service | Pass | Paired capture: `phone-26-terms-of-service.png` / `.xml`. |
| Glossary | Pass | Paired capture: `phone-17-glossary.png` / `.xml`. |
| Debug Menu | Pass | Paired debug-only capture: `phone-19-debug-menu.png` / `.xml`. |
| Debug QA Seeds | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |

## Gaps

- Full CL-QA-001 accounting is complete, but direct current phone evidence is
  still missing for 40 inventory rows listed as `Gap` above.
- The QA-006 route batch added paired phone evidence for standalone Smart
  detail, Workshop tool, guide, legal/settings, shop/reward, and search
  surfaces.
- Tank detail, add-log, livestock, equipment, reminders, onboarding,
  story/learning detail, tank-specific data, and data-resilience walkthroughs
  remain pending for a full phone map.
- The physical phone `RFCY8022D5R` remained unauthorized and was not used.
