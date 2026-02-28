# Danio — Master Plan
*Synthesised from 6 parallel research agents, 2026-02-28*

## The Headline

**Zero competition.** No aquarium app teaches fishkeeping. They're all "digital notebooks with 2015 UI." Danio is the first to combine Duolingo's engagement architecture with tank management. The market ($4-6.6B, 13M US fish-owning households) is wide open.

---

## What's Working

- ✅ 798 tests passing, 0 errors
- ✅ Strong accessibility foundation (163 semantic annotations + 17 new tooltips)
- ✅ Celebration system (confetti, level-ups, achievement unlocks)
- ✅ Release signing already configured
- ✅ Privacy policy + ToS written (real content)
- ✅ Custom app icon with adaptive layers
- ✅ Offline-first design
- ✅ Good colour contrast (all WCAG AA compliant)

---

## Critical Issues (Fix Before Launch)

### 1. 🔴 Orphaned Features (~40% unreachable)
Friends, Leaderboard, Workshop, Shop Street exist in old `HouseNavigator` but current `TabNavigator` doesn't include them. **These screens may be completely unreachable.**

**Fix:** Add "More" tab or drawer to Settings, or integrate into existing tabs.

### 2. 🔴 Onboarding Too Long (8-12 steps, 3-5 min)
3 info pages → profile creation (4 fields) → placement test → results → app. High drop-off risk.

**Fix:** Reduce to 1 welcome screen → create first tank → home. Defer placement test to post-onboarding nudge.

### 3. 🔴 God Object Provider (932 lines)
`userProfileProvider` handles XP, streaks, lessons, gems, inventory all in one.

**Fix:** Split into `xpProvider`, `streakProvider`, `inventoryProvider`, etc.

### 4. 🟡 Water Logging Friction (3 taps + 8 fields)
The most frequent user action is one of the most cumbersome.

**Fix:** Quick-log FAB on HomeScreen. Pre-fill from last test. "Quick test" mode (pH, ammonia, nitrite only).

### 5. 🟡 SharedPreferences as Database
Complex JSON blobs for profile and spaced repetition cards.

**Fix:** Migrate to Drift/SQLite for structured data (Phase 2).

### 6. 🟡 ~12,000 Lines of Static Data in Binary
Species, plants, stories compiled directly in. Inflates APK.

**Fix:** Move to asset JSON files loaded at runtime (Phase 2).

---

## Monetisation Recommendation

**Hybrid: Free + Subscription + Lifetime + Cosmetics**

| Tier | Price | What's Included |
|------|-------|-----------------|
| Free | $0 | 2 tanks, core tracking, full gamification loop, all lessons |
| Pro Monthly | $3.99/mo | Unlimited tanks, cloud sync, AI features, no ads |
| Pro Annual | $24.99/yr | Same as monthly (save 48%) |
| Lifetime | $59.99 | One-time, all Pro features forever |
| Cosmetics | $0.99-$2.99 | Tank themes, avatars, celebration effects |

**Core principle:** "Price below the hobby noise floor" — $25/yr is invisible to someone who just spent $80 on a filter.

**Conservative Year 3:** ~$63K revenue. Optimistic: ~$200K.

---

## Go-to-Market (Summary)

### ASO
- **Title:** "Danio — Learn Fishkeeping & Track Your Aquarium"
- **Screenshots:** 8-panel story (learning → tank setup → tracking → achievements)

### Launch Sequence
1. Pre-launch (4 weeks): Landing page, beta in r/Aquariums, YouTube outreach
2. Launch week: Product Hunt, Reddit, all fishkeeping communities
3. Post-launch: Content marketing, referral system, seasonal events

### Community Targets
- r/Aquariums (1.4M), r/PlantedTank (320K), r/bettafish (164K)
- YouTube: CoralFish12g (2M), Aquarium Co-Op (900K+), Girl Talks Fish
- Facebook: Freshwater Aquarium Hobby (250K+)

### Budget: $140 (bootstrapped) → $1,890 (recommended) → $8,300 (aggressive)

---

## Top 10 Actions (Prioritised)

| # | Action | Impact | Effort |
|---|--------|--------|--------|
| 1 | Fix orphaned navigation (Friends, Leaderboard, Shop) | 🔴 Critical | 4-8h |
| 2 | Shorten onboarding to 1 screen + first tank | 🔴 Critical | 8-12h |
| 3 | Add quick-log FAB for water testing | 🟠 High | 4-6h |
| 4 | Split userProfileProvider god object | 🟠 High | 8-16h |
| 5 | Add "More" section for secondary features | 🟠 High | 4-6h |
| 6 | Build release APK + test on device | 🟠 High | 2-4h |
| 7 | Create store screenshots (8 panels) | 🟡 Medium | 4-8h |
| 8 | Set up freemium gate infrastructure | 🟡 Medium | 16-24h |
| 9 | Add streak repair + hearts refill mechanics | 🟡 Medium | 8-12h |
| 10 | Performance: lazy tab loading + .select() | 🟢 Quick Win | 2-4h |

---

## Full Reports
- `docs/UX_RESEARCH.md` — Gamification patterns, UI trends, user pain points
- `docs/ARCHITECTURE_REVIEW.md` — Codebase architecture, performance, deps
- `docs/UX_JOURNEY_MAP.md` — 7 user journeys with friction points
- `docs/MONETISATION_STRATEGY.md` — Competitor pricing, revenue projections
- `docs/GO_TO_MARKET.md` — ASO, launch plan, community targets, budget
