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
is now accounted for below with `Pass` or `Gap` results. `Pass` means this slice
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

## Full Inventory Accounting

Summary: 96 `SCREEN_INVENTORY.md` rows checked; 29 current phone passes; 67
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
| Backup and Restore | Pass | Current black-box smoke asserted Backup/Restore, Export Data, Import Data, and ZIP export entry; no paired PNG/XML in this map. |
| Learning path detail | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Lesson reader | Pass | Paired lesson capture plus quiz states: `phone-09-lesson.png`, `phone-10-lesson-quiz-hint.png`, `phone-11-lesson-quiz-selected.png` with XML. |
| Unlock celebration | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Story Browser | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Story Play | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Spaced Repetition | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Review Session | Pass | Paired debug practice-session capture: `phone-12-practice-session.png` / `.xml`. |
| Difficulty Settings | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Aquarium Intelligence | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Symptom Triage | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Weekly Plan | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Fish ID | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Workshop | Pass | Paired root capture: `phone-06-workshop-root.png` / `.xml`. |
| Water Change | Pass | Current black-box smoke opened Water Change Calculator; no paired PNG/XML in this map. |
| Tank Volume | Pass | Current black-box smoke opened Tank Volume; no paired PNG/XML in this map. |
| Dosing | Pass | Current black-box smoke opened Dosing; no paired PNG/XML in this map. |
| CO2 | Pass | Current black-box smoke opened CO2 Calculator; no paired PNG/XML in this map. |
| Lighting | Pass | Current black-box smoke opened Lighting; no paired PNG/XML in this map. |
| Stocking | Pass | Current black-box smoke opened Stocking; no paired PNG/XML in this map. |
| Compatibility | Pass | Current black-box smoke opened Compatibility; no paired PNG/XML in this map. |
| Cycling Assistant | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Unit Converter | Pass | Current black-box smoke opened Unit Converter; no paired PNG/XML in this map. |
| Cost Tracker | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Fish Species Browser | Pass | Paired capture: `phone-14-species-browser.png` / `.xml`. |
| Plant Browser | Pass | Paired capture: `phone-15-plant-browser.png` / `.xml`. |
| Shop Street | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Wishlist | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Gem Shop | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Inventory | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Achievements | Pass | Paired capture: `phone-13-achievements.png` / `.xml`; also smoke-opened from More. |
| Emergency Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Acclimation Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Feeding Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Quarantine Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Disease Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Parameter Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Equipment Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Algae Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Breeding Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Vacation Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Quick Start Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Nitrogen Cycle Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Substrate Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Hardscape Guide | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Troubleshooting | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Search | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Notification Settings | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| Account / Offline Data | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |
| About | Pass | Current black-box smoke opened About and checked Privacy/Terms from it; no paired PNG/XML in this map. |
| FAQ | Pass | Paired capture: `phone-18-faq.png` / `.xml`. |
| Privacy Policy | Pass | Current black-box smoke opened Privacy Policy from About; no paired PNG/XML in this map. |
| Terms of Service | Pass | Current black-box smoke opened Terms of Service from About; no paired PNG/XML in this map. |
| Glossary | Pass | Paired capture: `phone-17-glossary.png` / `.xml`. |
| Debug Menu | Pass | Paired debug-only capture: `phone-19-debug-menu.png` / `.xml`. |
| Debug QA Seeds | Gap | No current CL-QA-001 phone evidence captured; keep as a target for route/deep-link or manual capture. |

## Gaps

- Full CL-QA-001 accounting is complete, but direct current phone evidence is
  still missing for 67 inventory rows listed as `Gap` above.
- Calculator/tool detail screens beyond Workshop root were exercised by the
  passing black-box smoke rerun, but were not added as paired screenshot/XML
  inventory evidence in this map.
- Tank detail, add-log, livestock, equipment, reminders, backup restore flows,
  guide detail screens, optional-AI detail screens, shop/wishlist/inventory, and
  data-resilience walkthroughs remain pending for a full phone map.
- The physical phone `RFCY8022D5R` remained unauthorized and was not used.
