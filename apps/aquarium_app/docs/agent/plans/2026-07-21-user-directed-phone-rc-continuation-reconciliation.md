# User-Directed Phone RC Continuation Reconciliation

Status: current manual continuation authority
Epoch: `DR-2026-07-21-061`
Marker: `danio-user-directed-continuation-reconciliation-2026-07-21/1`
Continuation mode: autonomous chain approved

## Authority And Scope

The saved Codex project is
`C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project`.
The repository root and Git authority are
`C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo`.
Current Git plus the five routine startup files, the ordered
`2026-07-19-phone-release-candidate-finalization-plan.md`, and directly relevant
closure authority outrank prompts and prior-session summaries.

This new user-directed manual chain may execute the remaining ordered Android
phone release-candidate work until `DCL-RC-001` closes. It does not authorize
tablet, Play Store signing or submission, public release, cloud/accounts, paid
services, provider keys, secrets, iOS, or any other parked or external lane.

## Historical-State Separation

`autonomous_completion/phone_completion_run_state.json` is a frozen historical
record. Its schema, claims, leases, transitions, budgets, launch/closeout
commands, and successor rules do not authorize, constrain, or account for this
manual chain. Do not invoke, edit, resume, reinterpret, or delete it. This plan
uses no historical claim transaction and writes no replacement autonomy state.

## Session Budget

The chain starts with 20 verified sessions total, including this reconciliation session.
A session consumes one unit when it reaches a durable clean closeout or a
durable stop, including a stop without product changes. After this
reconciliation closes cleanly, 19 verified sessions remain for a successor.

The budget is a safety ceiling, not a workload target. Carry the post-consumption
count in the single successor prompt; do not decrement twice during transfer.
Stop early when `DCL-RC-001` closes. If zero remains while current phone-release
work is still open, leave a clean paste-ready handoff and ask the user instead
of widening scope or creating a successor.

## Ownership And Verification

Exactly one repository-writing coordinator owns file edits, Flutter/Gradle and
device commands, staging, commits, merges, pushes, durable evidence, and
successor creation. Danio subagents may be read-only auditors for review,
triage, exploration, test-gap, accessibility, and performance review. They do
not edit files or run Git integration, gates, or device commands.

Each session rebuilds authority from fetched Git and the exact routine startup
sequence, then executes only the current `ACTIVE_HANDOFF.md` action under the
ordered finalization plan. Start only from clean aligned `main`, one worktree,
and no competing writer. Use one lean verified epoch with no speculative
backlog expansion.

- Product behavior: focused RED for the intended reason, smallest fix, focused
  GREEN, independent read-only review, required gate, focused commit.
- Documentation: guard RED for the missing authority, smallest docs change,
  guard GREEN, independent read-only review, one Docs gate, focused commit.
- Closeout: fetch again, prove the remote is not ahead, fast-forward local
  `main` to the tested branch commit, prove tree identity, make one non-force
  push, then prove
  clean status, `main...origin/main = 0 0`, intended worktrees, no running gate
  or terminal, and safe branch cleanup.

## Fail-Closed Rules

- Dirty or unexpected Git: preserve it, make no overlapping edit, and stop.
- Remote ahead or divergence: do not merge, rebase, or push; stop for
  reconciliation.
- Concurrent or uncertain writer ownership: remain read-only and stop.
- Gate failure: do not commit, merge, push, or chain. Diagnose narrowly; after a
  repeated failure with the same root cause, preserve evidence and stop.
- Unknown push result: classify `PUSH_OUTCOME_UNKNOWN`, preserve the candidate
  commit/branch/evidence, and create no successor. Remote evidence may be
  refreshed only to diagnose the outcome. Do not retry the push in this
  session; stop and ask the user.
- Device work: read `DEVICE_OWNERSHIP.md` first. If ownership is unclear, do not
  start, stop, wipe, install, tap, capture, or otherwise affect a device; stop.
- Paid/account-backed work, secrets/provider keys, external lanes, or an
  uncovered product decision: do not infer authority; stop and ask the user.

## Successor Contract

At an exact clean pushed checkpoint, create at most one fresh saved-project
successor for the live `ACTIVE_HANDOFF.md` action. Do not create while a branch,
gate, terminal, docs update, merge, push, cleanup, writer conflict, or unknown
outcome remains.

Lookup the exact marker in the same saved project before creation. Reuse and
report exactly one match. Create only on an unambiguous, exhaustive zero result.
An ambiguous lookup creates nothing; stop and ask the user. After an unknown
create outcome, query the exact marker once; reuse one confirmed match,
otherwise create nothing further, never retry the unknown create outcome, and
stop and ask the user. Carry this plan, the decremented budget, scope,
one-writer rule, verification contract, and stop conditions in the successor
prompt.

For the first successor, only if still selected live, the marker is
`danio-dcl-dr-003-wishlist-replay-probe-2026-07-21/1` and the budget is 19.
Do not create multiple future tasks. The Wishlist probe is not complete in this
documentation epoch.

When `DCL-RC-001` closes, stop with the final clean evidence packet and create
no successor.
