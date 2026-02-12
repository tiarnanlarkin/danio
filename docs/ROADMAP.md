# 🐠 AQUARIUM APP — MASTER ROADMAP

**Version:** 2.0  
**Created:** 2026-02-13  
**Status:** Single Source of Truth  
**Consolidates:** 15+ legacy planning documents (now archived)

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
| **Test Coverage** | 98%+ | 435+ tests passing |
| **UI Grade** | B- | Solid foundation, needs polish |

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

### What's Left
| Priority | Category | Hours | Status |
|----------|----------|-------|--------|
| **P0** | Critical Performance | 5-7h | 🔴 Do Now |
| **P1** | High Priority Polish | 10-15h | 🟡 This Sprint |
| **P2** | Medium Priority | 15-20h | 🟢 Next Sprint |
| **P3** | Future Features | 30-50h | 🔵 Backlog |
| **Total Remaining** | | **60-92 hours** | |

---

## 🔴 P0 — CRITICAL (Do Immediately)

### Performance Issues — Will Cause Jank

| Issue | Location | Count/Impact | Fix Time |
|-------|----------|--------------|----------|
| **withOpacity() calls** | Multiple files | 584 calls → GC pressure | 3-4h |
| **Non-builder ListView** | `livestock_screen.dart` | 100-300ms jank | 30 min |
| **Nested ScrollView** | `photo_gallery_screen.dart` | Defeats lazy loading | 45 min |
| **.map() in lists** | ~20 screens | Poor list performance | 2h |

**Top withOpacity() offenders:**
1. `exercise_widgets.dart` — 28 calls
2. `home_screen.dart` — 22 calls
3. `room_scene.dart` — 16 calls
4. `lesson_screen.dart` — 16 calls
5. `theme_gallery_screen.dart` — 14 calls

**Fix:** Add pre-computed alpha colors to `app_theme.dart`:
```dart
static const Color primaryAlpha10 = Color(0x1A2196F3);
static const Color primaryAlpha20 = Color(0x332196F3);
static const Color overlayLight50 = Color(0x80FFFFFF);
static const Color overlayDark50 = Color(0x80000000);
```

### Navigation Inconsistency

| Issue | Current | Target |
|-------|---------|--------|
| Navigator.push calls | 105 | 0 |
| GoRouter usage | 0 | 100% |

**Impact:** No deep linking, inconsistent navigation patterns, harder to test.

### Code Cleanup

| Issue | Location | Fix Time |
|-------|----------|----------|
| Duplicate Water Change Calculator | `settings_screen.dart` | 15 min |
| Dead code `_VolumeCalculatorSheet` | `workshop_screen.dart` | 15 min |
| Placeholder() widgets | `mini_analytics_widget.dart` | 30 min |

---

## 🟡 P1 — HIGH PRIORITY (This Sprint)

### TODOs in Code (5 remaining)

| Location | TODO | Priority |
|----------|------|----------|
| `home_screen.dart:896` | Implement export functionality | High |
| `spaced_repetition_practice_screen.dart:45` | Display weak cards count | Medium |
| `achievement_service.dart:134` | Implement based on LessonContent.allPaths | Medium |
| `storage_error_handler.dart:178` | Copy error info to clipboard | Low |
| `spaced_repetition.dart:320` | REVIEW ATTEMPT (review code) | Low |

### "Coming Soon" Features

| Feature | Location | Complexity |
|---------|----------|------------|
| **Export functionality** | `home_screen.dart:899` | Medium |
| **Marine/Saltwater tanks** | `create_tank_screen.dart`, `tank_settings_screen.dart` | High |
| **Premium themes** | `theme_gallery_screen.dart` | Low |
| **DIY Projects** | `workshop_screen.dart:292` | Medium |

### Achievement System Polish

| Issue | Impact | Fix Time |
|-------|--------|----------|
| No celebration on unlock | Major dopamine loss | 2h |
| Achievements buried in Settings | Low discoverability | 1h |

**Fix:** Add `AchievementUnlockBanner` with confetti, trigger on unlock.

### UI Consistency

| Issue | Count | Fix Time |
|-------|-------|----------|
| Remaining Card() widgets | ~30 | 1-2h |
| Hardcoded Colors (raw `Colors.xxx`) | ~30+ | 2h |
| Empty onTap handlers | 3 | 15 min |

**Files with hardcoded colors:**
- `activity_feed_screen.dart` — 12 occurrences
- `algae_guide_screen.dart` — 11 occurrences
- `achievements_screen.dart` — 4 occurrences

---

## 🟢 P2 — MEDIUM PRIORITY (Next Sprint)

### Design System Consistency

| Task | Scope | Fix Time |
|------|-------|----------|
| Batch replace SizedBox → AppSpacing | ~300 occurrences | 2-3h |
| Batch replace BorderRadius → AppRadius | ~100 occurrences | 1-2h |
| Design token 100% adoption | Currently ~0% | 4-6h |

### setState Heavy Screens (Refactor Candidates)

| Screen | setState Count | Refactor to Riverpod? |
|--------|---------------|----------------------|
| `add_log_screen.dart` | 31 | ⚠️ Yes |
| `tank_volume_calculator_screen.dart` | 16 | Maybe |
| `livestock_screen.dart` | 14 | ⚠️ Yes |
| `charts_screen.dart` | 13 | Maybe |

### Settings Screen Restructure

**Current:** 47+ items in one scrollable list  
**Target:** ~25 items across sub-pages

```
Settings (simplified)
├── Account & Profile
├── Tank Preferences  
├── Learning & Goals
├── Notifications
├── Appearance
├── Data & Privacy
└── About & Support
```

### Accessibility Improvements

| Issue | Fix Time |
|-------|----------|
| SpeedDial missing Semantics | 30 min |
| ~12 interactive elements missing labels | 1h |
| SpeedDial button 44x44 → 48x48dp | 15 min |
| FocusTraversalGroup (2/40 screens) | 2h |

### Mascot Completion

| Task | Status |
|------|--------|
| MascotBubble widget | ✅ Done |
| Mascot in onboarding | ✅ Done |
| Mascot in empty states | ✅ Done |
| Rive file with expressions | ⏳ Needs artist |
| Mascot in achievements | ⏳ Pending |
| Fish behavior state machine | ⏳ In progress |

---

## 🔵 P3 — FUTURE FEATURES (Backlog)

### Phase 4: Backend & Cloud Sync
| Feature | Description | Complexity |
|---------|-------------|------------|
| User accounts | Email/Google/Apple login | High |
| Cloud sync | Sync data across devices | High |
| Photo cloud storage | Store photos in cloud | Medium |
| Community features | Share tanks, compare stats | High |

### Phase 5: Content Expansion
| Feature | Description | Complexity |
|---------|-------------|------------|
| Marine tank support | Full saltwater parameters | High |
| AI Fish ID | Identify species from photos | High |
| More species | Expand from 122 | Low |
| More plants | Expand from 52 | Low |

### Polish & Delight
| Feature | Description | Complexity |
|---------|-------------|------------|
| Hero animations | Tank cards → detail | Medium |
| Pull-to-refresh | Tank list, species browser | Low |
| Empty state illustrations | Custom SVG/Lottie | Medium |
| Sound effects | Optional audio feedback | Low |

### Testing Expansion
| Area | Current | Target |
|------|---------|--------|
| Unit tests | 435+ | Maintain |
| Widget tests | Minimal | Core screens |
| Integration tests | None | Key flows |

---

## 📊 Test Coverage

### Current Tests (24 files)
- ✅ achievement_service_test, achievement_test
- ✅ analytics_service_test
- ✅ backup_service_photo_zip_test
- ✅ daily_goal_test
- ✅ difficulty_service_test
- ✅ exercises_test
- ✅ hearts_system_test
- ✅ leaderboard_provider_test, leaderboard_test
- ✅ performance_monitor_test
- ✅ review_achievement_test, review_queue_service_test
- ✅ shop_service_test
- ✅ social_test
- ✅ spaced_repetition_test
- ✅ storage_error_handling_test, storage_race_condition_test
- ✅ story_test
- ✅ streak_calculation_test
- ✅ task_date_test
- ✅ widget_test

### Missing (Future)
- Widget tests for screens
- Integration tests for user flows
- Golden tests for UI

---

## ⏱️ Time Estimates

### By Priority
| Priority | Hours | Calendar |
|----------|-------|----------|
| P0 Critical | 5-7h | 1-2 days |
| P1 High | 10-15h | 3-4 days |
| P2 Medium | 15-20h | 1 week |
| P3 Future | 30-50h | Ongoing |
| **Total** | **60-92h** | **3-4 weeks** |

### Recommended Order
1. **Days 1-2:** P0 performance fixes (withOpacity, ListView.builder)
2. **Days 3-5:** P1 export feature, achievement celebration
3. **Week 2:** P1 remaining TODOs, UI consistency
4. **Week 3:** P2 design system, settings restructure
5. **Week 4+:** P3 as time allows

---

## ⚡ Quick Wins (<30 min each)

| Task | Time | Impact |
|------|------|--------|
| Remove duplicate Water Change Calculator | 15 min | Bug fix |
| Delete dead `_VolumeCalculatorSheet` | 15 min | Cleanup |
| Fix SpeedDial button size 44→48dp | 15 min | Accessibility |
| Replace Placeholder() in mini_analytics | 30 min | Bug fix |
| Fix empty onTap handlers (3) | 15 min | Cleanup |
| Convert livestock_screen to ListView.builder | 30 min | Performance |

---

## 📁 Archived Documents

The following documents have been consolidated into this roadmap and moved to `docs/archive/planning/`:

- `FINAL_DEV_ROADMAP.md`
- `UI_POLISH_ROADMAP.md`
- `UI_POLISH_ROADMAP_A_PLUS.md`
- `planning/UI_OVERHAUL_MASTER_PLAN.md`
- `planning/UI_AUDIT_REPORT.md`
- `planning/ROADMAP_*.md` (5 files)

### Reference Documents (Still Active)
| Document | Location | Purpose |
|----------|----------|---------|
| FEATURE_LIST.md | `docs/` | Complete feature inventory |
| README.md | `docs/` | Docs index |
| ui-audit/*.md | `docs/ui-audit/` | Detailed specs (reference only) |

---

## 🎯 Success Metrics

### Target After P0+P1
| Metric | Current | Target |
|--------|---------|--------|
| Performance issues | 4 critical | 0 |
| withOpacity calls | 584 | <50 |
| TODOs in code | 5 | 0 |
| "Coming soon" snackbars | 4 | 1 (Marine only) |

### Target After All
| Metric | Current | Target |
|--------|---------|--------|
| UI Grade | B- | B+ |
| Design token usage | ~0% | 100% |
| Hardcoded colors | 30+ | <10 |
| Navigator.push calls | 105 | 0 |
| GoRouter usage | 0% | 100% |

---

## 🚀 Next Action

**Start with P0 — biggest performance impact:**

```bash
# 1. Open app_theme.dart
# 2. Add pre-computed alpha colors
# 3. Run find/replace for withOpacity in top 5 files
# 4. Convert livestock_screen to ListView.builder
# 5. Test with DevTools Performance tab
```

**Estimated time to noticeable improvement: 4-5 hours**

---

*This is the single source of truth for Aquarium App development. All other planning docs have been archived.*

**Last Updated:** 2026-02-13
