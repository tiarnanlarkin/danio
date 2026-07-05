# Danio Workflow Charter

Status: Active operating agreement
Created: 2026-07-03
Scope: `apps/aquarium_app`

## Purpose

This charter is the durable working agreement for Danio agent sessions. It
keeps the app local-first, research-first, live-preview-aware, handoff-proof,
and quality-gated without making optional paid or account-backed tools part of
the product.

`FINISH_MAP.md` remains the product roadmap.
`COMPLETE_LOCAL_CLOSURE_LEDGER.md` owns traceable finding IDs, and
`VERIFIED_SLICE_EXECUTION_CONTRACT.md` owns the local proof discipline for
autonomous slices. This charter controls how agents choose and complete slices
from those docs.

## Operating Order

Every non-trivial Danio session follows this order:

1. Decide whether this work should start in a fresh session. If the current
   session is long, usage-limited, heavily compacted, or about to begin a broad
   slice, pause at the next clean checkpoint and recommend a fresh session.
2. Rebuild context from repo truth, not old chat history. Read `AGENTS.md`,
   this charter, `COMPLETE_LOCAL_CLOSURE_LEDGER.md`,
   `VERIFIED_SLICE_EXECUTION_CONTRACT.md`, `COMPLETE_LOCAL_FORECAST.md`,
   `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, the current audit, the backlog,
   relevant source, and nearby tests.
3. Run `git status --short -uall` before editing, before staging, and before
   committing.
4. Select the ledger ID the slice advances. Define the slice from
   `SLICE_CONTRACT_TEMPLATE.md` when the work is more than a tiny doc or
   mechanical fix.
5. Use `RESEARCH_PROTOCOL.md` before implementation when framework, platform,
   testing, accessibility, AI, security, workflow, or tooling decisions matter.
6. For substantial app, UI, navigation, product behavior, Android, or visual
   work, attempt `LIVE_PREVIEW_WORKFLOW.md` when device ownership is clear.
7. Use test-first behavior work. For docs-only structural guards, update the
   guard before relying on it.
8. Run the checks required by `QUALITY_LADDER.md`.
9. Commit only the intended files. Leave unrelated dirty work unstaged.
10. Update `ACTIVE_HANDOFF.md` and `SLICE_LOG.md` when the slice changes the
    project state future agents need to know.

## Local-First Product Rules

- Danio must remain useful without network access, external accounts, cloud
  sync, or optional AI keys.
- Do not add fake premium, fake social, fake cloud sync, fake leaderboards, or
  dormant monetisation promises.
- Optional AI must degrade gracefully and must ask before writing app data.
- Care copy must be practical and educational. It must not imply veterinary or
  professional replacement.
- Paid or account-backed services are quality lanes only, never runtime
  requirements.

## Planning Contract

Before implementation, the agent must be able to state:

- The exact `FINISH_MAP.md` row or housekeeping purpose the slice advances.
- The `COMPLETE_LOCAL_CLOSURE_LEDGER.md` ID the slice advances, or the reason
  the slice is workflow-only.
- The current dirty files and which ones must not be touched.
- The source files and tests that define current behavior.
- The current best-practice sources checked, if the slice needs research.
- The local gate that will prove the change.
- The evidence or handoff update that will make the result recoverable.

If any of these cannot be answered from repo truth or current official sources,
pause and gather evidence before editing.

## Live Preview Rule

Live preview is an observation lane for the user, not proof. Use it for
substantial app-facing work when `DEVICE_OWNERSHIP.md` and
`LIVE_PREVIEW_WORKFLOW.md` say the dedicated Danio emulator is safe.

Skip live preview for docs-only, tests-only, refactor-only, or device-unsafe
slices, and record the reason in the final response or handoff.

## Visual No-Guessing Rule

Do not make material UI, layout, illustration, icon, chart, or visual polish
changes unless the target is grounded in one of:

- A current screenshot or local emulator observation.
- A committed design baseline or golden test.
- A Figma/mockup/design doc approved for the slice.
- An existing in-app surface being extended consistently.

Unknown visual state is recorded as `Needs evidence`, never guessed.

## Verification Rule

Verification scales with risk:

- Docs-only setup: `git diff --check`, current docs truth test, and Docs gate.
- Behavior: focused failing test first, then focused gate, then broader gate as
  required.
- Data safety: failure-path tests and Full gate before commit.
- UI/visual: visual target, focused UI/golden/screenshot proof where practical,
  and Visual gate.
- Android QA: device ownership first, then AndroidPrep or local device evidence.

See `QUALITY_LADDER.md` for the full matrix.

## Handoff Rule

Every broad slice or pause point should leave enough breadcrumbs that another
agent can continue without chat history:

- `ACTIVE_HANDOFF.md` for current branch, dirty files, live-preview state,
  last checks, active slice, blockers, do-not-touch files, and next action.
- `SLICE_LOG.md` for completed slice evidence and commit references.
- `SCREEN_INVENTORY.md` when screen coverage, visual proof, or route ownership
  changes.
- `COMPLETE_LOCAL_CLOSURE_LEDGER.md` when a new finding is discovered or a
  finding's disposition/done condition changes.
- `FINISH_MAP.md` only when completion status changes.
- `AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md` when successor startup discipline or
  chain handoff requirements change.

## Stop Rules

Stop and ask before:

- Installing or enabling plugins, MCP servers, hooks, automations, repo-local
  skills, or tools that change Codex behavior.
- Using GitHub, Figma, Firebase, Percy, BrowserStack, CodeRabbit, Sentry,
  Qodo, OpenAI API, or any account-backed/paid lane.
- Creating, pasting, or persisting secrets.
- Making a product decision not covered by the current slice.
- Taking control of a device or emulator without ownership clarity.
- Implementing a finding whose ledger disposition is `PRODUCT_DECISION` or
  `EXTERNAL_PARKED`.
