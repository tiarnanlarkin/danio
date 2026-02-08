# Wave 3 - Quick Start Guide

**Get up and running in 30 minutes!**

---

## 🎯 Goal

Get Wave 3 features integrated and see them working in your app in the shortest time possible.

---

## ⚡ 30-Minute Fast Track

### Minute 0-5: See It Working

```bash
# 1. Navigate to your app directory
cd /path/to/aquarium_app

# 2. Ensure dependencies are installed
flutter pub get

# 3. Run the app
flutter run
```

**In your app:**
```dart
// Navigate to demo screen (temporary for testing)
import 'package:aquarium_app/examples/wave3_demo_screen.dart';

// Add this to any button or menu:
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Wave3DemoScreen()),
  );
}
```

**✅ Checkpoint:** You can now see all 6 features working!

---

### Minute 5-10: Run Tests

```bash
# Run all Wave 3 tests
flutter test test/services/difficulty_service_test.dart
flutter test test/services/achievement_service_test.dart
flutter test test/hearts_system_test.dart
flutter test test/models/spaced_repetition_test.dart

# Expected: All tests passing ✅
```

**✅ Checkpoint:** Tests confirm features work correctly.

---

### Minute 10-15: Understand the Architecture

```
Wave 3 Features:
├── 1. Adaptive Difficulty
│   ├── Models: DifficultyLevel, PerformanceRecord, UserSkillProfile
│   ├── Service: DifficultyService
│   └── Widgets: DifficultyBadge, SkillLevelIndicator
│
├── 2. Achievements
│   ├── Models: Achievement, AchievementProgress
│   ├── Provider: AchievementChecker
│   └── Widgets: AchievementCard, AchievementNotification
│
├── 3. Hearts System
│   ├── Models: UserProfile (extensions)
│   ├── Provider: UserProfileProvider (methods)
│   └── Widgets: HeartsDisplay
│
├── 4. Spaced Repetition
│   ├── Models: ReviewCard, ReviewInterval
│   ├── Provider: SpacedRepetitionProvider
│   └── Screen: SpacedRepetitionPracticeScreen
│
├── 5. Analytics
│   ├── Models: DailyStats, WeeklyStats
│   ├── Service: AnalyticsService
│   └── Screen: AnalyticsScreen
│
└── 6. Social/Friends
    ├── Models: Friend, FriendActivity
    ├── Provider: FriendsProvider
    └── Screens: FriendsScreen, FriendComparisonScreen
```

**✅ Checkpoint:** You understand how Wave 3 is organized.

---

### Minute 15-25: Integrate ONE Feature

**Choose the easiest: Achievements** (takes ~15 minutes)

#### Step 1: Check achievement after lesson (5 min)
```dart
// In your lesson completion handler:
import 'package:aquarium_app/providers/achievement_provider.dart';
import 'package:aquarium_app/widgets/achievement_notification.dart';

Future<void> _onLessonCompleted() async {
  // Update your profile first
  userProfile = userProfile.copyWith(
    lessonsCompleted: userProfile.lessonsCompleted + 1,
    xp: userProfile.xp + 10,
  );
  
  // Check for achievements
  final achievementChecker = ref.read(achievementCheckerProvider);
  final results = await achievementChecker.checkAfterLesson(
    lessonsCompleted: userProfile.lessonsCompleted,
    currentStreak: userProfile.currentStreak,
    totalXp: userProfile.xp,
    perfectScores: userProfile.perfectScores ?? 0,
    lessonCompletedAt: DateTime.now(),
    lessonDuration: 300,
    lessonScore: 0.8,
    todayLessonsCompleted: 1,
    completedLessonIds: userProfile.completedLessons,
  );
  
  // Show notifications
  for (final result in results.where((r) => r.wasJustUnlocked)) {
    if (mounted) {
      await AchievementNotification.show(
        context,
        result.achievement,
        result.xpAwarded,
      );
    }
  }
}
```

#### Step 2: Add achievements screen navigation (5 min)
```dart
// In your settings or menu:
ListTile(
  leading: const Icon(Icons.emoji_events),
  title: const Text('Achievements'),
  subtitle: const Text('View your trophy case'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.pushNamed(context, 'achievements');
    // Or if not using named routes:
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => AchievementsScreen(),
    // ));
  },
)
```

#### Step 3: Test it! (5 min)
```dart
// Complete a lesson and check:
// 1. Achievement notification appears
// 2. Achievement screen shows unlocked achievement
// 3. XP is awarded
```

**✅ Checkpoint:** You have ONE feature working end-to-end!

---

### Minute 25-30: Plan Full Integration

Create your integration timeline:

```markdown
## My Wave 3 Integration Plan

### Week 1: Easy Wins (4-5 hours)
- [ ] Achievements (1-2h) ✅ DONE
- [ ] Analytics (2-3h)

### Week 2: Core Features (9-10 hours)
- [ ] Adaptive Difficulty (2-3h)
- [ ] Hearts System (3-4h)
- [ ] Spaced Repetition (4-6h)

### Week 3: Social (2-3 hours)
- [ ] Friends features (2-3h)

### Week 4: Testing & Deployment (5-6 hours)
- [ ] Full testing (3-4h)
- [ ] Migration setup (1h)
- [ ] Production deployment (1-2h)

Total: ~20-24 hours over 4 weeks
```

**✅ Checkpoint:** You have a clear roadmap!

---

## 🎯 What You Accomplished in 30 Minutes

1. ✅ Saw all 6 features working in the demo
2. ✅ Ran tests to verify functionality
3. ✅ Understood the architecture
4. ✅ Integrated your first feature (Achievements)
5. ✅ Created your integration plan

---

## 📖 Next Steps

### Tomorrow: Continue Integration
Start with **[WAVE3_INTEGRATION_GUIDE.md](WAVE3_INTEGRATION_GUIDE.md)** and follow step-by-step for each feature.

### This Week: Complete Core Features
- Adaptive Difficulty
- Hearts System
- Analytics

### Next Week: Advanced Features
- Spaced Repetition
- Social/Friends

### Throughout: Reference API Docs
Use **[WAVE3_API_DOCUMENTATION.md](WAVE3_API_DOCUMENTATION.md)** whenever you need to look up a method or parameter.

---

## 🚨 Common First-Time Issues

### Issue: "Package not found"
```bash
# Solution: Install dependencies
flutter pub get
```

### Issue: "Provider not found"
```dart
// Solution: Wrap app with ProviderScope
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Issue: "Achievement not unlocking"
```dart
// Solution: Update profile BEFORE checking
userProfile = userProfile.copyWith(
  lessonsCompleted: userProfile.lessonsCompleted + 1,
);
await saveProfile();  // Save first!

// THEN check achievements
final results = await achievementChecker.checkAfterLesson(/* ... */);
```

### Issue: "Demo screen not found"
```dart
// Solution: Import correctly
import 'package:aquarium_app/examples/wave3_demo_screen.dart';
// Not: import 'package:aquarium_app/lib/examples/...' ❌
```

---

## 🎓 Learning Path

### Beginner (Never used these patterns)
1. Start with demo screen
2. Read WAVE3_SUMMARY.md
3. Integrate Achievements first (easiest)
4. Learn patterns, then continue

### Intermediate (Familiar with Flutter/Riverpod)
1. Quick demo review
2. Read integration guide
3. Integrate 2-3 features per week
4. Reference API docs as needed

### Advanced (Want to customize)
1. Skim docs
2. Review models and services
3. Customize to your needs
4. Extend features

---

## 📊 30-Minute Success Checklist

After 30 minutes, you should have:

```markdown
- [✓] Seen Wave3DemoScreen working
- [✓] Run tests successfully
- [✓] Understood architecture
- [✓] Integrated Achievements feature
- [✓] Created integration timeline
- [ ] Read WAVE3_INTEGRATION_GUIDE.md (optional - save for later)
- [ ] Completed all 6 features (next 2-3 weeks)
```

---

## 🎉 Congratulations!

You've completed the Quick Start! You now have:
- ✅ Working demo
- ✅ First feature integrated
- ✅ Clear path forward
- ✅ All documentation at hand

**Continue with [WAVE3_INTEGRATION_GUIDE.md](WAVE3_INTEGRATION_GUIDE.md) to integrate the remaining features.**

---

## 🔥 Pro Tips

### Tip 1: Start with Easiest Features
```
Easiest → Hardest:
1. Achievements (1-2h)
2. Analytics (2-3h)
3. Adaptive Difficulty (2-3h)
4. Social/Friends (2-3h)
5. Hearts System (3-4h)
6. Spaced Repetition (4-6h)
```

### Tip 2: Test as You Go
Don't wait until the end. Test each feature immediately after integration.

### Tip 3: Use the Demo as Reference
Whenever stuck, check how `wave3_demo_screen.dart` implements it.

### Tip 4: Copy-Paste First, Customize Later
Get it working with provided code first. Customize once you understand it.

### Tip 5: Don't Skip the Backup
**ALWAYS** backup before migration. The migration service does this automatically, but better safe than sorry!

---

## 📱 Quick Command Reference

```bash
# Run demo
flutter run

# Run tests
flutter test

# Generate coverage
flutter test --coverage

# Build release
flutter build apk --release

# Check for issues
flutter analyze
```

---

## 🎯 Your Next 7 Days

### Day 1 (Today): ✅ Quick Start Complete
- Ran demo
- Integrated Achievements

### Day 2: Integrate Analytics
- 2-3 hours
- Follow WAVE3_INTEGRATION_GUIDE.md section 5

### Day 3: Integrate Adaptive Difficulty
- 2-3 hours
- Follow WAVE3_INTEGRATION_GUIDE.md section 1

### Day 4-5: Integrate Hearts System
- 3-4 hours
- Follow WAVE3_INTEGRATION_GUIDE.md section 3

### Day 6-7: Testing
- Run all tests
- Manual testing
- Fix any issues

**Week 2:** Spaced Repetition + Social features
**Week 3:** Final testing + deployment

---

## 💡 Final Thought

> "The best time to integrate Wave 3 was yesterday. The second best time is now."

You've already started. Keep going! 🚀

---

**Questions? Check the full docs:**
- [WAVE3_SUMMARY.md](WAVE3_SUMMARY.md) - Overview
- [WAVE3_INTEGRATION_GUIDE.md](WAVE3_INTEGRATION_GUIDE.md) - Complete guide
- [WAVE3_API_DOCUMENTATION.md](WAVE3_API_DOCUMENTATION.md) - API reference
- [WAVE3_TESTING_GUIDE.md](WAVE3_TESTING_GUIDE.md) - Testing help

**Happy coding! 🎉**
