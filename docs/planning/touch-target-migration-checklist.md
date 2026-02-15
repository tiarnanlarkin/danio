# Touch Target Migration Checklist

## Overview
This checklist helps ensure all screens comply with Material Design 3's 48x48dp minimum touch target requirement.

---

## Quick Reference

### ✅ Already Compliant
- Default `IconButton` (48x48dp)
- Default `FloatingActionButton` (56x56dp)
- `ElevatedButton`, `TextButton`, `OutlinedButton` (default padding)
- `AppButton` (all sizes)
- `AppIconButton` (all sizes)
- `AppChip` (all sizes)
- `SpeedDialFAB` (main + actions)

### ⚠️ Needs Review
- `FloatingActionButton.small` (40x40dp → wrap in 48x48)
- Custom `GestureDetector` with small children
- Custom `InkWell` with small children
- Raw `Chip` widgets (use `AppChip` instead)
- Custom icon buttons

---

## Screen-by-Screen Checklist

### Priority 1: High-Traffic Screens

- [ ] **home_screen.dart**
  - [x] IconButtons (compliant - using default)
  - [x] SpeedDialFAB (compliant - 48x48 actions)
  - [ ] Custom GestureDetectors (review needed)

- [ ] **tank_detail_screen.dart**
  - [x] QuickAddFAB (fixed)
  - [ ] IconButtons in app bar
  - [ ] Action buttons

- [ ] **enhanced_onboarding_screen.dart**
  - [ ] Skip button
  - [ ] Navigation buttons
  - [ ] Interactive elements

- [ ] **search_screen.dart**
  - [ ] Filter chips
  - [ ] Clear button
  - [ ] Search suggestions

### Priority 2: Settings & Configuration

- [ ] **settings_screen.dart**
  - [ ] List tile trailing icons
  - [ ] Switch controls
  - [ ] Section headers with actions

- [ ] **difficulty_settings_screen.dart**
  - [ ] Difficulty chips
  - [ ] Save/cancel buttons

- [ ] **backup_restore_screen.dart**
  - [ ] Action buttons
  - [ ] File picker triggers

### Priority 3: Data Entry Screens

- [ ] **add_log_screen.dart**
  - [ ] Input field trailing icons
  - [ ] Date/time picker buttons
  - [ ] Save button

- [ ] **create_tank_screen.dart**
  - [ ] Size selector
  - [ ] Type chips
  - [ ] Image picker

- [ ] **reminders_screen.dart**
  - [ ] Add reminder FAB
  - [ ] Delete icons
  - [ ] Edit buttons

### Priority 4: Browse/List Screens

- [ ] **achievements_screen.dart**
  - [ ] Achievement cards
  - [ ] Filter chips
  - [ ] Sort buttons

- [ ] **friends_screen.dart**
  - [ ] Add friend button
  - [ ] Friend action buttons
  - [ ] Profile taps

- [ ] **leaderboard_screen.dart**
  - [ ] Tab buttons
  - [ ] Profile avatars
  - [ ] Action icons

- [ ] **species_browser_screen.dart**
  - [ ] Filter chips
  - [ ] Species cards
  - [ ] Wishlist button

- [ ] **plant_browser_screen.dart**
  - [ ] Filter chips
  - [ ] Plant cards
  - [ ] Add to tank button

### Priority 5: Tool Screens

- [ ] **compatibility_checker_screen.dart**
  - [ ] Species selector
  - [ ] Check button
  - [ ] Result actions

- [ ] **stocking_calculator_screen.dart**
  - [ ] Input controls
  - [ ] Calculate button
  - [ ] Add species button

- [ ] **dosing_calculator_screen.dart**
  - [ ] Input steppers
  - [ ] Calculate button
  - [ ] Save preset button

- [ ] **co2_calculator_screen.dart**
  - [ ] Input controls
  - [ ] Calculate button

- [ ] **tank_volume_calculator_screen.dart**
  - [ ] Dimension inputs
  - [ ] Shape selector
  - [ ] Calculate button

### Priority 6: Reference Screens

- [ ] **glossary_screen.dart**
  - [ ] Search button
  - [ ] Bookmark icons
  - [ ] Term expansion

- [ ] **faq_screen.dart**
  - [ ] Section expansion
  - [ ] Search button

- [ ] **parameter_guide_screen.dart**
  - [ ] Parameter cards
  - [ ] Info buttons

### Priority 7: Guide Screens

- [ ] **acclimation_guide_screen.dart**
- [ ] **algae_guide_screen.dart**
- [ ] **breeding_guide_screen.dart**
- [ ] **disease_guide_screen.dart**
- [ ] **emergency_guide_screen.dart**
- [ ] **equipment_guide_screen.dart**
- [ ] **feeding_guide_screen.dart**
- [ ] **hardscape_guide_screen.dart**

### Priority 8: Learning Screens

- [ ] **enhanced_quiz_screen.dart**
  - [ ] Answer buttons
  - [ ] Skip button
  - [ ] Submit button

- [ ] **placement_test_screen.dart**
  - [ ] Answer options
  - [ ] Navigation buttons

- [ ] **spaced_repetition_practice_screen.dart**
  - [ ] Answer buttons
  - [ ] Rating buttons

- [ ] **stories_screen.dart**
  - [ ] Story cards
  - [ ] Play button

- [ ] **story_player_screen.dart**
  - [ ] Play/pause
  - [ ] Navigation controls

### Priority 9: Miscellaneous

- [ ] **activity_feed_screen.dart**
- [ ] **analytics_screen.dart**
- [ ] **charts_screen.dart**
- [ ] **cost_tracker_screen.dart**
- [ ] **equipment_screen.dart**
- [ ] **inventory_screen.dart**
- [ ] **journal_screen.dart**
- [ ] **livestock_screen.dart**
- [ ] **logs_screen.dart**
- [ ] **maintenance_checklist_screen.dart**
- [ ] **shop_street_screen.dart**
- [ ] **tasks_screen.dart**
- [ ] **wishlist_screen.dart**

---

## Common Patterns to Fix

### 1. Small IconButtons
```dart
// ❌ Before
IconButton(
  iconSize: 20,  // Too small
  icon: Icon(Icons.close),
  onPressed: () {},
)

// ✅ After
AppIconButton(
  icon: Icons.close,
  semanticsLabel: 'Close',
  size: AppButtonSize.small,  // 48x48
  onPressed: () {},
)
```

### 2. FloatingActionButton.small
```dart
// ❌ Before
FloatingActionButton.small(
  child: Icon(Icons.add),
  onPressed: () {},
)

// ✅ After
SizedBox(
  width: AppTouchTargets.minimum,
  height: AppTouchTargets.minimum,
  child: FloatingActionButton(
    mini: true,
    child: Icon(Icons.add, size: 20),
    onPressed: () {},
  ),
)
```

### 3. Custom GestureDetector
```dart
// ❌ Before
GestureDetector(
  onTap: () {},
  child: Icon(Icons.favorite, size: 24),
)

// ✅ After
Semantics(
  button: true,
  label: 'Favorite',
  child: GestureDetector(
    onTap: () {},
    child: Container(
      constraints: BoxConstraints.tightFor(
        width: AppTouchTargets.minimum,
        height: AppTouchTargets.minimum,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.favorite, size: 24),
    ),
  ),
)
```

### 4. Raw Chip
```dart
// ❌ Before
Chip(
  label: Text('Freshwater'),
  onDeleted: () {},
)

// ✅ After
AppChip(
  label: 'Freshwater',
  variant: AppChipVariant.filled,
  size: AppChipSize.medium,
  onDeleted: () {},
)
```

### 5. ListTile Trailing Icons
```dart
// ✅ Already Compliant (default trailing size is 48x48)
ListTile(
  title: Text('Settings'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
)

// ⚠️ If custom icon:
ListTile(
  title: Text('Settings'),
  trailing: AppIconButton(
    icon: Icons.edit,
    semanticsLabel: 'Edit',
    onPressed: () {},
  ),
  onTap: () {},
)
```

---

## Automated Search Commands

### Find potential issues:
```bash
# Find small IconButtons
grep -rn "iconSize.*1[0-9]\|iconSize.*2[0-3]" lib/screens/

# Find FloatingActionButton.small
grep -rn "FloatingActionButton.small" lib/

# Find custom GestureDetectors
grep -rn "GestureDetector" lib/screens/ | wc -l

# Find raw Chip usage
grep -rn "Chip(" lib/screens/ | grep -v "AppChip"
```

---

## Testing Protocol

For each screen:
1. ✅ Run app on small phone (e.g., 4.7" screen)
2. ✅ Tap all interactive elements
3. ✅ Enable TalkBack/VoiceOver
4. ✅ Test with "Large Text" accessibility setting
5. ✅ Verify no overlap between adjacent buttons

---

## Progress Tracking

**Total Screens:** 60  
**Completed:** 5  
**Remaining:** 55  

**Completion Rate:** 8%

---

## Next Steps

1. Start with **Priority 1** screens (home, tank detail, onboarding)
2. Review all `GestureDetector` usages in top 10 screens
3. Replace raw `Chip` with `AppChip` globally
4. Add automated tests for touch target compliance

---

## Notes

- Default Flutter widgets (`IconButton`, `ElevatedButton`, etc.) are usually compliant
- Focus migration efforts on:
  - Custom widgets
  - `GestureDetector`/`InkWell` with small children
  - `FloatingActionButton.small`
  - Raw `Chip` widgets

- Use existing `AppButton`, `AppIconButton`, `AppChip` components whenever possible
- Document any custom interactive widgets that need special handling
