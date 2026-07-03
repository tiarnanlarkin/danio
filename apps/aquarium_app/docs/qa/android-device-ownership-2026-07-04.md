# Android Device Ownership QA - 2026-07-04

Status: Ownership unblock evidence
Slice: `QA-2026-07-04-001`
Branch: `qa/production-tool-audit-2026-05-25`
App build commit: `eedf2719 fix: preserve reminders on delete save failure`
Evidence commit: current commit

## Scope

Narrow QA unblock for stable Android device ownership and first phone/tablet
launch evidence. This is not the full `CL-QA-001` phone whole-app map or
`CL-QA-002` tablet whole-app map. No flow navigation beyond install, launch,
foreground validation, and screenshot capture was performed.

## Device State

| Target | Serial | Result |
| --- | --- | --- |
| Phone AVD `danio_api36` | `emulator-5554` | `-LaunchEmulator -CheckOnly` passed, foreground was safe, debug APK installed, Danio launched. |
| Tablet AVD `danio_tablet_api36` | `emulator-5556` | `-LaunchEmulator -CheckOnly` passed, foreground was safe, debug APK installed, Danio launched. |
| Physical phone `RFCY8022D5R` | n/a | Still `unauthorized`; not used. |

## Checks

- `adb devices` initially showed only `RFCY8022D5R unauthorized`.
- `.\scripts\run_danio_live_preview.ps1 -LaunchEmulator -CheckOnly -WaitSeconds 180` passed for `danio_api36`.
- `.\scripts\run_danio_live_preview.ps1 -AvdName danio_tablet_api36 -LaunchEmulator -CheckOnly -WaitSeconds 180` passed for `danio_tablet_api36`.
- `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep` passed, including focused tests, dependency validation, custom lint, `flutter analyze`, debug APK build, and read-only device visibility.
- `adb install -r build\app\outputs\flutter-apk\app-debug.apk` succeeded on both owned AVDs.
- `adb shell am start -n com.tiarnanlarkin.danio/.MainActivity` launched Danio on both owned AVDs.
- Captured logcats showed no `FATAL EXCEPTION`, `AndroidRuntime`, `E/flutter`, `RenderFlex overflowed`, or `ANR` entries for this launch evidence.

## Evidence

Evidence folder:
`docs/qa/screenshots/live-preview/2026-07-04/`

| Target | Screenshot | Focus dump | Logcat |
| --- | --- | --- | --- |
| Phone `danio_api36` | `qa-device-ownership-phone-tank-launch.png` | `qa-device-ownership-phone-focus.txt` | `qa-device-ownership-phone-logcat.txt` |
| Tablet `danio_tablet_api36` | `qa-device-ownership-tablet-tank-launch.png` | `qa-device-ownership-tablet-focus.txt` | `qa-device-ownership-tablet-logcat.txt` |

## Result

Android ownership and transport are no longer the blocker for the next
whole-app evidence pass. The dedicated phone and tablet AVDs can be selected
explicitly, pass the repo safety checks, install the current debug APK, launch
Danio, and write local screenshot/log evidence.

## Follow-Up

Run `CL-QA-001` phone whole-app map and `CL-QA-002` tablet whole-app map from
the owned dedicated AVDs. Keep using explicit serials and do not use physical
phone `RFCY8022D5R` unless the user authorizes it and ADB authorization is
confirmed.
