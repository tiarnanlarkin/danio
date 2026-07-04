# Danio Active Handoff

Status: Active current-session handoff
Last updated: 2026-07-04 after phone/tablet black-box smoke reruns passed

## Branch

- Branch: `qa/production-tool-audit-2026-05-25`
- Current tested commit: `20f14eee docs: unblock android device ownership qa`
  plus uncommitted Smart/smoke-helper follow-up changes.
- Prior pushed handoff reference from user: `ce4a72b1 docs: add session freshness handoff rule`

## Current Slice

- Slice: CL-QA-001/002 follow-up for Smart bottom-dock overlap and black-box
  smoke helper hardening.
- Scope completed: after the partial phone/tablet map pass, fixed the Smart
  Fish & Plant ID card overlap locally, made the smoke helper avoid bottom-dock
  false positives, updated lower More hub route swipes for tablet geometry, and
  verified with local Flutter/script/build/device gates.
- Product behavior changes: Smart under the persistent bottom dock now nudges
  the locked Fish & Plant ID card above the dock on phone-sized shells.
- New accounts/tools/plugins/MCP/hooks/automations: none.
- Live preview/device requirement: completed through `DEVICE_OWNERSHIP.md` and
  `LIVE_PREVIEW_WORKFLOW.md`. No `flutter run` terminal is attached.

## Dirty Files To Preserve

- Expected current slice files:
  - `docs/qa/whole-app-phone-map-2026-07-04.md`
  - `docs/qa/whole-app-tablet-map-2026-07-04.md`
  - `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`
  - `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`
  - `docs/agent/DEVICE_OWNERSHIP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SCREEN_INVENTORY.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/superpowers/plans/2026-07-04-cl-qa-001-002-whole-app-maps.md`
  - `lib/screens/smart_screen.dart`
  - `lib/screens/tab_navigator.dart`
  - `scripts/run_android_blackbox_smoke.ps1`
  - `test/scripts/android_blackbox_smoke_script_test.dart`
  - `test/widget_tests/tab_navigator_test.dart`

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

## Device And Preview State

- Phone target: `danio_api36`, serial `emulator-5554`.
- Tablet target: `danio_tablet_api36`, serial `emulator-5556`.
- Physical phone `RFCY8022D5R`: still `unauthorized`; do not use without user
  authorization and ADB authorization.
- Device ownership for `QA-2026-07-04-002` is released after evidence capture.
  The dedicated Danio emulators were left running; do not kill or wipe them.

## Blockers

- CL-QA-001 and CL-QA-002 are still in progress, not complete.
- Resolved locally: Smart root lower optional-AI cards are nudged above the
  persistent bottom dock, and the smoke helper now avoids bottom-dock false
  positives for route assertions, tap centers, and lower More hub scroll
  positions.
- Full `SCREEN_INVENTORY.md` coverage remains pending beyond the current
  19-surface direct QA deep-link set.

## Next Action

Recommended clean checkpoint:

1. Finish CL-QA-001 and CL-QA-002 by extending coverage to every remaining
   `SCREEN_INVENTORY.md` surface with pass/fail/gap notes.
2. Recapture Smart root on phone after the dock fix as part of the full phone
   inventory closeout.
3. Keep using `DEVICE_OWNERSHIP.md` before installs, taps, screenshots, logcat,
   Patrol, Maestro, or live-preview control.
