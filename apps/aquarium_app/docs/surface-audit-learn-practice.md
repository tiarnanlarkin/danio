# Surface Audit — Learn · Lesson · Practice · Spaced Repetition · Stories · Learning Path Detail

**Auditor:** Argus (QA Director)
**Date:** 2026-03-29
**Scope:** Every screen, modal, button, state, and interaction across the six assigned areas.
**Repo:** `apps/aquarium_app`

---

## How to Read This Report

- **Classification key:** `✅ Complete` · `⚠️ Should Fix` · `🔴 Must Fix` · `🔍 Research First` · `⏳ Defer` · `🚫 Blocked` · `🔮 Future Scope`
- Each table covers one surface area.
- "Dead button" = button is rendered but does nothing, has no navigation, or silently fails.
- States checked: L = Loaded/Happy, E = Empty, Lo = Loading, Er = Error, Of = Offline.

---

## Area 1 — Learn Screen

**File:** `lib/screens/learn/learn_screen.dart` (implementation)
`lib/screens/learn_screen.dart` (re-export shim)

### Summary

The main learn tab. Scrollable canvas: illustrated header, XP/streak overlays, placement challenge card, learning streak badge, review banner, practice card, interactive stories section, learning paths list. First-visit tooltip on first open.

---

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Learn Screen — Header | Illustrated `learn_header.webp` gradient banner (32% vh) | L, Of | ✅ | errorBuilder present; renders solid gradient on error | ✅ Complete |
| Learn Screen — Header | XP / level badge (top-left, `⭐ N XP · Level`) | L, null profile | ✅ | Non-tappable — display only. No dead button. | ✅ Complete |
| Learn Screen — Header | Streak badge (top-right, `🔥 N`) — only rendered when streak > 0 | L, streak=0 | ✅ | Non-tappable — display only. Correctly hidden when streak=0. | ✅ Complete |
| Learn Screen | `RefreshIndicator` (pull-to-refresh) | L | ✅ | Invalidates `userProfileProvider`, `learningStatsProvider`, `pathMetadataProvider`. Functional. | ✅ Complete |
| Learn Screen | Loading skeleton (`_buildSkeletonScreen`) | Lo | ✅ | Skeletonizer renders 4 fake path cards with progress bars. Correct semantic `liveRegion`. | ✅ Complete |
| Learn Screen | Error state (`AppErrorState`) | Er | ✅ | Shown when `userProfileProvider.hasError`. Retry button calls `ref.invalidate(userProfileProvider)`. | ✅ Complete |
| Learn Screen | Null profile state ("Complete your profile setup") | null | ✅ | Shows `Create Profile` CTA → navigates to `OnboardingScreen`. XP/streak/paths all hidden. | ✅ Complete |
| Learn Screen | `Create Profile` button (null state) | null | ✅ | Pushes `OnboardingScreen` via `NavigationThrottle`. No dead button. | ✅ Complete |
| Learn Screen | First-visit tooltip (`FirstVisitTooltip`) | first visit only | ✅ | Persisted via `hasSeenTooltip`. Dismisses on tap. Doesn't interfere with navigation. | ✅ Complete |
| Learn Screen — Offline | No offline/connectivity guard | Of | ⚠️ | App is offline-first (data cached locally) so this is low risk, but no explicit offline message. On first install with no network, `userProfileProvider` loading may hang indefinitely with no timeout/error. | ⚠️ Should Fix |
| **PlacementChallengeCard** | Whole component | Lo, null | ✅ | Returns `SizedBox.shrink()` on loading or error — no flash. | ✅ Complete |
| PlacementChallengeCard | **"Take the test" button** | non-beginner, not completed/skipped | ⚠️ | Navigates to `SpacedRepetitionPracticeScreen` — **wrong destination**. Placement test should go to a dedicated quiz, not the spaced repetition practice screen. The `hasCompletedPlacementTest` field is never set to `true` from this flow (only `skipPlacementTest()` is called on skip). The card will reappear forever if user taps "Take the test" and goes through SR practice. | 🔴 Must Fix |
| PlacementChallengeCard | **"Skip for now" button** | visible | ✅ | Calls `ref.read(userProfileProvider.notifier).skipPlacementTest()`. Correctly sets `hasSkippedPlacementTest`. Card disappears. | ✅ Complete |
| PlacementChallengeCard | Hidden for beginners | experienceLevel=beginner | ✅ | Returns `SizedBox.shrink()`. Correct. | ✅ Complete |
| **LearningStreakBadge** | Badge row (📚 N-day learning streak!) | L, streak=0, streak=1 | ✅ | Renders only when streak ≥ 2. Non-interactive (display only). No dead button. | ✅ Complete |
| **LearnReviewBanner** | Whole banner — only shown when `dueCards > 0` | L, dueCards=0 | ✅ | Hidden when due=0. | ✅ Complete |
| LearnReviewBanner | **Tap anywhere on banner** | dueCards > 0 | ✅ | Navigates to `SpacedRepetitionPracticeScreen`. Correct. | ✅ Complete |
| LearnReviewBanner | Semantics | | ✅ | `Semantics(button: true, label: '...')` present. Screen-reader friendly. | ✅ Complete |
| **LearnPracticeCard** | Whole card — only shown when `weakCount > 0` | L, weakCount=0 | ✅ | Hidden when no weak lessons. | ✅ Complete |
| LearnPracticeCard | **Tap anywhere on card** | weakCount > 0 | ⚠️ | Navigates to `SpacedRepetitionPracticeScreen` — **same destination as the Review Banner**. Both cards appear on the same screen and route to the same place. No visual or behavioural distinction for the user. Potential for confusion. | ⚠️ Should Fix |
| **LearnStreakCard** | Streak card (only shown when `currentStreak > 0`) | L, streak=0, hasFreeze | ✅ | Non-interactive. Correctly hidden at streak=0. Freeze state renders correctly. | ✅ Complete |
| **_StoriesSection (GlassCard)** | Tap → `StoryBrowserScreen` | L | ✅ | `Navigator.of(context).push(MaterialPageRoute(...))`. Correct, no throttle (low-risk). | ✅ Complete |
| Learn Screen — Cold-start nudge | "New to fishkeeping? Start with the basics below." | completedLessons=0 | ✅ | Display only row. Not tappable (no dead button). Disappears after first lesson. | ✅ Complete |
| Learn Screen — Learning Paths header | Progress bar + "N of M paths complete" | L | ✅ | Calculated from metadata, renders correctly. | ✅ Complete |
| **LazyLearningPathCard** | ExpansionTile (collapsed) | L | ✅ | Lazy-loads full path on expansion. Shows BubbleLoader while loading. | ✅ Complete |
| LazyLearningPathCard | "Start Here 👋" badge | index=0 and completedLessons=0 | ✅ | Display only. Correct condition. | ✅ Complete |
| LazyLearningPathCard | Locked path tile (🔒 Locked) | isPathLocked=true | ✅ | Non-expandable. `onTap` shows `DanioSnackBar.warning` with prereq names. | ✅ Complete |
| LazyLearningPathCard | Coming Soon tile | comingSoonPathIds (empty set currently) | ✅ | Shows `showAppDialog` with "Coming Soon!" message + "Got it!" button. The set `comingSoonPathIds` is currently empty — no paths are gated. | ✅ Complete |
| LazyLearningPathCard | Lesson row — unlocked | isUnlocked=true | ✅ | `NavigationThrottle.push(LessonScreen(...))`. Hero animation on lesson icon. | ✅ Complete |
| LazyLearningPathCard | Lesson row — locked | isUnlocked=false | ✅ | `DanioSnackBar.warning` with "Complete the previous lesson to unlock this one 🔒". No navigation. | ✅ Complete |
| LazyLearningPathCard | Lesson row — completed | isCompleted=true | ✅ | Shows ✅ icon + "+N XP" label. Still tappable (allows replay). | ✅ Complete |
| LazyLearningPathCard | Path expand — loading state | isLoading=true | ✅ | Shows `BubbleLoader.small()` while path loads. | ✅ Complete |
| LazyLearningPathCard | Empty lesson list | path with 0 lessons | 🔍 | If a path somehow has 0 lessons, `_buildExpandedContent` returns `[Divider]` with no items. No empty-state message. Low risk since all paths have lessons. | 🔍 Research First |
| Learn Screen | **hasSeenTutorial** field in profile | | ⚠️ | `hasSeenTutorial` is read in `profileState` select but **never rendered** anywhere in `LearnScreen`. It's part of the profile watch tuple but has no effect on the screen. Dead watch — minor unnecessary compute. | ⚠️ Should Fix |
| Learn Screen | Animate: reduced motion | disableAnimations=true | ✅ | Both `.animate()` and non-animated paths render `LazyLearningPathCard`. The `reduceMotion` path renders the same widget twice (both branches identical — the non-animated path was never differentiated). | ⚠️ Should Fix |

---

## Area 2 — Lesson Screen

**Files:**
- `lib/screens/lesson/lesson_screen.dart` — orchestration
- `lib/screens/lesson/lesson_card_widget.dart` — content display
- `lib/screens/lesson/lesson_quiz_widget.dart` — quiz UI
- `lib/screens/lesson/lesson_completion_flow.dart` — quiz results + next lesson
- `lib/screens/lesson/lesson_hearts_modal.dart` — first-time energy explainer
- `lib/screens/lesson_screen.dart` — re-export shim

### Summary

Three sequential states: (1) lesson content card → (2) quiz widget → (3) completion flow. Back navigation intercepts mid-quiz with exit dialog. Energy system explained once on first lesson. Practice mode alters XP/heart behaviour.

---

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| **LessonScreen — AppBar** | Path title text (truncated with ellipsis) | long title | ✅ | `overflow: TextOverflow.ellipsis` present. | ✅ Complete |
| LessonScreen — AppBar | "PRACTICE" badge | isPracticeMode=true | ✅ | Renders amber chip. Correct. | ✅ Complete |
| LessonScreen — AppBar | `HeartIndicator(compact: true)` | normal, depleted | ✅ | Hidden in practice mode. Shown in lesson mode. | ✅ Complete |
| LessonScreen — AppBar | XP reward chip (`+N XP` or `up to +N XP`) | | ✅ | Display only. Correct formula. | ✅ Complete |
| LessonScreen — AppBar | Back button (`PopScope`) | mid-quiz, pre-quiz, complete | ✅ | `canPop: false`. Custom intercept. Calls `_confirmExitQuiz()`. Shows `showAppDestructiveDialog` mid-quiz. | ✅ Complete |
| **Hearts Explanation Modal** (`maybeExplainHearts`) | One-time modal on first lesson | first lesson, subsequent lessons | ✅ | Shown once via SharedPreferences key. `Got it!` → `Navigator.of(context).pop()`. | ✅ Complete |
| Hearts Explanation Modal | Skipped in practice mode | isPracticeMode=true | ✅ | Early return. Never shown in practice mode. | ✅ Complete |
| **LessonCardWidget — Lesson content** | Section type: `text` | | ✅ | Renders `AppTypography.bodyLarge` with lineHeight 1.6. | ✅ Complete |
| LessonCardWidget | Section type: `heading` | | ✅ | Renders `AppTypography.headlineMedium`. | ✅ Complete |
| LessonCardWidget | Section type: `keyPoint` | | ✅ | Lightbulb icon, primary-tinted box. | ✅ Complete |
| LessonCardWidget | Section type: `tip` | | ✅ | Green box with "Tip" label. | ✅ Complete |
| LessonCardWidget | Section type: `warning` | | ✅ | Amber box with "Heads up" label. | ✅ Complete |
| LessonCardWidget | Section type: `funFact` | | ✅ | Purple box with 🤓 and "Fun Fact" label. | ✅ Complete |
| LessonCardWidget | Section type: `bulletList` | | ✅ | Renders items split by `\n`. | ✅ Complete |
| LessonCardWidget | Section type: `numberedList` | | ✅ | Renders items split by `\n`. | ✅ Complete |
| LessonCardWidget | **Section type: `image`** | | 🔴 | **Placeholder only.** Shows grey box with `Icons.image_outlined` and "Visual guide on the way!" text. No actual image rendering. No lessons currently use `image` type, but if any are added, users will see an empty placeholder. Needs real implementation or removal of the type. | 🔴 Must Fix (when image sections added) |
| LessonCardWidget | Bottom CTA: **"Take Quiz"** (lesson has quiz) | | ✅ | Sets `_showQuiz = true`. Transitions to `LessonQuizWidget`. | ✅ Complete |
| LessonCardWidget | Bottom CTA: **"Complete Lesson"** (no quiz) | | ✅ | Calls `_completeLesson()` directly. No quiz flow. | ✅ Complete |
| LessonCardWidget | CTA disabled state | `isCompletingLesson=true` | ✅ | Button shows loading indicator. Prevents double-tap. | ✅ Complete |
| LessonCardWidget | Hero animation on lesson icon | | ✅ | `Hero(tag: 'lesson-${lesson.id}')` matches the path card icon. | ✅ Complete |
| **LessonQuizWidget — Quiz null** | Empty quiz state | quiz=null | ✅ | Shows "Quiz coming soon!" with outline icon. Safe. | ✅ Complete |
| LessonQuizWidget | Progress bar | 1 to N questions | ✅ | `LinearProgressIndicator` with correct fraction. Semantic label provided. | ✅ Complete |
| LessonQuizWidget | Question counter "N of M correct" | | ✅ | Updates after each answer. | ✅ Complete |
| LessonQuizWidget | **Hint button** (beginners only) | isBeginner=true, answered=false | ✅ | `ActionChip` "Need a hint?" renders only for beginners before answering. | ✅ Complete |
| LessonQuizWidget | **Hint text panel** | showHint=true | ✅ | Generic text: "Look for keywords in the question..." Reveals after chip tap. | ⚠️ Should Fix (hint is generic, not question-specific) |
| LessonQuizWidget | **Answer options (`QuizAnswerOption`)** | selected, answered-correct, answered-incorrect | ✅ | Bounce animation on correct answer. Scale + fade-in checkmark. Respects `disableAnimations`. | ✅ Complete |
| LessonQuizWidget | Answer option — tap disabled after answering | answered=true | ✅ | `onTap: null` when answered. | ✅ Complete |
| LessonQuizWidget | **Explanation panel** | answered=true, explanation present | ✅ | Shows info box with explanation text. Has `Semantics(liveRegion: true)`. | ✅ Complete |
| LessonQuizWidget | **"Check Answer" CTA** | selectedAnswer=null | ✅ | Button disabled when nothing selected. | ✅ Complete |
| LessonQuizWidget | "Check Answer" → submit | selectedAnswer≠null, !answered | ✅ | Calls `onCheckOrAdvance`. Energy deducted on wrong answer (non-practice). | ✅ Complete |
| LessonQuizWidget | **"Next Question" CTA** | answered=true, not last | ✅ | Advances to next question. Clears selection and hint state. | ✅ Complete |
| LessonQuizWidget | **"See Results" CTA** | answered=true, last question | ✅ | Sets `_quizComplete = true`. Transitions to `LessonCompletionFlow`. | ✅ Complete |
| LessonQuizWidget | Semantic announcement | answered | ✅ | `SemanticsService.sendAnnouncement` announces "Correct!" or "Incorrect. The correct answer is X." | ✅ Complete |
| **LessonCompletionFlow** | Passed state (emoji 🎉, varied passed messages) | percentage ≥ passingScore | ✅ | Random message from `passedMessage()`. Varied across 3 tiers (100%, ≥80%, <80%). | ✅ Complete |
| LessonCompletionFlow | Failed state (emoji 📚, varied try-again messages) | percentage < passingScore | ✅ | Random message from `tryAgainMessage()`. | ✅ Complete |
| LessonCompletionFlow | XP reward card | bonusXp=0, bonusXp>0 | ✅ | Shows total XP, optional "+N quiz bonus!" line. | ✅ Complete |
| LessonCompletionFlow | **"Complete Lesson" CTA** | isCompletingLesson=false | ✅ | Calls `onCompleteLesson()` which fires `_completeLesson()` in parent. | ✅ Complete |
| LessonCompletionFlow | "Complete Lesson" disabled | isCompletingLesson=true | ✅ | Loading state. Prevents double-submission. | ✅ Complete |
| **XP Award Animation** (`XpAwardOverlay.show`) | After completing lesson | | ✅ | Overlay shows. Checks level-up after XP animation. | ✅ Complete |
| **Level-Up Dialog** (`LevelUpDialog.show`) | New level reached | levelBeforeLesson < currentLevel | ✅ | Dialog blocks navigation until dismissed. | ✅ Complete |
| **Species Unlock Celebration** (`UnlockCelebrationScreen`) | Species unlocked by lesson | speciesId found | ✅ | Full-screen. Sparkle effect. Fish sprite (with fallback). | ✅ Complete |
| UnlockCelebrationScreen | **"See My Tank 🐟" CTA** | | ✅ | `Navigator.of(context).popUntil((route) => route.isFirst)` — goes to root (home/tank). | ✅ Complete |
| UnlockCelebrationScreen | **"Keep Learning" CTA** | | ✅ | `Navigator.of(context).pop()` — returns to lesson completion/path. | ✅ Complete |
| UnlockCelebrationScreen | Fish sprite asset missing | speciesId not in assets | ✅ | `errorBuilder` shows `_FallbackSprite` with 🐟 emoji. | ✅ Complete |
| **Next Lesson Bottom Sheet** | Shown after XP/level animation if next lesson exists | | ✅ | `showAppDragSheet`. Shows next lesson title. Two CTAs. | ✅ Complete |
| Next Lesson Bottom Sheet | **"Back to Path" CTA** | | ✅ | `Navigator.of(ctx).pop(false)` → pops sheet → then pops lesson screen. Returns to path. | ✅ Complete |
| Next Lesson Bottom Sheet | **"Start Next Lesson" CTA** | | ✅ | `Navigator.of(ctx).pop(true)` → `Navigator.of(context).pushReplacement(LessonScreen(...))`. Replaces current screen. | ✅ Complete |
| Next Lesson Bottom Sheet | In practice mode | isPracticeMode=true | ✅ | Sheet not shown in practice mode. Just pops back. | ✅ Complete |
| Next Lesson Bottom Sheet | No next lesson (path end) | nextLesson=null | ✅ | Just pops back. No sheet. | ✅ Complete |
| **Energy (Hearts) system** | Wrong answer → lose heart | non-practice, !isCorrect | ✅ | `heartsService.loseHeart()`. Shows heart animation. | ✅ Complete |
| Energy system | Energy depleted — soft block | hasHeartsAvailable=false | ✅ | **Not a hard block.** Shows `DanioSnackBar.info` "⚡ Energy depleted — keep going! No bonus XP until it refills." User can continue. This is correct design. | ✅ Complete |
| Energy system | Practice complete → gain heart | isPracticeMode=true | ✅ | `heartsService.gainHeart()`. Shows heart animation. | ✅ Complete |
| **Lesson completion error** | Save failure | network error | ✅ | `AppFeedback.showError` with retry callback. Retry re-calls `_completeLesson()`. | ✅ Complete |
| Exit Quiz dialog | Mid-quiz back press | | ✅ | `showAppDestructiveDialog` with "Leave" / "Keep going" options. | ✅ Complete |
| Exit Quiz dialog | Pre-quiz / post-quiz back press | `_showQuiz=false` or `_quizComplete=true` | ✅ | Allows immediate pop (returns `true` from `_confirmExitQuiz`). | ✅ Complete |
| **In-app review trigger** | After perfect score or streak ≥ 7 | | ✅ | One-time request, guarded by `review_requested` prefs key. | ✅ Complete |
| LessonScreen | **`isExitingDueToHearts` / `_isHeartsModalVisible` flags** | | ⚠️ | `_isHeartsModalVisible` is always false throughout the screen's lifecycle — it's set in `dispose()` but never set to `true` anywhere in the live code. The `maybeExplainHearts` dialog doesn't use it. This is dead state that was likely orphaned from an older hearts-block design. | ⚠️ Should Fix |

---

## Area 3 — Practice Hub Screen

**File:** `lib/screens/practice_hub_screen.dart`

### Summary

Tab 1 in the nav. Shows hero card (due/caught-up/empty state), stats row, practice modes section, mastery breakdown, progress cards. Routes to `SpacedRepetitionPracticeScreen`. First-visit tooltip.

---

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Practice Hub | First-visit tooltip | first visit | ✅ | `FirstVisitTooltip` with 🧪 emoji. Persisted via prefs. | ✅ Complete |
| Practice Hub | Header banner (180dp, gradient + illustration + title + HeartIndicator) | L | ✅ | `errorBuilder` present on image. `SafeArea` wrapping. | ✅ Complete |
| Practice Hub | `HeartIndicator(compact: true)` (top-right) | | ✅ | Display only. Shows current heart/energy state. | ✅ Complete |
| **Hero card — Due state** | Shows when `dueCards > 0` | dueCards > 0 | ✅ | Red icon, "Review Due Cards". Tap → `SpacedRepetitionPracticeScreen`. | ✅ Complete |
| Hero card — All caught up | Shows when `dueCards=0 && totalCards>0` | all due=0, has cards | ✅ | Green icon, "All Caught Up! 🎉". CTA "Try a new lesson" → `currentTabProvider.state = 0` (switches to Learn tab). | ✅ Complete |
| Hero card — No cards yet | Shows when `totalCards=0` | fresh account | ✅ | "🎴 No practice cards yet". CTA "Start Learning →" → tab switch to Learn. | ✅ Complete |
| **Stats row** | Due Today, Mastered, Total Cards | zero values | ✅ | BUG-05 fixed: grey color when value=0, semantic color only when >0. | ✅ Complete |
| **Practice Modes — "Spaced Repetition" card** | ListTile → `SpacedRepetitionPracticeScreen` | | ✅ | `NavigationThrottle.push`. Correct. | ✅ Complete |
| **Mastery Breakdown** | Progress bars by mastery level | totalCards=0 | ✅ | Empty state: "Complete lessons to earn flashcards and track your mastery here." | ✅ Complete |
| Mastery Breakdown | Cards with counts > 0 | | ✅ | Renders 5 mastery levels with progress bars + counts. | ✅ Complete |
| **Study Streak card** | Shows streak / "0 days" | streak=0, streak>0 | ✅ | BUG-06 fixed: neutral icon colour when streak=0. | ✅ Complete |
| **Cards Mastered card** | Shows mastered count | | ✅ | Display only. | ✅ Complete |
| **Practice Accuracy card** | Shows accuracy % or "Complete a review session" | totalReviews=0 | ✅ | Long CTA text rendered as subtitle (not truncated in trailing slot). | ✅ Complete |
| Practice Hub | **Error state from `spacedRepetitionProvider`** | errorMessage set | 🔴 | `srState.errorMessage` is **never checked or displayed** on the Practice Hub screen. If SR loading fails, the hub renders with all zeros — no error banner, no retry button. Users see "No practice cards yet" rather than an error. | 🔴 Must Fix |
| Practice Hub | **No profile error handling** | userProfileProvider error | ⚠️ | `userProfileProvider` is watched with `.select()` for streak only. If profile fails, `profile` defaults to null (streak=0) — screen renders normally with neutral streak. Low risk but no explicit error state. | ⚠️ Should Fix |
| Practice Hub | Item count constant `19` | | ⚠️ | `_getPracticeHubItemCount` always returns `19` regardless of state. If content changes, this magic number will cause index errors or missing items. | ⚠️ Should Fix |

---

## Area 4 — Spaced Repetition Practice Screen

**Files:**
- `lib/screens/spaced_repetition_practice/spaced_repetition_practice_screen.dart`
- `lib/screens/spaced_repetition_practice_screen.dart` (re-export shim)

### Summary

Launched from: Learn review banner, Practice Hub hero card, Practice Hub "Spaced Repetition" mode card, Learn practice card, PlacementChallengeCard (incorrectly). Handles loading state, empty state (no due cards), and the practice home (mode selection). Launches `ReviewSessionScreen` when a session is active.

---

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| **SR Practice — Loading** | `BubbleLoader` | isLoading=true | ✅ | Full-screen scaffold with spinner. Correct. | ✅ Complete |
| SR Practice — AppBar | "Practice" title + "📊 Statistics" icon button | | ✅ | Statistics dialog → `showAppDialog` with 7 stat rows + "Close" button. | ✅ Complete |
| **SR Practice — Empty state** (all caught up) | "All caught up!" hero | dueCards=0 | ✅ | Green circle, 🎯 emoji, "No reviews due right now." | ✅ Complete |
| SR Practice Empty | **"Try a new lesson" CTA** | | ✅ | `Navigator.of(context).popUntil((route) => route.isFirst)` — returns to root. | ✅ Complete |
| SR Practice Empty | "Next review in: N minutes/hours/days" | totalCards > 0 | ✅ | Calculated from next non-due card's `nextReview`. | ✅ Complete |
| SR Practice Empty | "Complete lessons to build your practice queue" text | totalCards=0 | ✅ | Shown when user has no cards at all. | ✅ Complete |
| **SR Practice — Practice Home** (dueCards > 0) | Stats card (gradient, Due/Today/Streak) | | ✅ | Display only. No interactive elements. | ✅ Complete |
| Practice Home | **"Standard Practice" mode card** (10 cards) | dueCards ≥ 1 | ✅ | Tappable. Calls `_startSession(ReviewSessionMode.standard)`. | ✅ Complete |
| Practice Home | **"Quick Review" mode card** (5 cards) | dueCards ≥ 1 | ✅ | Tappable. Calls `_startSession(ReviewSessionMode.quick)`. | ✅ Complete |
| Practice Home | **"Intensive Practice" mode card** (weak cards) | weakCards=0 | ✅ | Disabled (grey, `onTap: null`) when `weakCards=0`. Shows "None" badge. | ✅ Complete |
| Practice Home | Intensive Practice | weakCards > 0 | ✅ | Enabled. `_startSession(ReviewSessionMode.intensive)`. | ✅ Complete |
| Practice Home | **"Mixed Practice" mode card** (totalCards) | totalCards > 0 | ⚠️ | Tappable when `totalCards > 0`. But this screen is only shown when `dueCards > 0`, and `totalCards` includes already-mastered cards — so Mixed always shows a count. However, when `count=0` the card renders with `onTap: null` (dead but greyed). Low risk. | ✅ Complete |
| Practice Home | Mode card — `count=0` | | ✅ | `onTap: null`, shows "None" badge, greyed out. Not a dead button. | ✅ Complete |
| Practice Home | **Mastery Breakdown widget** | | ✅ | Renders MasteryLevel bars. Same as Practice Hub. | ✅ Complete |
| Practice Home | Session start error | `_startSession` throws | ✅ | `DanioSnackBar.error` with `onRetry`. | ✅ Complete |
| **SR Practice — Active session** | Delegates to `ReviewSessionScreen` | session not null | ✅ | Returns `ReviewSessionScreen(session: srState.currentSession!)`. | ✅ Complete |
| SR Practice | `errorMessage` from provider | provider error | ⚠️ | `srState.errorMessage` is **never displayed** on this screen. A failed card load or session start failure only shows a snackbar; the main screen shows no persistent error state. | ⚠️ Should Fix |

---

## Area 5 — Review Session Screen

**File:** `lib/screens/spaced_repetition_practice/review_session_screen.dart`

### Summary

Active flashcard review. Shows one card at a time: concept name + optional question text. User self-assesses with "Remembered" / "Forgot". Feedback panel shown after. Progress tracked in real time. Session complete → dialog with results.

---

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Review Session — AppBar | "Practice Session" title | | ✅ | | ✅ Complete |
| Review Session — AppBar | `HeartIndicator(compact: true)` | | ✅ | Display only. | ✅ Complete |
| Review Session — AppBar | **Close (✕) button** | mid-session | ✅ | Shows `_showExitDialog()`. Correct. | ✅ Complete |
| Review Session — AppBar | **Back button** (`PopScope`) | mid-session | ✅ | `canPop: false`. Triggers `_showExitDialog()`. | ✅ Complete |
| **Progress bar** | Card N of M, % complete | | ✅ | `LinearProgressIndicator` with correct fraction. | ✅ Complete |
| Progress bar | Accuracy row | cardsReviewed > 0 | ✅ | Shows correct / incorrect counts + accuracy %. | ✅ Complete |
| **Card content — concept name** | `_getQuestionText()` → `conceptDisplayName()` | | ✅ | Maps concept IDs to human-readable names. | ✅ Complete |
| Card content — question text | `questionText` panel (primary-tinted box) | questionText present | ✅ | Shows section/quiz content as the "content to recall." | ✅ Complete |
| Card content — question text | No questionText | questionText=null | ✅ | Panel hidden. Only concept name shown. User is asked to recall without a prompt. | ⚠️ Should Fix (cards without questionText give user no content to recall — just a concept name. User has nothing to assess themselves on.) |
| **"Remembered" / "Forgot" buttons** | Before `_showingAnswer` | | ✅ | Two large `AppButton`s. Primary (Remembered) and Destructive (Forgot). | ✅ Complete |
| Remembered / Forgot | Loading state (`_isSubmitting=true`) | | ✅ | Shows `BubbleLoader` + "Saving your answer..." text. Buttons hidden. | ✅ Complete |
| **Answer flow** | Self-assessment model | | ⚠️ | **The card shows ONLY the concept name before user answers.** There is no flip/reveal: user taps Remembered/Forgot without being shown what the answer is. The `questionText` IS shown upfront (it's the concept content), but there's no separate "answer" reveal step. This is a non-standard SRS UX — Anki shows front then flip to reveal back. Here the user is rating memory before seeing any confirmation of what's correct. Confusing for first-time users. | ⚠️ Should Fix |
| Answer flow | Feedback panel (after answering) | correct=true, correct=false | ✅ | "Great job!" (green) / "Keep practicing!" (red). Shows `+N XP`. | ✅ Complete |
| Feedback panel | **"Next Card" CTA** | not last card | ✅ | `_nextCard()` → advances `_currentCardIndex`, resets `_showingAnswer`. | ✅ Complete |
| Feedback panel | **"Complete Session" CTA** | last card | ✅ | Calls `_completeSession()`. | ✅ Complete |
| **Error inline message** | Record answer failure | network error | ✅ | Red inline error box shows "Couldn't save your answer. Your progress is still tracked." | ✅ Complete |
| Error inline | DanioSnackBar retry | | ✅ | `DanioSnackBar.error` with `onRetry`. | ✅ Complete |
| **Exit Session dialog** | "Exit Session?" | mid-session | ✅ | Shows cards reviewed / remaining counts. "Continue Session" (text) + "Exit" (destructive). | ✅ Complete |
| Exit dialog | "Continue Session" button | | ✅ | `Navigator.of(context).pop(false)` — stays in session. | ✅ Complete |
| Exit dialog | **"Exit" button** | | ✅ | `Navigator.of(context).pop(true)` → session pops back to SR practice screen. Progress saved. | ✅ Complete |
| **Session Completion dialog** | "Session Complete! 🎉" | | ✅ | `barrierDismissible: false`. Accuracy %, card counts, XP earned. | ✅ Complete |
| Session Completion | **"Done" CTA** | | ✅ | Two `Navigator.pop()` calls: dismisses dialog, pops session screen back to practice hub/learn. | ✅ Complete |
| Session Completion | Achievement check | | ✅ | `checkAfterReview()` called. Non-blocking (fire-and-forget). | ✅ Complete |
| Review Session | XP award on each card | | ✅ | `addXp(result.xpEarned)` called per card result. XP boost applied. | ✅ Complete |

---

## Area 6 — Story System

### 6a — Story Browser Screen

**File:** `lib/screens/story/story_browser_screen.dart`

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Story Browser | AppBar ("Interactive Stories") | | ✅ | Transparent AppBar, correct title. | ✅ Complete |
| Story Browser | Header copy ("Choose your adventure") | | ✅ | Subtext present. | ✅ Complete |
| Story Browser | **Story list** | allStories (6 stories) | ✅ | 6 stories: 3 beginner, 2 intermediate, 1 advanced. All rendered. | ✅ Complete |
| Story Browser | **No stories empty state** | allStories=[] | 🔴 | If `Stories.allStories` is empty, the list renders nothing with **no empty state message**. Low risk (stories are hardcoded), but fragile. | 🔍 Research First |
| Story Browser | **No error state** | profile load error | ⚠️ | `profileSlice` defaults to null on error — stories are treated as all locked (minLevel requirement fails). No error message. User sees all stories as locked with no explanation. | ⚠️ Should Fix |
| Story Browser — `_StoryCard` | **Unlocked story — tap** | isUnlocked=true | ✅ | `Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoryPlayScreen(story: story)))`. | ✅ Complete |
| _StoryCard | **Locked story — tap** | isUnlocked=false | ⚠️ | `onTap: null`. Tapping a locked story does **nothing** — no feedback, no snackbar, no explanation. The lock icon and "Complete prerequisites first" text are shown, but the whole card is silent on tap. | ⚠️ Should Fix |
| _StoryCard | Completed checkmark | isCompleted=true | ✅ | `Icons.check_circle` shown. | ✅ Complete |
| _StoryCard | Locked icon | isUnlocked=false | ✅ | `Icons.lock_outline` shown. 50% opacity. | ✅ Complete |
| _StoryCard | Difficulty badge (colour-coded) | beginner/intermediate/advanced | ✅ | Green / amber / red. | ✅ Complete |
| _StoryCard | Time + XP meta row | | ✅ | Schedule icon + XP star. | ✅ Complete |
| _StoryCard | "Complete prerequisites first" text | prerequisites.isNotEmpty | ✅ | Displayed in meta row when locked + has prereqs. | ✅ Complete |
| Story Browser | **Lock logic** | minLevel=0, prerequisites=[] | ✅ | Fallback when profile=null: story is unlocked only if minLevel=0 AND no prerequisites. | ✅ Complete |

### 6b — Story Play Screen

**File:** `lib/screens/story/story_play_screen.dart`

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Story Play — AppBar | Story title | | ✅ | | ✅ Complete |
| Story Play — AppBar | Difficulty badge (non-complete only) | _isComplete=false | ✅ | Shows `emoji displayName`. Hidden on completion screen. | ✅ Complete |
| Story Play — AppBar | Back button | mid-story | ✅ | `Leave story?` confirmation now protects unfinished story progress; cancel keeps the current scene and Leave returns to the story hub. | ✅ Complete |
| Story Play | **Progress indicator** | 0→1 | ✅ | `LinearProgressIndicator` at 4dp height. Progress based on `visitedSceneIds.length / scenes.length`. | ✅ Complete |
| Story Play — Scene | Scene text (GlassCard) | | ✅ | `bodyLarge` with lineHeight 1.6. Scrollable. | ✅ Complete |
| Story Play — Scene | "What do you do?" prompt | !_showingFeedback | ✅ | Shown above choices. | ✅ Complete |
| Story Play — Scene | **Choice tiles (`_ChoiceTile`)** | | ✅ | `GlassCard` with `onTap: () => _onChoiceTap(c)`. Arrow icon. | ✅ Complete |
| Story Play | Choice disabled after selection | _showingFeedback=true | ✅ | `if (!_showingFeedback)` guard. Choices hidden after selection. | ✅ Complete |
| Story Play — Feedback | **Feedback banner** | isCorrect=true, isCorrect=false | ✅ | Green "Great choice!" / Amber "Interesting choice..." with feedback text. | ✅ Complete |
| Story Play — Feedback | No feedback text | choice.feedback=null | ✅ | Label shown, no body text. Safe. | ✅ Complete |
| Story Play — Feedback | **"Continue" CTA** | _showingFeedback=true | ✅ | Calls `_onContinue()`. Advances scene or triggers completion. | ✅ Complete |
| Story Play | Scene with no choices | | 🔍 | If a scene has 0 choices and is not `isFinalScene`, user would be stuck with no Continue button and no choices. Not expected from current data, but no guard. | 🔍 Research First |
| **Story Completion screen** | Score-based headline (🏆/🎉/👍/📚) | score 90/70/50/0 | ✅ | Four tiers. | ✅ Complete |
| Story Completion | Score / XP / Choices stats card (GlassCard) | | ✅ | Three stat items. | ✅ Complete |
| Story Completion | **"Back to Stories" CTA** | | ✅ | `Navigator.of(context).pop()` — returns to `StoryBrowserScreen`. | ✅ Complete |
| **XP Award animation** | After `_handleCompletion` | | ✅ | `XpAwardOverlay.show()`. Non-blocking. | ✅ Complete |
| Story completion | Save to profile | | ✅ | `updateStoryProgress()` called with `isCompleted: true`. Story added to `completedStories`. | ✅ Complete |
| Story completion | **Double-award guard** | `_isAwarding=true` | ✅ | Guard prevents re-entry into `_handleCompletion`. | ✅ Complete |
| Story Play | `getSceneById` fallback | sceneId not found | ✅ | `?? widget.story.startScene` — falls back to start scene. Won't crash. | ✅ Complete |

---

## Area 7 — Learning Path Detail

**File:** `lib/screens/learn/lazy_learning_path_card.dart` (the path expansion is inline in the learn screen)

### Summary

Learning paths are displayed as `ExpansionTile`s within `LazyLearningPathCard`. The "path detail" is the expanded state of the card, not a separate screen. This was confirmed by code inspection.

---

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| **Path card — collapsed** | Emoji icon, title, description, progress bar, N/M badge | L | ✅ | All rendered correctly from `PathMetadata`. | ✅ Complete |
| Path card collapsed | Complete state (green glow box shadow) | all lessons done | ✅ | Green gradient on icon, green glow shadow. | ✅ Complete |
| Path card collapsed | Incomplete state (primary blue) | some done | ✅ | Blue gradient. | ✅ Complete |
| Path card collapsed | Zero progress (empty bar) | 0 completed | ✅ | Bar renders at 0 width. | ✅ Complete |
| **Path card — expansion** | Lazy load on first expand | loadedPath=null | ✅ | `ref.read(lessonProvider.notifier).loadPath(meta.id)` called once on expand. | ✅ Complete |
| Path card expansion | **BubbleLoader while loading** | isLoading=true | ✅ | `BubbleLoader.small()` shown. | ✅ Complete |
| Path card expansion | **Lesson list (unlocked)** | isUnlocked=true | ✅ | `PressableCard` → `NavigationThrottle.push(LessonScreen(...))`. | ✅ Complete |
| Path card expansion | Lesson completed | isCompleted=true | ✅ | ✅ icon + "+N XP" trailing label. Still tappable (replay allowed). | ✅ Complete |
| Path card expansion | **Lesson locked** | isUnlocked=false | ✅ | 🔒 icon. Tap → `DanioSnackBar.warning`. Not navigable. | ✅ Complete |
| Path card expansion | Time estimate + XP subtitle | | ✅ | "N min • N XP" on every lesson row. | ✅ Complete |
| Path card expansion | Hero animation | | ✅ | `Hero(tag: 'lesson-${lesson.id}')` on lesson icon. | ✅ Complete |
| **Locked path tile** (🔒 Locked) | Displayed when `isPathLocked=true` | | ✅ | Non-expandable `ListTile`. Lock icon. Prereq names in subtitle. | ✅ Complete |
| Locked path tile | **Tap** | | ✅ | `DanioSnackBar.warning` with prereq names. No navigation. | ✅ Complete |
| Locked path tile | Prereq name resolution | prereq ID not in allPathMetadata | ✅ | Falls back to `PathMetadata(id: id, title: id, emoji: '🔒', ...)`. Shows raw ID as name — minor UX rough edge. | ⚠️ Should Fix |
| **Coming Soon tile** | Displayed when `comingSoonPathIds` contains path ID | | ✅ | Non-expandable. Amber "Coming Soon 🚧" badge. | ✅ Complete |
| Coming Soon tile | **Tap** | | ✅ | `showAppDialog` with story about path being in development. "Got it!" dismisses. | ✅ Complete |
| Path card | **`comingSoonPathIds` is currently empty** | | ⚠️ | No paths are currently gated as coming soon. This constant was likely used historically. Either populate it or remove the code path to avoid dead code. | ⚠️ Should Fix |
| Path card | **Only one path has a prerequisite lock** (`fish_health` requires `nitrogen_cycle`) | | ✅ | Lock system functional. One real lock in production. | ✅ Complete |
| Path card expansion | Load error (path load fails) | network error mid-expand | ⚠️ | If `loadPath(meta.id)` throws/fails, `loadedPath` stays null and `isLoading` may return to false, leaving the expanded tile showing the BubbleLoader indefinitely, or reverting to showing the loader on re-expand. No error state rendered. | ⚠️ Should Fix |
| Path card | **No dedicated "path detail" screen** | | ⚠️ | The path is expanded inline in the learn screen. There is no fullscreen path view. Users cannot see the full lesson list without scrolling within a tiny expansion tile — especially an issue for paths with 13 lessons (Species Spotlights). | ⚠️ Should Fix |

---

## Cross-Cutting Issues

| Issue | Affected Areas | Classification |
|---|---|---|
| **Placement test CTA routes to wrong screen.** "Take the test" opens `SpacedRepetitionPracticeScreen` instead of a dedicated placement quiz. `hasCompletedPlacementTest` is never set, so the card reappears. | Learn Screen | 🔴 Must Fix |
| **Review Banner and Practice Card are visually distinct but functionally identical** — both route to `SpacedRepetitionPracticeScreen`. Shown simultaneously on Learn screen. Confusing to users. | Learn Screen | ⚠️ Should Fix |
| **`spacedRepetitionProvider.errorMessage` is never surfaced** on Practice Hub or SR Practice screens. SR load errors are silent beyond snackbars. | Practice Hub, SR Practice | 🔴 Must Fix |
| **Locked story cards (`onTap: null`) give no feedback on tap.** Users tap a locked story and nothing happens. Should show a snackbar explaining the lock. | Story Browser | ⚠️ Should Fix |
| **Story mid-play back button now asks before leaving unfinished progress.** Cancel keeps the current scene; Leave returns to the story hub. | Story Play | ✅ Complete |
| **Review session self-assessment UX.** User taps "Remembered/Forgot" without ever being asked to recall anything actively — just a label. Cards with no `questionText` are especially hollow. | Review Session | ⚠️ Should Fix |
| **`image` section type is a placeholder.** Renders "Visual guide on the way!" box. No image support. Fine now (no lessons use it), but must be implemented before image sections go live. | Lesson Screen | 🔮 Future Scope |
| **Path card expansion has no error state.** If `loadPath()` fails, the expansion shows a spinner indefinitely. | Learning Path Detail | ⚠️ Should Fix |
| **No dedicated full-screen path detail view.** Paths with 10+ lessons are squeezed into ExpansionTile. Especially poor for Species Spotlights (13 lessons). | Learning Path Detail | ⚠️ Should Fix |
| **`hasSeenTutorial` is watched but never rendered in LearnScreen.** Dead watch in the select tuple. | Learn Screen | ⚠️ Should Fix |
| **`_isHeartsModalVisible` / `_isExitingDueToHearts` flags are dead state** in `LessonScreen`. Set in `dispose()` but never set to `true` in active code. Orphaned from old hearts-block design. | Lesson Screen | ⚠️ Should Fix |
| **Reduce-motion path in LazyLearningPathCard renders the exact same widget both branches.** The non-animated path was never differentiated from the animated path. | Learn Screen | ⚠️ Should Fix |
| **`comingSoonPathIds` is an empty set.** Entire Coming Soon code path is dead. Either populate or remove. | Learning Path Detail | ⚠️ Should Fix |

---

## Summary Scorecard

| Area | Overall | Critical Issues | Should Fix |
|---|---|---|---|
| Learn Screen | ✅ Mostly complete | 1 (Placement test wrong dest.) | 5 |
| Lesson Screen | ✅ Mostly complete | 1 (image placeholder) | 3 |
| Practice Hub | ⚠️ Functional but fragile | 1 (error state silent) | 2 |
| SR Practice Screen | ✅ Mostly complete | 0 | 1 |
| Review Session | ⚠️ UX gap | 0 | 2 |
| Story Browser | ⚠️ UX gap | 0 | 2 |
| Story Play | ✅ Mostly complete | 0 | 1 |
| Learning Path Detail | ⚠️ UX gap | 0 | 4 |

**Total: 2 Must Fix · 20 Should Fix · 3 Research First · 3 Future Scope**

---

## Priority Action List

### 🔴 Must Fix (before launch)

1. **Placement test wrong destination** — `PlacementChallengeCard` "Take the test" → `SpacedRepetitionPracticeScreen`. Either build a real placement quiz or remove the card entirely. `hasCompletedPlacementTest` is never set to `true`, so the card is permanent.
2. **SR provider error state not surfaced** — Practice Hub and SR Practice screen never display `srState.errorMessage`. Add a visible error banner with retry.

### ⚠️ Should Fix (high priority)

3. **Locked story no feedback on tap** — add `DanioSnackBar.info` explaining what's needed to unlock.
4. **Story play exit confirmation** — complete; `PopScope` and the app-bar back button now ask before losing mid-story progress.
5. **Path expansion load error state** — if `loadPath()` fails, show an error row + retry, not a stuck spinner.
6. **Path detail as dedicated screen** — especially for paths with 10–13 lessons. Expansion tile is too cramped.
7. **Review session UX** — improve cards without `questionText` to show at least the lesson context, or consider a "flip" reveal model.
8. **Review Banner + Practice Card duplication** — differentiate purpose or merge into one card.

### ⚠️ Should Fix (lower priority / polish)

9. **Dead watch: `hasSeenTutorial`** in LearnScreen select tuple.
10. **Dead state: `_isHeartsModalVisible` / `_isExitingDueToHearts`** in LessonScreen.
11. **Reduce-motion branch in LazyLearningPathCard** renders identical widget both branches.
12. **`comingSoonPathIds` empty set** — dead code. Populate or remove.
13. **Generic hint in quiz** — hint chip shows the same text for every question. Should be question-specific or removed.
14. **Prereq name fallback shows raw ID** in locked path subtitle (if prereq ID not in metadata).

---

*Audit complete. Every screen, button, state, and modal has been checked against source code. Classifications reflect production-readiness judgement.*
