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

```powershell
maestro test .maestro\smoke-test.yaml
maestro test .maestro\tab-navigation.yaml
maestro test .maestro\settings.yaml
maestro test .maestro\calculators.yaml
maestro test .maestro\achievements.yaml
```

Run every current flow:

```powershell
maestro test .maestro
```

## QA Ladder

Use this order for release confidence:

1. `flutter analyze --no-pub`
2. `flutter test`
3. Android debug APK build
4. Android release APK/AAB build
5. Fresh-install Maestro smoke on Android
6. Targeted Maestro journeys for Learn, Practice, Tank, Smart, More
7. Logcat scan for `FATAL EXCEPTION`, `AndroidRuntime`, `ANR in`, and known plugin errors

## Notes

- Prefer visible text and accessibility labels over coordinates.
- Coordinates are only used where Flutter semantics do not expose a stable
  target, such as the current consent checkboxes.
- Do not commit generated Maestro binaries, `patrol_test/`, screenshots, or
  run output.
