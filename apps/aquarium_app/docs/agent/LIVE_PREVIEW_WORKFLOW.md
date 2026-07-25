# Danio Live Preview Workflow

Path: `docs/agent/LIVE_PREVIEW_WORKFLOW.md`.

This workflow lets the user watch Danio while Codex builds, without replacing
the local verification gates.

Default rule: live preview is opt-in and never a routine blocking gate. Start
it only when the current slice or user explicitly requests observation and the
writer, shared heavy lane, and device ownership checks all pass. Skipping live
preview needs no exception and does not weaken test or gate evidence.

## Purpose

Live preview is an observation lane. It helps the user see the current app,
interact with the latest debug build, and give feedback on visible behavior.
It does not replace focused tests, `flutter analyze`, debug APK builds,
Patrol, screenshot checks, or the Full gate.

Use the dedicated `danio_api36` phone emulator for Danio phone preview and the
dedicated `danio_tablet_api36` tablet emulator for tablet QA. Do not use
whichever emulator happens to be connected, because other Codex sessions may be
building other apps on the same machine.

Only the coordinator or danio_android_qa_owner may control the live preview
device. Read-only auditors and implementation workers must not run emulator,
ADB, Patrol, Maestro, screenshot, or live-preview commands.

## Device Contract

- Primary phone: keep `danio_api36` as the one day-to-day Pixel-class phone on
  Android 16 / API 36. Its normal persistent preview path uses Quick Boot and
  preserves emulator and app state between sessions.
- Clean journeys: reset or reinstall Danio only after the slice explicitly
  requires a clean app state and device ownership is established. Keep the AVD,
  Android settings, and other emulator data intact. Do not use Device Manager
  `Wipe Data`.
- Recovery: use a one-time snapshot-disabled cold boot only after a normal
  Quick Boot fails and the exact stopped AVD is proven unowned. Do not make
  cold boot the everyday launch mode.
- Compatibility: after the phone-quality work is settled, run one separately
  authorized compatibility sweep at API 24, the current Flutter-managed
  `minSdk`. It is not a day-to-day second emulator. If no suitable device
  already exists, propose its exact configuration and obtain approval before
  installing a system image or creating an AVD.

For a clean journey on an already owned and serial-pinned device, prefer an
app-only reset while retaining the installed APK:

```powershell
adb -s <serial> shell pm clear com.tiarnanlarkin.danio
```

Use an app-only uninstall followed by installation of the already verified APK
only when the journey specifically needs fresh-install behavior:

```powershell
adb -s <serial> uninstall com.tiarnanlarkin.danio
adb -s <serial> install .\build\app\outputs\flutter-apk\app-debug.apk
```

Both commands destroy Danio app data and require an explicit clean-journey
scope. They are intentionally absent from `run_danio_live_preview.ps1`.

## Standard Flow

Run commands from `apps/aquarium_app`.

1. Check repo state:

   ```powershell
   git status --short -uall
   ```

2. Check whether the dedicated Danio device is safe:

   ```powershell
   .\scripts\run_danio_live_preview.ps1 -CheckOnly -AdbCommandTimeoutSeconds 10 -PreflightTimeoutSeconds 30
   ```

   After the script reports the selected serial, pin later checks to it:

   ```powershell
   .\scripts\run_danio_live_preview.ps1 -DeviceId emulator-5554 -CheckOnly -AdbCommandTimeoutSeconds 10 -PreflightTimeoutSeconds 30
   ```

   The shared preflight deadline covers sequential ADB and emulator discovery,
   while `-AdbCommandTimeoutSeconds` still bounds each native command. Each
   command prints `PREFLIGHT_PHASE|<phase>` before it starts. Run the calling
   terminal with a timeout longer than the internal preflight deadline; an
   externally cancelled call is not a pass and requires a fresh process check.

3. If `danio_api36` is not running and no other session owns it, launch its
   normal persistent Quick Boot:

   ```powershell
   .\scripts\run_danio_live_preview.ps1 -LaunchEmulator -CheckOnly -WaitSeconds 120 -AdbCommandTimeoutSeconds 10 -PreflightTimeoutSeconds 150
   ```

   If this Quick Boot fails and process checks prove the AVD is no longer
   running or owned, use the snapshot-disabled recovery fallback:

   ```powershell
   .\scripts\run_danio_live_preview.ps1 -LaunchEmulator -ColdBoot -CheckOnly -WaitSeconds 120 -AdbCommandTimeoutSeconds 10 -PreflightTimeoutSeconds 150
   ```

   `-ColdBoot` only starts a stopped AVD; it does not restart, kill, or wipe a
   running emulator, and it is not the normal preview path. For tablet checks, use
   `-AvdName danio_tablet_api36` only inside an authorized tablet slice.

4. Keep the emulator window visible for user testing.

   For a short opt-in trial that cleans up only the Flutter process tree it
   starts, use a positive duration:

   ```powershell
   .\scripts\run_danio_live_preview.ps1 -DeviceId emulator-5554 `
     -PreviewSeconds 60 `
     -AdbCommandTimeoutSeconds 10 `
     -PreflightTimeoutSeconds 30
   ```

   `BOUNDED_PREVIEW|PASS|ended=deadline|seconds=60` means the viewer reached
   its requested bound and stopped its owned Flutter process tree. It does not
   stop or wipe the emulator.

5. Use hot reload for Dart and UI-only changes while the terminal is running:

   ```text
   r hot reload
   ```

6. Use hot restart for state, provider initialization, routing, or startup
   changes:

   ```text
   R hot restart
   ```

7. Stop and rebuild for native Android, plugin, asset, manifest, Gradle, pub
   dependency, generated-code, or app-id changes.

8. Run focused tests before claiming a reload proved the behavior:

   ```powershell
   flutter test test/widget_tests/<changed_screen>_test.dart --reporter compact
   ```

9. Run one Full gate on the final settled product-code epoch tree:

   ```powershell
   .\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
   ```

10. Capture screenshots only for UI evidence or user review:

    ```powershell
    .\scripts\capture_danio_screen.ps1
    ```

## What The User Sees

The user sees the Android emulator window and can interact with Danio normally.
For small Dart/UI changes, hot reload updates the visible app while preserving
most state. For larger state/startup changes, hot restart restarts the Flutter
app and the user may need to navigate back to the screen being reviewed.

Good feedback from the user includes:

- The screen or action being tested.
- What looked wrong or felt unfinished.
- Whether the issue reproduced after hot reload or hot restart.
- Any exact copy, layout, or interaction problem they noticed.

## Safe Failure Rules

`run_danio_live_preview.ps1` must stop instead of taking over a device when:

- Multiple devices are connected and no selected Danio AVD match is found.
- Sequential discovery exceeds the shared `-PreflightTimeoutSeconds` deadline;
  the error names the last `PREFLIGHT_PHASE|` and cleans up its owned child tree.
- ADB or AVD discovery exceeds `-AdbCommandTimeoutSeconds`.
- The requested `-DeviceId` does not report the requested AVD identity.
- The requested AVD is absent from `emulator -list-avds`.
- The selected device is focused on another non-Danio app package.
- The selected Danio AVD is not running and `-LaunchEmulator` was not supplied.
- `-ColdBoot` is supplied without `-LaunchEmulator`.
- Flutter, ADB, or the Android emulator binary cannot be resolved.
- `flutter run` exits with a non-zero code.
- `-PreviewSeconds` is negative. Zero retains the explicit interactive mode;
  a positive value runs the bounded opt-in trial.

`capture_danio_screen.ps1` must stop instead of writing evidence when:

- No owned Danio device can be resolved.
- Danio is not the foreground app.
- ADB screenshot capture fails.
- The output root resolves outside `docs\qa\screenshots\live-preview`.

## Relationship To QA

Live preview is useful, but it is not a pass/fail gate. The authoritative local
checks remain the focused test for the changed area, the relevant quality-gate
profile, and final Full gate coverage before product commits.

For broader Android evidence, use the existing AndroidPrep, black-box smoke,
Patrol, Maestro, and local screenshot workflows only after device ownership is
clear.
