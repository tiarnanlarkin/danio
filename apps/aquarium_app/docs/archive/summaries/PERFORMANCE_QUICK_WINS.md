# Performance Quick Wins - Action Plan

**Total Time:** 45 minutes  
**Impact:** Production-ready bundle + accessibility compliance

---

## 1. Remove Mockup Assets (5 min) ⚡

**Impact:** -4.2 MB bundle size

```bash
cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"

# Create design folder for references
mkdir -p design/references

# Move mockup images out of assets
mv assets/images/room_scene_reference.png design/references/
mv assets/images/ui_mockup_1.png design/references/
mv assets/images/ui_mockup_abstract.png design/references/

# Remove empty assets folder
rm -rf assets/images

# Update pubspec.yaml
# Comment out the assets section (since no runtime assets exist)
```

**Expected Result:**
- Bundle size: 170 MB → ~10-15 MB (release)
- Faster installation
- Cleaner production build

---

## 2. Build Release APK (10 min) ⚡

**Impact:** Verify actual production size

```bash
cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"

# Build release APK with size analysis
/home/tiarnanlarkin/flutter/bin/flutter build apk --release --analyze-size

# Also build split APKs (one per architecture)
/home/tiarnanlarkin/flutter/bin/flutter build apk --release --split-per-abi

# Check sizes
ls -lh build/app/outputs/flutter-apk/
```

**Expected Output:**
```
app-armeabi-v7a-release.apk   ~10-12 MB
app-arm64-v8a-release.apk     ~12-15 MB
app-x86_64-release.apk        ~12-15 MB
```

**Success Criteria:** ✅ Each APK < 25 MB

---

## 3. Add Missing Tooltips (30 min) ⚡

**Impact:** Accessibility compliance (57% → 90%+)

**Files to update:** 13 IconButtons across these files:
- lib/screens/home_screen.dart
- lib/screens/settings_screen.dart
- lib/screens/tank_detail_screen.dart
- lib/screens/livestock_screen.dart

**Pattern to apply:**
```dart
// Before
IconButton(
  icon: Icon(Icons.add),
  onPressed: () => _addItem(),
)

// After
IconButton(
  icon: Icon(Icons.add),
  tooltip: 'Add new item',  // ← Add this
  onPressed: () => _addItem(),
)
```

**Tooltip suggestions by icon:**
- `Icons.add` → "Add new tank" / "Add livestock" (context-specific)
- `Icons.edit` → "Edit"
- `Icons.delete` → "Delete"
- `Icons.search` → "Search"
- `Icons.settings` → "Settings"
- `Icons.info_outline` → "Information"
- `Icons.filter_list` → "Filter"
- `Icons.more_vert` → "More options"

**How to find them:**
```bash
# Find IconButtons without tooltips
grep -rn "IconButton" lib/ --include="*.dart" | grep -v "tooltip:"
```

**Testing:**
After adding tooltips, enable TalkBack (Android Settings → Accessibility) and verify all buttons announce their purpose.

---

## Verification Checklist

After completing these 3 quick wins:

- [ ] Assets folder moved to design/ (no longer in bundle)
- [ ] Release APK built successfully
- [ ] Release APK size < 25 MB per architecture ✅
- [ ] All 30 IconButtons have tooltip parameters
- [ ] TalkBack test: all buttons announce correctly
- [ ] pubspec.yaml assets section commented out (if empty)

---

## Expected Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Bundle size | 170 MB (debug) | 10-15 MB (release) | 📉 91% reduction |
| Assets | 4.2 MB | 0 MB | 📉 100% cleanup |
| Accessibility | 57% coverage | 90%+ coverage | 📈 +33% |
| Time invested | - | 45 minutes | ⏱️ Minimal |

---

## Next Steps (After Quick Wins)

Once these are complete, proceed to:

1. **Performance measurement** (see PERFORMANCE_REPORT.md §5)
   - Cold start time profiling
   - Memory leak check
   - Frame rate analysis

2. **Accessibility testing** (see PERFORMANCE_REPORT.md §4)
   - TalkBack full navigation
   - Large Text scale test
   - Color contrast verification

3. **Long-term optimizations** (see PERFORMANCE_REPORT.md §6)
   - Implement persistent storage (Hive)
   - Performance monitoring setup
   - Code modularization

---

**Ready to ship?** After completing these quick wins and verifying the checklist, the app will be production-ready! 🚀
