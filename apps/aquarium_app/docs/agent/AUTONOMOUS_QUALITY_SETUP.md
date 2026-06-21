# Danio Autonomous Quality Setup

This setup gives Codex a repeatable local quality workflow for finishing Danio
without silently depending on paid services, cloud runners, external accounts,
or API keys.

## Active Local Gate

Run from `apps/aquarium_app`:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused
```

Profiles:

- `Focused`: worktree visibility, whitespace diff check, current docs truth
  test, and the local gate contract test.
- `Docs`: `Focused` plus `flutter analyze`.
- `Full`: `Focused`, full `flutter test`, `flutter analyze`, and debug APK
  build.
- `Visual`: `Focused`, the current focused golden tests, and
  `flutter analyze`.
- `AndroidPrep`: `Focused`, `flutter analyze`, debug APK build, and read-only
  `adb devices` visibility. It does not install, wipe, tap, or capture device
  state.

Useful switches:

- `-RequireCleanWorktree`: fail if any dirty file is present.
- `-SkipApkBuild`: skip the debug APK build when a full/device-prep profile is
  being run only for a quick local check.
- `-RunAndroidSmoke`: run the existing local blackbox smoke script. Use only
  when emulator/device ownership is clear.
- `-RunOptionalTools`: run optional local tools when they are installed.
- `-StrictOptionalTools`: fail if an optional tool is missing or fails.

## Default Autonomous Flow

Use this order for normal implementation slices:

1. `git status --short -uall` before editing.
2. Focused failing test for behavior changes.
3. Small implementation slice.
4. `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`.
5. Broaden to `-Profile Docs`, `-Profile Visual`, `-Profile Full`, or
   `-Profile AndroidPrep` based on the files changed.
6. Commit only the intended files.
7. Push after the relevant local gates pass.

## Optional Local Tools

The gate can detect and run these tools when installed locally:

- `osv-scanner --offline --recursive .` for dependency vulnerability checks
  without a network lookup.
- `dcm analyze .` for stricter Dart/Flutter quality rules.
- `cspell .` for spelling checks across app copy and docs.
- `vale docs` for prose linting of documentation.

These tools are optional. Missing tools must not block ordinary product work
unless `-StrictOptionalTools` is explicitly supplied.

## Account-Backed Upgrade Lane

No account-backed service is configured by this setup pass. If the user later
approves a paid or external quality layer, keep it separate from the local core
and do not commit secrets.

Recommended escalation order:

- AI PR review: CodeRabbit or Qodo after changes are in pull requests.
- Independent mobile CI: Codemagic or an equivalent mobile CI runner after the
  user explicitly approves hosted builds.
- Device matrix testing: Firebase Test Lab, BrowserStack, or a similar service
  only after the user approves account setup and upload behavior.
- Release telemetry: Crashlytics or Sentry only after the local app is polished
  and the user explicitly approves runtime reporting.

These services can improve review coverage, but they do not replace the local
Flutter gates. Danio must remain useful and testable locally.

## Product Rules Protected By The Gate

- Smart Hub must work locally first.
- Optional AI must never make the app feel broken without keys.
- Do not add fake premium, social, cloud, leaderboard, or subscription
  behavior.
- Do not add hidden network behavior.
- Care guidance must remain educational and not imply veterinary/professional
  replacement.

## Research References Checked

Checked on 2026-06-21:

- Flutter integration testing:
  https://docs.flutter.dev/testing/integration-tests
- Flutter widget and golden-test APIs:
  https://docs.flutter.dev/cookbook/testing/widget/introduction
  and https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html
- Flutter Android build guidance:
  https://docs.flutter.dev/deployment/android
- Patrol native automation:
  https://patrol.leancode.co/
- Maestro local CLI:
  https://docs.maestro.dev/maestro-cli
- OSV-Scanner:
  https://google.github.io/osv-scanner/
- DCM:
  https://dcm.dev/
- CodeRabbit:
  https://docs.coderabbit.ai/guides/code-review-overview
- Qodo code review:
  https://docs.qodo.ai/code-review
- Codemagic Flutter builds:
  https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/
