# User Flow Documentation
## Aquarium App - Complete User Journey Maps

This document outlines all major user flows in the Aquarium App, combining learning system features with aquarium management.

---

## 🌟 Flow 1: First-Time User Flow

**Goal:** Successfully onboard a new user and get them to their first learning achievement.

```
┌─────────────────────────────────────────────────────────────────┐
│                        FIRST-TIME USER                           │
└─────────────────────────────────────────────────────────────────┘

1. App Launch (First Time)
   ↓
2. Splash Screen
   │
   ├─> Check onboarding status
   │   └─> Not completed → Continue to step 3
   │
3. Onboarding Screen
   │
   ├─> Welcome message
   ├─> App value proposition
   ├─> Swipe through introduction slides
   │   - Learn fishkeeping
   │   - Manage your tanks
   │   - Track your progress
   │
4. Profile Creation
   │
   ├─> Enter name (optional)
   ├─> Select experience level:
   │   - 🐣 Beginner (New to fishkeeping)
   │   - 🐟 Intermediate (Some experience)
   │   - 🦈 Expert (Experienced aquarist)
   ├─> Select primary tank type:
   │   - 🐠 Freshwater
   │   - 🐡 Marine (coming soon)
   ├─> Select goals (multiple):
   │   - ❤️ Happy, healthy fish
   │   - ✨ Beautiful display
   │   - 🥚 Breeding fish
   │   - 🏆 Show quality
   │   - 🧘 Relaxation & zen
   │
5. Placement Test (OPTIONAL)
   │
   ├─> User choice: Take test or skip
   │   │
   │   ├─> SKIP
   │   │   └─> Start at beginner level
   │   │
   │   └─> TAKE TEST
   │       ├─> 10-15 multiple choice questions
   │       ├─> Covers basic fishkeeping knowledge
   │       ├─> Get placement result
   │       │   - Beginner (0-40%)
   │       │   - Intermediate (41-70%)
   │       │   - Advanced (71-100%)
   │       └─> Lesson path adjusted based on result
   │
6. First Lesson
   │
   ├─> Recommended lesson based on placement
   ├─> Interactive content with images
   ├─> Quiz questions throughout
   ├─> Complete lesson
   ├─> Earn XP (typically 10 XP)
   ├─> Earn gems (5 gems for completion)
   ├─> Celebration animation
   │
7. Daily Goal Setup
   │
   ├─> Set daily XP goal (default: 50 XP)
   ├─> Enable/disable reminders
   ├─> Select reminder times:
   │   - Morning (default: 09:00)
   │   - Evening (default: 19:00)
   │   - Night (default: 23:00)
   │
8. First Tank Creation (OPTIONAL)
   │
   ├─> Prompt: "Want to create your first tank?"
   │   │
   │   ├─> YES
   │   │   ├─> Enter tank name
   │   │   ├─> Select tank type (freshwater/marine)
   │   │   ├─> Enter volume
   │   │   ├─> Select setup date
   │   │   ├─> Tank created
   │   │   └─> Earn XP (15 XP)
   │   │
   │   └─> SKIP
   │       └─> Can create later from home
   │
9. Home Screen (House Navigator)
   │
   └─> User lands on home with:
       - Profile stats (XP, streak, level)
       - Daily goal progress
       - Learning section
       - Tank management section
       - Social features

```

**Success Metrics:**
- User completes profile creation
- User completes at least 1 lesson
- User earns their first XP and gems
- User understands daily goal system

**Estimated Time:** 5-10 minutes

---

## 📚 Flow 2: Daily Active User Flow

**Goal:** User completes their daily learning routine and checks progress.

```
┌─────────────────────────────────────────────────────────────────┐
│                    DAILY ACTIVE USER                             │
└─────────────────────────────────────────────────────────────────┘

1. App Launch (Returning User)
   ↓
2. Home Screen
   │
   ├─> Display current stats:
   │   - Current streak (🔥 X days)
   │   - Total XP and level
   │   - Today's XP progress (X/50)
   │   - Gems balance (💎 X gems)
   │
3. Check Daily Status
   │
   ├─> Daily tip displayed (rotating tips)
   ├─> Streak status indicator:
   │   - ✅ Active streak
   │   - ⚠️ At risk (haven't learned today)
   │   - 🧊 Streak freeze available
   │
4. Complete Lesson #1
   │
   ├─> Navigate to "Learn" section
   ├─> View recommended lessons
   ├─> Select a lesson
   │   │
   │   ├─> Lesson content
   │   ├─> Interactive questions
   │   ├─> Quiz at end
   │   └─> Complete
   │
   ├─> Earn XP (10-15 XP)
   ├─> Earn gems (5 gems)
   ├─> Update daily progress
   ├─> Update streak if first lesson today:
   │   └─> Streak +1 🔥
   │
5. Complete Lesson #2 (Optional)
   │
   ├─> Continue learning to meet daily goal
   ├─> Same flow as Lesson #1
   ├─> Daily goal progress updates in real-time
   │
6. Daily Goal Achievement
   │
   ├─> When XP reaches daily goal (default: 50)
   │   ├─> Celebration animation 🎉
   │   ├─> Bonus gems (5 gems)
   │   ├─> Achievement recorded
   │   └─> Notification: "Great work! Goal complete!"
   │
7. Check Leaderboard
   │
   ├─> Navigate to "Leaderboard" tab
   ├─> View rankings:
   │   - This Week
   │   - All Time
   │   - Friends Only
   ├─> See your rank and XP
   ├─> Compare with friends
   │
8. View Friends Activity
   │
   ├─> Navigate to "Friends" tab
   ├─> See activity feed:
   │   - Friend completed lesson
   │   - Friend reached streak milestone
   │   - Friend leveled up
   │   - Friend unlocked achievement
   ├─> Send encouragement (emoji + message)
   │
9. Exit
   │
   └─> User closes app
       - Progress saved automatically
       - Daily stats recorded
       - Streak updated

```

**Success Metrics:**
- User completes daily XP goal
- User maintains or extends streak
- User engages with leaderboard
- User views or interacts with friends

**Estimated Time:** 10-15 minutes

---

## 🐠 Flow 3: Tank Management Flow

**Goal:** User creates and manages an aquarium tank, adding livestock and tracking maintenance.

```
┌─────────────────────────────────────────────────────────────────┐
│                    TANK MANAGEMENT                               │
└─────────────────────────────────────────────────────────────────┘

1. Create New Tank
   │
   ├─> Navigate to Home → Tank section
   ├─> Tap "Create Tank" or "+"
   │
   ├─> Tank Setup Form:
   │   ├─> Tank name (e.g., "Living Room 20G")
   │   ├─> Tank type:
   │   │   - Freshwater
   │   │   - Marine
   │   ├─> Volume:
   │   │   - Enter number
   │   │   - Select unit (gallons/liters)
   │   ├─> Setup date (date picker)
   │   └─> Submit
   │
   ├─> Tank created successfully
   ├─> Earn XP (15 XP)
   └─> Redirect to Tank Detail Screen
   │
2. Add Livestock
   │
   ├─> From Tank Detail Screen
   ├─> Tap "Add Livestock" section
   │
   ├─> Select species:
   │   ├─> Browse species database
   │   ├─> Search by name
   │   ├─> Filter by category:
   │   │   - Fish
   │   │   - Invertebrates
   │   │   - Plants
   │   └─> Select species
   │
   ├─> Enter livestock details:
   │   ├─> Quantity (number)
   │   ├─> Date added
   │   ├─> Custom name (optional)
   │   ├─> Notes (optional)
   │   └─> Submit
   │
   ├─> Livestock added
   ├─> Stocking level updated
   ├─> Compatibility check runs automatically
   │   └─> Warnings if stocking level high
   │
3. Log Water Test
   │
   ├─> Navigate to tank → "Logs" tab
   ├─> Tap "Add Log" → "Water Test"
   │
   ├─> Enter parameters:
   │   ├─> Date/time
   │   ├─> Temperature
   │   ├─> pH
   │   ├─> Ammonia (NH3)
   │   ├─> Nitrite (NO2)
   │   ├─> Nitrate (NO3)
   │   ├─> GH (hardness)
   │   ├─> KH (carbonate)
   │   ├─> Notes (optional)
   │   └─> Submit
   │
   ├─> Log saved
   ├─> Parameter trends updated
   ├─> Auto-analysis:
   │   └─> Warnings for out-of-range values
   │
4. Complete Maintenance Task
   │
   ├─> Navigate to tank → "Tasks" tab
   ├─> View pending tasks:
   │   - Water changes (scheduled)
   │   - Filter cleaning
   │   - Glass cleaning
   │   - Plant trimming
   │   - Equipment checks
   │
   ├─> Select task
   ├─> Mark as complete
   │   ├─> Add notes (optional)
   │   ├─> Upload photo (optional)
   │   └─> Submit
   │
   ├─> Task completed
   ├─> Next occurrence scheduled automatically
   ├─> Earn XP (5-10 XP)
   │
5. View Analytics
   │
   ├─> Navigate to tank → "Charts" tab
   ├─> View graphs:
   │   - Water parameter trends
   │   - Temperature over time
   │   - Maintenance frequency
   │   - Cost tracking
   │
   ├─> Select date range:
   │   - 7 days
   │   - 30 days
   │   - 90 days
   │   - All time
   │
   └─> Identify trends and patterns

```

**Success Metrics:**
- User creates tank successfully
- User adds at least 1 livestock
- User logs water test results
- User completes maintenance task
- User views analytics to understand trends

**Estimated Time:** 15-20 minutes

---

## 👥 Flow 4: Social Flow

**Goal:** User connects with friends, compares progress, and engages with social features.

```
┌─────────────────────────────────────────────────────────────────┐
│                        SOCIAL FLOW                               │
└─────────────────────────────────────────────────────────────────┘

1. Add Friends
   │
   ├─> Navigate to "Friends" tab
   ├─> Tap "Add Friend" or "+"
   │
   ├─> Search methods:
   │   ├─> By username
   │   ├─> By email (mock)
   │   └─> Suggested friends (mock)
   │
   ├─> Send friend request
   │   └─> (Currently auto-accepts for demo)
   │
   ├─> Friend added successfully
   └─> Friend appears in friends list
   │
2. Compare Progress
   │
   ├─> From Friends tab
   ├─> Tap on a friend's profile
   │
   ├─> Friend Comparison Screen shows:
   │   │
   │   ├─> Side-by-side stats:
   │   │   - Total XP
   │   │   - Current level
   │   │   - Current streak
   │   │   - Longest streak
   │   │   - Total achievements
   │   │
   │   ├─> Weekly XP comparison:
   │   │   - Bar chart showing daily XP
   │   │   - Your XP vs friend's XP
   │   │
   │   ├─> Achievement comparison:
   │   │   - Shared achievements
   │   │   - Unique achievements
   │   │
   │   └─> Leaderboard rank:
   │       - Your rank
   │       - Friend's rank
   │
3. Send Encouragement
   │
   ├─> From friend's profile
   ├─> Tap "Send Encouragement"
   │
   ├─> Select emoji:
   │   - 👍 Nice work!
   │   - 🎉 Congratulations!
   │   - 🔥 On fire!
   │   - ❤️ Love it!
   │   - 💪 Keep going!
   │
   ├─> Add optional message
   │   └─> Type custom message (optional)
   │
   ├─> Send
   │
   ├─> Encouragement sent
   └─> Friend receives notification (mock)
   │
4. View Activity Feed
   │
   ├─> Friends tab → "Activity" section
   ├─> Scroll through recent activities:
   │   │
   │   ├─> Activity types shown:
   │   │   - ⭐ Friend leveled up
   │   │   - 🏆 Achievement unlocked
   │   │   - 🔥 Streak milestone reached
   │   │   - 📚 Lesson completed
   │   │   - 🐠 Tank created
   │   │   - 🎖️ Badge earned
   │   │
   │   ├─> Activity details:
   │   │   - Friend name
   │   │   - Avatar emoji
   │   │   - Action description
   │   │   - Time ago
   │   │
   │   └─> React to activities:
   │       - Tap to send quick encouragement
   │
5. Check Your Activity
   │
   ├─> Friends tab → Profile icon
   ├─> View what friends see:
   │   - Your public stats
   │   - Your recent achievements
   │   - Your activity history
   │
   └─> Privacy settings:
       - Show/hide profile to friends
       - Show/hide activity feed

```

**Success Metrics:**
- User adds at least 1 friend
- User views friend comparison
- User sends encouragement
- User views activity feed
- User engages with social features regularly

**Estimated Time:** 5-10 minutes

---

## 💎 Flow 5: Shop & Progression Flow

**Goal:** User earns gems through learning and uses them to purchase items and power-ups.

```
┌─────────────────────────────────────────────────────────────────┐
│                   SHOP & PROGRESSION                             │
└─────────────────────────────────────────────────────────────────┘

1. Earn Gems Through Learning
   │
   ├─> Multiple earning opportunities:
   │   │
   │   ├─> Complete lesson: +5 gems 💎
   │   ├─> Pass quiz: +3 gems 💎
   │   ├─> Perfect quiz: +5 gems 💎
   │   ├─> Placement test: +10 gems 💎
   │   ├─> Review lesson: +2 gems 💎
   │   ├─> Daily goal met: +5 gems 💎
   │   ├─> 7-day streak: +10 gems 💎
   │   ├─> 30-day streak: +25 gems 💎
   │   ├─> Level up: +10 gems 💎
   │   └─> Achievement: +5-50 gems 💎
   │
   ├─> Gems display in top bar
   ├─> Running total tracked
   │
2. Browse Shop
   │
   ├─> Navigate to "Shop" tab
   ├─> Shop Street Screen (themed interface)
   │
   ├─> Categories available:
   │   │
   │   ├─> 🏠 Room Themes (60-150 gems)
   │   │   - Cozy Cabin
   │   │   - Modern Loft
   │   │   - Tropical Paradise
   │   │   - Zen Garden
   │   │
   │   ├─> ⚡ Power-Ups (15-40 gems)
   │   │   - 2x XP Boost (1 hour): 25 gems
   │   │   - Lesson Helper: 15 gems
   │   │   - Quiz Second Chance: 20 gems
   │   │
   │   ├─> 🎁 Extras (30-150 gems)
   │   │   - Streak Freeze: 30 gems
   │   │   - Weekend Pass: 40 gems
   │   │   - Goal Shield: 35 gems
   │   │
   │   └─> ✨ Cosmetics (50-200 gems)
   │       - Profile Badges: 50-100 gems
   │       - Special Emojis: 75 gems
   │       - Premium Themes: 150-200 gems
   │
3. Purchase Items
   │
   ├─> Tap on item
   ├─> View item details:
   │   - Full description
   │   - Effects/benefits
   │   - Duration (if applicable)
   │   - Preview (for themes)
   │   - Cost in gems
   │
   ├─> Purchase flow:
   │   │
   │   ├─> Sufficient gems:
   │   │   ├─> Tap "Purchase"
   │   │   ├─> Confirmation dialog
   │   │   ├─> Confirm purchase
   │   │   ├─> Gems deducted
   │   │   ├─> Item added to inventory
   │   │   └─> Success message
   │   │
   │   └─> Insufficient gems:
   │       ├─> "Not enough gems" message
   │       ├─> Show how many more gems needed
   │       └─> Suggest ways to earn more:
   │           - Complete lessons
   │           - Maintain streak
   │           - Achieve daily goal
   │
4. Use Power-Ups
   │
   ├─> Consumable items in inventory
   │
   ├─> 2x XP Boost:
   │   ├─> Tap to activate
   │   ├─> Timer starts (1 hour)
   │   ├─> All XP doubled during period
   │   ├─> Timer displayed in UI
   │   └─> Notification when expiring
   │
   ├─> Lesson Helper:
   │   ├─> Automatically applied to next lesson
   │   ├─> Provides hints during quiz
   │   ├─> Consumed after use
   │
   ├─> Quiz Second Chance:
   │   ├─> Applied to next quiz
   │   ├─> Allows retrying wrong answers
   │   ├─> Consumed after use
   │
   ├─> Streak Freeze:
   │   ├─> Automatically protects streak
   │   ├─> Stacks with free weekly freeze
   │   ├─> Shows in profile
   │   ├─> Consumed when needed
   │
   └─> Weekend Pass:
       ├─> Activate for upcoming weekend
       ├─> Daily goal reduced by 50%
       ├─> Active for 48 hours
       ├─> Consumed after weekend
   │
5. Track Progression
   │
   ├─> Profile screen shows:
   │   - Total gems earned (lifetime)
   │   - Total gems spent
   │   - Current gem balance
   │   - Items owned
   │   - Active power-ups
   │
   ├─> Shop history:
   │   - Purchase log
   │   - Transaction details
   │   - Gem economy insights
   │
   └─> Achievement tracking:
       - "Big Spender" (spent 500 gems)
       - "Collector" (own 10+ items)
       - "Power User" (used 20 power-ups)

```

**Success Metrics:**
- User earns gems consistently
- User browses shop
- User makes first purchase
- User uses power-ups strategically
- User understands gem economy

**Estimated Time:** 5-15 minutes

---

## 🔄 Cross-Flow Interactions

### Learning ↔ Tank Management
```
Complete lesson → Earn XP → Level up → Unlock advanced tank features
Learn about water chemistry → Apply to tank management
Complete tank maintenance → Earn XP → Progress in learning path
```

### Social ↔ Learning
```
Friend completes lesson → Activity feed → Encouragement → Motivation
Compare leaderboard → Competitive motivation → Complete more lessons
Send encouragement → Friend motivated → Both earn engagement bonuses
```

### Shop ↔ Learning
```
Earn gems from lessons → Purchase XP boost → Complete more lessons faster
Daily goal met → Earn gems → Purchase streak freeze → Maintain streak
Level up → Earn gems → Purchase cosmetics → Customize profile
```

### Gamification Loop
```
┌─────────────────────────────────────────────┐
│                                             │
│  Learn → XP → Level Up → Unlock Content    │
│    ↑                             ↓          │
│    └────── Gems → Shop ───────────┘         │
│                                             │
│  Streak → Motivation → Daily Goal → Reward │
│    ↑                                  ↓     │
│    └──────── Consistency ─────────────┘     │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 📱 Navigation Map

```
Home Screen (House Navigator)
├─ 🏠 Home
│  ├─ Profile stats
│  ├─ Daily goal progress
│  ├─ Quick actions
│  └─ Daily tip
│
├─ 📚 Learn
│  ├─ Recommended lessons
│  ├─ Lesson categories
│  ├─ Placement test
│  ├─ Practice mode
│  └─ Review lessons
│
├─ 🐠 Tanks (via Home)
│  ├─ Tank list
│  ├─ Create new tank
│  └─ Tank details:
│     ├─ Overview
│     ├─ Livestock
│     ├─ Logs
│     ├─ Tasks
│     ├─ Charts
│     └─ Settings
│
├─ 👥 Friends
│  ├─ Friends list
│  ├─ Add friend
│  ├─ Activity feed
│  ├─ Friend comparison
│  └─ Leaderboard
│
├─ 💎 Shop
│  ├─ Room themes
│  ├─ Power-ups
│  ├─ Extras
│  ├─ Cosmetics
│  └─ Purchase history
│
└─ ⚙️ Settings
   ├─ Profile
   ├─ Notifications
   ├─ Daily goal
   ├─ Theme
   ├─ Backup/restore
   └─ About

Tools & Guides (accessed via menu)
├─ 🧪 Calculators
│  ├─ Stocking calculator
│  ├─ Water change calculator
│  ├─ Dosing calculator
│  ├─ CO2 calculator
│  └─ Unit converter
│
├─ 📖 Guides
│  ├─ Quick start guide
│  ├─ Nitrogen cycle
│  ├─ Water parameters
│  ├─ Equipment guide
│  ├─ Disease guide
│  ├─ Feeding guide
│  └─ More...
│
└─ 🔍 Browsers
   ├─ Species browser
   ├─ Plant browser
   └─ Compatibility checker
```

---

## 🎯 Key Success Indicators

### First-Time User
- ✅ Completes profile creation
- ✅ Completes first lesson
- ✅ Understands XP/gem system
- ✅ Sets daily goal

### Daily Active User
- ✅ Maintains streak
- ✅ Meets daily XP goal
- ✅ Earns gems
- ✅ Engages with social features

### Tank Manager
- ✅ Creates at least one tank
- ✅ Adds livestock
- ✅ Logs water parameters
- ✅ Completes maintenance tasks

### Social User
- ✅ Has 1+ friends
- ✅ Views activity feed
- ✅ Sends encouragement
- ✅ Compares progress

### Shop User
- ✅ Understands gem economy
- ✅ Makes first purchase
- ✅ Uses power-ups strategically
- ✅ Customizes profile

---

## 📊 Flow Metrics

| Flow | Expected Time | Complexity | Priority |
|------|---------------|------------|----------|
| First-Time User | 5-10 min | Medium | Critical |
| Daily Active User | 10-15 min | Low | Critical |
| Tank Management | 15-20 min | High | High |
| Social | 5-10 min | Low | Medium |
| Shop & Progression | 5-15 min | Medium | Medium |

---

## 🔧 Common Flow Variations

### Offline Mode
- All flows should work offline
- Data syncs when online
- Queue actions for sync
- Show offline indicator

### Error Recovery
- Network errors → Retry with backoff
- Storage errors → Backup/restore flow
- Validation errors → Clear feedback
- Crashes → State recovery

### Accessibility
- Screen reader support
- High contrast mode
- Larger text options
- Keyboard navigation

---

*Last Updated: 2025-02-07*
*Version: 1.0*
