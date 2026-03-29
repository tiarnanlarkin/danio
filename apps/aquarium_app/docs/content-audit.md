# Content Completeness + Copy Polish Audit

**Branch:** `openclaw/stage-system`  
**Date:** 2026-03-29  
**Auditor:** Daedalus (T-D-282)

---

## Executive Summary

The Danio app is in excellent shape from a content perspective. The onboarding flow is warm and well-crafted, error messages are friendly and actionable, and lesson content is substantive. The main issues are a **consistent American English (American spelling) leak throughout lesson data files** (where UK English is expected), two isolated American spellings in UI strings, and minor copy opportunities. No lorem ipsum, no broken stubs, no scary technical error messages.

**Content Completeness Score: 8.5 / 10**

---

## 1. Placeholder / Stub Content

### Result: ✅ Clean

No lorem ipsum, "TODO", "TBD", "FIXME", or fake placeholder text found in user-facing strings.

**Minor notes:**
- `lib/models/story.dart:88` — code comment references "falls back to a placeholder if scenes is empty". This is internal fallback logic, not exposed to users.
- `lib/main.dart:164` — comment mentions "placeholders" in the context of offline mode. Internal only.
- `lib/models/tank.dart:122` — `isDemoTank` field for demo/sample tank. Handled correctly — a dismissible banner is shown in the Home screen when a demo tank is active. Not stub content.
- `comingSoonPathIds` in `lib/screens/learn/lazy_learning_path_card.dart` is an **empty set** — meaning no paths are currently gated as "Coming Soon". The dialog copy (`'The "${meta.title}" path is coming soon — we\'re crafting something great! Stay tuned 🐟'`) is warm and appropriate if/when paths get gated.

---

## 2. Copy Quality

### 2a. Spelling: American English Leaking into Lesson/Data Content

The app uses British English in UI strings (e.g. `recognise`, `recognised`, `behaviour`, `colour`) but lesson data files contain widespread **American spellings**. This is inconsistent and will feel odd to UK users.

#### `color` / `colors` / `colorful` — American spelling in lesson/plant/species data

| File | Line | Current | Suggested Fix |
|------|------|---------|---------------|
| `lib/data/lessons/first_fish.dart` | 41 | `colorful, active` | `colourful, active` |
| `lib/data/lessons/first_fish.dart` | 41 | `many colors` | `many colours` |
| `lib/data/lessons/first_fish.dart` | 41 | `beautiful red color` | `beautiful red colour` |
| `lib/data/lessons/first_fish.dart` | 177 | `'It\'s the wrong color'` (quiz option) | `'It\'s the wrong colour'` |
| `lib/data/lessons/first_fish.dart` | 386 | `Bright, vibrant colors` | `Bright, vibrant colours` |
| `lib/data/lessons/first_fish.dart` | 400 | `Faded colors` | `Faded colours` |
| `lib/data/lessons/first_fish.dart` | 493 | `'Bright color changes'` (quiz option) | `'Bright colour changes'` |
| `lib/data/lessons/nitrogen_cycle.dart` | 485 | `accurate color reading` | `accurate colour reading` |
| `lib/data/lessons/nitrogen_cycle.dart` | 485 | `distort the colors` | `distort the colours` |
| `lib/data/lessons/nitrogen_cycle.dart` | 772 | `'They change the water color'` | `'They change the water colour'` |
| `lib/data/lessons/planted_tank.dart` | 201 | `wide color choices` | `wide colour choices` |
| `lib/data/lessons/planted_tank.dart` | 301 | `'It changes color'` | `'It changes colour'` |
| `lib/data/lessons/water_parameters.dart` | 535 | `'It affects shrimp color only'` | `'It affects shrimp colour only'` |
| `lib/data/lessons/equipment.dart` | 406 | `'Color Temperature (Kelvin)'` | `'Colour Temperature (Kelvin)'` |
| `lib/data/lessons/equipment.dart` | 411 | `makes fish colors pop` | `makes fish colours pop` |
| `lib/data/lessons/equipment.dart` | 492 | `making colors look natural` | `making colours look natural` |
| `lib/data/plant_database.dart` | 332 | `Adds fresh color` | `Adds fresh colour` |
| `lib/data/plant_database.dart` | 336 | `'Bright green color'` | `'Bright green colour'` |
| `lib/data/plant_database.dart` | 376 | `adds color without` | `adds colour without` |
| `lib/data/plant_database.dart` | 454, 496, 522, 568, 989, 1009, 1247 | various `color` | `colour` |
| `lib/data/species_database.dart` | multiple | `colorful`, `color varieties` | `colourful`, `colour varieties` |

**Approximate count:** 32 instances of `\bcolor\b` in lesson/data files — all should be `colour`.

#### `behavior` / `behaviors` — American spelling in lesson/screen data

| File | Line | Current | Suggested Fix |
|------|------|---------|---------------|
| `lib/data/daily_tips.dart` | 38 | `behavior changes early` | `behaviour changes early` |
| `lib/data/lessons/first_fish.dart` | 363 | `'Reading Fish Behavior'` (lesson title) | `'Reading Fish Behaviour'` |
| `lib/data/lessons/first_fish.dart` | 377 | `they communicate through behavior` | `they communicate through behaviour` |
| `lib/data/lessons/first_fish.dart` | 386 | `Regular eating behavior` | `Regular eating behaviour` |
| `lib/data/lessons/first_fish.dart` | 391 | `fish's normal behavior`, `usual behavior` | `fish's normal behaviour`, `usual behaviour` |
| `lib/data/lessons/first_fish.dart` | 409 | `'Behavior-Based Diagnostics'` | `'Behaviour-Based Diagnostics'` |
| `lib/data/lessons/first_fish.dart` | 469 | `'Normal behavior'` (quiz option) | `'Normal behaviour'` |
| `lib/data/lessons/first_fish.dart` | 851 | `swimming behavior` | `swimming behaviour` |
| `lib/data/lessons/maintenance.dart` | 685 | `Observe behavior` | `Observe behaviour` |
| `lib/data/lessons/maintenance.dart` | 811 | `Observing fish behavior` | `Observing fish behaviour` |
| `lib/data/lessons/maintenance.dart` | 817 | `watch behavior` | `watch behaviour` |
| `lib/data/lessons/nitrogen_cycle.dart` | 375 | `fish show stress symptoms` (fine), `test regularly` (fine) | No change needed |
| `lib/data/lessons/equipment.dart` | 374 | `fish behavior` | `fish behaviour` |
| `lib/data/lessons/water_parameters.dart` | 638 | `breeding behavior` | `breeding behaviour` |
| `lib/screens/add_log/add_log_screen.dart` | 791 | `fish behavior, algae` | `fish behaviour, algae` |
| `lib/screens/breeding_guide_screen.dart` | 88 | `spawning behavior` | `spawning behaviour` |
| `lib/screens/emergency_guide_screen.dart` | 167 | `erratic behavior` | `erratic behaviour` |
| `lib/screens/faq_screen.dart` | 165 | `(spots, fins, behavior)` | `(spots, fins, behaviour)` |
| `lib/screens/feeding_guide_screen.dart` | 117, 209 | `hunting behavior`, `scavenging behavior` | `hunting behaviour`, `scavenging behaviour` |
| `lib/screens/glossary_screen.dart` | 337 | `proper behavior` | `proper behaviour` |
| `lib/screens/quarantine_guide_screen.dart` | 93 | `unusual behavior` | `unusual behaviour` |
| `lib/screens/troubleshooting_screen.dart` | 214 | `Natural behavior` | `Natural behaviour` |

**Approximate count:** 22 instances of `\bbehavior\b` in content-facing files — all should be `behaviour`.

#### UI Strings: Isolated American Spellings

| File | Line | Current | Suggested Fix |
|------|------|---------|---------------|
| `lib/screens/settings/settings_screen.dart` | 88 | `'Customize your living room style'` | `'Customise your living room style'` |
| `lib/screens/settings/widgets/tools_section.dart` | 91 | `'Optimize light duration for your setup'` | `'Optimise light duration for your setup'` |

---

### 2b. Tone & Brand Voice Assessment

**Onboarding:** ✅ Excellent

- Welcome screen: `'Your fish deserve better than guesswork.'` — punchy, stakes-setting, on brand.
- `"Danio learns what's in your tank and tells you exactly what they need."` — clear value proposition.
- Experience level cards: warm, non-judgemental. `'Just starting out'` / `'A few years in'` / `'Pretty experienced'` — friendly framing.
- Tank status cards: grounded. `'Thinking about getting one'` not `'No tank yet'` — positive framing.
- Micro-lesson screen is engaging and educational without being preachy.
- Aha moment: personalised fish profile reveal is excellent UX and the copy lands well.
- Push permission screen: `"We'll tap you when something matters."` — trustworthy, not pushy. `"We'll never spam you."` — good. ✅
- Feature summary: `'Danio is free to use — no subscription needed.'` — direct and honest. ✅

**One opportunity on consent screen:** The privacy blurb reads a little corporate — it's functional but cold:
> `'We use Firebase Analytics to understand how people use Danio, and Crashlytics to fix bugs. Data is sent to Google. You can change this anytime in Settings.'`

Suggested warmer version:
> `'We use Firebase Analytics to understand how Danio is being used, and Crashlytics to fix bugs quickly. Data is processed by Google. You can change this any time in Settings.'`

(Minor: "anytime" → "any time" is the stricter UK convention for adverbial use.)

---

### 2c. Grammatical / Phrasing Issues

| File | Issue | Suggestion |
|------|-------|------------|
| `lib/data/lessons/nitrogen_cycle.dart:384` | `'Test strips are convenient - just dip and compare colors.'` — hyphen used instead of em dash for parenthetical | `'Test strips are convenient — just dip and compare colours.'` |
| `lib/data/lessons/nitrogen_cycle.dart:412` | `'Read in natural light - artificial light distorts colors'` | `'Read in natural light — artificial light distorts colours'` |
| `lib/data/lessons/equipment.dart:374` | `'Beginners think lighting is about seeing their fish. Wrong!'` — abrupt single-word sentence | Consider: `'Most beginners think lighting is just about seeing their fish — it\'s not.'` |
| `lib/data/lessons/first_fish.dart:728` | `'Oops - it grows to 40cm'` | `'Oops — it grows to 40 cm'` (em dash + space before unit) |
| `lib/data/lessons/planted_tank.dart:48` | `'Amazon sword - impressive centerpiece'` | `'Amazon sword — impressive centrepiece'` (em dash + UK spelling) |
| `lib/data/daily_tips.dart:38` | `'You'll notice behavior changes early - often the first sign'` | `'You'll notice behaviour changes early — often the first sign'` |
| `lib/data/species_database.dart:927` | `'they can learn to recognise their owner.'` then `'surprisingly intelligent - they can learn'` | Replace hyphen with em dash: `'surprisingly intelligent — they can learn'` |

---

## 3. Error Message Quality Assessment

### Overall: ✅ Very Good

Error messages are consistently friendly, use plain language, and include a clear call to action. The team has done a good job here.

**Highlights (positive):**
- `'Backup didn\'t go through. Check your connection and try again!'` — identifies cause, gives next step. ✅
- `'Marine tanks are on the way — stay tuned! 🐠🦀🐙'` — honest, enthusiastic. ✅
- `'Complete $prereqNames first to unlock ... 🔒'` — constructive, tells users exactly what to do. ✅
- `'Couldn\'t record that answer, try again'` + retry button — functional. ✅
- `'⚡ Energy depleted — keep going! No bonus XP until it refills.'` — clear and motivating. ✅
- Water change notification body copy is warm and informative. ✅

**Minor issues:**

| Location | Current | Issue | Suggestion |
|----------|---------|-------|------------|
| `lib/screens/onboarding_screen.dart:211` | `'Something went wrong. Give it another go!'` | Generic — no hint of cause | `'Couldn\'t save your setup. Give it another go!'` |
| `lib/screens/cycling_assistant_screen.dart` | `'Something went wrong loading your tank data.'` | No retry CTA | Add: `'…Give it a moment and try again.'` |
| `lib/screens/tasks_screen.dart:777` | `'Oops, something went wrong!'` | Too vague, no action | `'Couldn\'t complete that action. Try again!'` |
| `lib/screens/equipment_screen.dart:795` | `'Oops, something went wrong. Try again!'` | Slightly clinical | `'Couldn\'t do that. Give it another go!'` |
| `lib/screens/inventory_screen.dart:175` | `'Couldn\'t use that item, try again'` | Missing punctuation | `'Couldn\'t use that item — try again.'` |
| `lib/features/smart/symptom_triage/symptom_triage_screen.dart:104` | `'Select at least one symptom'` | Instruction, not warm | `'Pick at least one symptom to continue.'` |
| `lib/screens/learn/learn_screen.dart:258` | `'Oops! Something went wrong'` | Title of an error dialog — generic | `'Couldn\'t load lessons'` (more specific) |

**One raw `SnackBar` found** (not using `DanioSnackBar`):
- `lib/screens/lesson/lesson_screen.dart:288-289` uses `ScaffoldMessenger.of(context).showSnackBar(const SnackBar(...))` directly. This bypasses the branded `DanioSnackBar` component. It should be replaced with `DanioSnackBar.show(...)` for visual consistency.

---

## 4. Lesson Content Completeness

### Result: ✅ Good

- **72 lessons** found across 10+ lesson files (`lessonId:` count: 72).
- **163 LessonContent / lessonId / pathId references** in `lib/data/` — substantive content.
- No lessons found with empty titles or empty descriptions.
- `comingSoonPathIds` is an empty set — all learning paths are live.
- Lesson files covered: `nitrogen_cycle`, `water_parameters`, `first_fish`, `maintenance`, `equipment`, `equipment_expanded`, `planted_tank`, `aquascaping`, `breeding`, `fish_health`, `species_care`, `species_care_expanded`, `advanced_topics`, `troubleshooting`.

**Minor:**
- `lib/data/lessons/advanced_topics.dart` references `'Dead centre of the tank'` (UK spelling ✅) — confirmed correct.
- `lib/data/lessons/aquascaping.dart` references `'Dead centre of the tank for maximum visual impact'` — confirmed UK spelling ✅.

---

## 5. Notification Copy

### Result: ✅ Excellent

Notification copy is notably warm, friendly, and well-crafted. Specific highlights:

| Notification | Copy Quality |
|---|---|
| Morning streak | `'🐠 5 minutes to level up your fishkeeping today?'` — question format is engaging, low-pressure ✅ |
| Evening streak | `'🔥 Don\'t lose your streak! Complete a lesson today'` — urgency without being aggressive ✅ |
| Night streak | `'⏰ Last call before midnight! … A 5-minute lesson is all it takes — you\'ve got this!'` — motivating, time-anchored ✅ |
| Review reminder | `'📚 Review time — keep that knowledge sharp!'` — positive framing ✅ |
| Water change (overdue) | `'💧 Your fish want fresh water!'` — fish-first empathy ✅ |
| Water change (upcoming) | `'Staying on top of water changes keeps your fish happy and your tank balanced.'` ✅ |
| Task reminder | `'✅ [task] is due today … Tap to mark it done — your tank will thank you!'` ✅ |
| Achievement | `'🎉 Achievement Unlocked! [icon] [name] - +[XP] XP, +[gems] 💎'` ✅ |
| Onboarding Day 1 | `'Welcome to Danio 🐠 — Your fishkeeping journey starts here.'` ✅ |
| Onboarding Day 2 | `'Did you know? Most aquarium fish can recognise their owner\'s face.'` — UK spelling ✅, charming fact ✅ |
| Onboarding Day 3 | `'Day 3 — you\'re building a habit 💪'` ✅ |
| Day 21 | `'There are 44 bite-sized lessons waiting for you.'` — specific number adds credibility ✅ |

**One minor issue:**  
`lib/services/notification_service.dart` — The `scheduleOnboardingSequence` onboarding Day 1 notification reads:  
`'Your fishkeeping journey starts here. Let\'s meet your fish.'`  
The phrase "Let's meet your fish" is slightly odd if the user hasn't added fish yet (they might still be setting up). Consider: `'Your fishkeeping journey starts here. Let\'s get you set up.'`

---

## 6. Onboarding Flow Assessment

### Value Proposition: ✅ Clear
`'Your fish deserve better than guesswork.'` — immediately frames the problem. `'Danio learns what's in your tank and tells you exactly what they need.'` — concise solution statement.

### Tone: ✅ Welcoming
Cards use first-person language from the user's perspective (`"I'm new"`, `"I've kept fish"`), not third-person labels. No jargon on entry screens. Progress through onboarding feels like a conversation.

### Expectations: ✅ Well Set
- `FeatureSummaryScreen` is honest: `'Danio is free to use — no subscription needed.'`
- Feature list is accurate and appropriately modest: `'Full species care guides for 125+ fish (and growing)'`
- `PushPermissionScreen` clearly explains the value before the OS dialog: water condition alerts, never spam.
- The aha moment (personalised fish profile reveal) sets a high bar for the app experience.

### Opportunities:
1. **Consent screen tone** — see §2b above. Slightly corporate. Minor.
2. **"Quick start with defaults"** (WelcomeScreen secondary link) — the label is functional but slightly dry. Consider: `'Skip setup — use defaults'` or keeping as-is (it's clear enough).
3. **Micro-lesson screen** has no explicit title/heading visible to the user explaining they're about to get a taster lesson. A single line like `'Let\'s see how much you know already'` before the question would set context.

---

## Top 10 Copy Improvements — Ranked by Impact

| # | Priority | File(s) | Issue | Suggested Fix |
|---|----------|---------|-------|---------------|
| 1 | 🔴 High | `lib/data/lessons/first_fish.dart` + all lesson files | **`behavior` → `behaviour`** (22 instances across lesson/screen files) | Batch replace `behavior` → `behaviour` in all `lib/data/` and content-facing `lib/screens/` files |
| 2 | 🔴 High | `lib/data/lessons/first_fish.dart`, `lib/data/plant_database.dart`, `lib/data/species_database.dart` + others | **`color` → `colour`** (32 instances in data files) | Batch replace `color` → `colour` in lesson/data files (excluding Dart code identifiers like `Color(`, `color:`) |
| 3 | 🟠 Medium | `lib/screens/settings/settings_screen.dart:88` | `'Customize your living room style'` — American spelling in UI | `'Customise your living room style'` |
| 4 | 🟠 Medium | `lib/screens/settings/widgets/tools_section.dart:91` | `'Optimize light duration for your setup'` — American spelling in UI | `'Optimise light duration for your setup'` |
| 5 | 🟠 Medium | `lib/screens/lesson/lesson_screen.dart:288` | Raw `SnackBar` bypasses `DanioSnackBar` branding | Replace with `DanioSnackBar.show(context, ...)` |
| 6 | 🟡 Low | `lib/screens/onboarding/consent_screen.dart` | Privacy blurb is functional but cold | Warm up: `'We use Firebase Analytics to understand how Danio is being used, and Crashlytics to fix bugs quickly. Data is processed by Google. You can change this any time in Settings.'` |
| 7 | 🟡 Low | Various lesson files | Hyphens used for parenthetical asides instead of em dashes (e.g. `'convenient - just dip'`, `'in natural light - artificial'`) | Replace ` - ` with ` — ` in parenthetical positions throughout lesson content |
| 8 | 🟡 Low | `lib/screens/tasks_screen.dart:777`, `lib/screens/onboarding_screen.dart:211`, `lib/screens/cycling_assistant_screen.dart` | Generic `'Something went wrong'` errors with no context or actionable next step | Contextualise: `'Couldn\'t save your setup. Give it another go!'`, `'Something went wrong loading your tank data. Give it a moment and try again.'` |
| 9 | 🟡 Low | `lib/services/notification_service.dart` (Day 1 onboarding notification) | `'Let\'s meet your fish'` — may not make sense before fish are added | `'Let\'s get you set up.'` |
| 10 | 🟢 Nice-to-have | `lib/features/smart/symptom_triage/symptom_triage_screen.dart:104` | `'Select at least one symptom'` — terse instruction | `'Pick at least one symptom to continue.'` |

---

## Summary Table

| Area | Status | Score |
|------|--------|-------|
| Placeholder / Stub Content | ✅ Clean | 10/10 |
| Onboarding Flow | ✅ Excellent | 9/10 |
| Notification Copy | ✅ Excellent | 9/10 |
| Error Messages | ✅ Good | 8/10 |
| Lesson Content Completeness | ✅ Good | 9/10 |
| UK English Consistency (UI strings) | 🟠 2 misses | 7/10 |
| UK English Consistency (lesson/data content) | 🔴 54+ misses | 4/10 |
| Tone & Brand Voice | ✅ Warm, on-brand | 9/10 |
| Em Dash Usage | 🟡 Inconsistent in lessons | 6/10 |

**Overall Content Completeness Score: 8.5 / 10**

The main action items are a batch spelling sweep of lesson data files (`color`→`colour`, `behavior`→`behaviour`) and two UI string fixes (`Customize`→`Customise`, `Optimize`→`Optimise`). Everything else is polish.
