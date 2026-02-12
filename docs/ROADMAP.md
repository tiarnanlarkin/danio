# 🐠 AQUARIUM APP — MASTER ROADMAP

**Version:** 3.0  
**Created:** 2026-02-13  
**Status:** Single Source of Truth  
**Sections:** Performance, UI, User Flow, Ease of Use, Logic, Testing

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
| **Ease of Use** | P2 | 10-15h | 🟢 Medium |
| **Logic/Architecture** | P2 | 8-10h | 🟢 Medium |
| **Automated Testing** | P2-P3 | 20-30h | 🔵 Ongoing |
| **Total** | | **61-89 hours** | |

---

# 🎨 UI POLISH

## Current State
- **Design System:** Excellent foundation (`AppSpacing`, `AppRadius`, `AppColors`) but ~0% adoption
- **Component Library:** 94% Card → AppCard migration complete, 339 inline widgets remain
- **Theming:** Dark mode works, but 30+ hardcoded `Colors.xxx` leak through
- **Animation:** Celebration system complete, micro-interactions partial

## UI Issues to Fix

### P0 — Critical Performance
| Issue | Count | Impact | Fix |
|-------|-------|--------|-----|
| `withOpacity()` calls | 584 | GC pressure, jank | Pre-compute alpha colors |
| Non-builder ListView | 1 critical | 100-300ms jank | Convert to `.builder` |
| Nested ScrollView | 1 | Defeats lazy loading | Remove `shrinkWrap` |

**Top withOpacity() files:**
```
exercise_widgets.dart    — 28 calls
home_screen.dart         — 22 calls
room_scene.dart          — 16 calls
lesson_screen.dart       — 16 calls
theme_gallery_screen.dart — 14 calls
```

### P1 — Visual Consistency
| Issue | Count | Fix Time |
|-------|-------|----------|
| Remaining `Card()` widgets | ~30 | 1-2h |
| Hardcoded `Colors.xxx` | 30+ | 2h |
| SizedBox → AppSpacing | ~300 | 2-3h |
| BorderRadius → AppRadius | ~100 | 1-2h |
| Empty onTap handlers | 3 | 15 min |

### P2 — Component Library Expansion
| Component | Status | Priority |
|-----------|--------|----------|
| AppCard | ✅ Done | - |
| AppListTile | ✅ Done | - |
| NavListTile | ✅ Done | - |
| AppButton (with variants) | ⏳ Needed | Medium |
| AppTextField | ⏳ Needed | Medium |
| AppChip/AppBadge | ⏳ Needed | Low |
| AppBottomSheet | ⏳ Needed | Low |

## UI Success Metrics
| Metric | Current | Target |
|--------|---------|--------|
| withOpacity calls | 584 | <50 |
| Hardcoded colors | 30+ | <10 |
| Design token usage | ~0% | 100% |
| Inline widgets | 339 | <100 |

---

# 🚶 USER FLOW

## Current State
- **Onboarding:** 6-8 screens, 12-25 taps to first tank
- **Navigation:** 105 `Navigator.push` calls, 0 GoRouter usage
- **Empty States:** 94 empty checks exist, but inconsistent handling
- **Error States:** Basic — usually just `Text('Error: $e')`

## Duolingo Comparison (Best in Class)
| Aspect | Duolingo | Aquarium App | Gap |
|--------|----------|--------------|-----|
| Onboarding steps | 6-7 | 8-10 | 2-3 extra |
| Taps to first action | 6-8 | 12-25 | 2-3x more |
| Skip option for experts | ✅ Yes | ❌ No | Missing |
| Learn by doing | ✅ Yes | ⚠️ Partial | Needs work |
| Progress indicator | ✅ Clear | ✅ Yes | Good |
| Personalization | ✅ Name + goals | ✅ Yes | Good |

## User Flow Improvements

### P1 — Onboarding Overhaul
**Current flow (too long):**
```
Welcome → Experience → Goals → Tank Type → Tank Name → Tank Size → 
Tank Setup → Assessment → Results → Home
```

**Target flow (Duolingo-style):**
```
Welcome (1 tap) → Goal (1 tap) → Tank basics (2-3 taps) → 
Celebration → Home
```

**Defer to later:**
- User name → Settings (or first log)
- Experience level → Pre-lesson prompt
- Placement test → Optional "Skip ahead?" card on Learn screen
- Detailed tank setup → Tank settings after creation

**Implementation:**
| Task | Priority | Hours |
|------|----------|-------|
| Reduce onboarding to 4-5 screens | P1 | 3-4h |
| Add "Skip, I'm experienced" link | P1 | 1h |
| Add back button to all screens | P1 | 30 min |
| Move assessment to optional | P2 | 2h |

### P1 — Navigation Consistency
| Task | Current | Target | Hours |
|------|---------|--------|-------|
| Migrate to GoRouter | 105 Navigator.push | 0 | 4-6h |
| Deep linking support | None | Full | Included |
| URL-based navigation | None | Yes | Included |

**Benefits of GoRouter:**
- Deep linking (users can bookmark/share specific screens)
- Declarative routing (easier to test)
- Type-safe parameters
- Better back button handling

### P2 — Empty State Improvements
**Current:** 94 empty checks, inconsistent handling

**Target:** Every list has:
1. Friendly illustration (mascot or custom)
2. Clear explanation of what goes here
3. Primary CTA to add first item
4. Secondary help link if relevant

**Priority screens:**
- [ ] No tanks → "Create your first tank!" + tank illustration
- [ ] No livestock → "Add your first fish!" + fish bowl
- [ ] No logs → "Start logging!" + journal
- [ ] No achievements → "Complete lessons to earn!" + trophy

### P2 — Error State Improvements
**Current:** `Text('Error: $e')` with no recovery

**Target:** Every error has:
1. User-friendly message (not stack trace)
2. "Retry" button
3. "Report Issue" for persistent errors
4. Automatic retry for network errors

---

# ✨ EASE OF USE

## Current State
- **Settings:** 47+ items in one scrollable list
- **Feature Discovery:** Many features buried (achievements in Settings)
- **Tooltips/Hints:** Minimal onboarding tooltips, no contextual help
- **Feedback:** Good haptics, celebration animations exist

## Ease of Use Improvements

### P1 — Feature Discoverability
| Issue | Impact | Fix |
|-------|--------|-----|
| Achievements buried in Settings | Low engagement | Move to bottom nav or home card |
| No achievement unlock celebration | No dopamine hit | Add full-screen celebration |
| Workshop tools hard to find | Low usage | Add "Recently Used" section |
| Guides scattered | Hard to learn | Add Knowledge Hub entry point |

### P2 — Settings Restructure
**Current:** 47+ items in one list

**Target structure:**
```
Settings (top level: 7 items)
├── Account & Profile
│   ├── Display name
│   ├── Experience level
│   └── Goals
├── Tank Preferences
│   ├── Default units
│   ├── Parameter ranges
│   └── Reminder defaults
├── Learning & Goals
│   ├── Daily goal
│   ├── Difficulty
│   └── Notifications
├── Appearance
│   ├── Theme
│   ├── Room style
│   └── Day/night mode
├── Data & Privacy
│   ├── Backup/Restore
│   ├── Export data
│   └── Delete account
└── About & Support
    ├── FAQ
    ├── Contact
    └── Version info
```

**Remove duplicates:** 10+ tools already in Workshop

### P2 — Contextual Help
| Feature | Implementation | Hours |
|---------|----------------|-------|
| First-time tooltips | Show once per feature | 2-3h |
| "What's this?" buttons | Info icons on complex screens | 2h |
| Mascot tips | Random helpful tips from mascot | 1h |
| Locked lesson explanation | "Complete X first" on tap | 1h |

### P3 — Quick Actions
| Feature | Description | Hours |
|---------|-------------|-------|
| Quick-log mode | 3 essential fields only | 2h |
| Recently used tools | Top of Workshop | 1h |
| Favorite species | Quick-add from favorites | 2h |
| Widget shortcuts | Home screen widgets (Android) | 4h |

---

# 🧠 LOGIC & ARCHITECTURE

## Current State
- **Services:** 20 service files with business logic
- **Providers:** 13 Riverpod providers for state
- **Error Handling:** 24 try blocks, 21 catch blocks in services
- **Validation:** 12 validation assertions in models

## Architecture Review

### Service Layer (lib/services/)
| Service | Lines | Tests | Status |
|---------|-------|-------|--------|
| local_json_storage_service | 28,409 | ✅ Yes | ⚠️ Very large |
| user_profile_provider | 29,193 | ⚠️ Partial | ⚠️ Very large |
| spaced_repetition_provider | 21,552 | ✅ Yes | ⚠️ Large |
| analytics_service | 20,412 | ✅ Yes | OK |
| achievement_service | 13,911 | ✅ Yes | OK |
| Other services | <15k | Varies | OK |

**Refactor candidates:** Files >20k lines should be split

### Logic Issues to Address

#### P1 — Error Handling Gaps
| Issue | Location | Fix |
|-------|----------|-----|
| Unhandled async errors | Various screens | Add try/catch |
| No offline indicator | App-wide | Add connectivity banner |
| Silent failures | Some services | Add user feedback |

#### P2 — State Management Cleanup
| Issue | Impact | Fix |
|-------|--------|-----|
| Heavy setState screens | Rebuilds, jank | Migrate to Riverpod |
| Provider over-watching | Unnecessary rebuilds | Use `select()` |
| Missing loading states | UI jumps | Add AsyncValue handling |

**setState heavy screens:**
```
add_log_screen.dart              — 31 setState
tank_volume_calculator_screen.dart — 16 setState
livestock_screen.dart            — 14 setState
charts_screen.dart               — 13 setState
```

#### P2 — Model Validation
| Gap | Impact | Fix |
|-----|--------|-----|
| No input validation | Bad data persists | Add validators |
| Null safety gaps | Runtime crashes | Audit models |
| Missing serialization tests | Data loss risk | Add tests |

---

# 🧪 AUTOMATED TESTING

## Current State

### Test Coverage by Type
| Type | Files | Assertions | Status |
|------|-------|------------|--------|
| Unit Tests | 24 | 1,158 | ✅ Good |
| Widget Tests | 0 | 0 | 🔴 Missing |
| Integration Tests | 0 | 0 | 🔴 Missing |
| Golden Tests | 0 | 0 | 🔴 Missing |
| E2E Tests | 0 | 0 | 🔴 Missing |

### Test Coverage by Layer
| Layer | Files | Tested | Coverage |
|-------|-------|--------|----------|
| Models | ~20 | 7 | 35% |
| Services | ~20 | 5 | 25% |
| Providers | ~13 | 1 | 8% |
| Widgets | ~50 | 0 | 0% |
| Screens | 86 | 0 | 0% |

### Screens Without Any Tests (30+ critical)
```
❌ home_screen          ❌ create_tank
❌ learn_screen         ❌ add_log
❌ settings_screen      ❌ charts
❌ tank_detail_screen   ❌ equipment
❌ livestock_screen     ❌ reminders
```

## Testing Strategy

### Recommended Testing Pyramid
```
        /\
       /  \     E2E Tests (Patrol)
      /    \    - Critical user journeys
     /------\   - 5-10 tests
    /        \  
   /  Widget  \ Widget Tests
  /   Tests    \ - Core screens
 /              \ - 20-30 tests
/----------------\
|   Unit Tests   | Unit Tests (existing)
|                | - Models, Services, Providers
|                | - 1,158+ assertions ✅
------------------
```

### P2 — Widget Testing Setup
**Framework:** Flutter's built-in `flutter_test`

**Priority screens to test:**
1. `home_screen.dart` — Main dashboard
2. `create_tank_screen.dart` — Core CRUD
3. `add_log_screen.dart` — Data entry
4. `learn_screen.dart` — Gamification
5. `settings_screen.dart` — Configuration

**Example widget test:**
```dart
testWidgets('Home screen shows tank cards', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [tankProvider.overrideWithValue(mockTanks)],
      child: MaterialApp(home: HomeScreen()),
    ),
  );
  
  expect(find.byType(TankCard), findsNWidgets(2));
  expect(find.text('My First Tank'), findsOneWidget);
});
```

### P2 — Golden Testing Setup
**Framework:** `alchemist` (2025 standard, replaces golden_toolkit)

**Purpose:** Visual regression testing — catch unintended UI changes

**Setup:**
```yaml
dev_dependencies:
  alchemist: ^0.10.0
```

**Priority components:**
1. AppCard variants
2. AppButton variants
3. Achievement badges
4. Empty states
5. Loading skeletons

### P3 — E2E Testing with Patrol
**Framework:** Patrol by LeanCode

**Why Patrol:**
- Native platform access (permissions, notifications)
- Hot restart for faster iteration
- Works with Firebase Test Lab
- Real device testing

**Setup:**
```yaml
dev_dependencies:
  patrol: ^3.0.0

# CLI
dart pub global activate patrol_cli
```

**Critical user journeys to test:**
1. **Onboarding → First tank** — New user experience
2. **Add livestock → View in tank** — Core CRUD
3. **Complete lesson → Earn XP** — Gamification
4. **Log water parameters → View chart** — Data flow
5. **Purchase shop item → Use item** — Economy

**Example Patrol test:**
```dart
patrolTest('User can create tank and add fish', ($) async {
  // Onboarding
  await $.tap(find.text('Get Started'));
  await $.tap(find.text('Track my tanks'));
  
  // Create tank
  await $.enterText(find.byType(TextField), 'My Tank');
  await $.tap(find.text('Create'));
  
  // Verify
  expect(find.text('My Tank'), findsOneWidget);
  
  // Add fish
  await $.tap(find.byIcon(Icons.add));
  await $.tap(find.text('Neon Tetra'));
  
  // Verify
  expect(find.text('Neon Tetra'), findsOneWidget);
});
```

### Testing Implementation Plan

| Phase | Focus | Tests | Hours |
|-------|-------|-------|-------|
| **Phase 1** | Widget test setup | 5 core screens | 8h |
| **Phase 2** | Golden test setup | 10 components | 6h |
| **Phase 3** | E2E with Patrol | 5 journeys | 10h |
| **Phase 4** | CI integration | GitHub Actions | 4h |
| **Total** | | | **28h** |

### CI/CD Integration
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter test --update-goldens # Optional
```

---

## 📊 COMPREHENSIVE TEST METRICS

### Target Coverage
| Type | Current | 3 Months | 6 Months |
|------|---------|----------|----------|
| Unit | 35% | 60% | 80% |
| Widget | 0% | 30% | 60% |
| Integration | 0% | 10% | 30% |
| E2E | 0% | 5 journeys | 10 journeys |

### Quality Gates (Future)
- [ ] All PRs require passing tests
- [ ] No decrease in coverage
- [ ] Golden tests must pass
- [ ] E2E smoke test on release

---

## ⏱️ TIME ESTIMATES BY CATEGORY

| Category | P0 | P1 | P2 | P3 | Total |
|----------|----|----|----|----|-------|
| Performance | 5-7h | - | - | - | 5-7h |
| UI Polish | - | 6-8h | 4-6h | - | 10-14h |
| User Flow | - | 6-8h | 4-6h | - | 10-14h |
| Ease of Use | - | 3-4h | 6-8h | 4-6h | 13-18h |
| Logic | - | 2-3h | 4-6h | - | 6-9h |
| Testing | - | - | 14-18h | 10-14h | 24-32h |
| **Total** | **5-7h** | **17-23h** | **32-44h** | **14-20h** | **68-94h** |

---

## 🎯 SUCCESS METRICS

### After P0+P1 (2 weeks)
| Metric | Current | Target |
|--------|---------|--------|
| Performance issues | 4 critical | 0 |
| Onboarding taps | 12-25 | 6-8 |
| Achievement celebration | None | Full-screen |
| GoRouter usage | 0% | 50%+ |

### After All (6-8 weeks)
| Metric | Current | Target |
|--------|---------|--------|
| UI Grade | B- | A- |
| UX Grade | C+ | B+ |
| Test Coverage (unit) | 35% | 80% |
| Test Coverage (widget) | 0% | 60% |
| E2E Journeys | 0 | 10 |
| Settings items | 47 | 25 |
| Navigator.push | 105 | 0 |

---

## 🚀 RECOMMENDED EXECUTION ORDER

### Week 1-2: Performance + Quick Wins
1. Fix withOpacity() in top 5 files
2. Convert livestock_screen to ListView.builder
3. Remove duplicate Water Change Calculator
4. Add achievement unlock celebration

### Week 3-4: User Flow
1. Reduce onboarding to 4-5 screens
2. Add "Skip" option for experienced users
3. Begin GoRouter migration
4. Improve empty states (3 priority screens)

### Week 5-6: Testing Foundation
1. Set up widget testing framework
2. Write tests for 5 core screens
3. Set up golden testing with alchemist
4. Create goldens for core components

### Week 7-8: Ease of Use + Polish
1. Restructure Settings screen
2. Add contextual tooltips
3. Set up Patrol for E2E
4. Write 5 critical journey tests

---

## 📁 REFERENCE

### Archived Documents
All legacy planning docs moved to `docs/archive/planning/`

### Research Sources
- [Duolingo UX Breakdown](https://userguiding.com/blog/duolingo-onboarding-ux)
- [Patrol Testing Framework](https://patrol.leancode.co/)
- [Flutter Golden Tests](https://solguruz.com/blog/flutter-golden-tests/)
- [Mobile Onboarding Best Practices 2026](https://www.designstudiouiux.com/blog/mobile-app-onboarding-best-practices/)

### Key Duolingo Patterns to Adopt
1. **Learn by doing** — First action within 6 taps
2. **Celebration on every achievement** — Full-screen for big wins
3. **Personalization from start** — Name, goals, preferences
4. **Empty states with mascot** — Encouraging, not blank
5. **Skip option for experts** — Respect user's time
6. **Progress always visible** — Streaks, XP, hearts in header

---

*This roadmap covers Performance, UI, User Flow, Ease of Use, Logic, and Testing. Update as work progresses.*

**Last Updated:** 2026-02-13
