# Reduced Motion - Quick Start Guide

## For Developers: How to Use Reduced Motion in Your Widgets

### 1. Basic Usage - Check if Reduced Motion is Enabled

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reducedMotion = ref.watch(reducedMotionProvider);
    
    return AnimatedContainer(
      duration: reducedMotion.isEnabled 
          ? Duration(milliseconds: 100)  // Fast fade
          : Duration(milliseconds: 300), // Normal animation
      curve: reducedMotion.isEnabled 
          ? Curves.linear           // Simple
          : Curves.easeInOut,       // Smooth
      // ... your widget
    );
  }
}
```

### 2. Skip Decorative Animations Completely

```dart
class MyDecorativeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reducedMotion = ref.watch(reducedMotionProvider);
    
    // Skip confetti, particles, ripples, etc.
    if (reducedMotion.disableDecorativeAnimations) {
      return SizedBox.shrink(); // Don't show at all
    }
    
    return ConfettiWidget(); // Show normally
  }
}
```

### 3. Page Navigation

```dart
// Automatic - just use the helper
Navigator.push(
  context,
  AppPageRoute.slide(MyPage()),  // Auto-adapts to fade if reduced motion
);

// Or with explicit control
final reducedMotion = ref.read(reducedMotionProvider);
Navigator.push(
  context,
  AppPageRoute.slide(
    MyPage(),
    reducedMotion: reducedMotion.isEnabled,
  ),
);
```

### 4. Add Haptic Feedback (Replaces Visual Animations)

```dart
class MyButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        // Add haptic when action succeeds
        ref.haptic.success();
        
        // Or light tap for simple interactions
        ref.haptic.light();
        
        // Or error for failures
        ref.haptic.error();
      },
      child: Text('Press Me'),
    );
  }
}
```

### 5. Use PressableScale (Auto-Respects Reduced Motion)

```dart
PressableScale(
  enableHaptic: true,  // Adds vibration on reduced motion
  onPressed: () {
    // Handle tap
  },
  child: Card(...),
)
```

## Testing Reduced Motion

### On Android Device

1. **Enable System Setting**:
   - Settings → Accessibility → Remove animations
   - Or Settings → Developer options → Animation scale → Off

2. **Test in App**:
   - Open Aquarium App
   - Go to Settings → Accessibility
   - Toggle should show "System setting detected"

3. **Verify Animations**:
   - Navigate between screens → should fade only (no slide)
   - Press buttons → no scale effect
   - Complete lesson → no confetti

### In Code (Unit Tests)

```dart
testWidgets('Widget respects reduced motion', (tester) async {
  final container = ProviderContainer(
    overrides: [
      reducedMotionProvider.overrideWith((ref) {
        final notifier = ReducedMotionNotifier();
        notifier.setUserPreference(true);
        return notifier;
      }),
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
});
```

## Common Patterns

### Pattern 1: Conditional Animation

```dart
// Good: Fast fade when reduced, normal slide when not
AnimatedSwitcher(
  duration: reducedMotion.isEnabled 
      ? Duration(milliseconds: 100)
      : Duration(milliseconds: 300),
  transitionBuilder: (child, animation) {
    if (reducedMotion.isEnabled) {
      return FadeTransition(opacity: animation, child: child);
    }
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0.1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  },
  child: myChild,
)
```

### Pattern 2: Duration Multiplier

```dart
final baseDuration = Duration(milliseconds: 300);
final effectiveDuration = baseDuration * reducedMotion.durationMultiplier;

// Results in:
// - Normal: 300ms
// - Reduced: 90ms (300 * 0.3)
```

### Pattern 3: Skip + Haptic Alternative

```dart
void celebrate() {
  final reducedMotion = ref.read(reducedMotionProvider);
  
  if (reducedMotion.disableDecorativeAnimations) {
    // Skip visual animation, use haptic instead
    ref.haptic.success();
    return;
  }
  
  // Show full confetti celebration
  ref.read(celebrationProvider.notifier).confetti();
}
```

## Checklist for New Animations

When adding a new animation, ask:

- [ ] Is this decorative or functional?
  - Decorative → skip completely when reduced motion
  - Functional → simplify (fade only, shorter duration)

- [ ] Does it involve motion (slide/scale/rotate)?
  - Yes → replace with fade when reduced motion
  - No → just reduce duration

- [ ] Is there alternative feedback?
  - Add haptic for important actions
  - Add sound cue if applicable

- [ ] Did I test with reduced motion enabled?
  - Toggle in Settings → Accessibility
  - Verify animation changes

## Quick Reference

### State Properties

```dart
reducedMotion.isEnabled                    // bool - overall state
reducedMotion.systemPreference             // bool - Android setting
reducedMotion.userOverride                 // bool? - manual override
reducedMotion.durationMultiplier           // double - 0.3 or 1.0
reducedMotion.useSimplifiedAnimations      // bool - same as isEnabled
reducedMotion.disableDecorativeAnimations  // bool - same as isEnabled
```

### Haptic Methods

```dart
ref.haptic.light()      // Button presses
ref.haptic.medium()     // Confirmations
ref.haptic.heavy()      // Critical actions
ref.haptic.selection()  // Picker scrolling
ref.haptic.success()    // Achievements
ref.haptic.error()      // Validation failures
```

### Page Routes

```dart
AppPageRoute.slide(page, reducedMotion: bool)    // Slide or fade
AppPageRoute.fade(page, reducedMotion: bool)     // Always fade
AppPageRoute.scale(page, reducedMotion: bool)    // Scale or fade
AppPageRoute.slideUp(page, reducedMotion: bool)  // Slide up or fade
```

## Common Mistakes to Avoid

### ❌ DON'T: Ignore reduced motion in critical UI

```dart
// Bad: Always animates
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.bounceOut,
  // ...
)
```

### ✅ DO: Respect the setting

```dart
// Good: Adapts based on setting
AnimatedContainer(
  duration: reducedMotion.isEnabled 
      ? Duration(milliseconds: 100)
      : Duration(milliseconds: 300),
  curve: reducedMotion.isEnabled 
      ? Curves.linear 
      : Curves.bounceOut,
  // ...
)
```

### ❌ DON'T: Disable all animations blindly

```dart
// Bad: Some animations are necessary for understanding
if (reducedMotion.isEnabled) {
  return StaticWidget();  // User loses context
}
```

### ✅ DO: Keep functional animations, simplify them

```dart
// Good: Functional animations remain, just simpler
LoadingIndicator(
  duration: reducedMotion.isEnabled 
      ? Duration(milliseconds: 800)   // Faster
      : Duration(milliseconds: 2000), // Normal
)
```

## Need Help?

1. Check `REDUCED_MOTION_GUIDE.md` for detailed info
2. Look at existing implementations in:
   - `lib/utils/animations.dart`
   - `lib/services/celebration_service.dart`
   - `lib/screens/settings_screen.dart`
3. Test on real device with system setting enabled

---

**Remember**: Reduced motion is about **comfort and accessibility**, not removing all motion. Keep functional animations, skip decorative ones, and always provide alternative feedback!
