# Danio Multi-Agent Workflow

Danio can use Codex subagents to speed up autonomous completion work, but the
main coordinator is the only writer and remains responsible for repo state,
integration, verification, durable evidence, commits, pushes, and task
creation. Every registered repo-local agent is a read-only auditor.

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
- `danio_android_qa_owner`: repository-read-only runtime observer for one
  coordinator-supplied immutable commit/APK and coordinator-assigned serial
  after device ownership is clear.

`.codex/agents/danio_worker.toml` is retained but de-registered. The phone
completion program must not invoke it or any other implementation subagent.

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
- Perform every repository and installed-skill write directly as the sole
  coordinator.
- Own every stage, commit, merge, push, durable evidence-file write, and task
  creation action.
- Run the required local gates.
- Commit and push focused slices from the coordinator-controlled checkout.

## Single-Writer Rules

Registered subagents are inspection-only. Their repository command allowlist is
exactly:

```text
rg
Get-Content
git show
git log
git diff --no-ext-diff
GIT_OPTIONAL_LOCKS=0 git --no-optional-locks status
```

They must not run fetch, checkout, add, commit, push, package resolution,
Flutter/Gradle test/build/analyze, generators, quality wrappers, background
processes, Figma writes, task creation, or account-backed actions. Non-Android
auditors also do not run ADB/emulator commands; Android QA has only the narrow
serial-scoped runtime exception below. They must not edit files or start
background/persistent processes. A need outside the allowlist is reported as
`BLOCKED` to the coordinator.

All allowlisted reads stay under the coordinator-supplied repository root:
`rg` has an explicit repo-relative search root and never uses `--pre` or
`--pre-glob`; `Get-Content` uses `-LiteralPath` with a repo-relative path; Git
uses `GIT_PAGER=cat`, `--no-ext-diff`, and `--no-textconv` where applicable and
never uses helpers, pagers, redirection, `--output`, or output-writing options.

## Android QA Rules

`danio_android_qa_owner` remains repository-read-only. Before any assigned
runtime observation, it must read `DEVICE_OWNERSHIP.md` and receive all three
immutable inputs from the coordinator:

- exact commit identity
- exact APK identity/path
- exact assigned serial and allowed runtime commands

It may then use only the assigned serial/runtime commands. It may not build,
resolve packages, run Flutter/Gradle tests or analyze, edit, stage, commit,
write evidence files, or use another device. The only test exception is the
exact coordinator-assigned local Patrol command described below. It returns
screenshots/logs/observations to the coordinator, which owns any durable
evidence-file write. Missing or ambiguous identity, ownership, or command
scope is `BLOCKED` without device action.

Only `adb devices` may be unscoped. Every device-affecting ADB command uses
`adb -s <assigned-serial>` with the exact coordinator-assigned serial. This
overlay overrides older unscoped examples in `DEVICE_OWNERSHIP.md`. Local
Patrol is allowed only as an exact coordinator-assigned serial-bound command.

For an assigned local live preview observation, use
`LIVE_PREVIEW_WORKFLOW.md` only as contextual guidance. This stricter Android
QA overlay controls and the live preview workflow does not expand its command,
write, evidence, or ownership authority.

Account-backed Android/device lanes remain forbidden for this overlay.

## Command Working Directories

- The coordinator runs `git status --short -uall`, `git diff --check`, Git
  mutation commands, and repo-wide checks from the repo root.
- The coordinator runs Flutter, Dart, and local quality-gate commands from
  `apps/aquarium_app`. Read-only auditors may recommend these commands but do
  not run them.
- Direct ADB/emulator commands and local Patrol run only from the
  repository-read-only Android QA context after immutable commit/APK identity,
  assigned serial, ownership, and exact runtime commands are clear.

## Verification Order

The coordinator uses local checks before optional account-backed checks;
auditors only inspect and recommend:

1. Focused test for the changed area.
2. `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`.
3. Broaden to `Docs`, `Visual`, `AndroidPrep`, or `Full` based on touched files.
4. Assign local Patrol or Android screenshots to Android QA only when immutable
   commit/APK identity, serial-bound commands, and device ownership are clear.
5. While the autonomous phone overlay is active, do not use account-backed
   Android/device or review lanes. Outside this overlay, the coordinator may
   use an explicitly approved account-backed lane only after local gates and
   with no secrets committed.

External services are review aids. They do not replace local Flutter tests,
analysis, content validation, visual baselines, or debug APK builds.
