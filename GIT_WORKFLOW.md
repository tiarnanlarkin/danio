# Danio Git Workflow

`main` is the buildable local source of truth. The remote is a backup mirror.
Use short-lived branches only when they make a verified epoch safer.

## Start

```powershell
git fetch --all --prune --tags
git status --short -uall
git status -sb
git branch -vv --all
git worktree list
git rev-list --left-right --count main...origin/main
```

Stop and reconcile if the remote is ahead. Preserve any dirty work you do not
own. Do not start a second writer against an overlapping checkout.

## Work

1. Branch from aligned `main` when isolation is useful.
2. Keep one writing coordinator; auditors and reviewers remain read-only.
3. Implement one lean epoch under
   `apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md`.
4. Stage only intended paths and inspect both staged and unstaged diffs.
5. Commit tested bytes with a specific message.

Never rewrite public history, force-push, or discard unclear work without a
separate explicit user instruction.

## Close

Record the tested commit and tree:

```powershell
git rev-parse HEAD
git rev-parse HEAD^{tree}
```

Fast-forward into `main`, then prove the merged tree is identical before one
non-force push:

```powershell
git switch main
git merge --ff-only <short-lived-branch>
git rev-parse HEAD^{tree}
git push origin main
git status --short -uall
git rev-list --left-right --count main...origin/main
git worktree list
```

Delete only safely merged temporary branches/worktrees. If identical tested
bytes were fast-forwarded or pushed, use tree identity and Git alignment rather
than rerunning Full.

Never create an automatic successor task. End at a clean checkpoint and leave
the next manual action in `ACTIVE_HANDOFF.md`.
