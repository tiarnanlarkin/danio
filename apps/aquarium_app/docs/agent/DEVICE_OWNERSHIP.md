# Danio Device Ownership

Status: Active coordination protocol
Created: 2026-06-24

## Purpose

Multiple Codex sessions may run on this machine. This file defines how Danio
sessions avoid fighting over emulators, ADB, Patrol, live preview, screenshots,
and Firebase Test Lab evidence.

Only the coordinator or `danio_android_qa_owner` may control Android devices.
Other agents must stop at compile, test, analyze, or `AndroidPrep` checks.

## Standard Devices

| Device | Intended use | Current durable owner | Notes |
| --- | --- | --- | --- |
| `danio_api36` | Phone live preview and phone Android QA | Unclaimed after `QA-2026-07-04-002` | Last verified as `emulator-5554`; use explicit device serial after checking `adb devices`. |
| `danio_tablet_api36` | Tablet layout QA and screenshots | Unclaimed after `QA-2026-07-04-002` | Last verified as `emulator-5556`; use explicit device serial after checking `adb devices`. |
| Physical phone `RFCY8022D5R` | Do not use unless user authorizes and ADB is authorized | Unclaimed | Observed as `unauthorized` on 2026-07-04; not used. |

This file is a durable coordination record, not a real-time lock. At the start
of each Android slice, the active session must announce ownership in the thread
and record durable evidence here only when the device interaction becomes part
of committed QA evidence.

## Ownership Claim Checklist

Before any install, tap, screenshot, Patrol run, logcat capture, screenrecord,
Firebase Test Lab upload, or live-preview control:

```powershell
.\scripts\run_danio_live_preview.ps1 -CheckOnly -AdbCommandTimeoutSeconds 10
.\scripts\run_danio_live_preview.ps1 -DeviceId emulator-5554 -CheckOnly -AdbCommandTimeoutSeconds 10
```

The first command starts or confirms ADB through a bounded client, selects the
named AVD, and reports its serial and foreground package. Pin the reported
serial with `-DeviceId` for the second check and every later device command.
If Quick Boot has failed, first prove no emulator process or other session owns
the stopped AVD, then use `-LaunchEmulator -ColdBoot -CheckOnly`; this starts
without loading or saving snapshots and does not restart or wipe a running AVD.

The owner must know:

- selected device serial;
- AVD name, when using an emulator;
- current foreground package;
- intended APK/build;
- intended flow or evidence folder;
- whether another Codex session is already using the device.

If any item is unclear, do not interact with the device. Use local tests,
`flutter analyze`, `flutter build apk --debug --target lib/main.dart`, or
`AndroidPrep` instead.

## Safe Actions Without Ownership

These are allowed without claiming a device:

```powershell
flutter test
flutter analyze
flutter build apk --debug --target lib/main.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
```

`AndroidPrep` is safe because it is read-only for attached devices and does not
install, wipe, tap, or capture device state.

## Forbidden Actions Without Ownership

- `flutter run -d <device>`
- `flutter install`
- `adb install`
- `adb shell input ...`
- `adb shell screencap ...`
- `adb logcat` capture for committed evidence
- `patrol test`
- `maestro test`
- `firebase test android run`
- emulator kill, wipe, restart, or data clear
- app uninstall or `pm clear`

## Ownership Log

Add a row when a committed slice uses Android evidence:

| Date | Owner/session | Device serial | AVD/device | Slice | Actions | Evidence path | Released |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5554` | `danio_api36` | `QA-2026-07-04-001` | CheckOnly launch, debug APK install, app launch, screenshot, focus dump, logcat | `docs/qa/screenshots/live-preview/2026-07-04/` | Yes |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5556` | `danio_tablet_api36` | `QA-2026-07-04-001` | CheckOnly launch, debug APK install, app launch, screenshot, focus dump, logcat | `docs/qa/screenshots/live-preview/2026-07-04/` | Yes |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5554` | `danio_api36` | `QA-2026-07-04-002` | CheckOnly, AndroidPrep, debug APK install/launch, black-box smoke attempt, 19-surface screenshot/XML capture, logcat tail, passing black-box smoke rerun | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/` | Yes |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5556` | `danio_tablet_api36` | `QA-2026-07-04-002` | CheckOnly, AndroidPrep, debug APK install/launch, black-box smoke attempt, 19-surface screenshot/XML capture, logcat tail, passing black-box smoke rerun | `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/` | Yes |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5554` | `danio_api36` | `QA-2026-07-04-004` | CheckOnly, AndroidPrep, debug APK install, Smart QA deep link, screenshot/XML recapture, XML dock-clearance check, logcat tail scan | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/` | Yes |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5554` | `danio_api36` | `QA-2026-07-04-006` | CheckOnly, debug APK install, 39 standalone QA deep-link screenshot/XML captures, XML hierarchy validation, logcat tail scan | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/` | Yes |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5556` | `danio_tablet_api36` | `QA-2026-07-04-006` | CheckOnly, debug APK install, 39 standalone QA deep-link screenshot/XML captures, XML hierarchy validation, logcat tail scan | `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/` | Yes |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5554` | `danio_api36` | `QA-2026-07-04-007` | CheckOnly, debug APK install, 24 seeded QA deep-link screenshot/XML captures, route-index/XML hierarchy/screen-anchor validation, logcat tail and error-boundary scans | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/` | Yes |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5556` | `danio_tablet_api36` | `QA-2026-07-04-007` | CheckOnly, debug APK install, 24 seeded QA deep-link screenshot/XML captures, route-index/XML hierarchy/screen-anchor validation, logcat tail and error-boundary scans | `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/` | Yes |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5554` | `danio_api36` | `QA-2026-07-04-008` | CheckOnly, debug APK install, Danio-only app-data reset, first-run/onboarding walkthrough, age-blocked branch capture, Debug QA Seeds capture, XML hierarchy/logcat/error-boundary scans | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/` | Yes |
| 2026-07-04 | `danio_android_qa_owner` current Codex session | `emulator-5556` | `danio_tablet_api36` | `QA-2026-07-04-008` | CheckOnly, debug APK install, Danio-only app-data reset, first-run/onboarding walkthrough, age-blocked branch capture, Debug QA Seeds capture, XML hierarchy/logcat/error-boundary scans | `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/` | Yes |
| 2026-07-05 | Coordinator current Codex session | `emulator-5556` | `danio_api36` | `DS-2026-07-05-023` | CheckOnly, LaunchEmulator with extended wait, debug APK install/launch through live-preview helper, foreground and pid checks | `docs/agent/ACTIVE_HANDOFF.md` | Yes; app left visible |
| 2026-07-11 | Coordinator current Codex session | `emulator-5554` | `danio_api36` | `QA-2026-07-11-001` | Dedicated phone capture, Danio-only app-data reset, onboarding/state walkthrough, 98 numbered screenshots plus 2 live variants, contact-sheet review, Figma atlas upload | Figma file `JnSwJlWnisxF6xtiwK6nFc`; temporary local capture manifest outside Git | Yes; emulator left running |
| 2026-07-23 | Coordinator current Codex session | `emulator-5554` | `danio_api36` | `DR-2026-07-23-072` | Ownership/process preflight before every command, CheckOnly, debug APK build/install/launch, focus check, screenshot and UI-hierarchy capture | `docs/qa/screenshots/2026-07-23/dcl-a11y-001-tank-daily-care/` | Yes; emulator left running |
| 2026-07-24 | Coordinator current Codex session | `emulator-5554` | `danio_api36` | `DR-2026-07-24-073` | Bounded ADB/process preflight, snapshot-disabled cold start, serial-pinned AVD and foreground verification; no install, launch, tap, wipe, or capture | `docs/agent/LIVE_PREVIEW_WORKFLOW.md` | Yes; emulator left running |

## Release Rule

After Android evidence is captured:

1. Stop any live-preview terminal with `q` if it was started for the slice.
2. Leave the emulator running only if it was already dedicated to Danio.
3. Do not kill or wipe the device.
4. State in the final slice summary whether device ownership was released.
