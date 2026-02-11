# Gamification Integration Roadmap

**Created:** 2025-01-24  
**Status:** Active  
**Owner:** Development Team  
**Priority:** HIGH - 95% implemented, only 25% integrated

---

## Executive Summary

The Aquarium App has **exceptional gamification systems** (XP, hearts, streaks, gems, daily goals, leaderboards, shop) that are 95% implemented but only 25% integrated. This roadmap provides a **phased, actionable plan** to wire all gamification into the app's 85 screens.

**Critical Issue:** Gem earning NEVER triggers automatically despite complete implementation.

**Current State:**
- ✅ All systems built and polished
- ⚠️ Only 5/85 screens award XP
- ❌ Gems defined but never awarded
- ❌ Shop items purchasable but don't function
- ❌ Achievements system incomplete

**Target State:** Full integration across all 85 screens with automated reward triggers.

---

## Table of Contents

1. [Phase 1: Critical Gem Earning Integration](#phase-1-critical-gem-earning-integration) (P0 - 8 hours)
2. [Phase 2: Expand XP Integration](#phase-2-expand-xp-integration) (P0 - 16 hours)
3. [Phase 3: Home Screen Gamification Dashboard](#phase-3-home-screen-gamification-dashboard) (P0 - 6 hours)
4. [Phase 4: Shop Item Effects - Consumables](#phase-4-shop-item-effects---consumables) (P1 - 20 hours)
5. [Phase 5: Shop Item Effects - Cosmetics](#phase-5-shop-item-effects---cosmetics) (P1 - 12 hours)
6. [Phase 6: Achievements System](#phase-6-achievements-system) (P1 - 16 hours)
7. [Phase 7: UX Enhancements](#phase-7-ux-enhancements) (P2 - 12 hours)
8. [Testing Checklist](#testing-checklist)
9. [Time Estimates Summary](#time-estimates-summary)

---

## Phase 1: Critical Gem Earning Integration

**Priority:** P0 (CRITICAL)  
**Estimated Time:** 8 hours  
**Sprint:** 1 (Week 1)

### Problem
All gem rewards are **defined** in `GemRewards` class but **never triggered automatically**. Users can purchase items but cannot earn gems through gameplay.

### Gem Reward Triggers Needed

| Event | Gems | Current Status | File to Modify |
|-------|------|----------------|----------------|
| Lesson complete | 5 | ❌ Not triggered | `lesson_screen.dart` |
| Quiz pass | 3 | ❌ Not triggered | `enhanced_quiz_screen.dart` |
| Quiz perfect (100%) | 5 | ❌ Not triggered | `enhanced_quiz_screen.dart` |
| Daily goal met | 5 | ❌ Not triggered | `user_profile_provider.dart` |
| Streak milestone (7d) | 10 | ❌ Not triggered | `user_profile_provider.dart` |
| Streak milestone (30d) | 25 | ❌ Not triggered | `user_profile_provider.dart` |
| Streak milestone (100d) | 100 | ❌ Not triggered | `user_profile_provider.dart` |
| Level up (default) | 10 | ❌ Not triggered | `user_profile_provider.dart` |
| Reach Expert (L5) | 50 | ❌ Not triggered | `user_profile_provider.dart` |
| Reach Master (L6) | 100 | ❌ Not triggered | `user_profile_provider.dart` |
| Reach Guru (L7) | 200 | ❌ Not triggered | `user_profile_provider.dart` |
| Placement test | 10 | ❌ Not triggered | `placement_test_screen.dart` |
| Weekly active (5+ days) | 10 | ❌ Not implemented | New logic needed |
| Perfect week (7/7 days) | 25 | ❌ Not implemented | New logic needed |

### Implementation Steps

#### 1.1 Lesson Completion Gems (2 hours)
**File:** `lib/screens/lesson_screen.dart`

**Current Code Location:** Search for lesson completion handler (likely in `_completeLesson()` or similar)

**Add After XP Award:**
```dart
// After: await ref.read(userProfileProvider.notifier).recordActivity();
// Add:
await ref.read(gemsProvider.notifier).addGems(
  amount: GemRewards.lessonComplete,
  source: 'lesson_complete',
  description: 'Completed ${widget.lesson.title}',
);
```

**Testing:**
- Complete a lesson
- Verify gem balance increases by 5
- Check transaction history shows correct source
- Verify gems persist after app restart

---

#### 1.2 Quiz Completion Gems (2 hours)
**File:** `lib/screens/enhanced_quiz_screen.dart`

**Current Code Location:** Quiz completion handler (likely in quiz results processing)

**Add After Score Calculation:**
```dart
// Determine gem reward based on score
final gemReward = score == 100 
    ? GemRewards.quizPerfect 
    : (score >= 60 ? GemRewards.quizPass : 0);

if (gemReward > 0) {
  await ref.read(gemsProvider.notifier).addGems(
    amount: gemReward,
    source: score == 100 ? 'quiz_perfect' : 'quiz_pass',
    description: 'Scored $score% on ${widget.quizTitle}',
  );
}
```

**Testing:**
- Complete quiz with 60-99% → 3 gems
- Complete quiz with 100% → 5 gems
- Complete quiz with <60% → 0 gems
- Verify transaction history

---

#### 1.3 Daily Goal & Streak Gems (3 hours)
**File:** `lib/providers/user_profile_provider.dart`

**Current Code Location:** `recordActivity()` method, after daily goal/streak calculation

**Add to `recordActivity()` method:**
```dart
// After streak and daily goal updates
// Check if daily goal just completed
if (todayXp >= current.dailyXpGoal && todayXp - xp < current.dailyXpGoal) {
  // Daily goal just met!
  await ref.read(gemsProvider.notifier).addGems(
    amount: GemRewards.dailyGoalMet,
    source: 'daily_goal_met',
    description: 'Met daily goal of ${current.dailyXpGoal} XP',
  );
}

// Check for streak milestones
final milestoneReward = GemRewards.getStreakMilestoneReward(currentStreak);
if (milestoneReward > 0) {
  final prevStreak = currentStreak - 1;
  final prevMilestone = GemRewards.getStreakMilestoneReward(prevStreak);
  
  // Only award if this is a NEW milestone
  if (milestoneReward != prevMilestone) {
    await ref.read(gemsProvider.notifier).addGems(
      amount: milestoneReward,
      source: 'streak_milestone',
      description: '$currentStreak day streak!',
    );
  }
}
```

**Testing:**
- Meet daily goal → +5 gems
- Reach 7-day streak → +10 gems
- Reach 30-day streak → +25 gems
- Verify no duplicate rewards on same day

---

#### 1.4 Level Up Gems (1 hour)
**File:** `lib/providers/user_profile_provider.dart`

**Current Code Location:** `addXp()` method, after level calculation

**Add After Level Update:**
```dart
// If level increased
if (newLevel > currentLevel) {
  final gemReward = GemRewards.getLevelUpReward(newLevel);
  await ref.read(gemsProvider.notifier).addGems(
    amount: gemReward,
    source: 'level_up',
    description: 'Reached ${UserProfile.levels[newLevel]}!',
  );
}
```

**Testing:**
- Level up from 1→2 → +10 gems
- Level up to Expert (5) → +50 gems
- Level up to Master (6) → +100 gems
- Level up to Guru (7) → +200 gems

---

### Phase 1 Success Criteria
- ✅ Gems awarded on lesson completion
- ✅ Gems awarded on quiz pass/perfect
- ✅ Gems awarded on daily goal completion
- ✅ Gems awarded on streak milestones
- ✅ Gems awarded on level ups
- ✅ All transactions appear in history
- ✅ Gems persist after app restart
- ✅ No duplicate rewards for same event

---

## Phase 2: Expand XP Integration

**Priority:** P0 (HIGH)  
**Estimated Time:** 16 hours  
**Sprint:** 1-2 (Week 1-2)

### Problem
Only 5 of 85 screens award XP. Core hobby activities (tank maintenance, water testing, logging) are ignored despite having defined XP rewards.

### XP Rewards Already Defined (In `XpRewards` class)
```dart
static const int lessonComplete = 50;    // ✅ Integrated
static const int quizPass = 25;          // ✅ Integrated  
static const int quizPerfect = 50;       // ✅ Integrated
static const int waterTest = 10;         // ❌ NOT integrated
static const int waterChange = 10;       // ❌ NOT integrated
static const int taskComplete = 15;      // ❌ NOT integrated
static const int dailyStreak = 25;       // ✅ Integrated
static const int addLivestock = 5;       // ⚠️ PARTIALLY integrated
static const int addPhoto = 5;           // ❌ NOT integrated
static const int journalEntry = 10;      // ❌ NOT integrated
```

### Screens Requiring XP Integration (Priority Order)

#### P0 - Critical Hobby Activities (8 screens, 8 hours)

| # | Screen | XP Reward | Trigger Event | Est. Time |
|---|--------|-----------|---------------|-----------|
| 1 | `add_log_screen.dart` | 10 XP | Water test logged | ✅ DONE (already has) |
| 2 | `tasks_screen.dart` | 15 XP | Task marked complete | 1h |
| 3 | `maintenance_checklist_screen.dart` | 30 XP | Checklist completed | 1h |
| 4 | `journal_screen.dart` | 10 XP | Journal entry created | 1h |
| 5 | `photo_gallery_screen.dart` | 5 XP | Photo uploaded | 1h |
| 6 | `create_tank_screen.dart` | 100 XP | First tank created | 1h |
| 7 | `livestock_screen.dart` | 5 XP/item | Fish/plant added | ✅ DONE (already has) |
| 8 | `equipment_screen.dart` | 15 XP | Equipment added | 1h |

#### P1 - Onboarding & Engagement (6 screens, 4 hours)

| # | Screen | XP Reward | Trigger Event | Est. Time |
|---|--------|-----------|---------------|-----------|
| 9 | `profile_creation_screen.dart` | 50 XP | Profile completed | 30m |
| 10 | `first_tank_wizard_screen.dart` | 100 XP | Wizard completed | 30m |
| 11 | `enhanced_placement_test_screen.dart` | 100 XP | Test completed | 30m |
| 12 | `enhanced_tutorial_walkthrough_screen.dart` | 25 XP | Tutorial completed | 30m |
| 13 | `activity_feed_screen.dart` | 5 XP | Share activity | 1h |
| 14 | `friends_screen.dart` | 25 XP | First friend added | 1h |

#### P2 - Secondary Activities (10 screens, 4 hours)

| # | Screen | XP Reward | Trigger Event | Est. Time |
|---|--------|-----------|---------------|-----------|
| 15 | `reminders_screen.dart` | 5 XP | Reminder completed | 30m |
| 16 | `wishlist_screen.dart` | 5 XP | Item added to wishlist | 20m |
| 17 | `cost_tracker_screen.dart` | 10 XP | Expense logged | 20m |
| 18 | `backup_restore_screen.dart` | 25 XP | First backup created | 20m |
| 19 | `charts_screen.dart` | 5 XP | View water parameter trends | 20m |
| 20 | `compatibility_checker_screen.dart` | 10 XP | Compatibility check run | 30m |
| 21 | `stocking_calculator_screen.dart` | 10 XP | Stocking plan created | 30m |
| 22 | `species_browser_screen.dart` | 5 XP | First species favorited | 30m |
| 23 | `plant_browser_screen.dart` | 5 XP | First plant favorited | 30m |
| 24 | `glossary_screen.dart` | 2 XP | Term learned (first view) | 30m |

### Implementation Template

**Standard Pattern for All Screens:**
```dart
// After successful action completion:
await ref.read(userProfileProvider.notifier).recordActivity(
  xp: XpRewards.[rewardType],
);

// Show XP animation (if not already shown)
if (mounted) {
  // Trigger XP animation overlay or snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('+${XpRewards.[rewardType]} XP'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}
```

### Specific Implementation Examples

#### 2.1 Tasks Screen (1 hour)
**File:** `lib/screens/tasks_screen.dart`

**Location:** Task completion handler (checkbox tap or complete button)

```dart
Future<void> _completeTask(Task task) async {
  // Mark task complete (existing code)
  await taskRepository.completeTask(task.id);
  
  // Award XP
  await ref.read(userProfileProvider.notifier).recordActivity(
    xp: XpRewards.taskComplete,
  );
  
  // Show feedback
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task completed! +${XpRewards.taskComplete} XP'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

---

#### 2.2 Maintenance Checklist (1 hour)
**File:** `lib/screens/maintenance_checklist_screen.dart`

**Location:** When ALL checklist items are marked complete

```dart
Future<void> _checkCompletion() async {
  final allComplete = checklist.every((item) => item.isComplete);
  
  if (allComplete && !hasAwardedXP) {
    await ref.read(userProfileProvider.notifier).recordActivity(
      xp: 30, // Checklist completion bonus
    );
    
    setState(() {
      hasAwardedXP = true;
    });
    
    // Show celebration
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🎉 Checklist Complete!'),
          content: const Text('+30 XP\n\nGreat job maintaining your tank!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Awesome!'),
            ),
          ],
        ),
      );
    }
  }
}
```

---

#### 2.3 Journal Entry (1 hour)
**File:** `lib/screens/journal_screen.dart`

**Location:** After journal entry is saved

```dart
Future<void> _saveEntry() async {
  // Save entry (existing code)
  await journalRepository.save(entry);
  
  // Award XP
  await ref.read(userProfileProvider.notifier).recordActivity(
    xp: XpRewards.journalEntry,
  );
  
  if (mounted) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entry saved! +${XpRewards.journalEntry} XP'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

---

#### 2.4 Photo Upload (1 hour)
**File:** `lib/screens/photo_gallery_screen.dart`

**Location:** After photo is successfully uploaded

```dart
Future<void> _uploadPhoto(File image) async {
  // Upload photo (existing code)
  await photoRepository.upload(image);
  
  // Award XP (only once per day to prevent spam)
  final today = DateTime.now().toIso8601String().split('T')[0];
  final lastPhotoXpDate = prefs.getString('last_photo_xp_date');
  
  if (lastPhotoXpDate != today) {
    await ref.read(userProfileProvider.notifier).recordActivity(
      xp: XpRewards.addPhoto,
    );
    await prefs.setString('last_photo_xp_date', today);
  }
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo uploaded! +5 XP'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

---

#### 2.5 First Tank Creation (1 hour)
**File:** `lib/screens/create_tank_screen.dart`

**Location:** After tank is created (check if first tank)

```dart
Future<void> _createTank() async {
  // Create tank (existing code)
  await tankRepository.create(tank);
  
  // Check if first tank
  final allTanks = await tankRepository.getAll();
  if (allTanks.length == 1) {
    // First tank bonus!
    await ref.read(userProfileProvider.notifier).recordActivity(
      xp: 100,
    );
    
    // Show celebration dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🎉 First Tank Created!'),
          content: const Text('+100 XP\n\nYour aquarium journey begins!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Let\'s Go!'),
            ),
          ],
        ),
      );
    }
  }
}
```

---

#### 2.6 Equipment Added (1 hour)
**File:** `lib/screens/equipment_screen.dart`

**Location:** After equipment item is added

```dart
Future<void> _addEquipment(Equipment equipment) async {
  // Add equipment (existing code)
  await equipmentRepository.add(equipment);
  
  // Award XP
  await ref.read(userProfileProvider.notifier).recordActivity(
    xp: XpRewards.taskComplete, // 15 XP for equipment added
  );
  
  if (mounted) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Equipment added! +15 XP'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

---

### Additional XP Rewards to Define

**Add to `XpRewards` class:**
```dart
class XpRewards {
  // Existing rewards...
  
  // Onboarding (NEW)
  static const int profileComplete = 50;
  static const int firstTankWizard = 100;
  static const int placementTestComplete = 100;
  static const int tutorialComplete = 25;
  
  // Social (NEW)
  static const int firstFriend = 25;
  static const int shareActivity = 5;
  
  // Tools (NEW)
  static const int useCalculator = 10;
  static const int checkCompatibility = 10;
  static const int createStockingPlan = 10;
  
  // Engagement (NEW)
  static const int favoriteSpe cies = 5;
  static const int logExpense = 10;
  static const int createBackup = 25;
  static const int completeReminder = 5;
}
```

---

### Phase 2 Success Criteria
- ✅ All P0 screens (8) award XP on key actions
- ✅ All P1 screens (6) award XP on key actions
- ✅ XP animations/feedback shown to users
- ✅ XP rewards feel balanced (not too easy/hard)
- ✅ No duplicate XP for same action (daily limits where needed)
- ✅ XP contributes to daily goal and streaks
- ✅ Level progression feels natural

---

## Phase 3: Home Screen Gamification Dashboard

**Priority:** P0 (HIGH)  
**Estimated Time:** 6 hours  
**Sprint:** 2 (Week 2)

### Problem
Gamification stats (XP, gems, streaks) are hidden in dialogs and sub-screens. Users don't see their progress prominently.

### Current Home Screen
- ✅ Hearts indicator in app bar
- ❌ No XP progress visible
- ❌ No gem balance visible
- ❌ No streak display
- ❌ Daily goal only in separate screen

### Target Home Screen Layout

```
┌─────────────────────────────────────┐
│  Home                    ❤️❤️❤️🖤🖤  │ ← Hearts (existing)
├─────────────────────────────────────┤
│                                     │
│  Gamification Dashboard Card        │
│  ┌─────────────────────────────┐  │
│  │  Level 4: Aquarist          │  │
│  │  [=========>    ] 450/700 XP│  │ ← XP Progress
│  │                             │  │
│  │  💎 125 gems   🔥 12 days   │  │ ← Gems & Streak
│  │                             │  │
│  │  Daily Goal: [====] 35/50 XP│  │ ← Daily Goal
│  └─────────────────────────────┘  │
│                                     │
│  [Your Tanks]                       │
│  ...                                │
└─────────────────────────────────────┘
```

### Implementation Steps

#### 3.1 Create Gamification Summary Widget (3 hours)
**New File:** `lib/widgets/gamification_summary_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../providers/gems_provider.dart';
import '../models/user_profile.dart';
import 'xp_progress_bar.dart';
import 'streak_display.dart';
import 'daily_goal_progress.dart';

class GamificationSummaryCard extends ConsumerWidget {
  const GamificationSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final gemsAsync = ref.watch(gemsProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level & XP Progress
                Text(
                  'Level ${profile.level}: ${UserProfile.levels[profile.level]}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                XpProgressBar(
                  currentXp: profile.xp,
                  currentLevel: profile.level,
                  showLabel: true,
                  height: 12,
                ),
                
                const SizedBox(height: 20),
                
                // Gems & Streak Row
                Row(
                  children: [
                    // Gems
                    Expanded(
                      child: _StatChip(
                        icon: '💎',
                        label: 'Gems',
                        value: gemsAsync.value?.balance.toString() ?? '0',
                        onTap: () {
                          // Navigate to gem shop
                          Navigator.pushNamed(context, '/gem-shop');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Streak
                    Expanded(
                      child: _StatChip(
                        icon: '🔥',
                        label: 'Streak',
                        value: '${profile.currentStreak} days',
                        onTap: () {
                          // Navigate to streak calendar
                          Navigator.pushNamed(context, '/streak-calendar');
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Daily Goal
                DailyGoalCard(
                  goal: profile.dailyGoal,
                  compact: true,
                  onTap: () {
                    // Navigate to learn screen
                    Navigator.pushNamed(context, '/learn');
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 3.2 Add to Home Screen (1 hour)
**File:** `lib/screens/home_screen.dart`

**Location:** After app bar, before tank list

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      // Existing app bar with hearts
      title: const Text('Home'),
      actions: [
        const HeartIndicator(), // Existing
        // ... other actions
      ],
    ),
    body: ListView(
      children: [
        // NEW: Gamification summary at top
        const GamificationSummaryCard(),
        
        // Existing content
        _buildTanksList(),
        // ...
      ],
    ),
  );
}
```

#### 3.3 Add Gems Indicator to App Bar (2 hours)
**File:** `lib/widgets/gems_indicator.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gems_provider.dart';

class GemsIndicator extends ConsumerWidget {
  final bool compact;

  const GemsIndicator({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gemsAsync = ref.watch(gemsProvider);

    return gemsAsync.when(
      data: (state) {
        if (state == null) return const SizedBox.shrink();

        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/gem-shop');
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F).withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4FC3F7),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '💎',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  state.balance.toString(),
                  style: const TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(width: 60, height: 32),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

**Add to multiple screens:**
- `home_screen.dart`
- `learn_screen.dart`
- `leaderboard_screen.dart`
- Any screen where users should see gem balance

```dart
AppBar(
  title: const Text('Home'),
  actions: [
    const GemsIndicator(compact: true), // NEW
    const SizedBox(width: 8),
    const HeartIndicator(), // Existing
    const SizedBox(width: 8),
  ],
),
```

### Phase 3 Success Criteria
- ✅ Home screen shows gamification summary card
- ✅ XP progress bar visible and animated
- ✅ Gem balance displayed with icon
- ✅ Streak count and fire emoji shown
- ✅ Daily goal progress visible
- ✅ All elements tappable (navigate to detail screens)
- ✅ Gem indicator in app bars of key screens
- ✅ Visual design matches app theme

---

## Phase 4: Shop Item Effects - Consumables

**Priority:** P1 (MEDIUM-HIGH)  
**Estimated Time:** 20 hours  
**Sprint:** 3-4 (Week 3-4)

### Problem
Users can purchase 20 shop items but NONE of them actually function. Items are added to inventory but have no effect on gameplay.

### Consumable Items to Implement (10 items)

| Item | Cost | Effect | Files to Modify | Est. Time |
|------|------|--------|-----------------|-----------|
| Timer Boost | 5💎 | +30s on timed lessons | `lesson_screen.dart` | 2h |
| 2x XP Boost | 25💎 | 2x XP for 1 hour | `user_profile_provider.dart` | 3h |
| Lesson Helper | 15💎 | Show hints during lesson | `lesson_screen.dart` | 3h |
| Quiz Second Chance | 20💎 | Retry wrong answers | `enhanced_quiz_screen.dart` | 3h |
| Streak Freeze | 10💎 | Skip 1 missed day | `user_profile_provider.dart` | 2h |
| Weekend Amulet | 20💎 | Weekends don't break streak | `user_profile_provider.dart` | 2h |
| Hearts Refill | 30💎 | Restore all hearts | `hearts_service.dart` | 1h |
| Goal Shield | 35💎 | Auto-complete daily goal | `user_profile_provider.dart` | 2h |
| Progress Protector | 40💎 | No penalties for wrong answers | `lesson_screen.dart` | 2h |

### Implementation Strategy

#### 4.1 Active Boosts Tracking System (3 hours)
**File:** `lib/models/active_boost.dart` (NEW)

```dart
class ActiveBoost {
  final String itemId;
  final ShopItemType type;
  final DateTime activatedAt;
  final DateTime expiresAt;
  final Map<String, dynamic> metadata;

  ActiveBoost({
    required this.itemId,
    required this.type,
    required this.activatedAt,
    required this.expiresAt,
    this.metadata = const {},
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isExpired;

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'type': type.toString(),
    'activatedAt': activatedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'metadata': metadata,
  };

  factory ActiveBoost.fromJson(Map<String, dynamic> json) => ActiveBoost(
    itemId: json['itemId'],
    type: ShopItemType.values.firstWhere(
      (t) => t.toString() == json['type'],
    ),
    activatedAt: DateTime.parse(json['activatedAt']),
    expiresAt: DateTime.parse(json['expiresAt']),
    metadata: json['metadata'] ?? {},
  );
}
```

**File:** `lib/providers/boosts_provider.dart` (NEW)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/active_boost.dart';
import '../models/shop_item.dart';

final boostsProvider = StateNotifierProvider<BoostsNotifier, List<ActiveBoost>>((ref) {
  return BoostsNotifier();
});

class BoostsNotifier extends StateNotifier<List<ActiveBoost>> {
  BoostsNotifier() : super([]) {
    _load();
  }

  static const _key = 'active_boosts';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getStringList(_key) ?? [];
    
    final boosts = json
        .map((s) => ActiveBoost.fromJson(jsonDecode(s)))
        .where((b) => b.isActive) // Filter expired
        .toList();
    
    state = boosts;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = state.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(_key, json);
  }

  /// Activate a consumable item
  Future<void> activateBoost({
    required String itemId,
    required ShopItemType type,
    required int durationHours,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();
    final boost = ActiveBoost(
      itemId: itemId,
      type: type,
      activatedAt: now,
      expiresAt: now.add(Duration(hours: durationHours)),
      metadata: metadata ?? {},
    );

    state = [...state, boost];
    await _save();
  }

  /// Check if a specific boost type is active
  bool isBoostActive(ShopItemType type) {
    return state.any((b) => b.type == type && b.isActive);
  }

  /// Get active boost of a specific type
  ActiveBoost? getActiveBoost(ShopItemType type) {
    try {
      return state.firstWhere((b) => b.type == type && b.isActive);
    } catch (_) {
      return null;
    }
  }

  /// Remove expired boosts
  Future<void> cleanExpired() async {
    final activeBoosts = state.where((b) => b.isActive).toList();
    if (activeBoosts.length != state.length) {
      state = activeBoosts;
      await _save();
    }
  }

  /// Consume a one-time boost (remove after use)
  Future<void> consumeBoost(String itemId) async {
    state = state.where((b) => b.itemId != itemId).toList();
    await _save();
  }
}
```

---

#### 4.2 XP Boost Implementation (3 hours)
**File:** `lib/providers/user_profile_provider.dart`

**Modify `recordActivity()` method:**

```dart
Future<void> recordActivity({int xp = 0}) async {
  var current = state.value;
  if (current == null) return;

  // Check for 2x XP boost
  final boosts = ref.read(boostsProvider);
  final xpBoost = boosts.firstWhere(
    (b) => b.type == ShopItemType.xpBoost && b.isActive,
    orElse: () => null,
  );

  int finalXp = xp;
  if (xpBoost != null) {
    finalXp = xp * 2; // Double XP!
  }

  // Continue with existing logic using finalXp...
  await addXp(finalXp);
  
  // ... rest of method
}
```

**File:** `lib/screens/gem_shop_screen.dart`

**Modify purchase handler:**

```dart
Future<void> _purchaseItem(ShopItem item) async {
  // Existing purchase logic...
  await shopService.purchaseItem(item.id);
  
  // If XP boost, activate it
  if (item.type == ShopItemType.xpBoost) {
    await ref.read(boostsProvider.notifier).activateBoost(
      itemId: item.id,
      type: item.type,
      durationHours: item.durationHours ?? 1,
    );
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚡ 2x XP Boost Activated!'),
          content: Text(
            'You\'ll earn double XP for the next ${item.durationHours} hour${item.durationHours! > 1 ? "s" : ""}!\n\n'
            'Get learning now to maximize your gains!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/learn');
              },
              child: const Text('Start Learning!'),
            ),
          ],
        ),
      );
    }
  }
}
```

**Add boost indicator to UI:**

```dart
// In lesson_screen.dart, quiz_screen.dart app bars:
AppBar(
  title: const Text('Lesson'),
  actions: [
    if (_is XpBoostActive) ...[
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Text('⚡', style: TextStyle(fontSize: 14)),
            SizedBox(width: 4),
            Text(
              '2x XP',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
    ],
    const HeartIndicator(),
  ],
),
```

---

#### 4.3 Timer Boost Implementation (2 hours)
**File:** `lib/screens/lesson_screen.dart`

```dart
// Check for timer boost in inventory before starting timed lesson
Future<void> _startTimedLesson() async {
  final inventory = ref.read(userProfileProvider).value?.inventory ?? [];
  final timerBoost = inventory.firstWhere(
    (item) => item.itemId == 'timer_boost' && item.quantity > 0,
    orElse: () => null,
  );

  int baseTime = 60; // 60 seconds default
  int bonusTime = 0;

  if (timerBoost != null) {
    // Ask user if they want to use the boost
    final useBoost = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⏱️ Use Timer Boost?'),
        content: const Text(
          'Use your Timer Boost to get +30 seconds?\n\n'
          'You have ${timerBoost.quantity} remaining.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No Thanks'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Use Boost!'),
          ),
        ],
      ),
    );

    if (useBoost == true) {
      bonusTime = 30;
      // Consume the boost
      await ref.read(inventoryProvider.notifier).consumeItem('timer_boost', 1);
    }
  }

  setState(() {
    _timeRemaining = baseTime + bonusTime;
    _timerActive = true;
  });
}
```

---

#### 4.4 Lesson Hints Implementation (3 hours)
**File:** `lib/screens/lesson_screen.dart`

```dart
// Add hint system to lesson questions
bool _canShowHint() {
  final inventory = ref.read(userProfileProvider).value?.inventory ?? [];
  return inventory.any(
    (item) => item.itemId == 'lesson_hints' && item.quantity > 0,
  );
}

Future<void> _showHint() async {
  // Consume hint
  await ref.read(inventoryProvider.notifier).consumeItem('lesson_hints', 1);

  // Show hint dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('💡 Hint'),
      content: Text(_currentQuestion.hint ?? 'No hint available'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it!'),
        ),
      ],
    ),
  );
}

// Add hint button to question UI
if (_canShowHint())
  ElevatedButton.icon(
    onPressed: _showHint,
    icon: const Text('💡'),
    label: const Text('Use Hint'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.amber,
    ),
  ),
```

---

#### 4.5 Quiz Second Chance Implementation (3 hours)
**File:** `lib/screens/enhanced_quiz_screen.dart`

```dart
bool _hasSecondChance() {
  final inventory = ref.read(userProfileProvider).value?.inventory ?? [];
  return inventory.any(
    (item) => item.itemId == 'quiz_retry' && item.quantity > 0,
  );
}

Future<void> _handleWrongAnswer(int questionIndex) async {
  // Mark answer wrong
  _results[questionIndex] = false;

  // Offer second chance if available
  if (_hasSecondChance() && !_usedSecondChance[questionIndex]) {
    final retry = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎯 Second Chance?'),
        content: const Text(
          'That\'s not quite right.\n\n'
          'Use your Quiz Second Chance to try again?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retry!'),
          ),
        ],
      ),
    );

    if (retry == true) {
      // Consume second chance
      await ref.read(inventoryProvider.notifier).consumeItem('quiz_retry', 1);
      
      // Mark as used for this question
      _usedSecondChance[questionIndex] = true;
      
      // Reset question (don't mark wrong yet)
      setState(() {
        _results[questionIndex] = null;
        _selectedAnswers[questionIndex] = null;
      });
      
      return;
    }
  }

  // Lose heart if not retrying
  await ref.read(heartsActionsProvider).loseHeart();
}
```

---

#### 4.6 Streak Freeze Implementation (2 hours)
**File:** `lib/providers/user_profile_provider.dart`

**Modify streak calculation in `recordActivity()`:**

```dart
// Check if streak should break
if (daysSinceLastActivity > 1) {
  // Check for streak freeze in inventory
  final inventory = current.inventory;
  final hasStreakFreeze = inventory.any(
    (item) => item.itemId == 'streak_freeze' && item.quantity > 0,
  );

  if (hasStreakFreeze) {
    // Consume streak freeze
    await ref.read(inventoryProvider.notifier).consumeItem('streak_freeze', 1);
    
    // Don't reset streak, but show notification
    // (Streak freeze used automatically)
  } else {
    // No streak freeze - break the streak
    currentStreak = 0;
  }
}
```

---

#### 4.7 Hearts Refill Implementation (1 hour)
**File:** `lib/screens/gem_shop_screen.dart`

```dart
// In purchase handler
if (item.id == 'hearts_refill') {
  // Refill hearts immediately
  await ref.read(heartsActionsProvider).refillAllHearts();
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❤️ All hearts restored!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

---

### Phase 4 Success Criteria
- ✅ 2x XP Boost multiplies XP for 1 hour
- ✅ Timer Boost adds 30 seconds to timed lessons
- ✅ Lesson Hints show helpful tips
- ✅ Quiz Second Chance allows retries
- ✅ Streak Freeze prevents streak loss
- ✅ Hearts Refill restores all hearts
- ✅ All consumables decrease quantity when used
- ✅ Active boosts show in UI
- ✅ Boosts expire correctly
- ✅ Purchase → use → effect loop works end-to-end

---

## Phase 5: Shop Item Effects - Cosmetics

**Priority:** P1 (MEDIUM)  
**Estimated Time:** 12 hours  
**Sprint:** 5 (Week 5)

### Cosmetic Items to Implement (10 items)

| Item | Cost | Effect | Implementation | Est. Time |
|------|------|--------|----------------|-----------|
| Early Bird Badge | 10💎 | Profile badge display | Badge system | 2h |
| Night Owl Badge | 10💎 | Profile badge display | Badge system | 30m |
| Perfectionist Badge | 25💎 | Profile badge display | Badge system | 30m |
| Confetti Celebration | 30💎 | Confetti on lesson complete | Animation | 2h |
| Fireworks Celebration | 50💎 | Fireworks on quiz perfect | Animation | 2h |
| Ocean Depths Theme | 50💎 | Blue/teal app theme | Theme system | 2h |
| Coral Reef Theme | 50💎 | Coral color theme | Theme system | 30m |
| Zen Garden Theme | 40💎 | Green/natural theme | Theme system | 30m |
| Rainbow Paradise Theme | 45💎 | Rainbow colors theme | Theme system | 30m |
| Night Mode Theme | 50💎 | Dark theme | Theme system | 30m |

### Implementation Strategy

#### 5.1 Badge Display System (3 hours)
**File:** `lib/widgets/profile_badges.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import '../models/shop_item.dart';

class ProfileBadges extends StatelessWidget {
  final List<String> ownedBadgeIds;
  final int maxDisplay;

  const ProfileBadges({
    super.key,
    required this.ownedBadgeIds,
    this.maxDisplay = 3,
  });

  @override
  Widget build(BuildContext context) {
    final badges = ownedBadgeIds.take(maxDisplay).toList();

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges.map((badgeId) {
        final badge = ShopCatalog.getById(badgeId);
        if (badge == null) return const SizedBox.shrink();

        return Tooltip(
          message: badge.name,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Text(
              badge.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

**Add to profile/leaderboard screens:**
```dart
// In user profile display
ProfileBadges(
  ownedBadgeIds: userProfile.inventory
      .where((item) => item.type == ShopItemType.profileBadge)
      .map((item) => item.itemId)
      .toList(),
),
```

---

#### 5.2 Celebration Effects System (4 hours)
**File:** `lib/widgets/celebration_effects.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // Add package

class CelebrationEffect extends StatefulWidget {
  final CelebrationType type;
  final VoidCallback? onComplete;

  const CelebrationEffect({
    super.key,
    required this.type,
    this.onComplete,
  });

  @override
  State<CelebrationEffect> createState() => _CelebrationEffectState();
}

enum CelebrationType { confetti, fireworks }

class _CelebrationEffectState extends State<CelebrationEffect> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();
    
    Future.delayed(const Duration(seconds: 3), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == CelebrationType.confetti) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      );
    } else {
      // Fireworks (more elaborate)
      return Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: -3.14 / 2, // Up
              emissionFrequency: 0.01,
              numberOfParticles: 100,
              gravity: 0.3,
              colors: const [
                Colors.red,
                Colors.yellow,
                Colors.blue,
                Colors.white,
              ],
              createParticlePath: _drawStar,
            ),
          ),
        ],
      );
    }
  }

  Path _drawStar(Size size) {
    // Draw star-shaped particles for fireworks
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
}
```

**Add to lesson/quiz completion:**
```dart
// After lesson completes
Future<void> _showCompletion() async {
  // Check for celebration effects in inventory
  final inventory = ref.read(userProfileProvider).value?.inventory ?? [];
  final hasConfetti = inventory.any((item) => item.itemId == 'celebration_confetti');
  final hasFireworks = inventory.any((item) => item.itemId == 'celebration_fireworks');

  showDialog(
    context: context,
    builder: (context) => Stack(
      children: [
        AlertDialog(
          title: const Text('🎉 Lesson Complete!'),
          content: Text('+$xpEarned XP'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
        
        // Add celebration effect if owned
        if (hasFireworks && score == 100)
          CelebrationEffect(type: CelebrationType.fireworks)
        else if (hasConfetti)
          CelebrationEffect(type: CelebrationType.confetti),
      ],
    ),
  );
}
```

---

#### 5.3 Theme System (5 hours)
**File:** `lib/themes/custom_themes.dart` (NEW)

```dart
import 'package:flutter/material.dart';

class CustomThemes {
  static final Map<String, ThemeData> themes = {
    'default': _defaultTheme,
    'theme_ocean_depth': _oceanDepthTheme,
    'theme_coral_reef': _coralReefTheme,
    'theme_freshwater_zen': _zenGardenTheme,
    'theme_rainbow': _rainbowTheme,
    'theme_night_mode': _nightModeTheme,
  };

  static ThemeData get _defaultTheme => ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
  );

  static ThemeData get _oceanDepthTheme => ThemeData(
    primaryColor: const Color(0xFF0D47A1),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0D47A1),
      secondary: Color(0xFF006064),
      surface: Color(0xFFE1F5FE),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D47A1),
    ),
  );

  static ThemeData get _coralReefTheme => ThemeData(
    primaryColor: const Color(0xFFFF6F61),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF6F61),
      secondary: Color(0xFFFFAB91),
      surface: Color(0xFFFFF3E0),
    ),
  );

  static ThemeData get _zenGardenTheme => ThemeData(
    primaryColor: const Color(0xFF388E3C),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF388E3C),
      secondary: Color(0xFF66BB6A),
      surface: Color(0xFFF1F8E9),
    ),
  );

  static ThemeData get _rainbowTheme => ThemeData(
    primaryColor: const Color(0xFFE91E63),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFE91E63),
      secondary: Color(0xFF9C27B0),
      surface: Color(0xFFFCE4EC),
    ),
  );

  static ThemeData get _nightModeTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1A237E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1A237E),
      secondary: Color(0xFF00BCD4),
      surface: Color(0xFF121212),
    ),
  );
}
```

**File:** `lib/providers/theme_provider.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/custom_themes.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(CustomThemes.themes['default']!) {
    _load();
  }

  static const _key = 'selected_theme';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeId = prefs.getString(_key) ?? 'default';
    state = CustomThemes.themes[themeId] ?? CustomThemes.themes['default']!;
  }

  Future<void> setTheme(String themeId) async {
    if (CustomThemes.themes.containsKey(themeId)) {
      state = CustomThemes.themes[themeId]!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, themeId);
    }
  }
}
```

**Apply theme in main app:**
```dart
// In main.dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      theme: theme,
      home: const HomeScreen(),
    );
  }
}
```

**Add theme selector to settings:**
```dart
// In settings_screen.dart
final ownedThemes = inventory
    .where((item) => item.type == ShopItemType.tankTheme)
    .toList();

ListTile(
  title: const Text('App Theme'),
  subtitle: const Text('Customize your app appearance'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(themeId: 'default', name: 'Default', emoji: '🌊'),
            ...ownedThemes.map((theme) => _ThemeOption(
              themeId: theme.itemId,
              name: theme.name,
              emoji: theme.emoji,
            )),
          ],
        ),
      ),
    );
  },
),
```

---

### Phase 5 Success Criteria
- ✅ Badges display on profile and leaderboard
- ✅ Confetti plays on lesson completion (if owned)
- ✅ Fireworks play on perfect quiz (if owned)
- ✅ Theme changes apply instantly
- ✅ Selected theme persists after restart
- ✅ Only owned themes are selectable
- ✅ All cosmetics visible in shop

---

## Phase 6: Achievements System

**Priority:** P1 (MEDIUM)  
**Estimated Time:** 16 hours  
**Sprint:** 6 (Week 6)

### Problem
Achievement system partially exists (gem rewards defined, achievements list in UserProfile) but NO achievements are defined or implemented.

### Achievement Categories & Definitions

#### 6.1 Define Achievements (4 hours)
**File:** `lib/models/achievements.dart` (NEW)

```dart
import 'learning.dart';

enum AchievementCategory {
  learning,
  hobby,
  social,
  milestones,
  special,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final AchievementTier tier;
  final AchievementCategory category;
  final int gemReward;
  final Map<String, dynamic> criteria; // Flexible unlock conditions

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.tier,
    required this.category,
    required this.gemReward,
    required this.criteria,
  });
}

class Achievements {
  // LEARNING ACHIEVEMENTS
  static const firstLesson = Achievement(
    id: 'first_lesson',
    name: 'First Steps',
    description: 'Complete your first lesson',
    emoji: '📚',
    tier: AchievementTier.bronze,
    category: AchievementCategory.learning,
    gemReward: 5,
    criteria: {'lessons_completed': 1},
  );

  static const lessons10 = Achievement(
    id: 'lessons_10',
    name: 'Dedicated Learner',
    description: 'Complete 10 lessons',
    emoji: '🎓',
    tier: AchievementTier.silver,
    category: AchievementCategory.learning,
    gemReward: 10,
    criteria: {'lessons_completed': 10},
  );

  static const lessons50 = Achievement(
    id: 'lessons_50',
    name: 'Knowledge Seeker',
    description: 'Complete 50 lessons',
    emoji: '📖',
    tier: AchievementTier.gold,
    category: AchievementCategory.learning,
    gemReward: 20,
    criteria: {'lessons_completed': 50},
  );

  static const perfectQuiz = Achievement(
    id: 'perfect_quiz',
    name: 'Perfectionist',
    description: 'Score 100% on a quiz',
    emoji: '💯',
    tier: AchievementTier.bronze,
    category: AchievementCategory.learning,
    gemReward: 5,
    criteria: {'perfect_quizzes': 1},
  );

  static const perfectQuiz10 = Achievement(
    id: 'perfect_quiz_10',
    name: 'Quiz Master',
    description: 'Score 100% on 10 quizzes',
    emoji: '🏆',
    tier: AchievementTier.gold,
    category: AchievementCategory.learning,
    gemReward: 20,
    criteria: {'perfect_quizzes': 10},
  );

  // HOBBY ACHIEVEMENTS
  static const firstTank = Achievement(
    id: 'first_tank',
    name: 'Tank Builder',
    description: 'Create your first tank',
    emoji: '🐠',
    tier: AchievementTier.bronze,
    category: AchievementCategory.hobby,
    gemReward: 5,
    criteria: {'tanks_created': 1},
  );

  static const waterTests10 = Achievement(
    id: 'water_tests_10',
    name: 'Water Chemist',
    description: 'Log 10 water tests',
    emoji: '🧪',
    tier: AchievementTier.silver,
    category: AchievementCategory.hobby,
    gemReward: 10,
    criteria: {'water_tests': 10},
  );

  static const maintenanceTasks25 = Achievement(
    id: 'maintenance_25',
    name: 'Tank Maintainer',
    description: 'Complete 25 maintenance tasks',
    emoji: '🔧',
    tier: AchievementTier.gold,
    category: AchievementCategory.hobby,
    gemReward: 20,
    criteria: {'maintenance_tasks': 25},
  );

  static const livestock20 = Achievement(
    id: 'livestock_20',
    name: 'Aquarist Collector',
    description: 'Add 20 fish or plants to your tanks',
    emoji: '🌿',
    tier: AchievementTier.silver,
    category: AchievementCategory.hobby,
    gemReward: 10,
    criteria: {'livestock_added': 20},
  );

  // MILESTONE ACHIEVEMENTS
  static const streak7 = Achievement(
    id: 'streak_7',
    name: 'Week Warrior',
    description: 'Maintain a 7-day streak',
    emoji: '🔥',
    tier: AchievementTier.silver,
    category: AchievementCategory.milestones,
    gemReward: 10,
    criteria: {'current_streak': 7},
  );

  static const streak30 = Achievement(
    id: 'streak_30',
    name: 'Month Master',
    description: 'Maintain a 30-day streak',
    emoji: '🌟',
    tier: AchievementTier.gold,
    category: AchievementCategory.milestones,
    gemReward: 20,
    criteria: {'current_streak': 30},
  );

  static const streak100 = Achievement(
    id: 'streak_100',
    name: 'Century Streaker',
    description: 'Maintain a 100-day streak!',
    emoji: '💎',
    tier: AchievementTier.platinum,
    category: AchievementCategory.milestones,
    gemReward: 50,
    criteria: {'current_streak': 100},
  );

  static const level5 = Achievement(
    id: 'level_expert',
    name: 'Expert Aquarist',
    description: 'Reach Expert level (5)',
    emoji: '⭐',
    tier: AchievementTier.gold,
    category: AchievementCategory.milestones,
    gemReward: 20,
    criteria: {'level': 5},
  );

  static const level7 = Achievement(
    id: 'level_guru',
    name: 'Aquarium Guru',
    description: 'Reach Guru level (7)',
    emoji: '👑',
    tier: AchievementTier.platinum,
    category: AchievementCategory.milestones,
    gemReward: 50,
    criteria: {'level': 7},
  );

  // SOCIAL ACHIEVEMENTS
  static const firstFriend = Achievement(
    id: 'first_friend',
    name: 'Social Butterfly',
    description: 'Add your first friend',
    emoji: '👥',
    tier: AchievementTier.bronze,
    category: AchievementCategory.social,
    gemReward: 5,
    criteria: {'friends_added': 1},
  );

  static const shareActivity = Achievement(
    id: 'first_share',
    name: 'Show & Tell',
    description: 'Share an activity',
    emoji: '📤',
    tier: AchievementTier.bronze,
    category: AchievementCategory.social,
    gemReward: 5,
    criteria: {'activities_shared': 1},
  );

  // SPECIAL ACHIEVEMENTS
  static const earlyBird = Achievement(
    id: 'early_bird',
    name: 'Early Bird',
    description: 'Complete a lesson before 8 AM',
    emoji: '🌅',
    tier: AchievementTier.silver,
    category: AchievementCategory.special,
    gemReward: 10,
    criteria: {'early_lessons': 1},
  );

  static const nightOwl = Achievement(
    id: 'night_owl',
    name: 'Night Owl',
    description: 'Complete a lesson after 10 PM',
    emoji: '🌙',
    tier: AchievementTier.silver,
    category: AchievementCategory.special,
    gemReward: 10,
    criteria: {'late_lessons': 1},
  );

  static const shopaholic = Achievement(
    id: 'shopaholic',
    name: 'Shopaholic',
    description: 'Purchase 10 items from the gem shop',
    emoji: '🛍️',
    tier: AchievementTier.silver,
    category: AchievementCategory.special,
    gemReward: 10,
    criteria: {'shop_purchases': 10},
  );

  // ALL ACHIEVEMENTS LIST
  static const List<Achievement> all = [
    firstLesson,
    lessons10,
    lessons50,
    perfectQuiz,
    perfectQuiz10,
    firstTank,
    waterTests10,
    maintenanceTasks25,
    livestock20,
    streak7,
    streak30,
    streak100,
    level5,
    level7,
    firstFriend,
    shareActivity,
    earlyBird,
    nightOwl,
    shopaholic,
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
```

---

#### 6.2 Achievement Tracking Provider (4 hours)
**File:** `lib/providers/achievements_provider.dart` (NEW)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievements.dart';
import 'gems_provider.dart';

final achievementsProvider = StateNotifierProvider<AchievementsNotifier, AchievementsState>((ref) {
  return AchievementsNotifier(ref);
});

class AchievementsState {
  final List<String> unlockedIds;
  final Map<String, int> progress; // Achievement ID → current progress

  AchievementsState({
    this.unlockedIds = const [],
    this.progress = const {},
  });

  bool isUnlocked(String id) => unlockedIds.contains(id);
  
  int getProgress(String id) => progress[id] ?? 0;
}

class AchievementsNotifier extends StateNotifier<AchievementsState> {
  AchievementsNotifier(this.ref) : super(AchievementsState()) {
    _load();
  }

  final Ref ref;
  static const _keyUnlocked = 'unlocked_achievements';
  static const _keyProgress = 'achievement_progress';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getStringList(_keyUnlocked) ?? [];
    final progressJson = prefs.getString(_keyProgress);
    
    final progress = progressJson != null
        ? Map<String, int>.from(jsonDecode(progressJson))
        : <String, int>{};

    state = AchievementsState(
      unlockedIds: unlocked,
      progress: progress,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyUnlocked, state.unlockedIds);
    await prefs.setString(_keyProgress, jsonEncode(state.progress));
  }

  /// Check and unlock achievement if criteria met
  Future<Achievement?> checkAndUnlock({
    required String achievementId,
    required Map<String, int> currentStats,
  }) async {
    if (state.isUnlocked(achievementId)) {
      return null; // Already unlocked
    }

    final achievement = Achievements.getById(achievementId);
    if (achievement == null) return null;

    // Check if criteria met
    bool criteriamet = achievement.criteria.entries.every((entry) {
      final statKey = entry.key;
      final required = entry.value as int;
      final current = currentStats[statKey] ?? 0;
      return current >= required;
    });

    if (criteriaMet) {
      // Unlock achievement!
      state = AchievementsState(
        unlockedIds: [...state.unlockedIds, achievementId],
        progress: state.progress,
      );
      await _save();

      // Award gems
      await ref.read(gemsProvider.notifier).addGems(
        amount: achievement.gemReward,
        source: 'achievement_unlocked',
        description: 'Unlocked: ${achievement.name}',
      );

      return achievement;
    }

    return null;
  }

  /// Update progress for tracking
  Future<void> updateProgress(String achievementId, int newProgress) async {
    state = AchievementsState(
      unlockedIds: state.unlockedIds,
      progress: {...state.progress, achievementId: newProgress},
    );
    await _save();
  }

  /// Check all achievements against current stats
  Future<List<Achievement>> checkAll(Map<String, int> stats) async {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in Achievements.all) {
      final unlocked = await checkAndUnlock(
        achievementId: achievement.id,
        currentStats: stats,
      );
      if (unlocked != null) {
        newlyUnlocked.add(unlocked);
      }
    }

    return newlyUnlocked;
  }
}
```

---

#### 6.3 Integrate Achievement Checks (6 hours)

**Modify `user_profile_provider.dart`:**
```dart
// After XP award, lesson completion, etc.
Future<void> _checkAchievements() async {
  final current = state.value;
  if (current == null) return;

  // Build current stats
  final stats = {
    'lessons_completed': current.lessonsCompleted,
    'perfect_quizzes': current.perfectQuizzes,
    'tanks_created': current.tanksCreated,
    'water_tests': current.waterTests,
    'maintenance_tasks': current.maintenanceTasks,
    'livestock_added': current.livestockAdded,
    'current_streak': current.currentStreak,
    'level': current.level,
    'friends_added': current.friendsCount,
    'activities_shared': current.activitiesShared,
    'shop_purchases': current.shopPurchases,
    'early_lessons': current.earlyLessons,
    'late_lessons': current.lateLessons,
  };

  // Check all achievements
  final unlocked = await ref.read(achievementsProvider.notifier).checkAll(stats);

  // Show celebration for newly unlocked
  for (final achievement in unlocked) {
    _showAchievementUnlocked(achievement);
  }
}

void _showAchievementUnlocked(Achievement achievement) {
  // Show modal or notification
  // (Implementation depends on context - could be a provider callback)
}
```

**Call after key events:**
```dart
// Lesson completion
await recordActivity(xp: XpRewards.lessonComplete);
current = current.copyWith(lessonsCompleted: current.lessonsCompleted + 1);
await _checkAchievements();

// Perfect quiz
if (score == 100) {
  current = current.copyWith(perfectQuizzes: current.perfectQuizzes + 1);
  await _checkAchievements();
}

// Tank created
current = current.copyWith(tanksCreated: current.tanksCreated + 1);
await _checkAchievements();
```

---

#### 6.4 Achievement Showcase Screen (2 hours)
**Modify:** `lib/screens/achievements_screen.dart`

```dart
@override
Widget build(BuildContext context) {
  final achievementsState = ref.watch(achievementsProvider);
  final userProfile = ref.watch(userProfileProvider).value;

  return Scaffold(
    appBar: AppBar(title: const Text('Achievements')),
    body: ListView(
      children: AchievementCategory.values.map((category) {
        final categoryAchievements = Achievements.all
            .where((a) => a.category == category)
            .toList();

        return ExpansionTile(
          title: Text(_categoryName(category)),
          initiallyExpanded: true,
          children: categoryAchievements.map((achievement) {
            final isUnlocked = achievementsState.isUnlocked(achievement.id);
            
            return ListTile(
              leading: Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 32,
                  opacity: isUnlocked ? 1.0 : 0.3,
                ),
              ),
              title: Text(
                achievement.name,
                style: TextStyle(
                  fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              subtitle: Text(achievement.description),
              trailing: isUnlocked
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : Text('💎 ${achievement.gemReward}'),
            );
          }).toList(),
        );
      }).toList(),
    ),
  );
}
```

---

### Phase 6 Success Criteria
- ✅ 19 achievements defined across 5 categories
- ✅ Achievements auto-unlock when criteria met
- ✅ Gems awarded on unlock
- ✅ Achievement progress tracked
- ✅ Achievements screen shows locked/unlocked states
- ✅ Celebration shown when unlocking
- ✅ Achievements integrated into all key events

---

## Phase 7: UX Enhancements

**Priority:** P2 (LOW)  
**Estimated Time:** 12 hours  
**Sprint:** 7 (Week 7)

### Enhancements to Implement

#### 7.1 Milestone Celebrations (4 hours)
- Daily goal completion → confetti
- Level up → fanfare modal
- Streak milestones → special animation
- Achievement unlock → celebration dialog

#### 7.2 Notifications (4 hours)
- Daily goal reminder (evening if not met)
- Hearts refilled notification
- Streak at risk warning (if haven't logged in)
- Weekly leaderboard results

#### 7.3 Settings & Customization (2 hours)
- Daily goal adjustment slider (25/50/100/200 XP)
- Notification preferences toggle
- Sound effects toggle
- Reminder time picker

#### 7.4 Polish & Feedback (2 hours)
- Loading states for all async operations
- Error handling for network failures
- Empty states for leaderboards/achievements
- Tooltips for new features

---

## Testing Checklist

### Phase 1: Gem Earning
- [ ] Complete lesson → +5 gems
- [ ] Pass quiz (60%+) → +3 gems
- [ ] Perfect quiz (100%) → +5 gems
- [ ] Meet daily goal → +5 gems
- [ ] 7-day streak → +10 gems
- [ ] 30-day streak → +25 gems
- [ ] Level up → +10 gems
- [ ] Reach Expert → +50 gems
- [ ] Transaction history accurate
- [ ] Gems persist after restart

### Phase 2: XP Integration
- [ ] Water test logged → +10 XP
- [ ] Task completed → +15 XP
- [ ] Maintenance checklist → +30 XP
- [ ] Journal entry → +10 XP
- [ ] Photo uploaded → +5 XP
- [ ] First tank created → +100 XP
- [ ] Equipment added → +15 XP
- [ ] Profile completed → +50 XP
- [ ] XP contributes to daily goal
- [ ] XP triggers level ups

### Phase 3: Home Screen
- [ ] Gamification card displays correctly
- [ ] XP progress bar updates in real-time
- [ ] Gem balance shows current count
- [ ] Streak displays with fire emoji
- [ ] Daily goal shows progress
- [ ] Tapping gems opens shop
- [ ] Tapping streak opens calendar
- [ ] Card looks good on all screen sizes

### Phase 4: Shop Items (Consumables)
- [ ] 2x XP Boost multiplies XP correctly
- [ ] Boost indicator shows in app bar
- [ ] Boost expires after 1 hour
- [ ] Timer Boost adds 30 seconds
- [ ] Lesson Hints show helpful tips
- [ ] Quiz Second Chance allows retry
- [ ] Streak Freeze prevents break
- [ ] Hearts Refill restores all hearts
- [ ] Consumables decrease quantity
- [ ] Out of stock items disabled

### Phase 5: Shop Items (Cosmetics)
- [ ] Badges display on profile
- [ ] Confetti plays on lesson complete
- [ ] Fireworks play on perfect quiz
- [ ] Ocean theme changes colors
- [ ] All 5 themes apply correctly
- [ ] Theme persists after restart
- [ ] Only owned themes selectable

### Phase 6: Achievements
- [ ] First lesson unlocks "First Steps"
- [ ] 10 lessons unlocks "Dedicated Learner"
- [ ] Perfect quiz unlocks "Perfectionist"
- [ ] 7-day streak unlocks "Week Warrior"
- [ ] Level 5 unlocks "Expert Aquarist"
- [ ] Achievements award gems
- [ ] Achievements screen shows progress
- [ ] Locked achievements show criteria
- [ ] Celebration shows on unlock

### Phase 7: UX Enhancements
- [ ] Daily goal reminder notification
- [ ] Hearts refilled notification
- [ ] Streak at risk warning
- [ ] Daily goal confetti on completion
- [ ] Level up fanfare animation
- [ ] Settings show all customization options
- [ ] Tooltips explain new features
- [ ] All loading states smooth

---

## Time Estimates Summary

| Phase | Priority | Estimated Hours | Sprint |
|-------|----------|-----------------|--------|
| Phase 1: Gem Earning | P0 | 8h | Sprint 1 |
| Phase 2: XP Integration | P0 | 16h | Sprint 1-2 |
| Phase 3: Home Screen | P0 | 6h | Sprint 2 |
| Phase 4: Consumables | P1 | 20h | Sprint 3-4 |
| Phase 5: Cosmetics | P1 | 12h | Sprint 5 |
| Phase 6: Achievements | P1 | 16h | Sprint 6 |
| Phase 7: UX Enhancements | P2 | 12h | Sprint 7 |
| **TOTAL** | | **90 hours** | **7 sprints** |

**Assuming 2-week sprints with ~15 hours/week dedicated to gamification:**
- **P0 work:** 3 sprints (6 weeks)
- **P1 work:** 4 sprints (8 weeks)
- **P2 work:** 1 sprint (2 weeks)
- **Total timeline:** ~16 weeks (4 months) for complete integration

**Accelerated timeline (P0 + P1 only):**
- **Total:** 78 hours → ~6 sprints → **12 weeks (3 months)**

---

## Priority Ranking

### P0 (Critical - Must Have)
1. **Phase 1:** Gem earning integration (8h) - **CRITICAL** - gems never trigger
2. **Phase 2:** XP integration (16h) - **HIGH** - only 5% of screens award XP
3. **Phase 3:** Home screen dashboard (6h) - **HIGH** - gamification hidden

**P0 Total:** 30 hours → **2-3 sprints**

### P1 (Important - Should Have)
4. **Phase 4:** Consumable shop items (20h) - items don't function
5. **Phase 5:** Cosmetic shop items (12h) - items don't apply
6. **Phase 6:** Achievements system (16h) - framework exists but empty

**P1 Total:** 48 hours → **3-4 sprints**

### P2 (Nice to Have - Could Have)
7. **Phase 7:** UX enhancements (12h) - polish and feedback

**P2 Total:** 12 hours → **1 sprint**

---

## Recommended Execution Order

### Sprint 1 (Week 1-2): CRITICAL GEM FIXES
- **Phase 1:** Wire up gem earning (ALL triggers)
- **Start Phase 2:** Begin XP integration (P0 screens)
- **Deliverable:** Gems working end-to-end

### Sprint 2 (Week 3-4): COMPLETE XP & HOME SCREEN
- **Finish Phase 2:** Complete all P0 XP integrations
- **Phase 3:** Build home screen gamification dashboard
- **Deliverable:** XP + gems visible and working on all key screens

### Sprint 3-4 (Week 5-8): SHOP FUNCTIONALITY
- **Phase 4:** Implement all consumable shop items
- **Deliverable:** Shop items usable and functional

### Sprint 5 (Week 9-10): COSMETICS
- **Phase 5:** Implement cosmetic shop items
- **Deliverable:** Themes, badges, celebrations working

### Sprint 6 (Week 11-12): ACHIEVEMENTS
- **Phase 6:** Build achievement system
- **Deliverable:** Achievements unlocking and awarding gems

### Sprint 7 (Week 13-14): POLISH
- **Phase 7:** UX enhancements and polish
- **Deliverable:** Notifications, celebrations, settings

---

## Success Metrics

**Post-Integration Targets:**
- ✅ **100% of screens** integrated (vs 5% currently)
- ✅ **100% of gem triggers** automated (vs 0% currently)
- ✅ **100% of shop items** functional (vs 0% currently)
- ✅ **19 achievements** defined and unlocking
- ✅ **User engagement** visible on home screen
- ✅ **Gamification completeness:** 95% → **100%**

**User Experience Goals:**
- Users earn gems naturally through gameplay
- XP rewarded for ALL hobby activities
- Shop items provide real value
- Achievements unlock regularly
- Progress always visible
- Gamification feels integrated, not bolted-on

---

## Maintenance & Future Work

### After Integration Complete:
1. **Monitor balance:** Adjust XP/gem amounts based on user data
2. **Add new achievements:** Quarterly achievement drops
3. **Seasonal shop items:** Limited-time cosmetics
4. **Leaderboard backend:** Replace mock data with real multiplayer
5. **Achievement notifications:** Push notifications for unlocks
6. **Social features:** Share achievements with friends

### Technical Debt to Address:
- Delete deprecated `leaderboard_provider.dart`
- Consolidate XP award patterns (create reusable helper)
- Add integration tests for gamification flows
- Document all XP/gem reward values in one place
- Create developer guide for adding new XP triggers

---

## Notes

### Key Files Reference:
- **Gem rewards:** `lib/models/gem_economy.dart`
- **XP rewards:** `lib/models/learning.dart` (`XpRewards` class)
- **Shop catalog:** `lib/data/shop_catalog.dart`
- **User profile:** `lib/providers/user_profile_provider.dart`
- **Gems provider:** `lib/providers/gems_provider.dart`
- **Hearts service:** `lib/services/hearts_service.dart`

### Design Patterns:
- **XP award pattern:** `await ref.read(userProfileProvider.notifier).recordActivity(xp: amount);`
- **Gem award pattern:** `await ref.read(gemsProvider.notifier).addGems(amount: gems, source: 'event', description: 'text');`
- **Inventory check:** `inventory.any((item) => item.itemId == 'id' && item.quantity > 0)`
- **Boost check:** `ref.read(boostsProvider).any((b) => b.type == type && b.isActive)`

---

**End of Roadmap**

**Next Steps:**
1. Review this roadmap with team
2. Prioritize P0 work for immediate sprint
3. Begin Phase 1: Gem earning integration
4. Track progress against this document
5. Update as implementation reveals new details

**Questions/Feedback:** Update this document as you discover edge cases or implementation details.
