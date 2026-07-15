# Danio

Danio is a local-first Flutter app for aquarium hobbyists. The active app lives
under `apps/aquarium_app`, and the current source-of-truth branch is `main`.

## Start Here

Routine development starts with the exact five-file set in `AGENTS.md`:
`AGENTS.md`, `GIT_WORKFLOW.md`, current `ACTIVE_HANDOFF.md`,
`VERIFIED_SLICE_EXECUTION_CONTRACT.md`, and `QUALITY_LADDER.md`. Load the
Finish Map, ledger, source, tests, device docs, archives, and old plans only
when the current task directly needs them.

## Build

Run app commands from `apps/aquarium_app`:

```powershell
flutter pub get
flutter test
flutter analyze
flutter build apk --debug --target lib/main.dart
flutter build apk --release --target lib/main.dart
```

The local quality wrapper is:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused -FocusedTests test/widget_tests/search_screen_test.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
```

`Focused` and `Visual` require explicit affected test paths. Product-code
epochs run one Full gate on the final settled tree; docs-only epochs run one
Docs gate. Autonomy checks are retained behind `-RunAutonomyTests`.

## Repository Shape

- `apps/aquarium_app/` - Flutter source, app docs, tests, scripts, assets, and
  QA evidence.
- `docs/` - repository-level public/legal/planning archive docs.
- `contracts/` - retained schema references that are not part of the Flutter
  build path.
- `docs/archive/root-legacy-2026-07-04/` - historical root-level reports and
  old workflow notes kept for reference only.

Do not use archived docs as current roadmap or workflow authority.
