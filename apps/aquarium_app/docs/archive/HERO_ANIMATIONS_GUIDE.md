# Hero Animations Implementation Guide

## Goal
Add Hero animations between screens for smooth, premium transitions. Hero animations create visual continuity by animating shared elements between screens.

## Current State
- ✅ Tank card → Tank detail screen
- ✅ Room background (partial)

## Target Additions (High Value)

### 1. Species Cards → Lesson Screen
**Flow:** Learn screen species list → Lesson detail  
**Element:** Species card with icon/image  
**Impact:** HIGH (very common navigation)

### 2. Livestock Cards → Livestock Detail
**Flow:** Livestock list → Livestock detail screen  
**Element:** Livestock card/tile  
**Impact:** HIGH (common user flow)

### 3. Achievement Cards → Achievement Detail
**Flow:** Achievements list → Achievement detail  
**Element:** Achievement badge/card  
**Impact:** MEDIUM (satisfying visual)

### 4. Equipment Cards → Equipment Detail
**Flow:** Equipment list → Equipment detail (if exists)  
**Element:** Equipment card  
**Impact:** MEDIUM

## Implementation Pattern

### Basic Hero Animation

**Source screen (list):**
```dart
Hero(
  tag: 'species-${species.id}', // Unique tag
  child: SpeciesCard(species: species),
)
```

**Destination screen (detail):**
```dart
Hero(
  tag: 'species-${species.id}', // Same tag
  child: SpeciesHeader(species: species),
)
```

### With Material (for cards):
```dart
// Wrap in Material to preserve elevation during transition
Hero(
  tag: 'livestock-${livestock.id}',
  child: Material(
    type: MaterialType.transparency,
    child: LivestockCard(livestock: livestock),
  ),
)
```

### Flightshuttle Builder (Advanced)
For complex animations where source and destination look very different:

```dart
Hero(
  tag: 'achievement-${achievement.id}',
  flightShuttleBuilder: (
    flightContext,
    animation,
    direction,
    fromContext,
    toContext,
  ) {
    return ScaleTransition(
      scale: animation,
      child: direction == HeroFlightDirection.push
          ? toContext.widget
          : fromContext.widget,
    );
  },
  child: AchievementBadge(achievement: achievement),
)
```

## Guidelines

### DO:
- ✅ Use unique, consistent tags (e.g., 'species-123')
- ✅ Match the visual element closely (same size/shape helps)
- ✅ Wrap in Material if the element has elevation
- ✅ Test the animation looks smooth in both directions
- ✅ Keep tags simple (avoid complex objects)

### DON'T:
- ❌ Use the same tag for multiple widgets on screen
- ❌ Animate elements that change size drastically
- ❌ Forget to add Hero on BOTH screens
- ❌ Use dynamic tags that change on rebuild

## Testing

After implementation:
1. Navigate from list → detail (should animate smoothly)
2. Navigate back (animation should reverse)
3. Check no visual glitches (flashing, jumping)
4. Verify tag uniqueness (no duplicate tag warnings)

## File Locations

**Species Cards:**
- Source: `lib/screens/learn_screen.dart`
- Destination: `lib/screens/lesson_screen.dart` (or equivalent)

**Livestock Cards:**
- Source: `lib/screens/livestock_screen.dart`
- Destination: `lib/screens/livestock_detail_screen.dart`

**Achievement Cards:**
- Source: `lib/screens/achievements_screen.dart`
- Destination: `lib/screens/achievement_detail_screen.dart` (if exists)

## Example Implementation

### Species Card Animation

**learn_screen.dart:**
```dart
// Wrap species card in Hero
GestureDetector(
  onTap: () => _openLesson(species),
  child: Hero(
    tag: 'species-${species.id}',
    child: Material(
      type: MaterialType.transparency,
      child: SpeciesCard(
        species: species,
        // ... other props
      ),
    ),
  ),
)
```

**lesson_screen.dart:**
```dart
// Add Hero to header/title area
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'species-${widget.species.id}',
              child: SpeciesHeader(species: widget.species),
            ),
          ),
        ),
        // ... rest of content
      ],
    ),
  );
}
```

## Success Criteria

- ✅ Smooth animation (no janky frames)
- ✅ Both directions work (push and pop)
- ✅ No duplicate tag warnings
- ✅ Visually pleasing (element flows naturally)
- ✅ Build succeeds
- ✅ No performance regressions

## Commit Message

```
feat: add Hero animations to [screen names]

- Added Hero animation for species cards → lesson screen
- Added Hero animation for livestock cards → detail screen
- Smooth transitions improve perceived app performance
- Premium feel to navigation
```
