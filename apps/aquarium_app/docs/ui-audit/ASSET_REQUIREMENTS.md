# 🎨 Aquarium App - Visual Asset Requirements

> **Purpose:** Complete manifest of all visual assets needed for A+ polish
> **Last Updated:** 2025-02-12
> **Status:** Planning Phase

---

## 📊 Current State Audit

### Existing Assets
| Asset Type | Status | Location |
|-----------|--------|----------|
| App Icon (Android) | ✅ Exists | `android/app/src/main/res/mipmap-*` |
| App Icon (Web) | ✅ Exists | `web/icons/` |
| Custom Images | ❌ Empty | `assets/images/` (empty) |
| Illustrations | ❌ None | Uses Material Icons |
| Lottie Animations | ❌ None | Built-in Flutter animations only |
| Achievement Badges | ❌ Emoji only | Uses emoji (🐣, 🐠, 🏆, etc.) |
| Shop Item Icons | ❌ Emoji only | Uses emoji (⏱️, ⚡, 💡, etc.) |

### Current Visual Style
The app has a well-defined design system in `lib/theme/app_theme.dart`:

**Primary Palette (Aquatic)**
- Primary: `#3D7068` (Deep teal)
- Primary Light: `#5B9A8B` (Soft teal)
- Accent: `#85C7DE` (Sky blue)

**Secondary Palette (Warm)**
- Secondary: `#9F6847` (Warm amber)
- Secondary Light: `#E8A87C` (Soft coral/peach)

**Semantic Colors**
- Success: `#5AAF7A` (Green)
- Warning: `#C99524` (Amber)
- Error: `#D96A6A` (Coral red)
- Info: `#5C9FBF` (Blue)

**Design Language**
- Soft, organic, calming aesthetic
- Glassmorphism + neumorphism inspired
- Large border radius (16-24px cards)
- Soft shadows (not harsh)
- Aquatic/underwater theme

---

## 🎯 Visual Style Guide (Recommended)

### Illustration Style
**Recommended:** Modern flat with soft gradients
- **Style:** Flat vector illustrations with subtle gradients
- **Feel:** Friendly, approachable, slightly playful
- **Detail Level:** Medium - not too minimalist, not too complex
- **Perspective:** Mostly frontal/isometric for icons, varied for scenes
- **Similar to:** Duolingo, Headspace, Notion illustrations

### Color Guidelines for Illustrations
```
Primary scenes:     Teal/aqua tones (#3D7068, #5B9A8B, #85C7DE)
Success/positive:   Greens with coral highlights
Warning/attention:  Amber (#C99524) + teal accents  
Error states:       Soft coral red (#D96A6A), not harsh
```

### Icon Style
- **Primary:** Continue using Material Icons (already consistent)
- **Custom icons:** Outlined style, 2px stroke, rounded caps
- **Match:** Material Design 3 aesthetic

---

## 📋 Asset Manifest

### Priority Levels
- 🔴 **P0 - Must Have:** Required for MVP polish
- 🟡 **P1 - Should Have:** Significantly improves UX
- 🟢 **P2 - Nice to Have:** Delights users but not critical

---

## 1️⃣ Empty State Illustrations

Critical for emotional UX when users have no content.

| ID | Asset Name | Screen/Context | Dimensions | Priority | Source |
|----|-----------|----------------|------------|----------|--------|
| E01 | `empty_tanks.svg` | Home - No tanks | 200×200 | 🔴 P0 | Create/Purchase |
| E02 | `empty_lessons.svg` | Learn - No lessons completed | 200×200 | 🔴 P0 | Create/Purchase |
| E03 | `empty_achievements.svg` | Achievements - None unlocked | 200×200 | 🟡 P1 | Create/Purchase |
| E04 | `empty_livestock.svg` | Tank - No fish/plants | 200×200 | 🟡 P1 | Create/Purchase |
| E05 | `empty_equipment.svg` | Equipment - None added | 200×200 | 🟡 P1 | Create/Purchase |
| E06 | `empty_logs.svg` | Logs - No entries | 200×200 | 🟡 P1 | Create/Purchase |
| E07 | `empty_tasks.svg` | Tasks - All complete | 200×200 | 🟢 P2 | Create/Purchase |
| E08 | `empty_wishlist.svg` | Wishlist - Empty | 200×200 | 🟢 P2 | Create/Purchase |
| E09 | `empty_friends.svg` | Friends - None added | 200×200 | 🟢 P2 | Create/Purchase |
| E10 | `empty_inventory.svg` | Inventory - Empty | 200×200 | 🟢 P2 | Create/Purchase |
| E11 | `empty_reviews.svg` | Practice - Nothing to review | 200×200 | 🟢 P2 | Create/Purchase |

**Illustration Concepts:**
- E01: Friendly fish looking curious, empty tank with sparkles
- E02: Open book with fish bookmark, welcoming vibe
- E03: Empty trophy shelf waiting to be filled
- E04: Happy tank with "Add your first fish!" feel
- E05: Simple aquarium stand with hooks for equipment
- E06: Clipboard/notebook ready for first entry
- E07: Checkmark with celebratory fish (success state!)
- E08: Heart-shaped wishlist with dotted placeholder items

---

## 2️⃣ Onboarding & Tutorial Illustrations

Replace current Material Icons with engaging illustrations.

| ID | Asset Name | Screen | Dimensions | Priority | Source |
|----|-----------|--------|------------|----------|--------|
| O01 | `onboard_tanks.svg` | Onboarding Slide 1 | 280×280 | 🔴 P0 | Create |
| O02 | `onboard_livestock.svg` | Onboarding Slide 2 | 280×280 | 🔴 P0 | Create |
| O03 | `onboard_maintenance.svg` | Onboarding Slide 3 | 280×280 | 🔴 P0 | Create |
| O04 | `onboard_learn.svg` | Learning Intro | 280×280 | 🟡 P1 | Create |
| O05 | `onboard_gamification.svg` | XP/Hearts/Streaks Intro | 280×280 | 🟡 P1 | Create |
| O06 | `tutorial_first_tank.svg` | First Tank Wizard | 200×200 | 🟡 P1 | Create |
| O07 | `tutorial_log_params.svg` | Parameter Logging Guide | 200×200 | 🟡 P1 | Create |
| O08 | `tutorial_complete.svg` | Onboarding Complete | 280×280 | 🟡 P1 | Create |

**Illustration Concepts:**
- O01: Beautiful aquarium in cozy room setting
- O02: Variety of friendly fish/plants together
- O03: Happy fish with calendar/checklist motif
- O04: Brain + fish = learning combination
- O05: Fire streak, hearts, XP stars floating
- O08: Celebration with fish wearing graduation cap

---

## 3️⃣ Achievement Badges (Optional Upgrade)

Currently using emoji. Could upgrade to custom illustrated badges.

| ID | Asset Name | Achievement | Dimensions | Priority | Source |
|----|-----------|-------------|------------|----------|--------|
| A01 | `badge_first_lesson.svg` | First Steps | 64×64 | 🟢 P2 | Create |
| A02 | `badge_streak_7.svg` | Week Warrior | 64×64 | 🟢 P2 | Create |
| A03 | `badge_streak_30.svg` | Monthly Marathon | 64×64 | 🟢 P2 | Create |
| A04 | `badge_streak_365.svg` | Year of Learning | 64×64 | 🟢 P2 | Create |
| A05 | `badge_xp_1000.svg` | Thousand Club | 64×64 | 🟢 P2 | Create |
| A06 | `badge_perfectionist.svg` | Perfectionist | 64×64 | 🟢 P2 | Create |
| A07 | `badge_completionist.svg` | Completionist | 64×64 | 🟢 P2 | Create |
| A08-A55 | (remaining 48 badges) | Various | 64×64 | 🟢 P2 | Create |

**Note:** 55 achievements total. Emoji system works well and is consistent.
Consider upgrading only the most prestigious achievements (platinum tier) first.

**Recommended Approach:**
1. Keep emoji for bronze/silver tiers
2. Create custom badges only for gold/platinum (highest-tier achievements)
3. This creates aspirational "special" feel for top achievements

---

## 4️⃣ Lottie Animations

High-impact animations that would elevate the experience significantly.

| ID | Asset Name | Usage | Duration | Priority | Source |
|----|-----------|-------|----------|----------|--------|
| L01 | `confetti_celebration.json` | Lesson complete, achievement unlock | 2-3s | 🟡 P1 | LottieFiles (free) |
| L02 | `fish_swimming.json` | Loading states | Loop | 🟡 P1 | LottieFiles (free) |
| L03 | `streak_fire.json` | Streak display | Loop | 🟡 P1 | LottieFiles (free/purchase) |
| L04 | `heart_refill.json` | Heart regeneration | 1.5s | 🟡 P1 | LottieFiles (free) |
| L05 | `xp_burst.json` | XP gain animation | 1s | 🟡 P1 | LottieFiles (free) |
| L06 | `achievement_unlock.json` | Achievement notification | 2s | 🟢 P2 | LottieFiles/Create |
| L07 | `level_up.json` | Level up celebration | 2-3s | 🟢 P2 | LottieFiles/Create |
| L08 | `stars_success.json` | Quiz success | 1.5s | 🟢 P2 | LottieFiles (free) |
| L09 | `water_ripple.json` | Water change logged | 1s | 🟢 P2 | Create |
| L10 | `gem_sparkle.json` | Gem earned/spent | 1s | 🟢 P2 | LottieFiles (free) |

**Note:** The app already has Flutter-built confetti and XP animations.
Lottie versions would be smoother and more polished.

**Recommended Sources:**
- [LottieFiles](https://lottiefiles.com) - Free tier available
- [IconScout](https://iconscout.com/lottie-animations) - Quality options
- [Lordicon](https://lordicon.com) - Beautiful animated icons

---

## 5️⃣ Error & Status State Illustrations

| ID | Asset Name | Context | Dimensions | Priority | Source |
|----|-----------|---------|------------|----------|--------|
| S01 | `error_generic.svg` | General error state | 200×200 | 🟡 P1 | Create/Purchase |
| S02 | `error_network.svg` | No internet connection | 200×200 | 🟡 P1 | Create/Purchase |
| S03 | `error_not_found.svg` | 404/item not found | 200×200 | 🟢 P2 | Create/Purchase |
| S04 | `success_saved.svg` | Data saved successfully | 120×120 | 🟢 P2 | Create/Purchase |
| S05 | `maintenance_mode.svg` | App maintenance | 200×200 | 🟢 P2 | Create/Purchase |

**Illustration Concepts:**
- S01: Confused fish with ? bubble
- S02: Fish with broken wifi symbol
- S03: Fish with magnifying glass searching
- S04: Happy fish with checkmark

---

## 6️⃣ Feature-Specific Illustrations

| ID | Asset Name | Feature | Dimensions | Priority | Source |
|----|-----------|---------|------------|----------|--------|
| F01 | `placement_test.svg` | Placement test intro | 240×240 | 🟡 P1 | Create |
| F02 | `practice_intro.svg` | Practice/review intro | 240×240 | 🟡 P1 | Create |
| F03 | `shop_header.svg` | Gem shop header | 400×120 | 🟡 P1 | Create |
| F04 | `leaderboard_top.svg` | Leaderboard celebration | 200×200 | 🟢 P2 | Create |
| F05 | `hearts_out.svg` | Out of hearts modal | 200×200 | 🟡 P1 | Create |
| F06 | `streak_lost.svg` | Streak broken state | 200×200 | 🟡 P1 | Create |
| F07 | `streak_frozen.svg` | Streak freeze active | 200×200 | 🟢 P2 | Create |

**Illustration Concepts:**
- F05: Sad fish with empty heart, encouragement to wait or purchase
- F06: Fish with extinguished fire, "Don't worry, start again!"
- F07: Fish with snowflake shield protecting streak fire

---

## 7️⃣ App Icon Refinements (If Needed)

Current icons exist but may need polish for store presence.

| ID | Asset Name | Platform | Dimensions | Priority | Source |
|----|-----------|----------|------------|----------|--------|
| I01 | `app_icon_ios.png` | iOS App Store | 1024×1024 | 🔴 P0 | Verify/Refine |
| I02 | `app_icon_android.png` | Google Play | 512×512 | 🔴 P0 | Verify/Refine |
| I03 | `app_icon_adaptive_fg.png` | Android Adaptive | 432×432 | 🔴 P0 | Verify/Refine |
| I04 | `feature_graphic.png` | Google Play | 1024×500 | 🟡 P1 | Create |
| I05 | `app_icon_web.png` | Web/PWA | 512×512 | 🟡 P1 | Verify/Refine |

---

## 📐 Technical Specifications

### File Formats
| Type | Format | Reason |
|------|--------|--------|
| Illustrations | SVG | Scalable, small file size |
| Complex illustrations | PNG @3x | For detailed scenes |
| Animations | Lottie JSON | Smooth, lightweight, interactive |
| App Icons | PNG | Platform requirements |
| Badges | SVG or PNG @3x | Need sharp at small sizes |

### Resolution Guidelines
```
Illustrations:  Design at 200×200, export @1x, @2x, @3x
Badges:         Design at 64×64, export @1x, @2x, @3x  
Animations:     Design at 300×300 for flexibility
App Icons:      Design at 1024×1024, export all sizes
```

### Flutter Asset Setup
Add to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/empty_states/
    - assets/images/onboarding/
    - assets/images/illustrations/
    - assets/animations/
    - assets/icons/badges/
```

---

## 💰 Cost Estimates

### Option 1: Free Resources
| Source | Assets | Cost |
|--------|--------|------|
| Undraw.co | Illustrations (recolor) | Free |
| LottieFiles | 5-10 animations | Free |
| Flaticon | Icons/badges | Free (with attribution) |
| **Total** | | **$0** |

### Option 2: Premium Resources  
| Source | Assets | Cost |
|--------|--------|------|
| Envato Elements | Illustration pack | ~$16.50/mo |
| LottieFiles Premium | Animations | ~$19/mo |
| Iconscout | Icon/badge pack | ~$12/mo |
| **Total** | | **~$50/mo or ~$200 one-time** |

### Option 3: Custom Design
| Service | Deliverables | Cost |
|---------|-------------|------|
| Fiverr (mid-tier) | 10 illustrations | ~$200-400 |
| 99designs | Full illustration set | ~$500-1000 |
| Dedicated illustrator | Complete package | ~$1000-2000 |

**Recommendation:** Start with Option 1 (free), upgrade P0 items with Option 2 if budget allows.

---

## ⏱️ Time Estimates (If Custom)

| Asset Category | Count | Design Time | Total Hours |
|---------------|-------|-------------|-------------|
| Empty States | 11 | 2h each | 22h |
| Onboarding | 8 | 3h each | 24h |
| Error States | 5 | 1.5h each | 7.5h |
| Feature Illustrations | 7 | 2h each | 14h |
| Achievement Badges | 10 (gold/platinum only) | 1h each | 10h |
| Lottie Customization | 5 | 1h each | 5h |
| **Total** | | | **~82.5 hours** |

---

## 🚀 Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
- [ ] Set up `assets/` folder structure
- [ ] Update `pubspec.yaml` with asset paths
- [ ] Add `lottie` package to dependencies
- [ ] Create asset loading utilities

### Phase 2: P0 Must-Haves (Week 2-3)
- [ ] E01: Empty tanks illustration
- [ ] E02: Empty lessons illustration  
- [ ] O01-O03: Onboarding illustrations (3)
- [ ] Verify app icons for all platforms

### Phase 3: P1 Should-Haves (Week 3-4)
- [ ] L01-L05: Core Lottie animations (5)
- [ ] E03-E06: Additional empty states (4)
- [ ] F05-F06: Hearts out & Streak lost
- [ ] S01-S02: Error illustrations

### Phase 4: P2 Nice-to-Haves (Week 5+)
- [ ] Remaining empty states
- [ ] Achievement badge upgrades (gold/platinum)
- [ ] Additional Lottie animations
- [ ] Feature-specific illustrations

---

## 📚 Recommended Free Resources

### Illustrations
- [Undraw](https://undraw.co) - Customizable colors, MIT license
- [Drawkit](https://drawkit.com) - Free packs available
- [Open Peeps](https://openpeeps.com) - Hand-drawn style
- [Blush](https://blush.design) - Mix & match illustrations

### Animations
- [LottieFiles Free](https://lottiefiles.com/free-animations) - Many free options
- [Lordicon](https://lordicon.com) - Animated icons
- [Lottie Lab](https://lottielab.com) - Create custom

### Icons
- [Material Icons](https://fonts.google.com/icons) - Already using ✅
- [Heroicons](https://heroicons.com) - Alternative style
- [Feather Icons](https://feathericons.com) - Lightweight

---

## 🔍 Visual Inconsistencies to Address

1. **Achievement Display:** Mix of emoji and text - consider consistent approach
2. **Empty States:** Currently icon + colored circle - upgrade to illustrations
3. **Onboarding:** Large Material Icons feel generic - need custom illustrations
4. **Loading States:** Plain CircularProgressIndicator - could be themed fish animation
5. **Error States:** Good but generic - add fish-themed illustrations

---

## ✅ Next Steps

1. **Approve style direction** - Confirm flat + soft gradients approach
2. **Prioritize assets** - Confirm P0 items list
3. **Source decision** - Free resources vs. custom vs. purchase
4. **Create folder structure** - Set up assets directory
5. **Begin Phase 2** - Start with onboarding illustrations

---

*Document maintained by: Asset Planning Agent*
*For questions: Update this document or check with main agent*
