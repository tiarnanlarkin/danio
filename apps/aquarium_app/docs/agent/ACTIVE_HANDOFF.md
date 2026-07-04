# Danio Active Handoff

Status: Active current-session handoff
Last updated: 2026-07-04 after phone Smart root recapture

## Branch

- Branch: `qa/production-tool-audit-2026-05-25`
- Latest slice commit: `docs: recapture phone smart qa evidence`.
- Source build commit for the latest device recapture:
  `273a9644 fix: harden smart dock qa smoke`.
- Prior pushed handoff reference from user: `ce4a72b1 docs: add session freshness handoff rule`

## Current Slice

- Slice: CL-QA-001 phone Smart root recapture after the bottom-dock fix.
- Scope completed: installed the current debug APK on `danio_api36`, opened
  `danio://qa/smart`, captured after-fix screenshot/XML/logcat evidence without
  overwriting the pre-fix failure artifacts, and verified Fish & Plant ID clears
  the bottom dock by `47px`.
- Product behavior changes: Smart under the persistent bottom dock now nudges
  the locked Fish & Plant ID card above the dock on phone-sized shells.
- New accounts/tools/plugins/MCP/hooks/automations: none.
- Live preview/device requirement: completed through `DEVICE_OWNERSHIP.md` and
  `LIVE_PREVIEW_WORKFLOW.md`. No `flutter run` terminal is attached.

## Dirty Files To Preserve

- Expected current slice files:
  - `docs/qa/whole-app-phone-map-2026-07-04.md`
  - `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-04b-smart-root-after-dock-fix.png`
  - `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-04b-smart-root-after-dock-fix.xml`
  - `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-smart-after-dock-fix-logcat-tail.txt`
  - `docs/agent/DEVICE_OWNERSHIP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SCREEN_INVENTORY.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

## Last Checks

- `git status --short -uall` before device work showed only the newly added QA
  execution plan.
- `adb devices` showed:
  - `RFCY8022D5R` as `unauthorized`; it was not used.
  - `emulator-5554` as `device`.
  - `emulator-5556` as `device`.
- `.\scripts\run_danio_live_preview.ps1 -DeviceId emulator-5554 -CheckOnly -WaitSeconds 180`
  passed for phone AVD `danio_api36`.
- `.\scripts\run_danio_live_preview.ps1 -AvdName danio_tablet_api36 -DeviceId emulator-5556 -CheckOnly -WaitSeconds 180`
  passed for tablet AVD `danio_tablet_api36`.
- `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep`
  passed, including focused tests, dependency validation, custom lint,
  `flutter analyze`, debug APK build, and read-only device visibility. The APK
  build emitted known Kotlin Gradle Plugin deprecation warnings only.
- `adb install -r build\app\outputs\flutter-apk\app-debug.apk` succeeded on
  both owned AVDs.
- `adb shell am start -n com.tiarnanlarkin.danio/.MainActivity` launched Danio
  on both owned AVDs.
- Pre-fix phone black-box smoke failed at Smart/Fish & Plant ID setup because
  the existing helper tapped a low card whose center overlapped the bottom dock.
  Evidence is in
  `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`.
- Pre-fix tablet black-box smoke failed before Workshop route verification; the
  failure state was Tank root. Evidence is in
  `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`.
- Direct QA deep-link evidence captured 19 paired PNG/XML states per form
  factor. Every XML contains a `<hierarchy>` root.
- Narrow logcat crash scan found no `FATAL EXCEPTION`, `AndroidRuntime: FATAL`,
  `E/flutter`, `RenderFlex overflowed`, or `ANR in` entries in the committed
  phone/tablet logcat tails. Broad scans saw UIAutomator `AndroidRuntime`
  startup/shutdown lines and `BLASTSyncEngine` transition warnings only.
- RED repro:
  `flutter test test/widget_tests/tab_navigator_test.dart --plain-name "Smart locked AI cards start clear of the bottom dock" --reporter compact`
  failed before the Smart scroll fix because the card bottom sat below the dock
  clearance line.
- Green focused checks:
  `flutter test test/widget_tests/tab_navigator_test.dart --reporter compact`;
  `flutter test test/widget_tests/smart_screen_test.dart --reporter compact`;
  `flutter test test/scripts/android_blackbox_smoke_script_test.dart --reporter compact`.
- Combined focused check:
  `flutter test test/widget_tests/tab_navigator_test.dart test/widget_tests/smart_screen_test.dart test/scripts/android_blackbox_smoke_script_test.dart --concurrency=1 --reporter compact`.
- `flutter analyze lib/screens/smart_screen.dart lib/screens/tab_navigator.dart test/widget_tests/tab_navigator_test.dart test/widget_tests/smart_screen_test.dart test/scripts/android_blackbox_smoke_script_test.dart`
  passed.
- PowerShell parser tokenization for `scripts/run_android_blackbox_smoke.ps1`
  passed.
- `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`
  passed.
- `flutter test --reporter compact` passed all 2059 tests.
- `flutter build apk --debug --target lib/main.dart` passed and built
  `build\app\outputs\flutter-apk\app-debug.apk`; it emitted the known Kotlin
  Gradle Plugin future-migration warning only.
- `git diff --check` passed.
- Reclaimed `danio_android_qa_owner` for `QA-2026-07-04-002`; `adb devices`
  still showed `RFCY8022D5R` as `unauthorized`, and it was not used.
- Phone rerun:
  `.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5554 -InstallApkPath build\app\outputs\flutter-apk\app-debug.apk -IncludeQaDeepLinks -ArtifactDir build\qa-artifacts\android-blackbox-phone-2026-07-04`
  passed with final `Android black-box smoke passed.`
- Tablet rerun:
  `.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5556 -InstallApkPath build\app\outputs\flutter-apk\app-debug.apk -IncludeQaDeepLinks -ArtifactDir build\qa-artifacts\android-blackbox-tablet-2026-07-04`
  passed with final `Android black-box smoke passed.`
- Additional RED/GREEN script regressions were added for current care-clue hint
  copy and lower More hub targets that sit behind the tablet/phone dock
  (`Workshop`, `Preferences`, `About`).
- `adb devices` for `QA-2026-07-04-004` showed `RFCY8022D5R` as
  `unauthorized`, `emulator-5554` as `device`, and `emulator-5556` as `device`;
  the physical phone was not used.
- `.\scripts\run_danio_live_preview.ps1 -DeviceId emulator-5554 -CheckOnly -WaitSeconds 180`
  passed for `danio_api36`, foreground package `com.tiarnanlarkin.danio`.
- `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep`
  passed, including focused tests, dependency validation, custom lint,
  `flutter analyze`, debug APK build, and device visibility. The build emitted
  the known Kotlin Gradle Plugin and Java source/target warnings only.
- `adb -s emulator-5554 install -r build\app\outputs\flutter-apk\app-debug.apk`
  succeeded.
- `adb -s emulator-5554 shell am start -W -a android.intent.action.VIEW -d danio://qa/smart com.tiarnanlarkin.danio`
  opened the Smart tab.
- New after-fix phone evidence:
  `phone-04b-smart-root-after-dock-fix.png`,
  `phone-04b-smart-root-after-dock-fix.xml`, and
  `phone-smart-after-dock-fix-logcat-tail.txt`.
- XML bounds check: Fish & Plant ID bottom `2080`, bottom dock top `2127`,
  clearance `47px`.
- Fresh logcat tail scan found no `FATAL EXCEPTION`, `AndroidRuntime: FATAL`,
  `E/flutter`, `RenderFlex overflowed`, or `ANR in` entries.

## Device And Preview State

- Phone target: `danio_api36`, serial `emulator-5554`.
- Tablet target: `danio_tablet_api36`, serial `emulator-5556`.
- Physical phone `RFCY8022D5R`: still `unauthorized`; do not use without user
  authorization and ADB authorization.
- Device ownership for `QA-2026-07-04-004` is released after evidence capture.
  The dedicated Danio emulators were left running; do not kill or wipe them.

## Blockers

- CL-QA-001 and CL-QA-002 are still in progress, not complete.
- Resolved locally: Smart root Fish & Plant ID now clears the persistent bottom
  dock on the phone recapture, and the smoke helper avoids bottom-dock false
  positives for route assertions, tap centers, and lower More hub scroll
  positions.
- Full `SCREEN_INVENTORY.md` coverage remains pending beyond the current
  19-surface direct QA deep-link set.

## Next Action

Recommended clean checkpoint:

1. Finish CL-QA-001 and CL-QA-002 by extending coverage to every remaining
   `SCREEN_INVENTORY.md` surface with pass/fail/gap notes.
2. Keep using `DEVICE_OWNERSHIP.md` before installs, taps, screenshots, logcat,
   Patrol, Maestro, or live-preview control.
