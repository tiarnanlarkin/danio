# Lazy Loading - Validation Checklist

Quick checklist to verify Phase 1.3 implementation works correctly.

---

## ⚡ Quick Validation (5 minutes)

### 1. Build Check ✅
```bash
cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"
flutter analyze lib/providers/lesson_provider.dart
flutter analyze lib/widgets/lesson_skeleton.dart
flutter analyze lib/data/lessons/*.dart
```
**Expected:** "No issues found!"

### 2. Test Suite
```bash
flutter test test/lazy_loading_test.dart
```
**Expected:** All tests pass

### 3. App Compiles
```bash
flutter build apk --debug
```
**Expected:** Build succeeds with no errors

---

## 🔬 Functional Testing (15 minutes)

### Test 1: App Starts Without Errors
- [ ] Run app: `flutter run`
- [ ] App loads successfully
- [ ] No console errors related to lesson loading
- [ ] Navigate to Learn screen (study room)
- [ ] Learning paths visible and clickable

### Test 2: Legacy Code Still Works
- [ ] Open any lesson (should work as before)
- [ ] Complete a lesson (XP awarded correctly)
- [ ] View analytics screen (lesson stats display)
- [ ] Check placement test (still functional)

**Why:** Backward compatibility ensures nothing breaks.

### Test 3: Memory Usage
- [ ] Open app in profile mode: `flutter run --profile`
- [ ] Open DevTools Memory tab
- [ ] Note baseline memory usage
- [ ] Navigate through 2-3 learning paths
- [ ] Memory should stay reasonable (<200MB)

---

## 📊 Performance Testing (Optional - 30 minutes)

### Startup Time Comparison

**Before (with old system):**
1. Temporarily restore old lesson_content.dart usage
2. Run: `flutter run --profile`
3. Measure time to first paint
4. Record memory at startup

**After (with lazy loading):**
1. Migrate one screen to use lazy loading
2. Run: `flutter run --profile`
3. Measure time to first paint
4. Compare memory usage

**Expected improvements:**
- Startup: ~50-100ms faster
- Memory: ~200-300MB lower baseline

### Web Bundle Analysis

**For web builds:**
```bash
flutter build web --profile
```

Check build output for separate chunk files:
- Should see multiple `.dart.js` files
- Each deferred library creates a separate chunk

---

## 🎯 Migration Validation (Per Screen)

When migrating a screen to lazy loading:

### Pre-Migration:
- [ ] Screen works correctly with old system
- [ ] Note any performance issues
- [ ] Capture baseline metrics

### Post-Migration:
- [ ] Screen displays correctly
- [ ] Loading skeletons appear during load
- [ ] Content appears after loading
- [ ] No console errors
- [ ] Error states work (test by simulating failures)
- [ ] Navigation smooth
- [ ] Performance improved or same

### Test Cases Per Screen:
- [ ] Fresh app start (cold load)
- [ ] Navigate away and back (warm load)
- [ ] Slow network simulation (web)
- [ ] Error simulation (invalid path ID)
- [ ] Memory profiling (no leaks)

---

## 🐛 Common Issues & Solutions

### Issue: "Lesson not found"
**Symptom:** Lesson doesn't load, shows error  
**Cause:** Lesson ID doesn't exist in metadata  
**Fix:** Check `LessonProvider.allPathMetadata` for correct IDs

### Issue: "Path loads on every rebuild"
**Symptom:** Skeleton flashes repeatedly  
**Cause:** `loadPath()` called without checking `isPathLoaded()`  
**Fix:** Wrap in `Future.microtask()` and add load check

### Issue: "Deferred import errors"
**Symptom:** Build fails with import errors  
**Cause:** Circular dependencies or incorrect import syntax  
**Fix:** Ensure deferred imports are top-level and no circular refs

### Issue: "Memory usage still high"
**Symptom:** Memory doesn't decrease after implementing lazy loading  
**Cause:** All paths loaded and never cleared  
**Fix:** Call `clearPath()` for unused paths or implement LRU cache

---

## ✅ Sign-Off Criteria

Before considering Phase 1.3 complete in production:

- [ ] All tests pass
- [ ] App builds successfully (debug and release)
- [ ] No new console errors or warnings
- [ ] Backward compatibility verified (old code still works)
- [ ] At least 1 screen migrated and tested
- [ ] Performance improvements measured and documented
- [ ] Code committed to git with clear commit message

---

## 📝 Validation Log

Use this section to track your testing:

```
Date: _____________
Tester: _____________

✅ Build Check: PASS / FAIL
✅ Test Suite: PASS / FAIL
✅ App Compilation: PASS / FAIL
✅ Functional Tests: PASS / FAIL
✅ Legacy Compatibility: PASS / FAIL
✅ Performance Testing: PASS / FAIL

Notes:
_________________________________
_________________________________
_________________________________

Issues Found:
_________________________________
_________________________________
_________________________________

Sign-off: _____________ Date: _____________
```

---

## 🚀 Ready for Production?

All boxes checked above? Then you're ready to:
1. Commit changes
2. Deploy to test environment
3. Begin gradual screen migration
4. Monitor performance metrics
5. Celebrate! 🎉

---

**Need help?** See migration guide in `docs/guides/lazy-loading-migration-guide.md`
