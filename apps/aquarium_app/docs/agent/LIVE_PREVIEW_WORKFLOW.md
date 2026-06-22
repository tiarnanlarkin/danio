# Danio Live Preview Workflow

Path: `docs/agent/LIVE_PREVIEW_WORKFLOW.md`.

This workflow lets the user watch Danio while Codex builds, without replacing
the local verification gates.

## Purpose

Live preview is an observation lane. It helps the user see the current app,
interact with the latest debug build, and give feedback on visible behavior.
It does not replace focused tests, `flutter analyze`, debug APK builds,
Patrol, screenshot checks, or the Full gate.

Use the dedicated `danio_api36` emulator for Danio. Do not use whichever
emulator happens to be connected, because other Codex sessions may be building
other apps on the same machine.

Only the coordinator or danio_android_qa_owner may control the live preview
device. Read-only auditors and implementation workers must not run emulator,
ADB, Patrol, Maestro, screenshot, or live-preview commands.

## Standard Flow

Run commands from `apps/aquarium_app`.

1. Check repo state:

   ```powershell
   git status --short -uall
   ```

2. Check whether the dedicated Danio device is safe:

   ```powershell
   .\scripts\run_danio_live_preview.ps1 -CheckOnly
   ```

3. If `danio_api36` is not running and no other session owns it, launch it:

   ```powershell
   .\scripts\run_danio_live_preview.ps1 -LaunchEmulator
   ```

4. Keep the emulator window visible for user testing.

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

9. Run the Full gate before committing product behavior:

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

- Multiple devices are connected and no `danio_api36` match is found.
- The selected device is focused on another non-Danio app package.
- `danio_api36` is not running and `-LaunchEmulator` was not supplied.
- Flutter, ADB, or the Android emulator binary cannot be resolved.
- `flutter run` exits with a non-zero code.

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
