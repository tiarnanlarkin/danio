# Engagement Features (Streak Freeze, Bulk Add, Activity Filters, Sample Tank)

Repo: `apps/aquarium_app`

This document summarizes the engagement-focused features implemented:

- **Streak Freeze** (1 skip per week) surfaced in UI
- **Bulk livestock add** (paste a list of fish/shrimp/snails)
- **Activity log filters** (multi-type + date range)
- **Sample tank discoverability** (add demo tank from Settings even after onboarding)

---

## 1) Streak Freeze

### What it does
- Users have a **weekly “streak freeze”**: if they miss **exactly 1 day** (i.e. a 2-day gap between activity dates), the app will **consume the freeze** and keep the streak going.
- Freeze is **re-granted weekly**.

### Where the logic lives
- `lib/models/user_profile.dart`
  - Fields: `hasStreakFreeze`, `streakFreezeUsedDate`, `streakFreezeGrantedDate`
  - Helpers:
    - `shouldResetStreakFreeze` (weekly reset)
    - `streakFreezeUsedThisWeek`
- `lib/providers/user_profile_provider.dart`
  - `recordActivity({int xp = 0})`:
    - Weekly freeze reset
    - Streak increment rules
    - Freeze consumption when `dayDifference == 2`

### UI surfacing
- `lib/screens/learn_screen.dart`
  - The streak card now also shows whether a freeze is **available** or **used this week**.
- `lib/screens/settings_screen.dart`
  - “Learn Fishkeeping” card shows streak + freeze status.

### Streak triggers (important)
To make streaks feel meaningful outside “Study”, activity is now recorded when users log normal aquarium events:
- `lib/screens/add_log_screen.dart`
  - After saving any log, we call `recordActivity(xp: …)` with a small XP reward based on log type.

---

## 2) Bulk Livestock Add

### What it does
Allows adding many livestock entries quickly via a bottom sheet.

Supported line formats:
- `Neon Tetra, 12`
- `Neon Tetra x12` / `Neon Tetra ×12`
- `12 Neon Tetra`
- `Mystery Snail` (defaults to 1)

### Entry points
- `lib/screens/livestock_screen.dart`
  - Empty state: **Bulk add** button
  - AppBar menu: **Bulk add**

### What happens when adding
- Each livestock entry is saved.
- A corresponding **Activity Log** entry is created (`LogType.livestockAdded`).
- XP + streak activity is awarded via:
  - `userProfileProvider.notifier.recordActivity(xp: count * XpRewards.addLivestock)`

---

## 3) Activity Filters

### What it does
Adds richer filtering to the Activity Log:
- **Multi-select log types** (chips)
- Optional **date range** filter
- Summary bar showing active filters
- One-tap **Clear filters**

### Where it lives
- `lib/screens/logs_screen.dart`
  - Replaced the single-type dropdown filter with a bottom-sheet filter UI.

---

## 4) Sample Tank Discoverability

### What it does
Users can add a demo tank even if they already have real tanks.

### Entry points
- **Home empty state** already supported:
  - `lib/screens/home_screen.dart` → “Try a sample tank”
- **New:** Settings option always available:
  - `lib/screens/settings_screen.dart` → “Add Sample Tank”

### Implementation
- `lib/services/sample_data.dart`
  - Added: `SampleData.addFreshwaterDemoTank(storage)`
  - Always generates **unique IDs** (tank + livestock + equipment + logs)
- `lib/providers/tank_provider.dart`
  - Added: `TankActions.addDemoTank()`
  - Invalidates relevant providers so UI updates immediately.

---

## 5) Extra engagement glue (small but impactful)

### Auto-log livestock changes
- `lib/screens/livestock_screen.dart`
  - When adding a brand-new livestock entry: auto-creates a `LogType.livestockAdded` log and awards XP/streak.
  - When removing livestock: auto-creates a `LogType.livestockRemoved` log.

### Logging counts as activity
- `lib/screens/add_log_screen.dart`
  - Saving a log now records user activity and awards small XP.

---

## Files changed / added

- `lib/screens/learn_screen.dart` (freeze UI in streak card)
- `lib/providers/user_profile_provider.dart` (already contained freeze logic)
- `lib/models/user_profile.dart` (already contained freeze fields/helpers)
- `lib/screens/settings_screen.dart` (Add Sample Tank; freeze status in Learn card)
- `lib/services/sample_data.dart` (new `addFreshwaterDemoTank`)
- `lib/providers/tank_provider.dart` (new `TankActions.addDemoTank()`)
- `lib/screens/livestock_screen.dart` (bulk add UI; auto logs; XP/streak)
- `lib/screens/add_log_screen.dart` (record activity + XP on log save)
- `lib/screens/logs_screen.dart` (multi-filters + date range)
- `lib/widgets/room_navigation.dart` (fixed a syntax issue encountered during analysis)

---

## Quick manual test checklist

1. **Sample tank**
   - Settings → Explore → **Add Sample Tank**
   - Verify it appears in tank list and navigates to Tank Detail.

2. **Bulk livestock add**
   - Tank → Livestock → Bulk add
   - Paste:
     - `Neon Tetra, 12`
     - `Corydoras x6`
     - `2 Mystery Snail`
   - Verify 3 livestock entries added + Activity Log entries created.

3. **Activity filters**
   - Tank → Activity Log → filter icon
   - Select types + date range
   - Verify list updates and “Clear filters” works.

4. **Streak freeze**
   - Do an activity (e.g., create a log) two days apart with exactly 1 missed day.
   - Verify freeze is consumed and streak continues.
   - Learn screen should show freeze available/used status.
