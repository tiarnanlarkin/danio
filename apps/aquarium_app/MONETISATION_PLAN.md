# Danio Monetisation Plan

> **Status:** No premium system exists. Everything is currently free.
> **Last Updated:** 2026-03-01

---

## Current State

### What exists:
- **Virtual gem economy** — gems earned through learning activities (lessons, quizzes, streaks, achievements)
- **Gem shop** — spend gems on power-ups (XP boost, timer boost, quiz retry), cosmetics (badges, themes, celebration effects), and extras (streak freeze, hearts refill)
- **Hearts system** — Duolingo-style lives that deplete on wrong answers, auto-refill over time
- **No real-money purchases** — gems are earned only, never bought
- **No paywall** — all features accessible to all users
- **No RevenueCat / StoreKit / billing_client** — zero IAP infrastructure

### What's missing:
- `isPremium` flag on UserProfile
- Premium/subscription provider
- Paywall screen/modal
- RevenueCat or purchases_flutter package
- Any gating logic for premium features
- Gem purchase packs (real money -> gems)

---

## Recommended Free vs Premium Split

### Free Tier (generous enough to get hooked)
| Feature | Limit |
|---------|-------|
| Tanks | 1 tank (unlimited fish/logs within it) |
| Learning paths | 3 of 9 paths (Nitrogen Cycle, First Fish, Maintenance) |
| Water logging | Full — no limit |
| Achievements | 20 of 55+ |
| Species browser | Basic — 50 species |
| Calculators | Volume + stocking only |
| Gem shop | Full access (earn-only gems) |
| Hearts system | Full (5 hearts, auto-refill) |
| Tank Health Score | Full |
| Water change streak | Full |

### Premium (Danio Pro — £3.99/month or £29.99/year)
| Feature | Detail |
|---------|--------|
| Unlimited tanks | No limit on number of tanks |
| All 9 learning paths | Equipment, Fish Health, Planted Tank, Advanced Topics, etc. |
| AI features | Fish ID, Ask Danio, Symptom Triage, Compatibility Checker |
| Cloud backup/sync | Cross-device sync via Supabase |
| Advanced analytics | Trends, charts, parameter comparison |
| All 55+ achievements | Full achievement catalogue |
| Full species database | All 122 fish + 52 plants |
| All 8 calculators | CO2, dosing, water volume, stocking, etc. |
| Priority support | In-app feedback goes to priority queue |
| Ad-free | Remove any future ads |

### Premium Touchpoints (where to show the paywall)
1. **When user tries to add a 2nd tank** → "Upgrade to Danio Pro for unlimited tanks"
2. **When user taps a locked learning path** → "This path is available with Danio Pro"
3. **When user tries an AI feature** → "AI features are powered by Danio Pro"
4. **After completing all free achievements** → "Unlock 35+ more achievements with Pro"
5. **When viewing locked species** → subtle lock icon + "Pro" badge
6. **Settings screen** → permanent "Upgrade to Pro" card

### Anti-patterns to AVOID:
- ❌ Random paywall popups
- ❌ Paywalling water logging (core utility must be free)
- ❌ Paywalling the first tank
- ❌ Time-limited free trials that feel pressured
- ❌ Making the free tier feel broken

---

## Gem Economy Enhancement

### Current gem sources (free):
- Lesson complete: 5 gems
- Quiz pass: 3 gems / Quiz perfect: 5 gems
- Daily goal met: 5 gems
- 7-day streak: 10 gems
- 30-day streak: 25 gems
- Level up: 10 gems
- Achievements: 5-50 gems depending on tier

### Proposed additions:
- **Water test logged: 3 gems** (encourages data entry)
- **Water change logged: 5 gems** (encourages maintenance)
- **Feeding logged: 1 gem** (low-effort tracking)
- **Photo added: 2 gems** (builds gallery)
- **Weekly active bonus: 10 gems** (logged in 5+ days)

### Optional: Gem purchase packs
| Pack | Price | Gems | Bonus |
|------|-------|------|-------|
| Starter | £0.99 | 50 | — |
| Popular | £2.99 | 200 | +50 bonus |
| Best Value | £4.99 | 500 | +200 bonus |

*Note: Gem purchases should NOT unlock premium features — they're for shop items only. This keeps premium subscription as the main revenue driver.*

---

## Implementation Priority

### Phase 1 (Pre-launch — essential)
1. Add `isPremium` field to UserProfile
2. Create PremiumProvider with gating logic
3. Build paywall/upgrade screen
4. Integrate RevenueCat (cross-platform IAP)
5. Gate 2nd tank, AI features, advanced learning paths

### Phase 2 (Post-launch — month 1-2)
6. Cloud sync (requires premium)
7. Gem purchase packs
8. Premium achievement set

### Phase 3 (Month 3+)
9. Annual subscription option
10. Family plan
11. Lifetime purchase option

---

## Revenue Projections (from Prometheus analysis)

| Milestone | Paying Users | Monthly Revenue | Annual Revenue |
|-----------|-------------|-----------------|----------------|
| Break-even (API costs) | 50 | £200 | £2,394 |
| Ramen profitable | 500 | £1,995 | £23,940 |
| Sustainable indie | 2,000 | £7,980 | £95,760 |

Target free-to-paid conversion: 5-8% (Duolingo benchmark: ~8%)

---

## Key Principle

> The free tier should make users love the app. The premium tier should make them love it more. Never make the free tier feel like a demo.
