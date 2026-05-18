# Whole-App Phone Review - Phase 0 Baseline

Date: 2026-05-17
Branch: `feature/quiet-guidance-notifications`
Commit tested: `1e1e701d Quiet guidance and notification reminders`
Device: `SM F966B` / Android 16 API 36 / `RFCY8022D5R`
Device state: returning-user state, no app data clear performed

## Automated Gate Results

| Check | Result | Notes |
| --- | --- | --- |
| `git status --short --branch` | Pass | Clean branch: `feature/quiet-guidance-notifications`. |
| `flutter devices` | Pass | Physical phone detected as `SM F966B - RFCY8022D5R`. |
| `flutter test` | Pass | 1,064 tests passed. |
| `flutter analyze --no-pub` | Pass | No issues found. |
| `flutter test integration_test/smoke_test_v2.dart -d RFCY8022D5R` | Fail: harness hang | Installed and launched on the phone, then hung on `App launches and displays initial screen`. The app was foregrounded and recent logs showed no crash. The process tree was stopped manually after several minutes. |
| `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/smoke_test_v2.dart -d RFCY8022D5R` | Pass | Same smoke target passed all six checks on the phone. |

## Phase 0 Findings

### QA-H1: `flutter test` Phone Smoke Hangs

Severity: P1 harness/setup friction
Surface: integration test runner
Evidence: `flutter test integration_test/smoke_test_v2.dart -d RFCY8022D5R` built and installed the APK, printed `00:00 +0: App launches and displays initial screen`, then produced no more output for several minutes. `adb` showed `com.tiarnanlarkin.danio/.MainActivity` focused. Recent device logs did not show `AndroidRuntime`, `FATAL`, or Dart crash output.
Workaround: run the same smoke target through `flutter drive` with `test_driver/integration_test.dart`; that path connected to the VM service and passed.

Recommended next action: update the documented phone smoke command, or harden `integration_test/smoke_test_v2.dart` so the direct `flutter test` path exits reliably on physical devices.

### QA-H2: Smoke Coverage Is Still Shallow

Severity: P2 coverage gap
Surface: whole-app regression coverage
Evidence: the current smoke test validates launch, `Scaffold` presence, and basic tab taps only. It does not cover onboarding completion, tank creation, lesson completion, practice reviews, notification settings, or backup/restore entry points.

Recommended next action: expand automation phase by phase only after the manual phone pass identifies stable repeatable flows worth locking down.

## Phone Review Instructions

Use this baseline for Phase 0 and for future phase checkpoints:

1. Keep the phone unlocked and connected by USB.
2. From `apps/aquarium_app`, confirm the target:
   ```powershell
   flutter devices
   ```
3. For the currently reliable automated phone smoke:
   ```powershell
   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/smoke_test_v2.dart -d RFCY8022D5R
   ```
4. For manual review without clearing data:
   ```powershell
   flutter run -d RFCY8022D5R
   ```
5. Record the commit tested, whether the phone is fresh or returning-user state, pass/fail notes, screenshots for visual issues, and any crash/log evidence.

Do not clear app data until Phase 1 starts. Phase 1 is a fresh-start onboarding review and should explicitly clear `com.tiarnanlarkin.danio` first.

## Phase 1 Entry Checklist

- Confirm permission to clear app data on `RFCY8022D5R`.
- Clear `com.tiarnanlarkin.danio` only for the fresh-start onboarding run.
- Complete consent, onboarding, fish selection, tank creation, warm entry, and notification opt-in copy naturally.
- Classify each issue as P0/P1/P2/P3.
- Keep quiet-guidance policy intact: no floating XP nudges, no stacked tutorial banners, and reminders remain explicit opt-in.
