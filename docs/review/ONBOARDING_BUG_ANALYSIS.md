# Onboarding Flow Bug Analysis

**Date:** 2025-01-XX  
**Bug:** Skipping onboarding leads to different home page layout than completing onboarding  
**Severity:** HIGH - Users get inconsistent app experience  
**Status:** Root cause identified, fix documented

---

## Executive Summary

The bug occurs because **Skip paths navigate to `HomeScreen` directly**, while **Complete paths navigate to `HouseNavigator`**. These are fundamentally different screens:

- **`HomeScreen`**: Just the tank management view (Living Room only)
- **`HouseNavigator`**: Full app shell with navigation between all rooms (Study, Living Room, Friends, Leaderboard, Workshop, Shop Street)

Users who skip end up trapped in the Living Room with no way to access other app features.

---

## Flow Diagrams

### Path 1: Skip in ProfileCreationScreen (BUG PATH)

```
ProfileCreationScreen
    ↓ (Skip button)
    ↓ _skipToHome()
    ↓   - Creates default profile
    ↓   - Navigator.pushReplacement → HomeScreen
    ↓
HomeScreen (BARE - NO NAVIGATION!)
    ❌ No bottom nav bar
    ❌ No access to Learn/Study
    ❌ No access to Friends
    ❌ No access to Workshop
    ❌ No access to Shop Street
```

### Path 2: Complete ProfileCreationScreen → Full Flow

```
ProfileCreationScreen
    ↓ (Continue button)
    ↓ _createProfile()
    ↓   - Creates user profile
    ↓   - Navigator.pushReplacement → EnhancedPlacementTestScreen
    ↓
EnhancedPlacementTestScreen
    ↓ (Answer questions)
    ↓ _completeTest()
    ↓   - Navigator.pushReplacement → PlacementResultScreen
    ↓
PlacementResultScreen
    ↓ (Continue button)
    ↓   - Navigator.pushReplacement → EnhancedTutorialWalkthroughScreen
    ↓
EnhancedTutorialWalkthroughScreen
    ↓ (Create tank or Skip)
    ↓   - Navigator.pushAndRemoveUntil → HouseNavigator
    ↓
HouseNavigator (CORRECT!)
    ✅ Full bottom nav bar
    ✅ Access to all rooms
    ✅ Proper app experience
```

### Path 3: OnboardingScreen → ExperienceAssessment Flow (ALSO BUGGY)

```
OnboardingScreen
    ↓ (Skip or Get Started)
    ↓ _completeOnboarding()
    ↓   - OnboardingService.completeOnboarding()
    ↓   - Navigator.pushReplacement → ExperienceAssessmentScreen
    ↓
ExperienceAssessmentScreen
    ↓ (Answer questions)
    ↓ _startJourney()
    ↓   - Navigator.pushReplacement → FirstTankWizardScreen
    ↓
FirstTankWizardScreen
    ↓ (Create tank)
    ↓ _createTank()
    ↓   - Navigator.pushAndRemoveUntil → HomeScreen (BUG!)
    ↓
HomeScreen (BARE - NO NAVIGATION!)
    ❌ Same issue as Path 1
```

---

## Root Cause Analysis

### File: `lib/screens/onboarding/profile_creation_screen.dart`

**Line 50-60 - `_skipToHome()` method:**
```dart
Future<void> _skipToHome() async {
  // ... creates profile ...
  
  // BUG: Navigates to HomeScreen instead of HouseNavigator
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const HomeScreen()),  // ❌ WRONG
  );
}
```

### File: `lib/screens/onboarding/first_tank_wizard_screen.dart`

**Line 76-81 - `_createTank()` method:**
```dart
Future<void> _createTank() async {
  // ... creates tank ...
  
  // BUG: Navigates to HomeScreen instead of HouseNavigator
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomeScreen()),  // ❌ WRONG
    (route) => false,
  );
}
```

### Why This Happens

The `HomeScreen` was designed to be the "Living Room" view within the `HouseNavigator` PageView. It should never be navigated to directly as a standalone screen. 

Looking at `house_navigator.dart` line 146-158:
```dart
PageView(
  controller: _pageController,
  children: const [
    LearnScreen(),           // Room 0: Study
    _LivingRoomWrapper(),    // Room 1: Living Room (wraps HomeScreen)
    FriendsScreen(),         // Room 2: Friends
    LeaderboardScreen(),     // Room 3: Leaderboard
    WorkshopScreen(),        // Room 4: Workshop
    ShopStreetScreen(),      // Room 5: Shop Street
  ],
),
```

The `HouseNavigator` wraps `HomeScreen` inside `_LivingRoomWrapper` and provides:
- Bottom navigation bar (`_RoomIndicatorBar`)
- Swipe navigation between rooms
- Tutorial overlay system
- Offline/sync indicators

---

## What's Different Between the Two Paths

| Aspect | Skip Path (HomeScreen) | Complete Path (HouseNavigator) |
|--------|------------------------|--------------------------------|
| Navigation | None - stuck in Living Room | Full 6-room navigation |
| Learning | Cannot access Study room | Full lesson access |
| Social | Cannot access Friends | Can connect with friends |
| Tools | Cannot access Workshop | Full calculator access |
| Shop | Cannot access Shop Street | Can browse shop |
| Tutorial | Never shown | Shown on first launch |
| App Experience | Broken | Complete |

---

## Recommended Fix

### Fix 1: `profile_creation_screen.dart`

Change `_skipToHome()` to navigate to `HouseNavigator`:

```dart
// BEFORE (lines 57-59):
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => const HomeScreen()),
);

// AFTER:
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => const HouseNavigator()),
  (route) => false,
);
```

### Fix 2: `first_tank_wizard_screen.dart`

Change `_createTank()` to navigate to `HouseNavigator`:

```dart
// BEFORE (lines 76-79):
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const HomeScreen()),
  (route) => false,
);

// AFTER:
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const HouseNavigator()),
  (route) => false,
);
```

### Required Import Changes

In `profile_creation_screen.dart`, change:
```dart
// REMOVE:
import '../home_screen.dart';

// ADD:
import '../house_navigator.dart';
```

In `first_tank_wizard_screen.dart`, change:
```dart
// REMOVE:
import '../home_screen.dart';

// ADD:
import '../house_navigator.dart';
```

---

## Full Code Changes

### File: `lib/screens/onboarding/profile_creation_screen.dart`

```diff
- import '../home_screen.dart';
+ import '../house_navigator.dart';

  Future<void> _skipToHome() async {
    setState(() => _isSubmitting = true);

    try {
      final profileNotifier = ref.read(userProfileProvider.notifier);

      // Create default profile for dev/testing
      await profileNotifier.createProfile(
        name: 'Dev User',
        experienceLevel: ExperienceLevel.beginner,
        primaryTankType: TankType.freshwater,
        goals: [UserGoal.keepFishAlive],
      );

      if (!mounted) return;

-     // Skip directly to HomeScreen
-     Navigator.of(context).pushReplacement(
-       MaterialPageRoute(builder: (context) => const HomeScreen()),
-     );
+     // Skip to HouseNavigator (main app shell)
+     Navigator.of(context).pushAndRemoveUntil(
+       MaterialPageRoute(builder: (context) => const HouseNavigator()),
+       (route) => false,
+     );
    } catch (e) {
      // ... error handling ...
    }
  }
```

### File: `lib/screens/onboarding/first_tank_wizard_screen.dart`

```diff
- import '../home_screen.dart';
+ import '../house_navigator.dart';

  Future<void> _createTank() async {
    // Use tankActionsProvider to create the tank
    await ref
        .read(tankActionsProvider)
        .createTank(
          name: _tankName,
          type: _tankType,
          volumeLitres: _volumeLitres,
        );

    if (mounted) {
      // 🎉 Celebrate first tank creation!
      ref.read(celebrationProvider.notifier).milestone(
        'Tank Created! 🐠',
        subtitle: 'Welcome to your aquarium journey!',
      );
      
      // Navigate after celebration starts
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
-         Navigator.of(context).pushAndRemoveUntil(
-           MaterialPageRoute(builder: (_) => const HomeScreen()),
-           (route) => false,
-         );
+         Navigator.of(context).pushAndRemoveUntil(
+           MaterialPageRoute(builder: (_) => const HouseNavigator()),
+           (route) => false,
+         );
        }
      });
    }
  }
```

---

## Testing Checklist

After applying fixes, verify:

- [ ] **Skip in ProfileCreationScreen** → Lands on HouseNavigator with bottom nav
- [ ] **Complete ProfileCreationScreen** → Lands on HouseNavigator with bottom nav  
- [ ] **ExperienceAssessment → FirstTankWizard** → Lands on HouseNavigator with bottom nav
- [ ] **EnhancedTutorialWalkthrough Skip** → Lands on HouseNavigator (already correct)
- [ ] **EnhancedTutorialWalkthrough Create Tank** → Lands on HouseNavigator (already correct)
- [ ] All rooms accessible via swipe and bottom nav
- [ ] Tutorial overlay shows for new users
- [ ] Returning users land on HouseNavigator via `_AppRouter`

---

## Additional Observations

### Already Correct Navigation

The following files correctly navigate to `HouseNavigator`:
- `enhanced_tutorial_walkthrough_screen.dart` - Line 102 `_skipTutorial()` and line 131 `_createFirstTank()`

### App Router is Correct

`main.dart` `_AppRouter` correctly routes to `HouseNavigator` when:
- Onboarding is completed AND profile exists

The bug only occurs in the intermediate navigation flows that were added later.

---

## Prevention

To prevent similar issues:

1. **Establish rule**: `HomeScreen` should NEVER be a navigation target - only `HouseNavigator`
2. **Add lint/comment**: Mark `HomeScreen` class with documentation warning
3. **Code review checklist**: Any navigation should verify target is `HouseNavigator` for main app entry
