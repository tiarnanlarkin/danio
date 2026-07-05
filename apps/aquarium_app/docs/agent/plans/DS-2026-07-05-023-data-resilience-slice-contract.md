# DS-2026-07-05-023 Data Resilience Slice Contract

## Slice

- ID: DS-2026-07-05-023
- Title: Bulk livestock move must reject missing source tanks before reporting success.
- Branch/worktree: `ds-2026-07-05-023-bulk-move-source-guard` in the main repo worktree.
- Coordinator: Codex current session.
- Worker agents, if any: None.
- Owned files/modules: `lib/providers/tank_provider.dart`, `test/providers/tank_provider_test.dart`, `docs/agent/ACTIVE_HANDOFF.md`, `docs/agent/DEVICE_OWNERSHIP.md`, `docs/agent/SLICE_LOG.md`, this contract.
- Files/modules explicitly out of scope: UI redesign, Android screenshots, optional cloud/account backup paths, broad backup/restore internals.

## Product Goal

- User-visible outcome: A stale bulk livestock move cannot silently report success after its source tank has already been deleted.
- Complete-local requirement this advances: local data safety and no false success states for stale create/delete actions.
- Finish Map row(s): Data resilience.
- Product backlog row(s): CL-P1-009 / CL-QA-006 remaining create/edit/delete coverage.

## Research And Planning

- Fresh session recommended: No. This is one narrow provider-level slice from a clean, aligned source branch.
- Repo context checked: `AGENTS.md`, root/app README, `GIT_WORKFLOW.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, device/live-preview docs, and relevant provider/tests/source.
- Current best-practice sources checked: Repo-owned source and test patterns only; no new framework or platform API decision.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `TankActions.bulkMoveLivestock` now rechecks the target tank, but it still reads livestock from a source tank id without first confirming that the source tank still exists in durable storage.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not required; provider-level data-safety behavior.
- Phone expectation: No visual change.
- Tablet expectation: No visual change.
- Accessibility expectation: No visual change.
- Visual evidence required: No.

## Tests And Gates

- Focused test(s): Add a RED provider test in `test/providers/tank_provider_test.dart` for a stale bulk-move source tank.
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`.
- Android evidence required: No screenshot or Android functional QA required. Live preview was recovered during the slice after user request: `danio_api36` launched as `emulator-5556`, the debug app was installed/launched, and the app was left foregrounded.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Tank and livestock records through `StorageService`.
- Failure states to test: Source tank deleted after selection but before bulk move save.
- Rollback or retry behavior: Throw before reporting success or moving any livestock to the target.
- No-fake-feature/product-honesty check: No new feature claims or provider-backed behavior.

## Chain Settings

- Continuation mode: autonomous chain approved.
- Remaining autonomous budget at slice start: 4 verified slices or small approved epochs total, including this slice.
- Successor target: saved Danio Aquarium App Project at `C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project`.
- Stop conditions: do not chain if source branch is not clean/pushed/aligned, unrelated dirty work touches needed files, required tests/gates/docs/merge/push/cleanup are incomplete, live preview refresh is required and fails, next action is ambiguous/stale, or a paid/cloud/account/provider-key/secret/release/hardware/destructive-cleanup/product-direction decision is needed.

## Done Criteria

The slice is done only when:

- focused RED then GREEN evidence exists;
- full provider test file passes;
- targeted analyzer passes;
- required Full local gate passes;
- `git diff --check` passes;
- docs/logs are updated for handoff and slice history;
- no unrelated dirty files are staged;
- verified work is merged to `main`, pushed, and the temporary branch is safely deleted.

## Result

- Commit: Pending until closeout commit.
- Verification summary:
  - RED: `flutter test test/providers/tank_provider_test.dart --name "rejects missing source tank ids before moving livestock" --reporter compact` failed because `bulkMoveLivestock` completed instead of throwing after source tank deletion.
  - GREEN: same focused command passed after source tank recheck.
  - `dart format lib/providers/tank_provider.dart test/providers/tank_provider_test.dart`
  - `flutter test test/providers/tank_provider_test.dart --reporter compact`
  - `flutter analyze lib/providers/tank_provider.dart test/providers/tank_provider_test.dart`
  - Live preview recovery: `.\scripts\run_danio_live_preview.ps1 -LaunchEmulator -CheckOnly -WaitSeconds 240`; `.\scripts\run_danio_live_preview.ps1 -DeviceId emulator-5556`; foreground/pid checks confirmed Danio visible.
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Evidence path: No screenshot evidence; device/runtime status is recorded in `docs/agent/ACTIVE_HANDOFF.md` and `docs/agent/DEVICE_OWNERSHIP.md`.
- Follow-up created: Returning-user prompt context-after-dispose runtime exception recorded in active handoff as a future runtime bug, outside this provider slice.
