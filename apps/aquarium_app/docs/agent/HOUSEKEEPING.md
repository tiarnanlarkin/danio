# Danio Housekeeping

Status: Active
Created: 2026-07-03

## Purpose

This file keeps the repo navigable while Danio is developed by multiple
agents. Prefer prevention over cleanup: clear evidence folders, focused
commits, no generated junk in Git, and explicit handoffs.

## Never Commit

- Secrets, API keys, tokens, local shell history, account exports, billing
  artifacts, or credential screenshots.
- Firebase, Percy, BrowserStack, Sentry, CodeRabbit, OpenAI, Supabase, Vercel,
  Figma, or other service secrets.
- Build outputs: `build/`, `.dart_tool/`, Gradle build directories, APKs unless
  a release process explicitly says otherwise.
- Temporary screenshots, crash dumps, emulator state, logcat floods, or raw
  generated diagnostics that do not prove a decision.
- Machine-local path config unless the user explicitly asks for setup docs.

## Evidence Folders

Durable visual evidence belongs under:

```text
apps/aquarium_app/docs/qa/screenshots/<date-or-branch>/<slice>/
```

Use descriptive names:

```text
phone-01-screen-state.png
tablet-01-screen-state.png
phone-01-screen-state-focus.txt
```

Use `docs/qa/screenshots/live-preview/` only for live-preview captures that are
intended as evidence. Temporary inspection images should stay outside Git.

## Logs

- Keep logs only when they prove a bug, fix, device failure, or QA result.
- Trim logs to the smallest useful excerpt before committing.
- Redact paths only if they reveal secrets; normal repo paths are acceptable.
- Do not commit full emulator logs for routine passes.

## Generated Files

Allowed to regenerate locally but not commit unless intentionally part of a
slice:

- Flutter generated build output.
- Updated ignored golden references.
- Temporary lint/cache folders.
- Test output files.
- Local Android install artifacts.

If a generated file appears in `git status --short -uall`, inspect why before
staging anything.

## Duplicate Roots And OneDrive

The authoritative repo root for this project is:

```text
C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo
```

If another Danio-like tree appears, do not merge or delete it casually. Record
the path in `ACTIVE_HANDOFF.md`, compare with `git status` and `git rev-parse
--show-toplevel`, and ask before cleanup.

## Stale Docs

- `FINISH_MAP.md` is the completion control layer.
- Product backlog and audit docs preserve acceptance history.
- `ACTIVE_HANDOFF.md` owns current session state.
- `SCREEN_INVENTORY.md` owns current screen/page map and evidence gaps.
- `SLICE_LOG.md` owns completed-slice breadcrumbs.

When a doc is superseded, link it to the current source of truth instead of
deleting historical context.

## Cleanup Cadence

At the end of each committed slice:

1. Run `git status --short -uall`.
2. Confirm only intended files were committed.
3. Remove or leave untracked temporary files intentionally outside Git.
4. Update `ACTIVE_HANDOFF.md` if a future agent needs to know current state.
5. Note any remaining dirty files and their owner.

Before release-candidate work:

- Audit ignored and untracked files.
- Check stale screenshot/log folders.
- Confirm docs do not claim fake cloud, fake premium, or unsupported AI.
- Run the release-candidate row in `QUALITY_LADDER.md`.

