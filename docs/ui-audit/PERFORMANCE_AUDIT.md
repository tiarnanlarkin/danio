# Performance Audit Report 🎯

**Aquarium App - UI Performance Analysis**  
**Date:** 2025-01-20  
**Auditor:** Performance & Smoothness Agent  
**Target:** 60fps everywhere (A+ smoothness)

---

## Executive Summary

The codebase shows **solid foundations** with good patterns in place (optimized images, builder patterns in key screens, vsync on animations). However, there are several **critical areas** that will cause dropped frames on mid-range devices, particularly around list rendering and excessive object allocation.

| Severity | Count | Impact |
|----------|-------|--------|
| 🔴 Critical | 3 | Will cause visible jank |
| 🟠 High | 5 | May cause frame drops under load |
| 🟡 Medium | 6 | Minor performance overhead |
| ✅ Good | 8 | Patterns already optimized |

---

## 🔴 CRITICAL Issues (Fix Immediately)

### 1. Livestock Screen - Non-Builder List Pattern
**File:** `lib/screens/livestock_screen.dart`  
**Line:** ~196  
**Severity:** 🔴 CRITICAL

**Problem:**
```dart
// CURRENT (BAD) - Creates ALL widgets upfront
ListView(
  children: [
    ...livestock.map((l) => _LivestockCard(...)),  // ❌ O(n) allocation
  ],
)
```

**Impact:** With 50+ livestock entries, this creates 50+ widgets immediately, causing:
- Initial render jank (100-300ms)
- Memory bloat
- Scroll stutter

**Fix:**
```dart
// CORRECT - Only creates visible widgets
ListView.builder(
  itemCount: livestock.length + 2, // +2 for summary cards
  itemBuilder: (context, index) {
    if (index == 0) return _SummaryCard(...);
    if (index == 1 && _isSelectMode) return _SelectionBanner(...);
    final adjustedIndex = index - (_isSelectMode ? 2 : 1);
    if (adjustedIndex < 0 || adjustedIndex >= livestock.length) {
      return const SizedBox.shrink();
    }
    return _LivestockCard(livestock: livestock[adjustedIndex], ...);
  },
)
```

---

### 2. Excessive withOpacity() Calls
**Files:** 607 occurrences across codebase  
**Severity:** 🔴 CRITICAL (cumulative impact)

**Problem:**
```dart
// CURRENT (BAD) - Creates new Color object EVERY build
color: AppColors.primary.withOpacity(0.1),  // ❌ New object each time
```

**Impact:** Every `withOpacity()` call:
- Allocates a new `Color` object
- Triggers garbage collection
- 607 calls × multiple rebuilds = thousands of allocations/second

**Fix - Option A:** Pre-define colors in theme:
```dart
// In app_theme.dart
class AppColors {
  static const primary = Color(0xFF2196F3);
  static const primaryLight = Color(0x1A2196F3);  // 0.1 opacity pre-computed
  static const primaryMedium = Color(0x4D2196F3); // 0.3 opacity pre-computed
  // etc.
}
```

**Fix - Option B:** Use Color.fromARGB for static values:
```dart
// Calculate once: 0.1 opacity = 0x1A (26 in decimal)
color: const Color.fromARGB(26, 33, 150, 243),  // ✅ const, zero allocation
```

**Priority files to fix first:**
- `room_scene.dart` (48 occurrences)
- `home_screen.dart` (35 occurrences)
- `widgets/*.dart` (120+ combined)

---

### 3. Photo Gallery - Nested ScrollView Performance Antipattern
**File:** `lib/screens/photo_gallery_screen.dart`  
**Lines:** ~85-100  
**Severity:** 🔴 CRITICAL

**Problem:**
```dart
// CURRENT (BAD)
ListView.builder(
  itemBuilder: (ctx, i) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,                        // ❌ Forces full layout
          physics: NeverScrollableScrollPhysics(), // ❌ Defeats builder optimization
          ...
        ),
      ],
    );
  },
)
```

**Impact:** `shrinkWrap: true` forces the GridView to measure ALL items to determine height, defeating lazy loading entirely.

**Fix:** Use `CustomScrollView` with `SliverGrid`:
```dart
CustomScrollView(
  slivers: [
    for (final month in grouped.keys) ...[
      SliverToBoxAdapter(
        child: _MonthHeader(month: month, count: grouped[month]!.length),
      ),
      SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (ctx, j) => _PhotoThumbnail(photo: grouped[month]![j]),
          childCount: grouped[month]!.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
      ),
    ],
  ],
)
```

---

## 🟠 HIGH Priority Issues

### 4. Learn Screen - ExpansionTile Children Built Eagerly
**File:** `lib/screens/learn_screen.dart`  
**Lines:** ~385-420  
**Severity:** 🟠 HIGH

**Problem:**
```dart
ExpansionTile(
  children: [
    ...path.lessons.map((lesson) => ListTile(...)),  // ❌ Built even when collapsed
  ],
)
```

**Fix:** Use `ExpansionTile` with lazy builder or conditionally build:
```dart
ExpansionTile(
  children: _isExpanded 
    ? path.lessons.map((lesson) => ListTile(...)).toList()
    : const [SizedBox.shrink()],
)
// Or use a custom ExpansionPanelList with explicit expansion state
```

---

### 5. Room Scene - Multiple BackdropFilters
**File:** `lib/widgets/room_scene.dart`  
**Lines:** Multiple locations  
**Severity:** 🟠 HIGH

**Problem:**
```dart
// Each BackdropFilter is GPU-expensive
ClipRRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),  // ❌ GPU rasterization
    child: Container(...),
  ),
)
// Used 4-5 times in the same scene
```

**Impact:** Each `BackdropFilter`:
- Forces GPU rasterization
- Prevents layer caching
- Compounds with each additional filter

**Fix:** 
1. Reduce to 1-2 BackdropFilters max
2. Use solid semi-transparent colors instead where possible
3. Cache the blur effect using `RenderRepaintBoundary`:

```dart
// Option: Replace blur with solid glass effect
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.8),  // Simulates frosted glass
    borderRadius: BorderRadius.circular(20),
  ),
)
```

---

### 6. Skeleton Loader - Animation Runs When Offscreen
**File:** `lib/widgets/skeleton_loader.dart`  
**Line:** ~25  
**Severity:** 🟠 HIGH

**Problem:**
```dart
_controller = AnimationController(...)..repeat();  // ❌ Runs forever
```

**Fix:** Use `VisibilityDetector` or `AutomaticKeepAliveClientMixin`:
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Only animate when visible
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      _controller.repeat();
    }
  });
}

@override
void dispose() {
  _controller.stop();  // Ensure stopped before dispose
  _controller.dispose();
  super.dispose();
}
```

---

### 7. Speed Dial FAB - Repaints on Every Frame
**File:** `lib/widgets/speed_dial_fab.dart`  
**Line:** ~90  
**Severity:** 🟠 HIGH

**Problem:**
```dart
AnimatedBuilder(  // Triggers rebuild every frame during animation
  animation: _expandAnimation,
  builder: (context, child) {
    return Positioned(
      bottom: 8 + (-y * progress),  // ❌ Layout changes every frame
      right: 8 + (-x * progress),
      child: Transform.scale(...),
    );
  },
)
```

**Fix:** Use `Transform` instead of changing Positioned coordinates:
```dart
AnimatedBuilder(
  animation: _expandAnimation,
  builder: (context, child) {
    final progress = _expandAnimation.value;
    return Transform.translate(
      offset: Offset(-x * progress, -y * progress),
      child: Transform.scale(
        scale: progress,
        child: Opacity(opacity: progress, child: child),
      ),
    );
  },
  child: _ActionButton(...),  // ✅ child is cached, not rebuilt
)
```

---

### 8. Home Screen - Heavy Stack Rebuilds
**File:** `lib/screens/home_screen.dart`  
**Severity:** 🟠 HIGH

**Problem:** The entire `LivingRoomScene` rebuilds when `_currentTankIndex` changes, including all complex painters and backdrop filters.

**Fix:** Wrap expensive children in `RepaintBoundary`:
```dart
Stack(
  children: [
    RepaintBoundary(  // Isolate room scene
      child: Positioned.fill(
        child: LivingRoomScene(...),
      ),
    ),
    // ... other widgets
  ],
)
```

---

## 🟡 MEDIUM Priority Issues

### 9. Missing RepaintBoundary on List Items
**Files:** Multiple screens  
**Severity:** 🟡 MEDIUM

**Affected files:**
- `livestock_screen.dart` - `_LivestockCard`
- `logs_screen.dart` - Log cards
- `friends_screen.dart` - Friend cards

**Fix:** Wrap complex list items:
```dart
return RepaintBoundary(
  child: _LivestockCard(...),
);
```

---

### 10. CustomPainter Without Cache
**File:** `lib/widgets/room_scene.dart`  
**Severity:** 🟡 MEDIUM

**Problem:** `_OrganicShapesPainter` repaints on every frame even when unchanged.

**Fix:** Implement proper `shouldRepaint`:
```dart
@override
bool shouldRepaint(covariant _OrganicShapesPainter old) {
  return old.theme != theme;  // ✅ Already implemented correctly
}
```
Note: This is actually implemented correctly - good pattern!

---

### 11. Missing const Constructors
**Files:** Various widgets  
**Severity:** 🟡 MEDIUM

**Examples:**
```dart
// CURRENT
child: Text('Your text here')  // ❌ New instance each build

// FIXED
child: const Text('Your text here')  // ✅ Compile-time constant
```

**Priority areas:**
- `_StatChip` in `species_browser_screen.dart`
- `_MiniChip` in `species_browser_screen.dart`
- `_Chip` in `logs_screen.dart`
- `_Bubble` in `room_scene.dart`

---

### 12. Glossary Screen - Static Data Processing in Build
**File:** `lib/screens/glossary_screen.dart`  
**Line:** ~35  
**Severity:** 🟡 MEDIUM

**Problem:**
```dart
final categories = _allTerms.map((t) => t.category).toSet().toList()..sort();
// ❌ Computed on every build
```

**Fix:** Compute once:
```dart
// At file level (outside class)
final _categories = _allTerms.map((t) => t.category).toSet().toList()..sort();
```

---

### 13. Confetti Overlay - Large Particle Count
**File:** `lib/widgets/confetti_overlay.dart`  
**Line:** ~26  
**Severity:** 🟡 MEDIUM

```dart
final int _particleCount = 50;  // Consider reducing to 30-35
```

---

### 14. Provider Over-Watching
**Files:** Various  
**Severity:** 🟡 MEDIUM

**Pattern found:**
```dart
final profileAsync = ref.watch(userProfileProvider);
// Full profile watched when only needing streak
```

**Fix:** Use `select` for targeted rebuilds:
```dart
final streak = ref.watch(userProfileProvider.select((p) => p?.currentStreak ?? 0));
```

---

## ✅ Good Patterns Found (Keep These!)

| Pattern | File | Notes |
|---------|------|-------|
| ✅ Optimized images | `optimized_image.dart` | Memory-efficient with cache hints |
| ✅ ListView.builder | `species_browser_screen.dart` | Proper lazy loading |
| ✅ ListView.separated | `logs_screen.dart` | Efficient with separators |
| ✅ GridView.builder + RepaintBoundary | `achievements_screen.dart` | Excellent pattern |
| ✅ ListView.builder + RepaintBoundary | `leaderboard_screen.dart` | Good isolation |
| ✅ vsync on AnimationController | All animation widgets | Proper tick syncing |
| ✅ shouldRepaint implementation | `room_scene.dart` painters | Avoids unnecessary repaints |
| ✅ CachedNetworkImage | `optimized_image.dart` | Proper network image caching |

---

## Priority Fix Order

### Week 1 (Critical)
1. [ ] Fix `livestock_screen.dart` - Convert to ListView.builder
2. [ ] Start `withOpacity()` migration - Focus on `room_scene.dart` first
3. [ ] Fix `photo_gallery_screen.dart` - Convert to CustomScrollView + SliverGrid

### Week 2 (High)
4. [ ] Fix SpeedDialFAB animation pattern
5. [ ] Add RepaintBoundary to Home Screen expensive children
6. [ ] Reduce BackdropFilter usage in room_scene

### Week 3 (Medium)
7. [ ] Add RepaintBoundary to all list item widgets
8. [ ] Fix skeleton loader visibility-aware animation
9. [ ] Add const constructors throughout
10. [ ] Implement provider select() patterns

---

## Verification Checklist

After fixes, verify with Flutter DevTools:
- [ ] No rebuild indicator flashing on static widgets
- [ ] Frame render time < 16ms (60fps)
- [ ] No jank during list scrolling
- [ ] Memory stable during long sessions
- [ ] No GPU overdraw warnings

**Run performance profiling:**
```bash
flutter run --profile
# Then use DevTools > Performance tab
```

---

## Code Snippets for Common Fixes

### Fix 1: Replace .map() in ListView
```dart
// Before
ListView(children: items.map((i) => ItemWidget(i)).toList())

// After
ListView.builder(
  itemCount: items.length,
  itemBuilder: (ctx, i) => ItemWidget(items[i]),
)
```

### Fix 2: Pre-compute opacity colors
```dart
// In app_theme.dart, add:
static const Color primaryAlpha10 = Color(0x1A2196F3);
static const Color primaryAlpha20 = Color(0x332196F3);
static const Color primaryAlpha30 = Color(0x4D2196F3);
// etc.
```

### Fix 3: Add RepaintBoundary
```dart
itemBuilder: (ctx, i) => RepaintBoundary(
  child: MyComplexListItem(data: items[i]),
)
```

---

*Report generated by Performance & Smoothness Agent*  
*Next review recommended after Week 2 fixes*
