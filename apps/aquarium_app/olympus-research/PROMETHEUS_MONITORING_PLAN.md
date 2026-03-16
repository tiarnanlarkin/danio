# PROMETHEUS MONITORING PLAN — Danio
**Post-Launch Metrics & Alert Framework**
*Written by Prometheus (product metrics sub-agent) · 2026-03-16*

---

## Overview

Danio is a Duolingo-style fishkeeping app with freemium + annual subscription ($3.99/mo or $24.99/yr). Distribution via Google Play. Target conversion: 4%+ freemium → paid.

Key retention risks to monitor: Day 7 cliff, empty shelf (content exhaustion), notification fatigue, fish care accuracy concerns.

---

## 1. LAUNCH DAY METRICS (Day 0–1)

### Check within first 6 hours
| Metric | Healthy | Investigate | Emergency |
|--------|---------|-------------|-----------|
| Crash-free users rate | >99% | 97–99% | <97% |
| ANR rate | <0.5% | 0.5–1% | >1% |
| Onboarding completion rate | >60% | 45–60% | <45% |
| App start success rate | >99.5% | 98–99.5% | <98% |
| Play Store install → open rate | >70% | 50–70% | <50% |

### Check within first 24 hours
| Metric | Healthy | Investigate | Emergency |
|--------|---------|-------------|-----------|
| D0 retention (opened app same day) | >80% | 65–80% | <65% |
| `onboarding_complete` events firing | >55% of installs | 40–55% | <40% |
| `tank_created` rate (post-onboarding) | >50% | 35–50% | <35% |
| First lesson started | >40% of installs | 25–40% | <25% |
| Average session length | >3 min | 1–3 min | <1 min |
| 1-star reviews | 0–1 | 2–3 (read them) | 4+ (respond immediately) |

### Crash & ANR Thresholds (Google Play policy)
- **Crash rate >1.09%** → Google Play may badge the app as "has crash issues" in Store
- **ANR rate >0.47%** → Google Play may badge the app as "has ANR issues"
- **Internal emergency threshold:** crash rate >2% → stop all paid UA, fix same day
- **ANR emergency threshold:** ANR rate >1% → treat as P0, build fix within 24h

### Launch Day War Room Checklist
- [ ] Firebase Crashlytics open on main screen
- [ ] Play Console Android Vitals tab open
- [ ] Firebase Analytics DebugView active
- [ ] Slack/Telegram alert configured for crash rate spike
- [ ] Review queue monitored every 2 hours

---

## 2. WEEK 1 DASHBOARD (Day 1–7)

### Daily Tracking Metrics
Check these every morning at 09:00:

| Metric | Track Daily | Target |
|--------|-------------|--------|
| New installs | count + delta | Baseline establishing |
| D1 retention | % of yesterday's installs who return | >40% |
| Crash-free rate | % | >99% |
| `lesson_complete` events | count + per-user avg | >1.5/user/day |
| `onboarding_complete` / installs | % | >55% |
| Avg sessions per DAU | count | >1.8 |
| Session duration (median) | minutes | >4 min |

### Retention Benchmarks — Education/Learning App Category
*(Mobile gaming is 30/10/5 D1/D7/D30 — learning apps benchmark higher on D1, lower on D7)*

| Cohort Day | Below Average | Average | Good | Excellent |
|------------|--------------|---------|------|-----------|
| D1 | <25% | 25–35% | 35–45% | >45% |
| D3 | <15% | 15–22% | 22–30% | >30% |
| D7 | <8% | 8–15% | 15–20% | >20% |

**Danio target (Duolingo-style with streak mechanic):**
- D1: ≥40% 
- D3: ≥25%
- D7: ≥15%

*These are achievable with a strong streak mechanic. Duolingo achieves D7 ~35% but has years of optimisation.*

### Onboarding Funnel — Where to Watch
Track this funnel in Firebase Analytics → Funnels:

```
Install
  ↓ (target: >70%)
App open (first_open)
  ↓ (target: >80%)
Onboarding started (first screen interaction)
  ↓ (target: >75%)
Tank setup started (tank_created intent)
  ↓ (target: >70%)
onboarding_complete
  ↓ (target: >80%)
First lesson started
  ↓ (target: >65%)
lesson_complete (first one)
```

**Drop-off red flags:**
- >40% drop between first_open and onboarding start → UX problem at cold start screen
- >30% drop between tank setup and onboarding_complete → tank setup is too complex/long
- >40% drop between onboarding_complete and first lesson → the "what do I do next?" moment is failing

### If D7 Retention < 15%: Action Plan

**Step 1 — Diagnose (within 24h of seeing signal):**
- Check drop-off at which day (D1 vs D3 vs D7)
- Pull `lesson_complete` events per user — are users running out of content?
- Check notification open rate — are push notifications landing?
- Review 1-3 star reviews for qualitative signal

**Step 2 — Triage by cause:**
| Cause | Signal | Fix |
|-------|--------|-----|
| Empty shelf | lesson_complete/user drops to 0 by Day 5 | Add content, unlock free tier content faster |
| Notification fatigue | Notification open rate <5% | Reduce frequency, improve copy |
| Streak break no recovery | Streak 0 spikes Day 3-4 | Add streak freeze mechanic |
| Onboarding mismatch | D1 high, D3 cliff | Users not getting to their "aha moment" fast enough |
| Content quality | Low quiz_passed rate | Review and fix accuracy of lessons |

**Step 3 — Fast interventions (no build required):**
- Push notification copy experiment (Firebase Remote Config)
- Adjust free tier content limits via Remote Config
- Email/push "we miss you" sequence if streak breaks

---

## 3. MONTH 1 DASHBOARD (Day 7–30)

### D30 Retention Target
- **Minimum viable:** >5% D30 (below this, LTV doesn't support any paid UA)
- **Healthy:** >8% D30
- **Good:** >12% D30
- **Excellent (Duolingo tier):** >18% D30

*For a niche app like Danio, >8% D30 is a genuine win. Focus on getting there before scaling UA.*

### Full Conversion Funnel
Track this as a Firebase Funnel with 30-day window:

```
Install (100%)
  ↓
onboarding_complete (target: >55%)
  ↓
lesson_complete × 3 (target: >35% of installers)
  ↓
streak_day_3 (proxy: achievement_unlocked "3-day streak") (target: >20%)
  ↓
fish_id_used (target: >25% — strong intent signal)
  ↓
Paywall shown (target: >15%)
  ↓
Subscription started (target: >4% of all installs = conversion target)
```

**Key conversion inflection points:**
- Users who complete 3+ lessons convert at 3–5× baseline → protect this funnel stage
- Users who use `fish_id_used` feature are your highest-intent users → surface this feature in onboarding
- `achievement_unlocked` is a strong sticky signal — users who unlock 3+ achievements have ~2× D30 retention

### Content Engagement — Drop-off Analysis
Set up a custom Firebase report to track per-lesson/quiz completion rates:

**What to build:**
- Custom dimension: `lesson_id` on `lesson_complete` and `lesson_started` events
- Custom dimension: `quiz_id` on `quiz_passed` and `quiz_failed` events
- Funnel per lesson: started → completed → passed (for quizzes)

**Red flags:**
| Signal | Threshold | Action |
|--------|-----------|--------|
| Any lesson completion rate | <50% | Shorten or simplify that lesson |
| Quiz pass rate | <60% | Questions too hard, review accuracy |
| Same lesson replayed >3×/user | any | Content is unclear — rewrite |
| `lesson_complete` drops to 0 by Day 10 | >20% of cohort | Content exhaustion — add content immediately |

### Notification Strategy & Fatigue Signal

**Healthy notification open rates (push, Android):**
- Opt-in rate: >50% is good for a learning app with clear value prop
- Open rate per notification: 8–15% is healthy
- 5–8%: acceptable but optimise copy
- <5%: fatigue signal — reduce frequency

**Fatigue signals to watch:**
| Signal | Threshold | Action |
|--------|-----------|--------|
| Notification open rate | <5% | Reduce to max 1/day |
| Notification opt-out spike | >5% in a day | Stop the campaign causing it, review copy |
| Users who disabled notifications | >30% of DAU | Rethink notification strategy entirely |
| Sessions from notification | <15% of total sessions | Notifications aren't driving engagement |

**Recommended cadence:**
- Day 1–3: Welcome series (1/day, high value — "your tank needs attention")
- Day 4–7: Streak reinforcement (1/day if active, 1 rescue if lapsed)
- Day 8+: Personalised based on last lesson topic + streak status
- Never more than 2 notifications in a day

---

## 4. ONGOING HEALTH METRICS

### Monthly Active Users (MAU) Trend
| Signal | Meaning | Action |
|--------|---------|--------|
| MAU growing >10%/mo | Healthy organic growth | Scale UA if unit economics work |
| MAU flat for 2+ months | Plateau — UA and retention balanced | Run retention experiments |
| MAU declining >5%/mo | Churn > new users | Retention crisis — full diagnostic |
| DAU/MAU ratio (stickiness) | >20% good, >30% excellent | Below 15% = habit not forming |

**Stickiness target for Danio:** DAU/MAU >20% in first 90 days

### Revenue Metrics

**MRR Calculation:**
```
MRR = (Annual subs / 12 × $24.99) + (Monthly subs × $3.99 × 12 / 12)
```
*Note: Google Play takes 15% for first $1M revenue (small developer programme)*

| Metric | Formula | Target (Month 3) |
|--------|---------|-----------------|
| MRR | Total monthly revenue | $500+ (proof of concept) |
| ARPU | MRR / MAU | >$0.10/MAU |
| ARPPU | MRR / paying users | ~$2.08/mo (annual avg) |
| LTV estimate | ARPPU × avg subscription months | Target >$10 LTV |
| CAC (if running UA) | Ad spend / new subscribers | Must be <LTV/3 |

**LTV Estimate Model:**
- Annual plan: $24.99 × (1 − Google 15% cut) = $21.24
- If 60% renew year 2: LTV ≈ $21.24 + (0.60 × $21.24) = $33.98
- Monthly plan: $3.99 × 12 × (1 − 15%) = $40.69/yr if retained (unlikely — monthly churns faster)
- **Blended LTV target: >$15 (allows CAC up to ~$5 for positive unit economics)**

### Churn Thresholds

| Metric | Acceptable | Investigate | Action Required |
|--------|-----------|-------------|-----------------|
| Monthly subscription churn | <8%/mo | 8–15%/mo | >15%/mo |
| Annual subscription renewal rate | >55% | 40–55% | <40% |
| Free user 30-day churn | <70% | — | >85% (content gap) |

**Monthly churn >15% is a crisis.** At that rate, you're replacing your entire paid base every 6–7 months and can never build MRR. Triggers: full retention audit, paywall timing review, value delivery review.

### Play Store Rating

| Rating | Status | Action |
|--------|--------|--------|
| >4.3 | Healthy | Monitor, respond to all reviews |
| 4.0–4.3 | Acceptable | Investigate low-rating patterns, launch review prompt optimisation |
| 3.7–4.0 | Problem | Trigger response campaign, identify top complaint themes |
| <3.7 | Crisis | Full review audit, fast content/fix patch, respond to every 1–2 star |

**Review response campaign triggers:**
- Rating drops 0.2+ in a week → immediate response to all 1–2 star reviews
- Any review mentioning "fish died" or "wrong advice" → respond within 2h (accuracy crisis protocol)
- Cluster of 3+ reviews with same complaint in 48h → flag for immediate investigation

---

## 5. SPECIFIC DANIO ALERTS (Set Up Day 1)

Configure these in Firebase Analytics → BigQuery export + alerting, or use Firebase Performance Monitoring:

### Alert 1: Onboarding Crisis
```
TRIGGER: onboarding_complete events / new_users < 45% 
         (rolling 24h window, min 50 new users)
SEVERITY: High
ACTION: Check onboarding funnel step-by-step in Firebase
        → If drop at tank_created: simplify fish selection UI
        → If drop at final screen: check for crashes at that step
NOTIFY: Tiarnan via Telegram
```

### Alert 2: Engagement Cliff
```
TRIGGER: lesson_complete events per DAU < 1.0
         for users in Day 5–9 cohort
SEVERITY: High  
ACTION: Content exhaustion check
        → Count total available lessons in free tier
        → If users averaging >8 lessons/day, content runs out in ~5 days
        → Emergency: unlock more free content via Remote Config
NOTIFY: Tiarnan via Telegram
```

### Alert 3: Crash Emergency
```
TRIGGER: Crash-free users rate < 97% (any 6h window)
         OR ANR rate > 1%
SEVERITY: Critical (P0)
ACTION: 
  1. Pull Crashlytics top crash — identify stack trace
  2. If reproducible: hotfix branch immediately
  3. If Play Store update needed: expedited review request
  4. If widespread: consider temporary rollback via Play Console
NOTIFY: Tiarnan via Telegram + email, immediate
```

### Alert 4: Accuracy Crisis (Fish Died Signal)
```
TRIGGER: Any 1-star review containing keywords: 
         "fish died", "wrong advice", "killed my fish", 
         "inaccurate", "dangerous", "fish dead"
SEVERITY: Critical (reputation)
ACTION:
  1. Read review in full — identify specific advice cited
  2. Locate the lesson/tip in the app content
  3. Consult fishkeeping reference source (verify accuracy)
  4. If wrong: remote config disable the content, patch within 48h
  5. Respond to review publicly within 2h: acknowledge, take responsibility, state fix in progress
  6. Post-fix: reach out to reviewer to update rating
NOTIFY: Tiarnan via Telegram immediately
```

### Alert 5: Conversion Target Miss
```
TRIGGER: Freemium→paid conversion rate < 2% by Day 30
         (less than half of 4% target — early warning)
SEVERITY: Medium
ACTION:
  1. Review paywall trigger points — when does it show?
  2. Check fish_id_used → paywall funnel (highest intent users)
  3. A/B test paywall copy/price display via Remote Config
  4. Consider adding trial period (7-day free premium)
NOTIFY: Tiarnan, weekly digest
```

### Alert 6: Notification Fatigue
```
TRIGGER: Push notification open rate < 5% (7-day rolling)
         OR notification permission opt-out rate > 3% in a day
SEVERITY: Medium
ACTION:
  1. Pause non-critical notification campaigns
  2. Review last 7 days of notification copy
  3. Reduce frequency to max 1/day
  4. Personalise based on last activity type
NOTIFY: Tiarnan, weekly digest
```

---

## 6. TOOLS RECOMMENDED

### Firebase Analytics — Dashboards to Build

**Dashboard 1: Launch Health (Day 0–7)**
- Active users (DAU chart)
- Top events: onboarding_complete, lesson_complete, tank_created, fish_id_used
- Crash-free rate (link to Crashlytics)
- New vs returning users

**Dashboard 2: Retention Funnel**
- User retention cohort table (Firebase built-in)
- Custom funnel: install → onboarding → first lesson → Day 3 → Day 7
- Streak length distribution

**Dashboard 3: Conversion Pipeline**
- fish_id_used users vs non (compare retention + conversion)
- Achievement unlock rates (proxy for engagement depth)
- Paywall impressions vs starts (when wired)

**Dashboard 4: Content Health**
- lesson_complete by lesson_id (requires custom param)
- quiz_passed rate by quiz_id
- Average lessons completed per user per day

**Set up immediately:**
- Firebase Crashlytics (already available in Firebase)
- Firebase Performance Monitoring (free, catches slow frames and network latency)
- Firebase Remote Config (for kill switches and content unlocks without a build)

### Google Play Console — Metrics to Monitor Daily

| Section | What to Watch |
|---------|--------------|
| Android Vitals → Crashes | Crash rate, ANR rate vs "bad behaviour threshold" |
| Android Vitals → Core metrics | Battery usage, rendering, permissions |
| Ratings & Reviews | Star distribution, new reviews (check daily week 1) |
| Store Listing Conversion | Install rate from store listing page views |
| Acquisition → Store Listing Performance | Which search terms drive installs |
| Subscriptions | Active subscribers, revenue, churn (when subscriptions start) |

**Play Console keyword to track from Day 1:**
- "fishkeeping app", "aquarium app", "fish care app", "fish tank app"
- Note your ranking vs AquaticHabitats, AqAdvisor, and any Duolingo-style competitors

### Free Tools Worth Adding

| Tool | Purpose | Cost | Priority |
|------|---------|------|----------|
| **Firebase Crashlytics** | Crash reporting (real-time, stack traces) | Free | Day 1 (essential) |
| **Firebase Remote Config** | Feature flags, content unlocks without builds | Free | Day 1 (essential) |
| **Firebase A/B Testing** | Onboarding, paywall, notification experiments | Free | Week 2 |
| **RevenueCat** | Subscription management, churn analytics, LTV | Free up to $2.5k MRR | Week 1 — connect before first subscription |
| **Mixpanel (free tier)** | Advanced funnel analysis beyond Firebase | Free up to 20M events/mo | Week 2–4 |
| **Loom / screen recording** | Watch real users via beta testers | Free | Pre-launch if possible |
| **AppFollow (free tier)** | Review monitoring + keyword alerts | Free tier available | Day 1 for review alerts |
| **Instabug (free tier)** | In-app bug reporting from beta users | Free tier | Beta phase |

**The non-negotiable stack:**
1. Firebase Analytics + Crashlytics (already wired) ✅
2. Firebase Remote Config (add immediately — gives you kill switches)
3. RevenueCat (connect before first subscription goes live — retrofitting is painful)
4. AppFollow or similar for review keyword alerts ("fish died" detection)

---

## Quick Reference: Week 1 War Card

```
MORNING CHECKLIST (09:00 daily):
□ Crash-free rate > 99%?
□ D1 retention from yesterday's cohort > 40%?
□ onboarding_complete rate > 55%?
□ lesson_complete events per DAU > 1.5?
□ Any new 1-3 star reviews? (read + respond)
□ ANR rate < 0.5%?

IF ANY RED → diagnose before lunch
```

---

*Prometheus monitoring plan v1.0 — update after first 30 days with actual baselines.*
