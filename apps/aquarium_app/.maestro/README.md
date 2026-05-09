# Maestro Flows - Danio Aquarium App

Automated black-box Android UI flows for `com.tiarnanlarkin.danio`.

These flows are for user-like checks on an installed APK. They complement,
not replace, Flutter unit/widget/integration tests.

## Prerequisites

1. Start an Android emulator or connect a device.
2. Install the app build you want to test.
3. Put Maestro on `PATH`.

On this Windows workstation the local Maestro install is:

```powershell
$env:Path="$env:USERPROFILE\maestro\maestro\bin;$env:Path"
$env:MAESTRO_CLI_NO_ANALYTICS="true"
$env:MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED="true"
```

Verify:

```powershell
adb devices
maestro --version
```

## Current App Shell

Bottom navigation:

| Index | Label | Screen |
| --- | --- | --- |
| 0 | Learn | Learning paths and stories |
| 1 | Practice | Spaced repetition and practice modes |
| 2 | Tank | Tank room, progress, tanks, today, and tank tools |
| 3 | Smart | AI and offline smart tools |
| 4 | More | Profile, shop, achievements, workshop, settings, backup |

First launch starts with the GDPR/COPPA consent gate. After consent, the
current quick path for black-box smoke testing is "Skip setup, I'll explore
first", which lands in the main app shell with seed/demo state.

## Main Flows

Run the deterministic release-smoke batch one flow at a time. The runner
clears app state before each flow unless `-KeepState` is passed:

```powershell
.\scripts\run_maestro_smoke.ps1 -DeviceId emulator-5554
```

Individual flows are still useful while debugging a single journey:

```powershell
maestro test .maestro\smoke-test.yaml
maestro test .maestro\tab-navigation.yaml
maestro test .maestro\settings.yaml
maestro test .maestro\calculators.yaml
maestro test .maestro\achievements.yaml
```

Avoid using folder-wide Maestro execution as the release gate. It is fine for
local exploration, but the explicit runner above gives each deterministic flow
a fresh app state and a stable order.

```powershell
maestro test .maestro
```

## Flutter Integration Smoke

Use `flutter drive` for the current device smoke. Do not use the old
`flutter test` device invocation for this release check; it has drifted from
the working driver entrypoint.

```powershell
flutter drive -d emulator-5554 --driver=test_driver\integration_test.dart --target=integration_test\smoke_test_v2.dart
```

Wrapper:

```powershell
.\scripts\run_integration_smoke.ps1 -DeviceId emulator-5554
```

## QA Ladder

Use this order for release confidence:

1. `flutter analyze --no-pub`
2. `flutter test`
3. Android debug APK build
4. Android release APK/AAB build
5. Flutter integration smoke with `flutter drive`
6. Fresh-install black-box Android smoke with `scripts\run_android_blackbox_smoke.ps1`
7. Deterministic Maestro smoke with `scripts\run_maestro_smoke.ps1`
8. Targeted Maestro journeys for Learn, Practice, Tank, Smart, More
9. Logcat scan for `FATAL EXCEPTION`, `AndroidRuntime`, `ANR in`, and known plugin errors

## Notes

- Prefer visible text and accessibility labels over coordinates.
- Coordinates are only used where Flutter semantics do not expose a stable
  target, such as the current consent checkboxes.
- Debug-only QA deep links can be checked by running
  `scripts\run_android_blackbox_smoke.ps1 -IncludeQaDeepLinks` against a debug
  build. Release builds do not register `danio://qa/...` routes.
- Do not commit generated Maestro binaries, `patrol_test/`, screenshots, or
  run output.
