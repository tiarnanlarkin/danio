# Master ↔ openclaw/stage-system merge strategy

**Date drafted:** 2026-04-07
**Author:** Claude (Phase 2 review session)
**Status:** Proposal — awaiting user decision

## TL;DR

`openclaw/stage-system` and `master` have diverged for ~5 weeks (since 2026-02-28). A naive `git merge origin/master` produces **143 conflicts** (69 rename/rename, 31 modify/delete, 31 content, 7 rename/delete, 5 add/add) — far too risky for a single attempt.

**Recommended path:** continue using `openclaw/stage-system` as the working branch (Strategy D). Cherry-pick a small number of master-only commits (~3–5) that contain unique value, then leave master frozen. Eventually rename `openclaw/stage-system` → `master` as the new default branch when ready to ship.

## Current state

| Branch | Commits ahead | Last commit |
|---|---|---|
| `openclaw/stage-system` | **828 ahead of master** | `efde6e0d` Phase 2 layout polish (just merged) |
| `master` | **42 ahead of stage-system** | `77e314ba` docs: privacy/terms HTML pages |
| Common ancestor | `eeacfc22` Sat Feb 28 2026 | `fix(ui): final polish pass — StudyRoomScene overlaps...` |

## What's on master that isn't on stage-system

42 commits across these themes (read top-to-bottom = newest-to-oldest):

| Theme | Commits | Examples |
|---|---|---|
| Privacy/compliance docs | 4 | `docs: privacy policy and terms of service for GitHub Pages`, `compliance: account deletion, EXIF stripping` |
| Brand & icon iteration | 13 | `brand: r3 icon APPROVED ✅`, `brand: lock official Danio art style`, `brand: Phase 1 bake-off` |
| Device audit fixes | 2 | `fix: device audit issues — empty state cleanup, contrast, filter clipping` |
| Settings rebuild | 1 | `ux: rebuild Settings screen — grouped sections, hierarchy, danger zone` |
| Practice/Smart polish | 3 | `fix: PracticeHub padding bug + real mastery %`, `ux: polish AI/Smart features` |
| Stories darkmode | 1 | `fix: Stories dark mode — replace 15+ hardcoded Colors with AppColors` |
| Onboarding | 1 | `ux: shorten onboarding — single welcome page` |
| Cleanup | 2 | `cleanup: remove dead HouseNavigator (twice)` |
| Quick-log feature | 1 | `ux: add quick-log water test mode` |
| Milestone snapshots | ~10 | `milestone(1)/(2)/(3)/(4)` — duplicate commits, likely cherry-picks of work also done elsewhere |
| Documentation | 4 | `docs: store listing, social launch kit`, `docs: UI perfection audit`, `docs: master plan + UX research` |

**Note on duplicates:** Some commits appear twice with slightly different messages (e.g., `milestone(1): build stability` × 2, `cleanup: remove dead HouseNavigator` × 2). This suggests the work was either cherry-picked between branches or done in parallel.

## Why a big merge is dangerous

Dry-run `git merge origin/master` from `openclaw/stage-system`:

```
69 rename/rename    ← stage-system reorganized files; master modified the originals
31 modify/delete    ← stage-system deleted obsolete code; master kept editing it
31 content          ← real text-level conflicts
 7 rename/delete    ← split decisions on file movements
 5 add/add          ← both branches independently added the same files
─────
143 total conflicts
 43 auto-merged (clean)
```

The **69 rename/rename** conflicts are the worst. Stage-system underwent major refactoring (notably moving `screens/home_screen.dart` → `screens/home/home_screen.dart` and pulling out subwidgets to `screens/home/widgets/`). Master kept modifying the old paths. Git can't auto-resolve these — every one needs manual decision: keep the rename, keep the master edit, or merge the edit into the new file location.

Estimated effort for a clean merge: **multiple sessions of careful conflict resolution**, with high risk of regression because there's no test coverage for the file-move + content-merge interaction.

## Files that diverged on both branches

87 files were modified on both branches since the common ancestor. Notable ones:

- `apps/aquarium_app/lib/screens/home/home_screen.dart` — Phase 2 fixes here, master has `quick-log water test mode`
- `apps/aquarium_app/pubspec.lock` — content conflict, normal for parallel dev
- `docs/privacy-policy.html` — **master 193 lines, stage-system 129 lines** (master is more complete)
- `docs/terms-of-service.html` — **master 289 lines, stage-system 71 lines** (master much more complete)
- `apps/aquarium_app/lib/screens/settings_hub_screen.dart` — settings rebuild on master, possibly redone on stage-system
- 14 widget core files on stage-system marked for delete by master refactor
- 16 test files in modify/delete state

## Recommended strategy

### Strategy D — Continue diverging, eventually replace master (RECOMMENDED)

**Premise:** stage-system is the integration branch. Treat master as a snapshot of the "old way." Don't try to keep them in sync.

**Steps:**

1. **Now (this session or next):** Continue Phase 3-5 development on `openclaw/stage-system`. Don't touch master.

2. **Cherry-pick targeted master-only commits onto stage-system** — only the ones that are clearly unique and valuable:
   - `77e314ba docs: privacy policy and terms of service for GitHub Pages` (master's privacy/terms are more complete)
   - `ea0987df brand: r3 icon APPROVED as final ✅` (final brand assets)
   - `60a69a4f brand: r6 mascot APPROVED ✅` (final mascot)
   - `5079e0bd ux: add quick-log water test mode` (verify this isn't already present in different form)

   For each cherry-pick: `git cherry-pick <sha>` → resolve any conflicts → run `flutter analyze && flutter test` → commit. If a cherry-pick is too messy, abort and manually port the change.

3. **When ready to ship (post-Phase 5 + final QA):**
   - Option A: Rename `openclaw/stage-system` → `master-new`, force-push to remote, change GitHub default branch from `master` to `master-new`, then archive old master as `master-archive`. Lowest effort but loses master's commit history.
   - Option B: Reset master to point at stage-system's HEAD (`git push --force origin openclaw/stage-system:master`). Cleanest if no one else has master checked out. **Requires explicit user authorization for force-push to master.**
   - Option C: Create a merge commit on master with `-X theirs` strategy to take stage-system as canonical. Preserves both histories but creates an ugly merge commit.

**Why this is the recommended path:**
- Avoids the 143-conflict merge entirely
- Cherry-picks are reversible per-commit
- Stage-system is already the source of truth for active development
- Master's unique value is contained in <10 commits, manageable to cherry-pick
- The "shipping" decision (Option A/B/C) can be deferred until after the fix brief is complete

### Strategy A — Big merge master → stage-system (NOT recommended)

Run `git merge origin/master`, resolve 143 conflicts manually, hope for the best. Risk:
- Breaks working code in subtle ways
- Requires re-running full test suite + manual smoke testing
- Easy to accidentally lose work or apply a master fix to a stale file location
- Estimated effort: 4-8 hours minimum, possibly 2-3 sessions

### Strategy B — Merge stage-system → master (NOT recommended without prep)

Same conflict count, plus master would lose its identity as the "stable" branch. If the goal is to make master the source of truth, Strategy D Option B is cleaner.

### Strategy C — Cherry-pick all 42 master commits onto stage-system (risky)

Most of the 42 commits will conflict because stage-system's file layout is different. Each cherry-pick could fail. Better to cherry-pick selectively (Strategy D step 2).

## Decision points for the user

1. **Are master's privacy policy / terms of service the canonical version?** If yes, cherry-pick `77e314ba` onto stage-system.
2. **Are master's brand iterations (r3 icon, r6 mascot) the final approved versions?** If yes, cherry-pick those commits.
3. **Is `quick-log water test mode` (commit `5079e0bd`) already on stage-system in some form?** Worth checking before cherry-picking.
4. **What's the long-term plan for master?** Archive, rebuild from stage-system, or keep as a "polish" branch?

## Verification steps when executing the plan

For each cherry-picked commit:
- `git cherry-pick <sha>`
- If conflicts: resolve manually, run `flutter analyze`, run `flutter test`
- `git cherry-pick --continue` (if conflict resolution went well) OR `git cherry-pick --abort` (if too messy)
- After successful cherry-pick: smoke test on Android emulator
- Commit message preserved from original master commit

When ready to "promote" stage-system to master:
- Tag the current master HEAD: `git tag master-archive-pre-promotion origin/master`
- Push tag: `git push origin master-archive-pre-promotion`
- Then execute Option A, B, or C from Strategy D step 3
- Verify GitHub default branch in repo settings

## Files referenced

- `repo/CLAUDE.md` — current working branch convention (`openclaw/stage-system`)
- `repo/docs/planning/2026-04-danio-fix-brief-concept-lock.md` — Phase 2 context
- `https://github.com/tiarnanlarkin/danio/pull/1` — Phase 2 merged PR (already on stage-system)
