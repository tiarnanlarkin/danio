# Production Audit: Learning System & Gamification

**Date:** 2026-03-15  
**Auditor:** Production Release Auditor (subagent)  
**Scope:** Full learning and gamification system  
**Codebase:** `apps/aquarium_app/lib/`  
**Status:** READ-ONLY audit — no files modified  

---

## Summary

| Severity | Count | Description |
|----------|-------|-------------|
| **P0** | 2 | Crash-level bugs |
| **P1** | 5 | Functional issues affecting UX |
| **P2** | 10 | Quality/polish issues |

---

## 1. Lesson Flow

### P0-001: Empty Quiz Crash — IndexOutOfBoundsException
**Files:** `lib/screens/lesson_screen.dart` (line ~350), `lib/data/lessons/fish_health.dart`, `lib/data/lessons/species_care.dart`, `lib/data/lessons/advanced_topics.dart`  
**Issue:** 17 lessons define `quiz: Quiz(... questions: [])` — an empty question list. When the quiz UI renders, it accesses `quiz.questions[_currentQuizQuestion]` where `_currentQuizQuestion = 0`, causing an `IndexOutOfBoundsException` crash. Additionally, the results screen calculates `_correctAnswers / quiz.questions.length * 100` which is a **division by zero**.  
**Affected lessons:**  
- `advanced_topics`: ALL 6 lessons (breeding, aquascaping, saltwater, biotopes + 2 more)
- `fish_health`: 5 of 6 lessons (ich, fin_rot, fungal, quarantine, prevention)
- `species_care`: 6 of 7 lessons (betta, guppy, tetras, shrimp, snails + 1 more)

**Mitigation:** These paths are gated as "Coming Soon" in `learn_screen.dart` via `_comingSoonPathIds`, so users can't normally reach them. But the guard is UI-only — a deep link or code change could expose the crash.  
**Suggested fix:** Add a guard in `_buildQuiz()`: if `quiz.questions.isEmpty`, skip directly to `_completeLesson()` or show a "quiz coming soon" message. Never access `quiz.questions[0]` without a length check.

### P0-002: Gems Provider — Final Field Reassignment (Compile Error)
**File:** `lib/providers/gems_provider.dart` (lines 66-67, 79-85)  
**Issue:** `_cumulativeEarned` and `_cumulativeSpent` are declared as `final int` but later reassigned in `_load()`. This is a Dart compile-time error. Either: (a) the code path is unreachable and the fields are dead code, or (b) this breaks compilation. The `totalEarned`/`totalSpent` getters recalculate from transaction history instead of using these fields, so the feature "works" but these fields are broken dead code.  
**Secondary issue (same file, line 203):** Truncated comment: `// Store original state for rollb      final originalState = current;` — the comment is cut off mid-word, though the code after it is syntactically valid.  
**Suggested fix:** Change `final int _cumulativeEarned = 0;` to `int _cumulativeEarned = 0;` (and same for `_cumulativeSpent`), or remove them entirely if unused.

### ✅ No Hearts Check Before Lesson Start — By Design
**File:** `lib/screens/learn_screen.dart` (`_buildExpandedContent`)  
**Finding:** Users with 0 hearts CAN tap and start a lesson. Hearts are only deducted on wrong quiz answers, matching Duolingo's model. The `canStartLesson()` method exists in `HeartsService` but is intentionally not called pre-navigation. When hearts reach 0 mid-quiz, the `OutOfHeartsModal` fires correctly, offering "Practice to Earn Heart" or "Wait for Refill".  
**Verdict:** Working as designed.

### ✅ Lesson Prerequisites Enforced in UI
**File:** `lib/screens/learn_screen.dart` (`_buildExpandedContent`)  
**Finding:** Locked lessons show a lock icon, are disabled (`enabled: isUnlocked`), and show a snackbar "Complete the previous lesson to unlock this one 🔒" when tapped. Prerequisites checked via `lesson.isUnlocked(completedLessons)`.  
**Verdict:** Correctly enforced.

### ✅ All Lessons Completed — Path Shows as Complete
**File:** `lib/screens/learn_screen.dart`  
**Finding:** Completed paths show a green progress bar, success-tinted styling, and correct "X/X" count badge. Overall progress bar at top tracks paths completed.  
**Verdict:** Working correctly.

### P2-001: Practice Mode — Half XP, No Quiz Bonus Clarity
**File:** `lib/screens/lesson_screen.dart` (line ~65)  
**Issue:** Practice mode awards `totalXp ~/ 2` (integer division). The AppBar shows `+${widget.lesson.xpReward ~/ 2} XP` but doesn't include quiz bonus in the displayed amount, while the actual award includes it. Minor UX inconsistency.  
**Suggested fix:** Either show "up to +X XP" consistently in practice mode too, or ensure the label exactly matches the awarded amount.

### ✅ XP Awarded Correctly — No Double-Awarding
**File:** `lib/providers/user_profile_provider.dart` (`completeLesson`)  
**Finding:** `completeLesson()` checks `completedLessons.contains(lessonId)` first — if already completed, returns early. XP is added directly and `recordActivity(xp: 0)` is called with 0 to avoid double-counting (only streak bonus added there). Well-documented with inline comments explaining the XP flow.  
**Verdict:** No double-awarding possible.

### P2-002: Double Card Seeding Call (Harmless but Wasteful)
**File:** `lib/screens/lesson_screen.dart` (`_completeLesson`, lines ~540-555)  
**Issue:** After calling `completeLesson()` (which internally calls `_createReviewCardsForLesson` → `autoSeedFromLesson`), the code ALSO calls `autoSeedFromLesson` directly. The duplicate check in `autoSeedFromLesson` prevents actual duplicate cards (checks by `conceptId`), but it's wasted work.  
**Suggested fix:** Remove the direct `autoSeedFromLesson()` call in `lesson_screen.dart` since `completeLesson()` already handles it.

---

## 2. Quiz System

### ✅ Answer Selection — Tap → Check → Reveal → Next
**File:** `lib/screens/lesson_screen.dart` (`_buildQuiz`)  
**Finding:** Flow works correctly:
1. User taps answer → `_selectedAnswer` set, answer highlighted in primary color
2. "Check Answer" button validates → `_answered = true`, correct/incorrect revealed with green/red styling
3. "Next Question" advances → resets state for next question
4. After last question → "See Results" transitions to results screen

User CAN change answer before checking (tapping another option updates `_selectedAnswer`). Cannot change after checking (`_answered ? null : () => setState...`).  
**Verdict:** Working correctly.

### P1-001: Empty Quiz — No Guard Before Rendering
**File:** `lib/screens/lesson_screen.dart` (`_buildQuiz`)  
**Issue:** (See P0-001 above.) When `quiz.questions.isEmpty`, the quiz renders and immediately crashes. The `_buildLesson` method shows "Take Quiz" button when `quiz != null`, regardless of whether questions exist.  
**Suggested fix:** Add `quiz != null && quiz.questions.isNotEmpty` check before showing "Take Quiz" button. If quiz has no questions, show "Complete Lesson" directly.

### ✅ Score Calculation Correct
**File:** `lib/screens/lesson_screen.dart` (`_buildQuizResults`)  
**Finding:** `percentage = (_correctAnswers / quiz.questions.length * 100).round()` — correct formula (assuming non-empty questions, see P0-001).

### ✅ Pass/Fail at Exactly 70%
**Finding:** `passed = percentage >= quiz.passingScore` where `passingScore = 70`. At exactly 70% (e.g., 7/10): `7/10 * 100 = 70.0 → .round() = 70 → 70 >= 70 = true`. Passes correctly.

### ✅ Explanations Shown for Both Correct and Incorrect
**File:** `lib/screens/lesson_screen.dart` (`_buildQuiz`, option items)  
**Finding:** Explanation container shown whenever `_answered && question.explanation != null` — regardless of whether the selected answer was correct. Both correct and incorrect answers get explanations.  
**Verdict:** Working correctly.

### P1-002: Accessibility — Screen Reader Announces Result But Not Explanation
**File:** `lib/screens/lesson_screen.dart` (~line 465)  
**Issue:** `SemanticsService.announce()` announces "Correct!" or "Incorrect. The correct answer is X." but doesn't read the explanation text. Screen reader users may miss the educational explanation.  
**Suggested fix:** Append explanation text to the semantics announcement.

---

## 3. Spaced Repetition

### P2-003: Not SM-2 Algorithm — Simplified Interval System
**File:** `lib/models/spaced_repetition.dart` (`_calculateNextInterval`)  
**Issue:** The system uses a simplified strength-threshold model, not the actual SM-2 algorithm (which uses an easiness factor, quality rating 0-5, and graduated intervals). The current algorithm:
- Incorrect → reset to day1
- Strength < 0.6 → day1
- Strength ≥ 0.6 → day7
- Strength ≥ 0.8 → day14
- Strength ≥ 0.9 → day30

This skips `day3` interval entirely — it's defined in the enum but never returned by `_calculateNextInterval`. Cards jump from day1 straight to day7 once strength hits 0.6 (3 correct answers in a row: 0.0 → 0.2 → 0.4 → 0.6).  
**Impact:** Users either review too frequently (day1) or too infrequently (day7). The day3 "bridge" interval is never used.  
**Suggested fix:** Use `day3` for strength 0.4-0.6 range: `if (strength >= 0.4) return ReviewInterval.day3;`

### ✅ Card Creation — No Duplicates
**File:** `lib/providers/spaced_repetition_provider.dart` (`autoSeedFromLesson`)  
**Finding:** Each card is checked against existing cards by `conceptId` before creation: `if (!state.cards.any((c) => c.conceptId == conceptId))`. Concept IDs are deterministic (`${lessonId}_section_$sectionIndex`), so duplicate calls safely skip. Max 5 cards per lesson to prevent overwhelm.  
**Verdict:** Working correctly.

### P2-004: Due Card Calculation — Not Timezone Aware
**File:** `lib/models/spaced_repetition.dart` (`isDue` getter)  
**Issue:** `isDue` uses `DateTime.now()` (local time) compared to `nextReview` which is stored from `DateTime.now()` at review time. If the user changes timezone, cards could appear due early or late. The main streak system uses UTC normalization (good), but spaced repetition does not.  
**Suggested fix:** Store and compare `nextReview` in UTC consistently.

### ✅ All Cards Reviewed — Empty State
**File:** `lib/screens/spaced_repetition_practice_screen.dart`  
**Finding:** When `dueCount == 0`, shows a friendly "All caught up!" state with next review countdown, total cards mastered, and options to start a standard session anyway. Well-implemented empty state.

### P2-005: Card Content Missing for Old Cards
**File:** `lib/providers/spaced_repetition_provider.dart` (`autoSeedFromLesson`)  
**Issue:** The `questionText` field was added later to pre-populate card content. Cards created before this addition will have `questionText: null`, and the practice screen would need to re-load lesson data to display them. The code handles this with `_safeStringField` dynamic dispatch, which is fragile.  
**Severity:** P2 — only affects early adopters who created cards before the update.

---

## 4. XP & Leveling

### ✅ XP Sources — All Working
**Finding:** XP awarded from:
- Lessons: 50 XP base (`XpRewards.lessonComplete`)
- Quizzes: 25 XP bonus for passing (`quiz.bonusXp`)
- Activities: Via `recordActivity()` — water tests (15), water changes (10), tasks (20)
- Streaks: 25 XP daily streak bonus (`XpRewards.dailyStreak`)
- Practice: Half XP of normal lesson

All sources route through `addXp()` or `completeLesson()` → `_saveImmediate()`. Critical saves use `_saveImmediate` (bypasses debouncer). Non-critical saves debounced at 200ms.

### ✅ Level Thresholds — Balanced
**Finding:** Thresholds: 0→Beginner, 100→Novice, 300→Hobbyist, 600→Aquarist, 1000→Expert, 1500→Master, 2500→Guru.
- Reach Novice: ~2 lessons (100 XP)
- Reach Hobbyist: ~4-5 lessons (300 XP)
- Reach Aquarist: ~8-10 lessons (600 XP)
- Reach Expert: ~13-15 lessons (1000 XP)
- Reach Master: ~20 lessons (1500 XP)
- Reach Guru: ~33 lessons (2500 XP)

With 44 total lessons, Guru is reachable before completing all content. Progressive difficulty feels balanced.

### ✅ Level Titles — Sensible
**Finding:** Beginner → Novice → Hobbyist → Aquarist → Expert → Master → Guru. Each title makes sense for the domain and represents increasing mastery. Level-up celebration dialog shows appropriate unlock messages.

### ✅ XP Boost — Applied Once Only
**File:** `lib/providers/user_profile_provider.dart` (`_applyXp`)  
**Finding:** Single `_applyXp()` helper: `return xpBoostActive ? amount * 2 : amount;`. Used consistently in both `addXp()` and `recordActivity()`. No double-boosting possible. Well-documented with comment "All XP additions MUST go through this helper to prevent double-boosting."

### ✅ Daily XP Goal — Progress Tracked Correctly
**File:** `lib/providers/user_profile_provider.dart`, `lib/models/daily_goal.dart`  
**Finding:** `dailyXpHistory` maps date strings ("YYYY-MM-DD") to XP earned. `todaysDailyGoalProvider` creates a `DailyGoal` from today's history entry. Progress bar on home screen reflects correctly. History capped at 365 entries to prevent unbounded growth.

---

## 5. Hearts System

### ✅ Starting Hearts, Max Hearts
**File:** `lib/services/hearts_service.dart`  
**Finding:** `startingHearts = 5`, `maxHearts = 5`. Default in UserProfile: `hearts = 5`. New profiles start with full hearts.

### ✅ Hearts Can't Go Below 0 or Above Max
**File:** `lib/services/hearts_service.dart` (`_updateHearts`)  
**Finding:** `newHearts.clamp(0, HeartsConfig.maxHearts)` — clamped both ways. `loseHeart()` also checks `hearts <= 0` before deducting.

### ✅ Heart Loss on Wrong Answer
**File:** `lib/screens/lesson_screen.dart` (`_buildQuiz` button handler)  
**Finding:** On wrong answer in non-practice mode: calls `heartsService.loseHeart()`, shows heart loss animation, then checks if out of hearts. Clean flow.

### ✅ Refill Timer — 1 Hour Per Heart
**File:** `lib/services/hearts_service.dart`  
**Finding:** `refillInterval = Duration(minutes: 60)`. Auto-refill checked via `calculateAutoRefill()` which calculates intervals passed since `lastHeartRefill`. Full refill from 0 = 5 hours. Timer started when hearts drop below max.

### P1-003: Gem-Based Hearts Refill — Cost May Be Prohibitive
**File:** `lib/data/shop_catalog.dart`  
**Issue:** Hearts Refill costs **50 gems** in the shop. Earning 50 gems requires substantial effort:
- Lesson completion: 3 gems each → ~17 lessons
- Quiz pass: 3 gems → ~17 quizzes
- Daily goal: 2 gems → 25 days

For new users who are struggling (hence losing hearts), 50 gems is very expensive. No gem-based refill option is shown in the `OutOfHeartsModal` — only "Practice to Earn Heart" and "Wait for Refill".  
**Suggested fix:** Either add a gem refill option to the out-of-hearts modal, or reduce the shop price to ~20-25 gems.

### ✅ Practice Mode Bypasses Heart Deduction
**File:** `lib/screens/lesson_screen.dart` (`_buildQuiz`)  
**Finding:** Heart deduction is wrapped in `if (!widget.isPracticeMode && !isCorrect)`. Practice mode skips heart loss entirely AND awards +1 heart on completion via `heartsService.gainHeart()`.

### ✅ Out-of-Hearts UX — Clear and Helpful
**File:** `lib/widgets/hearts_widgets.dart` (`OutOfHeartsModal`)  
**Finding:** Shows sad emoji, "Out of Hearts" title, explanation, countdown timer, and two clear options: "Practice to Earn Heart" (primary button) or "Wait for Refill" (outlined button). First-time hearts explanation dialog shown on first lesson.

---

## 6. Gems & Economy

### ✅ Earn Sources — All Working
**Finding:**
| Source | Gems | Status |
|--------|------|--------|
| Lesson complete | 3 | ✅ Via `completeLesson()` |
| Quiz pass | 3 | ✅ Via `awardQuizGems()` |
| Quiz perfect | 5 | ✅ Via `awardQuizGems(isPerfect: true)` |
| Placement test | 10 | ✅ Via `completePlacementTest()` |
| Lesson review | 2 | ✅ Via `reviewLesson()` |
| Daily goal met | 2 | ✅ Via `recordActivity()` |
| Streak milestones | 10-365 | ✅ Via `recordActivity()` → `getStreakMilestoneReward()` |
| Level up | 10-200 | ✅ Via `completeLesson()` → `getLevelUpReward()` |
| Achievement unlock | 5-50 | ✅ Via `unlockAchievement()` |

### ✅ Spend Sinks — Working
**Finding:** 22 shop items across Power-ups (5), Extras (5), Cosmetics (12). Prices: 5-500 gems. Atomic transaction with rollback on save failure.

### ✅ Balance Can't Go Negative
**File:** `lib/providers/gems_provider.dart` (`spendGems`)  
**Finding:** Checks `current.balance < amount` before spending. Returns `false` if insufficient. Mutex `_spending` prevents concurrent spends.

### P1-004: Transaction History Capped at 100 — Lifetime Stats Inaccurate
**File:** `lib/providers/gems_provider.dart` (line ~118)  
**Issue:** Transaction history trimmed to 100 entries. The `totalEarned` and `totalSpent` getters recalculate from this capped list, so after 100+ transactions, lifetime totals will undercount. The `_cumulativeEarned`/`_cumulativeSpent` fields were intended to fix this but are broken (declared `final` — see P0-002).  
**Suggested fix:** Fix the cumulative counters (remove `final` keyword) so they track accurate lifetime totals independently of the truncated transaction log.

### P2-006: Transaction History UX — Not Easily Accessible
**File:** `lib/providers/gems_provider.dart`  
**Issue:** `recentGemTransactionsProvider` exists and returns last 20 transactions, but there's no dedicated "Transaction History" screen visible in the navigation. Users can see balance but not spending history in a user-friendly way.  
**Suggested fix:** Add a transaction log accessible from the gem shop or profile screen.

---

## 7. Achievements

### Achievement Count: 55 Defined, 49 Earnable

**File:** `lib/data/achievements.dart`  
**Finding:** 55 achievements defined in `AchievementDefinitions.all`:
- Learning Progress: 11 (6 hidden, unimplemented)
- Streaks: 13
- XP Milestones: 8
- Special: 12 (comment says 11 — minor typo)
- Engagement: 11 (comment says 12 — minor typo)

### P1-005: 6 Hidden Achievements Are Unearnable
**File:** `lib/services/achievement_service.dart` (lines ~110-120)  
**Issue:** These 6 achievements have `shouldUnlock = false` with comment "Not implemented":
- `beginner_master` — "Beginner Graduate"
- `intermediate_master` — "Intermediate Expert"
- `advanced_master` — "Advanced Scholar"
- `water_chemistry_master` — "Chemistry Whiz"
- `plants_master` — "Green Thumb"
- `livestock_master` — "Fish Whisperer"

They are `isHidden: true` so users won't see them in the trophy case (hidden until unlocked), and they're excluded from the `completionist` check (which filters `!a.isHidden`). However, they add phantom entries to the total count, and if a user somehow discovers them (e.g., data inspection), it creates false expectations.  
**Suggested fix:** Either implement the path-completion logic (check if all lessons in the relevant path are completed) or remove them from the `all` list until implemented.

### ✅ Progress Tracking — Accurate
**Finding:** Each achievement type tracks its count correctly:
- Lesson count-based: uses `stats.lessonsCompleted`
- Streak-based: uses `stats.currentStreak`
- XP-based: uses `stats.totalXp`
- Time-based: checks `lastLessonCompletedAt.hour`
- Computed: weekend streaks, daily goal streaks, full hearts streak all computed from persistent profile data

### ✅ Celebration on Unlock — Works
**File:** `lib/providers/achievement_provider.dart` (`AchievementChecker.checkAchievements`)  
**Finding:** Shows `showAchievementUnlockedDialog()` for each newly unlocked achievement. Uses `_waitForNextFrame()` to prevent framework assertion crashes. Also sends push notification via `NotificationService`. XP and gems awarded via `unlockAchievement()`.

### ✅ Trophy Case — Filters Work
**File:** `lib/screens/achievements_screen.dart`, `lib/providers/achievement_provider.dart`  
**Finding:** Supports filtering by: unlocked/locked/all, category, rarity. Sorting by: rarity, date unlocked, progress, name. Completion percentage excludes hidden achievements. Progress bar and counts correct.

### P2-007: Achievement Count Comment Mismatch
**File:** `lib/data/achievements.dart` (lines ~608-620)  
**Issue:** Comments in the `all` list are wrong:
- "Special (11)" — actually 12 items
- "Engagement (12)" — actually 11 items
**Suggested fix:** Update comments to "Special (12)" and "Engagement (11)".

---

## 8. Streaks

### ✅ Daily Streak Increment — Correct Timing
**File:** `lib/providers/user_profile_provider.dart` (`recordActivity`)  
**Finding:** Uses UTC normalization for date comparison:
- Same day → no increment
- Next day (dayDifference == 1) → increment
- 2-day gap with freeze available → use freeze, continue streak
- Larger gap → reset to 1

First activity ever → streak = 1. Longest streak tracked separately.

### ✅ Streak Freeze — Works Correctly
**File:** `lib/providers/user_profile_provider.dart`, `lib/models/user_profile.dart`  
**Finding:** Streak freeze grants 1 free skip. Weekly reset on Monday (`shouldResetStreakFreeze` checks current vs granted Monday). Freeze consumed on 2-day gap. Shop sells additional streak freezes for 10 gems.

### ✅ Streak Display — Home Screen, Calendar, Badges
**File:** `lib/screens/learn_screen.dart` (`_StreakCard`)  
**Finding:** Shows streak count with fire emoji, freeze availability status, and encouraging message. `LearningStreakBadge` shows for users with lesson progress. `recentDailyGoalsProvider` provides 90 days of history for calendar view.

### P2-008: Streak Milestone Celebrations — Gems Only, No Visual
**File:** `lib/providers/user_profile_provider.dart` (`recordActivity`)  
**Issue:** Streak milestones (7, 14, 30, 50, 100, 365 days) award gems via `getStreakMilestoneReward()` but don't show a celebration dialog or animation. The XP streak bonus (25 XP) is added silently. Achievements fire separately (streak_3, streak_7, etc.) with their own celebration, but the gem milestone award has no visual feedback.  
**Suggested fix:** Show a brief toast or animation when streak gems are awarded: "🔥 7-day streak! +10 💎"

### P2-009: Streak Freeze — No Notification When Used
**File:** `lib/providers/user_profile_provider.dart`  
**Issue:** When a streak freeze is automatically consumed (user missed a day but had freeze), there's no notification or visual indicator. The user might not realize their freeze was used.  
**Suggested fix:** Show a notification: "❄️ Streak freeze saved your 15-day streak yesterday!"

---

## 9. Additional Cross-Cutting Issues

### P2-010: Shop Items — Some Power-Ups Have No Backend Implementation
**File:** `lib/data/shop_catalog.dart`  
**Issue:** Several shop items can be purchased but may lack full implementation:
- `timer_boost` (Timer Boost) — no timed lesson system exists
- `lesson_hints` (Lesson Helper) — no hint system in lesson UI
- `bonus_skill` (Bonus Skill Unlock) — no advanced content gating
- `quiz_retry` (Quiz Second Chance) — no retry mechanic in quiz flow
- `daily_goal_shield` (Goal Shield) — no goal shield check in streak logic
- `progress_protector` (Progress Protector) — no protection mechanic
- `weekend_amulet` (Weekend Amulet) — no weekend streak exception logic

Users can spend gems on these items, receive them in inventory, but they may have no effect. This is a gems-sink without value.  
**Suggested fix:** Either implement the mechanics, add "Coming Soon" labels to unpurchasable items, or remove them from the shop until functional.

---

## Findings Summary Table

| ID | Severity | Area | Issue |
|----|----------|------|-------|
| P0-001 | **P0** | Quiz | Empty quiz questions → IndexOutOfBounds + division by zero crash |
| P0-002 | **P0** | Gems | `final` field reassignment → compile error / dead code in cumulative tracking |
| P1-001 | **P1** | Quiz | No guard before rendering empty quiz — "Take Quiz" button shown for quizzes with 0 questions |
| P1-002 | **P1** | Quiz | Screen reader doesn't announce quiz explanations |
| P1-003 | **P1** | Hearts | Hearts refill costs 50 gems (prohibitive); no gem option in out-of-hearts modal |
| P1-004 | **P1** | Gems | Transaction history cap at 100 makes lifetime totals inaccurate |
| P1-005 | **P1** | Achievements | 6 achievements defined but permanently unearnable (shouldUnlock always false) |
| P2-001 | **P2** | Lessons | Practice mode XP label inconsistency |
| P2-002 | **P2** | Lessons | Double `autoSeedFromLesson()` call (harmless but wasteful) |
| P2-003 | **P2** | Spaced Rep | Not SM-2; day3 interval defined but never used — cards jump day1→day7 |
| P2-004 | **P2** | Spaced Rep | Due card calculation uses local time, not UTC |
| P2-005 | **P2** | Spaced Rep | Old cards may have null questionText |
| P2-006 | **P2** | Gems | No transaction history screen for users |
| P2-007 | **P2** | Achievements | Comment count mismatch (Special: 12 not 11, Engagement: 11 not 12) |
| P2-008 | **P2** | Streaks | Streak milestone gem awards have no visual feedback |
| P2-009 | **P2** | Streaks | Streak freeze consumption has no notification |
| P2-010 | **P2** | Shop | 7 shop items purchasable but possibly non-functional |

---

## What's Working Well

1. **XP system is robust** — Single `_applyXp()` helper, no double-awarding, proper save-immediate for critical writes
2. **Hearts system is solid** — Clamp prevents out-of-bounds, auto-refill works, practice bypass correct
3. **Achievement system is comprehensive** — 55 achievements, proper celebration dialogs, duplicate-guarded unlock
4. **Streak system uses UTC** — Timezone-resistant date normalization for streak comparison
5. **Gem economy has atomic transactions** — Rollback on save failure, mutex on spending
6. **Lesson prerequisites work** — UI correctly gates locked content with clear feedback
7. **Debounced saves with lifecycle flush** — Profile saves debounced at 200ms, flushed on app pause/detach
8. **Lazy-loaded lesson content** — 347KB startup savings via deferred imports
9. **Error resilience** — Most subsystems catch errors and continue rather than crashing
10. **Accessibility foundation** — Heart indicator, quiz results, and navigation are semantics-annotated

---

*End of audit.*
