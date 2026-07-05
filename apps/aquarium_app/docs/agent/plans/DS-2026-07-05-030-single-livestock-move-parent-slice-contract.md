# DS-2026-07-05-030 - Single Livestock Move Parent Guard

## Slice Contract

- Slice id: DS-2026-07-05-030
- Title: Reject stale single-livestock moves to missing target tanks
- Branch: `ds-2026-07-05-030-single-livestock-move-parent`
- Source branch: `main`
- Related plan: `2026-07-05-accelerated-complete-local-epoch-plan.md`, Epoch 1 fallback micro-slice
- Risk tier: Tier 2, persistence relationship guard

## Why This Slice

Epoch 1 starts with restore and migration closeout. Current repo inspection shows the nearest backup import and migration service candidates already have focused guards for tank and child ID collision remapping, import rollback, photo rollback, preferences rollback, local JSON load errors, and schema stamp failures. The remaining restore/migration work is mostly Android walkthrough proof, which is broader than a safe service micro-slice for this session.

The ranked data-resilience lane still includes create, edit, delete, undo, and relationship-mapping hardening. `TankActions.bulkMoveLivestock` already rejects missing source and target tanks before moving livestock, but the single `moveLivestock` path can still save a livestock record to a stale or deleted target tank. This slice brings the single-item path in line with the guarded bulk path.

## Intended Behavior

When a single livestock move is requested and the target tank no longer exists, the move should fail before saving. Existing livestock should remain associated with its original tank, and no orphan livestock should be created under the missing target tank id.

## Likely Files

- `lib/providers/tank_provider.dart`
- `test/providers/tank_provider_test.dart`
- `docs/agent/ACTIVE_HANDOFF.md`
- `docs/agent/FINISH_MAP.md`
- `docs/agent/SLICE_LOG.md`

## Focused Proof Plan

1. Add a focused provider test named `rejects missing target tank ids before moving single livestock`.
2. Run that test and verify RED because `moveLivestock` currently saves to the missing target tank.
3. Add the smallest target tank existence check to `TankActions.moveLivestock`.
4. Rerun the focused test and verify GREEN.
5. Run the full provider test file and targeted analyzer.

## Closeout Gate Plan

- `flutter test test/providers/tank_provider_test.dart --name "rejects missing target tank ids before moving single livestock" --reporter compact`
- `flutter test test/providers/tank_provider_test.dart --reporter compact`
- `flutter analyze lib/providers/tank_provider.dart test/providers/tank_provider_test.dart`
- `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
- `git diff --check`
- Required Full gate on the clean merged source branch:
  `./scripts/quality_gates/run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`

## Safety Notes

- No runtime/device manipulation is required for this service/provider slice beyond the startup ownership inspection already completed.
- No cloud, paid service, account, provider key, release, or store scope.
- Stop if unrelated dirty work appears in any target file or if the data-resilience roadmap contradicts this slice before implementation.
