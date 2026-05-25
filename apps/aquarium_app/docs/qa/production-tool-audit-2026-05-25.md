# Production Tool Audit - 2026-05-25

Branch: `qa/production-tool-audit-2026-05-25`  
Base commit: `0d107483`  
Primary QA target: `emulator-5560`, `Danio_E2E_API_36_1`, Android 16, 1080x2400  
Phase 2 QA target: `emulator-5564`, Android 16, 1080x2400
Phase 3 QA target: `emulator-5554`, `Danio_Codex_API_36_1`, Android 16, 1080x2400
Mode: emulator-only production polish audit

## Phase 0 Baseline

| Gate | Result | Evidence |
| --- | --- | --- |
| `flutter analyze --no-pub` | Pass | No issues found, ran before branch edits |
| `flutter test` | Pass | 1275 tests passed |
| `flutter test integration_test/smoke_test_v2.dart -d emulator-5556` | Pass | 5 integration tests passed after Flutter recovered from an install-storage retry |
| `flutter test integration_test/smoke_test_v2.dart -d emulator-5560` | Pass | 5 integration tests passed on the continuing audit emulator |
| `flutter build apk --debug --target lib/main.dart` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk` |
| `scripts/run_android_blackbox_smoke.ps1 -IncludeQaDeepLinks` | Pass | [screenshot](screenshots/production-tool-audit-2026-05-25/phase0-blackbox-pass.png), [XML](screenshots/production-tool-audit-2026-05-25/phase0-blackbox-pass.xml), [logcat](screenshots/production-tool-audit-2026-05-25/phase0-blackbox-pass-logcat.txt) |
| `flutter test test/scripts/android_blackbox_smoke_script_test.dart` | Pass | 14 source-contract tests passed after harness patch |
| `flutter analyze --no-pub` after harness patch | Pass | No issues found |

Notes:
- Initial black-box attempts on `emulator-5556` exposed a harness issue around Android emulator install storage pressure.
- The harness now trims package caches and retries an in-place install before falling back to uninstall/reinstall.
- Original failed install artifacts are preserved under [phase0-install-failures](screenshots/production-tool-audit-2026-05-25/phase0-install-failures/).
- The continuing audit target is `emulator-5560`; the other running emulators were left untouched because they had active foreground apps.
- Integration smoke on `emulator-5560` logged a caught duplicate Firebase initialization during repeated test launches. The normal black-box run did not include crash signatures, Flutter widget exceptions, or `AndroidRuntime: FATAL`.
- The normal debug APK was rebuilt with `flutter build apk --debug --target lib/main.dart` after integration smoke before the final black-box pass.

## Tool Matrix

Status legend: `Pending`, `Pass`, `Fixed`, `Blocked`, `Documented`.

| Tool / Surface | Canonical home | User path | Valid scenario | Invalid / empty scenario | Integration expectation | Source oracle | Evidence | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Water Change Calculator | Workshop | More -> Workshop -> Water Change | Calculate change volume from tank size, current nitrate, target nitrate, and tap nitrate | Reject impossible target/tap/current combinations | Result can inform Tank water-change logging without auto-writing data | Golden Checks | Workshop focused tests; black-box route pass | Pass |
| Stocking Calculator | Workshop | More -> Workshop -> Stocking | Estimate stocking load for tank size and selected species | Empty tank/species input shows useful guidance | Estimate remains separate from Tank livestock until user adds stock | Golden Checks | Workshop focused tests; black-box route pass | Pass |
| CO2 Calculator | Workshop | More -> Workshop -> CO2 Calculator | Estimate CO2 from KH and pH | Reject invalid pH/KH values | Advice copy stays estimate-based and non-prescriptive | Golden Checks | Workshop focused tests; black-box route pass | Pass |
| Dosing Calculator | Workshop | More -> Workshop -> Dosing | Calculate product dose from product rate and tank volume | Reject missing tank volume/product input | No medication claim beyond current supported products | Golden Checks | [empty](screenshots/production-tool-audit-2026-05-25/phase2-dosing-initial.png), [valid](screenshots/production-tool-audit-2026-05-25/phase2-dosing-valid-default.png), [presets](screenshots/production-tool-audit-2026-05-25/phase2-dosing-presets.png), focused tests | Fixed |
| Unit Converter | Workshop | More -> Workshop -> Unit Converter | Convert volume, temperature, length, and hardness values | Empty/invalid numeric input does not crash | Tool is stateless and returns to Workshop cleanly | Golden Checks | Workshop focused tests; black-box route pass | Pass |
| Tank Volume Calculator | Workshop | More -> Workshop -> Tank Volume | Calculate common tank shapes with unit conversion | Reject zero/negative dimensions | Can be used before tank creation without requiring a saved tank | Golden Checks | Workshop focused tests; black-box route pass | Pass |
| Lighting Planner | Workshop | More -> Workshop -> Lighting | Generate light schedule and CO2 timing advice | Handles midnight-spanning schedules and empty input | Advice remains planner-only unless user applies it elsewhere | Golden Checks | [default](screenshots/production-tool-audit-2026-05-25/phase2-lighting-default.png), midnight widget tests, black-box route pass | Fixed |
| Workshop Compatibility Checker | Workshop | More -> Workshop -> Compatibility | Local compatibility estimate for selected species | Empty species/tank values show setup guidance | Label stays distinct from Smart AI compatibility advice | Golden Checks | Workshop focused tests; black-box route pass | Pass |
| Cycling Assistant | Workshop | More -> Workshop -> Cycling Assistant | Show cycling stage guidance for a selected tank | No tank state explains requirement | Tank detail cycling status may deep-link here with context | Golden Checks | Cycling focused tests; Workshop no-tank widget state | Fixed |
| Cost Tracker | Workshop | More -> Workshop -> Cost Tracker | Add, persist, summarize, delete, and undo an expense | Empty/invalid amount is rejected | Tank-specific value tools remain separate from global cost tracking | Golden Checks | Workshop focused tests; add/invalid/persist widget coverage | Pass |
| Tank room | Tank | Bottom tab -> Tank | Room scene loads with current tank state | No tank state prompts creation without crash | Tank room reflects saved logs and selected tank | App contract | [tank](screenshots/production-tool-audit-2026-05-25/phase3-tank-entry-fixed-build.png), [cold open](screenshots/production-tool-audit-2026-05-25/phase3-tank-cold-open-for-detail.png) | Pass |
| Tank bottom panel | Tank | Tank -> bottom panel tabs | Today/care/status tabs open and scroll safely | No data states are calm and actionable | State updates after care actions | App contract | [before](screenshots/production-tool-audit-2026-05-25/phase3-tank-bottom-panel-expanded.png), [after](screenshots/production-tool-audit-2026-05-25/phase3-tank-bottom-panel-expanded-fixed.png), focused widget tests | Fixed |
| Today board | Tank | Tank -> Today | Daily goal and due care items reflect current state | No tasks/reviews avoids nagging | Care actions update board without stale state | App contract | Pending | Pending |
| Tank switcher / add tank | Tank | Tank -> switcher / add tank | Create and switch between multiple tanks | Cancel/discard paths preserve data | Selected tank drives Tank Detail and logs | App contract | Pending | Pending |
| Quick water test | Tank | Tank quick action -> Water Test | Save water parameters | Invalid values rejected with clear feedback | Saved result appears in logs, panels, charts | App contract | [before](screenshots/production-tool-audit-2026-05-25/phase3-quick-water-test-sheet.png), [after](screenshots/production-tool-audit-2026-05-25/phase3-quick-water-test-sheet-fixed.png), [empty warning](screenshots/production-tool-audit-2026-05-25/phase3-quick-water-test-empty-warning.png), [saved](screenshots/production-tool-audit-2026-05-25/phase3-quick-water-test-saved.png), focused widget tests | Fixed |
| Feed log | Tank | Tank quick action -> Feed | Save a feeding event | Cancel path does not write | Saved event appears in logs and Today board | App contract | Pending | Pending |
| Water change log | Tank | Tank quick action -> Water Change | Save a water-change event | Invalid volume/percent rejected | Saved event appears in logs and Today board | App contract | Pending | Pending |
| Tank note | Tank | Tank quick action -> Add Note | Save a journal note | Empty note rejected or no-op without crash | Note appears in journal/log surfaces | App contract | Pending | Pending |
| Temperature panel | Tank | Tank -> status panels | Update and display temperature | Invalid temperature rejected | Temperature persists after navigation | Pending Phase 1 | Pending | Pending |
| Water panel | Tank | Tank -> status panels | Show latest parameters | Empty state prompts water test | Latest test values appear consistently | App contract | [water panel after test](screenshots/production-tool-audit-2026-05-25/phase3-water-panel-after-quick-test.png), [tank return](screenshots/production-tool-audit-2026-05-25/phase3-tank-return-after-water-test.png) | Pass |
| Tank Toolbox | Tank | Tank -> Toolbox | Shows tank-contextual care tools only | No tank state avoids dead ends | No duplicate global calculators here | App contract | [toolbox](screenshots/production-tool-audit-2026-05-25/phase3-tank-toolbox-sheet.png), XML scan excludes Analytics, Species Search, Cost Tracker, and calculators | Pass |
| Tank Detail | Tank Detail | Tank -> current tank detail | Overview, care, livestock, and settings routes load | Empty/demo tank surfaces remain useful | Detail reflects current selected tank | App contract | [top](screenshots/production-tool-audit-2026-05-25/phase3-tank-detail-top.png), [overflow](screenshots/production-tool-audit-2026-05-25/phase3-tank-detail-overflow-menu.png), [quick add](screenshots/production-tool-audit-2026-05-25/phase3-tank-detail-quick-add-menu.png), [sections](screenshots/production-tool-audit-2026-05-25/phase3-tank-detail-sections-bottom.png) | Pass |
| Tank settings | Tank Detail | Tank Detail -> Settings | Edit tank name/type/volume | Cancel preserves old settings | Changes propagate to Tank room/detail | App contract | [before](screenshots/production-tool-audit-2026-05-25/phase3-tank-settings-screen.png), [after top](screenshots/production-tool-audit-2026-05-25/phase3-tank-settings-screen-fixed-top.png), [after bottom](screenshots/production-tool-audit-2026-05-25/phase3-tank-settings-screen-fixed-bottom.png), focused widget test | Fixed |
| Compare Tanks | Tank Detail | Tank Detail -> overflow / compare | Compare saved tanks | Fewer than two tanks explains requirement | Uses saved tank data only | App contract | Pending | Pending |
| Estimate Value | Tank Detail | Tank Detail -> overflow / estimate value | Estimate livestock/equipment value | Empty inventory explains requirement | Does not overlap global Cost Tracker | Pending Phase 1 | Pending | Pending |
| Tank reminders | Tank Detail | Tank Detail -> Reminders | Create/edit reminder | Invalid schedule rejected | Phone scheduling remains explicit opt-in | App contract | Pending | Pending |
| Tank tasks | Tank Detail | Tank Detail -> Tasks | Create/complete task | Empty title rejected | Today board reflects due tasks | App contract | Pending | Pending |
| Charts | Tank Detail | Tank Detail -> Charts | Visualize saved water/care data | No data state explains what to log | Updates after logs | App contract | Pending | Pending |
| Journal | Tank Detail | Tank Detail -> Journal | Add/view notes | Empty note behavior is safe | Notes persist after leaving screen | App contract | Pending | Pending |
| Gallery | Tank Detail | Tank Detail -> Gallery | Add/view tank photos when allowed | Permission denied/empty state is clear | Photo storage setting is respected | App contract | Pending | Pending |
| Livestock | Tank Detail | Tank Detail -> Livestock | Add/edit/remove stock | Empty list prompts add flow | Feeds compatibility/value surfaces | Pending Phase 1 | Pending | Pending |
| Equipment | Tank Detail | Tank Detail -> Equipment | Add/edit/remove equipment | Empty list prompts add flow | Feeds cost/value surfaces where supported | App contract | Pending | Pending |
| Delete tank | Tank Detail | Tank Detail -> Settings/Delete | Cancel then confirm deletion on demo data only | Cancel path preserves tank | Undo/recovery behavior verified if present | App contract | Pending | Pending |
| Learn home | Learn | Bottom tab -> Learn | Lesson paths and today's lesson load | Fresh user state has clear next action | Completion seeds XP/progress/reviews | App contract | Pending | Pending |
| Lesson list | Learn | Learn -> path/list | Open lesson from path | Locked/empty states are clear | Path progress updates after completion | App contract | Pending | Pending |
| Lesson flow | Learn | Learn -> lesson | Complete content and quiz | Wrong answer/hint states work | Completion creates review cards where expected | App contract | Pending | Pending |
| XP / species unlocks | Learn | Lesson completion -> XP | XP, level, unlock feedback match state | Repeat completion does not duplicate rewards | Progress visible in More/profile | App contract | Pending | Pending |
| Practice empty state | Practice | Bottom tab -> Practice | Fresh user gets learning-oriented next step | No cards avoids disabled dead ends | No reminder nudges unless opted in | App contract | Pending | Pending |
| Practice due review | Practice | Practice -> due/standard | Run a due-card session | No due cards explains state | Reviews update card strength and stats | App contract | Pending | Pending |
| Practice weak/mixed/quick modes | Practice | Practice -> mode cards | Start each enabled mode | Disabled modes explain requirement | Completion summary updates progress | App contract | Pending | Pending |
| Achievements / progress links | More | More -> Achievements / profile | Show earned and locked achievements | Fresh state is stable | XP/lesson/practice events appear here | App contract | Pending | Pending |
| Smart setup/offline state | Smart | Bottom tab -> Smart | No-key/offline states explain setup | Paid/API unavailable state does not crash | Preferences owns API key setup | App contract | Pending | Pending |
| Fish & Plant ID | Smart | Smart -> Fish & Plant ID | Setup/locked/offline gate works | No image/API key path is clear | No paid calls required | App contract | Pending | Pending |
| Symptom Checker | Smart | Smart -> Symptom Checker | Local/offline triage path loads | Empty symptoms show guidance | Does not imply veterinary certainty | Pending Phase 1 | Pending | Pending |
| Weekly Care Plan | Smart | Smart -> Weekly Plan | Generates or gates care plan correctly | No tank/no key states are clear | Uses tank state when available | App contract | Pending | Pending |
| Ask Danio | Smart | Smart -> Ask Danio | Setup/offline chat gate loads | Empty question handled | No paid call without key | App contract | Pending | Pending |
| AI Compatibility Advice | Smart | Smart -> Compatibility Advice | AI/setup gate label is clear | No key/offline handled | Distinct from Workshop local checker | App contract | Pending | Pending |
| Anomaly History | Smart | Smart -> Anomaly History | Empty/history state loads | No anomaly state is clear | Uses saved tank observations if present | App contract | Pending | Pending |
| Shop Street | More | More -> Shop Street | Shop hub loads | Empty/locked states stable | Rewards/currency labels match data | App contract | Pending | Pending |
| Gem Shop | More | More -> Gem Shop | Gem shop loads | Insufficient currency state clear | Purchases do not corrupt rewards state | App contract | Pending | Pending |
| Analytics | More | More -> Analytics | Analytics hub loads with saved data | No data state explains logging | Reads learning/tank data accurately | App contract | Pending | Pending |
| Backup & Restore | More | More -> Backup & Restore | Export/import entry points load | Permission/cancel paths safe | Does not imply unsupported cloud backup | App contract | Pending | Pending |
| Preferences | More | More -> Preferences | Settings categories open | Empty/missing profile defaults safe | Settings persist after navigation | App contract | Pending | Pending |
| Notification Settings | Preferences | Preferences -> Notifications | Toggle reminders on/off | Permission denied path is clear | Scheduling remains explicit opt-in | App contract | Pending | Pending |
| AI Configuration | Preferences | Preferences -> OpenAI API Key | Save/clear key paths work | Empty key state remains offline | Smart setup reflects key state | App contract | Pending | Pending |
| Appearance & Accessibility | Preferences | Preferences -> appearance/accessibility | Theme, motion, haptics settings persist | Unsupported settings do not crash | App visual state updates consistently | App contract | Pending | Pending |
| Privacy Controls | Preferences | Preferences -> privacy/data | Privacy controls and export entry points load | Cancel paths preserve data | Consent/privacy state remains coherent | App contract | Pending | Pending |
| Clear/Delete Data | Preferences | Preferences -> destructive data controls | Dialogs require confirmation | Cancel preserves data | Destructive actions tested only on seeded data | App contract | Pending | Pending |
| About / Legal | More | More -> About -> legal | About, privacy, terms load | Back navigation returns to About/More | Version/legal copy visible without overflow | App contract | Pending | Pending |

## Golden Checks

These expectations are the Phase 1 oracle for the first product-fix phase. Calculator outputs are acceptance checks; care guidance remains conservative and labelled as an estimate where species/tank variation matters.

| Tool | Golden valid check | Golden invalid / edge check | Source expectation |
| --- | --- | --- | --- |
| Water Change Calculator | 100 L, current nitrate 40 ppm, target 20 ppm, source 0 ppm -> 50% / 50 L. With source 5 ppm -> about 57.1% / 57 L. | Source/tap nitrate at or above target should not claim the target is reachable by dilution. Changes over about 60% should advise splitting. | AquaKit documents the dilution formula `tank volume * (current - target) / (current - source)` and explains source water nitrate effects. Aquarium Co-op says nitrate at 50 ppm or above should trigger water changes until a lower target is reached. |
| CO2 Calculator | KH 4 dKH and pH 7.0 -> 12 mg/L. KH 5 dKH and pH 7.0 -> 15 mg/L. Formula tolerance: +/- 0.1 mg/L. | Invalid pH outside 0-14 and KH <= 0 should show validation. Copy must say the pH/KH result is an estimate. | AquaPilot documents `CO2 mg/L = 3 * KH * 10^(7-pH)` and the carbonate-buffer limitation. Tropica says medium plants need roughly 10-15 mg/L and advanced plants roughly 15-30 mg/L. |
| Dosing Calculator | Seachem Prime: 100 L -> 2.5 mL. Seachem Stability initial: 100 L -> 12.5 mL. API Stress Coat: 100 L -> about 13.2 mL using 5 mL / 38 L, acceptable if rounded to 12.5 mL at 5 mL / 40 L. Tropica Specialised: 100 L -> 12 mL. Easy Green 500 mL bottle: 100 L -> about 2.6 mL. | Empty/zero tank volume or dose amount should show validation and never calculate. Medication warning stays visible. | Seachem Prime: 5 mL / 200 L. Seachem Stability initial: 5 mL / 40 L. API Stress Coat label: 5 mL / 10 US gal (38 L). Tropica Specialised: 6 mL / 50 L weekly. Aquarium Co-op Easy Green: 1 mL / 10 US gal. |
| Unit Converter | 1 US gal -> 3.785411784 L. 1 UK gal -> 4.54609 L. 25 C -> 77 F / 298.15 K. 10 in -> 25.4 cm. 1 dGH -> 17.848 ppm CaCO3. | Empty input shows no results without crash. Kelvin below 0 should not be encouraged if the UI ever allows it. Visible unit symbols must render as `degC`, `degF`, and `CaCO3` or proper Unicode, not mojibake. | NIST provides US liquid gallon and cubic inch/litre conversions; temperature formulas are standard Celsius/Fahrenheit/Kelvin conversions; German hardness is commonly 17.848 mg/L CaCO3 per degree. |
| Tank Volume Calculator | Rectangular 100 x 40 x 50 cm -> 200 L, about 52.8 US gal, 44.0 UK gal, 180 L usable at 90%. Rectangular 20 x 10 x 12 in -> about 39.3 L. | Zero/negative/missing dimensions show the empty calculation state without stale results. Shape labels and degree/bullet symbols must not mojibake. | Rectangular volume is length * width * height; 1 cm3 = 1 mL; NIST conversion factors for gallons/litres/inches. |
| Lighting Planner | Low-tech planted schedule of 8 hours should be accepted. Algae mode should recommend reducing toward 4-6 hours. A midnight-crossing schedule such as 22:00 -> 02:00 should display as 4 hours and render without layout exceptions. | Siesta periods must not create negative total hours or negative timeline widths. | Aquarium Co-op recommends starting newly planted aquariums at 6-8 hours; Tropica says start with 6 hours; Aquarium Co-op lighting guidance ties excess light to algae risk. |
| Stocking Calculator | Adding a small shoaling species should increase stocking estimate and remain clearly labelled as an estimate. | Tank volume <= 0 and filter rating <= 0 should show validation. Overstocked state should warn without implying exact safety. | AqAdvisor explains stocking calculators need species attributes, filtration, water-change schedule, compatibility, temperature/pH/hardness, and warns the result is not a replacement for experienced advice. |
| Workshop Compatibility Checker | Betta + neon tetra should produce a caution warning. Non-overlapping temperature or pH ranges should produce a serious issue. | Empty state should ask the user to add fish and not show a false verdict. | AqAdvisor highlights compatibility, aggression, size, minimum tank size, pH, temperature, hardness, territory, and diet as relevant attributes, while warning such tools are imperfect. |
| Cycling Assistant | No tests -> ready/not started. Ammonia present -> phase 1. Nitrite present -> phase 2. Ammonia and nitrite near zero with nitrate present -> cycled/near-cycled, with conservative copy. | Copy must describe ammonia oxidation and nitrite oxidation correctly. Planted tanks with very low nitrate should not be falsely framed as impossible to cycle. | Seachem describes cycling as beneficial bacteria converting toxic waste into less toxic forms, with ammonia/nitrite/nitrate tests used to track progress. PetMD and other care sources identify Nitrosomonas-type bacteria as ammonia-to-nitrite and Nitrospira/Nitrobacter-type bacteria as nitrite-to-nitrate. |
| Cost Tracker | Add expense, persist after leaving screen, summarize month/year/all-time, delete with undo, clear all with confirmation. | Empty description/amount, zero amount, cancel date/settings/destructive dialogs should not write data. Currency symbols and category separators must not mojibake. | App contract; no external care formula required. |

Source URLs:
- AquaKit water-change formula: https://aquakit.app/tools/water-change-calculator
- Aquarium Co-op nitrate guidance: https://www.aquariumcoop.com/blogs/aquarium/nitrate
- Tropica CO2/fertiliser guidance: https://tropica.com/en/guide/make-your-aquarium-a-success/fertiliser-and-co2/
- AquaPilot pH/KH CO2 formula: https://aqua-pilot.app/en/tools/co2-ph-kh-chart
- API Freshwater Master Test Kit: https://www.apifishcare.com/products/api-freshwater-master-test-kit
- AqAdvisor stocking limitations: https://aqadvisor.com/articles/AqAdvisorIntro.php
- Seachem Prime directions: https://seachem.zendesk.com/hc/en-us/articles/115000125454-Info-Seachem-Prime-dosing-instructions
- Seachem Stability directions: https://seachem.zendesk.com/hc/en-us/articles/115000127873-Info-Seachem-Stability-Dosing-Instructions
- API Stress Coat label via DailyMed: https://dailymed.nlm.nih.gov/dailymed/getFile.cfm?setid=fc4477cc-4d3a-4cbc-9c81-a0f5e48550be&type=pdf
- Tropica Specialised Nutrition: https://tropica.com/en/plant-care/liquid-fertilisers/specialised-nutrition/
- Aquarium Co-op Easy Green: https://www.aquariumcoop.com/products/easy-green-all-in-one-fertilizer
- NIST unit conversions: https://www.nist.gov/document/nist-hb-44-2024-appendix-c-general-tables-units-measurement
- Aquarium Co-op lighting balance: https://www.aquariumcoop.com/blogs/aquarium/how-to-balance-aquarium-lighting
- Tropica starting-light guidance: https://tropica.com/en/guide/get-the-right-start/growing-in/
- Seachem cycling introduction: https://seachem.zendesk.com/hc/en-us/articles/115000145073-Guide-An-introduction-to-cycling-your-tank
- PetMD beneficial bacteria overview: https://www.petmd.com/fish/care/using-good-bacteria-your-aquarium

## Issue Triage

| ID | Severity | Area | Finding | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| QA-001 | P2 | QA harness | Black-box smoke did not recover from Android emulator install storage pressure. | Fixed in harness; focused test added. | `test/scripts/android_blackbox_smoke_script_test.dart`; failed artifacts under phase0-install-failures |
| QA-002 | P3 | Integration harness | Repeated integration-test launches can log a caught duplicate Firebase initialization while tests still pass. | Documented for watchlist; not seen as a fatal normal-run issue in black-box logcat. | `flutter test integration_test/smoke_test_v2.dart -d emulator-5560` output |
| QA-003 | P1 | Dosing Calculator | Tropica Specialised and Easy Green presets used too-small per-litre rates versus product guidance; API Stress Coat rounded to 40 L instead of 10 US gal / 38 L. | Fixed; preset tests added. | `test/widget_tests/dosing_calculator_screen_test.dart`; [presets](screenshots/production-tool-audit-2026-05-25/phase2-dosing-presets.png) |
| QA-004 | P2 | Lighting Planner | Midnight-spanning siesta periods subtracted a negative interval, producing impossible total-light durations; timeline rendering used raw negative widths for wrapped schedules. | Fixed; midnight schedule tests added. | `test/widget_tests/lighting_schedule_screen_test.dart`; [default screenshot](screenshots/production-tool-audit-2026-05-25/phase2-lighting-default.png) |
| QA-005 | P2 | Cycling Assistant | Phase 1 education copy attributed ammonia-to-nitrite conversion to Nitrospira. | Fixed; phase education tests added. | `test/widget_tests/cycling_assistant_screen_test.dart` |
| QA-006 | P2 | Quick Water Test | The compact temperature field label clipped as `Temp (...` on the 1080 px emulator. | Fixed by moving the unit into a suffix and testing the compact label. | `test/widget_tests/home_sheets_tank_test.dart`; [after](screenshots/production-tool-audit-2026-05-25/phase3-quick-water-test-sheet-fixed.png) |
| QA-007 | P2 | Tank bottom panel | Expanded Tank panel clipped tab/stat labels (`Progres`, `0 ge...`, `35 tod...`) in the normal phone-width layout. | Fixed with scaled tab labels and non-ellipsized compact stat labels. | `test/widgets/stage/swiss_army_panel_test.dart`; `test/widget_tests/gamification_dashboard_test.dart`; [after](screenshots/production-tool-audit-2026-05-25/phase3-tank-bottom-panel-expanded-fixed.png) |
| QA-008 | P2 | Tank Settings | The final destructive action could sit too close to or beneath the persistent bottom dock. | Fixed by using the shared bottom-dock clearance for settings list padding. | `test/widget_tests/tank_settings_screen_test.dart`; [after bottom](screenshots/production-tool-audit-2026-05-25/phase3-tank-settings-screen-fixed-bottom.png) |
| QA-009 | P3 | Emulator QA | `emulator-5564` dropped off ADB during one black-box final logcat capture. | Documented as environmental; reran black-box smoke successfully on `emulator-5554`. | [failure artifacts](screenshots/production-tool-audit-2026-05-25/phase3-blackbox/); `phase3-blackbox-emulator-5554` run passed |

## Phase Notes

- Phase 0 is complete once the harness patch, dossier, focused test, analyzer, and passing black-box evidence are committed.
- Phase 1 completed source-backed golden checks before touching calculator behavior.
- Phase 2 completed Workshop-focused fixes and evidence:
  - `flutter test` Workshop subset: 136 tests passed.
  - `flutter analyze --no-pub`: pass.
  - `flutter build apk --debug --target lib/main.dart`: pass.
  - `scripts/run_android_blackbox_smoke.ps1 -IncludeQaDeepLinks`: pass on `emulator-5564`; emulator storage retry/fallback path was exercised successfully.
  - Manual emulator screenshots/XML captured for Workshop hub, Dosing empty/valid/presets, and Lighting default.
  - Phase 2 logcat scan: clean for fatal Android, Flutter, widget, render overflow, and negative constraint signatures. See [logcat](screenshots/production-tool-audit-2026-05-25/phase2-workshop-logcat.txt).
- Phase 3a completed Tank shell, quick water test, bottom panel, toolbox, detail overview, and settings polish:
  - Tank-focused subset: 160 tests passed.
  - `flutter analyze --no-pub`: pass.
  - `flutter build apk --debug --target lib/main.dart --target-platform android-x64`: pass and installed on `emulator-5554`.
  - `scripts/run_android_blackbox_smoke.ps1 -DeviceId emulator-5554`: pass.
  - Manual emulator screenshots/XML captured for Tank room, quick action menu, quick water test valid/invalid/save, water panel integration, bottom panel before/after, Tank Toolbox, Tank Detail overview/overflow/quick-add/sections, and Tank Settings before/after.
  - Phase 3 refined logcat scan: clean for fatal Android, Flutter, widget, render overflow, and negative constraint signatures. See [logcat](screenshots/production-tool-audit-2026-05-25/phase3-tank-logcat-after-detail.txt).
- Later phases will add valid/invalid screenshots, focused test references, and pass/fix status to the matrix above.
