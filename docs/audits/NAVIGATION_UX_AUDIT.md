# Navigation & UX Flow Audit Report

**Date:** 2024-02-11  
**Scope:** `/apps/aquarium_app/lib/`  
**Total Screens:** 80+ screens  
**Navigation Push Calls:** 113+ `Navigator.push` instances

---

## 📊 Navigation Structure Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              APP ENTRY POINT                                │
│                              (main.dart)                                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
         ┌───────────────────────────┼───────────────────────────┐
         │                           │                           │
         ▼                           ▼                           ▼
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│ OnboardingScreen│──────▶│ ProfileCreation │──────▶│ HouseNavigator  │
│   (3 pages)     │      │                 │      │  (Main App)     │
└─────────────────┘      └─────────────────┘      └─────────────────┘
         │                                                 │
         ▼                                                 ▼
┌─────────────────┐                    ┌──────────────────────────────────────┐
│ Experience      │                    │      HOUSE NAVIGATOR (Swipe)         │
│ Assessment      │                    │  ┌────┬────┬────┬────┬────┬────┐    │
└─────────────────┘                    │  │ 📚 │ 🛋️ │ 👥 │ 🏆 │ 🔧 │ 🏪 │    │
         │                             │  │Stdy│Home│Frnds│Ldbrd│Wksp│Shop│   │
         ▼                             │  │  0 │  1 │  2  │  3  │  4 │  5 │    │
┌─────────────────┐                    │  └────┴────┴────┴────┴────┴────┘    │
│ FirstTankWizard │                    │      ⬆️ Horizontal Swipe ⬆️           │
└─────────────────┘                    └──────────────────────────────────────┘
                                                         │
                    ┌────────────────────────────────────┼────────────────────┐
                    │                                    │                    │
                    ▼                                    ▼                    ▼
┌──────────────────────────────┐   ┌─────────────────────────────┐   ┌────────────────┐
│        LearnScreen           │   │       HomeScreen            │   │ Other Rooms    │
│   (Duolingo-style lessons)   │   │ ┌─────────────────────────┐ │   │ (standalone)   │
└──────────────────────────────┘   │ │ ⚠️ NESTED BOTTOM NAV ⚠️  │ │   └────────────────┘
              │                    │ │  Home│Learn│Tools│Shop  │ │
              │                    │ └─────────────────────────┘ │
              ▼                    └─────────────────────────────┘
     ┌────────────────┐                         │
     │  LessonScreen  │         ┌───────────────┴──────────────────┐
     │  PracticeScreen│         │                                  │
     └────────────────┘         ▼                                  ▼
                    ┌─────────────────────┐            ┌─────────────────────┐
                    │  TankDetailScreen   │            │   SettingsScreen    │
                    │  (Per-tank hub)     │            │  ⚠️ 25+ ITEMS ⚠️     │
                    └─────────────────────┘            └─────────────────────┘
                               │
     ┌──────────────┬──────────┼──────────┬──────────────┬──────────────┐
     ▼              ▼          ▼          ▼              ▼              ▼
┌─────────┐   ┌─────────┐ ┌─────────┐ ┌─────────┐  ┌─────────┐   ┌─────────┐
│Livestock│   │Equipment│ │  Logs   │ │  Tasks  │  │ Charts  │   │Settings │
│ Screen  │   │ Screen  │ │ Screen  │ │ Screen  │  │ Screen  │   │  Screen │
└─────────┘   └─────────┘ └─────────┘ └─────────┘  └─────────┘   └─────────┘
     │              │          │          │              │
     ▼              ▼          ▼          ▼              ▼
┌─────────┐   ┌─────────┐ ┌─────────┐ ┌─────────┐  ┌─────────┐
│Livestock│   │Equipment│ │Log Detail│ │Task Edit│  │Param    │
│ Detail  │   │ Detail  │ │  Screen │ │  Dialog │  │ Charts  │
└─────────┘   └─────────┘ └─────────┘ └─────────┘  └─────────┘
```

---

## 🗺️ User Journey Map

### Onboarding Flow (First-Time User)
```
OnboardingScreen (3 pages)
    │ [Complete / Skip]
    ▼
ExperienceAssessmentScreen (4 questions)
    │ [Determine experience level]
    ▼
FirstTankWizardScreen (optional)
    │ [Setup first tank]
    ▼
ProfileCreationScreen
    │ [Name, goals, tank type]
    ▼
EnhancedPlacementTestScreen (optional skill test)
    │
    ▼
HouseNavigator (Main App) ← Living Room (default)
```

### Core User Journeys

| Journey | Path | Taps Required |
|---------|------|---------------|
| **Check tank status** | Living Room → Tap Tank | 1 tap ✅ |
| **Log water parameters** | Living Room → Tank → FAB → Quick Test | 3 taps ✅ |
| **View fish details** | Living Room → Tank → Livestock → Fish | 3 taps ✅ |
| **Edit fish info** | Living Room → Tank → Livestock → Fish → Edit | 4 taps ⚠️ |
| **Start a lesson** | Swipe to Study → Path → Lesson | 3 taps ✅ |
| **Use CO2 Calculator** | Swipe to Workshop → CO2 Calc | 2 taps ✅ |
| **Find nitrogen cycle guide** | Settings → Nitrogen Cycle Guide | 2 taps (but buried!) ⚠️ |
| **Edit equipment** | Tank → Equipment → Item → Edit | 4 taps ⚠️ |
| **View parameter charts** | Tank → Charts → Parameter → Chart | 3-4 taps ⚠️ |

---

## 🔴 Critical Issues

### 1. DUPLICATE NAVIGATION SYSTEMS (HIGH PRIORITY)

**Problem:** Two competing navigation paradigms on screen simultaneously.

```
┌─────────────────────────────────────────────────────────────────┐
│                    HOUSE NAVIGATOR                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                   (swipe left/right)                       │ │
│  │  📚 Study  │  🛋️ Living Room  │  👥 Friends  │ ...         │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│                              ▼                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              HOME SCREEN (Living Room)                     │ │
│  │                                                            │ │
│  │  ┌────────────────────────────────────────────────────────┐│ │
│  │  │    ⚠️ ANOTHER BOTTOM NAV BAR ⚠️                        ││ │
│  │  │    🏠 Home │ 📚 Learn │ 🔧 Tools │ 🛒 Shop             ││ │
│  │  └────────────────────────────────────────────────────────┘│ │
│  └────────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  📚  │  🛋️  │  👥  │  🏆  │  🔧  │  🏪   (room indicator)  │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**What Users See:**
- Bottom room indicator bar (HouseNavigator)
- Bottom navigation bar (HomeScreen's own BottomNavigationBar)
- **Result:** Users are confused about which to use

**Recommendation:** Remove HomeScreen's bottom nav bar. Use HouseNavigator as the ONLY navigation system.


### 2. LearnScreen vs StudyScreen Confusion

**Current State:**
- `LearnScreen` - Duolingo-style lessons (swipe to Study room)
- `StudyScreen` - Hub that LINKS to LearnScreen (HomeScreen bottom nav → "Learn")

**Problem:**
```
HouseNavigator "Study" Room → LearnScreen (direct)
HomeScreen Bottom Nav "Learn" → StudyScreen → LearnScreen (extra step!)
```

**Recommendation:** Consolidate. Either:
- Use LearnScreen directly everywhere, OR
- Make StudyScreen the definitive hub and use it in HouseNavigator too


### 3. Multiple Paths to Same Screen

| Screen | Path 1 | Path 2 | Path 3 |
|--------|--------|--------|--------|
| WorkshopScreen | HouseNavigator swipe (Room 4) | HomeScreen bottom nav "Tools" | Settings → Tools section |
| ShopStreetScreen | HouseNavigator swipe (Room 5) | HomeScreen bottom nav "Shop" | Settings → Shop section |
| LearnScreen | HouseNavigator swipe (Room 0) | HomeScreen bottom nav "Learn" (via StudyScreen) | - |

**Problem:** Users don't know which path to use. Creates confusion about "where am I?"


### 4. Settings Screen is a Dumping Ground

**Current State:** 25+ ListTile items including:
- Theme/appearance (2 items)
- Notifications (3 items)  
- Tools (10+ items)
- Shop (1 item)
- Data (3 items)
- Help/Guides (15+ items!)
- Danger zone (1 item)

**Problem:** Users can't find anything. Too many items, no hierarchy.

**Recommendation:** Organize into subpages:
- Settings → Tools → [calculators, etc.]
- Settings → Help → [guides, glossary, FAQ]
- Settings → Account → [data, notifications]

---

## 🟡 Screens Buried Too Deep (>3 taps)

| Screen | Path | Depth |
|--------|------|-------|
| LivestockDetailScreen → Edit | Home → Tank → Livestock → Detail → Edit | 5 taps |
| EquipmentDetailScreen | Home → Tank → Equipment → Detail | 4 taps |
| LogDetailScreen → Edit | Home → Tank → Logs → Detail → Edit | 5 taps |
| ChartsScreen → Param Detail | Home → Tank → Charts → Parameter | 4 taps |
| LessonScreen → Quiz → Results | Study → Path → Lesson → Quiz → Done | 5 taps |
| JournalScreen (from tank) | Home → Tank → Menu → Journal | 4 taps |
| PhotoGalleryScreen | Home → Tank → Menu → Gallery | 4 taps |
| LivestockValueScreen | Home → Tank → Menu → Estimate Value | 4 taps |

### Quick Wins to Surface Buried Screens:
1. Add "Journal" and "Gallery" to tank detail visible buttons (not menu)
2. Move common guides to Study room main view
3. Surface "Estimate Value" on tank card itself

---

## 🟢 What's Working Well

1. **HouseNavigator Concept** - Room metaphor is creative and memorable
2. **Tank Detail Screen** - Good hub for tank-specific features
3. **FAB Quick Actions** - Speed dial for common tasks is excellent
4. **Learning Path Progress** - Clear visual progression
5. **Streak/Goal Cards** - Duolingo-style motivation on Living Room
6. **Offline/Sync Indicators** - Good UX for connectivity status

---

## 📋 Recommendations Summary

### Priority 1: Fix Navigation Conflict
1. **Remove HomeScreen's BottomNavigationBar** - Let HouseNavigator be the ONLY main navigation
2. **Consolidate LearnScreen and StudyScreen** - Pick one, remove the other
3. **Remove duplicate paths** to Workshop and Shop screens

### Priority 2: Improve Discoverability  
4. **Break up Settings screen** into subpages:
   - Tools & Calculators (its own page)
   - Help & Guides (its own page)
   - Account & Data (keep in main settings)

5. **Surface buried features:**
   - Add Journal/Gallery buttons to TankDetail (visible, not menu)
   - Add quick-access to popular guides on Study room

### Priority 3: Reduce Depth
6. **Add shortcuts:**
   - Long-press on livestock → quick edit dialog
   - Long-press on equipment → quick maintenance log
   - Swipe actions on list items

7. **Consider floating entry points:**
   - Global search that can jump to any screen
   - Recent screens menu

---

## 📱 Navigation Pattern Comparison

| Pattern | Current | Recommended |
|---------|---------|-------------|
| Main nav | Swipe (rooms) + Bottom nav | Swipe (rooms) only |
| Bottom indicator | Room bar at bottom | Keep (elegant) |
| Deep features | Buried in Settings | Organized subpages |
| Multiple paths | Same screen via 2-3 paths | Single clear path |
| Feature depth | Up to 5 taps | Target: 3 taps max |

---

## 🔍 Broken Navigation Check

**No broken routes found.** All `Navigator.push` calls reference existing screens.

However, note these edge cases:
- `EquipmentScreen` requires `tankId` - Workshop shows info message
- `TankDetailScreen` expects `tankId` - navigated correctly everywhere
- Some screens have optional params that change behavior

---

## Files Reviewed

- `main.dart` - App entry, routing logic
- `house_navigator.dart` - Main navigation shell
- `home_screen.dart` - Living Room (has redundant nav)
- `learn_screen.dart` - Learning paths
- `settings_screen.dart` - Settings hub (bloated)
- `tank_detail_screen.dart` - Tank hub (well organized)
- `onboarding/` - All onboarding screens
- `workshop_screen.dart` - Tools room
- `shop_street_screen.dart` - Shop room
- `friends_screen.dart` - Social room
- Various guide/calculator screens

---

*Report generated by Navigation & UX Audit subagent*
