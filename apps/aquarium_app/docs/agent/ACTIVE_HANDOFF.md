# Danio Active Handoff

Status: Active current-session handoff
Last updated: 2026-07-04 after QA-006 standalone route capture

## Branch

- Branch: `qa/production-tool-audit-2026-05-25`
- Latest completed slice: `QA-2026-07-04-006` standalone debug QA routes and
  phone/tablet route-batch evidence.
- Prior pushed checkpoint: `969ac228 docs: account for whole-app qa inventory gaps`.
- Current uncommitted slice: none expected after the QA-006 checkpoint is
  committed; verify with `git status --short -uall`.
- Prior pushed handoff reference from user:
  `ce4a72b1 docs: add session freshness handoff rule`.

## Current Slice

- Slice: QA-2026-07-04-006 standalone route capture for CL-QA-001/002 gaps.
- Scope completed: added 39 debug-only `danio://qa/...` routes for
  standalone normal-user screens that do not require seeded tank IDs, captured
  paired phone and tablet screenshot/XML evidence for those routes, and updated
  the whole-app maps.
- Product behavior changes: debug-only QA deep-link coverage expanded in
  `lib/services/debug_deep_link_service.dart`; release builds remain gated by
  `kDebugMode`.
- Inventory state: both CL-QA maps now account for all 96
  `SCREEN_INVENTORY.md` rows with 56 current passes and 40 explicit gaps per
  form factor.
- New accounts/tools/plugins/MCP/hooks/automations: none.
- Live preview/device requirement: device ownership for QA-006 was released.
  No `flutter run` terminal is attached.

## Dirty Files To Preserve

Expected QA-006 files before commit:

- `lib/services/debug_deep_link_service.dart`
- `test/services/debug_deep_link_service_test.dart`
- `docs/qa/whole-app-phone-map-2026-07-04.md`
- `docs/qa/whole-app-tablet-map-2026-07-04.md`
- `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-20-*`
  through `phone-58-*`, plus `phone-route-batch-qa-006-*`
- `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-20-*`
  through `tablet-58-*`, plus `tablet-route-batch-qa-006-*`
- `docs/agent/ACTIVE_HANDOFF.md`
- `docs/agent/DEVICE_OWNERSHIP.md`
- `docs/agent/FINISH_MAP.md`
- `docs/agent/SCREEN_INVENTORY.md`
- `docs/agent/SLICE_LOG.md`
- `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

## Last Checks

- RED repro for the route guard:
  `flutter test test/services/debug_deep_link_service_test.dart --reporter compact`
  failed before the new route cases were added, starting at missing
  `danio://qa/backup`.
- GREEN route guard:
  `flutter test test/services/debug_deep_link_service_test.dart --reporter compact`
  passed.
- Focused analyzer:
  `flutter analyze lib/services/debug_deep_link_service.dart test/services/debug_deep_link_service_test.dart`
  passed.
- Debug APK build:
  `flutter build apk --debug --target lib/main.dart` passed and built
  `build\app\outputs\flutter-apk\app-debug.apk`; known Kotlin/Java future
  warnings only.
- `adb devices` showed `RFCY8022D5R` as `unauthorized`; it was not used.
  `emulator-5554` and `emulator-5556` were available as devices.
- Phone CheckOnly:
  `.\scripts\run_danio_live_preview.ps1 -DeviceId emulator-5554 -CheckOnly -WaitSeconds 180`
  passed for `danio_api36`.
- Tablet CheckOnly:
  `.\scripts\run_danio_live_preview.ps1 -AvdName danio_tablet_api36 -DeviceId emulator-5556 -CheckOnly -WaitSeconds 180`
  passed for `danio_tablet_api36`.
- Debug APK installs succeeded on `emulator-5554` and `emulator-5556`.
- Phone route batch captured 39 paired PNG/XML states under
  `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`; every new
  XML contains `<hierarchy>`.
- Tablet route batch captured 39 paired PNG/XML states under
  `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`; every new
  XML contains `<hierarchy>`.
- Spot visual inspection checked `phone-31-aquarium-intelligence.png` and
  `tablet-45-quick-start-guide.png`.
- Fresh logcat tail scan found no `FATAL EXCEPTION`,
  `AndroidRuntime: FATAL`, `E/flutter`, `RenderFlex overflowed`, or `ANR in`
  entries in the QA-006 phone/tablet tails.
- Final checkpoint checks after the handoff rewrite passed:
  `git diff --check`;
  `flutter test test/services/debug_deep_link_service_test.dart --reporter compact`;
  `flutter analyze lib/services/debug_deep_link_service.dart test/services/debug_deep_link_service_test.dart`;
  `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`;
  route-batch evidence count/XML hierarchy validation; and
  `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`.

## Device And Preview State

- Phone target: `danio_api36`, serial `emulator-5554`.
- Tablet target: `danio_tablet_api36`, serial `emulator-5556`.
- Physical phone `RFCY8022D5R`: still `unauthorized`; do not use without user
  authorization and ADB authorization.
- Device ownership for `QA-2026-07-04-006` was released after evidence capture.
  The dedicated Danio emulators may still be running; do not kill or wipe them.

## Blockers

- CL-QA-001 and CL-QA-002 are still in progress as current visual audits.
- Completed locally: every `SCREEN_INVENTORY.md` row has phone/tablet `Pass`
  or `Gap` accounting in the map docs.
- Remaining gap: 40 phone rows and 40 tablet rows still need direct current
  capture or route-smoke evidence before the audits can be treated as complete
  current visual evidence.
- The remaining gaps are mainly tank/detail/onboarding/story/data-dependent
  surfaces plus cycling assistant, debug menu, and debug QA seeds.

## Next Action

Recommended next slice:

1. Capture or route-smoke the 40 phone and 40 tablet `Gap` rows, prioritizing
   tank/detail/onboarding/story/data-dependent normal-user surfaces.
2. Add targeted seed/deep-link support only where it is honest and does not
   create fake provider readiness.
3. Keep using `DEVICE_OWNERSHIP.md` before installs, taps, screenshots,
   logcat, Patrol, Maestro, or live-preview control.
