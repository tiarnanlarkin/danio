# 🐠 AQUARIUM APP — MASTER ROADMAP

**Version:** 5.0  
**Created:** 2026-02-13  
**Status:** Single Source of Truth  
**Sections:** Performance, UI, UX, Gamification, Testing & Development Workflow

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
| **Test Coverage** | Unit: Good, Widget: Starting, E2E: None | Building test suite |
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
- ✅ Widget test infrastructure ready

### What's Left by Category
| Category | Priority | Hours | Status |
|----------|----------|-------|--------|
| **Performance** | P0 | 5-7h | 🔴 Critical |
| **UI Polish** | P1 | 10-15h | 🟡 High |
| **User Flow** | P1 | 8-12h | 🟡 High |
| **Gamification Excellence** | P1-P2 | 12-18h | 🟡 High |
| **Microinteractions** | P2 | 8-12h | 🟢 Medium |
| **Test Suite Development** | P1-P2 | 15-20h | 🟡 High |
| **Logic/Architecture** | P2 | 8-10h | 🟢 Medium |
| **Total** | | **66-94 hours** | |

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

# 🧪 TEST SUITE & DEVELOPMENT WORKFLOW

## Why Widget Tests Are Game-Changing

### Old Workflow (Emulator) ❌
```
Start emulator (~2 min) → Build app (~1 min) → Install (~30s) → 
Navigate manually → Take screenshot → Analyze → Repeat
Total: 3-5 minutes per check
```

### New Workflow (Widget Tests) ✅
```
Write test → Run `flutter test` → See results in 3 seconds → Fix → Repeat
Total: 3-10 seconds per check
```

| Aspect | Emulator | Widget Tests |
|--------|----------|--------------|
| **Speed** | 3-5 min/check | 3-10 sec/check |
| **Automation** | Manual navigation | Fully automated |
| **Reliability** | Flaky, timing issues | Deterministic |
| **CI/CD Ready** | Complex setup | Works out of box |
| **Debugging** | Screenshots, guessing | Clear assertions |

## What Widget Tests Can Do

### ✅ Can Test (No Emulator Needed)
- Screen rendering and layout
- Button taps and interactions
- Text input and forms
- Navigation flows
- State changes (Riverpod)
- Loading states
- Error states
- Empty states
- Form validation
- Conditional UI

### ❌ Still Needs Emulator
- Camera/photo picker
- Push notifications
- File system access
- Real performance profiling
- Platform-specific features

## Test Suite Architecture

```
test/
├── widget_test.dart              # App boot test ✅
├── screens/
│   ├── create_tank_test.dart     # ✅ Started
│   ├── home_screen_test.dart     # Priority
│   ├── learn_screen_test.dart    # Priority
│   ├── settings_test.dart        # Priority
│   ├── tank_detail_test.dart     # Priority
│   └── add_log_test.dart         # Priority
├── widgets/
│   ├── app_card_test.dart
│   ├── app_button_test.dart
│   ├── empty_state_test.dart
│   └── celebration_test.dart
├── flows/
│   ├── onboarding_flow_test.dart
│   ├── create_tank_flow_test.dart
│   └── complete_lesson_flow_test.dart
├── models/                        # ✅ 7 files exist
├── services/                      # ✅ 5 files exist
└── providers/                     # ✅ 1 file exists
```

## Priority Test Suite (P1)

### Phase 1: Core Screens (8h)
| Screen | Tests | Purpose |
|--------|-------|---------|
| `home_screen` | 5-7 | Dashboard renders, tanks display, nav works |
| `create_tank_screen` | 5-7 | Form inputs, validation, creation flow |
| `learn_screen` | 5-7 | Lessons display, progress, navigation |
| `add_log_screen` | 5-7 | Parameter input, validation, saving |
| `settings_screen` | 3-5 | Settings render, toggles work |

### Phase 2: User Flows (6h)
| Flow | Tests | Purpose |
|------|-------|---------|
| Onboarding | 5-7 | Complete flow from welcome to home |
| Create Tank | 3-5 | Full tank creation journey |
| Complete Lesson | 3-5 | Start to finish with XP |
| Log Parameters | 3-5 | Add water test, see in history |

### Phase 3: Components (4h)
| Component | Tests | Purpose |
|-----------|-------|---------|
| AppCard | 3-4 | Variants render correctly |
| AppEmptyState | 3-4 | All types display properly |
| Celebrations | 2-3 | Confetti, XP popup trigger |
| Forms | 3-4 | Validation, error states |

## Test Development Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/screens/create_tank_test.dart

# Run with verbose output
flutter test --reporter expanded

# Run tests matching pattern
flutter test --name "CreateTank"

# Generate coverage report
flutter test --coverage
```

## Example Test Pattern

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aquarium_app/screens/home_screen.dart';
import 'package:aquarium_app/theme/app_theme.dart';

void main() {
  group('HomeScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
      });
    });

    testWidgets('displays tank cards when tanks exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify tanks are displayed
      expect(find.byType(TankCard), findsWidgets);
    });

    testWidgets('shows empty state when no tanks', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tankListProvider.overrideWithValue([]), // Empty
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.text('Create your first tank'), findsOneWidget);
    });

    testWidgets('navigates to create tank on FAB tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify navigation (or dialog)
      expect(find.byType(CreateTankScreen), findsOneWidget);
    });
  });
}
```

## AI-Assisted Test Development Workflow

### How Claude Can Help

1. **Write Tests** — Claude writes widget tests based on screen requirements
2. **Run Tests** — User runs `flutter test`, shares results
3. **Fix Issues** — Claude analyzes failures, fixes code or tests
4. **Iterate** — Repeat until all tests pass

### Workflow Example
```
User: "Test the create tank screen"

Claude: *writes test file*

User: *runs* `flutter test test/screens/create_tank_test.dart`
       *shares output*

Claude: "4/5 passed. The volume test failed because the label is 
        'Tank Size' not 'Volume'. Let me fix that..."
        *updates test*

User: *runs again*
       "All tests passed!"

Claude: "Great! Let's add tests for validation errors next..."
```

## Current Test Coverage

### Existing Tests ✅
| Area | Files | Assertions |
|------|-------|------------|
| Models | 7 | ~300 |
| Services | 5 | ~400 |
| Providers | 1 | ~50 |
| Widget (app boot) | 1 | ~10 |
| **Total** | **14** | **~760** |

### Target Coverage (3 months)
| Area | Current | Target |
|------|---------|--------|
| Unit (models/services) | 35% | 70% |
| Widget (screens) | 0% | 50% |
| Integration (flows) | 0% | 30% |
| E2E (Patrol) | 0% | 5 journeys |

## E2E Testing (Future)

### Option 1: Maestro (YAML-based)
```yaml
# test_flows/create_tank.yaml
appId: com.tiarnanlarkin.aquarium.aquarium_app
---
- launchApp
- tapOn: "Create Tank"
- inputText:
    id: "tank_name_field"
    text: "My Test Tank"
- tapOn: "Freshwater"
- tapOn: "Create"
- assertVisible: "My Test Tank"
```

### Option 2: Patrol (Dart-based)
```dart
patrolTest('User can create tank', ($) async {
  await $.tap(find.text('Create Tank'));
  await $.enterText(find.byKey(Key('tank_name')), 'My Tank');
  await $.tap(find.text('Create'));
  expect(find.text('My Tank'), findsOneWidget);
});
```

**Recommendation:** Start with widget tests (no emulator), add E2E later for critical journeys.

---

# 🎨 UI POLISH

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
| AppButton (with variants) | ⏳ Needed | Medium |
| AppEmptyState | ⏳ Needed | High |

---

# ✨ MICROINTERACTIONS

### P1 — High Impact, Low Effort
| Interaction | Status | Hours |
|-------------|--------|-------|
| Button press scale (0.95x) + haptic | ⏳ | 2h |
| Hero animations (tank cards → detail) | ⏳ | 3h |
| Error shake animation | ⏳ | 1h |
| Check mark bounce on completion | ⏳ | 1h |

### P2 — Medium Effort
| Interaction | Status | Hours |
|-------------|--------|-------|
| Pull-to-refresh | ⏳ | 2h |
| Swipe-to-delete on lists | ⏳ | 3h |
| Skeleton shimmer enhancement | ⏳ | 1h |

---

# 🎭 EMPTY STATES

## Priority Empty States
| Screen | Target | Priority |
|--------|--------|----------|
| No tanks | Mascot + fishbowl + CTA | P1 |
| No livestock | Fish silhouettes + CTA | P1 |
| No logs | Journal illustration + CTA | P1 |
| All tasks done | Celebratory mascot | P2 |

---

# 🧠 HOOK MODEL & GAMIFICATION

## Variable Rewards (Missing)
| Feature | Description | Hours |
|---------|-------------|-------|
| Mystery gem bonus | Random 2x-5x multiplier | 3h |
| Daily challenge | Different each day | 4h |
| Combo multiplier | Quiz streak = 2x, 3x XP | 2h |

## Gamification Upgrades
| Feature | Priority | Hours |
|---------|----------|-------|
| Achievement unlock celebration | P1 | 3h |
| Streak intensity animation | P1 | 2h |
| Daily challenge system | P1 | 4h |
| Milestone celebrations | P2 | 2h |

---

# 🚶 USER FLOW

## Onboarding Overhaul
| Task | Priority | Hours |
|------|----------|-------|
| Reduce to 4-5 screens | P1 | 3-4h |
| Add "Skip" option | P1 | 1h |
| Add back buttons | P1 | 30 min |

## Navigation
| Task | Current | Target |
|------|---------|--------|
| GoRouter migration | 105 Navigator.push | 0 |

---

# 🧠 LOGIC & ARCHITECTURE

### P1 — Error Handling
- Add try/catch to async operations
- Add offline connectivity banner
- Add user-friendly error messages

### P2 — State Management
- Migrate heavy setState screens to Riverpod
- Split large files (>20k lines)

---

# ⏱️ TIME ESTIMATES

| Priority | Hours | Calendar |
|----------|-------|----------|
| P0 Critical | 5-7h | 1-2 days |
| P1 High | 30-40h | 1-2 weeks |
| P2 Medium | 25-35h | 1-2 weeks |
| P3 Future | 15-25h | Ongoing |
| **Total** | **75-107h** | **4-6 weeks** |

---

# 🚀 IMPLEMENTATION ROADMAP

## Week 1-2: Performance + Testing Foundation
- [ ] Fix withOpacity() in top 5 files
- [ ] Convert livestock_screen to ListView.builder
- [ ] Write widget tests for 5 core screens
- [ ] Remove duplicate Water Change Calculator

## Week 3-4: Gamification + User Flow
- [ ] Achievement unlock celebration
- [ ] Daily challenge system
- [ ] Reduce onboarding to 4-5 screens
- [ ] Widget tests for user flows

## Week 5-6: Microinteractions + Polish
- [ ] Button press feedback
- [ ] Hero animations
- [ ] Empty states with mascot
- [ ] Streak intensity upgrades

## Week 7-8: Architecture + E2E
- [ ] Begin GoRouter migration
- [ ] Settings restructure
- [ ] Set up Maestro/Patrol for E2E
- [ ] CI/CD integration

---

# 🎯 SUCCESS METRICS

## After P0+P1 (2 weeks)
| Metric | Current | Target |
|--------|---------|--------|
| Widget test coverage | 0% | 30% |
| Performance issues | 4 | 0 |
| Achievement celebration | None | Full-screen |

## After All (6-8 weeks)
| Metric | Current | Target |
|--------|---------|--------|
| Widget test coverage | 0% | 60% |
| UI Grade | B- | A- |
| Onboarding taps | 12-25 | 6-8 |
| E2E journeys tested | 0 | 5 |

---

# 📚 RESOURCES

- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Patrol Framework](https://patrol.leancode.co/)
- [Maestro Testing](https://maestro.dev/)
- [Widget Test Best Practices](https://www.browserstack.com/guide/flutter-test-automation)

---

*This is the single source of truth. Update as work progresses.*

**Last Updated:** 2026-02-13
