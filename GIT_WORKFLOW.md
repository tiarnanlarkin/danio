# Danio Git Workflow

Current source of truth:

- Branch: `main`
- App path: `apps/aquarium_app`
- Remote mirror: use `git remote -v` for the current URL
- Handoff: `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`

## Safe Start

```powershell
git fetch --all --prune --tags
git status --short -uall
git status -sb
git branch -vv --all
git worktree list
```

If the remote is ahead, stop and reconcile before new work. If the worktree is
dirty with changes you did not make, preserve them.

## Branches

`main` is the buildable source-of-truth branch. Use short-lived feature or fix
branches for normal development slices when isolation is useful, then merge
verified work back into `main`, push the mirror, and delete merged temporary
branches.

Do not keep long-running branch stacks around as hidden source-of-truth copies.

## Verification

Run commands from `apps/aquarium_app` unless a repo doc says otherwise.

```powershell
flutter test
flutter analyze
flutter build apk --debug --target lib/main.dart
git diff --check
```

Use `apps/aquarium_app/docs/agent/QUALITY_LADDER.md` to choose the smallest
safe gate for the slice. Product/data-safety changes usually need the local
quality wrapper, not only ad hoc commands.

## Legacy

The previous workflow note was archived at
`docs/archive/root-legacy-2026-07-04/GIT_WORKFLOW.legacy.md`.
