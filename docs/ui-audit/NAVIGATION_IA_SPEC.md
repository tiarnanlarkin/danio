# Navigation & Information Architecture Spec

## Document Status
- **Version:** 1.0
- **Date:** February 2025
- **Author:** UI Audit Sub-Agent
- **Scope:** Complete navigation audit and IA recommendations for Aquarium App

---

## 1. Executive Summary

The Aquarium App uses a creative "house metaphor" with 6 swipeable rooms for navigation. While visually engaging, this audit identifies **significant IA issues** that hurt discoverability and increase user friction. Key findings:

- ⚠️ **85 screens** with inconsistent organization
- ⚠️ **Settings screen is severely bloated** (40+ items across 12 categories)
- ⚠️ **Feature duplication** between rooms (tools appear in both Workshop AND Settings)
- ⚠️ **Deep navigation** (some features require 3-5 taps)
- ⚠️ **Scattered guides** buried in Settings instead of contextual placement

**Recommendation:** Restructure IA to reduce cognitive load while preserving the house metaphor.

---

## 2. Current Navigation Structure

### 2.1 Primary Navigation: House Navigator (6 Rooms)

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         HOUSE NAVIGATOR (Swipe)                          │
├─────────┬──────────┬─────────┬─────────────┬───────────┬─────────────────┤
│  📚     │   🛋️     │   👥    │     🏆      │    🔧     │       🏪        │
│ Study   │ Living   │ Friends │ Leaderboard │ Workshop  │   Shop Street   │
│ Room 0  │ Room 1   │ Room 2  │   Room 3    │  Room 4   │     Room 5      │
│ (Start) │ (Home)   │         │             │           │                 │
└─────────┴──────────┴─────────┴─────────────┴───────────┴─────────────────┘
     │          │          │          │          │              │
     │          │          │          │          │              │
     ▼          ▼          ▼          ▼          ▼              ▼
  Learn      Tanks      Social    Rankings    Tools        Wishlists
  System     + Logs    Features   + XP       + Calc       + Shopping
```

### 2.2 Current Room Contents

#### 📚 Study (Room 0) - Learn Screen
```
Study Room
├── Study Room Scene Header (visual)
├── Review Cards Banner (if cards due)
├── Streak Card (if streak > 0)
├── Practice Card (if weak lessons)
└── Learning Paths (expandable)
    ├── Getting Started Path
    │   └── Lessons (tap → LessonScreen)
    ├── Water Chemistry Path
    │   └── Lessons
    ├── Fish Care Path
    │   └── Lessons
    └── [more paths...]
```
**Tap depth:** 1 tap to learning paths, 2 taps to start lesson

#### 🛋️ Living Room (Room 1) - Home Screen
```
Living Room
├── Top Bar
│   ├── Hearts Indicator
│   ├── Search (→ SearchScreen)
│   └── Settings (→ SettingsScreen) ⚠️ MAJOR CONCERN
├── Room Scene (visual with interactive elements)
│   ├── Tank (tap → TankDetailScreen)
│   ├── Test Kit (shows water params)
│   ├── Food (shows feeding info)
│   └── Plants (shows plant info)
├── Tank Switcher (if multiple tanks)
├── Gamification Dashboard
│   ├── Stats
│   ├── Streak
│   └── XP Progress
└── Speed Dial FAB
    ├── Add Log
    ├── Create Tank
    └── Quick Actions
```
**Tap depth:** 1-2 taps for most actions, but Settings explodes to 40+ options

#### 👥 Friends (Room 2) - Friends Screen
```
Friends
├── TabBar
│   ├── Friends Tab
│   │   ├── Search friends
│   │   └── Friend list
│   │       └── Friend (tap → FriendComparisonScreen)
│   └── Activity Tab
│       └── Activity Feed
└── Add Friend button
```
**Tap depth:** 2-3 taps

#### 🏆 Leaderboard (Room 3)
```
Leaderboard
├── Leaderboard header
├── Rankings list
│   └── User entry (tap → profile)
└── Your position highlight
```
**Tap depth:** 1-2 taps

#### 🔧 Workshop (Room 4) - Tools Screen
```
Workshop
├── Header
├── Tool Grid (2x6)
│   ├── Water Change Calculator
│   ├── Stocking Calculator
│   ├── CO₂ Calculator
│   ├── Dosing Calculator
│   ├── Unit Converter
│   ├── Tank Volume Calculator
│   ├── Lighting Schedule
│   ├── Charts (requires tank first!)
│   ├── Compatibility Checker
│   ├── Equipment (requires tank first!)
│   └── Cost Tracker
└── Quick Reference section
```
**Tap depth:** 2 taps (room + tool)

#### 🏪 Shop Street (Room 5)
```
Shop Street
├── Header
├── Wishlist Sections
│   ├── Fish Wishlist (→ WishlistScreen)
│   ├── Plant Wishlist (→ WishlistScreen)
│   └── Equipment Wishlist (→ WishlistScreen)
├── Budget Card
└── Local Shops Card
```
**Tap depth:** 2 taps

---

## 3. Settings Screen Audit (CRITICAL)

### 3.1 Current Settings Organization

The Settings screen is **dangerously overloaded** with 12+ sections and 40+ items:

```
Settings Screen (⚠️ BLOATED - 47 items)
├── Learn Section
│   ├── Learn Card (link to Study room - REDUNDANT)
│   └── Daily Goal picker
│
├── Explore Section
│   └── Room Navigation (REDUNDANT - house navigator exists)
│
├── Appearance Section
│   ├── Light/Dark Mode
│   ├── Room Themes (→ ThemeGalleryScreen)
│   └── Difficulty Settings (→ DifficultySettingsScreen)
│
├── Notifications Section
│   ├── Streak Reminders (→ NotificationSettingsScreen)
│   ├── Task Reminders toggle
│   └── Test Notification
│
├── Tools Section (⚠️ DUPLICATE of Workshop room!)
│   ├── Reminders (→ RemindersScreen)
│   ├── Fish Wishlist (⚠️ DUPLICATE of Shop Street!)
│   ├── Compare Tanks (→ TankComparisonScreen)
│   ├── Water Change Calculator (⚠️ DUPLICATE!)
│   ├── CO2 Calculator (⚠️ DUPLICATE!)
│   ├── Dosing Calculator (⚠️ DUPLICATE!)
│   ├── Unit Converter (⚠️ DUPLICATE!)
│   ├── Tank Volume Calculator (⚠️ DUPLICATE!)
│   ├── Cost Tracker (⚠️ DUPLICATE!)
│   ├── Compatibility Checker (⚠️ DUPLICATE!)
│   ├── Lighting Schedule (⚠️ DUPLICATE!)
│   └── Stocking Calculator (⚠️ DUPLICATE!)
│
├── Shop Section
│   └── Shop Street (⚠️ DUPLICATE - it's a room!)
│
├── About Section
│   ├── Version info
│   └── About dialog
│
├── Data Section
│   ├── Export All Data
│   ├── Import Data
│   └── Photo Storage info
│
├── Guides & Education (⚠️ MASSIVE - 20+ guides!)
│   ├── Essential Guides (expandable)
│   │   ├── Quick Start Guide
│   │   ├── Emergency Guide
│   │   └── Nitrogen Cycle Guide
│   ├── Water & Parameters (expandable)
│   │   ├── Water Parameters Guide
│   │   └── Algae Guide
│   ├── Fish Care (expandable)
│   │   ├── Feeding Guide
│   │   ├── Disease Guide
│   │   ├── Acclimation Guide
│   │   ├── Quarantine Guide
│   │   └── Breeding Guide
│   ├── Tank Setup & Design (expandable)
│   │   ├── Equipment Guide
│   │   ├── Substrate Guide
│   │   └── Hardscape Guide
│   ├── Planning & Travel (expandable)
│   │   └── Vacation Planning
│   └── Reference (expandable)
│       ├── Fish Database
│       ├── Plant Database
│       ├── Glossary
│       ├── FAQ
│       └── Troubleshooting
│
├── Help & Support Section
│   ├── Replay Onboarding
│   ├── Add Sample Tank
│   ├── Backup & Restore (→ BackupRestoreScreen)
│   └── About (→ AboutScreen)
│
└── Danger Zone
    └── Clear All Data
```

### 3.2 Settings Pain Points

| Issue | Severity | Description |
|-------|----------|-------------|
| **Feature Duplication** | 🔴 Critical | 10+ tools duplicated from Workshop room |
| **Misplaced Content** | 🔴 Critical | 20+ guides buried in Settings (not contextual) |
| **Cognitive Overload** | 🟠 High | 47 items requires excessive scrolling |
| **No Search** | 🟠 High | Can't search within Settings |
| **Redundant Navigation** | 🟡 Medium | Room navigation exists in Settings AND bottom bar |
| **Inconsistent Grouping** | 🟡 Medium | "Tools" section duplicates entire Workshop room |

---

## 4. Feature Tap-Depth Analysis

### 4.1 High-Frequency Features

| Feature | Current Taps | Expected Taps | Status |
|---------|--------------|---------------|--------|
| View tank details | 1 | 1 | ✅ Good |
| Add water log | 2 | 2 | ✅ Good |
| Start lesson | 2 | 2 | ✅ Good |
| View leaderboard | 1 | 1 | ✅ Good |
| Use calculator | 2 | 2 | ✅ Good |

### 4.2 Medium-Frequency Features  

| Feature | Current Taps | Expected Taps | Status |
|---------|--------------|---------------|--------|
| Check compatibility | 2 | 2 | ✅ Good |
| View fish database | 3-4 | 2 | 🟠 Too deep |
| Add to wishlist | 3 | 2 | 🟡 Acceptable |
| View charts/analytics | 3 | 2 | 🟠 Requires tank context |
| Manage equipment | 3 | 2 | 🟠 Requires tank context |

### 4.3 Low-Frequency Features (Settings)

| Feature | Current Taps | Expected Taps | Status |
|---------|--------------|---------------|--------|
| Change theme | 3 | 2 | 🟡 Acceptable |
| Adjust notifications | 3 | 2 | 🟡 Acceptable |
| Backup data | 3 | 2 | 🟡 Acceptable |
| Read disease guide | 4-5 | 2-3 | 🔴 Way too deep! |
| Find glossary term | 4-5 | 2 | 🔴 Way too deep! |
| Emergency guide | 4-5 | 1-2 | 🔴 CRITICAL - emergency info buried! |

---

## 5. Navigation Pattern Analysis

### 5.1 Current Pattern: Horizontal Swipe + Bottom Indicator

**Strengths:**
- ✅ Creative "house" metaphor is engaging
- ✅ Swipe navigation feels fluid
- ✅ Visual room indicator shows position
- ✅ Badge on Study room for due cards

**Weaknesses:**
- ❌ 6 rooms may be too many (Material Design recommends 3-5 bottom nav items)
- ❌ No persistent bottom navigation bar (just indicator dots)
- ❌ Leaderboard as separate room feels excessive (could be tab in Friends)
- ❌ Shop Street usage is unclear (wishlist management vs actual shopping?)

### 5.2 Alternative Patterns Considered

| Pattern | Pros | Cons | Recommendation |
|---------|------|------|----------------|
| **Bottom Tab Bar (5 tabs)** | Standard, predictable | Less creative | Consider for clarity |
| **Drawer Navigation** | Hides complexity | Discoverability issue | Not recommended |
| **Hybrid (Bottom + Swipe)** | Best of both worlds | More complex | **Recommended** |
| **Search-First** | Fast access | Learning curve | Add as supplement |

### 5.3 Deep Linking Considerations

Current state: **No deep linking implemented**

Needed deep links:
- `aquarium://tank/{id}` - Direct to tank
- `aquarium://lesson/{id}` - Direct to lesson
- `aquarium://log/add?tank={id}` - Add log to specific tank
- `aquarium://guide/{type}` - Direct to guide (emergency critical!)
- `aquarium://search?q={query}` - Search with query

---

## 6. Recommendations

### 6.1 Immediate Fixes (P0 - Critical)

#### 6.1.1 Emergency Guide Access
**Current:** Settings → Guides & Education → Essential Guides → Emergency Guide (4+ taps)  
**Fix:** Add emergency button to tank detail screen header (1 tap from tank)

```dart
// In TankDetailScreen app bar
IconButton(
  icon: Icon(Icons.emergency, color: Colors.red),
  tooltip: 'Emergency Help',
  onPressed: () => Navigator.push(context, 
    MaterialPageRoute(builder: (_) => EmergencyGuideScreen())),
)
```

#### 6.1.2 Remove Duplication from Settings
**Remove these from Settings (they exist in rooms):**
- All calculator links (exist in Workshop)
- Wishlist link (exists in Shop Street)
- Shop Street link (it's a room)
- Learn card (it's Room 0)
- Room Navigation widget (confusing)

**Result:** Settings drops from 47 items to ~25 items

### 6.2 High Priority (P1)

#### 6.2.1 Merge Leaderboard into Friends Room
**Current:** 6 rooms (Study, Living, Friends, Leaderboard, Workshop, Shop)  
**Proposed:** 5 rooms (Study, Living, Social, Workshop, Shop)

```
Social Room (merged)
├── TabBar
│   ├── Friends Tab
│   ├── Leaderboard Tab  ← Moved here
│   └── Activity Tab
```

**Benefits:**
- Reduces cognitive load (5 < 6)
- Social features grouped logically
- Leaderboard is social by nature

#### 6.2.2 Contextual Guide Placement
**Move guides to where they're needed:**

| Guide | Current Location | Proposed Location |
|-------|------------------|-------------------|
| Disease Guide | Settings | Tank Detail → Fish → "Health Help" |
| Feeding Guide | Settings | Tank Detail → Fish → "Feeding Tips" |
| Acclimation Guide | Settings | When adding new fish to tank |
| Nitrogen Cycle | Settings | Create Tank flow + Tank cycling status card |
| Equipment Guide | Settings | Workshop → Equipment section |
| Parameter Guide | Settings | Add Log screen → "What do these mean?" |

#### 6.2.3 Create Knowledge Hub in Study Room
**Consolidate educational content:**

```
Study Room (enhanced)
├── Learning Paths (current)
├── Practice/Review (current)
└── Knowledge Hub (NEW)
    ├── Quick Reference
    │   ├── Glossary
    │   ├── Parameter Guide
    │   └── Unit Converter
    ├── Guides Library
    │   ├── Essential
    │   ├── Fish Care
    │   ├── Tank Setup
    │   └── Planning
    └── Species Database
        ├── Fish Browser
        └── Plant Browser
```

### 6.3 Medium Priority (P2)

#### 6.3.1 Implement Global Search
**Add search accessible from any room:**
- Search fish species
- Search plants
- Search guides
- Search settings
- Search your tanks/livestock

```dart
// Add to HouseNavigator - floating search button
FloatingActionButton(
  mini: true,
  child: Icon(Icons.search),
  onPressed: () => showSearch(context: context, delegate: GlobalSearchDelegate()),
)
```

#### 6.3.2 Quick Actions Sheet
**Long-press on room indicator or shake to show:**
- Quick Log (most recent tank)
- Check Compatibility
- Emergency Help
- Recent Tank
- Today's Tasks

#### 6.3.3 Settings Restructure

**Proposed Settings organization (25 items, 6 sections):**

```
Settings (Streamlined)
├── Profile & Goals
│   ├── Edit Profile
│   ├── Daily XP Goal
│   └── Difficulty Level
│
├── Appearance
│   ├── Theme (Light/Dark/System)
│   └── Room Decorations
│
├── Notifications
│   ├── Notification Settings
│   └── Reminders
│
├── Data & Privacy
│   ├── Backup & Restore
│   ├── Export Data
│   └── Clear Data
│
├── Help
│   ├── Onboarding Replay
│   ├── FAQ
│   └── Troubleshooting
│
└── About
    ├── Version Info
    └── Licenses
```

### 6.4 Future Considerations (P3)

#### 6.4.1 Bottom Navigation Bar
Consider replacing swipe-only with hybrid approach:
- Keep swipe for discovery
- Add visible bottom nav bar for explicit navigation
- Users can tap OR swipe

#### 6.4.2 Personalized Home
Let users customize Living Room quick actions based on their tank type:
- Planted tank → CO2, Lighting prominent
- Fish-only → Feeding, Compatibility prominent
- Breeding → Breeding guides prominent

---

## 7. Proposed Navigation Sitemap

### 7.1 Visual Hierarchy

```
┌────────────────────────────────────────────────────────────────────────────┐
│                           AQUARIUM APP                                      │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│   ┌─────────────────────── HOUSE NAVIGATOR ───────────────────────┐       │
│   │                         (5 rooms)                              │       │
│   ├────────┬────────────┬──────────┬────────────┬─────────────────┤       │
│   │ 📚     │ 🛋️         │ 👥       │ 🔧         │ 🏪              │       │
│   │ STUDY  │ HOME       │ SOCIAL   │ WORKSHOP   │ SHOP            │       │
│   │        │            │          │            │                 │       │
│   │ Learn  │ Tanks      │ Friends  │ Tools      │ Wishlists       │       │
│   │ Paths  │ Dashboard  │ Leaders  │ Calculators│ Budget          │       │
│   │ Review │ Quick Log  │ Activity │ Equipment  │ Local Shops     │       │
│   │ *Hub   │ Tasks      │          │            │                 │       │
│   └────────┴────────────┴──────────┴────────────┴─────────────────┘       │
│                                   │                                        │
│                                   ▼                                        │
│   ┌──────────────────── SECONDARY NAVIGATION ─────────────────────┐       │
│   │                                                                │       │
│   │   From HOME (🛋️):                                              │       │
│   │   ├── Tank Detail → Livestock, Equipment, Logs, Charts        │       │
│   │   ├── Search (global)                                          │       │
│   │   └── Settings (gear icon)                                     │       │
│   │                                                                │       │
│   │   From STUDY (📚):                                             │       │
│   │   ├── Lessons → Quiz → Results                                 │       │
│   │   ├── Practice → Spaced Repetition                            │       │
│   │   └── *Knowledge Hub → Guides, Database, Glossary             │       │
│   │                                                                │       │
│   │   From SOCIAL (👥):                                            │       │
│   │   ├── Friend Profile → Comparison                              │       │
│   │   └── Leaderboard → User Profiles                              │       │
│   │                                                                │       │
│   │   From WORKSHOP (🔧):                                          │       │
│   │   └── Calculator Screens (standalone)                          │       │
│   │                                                                │       │
│   │   From SHOP (🏪):                                              │       │
│   │   └── Wishlist Screens (fish, plant, equipment)                │       │
│   │                                                                │       │
│   └────────────────────────────────────────────────────────────────┘       │
│                                                                            │
│   ┌────────────────── CONTEXTUAL ACCESS ──────────────────────────┐       │
│   │                                                                │       │
│   │   🆘 Emergency Guide: Accessible from any tank (1 tap)         │       │
│   │   🔍 Global Search: Floating button or top bar                 │       │
│   │   ⚡ Quick Actions: Long-press room indicator                  │       │
│   │                                                                │       │
│   └────────────────────────────────────────────────────────────────┘       │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Tap-Depth Summary (Proposed)

| Feature Category | Max Taps | Notes |
|------------------|----------|-------|
| Primary features (tank, lessons) | 2 | From any room |
| Tools & calculators | 2 | Workshop → Tool |
| Guides (contextual) | 2 | From relevant screen |
| Emergency help | 1 | From tank detail |
| Settings | 2-3 | Settings → Option |
| Deep content (species detail) | 3 | Database → Species → Detail |

---

## 8. Implementation Impact

### 8.1 Files to Modify

| File | Change Type | Effort |
|------|-------------|--------|
| `house_navigator.dart` | Reduce to 5 rooms, merge leaderboard | Medium |
| `settings_screen.dart` | Major refactor - remove duplicates | High |
| `learn_screen.dart` | Add Knowledge Hub section | Medium |
| `friends_screen.dart` | Add Leaderboard tab | Medium |
| `tank_detail_screen.dart` | Add emergency button | Low |
| Various screens | Add contextual guide links | Low each |

### 8.2 New Files Needed

| File | Purpose |
|------|---------|
| `knowledge_hub_screen.dart` | Consolidated education center |
| `global_search_delegate.dart` | Universal search |
| `quick_actions_sheet.dart` | Quick actions overlay |

### 8.3 Migration Strategy

1. **Phase 1:** Remove duplicates from Settings (non-breaking)
2. **Phase 2:** Add emergency access to tank detail (non-breaking)
3. **Phase 3:** Merge Leaderboard into Social room (breaking change)
4. **Phase 4:** Create Knowledge Hub (additive)
5. **Phase 5:** Implement global search (additive)

---

## 9. Metrics to Track

After implementing changes, track:

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Settings abandonment rate | ↓ 30% | Analytics: exits from Settings |
| Feature discovery | ↑ 20% | Track calculator usage |
| Emergency guide access | ↑ 50% | Track guide opens |
| Average taps to complete action | ↓ 15% | Analytics funnel |
| User satisfaction (NPS) | ↑ 10pts | In-app survey |

---

## 10. Appendix

### A. Complete Screen Inventory (85 screens)

<details>
<summary>Click to expand full screen list</summary>

**Main Navigation (6):**
- house_navigator.dart
- home_screen.dart
- learn_screen.dart
- friends_screen.dart
- leaderboard_screen.dart
- workshop_screen.dart
- shop_street_screen.dart

**Tank Management (8):**
- create_tank_screen.dart
- tank_detail_screen.dart
- tank_settings_screen.dart
- tank_comparison_screen.dart
- livestock_screen.dart
- livestock_detail_screen.dart
- livestock_value_screen.dart
- equipment_screen.dart

**Logging & Data (7):**
- add_log_screen.dart
- logs_screen.dart
- log_detail_screen.dart
- charts_screen.dart
- analytics_screen.dart
- journal_screen.dart
- photo_gallery_screen.dart

**Learning (6):**
- lesson_screen.dart
- practice_screen.dart
- enhanced_quiz_screen.dart
- spaced_repetition_practice_screen.dart
- placement_test_screen.dart
- placement_result_screen.dart
- stories_screen.dart
- story_player_screen.dart

**Calculators/Tools (10):**
- water_change_calculator_screen.dart
- stocking_calculator_screen.dart
- co2_calculator_screen.dart
- dosing_calculator_screen.dart
- unit_converter_screen.dart
- tank_volume_calculator_screen.dart
- lighting_schedule_screen.dart
- compatibility_checker_screen.dart
- cost_tracker_screen.dart
- search_screen.dart

**Guides (16):**
- quick_start_guide_screen.dart
- emergency_guide_screen.dart
- nitrogen_cycle_guide_screen.dart
- parameter_guide_screen.dart
- algae_guide_screen.dart
- feeding_guide_screen.dart
- disease_guide_screen.dart
- acclimation_guide_screen.dart
- quarantine_guide_screen.dart
- breeding_guide_screen.dart
- equipment_guide_screen.dart
- substrate_guide_screen.dart
- hardscape_guide_screen.dart
- vacation_guide_screen.dart
- glossary_screen.dart
- faq_screen.dart
- troubleshooting_screen.dart

**Databases (3):**
- species_browser_screen.dart
- plant_browser_screen.dart
- inventory_screen.dart

**Social (3):**
- friend_comparison_screen.dart
- activity_feed_screen.dart
- achievements_screen.dart

**Shopping (2):**
- wishlist_screen.dart
- gem_shop_screen.dart

**Settings & Config (10):**
- settings_screen.dart
- notification_settings_screen.dart
- difficulty_settings_screen.dart
- theme_gallery_screen.dart
- backup_restore_screen.dart
- about_screen.dart
- privacy_policy_screen.dart
- terms_of_service_screen.dart
- reminders_screen.dart
- tasks_screen.dart
- maintenance_checklist_screen.dart

**Onboarding (7):**
- onboarding_screen.dart
- enhanced_onboarding_screen.dart
- enhanced_placement_test_screen.dart
- enhanced_tutorial_walkthrough_screen.dart
- experience_assessment_screen.dart
- first_tank_wizard_screen.dart
- profile_creation_screen.dart
- tutorial_walkthrough_screen.dart

</details>

### B. Back Button Behavior Audit

| Screen Type | Back Behavior | Status |
|-------------|---------------|--------|
| Primary rooms | Swipe to adjacent room | ✅ Correct |
| Tank detail | Pop to Living Room | ✅ Correct |
| Settings | Pop to Living Room | ✅ Correct |
| Nested screens | Pop to parent | ✅ Correct |
| Modal sheets | Close sheet | ✅ Correct |
| Onboarding | Cannot go back | ✅ Correct |

**No dead ends detected.** Back navigation is consistent throughout.

### C. Accessibility Notes

- ✅ All bottom nav items have semantic labels
- ✅ Tutorial overlay provides screen reader descriptions
- ⚠️ Some guide content may need heading structure
- ⚠️ Search results need better a11y announcements

---

*End of Navigation & Information Architecture Spec*
