# Argus Monetisation & Competitive Audit

**Agent:** Argus (QA, Mount Olympus)
**Date:** 2026-03-01
**Branch:** openclaw/ui-fixes

---

## Part 1: Monetisation Audit

### Current State: Everything Is Free

**Q1: Is there a working premium/paid tier?**
No. Zero premium infrastructure exists. No `isPremium` field, no subscription provider, no paywall screen, no IAP SDK.

**Q2: What features are gated behind premium?**
Nothing. All features — AI, unlimited tanks, all learning paths, all achievements, all calculators — are available to every user for free.

**Q3: Is there a paywall shown at the right moments?**
No paywall exists at all. There are no gates, no limits, no upgrade prompts.

**Q4: Is there a free trial or freemium model?**
No. The app is fully free with no monetisation mechanism.

**Q5: What's the in-app purchase setup?**
Nothing. No RevenueCat, no flutter_inapp_purchase, no StoreKit, no billing_client. Zero IAP packages in pubspec.yaml.

**Q6: Is the gem/heart system connected to real monetisation?**
No. Gems are earned through learning activities only (lessons: 5, quizzes: 3-5, streaks: 10-100, achievements: 5-50). The gem shop sells virtual power-ups and cosmetics. Hearts auto-refill. No real money changes hands.

### Assessment
The gem economy is well-designed as an engagement mechanic but generates zero revenue. It's a Duolingo-style virtual currency that keeps users engaged through spending/earning loops, but unlike Duolingo, there's no path from engagement to payment.

**Risk:** Without monetisation, the AI features (which use OpenAI API with real costs) will bleed money at scale. Each Fish ID or Ask Danio query costs real API credits.

**Full monetisation plan written to:** `MONETISATION_PLAN.md`

---

## Part 2: Competitive Features Implemented

### ✅ 1. "Why Danio?" Onboarding Value Prop
**Commit:** `feat(ux): add 'Why Danio?' value prop to onboarding`

First onboarding screen now shows 3 differentiator bullets:
- 🎓 Learn fishkeeping the fun way — lessons, quizzes, streaks
- 🤖 AI that identifies fish and diagnoses problems
- 🏆 55+ achievements — from First Fish to Master Aquarist

Title changed from generic "Track Your Aquariums" to "Why Danio?" — immediately communicates what makes this app different from every tracker app.

### ✅ 2. Tank Health Score (0-100)
**Commit:** `feat(premium): add tank health score`

New service: `lib/services/tank_health_service.dart`
New widget: `lib/screens/tank_detail/widgets/tank_health_card.dart`

Scoring (100 total):
- **Water change recency (35 pts):** ≤7 days = 35, ≤10 = 25, ≤14 = 15, >14 = 5, none = 0
- **Water parameter quality (40 pts):** Checks ammonia (0 ideal), nitrite (0 ideal), nitrate (<40 ideal), pH (in tank target range). Stale tests (>14 days) penalised.
- **Logging regularity (25 pts):** ≥12 logs/month = 25, ≥8 = 20, ≥4 = 15, ≥1 = 8, 0 = 0

Display: Circular gauge with colour coding (🟢 80-100, 🟡 60-79, 🟠 40-59, 🔴 <40). Shows top contributing factors. Positioned on tank detail screen between Quick Stats and Action Buttons.

Prometheus called this a "killer differentiator — like a credit score for your aquarium." No competitor has this.

### ✅ 3. Water Change Streak
**Commit:** `feat(ux): add water change streak to home screen`

Displayed on home screen as a teal pill: "💧 Water change streak: 3 weeks"

Calculates consecutive calendar weeks with at least one water change logged, counting backwards from the current week. Hidden when streak is 0 (no water changes logged).

Gamifies the single most important maintenance task. Water changes prevent 80%+ of fish deaths. Making this visible and streak-tracked creates a positive reinforcement loop.

### ✅ 4. Smart Notification Copy
**Commit:** `feat(ux): improve notification copy for warmth and action`

| When | Before | After |
|------|--------|-------|
| Morning | "🔥 Good morning!" | "🎓 5 minutes to level up your fishkeeping today?" |
| Morning body | "Start your X-day streak with today's lesson" | "Your 🔥 X-day streak is waiting. Let's go!" |
| Evening | "⏰ Keep your streak alive!" | "🔥 Don't lose your streak! Complete a lesson today" |
| Night | "⚠️ Don't lose your streak!" | "🚨 Last chance today!" |
| Night body | "Only 5 minutes..." | "🔥 Your X-day streak ends at midnight! A 5-minute lesson is all it takes" |
| Water overdue | "💧 Water change overdue!" | "💧 Time for a water change! Your tank will thank you 🐠" |
| Water due | "💧 Water change coming up" | "💧 Water change reminder" |

All copy now feels warm, personal, and action-oriented. Urgency escalates through the day (morning = gentle, evening = motivating, night = urgent).

### ⏳ 5. Species Compatibility Pre-Check (Not Implemented — Too Complex)
**Reason:** This requires:
- Modifying the "Add Fish" flow to intercept before saving
- An AI API call with the current tank's species list
- Loading/error/result UI states
- Edge cases (no API key, offline, timeout)
- The compatibility check service already exists in `lib/features/smart/` but integrating it into the livestock addition flow requires significant UI refactoring

**TODO written below with full implementation plan.**

---

## Part 3: Features Not Implemented (with TODOs)

### Species Compatibility Pre-Check
**Complexity:** Medium-High | **ROI:** Very High | **Effort:** ~4-6 hours

Implementation plan:
1. In `lib/screens/livestock_screen.dart`, intercept the "Add" button tap
2. Before saving, gather current tank species list
3. Call `lib/features/smart/compatibility_checker.dart` with new species + existing species
4. Show a modal bottom sheet with results:
   - ✅ Compatible → "Great match! [species] gets along well with your current fish"
   - ⚠️ Caution → "Some things to consider: [reasons]" with proceed/cancel
   - ❌ Incompatible → "Warning: [species] may not be safe with [existing]. [reason]"
5. User chooses to proceed or cancel
6. Requires: OpenAI API key available, online connectivity

### Premium Infrastructure
**Complexity:** High | **ROI:** Critical | **Effort:** ~2-3 days

See `MONETISATION_PLAN.md` for full details. Key steps:
1. Add `isPremium` to UserProfile model + Hive adapter
2. Create `PremiumProvider` with gating methods
3. Build `PaywallScreen` (beautiful, non-aggressive)
4. Integrate `purchases_flutter` (RevenueCat)
5. Configure products in App Store Connect / Google Play Console
6. Add gate checks at tank creation (>1), AI features, advanced paths

### Cloud Sync
**Complexity:** High | **ROI:** High | **Effort:** ~1-2 weeks

Already partially built (`lib/services/cloud_sync_service.dart`, `lib/services/sync_service.dart`). Needs:
- Supabase backend deployment
- Auth flow (email/Google sign-in)
- Conflict resolution strategy
- Premium gating

---

## ROI Ranking of Remaining Features

| # | Feature | Impact | Effort | Priority |
|---|---------|--------|--------|----------|
| 1 | **Premium infrastructure + paywall** | 💰💰💰💰💰 | High | **P0 — blocks all revenue** |
| 2 | **Cloud sync** | 📈📈📈📈 | High | P1 — #1 retention risk |
| 3 | **Compatibility pre-check** | 📈📈📈📈 | Medium | P1 — prevents fish deaths |
| 4 | **XP for tank management** | 📈📈📈 | Medium | P1 — daily loop driver |
| 5 | **AI test strip scanner** | 📈📈📈📈📈 | High | P2 — viral potential |
| 6 | **iOS build** | 📈📈📈📈 | Medium | P2 — half the market |
| 7 | **Gem purchase packs** | 💰💰 | Low | P2 — supplementary revenue |
| 8 | **German localisation** | 📈📈📈 | Medium | P3 — largest EU market |
| 9 | **Social features** | 📈📈 | High | P3 — retention long-term |
| 10 | **Smart aquarium device integration** | 📈📈 | Very High | P4 — future differentiator |

---

## Summary

**What was done:**
- 4 features implemented and committed (Tank Health Score, Water Change Streak, Onboarding Value Prop, Smart Notifications)
- Full monetisation audit completed
- Detailed monetisation plan written (`MONETISATION_PLAN.md`)
- ROI-ranked feature backlog for remaining work

**Key finding:** The app has zero revenue infrastructure. This is the #1 priority before launch. Every AI query costs real money with no way to recoup it. The gem economy is excellent for engagement but needs a bridge to real-money premium subscription.

**Bottom line:** The product is genuinely competitive (Prometheus is right). The gamification, AI, and education system are unique in the market. But shipping without any monetisation is shipping a charity. Premium gating + RevenueCat integration should be the next sprint.

---

*"Quality is not an act, it is a habit." — Aristotle (via Argus)*
