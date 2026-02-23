# Hearts System - Implementation Guide

## Overview

The Hearts System provides a Duolingo-style lives mechanism where users:
- Start with 5 hearts
- Lose hearts on mistakes or skipped tasks
- Gain hearts by completing practice mode
- Auto-refill hearts over time (5 minutes per heart)
- See visual feedback when hearts change

## Architecture

### Core Components

1. **HeartsService** (`services/hearts_service.dart`)
   - Business logic for hearts management
   - Auto-refill calculations
   - Heart gain/loss operations

2. **HeartsProvider** (`providers/hearts_provider.dart`)
   - Reactive state management wrapper
   - Simplified API for UI components
   - Actions: loseHeart(), gainHeart(), refillToMax()

3. **Hearts Widgets** (`widgets/hearts_widgets.dart`)
   - `HeartIndicator` - Compact display for app bars
   - `DetailedHeartsDisplay` - Full display with timer
   - `CompactHeartsDisplay` - Icon-only display
   - `HeartAnimation` - Animated gain/loss feedback
   - `OutOfHeartsModal` - Dialog when hearts depleted

4. **Hearts Overlay** (`widgets/hearts_overlay.dart`)
   - `HeartsChangeOverlay` - Full-screen dramatic animation
   - `HeartsStatusBanner` - Top banner with refill timer
   - `HeartsScreenMixin` - Helper for screens needing hearts

## Usage

### Display Hearts in App Bar

```dart
import '../widgets/hearts_widgets.dart';

// In your app bar or header:
const HeartIndicator(compact: true)
```

**Already integrated in:**
- ✅ Home Screen (Living Room)
- ✅ Learn Screen (Study Room)
- ✅ Enhanced Quiz Screen
- ✅ Lesson Screen

### Consume Hearts on Mistakes

```dart
import '../services/hearts_service.dart';
import '../widgets/hearts_overlay.dart';

// When user makes a mistake:
final heartsService = ref.read(heartsServiceProvider);
final success = await heartsService.loseHeart();

if (success && mounted) {
  // Show visual feedback
  await showHeartsChangeOverlay(context, gained: false);
}

// Check if user is out of hearts:
if (!heartsService.hasHeartsAvailable) {
  final result = await showOutOfHeartsModal(context);
  if (result == 'practice') {
    // Navigate to practice mode
  } else {
    // User chose to wait - exit or disable lesson
  }
}
```

**Already implemented in:**
- ✅ Enhanced Quiz Screen (wrong answers)
- ✅ Lesson Screen (wrong answers, skipped exercises)

### Award Hearts for Practice Mode

```dart
// When user completes practice successfully:
final heartsService = ref.read(heartsServiceProvider);
final success = await heartsService.gainHeart();

if (success && mounted) {
  await showHeartsChangeOverlay(context, gained: true);
}
```

**Already implemented in:**
- ✅ Lesson Screen (practice mode completion)

### Use HeartsScreenMixin for Convenience

For screens that frequently interact with hearts:

```dart
class MyLessonScreen extends ConsumerStatefulWidget {
  // ...
}

class _MyLessonScreenState extends ConsumerState<MyLessonScreen> 
    with HeartsScreenMixin {
  
  void handleWrongAnswer() async {
    // Consume heart with automatic visual feedback
    final success = await consumeHeart();
    
    if (!canContinue()) {
      // Out of hearts - show dialog
      final action = await showOutOfHeartsDialog();
      // Handle action...
    }
  }
  
  void handlePracticeComplete() async {
    // Award heart with automatic visual feedback
    await awardHeart();
  }
}
```

### Display Hearts Status Banner

Show a live countdown timer at the top of screens:

```dart
HeartsStatusBanner(
  showTimer: true,
  child: YourScreenContent(),
)
```

### Check Auto-Refill

The app automatically checks for auto-refill when:
- App resumes from background (handled in `main.dart`)
- Before consuming hearts (handled in `HeartsService`)

Manual check:
```dart
final heartsService = ref.read(heartsServiceProvider);
await heartsService.checkAndApplyAutoRefill();
```

## Configuration

Edit `HeartsConfig` in `services/hearts_service.dart`:

```dart
class HeartsConfig {
  static const int maxHearts = 5;              // Maximum hearts
  static const int startingHearts = 5;         // Starting hearts
  static const Duration refillInterval = 
      Duration(minutes: 5);                    // 5 min per heart
  static const int practiceReward = 1;         // Hearts per practice
}
```

## Visual Feedback Levels

### 1. Subtle (App Bar Indicator)
- Compact hearts count: "❤️ 3/5"
- Changes color when low/empty
- Always visible, non-intrusive

### 2. Moderate (In-Screen Display)
- Row of heart icons (filled/empty)
- Live countdown timer
- Used in lesson/quiz contexts

### 3. Dramatic (Full-Screen Overlay)
- Large animated heart icon
- "±1 Heart" text
- Encouraging message
- Auto-dismisses after animation

## Integration Checklist

When adding hearts to a new lesson/quiz screen:

- [ ] Import `hearts_widgets.dart` and `hearts_overlay.dart`
- [ ] Display `HeartIndicator` in app bar/header
- [ ] Consume heart on mistakes: `loseHeart()` + `showHeartsChangeOverlay()`
- [ ] Check if out of hearts: `hasHeartsAvailable` → `showOutOfHeartsModal()`
- [ ] Award hearts for practice mode: `gainHeart()` + `showHeartsChangeOverlay()`
- [ ] Consider using `HeartsScreenMixin` for convenience
- [ ] Test edge cases: 0 hearts, full hearts, refill timing

## State Management

Hearts state is stored in `UserProfile`:
```dart
class UserProfile {
  final int hearts;                    // Current hearts (0-5)
  final DateTime? lastHeartRefill;     // Last refill timestamp
  // ...
}
```

Updates automatically trigger UI rebuilds via Riverpod:
- `userProfileProvider` - Source of truth
- `heartsStateProvider` - Derived reactive state
- `heartsServiceProvider` - Business logic
- `heartsActionsProvider` - Action methods

## Testing Scenarios

1. **Heart Loss**
   - User answers incorrectly → loses 1 heart
   - Animation shows "-1 Heart"
   - Count decreases in app bar

2. **Running Out**
   - Last heart lost → modal appears
   - Options: Practice Mode or Wait
   - Lessons disabled until hearts available

3. **Auto-Refill**
   - 5 minutes pass → 1 heart refills
   - Timer shows "Next heart in 4m 32s"
   - Auto-applies on app resume

4. **Practice Mode**
   - Complete practice → earn 1 heart
   - Animation shows "+1 Heart"
   - Can't exceed max (5)

5. **Full Hearts**
   - At max hearts → timer hidden
   - Shows "Hearts are full!"
   - No refill needed

## Accessibility

- Heart icons have semantic labels
- Countdown timer updates announced
- Modals support keyboard navigation
- Color-blind friendly (icons + text)

## Performance

- Timer updates throttled to 1 second
- Animations use hardware acceleration
- State updates batched via Riverpod
- No unnecessary rebuilds

## Future Enhancements

Potential additions:
- [ ] Shop items to refill hearts instantly
- [ ] Streak bonuses (extra hearts for 7-day streak)
- [ ] Achievements for never running out
- [ ] Difficulty modes (more/fewer hearts)
- [ ] Heart "insurance" power-ups
- [ ] Social features (gift hearts to friends)

## Troubleshooting

**Hearts not updating?**
- Check `userProfileProvider` is being watched
- Ensure `ref.invalidate()` called after changes
- Verify storage persistence working

**Timer not showing?**
- Ensure `Timer` is disposed properly
- Check `mounted` before `setState()`
- Verify `lastHeartRefill` timestamp set

**Animation not playing?**
- Use `mounted` check before showing overlay
- Ensure `BuildContext` is valid
- Check `vsync` for animation controllers

## Examples

See existing implementations:
- `screens/enhanced_quiz_screen.dart` - Full quiz integration
- `screens/lesson_screen.dart` - Lesson with practice mode
- `screens/home_screen.dart` - App bar display
- `screens/learn_screen.dart` - Study room display
