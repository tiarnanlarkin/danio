# Danio Optional Multi-Agent Workflow

Status: risk-triggered, not routine startup

Use extra agents only when independent read-only work will materially reduce
elapsed time or risk. Ordinary narrow epochs need only the coordinator.

## Roles

- The coordinator is the sole repository writer and owns edits, formatting,
  staging, commits, merges, pushes, durable evidence, and task boundaries.
- Discovery agents are read-only and return evidence or recommendations.
- A reviewer is read-only and examines the final settled diff.
- `danio_android_qa_owner` is the only delegated role allowed to perform
  assigned Android interaction after device ownership is established.

Use no more than two parallel discovery agents for an ordinary epoch. Give each
one a concrete, non-overlapping question. Agents must not create tasks or
successors.

## When review is required

Require one independent settled-diff review for high-risk or broad work:

- data safety or persistence;
- security or secrets;
- lifecycle or concurrency;
- destructive operations;
- release truth;
- broad multi-module changes.

The reviewer must not be the implementing coordinator and must remain
repository-read-only: no edits, formatting, staging, commits, merges, pushes,
cleanup, or device actions. Review the final settled diff after implementation
and documentation updates, then resolve findings before the final broad gate.
Record the reviewer and disposition in the epoch handoff or Slice Log.

No hosted, paid, or account-backed review service is required or configured.
Use an available local read-only reviewer. If none is available, stop before
the final broad gate and report the missing independent review. A reviewer does
not replace focused RED/GREEN proof or coordinator verification.

## Dirty work and devices

All agents inspect live Git before work. Read-only agents do not edit shared
files, stage, commit, merge, push, clean, or delete. If another writer owns
overlapping dirty files, stop and reconcile.

Before Android work, read `DEVICE_OWNERSHIP.md`. The coordinator assigns one
serial and immutable commit/APK. Except for `adb devices`, device-affecting
commands use `adb -s <assigned-serial>`.

The `LIVE_PREVIEW_WORKFLOW.md` live preview lane is observational. It can be
owned only by the coordinator or `danio_android_qa_owner`, and never replaces
tests, goldens, analysis, AndroidPrep, or Full.

## Frozen history

The prior autonomous coordinator/claim/successor overlay is frozen historical
material. It does not authorize parallel writers, task creation, budget
accounting, or automatic continuation.

Never create an automatic successor task.
