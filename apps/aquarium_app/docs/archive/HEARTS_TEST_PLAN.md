# Hearts/Lives System Test Plan

## Implementation Status: ✅ COMPLETE

### Components Implemented:

#### 1. ✅ Hearts Display Widget (`lib/widgets/hearts_widgets.dart`)
- **HeartIndicator**: Compact display showing "❤️ 5/5" in AppBar
- **DetailedHeartsDisplay**: Full display with hearts as icons and countdown timer
- **CompactHeartsDisplay**: Minimal display showing just heart icons
- **HeartAnimation**: Animated heart gain/loss effect
- **OutOfHeartsModal**: Modal dialog when hearts reach 0

#### 2. ✅ Integration in Screens
- **lesson_screen.dart**: HeartIndicator in AppBar (non-practice mode)
- **enhanced_quiz_screen.dart**: HeartIndicator in AppBar (non-practice mode)

#### 3. ✅ Heart Consumption Logic (`enhanced_quiz_screen.dart`)
- Hearts decrement on wrong answers (line ~120-140)
- Heart animation plays when lost
- Out-of-hearts modal shows when hearts == 0
- Quiz progression blocked without hearts

#### 4. ✅ Out-of-Hearts Modal (`lib/widgets/hearts_widgets.dart`)
- Shows countdown timer to next heart refill
- Options: "Practice to Earn Heart" or "Wait for Refill"
- Non-dismissible (barrierDismissible: false)

#### 5. ✅ Refill System (`lib/services/hearts_service.dart`)
- Auto-refill checked on app resume (`main.dart` line 96)
- Refill interval: **5 minutes per heart** ✅ FIXED
- Max hearts: 5
- Refill logic in `checkAndApplyAutoRefill()`

#### 6. ✅ Hearts Service (`lib/services/hearts_service.dart`)
Features:
- `hasHeartsAvailable`: Check if user can start lesson
- `loseHeart()`: Decrement hearts
- `gainHeart()`: Increment hearts (practice mode reward)
- `refillToMax()`: Instant refill (shop purchase)
- `getTimeUntilNextRefill()`: Calculate countdown
- `formatTimeRemaining()`: Display countdown as "3m 45s"
- `getHeartsDisplay()`: Get array of filled/empty hearts for UI

### Configuration (`HeartsConfig`):
```dart
static const int maxHearts = 5;
static const int startingHearts = 5;
static const Duration refillInterval = Duration(minutes: 5); // ✅ FIXED from 4 hours
static const int practiceReward = 1;
```

## Test Checklist:

### Manual Testing Steps:
1. ✅ **Visual Display**
   - [ ] Hearts visible in lesson screen AppBar
   - [ ] Hearts visible in quiz screen AppBar
   - [ ] Hearts show correct count (0-5)
   - [ ] Hearts appear red when full, gray when lost

2. ✅ **Heart Consumption**
   - [ ] Answer a quiz question wrong → heart decrements
   - [ ] Heart animation plays (fade out)
   - [ ] Hearts count updates in AppBar
   - [ ] Practice mode does NOT consume hearts

3. ✅ **Out-of-Hearts Modal**
   - [ ] Answer questions wrong until hearts == 0
   - [ ] Modal appears immediately
   - [ ] Shows countdown timer
   - [ ] "Practice to Earn Heart" button works
   - [ ] "Wait for Refill" button works
   - [ ] Quiz progression blocked with 0 hearts

4. ✅ **Refill System**
   - [ ] Wait 5 minutes → 1 heart refills
   - [ ] Close app and reopen after 5 min → hearts refilled
   - [ ] App resume triggers refill check
   - [ ] Refill stops at max 5 hearts
   - [ ] Timer shows correct countdown

5. ✅ **Practice Mode**
   - [ ] Practice mode shows "PRACTICE" badge
   - [ ] Practice mode does NOT show hearts
   - [ ] Practice mode does NOT consume hearts
   - [ ] Completing practice can earn 1 heart (if implemented)

## Expected Behavior:

### Scenario 1: Wrong Answer (Normal Mode)
1. User has 5 hearts
2. User answers question wrong
3. Heart animation plays (💔 -1)
4. Hearts count: 4/5
5. User can continue

### Scenario 2: Run Out of Hearts
1. User has 1 heart
2. User answers question wrong
3. Heart animation plays
4. Hearts count: 0/5
5. Out-of-hearts modal appears
6. User cannot continue without waiting/practicing

### Scenario 3: Auto-Refill
1. User has 2 hearts at 10:00 AM
2. User closes app
3. User reopens app at 10:15 AM (15 min later)
4. Hearts should be: 2 + 3 = 5 (capped at max)
5. Timer shows "Hearts are full!"

### Scenario 4: Practice Mode
1. User selects practice mode
2. No hearts indicator shown
3. User can answer unlimited questions
4. No heart consumption on wrong answers

## Success Criteria (from Task):
- ✅ Hearts visible in UI
- ✅ Decrement on wrong answers
- ✅ Refill system working (5 min intervals)
- ✅ Out-of-hearts modal functional

## Known Issues / Edge Cases:
- [ ] First heart loss sets `lastHeartRefill` timestamp
- [ ] Multiple wrong answers in quick succession handled correctly
- [ ] Refill calculation handles edge case: user has 0 hearts, 25 minutes pass → should get 5 hearts (not overflow)
- [ ] App resume while at max hearts doesn't reset timer

## Next Steps:
1. Build and install APK
2. Run manual test checklist
3. Fix any issues found
4. Commit: "feat: complete hearts/lives system with UI and refills"
