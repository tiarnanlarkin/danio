# Hearts System - Implementation Checklist

Track your progress implementing the hearts/lives system.

## ✅ Phase 1: Data Model

- [ ] Update `UserProfile` model with hearts fields:
  - [ ] `currentHearts` (int, default 5)
  - [ ] `lastHeartLost` (DateTime?)
  - [ ] `unlimitedHeartsEnabled` (bool, default false)
- [ ] Update `copyWith` method
- [ ] Update `toJson` serialization
- [ ] Update `fromJson` deserialization
- [ ] Add extension methods:
  - [ ] `hasHearts` getter
  - [ ] `heartsToRefill` getter
  - [ ] `heartsRefillable` getter (time-based calculation)
  - [ ] `timeUntilNextHeart` getter
  - [ ] `timeUntilNextHeartFormatted` getter

## ✅ Phase 2: Provider Logic

- [ ] Add `loseHeart()` method to `UserProfileNotifier`
- [ ] Add `refillHearts()` method (time-based)
- [ ] Add `earnHeartFromPractice()` method
- [ ] Add `toggleUnlimitedHearts()` method
- [ ] Test all methods with SharedPreferences persistence

## ✅ Phase 3: UI Widgets

- [ ] Create `HeartsDisplay` widget (`lib/widgets/hearts_display.dart`):
  - [ ] Show 5 hearts (filled/empty)
  - [ ] Optional timer display
  - [ ] Compact mode option
  - [ ] Tap to show info dialog
  - [ ] Auto-refill on display
  - [ ] Color coding for heart states

## ✅ Phase 4: Screens

### Practice Required Screen
- [ ] Create `PracticeRequiredScreen` (`lib/screens/practice_required_screen.dart`):
  - [ ] Broken heart illustration
  - [ ] Two option cards:
    - [ ] "Practice to Earn Hearts" (actionable)
    - [ ] "Wait for Refill" (informational)
  - [ ] Timer display
  - [ ] Educational tip footer

### Practice Mode Screen
- [ ] Create `PracticeModeScreen` (`lib/screens/practice_mode_screen.dart`):
  - [ ] Green theme (differentiate from regular quiz)
  - [ ] Load random questions from all lessons
  - [ ] Unlimited attempts (no heart loss)
  - [ ] Show explanations after each answer
  - [ ] Award 5 XP (reduced from 10)
  - [ ] Award 1 heart on completion
  - [ ] Completion celebration screen

## ✅ Phase 5: Quiz Integration

### Update Lesson Screen
- [ ] Import `practice_required_screen.dart` and `hearts_display.dart`
- [ ] Add `HeartsDisplay` to AppBar
- [ ] Check hearts before starting quiz:
  - [ ] Navigate to `PracticeRequiredScreen` if no hearts
- [ ] Deduct heart on wrong answer:
  - [ ] Call `loseHeart()` after incorrect response
  - [ ] Check if hearts depleted after deduction
  - [ ] Navigate to `PracticeRequiredScreen` if depleted mid-quiz
- [ ] Test full quiz flow with heart loss

## ✅ Phase 6: Settings

- [ ] Add "Unlimited Hearts" toggle to `SettingsScreen`:
  - [ ] Show current state
  - [ ] Call `toggleUnlimitedHearts()` on change
  - [ ] Show snackbar confirmation
  - [ ] Update hearts display when toggled

## ✅ Phase 7: Testing

### Unit Tests (`test/hearts_system_test.dart`)
- [ ] Test `UserProfile` model:
  - [ ] Default 5 hearts
  - [ ] `hasHearts` logic
  - [ ] Unlimited hearts bypass
  - [ ] `heartsRefillable` calculations
  - [ ] Time until next heart
- [ ] Test Provider methods:
  - [ ] `loseHeart()` decrements correctly
  - [ ] Hearts don't go below 0
  - [ ] Unlimited hearts bypass in `loseHeart()`
  - [ ] `refillHearts()` time-based logic
  - [ ] `earnHeartFromPractice()` awards 1 heart
  - [ ] Hearts cap at 5
  - [ ] `toggleUnlimitedHearts()` switches setting

### Integration Tests
- [ ] Wrong quiz answer → heart lost
- [ ] Quiz blocked when hearts = 0
- [ ] Practice mode doesn't deduct hearts
- [ ] Practice completion awards heart
- [ ] Settings toggle disables system
- [ ] Heart refill timer accuracy

### Manual Testing
- [ ] Complete quiz with all correct answers (no hearts lost)
- [ ] Answer questions incorrectly until hearts = 0
- [ ] Navigate to practice required screen
- [ ] Complete practice session
- [ ] Verify 1 heart awarded
- [ ] Test timer countdown display
- [ ] Toggle unlimited hearts in settings
- [ ] Verify quiz works with unlimited hearts
- [ ] Test heart refill after 5+ hours (or mock time)

## ✅ Phase 8: Polish & UX

- [ ] Test hearts display in different screen sizes
- [ ] Verify all color states (full, low, empty hearts)
- [ ] Check animations and transitions
- [ ] Verify timer updates in real-time
- [ ] Test info dialog readability
- [ ] Ensure practice mode feels distinct (green theme)
- [ ] Verify all text is clear and encouraging

## ✅ Phase 9: Documentation

- [ ] Update app README with hearts system description
- [ ] Document heart refill algorithm
- [ ] Add screenshots of hearts UI
- [ ] Document practice mode XP rewards

## ✅ Phase 10: Future Enhancements (Optional)

- [ ] Daily heart bonus (e.g., +1 for streak)
- [ ] Heart power-up items
- [ ] Achievements for perfect quizzes (no hearts lost)
- [ ] Analytics tracking:
  - [ ] Heart depletion rate
  - [ ] Practice mode engagement
  - [ ] Unlimited hearts adoption
- [ ] A/B test different refill intervals

---

## Quick Reference

**Key Numbers:**
- Max hearts: **5**
- Refill rate: **1 heart per 5 hours**
- Practice XP: **5** (vs regular **10**)
- Hearts earned per practice: **1**

**Key Files:**
- Model: `lib/models/user_profile.dart`
- Provider: `lib/providers/user_profile_provider.dart`
- Widget: `lib/widgets/hearts_display.dart`
- Screens:
  - `lib/screens/practice_required_screen.dart`
  - `lib/screens/practice_mode_screen.dart`
  - `lib/screens/lesson_screen.dart` (updated)
  - `lib/screens/settings_screen.dart` (updated)

---

**Progress Tracker:**
- [ ] Phase 1: Data Model
- [ ] Phase 2: Provider Logic
- [ ] Phase 3: UI Widgets
- [ ] Phase 4: Screens
- [ ] Phase 5: Quiz Integration
- [ ] Phase 6: Settings
- [ ] Phase 7: Testing
- [ ] Phase 8: Polish & UX
- [ ] Phase 9: Documentation
- [ ] Phase 10: Future Enhancements

**Status:** 0% Complete
