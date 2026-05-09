# QA Automation Hardening Notes - 2026-05-09

Scope: Worker D automation slice for DA-002 and DA-003. The remediation tracker
at `docs/qa/final-polish-remediation-2026-05-09.md` is coordinator-owned and
was not edited.

## Deterministic Commands

Flutter integration smoke:

```powershell
flutter drive -d emulator-5554 --driver=test_driver\integration_test.dart --target=integration_test\smoke_test_v2.dart
```

Wrapper:

```powershell
.\scripts\run_integration_smoke.ps1 -DeviceId emulator-5554
```

The wrapper intentionally rebuilds a standard debug APK after `flutter drive`.
Without that rebuild, `build\app\outputs\flutter-apk\app-debug.apk` can remain
the integration-test harness build and make downstream APK-based black-box
tests install the wrong artifact.

Deterministic Maestro batch:

```powershell
.\scripts\run_maestro_smoke.ps1 -DeviceId emulator-5554
```

Android black-box smoke:

```powershell
.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5554
```

Debug-only QA deep link checks:

```powershell
.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5554 -IncludeQaDeepLinks
```

Platform handoff checks, such as backup export leaving the app to Android UI,
are intentionally opt-in:

```powershell
.\scripts\run_android_blackbox_smoke.ps1 -DeviceId emulator-5554 -ExercisePlatformHandoffs
```

## Covered In Current Automation

| Risk | Current coverage |
| --- | --- |
| Integration command drift | `scripts/run_integration_smoke.ps1` and docs use `flutter drive` with `test_driver\integration_test.dart`, then rebuild the standard debug APK for downstream smoke tests. |
| Maestro batch state bleed | `scripts/run_maestro_smoke.ps1` runs selected flows one at a time and clears app state before each flow by default. |
| Stale Maestro consent/skip selectors | Maestro flows now tap visible `No Thanks` and `Skip setup...` text. Coordinates remain only for consent checkboxes that are not stable Maestro targets. |
| Settings deep link | `scripts/run_android_blackbox_smoke.ps1 -IncludeQaDeepLinks` checks `danio://qa/settings` on debug builds. |
| Dirty Create Tank discard | `-IncludeQaDeepLinks` opens `danio://qa/create-tank`, enters a tank name, verifies `Cancel` keeps the form open, then verifies `Discard` closes it. |
| Lesson deep link and hint surface | `-IncludeQaDeepLinks` opens `danio://qa/lesson/nitrogen_cycle`, then uses `danio://qa/lesson-quiz?state=hint` and `danio://qa/lesson-quiz?state=selected-correct` for deterministic quiz-state evidence. |
| Full-screen practice | Android black-box smoke enters an enabled practice mode when one is visible, and `danio://qa/practice-session?mode=due-mc` guarantees a seeded full-screen practice session for deterministic evidence. |
| Bottom-nav overlap | Maestro tab flow and Android black-box smoke repeatedly switch bottom tabs after pushed routes and long More/Backup screens. This catches unreachable-tab regressions without pixel-diff brittleness. |
| Backup export surface | Android black-box smoke verifies Backup & Restore, Export Data, Import Data, and either `Export Backup (ZIP)` or the empty-state `Go to Tank` CTA. Android handoff is opt-in because it depends on OS resolver/share UI. |

## Future Automation To Avoid Brittle Overfitting

- Add a backup export fake destination or debug share target before making the
  Android export handoff a default release gate. The real OS sharesheet/file UI
  is valid to smoke manually, but too device-dependent for the deterministic
  batch.
