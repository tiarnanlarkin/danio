# 🤖 PARALLEL WORKSTREAMS - Agent Spawn Guide

**Date**: February 7, 2025  
**Purpose**: Maximize velocity with parallel agent execution  
**Strategy**: Run 2-3 agents simultaneously while main agent coordinates  
**Risk**: LOW (tasks are independent with clear interfaces)

---

## 🎯 OVERVIEW

### Why Parallel Workstreams?

**Time Savings**: 12-week roadmap can be compressed with parallel execution
- **Sequential**: 12 weeks of main agent work
- **Parallel (2 agents)**: ~8 weeks of real time
- **Parallel (3 agents)**: ~6-7 weeks of real time

**Independence**: Most tasks don't require coordination
- Content writing is completely independent
- UI screens can be built in parallel
- Testing can happen alongside feature development

**Fresh Context**: Sub-agents start with clean context
- No cognitive overload from main session
- Can use different models (Opus for complex tasks)
- Self-contained deliverables

---

## 📊 PARALLELIZATION MATRIX

### Week-by-Week Agent Capacity

| Week | Main Agent | Agent 1 | Agent 2 | Agent 3 | Total Agents |
|------|------------|---------|---------|---------|--------------|
| 1 | Critical bugs + coordination | P1 bug fixes | Testing setup | - | 3 |
| 2 | Standard widgets + review | Accessibility (full sprint) | - | - | 2 |
| 3 | Daily goals polish | Hearts implementation | Gems backend | - | 3 |
| 4 | Integration testing | Leaderboards | Animations | - | 3 |
| 5 | Review + integration | Beginner lessons (25) | Intermediate lessons (15) | Advanced lessons (10) | 4 |
| 6 | Editorial oversight | Stories backend | Stories UI | - | 3 |
| 7 | Enhanced onboarding | Shop UI | Placement test | - | 3 |
| 8 | Social polish | Push notifications | Analytics setup | - | 3 |
| 9 | Performance profiling | Performance fixes | UI polish | - | 3 |
| 10 | Integration testing | Unit tests | Integration tests | - | 3 |
| 11 | User testing + iteration | (reactive based on feedback) | - | - | 1 |
| 12 | Launch coordination | Marketing assets | Documentation | - | 3 |

**Average Parallelization**: 2.7 agents working simultaneously  
**Peak Parallelization**: Week 5 (4 agents on content creation)

---

## 🚀 AGENT SPAWN TEMPLATES

### Template Format

Each spawn includes:
- **Task name**: Clear identifier
- **Goal**: What success looks like
- **Context**: Files to read before starting
- **Deliverables**: Specific files/features to create
- **Time estimate**: Expected completion time
- **Model**: Sonnet (default) or Opus (complex)
- **Dependencies**: What needs to be done first

---

## 📅 WEEK 1: Foundation Bugs

### Spawn 1: P1 Bug Fixes Agent

```
Task: "Fix all P1 bugs from BUG_HUNT_REPORT.md"

Goal: Zero P1 bugs remaining

Context:
- Read: BUG_HUNT_REPORT.md (P1 section)
- Read: Affected files listed in each bug report

Deliverables:
- Fix P1-2 (water parameter validation)
- Fix P1-3 (tank volume validation)
- Fix P1-7 (import/export ID remapping)
- Fix P1-8 (settings provider race condition)
- Fix P1-10 (TextFormField memory leaks)
- Fix P1-11 (onboarding error handling)
- Commit: "fix: resolve all P1 bugs"
- Document: Brief summary of each fix in BUG_TRACKER.md

Time: 12 hours
Model: sonnet (straightforward bug fixes)
Dependencies: None (can start immediately)

Success criteria:
- All P1 bugs have code fixes applied
- Each fix has a test case (manual or unit test)
- No regressions (existing features still work)
- flutter analyze passes
```

---

### Spawn 2: Testing Infrastructure Agent

```
Task: "Set up testing infrastructure and write 3 critical flow tests"

Goal: Testing framework operational + core paths tested

Context:
- Read: Flutter testing docs
- Read: Riverpod testing guide
- Look at existing tests in test/ directory

Deliverables:
- test/helpers/test_helpers.dart (mock providers, test utilities)
- test/helpers/mock_storage.dart (in-memory test storage)
- test/flows/onboarding_flow_test.dart (new user → first tank)
- test/flows/lesson_completion_flow_test.dart (lesson → quiz → XP)
- test/flows/water_log_flow_test.dart (add log → view charts)
- Update README.md with testing instructions
- CI configuration (if applicable)

Time: 6 hours
Model: sonnet
Dependencies: None

Success criteria:
- flutter test runs successfully
- All 3 flow tests pass
- Test coverage report shows baseline coverage
- Tests are maintainable (good helpers)
```

---

## 📅 WEEK 2: Accessibility

### Spawn 3: Accessibility Agent (Full Sprint)

```
Task: "Achieve 95/100 accessibility score"

Goal: App is fully accessible to screen reader users

Context:
- Read: ACCESSIBILITY_FIXES.md
- Read: UI_UX_POLISH_REPORT.md (accessibility section)
- Read: Flutter accessibility guide

Deliverables:
Day 1:
- Add semantic labels to all IconButtons (13 missing)
- Add labels to GestureDetectors
- Add labels to custom widgets
- Test with TalkBack/VoiceOver
- Commit: "a11y: add semantic labels"

Day 2:
- Fix color contrast (Ocean/Midnight themes)
- Ensure all touch targets ≥44dp
- Add focus indicators where missing
- Commit: "a11y: contrast and touch targets"

Day 3-4:
- Add form field labels and helper text
- Implement error announcements
- Add keyboard navigation support
- Test entire app with screen reader
- Commit: "a11y: forms and keyboard nav"

Documentation:
- Update ACCESSIBILITY_FIXES.md with completion status
- Create ACCESSIBILITY_TESTING_GUIDE.md

Time: 24 hours (3 days of 8-hour sprints)
Model: sonnet
Dependencies: Standard widgets created (Week 2 Day 5)

Success criteria:
- Accessibility score: 95/100
- Screen reader can navigate all screens
- All interactive elements have labels
- Color contrast WCAG AA compliant
- Touch targets meet 44dp minimum
```

---

## 📅 WEEK 3: Core Features (3 Agents!)

### Spawn 4: Hearts Implementation Agent

```
Task: "Implement Hearts system from HEARTS_SYSTEM_IMPLEMENTATION.md"

Goal: Fully functional hearts/lives system

Context:
- Read: HEARTS_SYSTEM_IMPLEMENTATION.md (complete guide)
- Read: HEARTS_SYSTEM_CHECKLIST.md (task list)
- Read: Duolingo hearts analysis

Deliverables:
Phase 1: Data Model (4 hours)
- lib/models/user_profile.dart (+150 lines)
- Add: currentHearts, lastHeartLost, unlimitedHeartsEnabled
- Add: hasHearts, heartsRefillable, timeUntilNextHeart getters
- Test: User profile serialization with hearts

Phase 2: Provider Logic (3 hours)
- lib/providers/user_profile_provider.dart (+80 lines)
- Methods: loseHeart(), refillHearts(), earnHeartFromPractice()
- Method: toggleUnlimitedHearts()
- Test: Heart loss/refill logic

Phase 3: UI Widgets (3 hours)
- lib/widgets/hearts_display.dart (~150 lines)
- lib/screens/practice_required_screen.dart (~200 lines)
- lib/screens/practice_mode_screen.dart (~350 lines)

Phase 4: Integration (2 hours)
- lib/screens/lesson_screen.dart (integrate hearts)
- lib/screens/settings_screen.dart (unlimited toggle)
- End-to-end testing

Time: 12 hours
Model: sonnet (well-documented, straightforward)
Dependencies: None (extends existing models)

Success criteria:
- Hearts displayed in all lesson contexts
- Lose 1 heart per wrong answer
- Practice mode unlocks when hearts depleted
- Auto-refill works (1 heart / 5 hours)
- Settings toggle disables system
- No bugs in heart calculations
```

---

### Spawn 5: Gems Economy Backend Agent

```
Task: "Implement gem economy backend (models, providers, rewards)"

Goal: Users earn gems for learning actions

Context:
- Read: LINGOTS_SHOP_IMPLEMENTATION.md
- Read: LINGOTS_QUICK_START.md
- Read: Existing models/user_profile.dart

Deliverables:
Phase 1: Data Models (3 hours)
- lib/models/gem_transaction.dart (already created, verify)
- lib/models/shop_item.dart (already created, verify)
- lib/models/purchase_result.dart (already created, verify)
- lib/models/gem_economy.dart (already created, verify)
- lib/data/shop_catalog.dart (already created, verify)

Phase 2: UserProfile Extension (3 hours)
- Extend UserProfile with:
  - int gems
  - List<GemTransaction> gemTransactions
  - Map<String, InventoryItem> inventory
  - List<String> activeEffects
- Update toJson/fromJson serialization
- Migration plan for existing users

Phase 3: Provider Methods (4 hours)
- lib/providers/user_profile_provider.dart
- Method: awardGems(amount, reason)
- Method: purchaseItem(itemId) with validation
- Method: activateItem(itemId)
- Method: hasActiveEffect(effectType)
- Hook into completeLesson() to award gems
- Hook into recordActivity() for streak gems
- Hook into unlockAchievement() for achievement gems

Phase 4: Testing (2 hours)
- Unit tests for gem economy
- Test earning scenarios
- Test purchase validation
- Test inventory management

Time: 12 hours
Model: sonnet
Dependencies: None (just extends UserProfile)

Success criteria:
- Users earn 5 gems per lesson completion
- Users earn 5 gems per daily goal
- Users earn 10-50 gems for achievements
- Gem balance persists across sessions
- Transaction history tracked
- No gem exploits (can't get negative gems)
```

---

## 📅 WEEK 4: Gamification Complete

### Spawn 6: Leaderboards Agent

```
Task: "Implement leaderboard system with league progression"

Goal: Weekly XP competition with promotion/demotion

Context:
- Read: LEADERBOARDS_IMPLEMENTATION.md
- Read: Duolingo leaderboard analysis
- Understand existing XP system

Deliverables:
Phase 1: Data Models (3 hours)
- lib/models/leaderboard.dart
- LeaderboardEntry model (userId, username, weeklyXP, rank)
- League enum (Bronze → Diamond, 10 leagues)
- LeaderboardState model (user's league, rank, entries)

Phase 2: Provider Logic (4 hours)
- lib/providers/leaderboard_provider.dart (already exists, enhance)
- Generate mock leaderboard (30 users per league)
- Weekly reset mechanism (Monday 00:00)
- Promotion logic (top 10 → up)
- Demotion logic (bottom 5 → down)
- User rank calculation

Phase 3: UI Screen (4 hours)
- lib/screens/leaderboard_screen.dart (already exists, enhance)
- League badge display
- User highlight in list
- Weekly countdown timer
- Promotion/demotion zone indicators
- Empty state for new users

Phase 4: Integration (1 hour)
- Update home screen with leaderboard access
- Add XP tracking hooks
- Test weekly reset logic
- Test promotion/demotion

Time: 12 hours
Model: sonnet
Dependencies: XP system functional (already is)

Success criteria:
- 30 users per leaderboard
- User appears in correct league
- Weekly XP totals accurate
- Promotion/demotion works correctly
- UI shows league progression clearly
- No performance issues with calculations
```

---

### Spawn 7: Celebrations & Animations Agent

```
Task: "Create celebrations animation library"

Goal: Delightful animations for achievements, level-ups, streaks

Context:
- Read: CELEBRATIONS_IMPLEMENTATION.md
- Read: CELEBRATIONS_QUICKSTART.md
- Look at existing animation code

Deliverables:
Phase 1: Animation Widgets (4 hours)
- lib/widgets/confetti_animation.dart (lesson completion)
- lib/widgets/level_up_animation.dart (level milestone)
- lib/widgets/streak_animation.dart (streak milestone)
- lib/widgets/achievement_unlock_animation.dart
- Use confetti package + Lottie animations

Phase 2: Celebration Service (3 hours)
- lib/services/celebration_service.dart
- triggerCelebration(CelebrationType)
- Coordinate animations + sound + haptic feedback
- Queue system (don't overlap celebrations)

Phase 3: Integration (4 hours)
- Integrate into lesson completion flow
- Integrate into achievement unlock
- Integrate into level-up
- Integrate into streak milestones
- Add celebration sound effects
- Add haptic feedback

Phase 4: Polish (1 hour)
- Test all celebration triggers
- Adjust timing and effects
- Ensure smooth performance
- Add settings toggle (disable animations)

Time: 12 hours
Model: sonnet
Dependencies: Core features (hearts, gems) for integration

Success criteria:
- Confetti plays on lesson completion
- Level-up animation is satisfying
- Streak milestones feel special
- Achievements unlock with fanfare
- No animation jank or lag
- User can disable if desired
```

---

## 📅 WEEK 5: Content Explosion (4 AGENTS!)

**This is the most parallelizable week - 4 agents writing content independently**

### Spawn 8: Beginner Content Agent

```
Task: "Write 25 beginner aquarium lessons with quizzes"

Goal: Comprehensive beginner curriculum

Context:
- Read: data/lesson_content.dart (existing lessons)
- Read: Duolingo lesson structure
- Review: Beginner topics list

Deliverables:
5 Lesson Packs (5 lessons each):

Pack 1: Nitrogen Cycle (foundational)
- Lesson 1: What is the nitrogen cycle?
- Lesson 2: Beneficial bacteria basics
- Lesson 3: Cycling your first tank
- Lesson 4: Testing water parameters
- Lesson 5: Nitrogen cycle problems
Each: 300-500 words + 5-question quiz

Pack 2: Equipment Basics
- Lesson 6: Choosing the right filter
- Lesson 7: Heater selection and safety
- Lesson 8: Lighting for beginners
- Lesson 9: Air pumps and aeration
- Lesson 10: Essential test kits

Pack 3: Water Chemistry 101
- Lesson 11: Understanding pH
- Lesson 12: Ammonia dangers
- Lesson 13: Nitrite toxicity
- Lesson 14: Nitrate management
- Lesson 15: Water hardness (GH/KH)

Pack 4: First Fish Selection
- Lesson 16: Beginner-friendly fish
- Lesson 17: Stocking calculations
- Lesson 18: Acclimating new fish
- Lesson 19: Feeding basics
- Lesson 20: Observing fish behavior

Pack 5: Tank Maintenance
- Lesson 21: Water change routine
- Lesson 22: Gravel vacuuming
- Lesson 23: Filter maintenance
- Lesson 24: Glass cleaning
- Lesson 25: Common beginner mistakes

Format per lesson:
- Title and difficulty tag
- Learning objectives (3-5 bullets)
- Main content (300-500 words)
- Key takeaways (3-5 bullets)
- Quiz (5 multiple-choice questions)
- XP reward: 10 XP
- Estimated time: 5 minutes

File: lib/data/lesson_content_beginner.dart

Time: 18 hours (25 lessons × ~40 min each)
Model: sonnet (content generation)
Dependencies: None

Success criteria:
- All 25 lessons are accurate and well-written
- Quizzes test actual comprehension
- Content flows logically (easier → harder)
- No factual errors
- Engaging, friendly tone
```

---

### Spawn 9: Intermediate Content Agent

```
Task: "Write 15 intermediate aquarium lessons with quizzes"

Goal: Intermediate curriculum for experienced beginners

Context:
- Read: Beginner lessons (for consistency)
- Research: Planted tank care, disease management
- Review: Intermediate topics list

Deliverables:
3 Lesson Packs (5 lessons each):

Pack 1: Planted Tanks
- Lesson 26: Low-tech vs. high-tech planted tanks
- Lesson 27: Substrate for planted tanks
- Lesson 28: CO2 injection basics
- Lesson 29: Fertilization strategies
- Lesson 30: Algae control in planted tanks

Pack 2: Disease Prevention & Treatment
- Lesson 31: Common fish diseases (Ich, fin rot, etc.)
- Lesson 32: Hospital tank setup
- Lesson 33: Medication safety
- Lesson 34: Quarantine procedures
- Lesson 35: Disease prevention best practices

Pack 3: Advanced Water Chemistry
- Lesson 36: Advanced pH management
- Lesson 37: Buffering capacity explained
- Lesson 38: Trace elements and minerals
- Lesson 39: RO/DI water systems
- Lesson 40: Water testing deep dive

Format: Same as beginner (300-500 words, 5-question quiz, 15 XP)

File: lib/data/lesson_content_intermediate.dart

Time: 12 hours
Model: sonnet
Dependencies: None (can run parallel with beginner agent)

Success criteria:
- Content is more detailed than beginner
- Assumes basic knowledge (doesn't re-explain nitrogen cycle)
- Quizzes are more challenging
- Accurate information
- Builds on beginner lessons
```

---

### Spawn 10: Advanced Content Agent

```
Task: "Write 10 advanced aquarium lessons with quizzes"

Goal: Expert-level content for serious hobbyists

Context:
- Read: Beginner + intermediate lessons
- Research: Breeding, reef aquariums, aquascaping
- Review: Advanced topics list

Deliverables:
3 Lesson Packs:

Pack 1: Breeding Fundamentals (3 lessons)
- Lesson 41: Breeding basics (egg layers vs. livebearers)
- Lesson 42: Fry care and raising juveniles
- Lesson 43: Breeding ethics and responsibility

Pack 2: Reef Aquarium Introduction (3 lessons)
- Lesson 44: Saltwater vs. freshwater differences
- Lesson 45: Reef tank equipment essentials
- Lesson 46: Coral care basics

Pack 3: Aquascaping (4 lessons)
- Lesson 47: Aquascaping styles (Iwagumi, Dutch, etc.)
- Lesson 48: Hardscape materials and placement
- Lesson 49: Plant selection for aquascaping
- Lesson 50: Maintaining a show-quality tank

Format: Same structure, 20 XP per lesson

File: lib/data/lesson_content_advanced.dart

Time: 8 hours
Model: sonnet
Dependencies: None (parallel)

Success criteria:
- Expert-level detail
- Assumes intermediate knowledge
- Content is aspirational (motivates users)
- Accurate and well-researched
- Challenges advanced users
```

---

## 📅 WEEK 6: Stories Mode

### Spawn 11: Stories Backend Agent

```
Task: "Implement Story data models and progress tracking"

Goal: Story engine functional, ready for UI

Context:
- Read: STORIES_MODE_IMPLEMENTATION.md
- Read: STORIES_MODE_SUMMARY.md
- Look at lib/data/story_content.dart

Deliverables:
Phase 1: Core Models (4 hours)
- lib/models/story.dart
- Story model (id, title, chapters, difficulty, xpReward)
- StoryChapter model
- StoryNode base class
- DialogueNode, NarrationNode, ChoiceNode, ComprehensionNode
- ImageNode (optional)
- StoryProgress model (currentChapter, currentNode, choices)

Phase 2: Story Data (4 hours)
- Verify lib/data/story_content.dart has 5 stories
- If not, create/complete stories:
  - First Tank Setup (beginner)
  - Ammonia Spike Emergency (intermediate)
  - The Sick Betta (intermediate)
  - Planted Tank Transformation (advanced)
  - Breeding Project Gone Wrong (advanced)

Phase 3: UserProfile Integration (2 hours)
- Extend UserProfile with storyProgress map
- Extend UserProfile with completedStories list
- Update serialization

Phase 4: Provider Logic (2 hours)
- lib/providers/user_profile_provider.dart
- Method: loadStoryProgress(storyId)
- Method: saveStoryProgress(storyId, progress)
- Method: completeStory(storyId, xpEarned)
- Method: getRecommendedStories()

Time: 12 hours
Model: sonnet
Dependencies: None

Success criteria:
- All story models compile without errors
- 5 complete stories with branching
- Story progress persists
- XP awarded on completion
- Can resume stories mid-way
```

---

### Spawn 12: Stories UI Agent

```
Task: "Build Story player UI screens"

Goal: Interactive story player with choices and quizzes

Context:
- Read: STORIES_MODE_IMPLEMENTATION.md (UI section)
- Read: Existing story models
- Look at lesson_screen.dart for inspiration

Deliverables:
Phase 1: Story List Screen (3 hours)
- lib/screens/story_list_screen.dart (~400 lines)
- Group stories by difficulty
- Show progress indicators
- Show XP rewards and time estimates
- Tap to start story

Phase 2: Story Player Screen (6 hours)
- lib/screens/story_screen.dart (~700 lines)
- Render DialogueNode (character avatars, dialogue bubbles)
- Render NarrationNode (descriptive text)
- Render ChoiceNode (branch selection buttons)
- Render ComprehensionNode (quiz questions)
- Progress indicator (chapter/node)
- Save/resume functionality
- Chapter transition animations

Phase 3: Story Widgets (2 hours)
- lib/widgets/character_avatar.dart
- lib/widgets/dialogue_bubble.dart
- lib/widgets/story_choice_button.dart
- lib/widgets/story_progress_bar.dart

Phase 4: Integration (1 hour)
- Add Stories section to learn screen
- Navigation from story list → player
- Test all story types
- Test save/resume

Time: 12 hours
Model: sonnet
Dependencies: Story backend agent (Spawn 11) complete

Success criteria:
- All 5 stories are playable
- Choices branch correctly
- Quizzes provide feedback
- Save/resume works
- Animations smooth
- UI is engaging and readable
```

---

## 📅 WEEK 7: Shop + Onboarding

### Spawn 13: Shop UI Agent

```
Task: "Build Gems Shop UI from LINGOTS_SHOP_IMPLEMENTATION.md"

Goal: Fully functional shop with purchases

Context:
- Read: LINGOTS_SHOP_IMPLEMENTATION.md (UI section)
- Read: Gems economy backend (already implemented)
- Read: shop_catalog.dart

Deliverables:
Phase 1: Shop Screen (4 hours)
- lib/screens/gem_shop_screen.dart (~500 lines)
- Tabbed layout (Power-Ups, Extras, Cosmetics)
- Category filtering
- Gem balance display in app bar
- Grid layout for items

Phase 2: Shop Item Card (3 hours)
- lib/widgets/shop_item_card.dart (~200 lines)
- Item icon/image
- Item name and description
- Gem cost
- Purchase button
- "Owned" indicator for purchased items
- Tap to see details

Phase 3: Purchase Flow (3 hours)
- Purchase confirmation dialog
- Insufficient gems error dialog
- Success animation (gem deduction)
- Inventory update
- Add to UserProfile inventory

Phase 4: Gem Balance Widget (2 hours)
- lib/widgets/gem_balance_widget.dart (~100 lines)
- Shows current gem count
- Animated gem increase/decrease
- Tap to show transaction history
- Place in navigation bar

Time: 12 hours
Model: sonnet
Dependencies: Gems backend (Week 3 Spawn 5)

Success criteria:
- Shop displays all 13 items
- Can purchase items (gems deducted)
- Inventory tracks owned items
- Can't purchase if insufficient gems
- Gem balance updates in real-time
- Purchase animations delightful
```

---

### Spawn 14: Placement Test Agent

```
Task: "Implement adaptive placement test"

Goal: Smart onboarding that places users at correct difficulty

Context:
- Read: PLACEMENT_TEST_IMPLEMENTATION.md
- Read: PLACEMENT_TEST_SUMMARY.md
- Look at existing quiz logic

Deliverables:
Phase 1: Placement Test Data (2 hours)
- lib/data/placement_test_content.dart (~300 lines)
- 20 questions covering beginner → advanced
- Questions tagged with difficulty
- Adaptive difficulty algorithm

Phase 2: Placement Test Screen (4 hours)
- lib/screens/placement_test_screen.dart (~400 lines)
- Question display
- Multiple choice answers
- Adaptive difficulty (gets harder if correct)
- Progress indicator
- Can skip test (start from beginning)

Phase 3: Result Screen (2 hours)
- lib/screens/placement_result_screen.dart (already exists, enhance)
- Show skill level determined
- Recommend starting lesson
- Show topics to review
- Celebrate completion

Phase 4: Integration (1 hour)
- Add to enhanced onboarding flow
- Show after goal setting
- Save results to UserProfile
- Unlock appropriate lessons

Time: 8 hours
Model: sonnet
Dependencies: Lesson content (Week 5)

Success criteria:
- Test adapts to user performance
- Results are accurate (places users correctly)
- Can skip test if preferred
- Recommendations are helpful
- Results persist
```

---

## 📅 WEEK 8: Notifications + Analytics

### Spawn 15: Push Notifications Agent

```
Task: "Set up push notifications system with Firebase"

Goal: Personalized reminders drive daily engagement

Context:
- Read: PUSH_NOTIFICATIONS_IMPLEMENTATION.md
- Read: Firebase Cloud Messaging docs
- Read: Duolingo notification strategy

Deliverables:
Phase 1: Firebase Setup (2 hours)
- Add firebase_messaging dependency
- Configure Android/iOS for FCM
- Set up notification permissions
- Test basic notification

Phase 2: Notification Service (4 hours)
- lib/services/notification_service.dart (~400 lines)
- scheduleNotification(type, time)
- cancelNotification(id)
- Notification types:
  - Daily practice reminder
  - Streak at risk (late night)
  - Friend activity
  - Water change reminder
  - Test parameter reminder
  - Achievement unlocked

Phase 3: Notification Scheduling (3 hours)
- Schedule daily practice (user's preferred time)
- Schedule streak saver (11 PM if not completed)
- Schedule task reminders (equipment maintenance, etc.)
- Weekly leaderboard updates
- Use flutter_local_notifications for scheduling

Phase 4: Preferences Screen (3 hours)
- lib/screens/notification_preferences_screen.dart
- Toggle for each notification type
- Time picker for daily reminder
- Frequency settings
- Test notification button
- Save preferences to UserProfile

Time: 12 hours
Model: sonnet
Dependencies: Core features (lessons, streaks, tasks)

Success criteria:
- Notifications deliver reliably
- User can customize preferences
- Streak saver fires at 11 PM
- Notifications are actionable (deep link to app)
- No spam (respectful frequency)
```

---

### Spawn 16: Analytics Agent

```
Task: "Integrate Firebase Analytics with comprehensive event tracking"

Goal: Track all key metrics (CURR, retention, engagement)

Context:
- Read: Firebase Analytics docs
- Read: Duolingo metrics strategy (CURR focus)
- Review: Key events to track

Deliverables:
Phase 1: Firebase Analytics Setup (1 hour)
- Add firebase_analytics dependency
- Configure for iOS/Android
- Test basic event logging

Phase 2: Analytics Service (3 hours)
- lib/services/analytics_service.dart (~300 lines)
- logEvent(name, parameters)
- logScreenView(screenName)
- setUserProperty(property, value)
- Convenience methods for common events

Phase 3: Event Integration (4 hours)
- Integrate into all key actions:
  - Lesson completed (lessonId, xpEarned, duration)
  - Quiz answered (correct/incorrect, questionId)
  - Story completed (storyId, choices made)
  - Item purchased (itemId, gemCost)
  - Streak milestone (days)
  - Achievement unlocked (achievementId)
  - Water change logged (tankId)
  - Friend added (friendId)
  - Settings changed

Phase 4: Dashboard Setup (2 hours)
- Create Firebase Analytics dashboard
- Set up retention cohorts
- Create CURR calculation (custom metric)
- Set up engagement funnels
- Document: ANALYTICS_GUIDE.md

Time: 6 hours
Model: sonnet
Dependencies: All core features implemented

Success criteria:
- All key events tracked
- Events visible in Firebase console
- CURR calculation accurate
- Retention cohorts set up
- No PII logged (privacy compliant)
- Events are actionable (inform decisions)
```

---

## 📅 WEEK 9: Performance + Polish

### Spawn 17: Performance Agent

```
Task: "Optimize app performance (startup, FPS, memory)"

Goal: <2s startup, consistent 60fps, <200MB memory

Context:
- Read: PERFORMANCE_REPORT.md
- Read: Flutter performance best practices
- Profiling tools: Flutter DevTools

Deliverables:
Phase 1: Profiling (3 hours)
- Profile startup time (target: <2s)
- Profile memory usage (target: <200MB)
- Identify FPS drops (target: 60fps)
- Find expensive rebuilds
- Document: PERFORMANCE_BASELINE.md

Phase 2: Startup Optimization (3 hours)
- Lazy load providers
- Defer non-critical initialization
- Optimize asset loading
- Profile again → verify improvement

Phase 3: Runtime Optimization (3 hours)
- Optimize image loading (caching, compression)
- Add RepaintBoundary to expensive widgets
- Use const constructors aggressively
- Optimize list rendering (ListView.builder)
- Profile FPS → verify 60fps

Phase 4: Memory Optimization (3 hours)
- Fix any memory leaks
- Optimize image cache size
- Clear unused providers
- Test long sessions (30+ minutes)
- Profile memory → verify <200MB

Time: 12 hours
Model: sonnet (systematic optimization)
Dependencies: All features complete (to avoid premature optimization)

Success criteria:
- Startup time <2 seconds (cold start)
- Consistent 60fps (no jank)
- Memory usage <200MB (long session)
- No memory leaks
- App feels snappy and responsive
```

---

### Spawn 18: UI Polish Agent

```
Task: "Visual polish pass across all screens"

Goal: Consistent, delightful UI throughout app

Context:
- Read: UI_UX_POLISH_REPORT.md
- Read: WIDGET_TEMPLATES.md
- Look at existing design system

Deliverables:
Phase 1: Standard Widget Migration (4 hours)
- Replace ad-hoc empty states with AppEmptyState
- Replace error displays with AppErrorState
- Replace loading indicators with AppLoadingIndicator
- Standardize all card layouts
- Update 20+ screens

Phase 2: Spacing & Typography (3 hours)
- Replace all hardcoded spacing (8.0, 16.0) with theme values
- Ensure consistent text styles
- Fix any typography inconsistencies
- Update: lib/theme/app_theme.dart

Phase 3: Animation Polish (3 hours)
- Review all animations (timing, easing)
- Add micro-interactions (button presses, card taps)
- Polish transitions between screens
- Add haptic feedback where appropriate
- Ensure all animations are smooth (no jank)

Phase 4: Tablet Optimization (2 hours)
- Test on tablet
- Optimize layouts for larger screens
- Two-column layouts where appropriate
- Test on different orientations
- Update responsive breakpoints

Time: 12 hours
Model: sonnet
Dependencies: Standard widgets (Week 2), all features

Success criteria:
- Visual consistency across all screens
- No hardcoded spacing/colors
- All animations smooth and delightful
- Tablet layouts work well
- App feels polished and professional
```

---

## 📅 WEEK 10: Testing

### Spawn 19: Unit Testing Agent

```
Task: "Write unit tests for 80% code coverage"

Goal: Comprehensive unit test suite

Context:
- Read: Existing tests in test/
- Review: All models and providers
- Read: Riverpod testing guide

Deliverables:
Phase 1: Model Tests (4 hours)
- test/models/user_profile_test.dart
- test/models/lesson_progress_test.dart
- test/models/story_test.dart
- test/models/gem_transaction_test.dart
- test/models/shop_item_test.dart
- test/models/leaderboard_test.dart
- Test serialization, getters, methods

Phase 2: Provider Tests (5 hours)
- test/providers/user_profile_provider_test.dart
- test/providers/friends_provider_test.dart
- test/providers/leaderboard_provider_test.dart
- Test state changes, async operations
- Mock dependencies

Phase 3: Service Tests (3 hours)
- test/services/storage_service_test.dart
- test/services/notification_service_test.dart
- test/services/analytics_service_test.dart
- test/services/celebration_service_test.dart

Time: 12 hours
Model: sonnet
Dependencies: All features complete

Success criteria:
- Test coverage ≥80%
- All tests pass
- Tests are maintainable
- Tests run fast (<30 seconds)
- CI/CD runs tests automatically
```

---

### Spawn 20: Integration Testing Agent

```
Task: "Write integration tests for critical user flows"

Goal: End-to-end tests for key scenarios

Context:
- Read: Flutter integration testing guide
- Identify: Critical user paths
- Review: Existing widget tests

Deliverables:
Phase 1: Critical Flow Tests (6 hours)
- test_driver/onboarding_flow_test.dart
  - New user → goal selection → first lesson → completion
- test_driver/learning_flow_test.dart
  - Browse lessons → start lesson → quiz → earn XP
- test_driver/social_flow_test.dart
  - Add friend → view leaderboard → send encouragement
- test_driver/story_flow_test.dart
  - Start story → make choices → complete → earn XP
- test_driver/shop_flow_test.dart
  - Earn gems → browse shop → purchase item → use item

Phase 2: Widget Tests (4 hours)
- test/widgets/hearts_display_test.dart
- test/widgets/gem_balance_widget_test.dart
- test/widgets/shop_item_card_test.dart
- test/widgets/confetti_animation_test.dart
- test/widgets/story_progress_bar_test.dart

Phase 3: Edge Case Tests (2 hours)
- Test offline scenarios
- Test low memory scenarios
- Test network failures
- Test data corruption recovery

Time: 12 hours
Model: sonnet
Dependencies: All features, unit tests complete

Success criteria:
- All critical paths tested end-to-end
- Tests cover happy path + error cases
- Widget tests cover custom widgets
- Tests run on CI/CD
- Integration tests run on emulator/device
```

---

## 📅 WEEK 12: Launch Prep

### Spawn 21: Marketing Assets Agent

```
Task: "Create professional app screenshots, demo video, and marketing materials"

Goal: Store-ready marketing assets

Context:
- Read: Google Play Store screenshot requirements
- Read: App Store screenshot requirements
- Review: Competitor app listings

Deliverables:
Phase 1: Screenshots (6 hours)
- 10-15 professional screenshots:
  - Home screen with vibrant tank
  - Lesson in progress (show learning)
  - Quiz completion (show gamification)
  - Story mode (show engagement)
  - Leaderboard (show competition)
  - Streak calendar (show retention)
  - Gem shop (show economy)
  - Social friends screen
  - Water log with charts
  - Tank detail with parameters
- Clean UI (remove debug info)
- Add captions/annotations
- Multiple device frames (phone/tablet)

Phase 2: Demo Video (4 hours)
- Record 1-2 minute app walkthrough
- Show key features:
  - Onboarding experience
  - Completing a lesson
  - Earning achievements
  - Social features
  - Aquarium management
- Add background music
- Add captions/text overlays
- Export in store-required formats

Phase 3: Social Media Assets (2 hours)
- Create animated GIFs for key features
- Create Twitter/Reddit announcement images
- Create feature highlight graphics
- Create app icon variants (promotional)

File deliverables in: design_references/marketing/

Time: 12 hours
Model: sonnet
Dependencies: App is feature-complete and polished

Success criteria:
- 10+ high-quality screenshots
- Demo video <2 minutes, professional quality
- All assets meet store requirements
- Visual consistency across assets
- Compelling presentation (makes users want to download)
```

---

### Spawn 22: Documentation Agent

```
Task: "Write comprehensive user-facing documentation"

Goal: Users can find help and get started easily

Context:
- Review: All app features
- Read: Best practices for app documentation
- Look at: Duolingo help center

Deliverables:
Phase 1: In-App Help (3 hours)
- lib/screens/help_center_screen.dart
- Categorized help articles:
  - Getting Started (5 articles)
  - Learning System (10 articles)
  - Aquarium Management (10 articles)
  - Troubleshooting (8 articles)
  - Account & Settings (5 articles)
- Search functionality
- Contact support button

Phase 2: FAQ Page (2 hours)
- Create: docs/FAQ.md
- 20-30 common questions:
  - How do I earn gems?
  - How does the hearts system work?
  - Why did my streak reset?
  - How do I add a friend?
  - How do water change reminders work?
  - Is there a premium version?
- Clear, concise answers

Phase 3: Privacy Policy & Terms (2 hours)
- docs/PRIVACY_POLICY.md
- docs/TERMS_OF_SERVICE.md
- Data collection disclosure
- User rights
- Contact information
- Legal compliance (GDPR, COPPA if applicable)

Phase 4: Release Notes Template (1 hour)
- docs/RELEASE_NOTES_TEMPLATE.md
- What's New format
- Feature highlight structure
- Bug fix presentation
- Future roadmap hints

Time: 8 hours
Model: sonnet
Dependencies: All features finalized

Success criteria:
- Help center covers all major features
- FAQ answers common user questions
- Privacy policy is compliant
- Documentation is clear and accessible
- Users can self-serve for most questions
```

---

## 📊 PARALLELIZATION SUMMARY

### Maximum Velocity Configuration

**Week 5 (Peak Parallelization):**
- Main Agent: Editorial review + integration
- Agent 1: Beginner lessons (25)
- Agent 2: Intermediate lessons (15)
- Agent 3: Advanced lessons (10)
- **Total**: 4 agents, 50 lessons in 1 week

**Weeks 3-4, 7-9, 10, 12:**
- 3 agents working simultaneously
- Main agent coordinates + critical path work
- 2-3 sub-agents on parallel tasks

**Average Weeks:**
- 2-3 agents active
- ~70% time savings vs. sequential

---

## ⚙️ COORDINATION STRATEGY

### Main Agent Responsibilities

1. **Context Bridging**: Share results between agents
2. **Integration**: Connect independently-built features
3. **Quality Control**: Review agent deliverables
4. **Priority Shifts**: Adjust based on blockers
5. **Critical Path**: Handle sequential dependencies
6. **Design Decisions**: Make architectural choices

### Agent Handoff Protocol

When spawning agent:
1. Provide clear task definition
2. Link to context documents
3. Specify deliverable format
4. Give time estimate
5. Define success criteria
6. State dependencies (what needs to be done first)

When agent completes:
1. Review deliverables
2. Test functionality
3. Integrate into main branch
4. Update roadmap status
5. Spawn next dependent agent

---

## 🎯 SUCCESS METRICS

### Velocity Gains

**Sequential Execution**:
- 12 weeks × 40 hours/week = 480 hours
- 1 agent, 12 weeks

**Parallel Execution (2 agents avg)**:
- Same 480 hours of work
- 2 agents = 240 hours real time
- 6 weeks calendar time
- **50% time savings**

**Parallel Execution (3 agents in busy weeks)**:
- Peak efficiency weeks: 3-4 agents
- Even faster in Week 5 (content creation)
- Estimated: **6-8 weeks** total vs. 12 weeks sequential

### Quality Maintenance

- Main agent reviews all work
- Integration testing between features
- Weekly quality gates still apply
- No compromise on standards

---

## ⚠️ RISKS & MITIGATION

### Integration Challenges

**Risk**: Features don't integrate smoothly  
**Mitigation**: Clear interfaces defined upfront, main agent tests integration

### Context Fragmentation

**Risk**: Agents make conflicting decisions  
**Mitigation**: Comprehensive context docs, main agent as arbiter

### Agent Availability

**Risk**: Can't spawn agents due to system issues  
**Mitigation**: Main agent can do any task (just slower), roadmap flexible

### Coordination Overhead

**Risk**: Managing multiple agents takes too much time  
**Mitigation**: Clear deliverables, async coordination, agents report back when done

---

## ✅ FINAL CHECKLIST

Before spawning any agent:

- [ ] Task is well-defined (clear goal, deliverables, success criteria)
- [ ] Context documents are up-to-date
- [ ] Dependencies are resolved (what needs to be done first)
- [ ] Time estimate is realistic
- [ ] Agent will have everything needed to complete task independently
- [ ] Deliverable format is specified (which files to create/modify)
- [ ] Integration points are clear (how this connects to existing code)
- [ ] Testing strategy is defined

After agent completes:

- [ ] Review all deliverables
- [ ] Test functionality manually
- [ ] Run automated tests (if applicable)
- [ ] Integrate into main codebase
- [ ] Update roadmap progress
- [ ] Document any learnings or issues
- [ ] Spawn next dependent agent (if any)

---

**STATUS**: ✅ READY TO EXECUTE

**Total Agents to Spawn**: 22 across 12 weeks  
**Peak Parallelization**: 4 agents (Week 5)  
**Average Active Agents**: 2.7  
**Estimated Time Savings**: 40-50% vs. sequential  

**Let's parallelize and ship faster!** 🚀

---

*Created: February 7, 2025*  
*For: Aquarium App Accelerated Development*  
*Strategy: Maximum parallelization with coordination*
