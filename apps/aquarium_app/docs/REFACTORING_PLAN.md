# Refactoring Plan — Large Provider Decomposition

> Status: **PLANNED — DO NOT EXECUTE PRE-LAUNCH**
> Author: Daedalus · Wave E.1
> Last updated: March 2026

This document covers the planned decomposition of `UserProfileNotifier` (and notes on `AchievementProgressNotifier`). Neither refactor should happen before v1.0.0 ships — the risk/reward is wrong at this stage. This plan exists so the work can begin immediately post-launch.

---

## 1. UserProfileNotifier — Current State

**File:** `lib/providers/user_profile_notifier.dart`
**Lines:** 1,084

### Responsibilities (too many for one class)

`UserProfileNotifier` currently owns at least **seven distinct concerns**:

| # | Concern | Key Methods |
|---|---|---|
| 1 | **Persistence** | `_load`, `_save`, `_saveImmediate`, `_onLifecyclePause`, `_trimXpHistory` |
| 2 | **Profile CRUD** | `createProfile`, `updateProfile`, `skipPlacementTest`, `resetProfile` |
| 3 | **XP & Streaks** | `recordActivity`, `addXp`, `_applyXp`, `getTodayXp`, `getTodayKey`, `_isSameWeek`, `_updatedWeeklyXP`, `setDailyGoal` |
| 4 | **Lesson tracking** | `completeLesson`, `reviewLesson`, `completePlacementTest`, `_createReviewCardsForLesson`, `_findLessonById`, `getLessonsNeedingReview`, `getWeakestLessons` |
| 5 | **Hearts** | `updateHearts` (with refill logic) |
| 6 | **Achievements** | `unlockAchievement`, `updateAchievements`, `incrementPerfectScoreCount` |
| 7 | **Stories** | `updateStoryProgress` |
| 8 | **Leagues / Gems (bonus)** | `_calculateLeagueFromXP`, `awardQuizGems` |

The class also mixes sync helpers (`getTodayXp`, `hasProfile`, `getWeakestLessons`) with heavy async operations, making it hard to test either in isolation.

---

## 2. Proposed Decomposition

Split into **5 focused notifiers** (plus the existing persistence layer):

### 2.1 `UserProfileCoreNotifier` (keep as-is, slimmed)
**Retains:** `createProfile`, `updateProfile`, `skipPlacementTest`, `resetProfile`, `hasProfile`, `_load`, `_save`, `_onLifecyclePause`, `_trimXpHistory`

The base class that owns the `UserProfile` state and disk persistence. All other notifiers read this via `ref.watch` and call it to commit changes. Single source of truth.

~250 lines target.

---

### 2.2 `XpStreakNotifier`
**Extracts:** `recordActivity`, `addXp`, `_applyXp`, `getTodayXp`, `getTodayKey`, `_formatDate`, `_isSameWeek`, `_updatedWeeklyXP`, `setDailyGoal`, `addStreakFreeze`, `_calculateLeagueFromXP`

**State type:** Could be a derived `StateNotifier<XpStreakState>` (a simple value object wrapping streak, level, daily XP, weekly XP, league).

**Why extract first:** This is the most self-contained concern. The streak logic is already well-tested in isolation. Extracting it makes the streak UI rebuild graph smaller and is the lowest-risk extraction.

~200 lines target.

---

### 2.3 `LessonProgressNotifier`
**Extracts:** `completeLesson`, `reviewLesson`, `completePlacementTest`, `_createReviewCardsForLesson`, `_findLessonById`, `getLessonsNeedingReview`, `getWeakestLessons`, `awardQuizGems`

**State type:** Could be `AsyncValue<Map<String, LessonProgress>>` or a dedicated `LessonProgressState`.

**Why:** Already naturally isolated. The lesson data model (`LessonProgress`) exists. Splitting this removes a large chunk of async complexity from the main notifier.

~250 lines target.

---

### 2.4 `HeartsNotifier`
**Extracts:** `updateHearts` (+ the heart-refill timer logic)

**State type:** `HeartsState { int current, int max, DateTime? lastRefill }`

This is small enough to be trivial but benefits from isolation: the hearts UI can watch a tiny state object instead of the entire `UserProfile`.

~80 lines target.

---

### 2.5 `StoryProgressNotifier`
**Extracts:** `updateStoryProgress`

**State type:** `Map<String, StoryProgress>`

Minor extraction but makes the story screen watchable independently.

~60 lines target.

---

### Achievement Concern
`unlockAchievement`, `updateAchievements`, `incrementPerfectScoreCount` — these currently live in `UserProfileNotifier` but logically belong with `AchievementProgressNotifier`. Post-refactor, delegate to `AchievementProgressNotifier` directly and remove the duplicate surface from `UserProfileNotifier`.

---

## 3. AchievementProgressNotifier — Current State

**File:** `lib/providers/achievement_provider.dart`
**Lines:** 736

Already reasonably focused — handles achievement checking, progress tracking, and the `AchievementChecker` helper class. Does not need urgent decomposition.

**Minor improvement:** The `AchievementChecker` class (line ~142) and `AchievementFilter` class (line ~706) could eventually be extracted to `lib/utils/achievement_checker.dart` and `lib/utils/achievement_filter.dart` respectively, keeping `achievement_provider.dart` as pure Riverpod state management.

Estimated improvement: ~150 lines removed from the file. Low priority.

---

## 4. Migration Strategy

### Phase 1 — Extract `XpStreakNotifier` (First, Safest)
1. Create `lib/providers/xp_streak_notifier.dart`
2. Move all streak/XP methods and state
3. `UserProfileNotifier` delegates to it or reads from it
4. Update all `ref.watch(userProfileProvider)` call sites that only need streak data

**Estimated effort:** 1–2 days
**Risk:** Low — streak logic is already isolated by method boundaries

### Phase 2 — Extract `LessonProgressNotifier`
1. Create `lib/providers/lesson_progress_notifier.dart`
2. Audit all `completeLesson`/`reviewLesson` callers (lesson screen, placement test screen)
3. Move `LessonProgress` reads out of `UserProfile` state or keep as nested reference

**Estimated effort:** 2–3 days
**Risk:** Medium — lesson completion triggers XP + achievement updates, so the ordering of cross-notifier calls matters

### Phase 3 — Extract `HeartsNotifier` and `StoryProgressNotifier`
Both small, low-risk. Can be done in a single session.

**Estimated effort:** 0.5 days each

### Phase 4 — Slim `UserProfileNotifier` to `UserProfileCoreNotifier`
Rename, clean up residual methods, update barrel exports in `user_profile_provider.dart`.

**Estimated effort:** 1 day

---

## 5. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Cross-notifier ordering bugs (XP + achievements trigger simultaneously) | Medium | High | Use `ref.listenSelf` and explicit sequencing; add integration tests pre-extraction |
| Stale state during extraction (old callers miss new provider) | Low | Medium | Barrel re-export `user_profile_provider.dart` so callers don't need updating immediately |
| Save race conditions (two notifiers write `UserProfile` concurrently) | Low | High | Keep a single write path through `UserProfileCoreNotifier`; other notifiers never write directly |
| Breaking existing UI while launch reviews are in progress | High (if done now) | High | **Do not start until v1.0.0 is live and rated** |

---

## 6. Estimated Total Effort

| Phase | Effort | When |
|---|---|---|
| Phase 1 — XpStreakNotifier | 1–2 days | Post-launch Week 1 |
| Phase 2 — LessonProgressNotifier | 2–3 days | Post-launch Week 2 |
| Phase 3 — Hearts + Stories | 1 day | Post-launch Week 2 |
| Phase 4 — Finalise Core | 1 day | Post-launch Week 3 |
| **Total** | **~6–8 days** | |

---

## 7. Success Criteria

After full decomposition:
- `UserProfileNotifier` (or `UserProfileCoreNotifier`) is under 300 lines
- Each extracted notifier has a single clear purpose
- All existing tests pass without modification
- No regressions in streak continuity, lesson completion, or achievement unlock

---

*This plan should be reviewed and updated after v1.0.0 ships — real-world usage patterns may change priorities.*
