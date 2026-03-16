# Danio — A/B Testing Roadmap
**Prepared by:** Prometheus (Research Sub-Agent)  
**Date:** 2026-03-16  
**Status:** Pre-launch roadmap — sequence matters more than speed

---

## Preamble: The Strategic Frame

Danio has three conversion funnels that matter:

```
Play Store listing → Install       (acquisition)
Install → Onboarding complete      (activation)
Onboarding complete → Paid         (monetisation)
```

Every test maps to exactly one funnel. Don't run tests across multiple funnels simultaneously — you won't know what moved the needle. Run sequentially by funnel: **acquisition first, then activation, then monetisation**.

At launch, traffic will be modest. This is the hard constraint that governs the entire roadmap. Tests that require 5,000+ users per variant should be deferred until you have the installs to support them. Underpowered tests are worse than no tests — they generate false confidence.

---

## Statistical Thresholds (Apply to All Tests)

| Parameter | Value |
|-----------|-------|
| Significance level | p < 0.05 (95% confidence) |
| Minimum detectable effect (MDE) | 20% relative lift (10% for paid conversion — rarer events need larger effects to be meaningful) |
| Power | 80% |
| Test type | Two-tailed (unless you have strong prior reason to use one-tailed) |
| **Call it done when:** | Significance reached AND minimum sample hit AND test ran ≥ 7 days |
| **Don't call it done when:** | You hit significance early (peeking bias — wait the full duration) |
| **Stop early only if:** | One variant is clearly harming a key metric (e.g. installs drop >40%) |

**Minimum sample size calculator baseline:**  
For a 5% baseline conversion rate, 20% relative lift (to 6%), 95% confidence, 80% power:  
→ ~3,800 users per variant (~7,600 total)

For a 2% baseline conversion rate (paid), 20% relative lift (to 2.4%), 95% confidence:  
→ ~9,500 users per variant (~19,000 total) — this is why monetisation tests run last

---

## Priority 1 — Screenshot 1 (Hero Shot)

**Test name:** Hero Shot Framing Test  
**Hypothesis:** A screenshot that leads with an emotional outcome ("your fish, thriving") will outperform a feature-demo screenshot, because users browsing the Play Store are emotionally driven — they want the feeling of being a confident fish keeper, not a feature list.

**Platform:** Google Play Store Experiments  
**Primary metric:** Install rate (store listing visits → installs)

### Variants
| | Variant A (Control) | Variant B |
|-|---------------------|-----------|
| **Image** | App UI screenshot showing the fish dashboard/home screen | Lifestyle-style shot: a beautiful planted tank with the app in the corner, headline overlay: *"Your fish. Thriving."* |
| **Overlay text** | None or feature-label (e.g. "Track feeding, water, health") | Outcome-focused: *"Learn fishkeeping. Keep fish alive."* |
| **Framing** | What the app looks like | What the app does for you |

**Minimum sample size:** 3,800 installs per variant (~7,600 total store visits required, assuming ~10% store listing → install baseline)  
**Recommended duration:** 14 days minimum (captures weekly patterns — weekend browsers behave differently)  
**Priority:** **#1 — Run this first.**

**Why first:** This is the highest-leverage test. Every downstream activation and monetisation metric is downstream of an install. If the hero shot lifts installs by even 15%, every other test benefits from a larger pool. Play Store Experiments also doesn't require any engineering work — zero dev cost, maximum impact.

---

## Priority 2 — Onboarding Length

**Test name:** Onboarding Trim Test  
**Hypothesis:** A shorter onboarding (5 screens) will produce higher completion rates and reach the aha moment (first fish added) faster. The Duolingo model works because it creates investment quickly — 10 screens before the first reward is friction, not value.

**Platform:** Firebase Remote Config  
**Primary metric:** Onboarding completion rate (% of users who reach "first fish added")

### Variants
| | Variant A (Control) | Variant B |
|-|---------------------|-----------|
| **Screen count** | 10 screens | 5 screens |
| **What's cut in B** | Remove: redundant permission explanations, extended "about fish" education, secondary feature tours | Keep: name input, fish selection, first care task, notification permission (post-lesson), one core value prop |
| **Time to aha moment** | ~3–4 minutes | ~90 seconds |

**Firebase instrumentation:**
```
logEvent("onboarding_screen_viewed", { screen_index: N, screen_name: "..." })
logEvent("onboarding_completed")
logEvent("first_fish_added")
```
Use Remote Config boolean `short_onboarding_enabled` to gate the variant.

**Minimum sample size:** 1,000 users per variant (onboarding completion rates are typically 40–70%, making this a high-signal test with smaller samples)  
**Recommended duration:** 10 days  
**Priority:** **#2 — Run immediately after the hero shot test closes.**

**Why second:** Activation is the make-or-break funnel at launch. Users who don't complete onboarding never reach the paywall. You need a high activation rate before monetisation tests can generate meaningful data.

---

## Priority 3 — Notification Permission Timing

**Test name:** Notification Opt-In Timing Test  
**Hypothesis:** Asking for notification permission after the user has experienced their first care reminder (post-first-lesson) will yield a higher opt-in rate than asking during onboarding, because the user has a concrete reason to say yes — they've just seen what they'd miss.

**Platform:** Firebase Remote Config  
**Primary metric:** Notification permission grant rate

### Variants
| | Variant A (Control) | Variant B |
|-|---------------------|-----------|
| **Timing** | Screen 7 of onboarding (before any engagement) | Immediately after first fish added + first care task completed |
| **Context** | Generic: "Allow notifications to get reminders" | Contextual: "Mochi's next feeding is in 6 hours. Get a reminder?" |
| **Framing** | Feature-first | Value-first, fish-specific |

**Firebase instrumentation:**
```
logEvent("notification_permission_prompt_shown", { timing: "onboarding" | "post_lesson" })
logEvent("notification_permission_granted")
logEvent("notification_permission_denied")
```

**Minimum sample size:** 1,000 users per variant  
**Recommended duration:** 10 days  
**Priority:** **#3**

**Why third:** Notification opt-in directly impacts long-term retention and DAU, which in turn feeds paid conversion. But it's only meaningful to test after the onboarding is optimised — otherwise you're measuring timing against a broken onboarding flow.

---

## Priority 4 — Paywall Headline

**Test name:** Paywall Personalisation Test  
**Hypothesis:** A personalised headline referencing the user's fish species will convert better than a generic premium pitch, because it ties the value of paying to something the user already cares about.

**Platform:** Firebase Remote Config  
**Primary metric:** Paywall → trial start rate (subscription_started event)

### Variants
| | Variant A (Control) | Variant B |
|-|---------------------|-----------|
| **Headline** | *"Unlock Premium Fishkeeping"* | *"Give [Fish Name] the best care possible"* (e.g. "Give Mochi the best care possible") |
| **Subhead** | *"Advanced care plans, health tracking, and more"* | *"Advanced care plans built for [species] — and every fish that follows"* |
| **Personalisation source** | None | First fish name + species from Firestore user profile |

**Firebase instrumentation:**
```
logEvent("paywall_viewed", { headline_variant: "generic" | "personalised", fish_name: "...", fish_species: "..." })
logEvent("subscription_started", { plan: "annual" | "monthly", headline_variant: "..." })
```

**Minimum sample size:** 500 users per variant who *reach the paywall* (not total users)  
**Recommended duration:** 21 days (paid conversion is rare — needs more time to accumulate)  
**Priority:** **#4 — Only run after activation is optimised.**

---

## Priority 5 — Paywall CTA

**Test name:** CTA Friction Test  
**Hypothesis:** A CTA that names the action and removes ambiguity ("Start My Free 7-Day Trial") will outperform alternatives because it's clear that no immediate charge occurs.

**Platform:** Firebase Remote Config  
**Primary metric:** CTA tap rate on paywall screen

### Variants
| | Variant A (Control) | Variant B | Variant C |
|-|---------------------|-----------|-----------|
| **CTA text** | *"Start My Free 7-Day Trial"* | *"Try Premium Free"* | *"Unlock Premium — Free for 7 Days"* |
| **Secondary text** | *"Cancel anytime"* | *"No charge for 7 days"* | *"Cancel anytime. No commitments."* |

**Note:** This is a 3-way test. Requires ~750 paywall viewers per variant (~2,250 total). At early traffic levels, reduce to 2 variants only (A vs B).

**Firebase instrumentation:**
```
logEvent("paywall_cta_tapped", { cta_variant: "A" | "B" | "C" })
```

**Minimum sample size:** 750 paywall views per variant  
**Recommended duration:** 21 days  
**Priority:** **#5**

---

## Priority 6 — Free Trial Framing

**Test name:** Trial Copy Framing Test  
**Hypothesis:** Micro-copy differences in how a free trial is framed ("7-day free trial" vs "Try free for a week") can affect conversion even when the underlying offer is identical — because "a week" feels longer and less clinical than "7 days".

**Platform:** Firebase Remote Config  
**Primary metric:** Trial start rate (subscription_started where trial=true)

### Variants
| | Variant A (Control) | Variant B |
|-|---------------------|-----------|
| **Primary framing** | *"7-day free trial"* | *"Try free for a week"* |
| **Usage** | Paywall header, CTA label, confirmation screen | Same placements |
| **Psychological angle** | Clinical / specific | Casual / approachable |

**Minimum sample size:** 750 paywall views per variant  
**Recommended duration:** 21 days  
**Priority:** **#6 — Low priority at launch. See "What NOT to A/B Test" notes below.**

---

## Priority 7 — Streak Mechanic Framing

**Test name:** Streak Identity Test  
**Hypothesis:** "Care streak" framing will drive higher DAU among existing users than "learning streak" because Danio is fundamentally about fish welfare, not education — the framing should reinforce what users are actually doing (caring for fish) not a secondary activity (learning).

**Platform:** Firebase Remote Config  
**Primary metric:** D7 retention (users with streak active at Day 7)

### Variants
| | Variant A (Control) | Variant B |
|-|---------------------|-----------|
| **Streak label** | *"Learning Streak"* | *"Care Streak"* |
| **Streak broken message** | *"Your learning streak ended"* | *"Your fish missed you"* |
| **Streak maintained message** | *"Keep learning every day!"* | *"Mochi appreciates you"* |

**Firebase instrumentation:**
```
logEvent("streak_shown", { framing: "learning" | "care", current_streak: N })
logEvent("streak_maintained")
logEvent("streak_broken")
```

**Minimum sample size:** 1,000 users per variant, tracked for D7 retention  
**Recommended duration:** 14 days (to observe D7 retention)  
**Priority:** **#7 — Run once DAU is stable enough to measure retention meaningfully.**

---

## What NOT to A/B Test at Launch

These tests are tempting but will be underpowered or inconclusive at early traffic volumes. Defer until post-launch growth.

### 1. Monthly vs Annual pricing ($3.99/mo vs $24.99/yr display)
**Why not:** Paid conversion rates are inherently low (1–3%). To detect a 20% relative lift on a 2% base rate, you need ~19,000 users per variant. At launch, you won't hit this for weeks. A false negative here could cause you to kill a pricing structure that actually works.

### 2. App icon variants
**Why not:** Icon A/B tests on Play Store require significant impression volume to reach significance. You'd need ~50,000–100,000 store listing visits for meaningful data. This is a post-scale test.

### 3. Paywall timing (immediately vs after 3 sessions)
**Why not:** This requires longitudinal tracking (cohort analysis over multiple sessions) and enough users completing multiple sessions to compare. At launch, your Day-3 cohort will be too small. Instrument it, but don't call it a test — use it for qualitative insight only.

### 4. Feature ordering in onboarding (water testing first vs feeding first vs health first)
**Why not:** Three-way test on a low-volume funnel. Each variant needs ~1,000 completions. If you're getting 100 installs/day at launch, this test takes 30+ days per variant. Too slow to be useful. Pick the best ordering based on user research or first-principles logic, ship it, and revisit post-scale.

**The rule:** If reaching minimum sample size takes more than 4 weeks at projected traffic, don't start the test. Log it in the backlog and revisit at 10x traffic.

---

## Firebase Instrumentation Guide

### Remote Config setup
All in-app test variants are gated via Remote Config boolean or string parameters:

```dart
// Fetch on app start, cache for 12 hours
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.setConfigSettings(RemoteConfigSettings(
  fetchTimeout: const Duration(minutes: 1),
  minimumFetchInterval: const Duration(hours: 12),
));
await remoteConfig.fetchAndActivate();

// Example usage
final shortOnboarding = remoteConfig.getBool('short_onboarding_enabled');
final paywallHeadline = remoteConfig.getString('paywall_headline_variant'); // 'generic' | 'personalised'
```

### Mandatory event schema
Every test must log variant exposure on first view:

```dart
FirebaseAnalytics.instance.logEvent(
  name: 'ab_test_exposure',
  parameters: {
    'test_name': 'onboarding_length',
    'variant': 'short', // or 'control'
    'user_id': currentUser.uid,
  },
);
```

### Existing 6 events — map to tests

| Existing event | Maps to test |
|---------------|-------------|
| `onboarding_started` | Onboarding Length (baseline denominator) |
| `onboarding_completed` | Onboarding Length (primary metric numerator) |
| `first_fish_added` | Onboarding Length (aha moment proxy) |
| `paywall_viewed` | Paywall Headline, CTA, Trial Framing |
| `subscription_started` | All monetisation tests |
| `notification_permission_result` | Notification Timing |

**Gap to fill:** Add `streak_shown` and `streak_maintained` events for the Streak Framing test. These don't exist yet.

---

## Launch Sequence — What to Run and When

```
WEEK 1–2  │  TEST #1: Hero Shot (Play Store Experiments — no dev work)
           │  Parallel: instrument Remote Config, add missing events
           │
WEEK 3–4  │  TEST #2: Onboarding Length (close Hero Shot, run Onboarding)
           │  Requires: short_onboarding_enabled Remote Config param
           │
WEEK 5–6  │  TEST #3: Notification Timing (close Onboarding, run Notification)
           │
WEEK 7–8  │  TEST #4: Paywall Headline (monetisation phase begins)
           │  (only if activation rate is ≥ 50% from Test #2 improvements)
           │
WEEK 9–10 │  TEST #5: Paywall CTA (close Paywall Headline)
           │
WEEK 11+  │  TEST #6: Streak Framing (retention-phase test, needs stable DAU)
           │  TEST #7: Trial Framing (if still getting to it — defer if paywall
           │           tests are already conclusive)
```

**Key sequencing rule:** Never run two tests that touch the same user journey simultaneously. A user who sees both a short onboarding AND a personalised paywall headline makes it impossible to attribute the conversion lift to either change.

**Exception:** Hero Shot (Play Store, pre-install) can run simultaneously with any in-app test, since they affect different stages of the funnel and different users.

---

## When to Call a Test Done

A test is **conclusive** when ALL of the following are true:
1. ✅ p < 0.05 (95% statistical significance) in the correct direction
2. ✅ Minimum sample size per variant reached
3. ✅ Test has run for ≥ 7 days (minimum) to capture weekly cycles
4. ✅ The winning lift is ≥ 20% relative (or ≥ 10% for monetisation tests) — below this, the effect may not be worth the maintenance complexity of the winner

A test is **inconclusive** when:
- Sample size reached but p > 0.05 → declare no significant difference, roll back to control, move on
- Test ran 4 weeks with p hovering around 0.1–0.15 → probably no meaningful effect, close it

A test is a **negative result** when:
- Variant B significantly *underperforms* control → this is still valuable data. Document why. Don't ship B.

**Ship the winner within 48 hours of calling the test done.** Decisions that sit for weeks accumulate opportunity cost.

---

## Backlog (Not Prioritised — Run Post-Scale)

- App icon variants (needs 50k+ store visits)
- Paywall timing (session 1 vs session 3)
- Monthly/annual price prominence
- Fish species suggestion algorithm (onboarding recommendation)
- Email capture opt-in framing (if email becomes part of funnel)
- In-app review prompt timing

---

*Last updated: 2026-03-16 by Prometheus*
