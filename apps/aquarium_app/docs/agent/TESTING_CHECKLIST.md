# Danio Testing Checklist

Use this checklist before committing Danio changes. It is local-first and no-cost.

## Before Editing

- Run `git status --short`.
- Identify unrelated dirty files and leave them alone.
- Read the relevant source and nearby tests before changing code.
- For behavior changes, write or update a focused failing test first.

## Focused Verification

Run focused tests for the changed area.

Examples:

```powershell
flutter test test/widget_tests/search_screen_test.dart
flutter test test/widget_tests/journal_screen_test.dart
flutter test test/widget_tests/backup_restore_screen_test.dart
flutter test test/widget/settings_screen_test.dart
flutter test test/services/backup_service_test.dart
flutter test test/copy/current_docs_local_truth_test.dart
```

Use the smallest focused test first, then broaden.
For UI/settings/navigation changes, include the focused widget test that proves
the visible flow can be reached and interacted with.

## Standard Product Gates

Run from `apps/aquarium_app`:

```powershell
flutter test
flutter analyze
flutter build apk --debug --target lib/main.dart
git diff --check
```

Expected:

- `flutter test` passes.
- `flutter analyze` reports no issues.
- Debug APK builds successfully.
- `git diff --check` prints no whitespace errors.

The debug APK build may report the known future Kotlin Gradle Plugin warning. That warning does not block the current local debug build unless it turns into a build failure.

## Docs-Only Gates

For docs-only changes:

```powershell
git diff --check
flutter test test/copy/current_docs_local_truth_test.dart
rg -n "Maestro Cloud|Vercel|Supabase|Sentry|OpenAI API calls|paid service|fake premium|fake social|fake cloud" AGENTS.md apps/aquarium_app/docs/agent
```

Run `flutter test test/copy/current_docs_local_truth_test.dart` if the docs describe current app behavior.

Docs-only setup changes do not require a full Flutter suite unless they alter product truth, test instructions, or launch/readiness claims.

## Android QA Discipline

Use Android devices only when safe:

- Check `adb devices`.
- Confirm no other Codex session owns the emulator/device.
- Do not install, clear data, restart, wipe, or kill a device without ownership clarity.
- If ownership is unclear, stop at `flutter build apk --debug --target lib/main.dart`.

When Android QA is safe, capture:

- Device/emulator name.
- APK/build used.
- Screens tested.
- Screenshots or logcat snippets if they prove an issue or fix.

Store durable local evidence under:

```text
apps/aquarium_app/docs/qa/screenshots/<date-or-branch>/<slice>/
```

## Local Screenshot Checklist

- Use local capture only.
- Name files by screen and state.
- Avoid uploading screenshots to external services.
- Include enough context to reproduce the state.
- Do not commit temporary screenshots unless they are useful QA evidence.

## Design And Visual Baseline Checks

Use `docs/design/BASELINES.md` to choose the minimum screenshot or golden-test
set for broad visual work and `docs/design/VISUAL_QA_CHECKLIST.md` for local
pass/fail criteria.

For focused Flutter golden checks:

```powershell
flutter test test/golden_tests/mc_card_golden_test.dart
flutter test test/golden_tests/empty_room_scene_golden_test.dart
```

Regenerate ignored local golden references only when intentionally reviewing
visual output:

```powershell
flutter test --update-goldens test/golden_tests/
```

For app-wide screenshot evidence, reuse committed local screenshot folders such
as `docs/qa/screenshots/whole-app-map-2026-05-18/` and capture new local
evidence only when device ownership is clear.

## Product Truth Checklist

Before committing product or docs changes, confirm:

- Smart Hub still works locally without AI.
- Optional AI absence is not presented as an app failure.
- No fake premium, social, cloud, leaderboard, referral, or subscription promises were introduced.
- Local backup/restore wording explains what happens in normal-user language.
- Educational care copy does not imply veterinary/professional replacement.

## Final Commit Checklist

- Focused tests passed.
- Required gates passed for the type of change.
- `git diff --check` passed.
- `git status --short` contains only files intended for the commit.
- Commit message is specific.
- Push only after the requested verification passes.
