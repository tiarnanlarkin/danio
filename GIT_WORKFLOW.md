# Git Workflow - Danio

Last updated: 2026-05-02

The old `master` / `aquarium-app` workflow is retired. The current source of truth is:

- Local repo: `C:\Users\larki\Documents\Danio Aquarium App Project\repo`
- Remote: `https://github.com/tiarnanlarkin/danio.git`
- Default branch: `main`
- App path: `apps/aquarium_app`

## Safe Start

```powershell
cd "C:\Users\larki\Documents\Danio Aquarium App Project\repo"
git status --short --branch
git fetch origin
git log --oneline --decorate --max-count=5
```

Do not run `git pull --rebase`, `git reset --hard`, or `git checkout -- <file>` unless the user explicitly asks for that operation.

## Branch Per Fix

Create a branch for every fix or audit implementation:

```powershell
git checkout -b fix/short-description
```

Use small branches. One user-visible issue or workflow improvement per branch is the default.

## Before Committing

From `apps/aquarium_app`, run the appropriate checks:

```powershell
flutter analyze --no-pub
flutter test
flutter build apk --debug --target-platform android-arm64 --no-pub
```

For release readiness, also run:

```powershell
flutter build appbundle --release
```

For UI/navigation/Tank/onboarding changes, run Android device smoke tests once Android tooling is available.

## Saving Work

The helper scripts now refuse to commit from `main`. Use them only from a feature/fix branch:

```powershell
.\save_work.bat
```

or:

```bash
./save_work.sh
```

They commit and push the current branch to `origin`.

## GitHub

Open PRs against `main` after local checks pass. GitHub Actions must be green before treating the branch as release-ready. If CI fails before runner steps start, check GitHub account/billing status before assuming the app is broken.

## Recovery

Prefer non-destructive inspection first:

```powershell
git status --short --branch
git diff --stat
git diff
git log --oneline --decorate --max-count=10
```

Ask before any destructive recovery. The repo may contain local work that is intentionally ahead of GitHub.
