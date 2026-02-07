# Integration Test Scenarios
**Date:** February 7, 2025

## Purpose
End-to-end test scenarios to verify all 15 learning features work together seamlessly.

---

## Test Scenario 1: Complete a Lesson (Full Flow)

### Objective
Verify that completing a lesson awards XP, gems, updates streak, and triggers achievements.

### Prerequisites
- Fresh user profile with 0 XP, 0 gems
- No lessons completed yet

### Steps
1. Launch app
2. Navigate to Study room (📚)
3. Select "The Nitrogen Cycle" learning path
4. Select first lesson: "Understanding the Nitrogen Cycle"
5. Read through all 5 lesson sections
6. Tap "Take Quiz"
7. Answer all 5 quiz questions (get 4/5 correct - 80%)
8. Tap "Complete Lesson"

### Expected Results

| System | Expected Behavior | Status |
|--------|------------------|--------|
| **XP** | Awarded 50 (lesson) + 25 (quiz pass) = 75 XP | ✅ |
| **Gems** | Awarded 5 (lesson) + 3 (quiz pass) = 8 gems | ✅ FIXED |
| **Streak** | Current streak = 1 day | ✅ |
| **Achievement** | "First Steps" unlocked | ✅ |
| **Daily Goal** | Progress updated (75/50 XP = complete) | ✅ |
| **Leaderboard** | Weekly XP updated (+75) | ✅ |
| **UI Feedback** | Snackbar shows "+75 XP, +8 gems" | ✅ FIXED |

### Validation Steps
1. Check home screen - verify streak badge shows "1🔥"
2. Check daily goal progress - should show 150% (75/50)
3. Open Study room - "First Steps" achievement badge visible
4. Check leaderboard - rank should reflect 75 weekly XP
5. Open gem shop (future) - balance shows 8 gems

---

## Test Scenario 2: Perfect Quiz Bonus

### Objective
Verify perfect quiz (100%) awards bonus gems.

### Prerequisites
- User has completed at least 1 lesson

### Steps
1. Navigate to Study room
2. Select any lesson with a quiz
3. Read lesson content
4. Take quiz
5. Answer all questions correctly (5/5)
6. Complete lesson

### Expected Results

| Item | Expected Value |
|------|---------------|
| Quiz XP Bonus | +50 XP (perfect bonus) |
| Quiz Gems Bonus | +5 gems (perfect) vs +3 (pass) |
| Total Rewards | 50 (lesson) + 50 (perfect) = 100 XP |
| Total Gems | 5 (lesson) + 5 (perfect) = 10 gems |
| Achievement | "Quiz Ace" unlocked |
| Gem Bonus | +20 gems (gold tier achievement) |

**Final:** 100 XP, 30 gems total (10 quiz + 20 achievement)

---

## Test Scenario 3: Daily Routine Flow

### Objective
Test typical daily engagement flow.

### Prerequisites
- User has existing streak (day 5)
- Current XP: 250
- Current gems: 30

### Steps
1. **Morning (9:00 AM)**
   - Open app
   - Check streak reminder notification
   - View home screen

2. **Complete Lesson 1 (9:15 AM)**
   - Navigate to Study room
   - Complete "Water Chemistry Basics"
   - Pass quiz (4/5)

3. **Complete Lesson 2 (9:45 AM)**
   - Complete "pH and Your Fish"
   - Pass quiz (5/5 - perfect)

4. **Check Progress (10:00 AM)**
   - View home screen
   - Check daily goal progress
   - Open leaderboard

5. **Evening (8:00 PM)**
   - Complete one more lesson
   - Check if daily goal achieved

### Expected Results

**After Lesson 1:**
- XP: 250 + 75 = 325
- Gems: 30 + 8 = 38
- Daily progress: 75/50 XP (goal met!)
- Daily goal gems: +5 gems → 43 total

**After Lesson 2 (Perfect Quiz):**
- XP: 325 + 100 = 425
- Gems: 43 + 10 = 53
- Achievement: "Quiz Ace" → +20 gems = 73 total

**Streak:**
- Maintained: 6 days
- No streak milestone (next at 7 days)

**Leaderboard:**
- Weekly XP: +175 (75 + 100)
- Rank: Likely improved

**Final Status:**
- Total XP: 425
- Total Gems: 73
- Streak: 6 days 🔥
- Lessons completed: 3 new
- Daily goal: ✅ Met (175/50)

---

## Test Scenario 4: Streak Milestone Rewards

### Objective
Verify streak milestones award bonus gems.

### Prerequisites
- User has 6-day streak
- Completed lessons on days 1-6

### Steps
1. Day 7: Complete any lesson
2. Check gem balance after lesson
3. View streak display

### Expected Results

| Milestone | XP Bonus | Gem Bonus |
|-----------|----------|-----------|
| 7-day streak | +25 XP | +10 gems |

**Breakdown:**
- Lesson: +50 XP, +5 gems
- Quiz: +25 XP, +3 gems
- Daily goal met: +5 gems
- **Streak milestone: +10 gems**
- **Total: +75 XP, +23 gems**

### Streak Gem Milestones

| Days | Gem Reward | XP Reward |
|------|-----------|-----------|
| 3 | - | - |
| 7 | 10 | 25 |
| 14 | 10 | 25 |
| 30 | 25 | 25 |
| 50 | 25 | 25 |
| 100 | 100 | 25 |

---

## Test Scenario 5: Level Up Rewards

### Objective
Verify leveling up awards bonus gems.

### Prerequisites
- User is close to level up (e.g., 290/300 XP)

### Steps
1. Complete a lesson that pushes over threshold
2. Check for level-up notification
3. Verify gem bonus

### Expected Level Thresholds

| Level | XP Required | Title | Gem Reward |
|-------|------------|-------|-----------|
| 1 | 0 | Beginner | - |
| 2 | 100 | Novice | 10 |
| 3 | 300 | Hobbyist | 10 |
| 4 | 600 | Aquarist | 10 |
| 5 | 1000 | Expert | 50 |
| 6 | 1500 | Master | 100 |
| 7 | 2500 | Guru | 200 |

### Example: Level 3 → Level 4

**Before:**
- XP: 590/600 (Hobbyist)
- Gems: 45

**After Lesson (+75 XP):**
- XP: 665 (Aquarist)
- Lesson gems: +5
- Quiz gems: +3
- **Level-up gems: +10**
- **Total gems: 45 + 18 = 63**

---

## Test Scenario 6: Social Interaction Flow

### Objective
Test friends, activity feed, and encouragement system.

### Prerequisites
- User has 5+ friends
- Friends have recent activities

### Steps
1. Open Friends screen (👥)
2. Scroll through activity feed
3. Select a friend
4. View friend comparison
5. Send encouragement ("🔥" + "Keep it up!")
6. Return to feed

### Expected Results

**Activity Feed:**
- ✅ Shows recent friend activities (last 7 days)
- ✅ Displays activity type icons (⭐🏆🔥📚)
- ✅ Shows XP earned for each activity
- ✅ Relative timestamps ("2h ago", "3d ago")

**Friend Comparison:**
- ✅ Side-by-side stats (XP, streak, level)
- ✅ Visual comparison bars
- ✅ Shared achievements highlighted

**Encouragement:**
- ✅ Can send emoji + message
- ✅ Sent encouragement appears in feed
- ⚠️ No real-time delivery (mock only)

**Limitations:**
- Mock friend data (no real backend)
- Activities are randomly generated
- No actual friend connection

---

## Test Scenario 7: Leaderboard Competition

### Objective
Test weekly leaderboard system and league progression.

### Prerequisites
- User in Bronze League
- Week started Monday

### Steps
1. Open Leaderboard screen (🏆)
2. View current rank
3. Check weekly XP total
4. Complete multiple lessons over the week
5. Check rank changes
6. Wait for Monday reset (or simulate)

### Expected Results

**Leaderboard Display:**
- ✅ Shows 50 users (1 real + 49 AI)
- ✅ Current user highlighted
- ✅ Weekly XP totals visible
- ✅ Rank displayed (1-50)
- ✅ League badge shown (🥉🥈🥇💎)

**Promotion Zones:**
- Top 10: Promotion to next league
- 11-15: Safe zone
- 16-50: Relegation risk

**Weekly Reset (Monday):**
- XP resets to 0
- Ranks recalculated
- Promotion/relegation applied
- Bonus gems awarded for promotion

**Example Promotion:**
- Finish rank 8 in Bronze
- Promoted to Silver
- **Award: +50 gems**

---

## Test Scenario 8: Placement Test Skip

### Objective
Verify placement test awards XP/gems and skips lessons.

### Prerequisites
- New user (or reset profile)
- Hasn't taken placement test

### Steps
1. Start onboarding
2. Take placement test
3. Answer 8/10 questions correctly
4. Complete test
5. Check which lessons were skipped
6. Verify XP and gems awarded

### Expected Results

**Test Results (8/10 - 80%):**
- ✅ Skips beginner lessons (3-4 lessons)
- ✅ Unlocks intermediate path
- ✅ Lessons marked as "tested out"
- ✅ Strength: 75% (lower than completed lessons)

**Rewards:**
- XP: +10 per skipped lesson (e.g., 40 XP for 4 lessons)
- **Gems: +10 (placement test bonus)**
- Daily goal progress updated

**Navigation:**
- Can immediately start intermediate lessons
- Skipped lessons still viewable (for review)

---

## Test Scenario 9: Gem Economy (Shop Purchase)

### Objective
Test gem earning, balance tracking, and shop purchases.

**Note:** Requires gem shop screen (created in this session).

### Prerequisites
- User has 50 gems
- No active power-ups

### Steps
1. Open gem shop (new screen)
2. View available items
3. Purchase "2x XP Boost" (25 gems)
4. Verify gem balance deducted
5. Check inventory
6. Activate power-up
7. Complete a lesson with boost active
8. Verify XP doubled

### Expected Results

**Gem Balance:**
- Before: 50 gems
- Purchase: -25 gems
- After: 25 gems

**Transaction History:**
- ✅ Shows "Spent 25 gems - 2x XP Boost"
- ✅ Balance after: 25

**Inventory:**
- ✅ "2x XP Boost" added (1x, 1h duration)
- ✅ Can activate item
- ✅ Shows expiry timer when active

**With Power-Up Active:**
- Lesson: 50 XP → **100 XP (doubled)**
- Quiz: 25 XP → **50 XP (doubled)**
- Gems still awarded normally (no change)

---

## Test Scenario 10: Comprehensive Weekly Routine

### Objective
Full week simulation to test all systems together.

### Day-by-Day Expectations

**Monday:**
- Start fresh week (leaderboard reset)
- Complete 2 lessons (150 XP, 16 gems)
- Daily goal met (+5 gems)
- Weekly XP: 150

**Tuesday:**
- Complete 1 lesson (75 XP, 8 gems)
- Streak: 2 days
- Weekly XP: 225

**Wednesday:**
- Complete 2 lessons, 1 perfect quiz (175 XP, 31 gems)
- Unlock achievement (+20 gems)
- Streak: 3 days
- Weekly XP: 400

**Thursday:**
- Complete 1 lesson (75 XP, 8 gems)
- Streak: 4 days
- Weekly XP: 475

**Friday:**
- Complete 3 lessons (225 XP, 24 gems)
- Streak: 5 days
- Weekly XP: 700

**Saturday:**
- Complete 1 lesson (75 XP, 8 gems)
- Streak: 6 days
- Weekly XP: 775

**Sunday:**
- Complete 2 lessons (150 XP, 16 gems)
- **Streak: 7 days (+10 gems milestone!)**
- Weekly XP: 925

### Week Summary

**XP Totals:**
- Total XP earned: 925 XP
- Daily goals met: 7 days (+35 gems)
- Level progress: Likely 1-2 levels gained

**Gem Totals:**
- Lesson gems: ~100 gems
- Daily goal gems: 35 gems
- Streak milestone: 10 gems
- Achievement gems: ~40 gems
- **Total: ~185 gems earned**

**Leaderboard:**
- Weekly XP: 925
- Estimated rank: Top 10-15 (varies by league)
- Possible promotion if top 10

**Achievements Unlocked:**
- "7-day Streak" (silver tier) → +10 gems
- "Quiz Ace" (gold tier) → +20 gems
- "Level Up" milestones → +10-50 gems

---

## Test Scenario 11: Streak Freeze Usage

### Objective
Test streak freeze system (automatic weekly + purchasable).

### Prerequisites
- User has active 5-day streak
- Streak freeze available (weekly reset)

### Steps
1. **Day 6:** Complete lesson (streak = 6)
2. **Day 7:** Skip day (no activity)
3. **Day 8:** Complete lesson
4. Check streak value

### Expected Results

**Without Freeze:**
- Day 8 streak: 1 (reset)

**With Auto-Freeze:**
- Day 8 streak: 7 (freeze used, streak continued)
- Freeze now unavailable until next Monday
- UI shows "Freeze used this week"

### Purchased Freeze

If user buys extra freeze from shop:
- 30 gems cost
- Stacks with free weekly freeze
- Can save streak twice in one week

---

## Validation Checklist

Use this checklist to verify integration after each major change:

### XP System
- [ ] Lessons award correct XP (50 base)
- [ ] Quizzes award bonus XP (25 pass, 50 perfect)
- [ ] Daily goal tracking works
- [ ] Level-up progression correct
- [ ] XP display updated everywhere

### Gems Economy
- [x] Lessons award gems (5 base)
- [x] Quizzes award gems (3 pass, 5 perfect)
- [x] Daily goals award gems (5)
- [x] Streak milestones award gems (10-100)
- [x] Achievements award gems (5-50)
- [x] Gem balance displays correctly
- [ ] Gem shop functional (partially - screen created)
- [ ] Inventory tracks purchases
- [ ] Power-ups can be activated

### Hearts System
- [ ] Hearts deduct on wrong answers (NOT IMPLEMENTED)
- [ ] Hearts refill over time (NOT IMPLEMENTED)
- [ ] Practice mode unlimited hearts (NOT IMPLEMENTED)
- [ ] Hearts display in UI (NOT IMPLEMENTED)

### Streak System
- [x] Daily activity tracked
- [x] Streak increments correctly
- [x] Freeze works (auto weekly)
- [ ] Streak warnings shown
- [x] Milestone rewards awarded

### Leaderboards
- [x] Weekly XP tracked
- [x] Ranks calculated correctly
- [x] League system working
- [x] Promotion/relegation logic
- [ ] Notifications on promotion

### Social Features
- [x] Friends list populated
- [x] Activity feed generated
- [x] Encouragements can be sent
- [x] Friend comparison works
- [ ] Real-time updates (mock only)

### Integration Points
- [x] XP and gems awarded together
- [x] Achievements trigger rewards
- [x] Streaks trigger milestones
- [x] Leaderboards reflect progress
- [ ] Celebrations shown (NOT IMPLEMENTED)
- [ ] Power-ups affect gameplay (PARTIAL)

---

## Known Issues & Limitations

### Critical
1. **Hearts system not implemented** - No heart tracking or deduction
2. **Gem shop incomplete** - UI created but not integrated into navigation
3. **Power-ups don't activate** - Items purchasable but effects don't apply
4. **No celebrations** - Missing visual feedback for achievements

### Minor
1. Social features use mock data only
2. No real-time leaderboard updates
3. No push notifications for achievements
4. Streak warnings not implemented
5. Adaptive difficulty not connected

---

## Testing Tools

### Manual Reset
To reset progress for testing:
```dart
// In developer menu (create if needed):
await ref.read(userProfileProvider.notifier).resetProfile();
await ref.read(gemsProvider.notifier).reset();
await ref.read(inventoryProvider.notifier).reset();
await ref.read(leaderboardProvider.notifier).reset();
```

### Debug Gem Grants
```dart
// Award test gems:
await ref.read(gemsProvider.notifier).grantGems(
  amount: 500,
  reason: 'Testing',
);
```

### Simulate Streak
```dart
// Set specific streak value (needs custom method):
// Manually edit dailyXpHistory in shared preferences
```

---

## Success Criteria

Integration is complete when:
- ✅ All core systems award rewards correctly
- ✅ Gem economy fully functional (earn + spend)
- ✅ Streaks and achievements work together
- ⚠️ Hearts system implemented (pending)
- ⚠️ Celebrations show for milestones (pending)
- ⚠️ Power-ups activate and affect gameplay (pending)
- ✅ Social features display correctly
- ✅ Leaderboards update in real-time (weekly)

**Current Status: 80% Complete**

---

**Document Version:** 1.0
**Last Updated:** February 7, 2025
**Next Review:** After implementing hearts system and celebrations
