# Performance Optimization Checklist

**Track your progress through the optimization sprint!**

---

## 📋 Phase 1: Audit & Setup (COMPLETE ✅)

- [x] Analyze codebase (133 files)
- [x] Identify critical issues
- [x] Create performance audit document
- [x] Create optimization roadmap
- [x] Create benchmarking framework
- [x] Build optimization tools
- [x] Document current state

**Status:** ✅ Complete (9 hours)

---

## 🚀 Phase 2: Quick Wins (Week 1)

### Image Optimization (2-3 hours)

- [x] Create ImageCacheService
- [x] Create CachedImage widget
- [ ] Update `add_log_screen.dart` to use CachedImage
- [ ] Update `photo_gallery_screen.dart` to use CachedImage
- [x] Update `log_detail_screen.dart` to use CachedImage
- [ ] Test photo loading performance
- [ ] Measure memory before/after

**Files to modify:** 2 remaining  
**Current:** 1/3 complete (33%)

---

### Const Constructors - Widgets (4-6 hours)

High-priority files (rebuild frequently):

- [ ] `lib/widgets/tank_card.dart`
- [ ] `lib/widgets/daily_goal_progress.dart`
- [ ] `lib/widgets/streak_display.dart`
- [ ] `lib/widgets/streak_calendar.dart`
- [ ] `lib/widgets/cycling_status_card.dart`
- [ ] `lib/widgets/exercise_widgets.dart`
- [ ] `lib/widgets/hobby_items.dart`
- [ ] `lib/widgets/decorative_elements.dart`
- [ ] `lib/widgets/room_scene.dart`
- [ ] `lib/widgets/study_room_scene.dart`

**Files to modify:** 10  
**Current:** 0/10 complete (0%)

---

### Const Constructors - High-Traffic Screens (6-8 hours)

- [x] `lib/screens/about_screen.dart` ✅
- [ ] `lib/screens/home_screen.dart`
- [ ] `lib/screens/tank_detail_screen.dart`
- [ ] `lib/screens/livestock_screen.dart`
- [ ] `lib/screens/equipment_screen.dart`
- [ ] `lib/screens/logs_screen.dart`
- [ ] `lib/screens/tasks_screen.dart`
- [ ] `lib/screens/settings_screen.dart`
- [ ] `lib/screens/learn_screen.dart`
- [ ] `lib/screens/practice_screen.dart`

**Files to modify:** 9 remaining  
**Current:** 1/10 complete (10%)

---

### Provider Optimization (3-4 hours)

- [ ] Refactor TankDetailScreen provider watching
- [ ] Remove duplicate `allLogsProvider` watch
- [ ] Split TankDetailScreen into sections:
  - [ ] LivestockSection
  - [ ] EquipmentSection
  - [ ] TasksSection
  - [ ] RecentActivitySection
- [ ] Test rebuild performance
- [ ] Measure rebuild count before/after

**Files to modify:** 1 major refactor  
**Current:** 0/1 complete (0%)

---

### Establish Baseline (1-2 hours)

- [ ] Build release APK
- [ ] Measure APK size
- [ ] Measure cold start time (3 runs, average)
- [ ] Measure warm start time (3 runs, average)
- [ ] Profile memory usage (DevTools)
- [ ] Count widget rebuilds (add counters)
- [ ] Document baseline in PERFORMANCE_BENCHMARKS.md

**Measurements needed:** 6  
**Current:** 0/6 complete (0%)

---

## 🎯 Phase 3: High-Impact Items (Week 2)

### Provider Selectors (4-6 hours)

Screens to optimize:

- [ ] `home_screen.dart` - Tank name display
- [ ] `livestock_screen.dart` - Individual livestock cards
- [ ] `equipment_screen.dart` - Equipment list items
- [ ] `logs_screen.dart` - Log entry cards
- [ ] `tasks_screen.dart` - Task items
- [ ] Other high-traffic screens

**Pattern:**
```dart
// Before: rebuilds on any tank change
final tank = ref.watch(tankProvider(id)).value;
final name = tank?.name;

// After: only rebuilds when name changes
final name = ref.watch(
  tankProvider(id).select((tank) => tank.value?.name)
);
```

**Files to modify:** 6+  
**Current:** 0/6 complete (0%)

---

### Lazy Loading Data Files (4-6 hours)

- [ ] Convert species_database to JSON asset
  - [ ] Create `assets/data/species.json`
  - [ ] Update species_database.dart to load from JSON
  - [ ] Implement caching
- [ ] Split lesson_content by category
  - [ ] Create individual lesson files
  - [ ] Update lesson loading logic
- [ ] Lazy load shop_catalog
  - [ ] Load only when shop accessed
  - [ ] Implement caching
- [ ] Test startup time improvement
- [ ] Measure memory reduction

**Data files to convert:** 3  
**Current:** 0/3 complete (0%)

---

### Pagination (6-8 hours)

Lists to paginate:

- [ ] Log history (`logs_screen.dart`)
  - [ ] Implement offset/limit in provider
  - [ ] Add infinite scroll widget
  - [ ] Test with 100+ logs
- [ ] Species browser (`species_browser_screen.dart`)
  - [ ] Paginate by 25 items
  - [ ] Add load more button
- [ ] Plant browser (`plant_browser_screen.dart`)
  - [ ] Paginate by 25 items
- [ ] Leaderboard (if large dataset)
- [ ] Test memory with large datasets

**Lists to paginate:** 4  
**Current:** 0/4 complete (0%)

---

## 💪 Phase 4: Medium Priority (Week 3-4)

### Const Constructors - Remaining Screens (6-8 hours)

All guide/info screens:

- [ ] Guide screens (20+ files)
- [ ] Calculator screens (5+ files)
- [ ] Browser screens (3+ files)
- [ ] Comparison screens (2+ files)
- [ ] Other utility screens (10+ files)

**Files to modify:** 40+  
**Current:** 0/40 complete (0%)

---

### APK Size Reduction (4-6 hours)

- [ ] Run APK size analysis
  ```bash
  flutter build apk --analyze-size
  ```
- [ ] Review dependency usage:
  - [ ] Can fl_chart be replaced?
  - [ ] Lazy load archive package
  - [ ] Review image_picker usage
  - [ ] Review file_picker usage
- [ ] Remove unused dependencies
- [ ] Test feature completeness
- [ ] Build and measure new APK size

**Dependencies to review:** 4  
**Current:** 0/4 complete (0%)

---

### setState Optimization (6-8 hours)

- [ ] Audit all 204 setState calls
- [ ] Identify excessive rebuilds
- [ ] Batch multiple setState calls
- [ ] Replace with Riverpod where appropriate
- [ ] Minimize setState rebuild scopes
- [ ] Test affected screens

**setState calls to review:** 204  
**Current:** 0/204 complete (0%)

---

### Performance Monitoring (2-3 hours)

- [ ] Add startup time tracking
- [ ] Add screen load tracking
- [ ] Add rebuild counters (debug mode)
- [ ] Add memory monitoring
- [ ] Create performance dashboard
- [ ] Test monitoring overhead

**Monitoring points:** 4  
**Current:** 0/4 complete (0%)

---

## 📊 Phase 5: Testing & Validation

### Performance Testing (3-4 hours)

- [ ] Test on high-end device (Pixel 7, Galaxy S22)
- [ ] Test on mid-range device (Pixel 6a, Galaxy A53)
- [ ] Test on low-end device (Galaxy A13 or similar)
- [ ] Measure all benchmarks on each device
- [ ] Document results

**Devices tested:** 0/3

---

### Regression Testing (2-3 hours)

Feature verification:

- [ ] All screens load correctly
- [ ] Navigation works
- [ ] Tank CRUD operations work
- [ ] Livestock management works
- [ ] Equipment management works
- [ ] Logging works
- [ ] Tasks work
- [ ] Photo upload/display works
- [ ] Backup/restore works
- [ ] Settings persist
- [ ] Notifications work

**Features verified:** 0/11

---

### Final Benchmarks (2-3 hours)

- [ ] Build final release APK
- [ ] Measure final APK size
- [ ] Measure final startup times
- [ ] Profile final memory usage
- [ ] Count final rebuild metrics
- [ ] Compare against baseline
- [ ] Calculate improvement percentages
- [ ] Update PERFORMANCE_BENCHMARKS.md

**Final measurements:** 0/6

---

## 🎉 Phase 6: Documentation & Celebration

### Update Documentation (1-2 hours)

- [ ] Update PERFORMANCE_BENCHMARKS.md with results
- [ ] Update OPTIMIZATION_SUMMARY.md with final stats
- [ ] Update PERFORMANCE_README.md with lessons learned
- [ ] Create before/after comparison graphics
- [ ] Write blog post / team update

**Documents to update:** 0/3

---

### Share Results (1 hour)

- [ ] Present to team
- [ ] Share on social media (if applicable)
- [ ] Update app store description with performance improvements
- [ ] Celebrate with team! 🎊

---

## 📈 Progress Summary

### Overall Progress

**Phase 1 (Audit):** ✅ Complete (100%)  
**Phase 2 (Quick Wins):** 🔄 In Progress (15%)  
**Phase 3 (High Impact):** ⏳ Pending (0%)  
**Phase 4 (Medium Priority):** ⏳ Pending (0%)  
**Phase 5 (Testing):** ⏳ Pending (0%)  
**Phase 6 (Documentation):** ⏳ Pending (0%)

### Time Tracking

**Completed:** 9 hours  
**Estimated Remaining:** 50-60 hours  
**Total Project:** 59-69 hours

### Key Metrics

| Metric | Baseline | Current | Target | Progress |
|--------|----------|---------|--------|----------|
| APK Size | 149MB | 149MB | <50MB | 0% |
| Const Constructors | 0/133 | 2/133 | 133/133 | 2% |
| Images Optimized | 0/3 | 1/3 | 3/3 | 33% |
| Providers Optimized | 0/10 | 0/10 | 10/10 | 0% |
| Cold Start | ~4s | ~4s | <2s | 0% |
| Memory Usage | ~180MB | ~180MB | <90MB | 0% |

---

## 🎯 This Week's Focus

**Priority 1:** Const constructors on widgets (biggest bang for buck)  
**Priority 2:** Image optimization rollout (already built, just deploy)  
**Priority 3:** TankDetailScreen provider refactor (60-80% rebuild reduction)

**Goal:** 30% improvement by end of week 1

---

## 💡 Tips for Success

- ✅ Check off items as you complete them
- ✅ Test after each major change
- ✅ Commit frequently with clear messages
- ✅ Measure before/after for each optimization
- ✅ Don't skip the baseline measurements!
- ✅ Celebrate small wins along the way

---

*Update this checklist as you progress. It's your roadmap to a faster, smoother app!*

---

**Last Updated:** February 7, 2025  
**Next Review:** After Phase 2 completion
