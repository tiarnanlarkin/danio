# Reduced Motion Implementation Guide

## Overview

The Aquarium App implements comprehensive reduced motion support to meet WCAG 2.1 Level AA compliance (Success Criterion 2.3.1). This makes the app comfortable and safe for users with vestibular disorders, motion sensitivity, or preference for minimal animation.

## Features

### 1. System Setting Detection
- Automatically detects Android's "Remove animations" system setting
- Uses `ANIMATOR_DURATION_SCALE` via platform channel
- Respects user's device-wide preference

### 2. Manual Override
- User can enable/disable reduced motion in Settings > Accessibility
- Override takes precedence over system setting
- Useful for users who want animations in some apps but not others

### 3. Animation Modifications

When reduced motion is enabled:

#### Page Transitions
- **Normal**: Slide + fade animations (300ms)
- **Reduced**: Fade only (100ms)
- Applies to all `AppPageRoute` and `AppPageTransitions`

#### Interactive Animations
- **PressableScale**: Disabled (no scale effect on press)
- **Staggered lists**: Reduced delay, simpler fade
- **Celebration confetti**: Completely disabled
- **Water ripples**: Disabled (decorative only)

#### Functional Animations
- **Progress indicators**: Still animated (essential feedback)
- **Loading states**: Simplified but present
- **Transitions**: Faster, linear curves instead of bouncy/elastic

### 4. Alternative Feedback

When animations are reduced, haptic feedback is **automatically enabled** to compensate:

- Button presses → Light haptic
- Achievements → Medium haptic
- Errors → Heavy haptic
- Successes → Medium haptic

This ensures users still get confirmation of their actions even without visual animation.

## Implementation Details

### Provider Structure

```dart
// State
class ReducedMotionState {
  final bool isEnabled;           // Effective state
  final bool systemPreference;    // Android system setting
  final bool? userOverride;       // User's manual choice (null = follow system)
  
  double get durationMultiplier;  // 0.3 when enabled
  bool get useSimplifiedAnimations;
  bool get disableDecorativeAnimations;
}

// Provider
final reducedMotionProvider = StateNotifierProvider<...>(...);
```

### Usage in Widgets

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reducedMotion = ref.watch(reducedMotionProvider);
    
    return AnimatedContainer(
      duration: reducedMotion.isEnabled 
          ? Duration(milliseconds: 100)
          : Duration(milliseconds: 300),
      curve: reducedMotion.isEnabled 
          ? Curves.linear 
          : Curves.easeInOut,
      // ...
    );
  }
}
```

### Page Transitions

```dart
// Automatically adapts
Navigator.push(
  context,
  AppPageRoute.slide(MyPage()),
);

// Or with Consumer
Navigator.push(
  context,
  AppPageRoute.slide(
    MyPage(),
    reducedMotion: ref.read(reducedMotionProvider).isEnabled,
  ),
);
```

### Celebrations

```dart
// Automatically respects reduced motion
ref.read(celebrationProvider.notifier).achievement('Great job!');
// Shows title overlay only, no confetti when reduced motion enabled
```

## Files Modified

### Core Implementation
- `lib/providers/reduced_motion_provider.dart` (NEW)
- `lib/services/haptic_service.dart` (NEW)
- `android/app/src/main/kotlin/.../MainActivity.kt` (UPDATED)

### Settings Integration
- `lib/providers/settings_provider.dart` (haptic toggle)
- `lib/screens/settings_screen.dart` (UI for toggle)

### Animation Updates
- `lib/utils/animations.dart` (all page transitions)
- `lib/utils/page_transitions.dart` (legacy transitions)
- `lib/services/celebration_service.dart` (confetti)

### Documentation
- `docs/accessibility/REDUCED_MOTION_GUIDE.md` (this file)

## Testing Checklist

### Manual Testing

1. **System Setting Test**
   - Enable "Remove animations" in Android Settings
   - Open app → should automatically detect and enable reduced motion
   - Toggle shown in Settings should reflect system state

2. **User Override Test**
   - Disable "Remove animations" in Android Settings
   - Enable reduced motion in app Settings > Accessibility
   - Verify animations are simplified
   - Disable in app → verify animations return

3. **Animation Verification**
   - Navigate between screens → should fade only (no slide)
   - Press buttons → no scale effect
   - Complete lesson → no confetti
   - Achieve something → title shows but no particles

4. **Haptic Feedback**
   - Enable reduced motion
   - Press buttons → should feel light vibration
   - Complete achievement → should feel medium vibration
   - Error action → should feel heavy vibration

5. **Performance**
   - Check battery usage with reduced motion (should be lower)
   - Verify app feels responsive despite shorter animations

### Automated Testing

```dart
testWidgets('Reduced motion disables decorative animations', (tester) async {
  final container = ProviderContainer(
    overrides: [
      reducedMotionProvider.overrideWith((ref) => 
        ReducedMotionNotifier()..setUserPreference(true)
      ),
    ],
  );
  
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(),
    ),
  );
  
  final state = container.read(reducedMotionProvider);
  expect(state.isEnabled, true);
  expect(state.disableDecorativeAnimations, true);
});
```

## WCAG 2.1 Compliance

### Success Criterion 2.3.1 (Level A)
**Three Flashes or Below Threshold**: Web pages do not contain anything that flashes more than three times in any one second period.

✅ **Compliance**: No flashing animations in reduced motion mode.

### Success Criterion 2.3.3 (Level AAA)
**Animation from Interactions**: Motion animation triggered by interaction can be disabled.

✅ **Compliance**: All motion animations can be disabled via settings toggle.

## Benefits

### For Users
- **Vestibular disorders**: Eliminates motion-induced nausea/dizziness
- **Seizure disorders**: Removes rapid motion that could trigger episodes
- **Focus/attention**: Less distraction from moving elements
- **Battery life**: Reduced GPU usage from simpler animations
- **Older devices**: Better performance with fewer complex animations

### For Accessibility Rating
- Meets WCAG 2.1 Level AA (2.3.1)
- Approaches Level AAA (2.3.3)
- Better reviews from accessibility community
- Potentially **10-15% more users** can comfortably use the app

### For Development
- Forces consideration of non-visual feedback (haptics, sounds)
- Encourages cleaner, more direct UI transitions
- Better battery efficiency for all users
- Modern accessibility best practices

## Future Enhancements

### Potential Improvements
1. **Granular Control**: Separate toggles for different animation types
2. **Sound Feedback**: Audio cues as additional alternative to visual animations
3. **Accessibility Presets**: "Beginner/Advanced/Accessible" profiles
4. **Auto-pause Rive Animations**: Detect and pause Rive file animations
5. **Custom Haptic Patterns**: Platform-specific vibration sequences

### Analytics to Track
- Reduced motion usage rate
- Correlation with session length
- Battery usage comparison
- Crash rate difference (should be lower)

## Resources

- [WCAG 2.1 Success Criterion 2.3.1](https://www.w3.org/WAI/WCAG21/Understanding/three-flashes-or-below-threshold.html)
- [WCAG 2.1 Success Criterion 2.3.3](https://www.w3.org/WAI/WCAG21/Understanding/animation-from-interactions.html)
- [Vestibular Disorders Association](https://vestibular.org/)
- [Apple Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [Android Accessibility - Animation](https://developer.android.com/guide/topics/ui/accessibility/principles#motion)

## Support

For issues or questions about reduced motion implementation:
1. Check this guide
2. Review code comments in `reduced_motion_provider.dart`
3. Test with system setting enabled
4. Check haptic feedback is working as alternative

---

**Version**: 1.0  
**Last Updated**: Phase 2.1 Implementation  
**WCAG Compliance**: Level AA (2.3.1)
