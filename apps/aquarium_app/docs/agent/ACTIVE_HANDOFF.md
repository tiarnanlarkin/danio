# Danio Active Handoff

Status: Active current-session handoff
Last updated: 2026-07-03 during workflow-foundation implementation

## Branch

- Branch: `qa/production-tool-audit-2026-05-25`
- Latest workflow checkpoint commit: `774fd154 docs: add research-first live preview workflow rules`
- Prior pushed handoff reference from user: `ce4a72b1 docs: add session freshness handoff rule`

## Current Slice

- Slice: Workflow foundation docs and structural docs guard.
- Scope: Docs and one docs truth test only.
- Product behavior changes: none.
- New accounts/tools/plugins/MCP/hooks/automations: none.
- Live preview requirement: skipped for this docs/test-guard slice. Live preview is required for later substantial app-facing work when device ownership is clear.

## Dirty Files To Preserve

- `apps/aquarium_app/test/widget_tests/reminders_screen_test.dart`
  - Paused Reminders resilience test from a separate data-safety slice.
  - Do not stage, format, rewrite, or commit it as part of workflow foundation.

## Last Checks

- `git status --short -uall` run before editing.
- `git diff --check` passed before commit `774fd154`.
- Foundation docs checks are pending until the new docs and guard test are written.

## Device And Preview State

- Dedicated preview target: `danio_api36`.
- Last known state from this session: live preview was launched before this docs-only foundation work.
- Before relying on preview or capturing evidence, rerun:

  ```powershell
  .\scripts\run_danio_live_preview.ps1 -CheckOnly
  ```

- If Flutter tests hang while a live preview terminal is attached, detach or
  quit live preview cleanly with `d` or `q`, rerun the docs checks, then
  restart preview only if useful.

## Blockers

- None known for the docs foundation slice.
- Whole-app phone/tablet evidence remains blocked until stable Android device
  ownership and transport are confirmed.

## Next Action

Finish the foundation slice:

1. Create/update `WORKFLOW_CHARTER.md`, `RESEARCH_PROTOCOL.md`,
   `SCREEN_INVENTORY.md`, `SLICE_LOG.md`, `HOUSEKEEPING.md`,
   `QUALITY_LADDER.md`, and `SOURCE_REFERENCES.md`.
2. Link them from the existing entry docs.
3. Extend `test/copy/current_docs_local_truth_test.dart`.
4. Run docs gates.
5. Commit the foundation docs and update this handoff with final commit state.

