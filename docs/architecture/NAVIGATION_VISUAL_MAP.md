# Navigation Visual Map - Aquarium App

## Tab Structure Overview

```
┌───────────────────────────────────────────────────────────────────────┐
│                         Aquarium App                                  │
│                    Bottom Tab Navigation                              │
└───────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                              APP BAR                                    │
│  [Back]  Screen Title                           [Hearts] [Settings]    │
└─────────────────────────────────────────────────────────────────────────┘
│                                                                         │
│                                                                         │
│                          SCREEN CONTENT                                 │
│                         (Tab-specific)                                  │
│                                                                         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────┐
│               BOTTOM NAVIGATION BAR (ALWAYS VISIBLE)                    │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐                       │
│  │  📚    │  │  🧪    │  │  🏠    │  │  ⚙️    │                       │
│  │ Learn  │  │  Quiz  │  │  Tank  │  │Settings│                       │
│  └────────┘  └────────┘  └────────┘  └────────┘                       │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Tab 1: 📚 Learn

**Purpose:** Educational content and learning paths

```
LearnScreen (Root)
│
├─ Learning Path: Getting Started
│  ├─ LessonScreen: "What is an Aquarium?"
│  ├─ LessonScreen: "The Nitrogen Cycle"
│  └─ LessonScreen: "Choosing Your First Tank"
│
├─ Learning Path: Water Chemistry
│  ├─ LessonScreen: "pH and Hardness"
│  ├─ LessonScreen: "Ammonia, Nitrite, Nitrate"
│  └─ ParameterGuideScreen (detailed guide)
│
├─ Learning Path: Fish Care
│  ├─ LessonScreen: "Species Selection"
│  └─ LessonScreen: "Feeding and Nutrition"
│
└─ Interactive Elements
   ├─ Microscope → WaterChemistryScreen
   └─ Globe → RandomFishFact (modal)
```

**Navigation:**
- Tap learning path → shows lessons list
- Tap lesson → LessonScreen (with quiz)
- Complete lesson → earns XP, unlocks next
- Back button → returns to LearnScreen

---

## Tab 2: 🧪 Quiz

**Purpose:** Practice and spaced repetition

```
PracticeHubScreen (Root)
│
├─ Review Due Cards (Hero Card)
│  └─ SpacedRepetitionPracticeScreen
│     └─ ReviewSessionScreen (card practice)
│
├─ Practice Modes
│  ├─ Spaced Repetition → SpacedRepetitionPracticeScreen
│  ├─ Quick Practice → PracticeScreen
│  └─ Achievements → PracticeScreen (achievements variant)
│
└─ Stats Dashboard
   ├─ Due Cards: 12
   ├─ Mastered: 45
   └─ Total Cards: 89
```

**Navigation:**
- Tap mode → starts practice session
- In session → PopScope prevents accidental exit
- Complete session → shows results, earns XP
- Back button → confirmation dialog if session active

---

## Tab 3: 🏠 Tank

**Purpose:** Tank management and tracking

```
HomeScreen (Root)
│
├─ Tank Switcher
│  ├─ Tank 1: "Community Tank" (200L)
│  ├─ Tank 2: "Planted Reef" (120L)
│  └─ [+] Create New Tank
│
├─ Current Tank View
│  ├─ TankDetailScreen
│  │  ├─ Fish List → FishDetailScreen
│  │  ├─ Equipment → EquipmentScreen
│  │  ├─ Water Logs → AddLogScreen
│  │  └─ Maintenance → RemindersScreen
│  │
│  └─ Quick Actions (FAB)
│     ├─ Add Fish
│     ├─ Log Parameters
│     └─ Add Maintenance Task
│
└─ Analytics
   └─ ChartsScreen (parameter graphs)
```

**Navigation:**
- Swipe left/right → switch tanks
- Tap tank card → TankDetailScreen
- Tap fish → FishDetailScreen
- Tap + FAB → context menu → detail screen
- Back button → returns through stack

---

## Tab 4: ⚙️ Settings

**Purpose:** Profile, community, shop, tools

```
SettingsHubScreen (Root)
│
├─ Profile Card
│  └─ SettingsScreen (preferences)
│
├─ Community
│  ├─ FriendsScreen
│  │  ├─ Add Friend
│  │  └─ FriendComparisonScreen
│  │
│  └─ LeaderboardScreen
│     └─ Global / Friends / Local rankings
│
├─ Shop & Rewards
│  ├─ ShopStreetScreen
│  │  └─ ShopDetailScreen (specific shop)
│  │
│  └─ AchievementsScreen
│     └─ Achievement detail modals
│
├─ Tools
│  ├─ WorkshopScreen
│  │  ├─ DosingCalculatorScreen
│  │  ├─ CO2CalculatorScreen
│  │  ├─ CompatibilityCheckerScreen
│  │  └─ [10+ more calculators]
│  │
│  └─ AnalyticsScreen
│     └─ Learning stats, tank stats
│
└─ App Settings
   ├─ SettingsScreen (theme, notifications)
   ├─ BackupRestoreScreen
   └─ AboutScreen
```

**Navigation:**
- Tap section → opens feature screen
- Most screens → standard back button behavior
- Deep stacks preserved when switching tabs
- Settings changes → instant apply

---

## Back Button Behavior Matrix

| Location | Action | Implementation |
|----------|--------|----------------|
| **Tab Root** | First press: Show toast "Press back again to exit"<br>Second press (within 2s): Exit app | `PopScope` with double-back detection |
| **Detail Screen** | Pop to previous screen in stack | Default `Navigator.pop()` |
| **Practice Session** | Show "Exit session?" confirmation dialog | `PopScope` with `onPopInvoked` |
| **Form Screen** | Show "Discard changes?" if modified | `PopScope` with dirty state check |
| **Modal/Dialog** | Close modal (no confirmation) | Default behavior |

---

## Deep Linking Structure

*Future enhancement - not yet implemented*

```
aquarium://
├─ learn/
│  ├─ path/{pathId}
│  └─ lesson/{lessonId}
│
├─ quiz/
│  ├─ practice
│  └─ session/{sessionId}
│
├─ tank/
│  ├─ {tankId}/
│  │  ├─ fish/{fishId}
│  │  ├─ equipment/{equipId}
│  │  └─ logs
│  └─ create
│
└─ settings/
   ├─ profile
   ├─ friends
   ├─ shop/{shopId}
   └─ tools/{toolId}
```

---

## State Preservation

Each tab has its own `Navigator` with a unique key:

```dart
final List<GlobalKey<NavigatorState>> _navigatorKeys = [
  GlobalKey<NavigatorState>(), // Learn tab navigator
  GlobalKey<NavigatorState>(), // Quiz tab navigator
  GlobalKey<NavigatorState>(), // Tank tab navigator
  GlobalKey<NavigatorState>(), // Settings tab navigator
];
```

**Benefits:**
- ✅ Switching tabs doesn't lose your place
- ✅ Can have deep stacks in multiple tabs simultaneously
- ✅ User can browse, switch tabs, come back
- ✅ No unexpected resets or data loss

**Example Flow:**
1. User in Learn tab → opens lesson → starts quiz
2. Switch to Tank tab → view fish details
3. Switch back to Learn tab → **still in quiz where they left off**

---

## Transition Animations

| Transition | Animation | Duration |
|------------|-----------|----------|
| Tab switch | None (instant) | 0ms |
| Push screen | Slide from right (Android)<br>Slide up (iOS) | 300ms |
| Pop screen | Slide to right (Android)<br>Slide down (iOS) | 300ms |
| Modal | Fade + scale | 200ms |
| Dialog | Fade | 150ms |

**Custom animations** can be added using `PageRouteBuilder`:

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MyScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  ),
);
```

---

## Common User Flows

### Flow 1: Complete a Lesson

```
Learn Tab (root)
  → Tap "Getting Started" path
  → LessonScreen: "What is an Aquarium?"
  → Read lesson content
  → Tap "Start Quiz"
  → Answer 5 questions
  → Complete quiz (earn 50 XP)
  → [Back button] → Learn Tab (root)
  → Next lesson unlocked ✓
```

### Flow 2: Practice Due Cards

```
Quiz Tab (root)
  → See "12 cards due" hero card
  → Tap to start practice
  → SpacedRepetitionPracticeScreen
  → ReviewSessionScreen
  → Answer 12 cards (rate difficulty)
  → Complete session (earn 120 XP)
  → [Back button with confirmation] → Quiz Tab (root)
  → Stats updated ✓
```

### Flow 3: Log Water Parameters

```
Tank Tab (root)
  → Current tank: "Community Tank"
  → Tap tank card
  → TankDetailScreen
  → Tap "Water Logs" card
  → AddLogScreen
  → Enter: pH 7.2, Temp 25°C, Ammonia 0
  → Tap "Save"
  → [Auto-pop] → TankDetailScreen
  → See new log in history ✓
```

### Flow 4: Find a Calculator

```
Settings Tab (root)
  → Scroll to "Aquarium Tools"
  → Tap "Workshop"
  → WorkshopScreen
  → Tap "Dosing Calculator"
  → DosingCalculatorScreen
  → Enter tank volume: 200L
  → Calculate fertilizer dose
  → [Back button] → WorkshopScreen
  → [Back button] → Settings Tab (root) ✓
```

---

## Accessibility Considerations

- **Tab labels:** Clear, semantic labels ("Learn", not "📚")
- **Screen reader order:** Top to bottom, left to right
- **Focus management:** First focusable element after tab switch
- **Keyboard navigation:** Tab key cycles through interactive elements
- **Color contrast:** All text meets WCAG AA standards
- **Touch targets:** Minimum 44x44 dp (Material guidelines)

---

## Performance Optimizations

1. **Lazy loading:** Tabs load content only when first viewed
2. **IndexedStack:** Only builds visible tab's widget tree
3. **State preservation:** Prevents rebuilding when switching tabs
4. **Navigator keys:** Unique keys avoid widget tree conflicts
5. **Debouncing:** Tab switches debounced to prevent rapid switching

---

## Testing Checklist

- [ ] All 4 tabs accessible
- [ ] Tab switching preserves state
- [ ] Deep navigation works in each tab
- [ ] Back button on root shows toast
- [ ] Second back press exits app
- [ ] Back button pops detail screens
- [ ] Practice session prevents accidental exit
- [ ] Forms show discard confirmation
- [ ] Hardware back button works (Android)
- [ ] Swipe-back gesture works (iOS)
- [ ] No navigation dead ends
- [ ] All screens reachable from tabs
- [ ] Offline indicator shows when offline
- [ ] Badge appears for due cards
- [ ] Tab icons change when selected

---

*This map is maintained alongside NAVIGATION_DECISION.md*  
*Last updated: February 15, 2025*
