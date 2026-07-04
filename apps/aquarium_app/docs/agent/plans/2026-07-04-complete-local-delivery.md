# Danio Complete-Local Delivery Execution Plan

Status: Active execution control
Created: 2026-07-04
Branch: `qa/production-tool-audit-2026-05-25`
Finish line: complete-local before public release or store/account execution

## Operating Model

- One coordinator owns branch state, slice selection, integration, commits,
  pushes, and final verification.
- Use at most six active project agents, matching `MULTI_AGENT_WORKFLOW.md`.
- Use worker agents only in explicit git worktrees with exact file/module
  ownership.
- Keep implementation mostly sequential in verified slices. Use parallel agents
  for read-only research and bounded review.
- Stop before paid services, cloud setup, external accounts, API keys, hosted
  review tools, or Android device control unless the user separately approves.

## Preflight

- Repo root: `C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo`
- Source branch: `qa/production-tool-audit-2026-05-25`
- Preflight command set:
  - `git status --short -uall`
  - `git fetch --all --prune`
  - `git rev-list --left-right --count "HEAD...@{u}"`
  - confirm `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, and
    `MULTI_AGENT_WORKFLOW.md`
- Latest observed start condition: branch was aligned with upstream at `0 0`
  before DS-2026-07-04-010 implementation.

## Initial Read-Only Research Wave

- `danio_product_auditor`: keep P1/P2/P3 completion order after data resilience.
- `danio_quality_auditor`: first data-resilience slice was local JSON
  migration stamp false-green coverage; current follow-up is continuing
  bounded CL-P1-009/CL-QA-006 failure-path coverage.
- `danio_ui_auditor`: defer P2 visual/accessibility/performance polish until
  data/test/security slices are resolved.
- `danio_reviewer`: security/product-honesty blockers are AI proxy abuse,
  direct OpenAI release fallback, cloud backup encryption copy, privacy copy,
  and global AI disclosure scope.
- `danio_android_qa_owner`: release/device QA must stay local-gate-first and
  requires device ownership before install/tap/screenshot/logcat/Patrol work.

## Prioritized Slice Queue

1. Data resilience: remaining create/edit/delete, restore, migration, and
   app-kill flush coverage.
2. Test truthfulness: make integration smoke tests fail if main-tab flows are
   not actually exercised.
3. Security/product honesty: AI proxy abuse controls, direct OpenAI release
   policy, backup encryption copy/keying truth, privacy copy, and AI disclosure
   scope.
4. P1 product depth: Living Tank, rewards, learning, guided tools, timeline,
   and preferences.
5. P2 polish: visual assets, accessibility, motion/haptics, performance, and
   visual regression.
6. Release hardening: Android AAB/signing/config hygiene, screenshots,
   notification icon QA, and final local release signoff.

## Active Slice

- Current slice: `DS-2026-07-04-010`
- Contract:
  `docs/agent/plans/DS-2026-07-04-010-data-resilience-slice-contract.md`
- Goal: failed bulk tank permanent delete writes must surface retry feedback.
- Owned files:
  - `lib/providers/tank_provider.dart`
  - `test/providers/tank_provider_test.dart`
  - relevant agent/product status docs

## Maintenance Checkpoints

- After every 3-5 completed slices, run a branch/remote/worktree cleanup review.
- Refresh `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, and `SLICE_LOG.md`.
- Do not delete branches, worktrees, artifacts, or files unless clearly safe.
