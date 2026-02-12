# 🐠 FINAL DEV ROADMAP — Aquarium App

**Version:** 1.0  
**Created:** 2026-02-12  
**Purpose:** THE definitive document for remaining development work  
**Sources:** 6 audit reports consolidated

---

## 📋 Executive Summary

### Current State
| Metric | Status | Notes |
|--------|--------|-------|
| **Total Screens** | 86 | Fully functional |
| **UI Grade** | C+ → B- | Significant progress made |
| **Design System** | 72/100 | Foundation excellent, usage inconsistent |
| **Animations** | ✅ 70% done | Core celebration system complete |
| **Loading States** | ⚠️ Partial | Skeleton loaders added to key screens |
| **Performance** | 🔴 3 critical issues | Need immediate attention |

### Recent Progress (What's Done)
The UI Overhaul Master Plan shows **massive progress**:
- ✅ All dependencies added (flutter_animate, confetti, skeletonizer, etc.)
- ✅ Room identity system with 6 themed backgrounds
- ✅ Custom page transitions (slide, scale, fade)
- ✅ Micro-interactions (button feedback, haptics)
- ✅ Celebration system (XP gain, streaks, confetti, level up)
- ✅ Skeleton loaders on key screens
- ✅ Staggered list animations
- ✅ Day/night ambient lighting
- ✅ Mascot speech bubble system
- ✅ Empty state improvements with mascot

### Remaining Work
| Priority | Category | Estimated Hours |
|----------|----------|-----------------|
| **P0** | Critical Bugs & Performance | 6-8h |
| **P1** | UX Flow Fixes | 8-12h |
| **P2** | Design System Consistency | 10-15h |
| **P3** | Polish & Nice-to-Have | 15-25h |
| **Total** | | **39-60 hours** |

---

## ✅ Completed Work (Recent Sessions)

### Foundation (Week 1) — DONE ✅
- [x] Added all animation dependencies
- [x] Created `app_animations.dart` utility
- [x] Created `haptic_helper.dart` utility
- [x] 6 themed room backgrounds with ambient particles
- [x] Custom page transition routes
- [x] Interactive room objects (journal, calendar, microscope, globe, workbench)

### Micro-Interactions (Week 2) — DONE ✅
- [x] Enhanced button feedback (scale + haptic)
- [x] BubbleLoader and FishLoader replace spinners
- [x] Skeletonizer on equipment, tank detail, learn, home screens
- [x] Water ripple on tank tap
- [x] Staggered list entrance animations (livestock, equipment, logs, tank detail)

### Celebrations (Week 3) — DONE ✅
- [x] XP gain floating animation (+XP popup with star)
- [x] Streak fire with intensity scaling
- [x] Achievement confetti system (multiple blast types)
- [x] Onboarding completion celebration
- [x] Level up animation (full-screen overlay)

### Living Elements (Week 4) — 80% DONE
- [x] Downloaded 3 free CC BY fish Rive animations
- [x] Ambient bubbles in tank scenes
- [x] Plant sway animations
- [x] Day/night ambient lighting with settings toggle
- [ ] Fish behavior state machine (Rive integration in progress)

### Mascot (Week 5-6) — 70% DONE
- [x] MascotBubble widget with moods
- [x] Mascot in onboarding (welcome message)
- [x] Mascot in empty states (no tanks, no livestock, no logs)
- [ ] Rive file with all expressions (needs artist or DIY)
- [ ] Mascot in achievements

---

## 🔴 P0 — Critical (Do Immediately)

### Performance Bugs (Will Cause Visible Jank)

| Issue | File | Impact | Fix Time |
|-------|------|--------|----------|
| **Non-builder ListView** | `livestock_screen.dart` | 100-300ms jank with 50+ items | 30 min |
| **607 withOpacity() calls** | Multiple files | Thousands of GC allocations/sec | 2-3h |
| **Nested ScrollView antipattern** | `photo_gallery_screen.dart` | Defeats lazy loading | 45 min |

#### Fix: livestock_screen.dart
```dart
// Convert .map() to ListView.builder
ListView.builder(
  itemCount: livestock.length + 2,
  itemBuilder: (context, index) {
    if (index == 0) return _SummaryCard(...);
    if (index == 1 && _isSelectMode) return _SelectionBanner(...);
    return _LivestockCard(livestock: livestock[index - 1], ...);
  },
)
```

#### Fix: withOpacity() migration
Priority files (start here):
1. `room_scene.dart` — 48 occurrences
2. `home_screen.dart` — 35 occurrences
3. `widgets/*.dart` — 120+ combined

Add to `app_theme.dart`:
```dart
static const Color primaryAlpha10 = Color(0x1A2196F3);
static const Color primaryAlpha20 = Color(0x332196F3);
static const Color overlayLight = Color(0x80FFFFFF);
static const Color overlayDark = Color(0x80000000);
```

### Critical UX Bug

| Issue | Location | Fix Time |
|-------|----------|----------|
| **Duplicate Water Change Calculator** | `settings_screen.dart` | 15 min |
| **Dead code cleanup** | `workshop_screen.dart` (`_VolumeCalculatorSheet`) | 15 min |

---

## 🟡 P1 — High Priority (This Sprint)

### Achievement System (MAJOR ENGAGEMENT ISSUE)

| Issue | Impact | Fix Time |
|-------|--------|----------|
| **No immediate celebration on unlock** | Major dopamine loss, reduced retention | 2h |
| **Achievements buried in Settings** | Low discoverability | 1h |

**Fix: Achievement Unlock Banner**
- Trigger on `checkAchievements()` returning unlocked
- Show: Icon, title, XP/gems earned, confetti
- Add "View Trophy Case" CTA
- Play haptic feedback

**Fix: Achievement Visibility**
Option A: Add to bottom nav (recommended)  
Option B: Add prominent card on home dashboard

### Onboarding Friction

| Issue | Current | Target | Fix Time |
|-------|---------|--------|----------|
| **Too many taps** | 12-23 taps | 6-8 taps | 3-4h |
| **No skip for experienced users** | Forces full assessment | Quick-select option | 1h |
| **No back button in result screen** | Can't revisit answers | Allow review | 30 min |

**Streamlined Flow:**
1. Welcome (1 tap)
2. Pick goal (1 tap)  
3. Tank basics — name + size combined (2-3 taps)
4. Celebration + Home

**Defer to later:**
- User name → Settings
- Experience level → Pre-lesson prompt
- Placement test → Optional "Skip ahead?" card

### Loading State Gaps

Screens still using bare `CircularProgressIndicator`:
- [ ] `learn_screen.dart` — line 31
- [ ] Most provider `.when()` blocks

**Fix:** Apply existing SkeletonLoader/BubbleLoader patterns.

### Error State Improvements

| Screen | Current | Fix |
|--------|---------|-----|
| `learn_screen.dart` | `Text('Error: $e')` | Use `ErrorState` widget + retry |
| Log save | Unclear | Explicit error + retry button |

---

## 🟢 P2 — Medium Priority (Next Sprint)

### Design System Consistency

**Current status:** 0% usage of design tokens despite excellent definitions.

| Task | Scope | Fix Time |
|------|-------|----------|
| Batch replace `SizedBox(height: X)` → `AppSpacing.X` | ~300 occurrences | 2-3h |
| Batch replace `BorderRadius.circular(X)` → `AppRadius.X` | ~100 occurrences | 1-2h |
| Fix hardcoded colors | 573 → <50 | 3-4h |

**Regex patterns:**
```
SizedBox(height: 4)  → SizedBox(height: AppSpacing.xs)
SizedBox(height: 8)  → SizedBox(height: AppSpacing.sm)
SizedBox(height: 16) → SizedBox(height: AppSpacing.md)
SizedBox(height: 24) → SizedBox(height: AppSpacing.lg)
BorderRadius.circular(8)  → AppRadius.smallRadius
BorderRadius.circular(12) → AppRadius.mediumRadius
```

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

- Remove 10+ duplicate tools (already in Workshop)
- Move guides to contextual locations

### Performance (High Priority)

| Issue | File | Fix |
|-------|------|-----|
| ExpansionTile eager building | `learn_screen.dart` | Lazy build when collapsed |
| Multiple BackdropFilters | `room_scene.dart` | Reduce 4-5 → 2 max |
| Skeleton animation offscreen | `skeleton_loader.dart` | VisibilityDetector |
| SpeedDialFAB repaints | `speed_dial_fab.dart` | Use Transform instead of Positioned |
| Home screen stack rebuilds | `home_screen.dart` | Add RepaintBoundary |

### Accessibility Improvements

| Issue | Fix Time |
|-------|----------|
| SpeedDial missing Semantics | 30 min |
| ~12 interactive elements missing labels | 1h |
| SpeedDial button 44x44 → 48x48dp | 15 min |
| Add `FocusTraversalGroup` to screens (2/40 done) | 2h |

---

## 🔵 P3 — Polish (Backlog)

### Nice-to-Have Animations
- [ ] Hero animations for tank cards → tank detail
- [ ] Shared element transitions for species/plants
- [ ] Parallax on room transitions
- [ ] Pull-to-refresh on tank list, species browser
- [ ] Scroll fade-in for list items

### Empty State Illustrations
Create or commission SVG/Lottie for:
- [ ] `empty_tank.svg` — Fish bowl, no fish
- [ ] `empty_lessons.svg` — Open book with sparkles  
- [ ] `empty_achievements.svg` — Trophy case
- [ ] `empty_tests.svg` — Test tubes
- [ ] `empty_photos.svg` — Camera with frame

### Mascot Completion
- [ ] Create Rive file with all expressions (needs artist)
- [ ] Add mascot to achievements screen
- [ ] Idle animation after 60s no input

### Additional Polish
- [ ] Add "Recently Used" section to Workshop
- [ ] Locked lessons show "Complete X first" tooltip
- [ ] Shop item preview/demo mode
- [ ] Default room preference in Settings
- [ ] Quick-log mode (3 essential fields only)
- [ ] FAB labels/tooltips on first use

---

## 🐛 Bug Fixes Needed

### Critical (P0)
| Bug | Location | Status |
|-----|----------|--------|
| Duplicate Water Change Calculator | `settings_screen.dart` | 🔴 Fix now |
| Dead code `_VolumeCalculatorSheet` | `workshop_screen.dart` | 🔴 Remove |

### High (P1)
| Bug | Location | Notes |
|-----|----------|-------|
| Marine tank "Coming soon" visible | `enhanced_tutorial_walkthrough.dart` | Should hide if not ready |
| Confetti plays on error if double-tap | `enhanced_tutorial_walkthrough.dart` | Guard against |
| Two FABs can overlap | `home_screen.dart` | SpeedDialFAB + QuickAddFAB |

### Medium (P2)
| Bug | Location | Notes |
|-----|----------|-------|
| Mock data shown in bottom sheets | `home_screen.dart` | `'-- °C'` placeholders |
| Form resets on demo toggle | `enhanced_tutorial_walkthrough.dart` | Preserve state |
| Pre-filled log values confusing | `add_log_screen.dart` | Style differently |

---

## 🔧 Technical Debt

### Code Cleanup
| Item | Location | Priority |
|------|----------|----------|
| Remove dead `_VolumeCalculatorSheet` | `workshop_screen.dart` | P0 |
| Review `UNUSED_WIDGETS.md` and delete | Multiple | P1 |
| Inline widgets → component library | 339 inline widgets | P2 |
| Missing const constructors | Various | P2 |
| Provider over-watching | Various | P2 |

### Architecture Improvements
| Item | Current | Target |
|------|---------|--------|
| Component library | 339 inline widgets | <50 reusable components |
| Design token usage | 0% | 100% |
| Hardcoded colors | 573 | <10 |

---

## ⏱️ Timeline Estimate

| Priority | Hours | Calendar Time |
|----------|-------|---------------|
| **P0 Critical** | 6-8h | 1-2 days |
| **P1 High** | 8-12h | 2-3 days |
| **P2 Medium** | 10-15h | 3-4 days |
| **P3 Polish** | 15-25h | 1 week |
| **Total** | **39-60h** | **2-3 weeks** |

### Recommended Order
1. **Day 1-2:** P0 performance bugs + critical bugs
2. **Day 3-5:** P1 achievement system + onboarding
3. **Week 2:** P2 design system + settings + accessibility
4. **Week 3:** P3 polish as time allows

---

## ⚡ Quick Wins (<30 min each)

These can be done in spare time, big impact:

| Task | Time | Impact |
|------|------|--------|
| Remove duplicate Water Change Calculator | 15 min | Bug fix |
| Delete dead `_VolumeCalculatorSheet` code | 15 min | Cleanup |
| Fix SpeedDial button size 44→48dp | 15 min | Accessibility |
| Add Semantics to SpeedDialFAB | 30 min | Accessibility |
| Convert livestock_screen to ListView.builder | 30 min | Performance |
| Add RepaintBoundary to Home screen children | 20 min | Performance |
| Fix marine tank "Coming soon" visibility | 15 min | UX |
| Add "Skip assessment" link to onboarding | 30 min | UX |
| Replace one learn_screen loading state | 20 min | Polish |
| Add retry button to learn_screen error | 20 min | UX |

---

## 📊 Success Metrics

### Target Grades After Completion

| Metric | Current | P0+P1 | All Done |
|--------|---------|-------|----------|
| UI Grade | C+ | B | B+ |
| Design System | 72/100 | 75/100 | 90/100 |
| Performance | 3 critical | 0 critical | 0 issues |
| Accessibility | C- | B- | B+ |
| Onboarding Taps | 12-23 | 8-10 | 6-8 |
| Loading States | D | C+ | B+ |

### User Experience Targets
- [ ] Achievement unlock → Immediate celebration (confetti + banner)
- [ ] Onboarding → <10 taps to first tank
- [ ] All loading states → Skeleton loaders
- [ ] All error states → Retry + recovery options
- [ ] 60fps everywhere → No jank

---

## 📁 Reference Documents

| Document | Location | Purpose |
|----------|----------|---------|
| UI Polish Roadmap | `docs/UI_POLISH_ROADMAP.md` | Original B+ plan |
| A+ Edition Roadmap | `docs/UI_POLISH_ROADMAP_A_PLUS.md` | Extended A+ plan |
| Screen Audit | `docs/ui-audit/SCREEN_AUDIT_REPORT.md` | Per-screen grades |
| UX Flow Audit | `docs/ui-audit/UX_FLOW_AUDIT.md` | Journey friction |
| Performance Audit | `docs/ui-audit/PERFORMANCE_AUDIT.md` | Jank sources |
| Master Plan | `docs/planning/UI_OVERHAUL_MASTER_PLAN.md` | Implementation tracking |

---

## 🎯 Next Action

**Start with P0 performance bugs:**

```bash
# 1. Open livestock_screen.dart
# 2. Convert ListView children: [...map()] to ListView.builder
# 3. Test with 50+ livestock items
# 4. Move to withOpacity() migration
```

**Estimated time to noticeable improvement: 4 hours**

---

*This roadmap consolidates 6 audit documents into a single actionable plan. Update this document as work is completed.*

**Last Updated:** 2026-02-12
