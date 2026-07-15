# Danio Working Agreement

Danio is a local-first Flutter app. Work from repository truth, keep product
claims honest, and optimize for small reviewed changes rather than ceremony.

## Routine startup (exact)

Read exactly these documents before ordinary development:

1. `AGENTS.md`
2. `GIT_WORKFLOW.md`
3. `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
4. `apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md`
5. `apps/aquarium_app/docs/agent/QUALITY_LADDER.md`

Do not add routine startup reads. Read the closure ledger, Finish Map, source,
tests, device docs, archives, old plans, forecasts, and frozen autonomy material
only when the current task directly needs them.

## Product and account boundaries

- Keep Danio useful offline and without external accounts or optional AI keys.
- Do not add fake premium, social, cloud-sync, leaderboard, referral, or
  subscription behavior.
- Optional AI must fail gracefully and ask before writing app data.
- Care content is educational and must not imply veterinary advice.
- Keep work local and no-cost by default.
- Do not configure paid services, cloud projects, hosted CI, external accounts,
  or API-backed workflows without explicit current-thread approval.
- Never commit secrets, keys, tokens, account exports, billing artifacts, or
  machine-local credential files.

## Git and ownership

- The repository root contains the source-of-truth `main`; GitHub is its mirror.
- Fetch and compare local/remote state before new work.
- Run `git status --short -uall` before editing, staging, and committing.
- Preserve user and other-agent work. Never revert, delete, overwrite, format,
  stage, or relocate unrelated changes.
- Use one repository-writing coordinator. Auditors and reviewers are read-only.
- Keep branches and worktrees short-lived and record an exact handoff if work
  cannot reach a clean checkpoint.
- Never force-push unless the user explicitly authorizes a separate recovery.
- Never create an automatic successor task.

## Lean development epochs

- Group two or three closely related micro-slices into one ordinary epoch.
- Keep data-safety, security, persistence, lifecycle/concurrency, destructive,
  release-truth, and broad multi-module changes in a single-slice epoch.
- For behavior changes, write or update a focused failing test first, prove RED
  for the expected reason, make the smallest fix, then prove GREEN.
- Run focused tests once for the affected behavior and run `flutter analyze`.
- Run one Full gate on the final settled tree of each product-code epoch.
- A docs-only epoch uses one Docs gate and no Full gate.
- After fast-forwarding or pushing identical tested bytes, compare tree IDs and
  Git alignment; do not rerun an identical Full gate.
- Update `ACTIVE_HANDOFF.md` and add one concise `SLICE_LOG.md` row per epoch.
- Update the Finish Map or closure ledger only when its actual status changes.
- Ordinary narrow work needs coordinator review only. Add one independent
  settled-diff review for high-risk or broad changes.

Run gates from `apps/aquarium_app`. Focused and Visual require explicit paths:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused -FocusedTests test/widget_tests/search_screen_test.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual -FocusedTests test/widget_tests/search_screen_test.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
```

Autonomy checks are retained but opt-in with `-RunAutonomyTests`.
`-ResetGeneratedOutputs` is the only gate option allowed to remove generated
trees. Ordinary gates preserve the warm `build` cache.

## Android and visual work

- Check `docs/agent/DEVICE_OWNERSHIP.md` before emulator, ADB, Patrol,
  live-preview, screenshot, or device-affecting work.
- Do not start, stop, wipe, install to, tap, or capture from a device without
  clear ownership; use `adb -s <assigned-serial>` for assigned-device commands.
- `apps/aquarium_app/docs/agent/LIVE_PREVIEW_WORKFLOW.md` live preview is
  observational and never replaces tests or gates.
- Ground material UI or visual changes in a current screenshot, golden, mockup,
  approved design doc, Figma frame, or existing app surface.
- Use local screenshots and assets with clear ownership or permissive licenses.

## Frozen autonomous workflow

The former phone-completion claim, budget, and successor machinery is frozen
historical material. The retained state is revision 2 `stopped`, with reason
`USER_REQUESTED_WORKFLOW_SIMPLIFICATION`. Do not invoke, resume, reinterpret,
or delete it during ordinary work.

Reactivation requires a new explicit user request plus a written reconciliation
plan covering live Git authority, state/schema compatibility, budget meaning,
tests, and safe rollback. Historical authorization is not reusable.

## Stop conditions

Stop and ask before using a paid/account-backed lane, handling secrets, making
an uncovered product decision, taking unclear device ownership, rewriting
public Git history, or deleting an artifact whose ownership is uncertain.

If work stops unfinished, leave the branch, dirty paths, completed checks,
failure reason, and exact next command in `ACTIVE_HANDOFF.md`.
