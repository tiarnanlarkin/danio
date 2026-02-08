# USER JOURNEY FIXES - PRIORITY CHECKLIST

**Overall Status:** 71% Complete (5/7 journeys functional)  
**Production Ready:** ❌ NO (Critical onboarding bug blocks new users)

---

## 🔴 CRITICAL - MUST FIX BEFORE ANY RELEASE

### 1. Fix Onboarding Flow (BROKEN - 40% complete)

**Problem:** New users skip placement test and land on empty home screen without profile.

**File:** `lib/screens/onboarding_screen.dart:145`

**Current Code:**
```dart
Future<void> _completeOnboarding() async {
  final service = await OnboardingService.getInstance();
  await service.completeOnboarding();

  if (mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),  // ❌ WRONG!
    );
  }
}
```

**Fix:**
```dart
Future<void> _completeOnboarding() async {
  final service = await OnboardingService.getInstance();
  await service.completeOnboarding();

  if (mounted) {
    // ✅ Route to placement test
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PlacementTestScreen()),
    );
  }
}
```

**Also Need:**
- [ ] Create `ProfileCreationScreen` (collect name, experience, goals)
- [ ] Route: `PlacementTestScreen` → `PlacementResultScreen` → `ProfileCreationScreen` → `HomeScreen`
- [ ] Make profile creation mandatory (block app use without profile)

**Time Estimate:** 4-6 hours

---

### 2. Add Error Handling to ALL Provider Actions

**Problem:** 12+ provider actions fail silently. Users see no feedback.

**Files to Fix:**
- `lib/providers/tank_provider.dart`
- `lib/providers/user_profile_provider.dart`
- `lib/providers/gems_provider.dart`
- `lib/providers/spaced_repetition_provider.dart`
- `lib/providers/achievement_provider.dart`

**Pattern to Apply:**
```dart
// ❌ BAD (current)
Future<void> someAction() async {
  await _storage.save(data);
  state = newState;
}

// ✅ GOOD (add this)
Future<void> someAction() async {
  try {
    await _storage.save(data);
    state = AsyncValue.data(newState);
  } catch (e, st) {
    state = AsyncValue.error(e, st);
    rethrow;  // Let UI handle it
  }
}
```

**UI Pattern:**
```dart
// In screens using providers
try {
  await ref.read(provider.notifier).someAction();
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Success!')),
    );
  }
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed: $e'),
        action: SnackBarAction(label: 'Retry', onPressed: _retry),
      ),
    );
  }
}
```

**Checklist:**
- [ ] `TankActionsProvider.createTank()` - Add try/catch
- [ ] `TankActionsProvider.deleteTank()` - Add error handling
- [ ] `UserProfileProvider.completeLesson()` - Add error handling
- [ ] `GemsProvider.spendGems()` - Add rollback on failure
- [ ] `SpacedRepetitionProvider.answerCard()` - Add error handling
- [ ] All 8 screens with async operations - Wrap in try/catch

**Time Estimate:** 6-8 hours

---

### 3. Add Loading States to Async Operations

**Problem:** 8+ screens perform async actions without loading indicators. Looks broken.

**Files to Fix:**
- `lib/screens/lesson_screen.dart` - Quiz start
- `lib/screens/enhanced_quiz_screen.dart` - Submit answer
- `lib/screens/gem_shop_screen.dart` - Purchase item
- `lib/screens/create_tank_screen.dart` - Create tank
- `lib/screens/spaced_repetition_practice_screen.dart` - Start session

**Pattern:**
```dart
bool _isLoading = false;

Future<void> _performAction() async {
  setState(() => _isLoading = true);
  try {
    await provider.action();
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

// In button:
ElevatedButton(
  onPressed: _isLoading ? null : _performAction,
  child: _isLoading 
    ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : Text('Submit'),
)
```

**Checklist:**
- [ ] `CreateTankScreen._createTank()` - Add loading state
- [ ] `QuizScreen._submitAnswer()` - Add loading state
- [ ] `GemShopScreen._purchaseItem()` - Add loading state
- [ ] `ReviewSessionScreen._submitRating()` - Add loading state
- [ ] `SettingsScreen._updateProfile()` - Add loading state

**Time Estimate:** 3-4 hours

---

## 🟠 HIGH PRIORITY - FIX BEFORE PUBLIC LAUNCH

### 4. Achievement Unlock Notifications

**Problem:** Achievements unlock silently. Users don't know they earned them.

**File:** Create new `lib/widgets/achievement_unlocked_dialog.dart`

**Implementation:**
```dart
class AchievementUnlockedDialog extends StatelessWidget {
  final Achievement achievement;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Confetti animation
            ConfettiOverlay(),
            
            // Achievement icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: achievement.tier.color,
                shape: BoxShape.circle,
              ),
              child: Icon(achievement.icon, size: 50),
            ),
            
            SizedBox(height: 16),
            
            // Title
            Text(
              'Achievement Unlocked!',
              style: AppTypography.headlineSmall,
            ),
            
            // Achievement name
            Text(
              achievement.title,
              style: AppTypography.titleLarge,
            ),
            
            // Description
            Text(
              achievement.description,
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 16),
            
            // Rewards
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star),
                Text('${achievement.tier.xpBonus} XP'),
                SizedBox(width: 16),
                Text('💎 ${achievement.tier.gemReward} Gems'),
              ],
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Awesome!'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Show on unlock:**
```dart
// In achievement_provider.dart
Future<void> unlockAchievement(String achievementId) async {
  // ... existing unlock logic ...
  
  // Show dialog
  final achievement = Achievements.getById(achievementId);
  if (achievement != null) {
    await showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => AchievementUnlockedDialog(achievement: achievement),
    );
  }
}
```

**Checklist:**
- [ ] Create `AchievementUnlockedDialog` widget
- [ ] Add confetti animation
- [ ] Hook into `AchievementProvider.unlockAchievement()`
- [ ] Test with various achievement tiers

**Time Estimate:** 3-4 hours

---

### 5. Spaced Repetition Review Reminders

**Problem:** Users forget to review cards. No notifications or badges.

**Files:**
- `lib/services/notification_service.dart` - Add review notifications
- `lib/screens/house_navigator.dart` - Add badge to Study room

**Implementation:**

```dart
// In notification_service.dart
Future<void> scheduleReviewReminder() async {
  final spacedRepState = await getSpacedRepetitionState();
  final dueCount = spacedRepState.stats.dueCards;
  
  if (dueCount > 0) {
    await _notifications.show(
      3,
      'Time to Review!',
      'You have $dueCount cards ready to review.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reviews',
          'Review Reminders',
          importance: Importance.high,
        ),
      ),
      payload: 'review',
    );
  }
}
```

**Badge in navigation:**
```dart
// In house_navigator.dart
Stack(
  children: [
    Icon(Icons.auto_stories),
    if (dueCardsCount > 0)
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$dueCardsCount',
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
      ),
  ],
)
```

**Checklist:**
- [ ] Add review notification scheduling
- [ ] Add badge to Study room when cards due
- [ ] Add "X cards due!" message on LearnScreen
- [ ] Schedule daily reminder at user-set time

**Time Estimate:** 4-5 hours

---

### 6. Hearts System UI

**Problem:** Hearts tracked in code but never displayed. Users don't know they exist.

**Files:**
- `lib/screens/lesson_screen.dart` - Show hearts in AppBar
- `lib/screens/enhanced_quiz_screen.dart` - Consume hearts on wrong answers

**Implementation:**
```dart
// In lesson_screen.dart AppBar
AppBar(
  title: Text(lesson.title),
  actions: [
    _HeartsDisplay(hearts: profile.hearts),
  ],
)

class _HeartsDisplay extends StatelessWidget {
  final int hearts;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.favorite, color: Colors.red, size: 20),
          SizedBox(width: 4),
          Text(
            '$hearts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
```

**Consume hearts:**
```dart
// In quiz_screen.dart when answer is wrong
Future<void> _submitAnswer() async {
  if (_selectedAnswer != _currentQuestion.correctIndex) {
    // Wrong answer - lose a heart
    final currentHearts = ref.read(userProfileProvider).value?.hearts ?? 5;
    
    if (currentHearts > 0) {
      await ref.read(userProfileProvider.notifier).updateHearts(
        hearts: currentHearts - 1,
      );
    } else {
      // No hearts left - fail quiz
      _showNoHeartsDialog();
      return;
    }
  }
  
  // ... rest of submit logic
}
```

**Checklist:**
- [ ] Add hearts display to lesson/quiz AppBars
- [ ] Consume heart on wrong quiz answer
- [ ] Show "out of hearts" dialog
- [ ] Refill 1 heart every 5 minutes (or via shop)
- [ ] Add hearts info in tutorial

**Time Estimate:** 4-5 hours

---

## 🟡 MEDIUM PRIORITY - POST-LAUNCH IMPROVEMENTS

### 7. XP Award Animations

**Problem:** XP awards happen silently. No visual feedback for progression.

**Create:** `lib/widgets/xp_award_animation.dart`

```dart
class XpAwardAnimation extends StatefulWidget {
  final int xp;
  final VoidCallback onComplete;
  
  @override
  State<XpAwardAnimation> createState() => _XpAwardAnimationState();
}

class _XpAwardAnimationState extends State<XpAwardAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -3),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward().then((_) => widget.onComplete());
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Text(
          '+${widget.xp} XP',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
```

**Show after quiz:**
```dart
// In quiz_screen.dart after XP awarded
await showDialog(
  context: context,
  builder: (_) => Center(
    child: XpAwardAnimation(
      xp: xpReward,
      onComplete: () => Navigator.pop(context),
    ),
  ),
);
```

**Time Estimate:** 3-4 hours

---

### 8. Undo for Tank Deletion

**Pattern:**
```dart
// In tank_detail_screen.dart
Future<void> _deleteTank() async {
  final tank = widget.tank;
  
  // Soft delete (mark as deleted but don't remove yet)
  await ref.read(tankActionsProvider).softDeleteTank(tank.id);
  
  // Show undo snackbar
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    SnackBar(
      content: Text('Tank deleted'),
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          await ref.read(tankActionsProvider).undoDeleteTank(tank.id);
        },
      ),
    ),
  ).closed.then((reason) {
    if (reason != SnackBarClosedReason.action) {
      // User didn't undo - permanently delete
      ref.read(tankActionsProvider).permanentlyDeleteTank(tank.id);
    }
  });
  
  Navigator.pop(context);
}
```

**Time Estimate:** 2-3 hours

---

## 🟢 LOW PRIORITY - FUTURE ENHANCEMENTS

### 9. Backend for Social Features

**Problem:** Leaderboard and friends are all mock data.

**Options:**
1. **Firebase** (Recommended)
   - Firestore for user data
   - Cloud Functions for leaderboard calculations
   - Authentication
   
2. **Supabase** (Open source alternative)
   - PostgreSQL backend
   - Real-time subscriptions
   - Authentication

**Time Estimate:** 2-3 weeks for full implementation

---

### 10. Custom Flashcards

**Add user-created review cards:**
- Card creation screen
- Import from CSV
- Tag and organize cards
- Deck management

**Time Estimate:** 1-2 weeks

---

### 11. Profile Picture / Avatar

**Files:**
- Update `UserProfile` model
- Add image picker to settings
- Display avatar in profile, leaderboard, friends

**Time Estimate:** 4-6 hours

---

## SUMMARY TIMELINE

### Week 1 (Critical Fixes)
- Day 1-2: Fix onboarding flow + profile creation
- Day 3: Add error handling to all providers
- Day 4: Add loading states
- Day 5: Achievement notifications + review reminders

**Deliverable:** App is production-ready for beta launch

### Week 2 (High Priority)
- Hearts system UI
- XP animations
- Undo for deletions

**Deliverable:** Polished user experience

### Week 3+ (Future)
- Backend integration
- Custom flashcards
- Profile enhancements

**Deliverable:** Feature-complete 1.0

---

## TESTING CHECKLIST

After fixes, verify:

- [ ] Fresh install → Onboarding → Placement test → Profile → Home (complete flow)
- [ ] Create tank → Add livestock → Edit → Delete → Undo works
- [ ] Complete lesson → Quiz → XP awarded → Streak incremented
- [ ] Earn achievement → Notification shown → Gems awarded
- [ ] Review cards → Rate difficulty → Next review scheduled
- [ ] Change settings → Theme applies → Notifications schedule
- [ ] All errors show user feedback (not silent failures)
- [ ] All async operations show loading states
- [ ] App works offline (cached lessons)
- [ ] Data persists after app restart

---

**Next Action:** Start with Critical Fix #1 (Onboarding Flow)
