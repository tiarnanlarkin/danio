# Danio Autonomous Chain Handoff Prompt

> **FROZEN HISTORICAL WORKFLOW:** Retained for evidence and recovery analysis
> only. Do not execute this prompt or generate successors. Reactivation requires
> a new explicit user request and reconciliation plan; see
> `autonomous_completion/README.md`.

Status: Frozen historical workflow; the body below preserves the former
activation and chaining contract and is not executable current authority.
Created: 2026-07-05
Reconciled: 2026-07-11 for the approved autonomous phone workflow bootstrap

This template is for the explicitly authorized workflow setup units that run
before Task 13 activation. It is not an operational product-successor prompt
and does not independently grant task-creation authority. The invoking task
must carry the user's current bounded authorization, exact unique bootstrap
marker, remaining integer budget, saved-project binding, and stop conditions.

Use the template only after the current setup unit has passed its focused and
Docs proof, committed and fast-forwarded to `main`, pushed, deleted only its
safely merged temporary branch/worktree, and confirmed clean
`main...origin/main` alignment. Replace bracketed values with fresh evidence.

```text
Load and follow $danio-autonomous-slice-runner first.
Then load and follow $verified-slice-runner underneath it.

Continuation mode: autonomous chain approved
Autonomous chain mode approved for explicit bootstrap continuation only.
Automatic operational successor creation remains disabled in bootstrap mode.
The explicit first product task is separately Task 13-gated, and later chaining
remains state-, readiness-, generator-, and duplicate-safety-gated.

Bootstrap marker: [danio-autonomy-bootstrap-2026-07-11/N]
Remaining sequential setup-unit budget: [N] total, including this task. Units
are sequential, never parallel writers. Do not run another repository-writing
task while this one is active. Stop early if a fail-closed condition applies.

Saved Codex project:
C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project

Actual repository root:
C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo

Current checkpoint evidence:
- Source-of-truth branch: clean main tracking origin/main.
- HEAD: [commit hash] ([commit subject]).
- Latest completed setup unit: [unit ID and one-line result].
- git rev-list --left-right --count main...origin/main returned 0 0.
- git status --short -uall returned clean.
- Temporary branch(es)/worktree(s): [deleted or none].
- Required gates passed: [focused proof and Docs gates].
- Bootstrap budget after the prior closeout: [consumed] consumed and
  [remaining] remaining including this task.

Do not rely on prior chat memory. Rebuild context from repo-owned files, live
Git state, current command output, current installed skill instructions, and
this prompt.

Required startup:
1. Load the latest installed $danio-autonomous-slice-runner from disk.
2. Load the latest installed $verified-slice-runner from disk.
3. Confirm the nested repository root with git and read every applicable
   AGENTS.md file.
4. Run git fetch --prune and git status --short -uall.
5. Confirm main is the source of truth, the checkout is clean, and
   main...origin/main is 0 0. Stop without edits if not.
6. Read these repo-owned authorities before editing:
   - apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md
   - apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md
   - apps/aquarium_app/docs/agent/FINISH_MAP.md
   - apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md
   - apps/aquarium_app/docs/agent/QUALITY_LADDER.md
   - apps/aquarium_app/docs/agent/TESTING_CHECKLIST.md
   - apps/aquarium_app/docs/agent/SLICE_LOG.md
   - apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md
   - apps/aquarium_app/docs/agent/plans/2026-07-11-autonomous-phone-completion-operating-model-design.md
   - apps/aquarium_app/docs/agent/plans/2026-07-11-autonomous-phone-completion-workflow-implementation-plan.md
7. Rebuild current truth from live files and commands. This template is not
   proof that a setup task is still needed or safe.

Objective: execute setup unit [number], plan Task(s) [numbers] only, exactly as
defined in the autonomous phone workflow implementation plan. One writing
coordinator owns every repository write, stage, commit, merge, push, and task
creation. Parallel agents may be repository-read-only auditors only.

The coordinator is also the only installed-skill writer and durable
evidence-file writer. Auditor repository commands are limited to `rg`,
`Get-Content`, `git show`, `git log`, `git diff --no-ext-diff`, and
`GIT_OPTIONAL_LOCKS=0 git --no-optional-locks status`. Auditors do not run
fetch, checkout, add, commit, push, package resolution, Flutter/Gradle gates,
generators, quality wrappers, background processes, Figma writes, task
creation, or account-backed actions. Non-Android auditors also do not run
ADB/emulator commands. Android QA remains repository-read-only and has only
the serial-scoped runtime exception: it requires coordinator-supplied immutable
commit/APK identity plus a coordinator-assigned serial after
`DEVICE_OWNERSHIP.md`.
Except for `adb devices`, every device-affecting command uses
`adb -s <assigned-serial>`.

Keep product execution blocked. Do not start DCL-DR-001 or another product
ledger row before Task 13. Do not take Android runtime ownership, edit Figma or
installed skills unless the selected setup task explicitly owns that scope,
create live operational run state before Task 13, or touch paid/cloud/account/
provider/store/deploy state.

Closeout: run the task's focused proof and Docs profile, update ACTIVE_HANDOFF
and SLICE_LOG honestly, and update the bootstrap budget exactly once only when
the unit reaches a durable clean closeout. Commit, fast-forward to main, rerun
the required clean-worktree Docs gate, push origin/main, remove only the safely
merged temporary branch/worktree, and prove clean 0 0 alignment.

Do not infer permission to create a next task from this template. Create or
reuse exactly one saved-project local bootstrap task only when the invoking
prompt explicitly authorizes that exact next marker and positive remaining
budget. If lookup, binding, or create outcome is unavailable or ambiguous,
create nothing and return the complete paste-ready handoff.
```

Task 10 adds the separately validated operational launch/successor prompt
generator and coordinator lookup algorithm. Committed manifest revision 3 sets
`authorizes_launch: true` only through the exact committed Task 12 rehearsal
proof it pins. While no live run state exists, only the explicitly authorized
Task 13 activation path may use that launch authority. After activation, the
generator's Launch output and duplicate-safe lookup govern the one explicit
first product task; later automatic successors remain live-state and readiness
gated. This bootstrap template does not create live run-state authority or
independently authorize an operational successor.
