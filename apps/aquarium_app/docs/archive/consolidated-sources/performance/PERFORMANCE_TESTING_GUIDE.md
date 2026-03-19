# Performance Testing Guide

## Quick Performance Check

### 1. Build and Run in Profile Mode
```bash
# Build debug APK with profile mode
/home/tiarnanlarkin/flutter/bin/flutter build apk --profile

# Or run directly on device/emulator
/home/tiarnanlarkin/flutter/bin/flutter run --profile
```

### 2. Install on Device
```bash
# Install APK (Windows path)
"C:\Users\larki\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r "build\app\outputs\flutter-apk\app-profile.apk"

# From WSL
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" install -r "build/app/outputs/flutter-apk/app-profile.apk"
```

### 3. Launch and Monitor
```bash
# Open DevTools
/home/tiarnanlarkin/flutter/bin/flutter pub global run devtools

# In another terminal, connect
/home/tiarnanlarkin/flutter/bin/flutter run --profile
```

## Performance Tests to Run

### Test 1: Leaderboard Scrolling (60 FPS Target)
1. Navigate to Leaderboard screen
2. Scroll rapidly up and down
3. **Expected**: Smooth 60 FPS, no dropped frames
4. **Check DevTools**: Performance tab should show green (no red frames >16ms)

### Test 2: Achievements Grid Scrolling
1. Navigate to Achievements screen  
2. Apply different filters (adds/removes items)
3. Scroll through grid rapidly
4. **Expected**: Smooth 60 FPS, no jank during filter changes

### Test 3: Tank Detail Screen
1. Navigate to Tank Detail
2. Scroll through all sections
3. Switch between tabs if present
4. **Expected**: No lag when sections come into view

### Test 4: Memory Usage (<100 MB Target)
1. Open DevTools Memory tab
2. Navigate through all major screens:
   - Home → Tank Detail → Leaderboard → Achievements → Home
3. Perform GC (garbage collection) in DevTools
4. **Expected**: Memory stabilizes <100 MB after GC
5. **Check**: No memory leaks (memory should drop after GC)

### Test 5: Rapid Navigation
1. Rapidly switch between screens using bottom nav
2. **Expected**: No frame drops during transitions
3. **Expected**: Each screen renders in <500ms

## Using DevTools

### Performance Tab
- **Green bars**: Good frames (<16ms)
- **Red bars**: Jank (>16ms)
- **Goal**: No red bars during scrolling

### Memory Tab
- **Snapshot**: Take before/after navigation
- **Compare**: Memory should be released after leaving screen
- **Look for**: Steady growth = memory leak

### Frame Rendering
- **Build time**: Time to build widget tree (should be <8ms)
- **Raster time**: Time to paint to screen (should be <8ms)
- **Total**: Build + Raster should be <16ms for 60 FPS

## Performance Metrics to Record

### Frame Rate (FPS)
- [ ] Home screen: _____ FPS (target: 60)
- [ ] Leaderboard scroll: _____ FPS (target: 60)
- [ ] Achievements grid: _____ FPS (target: 60)
- [ ] Tank detail: _____ FPS (target: 60)

### Memory Usage (MB)
- [ ] App start: _____ MB
- [ ] After navigation loop: _____ MB (target: <100)
- [ ] Peak usage: _____ MB (target: <150)

### Load Times (ms)
- [ ] Home screen initial: _____ ms (target: <500)
- [ ] Tank detail open: _____ ms (target: <500)
- [ ] Leaderboard render: _____ ms (target: <300)

## Common Performance Issues

### Issue: Jank during scrolling
**Cause**: Expensive widgets rebuilding on every frame
**Solution**: Add RepaintBoundary (already done ✅)

### Issue: High memory usage
**Cause**: Full-resolution images in memory
**Solution**: Use OptimizedNetworkImage/OptimizedAssetImage (infrastructure ready ✅)

### Issue: Slow screen transitions
**Cause**: Heavy build methods, multiple provider watches
**Solution**: Use Consumer for isolated rebuilds

### Issue: Stuttering animations
**Cause**: Synchronous work on UI thread
**Solution**: Move heavy work to isolates or use compute()

## Quick Optimization Checklist

- [x] RepaintBoundary on list/grid items
- [x] ListView.builder / GridView.builder (lazy loading)
- [x] Image optimization infrastructure
- [ ] Const constructors where possible
- [ ] Consumer widgets for isolated rebuilds
- [ ] provider.select for granular subscriptions
- [ ] Profile mode testing completed
- [ ] Memory profiling completed
- [ ] 60 FPS verified on all screens

## Automated Performance Tests

Create integration tests to catch regressions:

```dart
// test/performance_test.dart
testWidgets('Leaderboard scrolls at 60 FPS', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.text('Leaderboard'));
  await tester.pumpAndSettle();
  
  await tester.fling(
    find.byType(ListView),
    Offset(0, -500),
    5000,
  );
  
  // Check frame metrics
  // expect(frameTimings, everyElement(lessThan(16.67)));
});
```

## Results Template

```markdown
## Performance Test Results - [Date]

### Device: [Android/iOS] [Version]

### Frame Rate
- Home: 60 FPS ✅
- Leaderboard: 58 FPS ⚠️ (2 red frames during fast scroll)
- Achievements: 60 FPS ✅
- Tank Detail: 60 FPS ✅

### Memory Usage
- Start: 68 MB ✅
- After navigation: 82 MB ✅
- Peak: 95 MB ✅

### Issues Found
1. Leaderboard has 2 jank frames during very fast scrolling
   - Root cause: Theme.of(context) called in tight loop
   - Fix: Cache theme colors

### Next Steps
- [ ] Fix leaderboard jank
- [ ] Verify on lower-end device
- [ ] Add automated performance tests
```

## Lower-End Device Testing

**Important**: Test on a budget device to catch performance issues:
- Minimum: Android 8.0, 2GB RAM
- Test all scrolling screens
- Verify smooth performance

## CI/CD Integration

Add performance benchmarks to CI:
```yaml
# .github/workflows/performance.yml
- name: Run performance tests
  run: flutter drive --profile --target=test_driver/perf_test.dart
```
