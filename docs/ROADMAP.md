# 🐠 AQUARIUM APP — MASTER ROADMAP

**Version:** 4.0  
**Created:** 2026-02-13  
**Status:** Single Source of Truth  
**Sections:** Performance, UI, UX Excellence, User Flow, Gamification, Testing

---

## 📋 Executive Summary

### Current State
| Metric | Status | Notes |
|--------|--------|-------|
| **Total Screens** | 86 | Fully functional |
| **Features** | 150+ | Core gamification complete |
| **Species Database** | 122 | Comprehensive |
| **Plant Database** | 52 | Comprehensive |
| **Achievements** | 55 | All implemented |
| **Test Coverage** | Unit: Good, Widget: None, E2E: None | Gaps in UI testing |
| **UI Grade** | B- | Solid foundation, needs polish |
| **UX Grade** | C+ | Onboarding too long, nav inconsistent |

### What's Done ✅
- ✅ Complete gamification system (XP, gems, hearts, streaks, achievements)
- ✅ 50+ structured lessons with spaced repetition
- ✅ Full tank management (CRUD, parameters, photos, equipment)
- ✅ 8 calculators and tools
- ✅ Room navigation system with 6 themed backgrounds
- ✅ Celebration animations (confetti, XP popups, level up)
- ✅ Skeleton loaders on key screens
- ✅ Day/night ambient lighting
- ✅ Mascot speech bubble system
- ✅ 94% Card → AppCard migration

### What's Left by Category
| Category | Priority | Hours | Status |
|----------|----------|-------|--------|
| **Performance** | P0 | 5-7h | 🔴 Critical |
| **UI Polish** | P1 | 10-15h | 🟡 High |
| **User Flow** | P1 | 8-12h | 🟡 High |
| **Gamification Excellence** | P1-P2 | 12-18h | 🟡 High |
| **Microinteractions** | P2 | 8-12h | 🟢 Medium |
| **Logic/Architecture** | P2 | 8-10h | 🟢 Medium |
| **Automated Testing** | P2-P3 | 20-30h | 🔵 Ongoing |
| **Total** | | **71-104 hours** | |

---

# 🔴 P0 — CRITICAL PERFORMANCE

### Performance Issues — Will Cause Jank

| Issue | Location | Count/Impact | Fix Time |
|-------|----------|--------------|----------|
| **withOpacity() calls** | Multiple files | 584 calls → GC pressure | 3-4h |
| **Non-builder ListView** | `livestock_screen.dart` | 100-300ms jank | 30 min |
| **Nested ScrollView** | `photo_gallery_screen.dart` | Defeats lazy loading | 45 min |
| **.map() in lists** | ~20 screens | Poor list performance | 2h |

**Top withOpacity() offenders:**
```
exercise_widgets.dart    — 28 calls
home_screen.dart         — 22 calls
room_scene.dart          — 16 calls
lesson_screen.dart       — 16 calls
theme_gallery_screen.dart — 14 calls
```

**Fix:** Add pre-computed alpha colors to `app_theme.dart`:
```dart
static const Color primaryAlpha10 = Color(0x1A2196F3);
static const Color primaryAlpha20 = Color(0x332196F3);
static const Color overlayLight50 = Color(0x80FFFFFF);
static const Color overlayDark50 = Color(0x80000000);
```

### Code Cleanup (P0)
| Issue | Location | Fix Time |
|-------|----------|----------|
| Duplicate Water Change Calculator | `settings_screen.dart` | 15 min |
| Dead code `_VolumeCalculatorSheet` | `workshop_screen.dart` | 15 min |
| Placeholder() widgets | `mini_analytics_widget.dart` | 30 min |

---

# 🎨 UI POLISH

## Current State
- **Design System:** Excellent foundation but ~0% adoption
- **Component Library:** 94% Card → AppCard complete, 339 inline widgets remain
- **Theming:** Dark mode works, 30+ hardcoded colors leak through

## P1 — Visual Consistency
| Issue | Count | Fix Time |
|-------|-------|----------|
| Remaining `Card()` widgets | ~30 | 1-2h |
| Hardcoded `Colors.xxx` | 30+ | 2h |
| SizedBox → AppSpacing | ~300 | 2-3h |
| BorderRadius → AppRadius | ~100 | 1-2h |
| Empty onTap handlers | 3 | 15 min |

## P2 — Component Library Expansion
| Component | Status | Priority |
|-----------|--------|----------|
| AppCard | ✅ Done | - |
| AppListTile | ✅ Done | - |
| NavListTile | ✅ Done | - |
| AppButton (with variants) | ⏳ Needed | Medium |
| AppTextField | ⏳ Needed | Medium |
| AppEmptyState | ⏳ Needed | High |

---

# ✨ MICROINTERACTIONS (Every Tap Should Delight)

## Why It Matters
Best-in-class apps make every interaction feel alive:
- **Asana:** Unicorn flies across screen on task completion
- **Tinder:** Physics-based card swipe
- **Telegram:** Message bounce on send
- **Calm:** Slow fade transitions matching brand

## Microinteraction Checklist

### P1 — High Impact, Low Effort
| Interaction | Status | Hours |
|-------------|--------|-------|
| Button press scale (0.95x) + haptic | ⏳ | 2h |
| Hero animations (tank cards → detail) | ⏳ | 3h |
| Error shake animation on invalid input | ⏳ | 1h |
| Check mark bounce on task completion | ⏳ | 1h |

### P2 — Medium Effort
| Interaction | Status | Hours |
|-------------|--------|-------|
| Pull-to-refresh with custom indicator | ⏳ | 2h |
| Skeleton shimmer enhancement | ⏳ | 1h |
| Page slide transitions (improve) | ✅ Partial | 2h |
| Swipe-to-delete on lists | ⏳ | 3h |

### P3 — Polish
| Interaction | Status | Hours |
|-------------|--------|-------|
| Sound effects (optional) | ⏳ | 2h |
| Parallax on room transitions | ⏳ | 3h |
| Scroll fade-in for list items | ⏳ | 2h |

---

# 🎭 EMPTY STATES (Turn Nothing Into Something)

## Why It Matters
Empty states are:
- First impression for new users
- Opportunity to guide next action
- Brand personality moment

## Three Types

### 1. Informational
**Use when:** User needs context
**Example:** "Water tests will appear here once you log them"

### 2. Action-Oriented  
**Use when:** User should do something
**Example:** "No tanks yet! Create your first tank" + CTA button

### 3. Celebratory
**Use when:** Empty = success
**Example:** "All caught up! 🎉 Your tank is in great shape"

## Priority Empty States to Design

| Screen | Current | Target | Priority |
|--------|---------|--------|----------|
| No tanks | Generic | Mascot + empty fishbowl + "Create first tank!" | P1 |
| No livestock | Text only | Fish silhouettes + "Add your first fish!" | P1 |
| No logs | Text only | Journal illustration + "Start logging!" | P1 |
| No achievements | Text only | Trophy case + "Complete lessons to earn!" | P2 |
| All tasks done | Nothing | Celebratory mascot relaxing | P2 |
| Search no results | Generic | "No fish found" + filter suggestions | P2 |

## Empty State Component
```dart
class AppEmptyState extends StatelessWidget {
  final String illustration;  // Asset path or mascot
  final String headline;      // "No tanks yet!"
  final String? subtext;      // Optional helper text
  final String ctaLabel;      // "Create your first tank"
  final VoidCallback onCtaPressed;
  final bool showMascot;      // Use Finn instead of illustration
}
```

---

# 🧠 THE HOOK MODEL (Habit Formation)

## What It Is
Nir Eyal's model explains why apps like Duolingo become daily habits:

```
TRIGGER → ACTION → VARIABLE REWARD → INVESTMENT → (repeat)
```

## Current vs Target

| Stage | Current | Upgrade |
|-------|---------|---------|
| **Trigger** | Basic reminders | "Your streak is at risk! 🔥" + smart alerts |
| **Action** | Log water, complete lesson | One-tap quick log, 30-second lessons |
| **Reward** | XP, gems (predictable) | **Variable rewards** (see below) |
| **Investment** | Tank data, streaks | Photo memories, social sharing |

## Variable Rewards (The Secret Sauce)

**Why:** Predictable rewards become boring. Variable rewards create anticipation.

### P1 — Quick Wins
| Feature | Description | Hours |
|---------|-------------|-------|
| Mystery gem bonus | Random 2x-5x multiplier on some actions | 3h |
| Daily challenge | Different challenge each day | 4h |
| Combo multiplier | Consecutive quiz answers = 2x, 3x XP | 2h |

### P2 — Medium Effort
| Feature | Description | Hours |
|---------|-------------|-------|
| Hidden achievements | Discover unexpectedly | 3h |
| Mascot mood variations | Finn reacts differently each session | 2h |
| Weekly treasure chest | Random reward | 4h |

### P3 — Future
| Feature | Description | Hours |
|---------|-------------|-------|
| Weekly league | Compete with 30 random users | 8h |
| Friend challenges | Challenge friends to beat streak | 6h |
| Seasonal events | Limited-time challenges | 10h |

---

# 🎮 GAMIFICATION EXCELLENCE

## Current vs Duolingo Comparison

| Feature | Duolingo | Aquarium App | Gap |
|---------|----------|--------------|-----|
| Streak protection | ✅ Freeze item | ✅ Have | None |
| Streak celebration | 🔥 Fire intensifies | Basic | Enhance |
| League system | ✅ Weekly competition | ❌ None | Major |
| Variable rewards | ✅ Mystery chests | ❌ None | Add |
| Daily challenges | ✅ Different each day | ❌ None | Add |
| Combo multiplier | ✅ Answer streaks | ❌ None | Add |
| Achievement celebration | ✅ Full-screen | ❌ None | Add |

## Gamification Upgrades

### P1 — High Impact
| Feature | Impact | Hours |
|---------|--------|-------|
| Achievement unlock celebration (full-screen + confetti) | 🔥 Major | 3h |
| Streak intensity animation (fire grows at 7, 30, 100 days) | High | 2h |
| Combo multiplier in quizzes | High | 2h |
| Daily challenge system | High | 4h |

### P2 — Medium Impact
| Feature | Impact | Hours |
|---------|--------|-------|
| Mystery bonus rewards | Medium | 3h |
| Milestone celebrations (100 XP, 1000 XP, etc.) | Medium | 2h |
| Achievement tiers (Bronze → Silver → Gold) | Medium | 4h |
| Streak calendar visualization | Medium | 3h |

## Streak Psychology

**Key stats:**
- Users with 7+ day streaks are **2.3x more likely** to return daily
- Apps with streaks + milestones see **40-60% higher DAU**
- Loss aversion makes streaks powerful — users feel losses 2x more than gains

**Upgrades:**
- [ ] "Streak at risk!" notification 2 hours before midnight
- [ ] Streak recovery option (one-time, costs gems)
- [ ] Streak milestones: 7, 14, 30, 60, 100, 365 days
- [ ] Visual streak calendar showing history

---

# 🚶 USER FLOW

## Onboarding Overhaul

### Current Flow (Too Long)
```
Welcome → Experience → Goals → Tank Type → Tank Name → Tank Size → 
Tank Setup → Assessment → Results → Home (12-25 taps)
```

### Target Flow (Duolingo-Style)
```
Welcome (1 tap) → Goal (1 tap) → Tank basics (2-3 taps) → 
Celebration → Home (6-8 taps)
```

### Implementation
| Task | Priority | Hours |
|------|----------|-------|
| Reduce onboarding to 4-5 screens | P1 | 3-4h |
| Add "Skip, I'm experienced" link | P1 | 1h |
| Add back button to all screens | P1 | 30 min |
| Move assessment to optional | P2 | 2h |

## Navigation Consistency

| Task | Current | Target | Hours |
|------|---------|--------|-------|
| Migrate to GoRouter | 105 Navigator.push | 0 | 4-6h |
| Deep linking support | None | Full | Included |

## Settings Restructure

**Current:** 47+ items in one list

**Target:** 7 categories
```
Settings
├── Account & Profile
├── Tank Preferences  
├── Learning & Goals
├── Notifications
├── Appearance
├── Data & Privacy
└── About & Support
```

---

# 🎯 PERSONALIZATION

## Personalization Tiers

### Tier 1: Basic ✅ (Have)
- User's name in greetings
- Goal-based content
- Experience level

### Tier 2: Behavioral (Partial)
| Feature | Status | Hours |
|---------|--------|-------|
| Recently used tools | ⏳ | 2h |
| "Continue where you left off" | ⏳ | 2h |
| Favorite species | ⏳ | 3h |

### Tier 3: Contextual (Opportunity)
| Feature | Status | Hours |
|---------|--------|-------|
| Time-of-day greeting | ⏳ | 1h |
| Tank age milestones | ⏳ | 2h |
| Streak-aware mascot dialogue | ⏳ | 2h |
| Parameter trend alerts | ⏳ | 4h |

---

# 🧪 AUTOMATED TESTING

## Current State
| Type | Files | Assertions | Status |
|------|-------|------------|--------|
| Unit Tests | 24 | 1,158 | ✅ Good |
| Widget Tests | 0 | 0 | 🔴 Missing |
| Integration Tests | 0 | 0 | 🔴 Missing |
| Golden Tests | 0 | 0 | 🔴 Missing |
| E2E Tests | 0 | 0 | 🔴 Missing |

## Testing Strategy

### Testing Pyramid
```
        /\        E2E (Patrol) — 5-10 critical journeys
       /  \       
      /    \      Widget Tests — 20-30 core screens
     /------\     
    /        \    
   /----------\   Unit Tests — 1,158+ assertions ✅
```

### Frameworks
| Type | Framework | Setup |
|------|-----------|-------|
| Widget | flutter_test (built-in) | Ready |
| Golden | alchemist | `alchemist: ^0.10.0` |
| E2E | Patrol | `patrol: ^3.0.0` |

### Implementation Plan
| Phase | Focus | Hours |
|-------|-------|-------|
| Phase 1 | Widget tests for 5 core screens | 8h |
| Phase 2 | Golden tests for 10 components | 6h |
| Phase 3 | E2E tests for 5 user journeys | 10h |
| Phase 4 | CI/CD integration | 4h |
| **Total** | | **28h** |

---

# 🧠 LOGIC & ARCHITECTURE

## Issues to Address

### P1 — Error Handling
| Issue | Fix |
|-------|-----|
| Unhandled async errors | Add try/catch |
| No offline indicator | Add connectivity banner |
| Silent failures | Add user feedback |

### P2 — State Management
| Issue | Fix |
|-------|-----|
| Heavy setState screens (31, 16, 14 calls) | Migrate to Riverpod |
| Provider over-watching | Use `select()` |

### P2 — Large Files to Split
| File | Lines | Action |
|------|-------|--------|
| local_json_storage_service | 28,409 | Split by domain |
| user_profile_provider | 29,193 | Split by feature |
| spaced_repetition_provider | 21,552 | Consider splitting |

---

# ⏱️ TIME ESTIMATES

## By Priority
| Priority | Hours | Calendar |
|----------|-------|----------|
| P0 Critical | 5-7h | 1-2 days |
| P1 High | 25-35h | 1 week |
| P2 Medium | 30-40h | 1-2 weeks |
| P3 Future | 20-30h | Ongoing |
| **Total** | **80-112h** | **4-6 weeks** |

## By Category
| Category | P0 | P1 | P2 | P3 | Total |
|----------|----|----|----|----|-------|
| Performance | 5-7h | - | - | - | 5-7h |
| UI Polish | - | 6-8h | 4-6h | - | 10-14h |
| Microinteractions | - | 7-9h | 6-8h | 4-6h | 17-23h |
| Gamification | - | 11-14h | 8-12h | - | 19-26h |
| User Flow | - | 5-7h | 4-6h | - | 9-13h |
| Testing | - | - | 18-22h | 6-10h | 24-32h |
| Logic | - | 2-3h | 4-6h | - | 6-9h |

---

# 🚀 IMPLEMENTATION ROADMAP

## Week 1-2: Performance + Quick Wins
- [ ] Fix withOpacity() in top 5 files
- [ ] Convert livestock_screen to ListView.builder
- [ ] Remove duplicate Water Change Calculator
- [ ] Add button press feedback (scale + haptic)
- [ ] Add achievement unlock celebration

## Week 3-4: Gamification + User Flow
- [ ] Implement daily challenge system
- [ ] Add combo multiplier in quizzes
- [ ] Reduce onboarding to 4-5 screens
- [ ] Add "Skip" option for experienced users
- [ ] Design 3 priority empty states

## Week 5-6: Microinteractions + Polish
- [ ] Hero animations for tank cards
- [ ] Error shake animations
- [ ] Streak intensity upgrades
- [ ] Time-of-day greeting
- [ ] "Continue where you left off"

## Week 7-8: Testing + Architecture
- [ ] Set up widget testing framework
- [ ] Write tests for 5 core screens
- [ ] Set up golden testing
- [ ] Begin GoRouter migration
- [ ] Restructure Settings screen

---

# 🎯 SUCCESS METRICS

## After P0+P1 (2 weeks)
| Metric | Current | Target |
|--------|---------|--------|
| Performance issues | 4 critical | 0 |
| Onboarding taps | 12-25 | 6-8 |
| Achievement celebration | None | Full-screen |
| Daily challenge | None | Active |

## After All (6-8 weeks)
| Metric | Current | Target |
|--------|---------|--------|
| UI Grade | B- | A- |
| UX Grade | C+ | B+ |
| Microinteractions | 20% | 80% |
| Variable rewards | 0 | 5+ types |
| Test Coverage (widget) | 0% | 60% |
| DAU/MAU ratio | ? | 40%+ |

---

# 📚 RESEARCH SOURCES

- [Duolingo UX Breakdown](https://userguiding.com/blog/duolingo-onboarding-ux)
- [Hook Model by Nir Eyal](https://growthmethod.com/hooked-model/)
- [Streaks & Milestones Psychology](https://www.plotline.so/blog/streaks-for-gamification-in-mobile-apps)
- [Empty State UX](https://www.eleken.co/blog-posts/empty-state-ux)
- [Mobile UX Examples 2025](https://www.eleken.co/blog-posts/mobile-ux-design-examples)
- [Patrol Testing Framework](https://patrol.leancode.co/)

---

# 🏆 WHAT MAKES YOU UNIQUE

**No competitor combines:**
- 50+ structured lessons with spaced repetition
- Full tank management (CRUD, photos, equipment)
- XP/gems/hearts/streaks gamification
- Room navigation metaphor
- Mascot personality

**You are "Duolingo for fishkeeping" — own it!**

---

*This is the single source of truth. Update as work progresses.*

**Last Updated:** 2026-02-13
