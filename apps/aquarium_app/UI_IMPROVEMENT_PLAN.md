# Danio UI Improvement Plan
Generated: 2026-02-28

## Executive Summary

Danio has a strong conceptual foundation — the dark aquarium theme is appealing, gamification elements (XP, streaks, hearts) create engagement hooks, and the content structure is logically organised. However, the app has **significant polish and consistency issues** that prevent it from being store-ready. The three most critical problems are: (1) a persistent **red UI artifact bleeding from the left edge** on nearly every screen, (2) **Flutter debug overflow indicators** visible in production builds, and (3) an **inconsistent design system** with no unified type scale, color semantics, or card styling. Overall UI score: **4.5/10**.

---

## Screen-by-Screen Analysis

### 1. Learn Screen (Home Dashboard)
**Screenshot:** screen_launch.png, screen_learn_scrolled.png
**Overall Score:** 5/10

**Strengths:**
- Clear bottom navigation with 5 well-labelled tabs
- XP, streak, and hearts gamification elements are prominently displayed
- Learning Paths cards have good information density (icon, title, description, progress)
- Streak card effectively communicates daily engagement status

**Issues:**
- [CRITICAL] Red element clipped on left edge of screen — visible across nearly all screens, likely a mispositioned widget or debug artifact
- [CRITICAL] "Study" tooltip/label appears frozen/stuck floating over the hero illustration area
- [MEDIUM] Hero illustration consumes ~35% of screen height before any actionable content
- [MEDIUM] Learning path cards have no visible boundaries — blend into the dark background
- [MEDIUM] Icon colours on learning path list are completely inconsistent (amber, orange, green, gray, white, blue) with no theming logic
- [MEDIUM] Progress bar fill colour (tan/beige) doesn't match any other colour in the design system
- [LOW] "Aquarist" rank text nearly invisible — gray on dark gray, extremely low contrast
- [LOW] Description text truncates mid-word ("understan…") — should break at word boundaries
- [LOW] Streak card text uses all-amber colouring, collapsing the hierarchy between headline and body

---

### 2. Quiz/Practice Hub
**Screenshot:** screen_quiz.png
**Overall Score:** 4.5/10

**Strengths:**
- Continue Learning CTA banner is prominent and actionable
- Practice Modes section clearly lists available activities
- Card-based layout is scannable

**Issues:**
- [CRITICAL] Red left-edge artifact visible
- [CRITICAL] "0 Due Today" displayed in red — semantically wrong (zero due should be positive/neutral, not alarming)
- [CRITICAL] "Continue Learning: 17 cards to practice" contradicts "0 Due Today" — logic/copy mismatch
- [MEDIUM] "1 days" pluralisation bug in Study Streak section
- [MEDIUM] Practice Mode card descriptions wrap to 2 lines unnecessarily — container width too narrow
- [MEDIUM] Screen title says "Practice" but tab says "Quiz" — naming mismatch confuses users
- [LOW] Section headers use same weight as card titles — insufficient hierarchy differentiation

---

### 3. Quiz Empty State
**Screenshot:** screen_quiz_active.png
**Overall Score:** 3.5/10

**Strengths:**
- Target icon is thematically appropriate
- Headline text is clear and readable

**Issues:**
- [CRITICAL] No CTA button — user is stranded with no way to navigate to lessons
- [MEDIUM] ~35% of screen is wasted whitespace below the message
- [MEDIUM] Secondary body text likely fails WCAG AA contrast (dark gray on dark background)
- [MEDIUM] No gamification in empty state — missed opportunity to show streak, next review time, mastery stats
- [LOW] Icon background circle barely distinguishable from page background

---

### 4. Tank View
**Screenshot:** screen_tank.png
**Overall Score:** 4/10

**Strengths:**
- Charming aquarium illustration with appealing fish and plant artwork
- Water quality parameters (pH, NH₃, NO₃) are prominently displayed
- Temperature reading is large and scannable

**Issues:**
- [CRITICAL] Flutter debug overflow warning ("RIGHT OVERFLOWED BY 0.592 PIXELS") visible in yellow text — must never appear in any build users can see
- [CRITICAL] Gamification stats overlay appears stuck/persistent over tank content — z-index/state management bug
- [CRITICAL] "hearts" label truncated to "hea..." and "Daily Goal" to "Do..." — text overflow bugs
- [MEDIUM] Water quality values (7.0, 0.0, 10.0) have no semantic colouring (green/yellow/red for safe/warning/danger)
- [MEDIUM] "368/200 XP" suggests goal exceeded but denominator isn't updating — logic issue
- [MEDIUM] Temperature display has no label — relies solely on °C unit
- [LOW] 4 different accent colours in gamification card (orange, yellow, teal, red) with no hierarchy
- [LOW] Label text (~10-11sp) is below recommended 12sp minimum

---

### 5. Smart Hub
**Screenshot:** screen_smart.png
**Overall Score:** 4/10

**Strengths:**
- Card-based layout is scannable
- Feature descriptions are clear and descriptive
- Dark theme is cohesive

**Issues:**
- [CRITICAL] "Coming Soon" banner contradicts tappable-looking feature cards below — cards appear active with chevrons but features don't work
- [CRITICAL] Red left-edge artifact visible
- [MEDIUM] No locked/disabled state on feature cards — users will tap expecting functionality
- [MEDIUM] Icon styles are inconsistent across the 4 feature cards (outlined vs filled, different shapes/saturations)
- [MEDIUM] "Did You Know?" card has no relationship to the AI theme — feels randomly placed
- [LOW] Robot emoji/illustration feels like a placeholder asset

---

### 6. Settings & More Hub
**Screenshot:** screen_settings.png, screen_settings_scrolled.png
**Overall Score:** 5.5/10

**Strengths:**
- Profile card with avatar, level, XP, and streak is informative
- Section grouping (Community, Shop & Rewards, Aquarium Tools, App Settings) is logical
- Consistent row layout with icon, title, subtitle, chevron

**Issues:**
- [CRITICAL] Red strip on left edge of profile card — rendering bug
- [MEDIUM] All subtitle text truncates with ellipsis ("Connect with other aquarium e…", "Browse local aquarium shops a…") — should allow 2 lines or use shorter copy
- [MEDIUM] "Settings & More" is a misnomer — this is a Profile + Navigation Hub, not actual settings
- [MEDIUM] No logout, account management, or privacy settings visible in main view
- [MEDIUM] Icon containers are inconsistent — some have square backgrounds, some circular, some bare
- [LOW] Profile card gradient (dark red-purple) doesn't match the app's blue-gray palette
- [LOW] "1 day streak" on a new user is demotivating — consider hiding sub-3-day streaks

---

### 7. Friends Screen
**Screenshot:** screen_friends.png
**Overall Score:** 3/10

**Strengths:**
- Fish avatars on circular backgrounds add personality
- Search bar is present and appropriately placed
- Friend/Requests tab structure is logical

**Issues:**
- [CRITICAL] Flutter debug overflow labels visible on every friend card ("overflowed by 48px", "overflowed by 57px") — broken card layout
- [CRITICAL] Red left-edge artifact visible
- [CRITICAL] Card layout breaks — badge + streak text + chevron collide due to no overflow protection
- [MEDIUM] Streak text clipped mid-word ("12 da…y streak") — content actually truncated
- [MEDIUM] Two badge tiers (Hobbyist, Aquarist) use identical blue colour — indistinguishable
- [MEDIUM] All "last active" times show "Over a week ago" — either stale demo data or timestamp bug
- [LOW] Handle text (@aqua_explorer) has insufficient contrast — likely fails WCAG AA

---

### 8. Leaderboard
**Screenshot:** screen_leaderboard.png
**Overall Score:** 5/10

**Strengths:**
- League system (Bronze) with timer creates competitive urgency
- Trophy icons for top 3 are visually clear
- XP values are prominently displayed

**Issues:**
- [CRITICAL] Red strip artifact bleeding in from left edge (around ranks 4-7)
- [MEDIUM] No "You are here" row — the primary reason users open a leaderboard is missing
- [MEDIUM] "Bronze" league label repeated under every username — heavy visual noise with zero information value
- [MEDIUM] No promotion/demotion zone marking (e.g., "Top 3 advance to Silver")
- [MEDIUM] Trend arrows only appear for ranks 1-3, not 4-7 — inconsistent
- [LOW] "XP" suffix repeated on every row — should be a column header
- [LOW] Row heights inconsistent between trophy rows (1-3) and number rows (4-7)

---

### 9. Achievements (Trophy Case)
**Screenshot:** screen_achievements.png
**Overall Score:** 4/10

**Strengths:**
- Filter pills (All, Unlocked, Locked, Learning) are useful
- Card grid layout is appropriate for browsing
- Lock icon overlay on locked achievements is conceptually correct

**Issues:**
- [CRITICAL] Red rectangle artifact between sections
- [MEDIUM] Achievement titles truncate mid-word ("Advanced Scho…", "Memory Champ…") — never acceptable
- [MEDIUM] White cards on dark background create harsh contrast — should use dark-surface cards for consistency
- [MEDIUM] "Learni…" filter pill clipped at right edge with no scroll indicator
- [MEDIUM] Stats bar gradient (teal → olive) looks unintentional and visually incoherent
- [MEDIUM] Progress bar on "Year of Learning" nearly invisible (very light fill on light track)
- [LOW] Gray description text on white cards likely fails WCAG AA contrast
- [LOW] "PLATINUM" badge uses gray colour that reads as inactive, not aspirational

---

### 10. Shop Street
**Screenshot:** screen_shop.png
**Overall Score:** 4/10

**Strengths:**
- Monthly Budget tracker is a useful unique feature
- Card layout with icon, title, subtitle is clean
- Wishlist concept is well-structured

**Issues:**
- [CRITICAL] Active nav tab (Settings) doesn't match current screen (Shop) — navigation state bug
- [CRITICAL] Red element clipping from left edge
- [MEDIUM] "0" count on every card with no empty state — three rows of "0" is demotivating for new users
- [MEDIUM] "0" on Gem Shop is semantically ambiguous — zero gems owned? zero items available?
- [MEDIUM] Icon tile background colours (pink, green, blue, purple) feel random with no system
- [MEDIUM] Low contrast throughout — cards barely distinguishable from background
- [LOW] Equipment Wishlist title wraps while others don't — inconsistent card heights
- [LOW] Bottom nav bar switches to dark/black background, creating jarring colour break with green content area

---

### 11. Analytics/Progress
**Screenshot:** screen_analytics2.png
**Overall Score:** 2/10

**Strengths:**
- Time range filter concept is appropriate
- Dark theme is consistent

**Issues:**
- [CRITICAL] All charts render as blank gray rectangles — complete render failure
- [CRITICAL] App triggered an ANR (App Not Responding) dialog when opening this screen
- [CRITICAL] 4 red rotated "RIGHT OV…" debug labels visible — Flutter overflow indicators in production
- [CRITICAL] Red left-edge artifact visible
- [MEDIUM] Time range filter has redundant options (Today + This Week + Last 7 Days overlap)
- [MEDIUM] Bottom nav shows Settings as active despite being on Analytics — wrong tab state
- [MEDIUM] No loading/error state — blank rectangles give zero user feedback
- [LOW] Card grid has unequal sizing and clipping at edges

---

### 12. Lesson Content Screen
**Screenshot:** screen_lesson.png
**Overall Score:** 5.5/10

**Strengths:**
- Single-column reading layout is appropriate for mobile
- Section headers with left accent bar add visual structure
- "Take Quiz" CTA is prominent and well-positioned
- Content is well-written and informative

**Issues:**
- [MEDIUM] Bullet list alignment bug — wrapped text aligns under bullet character, not text start
- [MEDIUM] No reading progress indicator (scroll position bar)
- [MEDIUM] Horizontal padding too narrow (~16dp) — lines feel long and tiring to read
- [MEDIUM] No diagrams or illustrations — the nitrogen cycle begs for a visual
- [LOW] Red left accent bar on section header appears vertically misaligned/clipped at top
- [LOW] XP badge uses steel gray instead of achievement-appropriate gold/amber
- [LOW] Duplicate XP display in lesson rows (metadata "50 XP" AND "+50 XP" right-aligned)

---

### 13. Profile Edit / Settings Detail
**Screenshot:** screen_profile.png
**Overall Score:** 4.5/10

**Strengths:**
- Section grouping (Account, Learn, Explore) is logical
- Teal left-border accent on section headers is effective

**Issues:**
- [CRITICAL] Red left-edge artifact visible
- [MEDIUM] No actual settings toggles/inputs visible — screen is a navigation hub, not settings
- [MEDIUM] "Explore the House" section with oversized heading feels like marketing content misplaced in settings
- [MEDIUM] Gradient card (teal → brown) feels random and unmotivated
- [LOW] Inconsistent type scale — section labels vs "Explore the House" heading

---

### 14. Workshop Screen
**Screenshot:** screen_workshop.png
**Overall Score:** 5/10

**Strengths:**
- Tool grid with icons and descriptions is useful
- CO₂ subscript renders correctly
- Icon accent colours add helpful visual variety

**Issues:**
- [CRITICAL] Red left-edge artifact visible
- [MEDIUM] Bottom row cards clip off-screen without scroll indicator
- [MEDIUM] Nav state bug — Workshop isn't highlighted in bottom nav (Settings appears active instead)
- [MEDIUM] Card internal padding is inconsistent — icons at different visual weights
- [LOW] Overall olive-brown palette is muddy and low contrast
- [LOW] Duplicate wrench icon (header + card) is redundant

---

## Consolidated Issue List (prioritised)

| Priority | Screen | Issue | Suggested Fix |
|----------|--------|-------|---------------|
| P0 | ALL SCREENS | Red UI artifact bleeding from left edge on nearly every screen | Debug the widget tree — likely a mispositioned `Positioned` or `Stack` child with negative offset. Check for a global overlay/drawer that's partially visible |
| P0 | Tank | Flutter debug overflow warning visible ("RIGHT OVERFLOWED BY 0.592 PIXELS") | Fix the layout overflow, ensure `debugShowCheckedModeBanner: false` and overflow indicators are suppressed in release builds |
| P0 | Analytics | Charts render as blank gray rectangles + ANR crash | Fix async data loading, add proper loading/error states, investigate performance causing ANR |
| P0 | Friends | Debug overflow labels on every friend card (48px, 57px overflow) | Fix card layout constraints — likely need `Flexible`/`Expanded` widgets and text overflow handling |
| P0 | Analytics | "RIGHT OV…" debug text artifacts visible | Same root cause as Tank overflow — fix layout constraints |
| P1 | Tank | Gamification stats overlay appears stuck/persistent — no dismiss mechanism | Add clear trigger/dismiss for the stats panel, or integrate it naturally into the layout |
| P1 | Tank | "hearts" truncated to "hea…", "Daily Goal" to "Do…" | Use `Flexible` wrapping, reduce text, or use icons-only layout |
| P1 | Quiz | "0 Due Today" in red + "17 cards to practice" contradiction | Fix logic: align the numbers, use neutral colour for zero state |
| P1 | Smart | "Coming Soon" banner contradicts active-looking feature cards | Add locked/disabled state to cards: gray out, add lock icon, remove chevrons |
| P1 | Multiple | Active nav tab doesn't match current screen (Shop, Analytics, Workshop) | Ensure navigation state is properly tracked for sub-screens |
| P1 | Friends | Card layout completely broken — text overflow, clipped content | Redesign friend card with proper layout constraints and text truncation |
| P1 | Achievements | Title text truncation mid-word ("Advanced Scho…") | Allow 2-line titles or reduce font size |
| P1 | Settings | All subtitle text truncated with ellipsis | Set `maxLines: 2` or rewrite shorter copy |
| P2 | Learn | Hero illustration takes 35% of screen — too much decorative overhead | Reduce height by 40-50%, or make it collapsible on scroll |
| P2 | Learn | Learning path cards have no visible boundaries | Add subtle card background (`#1E2D3D`) with 1px border or divider |
| P2 | Quiz | "1 days" pluralisation bug | Add proper pluralisation logic |
| P2 | Tank | Water quality values have no semantic colouring | Add green/yellow/red indicators based on safe ranges per species |
| P2 | Leaderboard | No "You are here" current user row | Pin current user row at bottom if off-screen |
| P2 | Shop | All wishlists show "0" with no empty state or CTA | Add "Add your first fish →" style prompts |
| P2 | Lesson | Bullet list alignment bug — wrapped text misaligned | Use proper `ListTile` or padded text with correct indentation |
| P2 | All | Inconsistent icon styles across screens | Define unified icon system: consistent shape, size, and colour approach |
| P3 | Learn | "Aquarist" rank text nearly invisible | Increase contrast — use lighter gray or accent colour |
| P3 | Learn | Progress bar fill colour doesn't match design system | Align with primary accent (amber/teal) |
| P3 | Leaderboard | "Bronze" label repeated under every username | Remove or show only for users in different leagues |
| P3 | Achievements | White cards on dark background create harsh contrast | Use dark-surface cards consistent with app theme |
| P3 | Lesson | No reading progress indicator | Add thin progress bar at top of screen |

---

## Top 10 High-Impact Improvements

1. **Fix the red left-edge artifact** — This appears on virtually every screen and is the single most visible bug. Likely a mispositioned widget in the root `Stack` or `Scaffold`. Fixing this one issue instantly improves the perceived quality of every screen.

2. **Remove all Flutter debug overflow indicators** — The yellow "RIGHT OVERFLOWED" warnings on Tank, the red overflow labels on Friends cards, and the rotated debug text on Analytics must never appear. Fix the underlying layout constraints with `Flexible`, `Expanded`, and proper `overflow` handling.

3. **Fix the Analytics screen** — Charts don't render, the screen triggers ANR crashes, and debug text is visible. This screen is completely non-functional and should either be fixed or hidden until ready.

4. **Establish a unified card component** — Create one reusable card widget with consistent background colour, border radius, padding, and elevation. Currently every screen uses a different card treatment, making the app feel like multiple apps stitched together.

5. **Fix navigation state tracking** — Multiple sub-screens (Shop, Analytics, Workshop) show the wrong tab as active. Implement proper `NavigationDestination` state management so the correct tab is always highlighted.

6. **Add semantic colour to data displays** — Water quality parameters, quiz statistics, and leaderboard positions all show raw numbers with no colour-coded meaning. Add green/yellow/red indicators based on context (safe pH = green, dangerous ammonia = red).

7. **Fix text truncation across the app** — Mid-word truncation appears on Learn paths, Achievements, Settings subtitles, and Friend cards. Set `maxLines: 2` with `TextOverflow.ellipsis` at word boundaries, or rewrite copy to fit.

8. **Design proper empty states** — Quiz empty state, Shop wishlists showing "0", Friends demo data, and Smart's "Coming Soon" cards all need purposeful empty state designs with illustrations, helpful copy, and CTAs that guide users to their next action.

9. **Reduce decorative overhead on Learn screen** — The hero illustration, floating "Study" label, and XP display consume too much vertical real estate. Users should see actionable learning content above the fold.

10. **Create a type scale and spacing system** — Define 4-5 font sizes (H1/H2/H3/Body/Caption) and a consistent spacing scale (8dp grid). Apply uniformly across all screens. This single change would dramatically improve visual consistency.

---

## Design System Observations

### Typography
- **No consistent type scale exists.** Font sizes appear arbitrary across screens, ranging from ~10sp labels to ~24sp headlines with no clear hierarchy steps.
- Body text, card titles, section headers, and subtitles often use similar sizes, reducing scanability.
- Bold/regular weight is the primary differentiator, but it's applied inconsistently.
- **Recommendation:** Define 5 type styles: Display (24sp), Headline (20sp), Title (16sp), Body (14sp), Caption (12sp). Apply consistently.

### Colour System
- The app uses a dark navy base (`~#1a2535`) consistently — this is the strongest design system element.
- Accent colours are undisciplined: amber, teal, green, red, blue, purple, gold, and olive all appear with no clear semantic meaning.
- Green is simultaneously used for: completion checkmarks, CTA buttons, progress fills, and friend badges — meaning is overloaded.
- Red is used for: hearts/lives, debug artifacts, Due Today stats, and left-edge bugs — meaning is confused.
- **Recommendation:** Define a semantic colour palette: Primary (amber/gold for branding), Success (green for completion), Warning (yellow), Error (red for danger), Info (teal), and Neutral (grays for text hierarchy).

### Card Components
- At least 5 different card styles exist: flat cards (Learn), gradient cards (Settings), white cards (Achievements), frosted cards (Tank), and borderless cards (Quiz).
- Inconsistent border radius, padding, elevation, and background treatment.
- **Recommendation:** Create 2 card variants: `DanioCard` (standard dark surface) and `DanioCardElevated` (for CTAs/featured content). Use everywhere.

### Icon System
- Mix of emoji, custom icons, and material icons with no consistency.
- Icon containers vary: rounded squares, circles, bare icons, coloured backgrounds.
- Emoji icons render differently across Android OEMs and versions — unreliable for production.
- **Recommendation:** Replace all emoji with SVG/vector icons. Define one icon container style (e.g., 40dp rounded square with tinted background).

### Navigation
- Bottom nav is the strongest UI element — consistent across screens with clear active state.
- However, "Smart" label is vague, "Quiz" vs "Practice" naming is inconsistent, and sub-screen nav state tracking is broken.
- No back/breadcrumb pattern for sub-screens beyond system back button.
- **Recommendation:** Rename "Smart" to "AI" or "Tools", align "Quiz"/"Practice" naming, fix nav state.

### Spacing & Layout
- No consistent spacing grid. Gaps between elements vary from 4dp to 48dp with no apparent rhythm.
- Horizontal padding varies by screen (some 16dp, some 24dp, some edge-to-edge).
- **Recommendation:** Adopt an 8dp spacing grid. Define standard page padding (20dp horizontal), card padding (16dp), and section gaps (24dp).

---

## Production Readiness Assessment

### 🚫 Blockers (Must Fix Before Store Submission)

1. **Flutter debug indicators in production** — Overflow warnings, debug labels, and the persistent red artifact are unacceptable in any shipped build. These alone would likely trigger rejection.

2. **Analytics screen crashes (ANR)** — An unresponsive screen that crashes the app is a hard blocker for store review.

3. **Friend card layout completely broken** — Overflow labels visible on every card with clipped content. Non-functional screen.

4. **Tank screen overlay bug** — Gamification stats panel appears stuck with no dismiss mechanism, blocking tank content.

5. **Accessibility failures** — Multiple text elements likely fail WCAG AA contrast ratios (gray text on dark backgrounds throughout). Required for Google Play accessibility guidelines.

### ⚠️ Should Fix (Won't Block But Will Hurt Reviews)

6. **Text truncation mid-word** across multiple screens — looks unprofessional.
7. **Broken navigation state** on sub-screens — confuses users about where they are.
8. **Empty states with no guidance** — new users see screens full of zeros with no help.
9. **Smart tab full of non-functional features** — could frustrate users; consider hiding until ready.
10. **"0 Due Today" in red / copy contradictions** — confuses and misleads users.

### ✅ Nice-to-Have Polish (Post-Launch)

11. Reading progress indicators in lessons
12. Animated empty states and achievement celebrations
13. Swipe navigation between lessons
14. Water quality trend charts
15. Profile photo upload
16. Promotion/demotion zones on leaderboard
17. Semantic progress bar colours
18. Skeleton loading animations

---

*Report generated by automated UI audit on 2026-02-28. Screenshots captured from Samsung Galaxy Z Fold (SM-F966B) running Android 16, debug build on branch `openclaw/qa-fixes`.*
