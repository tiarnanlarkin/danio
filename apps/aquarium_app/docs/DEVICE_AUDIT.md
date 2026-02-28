# Device Audit — Samsung Galaxy Z Fold6 (SM-F966B)

**Date:** 2026-02-28
**Build:** Debug APK (Milestone 5)
**Device:** Samsung Galaxy Z Fold6 (RFCY8022D5R)
**Screen:** 1080×2520 (cover display)
**Android:** Stock Samsung One UI

> **Note:** Red strip on left edge = Samsung Edge Panel. Not an app bug.

---

## Summary

| Screen | Visual Quality | Critical Issues |
|--------|:---:|---|
| Learn | 8/10 | None |
| Quiz | 7.5/10 | Content clipping at bottom |
| Tank/Home | 7/10 | Empty widget area, low-contrast text |
| Smart | 8/10 | None |
| Settings | 7.5/10 | Content clipping, small edit button |
| Achievements | 7.5/10 | Filter tab clipping on right edge |
| Friends | 8/10 | None |
| Tank Detail | 7.5/10 | FAB overlaps content, truncated tip text |

**Overall Average: 7.6/10**

---

## Per-Screen Analysis

### Learn Tab
**Screenshot:** m5_learn.png
**Visual Quality:** 8/10
**Issues:**
- Text truncation mid-word on learning path descriptions (e.g. "must understan…")
- Progress bars at 0% nearly invisible against dark cards — low contrast
- Last card ("Tank Maintenance") clipped at bottom with no scroll affordance (no fade/gradient hint)
- Small chevron arrows (~20-24px) may be undersized for touch targets (recommend 44×44px min)
- XP badge/globe icon overlaps "Beginner" label slightly

### Quiz Tab
**Screenshot:** m5_quiz.png
**Visual Quality:** 7.5/10
**Issues:**
- "Your Progress" section content completely clipped at bottom — no scroll indicator
- Zero-state stats ("Total Cards: 0") uses inconsistent color treatment vs other stat values
- Practice mode left icons have low contrast against card background
- Subtitle/description text in muted grey-green may struggle in bright ambient light

### Tank/Home Tab
**Screenshot:** m5_tank.png
**Visual Quality:** 7/10
**Issues:**
- **Large unexplained brown/wooden area** between tank illustration and "Weekly Trends" — appears to be an empty widget with only two small icons floating in it. Looks unfinished.
- "Daily Goal: 0/100 XP" text has very low contrast — effectively unreadable
- "Living Room Tank / 120L" appears redundantly both as overlay on tank illustration AND as a separate card below
- Hearts row (❤️×5) lacks numeric count, inconsistent with other stats (🔥0 ⭐0 💎0)
- Jarring visual transitions between sections (navy → illustration → brown wood → dark cards)

### Smart Tab
**Screenshot:** m5_smart.png
**Visual Quality:** 8/10
**Issues:**
- Locked feature rows (Fish & Plant ID, Symptom Triage, Weekly Plan) look too similar to unlocked "Anomaly History" — weak disabled state differentiation
- No chevrons on locked rows vs chevron on unlocked row — correct UX but visually subtle
- Slight gap between feature list and "Did You Know?" card
- Minor: "Coming Soon" messaging slightly redundant (top card + individual lock icons)

### Settings Tab
**Screenshot:** m5_settings.png
**Visual Quality:** 7.5/10
**Issues:**
- Content clipping at bottom — last card partially visible with no scroll indicator
- Edit/pencil icon in profile card appears small (~24dp), below 48dp recommended touch target
- "0 day streak 🔥" — flame icon contradicts zero achievement (motivationally poor)
- Profile card has slightly different tint (reddish) vs other cards (blue-grey)
- "Friends" card missing colored icon badge that other cards have — inconsistent

### Achievements
**Screenshot:** m5_achievements.png
**Visual Quality:** 7.5/10
**Issues:**
- **Filter tab clipping** — "Learn" category tab cut off at right edge with no horizontal scroll indicator. Users may not discover additional filters.
- Header progress banner gradient (olive/brown) feels disconnected from dark navy theme
- Bottom row of achievement cards cut off too abruptly — no text visible at all
- Empty progress bar at 0% looks broken (no minimum fill indicator)
- "PLATINUM" badge has marginal contrast (grey on light card)

### Friends
**Screenshot:** m5_friends.png
**Visual Quality:** 8/10
**Issues:**
- "Novice" badge (grey background + white text) reads as disabled/inactive rather than a rank — low contrast vs colorful other badges
- Demo data banner ("connect your account…") blends in too subtly — users may miss it
- Back arrow sits close to screen edge with minimal padding
- Minor layout shift when "Online now" appears vs time elapsed on other cards

### Tank Detail
**Screenshot:** m5_tank_detail.png
**Visual Quality:** 7.5/10
**Issues:**
- **FAB (+) button overlaps PO₄ parameter card AND tip text** — creates visual clutter
- Tip text truncated mid-sentence: "Tip: tap a trend below to jump straight t…" — cut off by FAB/nav overlap
- Parameter grid inconsistent: Row 1 has 3 cards, Row 2 has 2 wider cards, Row 3 has 3 — unbalanced rhythm
- GH, KH, PO₄ all show "—" with no empty-state guidance
- Large header gradient (~30% screen height) for just tank name feels spatially wasteful

---

## Top Priority Fixes

1. **FAB overlap on Tank Detail** — Reposition FAB or add bottom padding to prevent content obstruction
2. **Tank/Home empty brown area** — Either populate the widget or remove it; current state looks broken
3. **Daily Goal text contrast** — Increase text contrast/brightness on Tank/Home screen
4. **Achievements filter tab clipping** — Add horizontal scroll indicator or ensure all tabs fit
5. **Scroll affordance** — Add fade/gradient hints on screens where content is clipped (Learn, Quiz, Settings, Achievements)
6. **0% progress bars** — Add minimum visible fill or marker so they don't look broken

---

*Generated by Athena — On-device visual verification, Milestone 5*
