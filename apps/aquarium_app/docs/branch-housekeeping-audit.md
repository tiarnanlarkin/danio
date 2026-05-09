# Danio Branch Housekeeping Audit

Date: 2026-05-09

This report records the branch state after consolidating the tested Danio app
candidate into `main`. It is intended to prevent old branch names from being
mistaken for current work.

No branch deletion, pruning, rebasing, or remote cleanup was performed while
creating this report.

## Current Source Of Truth

- Local `main` and remote `origin/main` are aligned.
- Current primary worktree: `C:\Users\larki\Documents\Danio Aquarium App Project\repo`
- Current primary worktree branch: `main`
- Current release source of truth: `main`

The previously tested candidate branch, `fix/android-polish-followup`, is now
represented by `main` plus the follow-up Supabase Edge Function type-check fix.

## Preservation Archive

Before any branch cleanup, branch tips were archived in:

`C:\Users\larki\Documents\Danio Aquarium App Project\branch-archives\danio-branch-archive-20260509-013529.bundle`

The bundle was verified successfully with `git bundle verify`. It contains the
local and remote branch refs, tags, and complete history needed to recover old
branch tips if a branch is later deleted from the local repo or remote.
Documentation commits made after the bundle remain on `main`, which is not a
cleanup deletion target.

Associated manifest:

`C:\Users\larki\Documents\Danio Aquarium App Project\branch-archives\danio-branch-archive-20260509-013529-manifest.txt`

## Branch Counts Before Cleanup

| Ref set | Count |
| --- | ---: |
| Local branches | 34 |
| Local branches excluding `main` | 33 |
| Remote branches | 34 |
| Remote branches excluding `main` | 33 |
| Unique branch names across local and remote | 36 |
| Unique branch names excluding `main` | 35 |

Local-only branch names:

- `feature/danio-fix-brief-phase-3`
- `worktree-agent-a849618f`

Remote-only branch names:

- `feature/danio-fix-brief-phase-5`
- `feature/side-panel-redesign`

## Remaining Non-Main Branches

These branches remain as historical refs only. They should not be used as the
base for new work now that `main` is current.

- `docs/safe-codex-workflow`
- `feature/conservative-ui-polish`
- `feature/danio-fix-brief-2026-04`
- `feature/danio-fix-brief-phase-3`
- `feature/danio-fix-brief-phase-4`
- `feature/danio-fix-brief-phase-5`
- `feature/learn-practice-lockdown`
- `feature/side-panel-redesign`
- `fix/android-polish-followup`
- `fix/full-app-qa-lockdown`
- `master`
- `openclaw/qa-fixes`
- `openclaw/stage-final`
- `openclaw/stage-system`
- `openclaw/ui-fixes`
- `polish/cleanup-house-nav`
- `polish/compliance-fixes`
- `polish/critical-fixes`
- `polish/design-system-adoption`
- `polish/device-fixes`
- `polish/milestone-1`
- `polish/milestone-2`
- `polish/milestone-3`
- `polish/milestone-4`
- `polish/onboarding-shorten`
- `polish/practice-fixes`
- `polish/practicehub-fix`
- `polish/quick-log`
- `polish/settings-rebuild`
- `polish/settings-rebuild-v2`
- `polish/smart-polish-v2`
- `polish/smart-premium`
- `polish/stories-darkmode`
- `pre-feb7-polish`
- `worktree-agent-a849618f`

## Open Worktrees Before Cleanup

| Path | State |
| --- | --- |
| `C:\Users\larki\Documents\Danio Aquarium App Project\repo` | `main` |
| `C:\Users\larki\Documents\Danio Aquarium App Project\worktrees\conservative-ui-polish` | `fix/android-polish-followup` at `3bd519f6` |
| `C:\Users\larki\Documents\Danio Aquarium App Project\worktrees\audit-main-5e451577` | detached `HEAD` at `5e451577` |

The `conservative-ui-polish` worktree points at the same commit as `main`, but
it is still checked out on an old branch name. The `audit-main-5e451577`
worktree is a stale detached audit worktree.

## Recommended Cleanup Sequence

After this report is committed to `main` and pushed:

1. Verify `main`, `origin/main`, and `HEAD` all point at the same commit.
2. Remove stale worktrees after confirming they have no uncommitted changes.
3. Delete local branches other than `main`.
4. Delete remote branches other than `main`.
5. Fetch once more without pruning assumptions and confirm only `main` remains.
6. Keep the branch archive bundle and manifest outside the repo.

This leaves `main` as the single working source of truth locally and on GitHub,
while preserving recoverability through the verified bundle.
