# Danio Quality Ladder

Status: Active
Created: 2026-07-03

Use the smallest ladder rung that proves the change, then broaden when risk or
surface area demands it. Run commands from `apps/aquarium_app` unless noted.

Current phase: Android phone complete-local. Tablet evidence is required only
after the user reopens the parked tablet phase. Historical tablet checks remain
valid evidence but do not block the phone candidate.

Within the active phase, `DCL-A11Y-001` and `DCL-PERF-001` are phone-only.
All later tablet layout, accessibility, visual-polish, and performance work is
owned by parked row `DCL-TAB-001`.

## Required Checks By Change Type

| Change type | Required local checks | Evidence to record | Notes |
| --- | --- | --- | --- |
| Autonomy authority/bootstrap setup | Focused docs authority guard; `git diff --check`; `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs` | `ACTIVE_HANDOFF.md`, `SLICE_LOG.md`, exact bootstrap budget transition, and clean aligned Git proof | Keep automatic successor creation disabled except for one explicitly authorized project-scoped bootstrap handoff after durable closeout. No runtime proof is required. |
| Autonomy authority/schema change | Docs truth; autonomous script contract; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs` | Updated authority/schema references plus focused test output | Use this tier when state behavior and Git mutation logic are unchanged. |
| Autonomy pure state/readiness change | PowerShell behavior suite; disposable Git fixture suite; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs` | Transition counts, fixture scenario counts, and gate result | The fixture suite must use isolated temporary repositories and clean its verified temporary paths. |
| Autonomy Git mutation/claim/closeout change | Race and disposable Git fixtures; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs`; clean-main `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs -RequireCleanWorktree` | Race/rollback proof plus committed clean-main gate result | Preserve fail-closed claim, closeout, and recovery behavior. |
| Autonomy no-product rehearsal | All autonomous Dart, behavior, and disposable Git fixture suites; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs -RequireCleanWorktree` | Committed rehearsal report and zero-side-effect proof | No product, task, Android, Figma, or external-service mutation is allowed. |
| Docs-only workflow/setup | `git diff --check`; `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs` | Final response and `SLICE_LOG.md` when durable | No live preview required. |
| Docs claiming product behavior | Docs-only checks plus focused product test or source inspection proving the claim | Link source/test in handoff or slice log | Do not assert new product state without proof. |
| Tests-only | Focused test file; `git diff --check`; relevant gate if test changes shared setup | Final response | Keep paused/experimental tests separate from product commits. |
| Product behavior | Focused failing test first; focused test passes; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`; broaden to Docs or Full based on scope | Slice log and product docs if status changes | Use current source patterns. |
| Data safety | Failure-path test; rollback/retry assertion; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full` before commit | `FINISH_MAP.md` or data docs if completion status changes | No false success states. |
| UI/visual | Current visual target; focused widget/golden/screenshot where practical; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual` | Screenshot/golden/Figma target and affected phone evidence | Phone proof is required before Done in the active phase. Tablet proof resumes with the parked tablet phase. |
| Android QA | `.\scripts\run_danio_live_preview.ps1 -CheckOnly`; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep`; local screenshots/Patrol only with ownership | `DEVICE_OWNERSHIP.md`, screenshot path, or handoff | Do not install/tap/capture without ownership clarity. |
| Content | Focused content tests; `flutter test test/quality/content_validation_test.dart --reporter compact`; Focused or Docs gate | Content docs/backlog if acceptance changes | Keep source trails and safety copy honest. |
| Optional AI | No-AI path test; keyless/setup-state test; confirmation-before-write test where data can change; relevant gate | Source references and product docs if behavior changes | Do not enable fake providers. |
| Phone release candidate | `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`; `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep`; evidence manifest; affected phone QA | Final phone QA doc, evidence manifest, and Finish Map | Tablet and external lanes remain parked. No public launch/store/legal hosting begins from this checkpoint. |

## Standard Commands

```powershell
git diff --check
flutter test test/copy/current_docs_local_truth_test.dart --reporter compact
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
```

## External Quality Lanes

External lanes are optional review aids after local gates. Before use:

1. Confirm `PAID_TOOL_APPROVAL_LEDGER.md` covers the exact tool and purpose.
2. Run:

   ```powershell
   .\scripts\quality_gates\check_external_quality_readiness.ps1 -Target All
   ```

3. Keep secrets outside Git.
4. Record results as supplementary evidence, not as replacement for local
   Flutter tests, analyzer, content validation, or debug builds.
