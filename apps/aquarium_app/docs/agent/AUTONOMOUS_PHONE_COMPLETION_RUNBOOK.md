# Danio Autonomous Phone Completion Runbook

Status: Installed runner contracts pinned; launch and operational chaining
remain disabled
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
- `runner_compatible` is `true` for the reviewed installed bytes.
- `authorizes_launch` is `false`.
- Installed runner hashes and compatibility-contract hashes are pinned to the
  independently reviewed exact bytes in `runner_compatibility.json`.
- No operational run-state file exists. Only Task 13 may create
  `apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json`.
- The JSON files under
  `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/` are
  normative test fixtures. They are not live leases, budget authority, or
  permission to perform product work.
- Before Task 13, the bootstrap-budget block in `ACTIVE_HANDOFF.md` is the only
  machine-readable unit counter, and it changes only at durable clean closeout.

`RUNNER_COMPATIBLE` is now the expected compatibility result for the reviewed
installed bytes. Launch remains blocked by `authorizes_launch: false`; the
Task 8 writer-claim transaction does not authorize operational chaining or
create live state. Task 9 implements and fixture-proves evidence validation,
closeout, finalization, and exactly-once charging, but does not activate them.
Task-tool successor capability, rehearsal, and activation remain with Tasks 10
through 13.

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
`state_revision`, the parent-derived authority snapshot, and
`control_surface_sync`. It may only resolve the exact previously pending visual
target to `synced` or `failed`; it cannot retarget Figma administration fields.

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

## Atomic Writer Claim

`invoke_autonomous_writer_claim.ps1` is the only Task 8 claim mutation entry
point. It accepts a valid JSON result from `plan_autonomous_writer_claim.ps1`,
an optional repository root, and the fixture-only `TestTransportOutcome`.
Before any production mutation it performs a fresh synchronization and Claim
readiness check. It then re-observes a clean `main`, requires
`HEAD == main == origin/main == base_commit`, reloads the exact committed state
and parent tree, reruns private pure claim-plan validation, re-derives the
owner identity, and rechecks saved-project worktree containment. Only the
strictly guarded disposable transport fixture may replace that live readiness
with its committed plan evidence.

The transaction then:

1. creates the absent deterministic branch and worktree at the planned base
   commit; any pre-existing identity requires explicit recovery proof and Task
   8 fails closed rather than inferring quiescence from process command lines;
2. writes and stages only
   `apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json`;
3. records `git write-tree`, validates the staged transition, runs the Docs
   profile without `-RequireCleanWorktree`, and validates the same staged tree
   again with no unstaged or untracked output;
4. creates one claim commit with the terminal trailers
   `Danio-State-Tree`, `Danio-State-Validation: pass`,
   `Danio-Docs-Profile: pass`, and `Danio-Verified-At`;
5. captures exactly one expanded `origin` push endpoint, validates the
   committed transition, and attempts at most one bounded, noninteractive,
   normal non-force `git push --porcelain HEAD:main` to that immutable endpoint;
   and
6. uses bounded, noninteractive fetches when possible, reconciles the exact
   candidate from the same immutable endpoint, and fast-forwards local `main`
   only when `origin/main` is exactly the candidate.

No claim path force-pushes, rebases, retries a push, decrements budget, edits
product files, or begins product work before local `main` is clean and aligned
at the accepted candidate. A successful claim keeps the deterministic branch
and worktree because that exact identity becomes the product writer.

The compact `danio_writer_claim_result` records the transport observation,
reconciliation status, push attempt count, retry flag, budget-consumed flag,
push-timeout, process-tree termination, explicit target-ref rejection, and
fresh-readiness facts, cleanup and preservation facts,
fixture-equivalence use, owner identity, base, candidate, staged tree, and
observed `origin/main`. Exit `0` means only `WRITER_CLAIM_ACCEPTED`; every
other code exits `1`.

If push process-tree and redirected-stream termination cannot be confirmed,
the result is immediately `PUSH_OUTCOME_UNKNOWN`. The invoker performs no
fetch, retry, rejection classification, or cleanup while that process may still
be able to reach the remote.

A confirmed timeout, disconnect, or unclassified nonzero exit may fetch to
prove that the candidate was accepted or became reachable. Candidate absence
after that ambiguous transport remains `PUSH_OUTCOME_UNKNOWN`; it never permits
cleanup. Only the exact machine-readable porcelain rejection for
`HEAD:refs/heads/main` captured from Git's standard-output stream, followed by
fresh candidate-absence proof, is a definite remote rejection. Standard error
is retained for diagnostics but never supplies rejection proof.

| Fresh evidence | Code | Required disposition |
| --- | --- | --- |
| `origin/main` is the exact candidate and local `main` fast-forwards cleanly | `WRITER_CLAIM_ACCEPTED` | Preserve the accepted branch/worktree |
| Candidate is reachable but `origin/main` advanced, or accepted local alignment is unsafe | `REMOTE_MOVED` | Preserve everything and stop |
| Exact target-ref rejection and fresh history both prove candidate absent | `WRITER_CLAIM_LOST` | Remove only the exact clean rejected branch/worktree |
| Candidate is absent after timeout, disconnect, or unclassified failure | `PUSH_OUTCOME_UNKNOWN` | Preserve everything; no retry or cleanup |
| Fetch or reachability remains unprovable | `PUSH_OUTCOME_UNKNOWN` | Preserve everything; no retry or cleanup |

Definite-rejection cleanup rechecks the candidate parent, owner token, claim
revision, exact worktree registry entry, branch tip, worktree branch and
commit, reparse status, and clean status. It refreshes remote candidate absence
immediately before removal, confirms the worktree registry stayed unchanged,
and prepares an expected-old-object ref deletion before removing the registered
worktree. The prepared ref lock prevents branch movement during removal; the
transaction commits only after normal worktree removal succeeds. Any mismatch
aborts before cleanup and fails closed. If the prepared transaction fails after
worktree removal, the exact candidate ref and clean worktree are restored and
verified. An unprovable restoration is reported as
`REJECTION_CLEANUP_PARTIAL` with recovery required, never as preservation.

The five transport injections are exactly `accepted`, `rejected`,
`unknown_accepted`, `unknown_not_accepted`, and `unknown_unresolved`. They are
rejected unless `DANIO_AUTONOMY_TEST_MODE=1` and the repository is an ordinary
clone below the system temp root with exactly one identical, reparse-free local
bare fetch and push URL in the same fixture.
The fixture-only `rejected` outcome is the sole no-send synthetic rejection
proof and records `push_rejection_proven: true` alongside its non-null
`test_transport_outcome`. `unknown_not_accepted` models candidate absence
without rejection proof, so it preserves artifacts as `PUSH_OUTCOME_UNKNOWN`.
The two-clone fixture may use a second physical clone only after proving both
clones share that bare remote and the exact base tree and state blob. This
fixture-only equivalence never weakens production repository-root identity.

Windows long-path operation is process-local. Git receives ephemeral
`core.longpaths=true`; the Docs child uses a temporary free `subst` drive and
targets dependency validation at that alias while using the short source
checkout for the Dart executable cache. The mapping and isolated temp root are
removed in `finally`. Task 8 proved the real deterministic saved-project
worktree at a 313-character tracked path with PowerShell extended-path access,
Flutter, offline Gradle, and the Docs profile without renaming the project or
changing persistent machine or Git configuration.

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

## Evidence Checkpoint And State Closeout

The product/workflow commit and its evidence manifest are a separate committed,
pushed, clean, aligned parent checkpoint while durable ownership is still
`active` or `finalizing`. The state transaction does not create or push that
checkpoint. It verifies a fresh `origin/main` observation before mutation, then
owns at most one normal non-force state push and never retries it.

A new checkpoint belongs to the current lease only when its exact product
commit and manifest commit are strict descendants of the typed `claim` or
`finalize` transition that established that owner and are both ancestors of the
candidate parent. A pre-owner commit, unreachable side object, or merely local
object cannot satisfy this proof. The last commit that changed the parent state
must be that typed owner transition with exact path scope, tree, trailers, and
historical evidence, and the state bytes must remain unchanged through the
evidence parent.

For owner-releasing transitions, `LeaseReleaseJson` contains exactly
`owner_token`, `android_released`, and `processes_released`. The validator binds
the token to the previous owner and derives branch, worktree registration,
worktree-path, and writer release from live Git and filesystem observations.
Unsafe or ambiguous release returns `STOP_PENDING` before state write, stage,
charge, commit, or push. `finalize` retains the exact owner and rejects release
JSON.

Both staged and committed transition validation load the ledger and manifest
from the exact candidate parent. A caller cannot supply ledger rows, completion
checks, cleanup identity, or a checkpoint commit. Evidence-bearing transition
commits add one terminal trailer:

```text
Danio-Evidence-Manifest: <repository-relative manifest path>
```

Only an emergency `active -> stopped` transition with no historical checkpoint
uses `Danio-Evidence-Manifest: none`; it must preserve a null checkpoint and
prove the recorded recovery commit is reachable from the parent. Historical
stop and finalization-stop paths preserve and validate their existing manifest.
A budget-exhausted normal closeout instead uses `stop` with reason
`BUDGET_EXHAUSTED`, exact post-charge budget zero, and a fresh owned-cursor
checkpoint; it creates no successor and does not advance handoff generation.

The staged validator requires the caller-precomputed candidate tree object ID
and verifies the index against it without writing a tree. Task 9 state commits
must include the run-state path and may additionally include only
`ACTIVE_HANDOFF.md` and `SLICE_LOG.md` for launch/closeout bookkeeping. Product
paths are rejected. Candidate authority is rebuilt from the exact parent:
canonical path, reachable snapshot commit, and exact blob bytes are binding,
without requiring current-origin blob equality or creating candidate
self-reference.

The state transaction stages the run-state path and only already-dirty
`ACTIVE_HANDOFF.md` or `SLICE_LOG.md` closeout updates. It rejects every other
staged, unstaged, or untracked path, validates the staged tree, runs the Docs
profile, proves the tree did not move, validates the committed candidate, and
then performs its single bounded push of the immutable raw candidate object ID
to `main`, never a moving symbolic `HEAD`. Exact rejection plus fresh candidate
absence returns `REMOTE_MOVED`; timeout, unclassified failure, unconfirmed
process-tree termination, or unprovable reachability returns
`PUSH_OUTCOME_UNKNOWN`. Both preserve the candidate and evidence artifacts.
Nullable durable-charge and `owner_retained`/`owner_released` fields report the
exact prior or candidate transition effect whose origin reachability is proven.
`STOP_PENDING` or definite rejection may prove the aligned prior owner; an
exact candidate or reachable candidate ancestor may prove the candidate charge
and owner effect; and local-alignment failure does not erase remote proof. The
fields remain null when reachability is ambiguous. `owned_cleanup_proven`
separately reports physical cleanup. Local alignment failure remains fail closed
and preserves artifacts.

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
Environment identity, durable artifacts, named checks, and overall status are
manifest-level fields. Every check has exactly `code`, `status`,
`command_indexes`, and `artifact_indexes`; indexes are unique, bounded, and
refer to the committed commands or exact-byte artifact hashes. Passing terminal
evidence contains exactly one `FULL`, `ANDROID_PREP`, `CONTENT`, `VISUAL`,
`PRODUCT_TRUTH`, and `PHONE_QA` check.

`closeout` and `complete` may preserve control-surface state or schedule
`pending` against their newly verified product commit. A later nonvisual
checkpoint may preserve the older target. Administrative sync can only resolve
that exact pending target to `synced` or `failed`.

The no-product-change rehearsal records before/after observations and proves
all repository-file, index, local-ref, remote-ref, worktree, task, Android,
Figma, and external-service mutation flags are false. Rehearsal output does not
authorize launch. A later commit must pin and verify the committed report before
authorization can change.

## Handoff Boundary

PowerShell may generate a title, exact marker, and paste-ready prompt. It never
pretends to list, read, create, fork, or message Codex tasks. Task lookup and
creation remain explicit coordinator actions using live tool schemas.

`new_autonomous_handoff_prompt.ps1` accepts strict JSON input contracts:

```json
{
  "list_threads": true,
  "read_thread": true,
  "create_thread.project_target": true
}
```

The task-capability object contains exactly those three booleans. The saved
project object contains exactly `project_id` and `root`. Both saved-project
values are null when live project identity is unavailable; otherwise the ID is
nonempty and the root is an absolute forward-slash Windows path matching the
committed authorization. Unknown fields, wrong types, and mixed null/non-null
identity reject without mutation.

Launch consumes a `Launch` readiness report. Successor consumes a `Claim`
readiness report. A selected task capability can become true only when the
report is eligible and no older than 120 seconds, the runner manifest is both
compatible and rehearsal-authorized, the exact supplied live-state bytes are
committed on clean aligned `main`, repository/project binding is exact, every
required task tool is available, and remaining budget is positive. Until Task
12 and Task 13 establish those facts, the generator remains an honest
paste-ready fallback with both operational task capabilities false.

The compact report always sets `mutations_performed: false`. Valid kind/state
input returns `accepted: true`, a complete prompt, and exit `0` even when the
selected capability is false. Malformed strict input or a kind/state mismatch
returns `accepted: false`, a stable code, the observed mode when parseable,
null generated fields, at least one failed check, and exit `1`.

Launch uses `<run_id>/launch/0` only from launch-authorized `ready`. A successor
uses `<run_id>/<handoff_generation>` only from pushed, clean, aligned
`handoff_ready`. Missing or ambiguous task capabilities or saved-project
identity create nothing and return the full paste-ready prompt.

After a report proves positive capability, the live coordinator follows this
task-tool algorithm without delegating it to PowerShell:

1. Resolve the exact saved Danio project and kind-specific marker.
2. Exhaust `list_threads` pagination for that exact marker.
3. `read_thread` every exact candidate.
4. Reuse one queued or running match without messaging it.
5. Inspect stopped or completed matches and preserve their real stop reason.
6. Create once only when zero exact matches remain and project binding is exact.
7. Verify a returned task with `read_thread`.
8. On multiple matches, ambiguous binding, or unknown create outcome, create
   nothing further, preserve `ready` or `handoff_ready`, and return the prompt.

`send_message_to_thread` is recovery-only. Do not use `fork_thread` for successors.
Use a native idempotency key only when the live create schema actually exposes
one.

During bootstrap, continuation uses only the explicit user-authorized marker
and remaining budget carried by the current task. It is not operational
automatic chaining.

## Hard Boundaries

Workflow setup does not change application Dart behavior, take Android runtime
ownership, edit Figma, use paid/cloud/account/provider/store/deploy state, or
create operational run state before Task 13. Product row `DCL-DR-001` remains
blocked until setup, rehearsal, activation, and explicit launch readiness pass.
