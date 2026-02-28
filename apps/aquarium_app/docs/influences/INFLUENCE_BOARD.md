# Influence Board — Danio
Version: 1.0 | Date: 2026-02-28

---

## Existing Research — Key Takeaways

From `COMPETITIVE_RESEARCH_REPORT.md` (Feb 9, 2026):

**Market opportunity:** No aquarium app has achieved Duolingo-level engagement. The market is split between data-logging spreadsheet replacements (Aquarimate, Aquarium Note) and basic community apps (AquaHome). None have gamification, education, or habit formation.

**Design lessons from competitors:**
- **Aquarimate** — feature-rich but "feels like a spreadsheet, not fun to use". UI hasn't evolved since 2012. Danio must feel modern and delightful, not utilitarian.
- **AquaHome** — clean modern interface but forced community participation creates friction. Social should always be opt-in.
- **Fishi** — responsive developers + fast iteration = loyal users. Speed of polish matters.
- All competitors lack: gamification, educational content, streaks, daily goals, any form of progress tracking beyond data entry.

**Danio's unique position:** First aquarium app with Duolingo-style learning + gamification + modern UI + habit formation. This is the moat.

---

## Additional Design References

### 1. Duolingo (Education/Gamification)
- **What:** Language learning app, gold standard for gamification in education
- **Why relevant:** Danio is explicitly modeled on this — "Duolingo for fishkeeping"
- **Key patterns to emulate:**
  - **Streak calendar** with emotional reinforcement (✅ already implemented)
  - **Hearts system** limiting daily mistakes (✅ already implemented)
  - **XP and levels** with celebration animations (✅ already implemented)
  - **Lesson path map** with locked/unlocked visual states
  - **Character mascot** that reacts to user progress (Rive animations — partially implemented)
- **What NOT to copy:** Aggressive monetization prompts. Danio should feel generous.

### 2. Habitica (Gamification/Habit Formation)
- **What:** Habit tracker that turns real life into an RPG
- **Why relevant:** Demonstrates how gamification can make mundane tasks (like water testing) feel rewarding. RPG elements create long-term engagement beyond simple streaks.
- **Key insight:** Habitica's pixel-art aesthetic creates emotional attachment to progress. Danio's "cozy room" metaphor serves the same purpose — your virtual space grows as you learn.
- **Pattern to borrow:** Equipment/avatar customisation as reward. Danio's room themes and shop items already do this — lean into it harder.

### 3. Forest (Focus/Gamification)
- **What:** Focus timer app where trees grow while you concentrate
- **Why relevant:** Single-mechanic gamification done beautifully. Proves that one compelling visual metaphor (growing trees) can drive daily engagement.
- **Key insight:** Forest succeeds because the visual reward is calming and satisfying, not flashy. Danio's aquatic/cozy aesthetic should aim for the same — progress feels like nurturing, not grinding.
- **Pattern to borrow:** Time-based rewards with visual growth. Tank "health" improving over time as user completes maintenance tasks.

### 4. Calm / Headspace (Wellness/Dark Theme)
- **What:** Meditation and wellness apps
- **Why relevant:** Best-in-class dark mode design. Aquatic, calming colour palettes. Proves that "soft" design can be premium.
- **Key insight:** Dark backgrounds with luminous accent colours create depth and calm. Danio's dark mode (`#1A2634` background + teal accents) already follows this pattern.
- **Patterns to borrow:**
  - Ambient background animations (bubbles, gentle wave motion)
  - Sound design as part of UX (celebration sounds, ambient aquarium sounds)
  - "Daily check-in" as engagement driver
- **Motion inspiration:** Slow, organic transitions (200–400ms easeOutCubic). Never jarring.

### 5. Brilliant (Education/Dark Theme/Gamification)
- **What:** Math and science learning app with interactive lessons
- **Why relevant:** Combines education + gamification + stunning dark-theme UI. The closest reference to what Danio should feel like in terms of polish level.
- **Key insight:** Brilliant uses interactive problem-solving (not just multiple choice) to make learning feel tactile. Danio's quiz system should aspire to this variety — drag-and-drop, matching, fill-in-the-blank.
- **Patterns to borrow:**
  - Course "path" with branching options (not just linear)
  - Animated explanations inline with lessons
  - Premium "glow" aesthetic on dark backgrounds
  - Subtle particle effects on achievement unlock

---

## Motion & Animation Reference Points

1. **Rive interactive mascots** (Duolingo-style) — already integrated via `rive` package. Expand character reactions (happy on correct, sad on wrong, excited on streak).
2. **Lottie micro-animations** — already integrated via `lottie` package. Use for button feedback, state transitions, loading states.
3. **Flutter Animate stagger patterns** — already integrated via `flutter_animate`. Use for list item entrance animations (150ms stagger per item).
4. **Confetti celebrations** — already integrated via `confetti` package. Use sparingly for major milestones (level up, achievement unlock, streak milestone).

---

## Design Principles (derived from influences)

1. **Nurture, don't pressure.** Progress should feel like tending a garden, not grinding a game.
2. **Calm > flashy.** Aquatic aesthetic means smooth, organic, flowing. Never jarring or aggressive.
3. **Reward learning, not spending.** Gems and shop items are fun extras, not gates.
4. **Every interaction teaches.** Even calculators and tools should include educational context.
5. **Dark mode is first-class.** Not an afterthought — designed with equal care to light mode.
