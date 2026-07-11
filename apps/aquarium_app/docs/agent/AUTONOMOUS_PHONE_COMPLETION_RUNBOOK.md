# Danio Autonomous Phone Completion Runbook

Status: Bootstrap contracts defined; launch and operational chaining remain
disabled
Created: 2026-07-11
Scope: Android phone complete-local workflow coordination only

## Purpose

This runbook is the operational contract for the fail-closed coordination
layer described by the approved autonomous phone completion design and its
implementation plan. It does not activate the product run, authorize a writer,
or replace any product authority.

Repository source, tests, Git state, and fresh command output remain factual
truth. The phone completion program owns phase order. The closure ledger owns
row closure state, disposition, evidence, and done conditions. The Finish Map
owns category status and quality-bar summaries.

## Current Bootstrap State

- Automatic operational successor creation is disabled.
- `runner_compatible` is `false`.
- `authorizes_launch` is `false`.
- Installed runner hashes and compatibility-contract hashes are unpinned and
  explicitly `null`.
- No operational run-state file exists. Only Task 13 may create
  `apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json`.
- The JSON files under
  `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/` are
  normative test fixtures. They are not live leases, budget authority, or
  permission to perform product work.
- Before Task 13, the bootstrap-budget block in `ACTIVE_HANDOFF.md` is the only
  machine-readable unit counter, and it changes only at durable clean closeout.

`RUNNER_INCOMPATIBLE` is the intended launch result until the separately
reviewed installed-runner contract is pinned. Setup Tasks 2 through 5 may add
pure contracts and validators while this blocker remains.

## Machine Contract Inventory

All machine schemas are under
`apps/aquarium_app/docs/agent/autonomous_completion/schemas/`:

- `run_state.schema.json`
- `synchronization_receipt.schema.json`
- `readiness_report.schema.json`
- `transition_validation_report.schema.json`
- `writer_claim_plan.schema.json`
- `runner_compatibility.schema.json`
- `evidence_manifest.schema.json`
- `rehearsal_report.schema.json`
- `handoff_prompt_report.schema.json`

Every schema uses JSON Schema draft 2020-12. Every object contract rejects
unknown fields with `additionalProperties: false`. Repository paths use
forward slashes, are relative to the nested repository root, and reject parent
escape. Fields that may be absent in meaning are present with explicit `null`
when the schema defines them as nullable.

Strict UTC timestamps use seven fractional digits and a trailing `Z`, for
example `2026-07-11T12:00:00.0000000Z`. Git object IDs use 40 lowercase
hexadecimal characters. Exact-byte SHA-256 values use 64 hexadecimal
characters with the case required by their field contract.

Machine entry points added by later tasks must use `[CmdletBinding()]`,
`Set-StrictMode -Version Latest`, `$ErrorActionPreference = "Stop"`, and
`-LiteralPath` for filesystem paths. They write exactly one compact JSON object
to stdout. Diagnostics go to stderr or to structured `checks`. Exit `0` means
the request was accepted. Exit `1` means it was rejected with a stable code.

## Run State

The allowed durable modes are exactly:

```text
inactive ready active handoff_ready paused stopped finalizing complete
```

`STOP_PENDING` is task-local lease retention, not a mode. A task must keep the
durable state `active` or `finalizing` while writer, worktree, process, or
Android release is unsafe or unproven.

The state stores lease, budget, cursor, immutable authority references,
recovery pointers, and administrative synchronization status. It does not copy
feature status, row done conditions, the human next action, parked scope, or a
successor task ID.

`owner` is non-null only in `active` and `finalizing`. Those modes retain the
stable token, task ID, claim revision, parent commit, staged tree, branch,
worktree identity, claim time, and lease state. Every other mode has
`owner: null`; durable `stopped` additionally requires proven writer and device
lease release.

Product completion has one derived definition:

```text
product_complete := run_state.mode == "complete"
```

There is no stored `product_complete` field. The containing Git commit is the
state commit. A state document never stores its own future commit hash.

## Budget Contract

The approved count is a number of claimed task units, not a token budget. The
remaining count includes the current unit.

- A successful writer claim changes the current charge from `none` to
  `pending` and does not decrement the budget.
- Ordinary closeout, pause, durable stop, or entry into finalization consumes
  the pending charge exactly once.
- `finalizing -> complete` and `finalizing -> stopped` never decrement again.
- A pre-claim exit or `WRITER_CLAIM_LOST` consumes zero units.
- Recovery of an abandoned pending charge requires explicit user approval and
  consumes that unit when it is durably closed or stopped.
- `consumed_units + remaining_units_including_current` must equal
  `total_approved_units`. This arithmetic is enforced by pure PowerShell
  validation, not by JSON Schema.
- A post-closeout remaining count of zero stops without a successor.

The normative inactive fixture models the original bootstrap authorization as
20 total, 1 consumed, and 19 remaining. It does not override the later live
bootstrap counter in `ACTIVE_HANDOFF.md`.

## Transition Matrix

Only these transition/action pairs are allowed:

| From | To | Action |
| --- | --- | --- |
| `inactive` | `ready` | `launch` |
| `ready` | `active` | `claim` |
| `handoff_ready` | `active` | `claim` |
| `ready` | `stopped` | `preclaim_stop` |
| `handoff_ready` | `stopped` | `preclaim_stop` |
| `active` | `handoff_ready` | `closeout` |
| `active` | `paused` | `pause` |
| `active` | `stopped` | `stop` |
| `active` | `finalizing` | `finalize` |
| `finalizing` | `complete` | `complete` |
| `finalizing` | `stopped` | `finalization_stop` |
| `paused` | `ready` | `resume` |
| `stopped` | `ready` | `resume` |
| `handoff_ready` | `handoff_ready` | `administrative_sync` |
| `complete` | `complete` | `administrative_sync` |

Every durable transition increments `state_revision` by exactly one. A
same-mode administrative transition may change only transition metadata,
`state_revision`, and `control_surface_sync`.

An absent live-state path is valid only for Launch readiness. The inactive
fixture is the conceptual parent, Task 13 stages revision 1, and activation
applies the bootstrap charge arithmetic without writing a durable inactive
file.

## Owner Token

The stable owner token is the lowercase SHA-256 of the UTF-8 bytes of these
four values joined by a single line feed and no trailing line feed:

```text
run_id
work_unit_id
task_id
expected_state_revision
```

Branch and worktree identities use the first 12 token characters. Worktrees
are allowed only below the saved project root at `.codex-worktrees/<id>`.

## Ledger Parsing

Pure ledger parsing reads only the formal `Active Findings` and
`Closed, Accepted, Or Superseded Findings` tables in
`COMPLETE_LOCAL_CLOSURE_LEDGER.md`.

Parsing rejects a missing or repeated heading, malformed row width, duplicate
ID, unknown closure state, or literal unescaped pipe in a cell. It preserves
escaped pipes as cell content. The allowed closure states are `open`, `closed`,
`parked`, and `decision_required`.

`PHASE_PARKED` and `EXTERNAL_PARKED` require `parked` closure state.
`ACCEPTED_LOCAL_LIMITATION` and `NOT_CURRENT_ARCHIVED` require `closed`.
Bootstrap evidence currently reports 18 open, 5 parked, 4 closed, and zero
decision-required rows, but runtime validation must accept later valid rows and
must never freeze those counts. `DCL-RC-001` is the final active phone-program
row, even though a physically later parked row remains in the Markdown table.

## Pure Validation Boundary

Pure validation performs no fetch, stage, commit, push, branch or worktree
creation, task creation, filesystem write, runtime mutation, Figma action,
account action, or external call.

The pure module validates ledger rows, state shape and arithmetic, transition
action and revision, owner nullability and token retention, charge semantics,
administrative deep comparison, and normalized completion-readiness inputs.

Synchronization is a separate coordinator-owned mutation added by a later
task. Its ephemeral receipt records the exact `git fetch --prune` invocation,
nonce, resolved root, completion time, `origin/main`, and ahead/behind counts.
The readiness command consumes that receipt and remains pure.

## Completion Readiness

Terminal readiness is evaluated while the candidate parent is `finalizing`,
before the transition that records `complete`. It is false unless all of these
are proven by normalized inputs:

- the retained owner token is valid;
- every active phone row other than `DCL-RC-001` is closed;
- the final evidence checkpoint closes `DCL-RC-001`;
- no active-scope row remains `open` or `decision_required`;
- every parked row remains outside active scope;
- Full, AndroidPrep, content, visual, product-truth, and phone-QA evidence
  matches the aligned parent checkpoint; and
- the exact owned branch, worktree, and device cleanup is proven.

The guard does not require the candidate state already to be `complete`.

## Runner Compatibility

`apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json`
is the
repository-owned compatibility authority. While `authorizes_launch` is false,
`launch_proof` must be null. If a later reviewed commit sets launch
authorization true, `runner_compatible` must also be true and `launch_proof`
must pin a committed rehearsal report path, its exact-byte lowercase SHA-256,
and its containing commit.

A digest or semantic mismatch returns `RUNNER_INCOMPATIBLE`. Validators never
repair installed skills. Missing task capabilities affect launch/successor
capability separately and do not fabricate runner incompatibility.

## Evidence And Rehearsal

Evidence manifests are named by the exact product commit plus `.json`. The
filename and `product_commit` field must match. Each command record includes
only the command, exit code, and strict UTC start and completion timestamps.
Environment identity, durable artifacts, and overall status are manifest-level
fields.

The no-product-change rehearsal records before/after observations and proves
all repository-file, index, local-ref, remote-ref, worktree, task, Android,
Figma, and external-service mutation flags are false. Rehearsal output does not
authorize launch. A later commit must pin and verify the committed report before
authorization can change.

## Handoff Boundary

PowerShell may generate a title, exact marker, and paste-ready prompt. It never
pretends to list, read, create, fork, or message Codex tasks. Task lookup and
creation remain explicit coordinator actions using live tool schemas.

Launch uses `<run_id>/launch/0` only from launch-authorized `ready`. A successor
uses `<run_id>/<handoff_generation>` only from pushed, clean, aligned
`handoff_ready`. Missing or ambiguous task capabilities or saved-project
identity create nothing and return the full paste-ready prompt.

During bootstrap, continuation uses only the explicit user-authorized marker
and remaining budget carried by the current task. It is not operational
automatic chaining.

## Hard Boundaries

Workflow setup does not change application Dart behavior, take Android runtime
ownership, edit Figma, use paid/cloud/account/provider/store/deploy state, or
create operational run state before Task 13. Product row `DCL-DR-001` remains
blocked until setup, rehearsal, activation, and explicit launch readiness pass.
