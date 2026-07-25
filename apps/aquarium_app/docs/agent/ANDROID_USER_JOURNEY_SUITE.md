# Compact Local Android User-Journey Suite

Status: opt-in local workflow

This suite provides one small, repeatable Android confidence pass using the
repository-owned Danio preflight and black-box smoke runner. It does not replace
focused tests, Full, AndroidPrep, visual review, or release evidence.

## Covered journeys

1. `first-run-and-shell`: consent, skip setup, and all five main tabs.
2. `practice-and-tank`: practice entry, Tank toolbox, and tank routes.
3. `learn-smart-and-more`: learning, Smart, Workshop, preferences, and backup.

The wrapper enables the existing debug QA deep-link checks for deterministic
Create Tank, lesson/quiz, and practice-session states. Platform handoffs remain
excluded because they depend on Android resolver or share UI.

## Inspect without a device

From `apps/aquarium_app`:

```powershell
.\scripts\run_android_user_journeys.ps1 -ListOnly
```

`-ListOnly` prints the three journeys and performs no ADB, emulator, Flutter,
install, tap, capture, or app-state action.

## Run with ownership

Before execution, the repository writer must read `DEVICE_OWNERSHIP.md`, claim
the shared heavy lane with `ClaimHeavy`, establish exclusive Danio device
ownership, and pin the verified serial. Then run:

```powershell
.\scripts\run_android_user_journeys.ps1 -DeviceId emulator-5554
```

To install a specific locally built debug APK first:

```powershell
.\scripts\run_android_user_journeys.ps1 -DeviceId emulator-5554 `
  -InstallApkPath build\app\outputs\flutter-apk\app-debug.apk `
  -CleanInstall
```

The wrapper first runs the bounded `run_danio_live_preview.ps1 -CheckOnly`
identity and foreground-safety preflight for `danio_api36`. It then runs
`run_android_blackbox_smoke.ps1 -IncludeQaDeepLinks`, pinned to the same serial.
Artifacts stay under `build/qa-artifacts/android-user-journeys` by default.

Release the heavy lane and device ownership after the process stops. A failed
preflight, missing serial, or unclear owner is a stop condition; do not bypass
it or substitute another device.
