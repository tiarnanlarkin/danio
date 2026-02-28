# Danio UI Perfection Audit — Learn + Quiz + Tank Tabs

**Date:** 2026-02-28  
**Auditor:** Athena (Senior UI/UX Review)  
**Scope:** Learn Screen, Quiz/Practice Hub, Tank/Home Tab, Design System  
**Overall Score: 7.2/10** — Solid foundation with good gamification bones, but inconsistencies and missed opportunities hold it back from top-tier.

---

## Executive Summary

The app has genuinely impressive depth of features — spaced repetition, hearts system, streak tracking, XP animations, level-ups, stories — all the Duolingo-inspired mechanics are present. The design system (`app_theme.dart`) is uncommonly thorough with pre-computed alpha colors, WCAG-compliant semantic colours, and consistent token usage. However, the execution across screens is uneven: some screens feel polished (Learn Screen, Story Player), while others feel like rushed scaffolding (Practice Hub, Practice Screen). The biggest gap is **visual delight** — the mechanics are there but the UI doesn't make them *feel* exciting.

### Key Themes
1. **Inconsistent card styling** — Mix of raw `Container`, `Card`, `InkWell`, `AppCard`, and `CozyCard` across screens
2. **Missing micro-animations** — Gamified apps live or die by feedback animations; many interactions feel flat
3. **Dark mode blindspots** — `StoriesScreen` uses hardcoded `Colors.white` backgrounds on cards
4. **Information density varies wildly** — Some screens are sparse, others overwhelming
5. **The "Duolingo gap"** — Mechanics are Duolingo-inspired but the *visual energy* isn't there yet

---

## Tab 1: Learn Screen

### Learn Screen (Main Hub)
**File:** `lib/screens/learn_screen.dart`  
**Current state:** Well-structured learning hub with a Study Room scene header, streak/review banners, and lazy-loading learning path cards. The architecture is solid but the visual presentation is workmanlike rather than inspiring.  
**Score:** 7.5/10

**Issues:**
1. **Line 200-210** — `_ReviewCardsBanner` uses raw `Container` + `InkWell` instead of `AppCard` — breaks design system consistency. The gradient + boxShadow combo is manually constructed rather than using the design system's `AppCardVariant.gradient`.
2. **Line 280-340** — `_PracticeCard` is nearly identical to `_ReviewCardsBanner` (same layout, different gradient). This is copy-paste UI — should be a shared widget.
3. **Line 342-400** — `_StreakCard` uses hardcoded `Colors.orange.shade700` and `Colors.orange.shade600` instead of semantic colours from `AppColors`. This will look wrong in dark mode.
4. **Line 128-135** — "Learning Paths" section header is a plain `Text` widget. No visual separation from content above. Duolingo uses subtle dividers or spacing shifts to create visual rhythm.
5. **Line 170** — `SizedBox(height: 160)` at bottom is magic number padding. Should use `AppSpacing` tokens or calculate based on bottom nav height.
6. **Line 108-120** — Profile null state (no profile) is functional but bland. The "Create Profile" CTA uses a generic `ElevatedButton` instead of `AppButton`, missing the design system's haptic feedback and scale animation.

**Enhancements:**
1. **Add a visual learning path map** — Instead of a flat list of ExpansionTiles, render a connected vertical path (like Duolingo's bubble trail). Each node shows progress state with connecting lines. This is the single biggest thing that would differentiate the Learn screen from "boring list." — **High effort** (custom widget, ~2-3 days)
2. **Animate the Study Room scene** — The scene is static. Add subtle idle animations (book pages turning, microscope lens glinting, globe spinning) to make it feel alive. — **Medium effort** (~1 day with flutter_animate)
3. **Add daily challenge card** — Between the streak banner and learning paths, add a rotating daily challenge ("Today's challenge: Complete 3 lessons" with a progress ring). Duolingo's power is in creating *urgency*. — **Medium effort** (~0.5 day)
4. **Consolidate banner widgets** — Extract `_ReviewCardsBanner` and `_PracticeCard` into a shared `GradientActionBanner` widget that takes title, subtitle, icon, gradient, and onTap. — **Low effort** (~1 hour)

### Lesson Screen
**File:** `lib/screens/lesson_screen.dart`  
**Current state:** Solid reading experience with well-differentiated section types (key points, tips, warnings, fun facts). The quiz flow is functional with proper answer validation and heart mechanics. Good use of Hero animations for lesson icons.  
**Score:** 7/10

**Issues:**
1. **Line 93-100** — AppBar title uses `FittedBox` which can make text illegibly small on long path titles. Should truncate with ellipsis instead.
2. **Line 225-270** — Quiz question options use raw `InkWell` + `Container` instead of the design system's card components. Visually inconsistent with rest of app.
3. **Line 310-340** — Quiz results screen emoji container (🎉 / 📚) is a static circle. No animation on reveal — this should be the most celebratory moment. Duolingo uses confetti, particle effects, and bouncing animations here.
4. **Line 155-170** — Section builders for `bulletList` and `numberedList` are identical implementations. No visual distinction between bullet and numbered lists (both render as plain text paragraphs).
5. **Line 180-190** — `LessonSectionType.image` is a placeholder (`Container` with grey background and camera icon). If images aren't supported yet, this should be hidden entirely rather than showing a broken-looking placeholder.
6. **Line 340** — XP card on results uses `AppColors.primaryGradient` but the gradient definition in theme uses lighter teal tones — the XP reward should feel *golden* and celebratory, not teal.
7. **Line 405-480** — `_completeLesson()` method is 75+ lines of mixed concerns (XP, spaced repetition seeding, activity recording, notifications, achievements). Works but is a maintenance burden. Not a UI issue per se, but affects perceived responsiveness if any of those async operations are slow.

**Enhancements:**
1. **Add reading progress indicator** — A thin progress bar at the top showing how far through the lesson content the user has scrolled. Creates a sense of momentum. — **Low effort** (~2 hours)
2. **Animate quiz transitions** — When moving between questions, slide the old question out and new one in. Currently it's an abrupt state change. — **Low effort** (~1 hour with flutter_animate)
3. **Add confetti to quiz results** — The app already has `widgets/celebrations/confetti_overlay.dart`. USE IT on the quiz results screen when the user passes. — **Very low effort** (~30 min)
4. **Visual bullet/numbered lists** — Add actual bullet dots (•) and numbering (1. 2. 3.) to the respective list types. Currently both are just `\n`-split plain text. — **Low effort** (~1 hour)

### Stories Screen
**File:** `lib/screens/stories_screen.dart`  
**Current state:** Functional story browser with filtering and sorting. Clean layout with good metadata chips (difficulty, duration, XP). However, it has the most egregious dark mode violations in the codebase.  
**Score:** 5.5/10

**Issues:**
1. **Line 198** — `StoryCard` uses hardcoded `color: Colors.white` for Material background. This will look jarring in dark mode — a white card on a dark background. Must use `AppColors.surface` or theme-aware colour.
2. **Line 207-212** — Border uses `Colors.grey.shade200` — another hardcoded light-mode colour. Should use `AppColors.border` / `AppColors.borderDark`.
3. **Line 234-235** — Description text uses `Colors.grey.shade700` instead of `AppColors.textSecondary`.
4. **Line 270-285** — "Start"/"Resume"/"Replay" text uses `Colors.blue` (5 occurrences). Should use `AppColors.primary` or `AppColors.info`.
5. **Line 295** — Lock reason text uses `Colors.grey.shade600`. Again, not theme-aware.
6. **Line 50-70** — `SliverAppBar` header with gradient — the gradient uses `Colors.purple.shade700`, `Colors.blue.shade600`, `Colors.cyan.shade500`. These are Material defaults, not the app's palette. Should use the app's `AppColors` gradients.
7. **Line 305-325** — `_buildInfoChip` method uses `color.withAlpha(26)` and `color.withAlpha(76)` for chip styling. This is fine functionally but bypasses the design system's pre-computed alpha colours, causing unnecessary object allocations (the exact thing the comment in `app_theme.dart` warns against).

**Enhancements:**
1. **Fix all dark mode colours** — Replace every `Colors.white`, `Colors.grey.shade*`, and `Colors.blue` with theme-aware equivalents. This is not optional — it's a bug. — **Low effort** (~1 hour)
2. **Add story cover illustrations** — The thumbnail area currently shows a single emoji at 40px. Replace with an illustrated scene or at least a gradient background with the emoji, similar to Duolingo's story cards which use charming illustrations. — **Medium effort** (~1 day for illustrations)
3. **Add completion percentage badge** — For in-progress stories, show a small circular progress indicator overlaid on the thumbnail. — **Low effort** (~1 hour)

### Story Player Screen
**File:** `lib/screens/story_player_screen.dart`  
**Current state:** The most visually polished screen in the Learn tab. Full-screen immersive experience with gradient backgrounds, animated text, slide-up choices, and feedback overlays. Good use of `TickerProviderStateMixin` for animations. Feels genuinely engaging.  
**Score:** 8/10

**Issues:**
1. **Line 240-260** — Story text card uses hardcoded `Colors.white` for background and `Colors.black87` for text. Won't adapt to dark mode (though the full-screen blue gradient arguably makes this less critical).
2. **Line 285-300** — `_ChoiceButton` uses hardcoded `Colors.white`, `Colors.black87`, `Colors.blue.shade200`, `Colors.blue.shade700`. Should use theme tokens.
3. **Line 175-185** — `BubblePainter` draws static bubbles. They don't animate. For an aquarium app, animated rising bubbles would be a signature touch. The app already has `widgets/ambient/ambient_bubbles.dart` — use it!
4. **Line 145** — Feedback overlay uses `AppOverlays.green90` / `AppOverlays.orange90` — these are 90% opacity which is extremely opaque and covers the entire screen. Consider a more nuanced overlay (semi-transparent with blur) so context isn't completely lost.
5. **Line 130** — Completion dialog is a standard `AlertDialog`. For the climactic moment of finishing a story, this feels anti-climactic. Should be a custom full-screen celebration.

**Enhancements:**
1. **Use animated bubbles** — Replace `BubblePainter` with the existing `AmbientBubbles` widget for animated background. — **Very low effort** (~30 min)
2. **Full-screen story completion** — Replace `AlertDialog` with a custom results screen (like the quiz results screen) showing score, XP earned, and a celebration animation. — **Medium effort** (~0.5 day)
3. **Add character avatars** — For dialogue-style stories, show character avatars in chat-bubble style. This would make stories feel more interactive and personal. — **High effort** (~2 days)

---

## Tab 2: Quiz / Practice Hub

### Practice Hub Screen
**File:** `lib/screens/practice_hub_screen.dart`  
**Current state:** Functional but feels like a settings menu, not an engaging practice hub. The hero card, stats row, and practice mode cards are all correctly structured but lack visual energy. The hardcoded `itemCount: 19` approach with a giant switch statement is fragile and hard to maintain.  
**Score:** 5/10

**Issues:**
1. **Line 67** — `_getPracticeHubItemCount` returns hardcoded `19`. Any layout change requires manually updating this count. Fragile pattern. Should use a dynamic list builder.
2. **Line 130-140** — Hero card icon container uses `padding: const EdgeInsets.fromLTRB(16, 16, 16, 100)`. The `100` bottom padding is clearly a bug — it pushes the icon way down and creates a massive empty space. This should be `EdgeInsets.all(16)`.
3. **Line 155-165** — Stats row cards also use `padding: const EdgeInsets.fromLTRB(16, 16, 16, 100)` — same bug. The cards will be absurdly tall.
4. **Line 218-225** — `_calculateAccuracy` returns a hardcoded `85` as a placeholder. This is shipping a lie to the user. Either calculate the real value or don't show the stat.
5. **Line 88-105** — The hero card uses a basic `Card` widget instead of `AppCard`, losing the design system's shadow, press animation, and haptic feedback.
6. **Line 175-190** — Practice mode cards use simple `ListTile` inside `Card`. Functional but visually flat compared to the rest of the app. These should be the most inviting elements — they're what the user is supposed to tap.

**Enhancements:**
1. **Fix the padding bug** — Change `EdgeInsets.fromLTRB(16, 16, 16, 100)` to `EdgeInsets.all(16)` in hero card and stats row. This is a **P0 bug**. — **5 minutes**
2. **Replace hardcoded item count** — Convert to a proper list model or use `ListView` with widgets directly. — **Low effort** (~1 hour)
3. **Calculate real accuracy** — Wire up actual accuracy tracking from the spaced repetition state. — **Low effort** (~30 min)
4. **Add visual variety to practice mode cards** — Use gradient cards or illustrated cards with icons instead of plain ListTiles. Each mode should feel distinct and enticing. — **Medium effort** (~0.5 day)
5. **Add a "streak on fire" animation** — When streak > 7 days, show the fire emoji animating (flickering). Small touch, big dopamine hit. — **Low effort** (~1 hour)

### Enhanced Quiz Screen
**File:** `lib/screens/enhanced_quiz_screen.dart`  
**Current state:** The most feature-rich quiz implementation. Supports multiple exercise types (multiple choice, fill-in-blank, true/false, matching, ordering) with type badges, animated progress, explanation cards, and heart mechanics. The results screen has good animated elements (elastic emoji, animated circular progress). Genuinely well-built.  
**Score:** 8/10

**Issues:**
1. **Line 142** — Progress header uses `AnimatedBuilder` but the `LinearProgressIndicator` uses the raw `progress` variable, not `_progressAnimation.value`, so the animation isn't actually applied. The progress bar jumps instead of animating smoothly.
2. **Line 80** — `color.withOpacity(0.1)` and `color.withOpacity(0.3)` in `_buildExerciseTypeBadge`. Should use `withAlpha()` for consistency (the entire theme file warns about this).
3. **Line 260-275** — Results screen XP calculation has a potential double-counting bug: `totalXp = widget.quiz.bonusXp + bonusXp` where `bonusXp` is already derived from `widget.quiz.bonusXp`. If `passed == true`, this doubles the bonus XP display.
4. **Line 170-180** — Explanation card uses `ScaleTransition` with `Curves.elasticOut` which can look jittery on low-end devices. Consider `Curves.easeOutBack` for smoother feel.

**Enhancements:**
1. **Fix progress bar animation** — Use `_progressAnimation.value` instead of the raw `progress` variable so the progress bar animates smoothly between questions. — **Very low effort** (~15 min)
2. **Add sound effects** — Correct/incorrect answer sounds. The gamification is purely visual right now. Even simple haptic patterns would help. — **Low effort** (~1 hour)
3. **Add streak counter within quiz** — "3 correct in a row! 🔥" as a temporary badge when user gets consecutive answers right. Duolingo does this and it's incredibly motivating. — **Medium effort** (~0.5 day)

### Spaced Repetition Practice Screen
**File:** `lib/screens/spaced_repetition_practice_screen.dart`  
**Current state:** Two screens in one file: the session launcher and the active review session. The launcher has a good stats overview with gradient card and mastery breakdown. The review session is functional but feels clinical — more like a flashcard app than a gamified experience.  
**Score:** 6.5/10

**Issues:**
1. **Line 310-330** — Review session answer buttons ("Forgot" / "Remembered") are binary. Modern spaced repetition UIs (Anki, Memrise) offer 3-4 difficulty levels (Easy, Good, Hard, Again). Binary choice loses nuance about memory strength.
2. **Line 280-295** — The question card shows `_getQuestionText()` which falls back to formatting the concept ID as readable text (line 370: `conceptId.replaceAll("_", " ").trim()`). This can produce nonsensical text if the ID format doesn't match expectations.
3. **Line 125-130** — Mode cards use `AppColors.whiteAlpha50` when disabled, but this is a pure white overlay — in light mode it's invisible. Should use `AppColors.surfaceVariant` for disabled state.
4. **Line 400-440** — Session completion dialog is a standard `AlertDialog`. After completing a practice session, the user deserves more celebration than a dialog box.
5. **Line 345** — Feedback card shows "+X XP" but the XP award feels buried. There's no animation when XP is earned within the session.

**Enhancements:**
1. **Add difficulty rating buttons** — Replace binary "Forgot/Remembered" with "Again / Hard / Good / Easy" for more granular spaced repetition scheduling. — **Medium effort** (~0.5 day, requires model changes)
2. **Animate card transitions** — When moving to the next card, use a swipe or flip animation instead of a state swap. — **Low effort** (~1 hour)
3. **Show XP animation on each correct answer** — Use the existing `XpAwardOverlay` for inline XP feedback. — **Low effort** (~30 min)
4. **Replace completion AlertDialog** — Use a full-screen results view similar to `EnhancedQuizScreen._buildResults()`. — **Medium effort** (~0.5 day)

### Practice Screen (Weak Lessons)
**File:** `lib/screens/practice_screen.dart`  
**Current state:** Straightforward list of lessons needing review with strength indicators. Functional but uninspiring. The strength bar is the most useful UI element. Contains a dead `PracticeLessonScreen` class with an incomplete quiz implementation.  
**Score:** 5.5/10

**Issues:**
1. **Line 280-360** — `PracticeLessonScreen` has `_buildQuiz()` that returns `Center(child: Text('Quiz implementation (same as original LessonScreen)'))`. This is dead code shipping a broken screen. If this class isn't used, remove it. If it is, implement it.
2. **Line 100-110** — Practice list header and info card use raw `Container` with gradient/border instead of `AppCard`. Inconsistent with design system.
3. **Line 160-165** — Lesson cards use `InkWell` + `Container` instead of `AppCard`. No press animation or haptic feedback.
4. **Line 195-200** — Strength indicator text ("Strength: 45%") uses manual colour switching with if/else. Should use a utility function or the design system's semantic colours more cleanly.

**Enhancements:**
1. **Remove or fix `PracticeLessonScreen`** — This is dead weight in the codebase. If practice mode should use a different lesson UI, implement it properly. Otherwise, delete it. — **Very low effort** (~10 min)
2. **Add urgency indicators** — For lessons with strength < 30%, add a pulsing red indicator or "Critical!" badge to create urgency. — **Low effort** (~30 min)
3. **Group by strength level** — Instead of a flat list, group into "Critical (< 30%)", "Weakening (30-70%)", "Fading (70-90%)" sections with visual headers. — **Medium effort** (~2 hours)

---

## Tab 3: Tank / Home

### Home Screen (Living Room)
**File:** `lib/screens/home/home_screen.dart`  
**Current state:** The most complex screen in the app. Full room scene with interactive objects, tank switcher, speed dial FAB, compact stats bar, daily goal progress, room theme picker, and multiple bottom sheets. Architecturally ambitious with a "cozy room" metaphor. Impressive but dense.  
**Score:** 7.5/10

**Issues:**
1. **Line 155-185** — Stats bar uses emoji-based display (🔥, ⭐, 💎, ❤️) which is visually charming but may render inconsistently across devices/OS versions. Consider icon fallbacks.
2. **Line 200-250** — The room scene is the app's centrepiece but it's a `Positioned.fill` inside a `Stack` inside an `Expanded` — no ability for the user to scroll or interact with content below the scene without specific widgets. This creates a "trapped" feeling on small screens.
3. **Line 270-310** — Daily goal card uses nested `profileAsync.when` which means it re-renders on every profile change. Could be extracted to its own `ConsumerWidget` for performance.
4. **Line 340-380** — Tank switcher height is hardcoded at `72` pixels. On smaller devices, this plus the room scene and stats bar may not leave enough space.
5. **Line 440-490** — Room switcher bottom sheet uses a `ListTile` per room. The room names are hardcoded strings in a tuple list. Should come from a model/enum.
6. **Line 495-560** — Multiple `_showXxxInfo` methods show bottom sheets with hardcoded placeholder data (`'-- °C'`, `'-- ppm'`). These should show real data from the tank or be hidden if no data exists.

**Enhancements:**
1. **Replace placeholder data with real values** — The water params sheet showing "--" everywhere looks broken, not empty. Either show real last-known values or don't show the sheet at all until data exists. — **Medium effort** (~0.5 day)
2. **Add tank health summary** — Show a simple health score or traffic light indicator (🟢🟡🔴) on the tank card/switcher so users can see status at a glance without tapping into details. — **Medium effort** (~0.5 day)
3. **Responsive room layout** — On phones < 375px width, the room scene + stats bar + daily goal + tank switcher won't all fit. Add scroll capability or collapse elements. — **Medium effort** (~1 day)

### Tank Detail Screen
**File:** `lib/screens/tank_detail/tank_detail_screen.dart`  
**Current state:** Comprehensive dashboard with SliverAppBar, quick stats, action buttons, snapshot card, trends, alerts, cycling status, tasks, logs, livestock, equipment, and stocking indicator. Well-structured with extracted sub-widgets. Excellent skeleton loading states.  
**Score:** 8/10

**Issues:**
1. **Line 350-360** — SliverAppBar has 5 action icons (checklist, gallery, journal, charts, more). This is too many for a phone screen — they'll be tiny and hard to tap. Material Design recommends 2-3 actions max; put the rest in the overflow menu.
2. **Line 340** — AppBar gradient uses `AppColors.primary` to `AppColors.secondary` which is teal-to-amber. This is a strong colour shift that may not look refined. Consider a single-colour gradient with tonal variation.
3. **Line 360** — "More" popup menu items include "Delete Tank" with a red icon. Destructive actions should require confirmation AND be harder to accidentally access. Consider separating it further from other menu items.
4. **Line 90-130** — Skeleton builders are well-implemented but static. No shimmer animation since `Skeletonizer` is used (which handles this), but the skeleton data doesn't match realistic content length.

**Enhancements:**
1. **Consolidate AppBar actions** — Move checklist, gallery, and journal into the overflow menu. Keep only "Charts" and "More" as direct actions. — **Very low effort** (~15 min)
2. **Add pull-to-refresh** — The screen is a `CustomScrollView` but doesn't support pull-to-refresh. Users expect this for data-heavy screens. — **Low effort** (~30 min)
3. **Add header illustration** — Replace the plain gradient header with a subtle aquarium illustration or the tank's photo if one exists. — **Medium effort** (~0.5 day)

### Create Tank Screen
**File:** `lib/screens/create_tank_screen.dart`  
**Current state:** Excellent multi-step wizard with progress indicator, haptic feedback, accessibility support (Semantics, FocusTraversalOrder), and clear step-by-step flow. One of the best-implemented screens in terms of UX. Uses `AppButton` consistently.  
**Score:** 8.5/10

**Issues:**
1. **Line 245** — Marine tank option is disabled with "Coming soon" text but still visually appears as a selectable option. The `isDisabled` state reduces opacity to 0.6 but allows taps (which show a SnackBar). This is good UX (acknowledges the feature) but the SnackBar could be more engaging — show a "notify me" option.
2. **Line 300-320** — Size presets (`20L`, `60L`, etc.) are `ActionChip` widgets without any visual indicator of which one was selected. After tapping "120L", the chip doesn't highlight but the text field updates. Add visual feedback.
3. **Line 155** — Water type selector options ("Tropical" / "Coldwater") use emoji icons (🌴, ❄️) which is charming but may not render on all devices.

**Enhancements:**
1. **Add tank setup tips** — Show a small info callout on each page with beginner-friendly context ("Most beginners start with a 60-120L tank"). — **Low effort** (~1 hour)
2. **Add a "Create from template" option** — Preset configurations like "Betta Setup", "Community Tank", "Planted Tank" that pre-fill volume, water type, and even suggest livestock. — **High effort** (~2 days)
3. **Animate page transitions** — The PageView uses `NeverScrollableScrollPhysics` (correct for a wizard) but page transitions could have a more polished animation than the default slide. — **Low effort** (~1 hour)

### Add Log Screen
**File:** `lib/screens/add_log_screen.dart`  
**Current state:** Well-structured form with type selector, pre-filling from last values, photo attachment, and bulk entry mode. The type selector is clear and the water test form pre-fills intelligently. Uses `AppButton` for save action.  
**Score:** 7/10

**Issues:**
1. **Line 55-80** — Pre-filling from last values is a great feature but happens asynchronously after `initState`. The user may start typing before values load, causing a jarring overwrite. Should show a brief loading state or delay the form render.
2. **Line 95** — AppBar uses `AppButton` for save, which is good, but a floating save button or bottom-anchored action bar would be more discoverable.
3. **Not visible in first 200 lines** — The form likely has many TextFormFields for water params. On phones, a long form with 8+ numeric inputs (pH, ammonia, nitrite, nitrate, GH, KH, phosphate, temp) is tedious. Consider a more visual entry method.

**Enhancements:**
1. **Add slider inputs for common ranges** — Instead of typing "7.2" for pH, provide a slider with the range (6.0-8.0) and tick marks. Much faster and more enjoyable. — **Medium effort** (~1 day)
2. **Add "quick log" shortcuts** — One-tap buttons for common entries: "All clear" (sets ammonia/nitrite to 0), "Standard water change" (pre-fills percentage). — **Low effort** (~2 hours)
3. **Show parameter status inline** — As users enter values, show a green/amber/red indicator next to each field based on the tank's target ranges. Immediate feedback makes data entry feel meaningful. — **Medium effort** (~0.5 day)

### Logs Screen
**File:** `lib/screens/logs_screen.dart`  
**Current state:** Clean activity log with filtering, date range selection, skeleton loading, empty states, and staggered animations. Good use of `flutter_animate` for list item reveals. Includes mascot context for empty states. Well done.  
**Score:** 7.5/10

**Issues:**
1. **Line 100-110** — Log list items use `Card` with `ListTile` — functional but every log looks the same. Visual differentiation between log types (water test vs. observation vs. water change) would help scanning.
2. **Line 115** — Entry animations use `delay: (50 * index).ms` which means the 20th item has a 1-second delay. For long lists, this is too slow. Cap the delay at ~500ms.

**Enhancements:**
1. **Add timeline view option** — Instead of a flat list, offer a vertical timeline with connecting lines and type-coloured dots on the left. Makes the history feel more meaningful. — **Medium effort** (~1 day)
2. **Cap animation delays** — Add `.clamp(0, 500)` to the delay calculation so items beyond the 10th render immediately. — **Very low effort** (~5 min)

### Charts Screen
**File:** `lib/screens/charts_screen.dart`  
**Current state:** Feature-rich charting with parameter selection chips, multi-param comparison, goal zones, alert indicators, and CSV export. Uses fl_chart. Good empty state with CTA.  
**Score:** 7.5/10

**Issues:**
1. **Line 80-120** — Parameter chips are a horizontal scroll of `_ParamChip` widgets. With 8 params, this is scrollable but easy to miss params off-screen. A Wrap layout or segmented control would be more discoverable.
2. **Line 130-145** — Chart control chips (Compare, Goal Zones, Alerts) are custom widgets but don't indicate their toggle state clearly enough.

**Enhancements:**
1. **Add parameter summary cards** — Below the chart, show current value, trend direction (↑↓→), and a mini sparkline for each parameter. This gives at-a-glance insight without needing to switch between chips. — **Medium effort** (~1 day)
2. **Add date range selector** — Allow users to zoom into specific time periods (last 7 days, 30 days, 90 days, all time). — **Low effort** (~2 hours)

---

## Design System Check

### App Theme (`lib/theme/app_theme.dart`)
**Score:** 9/10

**What's genuinely good:**
- Pre-computed alpha colours with clear naming convention — eliminates GC pressure from `.withOpacity()` calls
- WCAG AA-compliant semantic colours with documented contrast ratios
- Comprehensive typography scale with semantic aliases
- Consistent spacing tokens (`AppSpacing`)
- Touch target sizes meeting Material Design 3 minimums (48dp)
- Well-documented gradients

**Issues:**
1. `AppSpacing.lg2 = 20` is *less* than `AppSpacing.lg = 24`. The naming suggests `lg2` > `lg`. Rename to `AppSpacing.md2` or reorder values.
2. `AppCurves` and `AppDurations` are referenced in code but defined later in the file — they exist but some screens use raw `Curves.easeInOut` instead of the design system tokens.
3. No dark mode theme data is explicitly constructed — screens manually check `Theme.of(context).brightness` and apply colours. Should have a full `ThemeData.dark()` constructor.

### App Card (`lib/widgets/core/app_card.dart`)
**Score:** 8.5/10

**What's genuinely good:**
- 5 variants (elevated, outlined, filled, glass, gradient) covering all use cases
- Press animation with scale controller
- Haptic feedback on interaction
- Semantic labels for accessibility
- Pre-composed variants (InfoCard, StatisticCard, ActionCard, TrendBadge)

**Issues:**
1. Despite this excellent component existing, many screens don't use it. `LearnScreen`, `PracticeHubScreen`, `StoriesScreen`, and `PracticeScreen` all build their own card containers manually. The design system exists but isn't consistently adopted.
2. The glass variant uses `AppOverlays.white10` / `AppOverlays.black10` without a backdrop filter — so it's not actually glassmorphism, just a semi-transparent card.

### App Button (`lib/widgets/core/app_button.dart`)
**Score:** 8.5/10

**What's genuinely good:**
- 5 variants with clear semantic meanings
- Scale animation on press
- Haptic feedback
- Loading state with spinner
- Full-width option
- `AppIconButton` with enforced semantic labels

**Issues:**
1. Some screens still use `ElevatedButton.styleFrom()` directly instead of `AppButton`. Notably the Learn Screen's "Create Profile" button and multiple quiz action buttons.

### Cozy Card (`lib/widgets/common/cozy_card.dart`)
**Score:** 7/10

A thin wrapper around `AppCard` with warm colours and XL border radius. Good concept, but:
1. Only used in specific screens — not the default for the "cozy room" aesthetic that's supposed to pervade the app.
2. The dark mode colour (`0xFF2D2B3A`) is hardcoded rather than derived from the theme.

### Empty State (`lib/widgets/common/empty_state.dart`)
**Score:** 8/10

Clean wrapper around `AppEmptyState`. Good use across the app with mascot contexts. No issues.

---

## Cross-Cutting Concerns

### Dark Mode Readiness
**Score: 5/10** — Many screens use hardcoded light-mode colours (`Colors.white`, `Colors.grey.shadeXXX`, `Colors.blue`, `Colors.orange.shade700`). The design system has full dark mode support, but it's not consistently applied. Biggest offenders: `StoriesScreen`, `StoryPlayerScreen`, `_StreakCard`.

### Animation Consistency
**Score: 6/10** — Some screens use `flutter_animate` (LearnScreen, LogsScreen), some use manual `AnimationController` (StoryPlayerScreen, EnhancedQuizScreen), some have no animations at all (PracticeHubScreen, PracticeScreen). The app should pick a primary animation approach and use it consistently.

### Accessibility
**Score: 7.5/10** — `CreateTankScreen` has exemplary accessibility (Semantics, FocusTraversalOrder, A11yLabels). Other screens are inconsistent — many interactive elements lack semantic labels. The `AppButton` enforces semantic labels but screens using raw `InkWell`/`GestureDetector` don't.

### Component Adoption
**Score: 5/10** — The design system (`AppCard`, `AppButton`, `CozyCard`, `EmptyState`, `AppStates`) is well-built but severely under-adopted. Many screens build their own card/button variants from scratch, losing haptic feedback, press animations, and dark mode support.

---

## Priority Matrix

| Change | Impact | Effort | Files |
|--------|--------|--------|-------|
| **Fix PracticeHub padding bug (100px)** | 🔴 Critical | 5 min | `practice_hub_screen.dart` |
| **Fix hardcoded accuracy (85%)** | 🔴 Critical | 30 min | `practice_hub_screen.dart` |
| **Fix Stories dark mode colours** | 🔴 High | 1 hr | `stories_screen.dart` |
| **Fix StreakCard hardcoded colours** | 🟡 Medium | 30 min | `learn_screen.dart` |
| **Remove dead PracticeLessonScreen** | 🟡 Medium | 10 min | `practice_screen.dart` |
| **Add confetti to quiz results** | 🟢 High | 30 min | `lesson_screen.dart` |
| **Consolidate banner widgets** | 🟡 Medium | 1 hr | `learn_screen.dart` |
| **Cap log list animation delays** | 🟢 Medium | 5 min | `logs_screen.dart` |
| **Reduce TankDetail AppBar actions** | 🟡 Medium | 15 min | `tank_detail_screen.dart` |
| **Fix quiz progress bar animation** | 🟢 Medium | 15 min | `enhanced_quiz_screen.dart` |
| **Use animated bubbles in StoryPlayer** | 🟢 High | 30 min | `story_player_screen.dart` |
| **Adopt AppCard across all screens** | 🟢 High | 4 hrs | Multiple files |
| **Replace ElevatedButton with AppButton** | 🟡 Medium | 2 hrs | Multiple files |
| **Add visual bullet/numbered lists** | 🟡 Medium | 1 hr | `lesson_screen.dart` |
| **Add reading progress indicator** | 🟢 Medium | 2 hrs | `lesson_screen.dart` |
| **Add slider inputs for water params** | 🟢 High | 1 day | `add_log_screen.dart` |
| **Add inline param status indicators** | 🟢 High | 0.5 day | `add_log_screen.dart` |
| **Build learning path map (Duolingo)** | 🟢 Very High | 2-3 days | `learn_screen.dart` |
| **Add tank health indicator** | 🟢 High | 0.5 day | `home_screen.dart` |
| **Full dark mode audit** | 🔴 High | 1 day | Multiple files |
| **Replace placeholder data in Home** | 🟡 Medium | 0.5 day | `home_screen.dart` |

**Legend:** 🔴 = Bug/must-fix | 🟡 = Should-fix | 🟢 = Enhancement

---

## Final Verdict

**What's genuinely good:** The gamification system is comprehensive and well-architected. Hearts, XP, streaks, spaced repetition, achievements, level-ups, stories — this is not a toy app. The design system foundation is unusually mature for a project at this stage. The Create Tank wizard and Tank Detail dashboard are polished. The Story Player is immersive.

**What needs work:** Consistency. The design system is a Ferrari in the garage — it exists but half the screens drive a Honda. Adopt `AppCard`, `AppButton`, and theme colours universally. Fix the dark mode violations. The Practice Hub has embarrassing padding bugs. And the biggest gap: the Learn Screen needs a visual learning path (connected nodes, not an ExpansionTile list) to feel like a proper gamified experience.

**If I had to pick three changes to ship this week:**
1. Fix the P0 bugs (PracticeHub padding, hardcoded accuracy, dark mode colours)
2. Add confetti + animated bubbles (re-use existing widgets for instant delight)
3. Adopt `AppCard` across Learn and Practice screens for consistency

The bones are excellent. The flesh needs consistency and polish.
