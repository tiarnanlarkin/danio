# Git Workflow - Simple & Safe

**Goal**: Single local source, one remote repo, never lose work.

## After Each Work Session

### Option 1: Use the Script (Easiest)
**Windows**: Double-click `save_work.bat`  
**WSL/Linux**: Run `./save_work.sh`

This automatically:
1. Stages all changes
2. Commits with timestamp
3. Pushes to GitHub

### Option 2: Manual Commands
```bash
cd "C:\Users\larki\Documents\Aquarium App Dev\repo"

# Save everything
git add -A
git commit -m "Work session: [describe what you did]"
git push origin master
```

## Current Setup

- **Local repo**: `C:\Users\larki\Documents\Aquarium App Dev\repo`
- **Remote repo**: https://github.com/tiarnanlarkin/aquarium-app
- **Branch**: `master`

## Safety Checks

Before starting work, make sure you're up to date:
```bash
git pull origin master
```

Check status anytime:
```bash
git status
```

See what's changed:
```bash
git log --oneline -10
```

## Recovery

If something goes wrong, you can always restore from GitHub:
```bash
git reset --hard origin/master  # ⚠️ Discards local changes
git pull origin master
```

## Rules

1. ✅ Always commit and push after each work session
2. ✅ Pull before starting new work (if working from multiple machines)
3. ✅ Keep it simple - one branch (master)
4. ✅ Remote always matches local after a push

---

**Last updated**: 2026-02-08
**Remote repo**: https://github.com/tiarnanlarkin/aquarium-app
