# Danio — Master Research File
**Compiled by Athena — Mount Olympus**
**Last updated:** 2026-03-16 06:00 GMT
**Status:** LIVE — agents still running (5 more reports incoming)

> This file is the single source of truth for all research on Danio.
> Sections are updated as new agent reports land.

---

## TABLE OF CONTENTS

1. [Strategic Position](#1-strategic-position)
2. [Onboarding — Artemis Audit](#2-onboarding--artemis-audit)
3. [Visual Design — Apollo Brief](#3-visual-design--apollo-brief)
4. [ASO & Launch Strategy — Aphrodite](#4-aso--launch-strategy--aphrodite)
5. [User Psychology & Retention — Dionysus](#5-user-psychology--retention--dionysus)
6. [Repo & Content Audit — Argus](#6-repo--content-audit--argus) ⏳
7. [Paywall Strategy — Aphrodite](#7-paywall-strategy--aphrodite) ⏳
8. [UK Launch — Prometheus](#8-uk-launch--prometheus) ⏳
9. [Notification Sequence — Dionysus](#9-notification-sequence--dionysus) ⏳
10. [Competitive Matrix — Prometheus](#10-competitive-matrix--prometheus) ⏳
11. [Compliance — Themis](#11-compliance--themis) ⏳
12. [Production Roadmap](#12-production-roadmap)
13. [Open Questions & Gaps](#13-open-questions--gaps)

---

## 1. STRATEGIC POSITION

**The one-liner:** "Duolingo for Fishkeeping" — a genuinely unclaimed position.

### The Blue Ocean
No current competitor owns the educational + gamified space in fishkeeping:
- **Fishkeeper (Maidenhead Aquatics):** tank management only, no learning, no gamification
- **AquaBuildr:** tank planning/tracking, no education
- **Fishi:** community + species DB, no structured learning
- **Aquarium Fish (soft24hours):** static species encyclopedia, no interactivity

Danio's unclaimed keywords: "learn fishkeeping", "fish quiz", "fish lessons" — low competition, high intent.

### Danio's Core Identity
- **What it is:** Duolingo-style gamified fishkeeping education + virtual aquarium
- **Target user:** 18–40, passion hobby on a budget ($0–50/mo spend), collector × caretaker × scientist mindset
- **Core anxiety of the user:** killing fish through ignorance — they want *confidence*, not just information
- **Differentiator:** The only app that makes learning fishkeeping genuinely fun
- **Aesthetic:** "Golden Hour" — warm amber/golden, animated fish, NanaBanana room backgrounds

### The North Star
Pull the Tank tab's visual identity through every screen. Make Danio look like a professional, branded piece of software. Every room has a personality. NanaBanana backgrounds (swappable) + Flutter elements (fixed).

---

## 2. ONBOARDING — ARTEMIS AUDIT

**Source:** `danio/ARTEMIS_ONBOARDING_AUDIT.md` (filed separately)
**Filed:** 2026-03-16

### The Headline Finding
**The good stuff already exists — it's just dead code.** A full Duolingo-style flow (placement test, learning style screen, tutorial with tank creation) is completely unreachable from the live onboarding. The live flow is 3 slides + 2 questions + drop into the app.

### The 5 Biggest Problems

1. **No aha moment** — user reads slides but never *touches* the product. No lesson, no tank, no AI. They land on Learn tab with a SnackBar that disappears in 4 seconds.

2. **No tank created during onboarding** — user hits home with "Your aquarium adventure starts here." Cold empty state.

3. **Personalisation data collected but never used** — experience level and tank status don't change what any screen shows. Beginner = expert. Wasted data.

4. **No push notification permission requested** — streak notifications can't fire. Permission exists in the orphaned flow, not the live one.

5. **Second launch is completely cold** — no "welcome back," no streak nudge. Just opens on Tab 0.

### Recommended 60-Second Onboarding Flow
```
Single slide → personalisation (2 taps) → immediate micro-lesson
("The #1 Beginner Mistake") → XP animation + first achievement
→ "Add your tank / try demo tank" → in the app with context
```

**Core principle:** The aha moment must be *doing*, not reading.

### Key Insight
The aha moment should be: *"This app actually knows about my specific fish."*
Trigger it by: user adds first fish species → instantly sees personalised pH requirements, compatibility warnings, care tips for *that exact species*.

---

## 3. VISUAL DESIGN — APOLLO BRIEF

**Source:** `danio/DESIGN_BRIEF_APOLLO.md`
**Filed:** 2026-03-16

### Quick Reference Card
```
FONTS:    Nunito (headers/UI) + Lora (body/content)
PRIMARY:  #F5A623 Amber Glow
SECONDARY:#1B7A6E Deep Teal
SURFACE:  #FFF8F0 Warm Cream (light) / #251A0D Dark Oak (dark)
TEXT:     #2C1E0F (light) / #F5E9D5 (dark)
SHADOWS:  Color(0x33C97A0C) warm amber at 20% opacity
RADIUS:   Cards 16dp | Buttons 24dp | Chips 20dp
ANIM:     Tabs 250ms easeOut | Micro 100-200ms | Rewards 600ms elasticOut
```

### Typography
- **Nunito** (headers/UI) — rounded warmth, friendly, Duolingo-adjacent without copying
- **Lora** (body/content) — serif credibility, "reading a nature book"
- Never: Roboto, Open Sans (too cold/corporate)

### Room-by-Room Design Brief

| Tab | Room | Atmosphere |
|-----|------|------------|
| 🐠 Tank | Living Room | Preserve as-is — this is the benchmark. Don't touch it. |
| 📚 Learn | Study/Library | Index card surfaces, Lora body text, warm desk lamp |
| 🎯 Practice | Studio | Energetic, animation-heavy, score floaters + shimmer |
| 🔬 Smart AI | Naturalist's Lab | Teal accent prominent, specimen-reveal animations |
| ⚙️ Settings | Hallway | Clean, warm, still Danio's personality |

### Top 5 "Cheap" Traps to Avoid
1. Cold grey defaults (Flutter defaults are cool-grey — override everything)
2. Mismatched animation speeds
3. Generic card stacks (white/grey cards with rounded corners and shadow)
4. Flat colour backgrounds (NanaBanana rooms ARE the aesthetic)
5. Over-animating the aquarium

### Animation Standards
| Type | Duration | Curve |
|------|----------|-------|
| Tab switch | 250ms | easeOut |
| Micro (buttons) | 100–200ms | easeOut |
| Rewards/achievements | 600ms | elasticOut |
| Correct answer | 200ms | easeOut (golden shimmer) |
| Wrong answer | 300ms | custom shake |

### Material You Seed
```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFFF5A623),
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity, // preserves amber character
)
```

---

## 4. ASO & LAUNCH STRATEGY — APHRODITE

**Source:** `danio/APHRODITE_ASO_LAUNCH.md` (filed separately)
**Filed:** 2026-03-16

### Store Listing

**Title:** `Danio: Learn Fishkeeping & Fish Care`
**Short description:** `Gamified fishkeeping lessons, quizzes & your virtual aquarium 🐠`

**Top 20 Keywords (ranked):**
1. aquarium app (high volume)
2. fishkeeping (medium — core identity)
3. fish care (high volume)
4. fish tank app (high)
5. learn fishkeeping (low-medium — **Danio can own this**)
6. fish quiz (medium — **Danio can rank #1**)
7. tropical fish guide (medium)
8. aquarium beginner (medium)
9. fish species identifier (medium)
10. aquarium maintenance (medium)

**Keyword strategy:** Own "learn fishkeeping" and "fish quiz" from day one — low competition, high intent, unclaimed.

### Screenshot Order (7 portraits, 1080×1920)
1. Lesson in progress — hero shot (XP bar filling, streak visible)
2. Streak + XP level-up animation
3. Lesson card mid-completion
4. Species discovery (Neon Tetra, Betta, Guppy)
5. Virtual aquarium showing progression
6. Achievement grid
7. Beginner CTA / social proof

**Rule:** First screenshot must work as standalone billboard in search results.

### Monetisation
| Tier | Price | Notes |
|------|-------|-------|
| Free | — | First 3 lesson units (~30 lessons), 20 fish, basic aquarium |
| **Danio Plus Monthly** | **$3.99/mo** | Below Duolingo ($6.99) |
| **Danio Plus Annual** | **$24.99/yr** | Push this as the default highlighted option |
| Lifetime | $49.99 | Capture power users, early cash flow |

### Launch Sequence
**Week -2:** Closed beta (20-30 fishkeeping community members), landing page, influencer DMs
**Week -1:** TikTok/Reels ("I made Duolingo for fishkeeping"), YouTube outreach
**Week 1:** Authentic r/Aquariums builder post (3.5M members), r/fishtank, r/bettafish, r/PlantedTank. Product Hunt Tuesday-Thursday.
**Week 2:** First week update post, indie dev crosspost (r/androiddev), influencer follow-ups
**Week 3:** Content loop (fishkeeping tips, "Did you know?" shareable posts)
**Week 4:** Play Store analytics review, A/B test screenshot 1

### Top Communities
| Platform | Target | Size |
|----------|--------|------|
| Reddit | r/Aquariums | ~3.5M |
| Reddit | r/fishtank | ~500K |
| Reddit | r/bettafish | ~400K |
| Reddit | r/PlantedTank | ~400K |
| Facebook | Tropical Fish Hobbyists | 300K+ |
| Facebook | Freshwater Aquarium Advice | 200K+ |
| Forum | Fishlore.com | Active, beginner-friendly |

---

## 5. USER PSYCHOLOGY & RETENTION — DIONYSUS

**Source:** `danio/DIONYSUS_USER_PSYCHOLOGY.md` (filed separately)
**Filed:** 2026-03-16

### Who the Danio User Is
- **Age:** Mostly 18–40 (millennial/Gen Z), meaningful 40–65 tail
- **Spending:** 68.8% spend $0–50/month — passion hobby on a budget
- **Mindset:** Collector × caretaker × scientist. Same psychology as Pokémon GO, planted terrariums, miniature painting.
- **Core anxiety:** Killing fish through ignorance. They want *confidence*.
- **What they want emotionally:** Validation, discovery, pride, safety net, belonging.

### Top 10 Psychological Hooks

1. **"Good Fishkeeper" Identity Loop** — shift from "I use Danio" to "I am a fishkeeper." Achievement titles, mastery tiers, language that treats users as experts. Identity habits are 3× stickier.

2. **Streaks done right** — tie to actual tank care (water change reminders, feeding logs), not arbitrary opens. "Care for your fish" not "do your homework."

3. **Variable rewards via discovery** — "Today's species spotlight," personalised care insights ("Your neon tetras prefer 6.5 pH — is your tank within that range?"). Ethical variable reward = genuine surprise.

4. **Endowed Progress Effect** — show how far they've come. Pre-filled progress. "You've kept fish for 47 days." Counter from Day 1 (credit them for what they've already done).

5. **Emotional attachment via care mechanics** — fish log becomes irreplaceable. Churning = losing their journal. Use warm empathetic language when fish die.

6. **Competence loops (IKEA Effect)** — let users build their own compatibility charts, contribute notes, customise tank profile. Knowledge they helped construct is stickier.

7. **Social proof without social pressure** — "4,823 Danio users keep neon tetras." Belonging without threat. Fishkeepers are NOT competitive — leaderboards demotivate the majority.

8. **Quick wins in onboarding** — aha moment within 3 minutes. "This app knows about my specific fish." Add first fish → see personalised care data instantly.

9. **Contextual notifications (not spam)** — care reminders that serve actual fishkeeping needs. Never: generic "Come back!" pressure. After 3 days no response: pause.

10. **Beautiful default state** — visual-first. The tank growing as they log = emotional investment. Make sharing feel like showing off art, not data.

### Retention Risk Factors
1. **Inaccuracy** — one bad compatibility recommendation = permanent trust destruction
2. **Empty shelf** — users run out of content and bounce (content depth unknown — Argus auditing)
3. **Generic content** — fishkeepers want species-specific advice, not "keep water clean"
4. **Notification fatigue** — once notifications are off, retention collapses
5. **Day 7 cliff** — universal to all habit apps. Novelty fades, habit not yet automatic.
6. **No visible progress at Day 30** — if app feels same as Day 1, users leave

### Re-engagement Sequence
| Silence | Message |
|---------|---------|
| Day 1–2 | Soft reminder — "[Species] is due for a water check" |
| Day 3 | Discovery hook — species fact about their fish |
| Day 7+ | Warm non-judgmental re-entry, no streak guilt |
| Day 14+ | Go silent. Don't burn the channel. |

**"Care Continuity"** replaces punitive streaks — no "you broke your streak" language. Fits caretaker personality.

### Social Features: Build vs Skip

**Build at launch:**
- Shareable tank profile card (beautiful, like showing off art)
- Community care notes per species (self-reinforcing — better with more users)
- Care milestone shareable cards ("I've kept my bettas alive for 1 year 🎉 via Danio")

**Skip for now:**
- ❌ Public leaderboards (demotivates majority of fishkeepers)
- ❌ Direct messaging / forums (Reddit already owns this — don't compete)
- ❌ Friends/followers (needs 50K+ MAU, creates empty graph anxiety at launch)

---

## 6. REPO & CONTENT AUDIT — ARGUS

**Status:** ✅ Complete (5 reports)

*Known from prior Argus gamification audit (partial):*

### Gamification P0 Bugs (achievements permanently broken)
- `perfectionist` — missing `perfectScoreCount` field, counter logic broken
- `speed_demon` — tracking estimated duration not actual elapsed time
- `comeback` — `lastActivityDate` never populated in `checkAfterLesson()`
- `completionist` — hidden achievements counted in total, gate unreachable
- `checkAfterReview()` — not wired into spaced repetition screen (12+ dead achievements)

### Gamification P1
- XP cap at 2,500 — hits max in ~50 lessons. Needs 10,000+ for meaningful progression.
- Streak/achievement bonus XP not routed through `weeklyXP` — invisible to leagues.

*Full content depth count and quality audit: pending Argus report.*

---

## 7. PAYWALL STRATEGY — APHRODITE

**Status:** ✅ Complete — `danio/APHRODITE_PAYWALL_STRATEGY.md`
**Filed:** 2026-03-16

### Top 5 Recommendations

1. **Paywall immediately after the aha moment** — user adds first fish → personalised care card appears → 2-second beat → paywall. Apps that moved to post-aha placement (Greg, Rootd, PhotoRoom) saw 5× conversion increases. Don't wait for a content wall.

2. **Feature gates, not usage caps** — lock *capabilities* (full care guides, disease diagnosis, water chemistry tracking, unlimited fish profiles) rather than counting uses. Mental model shifts from "you hit a wall" to "you can unlock more." Greg's pivot from usage-limits to feature-gates drove its 5× jump.

3. **7-day free trial on annual plan** — 7-day trials convert at ~45% vs ~30% for ≤4-day trials. Trials longer than 7 days add no meaningful lift. Show a timeline module (Day 0 / Day 5 reminder / Day 7 billing). Frame annual as "less than a bag of fish food per month" ($2.08/mo).

4. **Personalise paywall copy to the fish they just added** — don't show generic "Upgrade to Pro." Show: *"Get the full care guide for your Betta — feeding schedule, disease prevention, compatible tank mates."* Copy that mirrors the user's exact situation converts significantly better.

5. **Multiple paywall entry points** — Duolingo uses 7+ touchpoints per session. Surface upgrade prompts at: streak milestones ("Protect your 7-day streak"), species encyclopedia, locked aquarium species, after lessons. Persistent "Pro" badge on locked areas — not a modal every time.

---

## 8. UK LAUNCH — PROMETHEUS

**Status:** ✅ Complete — `danio/PROMETHEUS_UK_LAUNCH.md`
**Filed:** 2026-03-16

### Top 7 UK Recommendations

1. **Launch in January (post-Christmas surge)** — "Just got a fish tank for Christmas" is a real UK phenomenon. January = highest-traffic moment for beginner fishkeeping queries. Catch them before they make the classic mistakes.

2. **Email Practical Fishkeeping magazine now** — Britain's best-selling fishkeeping publication. They love UK indie developer stories. "UK dev builds Duolingo for fishkeeping" = natural feature. Far easier press access than any US outlet.

3. **en-GB Play Store listing (separate from en-US)** — Google Play supports `en-GB` as a distinct locale. British English (colour, behaviour), £ in screenshots, UK species. UK users notice American English. Most apps skip this — it's a free differentiator.

4. **Price at £2.99/mo and £19.99/yr** — Duolingo UK is £4.99–£6.49/mo. Danio at £2.99 = "less than a coffee." £19.99/yr = "less than a bag of fish food per year" (under the psychological £20 barrier). Consider £9.99 lifetime for first 500 users to seed enthusiasts. Google handles VAT collection.

5. **Partner with Maidenhead Aquatics (130+ UK stores)** — #1 voted UK retailer (PFK 2025 Readers' Poll). They sell fish; Danio teaches people to keep them — zero competitive conflict. QR code cards with every fish purchase = acquisition at the exact moment of need.

6. **"UK developer" as core identity** — In UK communities this is practically a get-out-of-spam-free card. Include UK water hardness regional variation, stock UK LFS species, reference UK retailers. Be visibly, authentically UK before any US competitor thinks to be.

7. **Outreach to George Farmer + MD Fish Tanks** — George Farmer (~100K subs, writes for PFK, UK aquascaping) and MD Fish Tanks (~200K+ subs, beginner-friendly, UK-based). A single mention from either = thousands of relevant UK downloads.

---

## 9. NOTIFICATION SEQUENCE — DIONYSUS

**Status:** ✅ Complete — `danio/DIONYSUS_NOTIFICATION_SEQUENCE.md`
**Filed:** 2026-03-16

60+ notifications across all phases. Includes dynamic variable fallbacks, timing windows, send frequency by phase, and a banned word list. Ready for implementation.

### Standout Notifications

| Day | Title | Body | Type |
|-----|-------|------|------|
| Day 2 | "Your betta is watching you" | Bettas recognise their owners' faces. Yours probably knows you already. | DISCOVERY |
| Day 4 | "You've checked in 3 days in a row" | That's the kind of consistency healthy fish are built on. Quietly impressive. | IDENTITY |
| Day 10 | "10 days in. That's real care." | Most new aquarists give up by now. You're still here. Your fish noticed. | IDENTITY |
| Day 14 | "Two weeks of consistent care 💙" | Fourteen days. Your tank is stable. Your fish is thriving. That's you. | MILESTONE |
| Day 20 | "You think like an aquarist now" | Water chemistry, behaviour, schedules — this is second nature to you. | IDENTITY |
| Day 26 | "[Species] keepers are a rare breed" | Only 8% of Danio users keep [species]. You're in a niche club. | SOCIAL_PROOF |
| Day 30 | "30 days. You really did that. 🏆" | A whole month of consistent care. That's not luck — that's who you are now. | MILESTONE |
| First fish | "[Fish name] is officially in your care 🐟" | First fish logged. Your aquarium journey just became real. | SPECIAL |
| 7d silence | "[Fish name] misses the attention 🐠" | A week away — totally fine. Come back when you're ready. We kept your data. | RE_ENGAGEMENT |
| 14d silence | "Still here when you're ready" | Life gets busy. Your fishkeeping journey picks up right where you left it. | RE_ENGAGEMENT |

---

## 10. COMPETITIVE MATRIX — PROMETHEUS

**Status:** ✅ Complete — `danio/PROMETHEUS_COMPETITOR_MATRIX.md`
**Filed:** 2026-03-16

### What Competitors Have That Danio Is Missing
1. **Community/social feed** — AquaBuildr has nested comments + social. Stickiness gap.
2. **In-store barcode scanning** — Fishkeeper lets users scan fish labels at point of purchase. Friction-free acquisition moment.
3. **Offline mode** — Aquarium Fish (100K+ downloads) is offline-first. Fishkeeping decisions happen in stores with patchy WiFi.
4. **Fish ID from photo** — Aquarium Fish added AI photo search; Fishelly building it. Danio's Smart AI tab is the perfect home — needs to ship before competitors own it.
5. **Disease diagnosis** — Aquarium Fish and Fishelly surface this. Danio has species data but doesn't feature it prominently.

### Danio's 3 Defensible Moats

**1. Gamified Learning Architecture** — Zero competitors use any gamification mechanic. Not even a badge. After surveying all 6 competitors and fishkeeping forums. This requires curriculum design expertise, not just dev time. First-mover who ships this and gets retention data owns it permanently.

**2. Animated Aquarium as Emotional Core** — Every competitor is a maintenance tool. Danio is an *experience*. Emotional attachment that no list-and-graph app can replicate. Competitors would have to tear down and rebuild to match.

**3. "Duolingo for Fishkeeping" Positioning** — Nobody has claimed the daily-learning habit model for fishkeeping. Once you own this through brand recognition + app store presence + community word-of-mouth, it becomes self-reinforcing. The first mover wins the category.

---

## 11. COMPLIANCE — THEMIS

**Status:** ⏳ Queued — spawns after Argus repo audit lands

*Will cover:*
- GDPR compliance (Tiarnan is UK-based, EU users)
- Data collection consent requirements
- COPPA (any under-13 users in the fishkeeping audience?)
- Privacy policy adequacy review
- Play Store policy compliance
- Notification permission flows

---

## 12. PRODUCTION ROADMAP

**Source:** `prd/danio-production-roadmap.md`
**Created:** 2026-03-16 05:38 GMT

### Sprint Order
| Sprint | Focus | Risk |
|--------|-------|------|
| 1 | Design system + font decision | Low |
| 2 | Learn tab NanaBanana image + Flutter elements | Low |
| 3 | Tank header icons enlarged + nav bar modernised | Low |
| 4 | Smart AI tab layout polish | Low |
| 5 | Gamification P0 bug fixes | Medium |
| 6 | Custom icons throughout | Medium |
| 7 | Education content audit + copy polish | Low |
| 8 | Global symmetry/alignment pass | Low |
| 9 | Test suites | Medium |
| 10 | Monetisation implementation | High |
| 11 | Store screenshots + signed AAB + submission | Low |

### Non-Negotiable Principles
1. Cosmetic changes only — no refactors, no structural changes
2. Every button, feature, and flow keeps working
3. Test before and after every sprint
4. The tank tab is the bar — every screen should feel as polished
5. No AI-generated feel — custom icons, proper copy, real personality
6. Each room has a personality — NanaBanana bg (swappable) + Flutter elements (fixed)

---

## 13. OPEN QUESTIONS & GAPS

### All Answered ✅
- ✅ Competitive landscape — Prometheus competitor matrix
- ✅ Positioning — "Duolingo for Fishkeeping" confirmed blue ocean
- ✅ Who is the user — Dionysus psychology report
- ✅ Design system — Apollo full brief
- ✅ ASO keywords — Aphrodite, own "learn fishkeeping" + "fish quiz"
- ✅ Pricing — $3.99/mo, $24.99/yr, RevenueCat for billing
- ✅ Onboarding problems + rewrite spec — Artemis (2 reports)
- ✅ Paywall placement + design — Aphrodite + Apollo
- ✅ UK launch strategy + pricing — Prometheus
- ✅ Notification sequence — Dionysus (60+ notifications)
- ✅ Content depth — 32 solid days, 50 if stubs completed
- ✅ Content quality — 7 factual errors, Betta tank size is worst
- ✅ Species count — 121 species
- ✅ Achievements — 55 total, 4 broken + 1 cascading (completionist unreachable)
- ✅ Navigation/dead code — 9 orphaned screens, old onboarding path still live
- ✅ Data collection + Firebase — Analytics + Crashlytics, 6 events, Supabase placeholder
- ✅ Notifications — in dead code, not live onboarding
- ✅ Store readiness — 2 blockers (SCHEDULE_EXACT_ALARM, OpenAI key guarantee)
- ✅ Accessibility — 63% screens unannoted, WCAG contrast failures
- ✅ Compliance — 7 GDPR/Play Store blockers, Firebase consent most critical
- ✅ Master fix list — 24 tasks (13 P0, 8 P1, 3 P2)
- ✅ A/B test roadmap — start with screenshot 1
- ✅ Post-launch monitoring — D7 retention target ≥15%
- ✅ PR/press outreach — r/Aquariums is the #1 lever
- ✅ Screenshot brief — store_screenshots.sh needs to be written from scratch
- ✅ Heartbeat bug — fixed in AGENTS.md (sub-agents must IGNORE polls, not reply)

### Remaining Open
- Test suite strategy (unit/widget/integration — which first?)
- Content expansion roadmap (completing 18 stubs — who writes them?)

---

*This file is updated as each agent delivers. For the full detailed reports, see individual files in `danio/`.*
*Next update: when Argus, Aphrodite paywall, Prometheus UK + competitor, and Dionysus notifications land.*
