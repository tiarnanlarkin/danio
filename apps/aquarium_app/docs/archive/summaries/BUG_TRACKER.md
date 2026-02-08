# 🎯 BUG TRACKER - Aquarium App

Quick reference checklist for tracking bug fixes

---

## 🔴 P0: CRITICAL (Fix Immediately)

- [ ] **P0-1** Race condition in storage - Data corruption risk
  - File: `local_json_storage_service.dart`
  - Fix: Add `synchronized` lock to `_persist()`
  - Time: 1 hour

- [ ] **P0-2** Silent JSON parse failures
  - File: `local_json_storage_service.dart:56-80`
  - Fix: Add error dialog + backup corrupted files
  - Time: 1 hour

- [ ] **P0-3** Monthly task date crash (month-end)
  - File: `task.dart:73-89`
  - Fix: Clamp day to valid range for month
  - Time: 30 minutes

- [ ] **P0-4** User streak calculation bug
  - File: `user_profile_provider.dart:91-103`
  - Fix: Handle "same day" case correctly
  - Time: 30 minutes

- [ ] **P0-5** Storage provider uses in-memory (NO PERSISTENCE)
  - File: `storage_provider.dart`
  - Fix: Change to `LocalJsonStorageService()`
  - Time: 5 minutes ⚡

---

## 🟠 P1: HIGH (Fix This Week)

- [ ] **P1-1** Notification timezone issues
  - File: `notification_service.dart:61-86`
  - Fix: Update timezone on app resume
  - Time: 1 hour

- [ ] **P1-2** No input validation - negative/invalid values
  - File: `add_log_screen.dart:216-289`
  - Fix: Add min/max bounds to `_ParameterField`
  - Time: 1 hour

- [ ] **P1-3** Tank volume accepts zero/negative
  - File: `create_tank_screen.dart:121-127`
  - Fix: Add validator to volume field
  - Time: 15 minutes

- [ ] **P1-4** (Actually validated - marked as OK ✅)

- [ ] **P1-5** Photo picker - no disk full handling
  - File: `add_log_screen.dart:473-510`
  - Fix: Wrap copy in try-catch
  - Time: 30 minutes

- [ ] **P1-6** (Validated in code ✅)

- [ ] **P1-7** Import doesn't handle related data (MAJOR)
  - File: `backup_restore_screen.dart` + `tank_provider.dart`
  - Fix: Implement ID remapping for livestock/equipment
  - Time: 4 hours

- [ ] **P1-8** Settings race condition on load
  - File: `settings_provider.dart:38-50`
  - Fix: Wait for load before allowing changes
  - Time: 1 hour

- [ ] **P1-9** Navigation back before provider refresh
  - File: `add_log_screen.dart` (multiple screens)
  - Fix: Await provider rebuild before Navigator.pop
  - Time: 30 minutes

- [ ] **P1-10** TextFormField memory leaks
  - File: Multiple screens
  - Fix: Migrate to explicit controllers
  - Time: 4 hours (large refactor)

- [ ] **P1-11** Onboarding infinite loading on error
  - File: `main.dart:47-61`
  - Fix: Wrap in try-catch, default to main app
  - Time: 15 minutes

---

## 🟡 P2: MEDIUM (Next Sprint)

- [ ] **P2-1** Photo grid performance issues
  - File: `add_log_screen.dart:663-693`
  - Fix: Add cacheWidth/cacheHeight to Image.file
  - Time: 15 minutes

- [ ] **P2-2** No character limit on text fields
  - File: `add_log_screen.dart:232-238`
  - Fix: Add maxLength: 2000
  - Time: 15 minutes

- [ ] **P2-3** Tank name special characters
  - File: `create_tank_screen.dart`
  - Fix: Sanitize input (remove newlines, limit length)
  - Time: 30 minutes

- [ ] **P2-4** Date picker doesn't dismiss keyboard
  - File: Multiple screens
  - Fix: Call `FocusScope.of(context).unfocus()` before picker
  - Time: 15 minutes

- [ ] **P2-5** Backup export - no size warning
  - File: `backup_restore_screen.dart:114-146`
  - Fix: Check JSON size before clipboard
  - Time: 30 minutes

- [ ] **P2-6** Over-aggressive provider invalidation
  - File: `tank_provider.dart:36-43`
  - Fix: More granular invalidation
  - Time: 2 hours (requires research)

- [ ] **P2-7** No optimistic UI updates
  - File: Task management screens
  - Fix: Update state immediately, revert on error
  - Time: 2 hours

- [ ] **P2-8** Image loading - no placeholder
  - File: `add_log_screen.dart:663-693`
  - Fix: Add frameBuilder with loading state
  - Time: 30 minutes

- [ ] **P2-9** Chart empty state
  - File: `charts_screen.dart`
  - Fix: Show "need more data" message
  - Time: 30 minutes

- [ ] **P2-10** Notification permission - one-shot only
  - File: `notification_service.dart`
  - Fix: Add settings button to re-request
  - Time: 1 hour

- [ ] **P2-11** Equipment maintenance - no interval validation
  - File: Equipment editing screens
  - Fix: Validate 1-365 day range
  - Time: 15 minutes

- [ ] **P2-12** Decimal input allows multiple dots
  - File: `add_log_screen.dart:621-643`
  - Fix: Better regex: `^\d*\.?\d{0,2}$`
  - Time: 10 minutes

---

## 🔵 P3: LOW (Future)

- [ ] **P3-1** No system theme change detection
- [ ] **P3-2** Auto-calculate volume from dimensions
- [ ] **P3-3** Search/filter missing in tank list
- [ ] **P3-4** No undo for deletions
- [ ] **P3-5** Water test - no auto-fill from last
- [ ] **P3-6** Equipment - no autocomplete

---

## 📈 PROGRESS TRACKING

### Sprint 1 (Week 1) - CRITICAL FIXES
**Goal:** Fix all P0 bugs + top P1 bugs  
**Target:** 10 bugs fixed

- [ ] P0-1: Race condition
- [ ] P0-2: Silent failures
- [ ] P0-3: Monthly dates
- [ ] P0-4: Streak bug
- [ ] P0-5: Enable persistence ⚡
- [ ] P1-2: Input validation
- [ ] P1-3: Tank volume
- [ ] P1-11: Onboarding error
- [ ] P2-4: Keyboard dismissal
- [ ] P2-12: Decimal regex

**Estimated time:** 8-10 hours  
**Priority:** MUST DO before any new features

---

### Sprint 2 (Week 2) - DATA INTEGRITY
**Goal:** Fix import/export + memory leaks  
**Target:** 6 bugs fixed

- [ ] P1-7: Import/export full data
- [ ] P1-8: Settings race condition
- [ ] P1-10: Memory leaks (partial)
- [ ] P2-1: Photo performance
- [ ] P2-2: Character limits
- [ ] P2-5: Export size warning

**Estimated time:** 12-14 hours

---

### Sprint 3 (Week 3-4) - POLISH
**Goal:** UX improvements  
**Target:** 8 bugs fixed

- [ ] P1-1: Notification timezone
- [ ] P1-5: Photo disk full
- [ ] P1-9: Navigation staleness
- [ ] P2-3: Input sanitization
- [ ] P2-7: Optimistic updates
- [ ] P2-8: Image placeholders
- [ ] P2-9: Chart empty states
- [ ] P2-11: Equipment validation

**Estimated time:** 8-10 hours

---

## 🎯 QUICK WINS (Do These First!)

High impact, minimal effort:

1. ✅ **P0-5** - Enable persistence (5 min)
2. ✅ **P0-3** - Fix monthly dates (30 min)
3. ✅ **P1-11** - Onboarding error (15 min)
4. ✅ **P2-4** - Keyboard dismissal (15 min)
5. ✅ **P2-12** - Decimal regex (10 min)
6. ✅ **P1-3** - Tank volume validation (15 min)

**Total: ~1.5 hours for 6 bugs** 🚀

---

## 🧪 TEST COVERAGE NEEDED

### Unit Tests
- [ ] Task date calculations (all recurrence types)
- [ ] User streak logic (all edge cases)
- [ ] Input validation (boundary values)
- [ ] Storage concurrency (stress test)

### Integration Tests
- [ ] Full backup/restore cycle
- [ ] Multi-tank management
- [ ] Photo upload flow
- [ ] Navigation state preservation

### Manual Testing
- [ ] Low-end device performance
- [ ] Offline behavior
- [ ] Large dataset handling (50+ tanks, 1000+ logs)
- [ ] System theme changes

---

## 📊 BUG METRICS

**Current state:**
- Total bugs: 34
- Critical (P0): 5
- High (P1): 11
- Medium (P2): 12
- Low (P3): 6

**After Sprint 1:**
- Expected: 24 bugs remaining
- Critical: 0 ✅
- High: 8

**After Sprint 2:**
- Expected: 18 bugs remaining
- High: 2

**Goal state:**
- All P0/P1: Fixed
- P2: 50% fixed
- P3: Backlog for future releases

---

## 🚀 DEPLOYMENT CHECKLIST

Before releasing fixes:

- [ ] All P0 bugs verified fixed
- [ ] Regression testing on main flows
- [ ] Performance testing (no slowdowns)
- [ ] Fresh install test
- [ ] Upgrade test (existing data preserved)
- [ ] Low-memory device test
- [ ] Review crash analytics baseline

---

## 📝 NOTES

**Testing priorities:**
1. Data persistence (P0-5)
2. Concurrent operations (P0-1)
3. Edge case inputs (P1-2, P1-3)
4. Long-running usage (memory leaks)

**Known risks:**
- P1-10 (TextFormField refactor) may introduce regressions
- P1-7 (Import/export) requires careful testing
- P0-1 (locking) might affect performance

**Deferred:**
- Full error reporting system (needs architecture)
- Comprehensive test suite (gradual addition)
- Performance optimization (monitor first)
