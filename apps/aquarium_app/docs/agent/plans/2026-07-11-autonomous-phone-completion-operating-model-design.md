# Danio Autonomous Phone Completion Operating Model Design

- **Status:** Approved design for repository implementation planning
- **Date:** 2026-07-11
- **Decision owner:** User
- **Implementation state:** Not started
- **Product scope:** Android phone complete-local only

## Purpose

Define the operating model that will let Codex complete Danio's remaining
phone complete-local work with high autonomy while preserving repository
truth, data safety, verification quality, context freshness, and explicit stop
conditions.

This design prepares the workflow for a later user-launched development push.
It does not launch that push, authorize an autonomous-unit budget, change
application behavior, take Android runtime ownership, or reopen parked product
scope.

## Problem Statement

Danio already has the important completion assets:

- a finite issue register in `../COMPLETE_LOCAL_CLOSURE_LEDGER.md`;
- an ordered execution program in
  `2026-07-11-phone-complete-local-completion-program.md`;
- a risk-based gate contract in `../QUALITY_LADDER.md`;
- source-of-truth handoff and history in `../ACTIVE_HANDOFF.md` and
  `../SLICE_LOG.md`;
- specialist read-only and implementation agent definitions in
  `../MULTI_AGENT_WORKFLOW.md` and `.codex/`;
- a verified phone atlas and completion control surface in Figma; and
- clean-checkpoint continuation rules in the installed Danio and verified
  slice-runner skills.

The remaining weakness is orchestration. A long completion program needs a
small, durable control layer that can answer these questions without relying
on a growing conversation transcript:

1. What exact lane is authorized now?
2. What was the last clean verified checkpoint?
3. What may the current coordinator change?
4. Which read-only auditors should run for this lane?
5. What evidence is required before merge and continuation?
6. When must the run stop for a user decision?
7. When and how should a fresh project-scoped task take over?

## Locked Decisions

The following decisions are part of this design and require a fresh user
decision to change:

- Use one writing coordinator.
- Use parallel repository agents only for read-only audit, test analysis,
  evidence analysis, and review. The Android QA owner is a separately
  serialized runtime-mutating role that remains repository-read-only.
- Do not use concurrent writing agents during this completion program.
- Keep live Git, repository source, tests, and gates authoritative for factual
  behavior, with canonical document ownership defined per field below.
- Keep Figma as the visual control surface, not the implementation source of
  truth.
- Keep tablet, cloud, accounts, hosted sync, provider/API-key expansion,
  premium, store/deploy, public release, and iOS parked.
- Keep the app useful without Optional AI or a provider key.
- Require an explicit user launch and explicit integer autonomous-unit budget
  before autonomous implementation starts.

## Goals

- Make each autonomous work unit narrow, evidence-backed, and reversible.
- Preserve one clear writer and one integration owner.
- Use parallel read-only analysis to improve speed and review depth without
  creating merge conflicts.
- Make every continuation reconstructible from committed repository state.
- Rotate to fresh project-scoped tasks at clean checkpoints before context
  quality degrades.
- Match verification cost to behavioral and data risk.
- Stop automatically when the phone complete-local bar is genuinely met.
- Stop safely when product direction, external approval, ownership, or
  repository state is ambiguous.

## Non-Goals

- Running an unattended operating-system daemon or scheduled coding task.
- Treating a single Codex goal as an open-ended instruction to finish every
  unrelated backlog item.
- Replacing local gates with CodeRabbit, Firebase Test Lab, Percy,
  BrowserStack, Figma, or another hosted service.
- Adding parallel writing simply because multiple agent slots are available.
- Adding broad test dependencies, coverage targets, mutation testing, or
  performance infrastructure without a demonstrated lane-specific benefit.
- Expanding the accepted Living Tank, rewards, plant, decoration, or seasonal
  product boundaries without a new ledger decision.

## Evaluated Operating Models

### Model A: Fully Sequential Single Agent

One agent performs discovery, implementation, verification, review, merge,
and handoff.

**Advantages**

- Lowest coordination cost.
- No concurrent repository activity.
- Simple ownership.

**Disadvantages**

- Slow on source and test inventory work.
- No independent review perspective.
- Exploration logs and implementation reasoning compete for main-task
  context.

### Model B: One Writer With Parallel Read-Only Auditors

One coordinator owns every write and integration decision. Relevant
specialists inspect source, tests, screenshots, Figma, gates, or diffs in
parallel and return concise evidence summaries.

**Advantages**

- Preserves single-writer safety.
- Moves noisy exploration and review away from the coordinator context.
- Adds independent product, quality, UI, and regression perspectives.
- Reuses Danio's existing specialist agent configuration.

**Disadvantages**

- Uses more model work than a single-agent run.
- Requires explicit dispatch scopes and concise result contracts.
- The coordinator must resolve conflicting findings.

**Decision:** Adopt Model B.

### Model C: Parallel Writing Worktrees

Several agents implement disjoint slices in separate Git worktrees and a
coordinator integrates them.

**Advantages**

- Highest theoretical throughput for truly independent work.
- Useful for large, mechanically separable programs.

**Disadvantages**

- Higher merge, stale-base, and duplicated-work risk.
- Poor fit for Danio's shared providers, storage services, app shell, design
  system, completion ledger, and Android runtime.
- Makes evidence and ownership harder to reason about during data-resilience
  and release-candidate work.

**Decision:** Do not use Model C in this completion program. Reconsider only
under a new user-approved operating-model change for a demonstrably disjoint
future lane.

## Canonical Authority By Field

There is no single prose document that owns every kind of state. Live Git,
source, tests, and fresh command output always override stale factual claims.
For planning fields, ownership is explicit:

| Field | Canonical owner |
| --- | --- |
| Active product boundary and ordered completion phases | `plans/2026-07-11-phone-complete-local-completion-program.md` |
| Closure IDs, dispositions, evidence, and exact done conditions | `COMPLETE_LOCAL_CLOSURE_LEDGER.md` |
| Category completion status and quality bar | `FINISH_MAP.md` |
| Verification requirements | `QUALITY_LADDER.md` and `VERIFIED_SLICE_EXECUTION_CONTRACT.md` |
| Latest human-readable checkpoint and next manual action | `ACTIVE_HANDOFF.md` |
| Append-only completed-slice history | `SLICE_LOG.md` |
| Machine lease, run mode, budget counters, and handoff generation | The operational run-state artifact defined below |
| Android ownership policy and ownership history | `DEVICE_OWNERSHIP.md` |
| Live Android device/process observation | Fresh, serial-scoped runtime preflight output |
| Installed runner compatibility | A repository-owned compatibility manifest and validator |
| Figma administrative synchronization status | The `control_surface_sync` field in operational run state |
| Visual state and gap presentation | The Figma phone atlas, downstream of repository proof |

The operational state stores identifiers and immutable references to these
owners. It does not copy issue status, done conditions, feature status, the
human next action, or the parked-scope list.

Current repository docs contain a known ordering contradiction: the accepted
phone completion program places Optional AI before normal-user P1 depth, while
the generic Finish Map selector places P1 before P3 Optional AI and the ledger
currently says the Finish Map owns rank. Repository implementation must
reconcile those statements in favor of the user-approved phone completion
program before any autonomous launch. Until that reconciliation passes its
guard test, `AUTHORITY_CONFLICT` is a startup stop condition.

The closure ledger also needs an explicit machine-verifiable closure state (or
equivalent schema) before automation can infer completion. Disposition alone
must not be overloaded to mean both work type and closed/open status.

## Roles

### Writing Coordinator

The coordinator is the only role permitted to:

- create or modify repository files;
- derive and create the deterministic claim/slice branch and writable
  worktree;
- stage and commit changes;
- update the closure ledger, handoff, Finish Map, and slice log;
- run integration and clean-main closeout;
- merge and push verified work; or
- create the next project-scoped completion task.

The coordinator remains accountable for checking all auditor claims against
the live repository before using them to justify a change.

### Product Auditor

Use for scope, feature completeness, product truth, content boundaries, and
whether a candidate finding belongs in complete-local. It must not edit files.

### Quality Auditor

Use for test inventory, gate selection, dependency hygiene, failure-path
coverage, and verification gaps. It must not edit files or run Android.

### UI Auditor

Use for current screenshots, Figma frames, design-system consistency,
accessibility, visual baselines, text fit, reduced motion, and haptics. It must
not edit files, Figma, or runtime state.

### Independent Reviewer

Use after the coordinator has a reviewable diff and focused proof. It reports
bugs, regressions, missing tests, product-truth drift, and scope violations in
severity order. It must not edit files.

### Android QA Owner

Use only when the active lane requires runtime evidence and after
`DEVICE_OWNERSHIP.md` preflight. It is the sole Android/ADB/emulator owner for
that runtime window. It may install, launch, tap, capture, or otherwise mutate
the owned Android runtime, but it remains repository-read-only. Every runtime
dispatch is pinned to an immutable commit and APK identity. The coordinator
freezes repository edits for that evidence window, then resumes only after the
owner releases runtime control and returns its evidence.

## Auditor Dispatch Policy

- Dispatch only independent, lane-relevant questions.
- Pin every repository auditor to an exact base commit, branch diff, or staged
  tree identity.
- Prefer two focused auditors over using all configured slots by default.
- Add the third specialist only when the lane crosses product, UI, and quality
  boundaries.
- Dispatch the independent reviewer after implementation, not as a duplicate
  of discovery.
- Require each auditor to return: verified facts, actionable findings, exact
  files/tests/evidence, unresolved questions, and a clear no-findings statement
  when appropriate.
- Do not ask two auditors to answer the same broad question.
- Do not allow auditor output to change ledger status by itself.
- Do not dispatch `danio_worker` while the autonomous phone completion run is
  active. Repository implementation must enforce this overlay in `AGENTS.md`,
  `MULTI_AGENT_WORKFLOW.md`, the chain prompt, and the repo-local agent
  configuration or agent instructions.

Repository-read-only means observational commands that do not update files,
refs, indexes, dependency caches, generated output, devices, processes, or
external services. The normal auditor allowlist is source/document reads with
`rg` or `Get-Content`, plus non-mutating Git inspection such as `git show`,
`git log`, `git diff --no-ext-diff`, and `git --no-optional-locks status`.
Auditors must not run fetch, checkout, add, commit, package resolution, Flutter
or Gradle tests/builds/analyze, generators, quality-gate wrappers, ADB, emulator
commands, or background processes. The coordinator owns those actions. An
auditor may run a mutating command only inside an explicitly approved,
disposable isolated environment that cannot affect the source checkout,
shared caches, runtime, or external state; otherwise it asks the coordinator
to run the command and returns the requested evidence.

## Durable Run State

Repository implementation should add one small machine-readable operational
state artifact. It is a lease, budget counter, and continuation cursor, not a
second backlog or handoff narrative.

The state must represent at least:

- schema version;
- run identifier;
- monotonically increasing state revision;
- mode: `inactive`, `ready`, `active`, `handoff_ready`, `paused`, `stopped`,
  `finalizing`, or `complete`;
- immutable references and content digests for the approved scope/sequence
  document and closure ledger;
- current phase identifier and authorized finite work-unit ID;
- current ledger row IDs as references only;
- owner task ID while active or finalizing;
- stable owner token, owner claim revision, claim parent/base commit, claim
  staged-tree hash, deterministic owned branch/worktree identity, and claim
  timestamp;
- total approved autonomous units, consumed units,
  `remaining_units_including_current`, and the current unit's pending/consumed
  charge status;
- monotonically increasing handoff generation;
- last verified product or workflow commit and its evidence-manifest path;
- normalized repeated-failure signature and attempt count when applicable;
- stop reason code; and
- emergency recovery pointers for an unfinished branch/worktree when needed;
- `control_surface_sync` status, target commit, Figma file/node identifiers,
  attempt timestamp, and evidence or normalized failure reference.

The budget is a count of autonomous task units, not a Codex goal token budget.
It follows the installed verified-slice runner contract: the remaining count
includes the current slice or epoch. A writer claim marks that unit `pending`
but does not decrement the budget. A typed closeout, pause, emergency stop, or
entry into finalization consumes the current unit exactly once before deciding
whether a successor is permitted. A budget of one therefore lets the current
unit finish and leaves zero units for a successor. A rejected writer claim
consumes no unit. Recovery from an abandoned active claim is user-approved and
must consume that pending unit when it is closed or stopped; it is never
silently returned to the budget.

The state must not store copied feature status, ledger done conditions,
human-readable next action, a duplicated parked-scope list, or a latest
successor task ID. Those fields remain with their canonical owners.

The active claim artifact also does not contain its own future commit SHA. Its
containing Git commit is the claim commit, identified from the transition
revision and Git history; later closeout state may reference that now-known
commit. This is the same non-self-referential rule used for other state commits.

## Run-State Transitions

Only these transitions are permitted:

| From | To | Guard and required action |
| --- | --- | --- |
| `inactive` | `ready` | Explicit user launch, approved positive unit budget, compatible runner contract, authority reconciliation complete, and clean aligned preflight. |
| `ready` or `handoff_ready` | `active` | Positive remaining budget and a compare-and-swap writer claim succeed; record the stable owner token, deterministic branch/worktree identity, and pending unit charge without decrementing the remaining budget. |
| `ready` or `handoff_ready` | `stopped` | A pre-claim blocker is suitable for durable recording and a clean aligned compare-and-swap stop commit succeeds; no unit is consumed. If a safe CAS commit is impossible, this is only a task-local exit and run state does not change. |
| `active` | `handoff_ready` | Current unit reaches a clean pushed checkpoint, completion readiness is false, no stop condition applies, and the post-decrement remaining count is positive; consume the unit once, release owner, and advance handoff generation. |
| `active` | `paused` | The current unit reaches its normal clean closeout and the user requests a pause; consume the unit once, release owner after verified cleanup, and create no successor. Mid-unit interruption uses the stopped/emergency path instead. |
| `active` | `stopped` | A stop condition, zero post-decrement budget, or emergency-stop record applies; consume the current unit once, prove the writer lease is released, and create no successor. If release is unsafe or unproven, remain `active` under task-local `STOP_PENDING`. |
| `active` | `finalizing` | The authorized unit is `DCL-RC-001`, all non-release-candidate prerequisites are closed, and its closeout starts terminal proof; consume the unit once but retain the owner through finalization. |
| `finalizing` | `complete` | Final evidence, `DCL-RC-001` closure, parent-commit alignment, temporary-worktree cleanup, and the completion-readiness guard all pass; write the typed terminal transition, release owner, push it, and confirm terminal alignment. The guard does not require the state already to be `complete`. |
| `finalizing` | `stopped` | Final proof or terminal push cannot finish safely; record exact recovery evidence and prove the writer lease is released. If release is unsafe or unproven, remain `finalizing` under task-local `STOP_PENDING`. The unit was already consumed on entry to `finalizing`. |
| `paused` or `stopped` | `ready` | Fresh explicit user resume/relaunch, positive remaining or newly approved budget, and a new readiness pass; stale ownership is never stolen automatically. |
| `handoff_ready` or `complete` | same mode | A compare-and-swap administrative update may change only `control_surface_sync` metadata; it cannot change budget, phase, product evidence, ownership, or authorize product work. |

Every durable transition uses the staged-tree protocol: derive it from the
expected parent revision, stage only allowed paths, prove no unstaged/untracked
changes in that checkout, validate schema and transition guards against the
index, run the required state-only Docs profile, confirm the index tree hash is
unchanged, and prove the checkout is still free of unstaged/untracked output.
Then commit with verification trailers, recheck cleanliness, and normally push
through the remote fast-forward boundary. After push, recheck clean status and
remote symmetry before the new mode is operationally eligible for handoff or
successor creation. This applies to launch, claim, pause, pre-claim stop,
resume, emergency stop, finalization, terminal completion, and same-mode
administrative updates, not only ordinary slice closeout. Readiness revalidates
the committed transition at the next entry.

A task that stops mid-slice may write a typed emergency-stop state commit from
a clean `main` checkout while preserving unfinished work on its named
branch/worktree. That record must name dirty files, relevant processes,
recovery commands, and the last clean product checkpoint. It does not create a
successor or transfer budget automatically.

Durable `stopped` always means the writer lease and any Android ownership are
released. When a task cannot prove safe release, it must not write `stopped`:
the durable mode remains `active` or `finalizing`, the owner token remains
authoritative, and the task reports local `STOP_PENDING` with exact recovery
evidence. Only explicit user-approved recovery may later release that lease.

## Atomic Writer Claim

Single-writer ownership must be enforced, not merely requested:

1. The candidate coordinator performs the synchronization step and pure
   readiness validation below.
2. It derives one deterministic branch name, logical worktree ID, normalized
   worktree path, and stable owner token from the run ID, work-unit ID, task ID,
   and expected state revision. It creates that isolated branch/worktree from
   the exact current `origin/main` and prepares the typed claim commit there.
   The commit records those intended ownership values, the expected revision,
   and a `pending` unit charge; it does not decrement the budget.
3. It attempts a normal non-force push of that claim commit to `origin/main`.
   The remote fast-forward check is the compare-and-swap boundary.
4. Only the successful claimant may fast-forward local `main`, then reuse that
   exact recorded branch/worktree for product work, dispatch auditors, or edit
   product files. It must not create a different product worktree after claim.
5. A rejected claimant must not repair, rebase, retry, or edit product code. It
   removes only its isolated unpushed claim branch/worktree after verifying the
   resolved paths and stops task-locally with `WRITER_CLAIM_LOST`; the run state
   and budget remain unchanged.

If the deterministic branch/worktree identity already exists, the claimant may
reuse it only when its owner token, expected revision, commit, and process state
match exactly. Any ambiguous or foreign occupant is an ownership conflict and
must not be deleted or repurposed automatically.

No task may steal or expire an active claim automatically. Recovery from an
apparently abandoned owner requires proof that no relevant task, process,
branch, worktree, or Android owner remains active plus explicit user approval.

The brief interval in which the successful claim reaches `origin/main` before
local `main` is fast-forwarded is part of one claim transaction. No product
work begins during that interval.

### Indeterminate Push Outcomes

A timeout, connection loss, or missing command result is not a rejected push;
the remote may already have accepted it. Any claim, evidence-checkpoint, state,
or terminal push with an indeterminate result enters task-local
`PUSH_OUTCOME_UNKNOWN` and preserves its commit, branch/worktree, owner token,
and recovery data. It must not retry, delete, release ownership, create a
successor, or report success yet.

The coordinator performs a fresh fetch when possible and reconciles the exact
candidate commit and owner token against `origin/main`:

- if the remote tip is the exact candidate commit, treat the original push as
  accepted and continue with normal post-push checks;
- if the candidate is present but the remote tip has advanced, treat the push
  as accepted followed by `REMOTE_MOVED`; preserve recovery state and do not
  continue or clean up automatically;
- if the remote history proves the candidate was not accepted, apply the
  definite rejection path; or
- if fetch fails or history is still ambiguous, preserve all artifacts and
  remain in task-local `PUSH_OUTCOME_UNKNOWN` (or `STOP_PENDING` when an active
  lease cannot be released) until explicit recovery can prove the outcome.

No cleanup or second push is allowed from an unknown outcome.

## Duplicate-Safe Handoff

For an ordinary unit exit, the active task writes and pushes a state transition
that:

- records the completed unit and exact verified commit/evidence manifest;
- changes the current unit from `pending` to `consumed` and decrements
  `remaining_units_including_current` exactly once;
- releases the owner;
- advances `handoff_generation` exactly once; and
- selects `handoff_ready`, `paused`, or `stopped` from the transition table.

The DCL-RC `active -> finalizing` transition is not an ordinary closeout and
does not use that payload. It records the candidate parent checkpoint, exact
terminal-proof requirements, and consumed DCL-RC charge; retains the owner and
recorded branch/worktree; does not claim a completed-unit evidence manifest;
does not advance handoff generation; and cannot create a successor. Section 6
owns its final evidence and cleanup sequence.

A successor is eligible only from pushed `handoff_ready` state with remaining
units greater than zero. The deterministic marker
`<run_id>/<handoff_generation>` is included in the successor title and prompt.
Before creating a task, the coordinator searches the saved Danio project for
that marker and reuses an existing match. A native idempotency key is used when
the task API exposes one. Otherwise this lookup is best-effort duplicate
suppression, not an exactly-once creation guarantee. If project lookup or
project-scoped creation is unavailable, ambiguous, or would target general
chat, state remains `handoff_ready`, no task is created, and the coordinator
returns the paste-ready prompt. If duplicate tasks are nevertheless created,
only one can win the next compare-and-swap writer claim; all others exit
read-only without consuming budget.

If task creation fails, the state remains safely `handoff_ready` and the same
generation may be retried. The closeout decrement is not repeated.

## Synchronization And Readiness

`git fetch --prune` is an explicit coordinator-owned synchronization action.
It mutates remote-tracking Git metadata and is not described as read-only. A
wrapper must run it immediately before startup validation and again immediately
before merge/closeout validation. On success, the wrapper emits an ephemeral
JSON receipt on stdout containing an invocation nonce, resolved repository
root, exact command, exit code, UTC completion time, fetched `origin/main` SHA,
and ahead/behind result. The receipt is passed directly to the validator and is
not written into the repository. Readiness rejects a receipt older than the
runbook's tested maximum age, set to 120 seconds unless the repository profile
defines a stricter value.

After synchronization, a separate pure readiness command performs no network,
Git-ref, file, device, or external-state mutation. It returns a non-zero exit
code when autonomous work is unsafe to begin.

It must check at least:

- the actual nested repository root;
- current branch and source-of-truth branch policy;
- a valid, fresh synchronization receipt whose nonce, repository root,
  timestamp, fetched SHA, and current `origin/main` all agree;
- clean `git --no-optional-locks status --short -uall` with
  `GIT_OPTIONAL_LOCKS=0`;
- `main...origin/main` symmetry;
- state schema, revision, mode, canonical-reference digests, and transition
  validity;
- active worktrees and temporary branches;
- valid active ledger identifiers;
- a current handoff and completion-program reference;
- a positive `remaining_units_including_current` counter before a new claim;
- canonical authority reconciliation and parked-scope invariants; and
- Android ownership only when an explicit runtime-required flag is supplied.

The validator must not fetch, delete branches, edit state, claim writer/device
ownership, contact external services, or repair a failed condition
automatically.

## Runner Compatibility And Launch Authorization

The repository must not assume that globally installed skills keep stable
semantics. A small compatibility manifest must record the expected installed
paths, content digests or versions, and the semantic clauses Danio depends on:
single-writer behavior, budget including the current unit, decrement at
closeout, charging policy for completed/paused/failed/emergency-stopped and
abandoned units, project-scoped successor creation, handoff-only fallback, and
stop conditions. Readiness computes the current skill digests and validates
those clauses before writer claim.

The currently installed runners are not yet sufficient as an implicit launch
contract: the verified runner supports explicitly approved autonomous chains,
while the Danio runner's default closeout text requires a current-thread user
request before task creation. Repository implementation must reconcile that
difference through a separately reviewed compatible skill/runbook contract.
It must also reconcile this design's rule that a successfully claimed task unit
is charged when closed or stopped with the verified runner's current wording
that describes a budget unit as a completed slice or epoch.
Until then, `RUNNER_INCOMPATIBLE` blocks autonomous successor creation and the
workflow remains handoff-only. It must not silently edit a global skill during
a product unit.

The eventual launch request must explicitly include:

- the literal authorization `Autonomous chain mode approved`;
- an integer remaining-unit budget that includes the current unit;
- the saved Danio project binding and allowed successor target;
- the approved phone-only scope and parked boundaries;
- the run-state path, closeout rules, and stop conditions; and
- permission to create project-scoped successors while that committed run and
  budget remain valid.

Every generated successor prompt carries the same run ID and committed
authorization with the newly decremented remaining count. Missing, stale, or
incompatible authorization means handoff-only behavior.

## Goal Model

Use a Codex goal only for one finite authorized work unit: one high-risk
micro-slice or one bounded epoch. Do not create one goal for the entire mixed
completion backlog.

Every launched goal must define:

- objective;
- required repository reading;
- authorized ledger rows;
- excluded scope;
- verification artifacts;
- checkpoint rules;
- the operational run-state reference and
  `remaining_units_including_current` field;
- escalation conditions; and
- a verifiable stopping condition.

Goal state is task-local assistance. The committed operational state remains
the continuation source across fresh tasks.

A newly discovered ledger row may be recorded, but discovery does not
authorize its implementation. The current task may implement it only when the
approved work unit already defines that child scope without crossing its risk
boundary; otherwise the row waits for a fresh claim or explicit scope
amendment.

## Work Unit Policy

### High-Risk Micro-Slice

Use exactly one behavior change per branch for:

- restore and import transactions;
- migration and corruption recovery;
- destructive actions and rollback;
- persistent data creation, editing, deletion, or undo;
- Optional AI writes; and
- release-candidate blockers.

Require focused RED/GREEN proof, the quality-ladder gate for the risk, an
independent review, clean-main closeout proof, and a clean pushed checkpoint.

### Bounded Epoch

Allow up to three tightly related micro-slices in one coordinator-owned branch
only when they share the same risk boundary and proof setup, and none is a
high-risk item above.

Examples may include:

- related content/rule test clusters;
- several accessibility fixes in one current screen family;
- selective visual baselines for one stable surface cluster; or
- a small set of closely related preference verification gaps.

Run focused proof after each micro-slice and the required heavy gate before
merge. Split the epoch immediately if findings cross ownership, product, or
risk boundaries.

## Session Lifecycle

### 1. Rebuild Truth

- Load the Danio runner skill and underlying verified-slice contract, then
  validate them against the compatibility manifest.
- Run coordinator-owned `git fetch --prune`.
- Run the pure readiness validator.
- Read the operational state, ledger, active handoff, completion program,
  quality ladder, and latest slice-log entries.
- Confirm the highest-ranked authorized open item from fresh source and tests.
- Win the atomic writer claim before dispatching auditors or editing files.

### 2. Audit Before Editing

- Build the lane-specific behavior or evidence matrix.
- Dispatch relevant read-only auditors.
- Reconcile their findings against live source and tests.
- Add a newly proven issue to the ledger before implementation.
- Keep a newly added row outside the current write scope unless the claimed
  work unit already authorizes it under the Goal Model rule.
- Stop if no specific current gap is proven and close by verification only
  when the ledger definition is genuinely met.

### 3. Implement

- Reuse the exact deterministic branch/worktree recorded by the pushed writer
  claim. Do not create or substitute a second product worktree.
- For behavior or data changes, prove the focused test fails for the intended
  reason before changing implementation.
- Make the smallest change that closes the proven gap.
- Keep unrelated formatting, refactors, metadata, and parked scope untouched.

### 4. Verify And Review

- Run focused proof.
- Run lane-specific visual, content, Android, or performance proof when
  applicable.
- Dispatch the independent read-only reviewer.
- Address validated findings and rerun focused proof.
- Update the ledger, Finish Map, or completion program only when repository
  evidence genuinely changes their canonical fields. Make these product-truth
  updates before the final profile. Do not update Figma yet.
- Run the final required quality-ladder profile only after the review diff is
  settled.
- Treat any later product code, test, product documentation, generated-file,
  or configuration change as invalidating that final profile and rerun the
  required profile. The later path-constrained state/handoff closeout uses its
  separate staged-tree and Docs protocol.
- During Android evidence capture, freeze coordinator edits and pin the QA
  owner to the exact commit/APK under test.

### 5. Close Out

This ordinary closeout does not apply to DCL-RC entry into `finalizing`; that
unit follows the special Section 6 sequence instead.

- Commit the verified product/workflow slice on its owned branch.
- Run `git fetch --prune` again before merge. Stop if `origin/main`, the state
  revision, the containing claim commit, or the recorded base commit moved.
- Fast-forward merge into local `main` and run required clean-main proof.
- Create an evidence manifest keyed to the exact merged product/workflow
  commit, with command, result, environment, and durable artifact entries.
- Commit the evidence manifest as a path-constrained evidence checkpoint while
  operational state remains `active`. Run its required Docs proof, normally
  push it, and confirm clean `main...origin/main` at `0 0`. A rejected push
  preserves the owned branch/worktree and stops before cleanup.
- From the coordinator's clean `main` checkout, remove only the verified merged
  owned worktree/branch after checking its recorded resolved path and merge
  status. Ownership remains active through the pushed checkpoint and this
  cleanup. Keep the worktree when recovery evidence is still needed.
- Update handoff and slice log from the now-known product/workflow and evidence
  commits. They may say the typed state transition is included in the same
  closeout tree, but must not invent that transition commit's future hash or
  claim a state-transition push before it occurs.
- Compute the next run mode and consume the pending current unit exactly once.
  Release the owner and advance handoff generation only when the transition
  requires it.
- Prepare the typed state closeout and required tracking-doc updates on
  `main`, then stage the exact intended tree. Prove there are no unstaged or
  untracked changes and record `git write-tree`.
- Run the deterministic transition/schema validator against the parent state
  and staged tree, followed by the Docs profile. Recheck `git write-tree`; any
  tree change or new unstaged/untracked output invalidates the result and
  requires cleanup only when proven owned, then restaging and revalidation.
- Commit once without further file edits. Store non-recursive verification in
  commit trailers: staged tree hash, transition-validator result, Docs-profile
  result, UTC time, and referenced product evidence-manifest path. The state
  payload never attempts to contain its own commit hash.
- Revalidate the committed transition from `HEAD` and prove the checkout clean
  before push.
- Push with a normal fast-forward. If rejected, stop without further state
  edits or destructive cleanup and reconcile from fresh evidence.
- Confirm clean status and `main...origin/main` at `0 0`; `handoff_ready` is not
  eligible for task creation until both pass.
- After the state commit is pushed and aligned, synchronize Figma when the lane
  changed its visual control surface. Record the attempt with a same-mode
  compare-and-swap administrative state update; do not reopen product work.

### 6. Terminal Finalization

`DCL-RC-001` uses a two-phase terminal sequence rather than jumping directly
from `active` to `complete`:

1. After all non-release-candidate prerequisites are closed, the authorized
   DCL-RC unit consumes its budget once and commits and pushes
   `active -> finalizing` through the staged-tree transition protocol while
   retaining the writer token and recorded branch/worktree. Before final proof,
   fast-forward that exact branch/worktree to the pushed finalizing commit.
2. In `finalizing`, run the exact final Full, AndroidPrep, content, visual,
   product-truth, and phone QA proof required by the canonical ledger. Close
   `DCL-RC-001` only from that evidence and create the commit-keyed manifest.
3. Merge and push the final product/evidence/ledger checkpoint, confirm
   parent-state `main...origin/main` is `0 0`, and remove the verified owned
   temporary branch/worktree while the writer token is still held.
4. From clean aligned `main`, stage and validate the typed
   `finalizing -> complete` transition using the same staged-tree protocol.
   Its guard checks the parent checkpoint and completion-readiness facts; it
   does not require the state already to be `complete`.
5. Commit and normally push the terminal transition, release the owner, create
   no successor, and confirm the terminal postconditions: clean status,
   `main...origin/main` at `0 0`, and committed mode `complete`.

Any failure before step 5 uses `finalizing -> stopped` with exact recovery
evidence. Finalization never starts a replacement task automatically and never
decrements the already consumed DCL-RC unit again.

### 7. Continue Or Stop

- Create or reuse a fresh project-scoped successor only from pushed
  `handoff_ready` state with `remaining_units_including_current` greater than
  zero and a compatible chain authorization.
- Include the exact state path, run/handoff marker, authorized work-unit ID,
  last verified commit, and required skill in the successor prompt.
- Do not decrement budget during transfer; the completed unit was consumed
  exactly once by its closeout transition.
- Stop early when the phone complete-local bar is met even if budget remains.

## Context Freshness Policy

Rotate to a fresh project-scoped task after any of these:

- one high-risk micro-slice;
- one bounded epoch;
- a Full-gate closeout with substantial logs;
- a material product decision;
- repeated debugging that has filled the task with obsolete hypotheses; or
- the coordinator can no longer summarize the next action, current proof, and
  stop condition concisely.

Autonomous rotation requires a clean pushed checkpoint and `handoff_ready`
state. Never create an autonomous successor from a dirty branch, unpushed
commit, active writer claim, or emergency stop.

When a task must end mid-edit, write an emergency manual-stop record from
clean `main`, preserve the named branch/worktree and relevant processes, and
record exact dirty files and recovery instructions. Consume the pending unit
exactly once in that emergency-stop transition. Resumption requires explicit
user direction and the stopped-state transition; there is no autonomous budget
transfer. If writer, device, or process ownership cannot be safely released,
do not commit `stopped` or consume the unit yet; preserve durable
`active`/`finalizing` state and report task-local `STOP_PENDING` for explicit
recovery.

Subagents reduce context noise but do not replace clean-task rotation.

## Verification Strategy

### Existing Mandatory Core

- Focused test first for behavior and data-safety changes.
- Independent read-only diff review before the final required profile.
- Existing quality-ladder profile on the final settled diff.
- Clean-main proof and remote symmetry.
- Android ownership protocol for runtime evidence.
- Figma synchronization only after verified repository change.
- An evidence manifest keyed to the exact verified product/workflow commit.
- Deterministic validation of every staged state transition against its parent,
  followed by committed-transition revalidation at readiness.

Any product, test, configuration, generated-output, or product-document change
after a final profile invalidates that result. The product profile must rerun
before the product/workflow commit or merge. A later state-and-handoff-only
tree is constrained by path policy and uses the staged transition validator
plus Docs profile; it does not force a second Full gate when no Full-gated path
changed. Evidence-manifest entries include command, exit result, relevant
environment/device identity, timestamp, and durable artifact path where
applicable. The manifest verifies the preceding product/workflow commit. The
later state transition records its staged tree and validation results in Git
commit trailers, avoiding a self-referential receipt inside its own tree.

### Adopt As Lane-Specific Methods

- One-time risk-based coverage diagnostics to find untested critical modules;
  do not use an arbitrary global coverage percentage as a completion claim.
- Deterministic generated invariant tests for import relationship validation,
  serialization round trips, and migration idempotence where they provide
  better edge coverage than hand-picked examples.
- Flutter accessibility guideline tests for target size, labels, and contrast
  on high-traffic stable surfaces.
- Selective golden tests only after the visual target is stable and fonts and
  test environment are controlled.
- Flutter profile-mode timeline evidence for startup, frame timing, scrolling,
  animation, and image first-paint questions.

### Defer Until Evidence Justifies Them

- Android Macrobenchmark and Baseline Profile infrastructure.
- Firebase Test Lab device matrices beyond the already approved, bounded
  no-cost lane.
- CodeRabbit review beyond risk-selected pull requests after local proof.
- Percy or BrowserStack visual/device runs after local baselines stabilize.
- GitHub branch protection and mandatory hosted status checks.
- A property-testing dependency beyond a successful deterministic pilot.
- Targeted mutation analysis on a small critical pure-function set.

### Do Not Make Mandatory

- Whole-repository mutation testing.
- Hosted gates that can block local completion when an account, quota, token,
  or service is unavailable.
- Broad screenshot generation without a named visual target and comparison.
- Repeated Full gates when a lower risk profile is explicitly sufficient.

## Figma Contract

- The existing Danio phone atlas remains the visual control surface.
- Repository truth changes first.
- Figma synchronization occurs only after the relevant verified commit is
  pushed and local/remote `main` is aligned.
- Current screenshots remain evidence unless a verified change supersedes
  them.
- A frame or state becomes `Verified` only after matching repository proof.
- Visual QA compares target and current capture at the same viewport and state;
  screenshots alone are not a pass claim.
- Tablet and external lanes stay visibly parked.
- `product_complete` and `control_surface_sync.status == synced` are separate
  outcomes. A Figma outage, connector failure, quota issue, or unavailable
  account may leave control-surface synchronization pending, but it does not
  reopen or block a locally verified phone product completion.
- The operational state's `control_surface_sync` object is the canonical
  administrative record. The Figma file is visual evidence, not the authority
  for whether synchronization was attempted or verified.
- A product closeout that needs visual synchronization first commits
  `pending` with the target product commit. A later successful or failed attempt
  may update only that object through a same-mode compare-and-swap transition
  while mode remains `handoff_ready` or `complete`. The update records exact
  Figma file/node identifiers and an evidence hash or normalized error; it
  cannot authorize more product work.
- If a successor claim races an administrative update, the remote
  compare-and-swap winner proceeds and the loser stops. A rejected Figma status
  update may be reconciled later and never blocks the product run.
- No Figma token, paid asset, Code Connect setup, or team publishing workflow
  is added by this operating model.

## External Tool Policy

External tools are evidence amplifiers, not authorities.

- Local gates always run first.
- Only the writing coordinator may initiate an account-backed external action,
  except for a specifically dispatched Android QA owner operating within its
  recorded device/test scope.
- Use the paid-tool approval ledger and obtain exact scoped approval for the
  tool, purpose, data classification, expected artifact, and quota/cost before
  any account-backed action.
- Keep credentials in connector/session management or current-shell variables,
  never Git.
- Redact secrets and user data before sharing. Auditors may recommend an
  external check but may not initiate it.
- Record artifact paths or hashes, data classification, and the minimum scope
  shared; do not copy secret or user-data contents into logs.
- Do not spend quota on broad runs when a focused local proof can answer the
  question.
- A hosted-service failure cannot be reported as an application failure
  without independent evidence.

## Stop Conditions

Stop predicates are phase-qualified and distinguish task-local exits from
durable run transitions:

| Phase | Code | Scope/action | Predicate |
| --- | --- | --- | --- |
| Startup or handoff | `REMOTE_DIVERGED` | Task-local exit; leave run state unchanged because a safe CAS stop is unavailable. | Freshly fetched `main...origin/main` is not `0 0`. |
| Startup or handoff | `DIRTY_UNOWNED` | Task-local exit; persist a stop only if the tree can first be proven clean without changing foreign work. | Unrelated or unowned changes are present. |
| Startup or handoff | `AUTHORITY_CONFLICT` | CAS `ready`/`handoff_ready -> stopped` when clean/aligned; otherwise task-local exit. | Canonical docs disagree on scope, sequence, status, or done criteria. |
| Startup or handoff | `RUNNER_INCOMPATIBLE` | CAS `ready`/`handoff_ready -> stopped` when clean/aligned; otherwise handoff-only task exit. | Installed runner digest or required chain semantics do not match the compatibility manifest. |
| Writer claim | `WRITER_CLAIM_LOST` | Task-local exit only; no state or budget change. | Another task wins the expected state revision/remote fast-forward. |
| Any push | `PUSH_OUTCOME_UNKNOWN` | Task-local hold; preserve commit, ownership, branch/worktree, and budget state until exact remote reconciliation. | Push response is missing, timed out, disconnected, or otherwise cannot prove acceptance or rejection. |
| Active unit | `BASELINE_FAILED` | `active -> stopped`; consume current unit once. | The claimed source-of-truth baseline fails before intended changes. |
| Active unit | `LEDGER_AMBIGUOUS` | `active -> stopped`; consume current unit once. | The authorized row or done definition is unclear. |
| Active unit | `PRODUCT_DECISION_REQUIRED` | `active -> stopped`; consume current unit once. | Closing the gap changes accepted scope or behavior without a recorded decision. |
| Active unit | `EXTERNAL_APPROVAL_REQUIRED` | `active -> stopped`; consume current unit once. | Work requires an unapproved account, secret, quota, payment, deployment, or provider action. |
| Active unit | `SCOPE_DRIFT` | `active -> stopped`; consume current unit once. | Work crosses the finite claimed unit or a parked lane. |
| Runtime-required active unit | `RUNTIME_OWNERSHIP_CONFLICT` | `active -> stopped`; consume current unit once. | Required Android ownership is unavailable or unclear. |
| Active verification | `PERSISTENT_GATE_FAILURE` | `active -> stopped`; consume current unit once. | The same normalized non-transient failure remains after the initial failure and two bounded repair attempts. |
| Active pre-merge or push | `REMOTE_MOVED` | `active -> stopped` when a safe stop commit is possible; otherwise preserve recovery state and exit task-locally. | A fresh fetch shows the recorded base/state revision moved, or the normal push rejects. |
| Active closeout | `BUDGET_EXHAUSTED` | `active -> stopped` after the current unit's one decrement. | Post-decrement remaining units are zero and completion readiness is false. |
| Active DCL-RC unit | `FINALIZE` | `active -> finalizing`; not a stop. | All non-RC prerequisites pass and terminal proof is ready to begin. |
| Finalizing | `FINALIZATION_FAILED` | `finalizing -> stopped`; do not decrement again. | Final evidence, ledger closure, cleanup, terminal validation, or push cannot finish safely. |
| Active or finalizing recovery | `STOP_PENDING` | Task-local hold; durable mode and owner token remain unchanged. | Safe writer/device/process lease release cannot be proven, so `stopped` is illegal. |

Pre-claim failure attempts and signatures are task-local. Repeated-failure
counters become durable only after writer claim and are written by the active
unit's typed transition. When stopping, preserve the last clean checkpoint,
record the exact condition and recovery evidence, and ask one direct question
only when user input can unblock progress. A stop never creates a successor.

## Completion Condition

Before launch, the ledger schema must expose one canonical machine-readable
open/closed/parked state separate from work disposition. The non-circular
`completion_readiness` guard for `finalizing -> complete` is:

- no row in the active phone scope is machine-state `open` or
  `decision_required`;
- parked rows match the approved completion program boundary;
- every accepted limitation has a recorded user decision;
- `DCL-RC-001` transitions to verified-closed after every other active phone
  row, never before;
- an evidence manifest keyed to the exact final product commit records the
  required Full, AndroidPrep, content, visual, product-truth, and phone QA
  results;
- canonical-owner guard tests pass with no authority conflict;
- operational mode is `finalizing`, the same writer token remains valid, and
  the DCL-RC unit charge is already consumed;
- the final product/evidence/ledger parent checkpoint is pushed and aligned;
- temporary branches and worktrees are removed;
- the parent checkout is clean before staging only the terminal transition; and
- `main...origin/main` is `0 0` at that parent checkpoint.

The terminal transition then releases the owner and records `complete` with no
successor. After that commit is normally pushed, the terminal postcondition is
mode `complete`, clean `git --no-optional-locks status --short -uall` with
`GIT_OPTIONAL_LOCKS=0`, and `main...origin/main = 0 0`. Neither the guard nor
its evidence requires the state to be terminal before the transition that
makes it terminal.

Figma synchronization should normally follow immediately, but
`control_surface_sync.status: pending` is an allowed administrative follow-up
when the external service is unavailable. It does not change
`product_complete`.

## Repository Implementation Surfaces

The later implementation plan should cover these bounded surfaces:

1. A static autonomous completion runbook that applies this design.
2. Canonical authority reconciliation across the completion program, ledger,
   Finish Map selector, active handoff, and guard tests.
3. An explicit machine-readable ledger closure state separate from
   disposition.
4. A machine-readable lease/budget/run-state artifact, transition schema,
   evidence manifest, and validation.
5. A repository-owned installed-runner compatibility manifest and validator.
6. A coordinator-owned synchronization command with ephemeral receipt plus a
   pure PowerShell readiness validator.
7. A compare-and-swap writer-claim, deterministic branch/worktree identity,
   and staged-tree state-commit protocol.
8. A duplicate-safe handoff marker, native idempotency key when available,
   successor lookup, and paste-ready fallback protocol.
9. Updated autonomous chain and handoff prompts that invoke the Danio runner
   first and the verified-slice contract underneath it.
10. Explicit repository-read-only auditor command policy, serialized
    Android-owner, and single-writer enforcement in `AGENTS.md`,
    `MULTI_AGENT_WORKFLOW.md`, `.codex/config.toml` or its agent instructions,
    and the chain prompt.
11. Autonomous-unit budget and clean fresh-task continuation rules.
12. Documentation and script tests for synchronization-receipt freshness,
   claim races and cleanup, transition/finalization guards, failure fuses,
   `PUSH_OUTCOME_UNKNOWN` reconciliation, `STOP_PENDING` lease retention, state
   parsing, failed/closeout-time budget charging, duplicate-safe handoff, prompt
   freshness, and parked-scope invariants.
13. A dry-run launch rehearsal that makes no product changes and creates no
   successor task.

Implementation must prefer extending existing documents and scripts over
creating duplicate sources of truth.

## Risks And Mitigations

| Risk | Mitigation |
| --- | --- |
| Operational state becomes a second backlog | Store only lease, budget, cursor, immutable references, and recovery data; canonical feature/issue status stays in its owned docs. |
| Two tasks both become writers | Require a state-revision and remote fast-forward compare-and-swap claim before any product edit. |
| Budget overruns or decrements twice | Keep the current unit in the remaining count, mark it pending at claim, and consume it once in a typed closeout/stop/finalization transition. |
| Duplicate successor creation | Prefer a native idempotency key, suppress duplicates with deterministic run/generation lookup, and make writer claim the final exactly-one write boundary. |
| Auditor findings conflict | Coordinator verifies claims against live source/tests and records unresolved uncertainty instead of voting. |
| Too many auditors increase cost and noise | Dispatch only lane-relevant independent questions, normally two discovery auditors plus one later reviewer. |
| Goals become open-ended | Bind each goal to one finite claimed work unit; newly discovered rows remain unauthorized unless explicitly included. |
| Fresh tasks lose context | Push a typed handoff-ready state first; successor reads canonical docs and the exact run/generation marker. |
| Epochs hide risky changes | Prohibit batching for data, migration, destructive, Optional AI write, and release-candidate changes. |
| Heavy gates slow progress | Use the existing risk ladder; reserve mandatory Full gates for the profiles that require them. |
| External tools become dependencies | Keep them optional, approval-ledger controlled, and downstream of local proof. |
| Figma drifts or is unavailable | Sync only after pushed proof; track control-surface status separately so an outage cannot block product completion. |
| Installed runner semantics drift | Pin and validate a compatibility manifest before claim; fall back to handoff-only when incompatible. |
| Terminal completion becomes circular | Use `finalizing`, evaluate readiness against its aligned parent checkpoint, then push one typed terminal transition and verify postconditions. |
| A timed-out push actually succeeded | Treat missing/ambiguous push results as `PUSH_OUTCOME_UNKNOWN`; preserve all artifacts and reconcile the exact commit before retry or cleanup. |
| A stop falsely releases an active lease | Durable `stopped` requires proven writer/device release; otherwise retain the active/finalizing lease under task-local `STOP_PENDING`. |

## Research Basis

- OpenAI Codex: long-running goals should have one coherent objective,
  explicit proof, checkpoints, and a verifiable stop condition:
  <https://learn.chatgpt.com/use-cases/follow-goals>
- OpenAI Codex: subagents are strongest for read-heavy parallel work and need
  more caution for parallel writing:
  <https://learn.chatgpt.com/docs/agent-configuration/subagents>
- OpenAI Codex: local review can inspect branch or uncommitted changes without
  changing the working tree:
  <https://learn.chatgpt.com/docs/code-review>
- OpenAI Codex and Git: worktrees isolate independent tasks but share repository
  metadata and still require explicit ownership:
  <https://learn.chatgpt.com/docs/environments/git-worktrees> and
  <https://git-scm.com/docs/git-worktree.html>
- Flutter: use many unit/widget tests and enough integration tests for important
  journeys:
  <https://docs.flutter.dev/testing/overview>
- Flutter accessibility guideline testing:
  <https://docs.flutter.dev/ui/accessibility/accessibility-testing>
- Flutter golden matcher and environment caveats:
  <https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html>
- Flutter integration and performance profiling:
  <https://docs.flutter.dev/testing/integration-tests> and
  <https://docs.flutter.dev/cookbook/testing/integration/profiling>
- Android Macrobenchmark and Baseline Profiles:
  <https://developer.android.com/topic/performance/benchmarking/macrobenchmark-overview>
  and
  <https://developer.android.com/topic/performance/baselineprofiles/create-baselineprofile>
- Firebase Test Lab device matrices and test artifacts:
  <https://firebase.google.com/docs/test-lab/android/get-started>
- GitHub protected branch and required-check behavior:
  <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches>
- Optional Dart property and mutation testing research:
  <https://pub.dev/documentation/glados/latest/> and
  <https://pub.dev/packages/mutation_test>

## Independent Review Record

Two parallel repository-read-only reviewers pressure-tested the approved draft
and one reviewer rechecked the corrected state machine before commit. Their
blocking findings were accepted and resolved in this specification:

- budget semantics now match the installed verified runner: remaining count
  includes the current unit and consumption occurs once at closeout/stop;
- writer ownership uses a state-revision and remote fast-forward
  compare-and-swap claim with deterministic branch/worktree identity;
- run modes now include non-circular terminal finalization, explicit guarded
  transitions, task-local exits, and emergency-stop behavior;
- synchronization is separated from the pure readiness validator and carries
  a fresh ephemeral receipt;
- installed runner compatibility and explicit chain authorization are
  pre-launch requirements;
- canonical field ownership and the current sequence contradiction are
  explicit pre-launch requirements;
- operational state no longer duplicates handoff, feature, or ledger status;
- review occurs before the final required product gate, while a later
  path-constrained state-only commit uses staged-tree and Docs validation;
- Android QA is repository-read-only but explicitly runtime-mutating and
  serialized;
- repository-read-only auditor commands explicitly exclude cache-, ref-,
  process-, runtime-, and external-state mutation;
- autonomous dirty-task rotation is prohibited;
- merge/push cleanup and stop predicates are phase-qualified;
- unknown push outcomes preserve artifacts until exact remote reconciliation,
  and durable stopped state requires proven lease release;
- handoff is duplicate-safe with a no-creation fallback rather than falsely
  claiming exactly-once behavior;
- the DCL-RC entry path is separate from ordinary completed-unit closeout, and
  post-gate checks catch unstaged/untracked output as well as index changes;
- Figma synchronization has one canonical administrative field, remains
  downstream, and cannot block local product completion; and
- completion requires a machine-readable ledger state and commit-keyed
  evidence manifest.

The reviewers made no repository, runtime, Figma, or external-state changes.

## Approval Record

On 2026-07-11 the user selected and approved the recommended reliability model:
one writing coordinator with parallel read-only auditors. The user then
approved this design to proceed to a committed specification and subsequent
implementation planning. No autonomous implementation budget is implied by
that approval.
