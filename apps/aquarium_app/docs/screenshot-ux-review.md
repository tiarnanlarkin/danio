# Danio App — Screenshot UX Review
**Reviewed by:** Apollo (Design Agent)  
**Date:** 2026-03-29  
**Scope:** Onboarding, Home, Learn, Practice, Tank, Key Interactions, Settings

---

## Per-Screenshot Notes

### Batch 1 — Onboarding

#### `danio-test-01-privacy.png` — Privacy Consent Screen
- Good vertical hierarchy (icon → title → body → checkboxes → buttons), but both "Accept Analytics" and "No Thanks" buttons are the **same muted gray** — no visual distinction between primary and secondary actions.
- Checkboxes appear to be ~24px, well below the 44px minimum tap target. This could prevent users from ticking them.
- The two links (Terms / Privacy Policy) are styled correctly in orange — a nice touch.

#### `danio-test-05-onboarding-start.png` — Experience Level Selection
- Clean card layout with clear three-choice hierarchy. However, the **"Continue" button appears disabled** (gray on gray) even before selection — this creates anxiety about whether the button will respond.
- No selected state is visible in this screenshot, making it unclear to users which card they've chosen.
- Pagination dots (step 1 of 10) are decorative and very small — cannot be interacted with, which is fine, but their tiny size makes the step count hard to read.

#### `danio-test-12-add-fish.png` — Fish Selection Grid (no selection)
- Efficient 4-column grid with search bar. Good for browsing.
- **Scientific names are truncated** ("Paracheirodon in...", "Bronze Coryd...") throughout — users cannot read full species names, which is core content for this audience.
- No visible navigation forward (CTA button absent), leaving users uncertain how to proceed.

#### `danio-test-13-fish-selected.png` — Fish Selection Grid (Betta selected)
- Selected state (orange border + checkmark on Betta card) is clear and polished. 
- Sticky bottom bar showing "Betta" + CTA button is a good pattern.
- Scientific name truncation persists. The grid card size could allow for slightly smaller font or two-line wrap rather than ellipsis.

#### `danio-test-15-post-start-journey.png` — Post-Onboarding Confirmation
- **Critical layout issue:** The feature checklist occupies roughly the top 40% of the screen, with a vast empty void before the CTA button. Feels incomplete or like content failed to load.
- Olive/yellow-green checkmarks have questionable contrast against the cream background — potential WCAG failure.
- No back navigation visible. First-time users may feel trapped on this screen.

---

### Batch 2 — Home Screen States

#### `danio-test-16-main-app.png` — Notification Permission Screen
- Well-executed permission ask screen. Clear hierarchy, good CTA prominence (orange button), appropriate de-emphasis of "Not right now."
- Minor: content slightly low on screen, leaving empty real estate at the top.
- "Not right now" text link has a small tap target — could use more vertical padding.

#### `danio-test-18-main-home.png` — Name Input Screen
- **Inconsistent button pattern:** Previous screens used full-width buttons; this screen places the input field and "Next →" button side-by-side in one row — unconventional and cramped.
- Screen is ~70% empty below the input field — very top-heavy with wasted space.
- Both "(optional)" in the placeholder AND a "Skip" link below create redundancy. Remove one.

#### `danio-test-19b-home-fresh.png` — Learning Home Screen (Fresh)
- Good overall structure: gradient header → Interactive Stories card → beginner callout → Learning Paths. Warm, inviting.
- The first learning module appears to be auto-expanded by default, creating a very long scroll that may bury other learning paths.
- Two competing "Start Here" prompts (badge + banner) — consolidate into one.

#### `danio-test-30-tank-view.png` — Tank View with Neon Tetra Modal
- **Critical bug:** Tank name displays as `My%20Betta%20TanTestTank` — URL-encoded string rendered raw. This is a showstopper for production.
- "1-day streak!" notification banner partially obscures the "5/5" counter in the top bar.
- Modal is clear and well-styled, but the dismiss target (X on streak banner) appears very small.

#### `danio-test-34-tank-main-view.png` — Tank Main View
- URL-encoding bug persists as the tank label (`My%20Betta%20TanTestTank · 60L`).
- Left/right navigation arrows for tank carousel are small, partially cropped, with tap targets well below 44px.
- Large empty beige area below the tank stand (~25% of screen height) — wasted engagement opportunity. Could show tank stats or fish count.

---

### Batch 3 — Learn + Practice Tabs

#### `danio-test-51-learn-tab.png` — Lesson List Expanded View
- Clean lesson list with clear lock/unlock states and XP indicators — good design.
- "Start Here🔥" badge in the module header is **truncated/cut off** — badge layout needs overflow handling.
- First available lesson's play icon could be more prominent (e.g., filled circle vs. outline) to signal it as the entry point.

#### `danio-test-52-learn-top.png` — Learning Overview (with streak)
- Good gamification hierarchy — streak banner, XP, progress bars all motivating.
- "Streak freeze available" blue link text on yellow/amber background may fail WCAG AA contrast (estimated ~2.5:1).
- Auto-expanded first module creates a very long initial scroll — consider collapsed by default.

#### `danio-test-22-practice-tab.png` — Practice Dashboard (Empty State)
- Clean empty state with a clear explanation card. Statistics row (Due Today / Mastered / Total) is informative.
- **"Start Learning →" is a text link**, not a button — undersized tap target, low visual prominence for a key CTA.
- Excessive empty space above the main card creates visual imbalance.

#### `danio-test-88-spaced-rep.png` — "All Caught Up" State
- Well-executed empty state with centered illustration, clear messaging, single CTA. Excellent.
- "Next review in: 23 hours" — the label text ("Next review in:") is low contrast gray on beige, borderline accessible.
- Orange "23 hours" text is readable but worth verifying contrast ratio.

#### `danio-test-69-learn-updated.png` — Level Up Modal (over lesson)
- **Critical contrast failure:** White text on solid orange background ("Level Up!", "Level 2 Novice", "225 Total XP") fails WCAG AA.
- "Continue" button (cream on orange) also has insufficient contrast.
- No dismiss option (no X button) — user must tap Continue. This could be intentional but feel coercive.

---

### Batch 4 — Key Interaction Screens

#### `danio-test-58-lesson-start.png` — Article View with Quiz Modal
- Good article layout — warm typography, clear heading ("Why New Tanks Kill Fish"), comfortable line height.
- Modal overlay is clean but "Got it!" is a text-only CTA with no button background — low visual prominence.
- Navigation title "The Nitroge..." is truncated — fix with `TextOverflow.ellipsis` on a longer label or abbreviate differently.

#### `danio-test-60-quiz.png` — Quiz Interface
- Strong quiz layout: progress bar, question count, hint affordance, full-width answer cards. Very good.
- **"Check Answer" button appears grayed out/disabled** when no answer is selected — this is correct UX behaviour but the disabled state contrast is very low (light gray on gray).
- Answer option letter badges (A, B, C, D) use light orange on lighter orange — marginally sufficient contrast.

#### `danio-test-64-quiz-complete.png` — Quiz Question with Correct Answer
- Correct answer selection (green border on option B) is clear and satisfying.
- Explanation card below the answer is well-positioned and readable.
- Option B loses its letter indicator when selected (shows empty space instead of "B") — inconsistent selection state rendering.

#### `danio-test-71-level2-screen.png` — Level Up / Completion Screen
- **Critical layout bug:** The large purple "2" level circle overlaps and obscures the score text ("You got X (100%)") above it. Either mid-animation capture or a real z-index/layout issue.
- Screen has too many competing messages: "LEVEL UP!", "Perfect Score!", "Lesson Complete!", next lesson card, confetti — cognitive overload.
- "Lesson Complete!" appears *below* the "Continue" button, which is wrong sequencing — it should appear first.
- Two additional buttons are partially cropped at the bottom — unclear what they do.

#### `danio-test-44-settings.png` — Preferences / More Screen
- **Content architecture issue:** This screen mixes Preferences, progress stats, gamification data, AND navigation shortcuts ("Explore the House"). It's trying to be too many things.
- "Beginner · 50 XP" text on the orange card fails WCAG AA contrast (~2.8:1 estimated).
- Section headers (ACCOUNT, LEARN, EXPLORE) are small muted uppercase — low contrast and hard to scan.
- Green card at the bottom is cut off with no scroll indicator — discoverability issue.
- "Explore the House" is styled as an H1-weight heading while "Account & Sync" is body weight — inconsistent treatment of equivalent list items.

---

## Top 10 Visual Issues — Ranked by User Impact

| # | Issue | Severity | Screenshot(s) |
|---|-------|----------|---------------|
| 1 | **URL-encoded tank name displayed raw** (`My%20Betta%20TanTestTank`) | 🔴 Critical | `danio-test-30-tank-view.png`, `danio-test-34-tank-main-view.png` |
| 2 | **Level Up overlay obscures score text** — large circle covers "You got X (100%)" | 🔴 Critical | `danio-test-71-level2-screen.png` |
| 3 | **Level Up modal: white text on orange fails WCAG AA contrast** | 🔴 Critical | `danio-test-69-learn-updated.png` |
| 4 | **Primary action buttons look disabled** — Continue/Check Answer styled in low-contrast gray before interaction | 🟠 High | `danio-test-05-onboarding-start.png`, `danio-test-60-quiz.png` |
| 5 | **Post-onboarding confirmation screen has massive empty void** — ~60% of screen blank, feels broken | 🟠 High | `danio-test-15-post-start-journey.png` |
| 6 | **Settings screen has wrong content architecture** — mixes navigation, gamification and preferences in one view | 🟠 High | `danio-test-44-settings.png` |
| 7 | **Scientific names truncated in fish grid** — core content for the target audience | 🟡 Medium | `danio-test-12-add-fish.png`, `danio-test-13-fish-selected.png` |
| 8 | **Tank carousel navigation arrows below minimum tap target** — partially cropped, ~20px | 🟡 Medium | `danio-test-34-tank-main-view.png` |
| 9 | **Name input screen: inline input+button layout is unconventional and top-heavy** — 70% empty below input | 🟡 Medium | `danio-test-18-main-home.png` |
| 10 | **Level Up / Lesson Complete screen has cognitive overload** — too many simultaneous celebration messages, cropped buttons | 🟡 Medium | `danio-test-71-level2-screen.png` |

---

## File/Line Recommendations

The following are suggested areas to investigate in the codebase:

- **URL-encoding bug:** Look for `Uri.encodeComponent()` or `Uri.encodeFull()` applied to tank name on write, but not decoded on read. Check wherever `TankModel.name` is stored/retrieved. Fix: apply `Uri.decodeFull()` or `Uri.decodeComponent()` when rendering, or strip encoding at persistence layer.
- **Level Up modal layout:** Check `level_up_overlay.dart` or similar — the purple level circle likely uses an `Positioned` or `Stack` widget that overlaps text. Add appropriate top margin or restructure the stack order.
- **Disabled button contrast:** Search for `ElevatedButton.styleFrom(disabledBackgroundColor:...)` — bump the disabled color from gray to a more visible muted primary. Consider using `opacity` overlay on the active color instead.
- **Settings screen content architecture:** `more_tab.dart` or `settings_screen.dart` — the "Explore the House" section and gamification card should be moved to the home dashboard, not the preferences/more screen.
- **Scientific name truncation:** Fish grid cards — use `maxLines: 2` with `TextOverflow.ellipsis` on scientific names instead of single-line ellipsis, or reduce font size by 1-2pt to fit more characters.
- **Post-onboarding empty space:** `journey_start_screen.dart` or equivalent — check if a `Spacer()` or `Expanded` is consuming space where an illustration or additional copy should live. This screen likely has a missing asset or a removed section.

---

## Overall Visual Polish Score

**6.5 / 10**

### Rationale
The app has a clear, warm visual identity with a consistent cream/orange palette that feels appropriate for the subject matter. Core learning flows (quiz, lesson, progress tracking) are well-structured and engaging. Gamification elements (XP, streaks, locks) are well-integrated.

Points deducted for:
- A showstopper data-rendering bug (URL encoding) that would immediately undermine user trust
- Multiple contrast failures on critical screens (Level Up modal, Settings card text)
- Inconsistent button treatment (full-width vs. inline, filled vs. text-only) that undermines confidence in primary actions
- A completion/celebration screen (Level 2) that currently feels visually broken (overlap, cropped buttons, overcrowded)
- The Settings/More screen identity crisis — it's trying to be home screen, navigation, and preferences simultaneously

With targeted fixes to the top 5 issues, this could easily score **8/10**. The foundations are solid.

---

*Review generated by Apollo — Design Agent for Mount Olympus*
