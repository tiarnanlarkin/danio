# Accelerated Complete-Local Epoch Plan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `$verified-slice-runner` and `superpowers:executing-plans` to implement this plan task-by-task. Use read-only subagents only when explicitly allowed by the current thread; do not use write agents or parallel repo sessions without fresh approval. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish Danio's phone-first complete-local work faster by replacing single micro-slice sessions with bounded verified epochs that preserve the existing quality bar.

**Architecture:** Keep `main` as the source-of-truth branch and run one short-lived epoch branch at a time. Each epoch bundles 2 to 3 closely related micro-slices, proves each micro-slice with focused RED/GREEN or equivalent guard evidence, then runs the required closeout gate once at epoch end.

**Tech Stack:** Flutter, Dart, Riverpod, local JSON/SharedPreferences storage, PowerShell quality wrappers, Android local debug builds, repo-owned agent/product docs.

---

## Scope Freeze

This plan accelerates only the local-first complete-local finish line.

In scope:

- Data resilience, backup/restore, migration, create/edit/delete, undo, lifecycle, and app-kill persistence gaps.
- Optional AI confirmation only for real current AI writes to local app data.
- Normal-user P1 depth that is already in the finish map: living tank, guided tools, timeline, learning, rewards.
- Content/rule confidence, accessibility, visual polish, performance measurement, and final local evidence.
- Local-only tests, local Android builds, local screenshots, and local emulator evidence when device ownership is clear.

Out of scope unless the current user explicitly reopens it:

- Non-OpenAI provider implementation.
- Premium AI.
- Store/release submission.
- Cloud setup, hosted CI, paid services, account-backed QA, provider keys, or secret workflows.
- Broad seasonal cosmetics, large asset-generation passes, or new product areas that are not required by the complete-local bar.

## Epoch Rules

- Use epoch mode only from a clean, aligned `main`.
- One epoch equals one completed verified session.
- Each epoch may contain 1 to 3 micro-slices.
- Default to 2 micro-slices. Use 3 only when all slices share the same module, test family, risk boundary, and proof setup.
- Run focused proof immediately after each micro-slice. Do not defer risky proof to the end.
- Run the repo-required closeout gate at epoch end.
- Keep one branch per epoch and one final commit unless the diff becomes clearer with separate commits.
- Stop and split the epoch if the diff crosses modules unexpectedly, device evidence becomes required and unsafe, a product decision is needed, or a focused proof fails twice for the same root cause.

## Required Startup For Every Epoch

- [ ] Confirm repo root:

```powershell
git rev-parse --show-toplevel
```

- [ ] Fetch and verify source branch alignment:

```powershell
git fetch --prune
git status --short -uall
git rev-list --left-right --count main...origin/main
```

Expected: clean worktree and `0 0` before starting.

- [ ] Read the current instructions and roadmap docs:

```text
AGENTS.md
GIT_WORKFLOW.md
apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md
apps/aquarium_app/docs/agent/FINISH_MAP.md
apps/aquarium_app/docs/agent/QUALITY_LADDER.md
apps/aquarium_app/docs/agent/TESTING_CHECKLIST.md
apps/aquarium_app/docs/agent/SLICE_LOG.md
apps/aquarium_app/docs/agent/plans/2026-07-05-accelerated-complete-local-epoch-plan.md
apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md
apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md
```

- [ ] Inspect device ownership before any runtime work:

```powershell
cd apps/aquarium_app
.\scripts\run_danio_live_preview.ps1 -CheckOnly
```

Skip this for docs-only or pure service/test epochs unless Android evidence is required.

## Epoch 1: Data Resilience Restore And Migration Closeout

**Goal:** Close the highest-priority remaining local data-safety lane around restore, migration, and broader import failure behavior.

**Likely files:**

- Modify: `apps/aquarium_app/lib/screens/backup_restore_screen.dart`
- Modify: `apps/aquarium_app/lib/services/backup_import_service.dart`
- Modify: `apps/aquarium_app/lib/services/backup_service.dart`
- Modify: `apps/aquarium_app/lib/services/local_json_storage_service.dart`
- Modify: `apps/aquarium_app/lib/utils/schema_migration.dart`
- Test: `apps/aquarium_app/test/services/backup_import_service_test.dart`
- Test: `apps/aquarium_app/test/services/backup_service_photo_restore_test.dart`
- Test: `apps/aquarium_app/test/storage_error_handling_test.dart`
- Test: `apps/aquarium_app/test/utils/schema_migration_test.dart`
- Docs: `apps/aquarium_app/docs/agent/FINISH_MAP.md`
- Docs: `apps/aquarium_app/docs/agent/SLICE_LOG.md`
- Docs: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Docs: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

### Task 1: Select Two Restore Or Migration Micro-Slices

- [ ] Search for the current gap language:

```powershell
rg -n "restore|migration|rollback|partial|orphan|false|CL-P1-009" apps/aquarium_app/docs/agent/FINISH_MAP.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md
```

- [ ] Pick two gaps that share one service/test family.
- [ ] Write an epoch contract under `apps/aquarium_app/docs/agent/plans/` with the selected micro-slices, expected RED tests, and stop conditions.

### Task 2: Prove Micro-Slice A RED, Then GREEN

- [ ] Write the focused failing test in the relevant service or widget test file.
- [ ] Run only that named test:

```powershell
cd apps/aquarium_app
flutter test test/services/backup_import_service_test.dart --reporter compact
```

Expected during the RED step: the newly added test in this file fails for the
specific missing rollback, migration, or false-success behavior. If the epoch
contract records a concrete test name, run that named test first and then the
full touched file after the fix.

- [ ] Implement the smallest production fix.
- [ ] Re-run the named test and the full touched test file.

Expected: named test passes, then full touched test file passes.

### Task 3: Prove Micro-Slice B RED, Then GREEN

- [ ] Write the second focused failing test in the same service/test family when possible.
- [ ] Run only that named test:

```powershell
cd apps/aquarium_app
flutter test test/services/backup_import_service_test.dart --reporter compact
```

Expected during the RED step: the newly added second test in this file fails
for the specific missing rollback, migration, or false-success behavior. If the
epoch contract records a concrete test name, run that named test first and then
the full touched file after the fix.

- [ ] Implement the smallest production fix.
- [ ] Re-run the named test and the full touched test file.

Expected: named test passes, then full touched test file passes.

### Task 4: Close Epoch 1

- [ ] Run targeted analyze on touched Dart files:

```powershell
cd apps/aquarium_app
flutter analyze
```

- [ ] Run the required Full gate:

```powershell
cd apps/aquarium_app
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree
```

- [ ] Update docs and run docs checks:

```powershell
git diff --check
cd apps/aquarium_app
flutter test test/copy/current_docs_local_truth_test.dart --reporter compact
```

- [ ] Commit, fast-forward merge to `main`, rerun the clean `main` Full gate, push, delete the epoch branch, and confirm `main...origin/main` is `0 0`.

## Epoch 2: Create Edit Delete Relationship Mapping

**Goal:** Close remaining normal create/edit/delete relationship gaps that could create orphan records, stale-success states, or broken local relationships.

**Likely files:**

- Modify: tank, livestock, equipment, task, journal, cost tracker, wishlist, or provider files selected by source review.
- Test: focused widget/provider test files already covering the selected surface.
- Docs: finish map, slice log, and product audit/backlog rows when behavior changes.

### Task 1: Select Two Relationship Micro-Slices

- [ ] Search for stale relationship and parent/child gaps:

```powershell
rg -n "missing parent|orphan|stale|delete|undo|relationship|relatedEquipmentId|tankId|save.*success|false success" apps/aquarium_app/lib apps/aquarium_app/test
```

- [ ] Pick two gaps with shared UI/provider/storage ownership.
- [ ] Reject the epoch if the candidates require unrelated screens or different proof styles.

### Task 2: Execute RED/GREEN Per Micro-Slice

- [ ] For each selected gap, write the focused failing test first.
- [ ] Run the named test and verify expected RED.
- [ ] Implement the smallest fix.
- [ ] Re-run the named test and the full touched test file.

### Task 3: Close Epoch 2

- [ ] Run targeted analyze.
- [ ] Run `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`.
- [ ] Update docs/logs.
- [ ] Merge, push, and clean up exactly as Epoch 1.

## Epoch 3: Future Debounced Writers And App-Kill Flush

**Goal:** Make sure remaining and future debounced local writers either flush on lifecycle detach or fail visibly without false success.

**Likely files:**

- Modify: providers/services with debounce timers or delayed local saves.
- Test: `apps/aquarium_app/test/screens/app_lifecycle_contract_test.dart`
- Test: provider-specific lifecycle or persistence tests.

### Task 1: Inventory Debounced Writers

- [ ] Search current source:

```powershell
rg -n "Timer|Debounce|debounce|flush|detached|AppLifecycleState|WidgetsBindingObserver|setString|setStringList|remove\\(" apps/aquarium_app/lib
```

- [ ] Compare findings with existing lifecycle tests.
- [ ] Pick up to two missing flush or false-write boundaries.

### Task 2: Execute RED/GREEN Per Boundary

- [ ] Add focused lifecycle or provider tests for each chosen boundary.
- [ ] Verify RED for the missing flush or false-success behavior.
- [ ] Implement the smallest fix.
- [ ] Verify GREEN and the full touched test file.

### Task 3: Close Epoch 3

- [ ] Run targeted analyze.
- [ ] Run the Full gate with clean worktree requirement.
- [ ] Update `FINISH_MAP.md` only if the app-kill follow-up can be narrowed or closed.

## Epoch 4: Optional AI Confirmation Audit

**Goal:** Close AI confirmation only for real current local writes; do not create fake AI write paths.

**Likely files:**

- Inspect: `apps/aquarium_app/lib/features/smart/`
- Inspect: `apps/aquarium_app/lib/screens/smart_screen.dart`
- Inspect: `apps/aquarium_app/lib/services/openai_service.dart`
- Test: relevant Smart, Symptom Triage, Weekly Plan, and Ask Danio widget/service tests.

### Task 1: Audit Real AI Writes

- [ ] Search AI write surfaces:

```powershell
rg -n "OpenAI|AI|ai_interaction_history|weekly_plan_cache|saveLog|saveTask|saveTank|saveEquipment|saveLivestock|SharedPreferences" apps/aquarium_app/lib/features/smart apps/aquarium_app/lib/screens/smart_screen.dart apps/aquarium_app/lib/services
```

- [ ] Classify each current write as confirmed, no-write, or needs confirmation.
- [ ] If no real unconfirmed current write exists, update docs with audit evidence and stop without product-code changes.

### Task 2: Add Confirmation Where A Real Write Exists

- [ ] Write cancel and confirm tests before implementation.
- [ ] Verify cancel RED because the write currently happens without confirmation.
- [ ] Add the minimal confirmation UI or service boundary.
- [ ] Verify cancel leaves storage unchanged and confirm writes exactly once.

### Task 3: Close Epoch 4

- [ ] Run focused Smart tests and targeted analyze.
- [ ] Run `Focused` or `Full` gate according to changed risk.
- [ ] Update Optional AI notes in `FINISH_MAP.md` and product audit docs.

## Epoch 5: Normal-User P1 Depth

**Goal:** Close the highest-value user-depth gaps without reopening broad redesign.

Candidate bundles:

- Living Tank plus Rewards: plant inventory, earned decorations, or seasonal cues only if grounded in current reward rules and screenshots.
- Guided Tools plus Timeline: remaining tool-specific save/apply handoff walkthrough gaps.
- Learning plus Citations: richer visuals, practice links, scenarios, or subtle source trails in one path cluster.

### Task 1: Pick One Bundle From Current Evidence

- [ ] Start from `FINISH_MAP.md` ranked roadmap and current screenshots/goldens.
- [ ] Pick one bundle with one user journey and one proof family.
- [ ] Do not combine UI-heavy work with data-resilience or AI work.

### Task 2: Implement 1 To 2 User-Facing Micro-Slices

- [ ] For behavior, write focused widget/service tests before code.
- [ ] For UI/visual changes, capture or name the current screenshot/golden/design target before edits.
- [ ] Run focused tests after each micro-slice.

### Task 3: Close Epoch 5

- [ ] Run the gate required by `QUALITY_LADDER.md`.
- [ ] For visual work, run the Visual profile or relevant goldens/screenshots.
- [ ] Update screen inventory or QA evidence only for surfaces that changed.

## Epoch 6: Content And Rule Confidence

**Goal:** Improve recommendation, compatibility, emergency, unit, calculator, citation, and content-risk coverage.

**Likely files:**

- Modify content validators under `apps/aquarium_app/test/quality/` or content/rule tests.
- Modify source trails or lesson/species content only where tests identify a concrete gap.

### Task 1: Select Rule Or Content Gaps

- [ ] Search current rule coverage:

```powershell
rg -n "recommendation|compatibility|emergency|calculator|unit|citation|source|unsafe|veterinary|professional" apps/aquarium_app/test apps/aquarium_app/lib
```

- [ ] Pick 2 to 3 related validation gaps.

### Task 2: Add Tests Before Content Fixes

- [ ] Add failing validator or rule tests.
- [ ] Verify RED.
- [ ] Patch the content/rule logic.
- [ ] Verify GREEN.

### Task 3: Close Epoch 6

- [ ] Run focused content/rule tests.
- [ ] Run `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused` or stronger if `QUALITY_LADDER.md` requires it.
- [ ] Update citations/source notes only when the content changed.

## Epoch 7: Accessibility Visual Performance Evidence

**Goal:** Close remaining P2 proof gaps without broad redesign.

Candidate bundles:

- Accessibility pass on one high-traffic cluster.
- Selective visual regression additions for core surfaces.
- Performance measurement on Android phone/tablet when device ownership is clear.

### Task 1: Choose One Evidence Type

- [ ] Do not mix accessibility, visual asset replacement, and performance in one epoch unless the same screen and evidence workflow covers all of them.
- [ ] For UI changes, start from a screenshot, golden, mockup, or current in-app surface.

### Task 2: Add Focused Evidence

- [ ] Add accessibility/widget/golden/performance proof before or alongside changes.
- [ ] Capture local Android evidence only after `DEVICE_OWNERSHIP.md` and `-CheckOnly` confirm safe ownership.

### Task 3: Close Epoch 7

- [ ] Run the Visual, AndroidPrep, or focused performance checks required by `QUALITY_LADDER.md`.
- [ ] Record screenshot paths or performance result summaries in agent QA docs.

## Epoch 8: Final Release-Candidate Evidence

**Goal:** Produce the final local-first completion evidence packet after the higher-priority lanes are closed or explicitly deferred.

### Task 1: Confirm No Higher-Ranked Open Blockers

- [ ] Re-read `FINISH_MAP.md`, product audit, backlog, `ACTIVE_HANDOFF.md`, and `SLICE_LOG.md`.
- [ ] Search for live open blockers:

```powershell
rg -n "remaining|open|blocker|not started|in progress|follow-up|must|fake|cloud|premium|provider" apps/aquarium_app/docs/agent apps/aquarium_app/docs/product
```

- [ ] If any item is still required for complete-local, stop and plan that item first.

### Task 2: Run Final Local Evidence

- [ ] Run the final gate set from `FINISH_MAP.md` and `QUALITY_LADDER.md`:

```powershell
cd apps/aquarium_app
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
```

- [ ] Recheck phone/tablet maps only if surfaces changed since the last verified inventory or release signoff requires fresh evidence.

### Task 3: Write Final QA Note

- [ ] Create a final release-candidate note under `apps/aquarium_app/docs/qa/`.
- [ ] Include commit, branch, gate results, Android evidence paths, deferred work, and explicit no-go items.
- [ ] Commit, merge, push, and leave `main...origin/main` at `0 0`.

## Stop Conditions

Stop the current epoch and ask one direct question when:

- `main...origin/main` is not `0 0` at startup.
- The worktree is dirty with unrelated files needed by the epoch.
- The next action is ambiguous, stale, or already complete.
- A gate fails twice for the same root cause.
- A product direction, paid/cloud/account, provider key, secret, release/store, hardware, destructive cleanup, or fake-feature decision is needed.
- Device ownership is unclear for required Android evidence.
- The epoch grows beyond three micro-slices or crosses unrelated modules.

## Expected Session Count

Plan against 7 to 10 verified sessions:

- Epochs 1 to 3: data resilience closeout.
- Epoch 4: optional AI confirmation audit and fixes if real current writes require them.
- Epoch 5: normal-user P1 depth.
- Epoch 6: content and rule confidence.
- Epoch 7: accessibility, visual, and performance evidence.
- Epoch 8: final release-candidate evidence.

Use fewer sessions only when an epoch closes cleanly with all focused proof and required gates. Use more sessions when the evidence requires device work, visual targets, or product decisions.
