# 🎬 Animation System Specification

## Overview

This document defines a comprehensive animation system for the Aquarium App to achieve A+ polish. Consistent, purposeful animations make the app feel premium and responsive.

---

## 📊 Current State Audit

### Existing Animation Usage

| File | Animation Type | Duration | Curve | Notes |
|------|---------------|----------|-------|-------|
| `enhanced_onboarding_screen.dart` | AnimatedContainer | 200-300ms | easeInOut | Page transitions |
| `enhanced_quiz_screen.dart` | AnimationController | 400-600ms | elasticOut | Progress feedback |
| `enhanced_placement_test_screen.dart` | TweenAnimationBuilder | 300-800ms | easeOut | Question stagger |
| `gem_shop_screen.dart` | ConfettiController | 3s | - | Purchase celebration |
| `house_navigator.dart` | AnimatedContainer | 200-400ms | easeOutCubic | Tab indicator |

### Issues Identified

1. **Inconsistent Durations:** 200ms, 300ms, 400ms, 500ms, 600ms, 800ms, 1200ms, 1500ms used randomly
2. **Inconsistent Curves:** Mix of easeInOut, easeOut, easeIn, elasticOut, easeOutCubic
3. **No Page Transitions:** All routes use default `MaterialPageRoute` (instant)
4. **No Hero Animations:** Shared elements don't animate between screens
5. **No List Animations:** Lists appear instantly, no stagger effects
6. **No Micro-interactions:** Button presses feel flat
7. **No Loading States:** No shimmer/skeleton screens
8. **85 screens total:** Most have ZERO animations

---

## 🎯 Material 3 Motion Guidelines

### Duration Standards (M3)

| Duration | Use Case | Flutter Value |
|----------|----------|---------------|
| **Extra Short** (50ms) | Micro-interactions, icons | `Durations.short1` |
| **Short** (100ms) | Small element changes | `Durations.short2` |
| **Medium 1** (150ms) | State changes, toggles | `Durations.medium1` |
| **Medium 2** (200ms) | Cards, containers | `Durations.medium2` |
| **Medium 3** (250ms) | Dialogs, modals | `Durations.medium3` |
| **Medium 4** (300ms) | Page transitions | `Durations.medium4` |
| **Long 1** (400ms) | Complex transitions | `Durations.long1` |
| **Long 2** (500ms) | Full page fades | `Durations.long2` |
| **Extra Long** (700ms+) | Celebrations, emphasis | `Durations.extralong1` |

### Recommended Easing Curves (M3)

| Curve | Use Case | Flutter Curve |
|-------|----------|---------------|
| **Emphasized** | Most transitions | `Curves.easeOutCubic` |
| **Emphasized Decelerate** | Entering elements | `Curves.easeOutCirc` |
| **Emphasized Accelerate** | Exiting elements | `Curves.easeInCirc` |
| **Standard** | Resizing, repositioning | `Curves.easeInOut` |
| **Standard Decelerate** | Growing elements | `Curves.decelerate` |
| **Standard Accelerate** | Shrinking elements | `Curves.easeIn` |
| **Elastic** | Celebrations, bouncy UI | `Curves.elasticOut` |
| **Spring** | Natural feel | `Curves.bounceOut` |

---

## 🏗️ Animation Constants File

Create `lib/theme/animation_constants.dart`:

```dart
/// Animation constants following Material 3 motion guidelines
library;

import 'package:flutter/material.dart';

/// Standardized animation durations
abstract class AppDurations {
  // Micro-interactions (icons, small elements)
  static const microFast = Duration(milliseconds: 50);
  static const microSlow = Duration(milliseconds: 100);
  
  // Small state changes (toggles, checkboxes)
  static const stateChange = Duration(milliseconds: 150);
  
  // Container/card animations
  static const container = Duration(milliseconds: 200);
  
  // Dialog/modal appearances
  static const modal = Duration(milliseconds: 250);
  
  // Page transitions
  static const pageTransition = Duration(milliseconds: 300);
  
  // Complex multi-element transitions
  static const complex = Duration(milliseconds: 400);
  
  // Celebrations, emphasis animations
  static const celebration = Duration(milliseconds: 600);
  static const celebrationLong = Duration(milliseconds: 800);
  
  // Loading/shimmer cycles
  static const shimmerCycle = Duration(milliseconds: 1500);
  
  // Confetti/particles
  static const confetti = Duration(seconds: 3);
  
  // Stagger delay between list items
  static const staggerDelay = Duration(milliseconds: 50);
}

/// Standardized animation curves
abstract class AppCurves {
  // Primary curve for most transitions (M3 emphasized)
  static const standard = Curves.easeOutCubic;
  
  // For elements entering the screen
  static const enter = Curves.easeOutCirc;
  
  // For elements leaving the screen
  static const exit = Curves.easeInCirc;
  
  // For resizing/repositioning
  static const resize = Curves.easeInOut;
  
  // For celebrations and bouncy feedback
  static const bounce = Curves.elasticOut;
  static const bounceSubtle = Curves.easeOutBack;
  
  // For natural spring feel
  static const spring = Curves.bounceOut;
  
  // For shake/error animations
  static const shake = Curves.elasticIn;
  
  // Smooth deceleration
  static const decelerate = Curves.decelerate;
}

/// Stagger animation utilities
class StaggerHelper {
  /// Calculate delay for item at index in a list
  static Duration delayForIndex(int index, {Duration? baseDelay}) {
    return (baseDelay ?? AppDurations.staggerDelay) * index;
  }
  
  /// Max duration for a staggered list animation
  static Duration totalDuration(
    int itemCount, {
    Duration? baseDelay,
    Duration? itemDuration,
  }) {
    final delay = baseDelay ?? AppDurations.staggerDelay;
    final duration = itemDuration ?? AppDurations.container;
    return delay * (itemCount - 1) + duration;
  }
}

/// Page transition builders
class AppPageTransitions {
  /// Fade + slide up transition (modern feel)
  static PageRouteBuilder<T> fadeSlideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppDurations.pageTransition,
      reverseTransitionDuration: AppDurations.container,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppCurves.enter,
          reverseCurve: AppCurves.exit,
        );
        
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
  
  /// Shared axis horizontal (left/right navigation)
  static PageRouteBuilder<T> sharedAxisX<T>(Widget page, {bool forward = true}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppDurations.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppCurves.standard,
        );
        
        final beginOffset = forward 
            ? const Offset(0.3, 0) 
            : const Offset(-0.3, 0);
        
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
  
  /// Scale fade (for modals/dialogs launched as pages)
  static PageRouteBuilder<T> scaleFade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppDurations.modal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppCurves.bounceSubtle,
        );
        
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
```

---

## 🎨 Animation Type Specifications

### 1. Page Transitions

**Goal:** Smooth navigation between screens

```dart
// Instead of:
Navigator.push(context, MaterialPageRoute(builder: (_) => NewScreen()));

// Use:
Navigator.push(context, AppPageTransitions.fadeSlideUp(const NewScreen()));

// Or for horizontal navigation:
Navigator.push(context, AppPageTransitions.sharedAxisX(const NewScreen()));
```

**Priority:** 🔴 HIGH - Apply to all 85 screens

---

### 2. Hero Animations

**Goal:** Shared elements smoothly transition between screens

```dart
// On source screen (e.g., species list)
Hero(
  tag: 'species_${species.id}',
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(species.imageUrl, height: 80),
  ),
)

// On destination screen (species detail)
Hero(
  tag: 'species_${species.id}',
  child: ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Image.network(species.imageUrl, height: 300),
  ),
)
```

**Apply to:**
- Tank cards → Tank detail
- Species cards → Species detail
- Achievement cards → Achievement modal
- Equipment items → Equipment detail

**Priority:** 🔴 HIGH

---

### 3. List Animations (Staggered Entry)

**Goal:** List items animate in sequentially

```dart
// Using flutter_animate package (RECOMMENDED)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(...)
        .animate()
        .fadeIn(
          delay: AppDurations.staggerDelay * index,
          duration: AppDurations.container,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: AppDurations.staggerDelay * index,
          duration: AppDurations.container,
          curve: AppCurves.enter,
        );
  },
)

// Manual approach (without package)
class StaggeredListItem extends StatefulWidget {
  final int index;
  final Widget child;
  
  const StaggeredListItem({required this.index, required this.child});
  
  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.container,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.enter,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_fadeAnimation);
    
    // Delay based on index
    Future.delayed(AppDurations.staggerDelay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
```

**Apply to:**
- Tank list
- Livestock list
- Achievement grid
- Log entries
- Equipment list
- Species browser
- Lesson list

**Priority:** 🔴 HIGH

---

### 4. Item Add/Remove Animations

**Goal:** Smooth insert/delete from lists

```dart
// Use AnimatedList for dynamic content
final _listKey = GlobalKey<AnimatedListState>();
List<Tank> _tanks = [];

// Add item
void _addTank(Tank tank) {
  _tanks.add(tank);
  _listKey.currentState?.insertItem(
    _tanks.length - 1,
    duration: AppDurations.container,
  );
}

// Remove item
void _removeTank(int index) {
  final removedTank = _tanks.removeAt(index);
  _listKey.currentState?.removeItem(
    index,
    (context, animation) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppCurves.exit,
      );
      return SizeTransition(
        sizeFactor: curvedAnimation,
        child: FadeTransition(
          opacity: curvedAnimation,
          child: TankCard(tank: removedTank),
        ),
      );
    },
    duration: AppDurations.container,
  );
}

// Build AnimatedList
AnimatedList(
  key: _listKey,
  initialItemCount: _tanks.length,
  itemBuilder: (context, index, animation) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: AppCurves.enter,
    );
    return SizeTransition(
      sizeFactor: curvedAnimation,
      child: FadeTransition(
        opacity: curvedAnimation,
        child: TankCard(tank: _tanks[index]),
      ),
    );
  },
)
```

**Priority:** 🟡 MEDIUM

---

### 5. Micro-interactions

#### Button Press Effect

```dart
// Wrap buttons with InkWell + scale animation
class AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  
  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.microSlow,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
```

#### Toggle/Switch Animation

```dart
// Use AnimatedSwitcher for content changes
AnimatedSwitcher(
  duration: AppDurations.stateChange,
  switchInCurve: AppCurves.enter,
  switchOutCurve: AppCurves.exit,
  transitionBuilder: (child, animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
        child: child,
      ),
    );
  },
  child: isOn
      ? Icon(Icons.check, key: const ValueKey('on'))
      : Icon(Icons.close, key: const ValueKey('off')),
)
```

#### Checkbox Animation

```dart
AnimatedContainer(
  duration: AppDurations.stateChange,
  curve: AppCurves.bounceSubtle,
  transform: Matrix4.identity()..scale(isChecked ? 1.1 : 1.0),
  child: Checkbox(value: isChecked, onChanged: onChanged),
)
```

**Priority:** 🟡 MEDIUM

---

### 6. Celebration Animations

#### Confetti (Already Implemented)

```dart
// Using existing confetti package
ConfettiController _confettiController = ConfettiController(
  duration: AppDurations.confetti,
);

// Trigger on achievement unlock, level up, lesson complete
_confettiController.play();
```

#### XP Gain Animation

```dart
// Floating XP indicator that rises and fades
class XpGainWidget extends StatefulWidget {
  final int xpAmount;
  final VoidCallback? onComplete;
  
  @override
  State<XpGainWidget> createState() => _XpGainWidgetState();
}

class _XpGainWidgetState extends State<XpGainWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.celebrationLong,
    )..forward().whenComplete(() => widget.onComplete?.call());
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _controller.value,
          child: Transform.translate(
            offset: Offset(0, -80 * _controller.value),
            child: Transform.scale(
              scale: 1.0 + (_controller.value * 0.3),
              child: Text(
                '+${widget.xpAmount} XP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

#### Achievement Unlock (Enhance Existing)

Already has good animation in `achievement_unlocked_dialog.dart`. Consider adding:
- Pulsing glow effect around badge
- Particle burst behind icon

**Priority:** 🟢 LOW (polish existing)

---

### 7. Loading States

#### Shimmer Effect

```dart
// Using shimmer package
Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  period: AppDurations.shimmerCycle,
  child: Container(
    height: 100,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)

// Custom shimmer gradient
class ShimmerLoadingCard extends StatefulWidget {
  @override
  State<ShimmerLoadingCard> createState() => _ShimmerLoadingCardState();
}

class _ShimmerLoadingCardState extends State<ShimmerLoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.shimmerCycle,
    )..repeat();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
```

#### Skeleton Screen

```dart
// Create skeleton versions of cards
class TankCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(height: 20, width: 150), // Title
            SizedBox(height: 8),
            ShimmerBox(height: 14, width: 100), // Subtitle
            SizedBox(height: 16),
            ShimmerBox(height: 60, width: double.infinity), // Content
          ],
        ),
      ),
    );
  }
}
```

**Priority:** 🟡 MEDIUM

---

### 8. Feedback States

#### Success Animation

```dart
class SuccessCheckmark extends StatefulWidget {
  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<SuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.celebration,
    )..forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Curves.elasticOut.transform(_controller.value),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3 * (1 - _controller.value)),
                  blurRadius: 20 + (20 * _controller.value),
                  spreadRadius: 5 * _controller.value,
                ),
              ],
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}
```

#### Error Shake Animation

```dart
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;
  
  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }
  
  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _controller.forward(from: 0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final sineValue = sin(_controller.value * 4 * pi);
        return Transform.translate(
          offset: Offset(sineValue * 10, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
```

**Priority:** 🟡 MEDIUM

---

## 📦 Recommended Packages

### Must Have (Add to pubspec.yaml)

```yaml
dependencies:
  # Declarative animations (game changer!)
  flutter_animate: ^4.5.0
  
  # Already have this - keep it
  confetti: ^0.7.0
  
  # Shimmer loading states
  shimmer: ^3.0.0
```

### Nice to Have

```yaml
dependencies:
  # Complex vector animations (splash screens, onboarding)
  lottie: ^3.1.0
  
  # Spring physics animations
  sprung: ^3.0.1
  
  # Animated icons
  animated_icon_button: ^1.0.3
```

### flutter_animate Quick Reference

```dart
// Fade + slide in
Widget build(BuildContext context) {
  return MyWidget()
      .animate()
      .fadeIn(duration: AppDurations.container)
      .slideY(begin: 0.2, end: 0, curve: AppCurves.enter);
}

// Staggered list
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget()
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn()
        .slideX(begin: 0.1);
  },
)

// On tap scale
GestureDetector(
  child: Button()
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .scaleXY(end: 0.95, duration: 100.ms),
)

// Shimmer effect built-in
Container().animate(onPlay: (c) => c.repeat())
    .shimmer(duration: 1500.ms);
```

---

## 📋 Implementation Priority

### Phase 1: Foundation (Week 1) 🔴 HIGH

1. Create `lib/theme/animation_constants.dart`
2. Add `flutter_animate` and `shimmer` to pubspec.yaml
3. Create `lib/utils/page_transitions.dart`
4. Apply page transitions to top 10 most-used navigation paths

### Phase 2: Lists & Loading (Week 2) 🔴 HIGH

1. Add staggered entry to all list screens
2. Create skeleton/shimmer loading states for:
   - Tank list
   - Species browser
   - Achievement grid
3. Add Hero animations to key card → detail flows

### Phase 3: Micro-interactions (Week 3) 🟡 MEDIUM

1. Add button press animations to primary CTAs
2. Add AnimatedSwitcher to all toggle states
3. Add feedback animations (success/error)

### Phase 4: Polish (Week 4) 🟢 LOW

1. Enhance celebration animations (XP floaters, particle effects)
2. Add Lottie animations for splash/onboarding
3. Fine-tune timing across all animations
4. Add subtle idle animations (breathing effects on important elements)

---

## 🧪 Testing Animations

### Performance Testing

```dart
// Enable timeline in debug
debugProfileBuildsEnabled = true;
debugProfilePaintsEnabled = true;

// Check in DevTools:
// - Frames should be 60fps (16.67ms)
// - No jank during animations
// - Memory stable during long animations
```

### Accessibility

```dart
// Respect user preferences
MediaQuery.of(context).disableAnimations
// or
MediaQueryData.fromView(View.of(context)).disableAnimations

// Reduce motion when requested
final reduceMotion = MediaQuery.of(context).disableAnimations;
final duration = reduceMotion 
    ? Duration.zero 
    : AppDurations.pageTransition;
```

### Visual Testing

1. Record screen during navigation flows
2. Review at 0.25x speed
3. Check for:
   - Consistent timing feel
   - Smooth curves (no stuttering)
   - Appropriate durations (not too fast/slow)
   - Visual hierarchy (important elements animate first)

---

## 📁 File Structure

```
lib/
├── theme/
│   ├── animation_constants.dart    # NEW: Durations, curves
│   ├── app_theme.dart
│   └── room_themes.dart
├── utils/
│   ├── page_transitions.dart       # NEW: Custom PageRouteBuilders
│   └── animation_helpers.dart      # NEW: Stagger, shimmer utilities
├── widgets/
│   ├── animated/                   # NEW: Reusable animated widgets
│   │   ├── animated_list_item.dart
│   │   ├── shimmer_placeholder.dart
│   │   ├── xp_gain_overlay.dart
│   │   ├── success_checkmark.dart
│   │   └── shake_widget.dart
│   └── [existing widgets]
└── screens/
    └── [update all 85 screens]
```

---

## ✅ Success Metrics

| Metric | Before | Target |
|--------|--------|--------|
| Screens with animations | ~10 | 85 (100%) |
| Consistent duration usage | ❌ | ✅ |
| Consistent curve usage | ❌ | ✅ |
| Page transitions | 0 | 100% |
| Hero animations | 0 | 10+ flows |
| List stagger animations | 0 | All lists |
| Loading states | 0 | All async content |
| Frame rate during animation | Unknown | 60fps |

---

## 📚 References

- [Material 3 Motion Guidelines](https://m3.material.io/styles/motion/overview)
- [Flutter Animation Docs](https://docs.flutter.dev/ui/animations)
- [flutter_animate Package](https://pub.dev/packages/flutter_animate)
- [Implicit vs Explicit Animations](https://docs.flutter.dev/ui/animations/implicit-animations)

---

*Document created: 2025-02-12*
*Last updated: 2025-02-12*
*Author: Animation Design Agent*
