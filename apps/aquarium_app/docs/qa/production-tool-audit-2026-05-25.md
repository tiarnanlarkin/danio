# Production Tool Audit - 2026-05-25

Branch: `qa/production-tool-audit-2026-05-25`  
Base commit: `0d107483`  
Primary QA target: `emulator-5560`, `Danio_E2E_API_36_1`, Android 16, 1080x2400  
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
| Water Change Calculator | Workshop | More -> Workshop -> Water Change | Calculate change volume from tank size, current nitrate, target nitrate, and tap nitrate | Reject impossible target/tap/current combinations | Result can inform Tank water-change logging without auto-writing data | Pending Phase 1 | Pending | Pending |
| Stocking Calculator | Workshop | More -> Workshop -> Stocking | Estimate stocking load for tank size and selected species | Empty tank/species input shows useful guidance | Estimate remains separate from Tank livestock until user adds stock | Pending Phase 1 | Pending | Pending |
| CO2 Calculator | Workshop | More -> Workshop -> CO2 Calculator | Estimate CO2 from KH and pH | Reject invalid pH/KH values | Advice copy stays estimate-based and non-prescriptive | Pending Phase 1 | Pending | Pending |
| Dosing Calculator | Workshop | More -> Workshop -> Dosing | Calculate product dose from product rate and tank volume | Reject missing tank volume/product input | No medication claim beyond current supported products | Pending Phase 1 | Pending | Pending |
| Unit Converter | Workshop | More -> Workshop -> Unit Converter | Convert volume, temperature, length, and hardness values | Empty/invalid numeric input does not crash | Tool is stateless and returns to Workshop cleanly | Pending Phase 1 | Pending | Pending |
| Tank Volume Calculator | Workshop | More -> Workshop -> Tank Volume | Calculate common tank shapes with unit conversion | Reject zero/negative dimensions | Can be used before tank creation without requiring a saved tank | Pending Phase 1 | Pending | Pending |
| Lighting Planner | Workshop | More -> Workshop -> Lighting | Generate light schedule and CO2 timing advice | Handles midnight-spanning schedules and empty input | Advice remains planner-only unless user applies it elsewhere | Pending Phase 1 | Pending | Pending |
| Workshop Compatibility Checker | Workshop | More -> Workshop -> Compatibility | Local compatibility estimate for selected species | Empty species/tank values show setup guidance | Label stays distinct from Smart AI compatibility advice | Pending Phase 1 | Pending | Pending |
| Cycling Assistant | Workshop | More -> Workshop -> Cycling Assistant | Show cycling stage guidance for a selected tank | No tank state explains requirement | Tank detail cycling status may deep-link here with context | Pending Phase 1 | Pending | Pending |
| Cost Tracker | Workshop | More -> Workshop -> Cost Tracker | Add, persist, summarize, delete, and undo an expense | Empty/invalid amount is rejected | Tank-specific value tools remain separate from global cost tracking | Pending Phase 1 | Pending | Pending |
| Tank room | Tank | Bottom tab -> Tank | Room scene loads with current tank state | No tank state prompts creation without crash | Tank room reflects saved logs and selected tank | App contract | Pending | Pending |
| Tank bottom panel | Tank | Tank -> bottom panel tabs | Today/care/status tabs open and scroll safely | No data states are calm and actionable | State updates after care actions | App contract | Pending | Pending |
| Today board | Tank | Tank -> Today | Daily goal and due care items reflect current state | No tasks/reviews avoids nagging | Care actions update board without stale state | App contract | Pending | Pending |
| Tank switcher / add tank | Tank | Tank -> switcher / add tank | Create and switch between multiple tanks | Cancel/discard paths preserve data | Selected tank drives Tank Detail and logs | App contract | Pending | Pending |
| Quick water test | Tank | Tank quick action -> Water Test | Save water parameters | Invalid values rejected with clear feedback | Saved result appears in logs, panels, charts | Pending Phase 1 | Pending | Pending |
| Feed log | Tank | Tank quick action -> Feed | Save a feeding event | Cancel path does not write | Saved event appears in logs and Today board | App contract | Pending | Pending |
| Water change log | Tank | Tank quick action -> Water Change | Save a water-change event | Invalid volume/percent rejected | Saved event appears in logs and Today board | App contract | Pending | Pending |
| Tank note | Tank | Tank quick action -> Add Note | Save a journal note | Empty note rejected or no-op without crash | Note appears in journal/log surfaces | App contract | Pending | Pending |
| Temperature panel | Tank | Tank -> status panels | Update and display temperature | Invalid temperature rejected | Temperature persists after navigation | Pending Phase 1 | Pending | Pending |
| Water panel | Tank | Tank -> status panels | Show latest parameters | Empty state prompts water test | Latest test values appear consistently | Pending Phase 1 | Pending | Pending |
| Tank Toolbox | Tank | Tank -> Toolbox | Shows tank-contextual care tools only | No tank state avoids dead ends | No duplicate global calculators here | App contract | Pending | Pending |
| Tank Detail | Tank Detail | Tank -> current tank detail | Overview, care, livestock, and settings routes load | Empty/demo tank surfaces remain useful | Detail reflects current selected tank | App contract | Pending | Pending |
| Tank settings | Tank Detail | Tank Detail -> Settings | Edit tank name/type/volume | Cancel preserves old settings | Changes propagate to Tank room/detail | App contract | Pending | Pending |
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

Phase 1 will replace `Pending Phase 1` entries with source-backed expectations before product fixes. Initial source anchors:
- Tropica CO2 and fertiliser guidance: https://tropica.com/en/guide/make-your-aquarium-a-success/fertiliser-and-co2/
- API Freshwater Master Test Kit: https://www.apifishcare.com/products/api-freshwater-master-test-kit
- AqAdvisor limitations: https://aqadvisor.com/articles/AqAdvisorIntro.php
- Aquarium Co-op nitrate guidance: https://www.aquariumcoop.com/blogs/aquarium/nitrate
- AquaKit water-change calculator: https://aquakit.app/tools/water-change-calculator

## Issue Triage

| ID | Severity | Area | Finding | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| QA-001 | P2 | QA harness | Black-box smoke did not recover from Android emulator install storage pressure. | Fixed in harness; focused test added. | `test/scripts/android_blackbox_smoke_script_test.dart`; failed artifacts under phase0-install-failures |
| QA-002 | P3 | Integration harness | Repeated integration-test launches can log a caught duplicate Firebase initialization while tests still pass. | Documented for watchlist; not seen as a fatal normal-run issue in black-box logcat. | `flutter test integration_test/smoke_test_v2.dart -d emulator-5560` output |

## Phase Notes

- Phase 0 is complete once the harness patch, dossier, focused test, analyzer, and passing black-box evidence are committed.
- Phase 1 must research numeric/care expectations before touching calculator behavior.
- Each later phase will add valid/invalid screenshots, focused test references, and pass/fix status to the matrix above.
