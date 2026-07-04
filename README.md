# Danio

Danio is a local-first Flutter app for aquarium hobbyists. The active app lives
under `apps/aquarium_app`, and the current source-of-truth branch is `main`.

## Start Here

- `AGENTS.md` - repo working rules for Codex sessions.
- `apps/aquarium_app/README.md` - app overview, architecture, build commands,
  and local-first product scope.
- `apps/aquarium_app/docs/agent/FINISH_MAP.md` - current completion control
  layer and next-slice priority order.
- `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
  - current complete-local audit baseline and status history.
- `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - detailed backlog and acceptance history.
- `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md` - current branch, checks,
  blockers, and exact resume point.

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
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
```

## Repository Shape

- `apps/aquarium_app/` - Flutter source, app docs, tests, scripts, assets, and
  QA evidence.
- `docs/` - repository-level public/legal/planning archive docs.
- `contracts/` - retained schema references that are not part of the Flutter
  build path.
- `docs/archive/root-legacy-2026-07-04/` - historical root-level reports and
  old workflow notes kept for reference only.

Do not use archived docs as current roadmap or workflow authority.
