# ARTEMIS_ONBOARDING_SPEC.md
# Danio — Onboarding Rewrite Spec
**Author:** Artemis (Product Spec Sub-Agent)  
**Date:** 2026-03-16  
**Status:** DRAFT — Awaiting Tiarnan Review  
**Version:** 1.0

---

## Overview

This spec defines the complete new onboarding flow for Danio, replacing the current 3-slide + 2-question cold-drop experience. The new flow is built around a single principle: **the aha moment must happen within 3 minutes**, and every screen before it exists solely to create the conditions for that moment.

**Core design philosophy:**
- No guilt language. No FOMO. No countdown pressure.
- Confidence-first: the user should feel capable, not overwhelmed.
- Every screen earns its place by moving the user toward their first personalised fish care reveal.
- The paywall is a natural continuation of the aha moment — not an interruption.

**Design system:**
- Fonts: Nunito (body, UI) + Lora (headlines, emotional moments)
- Primary colour: #F5A623 (amber)
- Surfaces: warm cream (#FFF8F0 or equivalent)
- Backgrounds: NanaBanana room illustrations where applicable
- Icons: rounded, friendly, no sharp edges

---

## Flow Summary (9 Primary Screens)

```
[1] Welcome/Hook
    ↓
[2] Experience Level (tap to select)
    ↓
[3] Tank Status (tap to select)
    ↓
[4] Micro-Lesson: "The #1 Mistake" (interactive)
    ↓
[5] First XP Earned (achievement animation)
    ↓
[6] Add Your Fish (search + select)
    ↓
[7] Personalised Fish Care Reveal (AHA MOMENT)
    ↓
[8] Paywall (contextual, fish-specific)
    ↓
[9] Push Notification Permission
    ↓
[10] Warm App Entry
```

Total primary screens: **10** (including warm entry)  
Secondary flows documented separately: Day 2, Day 7, Day 30 returning-user flows.

---

## SCREEN 1 — Welcome / Hook

**Purpose:** Stop the scroll. Make the user feel seen in 5 seconds. One screen, not three.

**Entry condition:** App cold launch, no existing user session.

### UI Components
- **Full-bleed background:** NanaBanana room illustration — warm living room, fish tank visible in background, soft amber lighting. Tank subtly animated (bubbles rising, fish tail flicking — looped 3s animation).
- **Logo:** Danio wordmark, top-centre, small (Nunito Bold, cream).
- **Headline (Lora, 28pt, cream, centred):** positioned in lower 40% of screen over a soft dark-to-transparent gradient scrim.
- **Body text (Nunito Regular, 16pt, cream/80% opacity):** 2 lines max, below headline.
- **Primary CTA button:** full-width, amber (#F5A623), rounded corners (24px), Nunito Bold, dark text.
- **Secondary link:** below button, small, underlined.

### Copy
> **Headline:** "Your fish deserve better than guesswork."
>
> **Body:** "Danio learns what's in your tank and tells you exactly what they need."
>
> **Button:** "Let's get started →"
>
> **Secondary link:** "I already have an account"

### Logic / Branching
- Tap "Let's get started" → Screen 2 (Experience Level)
- Tap "I already have an account" → Login flow (existing flow, out of scope for this spec)
- No auto-advance, no timer.

### Animation Notes
- On screen appear: headline fades up from 8px below (300ms, ease-out). Body fades in 150ms after headline. Button slides up from bottom (200ms, spring).
- Fish tank in background: continuous idle animation (bubbles, subtle fish movement). This runs before user taps anything — it's not decorative, it's proof the app cares about fish.
- No splash screen. No loading spinner. The illustration IS the welcome.

### Exit Condition
User taps "Let's get started."

---

## SCREEN 2 — Experience Level

**Purpose:** Collect the single most important personalisation signal. 2 taps max (tap card, tap continue). No keyboard. No forms.

**Entry condition:** User tapped "Let's get started" from Screen 1.

### UI Components
- **Background:** Cream surface (#FFF8F0). No room illustration — user is now "inside" the app, not looking in.
- **Progress indicator:** Subtle dot row (3 dots, first dot filled amber) — top-centre. Small, not dominant.
- **Headline (Lora, 24pt, dark brown):** centred, top third of screen.
- **Body text (Nunito, 15pt, medium grey):** 1 line, below headline.
- **Option cards:** 3 cards, stacked vertically with 12px gap. Each card:
  - Rounded rectangle (16px radius), cream with amber border when selected (2px)
  - Left: emoji icon (large, 32pt)
  - Right: card label (Nunito Bold, 17pt) + 1-line description (Nunito Regular, 14pt, grey)
  - Tap to select — immediate amber border + soft amber background tint
  - Only one selectable at a time
- **Continue button:** Full-width amber, disabled (grey) until selection made. Activates on card tap.

### Copy
> **Headline:** "How long have you kept fish?"
>
> **Body:** "We'll adjust what we show you based on your experience."
>
> **Card 1:** 🐠 **Just starting out** — "I'm new to fishkeeping or setting up my first tank"
>
> **Card 2:** 🐡 **A few years in** — "I've kept fish before and know the basics"
>
> **Card 3:** 🦈 **Pretty experienced** — "I've had multiple tanks or kept challenging species"
>
> **Button:** "Continue"

### Logic / Branching
- Tap any card → card highlights, Continue button activates.
- Tap Continue → saves `experience_level` (values: `beginner` / `intermediate` / `advanced`). Advance to Screen 3.
- This value is USED — not just collected. See "Personalisation Data Usage" section at end.

### Animation Notes
- Cards animate in with stagger (50ms between each, fade + 4px rise).
- Selected card: border pulses once (scale 1.0 → 1.02 → 1.0, 200ms) to confirm selection.
- Continue button: animates from grey to amber when card selected (150ms colour transition).

### Exit Condition
User selects a card and taps Continue.

---

## SCREEN 3 — Tank Status

**Purpose:** Collect second personalisation signal. Sets up the micro-lesson context. No forms, 2 taps.

**Entry condition:** User completed Screen 2 (experience level saved).

### UI Components
- **Progress indicator:** Dot 2 of 3 filled.
- **Headline (Lora, 24pt):** centred.
- **Body (Nunito, 15pt, grey):** 1 line.
- **Option cards:** 3 cards, same style as Screen 2.
- **Continue button:** same behaviour as Screen 2.

### Copy
> **Headline:** "What's your tank situation?"
>
> **Body:** "We'll help you from wherever you are right now."
>
> **Card 1:** 🏠 **Thinking about getting one** — "I'm planning my first tank but haven't set it up yet"
>
> **Card 2:** 🔧 **Setting it up** — "My tank is new or still cycling"
>
> **Card 3:** 🐟 **Already up and running** — "I have fish in my tank right now"
>
> **Button:** "Continue"

### Logic / Branching
- Tap card → highlights. Continue activates.
- Tap Continue → saves `tank_status` (values: `planning` / `cycling` / `active`).
- All paths advance to Screen 4 (micro-lesson). The content of the lesson does NOT branch here — the micro-lesson is universal. But tank_status affects copy on Screen 6 (aha moment) and Screen 10 (warm entry).
- Specifically: `active` users get "Right now, your [Fish]" phrasing. `planning`/`cycling` users get "When you get your [Fish]" phrasing.

### Animation Notes
- Same stagger card animation as Screen 2.
- Progress dot 2 fills with amber (animated fill, 300ms) as screen loads.

### Exit Condition
User selects a card and taps Continue.

---

## SCREEN 4 — Micro-Lesson: "The #1 Beginner Mistake"

**Purpose:** Deliver genuine value before asking for anything. Make the user feel smart. This is the first interactive moment — it earns trust, sets the learning tone, and gates the first XP reward.

**Entry condition:** Tank status saved. App now has enough context to personalise.

### UI Components
- **Full-screen lesson card UI:** warm cream background, generous padding (24px sides).
- **Progress indicator:** Dot 3 of 3 filled (this completes the "setup" arc).
- **Lesson badge:** Small amber pill at top — "Quick Lesson · 30 seconds" (Nunito SemiBold, 12pt).
- **Headline (Lora, 26pt):** Large, occupies top third.
- **Body text (Nunito, 16pt):** 2-3 short paragraphs. Conversational, not textbook.
- **Interactive element:** A multiple-choice question with 3 answer tiles. Tiled layout (2+1 or 3-column). Tap to answer.
- **Feedback state:** On tap, the correct answer turns green with a ✓, wrong answers grey with ✗ (if wrong was tapped, it greys and correct highlights). A 1-line explanation appears below.
- **Continue button:** Appears only AFTER answering (correct or wrong). "Got it →"

### Copy (beginner variant — shown when `experience_level = beginner` or `intermediate`)

> **Badge:** "Quick Lesson · 30 seconds"
>
> **Headline:** "The #1 mistake that kills fish"
>
> **Body:** 
> "Most fish don't die from illness. They die from water that looks perfectly clean but isn't.
>
> New tanks need time to grow the invisible bacteria that make water safe. Skip this step and even the hardiest fish will struggle.
>
> It's called the nitrogen cycle — and it's the one thing worth getting right from the start."
>
> **Question:** "Why do most beginner fish die in the first few weeks?"
>
> **Answer A:** 🍽️ Overfeeding  
> **Answer B:** 💧 Uncycled water ← CORRECT  
> **Answer C:** 🌡️ Wrong temperature
>
> **Correct feedback:** "Exactly right. Ammonia from fish waste builds up in new tanks before good bacteria arrive to neutralise it. Danio will help you track this."
>
> **Wrong feedback (if A or C tapped):** "Actually, uncycled water is the most common culprit — but overfeeding and temperature matter too. We'll cover all of it."
>
> **Button (after answering):** "Got it →"

### Copy (advanced variant — shown when `experience_level = advanced`)

> **Headline:** "A common mistake even experienced keepers make"
>
> **Body:** 
> "Cross-species compatibility is the issue most keepers underestimate — even after years in the hobby.
>
> Aggression, water parameter overlap, and bioload all interact in ways that aren't obvious from individual species cards.
>
> Danio builds a compatibility map for your specific tank."
>
> **Question:** "What's the most underestimated cause of aggression in community tanks?"
>
> **Answer A:** 🐠 Species mismatch ← CORRECT  
> **Answer B:** 🏠 Tank size  
> **Answer C:** 🍽️ Feeding competition
>
> **Correct feedback:** "Right. Same-species aggression, fin-nipping species, and territory issues cause more problems than most keepers expect."
>
> **Wrong feedback:** "Tank size matters, but species mismatch — including same-species aggression and incompatible temperaments — is the most common root cause."
>
> **Button:** "Got it →"

### Logic / Branching
- Tap answer → immediate feedback (correct/wrong reveal). Answer is locked — no re-tap.
- Correct or wrong: same exit path. The lesson is the value, not a gating quiz.
- "Got it →" → advance to Screen 5 (XP animation).
- `experience_level` determines which lesson variant loads. Intermediate users see the beginner lesson (simpler is safer for engagement).

### Animation Notes
- Answer tiles: on tap, selected tile scales up 1.05 for 100ms, then transitions to green (correct) or red flash → grey (wrong).
- Correct answer (if wrong was tapped): correct tile does a celebratory bounce (scale 1.0 → 1.1 → 1.0, 300ms, spring easing).
- "Got it →" button slides up into view after feedback renders (200ms delay, fade + rise).

### Exit Condition
User taps "Got it →" after answering the question.

---

## SCREEN 5 — First XP Earned

**Purpose:** Reward the user for completing the micro-lesson. Creates the dopamine loop that Duolingo is built on. Sets the expectation: learning in Danio = tangible progress.

**Entry condition:** User tapped "Got it →" on the micro-lesson.

### UI Components
- **Full-screen celebration state:** Cream background, centred content.
- **XP badge animation:** Large circular badge, amber fill, "+10 XP" in Lora Bold (36pt, cream). Enters with a pop animation.
- **Streak/level context:** Below the badge — "Level 1 · 10 XP" (Nunito, 14pt, grey). Progress bar (0→10, fills to 10% of Level 1).
- **Achievement label (Lora, 22pt):** Below progress bar.
- **Body text (Nunito, 15pt, grey):** 1-2 lines.
- **Primary CTA button:** Amber, full-width. Below body.

### Copy
> **Achievement label:** "First lesson complete 🎣"
>
> **Body:** "You just earned your first 10 XP. Now let's make it personal — tell us what fish you're keeping."
>
> **Button:** "Add my fish →"

### Logic / Branching
- No branching. Single path to Screen 6.
- XP is written to user profile: `xp = 10`, `level = 1`.
- No skip option. This screen is short enough that a skip wastes more time than it saves.

### Animation Notes
- **Entry sequence (total ~1.5s, then idle):**
  1. Background burst: amber confetti particles radiate from centre (burst lasts 800ms, particles fade out).
  2. XP badge: scales from 0 to 1.15 (overshoot), settles at 1.0 (spring, 400ms). Appears 100ms after confetti burst starts.
  3. Progress bar: fills from 0% to 10% over 600ms (ease-out), 300ms after badge appears.
  4. Achievement label + body: fade in 200ms after progress bar completes.
  5. Button: slides up 200ms after body appears.
- Confetti colours: amber, warm orange, cream, soft gold (no garish colours).
- Sound: subtle chime (if sound is enabled by system — never force-play sound). 

### Exit Condition
User taps "Add my fish →"

---

## SCREEN 6 — Add Your Fish

**Purpose:** This is the aha moment TRIGGER. User selects their first fish species. The act of selection is the mechanism that unlocks the personalised reveal. Must feel frictionless — search or browse, confirm with one tap.

**Entry condition:** User tapped "Add my fish →" from Screen 5.

### UI Components
- **Header (Nunito Bold, 20pt):** Left-aligned, top of screen (below status bar).
- **Sub-header (Nunito, 14pt, grey):** 1 line.
- **Search bar:** Full-width, rounded (12px), placeholder text, amber focus ring. Keyboard opens automatically.
- **Fish grid / list:** Below search bar. Default state (no search query): shows 12 "popular starter fish" thumbnails in a 3-column grid. Each tile: fish illustration/photo, common name (Nunito Bold, 13pt), scientific name (Nunito Light, 11pt, grey).
- **Search results state:** On typing, grid transitions to list view — full-width cards with fish image, common name, scientific name, difficulty indicator (colour dot: green=easy, amber=medium, red=hard).
- **Selected state:** Tapping a fish adds a amber ✓ badge to its tile and populates a bottom tray.
- **Bottom tray (appears on selection):** Slides up from bottom. Shows selected fish thumbnail + name. "This is my fish →" button (amber, full-width).

### Copy
> **Header:** "What fish are you keeping?"
>
> **Sub-header:** "Search or pick from popular choices below."
>
> **Search placeholder:** "Search 2,000+ species..."
>
> **Popular grid label:** "Popular starter fish" (Nunito SemiBold, 12pt, grey, above grid)
>
> **Bottom tray CTA:** "This is my fish →"
>
> **Bottom tray secondary (if multiple selected):** Shows count badge. (For this onboarding flow, optimise for single-species selection — don't push multi-select.)

### Logic / Branching
- User can search by common name ("neon tetra") or scientific name ("Paracheirodon innesi").
- Minimum 1 fish must be selected to activate bottom tray.
- Tap "This is my fish →" → save `first_fish_species_id`. Advance to Screen 7.
- If user has `tank_status = active`, placeholder copy is "What fish do you have right now?" instead of "What fish are you keeping?"
- If user has `tank_status = planning`, placeholder copy is "What fish are you thinking of getting?"

### Animation Notes
- Keyboard opens automatically on entry (no manual tap needed).
- Search results: transition from grid to list smoothly (crossfade, 200ms).
- Bottom tray: spring-slide up from bottom when first fish tapped (280ms, spring easing). Dismisses if fish is de-selected.
- "This is my fish →" button: amber pulse animation (scale 1.0 → 1.02 → 1.0, 800ms loop) to draw eye downward.

### Exit Condition
User selects a fish and taps "This is my fish →".

---

## SCREEN 7 — Personalised Fish Care Reveal (THE AHA MOMENT)

**Purpose:** This is the entire reason the onboarding exists. The user sees that Danio actually knows about *their specific fish*. Not generic fish advice. Their fish. This is the moment that converts browsers into believers.

**Timing target:** This screen should appear within 3 minutes of app launch.

**Entry condition:** User selected their first fish species and tapped "This is my fish →".

### UI Components — Three-Phase Reveal

This screen has three visual phases, each triggered automatically in sequence (no user input needed until the end).

#### Phase 1: "Generating your profile..." (1.5–2 seconds)
- Dark cream overlay (80% opacity) over the fish selection screen.
- Centred: fish species illustration (large, 120px, circular crop with amber ring).
- Below illustration: fish common name (Lora Bold, 22pt).
- Below name: animated dots / gentle spinner. Not a loading bar — too clinical.
- Subtitle (Nunito, 14pt, amber): "Building your [Fish Name] care guide..."

#### Phase 2: Card reveal (cascading, ~2 seconds)
- Background: warm cream full-screen. Fish illustration moves to top-left corner (small, 48px) — becomes a persistent "your fish" marker.
- Amber header pill: "Your [Fish Name] Profile" (Nunito Bold, 13pt).
- Headline (Lora, 24pt): "[Fish Name] needs a little love."
- Three care cards appear in sequence (stagger 300ms each):

**Card 1 — Water Parameters**
- Icon: 💧
- Label: "Ideal pH"
- Value: Species-specific range (e.g., "6.0–7.0" for Neon Tetra)
- Sub-label: "Soft, slightly acidic water" (or whatever is species-appropriate)
- Your pH indicator: "Most tap water is 7.2–7.8 — we'll show you how to adjust this"

**Card 2 — Compatibility**
- Icon: 🐠
- Label: "Tank mates"
- Value: "Peaceful community fish"
- Sub-label: Species-specific compat note (e.g., "Avoid large cichlids and tiger barbs")
- Callout if tank_status = active: "Danio will check your full tank for conflicts"

**Card 3 — Care Level**
- Icon: ⭐
- Label: "Care level"
- Value: Difficulty rating (e.g., "Easy — great choice for beginners")
- Sub-label: One species-specific care tip (e.g., "Best kept in schools of 6 or more")

#### Phase 3: The Invite (after cards load)
- Below the three cards, a final text block fades in:
  - Body (Nunito, 15pt): "Danio tracks all of this for you — and alerts you if anything goes wrong."
- CTA button (amber, full-width): "See the full care guide →"

### Copy (example — Neon Tetra, beginner user, active tank)

> **Phase 1:** "Building your Neon Tetra care guide..."
>
> **Phase 2 Headline:** "Neon Tetras need a little love."
>
> **Card 1:** 💧 Ideal pH — 6.0–7.0 — "Soft, slightly acidic water. Most tap water is too alkaline — we'll show you how to fix this."
>
> **Card 2:** 🐠 Tank mates — "Peaceful community fish. Avoid tiger barbs, cichlids, and bettas (usually). They're fin-nippers' favourite target."
>
> **Card 3:** ⭐ Care level — "Easy — great choice for beginners. Keep in groups of 6+ or they'll stress out and hide."
>
> **Phase 3:** "Danio tracks all of this for you — and alerts you before problems become emergencies."
>
> **Button:** "See the full care guide →"

### Copy variations by experience level and tank status

| Condition | Variation |
|-----------|-----------|
| `beginner` + `active` | "Danio will help you keep them alive — and thriving." |
| `intermediate` + `active` | "Danio will watch your parameters and flag anything unusual." |
| `advanced` + `active` | "Danio tracks everything, so you can focus on the fun parts." |
| `planning` or `cycling` | Replace "your tank" with "when your tank is ready" throughout |

### Logic / Branching
- Fish care data is fetched from app's local species DB (no network call needed — data is bundled).
- All three cards load within the 1.5s "generating" phase — this is a theatrical delay, not a real one.
- Tap "See the full care guide →" → 2-second beat (see Animation Notes) → advance to Screen 8 (Paywall).
- The 2-second beat is intentional. It lets the aha moment land before the paywall arrives.

### Animation Notes
- Phase 1: fish illustration scales up from 0 to full (spring, 400ms). Dots animate (CSS dot-dot-dot, 400ms interval).
- Phase 1 → Phase 2 transition: illustration scales down and slides to top-left corner (400ms, ease-in-out). Background transitions from overlay to full cream (200ms).
- Phase 2 cards: each card slides in from right (40px) and fades in (250ms per card, 300ms stagger). Not simultaneous — the stagger makes it feel like it's being "built" for the user.
- Phase 3 text + button: fade in after all 3 cards are visible (300ms delay).
- Post-CTA tap beat: screen holds for 2 seconds (no spinner, no animation). Then the paywall slides up from bottom. The 2s is silent. Let the aha land.

### Exit Condition
User taps "See the full care guide →" + 2-second beat elapses.

---

## SCREEN 8 — Paywall

**Purpose:** Convert. This appears immediately after the aha moment — the user has just experienced the product's core value. This is the highest-intent moment in the entire funnel. The paywall must feel like a natural continuation, not a gate.

**Entry condition:** 2-second beat after user tapped "See the full care guide →" on Screen 7.

### UI Components
- **Full-screen modal:** slides up from bottom over the aha moment screen (which remains partially visible beneath, blurred — keeps the context alive).
- **Top handle:** pill drag handle (grey, centred) — user can see this is a bottom sheet. Slightly draggable but no dismiss on drag (dismisses only via the "Maybe later" link).
- **Fish reference header:** small fish thumbnail (48px) + species name (Nunito SemiBold, 14pt) — "Your [Fish Name] care guide is ready."
- **Paywall title (Lora, 26pt):** centred, top of sheet content.
- **Feature list:** 3–4 bullet points (not a wall of text). Nunito, 15pt. Each bullet has a small amber ✓ icon.
- **Pricing block:** Primary plan (annual) shown large. Monthly shown smaller. No confusing tables.
  - Annual: large text (Lora Bold, 28pt for price). "per month, billed annually" in small grey.
  - Monthly: smaller, slightly grey. "or [price]/month"
  - Free trial callout: amber pill — "7-day free trial · Cancel anytime"
- **Primary CTA button:** amber, full-width, Nunito Bold. "Start my free trial →"
- **Plan toggle:** Optional toggle between Monthly / Annual above pricing block. Annual pre-selected.
- **Secondary link:** Below button, centred, small, no underline styling. Quiet.
- **Legal footer:** Terms + Privacy, 11pt, grey.

### Copy (example — Neon Tetra user)

> **Fish header:** "🐟 Your Neon Tetra care guide is ready"
>
> **Title:** "Keep your fish alive, longer."
>
> **Bullets:**
> - ✓ Full species care guides for 2,000+ fish
> - ✓ Water parameter tracking with smart alerts
> - ✓ Tank compatibility checker
> - ✓ Daily lessons to grow your fishkeeping skills
>
> **Annual price:** £3.99/month *(example — use real pricing)*
> *"Billed as £47.99/year"*
>
> **Monthly:** "or £6.99/month"
>
> **Trial pill:** "7-day free trial · Cancel anytime"
>
> **CTA:** "Start my free trial →"
>
> **Secondary link:** "Maybe later"

### Logic / Branching
- Tap "Start my free trial →" → initiate App Store / Play Store subscription flow. On success → Screen 9 (push notification).
- Tap "Maybe later" → dismiss paywall. Advance directly to Screen 9 (push notification). User is on free tier.
- Subscription success also advances to Screen 9.
- Do NOT skip Screen 9 on successful subscription — notification permission is valuable for both free and paid users.
- Annual plan pre-selected (highest LTV option shown first — but no pressure language, no countdown).

### Animation Notes
- Sheet slides up from bottom (350ms, spring easing). Backdrop blur applies to aha moment screen beneath.
- On appear: fish header thumbnail does a subtle bounce (scale 1.0 → 1.05 → 1.0, 300ms) — tiny detail that connects the paywall to the personal moment.
- CTA button: amber, no pulsing on this screen. The aha moment did the work. The button just needs to be clear.
- "Maybe later": appears 1 second after sheet fully loads (slight delay — gives pricing time to register before easy-exit appears).

### Exit Condition
User taps "Start my free trial →" (subscription flow completes or cancels) OR taps "Maybe later."

---

## SCREEN 9 — Push Notification Permission

**Purpose:** Request push permission at peak goodwill — user has just completed the aha moment and made a decision about the app (subscribed or not). This is the highest-trust moment to ask for permission.

**Entry condition:** User exited paywall (either subscribed or tapped "Maybe later").

### UI Components
- **Custom permission prompt (shown BEFORE the system dialog):** This is the pre-permission screen — it explains the value so users don't dismiss the system prompt reflexively.
- **Background:** Warm cream. Centred content layout.
- **Illustration:** A friendly illustrated fish tank with a notification bell floating above it (gentle pulse animation). NanaBanana-style art.
- **Headline (Lora, 24pt):** centred.
- **Body (Nunito, 15pt, grey):** 2-3 lines. Explains what notifications will do. No scary language.
- **Primary button:** amber, full-width. "Yes, keep me informed →"
- **Secondary link:** "Not right now"

### Copy

> **Headline:** "We'll tap you when something matters."
>
> **Body:** "Danio can alert you when your fish's water conditions need attention — before small problems become big ones. We'll never spam you."
>
> **Button:** "Yes, keep me informed →"
>
> **Secondary link:** "Not right now"

### Logic / Branching
- Tap "Yes, keep me informed →" → trigger OS-level notification permission dialog (iOS/Android native). 
  - User grants → permission stored. Advance to Screen 10.
  - User denies OS prompt → still advance to Screen 10 (don't punish denial).
- Tap "Not right now" → skip OS dialog entirely. Advance to Screen 10.
- In both cases, advance to Screen 10.

### Animation Notes
- Notification bell illustration: gentle float animation (translate Y -6px to 0px, 1.5s ease-in-out loop).
- Screen entry: fade in from white (200ms).
- Primary button: standard. No pulsing.

### Exit Condition
User taps either option (permission granted/denied/skipped — all paths proceed to Screen 10).

---

## SCREEN 10 — Warm App Entry

**Purpose:** The opposite of a cold drop. The user's first view of the main app must feel like it was set up for them — not like they've been dumped in a generic home screen.

**Entry condition:** Notification permission step completed (any outcome).

### UI Components
- **Transition animation:** Smooth crossfade from notification screen into main app home (not a hard cut).
- **Home screen — personalised first-launch state:**
  - **Personalised greeting (Lora, 22pt):** Top of screen.
  - **Fish care card (prominent, first item):** The [Fish Name] card from the aha moment — now living in the app. Not a teaser. The full thing (for subscribed users) or a 3-field preview (for free users with "unlock" indicator).
  - **"Your first lesson" card:** Next lesson recommended based on `experience_level`. Beginner: "Understanding the nitrogen cycle in depth." Advanced: "Reading your fish's behaviour as a health signal."
  - **XP progress bar:** Visible at top — "Level 1 · 10 XP". Shows continuity from Screen 5.
  - **Streak counter:** Day 1 streak displayed (amber flame icon). Sets expectation immediately.

### Copy (example — beginner, Neon Tetra, active tank)

> **Greeting:** "Welcome to your tank, [first name if captured, else "fishkeeper"] 🐟"
>
> *(If name not captured during onboarding, use "Welcome to your tank" — no anonymous "User")*
>
> **Fish card header:** "Neon Tetra · Your fish"
>
> **Next lesson:** "Up next: Understanding the nitrogen cycle"
>
> **Streak label:** "Day 1 streak 🔥 Keep it going"

### Copy variations

| Condition | Variation |
|-----------|-----------|
| `planning` | Greeting: "Let's get your tank ready 🏠" |
| `cycling` | Greeting: "Your tank is almost there 🔧" |
| `active` | Greeting: "Welcome to your tank 🐟" |
| `subscribed` | Show full fish care card (all parameters unlocked) |
| `free` | Show fish care card with 3 visible fields + soft "unlock" indicator on additional fields |

### Logic / Branching
- This is the live app home screen. Onboarding session ends here.
- `onboarding_completed = true` written to user profile.
- `first_fish_species_id` surfaced as primary fish card.
- XP total (10) and level (1) carried forward from Screen 5.
- Streak counter initialised to Day 1.

### Animation Notes
- Crossfade from notification screen: 300ms, ease-in-out.
- Fish card: slides in from slightly below (20px), fade in, 400ms, 100ms after home screen appears.
- "Up next" lesson card: appears 200ms after fish card.
- XP bar: animates a quick fill (0 to 10XP position, 500ms) on first render — reminds user they already have XP.
- Streak flame: does a brief flicker animation on first appear (150ms).

### Exit Condition
User is in the live app. Onboarding flow ends.

---

## RETURNING USER FLOWS

### Day 2 — The Hook Return

**Goal:** Re-establish the habit before it's broken.

**Entry condition:** User returns on Day 2 (last session was yesterday, streak = 1).

**What they see:**
1. **No re-onboarding.** Direct to home screen.
2. **Day 2 streak prompt (bottom sheet, auto-appears after 500ms):**
   - Flame icon (animated flicker).
   - "Day 2 🔥 Your streak is alive. Keep it going."
   - "Continue learning →" button → takes to next lesson.
   - Dismiss: tap outside or "Later" link.
3. **Home screen state:** Fish care card prominent. "Day 2 lesson" card surfaces a lesson directly tied to their fish (e.g., "What Neon Tetras eat — and what to avoid").
4. **XP context:** Progress bar visible. Shows 10XP from Day 1. Clear progression path.

**Copy:**
> "Day 2 🔥 You're on a roll."
> "Today's lesson is about [Fish Name] — 5 minutes."
> **Button:** "Start today's lesson →"

---

### Day 7 — The Invested User

**Goal:** Deepen commitment. Surface the features they haven't tried yet.

**Entry condition:** User has 7-day streak OR 7 days since install (whichever is true).

**What they see:**
1. **"One week in" milestone card:** Surfaces on home screen (not a modal — inline card).
   - Gold/amber background. "7 days 🏆 You've earned Apprentice Fishkeeper."
   - Milestone XP reward: "+50 XP bonus" animation plays.
2. **Feature prompt:** Below milestone card — "Have you tried the tank compatibility checker?" with thumbnail and "Try it →" CTA.
3. **Lesson progression:** Lesson card now shows week 2 content (based on experience_level and fish species).

**Copy:**
> **Milestone:** "One week in. You've earned Apprentice Fishkeeper 🏆"
> **Bonus:** "+50 XP for the 7-day streak"
> **Feature nudge:** "Your [Fish Name] care guide has more — tap to explore."

---

### Day 30 — The Committed Keeper

**Goal:** Convert free users still on the fence. Celebrate committed paid users. Reduce churn risk.

**Entry condition:** 30 days since install.

**What they see:**

**For free users:**
1. **Month milestone card:** "30 days of Danio 🎣"
2. **Usage summary:** "You've logged X lessons, earned X XP, and looked up X fish species."
3. **Soft paywall re-engagement:** "You've been using the free version. Here's what unlocking gets you:" — same feature list as paywall, but framed as "you've seen the value, this is more of it." No countdown, no price urgency.
4. **CTA:** "Unlock everything →" → paywall sheet.

**For paid users:**
1. **Month milestone card with premium badge.**
2. **Usage summary + personalised stat:** "Your most-looked-up fish: [species]. You're a [Fish Name] expert."
3. **Feature highlight:** Surface a paid feature they haven't used yet.
4. **No paywall. No upsell.** Just celebration + feature discovery.

**Copy (free user):**
> "30 days in. You're a real fishkeeper now. 🐟"
> "You've learned X things about [Fish Name]. Ready to unlock the rest?"
> **CTA:** "See what's waiting for you →"

**Copy (paid user):**
> "30 days in. Your fish are lucky to have you. 🏆"
> "You've earned [X] XP and completed [N] lessons. Keep going."

---

## PERSONALISATION DATA USAGE

This section documents exactly how `experience_level` and `tank_status` change the in-app experience. These values are collected in onboarding and MUST be used — not stored and ignored (which is the current bug).

### Experience Level Usage

| Surface | `beginner` | `intermediate` | `advanced` |
|---------|-----------|----------------|------------|
| Micro-lesson (Screen 4) | Nitrogen cycle / beginner mistake | Nitrogen cycle / beginner mistake | Compatibility / experienced keeper mistake |
| Lesson recommendations | Start from Lesson 1 (basics) | Start from Lesson 5 (skip fundamentals intro) | Start from Lesson 10 (advanced topics) |
| Care card copy tone | "Here's what this means:" (explanatory) | "You probably know this, but:" (light) | Data-first, no handholding |
| Parameter alerts | Explains what pH/ammonia means when alerting | Brief alert with "why" toggle | Alert only — assumes knowledge |
| Fish search results | Difficulty filter defaults to "Easy" | Difficulty filter defaults to "All" | Difficulty filter defaults to "Medium/Hard" |
| Onboarding aha copy | "Danio will help you keep them alive" | "Danio watches so you don't have to" | "Danio tracks everything" |

### Tank Status Usage

| Surface | `planning` | `cycling` | `active` |
|---------|-----------|-----------|---------|
| Aha moment copy | "When you get your [Fish]..." | "As your tank matures..." | "Right now, your [Fish]..." |
| Home screen greeting | "Let's get your tank ready 🏠" | "Your tank is almost there 🔧" | "Welcome to your tank 🐟" |
| First lesson recommendation | "How to set up your first tank" | "Cycling explained: what's happening right now" | Fish-specific first lesson |
| Parameter tracking prompt | "Set up your tank profile" | "Track your cycle progress" | "Log your first water test" |
| Compatibility checker prompt | "Plan your fish list" | "Check your stocking plan" | "Check your current fish" |

---

## IMPLEMENTATION NOTES

### Dead Code (Must Remove or Activate)
The Duolingo-style placement test, learning style selector, and tutorial screens currently exist as dead code. This spec replaces all of them. The dead code should be:
- Either deleted entirely (preferred)
- Or connected to the new flow where equivalent (the micro-lesson on Screen 4 is the functional replacement for the tutorial)

Do not leave dead code in place — it creates confusion and carries maintenance overhead.

### Species Database
- Minimum viable: Top 100 most common aquarium fish, all fields populated (pH range, care level, compatibility notes, diet, school size).
- Full launch: 500+ species.
- The aha moment (Screen 7) is only as good as the data behind it. Thin species data = weak aha. Invest here.

### Performance Requirement
- Screen 7 (aha reveal) MUST feel instant. The "generating your profile..." delay is theatrical — data must already be loaded. Target: species data available within 200ms of species_id being set.
- The 1.5s "generating" animation should play out regardless of load time. If data isn't ready at 1.5s, extend the animation (not the delay text — keep the fish illustration, remove the loading dots).

### Analytics Events to Instrument
Every screen transition should fire a named event. Key events:

| Event | Trigger |
|-------|---------|
| `onboarding_started` | Screen 1 appears |
| `experience_level_selected` | Screen 2 continue |
| `tank_status_selected` | Screen 3 continue |
| `lesson_answered_correct` | Screen 4 correct answer |
| `lesson_answered_wrong` | Screen 4 wrong answer |
| `xp_earned_first` | Screen 5 appears |
| `fish_searched` | Screen 6 search query entered |
| `fish_selected` | Screen 6 fish tapped |
| `aha_moment_reached` | Screen 7 Phase 2 appears |
| `aha_cta_tapped` | Screen 7 "See full guide" tapped |
| `paywall_seen` | Screen 8 appears |
| `paywall_subscribed` | Subscription success |
| `paywall_dismissed` | "Maybe later" tapped |
| `notification_granted` | OS permission granted |
| `notification_denied` | OS permission denied |
| `onboarding_completed` | Screen 10 renders |

**Funnel to watch:** `onboarding_started` → `aha_moment_reached` → `paywall_seen` → `paywall_subscribed`

The drop between `aha_moment_reached` and `paywall_seen` should be near-zero (the 2-second beat is the only gap). If it's not, something is wrong with the transition.

### A/B Test Candidates (Post-Launch)
1. Screen 1 headline: "Your fish deserve better than guesswork" vs "The fishkeeping app that actually knows your fish"
2. Paywall timing: 2-second beat vs immediate (hypothesis: 2s beat converts better)
3. Micro-lesson: single question vs no question (hypothesis: interactive lesson increases Screen 5 completion)
4. Screen 9 notification copy: "We'll tap you when something matters" vs "Get alerts before your fish are in danger" (hypothesis: care-framing outperforms alarm-framing)

---

## SPEC SUMMARY

| Metric | Value |
|--------|-------|
| Total onboarding screens | 10 |
| Estimated time to aha moment | ~2.5–3 minutes |
| Screens before first value | 3 (Welcome, Experience, Tank) |
| Interactive screens | 2 (Micro-lesson, Add Fish) |
| Personalisation signals collected | 2 (experience_level, tank_status) |
| Personalisation signals actually used | 2 (both — fixed from current 0) |
| Paywall position | Post-aha (Screen 8 of 10) |
| Push permission position | Post-paywall (Screen 9 of 10) |
| Cold drop | Eliminated |

---

*Spec authored by Artemis. For questions, route to Athena → Tiarnan.*
