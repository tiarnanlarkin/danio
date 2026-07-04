# Danio Active Handoff

Status: Active current-session handoff
Last updated: 2026-07-04 after QA-007 seeded route capture

## Branch

- Branch: `qa/production-tool-audit-2026-05-25`
- Latest completed slice: `QA-2026-07-04-007` seeded debug QA routes,
  livestock skeleton Hero regression fix, and phone/tablet route-batch
  evidence.
- Prior pushed checkpoint: `969ac228 docs: account for whole-app qa inventory gaps`.
- Current uncommitted slice: QA-007 code, tests, screenshot/XML evidence, and
  docs are in the worktree; verify with `git status --short -uall` before
  committing or starting a new slice.
- Prior pushed handoff reference from user:
  `ce4a72b1 docs: add session freshness handoff rule`.

## Current Slice

- Slice: QA-2026-07-04-007 seeded route capture for CL-QA-001/002 gaps.
- Scope completed: added debug-only seeded `danio://qa/...` routes for 24
  tank/detail/care/learning/story/cycling surfaces, captured paired phone and
  tablet screenshot/XML evidence for those routes, fixed a livestock loading
  skeleton duplicate-Hero regression found during Android validation, and
  updated the whole-app maps.
- Product behavior changes: debug-only QA deep-link coverage expanded in
  `lib/services/debug_deep_link_service.dart`; release builds remain gated by
  `kDebugMode`. `SkeletonPlaceholders.livestockList` now gives generated
  placeholder livestock unique IDs so loading rows do not register duplicate
  Hero tags.
- Inventory state: both CL-QA maps now account for all 96
  `SCREEN_INVENTORY.md` rows with 80 current passes and 16 explicit gaps per
  form factor.
- New accounts/tools/plugins/MCP/hooks/automations: none.
- Live preview/device requirement: device ownership for QA-007 was released.
  No `flutter run` terminal is attached.

## Dirty Files To Preserve

Expected QA-007 files before commit:

- `lib/services/debug_deep_link_service.dart`
- `lib/utils/skeleton_placeholders.dart`
- `test/services/debug_deep_link_service_test.dart`
- `test/widget_tests/livestock_screen_test.dart`
- `docs/qa/whole-app-phone-map-2026-07-04.md`
- `docs/qa/whole-app-tablet-map-2026-07-04.md`
- `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-59-*`
  through `phone-82-*`, plus `phone-route-batch-qa-007-*`
- `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/tablet-59-*`
  through `tablet-82-*`, plus `tablet-route-batch-qa-007-*`
- `docs/agent/ACTIVE_HANDOFF.md`
- `docs/agent/DEVICE_OWNERSHIP.md`
- `docs/agent/FINISH_MAP.md`
- `docs/agent/SCREEN_INVENTORY.md`
- `docs/agent/SLICE_LOG.md`
- `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

## Last Checks

- Route guard:
  `flutter test test/services/debug_deep_link_service_test.dart --reporter compact`
  passed after adding the seeded route cases.
- Focused analyzer:
  `flutter analyze lib/services/debug_deep_link_service.dart lib/utils/skeleton_placeholders.dart test/services/debug_deep_link_service_test.dart test/widget_tests/livestock_screen_test.dart`
  passed.
- Livestock duplicate-Hero RED:
  `flutter test test/widget_tests/livestock_screen_test.dart --name "loading skeleton does not register duplicate hero tags" --reporter compact`
  failed before the skeleton placeholder fix with the duplicate `Hero` tag
  assertion.
- Livestock duplicate-Hero GREEN:
  `flutter test test/widget_tests/livestock_screen_test.dart --name "loading skeleton does not register duplicate hero tags" --reporter compact`
  passed after the fix.
- Full livestock widget file:
  `flutter test test/widget_tests/livestock_screen_test.dart --reporter compact`
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
- Debug APK installs succeeded on `emulator-5554` and `emulator-5556` after
  the livestock fix.
- Phone route batch captured 24 fixed-build paired PNG/XML states under
  `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`; every route
  is listed in the QA-007 index and every XML contains `<hierarchy>` plus a
  route-specific screen anchor.
- Tablet route batch captured 24 fixed-build paired PNG/XML states under
  `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`; every route
  is listed in the QA-007 index and every XML contains `<hierarchy>` plus a
  route-specific screen anchor.
- Spot visual inspection checked `phone-72-livestock.png` and
  `tablet-82-cycling-assistant.png`.
- Fresh logcat tail and XML scans found no `FATAL EXCEPTION`,
  `AndroidRuntime: FATAL`, `E/flutter`, `RenderFlex overflowed`, `ANR in`,
  app error-boundary text, duplicate-Hero text, or
  `livestock-skeleton-livestock` entries in the QA-007 phone/tablet evidence.
- Final checkpoint after this handoff rewrite passed: `git diff --check`;
  `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`;
  QA-007 evidence validation; `flutter test test/services/debug_deep_link_service_test.dart test/widget_tests/livestock_screen_test.dart --reporter compact`;
  targeted `flutter analyze`; and
  `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`.

## Device And Preview State

- Phone target: `danio_api36`, serial `emulator-5554`.
- Tablet target: `danio_tablet_api36`, serial `emulator-5556`.
- Physical phone `RFCY8022D5R`: still `unauthorized`; do not use without user
  authorization and ADB authorization.
- Device ownership for `QA-2026-07-04-007` was released after evidence capture.
  The dedicated Danio emulators may still be running; do not kill or wipe them.

## Blockers

- CL-QA-001 and CL-QA-002 are still in progress as current visual audits.
- Completed locally: every `SCREEN_INVENTORY.md` row has phone/tablet `Pass`
  or `Gap` accounting in the map docs.
- Remaining gap: 16 phone rows and 16 tablet rows still need direct current
  capture or route-smoke evidence before the audits can be treated as complete
  current visual evidence.
- The remaining gaps are onboarding/first-run states plus Debug QA Seeds.

## Next Action

Recommended next slice:

1. Capture or route-smoke the 16 phone and 16 tablet `Gap` rows, prioritizing
   onboarding/first-run states.
2. Capture Debug QA Seeds only as debug evidence, not normal-user product
   evidence.
3. Keep using `DEVICE_OWNERSHIP.md` before installs, taps, screenshots,
   logcat, Patrol, Maestro, or live-preview control.
