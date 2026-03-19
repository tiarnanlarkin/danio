# APOLLO_PAYWALL_DESIGN.md
# Danio — Paywall Screen Design Brief
**Author:** Apollo (Design Sub-agent)  
**Date:** 2026-03-16  
**Status:** READY FOR IMPLEMENTATION

---

## Overview

The Danio paywall is a confidence-builder, not a sales pitch. It appears at peak emotional investment — the moment a user has just added their first fish and seen their personalised care card. They're hooked (pun intended). Our job is to meet their anxiety with reassurance, and turn "I hope I don't kill this fish" into "I've got everything I need."

**Core emotion to trigger:** Relief. Safety. Belonging.  
**Core fear to address:** "I'll mess something up and my fish will die."  
**Core promise:** "We'll make sure that doesn't happen."

---

## 1. LAYOUT SPEC

### Overall Structure
Full-screen modal over the care card (care card blurs and dims to 40% behind it). Not a push navigation — this feels like an overlay, preserving the "aha" context beneath. User can always see their fish name ghosted behind.

**Screen height budget (844px reference / iPhone 14):**
| Zone | Height | Notes |
|------|--------|-------|
| Header (fish hero + headline) | 220px | Fish illustration + personalised copy |
| Value props (4 bullets) | 180px | Icon + copy, compact rows |
| Pricing toggle | 120px | 3 options, pill selector |
| Trial timeline | 80px | Day 0 / Day 5 / Day 7 row |
| CTA button | 56px | Full-width, amber |
| Skip link | 44px | Centred, low contrast |
| **Total** | **700px** | Safe on all modern devices, scrollable on SE |

---

### Header Area

**Visual:** 
- The fish species illustration from the care card (same asset, ~96px) centred at top
- Warm cream (#FFF8F0) background that bleeds from the care card beneath
- Subtle amber gradient wash from top-left corner (15% opacity #F5A623)
- Fish name in **Lora Bold 22px** directly below illustration: "{Fish Name}" in #1B7A6E teal
- Headline in **Nunito ExtraBold 26px** below that, #2C2C2C near-black

**Personalisation logic:**
- If species known → show species illustration + species name in headline
- If custom name given → use their given name ("Your Bubbles needs...")
- If both → use given name first, species in parentheses subtitle
- Fallback → generic fish silhouette + fallback headline

**Personalisation data sources:**
- `fish.species` → illustration key + species-specific copy variant
- `fish.nickname` → preferred over species name in headline
- `fish.tankSize` → used for bullet 3 water quality copy

---

### Value Proposition Section

4 bullet rows. Each row:
- 24px icon (teal #1B7A6E, filled, rounded)
- **Nunito Bold 16px** title on line 1
- **Nunito Regular 14px** #666 subtitle on line 2
- 12px vertical padding between rows

Icons (use from existing Danio icon set or Material Rounded):
1. 🩺 Medical cross / health shield
2. 📚 Open book / graduation cap
3. 💧 Water drop
4. 👥 People / community

---

### Pricing Options Display

**Layout:** Horizontal pill selector (not cards) for the 3 plans.
- Default selected: **Annual** (pre-selected on load)
- Pills sit on a #F5EDD8 warm sand background row, rounded 12px corners
- Selected pill: #F5A623 amber fill, white text, subtle drop shadow
- Unselected: transparent, #8A7B6A muted text

**Pill order (left → right):**
```
[Monthly]  [Annual ★ Most Popular]  [Lifetime]
```

**Below the pills:** An expanded detail card animates in for the selected plan:
- Price (large, **Lora Bold 32px**)
- Per-unit breakdown (**Nunito Regular 14px** #666)
- For annual: strikethrough monthly equivalent + "Save 47%"
- For lifetime: "Pay once, yours forever"

**Most Popular badge:** Amber #F5A623 label above the Annual pill, small **Nunito Bold 11px** ALL CAPS: "MOST POPULAR"

---

### Trial Timeline Module

A horizontal 3-step timeline with connecting line.

```
[●]————————[○]————————[○]
Today       Day 5        Day 7
Start free  Reminder     Billed
trial       sent         $24.99/yr
```

- Active node (Today): amber filled circle
- Future nodes: cream circle with teal border
- Connecting line: dashed, #D4C4B0 warm grey
- Node labels: **Nunito Bold 12px** above the node
- Sub-labels: **Nunito Regular 11px** #888 below the node
- Only shown when Annual plan is selected (slides in/out with plan selection)

---

### CTA Button

- **Full width** (horizontal margin 24px each side)
- Height: 56px
- Background: #F5A623 amber
- Text: **Nunito ExtraBold 18px** white, centred
- Corner radius: 16px
- Drop shadow: 0px 4px 12px rgba(245, 166, 35, 0.35)
- Active/pressed state: scale(0.97) + shadow collapse, 120ms

**Button copy changes with plan selection:**
- Annual (default): **"Start My Free 7-Day Trial"**
- Monthly: **"Start Danio Pro"**
- Lifetime: **"Get Lifetime Access"**

---

### Skip / Maybe Later Option

- Position: centred below CTA button, 16px gap
- **Nunito Regular 14px**
- Colour: #A89880 (warm grey, low contrast — visible but not prominent)
- Text: **"Maybe later"**
- Touch target: full-width invisible tap zone (44px height) despite small text
- No underline, no button styling — it's a ghost

**Behaviour on tap:** Dismiss modal with a slow fade (300ms), return to care card. No guilt, no second dialog, no "are you sure?"

---

## 2. COPY

### Headline

**Personalised (species known):**
> "Your [Fish Name] deserves the best care."

Examples:
- "Your Betta deserves the best care."
- "Your Neon Tetras deserve the best care."
- "Your Oscar deserves the best care."

**Personalised (nickname given):**
> "[Nickname] is lucky to have you — keep it that way."

Examples:
- "Bubbles is lucky to have you — keep it that way."
- "Finn is lucky to have you — keep it that way."

**Fallback (no name/species yet):**
> "Give your fish the care they deserve."

---

### 4 Value Proposition Bullets

**Bullet 1 — Species-specific care**
> 🩺 **Full care guides for your exact fish**  
> Feeding schedules, tank setup, disease symptoms — all tailored to your species.

**Bullet 2 — Learning path**
> 📚 **Unlock every lesson, no walls**  
> Progress through the full curriculum at your pace. Water chemistry, breeding, community tanks — it's all yours.

**Bullet 3 — Water quality alerts**
> 💧 **Never miss a water change**  
> Smart reminders based on your tank size and stocking. Your fish stay healthy. You stay sane.

**Bullet 4 — Community**
> 👥 **Join a community that gets it**  
> Ask questions, share wins, get help from fishkeepers who've been there. No judgment — just fish people.

---

### Pricing Copy

**Annual Plan**
- Badge: `MOST POPULAR`
- Label: `Annual`
- Price: `$24.99 / year`
- Breakdown: `Just $2.08/month — less than a bag of fish food`
- Savings callout: `Save 47% vs monthly`

**Monthly Plan**
- Label: `Monthly`
- Price: `$3.99 / month`
- Breakdown: `Cancel anytime`

**Lifetime Plan**
- Label: `Lifetime`
- Price: `$49.99 once`
- Breakdown: `Pay once. Yours forever.`

---

### Trial Timeline Copy

```
Today                  Day 5                  Day 7
Start your             We'll remind           You're billed
free trial             you before             $24.99/yr
                       billing
```

Above timeline (small, centred, **Nunito Regular 13px** #888):
> "Try everything free for 7 days. Cancel before Day 7 and you won't be charged."

---

### CTA Button Text

- Annual (default): **"Start My Free 7-Day Trial"**
- Monthly: **"Start Danio Pro"**
- Lifetime: **"Get Lifetime Access"**

---

### Skip Link Text

> "Maybe later"

*(No guilt variant. Do not use "No thanks", "I'll risk it", "Skip for now — my fish might suffer", or any dark-pattern variant.)*

---

### Social Proof Line

Position: between value props and pricing section, centred.  
Style: **Nunito Regular 13px** #888, italic

> "Join 12,400 fishkeepers who haven't lost a fish since starting Danio Pro."

*(Number should be dynamic / A/B tested. Start with a conservative real number at launch. Do not invent.)*

Alternative for early launch (pre-data):
> "Fishkeepers who track their water changes lose 60% fewer fish. Start the habit today."

---

## 3. ANIMATION SPEC

### Entry Animation — Paywall Screen Appears

**Trigger:** Care card "aha moment" fully loaded (card animate-in completes)  
**Delay:** 800ms after care card settles (let the user *feel* the aha moment first)

**Sequence:**
1. Background blur: care card blurs to 8px over 300ms easeOut
2. Overlay dim: dark scrim fades to 40% opacity over 300ms easeOut (concurrent with blur)
3. Modal slides up from bottom: `translateY(100%) → translateY(0)`, 450ms cubic-bezier(0.34, 1.56, 0.64, 1) — a soft spring/elasticOut feel
4. Fish illustration: scale(0.6) → scale(1.0), 600ms elasticOut, starts 100ms after modal begins
5. Headline: fadeIn + translateY(8px → 0), 350ms easeOut, starts 200ms after modal begins
6. Value bullets: staggered fadeIn, each 80ms apart, starting 350ms after modal begins
7. Pricing row: fadeIn 300ms, starts after last bullet appears
8. Trial timeline: slideIn from right (20px), 300ms easeOut, starts with pricing row
9. CTA button: scaleX(0.95 → 1.0) + fadeIn, 300ms elasticOut, starts 500ms after modal begins
10. Skip link: fadeIn 200ms, starts 700ms after modal begins (last thing to appear — lower visual priority)

**Total time from trigger to fully settled:** ~1.5s

---

### Plan Selection Animation

**Trigger:** User taps a plan pill

**Sequence:**
1. Previously selected pill: amber fill fades out 250ms easeOut, text colour transitions to muted
2. Newly selected pill: amber fill fades in 250ms easeOut, text transitions to white
3. Detail card below pills: height animates (expand/collapse) 300ms easeOut, content crossfades
4. Trial timeline module:
   - If switching TO annual: slides in from bottom, 300ms easeOut (height: 0 → 80px)
   - If switching FROM annual: slides out upward, 250ms easeOut (height: 80px → 0)
5. CTA button text: current text fades out 150ms, new text fades in 150ms (sequential crossfade)
6. "Save 47%" badge on annual: if selecting annual for first time in session, small bounce scale(1.0 → 1.15 → 1.0) 400ms elasticOut

---

### CTA Button Press Animation

**Trigger:** User taps CTA button

**Sequence:**
1. Button scale: 1.0 → 0.97 over 80ms easeIn (tactile press feel)
2. Button scale: 0.97 → 1.0 over 120ms easeOut (release)
3. Amber fill: briefly brightens (+10% lightness) then returns
4. Haptic: medium impact (iOS) / VIRTUAL_KEY (Android)
5. Loading indicator: if async (subscription validation), button text replaced with spinner after 200ms

---

### "Start Free Trial" Tap — What Happens Next

**Trigger:** User confirms annual plan CTA

**Sequence:**
1. Button press animation (above)
2. OS-native subscription sheet appears (StoreKit / Play Billing)
3. On confirmation from OS sheet:
   - Modal dismisses: slides back down 400ms easeIn
   - Care card un-blurs: 300ms easeOut
   - **Celebration burst:** confetti/bubbles particle effect from top of care card, 1200ms duration, #F5A623 amber + #1B7A6E teal + white particles
   - Toast notification slides in from top: "✓ You're all set, [Name]! 7 days free." — **Nunito Bold 15px**, amber background, 3s auto-dismiss
   - Care card gets a subtle amber glow border pulse (2 pulses, 600ms each, elasticOut)
4. On cancellation from OS sheet: silently return to paywall, no guilt message

---

## 4. MULTIPLE ENTRY POINT VARIANTS

### Variant A — Post-Aha Moment (Primary)
**Trigger:** User adds first fish + care card loads  
**Personalisation:** Full — fish name/species in headline, species illustration in header  
**Emotional state:** Excited, hopeful, slightly anxious  
**Key message:** "You've made a great start. Here's everything you need to keep it that way."  
**Special element:** Care card visible and blurred behind the paywall (maintains context)  
**CTA:** "Start My Free 7-Day Trial"  
**Skip behaviour:** Soft dismiss, returns to care card  

---

### Variant B — Streak Milestone (Day 7)
**Trigger:** User completes 7-day login/care streak  
**Header:** Streak flame illustration (not fish) — amber flame with "7" inside  
**Headline:** "7 days strong. Don't let it end here."  
**Subheadline:** "Your streak is safe with Danio Pro — even if you miss a day."  
**Value props:** Replaced with streak-specific benefits:
- 🔥 **Streak protection** — Miss a day? We've got you covered.
- 📊 **Your tank history** — See every water change, every feeding, every win.
- 🏆 **Achievements that mean something** — Earn badges that actual fishkeepers care about.
- 🔔 **Smart reminders** — Never forget a care task again.

**Tone shift:** More urgency, but still warm. "You've built something worth protecting."  
**CTA:** "Protect My Streak"  
**Skip:** "I'll start again if I miss one" (self-deprecating, honest — NOT guilt-inducing)

---

### Variant C — Content Wall (Lesson 4+)
**Trigger:** User taps Lesson 4 or beyond in the learning path  
**Header:** Lock icon over a blurred lesson preview — they can see what's locked  
**Headline:** "Keep learning — your fish are counting on you."  
**Subheadline:** "Lessons 4+ cover water chemistry, disease diagnosis, and advanced care."  
**Value props:** Education-focused:
- 📚 **20+ expert lessons** — From beginner to confident fishkeeper in weeks.
- 🔬 **Water chemistry made simple** — Understand pH, ammonia, and nitrates without the jargon.
- 🩺 **Disease diagnosis guide** — Spot problems early. Act before it's too late.
- 🎓 **Species masterclasses** — Deep dives on your exact fish.

**Tone:** Curious, learner-focused. "You're asking the right questions."  
**CTA:** "Unlock All Lessons"  
**Skip:** "Maybe later"  
**Special:** Show a preview of Lesson 4's first card (blurred) as a teaser behind the paywall overlay

---

### Variant D — Species Encyclopedia (Locked Species)
**Trigger:** User taps a locked species in the encyclopedia  
**Header:** Blurred species card behind overlay — they can see the species name but not the content  
**Headline:** "Unlock the full guide for [Species Name]."  
**Subheadline:** "Everything you need to know before you buy — tank requirements, compatibility, common mistakes."  
**Value props:** Reference-focused:
- 🐠 **500+ species profiles** — Find any fish, any time.
- ⚠️ **Compatibility checker** — Know before you add. Avoid costly mistakes.
- 🛒 **Buyer's guide** — What to look for at the fish store. Red flags to avoid.
- 🌿 **Plant & invertebrate guides** — The full ecosystem, not just the fish.

**Tone:** Practical, research-oriented. "Do your homework — we've done it for you."  
**CTA:** "Unlock the Encyclopedia"  
**Skip:** "Maybe later"

---

## 5. WHAT TO AVOID

### Dark Patterns — Explicitly Excluded

| Pattern | Why it's excluded |
|---------|------------------|
| **Confirmshaming** — "No thanks, I want my fish to die" | Violates our warm, non-pushy tone. Fishkeepers are emotionally attached to their fish; mocking that is cruel. |
| **Fake countdown timers** — "Offer expires in 03:42" | We don't have time-limited pricing. Fake urgency destroys trust with our audience. |
| **Hidden subscription** — burying the billing date | We surface Day 7 billing proactively in the trial timeline. Trust is the product. |
| **Pre-ticked upgrade boxes** | Never pre-select annual "for" the user without making it obvious. We pre-highlight it, but the selection is visible and clear. |
| **Cancellation obstacles** — "Call to cancel" or multi-step cancellation | Cancel must be 2 taps max. If they leave, we want them to want to come back. |
| **Fake social proof** — "9,999 users love us!" with inflated numbers | Use real numbers. If we don't have them yet, use credible proxy stats. |
| **Guilt messaging on skip** — second dialog asking "are you sure?" | One tap = dismissed. No second dialog. No guilt. |
| **Disguised skip button** — tiny text, off-screen, low contrast to near-invisible | Skip link must be visible. Low contrast = subtle, not invisible. 14px minimum. |
| **Auto-enrolling in annual without confirmation** | Annual is pre-highlighted but the user must tap CTA + confirm OS sheet. Two explicit actions. |

---

### Language That Doesn't Fit the Fishkeeper Persona

**Avoid:**
- "Supercharge your fishkeeping" — too tech-startup, wrong vibe
- "Unlock your potential" — we're talking about fish, not productivity
- "Be a fish boss" — cringe, doesn't match caretaker identity
- "Don't miss out" — FOMO language, too pushy
- "Premium features" — generic, says nothing
- "Go Pro" — fine as a button label but overused; we prefer personalised copy
- "Your fish will thank you" — cute but overdone
- Any copy that implies the free tier is dangerous or harmful to the fish — we want free users to have a good experience too

**Use instead:**
- "The full care guide" (specific)
- "Less than a bag of fish food" (relatable, in-world)
- "Fishkeepers who..." (community framing)
- "Your [species/name]" (personalised, possessive — they're invested)
- "Keep it that way" (positive reinforcement, not fear)
- "Confident fishkeeper" (identity aspiration, not just product feature)

---

## Appendix: Design Tokens Reference

| Token | Value | Usage |
|-------|-------|-------|
| `color.primary` | `#F5A623` | CTA button, selected pills, badges, icons |
| `color.secondary` | `#1B7A6E` | Fish name text, secondary icons, trial nodes |
| `color.surface` | `#FFF8F0` | Modal background, pill row background |
| `color.surface.warm` | `#F5EDD8` | Pricing row background |
| `color.text.primary` | `#2C2C2C` | Headlines |
| `color.text.secondary` | `#666666` | Bullet subtitles |
| `color.text.muted` | `#A89880` | Skip link, timeline labels |
| `font.display` | `Lora Bold` | Fish name, price display |
| `font.heading` | `Nunito ExtraBold` | Headlines, CTA button |
| `font.body` | `Nunito Regular` | Subtitles, descriptions |
| `font.label` | `Nunito Bold` | Bullet titles, badges |
| `anim.spring` | `600ms elasticOut` | Fish illustration, CTA appear |
| `anim.tab` | `250ms easeOut` | Plan pill selection |
| `anim.modal` | `450ms cubic-bezier(0.34,1.56,0.64,1)` | Modal entry |
| `radius.button` | `16px` | CTA button |
| `radius.card` | `12px` | Pricing pills, detail card |

---

*Brief prepared by Apollo — Danio Design Sub-agent*  
*For implementation queries, refer to Hephaestus with this document.*
