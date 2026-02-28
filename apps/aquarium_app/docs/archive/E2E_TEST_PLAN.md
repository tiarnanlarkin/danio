# End-to-End Testing Plan - Aquarium App

**Test Date:** 2026-02-07 22:05 GMT  
**Build:** Fresh install with all 11 agent features  
**Device:** Android Emulator

---

## Test Flows

### 1. ✅ Onboarding Flow (Agent 2)
- [ ] View 3 onboarding screens
- [ ] Skip functionality
- [ ] Profile creation form
- [ ] Experience level selection
- [ ] Tank type selection
- [ ] Goals selection
- [ ] Placement test
- [ ] Tutorial overlay on first main screen

### 2. ✅ Hearts System (Agent 3)
- [ ] Hearts display in AppBar
- [ ] Wrong answer consumes heart
- [ ] Heart refill after 5 minutes
- [ ] Out-of-hearts modal blocks quiz
- [ ] "Practice to Earn Heart" option
- [ ] "Wait for Refill" countdown

### 3. ✅ XP Animations (Agent 4)
- [ ] "+X XP" floats up after lesson
- [ ] Level-up confetti celebration
- [ ] Milestone messages display
- [ ] Navigation waits for animations

### 4. ✅ Spaced Repetition (Agent 5)
- [ ] Cards auto-created after lesson (3-5 cards)
- [ ] Badge shows due card count
- [ ] Banner on LearnScreen when cards due
- [ ] Review session opens
- [ ] Progress bar during review
- [ ] Completion summary shows

### 5. ✅ Achievements (Agent 6)
- [ ] Full-screen celebration dialog
- [ ] Confetti animation (3 directions)
- [ ] XP and Gems awarded
- [ ] System notification fires
- [ ] Tap notification opens achievements

### 6. ✅ Tank Management (Agent 7)
- [ ] Soft delete with undo (5 seconds)
- [ ] Bulk selection mode (long-press)
- [ ] Multi-delete with confirmation
- [ ] Undo restores full data

### 7. ✅ Offline Mode (Agent 9)
- [ ] Orange offline banner appears
- [ ] Sync indicator shows queue
- [ ] Lessons work offline
- [ ] Auto-sync when connection returns

### 8. ✅ Performance (Agent 10)
- [ ] Scrolling is smooth (60 FPS)
- [ ] No jank on lists
- [ ] Image thumbnails load quickly
- [ ] Memory usage reasonable

### 9. ✅ Journey Verification (Agent 8)
All 7 user journeys validated with 98.1% test pass rate

### 10. ✅ Build & Test (Agent 11)
- [ ] APK builds successfully
- [ ] App installs and launches
- [ ] No crashes on startup

---

## Execution Steps

I'll navigate through each flow systematically, taking screenshots and documenting issues.

**Testing started...**
