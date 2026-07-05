# Danio Multi-Agent Workflow

Danio can use Codex subagents to speed up autonomous completion work, but the
main coordinator remains responsible for repo state, integration, verification,
commits, and pushes.

This workflow is subordinate to `WORKFLOW_CHARTER.md`,
`COMPLETE_LOCAL_CLOSURE_LEDGER.md`, `VERIFIED_SLICE_EXECUTION_CONTRACT.md`,
`COMPLETE_LOCAL_FORECAST.md`, `RESEARCH_PROTOCOL.md`, `ACTIVE_HANDOFF.md`,
`SLICE_LOG.md`, and `QUALITY_LADDER.md`. Use `SCREEN_INVENTORY.md` when
subagents audit or review screen/page coverage.

## Standard Agent Layout

Use at most six open project agents:

- `danio_product_auditor`: read-only product, content, Smart Hub, learning,
  species, and local-first completeness audit.
- `danio_ui_auditor`: read-only visual, design-system, accessibility,
  screenshot, and golden-baseline audit.
- `danio_quality_auditor`: read-only test, script, lint, gate, and
  verification audit.
- `danio_reviewer`: read-only post-slice reviewer for regressions, product
  truth, missing tests, and local-first rule violations.
- `danio_worker`: implementation worker for one assigned git worktree and one
  disjoint file/module ownership area.
- `danio_android_qa_owner`: single owner for emulator, ADB, Patrol, Firebase
  Test Lab, and Android screenshot evidence after device ownership is clear.

The repo-local Codex config lives under `.codex/`. Project sessions must trust
the repo before project-scoped Codex config and agents are loaded.

Do not store secrets, access tokens, account exports, machine-local paths, or
temporary device state in `.codex/`.

## Coordinator Responsibilities

- Run `git status --short -uall` before edits, before staging, and before
  committing.
- Keep the main checkout clean and preserve unrelated dirty work.
- Choose one small completion slice at a time.
- Dispatch read-only auditors for discovery and verification gaps.
- Assign implementation workers only to explicit worktrees and disjoint files.
- Review and integrate worker output before staging.
- Run the required local gates.
- Commit and push focused slices from the coordinator-controlled checkout.

## Worker Rules

Use `danio_worker` only when all of these are true:

- The task is bounded and testable.
- The worker has an explicit git worktree path.
- The worker has exact file/module ownership.
- The write set does not overlap with other agents or active dirty work.
- The coordinator will review the result before integration.

Workers must stop and report `BLOCKED` if they are not in the assigned
worktree, if needed files are dirty from another session, or if the task
requires product decisions outside the assigned slice.

Workers use local gates by default. Optional network/account-backed tools such
as OSV, Firebase Test Lab, BrowserStack/App Percy, Percy, Qodo, Sentry,
Crashlytics, Figma paid features, and CodeRabbit are forbidden unless the
current coordinator prompt explicitly assigns that lane and
`PAID_TOOL_APPROVAL_LEDGER.md` covers the exact use.

## Android QA Rules

Only `danio_android_qa_owner` should coordinate Android device work. Before any
install, tap, screenshot, Patrol run, logcat capture, or cloud/device-lab run,
the QA owner must confirm:

- `adb devices` output.
- The selected device ID.
- No other Codex session owns the device.
- The intended APK/build and flow.

If ownership is unclear, stop at compile/build checks such as `AndroidPrep`
without device interaction.

The live preview lane is also Android QA ownership. Use
`docs/agent/LIVE_PREVIEW_WORKFLOW.md` when the user wants to watch the app
during implementation. Only the coordinator or `danio_android_qa_owner` should
run `scripts/run_danio_live_preview.ps1`,
`scripts/capture_danio_screen.ps1`, or any related emulator controls.

## Command Working Directories

- Run `git status --short -uall`, `git diff --check`, `git worktree`, and
  repo-wide `rg` commands from the repo root.
- Run Flutter, Dart, Patrol, and local quality-gate commands from
  `apps/aquarium_app`.
- Run Android device commands only from the Android QA owner context after a
  device ID and ownership are clear.

## Verification Order

Use local checks before optional account-backed checks:

1. Focused test for the changed area.
2. `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`.
3. Broaden to `Docs`, `Visual`, `AndroidPrep`, or `Full` based on touched files.
4. Use Patrol or local Android screenshots only when device ownership is clear.
5. Use Firebase Test Lab, CodeRabbit, Qodo, Sentry, BrowserStack, or Percy/App
   Percy only after local gates, with no secrets committed and with approval
   recorded for the exact paid/account-backed use.

External services are review aids. They do not replace local Flutter tests,
analysis, content validation, visual baselines, or debug APK builds.
