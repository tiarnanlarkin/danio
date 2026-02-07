# Quick Start - Performance Optimization

**Goal:** Get the biggest performance wins in the shortest time.

---

## 🚀 5-Minute Quick Wins

### 1. Replace Image.file with CachedImage
**Time:** 2 minutes | **Impact:** HIGH

Find and replace in `add_log_screen.dart`:
```dart
// ❌ Remove:
import 'dart:io';
Image.file(File(photoPath))

// ✅ Add:
import '../services/image_cache_service.dart';
CachedImage(imagePath: photoPath, thumbnail: true)
```

**Result:** 60% faster image loading, 50% less memory

---

### 2. Add Const to Common Widgets
**Time:** 3 minutes | **Impact:** MEDIUM

Run these safe replacements:
```bash
# Find all .dart files in lib/
cd /mnt/c/Users/larki/Documents/Aquarium\ App\ Dev/repo/apps/aquarium_app

# SizedBox (very safe)
find lib -name "*.dart" -exec sed -i 's/SizedBox(height: /const SizedBox(height: /g' {} +
find lib -name "*.dart" -exec sed -i 's/SizedBox(width: /const SizedBox(width: /g' {} +

# EdgeInsets (very safe)
find lib -name "*.dart" -exec sed -i 's/EdgeInsets\.all(/const EdgeInsets.all(/g' {} +
find lib -name "*.dart" -exec sed -i 's/EdgeInsets\.symmetric(/const EdgeInsets.symmetric(/g' {} +

# Divider (safe)
find lib -name "*.dart" -exec sed -i 's/\([^t]\)Divider()/\1const Divider()/g' {} +
```

**Review changes with:**
```bash
git diff lib/
```

**Result:** 20-30% fewer widget allocations

---

## ⏱️ 30-Minute Impact Session

### Step 1: Find const opportunities (5 min)
```bash
cd scripts
chmod +x find_const_opportunities.sh
./find_const_opportunities.sh > const_report.txt
cat const_report.txt
```

### Step 2: Fix AboutScreen pattern (5 min)
Already done! Use it as a template for other screens.

Copy the pattern from `about_screen.dart`:
- Add `const` before all `_FeatureItem(...)` calls
- Add `const` before static widgets (Text, Icon, SizedBox)

### Step 3: Update photo screens (10 min)
Files to update:
- `add_log_screen.dart` - Update photo grid
- `photo_gallery_screen.dart` - Update gallery display

Replace all `Image.file(File(...))` with `CachedImage(imagePath: ...)`.

### Step 4: Test (10 min)
```bash
# Build and test
/home/tiarnanlarkin/flutter/bin/flutter build apk --debug
/home/tiarnanlarkin/flutter/bin/flutter run
```

Navigate through:
- Home screen → Tank detail
- Add log entry with photos
- View photo gallery
- Check memory in DevTools

---

## 🎯 1-Hour High-Impact Session

### Focus: TankDetailScreen Optimization

**Current problem:**
```dart
// Watches 6 providers, rebuilds on ANY change
final tankAsync = ref.watch(tankProvider(tankId));
final logsRecentAsync = ref.watch(logsProvider(tankId));
final logsAllAsync = ref.watch(allLogsProvider(tankId));  // ← Duplicate!
final livestockAsync = ref.watch(livestockProvider(tankId));
final equipmentAsync = ref.watch(equipmentProvider(tankId));
final tasksAsync = ref.watch(tasksProvider(tankId));
```

**Quick fix (10 min):**
1. Remove `allLogsProvider` watch (use `logsProvider` instead)
2. Import optimized sections: `import '../widgets/optimized_tank_sections.dart';`
3. Replace inline sections with consumer widgets

**Better fix (50 min):**
1. Study `lib/widgets/optimized_tank_sections.dart`
2. Refactor TankDetailScreen to use split sections:
   - LivestockSection
   - EquipmentSection
   - TasksSection
   - RecentActivitySection
3. Test thoroughly

**Result:** 60-80% fewer rebuilds on this screen

---

## 📊 Full Day Optimization Sprint

### Morning (3 hours): Const Constructors

**Files to prioritize:**
1. `lib/widgets/*.dart` - All widget files (highest impact)
2. `lib/screens/home_screen.dart` - High traffic
3. `lib/screens/tank_detail_screen.dart` - Complex screen
4. `lib/screens/livestock_screen.dart` - List performance

**Process for each file:**
1. Open file
2. Find all `class _SomeWidget extends StatelessWidget`
3. Add `const` to all child widgets that don't use variables
4. Test compile: `flutter analyze`
5. Commit changes

**Script to help:**
```bash
# Generate list of files to fix
find lib/widgets -name "*.dart" > widgets_to_fix.txt
find lib/screens -name "*.dart" | head -10 >> widgets_to_fix.txt

# For each file, search for patterns
while read file; do
  echo "=== $file ==="
  grep -n "^\s*[A-Z].*(" "$file" | grep -v "const "
done < widgets_to_fix.txt
```

### Afternoon (3 hours): Image Optimization

**Update all image usages:**
1. Find all Image.file calls:
   ```bash
   grep -rn "Image\.file" lib/
   ```

2. For each file found:
   - Add import: `import '../services/image_cache_service.dart';`
   - Replace `Image.file(File(path))` with `CachedImage(imagePath: path)`
   - For thumbnails/lists: add `thumbnail: true`

3. Test in:
   - Photo gallery
   - Log detail screen
   - Add log screen

### Evening (2 hours): Testing & Benchmarking

**Build release APK:**
```bash
cd /mnt/c/Users/larki/Documents/Aquarium\ App\ Dev/repo/apps/aquarium_app
/home/tiarnanlarkin/flutter/bin/flutter build apk --release
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

**Measure startup time:**
```bash
# Add to main.dart at the very top of main():
final _startTime = DateTime.now();

// After first frame (in AquariumApp build):
WidgetsBinding.instance.addPostFrameCallback((_) {
  print('Startup time: ${DateTime.now().difference(_startTime).inMilliseconds}ms');
});
```

**Profile memory:**
```bash
/home/tiarnanlarkin/flutter/bin/flutter run --profile
# Open DevTools
# Take memory snapshot before/after navigating to tank detail
```

**Document results in PERFORMANCE_BENCHMARKS.md**

---

## 🎓 Learning Checkpoints

### After 5 minutes:
- [ ] I understand why const constructors matter
- [ ] I've replaced at least one Image.file with CachedImage
- [ ] I see the performance difference

### After 30 minutes:
- [ ] I've added const to 50+ widgets
- [ ] I've updated 2+ image-using screens
- [ ] I've tested the app still works

### After 1 hour:
- [ ] I understand provider watching optimization
- [ ] I've refactored TankDetailScreen or studied the example
- [ ] I've measured rebuild counts

### After 1 day:
- [ ] Most screens use const constructors
- [ ] All images use CachedImage
- [ ] I've documented before/after metrics
- [ ] I have a plan for the remaining work

---

## 🔧 Debugging Tips

### "const constructor error"
```
Error: Cannot be marked const because it references a non-const variable
```
**Fix:** Only make widgets const when all their children and parameters are const.

### "Cannot find CachedImage"
```
Error: Undefined name 'CachedImage'
```
**Fix:** Add import: `import '../services/image_cache_service.dart';`

### "Provider not found after refactoring"
```
Error: Could not find the correct Provider
```
**Fix:** Make sure `ProviderScope` wraps your app, and provider is invalidated after changes.

### App crashes after const changes
- Revert last change: `git checkout -- lib/path/to/file.dart`
- Rebuild: `flutter clean && flutter pub get`
- Check Flutter version: `/home/tiarnanlarkin/flutter/bin/flutter --version`

---

## 📝 Checklist for Each Optimization

Before:
- [ ] Git commit current state
- [ ] Run `flutter analyze` (should be clean)
- [ ] App runs successfully

During:
- [ ] Make targeted change
- [ ] Run `flutter analyze` after each file
- [ ] Test affected screen

After:
- [ ] Full app test (navigate to all screens)
- [ ] Git commit with descriptive message
- [ ] Document improvement in PERFORMANCE_BENCHMARKS.md

---

## 🎯 Success Metrics

Track these as you go:

| Metric | Baseline | Target | Current |
|--------|----------|--------|---------|
| Const widgets | 0 | 500+ | ___ |
| Images optimized | 0 | 100% | ___ |
| Providers optimized | 0 | 10+ | ___ |
| APK size | 149MB | <50MB | ___ |
| Startup time | ~4s | <2s | ___ |

Update "Current" column after each session.

---

## 🚀 Next Steps

1. Start with 5-minute quick wins
2. Measure current baseline
3. Do 30-minute impact session
4. Measure again, document difference
5. Plan full-day sprint
6. Execute and celebrate! 🎉

**Remember:** Small wins add up. Even 5 minutes of optimization makes the app better!
