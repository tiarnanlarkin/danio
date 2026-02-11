# Onboarding Screens

This directory contains the enhanced onboarding flow for the Aquarium App.

## Overview

The onboarding experience is designed to be engaging, personalized, and Duolingo-style interactive. It guides users from first launch to their first tank setup.

## Screens

### 1. OnboardingScreen (Main Entry)
**File:** `../onboarding_screen.dart`

Simple 3-page introduction carousel showcasing app features.
- Track Your Aquariums
- Manage Livestock & Equipment
- Stay On Top of Maintenance

Users can skip or proceed to profile creation.

### 2. ProfileCreationScreen
**File:** `profile_creation_screen.dart`

Collects user preferences and experience level.

**Required Fields:**
- Experience Level (Beginner/Intermediate/Expert)
- Primary Tank Type (Freshwater/Marine)
- Goals (at least one)

**Optional:**
- User name

**Flow:** ProfileCreationScreen → EnhancedPlacementTestScreen

### 3. EnhancedPlacementTestScreen ⭐ NEW
**File:** `enhanced_placement_test_screen.dart`

Interactive quiz to assess user knowledge and personalize learning paths.

**Features:**
- 20 questions across 5 learning paths
- Animated feedback (confetti for correct, shake for incorrect)
- Real-time explanations
- Skip option after 10 questions
- Progress tracking
- Color-coded categories

**Quiz Topics:**
1. Nitrogen Cycle
2. Water Parameters
3. First Fish
4. Maintenance
5. Planted Tanks

**Flow:** EnhancedPlacementTestScreen → PlacementResultScreen

### 4. PlacementResultScreen
**File:** `../placement_result_screen.dart`

Shows quiz results and personalized recommendations.

**Displays:**
- Overall score and percentage
- Per-path recommendations
- Lessons to skip (if applicable)
- XP earned for testing out
- Detailed breakdown

**Flow:** PlacementResultScreen → EnhancedTutorialWalkthroughScreen

### 5. EnhancedTutorialWalkthroughScreen ⭐ NEW
**File:** `enhanced_tutorial_walkthrough_screen.dart`

Multi-step interactive tutorial with First Tank Wizard.

**Tutorial Steps:**
1. Welcome to Your Journey 🐠
2. Track Everything 📊
3. Learn as You Go ⭐
4. Create First Tank (Wizard)

**First Tank Wizard Features:**
- **Demo Tank Option** - Pre-configured 60L community tank
- Custom tank creation
  - Tank name
  - Tank type (Freshwater/Marine)
  - Volume (with quick select chips)
  - Water type (Tropical/Coldwater)
- Celebration animation on creation
- Skip option available

**Flow:** EnhancedTutorialWalkthroughScreen → HouseNavigator (Main App)

## Quick Start Guide

### QuickStartGuide Widget
**File:** `../../widgets/quick_start_guide.dart`

**Two Components:**

#### 1. Overlay Guide (Auto-shows on first launch)
Full-screen overlay with tooltips pointing to key features.

**Steps:**
1. Welcome to Your Tank
2. Log Water Parameters
3. Complete Tasks
4. Learn & Grow

#### 2. Quick Start Tips Card
Dismissible card that appears on home screen for new users.

**Usage:**
```dart
// Wrap home screen
QuickStartGuide(
  child: YourHomeScreen(),
)

// Or add Tips Card directly
QuickStartTipsCard()
```

## Animations

All enhanced screens use animation controllers for:
- ✨ Confetti celebrations
- 📏 Scale transitions
- 📐 Slide/fade effects
- 🔴 Shake on errors
- 📊 Progress bar animations

**Dependencies:**
- `confetti: ^0.7.0`
- `shared_preferences` (for state persistence)

## State Management

**User Profile:** Riverpod (`userProfileProvider`)
**Tanks:** Riverpod (`tankActionsProvider`)
**Preferences:** SharedPreferences
- `quick_start_guide_seen`
- `quick_start_tips_card_dismissed`

## Testing

Run flutter analyze:
```bash
flutter analyze
```

Test onboarding flow:
```bash
# Reset onboarding state
# Delete app data or use:
SharedPreferences.getInstance().then((prefs) {
  prefs.clear();
});
```

## Design Principles

1. **Show, Don't Tell** - Visual first, text second
2. **Celebrate Success** - Positive reinforcement with animations
3. **Respect User Time** - Skip options at every stage
4. **Personalize** - Adapt content based on experience level
5. **Reduce Friction** - Demo data for quick exploration

## Future Enhancements

- [ ] Sound effects for celebrations
- [ ] Haptic feedback
- [ ] Highlight-based tooltips
- [ ] Multiple demo tank templates
- [ ] Localization support
- [ ] Accessibility improvements (screen reader annotations)

## File Structure

```
lib/screens/
├── onboarding_screen.dart          (Entry point)
├── placement_test_screen.dart      (Original, kept for reference)
├── placement_result_screen.dart    (Results display)
└── onboarding/
    ├── profile_creation_screen.dart
    ├── enhanced_placement_test_screen.dart  ⭐ NEW
    ├── enhanced_tutorial_walkthrough_screen.dart  ⭐ NEW
    └── tutorial_walkthrough_screen.dart     (Original, kept for reference)

lib/widgets/
└── quick_start_guide.dart  ⭐ NEW
```

## Notes for Developers

- **DO NOT** delete the original `placement_test_screen.dart` and `tutorial_walkthrough_screen.dart` - they serve as reference
- The enhanced versions are drop-in replacements
- All animations are optional - screens work fine without them
- Demo tank feature is toggleable - users can still create custom tanks
- Quick Start Guide can be re-triggered by clearing SharedPreferences

---

**Version:** 1.0  
**Last Updated:** 2025-02-09  
**Maintainer:** Development Team
