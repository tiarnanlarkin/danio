# 🗺️ Master Polish Roadmap - Path to Duolingo-Level Quality

**Created:** February 7, 2025  
**Current Quality:** 72/100  
**Target Quality:** 95/100  
**Timeline:** 12 weeks (3 months)  
**Approach:** Parallel workstreams + iterative releases

---

## Executive Summary

### The Strategy

**Don't build everything at once.** Ship small, iterate fast, measure engagement.

**Three-Phase Approach:**
1. **Quick Wins** (Week 1): Low-hanging fruit, immediate impact
2. **Core Features** (Weeks 2-8): Must-have engagement mechanics
3. **Polish Layer** (Weeks 9-12): Excellence tier, final 10% quality boost

**Parallel Workstreams:**
- Stream A: Engagement features (spaced repetition, leaderboards)
- Stream B: Content creation (micro-lessons, exercises)
- Stream C: Polish (animations, sounds, accessibility)
- Stream D: Testing + performance

**Success Metrics:**
- D1 retention: 40% → 60%
- D7 retention: 20% → 35%
- Daily goal completion: 0% → 50%+
- Average session length: 5 min → 8 min
- Weekly active users returning: 30% → 50%

---

## Phase 0: Quick Wins (Week 1) ⚡

**Goal:** Ship visible improvements in 5 days, boost morale

### Monday-Tuesday: Celebration System

**Tasks:**
1. Create `CelebrationDialog` widget
   - Confetti animation (use Lottie or custom)
   - XP count-up animation
   - Sound effect integration
   - Haptic feedback

2. Integrate into lesson completion flow
   ```dart
   // lib/screens/lesson_screen.dart
   Future<void> _completeLesson() async {
     await showCelebrationDialog(
       context: context,
       type: CelebrationType.lessonComplete,
       xpEarned: widget.lesson.xpReward,
     );
     // ... rest of completion logic
   }
   ```

3. Add celebration triggers:
   - Lesson complete
   - Quiz passed (score > 70%)
   - Daily goal reached
   - Streak milestone (7, 14, 30 days)

**Deliverables:**
- ✅ `lib/widgets/celebration_dialog.dart`
- ✅ `lib/services/sound_service.dart`
- ✅ 4 sound files (victory.mp3, xp.mp3, achievement.mp3, streak.mp3)
- ✅ Confetti animation asset

**Time:** 2 days  
**Impact:** Massive emotional engagement boost

---

### Wednesday: Success/Error Feedback

**Tasks:**
1. Create `AppFeedback` utility (already exists, just enhance)
   ```dart
   // lib/utils/app_feedback.dart
   class AppFeedback {
     static void showSuccess(BuildContext context, String message);
     static void showError(BuildContext context, String message);
     static void showInfo(BuildContext context, String message);
   }
   ```

2. Replace generic errors with friendly messages:
   ```dart
   // Before:
   Text('Error: $e')
   
   // After:
   AppFeedback.showError(context, 
     'Oops! Couldn\'t load your tanks. Check your connection?');
   ```

3. Add success feedback:
   - Tank created → "🎉 Tank created! Let's add some fish!"
   - Water test logged → "✅ Parameters logged. Looking good!"
   - Lesson complete → "🌟 Lesson complete! +50 XP earned!"

**Deliverables:**
- ✅ Enhanced `app_feedback.dart`
- ✅ 20+ friendly error messages
- ✅ Success messages throughout app

**Time:** 1 day  
**Impact:** App feels more responsive and friendly

---

### Thursday: Daily Goal UI Improvements

**Tasks:**
1. Add goal progress to home screen
   ```dart
   // lib/screens/home_screen.dart
   // Top overlay section
   DailyGoalProgressBar(
     currentXp: profile.dailyXp,
     targetXp: profile.dailyGoalXp,
   )
   ```

2. Animate XP additions
   ```dart
   // When user earns XP:
   ref.read(userProfileProvider.notifier).addXP(
     amount: 50,
     animated: true, // NEW
   );
   ```

3. Celebration on goal completion
   ```dart
   // Check after XP added:
   if (justCompletedDailyGoal) {
     await showCelebrationDialog(
       type: CelebrationType.dailyGoalComplete,
     );
   }
   ```

**Deliverables:**
- ✅ Prominent daily goal display
- ✅ Animated XP updates
- ✅ Goal completion celebration

**Time:** 1 day  
**Impact:** Drives daily engagement

---

### Friday: Performance Quick Fixes

**Tasks:**
1. Add `const` to static widgets
   ```dart
   // Find all places missing const:
   grep -r "Widget build" lib/ | grep -v "const"
   
   // Add const where possible:
   const SizedBox(height: 16)
   const Padding(...)
   ```

2. Memoize expensive widgets
   ```dart
   // lib/widgets/room_scene.dart
   class LivingRoomScene extends StatelessWidget {
     // Cache decorative elements
     static final _decorations = _buildDecorations();
   }
   ```

3. Lazy load lesson content
   ```dart
   // Don't load all paths on startup
   final currentPathProvider = FutureProvider<LearningPath>((ref) async {
     final pathId = ref.watch(selectedPathIdProvider);
     return await LessonRepository.loadPath(pathId);
   });
   ```

**Deliverables:**
- ✅ 100+ const additions
- ✅ Memoized room scenes
- ✅ Lazy loading for lessons

**Time:** 1 day  
**Impact:** Faster startup, smoother animations

---

## Phase 1: Core Engagement (Weeks 2-8)

### Stream A: Spaced Repetition System (Weeks 2-4)

**Week 2: Algorithm Foundation**

**Monday-Wednesday: HLR Algorithm**
```dart
// lib/services/spaced_repetition_service.dart

class HalfLifeRegressionEngine {
  // Core formula: p = 2^(-Δ/h)
  // p = probability of recall
  // Δ = time since last practice
  // h = half-life (time to 50% recall)
  
  double calculateHalfLife(ConceptMemoryStrength concept) {
    // Factors affecting half-life:
    // 1. Base difficulty of concept
    // 2. Number of correct attempts
    // 3. Number of incorrect attempts
    // 4. Time between practices
    
    final difficulty = _getConceptDifficulty(concept.id);
    final successRate = concept.correctCount / 
      (concept.correctCount + concept.incorrectCount + 1);
    
    // Simplified HLR:
    // h = base_difficulty * (1 + success_rate)^correct_count
    return difficulty * pow(1 + successRate, concept.correctCount);
  }
  
  double calculateRecallProbability(ConceptMemoryStrength concept) {
    final hoursSince = DateTime.now()
      .difference(concept.lastPracticed)
      .inHours;
    
    return pow(2, -hoursSince / concept.halfLife);
  }
  
  List<String> selectWeakestConcepts(UserProfile user, {int count = 5}) {
    final allConcepts = user.conceptStrengths.values.toList();
    
    // Sort by recall probability (lowest first)
    allConcepts.sort((a, b) => 
      calculateRecallProbability(a).compareTo(
        calculateRecallProbability(b)));
    
    return allConcepts.take(count).map((c) => c.conceptId).toList();
  }
}
```

**Deliverables:**
- ✅ `lib/models/concept_memory_strength.dart`
- ✅ `lib/services/spaced_repetition_service.dart`
- ✅ Unit tests for algorithm
- ✅ Sample data for testing

**Time:** 3 days

---

**Thursday-Friday: Concept Extraction**

**Task:** Identify all learnable concepts from lessons
```dart
// lib/data/concepts.dart

enum ConceptCategory {
  nitrogenCycle,
  waterParameters,
  fishCare,
  plantCare,
  equipment,
}

class LearnableConcept {
  final String id;
  final String name;
  final ConceptCategory category;
  final double baseDifficulty; // 0.5 - 3.0 (hours)
  final List<String> relatedLessonIds;
  
  const LearnableConcept({
    required this.id,
    required this.name,
    required this.category,
    this.baseDifficulty = 1.0,
    this.relatedLessonIds = const [],
  });
}

// Extract from existing lessons:
final nitrogenCycleConcepts = [
  LearnableConcept(
    id: 'ammonia_toxic',
    name: 'Ammonia is toxic to fish',
    category: ConceptCategory.nitrogenCycle,
    baseDifficulty: 0.5, // Easy concept
  ),
  LearnableConcept(
    id: 'cycle_stages',
    name: 'Three stages of nitrogen cycle',
    category: ConceptCategory.nitrogenCycle,
    baseDifficulty: 1.5, // Medium
  ),
  // ... extract 50+ concepts from 12 lessons
];
```

**Deliverables:**
- ✅ 50+ learnable concepts identified
- ✅ Difficulty ratings assigned
- ✅ Concept taxonomy created

**Time:** 2 days

---

**Week 3: Practice System**

**Monday-Wednesday: Practice Session Builder**
```dart
// lib/services/practice_session_builder.dart

class PracticeSessionBuilder {
  final SpacedRepetitionEngine _srEngine;
  
  Future<PracticeSession> buildPersonalizedSession(
    UserProfile user, {
    int exerciseCount = 10,
  }) async {
    // 1. Get weakest concepts
    final weakConcepts = _srEngine.selectWeakestConcepts(
      user,
      count: exerciseCount,
    );
    
    // 2. Create exercises for each concept
    final exercises = <Exercise>[];
    for (final conceptId in weakConcepts) {
      final exercise = await _createExerciseForConcept(conceptId);
      exercises.add(exercise);
    }
    
    // 3. Mix easy/medium/hard (70/20/10 ratio)
    final balanced = _balanceDifficulty(exercises);
    
    return PracticeSession(
      id: uuid.v4(),
      exercises: balanced,
      targetConcepts: weakConcepts,
    );
  }
  
  Future<Exercise> _createExerciseForConcept(String conceptId) async {
    final concept = Concepts.byId(conceptId);
    
    // Vary exercise type based on concept
    switch (concept.category) {
      case ConceptCategory.nitrogenCycle:
        return _createNitrogenCycleExercise(concept);
      case ConceptCategory.waterParameters:
        return _createParameterExercise(concept);
      // ...
    }
  }
}
```

**Deliverables:**
- ✅ Practice session builder
- ✅ Exercise generation from concepts
- ✅ Difficulty balancing

**Time:** 3 days

---

**Thursday-Friday: Practice UI**
```dart
// lib/screens/practice_screen.dart (enhancement)

class PracticeScreen extends ConsumerStatefulWidget {
  // Already exists! Just enhance with:
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Show which concepts are weak
    final weakConcepts = ref.watch(weakConceptsProvider);
    
    // 2. "Start Practice" button generates personalized session
    ElevatedButton(
      onPressed: () async {
        final session = await buildPersonalizedSession(user);
        Navigator.push(context, ExerciseSessionScreen(session));
      },
      child: Text('Practice Weak Skills (${weakConcepts.length})'),
    );
    
    // 3. Show skill strength meters
    for (final concept in weakConcepts) {
      SkillStrengthMeter(
        concept: concept,
        strength: calculateRecallProbability(concept),
      );
    }
  }
}
```

**New widget: Skill Strength Meter**
```dart
// lib/widgets/skill_strength_meter.dart

class SkillStrengthMeter extends StatelessWidget {
  final LearnableConcept concept;
  final double strength; // 0.0 - 1.0
  
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(concept.name),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: strength,
                  color: _getStrengthColor(strength),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.school),
            onPressed: () => _practiceThisConcept(concept),
          ),
        ],
      ),
    );
  }
  
  Color _getStrengthColor(double strength) {
    if (strength > 0.7) return Colors.green;
    if (strength > 0.4) return Colors.orange;
    return Colors.red;
  }
}
```

**Deliverables:**
- ✅ Enhanced practice screen
- ✅ Skill strength visualization
- ✅ Personalized practice flow

**Time:** 2 days

---

**Week 4: Recording & Adaptation**

**Monday-Tuesday: Result Recording**
```dart
// lib/services/spaced_repetition_service.dart

class SpacedRepetitionEngine {
  // ... existing code
  
  Future<void> recordPracticeResult({
    required String userId,
    required String conceptId,
    required bool correct,
    required Duration timeTaken,
  }) async {
    final concept = await _getConceptStrength(userId, conceptId);
    
    if (correct) {
      concept.correctCount++;
      concept.halfLife = calculateHalfLife(concept);
    } else {
      concept.incorrectCount++;
      concept.halfLife = calculateHalfLife(concept) * 0.7; // Reduce
    }
    
    concept.lastPracticed = DateTime.now();
    
    await _saveConceptStrength(userId, concept);
  }
}
```

**Wednesday-Friday: Analytics Dashboard**
```dart
// lib/screens/learning_analytics_screen.dart

class LearningAnalyticsScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(learningStatsProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Your Progress')),
      body: ListView(
        children: [
          // Overall stats
          StatsCard(
            title: 'Concepts Mastered',
            value: stats.masteredCount,
            icon: Icons.emoji_events,
          ),
          StatsCard(
            title: 'Practice Streak',
            value: '${stats.practiceStreak} days',
            icon: Icons.local_fire_department,
          ),
          
          // Skill strength by category
          CategoryStrengthChart(
            data: stats.strengthByCategory,
          ),
          
          // Weakest skills (need practice)
          SectionHeader(title: 'Needs Practice'),
          ...stats.weakestConcepts.map((c) => 
            SkillStrengthMeter(concept: c, strength: c.strength)),
          
          // Strongest skills
          SectionHeader(title: 'Mastered'),
          ...stats.strongestConcepts.map((c) => 
            SkillStrengthMeter(concept: c, strength: c.strength)),
        ],
      ),
    );
  }
}
```

**Deliverables:**
- ✅ Result recording system
- ✅ Analytics dashboard
- ✅ Progress visualization
- ✅ Weak skills tracking

**Time:** 3 days

---

### Stream B: Micro-Lessons (Weeks 5-7)

**Week 5: Content Architecture**

**Monday-Wednesday: Micro-Lesson Framework**
```dart
// lib/models/micro_lesson.dart

class MicroLesson {
  final String id;
  final String pathId;
  final String title;
  final int orderIndex;
  final List<Exercise> exercises; // 3-5 exercises
  final int xpReward; // 10-15 XP (lower than full lessons)
  final List<String> prerequisites;
  final List<String> conceptIds; // What this teaches
  
  Duration get estimatedTime => 
    Duration(seconds: exercises.length * 20); // ~1-2 min
}

// Break existing lessons into micro-lessons:
// OLD: "Why New Tanks Kill Fish" (4 min, 6 sections)
// NEW: 3 micro-lessons:
//   1. "Fish Produce Waste" (1 min, 3 exercises)
//   2. "Ammonia is Toxic" (1 min, 4 exercises)
//   3. "Testing for Ammonia" (1.5 min, 4 exercises)
```

**Thursday-Friday: Content Breakdown**

**Task:** Break 12 existing lessons → 50 micro-lessons
```
Nitrogen Cycle Path (3 lessons → 15 micro):
├─ What is Fish Waste? (1 min)
├─ Ammonia is Deadly (1 min)
├─ Testing for Ammonia (1.5 min)
├─ Meet Beneficial Bacteria (1 min)
├─ Nitrite: Stage Two (1 min)
├─ Nitrite Poisoning Signs (1.5 min)
├─ Nitrate: The Final Form (1 min)
├─ Safe Nitrate Levels (1 min)
├─ Why We Do Water Changes (1 min)
├─ Starting the Cycle (1.5 min)
├─ Ammonia Sources (1 min)
├─ Seeding Bacteria (1 min)
├─ Testing During Cycling (1.5 min)
├─ When is Cycling Complete? (1 min)
└─ Cycling Troubleshooting (2 min)

Water Parameters Path (3 lessons → 12 micro):
... similar breakdown

First Fish Path (2 lessons → 8 micro):
... similar breakdown

Maintenance Path (2 lessons → 8 micro):
... similar breakdown

Planted Tank Path (2 lessons → 7 micro):
... similar breakdown

Total: 50 micro-lessons
```

**Deliverables:**
- ✅ Micro-lesson content plan (50 lessons)
- ✅ Content outline for each
- ✅ Concept mapping

**Time:** 3 days (planning phase)

---

**Week 6-7: Content Creation**

**Time allocation:**
- 50 micro-lessons ÷ 10 days = 5 per day
- Each micro-lesson: ~90 minutes to write
  - 10 min: Outline
  - 30 min: Educational content
  - 30 min: Create 3-5 exercises
  - 20 min: Review & refine

**Daily target:** 5 micro-lessons

**Week 6:**
- Mon: 5 lessons (Nitrogen Cycle 1-5)
- Tue: 5 lessons (Nitrogen Cycle 6-10)
- Wed: 5 lessons (Nitrogen Cycle 11-15)
- Thu: 5 lessons (Water Parameters 1-5)
- Fri: 5 lessons (Water Parameters 6-10)

**Week 7:**
- Mon: 5 lessons (Water Parameters 11-12, First Fish 1-3)
- Tue: 5 lessons (First Fish 4-8)
- Wed: 5 lessons (Maintenance 1-5)
- Thu: 5 lessons (Maintenance 6-8, Planted 1-2)
- Fri: 5 lessons (Planted 3-7)

**Deliverables:**
- ✅ 50 complete micro-lessons
- ✅ 200+ exercises (variety of types)
- ✅ All content in `lib/data/micro_lesson_content.dart`

**Time:** 10 days

---

### Stream C: Leaderboards (Week 6)

**Monday-Tuesday: Matchmaking System**
```dart
// lib/services/leaderboard_service.dart

class LeaderboardMatchmaker {
  Future<List<String>> findWeeklyOpponents(String userId) async {
    // 1. Get user's prior week XP
    final userPriorXp = await _getPriorWeekXP(userId);
    
    // 2. Find 29 users with similar XP (±30%)
    final lowerBound = (userPriorXp * 0.7).round();
    final upperBound = (userPriorXp * 1.3).round();
    
    final candidates = await _queryUsersByXPRange(
      lowerBound,
      upperBound,
      limit: 100,
    );
    
    // 3. Randomize and select 29
    candidates.shuffle();
    return candidates.take(29).toList();
  }
  
  Future<void> createWeeklyLeagues() async {
    final allActiveUsers = await _getActiveUsers();
    
    // Group users into leagues of 30
    for (int i = 0; i < allActiveUsers.length; i += 30) {
      final cohort = allActiveUsers.skip(i).take(30).toList();
      
      final league = WeeklyLeague(
        id: uuid.v4(),
        startDate: _getWeekStart(),
        endDate: _getWeekEnd(),
        participants: cohort,
      );
      
      await _saveLeague(league);
    }
  }
}
```

**Wednesday-Thursday: League Progression**
```dart
// lib/models/league.dart

enum League {
  bronze(0),
  silver(1),
  gold(2),
  sapphire(3),
  ruby(4),
  emerald(5),
  amethyst(6),
  pearl(7),
  obsidian(8),
  diamond(9);
  
  final int tier;
  const League(this.tier);
  
  League? promote() => tier < 9 ? League.values[tier + 1] : null;
  League? demote() => tier > 0 ? League.values[tier - 1] : null;
}

class LeaguePromotionCalculator {
  League calculateNewLeague(League current, int finalRank) {
    // Top 10: Promote
    if (finalRank <= 10 && current.tier < 9) {
      return current.promote()!;
    }
    
    // Bottom 5: Demote
    if (finalRank >= 26 && current.tier > 0) {
      return current.demote()!;
    }
    
    // Middle 15: Stay
    return current;
  }
}
```

**Friday: Weekly Reset Scheduler**
```dart
// lib/services/leaderboard_scheduler.dart

class LeaderboardScheduler {
  Future<void> scheduleWeeklyReset() async {
    // Runs every Monday at 00:00 UTC
    final nextMonday = _getNextMonday();
    
    final scheduledTask = ScheduledTask(
      id: 'weekly_leaderboard_reset',
      executeAt: nextMonday,
      action: () async {
        await _resetWeeklyLeaderboards();
      },
    );
    
    await TaskScheduler.schedule(scheduledTask);
  }
  
  Future<void> _resetWeeklyLeaderboards() async {
    final allLeagues = await _getCurrentWeekLeagues();
    
    for (final league in allLeagues) {
      // 1. Calculate final rankings
      final rankings = _calculateFinalRankings(league);
      
      // 2. Update user leagues
      for (final participant in league.participants) {
        final rank = rankings.indexOf(participant.userId) + 1;
        final newLeague = _calculateNewLeague(
          participant.currentLeague,
          rank,
        );
        
        await _updateUserLeague(participant.userId, newLeague);
        
        // 3. Send notification
        if (newLeague != participant.currentLeague) {
          await _sendLeagueChangeNotification(
            participant.userId,
            newLeague,
            promoted: newLeague.tier > participant.currentLeague.tier,
          );
        }
      }
      
      // 4. Clear weekly XP
      await _clearWeeklyXP(league.participants);
    }
    
    // 5. Create new week's leagues
    await _createWeeklyLeagues();
  }
}
```

**Deliverables:**
- ✅ Matchmaking system
- ✅ League progression logic
- ✅ Weekly reset scheduler
- ✅ Promotion/demotion notifications

**Time:** 5 days

---

### Stream D: Exercise Variety (Week 7)

**Task:** Integrate existing exercise widgets + create content

**Monday: Fill-in-Blank**
```dart
// lib/data/exercises/fill_blank_exercises.dart

final fillBlankExercises = [
  FillInBlankExercise(
    id: 'fb_ammonia_1',
    conceptId: 'ammonia_source',
    sentence: 'Fish waste breaks down into ___, which is toxic.',
    answer: 'ammonia',
    hints: ['am___ia', 'Sounds like "a moany uh"'],
    alternativeAnswers: ['NH3', 'nh3'], // Case-insensitive
  ),
  FillInBlankExercise(
    id: 'fb_cycle_1',
    sentence: 'The first bacteria convert ammonia into ___.',
    answer: 'nitrite',
    hints: ['ni___ite', 'Second stage of cycle'],
  ),
  // Create 30+ fill-in-blank exercises
];
```

**Tuesday: Matching**
```dart
// lib/data/exercises/matching_exercises.dart

final matchingExercises = [
  MatchingExercise(
    id: 'match_chemicals',
    conceptId: 'cycle_stages',
    question: 'Match the chemical to its toxicity level:',
    pairs: {
      'Ammonia (NH3)': 'Highly toxic',
      'Nitrite (NO2)': 'Very toxic',
      'Nitrate (NO3)': 'Low toxicity',
    },
  ),
  MatchingExercise(
    id: 'match_parameters',
    question: 'Match parameter to ideal range:',
    pairs: {
      'pH': '6.5-7.5',
      'Temperature': '75-80°F',
      'Ammonia': '0 ppm',
      'Nitrite': '0 ppm',
    },
  ),
  // Create 20+ matching exercises
];
```

**Wednesday: Ordering**
```dart
// lib/data/exercises/ordering_exercises.dart

final orderingExercises = [
  OrderingExercise(
    id: 'order_cycle',
    conceptId: 'cycle_stages',
    question: 'Put the nitrogen cycle in order:',
    items: [
      'Fish produce waste',
      'Waste becomes ammonia',
      'Bacteria convert to nitrite',
      'Bacteria convert to nitrate',
      'Water changes remove nitrate',
    ],
    correctOrder: [0, 1, 2, 3, 4],
  ),
  OrderingExercise(
    id: 'order_cycling',
    question: 'Order the steps to cycle a new tank:',
    items: [
      'Set up tank and filter',
      'Add ammonia source',
      'Wait for bacteria to grow',
      'Test water daily',
      'Add fish when safe',
    ],
    correctOrder: [0, 1, 2, 3, 4],
  ),
  // Create 15+ ordering exercises
];
```

**Thursday-Friday: Image Selection**
```dart
// lib/data/exercises/image_exercises.dart

final imageExercises = [
  ImageChoiceExercise(
    id: 'img_healthy_water',
    conceptId: 'water_clarity',
    question: 'Which shows healthy, clear water?',
    images: [
      AssetImage('assets/exercises/clear_water.jpg'),
      AssetImage('assets/exercises/cloudy_water.jpg'),
      AssetImage('assets/exercises/green_water.jpg'),
    ],
    correctIndex: 0,
    explanation: 'Clear water is a sign of healthy parameters.',
  ),
  // Create 10+ image exercises
  // Note: Need to source/create images
];
```

**Deliverables:**
- ✅ 30+ fill-in-blank exercises
- ✅ 20+ matching exercises
- ✅ 15+ ordering exercises
- ✅ 10+ image exercises
- ✅ Exercise content integrated

**Time:** 5 days

---

## Phase 2: Push Notifications & Streaks (Week 8)

### Monday-Tuesday: Notification Service

```dart
// lib/services/notification_service.dart

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('app_icon');
    const iosSettings = DarwinInitializationSettings();
    
    await _plugin.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }
  
  // 1. Daily Reminder
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await _plugin.zonedSchedule(
      0, // notification id
      '🐠 Time to learn!',
      'Keep your streak alive! Just 5 minutes today.',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Practice Reminder',
          importance: Importance.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  // 2. Streak Risk Alert
  Future<void> scheduleStreakRiskAlert() async {
    // Check at 9 PM if user hasn't practiced
    await _plugin.zonedSchedule(
      1,
      '⚠️ Your ${currentStreak}-day streak is at risk!',
      'Complete one lesson before midnight to keep it alive.',
      _nextInstanceOfTime(TimeOfDay(hour: 21, minute: 0)),
      // ... notification details
    );
  }
  
  // 3. Goal Progress
  Future<void> showGoalProgress(int xpRemaining) async {
    await _plugin.show(
      2,
      '🎯 Almost there!',
      'Just $xpRemaining XP to reach your daily goal!',
      // ... notification details
    );
  }
  
  // 4. Achievement Unlocked
  Future<void> showAchievementUnlocked(Achievement achievement) async {
    await _plugin.show(
      3,
      '🏆 Achievement Unlocked!',
      '${achievement.emoji} ${achievement.title}',
      // ... notification details
    );
  }
  
  // 5. Leaderboard Update
  Future<void> showLeaderboardUpdate(String message) async {
    await _plugin.show(
      4,
      '📊 Leaderboard Update',
      message, // "You moved to 3rd place!"
      // ... notification details
    );
  }
}
```

**Wednesday: Notification Settings UI**

Enhance existing `lib/screens/notification_settings_screen.dart`:
```dart
class NotificationSettingsScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Daily Reminder'),
            subtitle: Text('Remind me to practice'),
            value: settings.dailyReminder,
            onChanged: (val) => _toggle('dailyReminder', val),
          ),
          
          if (settings.dailyReminder)
            ListTile(
              title: Text('Reminder Time'),
              subtitle: Text('${settings.reminderTime.format(context)}'),
              onTap: () => _pickTime(context),
            ),
          
          SwitchListTile(
            title: Text('Streak Alerts'),
            subtitle: Text('Warn when streak at risk'),
            value: settings.streakAlerts,
            onChanged: (val) => _toggle('streakAlerts', val),
          ),
          
          SwitchListTile(
            title: Text('Leaderboard Updates'),
            subtitle: Text('Competition notifications'),
            value: settings.leaderboardUpdates,
            onChanged: (val) => _toggle('leaderboardUpdates', val),
          ),
          
          SwitchListTile(
            title: Text('Achievements'),
            subtitle: Text('When you unlock badges'),
            value: settings.achievementNotifs,
            onChanged: (val) => _toggle('achievements', val),
          ),
          
          Divider(),
          
          ListTile(
            title: Text('Test Notification'),
            trailing: Icon(Icons.send),
            onTap: () => _sendTestNotification(),
          ),
        ],
      ),
    );
  }
}
```

**Thursday-Friday: Streak Protection**

```dart
// lib/models/streak_protection.dart

class StreakFreeze {
  final String id;
  final DateTime purchasedDate;
  final DateTime? usedDate;
  
  bool get isActive => usedDate == null;
}

class WeekendAmulet {
  final String id;
  final DateTime purchasedDate;
  final DateTime expiryDate;
  
  bool get isActive => DateTime.now().isBefore(expiryDate);
}

// Update streak calculation
class StreakCalculator {
  int calculateStreak(UserProfile user) {
    final today = DateTime.now().date;
    final lastActive = user.lastActiveDate?.date;
    
    if (lastActive == null) return 0;
    if (lastActive == today) return user.currentStreak;
    
    final daysSince = today.difference(lastActive).inDays;
    
    if (daysSince == 1) {
      // Consecutive day
      return user.currentStreak + 1;
    }
    
    if (daysSince > 1) {
      // Potential break - check protections
      
      // 1. Streak Freeze?
      if (user.activeStreakFreezes.isNotEmpty && daysSince == 2) {
        final freeze = user.activeStreakFreezes.first;
        freeze.use();
        return user.currentStreak; // Protected!
      }
      
      // 2. Weekend Amulet?
      if (user.activeWeekendAmulet != null && _wasWeekend(lastActive)) {
        return user.currentStreak; // Weekend pass!
      }
      
      // Streak broken :(
      return 0;
    }
    
    return user.currentStreak;
  }
  
  bool _wasWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || 
           date.weekday == DateTime.sunday;
  }
}
```

**Deliverables:**
- ✅ Notification service (5 types)
- ✅ Settings UI functional
- ✅ Streak protection logic
- ✅ Shop items for protection

**Time:** 5 days

---

## Phase 3: Polish & Excellence (Weeks 9-12)

### Week 9: Animations & Sound

**Monday-Tuesday: Core Animations**

1. **Confetti System**
```dart
// lib/widgets/animations/confetti.dart
class ConfettiAnimation extends StatefulWidget {
  // Particle-based confetti
  // Falls from top, bounces, fades
  // Colors match app theme
}
```

2. **XP Counter Animation**
```dart
// lib/widgets/animations/xp_counter.dart
class AnimatedXPCounter extends StatefulWidget {
  final int startValue;
  final int endValue;
  final Duration duration;
  
  // Counts up from start to end
  // With easing curve (fast start, slow end)
  // Haptic feedback on completion
}
```

3. **Progress Bar Fill**
```dart
// Smooth fill animation
LinearProgressIndicator(
  value: _animationController.value,
  // Animate from 0.0 to target over 500ms
)
```

**Wednesday-Thursday: Sound System**

```dart
// lib/services/sound_service.dart

class SoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;
  
  Future<void> playSuccess() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/success.mp3'));
  }
  
  Future<void> playError() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/error.mp3'));
  }
  
  Future<void> playAchievement() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/achievement.mp3'));
  }
  
  Future<void> playXP() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/xp.mp3'));
  }
  
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }
}
```

**Assets needed:**
- `assets/sounds/success.mp3` (correct answer chime)
- `assets/sounds/error.mp3` (wrong answer buzz)
- `assets/sounds/achievement.mp3` (unlock fanfare)
- `assets/sounds/xp.mp3` (XP gain sound)
- `assets/sounds/victory.mp3` (lesson complete)

**Friday: Haptic Feedback**

```dart
// lib/services/haptic_service.dart

class HapticService {
  static void success() {
    HapticFeedback.mediumImpact();
  }
  
  static void error() {
    HapticFeedback.heavyImpact();
  }
  
  static void buttonPress() {
    HapticFeedback.lightImpact();
  }
  
  static void achievement() {
    HapticFeedback.mediumImpact();
    Future.delayed(Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
  }
}

// Integrate throughout app:
ElevatedButton(
  onPressed: () {
    HapticService.buttonPress();
    _handlePress();
  },
  child: Text('Start Lesson'),
)
```

**Deliverables:**
- ✅ Confetti animation
- ✅ XP counter animation
- ✅ Progress animations
- ✅ Sound service + 5 sound effects
- ✅ Haptic feedback integrated

**Time:** 5 days

---

### Week 10: Testing Sprint

**Goal:** Achieve 60% test coverage

**Monday-Tuesday: Model Tests**
```dart
// test/models/learning_test.dart
test('Quiz calculates score correctly', () {
  final quiz = Quiz(
    id: 'test_quiz',
    lessonId: 'test_lesson',
    questions: [q1, q2, q3, q4, q5],
  );
  
  final score = quiz.calculateScore([0, 1, 0, 1, 1]); // 3/5 correct
  expect(score, 60.0);
  expect(quiz.isPassing(score, passingScore: 70), false);
});

test('Lesson unlocks when prerequisites met', () {
  final lesson = Lesson(
    id: 'advanced',
    prerequisites: ['intro', 'basics'],
    // ...
  );
  
  expect(lesson.isUnlocked(['intro']), false);
  expect(lesson.isUnlocked(['intro', 'basics']), true);
});
```

**Wednesday: Service Tests**
```dart
// test/services/spaced_repetition_test.dart
test('HLR calculates half-life correctly', () {
  final concept = ConceptMemoryStrength(
    id: 'test_concept',
    correctCount: 5,
    incorrectCount: 1,
    baseDifficulty: 1.0,
  );
  
  final engine = SpacedRepetitionEngine();
  final halfLife = engine.calculateHalfLife(concept);
  
  expect(halfLife, greaterThan(1.0)); // Success increases half-life
});

test('Selects weakest concepts for practice', () {
  final user = UserProfile(
    conceptStrengths: {
      'concept_a': ConceptMemoryStrength(strength: 0.9),
      'concept_b': ConceptMemoryStrength(strength: 0.3),
      'concept_c': ConceptMemoryStrength(strength: 0.5),
    },
  );
  
  final weakest = engine.selectWeakestConcepts(user, count: 2);
  
  expect(weakest, contains('concept_b')); // Weakest
  expect(weakest, contains('concept_c')); // Second weakest
});
```

**Thursday-Friday: Widget Tests**
```dart
// test/widgets/celebration_dialog_test.dart
testWidgets('Celebration dialog shows XP gained', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CelebrationDialog(
        type: CelebrationType.lessonComplete,
        xpEarned: 50,
      ),
    ),
  );
  
  expect(find.text('+50 XP'), findsOneWidget);
  expect(find.byType(ConfettiAnimation), findsOneWidget);
});

testWidgets('Daily goal progress shows correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: DailyGoalProgressBar(
        currentXp: 30,
        targetXp: 50,
      ),
    ),
  );
  
  final progress = tester.widget<LinearProgressIndicator>(
    find.byType(LinearProgressIndicator),
  );
  
  expect(progress.value, 0.6); // 30/50
});
```

**Deliverables:**
- ✅ 40+ unit tests (models, services)
- ✅ 20+ widget tests
- ✅ Integration tests for key flows
- ✅ 60%+ code coverage

**Time:** 5 days

---

### Week 11: Accessibility & Performance

**Monday-Tuesday: Accessibility**

1. **Semantic Labels**
```dart
// Before:
IconButton(
  icon: Icon(Icons.edit),
  onPressed: () {},
)

// After:
Semantics(
  label: 'Edit tank settings',
  child: IconButton(
    icon: Icon(Icons.edit),
    onPressed: () {},
  ),
)
```

**Script to find missing labels:**
```dart
// audit_accessibility.dart
void auditSemanticLabels() {
  // Find all IconButton, GestureDetector without labels
  // Generate report
}
```

2. **Color Contrast**
```dart
// Test all color combinations meet WCAG AA:
// - Normal text: 4.5:1 contrast ratio
// - Large text: 3:1 contrast ratio

// Fix low-contrast issues in room themes
```

3. **Screen Reader Support**
```dart
// Test with TalkBack (Android) / VoiceOver (iOS)
// Ensure all screens navigable
// Announce important changes (XP gained, lesson complete)
```

**Wednesday-Thursday: Performance Optimization**

1. **Lazy Loading**
```dart
// lib/providers/lesson_provider.dart
final lessonProvider = FutureProvider.family<Lesson, String>((ref, id) async {
  // Load only requested lesson, not all
  return await LessonRepository.loadLesson(id);
});
```

2. **Const Widgets**
```bash
# Audit script:
find lib/ -name "*.dart" -exec grep -H "Widget build" {} \; | \
  grep -v "const" > non_const_widgets.txt

# Add const to 100+ widgets
```

3. **Image Optimization**
```dart
// Compress images, use cached_network_image
// Lazy load room decorations
```

4. **Build Optimization**
```dart
// Memoize expensive computations
class ExpensiveWidget extends StatelessWidget {
  static final _cache = <String, Widget>{};
  
  Widget build(BuildContext context) {
    return _cache.putIfAbsent(
      'key',
      () => _buildExpensiveWidget(),
    );
  }
}
```

**Friday: Performance Testing**
```bash
# Measure startup time
flutter run --profile --trace-startup

# Analyze build times
flutter analyze

# Check APK size
flutter build apk --analyze-size
```

**Deliverables:**
- ✅ 200+ semantic labels added
- ✅ WCAG AA compliance
- ✅ Screen reader tested
- ✅ 2x faster startup time
- ✅ Const widgets throughout

**Time:** 5 days

---

### Week 12: Final Polish & Launch Prep

**Monday: UI Polish**
- Loading skeletons instead of spinners
- Smooth page transitions
- Button state polish (hover, pressed)
- Empty state illustrations

**Tuesday: Content Review**
- Proofread all 50 micro-lessons
- Test all 200+ exercises
- Fix typos, unclear explanations
- Ensure concept coverage

**Wednesday: Bug Bash**
- Test all flows end-to-end
- Fix critical bugs
- Performance regression testing
- Cross-device testing

**Thursday: Analytics Setup**
```dart
// lib/services/analytics_service.dart

class AnalyticsService {
  void trackLessonComplete(String lessonId, int score);
  void trackStreakMilestone(int days);
  void trackDailyGoalComplete();
  void trackLeaguePromotion(League newLeague);
  void trackPracticeSession(int conceptCount);
  
  // Track key metrics:
  // - Lesson completion rate
  // - Quiz pass rate
  // - Daily goal achievement rate
  // - Streak retention
  // - Leaderboard engagement
}
```

**Friday: Launch Checklist**
- [ ] All tests passing
- [ ] Performance benchmarks met
- [ ] Accessibility verified
- [ ] Analytics working
- [ ] Error tracking enabled
- [ ] App Store assets ready
- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] Beta testing complete

**Deliverables:**
- ✅ All critical bugs fixed
- ✅ Polish complete
- ✅ Analytics integrated
- ✅ Ready for beta release

**Time:** 5 days

---

## Parallel Workstreams Summary

**Weeks 1-4:**
- Stream A: Spaced Repetition (Weeks 2-4)
- Quick Wins: (Week 1)

**Weeks 5-8:**
- Stream B: Micro-Lessons (Weeks 5-7)
- Stream C: Leaderboards (Week 6)
- Stream D: Exercise Variety (Week 7)
- Push Notifications (Week 8)

**Weeks 9-12:**
- Animations & Sound (Week 9)
- Testing Sprint (Week 10)
- Accessibility & Performance (Week 11)
- Final Polish (Week 12)

---

## Success Metrics Tracking

### Week-by-Week Targets

| Week | Quality Score | Key Deliverables |
|------|--------------|------------------|
| 1 | 75/100 | Celebrations, feedback, performance |
| 2-4 | 78/100 | Spaced repetition working |
| 5-7 | 82/100 | 50 micro-lessons, exercise variety |
| 8 | 85/100 | Leaderboards, push notifications |
| 9 | 88/100 | Animations, sound |
| 10 | 90/100 | Test coverage 60%+ |
| 11 | 93/100 | Accessibility, performance |
| 12 | 95/100 | **Launch ready!** |

---

## Risk Mitigation

### High-Risk Items

1. **Spaced Repetition Complexity**
   - Risk: Algorithm harder than expected
   - Mitigation: Start with simplified HLR, iterate
   - Fallback: Use basic Leitner system

2. **Content Creation Pace**
   - Risk: 50 lessons in 2 weeks is aggressive
   - Mitigation: Reuse existing content, templates
   - Fallback: Launch with 30 lessons, add more post-release

3. **Testing Coverage**
   - Risk: 60% coverage in 1 week is challenging
   - Mitigation: Focus on critical paths first
   - Fallback: 40% coverage minimum, improve post-launch

### Medium-Risk Items

4. **Leaderboard Matchmaking**
   - Risk: Not enough users for fair matching
   - Mitigation: Use mock data for testing
   - Fallback: Global leaderboard only for v1

5. **Push Notifications**
   - Risk: iOS permissions, opt-in rates
   - Mitigation: Gradual prompting, clear value prop
   - Fallback: In-app notifications only

---

## Resource Requirements

### Time Investment
- **Full-time:** 12 weeks @ 40 hours/week = 480 hours
- **Part-time (20h/week):** 24 weeks
- **Contractor:** Can parallelize streams, reduce to 8 weeks

### Skills Needed
- Flutter development (advanced)
- UI/UX design (intermediate)
- Content writing (beginner-intermediate)
- Testing (intermediate)
- Analytics (beginner)

### Assets Needed
- Sound effects (5 files) - $50-100 or free alternatives
- Confetti animation - Free (Lottie) or custom
- Images for exercises - Stock photos or custom illustrations
- Optional: Mascot character (like Duo owl)

---

## Post-Launch Roadmap (Week 13+)

### Phase 4: Stories Mode (Weeks 13-14)
- 10 scenario-based stories
- Real-world troubleshooting
- Branching narratives

### Phase 5: Social Features (Weeks 15-16)
- Friend challenges
- Achievement sharing
- Community forums

### Phase 6: Advanced Content (Weeks 17-20)
- 100+ total micro-lessons
- Intermediate/advanced tracks
- Specialty paths (reef, planted, breeding)

### Phase 7: Premium Features (Weeks 21-24)
- Ad-free experience
- Unlimited hearts/mistakes
- Offline mode
- Advanced analytics
- Priority support

---

## Conclusion

**12 weeks from 72/100 → 95/100 quality**

**The Path:**
1. Quick wins (Week 1) → Immediate morale boost
2. Core features (Weeks 2-8) → Engagement foundation
3. Polish (Weeks 9-12) → Excellence layer

**Key Success Factors:**
- ✅ Parallel workstreams (faster delivery)
- ✅ Iterative approach (ship small, iterate)
- ✅ Metrics tracking (know what's working)
- ✅ Risk mitigation (fallback plans)

**You can do this!** The foundation is solid. Just need to add the engagement layer that makes Duolingo addictive.

**Next:** See `QUICK_WINS_CHECKLIST.md` for immediate actions (Week 1)

---

**Roadmap Status:** Ready for execution ✅  
**Estimated Completion:** May 2, 2025 (if starting Feb 10)  
**Confidence Level:** High (80%+ achievable on schedule)
