# Danio Final-Polish Remediation Tracker

Date: 2026-05-09
App: Danio `1.0.0+1`
Package: `com.tiarnanlarkin.danio`
Primary final emulator: `emulator-5556`, 1080x2400, density 420
Unavailable target: `emulator-5554` was offline during final closure
Final artifact root: `C:\Users\larki\Documents\Danio Aquarium App Project\repo\apps\aquarium_app\build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738`
Original remediation artifact root: `C:\Users\larki\Documents\Danio Aquarium App Project\repo\apps\aquarium_app\build\qa-artifacts\final-polish-remediation-20260509`
Original audit artifact root: `C:\Users\larki\Documents\Danio Aquarium App Project\repo\apps\aquarium_app\build\qa-artifacts\final-polish-audit-20260509-031522`

## Status Rules

Allowed status values:
- `Not started`
- `In progress`
- `Code complete`
- `Automated tests passed`
- `Emulator verified`
- `Done`

An issue can only be marked `Done` after relevant automated tests and emulator evidence are linked.

## Final Verification Gates

- [x] `.\scripts\flutterw.ps1 analyze --no-pub` - `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\final2-analyze.txt`
- [x] `.\scripts\flutterw.ps1 test` - `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\final2-full-flutter-test.txt` (`1050` tests passed)
- [x] `.\scripts\flutterw.ps1 build apk --debug` - `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\final2-build-debug.txt`
- [x] `.\scripts\flutterw.ps1 build apk --release` - `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\final2-build-release.txt`
- [x] `.\scripts\run_integration_smoke.ps1 -DeviceId emulator-5556 -FlutterCommand .\scripts\flutterw.ps1` - `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\final3-integration-smoke.txt`
- [x] `.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5556 -InstallApkPath build\app\outputs\flutter-apk\app-debug.apk -IncludeQaDeepLinks` - `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\final6-blackbox-smoke.txt`
- [x] Release clean install/launch/logcat/screenshot check - `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\release-startup\cold-start-am-start-W.txt`, `warm-start-am-start-W.txt`, `cold-logcat.txt`, `warm-logcat.txt`, `cold-screen.png`, `warm-screen.png`
- [ ] `.\scripts\run_maestro_smoke.ps1 -DeviceId emulator-5556 -MaestroPath C:\maestro\bin\maestro.bat` - environment blocked; see DA-003
- [x] `git diff --check` - no whitespace errors; only existing Windows LF/CRLF conversion warnings

## Additional Emulator Evidence

Success screenshots and UI hierarchy dumps for deterministic debug-only QA states:

- Lesson selected-correct state: `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\evidence-final\da-007-selected-correct.png`, `da-007-selected-correct.xml`
- Lesson hint reveal: `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\evidence-final\da-008-lesson-hint-revealed.png`, `da-008-lesson-hint-revealed.xml`
- Full-screen practice session: `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\evidence-final\da-009-da-010-practice-session-fullscreen.png`, `da-009-da-010-practice-session-fullscreen.xml`
- Create Tank dirty form: `build\qa-artifacts\final-polish-reaudit-20260509-20260509-064738\evidence-final\da-012-create-tank-dirty.png`, `da-012-create-tank-dirty.xml`

## Issue Tracker

### DA-001 Startup Jank And Global Launch Polish

- [x] Status: `Done`
- Owner: Coordinator
- Files: `android\app\src\main\AndroidManifest.xml`, `lib\main.dart`, `lib\screens\onboarding\consent_screen.dart`
- Tests: `final2-analyze.txt`, `final2-full-flutter-test.txt`, `final2-build-debug.txt`, `final2-build-release.txt`
- Emulator Evidence: `release-startup\cold-start-am-start-W.txt`, `warm-start-am-start-W.txt`, `cold-logcat.txt`, `warm-logcat.txt`, `cold-screen.png`, `warm-screen.png`
- Follow-up: Release launch is crash-free and visually stable. Cold release launch recorded `TotalTime: 4446` and one non-repeated skipped-frame warning; warm launch returned to foreground in `143ms` with no repeated skipped-frame burst.

### DA-002 Integration Smoke Command Drift

- [x] Status: `Done`
- Owner: Worker D / Coordinator
- Files: `scripts\run_integration_smoke.ps1`, `test\scripts\integration_smoke_script_test.dart`, `.maestro\README.md`, `docs\TEST_REPORT.md`, `docs\test-coverage-audit.md`, `docs\review-findings-argus.md`
- Tests: `final2-full-flutter-test.txt`, targeted `test\scripts\integration_smoke_script_test.dart`
- Emulator Evidence: `final3-integration-smoke.txt`
- Follow-up: Wrapper now uses `flutter drive` and rebuilds the standard debug APK afterward so downstream APK-based smoke tests do not accidentally install the integration-test harness.

### DA-003 Maestro Smoke Drift And Batch Reliability

- [ ] Status: `In progress`
- Owner: Worker D / Coordinator
- Files: `scripts\run_maestro_smoke.ps1`, `.maestro\*.yaml`, `.maestro\README.md`, `docs\qa\automation-hardening-2026-05-09.md`
- Tests: `final2-full-flutter-test.txt`
- Emulator Evidence: `maestro\maestro-version.txt`, `maestro\maestro-list-devices.txt`, `maestro\maestro-hierarchy-emulator-5556.txt`, `maestro\run-maestro-smoke-emulator-5556.txt`
- Follow-up: Maestro `2.5.1` is installed at `C:\maestro`, Java is `25.0.1`, but Maestro lists only `pixel_6 android-33` and reports `Device with id emulator-5556 is not connected` for the available API 36 emulator. No API 34/35 AVD is available locally, so this remains an environment blocker rather than an app defect.

### DA-004 Age-Blocked Flow Has No In-App Recovery

- [x] Status: `Done`
- Owner: Coordinator
- Files: `lib\screens\onboarding\age_blocked_screen.dart`
- Tests: `final2-full-flutter-test.txt`
- Emulator Evidence: `build\qa-artifacts\final-polish-remediation-20260509\evidence\da-004-age-blocked.png`, `da-004-age-blocked-window.xml`
- Follow-up: None.

### DA-005 Learn Bottom Safe-Area Crowding

- [x] Status: `Done`
- Owner: Coordinator
- Files: `lib\screens\learn\learn_screen.dart`
- Tests: `final2-full-flutter-test.txt`
- Emulator Evidence: `final6-blackbox-smoke.txt`
- Follow-up: None.

### DA-006 QA Settings Deep Link Stops At More

- [x] Status: `Done`
- Owner: Coordinator
- Files: `lib\services\debug_deep_link_service.dart`, `scripts\run_android_blackbox_smoke.ps1`
- Tests: `final2-full-flutter-test.txt`
- Emulator Evidence: `final6-blackbox-smoke.txt`
- Follow-up: None.

### DA-007 Lesson Quiz Selected Correct Marker Is Blank

- [x] Status: `Done`
- Owner: Worker B / Coordinator
- Files: `lib\screens\lesson\lesson_quiz_widget.dart`, `lib\screens\debug_qa_seed_screen.dart`, `lib\services\debug_deep_link_service.dart`, `scripts\run_android_blackbox_smoke.ps1`
- Tests: `final2-full-flutter-test.txt`, `test\widget_tests\debug_qa_seed_screen_test.dart`, `test\widget_tests\lesson_screen_test.dart`
- Emulator Evidence: `final6-blackbox-smoke.txt`, `evidence-final\da-007-selected-correct.png`, `evidence-final\da-007-selected-correct.xml`
- Follow-up: None.

### DA-008 Lesson Hint Control Does Not Reveal An Obvious Hint

- [x] Status: `Done`
- Owner: Worker B / Coordinator
- Files: `lib\screens\lesson\lesson_quiz_widget.dart`, `lib\screens\debug_qa_seed_screen.dart`, `lib\services\debug_deep_link_service.dart`, `scripts\run_android_blackbox_smoke.ps1`
- Tests: `final2-full-flutter-test.txt`, `test\widget_tests\debug_qa_seed_screen_test.dart`, `test\widget_tests\lesson_screen_test.dart`
- Emulator Evidence: `final6-blackbox-smoke.txt`, `evidence-final\da-008-lesson-hint-revealed.png`, `evidence-final\da-008-lesson-hint-revealed.xml`
- Follow-up: None.

### DA-009 Practice Session Question Left Clipping

- [x] Status: `Done`
- Owner: Worker B / Coordinator
- Files: `lib\screens\spaced_repetition_practice\review_session_screen.dart`, `lib\screens\debug_qa_seed_screen.dart`, `lib\services\debug_deep_link_service.dart`, `scripts\run_android_blackbox_smoke.ps1`
- Tests: `final2-full-flutter-test.txt`, `test\widget_tests\review_session_screen_test.dart`, `test\widget_tests\debug_qa_seed_screen_test.dart`
- Emulator Evidence: `final6-blackbox-smoke.txt`, `evidence-final\da-009-da-010-practice-session-fullscreen.png`, `evidence-final\da-009-da-010-practice-session-fullscreen.xml`
- Follow-up: None.

### DA-010 Practice Session Keeps Bottom Tab Nav Visible

- [x] Status: `Done`
- Owner: Coordinator / Worker B
- Files: `lib\utils\navigation_throttle.dart`, `lib\navigation\app_routes.dart`, `lib\screens\practice_hub_screen.dart`, `lib\screens\learn\learn_practice_card.dart`, `lib\screens\learn\learn_review_banner.dart`, `lib\screens\spaced_repetition_practice\review_session_screen.dart`, `lib\screens\debug_qa_seed_screen.dart`
- Tests: `final2-full-flutter-test.txt`, `test\widget_tests\navigation_throttle_test.dart`, `test\widget_tests\review_session_screen_test.dart`
- Emulator Evidence: `final6-blackbox-smoke.txt`, `evidence-final\da-009-da-010-practice-session-fullscreen.png`, `evidence-final\da-009-da-010-practice-session-fullscreen.xml`
- Follow-up: None.

### DA-011 Nested Tools And Settings Can Be Obscured By Bottom Nav

- [x] Status: `Done`
- Owner: Coordinator / Worker C
- Files: `lib\utils\navigation_throttle.dart`, `lib\navigation\app_routes.dart`, `lib\screens\settings_hub_screen.dart`, `lib\screens\settings\settings_screen.dart`, `lib\screens\backup_restore_screen.dart`, `lib\screens\smart_screen.dart`, `lib\screens\workshop_screen.dart`, `lib\screens\settings\widgets\tools_section.dart`, `lib\screens\home\home_screen.dart`
- Tests: `final2-full-flutter-test.txt`
- Emulator Evidence: `final6-blackbox-smoke.txt`
- Follow-up: None.

### DA-012 Create Tank Dirty-Form Discard Loops Instead Of Closing

- [x] Status: `Done`
- Owner: Worker A / Coordinator
- Files: `lib\screens\create_tank_screen.dart`, `lib\screens\add_log\add_log_screen.dart`, `lib\services\debug_deep_link_service.dart`, `scripts\run_android_blackbox_smoke.ps1`
- Tests: `final2-full-flutter-test.txt`, `test\widget_tests\create_tank_screen_test.dart`, `test\widget_tests\add_log_screen_test.dart`
- Emulator Evidence: `final6-blackbox-smoke.txt`, `evidence-final\da-012-create-tank-dirty.png`, `evidence-final\da-012-create-tank-dirty.xml`
- Follow-up: None.

### DA-013 Smart Locked AI Cards Are Non-Actionable

- [x] Status: `Done`
- Owner: Worker C
- Files: `lib\screens\smart_screen.dart`, `lib\features\smart\fish_id\fish_id_screen.dart`
- Tests: `final2-full-flutter-test.txt`, `test\widget_tests\smart_screen_test.dart`
- Emulator Evidence: `final6-blackbox-smoke.txt`
- Follow-up: None.

### DA-014 Duplicate Semantics Labels In More/Settings/Backup

- [x] Status: `Done`
- Owner: Worker C
- Files: `lib\widgets\core\app_list_tile.dart`, `lib\widgets\core\app_button.dart`, `lib\screens\settings_hub_screen.dart`, `test\widget\settings_screen_test.dart`, `test\widget_tests\settings_hub_screen_test.dart`
- Tests: `final2-full-flutter-test.txt`
- Emulator Evidence: `final6-blackbox-smoke.txt`
- Follow-up: None.

## Full Reaudit Notes

- Read-only reaudit passes covered the original 10 chunks: launch/onboarding/navigation/Learn, lessons/practice/tank, Smart/More/settings/error states/visual polish.
- No new app defect was promoted to `DA-015+` after the remediation and final emulator verification.
- The only remaining open tracker item is DA-003, which is a local Maestro/device compatibility blocker.

