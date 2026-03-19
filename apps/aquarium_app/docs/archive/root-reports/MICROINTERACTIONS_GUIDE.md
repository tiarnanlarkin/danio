# Microinteractions Implementation Guide

## Goal
Add subtle, delightful micro-interactions throughout the app for premium feel. These small touches make the app feel polished and responsive.

## Target Microinteractions

### 1. Button Press Feedback (HIGH PRIORITY)
**Status:** Partially implemented (haptics exist)  
**Enhancement:** Add visual scale/bounce on tap

**Implementation:**
```dart
class AppButton extends StatefulWidget {
  // Add scale animation on tap
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.95).animate(_controller),
        child: // ... button content
      ),
    );
  }
}
```

### 2. Loading Shimmer Effects
**Current:** CircularProgressIndicator  
**Enhancement:** Skeleton loading with shimmer

**Screens to enhance:**
- Tank list loading
- Livestock list loading
- Learn screen loading
- Charts loading

**Package:** Already has Skeletonizer package

**Example:**
```dart
Skeletonizer(
  enabled: isLoading,
  child: ListView.builder(
    itemCount: isLoading ? 5 : items.length,
    itemBuilder: (context, index) {
      final item = isLoading ? placeholderItem : items[index];
      return ItemCard(item: item);
    },
  ),
)
```

### 3. Success Celebrations (Already exists!)
**Current implementation:**
- Level-up celebrations with confetti ✅
- Achievement unlocks ✅
- Celebration service ✅

**No work needed** - already comprehensive!

### 4. Pull-to-Refresh (Already exists!)
**Implemented in:**
- livestock_screen ✅
- equipment_screen ✅  
- logs_screen ✅

**Good coverage** - no additional work needed.

### 5. List Item Animations
**Enhancement:** Animate items as they appear in lists

**Using flutter_animate (already in dependencies):**
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return ItemCard(item: items[index])
      .animate()
      .fadeIn(duration: 300.ms, delay: (index * 50).ms)
      .slideY(begin: 0.2, end: 0);
  },
)
```

### 6. Page Transitions (Custom routes)
**Current:** Default Material transitions  
**Enhancement:** Custom page route with slide+fade

**Example:**
```dart
class FadeSlidePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  
  FadeSlidePageRoute({required this.builder});
  
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
  
  // ... rest of PageRoute implementation
}
```

## Priority Order

### Phase 1: Quick Wins (2-3h)
1. ✅ **Button press scale animation** - Add to AppButton
2. ✅ **List fade-in animations** - High-traffic lists (learn, livestock, equipment)
3. ✅ **Loading shimmers** - Replace simple spinners

### Phase 2: Polish (2-3h)
4. Card hover effects (subtle scale on hover - desktop/web)
5. Input focus animations (already has focus states)
6. Custom page transitions
7. Micro-animations on state changes

## Implementation Strategy

### Parallel Sub-Agents (Recommended)
- **Agent 1:** Button animations (AppButton + high-use buttons)
- **Agent 2:** List animations (learn_screen, livestock_screen)
- **Agent 3:** Loading shimmers (tank list, charts, search)
- **Agent 4:** Page transitions (create custom route class)

Each agent: 1-2 files, clear scope, 30-45 min

## Testing Checklist

- [ ] Animations don't cause janky frames (60fps target)
- [ ] No animation conflicts with existing Hero animations
- [ ] Haptic feedback still works
- [ ] Animations respect reduced motion accessibility setting
- [ ] Build succeeds
- [ ] Visual smoothness verified on both light/dark themes

## Performance Considerations

**DO:**
- ✅ Use `flutter_animate` package (already in deps)
- ✅ Keep animations under 300ms
- ✅ Use `Curves.easeOutCubic` for natural feel
- ✅ Test on lower-end devices

**DON'T:**
- ❌ Animate on every frame (use AnimationController)
- ❌ Create new animation controllers in build()
- ❌ Forget to dispose controllers
- ❌ Use overly complex animations in lists

## Accessibility

Respect `MediaQuery.of(context).disableAnimations`:

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;

Widget build(BuildContext context) {
  return widget
    .animate(autoPlay: !reduceMotion)
    .fadeIn(duration: reduceMotion ? 0.ms : 300.ms);
}
```

## Files to Modify

**High Priority:**
- `lib/widgets/core/app_button.dart` - Add press scale
- `lib/screens/learn_screen.dart` - List animations
- `lib/screens/livestock_screen.dart` - List animations
- `lib/screens/home_screen.dart` - Tank card animations

**Medium Priority:**
- `lib/widgets/core/app_card.dart` - Hover effects
- `lib/utils/custom_page_route.dart` - Create new file
- Loading states across charts, search, etc.

## Success Criteria

- ✅ App feels more responsive
- ✅ No performance regressions (60fps maintained)
- ✅ Animations enhance UX, don't distract
- ✅ All animations respect accessibility settings
- ✅ Build succeeds
- ✅ Visual polish noticeable

## Commit Messages

```
feat: add button press scale animations
feat: add list item fade-in animations to learn/livestock screens  
feat: add loading shimmer effects throughout app
feat: implement custom page transitions
```
