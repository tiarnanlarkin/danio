# Danio Autonomous Chain Handoff Prompt

Status: Active successor prompt template
Created: 2026-07-05

Use this template only after the current session has merged, pushed, deleted
temporary branches/worktrees, and confirmed clean `main...origin/main` alignment.
Replace bracketed values with current evidence.

```text
Use $verified-slice-runner for the next Danio Aquarium complete-local slice.

Continuation mode: autonomous chain approved.
Autonomous chain mode approved.
Remaining sequential session budget: [N] total, including this successor. Do
not run parallel repo sessions after this successor is running. Stop early if
the app reaches the complete-local bar before the budget is exhausted. If more
than the remaining budget would be needed, stop at a clean checkpoint and ask
the user.

Saved Codex project:
C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project

Start from:
C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo

Current checkpoint evidence:
- Source-of-truth branch: clean main tracking origin/main.
- HEAD: [commit hash] ([commit subject]).
- Latest completed slice(s): [slice IDs and one-line result].
- git rev-list --left-right --count main...origin/main returned 0 0.
- git status --short -uall returned clean.
- Temporary branch(es)/worktree(s): [deleted or none].
- Required gates passed: [focused proof and local gates].

Do not rely on prior chat memory. Rebuild context from repo-owned files, live
git state, current command output, current installed skill instructions, and
this prompt.

Required startup:
1. Load and follow the latest installed $verified-slice-runner skill from disk.
2. Confirm the actual repo root with git.
3. Read applicable AGENTS.md / repo instructions from root to working
   directory.
4. Run git fetch --prune.
5. Run git status --short -uall.
6. Confirm source branch and upstream alignment first; stop if main...origin/main
   is not 0 0.
7. Read README, GIT_WORKFLOW.md, and these repo-owned docs before editing:
   - apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md
   - apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md
   - apps/aquarium_app/docs/agent/COMPLETE_LOCAL_FORECAST.md
   - apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md
   - apps/aquarium_app/docs/agent/FINISH_MAP.md
   - apps/aquarium_app/docs/agent/QUALITY_LADDER.md
   - apps/aquarium_app/docs/agent/TESTING_CHECKLIST.md
   - apps/aquarium_app/docs/agent/SLICE_LOG.md
   - apps/aquarium_app/docs/agent/plans/2026-07-05-accelerated-complete-local-epoch-plan.md
   Also read any docs those files require for the selected lane.
8. Preserve unrelated dirty work and inspect emulator/device/debug-server state
   before any runtime action.

Goal: continue Danio toward local-first, phone-first complete-local quality.
Begin with a read-only ledger-driven gap selection audit. Prefer the highest
ranked open COMPLETE_LOCAL_CLOSURE_LEDGER.md item whose missing behavior is
proven by fresh source/test evidence. Link every implementation slice to its
ledger ID. New issues discovered during work must be added to the ledger before
implementation. External/cloud/account/paid/API-key/store/deploy/provider/premium
work stays parked unless the user explicitly approves it in the current thread.

Implementation rule: implement exactly one small verified slice, or one bounded
2-3 micro-slice epoch only when the selected ledger IDs share the same module,
test family, proof setup, and risk boundary. Use TDD RED/GREEN for behavior or
data-safety changes. Run focused proof and the required local gate from
QUALITY_LADDER.md. If multiple candidates remain plausible, runtime ownership is
needed, the target is already covered, source/docs disagree, or product
direction is needed, stop and ask one direct question.

Closeout: update repo-owned handoff/log/ledger/finish docs as appropriate, run
focused proof and documented local gates, commit, merge to main, push
origin/main, clean temporary branches/worktrees, and stop at a clean pushed
aligned checkpoint. At that checkpoint decrement the remaining budget and, if
budget remains and no stop condition is hit, create the next successor in this
same saved Danio project with the updated remaining sequential session budget.
If project-scoped thread creation is unavailable or would create a projectless
thread, stop and provide the paste-ready handoff prompt instead.
```
