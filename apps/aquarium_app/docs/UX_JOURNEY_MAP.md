# Danio User Journey Map + UX Improvement Plan
Date: 2026-02-28

## App Architecture Overview

**Two navigation systems exist** (potential confusion):
- **HouseNavigator** — 6-room horizontal swipe: Study, Living Room, Friends, Leaderboard, Workshop, Shop Street
- **TabNavigator** — 5-tab bottom nav: Learn, Quiz, Tank, Smart, Settings

The `_AppRouter` in `main.dart` routes to `OnboardingScreen` → `ProfileCreationScreen` → `TabNavigator`. The HouseNavigator appears to be the older pattern. TabNavigator is the current primary shell.

**Current tab structure:**
| Tab | Screen | Purpose |
|-----|--------|---------|
| 0 - Learn | LearnScreen | Learning paths, lessons |
| 1 - Quiz | PracticeHubScreen | Spaced repetition, practice quizzes |
| 2 - Tank | HomeScreen | Tank dashboard, management |
| 3 - Smart | SmartScreen | AI features (Fish ID, Symptom Triage, Weekly Plan) |
| 4 - Settings | SettingsHubScreen | App settings |

---

## User Journeys

### Journey 1: First Launch
**Entry point:** App install → cold start

**Steps:**
1. App loads splash screen while checking onboarding state
2. `OnboardingScreen` shows 3 swipeable info pages (Track, Manage, Thrive)
3. Tap "Get Started" → `ProfileCreationScreen`
4. Enter name, select experience level, tank type, and goals
5. Tap "Create Profile" → `EnhancedPlacementTestScreen` (knowledge quiz)
6. Answer placement questions (multi-choice, with explanations)
7. See `PlacementResultScreen` with level assignment
8. Navigate to `TabNavigator` (main app)

**Friction points:**
- 🔴 **8+ steps before seeing the app** — high drop-off risk. Users must complete onboarding (3 pages) + profile creation (4 fields) + placement test before they see anything useful
- 🟡 **Placement test feels like homework** — new users who just want to track a tank are forced through an educational assessment
- 🟡 **No skip option on placement test** — profile creation has a "Skip" (dev/testing only with hardcoded values), but the test flow doesn't clearly let users defer
- 🟢 **First Tank Wizard exists** (`first_tank_wizard_screen.dart`) but unclear if it's wired into the current flow

**Missing:**
- Progressive onboarding — let users explore immediately, then prompt for profile details
- "Quick Start" path for experienced users who just want tank tracking
- Social proof / sample data to show what the app looks like populated

**Delight moments:**
- ✅ Celebration on onboarding completion ("Welcome Aboard! 🐠" with confetti milestone)
- ✅ Animated content transitions between onboarding pages
- ❌ No progress indicator showing "almost done" during profile creation

---

### Journey 2: Daily Return
**Entry point:** App reopen → Tab 2 (Tank / HomeScreen)

**Steps:**
1. See tank dashboard with current tank stats
2. Switch tanks via TankSwitcher widget
3. Tap tank card → `TankDetailScreen`
4. View quick stats (parameters, livestock count, stocking level)
5. Tap FAB → "Add Log" → `AddLogScreen`
6. Select log type (water test, water change, observation, etc.)
7. Enter water parameters (8 fields: temp, pH, ammonia, nitrite, nitrate, GH, KH, phosphate)
8. Save → XP awarded → return to tank detail

**Friction points:**
- 🔴 **Water test entry is 8 fields deep** — even with pre-fill from last values, that's a lot of manual entry for a daily task
- 🟡 **3 taps to start logging** — Home → Tank Detail → FAB → Add Log. Should be 1 tap from home
- 🟡 **No widget/notification prompt** — users must remember to open the app and log
- 🟢 **Bulk entry mode exists** but is hidden behind a "Quick" toggle that's easy to miss

**Missing:**
- Home screen quick-log button (bypass tank detail)
- NFC/barcode scanning for test strip results
- Notification reminders: "Time to test your water!"
- Historical comparison on the log entry screen ("Last time: pH 7.2, today: ___")

**Delight moments:**
- ✅ Pre-fills last test values (saves re-typing)
- ✅ XP awarded on log save
- ❌ No streak celebration for consecutive daily logging
- ❌ No "all parameters in safe range" celebration

---

### Journey 3: Learning
**Entry point:** Tab 0 (Learn) → `LearnScreen`

**Steps:**
1. See learning paths with progress bars
2. Tap a lesson → `LessonScreen`
3. Read through lesson content
4. Take quiz → `EnhancedQuizScreen`
5. Answer questions, get instant feedback
6. Earn XP → potential level-up → celebration
7. Cards added to spaced repetition deck
8. Return to learn screen → see updated progress

**Friction points:**
- 🟡 **Learn and Quiz are separate tabs** — user must switch between Tab 0 (Learn) and Tab 1 (Quiz/Practice) to do lessons vs. review. Could be confusing
- 🟡 **No clear "what to do next"** — learning paths show progress but don't highlight the recommended next lesson
- 🟢 **Badge on Quiz tab** shows due card count — good nudge

**Missing:**
- "Continue where you left off" card at top of Learn screen
- Lesson difficulty indication before starting
- Estimated time per lesson
- "Daily lesson" suggestion based on user level

**Delight moments:**
- ✅ Level-up celebrations with confetti (`LevelUpListener` wraps the entire app)
- ✅ XP earned per lesson/quiz
- ✅ Spaced repetition badge nudges review
- ❌ No streak-specific learning celebration
- ❌ No "course complete" milestone celebration

---

### Journey 4: Tank Management
**Entry point:** Tab 2 (Tank) → HomeScreen → tap tank

**Steps:**
1. HomeScreen shows current tank with room scene
2. Tank switcher to change active tank
3. Tap → `TankDetailScreen` dashboard
4. See: quick stats, cycling status, alerts, trends, livestock preview, equipment preview, task preview, recent logs
5. FAB menu: Add Log, Add Livestock, Add Equipment, Add Task
6. Add livestock → `LivestockScreen` → add species
7. View parameter charts → `ChartsScreen`
8. Tank settings → `TankSettingsScreen`

**Friction points:**
- 🔴 **Creating a new tank is a 3-page wizard** (`CreateTankScreen`) — Page 1: name + type, Page 2: volume + dimensions (4 fields), Page 3: water type + start date. That's 7+ fields minimum
- 🟡 **Tank detail screen is very dense** — quick stats, cycling card, alerts, trends, livestock, equipment, tasks, logs all on one scroll. Information overload
- 🟡 **No guided setup after creating a tank** — user creates tank and lands on empty dashboard with no guidance on what to do next

**Missing:**
- Tank templates ("60L Community Tank", "20L Betta Tank") for one-tap setup
- Empty state guidance: "Add your first fish" → "Log your first water test" → "Set up maintenance reminders"
- Photo of the actual tank as hero image
- Tank health score / summary badge

**Delight moments:**
- ✅ Room scene with themed decorative elements
- ✅ Speed dial FAB for quick actions
- ✅ Cycling status card for new tanks
- ❌ No celebration when adding first fish to a tank
- ❌ No "tank anniversary" reminder/celebration

---

### Journey 5: Social
**Entry point:** Tab navigation doesn't include Friends/Leaderboard directly (they're in HouseNavigator rooms 2 & 3, not in TabNavigator)

**Steps (via HouseNavigator):**
1. Swipe to Friends room (Room 2)
2. See friends list with search
3. TabBar: Friends | Activity
4. Add friend via dialog
5. Tap friend → `FriendComparisonScreen`
6. Swipe to Leaderboard room (Room 3)
7. See weekly XP leaderboard

**Steps (via TabNavigator):**
- ⚠️ **No direct access** — Friends and Leaderboard are NOT in the 5-tab navigation. Users would need to navigate from within another screen or the old HouseNavigator.

**Friction points:**
- 🔴 **Social features are orphaned** — the TabNavigator (current primary nav) has no Friends or Leaderboard tab. These screens exist but may be unreachable from the main navigation
- 🟡 **Demo data banner** — both Friends and Leaderboard show "Demo data" indicators, meaning these features may not be fully functional yet
- 🟡 **Friend comparison requires mock data** — `MockLeaderboard.generate()` creates simulated data

**Missing:**
- Social tab in TabNavigator (or accessible from Settings/Profile)
- Friend activity notifications
- Tank sharing / "visit friend's tank" feature
- Achievement comparison between friends
- In-app messaging

**Delight moments:**
- ❌ No social celebrations (e.g., "You overtook [friend] on the leaderboard!")
- ❌ No friend request notifications

---

### Journey 6: Achievement Hunting
**Entry point:** `AchievementsScreen` — accessible from PracticeHubScreen (Tab 1)

**Steps:**
1. Navigate to Achievements (Trophy Case)
2. See completion percentage and stats
3. Filter by category, rarity, or status (all/locked/unlocked)
4. Sort by rarity, date, progress, or name
5. Tap achievement → `AchievementDetailModal`
6. See progress towards locked achievements
7. Achievements auto-unlock via `AchievementProvider` checks

**Friction points:**
- 🟡 **Achievement screen is buried** — accessible from Practice Hub but not from the main tab bar or home screen
- 🟡 **No "almost there" nudges** — achievements at 80%+ completion don't surface as suggestions
- 🟢 **Good filtering and sorting** options

**Missing:**
- Achievement progress on home screen or profile
- "Featured achievement" card highlighting close-to-unlock achievements
- Achievement sharing (social proof)
- Achievement rarity stats ("Only 5% of users have this")

**Delight moments:**
- ✅ Achievement unlock triggers celebration dialog with gem reward
- ✅ Confetti on unlock
- ❌ No "rare achievement" extra-special celebration
- ❌ No achievement showcase/display feature

---

### Journey 7: Shop/Rewards
**Entry point:** HouseNavigator Room 5 (Shop Street) — or `GemShopScreen` for gem purchases

**Steps:**
1. Shop Street: see wishlist categories (Fish, Plants, Equipment)
2. Browse wishlists, manage budget, track local shops
3. Gem Shop: browse categories (Power-ups, Cosmetics, Extras)
4. See gem balance
5. Purchase item → confetti celebration
6. Items go to inventory

**Friction points:**
- 🔴 **Shop Street may be unreachable** from TabNavigator — same orphaning issue as Social features
- 🟡 **Two different "shops"** — Shop Street (real-world wishlist/budget) vs Gem Shop (in-app currency) serve different purposes but could confuse users
- 🟡 **Gem earning unclear** — how do users earn gems? Not obvious from the shop screen itself

**Missing:**
- Clear gem earning guide / "How to earn gems" section
- Shop access from main navigation
- Purchase previews (e.g., "See what this theme looks like before buying")
- Daily deals / limited-time offers for engagement
- "Gem doubler" first-purchase incentive

**Delight moments:**
- ✅ Confetti on purchase in Gem Shop
- ✅ Themed shop environments (treasure theme for Gem Shop, outdoor market for Shop Street)
- ❌ No "new item in shop" notification
- ❌ No unboxing/reveal animation for purchases

---

## Friction Point Summary

| Journey | Friction | Severity | Fix |
|---------|----------|----------|-----|
| First Launch | 8+ steps before seeing the app | 🔴 Critical | Defer placement test, allow exploration first |
| First Launch | Placement test feels mandatory | 🟡 Medium | Make it optional, suggest it later |
| Daily Return | 3 taps to start logging water | 🔴 Critical | Add quick-log FAB on home screen |
| Daily Return | 8 water parameter fields | 🔴 Critical | Smart defaults, test-strip camera scan, "only changed" mode |
| Learning | Learn vs Quiz split across tabs | 🟡 Medium | Merge or add "Review Due" card to Learn tab |
| Tank Mgmt | 3-page tank creation wizard | 🟡 Medium | Tank templates, reduce to 1 page with expandable details |
| Tank Mgmt | Dense tank detail screen | 🟡 Medium | Collapsible sections, priority-based ordering |
| Social | Features unreachable from TabNavigator | 🔴 Critical | Add social entry point to navigation |
| Social | All data is mock/demo | 🟡 Medium | Implement real backend or clearly mark as "coming soon" |
| Achievements | Buried in Practice Hub | 🟡 Medium | Surface on home/profile screen |
| Shop | Two shops, both orphaned from nav | 🔴 Critical | Consolidate or add to main navigation |
| Shop | Gem earning path unclear | 🟡 Medium | Add "Earn Gems" guide, show gem sources on home |

---

## Missing Delight Moments

| Moment | Where It Should Happen | Current State |
|--------|----------------------|---------------|
| First fish added to tank | Tank Detail → after adding livestock | ❌ No celebration |
| All parameters in safe range | After logging water test | ❌ No "Looking great!" feedback |
| Logging streak (7 days, 30 days) | After saving a log entry | ❌ No streak milestone |
| Course/path completion | After finishing all lessons in a path | ❌ No completion ceremony |
| Tank anniversary | Home screen on tank creation date | ❌ Not tracked |
| Leaderboard promotion | When moving up a league | ❌ No promotion animation |
| Friend overtaken | When surpassing a friend's XP | ❌ No competitive nudge |
| First achievement unlocked | Achievement screen | ✅ Exists — confetti + dialog |
| Level up | Anywhere in app | ✅ Exists — LevelUpListener + overlay |
| Gem purchase | Gem Shop | ✅ Exists — confetti |
| Onboarding complete | After profile creation | ✅ Exists — milestone celebration |
| Perfect quiz score | After quiz completion | ❌ No "perfect score" fanfare |
| 100th log entry | After saving log | ❌ No milestone |

---

## Onboarding Assessment

**Current flow length:** 8-12 steps (3 onboarding pages + 4 profile fields + 5-10 placement questions + results)

**Estimated time:** 3-5 minutes before seeing the app

**Drop-off risk:** HIGH — every extra step before value delivery loses ~20% of users

**What could be deferred:**
| Step | Current | Recommendation |
|------|---------|---------------|
| Onboarding pages (3 swipes) | Required first | Keep but make skippable after 1st page |
| Name entry | Required | Defer — use "Aquarist" default, prompt later |
| Experience level | Required | Defer — infer from behaviour or ask on first lesson |
| Tank type | Required | Defer — ask when creating first tank |
| Goals | Required | Defer — ask after 3 days of usage |
| Placement test | Part of flow | Make entirely optional — offer from Learn tab |

**Recommended flow:** Install → 1 welcome screen → "Create your first tank" (name + type only) → Home screen. Everything else prompted contextually.

---

## Data Entry UX Assessment

### Water Test Logging (AddLogScreen — 1,204 lines)

**Current fields:** Temperature, pH, Ammonia, Nitrite, Nitrate, GH, KH, Phosphate (8 fields)

**Good:**
- ✅ Pre-fills with last test values
- ✅ "Quick" bulk entry mode with compact grid
- ✅ "Leave blank if not tested" guidance
- ✅ Photo attachment support
- ✅ Notes field

**Problems:**
- 🔴 Even in "Quick" mode, 8 fields is a lot for a daily task
- 🟡 Bulk entry toggle is small and easy to miss
- 🟡 No validation against tank's target ranges during entry
- 🟡 No "same as last time" one-tap option

**Improvement ideas:**
1. **"Same as last time" button** — one tap for unchanged values, only modify what changed
2. **Inline range indicators** — show green/yellow/red next to each field based on tank targets
3. **Test strip camera scan** — photograph test strip, auto-read values (AI via Smart tab)
4. **Parameter presets** — "I only test pH and ammonia" → hide other fields by default
5. **Slider entry** — for common ranges (pH 6.0-8.5), sliders are faster than typing
6. **Voice entry** — "pH seven point two, ammonia zero" via speech-to-text

### Tank Creation (CreateTankScreen — 928 lines)

**Current:** 3-page wizard with 7+ fields

**Good:**
- ✅ Progress indicator
- ✅ Size presets available
- ✅ Water type auto-sets target ranges

**Problems:**
- 🟡 3 separate pages for what could be 1 scrollable form
- 🟡 Dimensions (L×W×H) are optional but take up a full page
- 🟡 No tank templates

**Improvement ideas:**
1. **Tank templates** — "Betta tank (20L)", "Community (60L)", "Planted (100L)" with pre-filled values
2. **Single page** with expandable "Advanced" section for dimensions
3. **Photo-first** — let users photograph their tank, then fill in details

---

## Top 20 UX Improvements

Prioritised by user impact (1 = highest).

| # | Improvement | Screen/Component | What to Change | Impact |
|---|------------|-----------------|----------------|--------|
| 1 | **Quick-log from home** | HomeScreen | Add persistent "Log Water" FAB that goes directly to AddLogScreen for current tank | 🔴 Reduces daily task from 3 taps to 1 |
| 2 | **Shorten onboarding** | OnboardingScreen, ProfileCreation | Reduce to 1 welcome page + tank name/type → home. Defer everything else | 🔴 Reduces drop-off by ~40% |
| 3 | **Fix orphaned features** | TabNavigator | Add a "More" tab or drawer menu with Friends, Leaderboard, Shop, Workshop, Achievements | 🔴 Makes 40% of features discoverable |
| 4 | **"Same as last time" log button** | AddLogScreen | One-tap to copy all values from last log, then edit only changes | 🔴 Reduces water test entry from 60s to 10s |
| 5 | **Tank templates** | CreateTankScreen | Offer 5-6 common tank presets (Betta, Community, Planted, Marine, Nano, Pond) | 🟡 Reduces tank creation from 7 fields to 1 tap + name |
| 6 | **Inline parameter warnings** | AddLogScreen | Show green/yellow/red indicator next to each field based on tank targets | 🟡 Immediate feedback, catches dangerous values |
| 7 | **"Continue learning" card** | LearnScreen | Hero card at top showing next recommended lesson + "Resume" button | 🟡 Reduces decision fatigue, increases lesson starts |
| 8 | **Empty tank onboarding** | TankDetailScreen | When tank is empty, show guided checklist: "Add fish → Log water → Set reminders" | 🟡 Prevents confusion after tank creation |
| 9 | **Bulk entry as default** | AddLogScreen | Make compact grid the default mode, move detailed entry to "Detailed" toggle | 🟡 Faster daily logging for most users |
| 10 | **Parameter customisation** | AddLogScreen/Settings | Let users choose which parameters they track (hide unused ones) | 🟡 Reduces form to 3-4 fields for most users |
| 11 | **Logging streak celebration** | AddLogScreen (on save) | Show streak counter + celebrate 7-day, 30-day, 100-day milestones | 🟡 Reinforces daily habit formation |
| 12 | **"All clear" celebration** | AddLogScreen (on save) | When all parameters are in safe range, show a satisfying "Your tank is thriving! 🌿" moment | 🟡 Positive reinforcement |
| 13 | **Achievement surface** | HomeScreen or Profile | Show 1-2 "almost unlocked" achievements on home screen | 🟡 Drives engagement without extra navigation |
| 14 | **Smart test strip scan** | AddLogScreen | Camera button to photograph test strips → AI reads values (uses Smart/OpenAI) | 🟡 Eliminates manual entry entirely |
| 15 | **Single-page tank creation** | CreateTankScreen | Merge 3 pages into 1 scrollable form, dimensions in expandable "Advanced" | 🟢 Less cognitive overhead |
| 16 | **Notification reminders** | System | "Time to test your water!" push notifications based on schedule | 🟢 Drives daily returns |
| 17 | **Gem earning visibility** | HomeScreen, GemShopScreen | Show "Ways to earn gems" section and gem sources breakdown | 🟢 Motivates engagement with reward system |
| 18 | **Perfect quiz celebration** | EnhancedQuizScreen | Special confetti + bonus XP for 100% quiz scores | 🟢 Rewards excellence |
| 19 | **Tank health badge** | HomeScreen, TankDetailScreen | Single emoji/colour badge summarising tank health (🟢🟡🔴) | 🟢 At-a-glance status without reading numbers |
| 20 | **Leaderboard promotion animation** | LeaderboardScreen | Animate league promotion/demotion at end of weekly period | 🟢 Competitive engagement |

---

## "10-Second Test" Results

For each major screen: can a new user understand what to do within 10 seconds?

| Screen | Verdict | Notes |
|--------|---------|-------|
| **OnboardingScreen** | ✅ Pass | Clear swipe-through with simple messaging and prominent CTA |
| **ProfileCreationScreen** | ✅ Pass | Form fields are labelled, purpose is clear |
| **HomeScreen (with tanks)** | 🟡 Partial | Tank cards are clear, but the room scene may confuse — is this a game? What do I tap? |
| **HomeScreen (empty)** | ❌ Fail | If user has no tanks, what does the empty room scene communicate? Need clear "Create your first tank" CTA |
| **TankDetailScreen** | 🟡 Partial | Lots of information — good for returning users, overwhelming for new ones. Quick stats section helps |
| **LearnScreen** | ✅ Pass | Learning paths with progress bars are intuitive. Clear next step |
| **PracticeHubScreen** | ✅ Pass | Due card count and practice buttons are clear |
| **AddLogScreen** | 🟡 Partial | Log type selector is clear, but 8 parameter fields may overwhelm first-time users. "Leave blank if not tested" helps |
| **CreateTankScreen** | ✅ Pass | Wizard with progress bar is clear. Name field is obvious first step |
| **SmartScreen** | ✅ Pass | Feature cards with icons and descriptions are immediately understandable |
| **FriendsScreen** | ✅ Pass | Tabs and add-friend button are clear. Demo banner is honest |
| **AchievementsScreen** | ✅ Pass | Trophy case metaphor works. Filters are discoverable |
| **GemShopScreen** | ✅ Pass | Gem balance prominent, items are browsable |
| **ShopStreetScreen** | 🟡 Partial | Wishlist concept may not be immediately obvious — "Is this a real shop?" |
| **WorkshopScreen** | ✅ Pass | Tool cards with clear descriptions |
| **LeaderboardScreen** | ✅ Pass | Standard leaderboard layout, immediately recognisable |

---

## Critical Architecture Issue

**Two navigation systems coexist:** `HouseNavigator` (6 rooms, swipe) and `TabNavigator` (5 tabs, bottom nav). The `_AppRouter` currently routes to `TabNavigator`, meaning **HouseNavigator's exclusive features (Friends, Leaderboard, Workshop, Shop Street) are potentially unreachable** unless linked from within TabNavigator screens.

**Recommendation:** Either:
1. **Fully commit to TabNavigator** — add a "More" or "Explore" tab with Friends, Leaderboard, Workshop, Shop
2. **Switch back to HouseNavigator** with a redesigned bottom bar
3. **Hybrid approach** — keep TabNavigator for core 5 tabs, add a hamburger/drawer menu for secondary features

This is the single biggest UX issue in the app. ~40% of built features may be invisible to users.
