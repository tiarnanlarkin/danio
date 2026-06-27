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
| Learn Screen — Slow local profile load | Loading guard | Lo, Of | ✅ | After an extended profile-loading state, Learn swaps the skeleton for retryable local-first guidance instead of hanging indefinitely. Widget coverage verifies the stuck-loading state. | ✅ Complete |
| **PlacementChallengeCard** | Whole component | all users | ✅ | Returns `SizedBox.shrink()` while no real placement flow exists. No placeholder CTA is shown. | ✅ Complete |
| PlacementChallengeCard | **Placeholder actions** | "Take the test" / "Skip for now" | ✅ | Neither action is rendered, so the old wrong route to `SpacedRepetitionPracticeScreen` is no longer reachable. Widget coverage verifies these labels stay hidden. | ✅ Complete |
| PlacementChallengeCard | Future real placement flow | dedicated quiz not implemented | 🔮 | A richer placement quiz can still be built later, but there is no broken local CTA in the current app. | 🔮 Future Scope |
| PlacementChallengeCard | Hidden for beginners | experienceLevel=beginner | ✅ | The whole card is hidden for all users until a real placement flow exists. | ✅ Complete |
| **LearningStreakBadge** | Badge row (📚 N-day learning streak!) | L, streak=0, streak=1 | ✅ | Renders only when streak ≥ 2. Non-interactive (display only). No dead button. | ✅ Complete |
| **LearnReviewBanner** | Whole banner — only shown when `dueCards > 0` | L, dueCards=0 | ✅ | Hidden when due=0. | ✅ Complete |
| LearnReviewBanner | **Tap anywhere on banner** | dueCards > 0 | ✅ | Navigates to `SpacedRepetitionPracticeScreen`. Correct. | ✅ Complete |
| LearnReviewBanner | Semantics | | ✅ | `Semantics(button: true, label: '...')` present. Screen-reader friendly. | ✅ Complete |
| **LearnPracticeCard** | Whole card — only shown when `weakCount > 0` | L, weakCount=0 | ✅ | Hidden when no weak lessons. | ✅ Complete |
| LearnPracticeCard | **Tap anywhere on card** | weakCount > 0 | ✅ | Switches to the Practice hub tab, leaving the Review Banner as the direct due-review entry point. Widget coverage verifies it does not push review directly. | ✅ Complete |
| **LearnStreakCard** | Streak card (only shown when `currentStreak > 0`) | L, streak=0, hasFreeze | ✅ | Non-interactive. Correctly hidden at streak=0. Freeze state renders correctly. | ✅ Complete |
| **_StoriesSection (GlassCard)** | Tap → `StoryBrowserScreen` | L | ✅ | `Navigator.of(context).push(MaterialPageRoute(...))`. Correct, no throttle (low-risk). | ✅ Complete |
| Learn Screen — Cold-start nudge | "New to fishkeeping? Start with the basics below." | completedLessons=0 | ✅ | Display only row. Not tappable (no dead button). Disappears after first lesson. | ✅ Complete |
| Learn Screen — Learning Paths header | Progress bar + "N of M paths complete" | L | ✅ | Calculated from metadata, renders correctly. | ✅ Complete |
| **LazyLearningPathCard** | ExpansionTile (collapsed) | L | ✅ | Lazy-loads full path on expansion. Shows BubbleLoader while loading. | ✅ Complete |
| LazyLearningPathCard | "Start Here 👋" badge | index=0 and completedLessons=0 | ✅ | Display only. Correct condition. | ✅ Complete |
| LazyLearningPathCard | Locked path tile (🔒 Locked) | isPathLocked=true | ✅ | Non-expandable. `onTap` shows `DanioSnackBar.warning` with prereq names. | ✅ Complete |
| LazyLearningPathCard | Coming Soon tile | removed branch | ✅ | No coming-soon path gate remains in `LearnScreen`; all current metadata paths are available. Existing source guard coverage verifies `comingSoonPathIds` and placeholder "Coming Soon" copy stay out of the Learn source. | ✅ Complete |
| LazyLearningPathCard | Lesson row — unlocked | isUnlocked=true | ✅ | `NavigationThrottle.push(LessonScreen(...))`. Hero animation on lesson icon. | ✅ Complete |
| LazyLearningPathCard | Lesson row — locked | isUnlocked=false | ✅ | `DanioSnackBar.warning` with "Complete the previous lesson to unlock this one 🔒". No navigation. | ✅ Complete |
| LazyLearningPathCard | Lesson row — completed | isCompleted=true | ✅ | Shows ✅ icon + "+N XP" label. Still tappable (allows replay). | ✅ Complete |
| LazyLearningPathCard | Path expand — loading state | isLoading=true | ✅ | Shows `BubbleLoader.small()` while path loads. | ✅ Complete |
| LazyLearningPathCard | Empty lesson list | path with 0 lessons | ✅ | Loaded paths with no lessons now show an explicit "No lessons in this path yet" empty state instead of only a divider. Widget coverage verifies the fallback and keeps the full-path CTA hidden. | ✅ Complete |
| Learn Screen | **hasSeenTutorial** field in profile | | ✅ | Current `profileState` select no longer watches `hasSeenTutorial`; the stale dead-watch finding is closed. | ✅ Complete |
| Learn Screen | Animate: reduced motion | disableAnimations=true | ✅ | Reduced motion renders the plain `LazyLearningPathCard`; normal motion applies fade/slide animation. The branches are now intentionally differentiated. | ✅ Complete |

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
| LessonCardWidget | **Section type: `image`** | asset, caption, missing asset | ✅ | Renders real asset/network images in a stable 16:9 frame with caption support and a "Visual unavailable" fallback. Widget coverage verifies asset rendering and rejects stale "Visual guide on the way!" copy. | ✅ Complete |
| LessonCardWidget | Bottom CTA: **"Take Quiz"** (lesson has quiz) | | ✅ | Sets `_showQuiz = true`. Transitions to `LessonQuizWidget`. | ✅ Complete |
| LessonCardWidget | Bottom CTA: **"Complete Lesson"** (no quiz) | | ✅ | Calls `_completeLesson()` directly. No quiz flow. | ✅ Complete |
| LessonCardWidget | CTA disabled state | `isCompletingLesson=true` | ✅ | Button shows loading indicator. Prevents double-tap. | ✅ Complete |
| LessonCardWidget | Hero animation on lesson icon | | ✅ | `Hero(tag: 'lesson-${lesson.id}')` matches the path card icon. | ✅ Complete |
| **LessonQuizWidget — Quiz null** | Empty quiz state | quiz=null | ✅ | Shows "Quiz coming soon!" with outline icon. Safe. | ✅ Complete |
| LessonQuizWidget | Progress bar | 1 to N questions | ✅ | `LinearProgressIndicator` with correct fraction. Semantic label provided. | ✅ Complete |
| LessonQuizWidget | Question counter "N of M correct" | | ✅ | Updates after each answer. | ✅ Complete |
| LessonQuizWidget | **Hint button** (beginners only) | isBeginner=true, answered=false | ✅ | `ActionChip` "Need a hint?" renders only for beginners before answering. | ✅ Complete |
| LessonQuizWidget | **Hint text panel** | showHint=true | ✅ | Hint copy is now derived from the current question's explanation when available, with the correct option scrubbed from the clue. Widget coverage verifies the old generic "Look for keywords" copy is gone. | ✅ Complete |
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
| LessonScreen | **`isExitingDueToHearts` / `_isHeartsModalVisible` flags** | | ✅ | These old hearts-block flags are no longer present in `LessonScreen`; the stale dead-state finding is closed. | ✅ Complete |

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
| Practice Hub | **Error state from `spacedRepetitionProvider`** | errorMessage set | ✅ | Displays a visible error banner with the provider message and a Retry action while preserving the rest of the hub context. Widget coverage verifies the banner appears. | ✅ Complete |
| Practice Hub | **Profile error handling** | userProfileProvider error | ✅ | Shows a non-blocking retry banner while keeping Practice usable. Header energy indicator now reads `valueOrNull` so profile errors do not crash the screen. Widget coverage verifies the banner and existing hub content remain visible. | ✅ Complete |
| Practice Hub | Item count constant | | ✅ | Populated Practice Hub content is now assembled as an explicit widget list, with source-guard coverage rejecting the old `_getPracticeHubItemCount` / `return 23` magic-count pattern. | ✅ Complete |

---

## Area 4 — Spaced Repetition Practice Screen

**Files:**
- `lib/screens/spaced_repetition_practice/spaced_repetition_practice_screen.dart`
- `lib/screens/spaced_repetition_practice_screen.dart` (re-export shim)

### Summary

Launched from: Learn review banner, Practice Hub hero card, Practice Hub "Spaced Repetition" mode card, and Learn practice card. Handles loading state, empty state (no due cards), provider error state, and the practice home (mode selection). Launches `ReviewSessionScreen` when a session is active.

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
| SR Practice | `errorMessage` from provider | provider error | ✅ | Displays a persistent provider error message with a Try again action instead of the empty/caught-up state. Widget coverage verifies the error surface. | ✅ Complete |

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
| Card content — question text | No questionText | questionText=null | ✅ | Shows a fallback recall prompt for the concept and tells unsure users to choose Forgot so the card returns sooner. Widget coverage verifies the legacy-card path. | ✅ Complete |
| **"Remembered" / "Forgot" buttons** | Before `_showingAnswer` | | ✅ | Two large `AppButton`s. Primary (Remembered) and Destructive (Forgot). | ✅ Complete |
| Remembered / Forgot | Loading state (`_isSubmitting=true`) | | ✅ | Shows `BubbleLoader` + "Saving your answer..." text. Buttons hidden. | ✅ Complete |
| **Answer flow** | Fallback self-assessment model | | ✅ | Fallback cards now show a recall prompt first, hide Forgot/Remembered until the user taps "Reveal answer", then show the saved answer/content and self-rating buttons. Widget coverage verifies reveal, answer visibility, and reset on the next card. | ✅ Complete |
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
| Story Browser | Empty story catalog | allStories=[] | ✅ | Shows a "No stories available yet" empty state instead of a blank list. Widget coverage verifies the empty catalog fallback through an injectable story list seam. | ✅ Complete |
| Story Browser | Profile error handling | profile load error | ✅ | Shows a non-blocking retry banner while keeping available starter stories visible; locked-state decisions use profile data only when available. Widget coverage verifies banner and story hub copy. | ✅ Complete |
| Story Browser — `_StoryCard` | **Unlocked story — tap** | isUnlocked=true | ✅ | `Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoryPlayScreen(story: story)))`. | ✅ Complete |
| _StoryCard | **Locked story — tap** | isUnlocked=false | ✅ | Card stays locked but now shows `DanioSnackBar.info` with the missing level or prerequisite requirement. No Story Play navigation occurs while locked. | ✅ Complete |
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
| Story Play | Scene with no choices | malformed content | ✅ | Non-final scenes with no choices now show a "Story step unavailable" fallback with a safe Back to Stories action instead of trapping the user. Widget coverage verifies the fallback and return path. | ✅ Complete |
| **Story Completion screen** | Score-based headline (🏆/🎉/👍/📚) | score 90/70/50/0 | ✅ | Four tiers. | ✅ Complete |
| Story Completion | Score / XP / Choices stats card (GlassCard) | | ✅ | Three stat items. | ✅ Complete |
| Story Completion | **"Back to Stories" CTA** | | ✅ | `Navigator.of(context).pop()` — returns to `StoryBrowserScreen`. | ✅ Complete |
| **XP Award animation** | After `_handleCompletion` | | ✅ | `XpAwardOverlay.show()`. Non-blocking. | ✅ Complete |
| Story completion | Save to profile | | ✅ | `updateStoryProgress()` called with `isCompleted: true`. Story added to `completedStories`. | ✅ Complete |
| Story completion | **Double-award guard** | `_isAwarding=true` | ✅ | Guard prevents re-entry into `_handleCompletion`. | ✅ Complete |
| Story Play | `getSceneById` fallback | sceneId not found | ✅ | `?? widget.story.startScene` — falls back to start scene. Won't crash. | ✅ Complete |

---

## Area 7 — Learning Path Detail

**Files:** `lib/screens/learn/lazy_learning_path_card.dart`, `lib/screens/learn/learning_path_detail_screen.dart`

### Summary

Learning paths are previewed inside `LazyLearningPathCard` and can now open a dedicated full-screen path detail view with path overview, progress, and the complete lesson sequence.

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
| Locked path tile | Prereq name resolution | raw ID-style title | ✅ | Raw ID-style prerequisite titles are formatted into readable names before rendering, and the locked tile has its own transparent `Material` for correct ink/debug behavior inside the decorated card. | ✅ Complete |
| **Coming Soon tile** | Removed branch | | ✅ | No coming-soon path branch remains in the Learn source; all current metadata paths are shown as available or locked by real prerequisites. | ✅ Complete |
| Coming Soon tile | **Tap** | removed branch | ✅ | No placeholder coming-soon dialog branch remains for learning paths. | ✅ Complete |
| Path card | **`comingSoonPathIds` is currently empty** | | ✅ | Stale audit row: source guard coverage already verifies `comingSoonPathIds` is absent from `learn_screen.dart`. | ✅ Complete |
| Path card | **Only one path has a prerequisite lock** (`fish_health` requires `nitrogen_cycle`) | | ✅ | Lock system functional. One real lock in production. | ✅ Complete |
| Path card expansion | Load error (path load fails) | network error mid-expand | ✅ | Renders a retryable error row with "Couldn't load this path", supporting copy, and a Try again action. Widget coverage verifies no loader remains stuck. | ✅ Complete |
| Path card | **Dedicated path detail screen** | | ✅ | Expanded path cards expose `Open full path`; the inline list is now a short preview and the full-screen view shows overview, progress, and the complete lesson sequence. | ✅ Complete |

---

## Cross-Cutting Issues

| Issue | Affected Areas | Classification |
|---|---|---|
| **Placement test placeholder CTA is hidden until a real flow exists.** The old wrong route to `SpacedRepetitionPracticeScreen` is not reachable. | Learn Screen | ✅ Complete |
| **Review Banner and Practice Card now have distinct roles.** Review Banner starts due review; Practice Card opens the Practice hub for weak-spot options. | Learn Screen | ✅ Complete |
| **`spacedRepetitionProvider.errorMessage` is surfaced** on Practice Hub and SR Practice screens with retry affordances. | Practice Hub, SR Practice | ✅ Complete |
| **Locked story cards now explain unlock requirements on tap.** Locked cards remain non-navigable but no longer behave like dead controls. | Story Browser | ✅ Complete |
| **Story mid-play back button now asks before leaving unfinished progress.** Cancel keeps the current scene; Leave returns to the story hub. | Story Play | ✅ Complete |
| **Review session fallback self-assessment now has a reveal step.** Users no longer rate fallback cards before revealing the saved content. | Review Session | ✅ Complete |
| **`image` section type renders real lesson visuals.** The stale placeholder branch is gone; image sections now support assets/network images, captions, and fallback UI. | Lesson Screen | ✅ Complete |
| **Path card expansion shows a retryable error state.** Failed `loadPath()` calls no longer leave users with a stuck spinner. | Learning Path Detail | ✅ Complete |
| **Dedicated full-screen path detail view exists.** Paths with 10+ lessons can be opened from the inline preview into the complete sequence view. | Learning Path Detail | ✅ Complete |
| **`hasSeenTutorial` is no longer watched by LearnScreen.** The stale dead-watch audit row is closed. | Learn Screen | ✅ Complete |
| **`_isHeartsModalVisible` / `_isExitingDueToHearts` flags are no longer present** in `LessonScreen`. The stale dead-state audit row is closed. | Lesson Screen | ✅ Complete |
| **Reduced-motion path in LazyLearningPathCard is differentiated.** Reduced motion uses the plain card; normal motion applies fade/slide animation. | Learn Screen | ✅ Complete |
| **`comingSoonPathIds` branch is absent.** The stale empty-set dead-code row is closed by existing Learn source guard coverage. | Learning Path Detail | ✅ Complete |

---

## Summary Scorecard

| Area | Overall | Critical Issues | Should Fix |
|---|---|---|---|
| Learn Screen | ✅ Mostly complete | 0 | 0 |
| Lesson Screen | ✅ Mostly complete | 0 | 0 |
| Practice Hub | ✅ Mostly complete | 0 | 0 |
| SR Practice Screen | ✅ Mostly complete | 0 | 0 |
| Review Session | ✅ Mostly complete | 0 | 0 |
| Story Browser | ✅ Mostly complete | 0 | 0 |
| Story Play | ✅ Mostly complete | 0 | 0 |
| Learning Path Detail | ✅ Mostly complete | 0 | 0 |

**Total: 0 Must Fix · 0 Should Fix · 0 Research First · 1 Future Scope**

---

## Priority Action List

### 🔴 Must Fix (before launch)

None currently listed in this surface audit.

### ⚠️ Should Fix (high priority)

None currently listed in this surface audit.

### ⚠️ Should Fix (lower priority / polish)

None currently listed in this surface audit.

---

*Audit complete. Every screen, button, state, and modal has been checked against source code. Classifications reflect production-readiness judgement.*
