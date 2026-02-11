# User Flow Diagrams - Aquarium App

Visual representations of critical user journeys.

---

## Flow 1: First-Time User Journey

```
┌─────────────────────────────────────────────────────────────────────┐
│                        APP LAUNCH (Fresh Install)                    │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │   Splash Screen      │
                    │  (2-3 sec loading)   │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ OnboardingService    │
                    │ .isCompleted?        │
                    └──────────┬───────────┘
                               │ FALSE
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                       ONBOARDING SCREENS                             │
├──────────────────────────────────────────────────────────────────────┤
│  Page 1/3: "Track Your Aquariums"                                   │
│  - Water drop icon (140x140)                                        │
│  - Value proposition                                                │
│  - Progress dots (1 active)                                         │
│  - [Skip] button (top-right)                                        │
│  - [Next] button                                                    │
├──────────────────────────────────────────────────────────────────────┤
│  Page 2/3: "Manage Livestock & Equipment"                           │
│  - Pets icon                                                        │
│  - Maintenance focus                                                │
│  - Progress dots (2 active)                                         │
│  - [Back] [Next] buttons                                            │
├──────────────────────────────────────────────────────────────────────┤
│  Page 3/3: "Stay On Top of Maintenance"                             │
│  - Insights icon                                                    │
│  - Tasks & charts                                                   │
│  - Progress dots (3 active)                                         │
│  - [Back] [Get Started] buttons                                     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Get Started]
                               ▼
                    ┌──────────────────────┐
                    │ OnboardingService    │
                    │ .completeOnboarding()│
                    └──────────┬───────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    HOME SCREEN (Empty State)                         │
├──────────────────────────────────────────────────────────────────────┤
│  Living Room Scene:                                                  │
│  - Empty stand (placeholder for tank)                               │
│  - "Tank goes here" dashed outline                                  │
│  - Window with clouds                                                │
│  - Faded floor plant                                                │
│                                                                      │
│  Call to Action Card:                                                │
│  ┌────────────────────────────────────┐                             │
│  │ 🐠 Welcome!                        │                             │
│  │ This room is waiting for           │                             │
│  │ your first aquarium.               │                             │
│  │                                    │                             │
│  │  [Add Your Tank]                   │  ◄── Primary action         │
│  │  [Try a sample tank]               │  ◄── Demo option            │
│  └────────────────────────────────────┘                             │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Add Your Tank]
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│              CREATE TANK WIZARD (3 Pages)                            │
├──────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │ Progress: ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 33%        │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  PAGE 1: Basic Info                                                 │
│  ┌────────────────────────────────────┐                             │
│  │ Name your tank                     │                             │
│  │ ┌────────────────────────────────┐ │                             │
│  │ │ Living Room Tank               │ │                             │
│  │ └────────────────────────────────┘ │                             │
│  │                                    │                             │
│  │ Tank type                          │                             │
│  │ ┌─────────────┐  ┌─────────────┐  │                             │
│  │ │ Freshwater  │  │   Marine    │  │                             │
│  │ │  [Selected] │  │   [Locked]  │  │                             │
│  │ │     ✓       │  │   🔒        │  │                             │
│  │ └─────────────┘  └─────────────┘  │                             │
│  │                                    │                             │
│  │              [Next] →              │                             │
│  └────────────────────────────────────┘                             │
│                      ⬇                                               │
│  PAGE 2: Size                                                       │
│  ┌────────────────────────────────────┐                             │
│  │ Tank size                          │                             │
│  │ ┌────────────────────────────────┐ │                             │
│  │ │ Volume: 120 litres             │ │                             │
│  │ └────────────────────────────────┘ │                             │
│  │                                    │                             │
│  │ Dimensions (optional)              │                             │
│  │ ┌──────┐ ┌──────┐ ┌──────┐        │                             │
│  │ │ 80cm │ │ 40cm │ │ 50cm │        │                             │
│  │ │  L   │ │  W   │ │  H   │        │                             │
│  │ └──────┘ └──────┘ └──────┘        │                             │
│  │                                    │                             │
│  │ Quick presets:                     │                             │
│  │ [20L] [60L] [120L] [200L] [300L]  │                             │
│  │                                    │                             │
│  │      ← [Back]    [Next] →          │                             │
│  └────────────────────────────────────┘                             │
│                      ⬇                                               │
│  PAGE 3: Water Type                                                 │
│  ┌────────────────────────────────────┐                             │
│  │ Water type                         │                             │
│  │ ┌────────────────────────────────┐ │                             │
│  │ │ 🌴 Tropical     [Selected] ✓   │ │                             │
│  │ │ 24-28°C • Most community fish  │ │                             │
│  │ └────────────────────────────────┘ │                             │
│  │ ┌────────────────────────────────┐ │                             │
│  │ │ ❄️  Coldwater                  │ │                             │
│  │ │ 15-22°C • Goldfish, minnows    │ │                             │
│  │ └────────────────────────────────┘ │                             │
│  │                                    │                             │
│  │ Start date: Jan 27, 2025 [Edit]   │                             │
│  │                                    │                             │
│  │      ← [Back]  [Create Tank] →     │                             │
│  └────────────────────────────────────┘                             │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Create Tank]
                               ▼
                    ┌──────────────────────┐
                    │ TankActions          │
                    │ .createTank()        │
                    │ - Validates input    │
                    │ - Generates UUID     │
                    │ - Saves to storage   │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Success Snackbar     │
                    │ "Living Room Tank    │
                    │  created! ✓"         │
                    └──────────┬───────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                   HOME SCREEN (With Tank)                            │
├──────────────────────────────────────────────────────────────────────┤
│  Living Room Scene:                                                  │
│  - Tank illustration (water, bubbles, plants)                        │
│  - Stand with details                                                │
│  - Decorative items (test kit, food, plants)                        │
│  - Window with daylight                                              │
│                                                                      │
│  Tank Switcher Card:                                                 │
│  ┌────────────────────────────────────┐                             │
│  │ 🐠 Living Room Tank      120L      │                             │
│  │                          [▼]       │  ◄── Tap to open picker     │
│  └────────────────────────────────────┘                             │
│                                                                      │
│  Speed Dial FAB (bottom-right):                                      │
│  ┌────────────┐                                                      │
│  │ 💧 [+]     │  ◄── Tap to expand                                  │
│  │ Add Tank   │                                                      │
│  │ Feed       │                                                      │
│  │ Test       │                                                      │
│  │ Water      │                                                      │
│  │ Stats      │                                                      │
│  └────────────┘                                                      │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Tap Tank]
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                       TANK DETAIL SCREEN                             │
├──────────────────────────────────────────────────────────────────────┤
│  Header (Gradient):                                                  │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ ← Living Room Tank                    🗒️ 📷 📖 📊 ⋮       │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Cycling Status Card:                                                │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 🔄 Cycling in Progress (Day 3)                            │     │
│  │ Progress: ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 30%            │     │
│  │ Next step: Keep testing ammonia & nitrite                 │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Recent Activity:                                                    │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ No activity yet. Tap + to log water tests or changes.     │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  At a Glance:                                                        │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 🌡️ Temperature: --     💧 Last water change: --           │     │
│  │ 🧪 pH: --               📅 Last test: --                  │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  [View All Tasks] [View Livestock] [View Equipment]                 │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Speed Dial: Test]
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                      ADD LOG SCREEN (Water Test)                     │
├──────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ ← Log Water Test                              [Save]       │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Type Selector:                                                      │
│  [💧 Water Test] [💦 Water Change] [👁️ Observation] [💊 Medication]│
│                                                                      │
│  Water Parameters:                                                   │
│  ┌─────────────────────┬─────────────────────┐                      │
│  │ Temperature (°C)    │ pH                  │                      │
│  │ [  25.5  ]          │ [  7.4  ]           │                      │
│  └─────────────────────┴─────────────────────┘                      │
│                                                                      │
│  Nitrogen Cycle:                                                     │
│  ┌─────────────────────┬─────────────────────┐                      │
│  │ Ammonia (ppm) 🔴    │ Nitrite (ppm) 🟡    │                      │
│  │ [  0.25  ]          │ [  0.1  ]           │                      │
│  └─────────────────────┴─────────────────────┘                      │
│  ┌─────────────────────┐                                            │
│  │ Nitrate (ppm) 🟢    │                                            │
│  │ [  5  ]             │                                            │
│  └─────────────────────┘                                            │
│                                                                      │
│  🔴 = Danger  🟡 = Warning  🟢 = Safe                                │
│                                                                      │
│  Photos (0/5): [+ Add Photo]                                        │
│  Notes: [Optional observations...]                                  │
│  Date & Time: Jan 27, 2025 3:45 PM [Edit] [Now]                     │
│                                                                      │
│                          [Save]                                      │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Save]
                               ▼
                    ┌──────────────────────┐
                    │ StorageService       │
                    │ .saveLog()           │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Success Snackbar     │
                    │ "Water Test logged!" │
                    └──────────┬───────────┘
                               │
                               ▼
              ┌────────────────────────────┐
              │ Tank Detail (Updated)      │
              │ - Recent Activity shows log│
              │ - At a Glance updates      │
              │ - Cycling status updates   │
              └────────────────────────────┘

```

**Success Criteria:**
- ✅ Onboarding completes in 3 taps
- ✅ Tank created in <2 minutes
- ✅ First water test logged in <1 minute
- ✅ No errors or confusion

---

## Flow 2: Daily Maintenance Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                      APP LAUNCH (Returning User)                     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ OnboardingService    │
                    │ .isCompleted = TRUE  │
                    └──────────┬───────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                       HOME SCREEN (Dashboard)                        │
├──────────────────────────────────────────────────────────────────────┤
│  Living Room Scene with Tank                                         │
│  Tank Switcher: "Living Room Tank • 120L"                           │
│  Speed Dial FAB available                                            │
│                                                                      │
│  [Tap Tank]                                                          │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                       TANK DETAIL SCREEN                             │
├──────────────────────────────────────────────────────────────────────┤
│  Recent Activity:                                                    │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 🧪 Water Test - 2 days ago                                 │     │
│  │    pH: 7.4 • Ammonia: 0.25ppm • Nitrite: 0.1ppm          │     │
│  │                                                            │     │
│  │ 💦 Water Change (25%) - 5 days ago                        │     │
│  │    Dosed API Stress Coat                                  │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  At a Glance:                                                        │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 🌡️ Temperature: 25.5°C    💧 Last water change: 5d ago    │     │
│  │ 🧪 pH: 7.4                 📅 Last test: 2d ago            │     │
│  │ ⚠️  Nitrite elevated (0.1ppm) - keep testing               │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Tasks (Due Today):                                                  │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ ✓ Feed fish (2x daily)                         [Complete]  │     │
│  │ ✓ Test water parameters                        [Complete]  │     │
│  │ 💦 Water change (25%)                          [Due]       │     │
│  └────────────────────────────────────────────────────────────┘     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Speed Dial: Water]
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                  ADD LOG SCREEN (Water Change)                       │
├──────────────────────────────────────────────────────────────────────┤
│  Type: 💦 Water Change                                               │
│                                                                      │
│  How much water did you change?                                      │
│  Presets: [10%] [20%] [25%] [30%] [40%] [50%]                       │
│                     ▲                                                │
│                 Selected: 25%                                        │
│                                                                      │
│  Custom: [ 25 ] %                                                    │
│                                                                      │
│  Notes:                                                              │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ Added 2 capfuls of Seachem Prime.                         │     │
│  │ Water from tap, conditioned before adding.                │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Photos: [Before] [After]                                            │
│  ┌──────────┐ ┌──────────┐                                          │
│  │ [Image]  │ │ [Image]  │                                          │
│  └──────────┘ └──────────┘                                          │
│                                                                      │
│  Date & Time: Jan 27, 2025 4:30 PM [Now]                            │
│                                                                      │
│                          [Save]                                      │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Save]
                               ▼
                    ┌──────────────────────┐
                    │ StorageService       │
                    │ .saveLog()           │
                    │ - Creates LogEntry   │
                    │ - Updates tank data  │
                    └──────────┬───────────┘
                               │
                               ▼
              ┌────────────────────────────┐
              │ Tank Detail (Refreshed)    │
              │ - Water change in activity │
              │ - "Last water change: now" │
              └────────────┬───────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────┐
│                       MARK TASK COMPLETE                             │
├──────────────────────────────────────────────────────────────────────┤
│  Tasks (Due Today):                                                  │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ ✓ Feed fish (2x daily)              [✓ Completed]         │     │
│  │ ✓ Test water parameters             [✓ Completed]         │     │
│  │ 💦 Water change (25%)               [✓]  ◄── Tap checkmark │     │
│  └────────────────────────────────────────────────────────────┘     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [✓ Complete]
                               ▼
                    ┌──────────────────────┐
                    │ Task.complete()      │
                    │ - Updates            │
                    │   lastCompletedAt    │
                    │ - Increments count   │
                    │ - Advances due date  │
                    │   (recurring)        │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Creates Log Entry    │
                    │ type: taskCompleted  │
                    │ title: "Water change"│
                    └──────────┬───────────┘
                               │
                               ▼
              ┌────────────────────────────┐
              │ Task moves to "Upcoming"   │
              │ Next due: Feb 3, 2025      │
              │ (weekly recurrence)        │
              └────────────┬───────────────┘
                           │
                           ▼
              ┌────────────────────────────┐
              │ Recent Activity updated:   │
              │ "✓ Water change - just now"│
              └────────────────────────────┘

```

**Time Benchmark:**
- Water change log: 45 seconds
- Task completion: 10 seconds
- **Total: ~90 seconds** ✅

---

## Flow 3: Learning Journey

```
┌─────────────────────────────────────────────────────────────────────┐
│                        NAVIGATE TO STUDY                             │
├──────────────────────────────────────────────────────────────────────┤
│  Entry Points:                                                       │
│  1. Settings → "Learn" card (gradient, shows XP/level/streak)        │
│  2. House Navigator → "Study" room (bottom nav)                      │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        LEARN SCREEN                                  │
├──────────────────────────────────────────────────────────────────────┤
│  Study Room Scene (Header - 320px):                                  │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 📚 Study                                                   │     │
│  │                                                            │     │
│  │ Cozy illustration:                                         │     │
│  │  🪴 Bookshelf  📚 Desk with laptop  🖼️ Posters            │     │
│  │                                                            │     │
│  │  ┌─────────────────────────────────────────┐              │     │
│  │  │ Level: Beginner      150 XP              │              │     │
│  │  │ Progress: ━━━━━━━━━━━━━ 15/50 lessons    │              │     │
│  │  │ 🔥 3 day streak!                         │              │     │
│  │  └─────────────────────────────────────────┘              │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Streak Card (if >0):                                                │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 🔥 3 day streak! Keep learning to maintain your streak     │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Learning Paths:                                                     │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 🐠 Beginner's Guide to Fishkeeping            [Expand ▼]   │     │
│  │ Start here if you're new to the hobby                      │     │
│  │ Progress: ━━━━━━━━━━━━━━━━ 5/10 (50%)                      │     │
│  └────────────────────────────────────────────────────────────┘     │
│                            │ [Tap to expand]                         │
│                            ▼                                         │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 🐠 Beginner's Guide to Fishkeeping            [Collapse ▲] │     │
│  │ Start here if you're new to the hobby                      │     │
│  │ Progress: ━━━━━━━━━━━━━━━━ 5/10 (50%)                      │     │
│  ├────────────────────────────────────────────────────────────┤     │
│  │ Lessons:                                                   │     │
│  │  ✅ 1. What is an Aquarium?              15 min • 50 XP    │     │
│  │  ✅ 2. The Nitrogen Cycle                20 min • 100 XP   │     │
│  │  ✅ 3. Choosing Your First Tank          10 min • 50 XP    │     │
│  │  ✅ 4. Essential Equipment               15 min • 75 XP    │     │
│  │  ✅ 5. Water Parameters Basics           20 min • 100 XP   │     │
│  │  ▶️  6. Cycling Your Tank                25 min • 150 XP ◄─┤     │
│  │  🔒 7. First Fish Selection              15 min • 75 XP    │     │
│  │  🔒 8. Feeding & Maintenance             10 min • 50 XP    │     │
│  │  🔒 9. Common Beginner Mistakes          10 min • 50 XP    │     │
│  │  🔒 10. Troubleshooting                  15 min • 75 XP    │     │
│  └────────────────────────────────────────────────────────────┘     │
│                            │ [Tap Lesson 6]                          │
│                            ▼                                         │
└──────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        LESSON SCREEN                                 │
├──────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ ← Cycling Your Tank                         Section 1/5    │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Content (Markdown-rendered):                                        │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │                                                            │     │
│  │  # What is Cycling?                                        │     │
│  │                                                            │     │
│  │  Cycling is the process of establishing beneficial        │     │
│  │  bacteria in your tank that convert harmful ammonia       │     │
│  │  into less harmful nitrite, then nitrate.                 │     │
│  │                                                            │     │
│  │  ## The Nitrogen Cycle                                     │     │
│  │                                                            │     │
│  │  [Diagram: Ammonia → Nitrite → Nitrate]                   │     │
│  │                                                            │     │
│  │  - Ammonia (NH₃): Highly toxic to fish                    │     │
│  │  - Nitrite (NO₂): Also toxic                              │     │
│  │  - Nitrate (NO₃): Less harmful, removed via water changes │     │
│  │                                                            │     │
│  │  ## How Long Does It Take?                                 │     │
│  │                                                            │     │
│  │  Typically 4-6 weeks for a fishless cycle.                │     │
│  │                                                            │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Progress: ●○○○○ (Section 1/5)                                       │
│                                                                      │
│                      [Continue →]                                    │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Continue through sections]
                               │ Section 2, 3, 4, 5...
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        QUIZ SECTION                                  │
├──────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ Quiz: Cycling Your Tank                     Question 1/5   │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Question:                                                           │
│  What is the first step in the nitrogen cycle?                       │
│                                                                      │
│  Answers:                                                            │
│  ○ Nitrite converts to nitrate                                       │
│  ● Ammonia converts to nitrite  ◄── Selected                        │
│  ○ Nitrate builds up                                                 │
│  ○ Bacteria die off                                                  │
│                                                                      │
│                      [Submit Answer]                                 │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Submit]
                               ▼
                    ┌──────────────────────┐
                    │ Validate Answer      │
                    │ - Check if correct   │
                    │ - Show feedback      │
                    └──────────┬───────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        ANSWER FEEDBACK                               │
├──────────────────────────────────────────────────────────────────────┤
│  ✅ Correct!                                                         │
│                                                                      │
│  Ammonia (from fish waste, uneaten food) is converted to nitrite    │
│  by Nitrosomonas bacteria.                                           │
│                                                                      │
│                      [Next Question →]                               │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Continue through quiz]
                               │ Questions 2, 3, 4, 5...
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        QUIZ COMPLETE                                 │
├──────────────────────────────────────────────────────────────────────┤
│  🎉 Quiz Complete!                                                   │
│                                                                      │
│  Score: 5/5 (100%)                                                   │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │                                                            │     │
│  │                    +150 XP                                 │     │
│  │                 ✨ [Animation] ✨                          │     │
│  │                                                            │     │
│  │  Total XP: 300 → 450                                       │     │
│  │                                                            │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│                   [Back to Learning Paths]                           │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ UserProfile Update   │
                    │ - Add lesson to      │
                    │   completedLessons   │
                    │ - Increase totalXp   │
                    │ - Update             │
                    │   lastLessonAt       │
                    │ - Calculate streak   │
                    └──────────┬───────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    LEARN SCREEN (Updated)                            │
├──────────────────────────────────────────────────────────────────────┤
│  Study Room Scene:                                                   │
│  ┌─────────────────────────────────────────┐                        │
│  │ Level: Intermediate  450 XP            │  ◄── Updated!           │
│  │ Progress: ━━━━━━━━━━━━━ 16/50 lessons  │                         │
│  │ 🔥 4 day streak!                       │  ◄── Streak incremented │
│  └─────────────────────────────────────────┘                        │
│                                                                      │
│  Learning Paths:                                                     │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 🐠 Beginner's Guide                                        │     │
│  │ Progress: ━━━━━━━━━━━━━━━━━━ 6/10 (60%)  ◄── Progress++    │     │
│  │  ✅ 6. Cycling Your Tank   (+150 XP)   ◄── Checkmark!     │     │
│  │  ▶️  7. First Fish Selection (unlocked!)                   │     │
│  └────────────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────────────┘

```

**Success Criteria:**
- ✅ Lessons unlock sequentially
- ✅ XP awarded on quiz completion
- ✅ Streak tracked daily
- ✅ Progress persists across sessions

---

## Flow 4: Data Analysis Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                      TANK DETAIL SCREEN                              │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Charts icon] (top-right)
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        CHARTS SCREEN                                 │
├──────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ ← Water Charts                                  [📥 Export] │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Parameter Selector (horizontal scroll):                             │
│  [Nitrate] [Nitrite] [Ammonia] [pH] [Temp] [GH] [KH] [Phosphate]   │
│     ▲                                                                │
│  Selected: Nitrate                                                   │
│                                                                      │
│  Chart Title: Nitrate (NO₃) ppm                                      │
│                                                                      │
│  Line Chart:                                                         │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 40 ├────────────────────────────────────────────────────   │     │
│  │ 35 ├─────────────────────────────────┐                     │     │
│  │ 30 ├─────────────────────────┐       │                     │     │
│  │ 25 ├──────────────┐          │       ●                     │     │
│  │ 20 ├───────┐      ●          ●                             │     │
│  │ 15 ├──┐    ●                                               │     │
│  │ 10 ├  ●                                                    │     │
│  │  5 ├────────────────────────────────────────────────────   │     │
│  │  0 ├────────────────────────────────────────────────────   │     │
│  │    └─┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┘   │     │
│  │     1/1 1/7 1/14 1/21 1/28                                │     │
│  │                                                            │     │
│  │  ┄┄┄┄┄┄┄┄┄ Target Max (40 ppm) ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄        │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Summary:                                                            │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ Latest   Average    Min      Max                           │     │
│  │   35        22       5        35                           │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  Recent Values (scrollable table):                                   │
│  ┌───────┬─────┬────┬────┬────┬────┬────┬────┬────┐               │
│  │ Date  │Temp │ pH │NH₃ │NO₂ │NO₃ │ GH │ KH │PO₄ │               │
│  ├───────┼─────┼────┼────┼────┼────┼────┼────┼────┤               │
│  │Jan 27 │25.5 │7.4 │0.25│0.1 │ 35 │ 8  │ 4  │0.2 │               │
│  │Jan 25 │25.0 │7.3 │0.5 │0.2 │ 30 │ 8  │ 4  │0.3 │               │
│  │Jan 22 │24.8 │7.4 │0.8 │0.3 │ 25 │ 7  │ 3  │0.2 │               │
│  │Jan 19 │25.2 │7.2 │1.0 │0.5 │ 20 │ 8  │ 4  │0.1 │               │
│  │Jan 16 │25.0 │7.3 │1.5 │0.8 │ 15 │ 8  │ 4  │ -  │               │
│  │Jan 13 │24.9 │7.4 │2.0 │1.0 │ 10 │ 7  │ 3  │ -  │               │
│  │Jan 10 │25.1 │7.3 │2.5 │0.5 │  5 │ 8  │ 4  │ -  │               │
│  └───────┴─────┴────┴────┴────┴────┴────┴────┴────┘               │
│                                                                      │
│  💡 Insights (manual interpretation):                                │
│  - Nitrate rising steadily (5 → 35 ppm in 17 days)                  │
│  - Approaching max threshold (40 ppm)                                │
│  - Ammonia/nitrite declining (cycling progressing)                   │
│  - **Action needed:** Water change to reduce nitrate                 │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Export] (top-right)
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        EXPORT CSV                                    │
├──────────────────────────────────────────────────────────────────────┤
│  Generating CSV...                                                   │
│                                                                      │
│  Format:                                                             │
│  Date,Time,Temp,pH,Ammonia,Nitrite,Nitrate,GH,KH,Phosphate,Notes    │
│  2025-01-27,15:45,25.5,7.4,0.25,0.1,35,8,4,0.2,                     │
│  2025-01-25,14:30,25.0,7.3,0.5,0.2,30,8,4,0.3,                      │
│  ...                                                                 │
│                                                                      │
│  ✓ CSV generated: water_tests_export.csv                            │
│                                                                      │
│  Share via:                                                          │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ [Email] [Google Drive] [Dropbox] [Save to Files]          │     │
│  └────────────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────────────┘

```

**Insights from Analysis:**
- ✅ Visual trend identification (upward/downward)
- ✅ Comparison to target ranges
- ✅ Historical data table for reference
- ⚠️ No automated alerts (manual user interpretation required)

---

## Flow 5: Backup/Recovery Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SETTINGS SCREEN                               │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Backup & Restore]
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    BACKUP & RESTORE SCREEN                           │
├──────────────────────────────────────────────────────────────────────┤
│  Info Card:                                                          │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ ℹ️  Export your tank data as JSON to back up or transfer  │     │
│  │    to another device.                                      │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  EXPORT DATA                                                         │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ 📦 3 tanks to export:                                      │     │
│  │  • Living Room Tank                                        │     │
│  │  • Bedroom Tank                                            │     │
│  │  • Office Tank                                             │     │
│  │                                                            │     │
│  │                [Export to Clipboard]                       │     │
│  └────────────────────────────────────────────────────────────┘     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Export]
                               ▼
                    ┌──────────────────────┐
                    │ Generate JSON        │
                    │ - Serialize all tanks│
                    │ - Include metadata   │
                    │ - Format with indent │
                    └──────────┬───────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    JSON STRUCTURE                                    │
├──────────────────────────────────────────────────────────────────────┤
│  {                                                                   │
│    "version": 1,                                                     │
│    "exportDate": "2025-01-27T16:00:00.000Z",                         │
│    "appVersion": "1.0.0",                                            │
│    "tanks": [                                                        │
│      {                                                               │
│        "id": "uuid-1",                                               │
│        "name": "Living Room Tank",                                   │
│        "type": "freshwater",                                         │
│        "volumeLitres": 120,                                          │
│        "livestock": [ {...}, {...} ],                                │
│        "equipment": [ {...} ],                                       │
│        "logs": [ {...}, {...}, ... ],                                │
│        "tasks": [ {...} ],                                           │
│        "photos": [ "path/to/photo1.jpg" ]                            │
│      },                                                              │
│      { ... },                                                        │
│      { ... }                                                         │
│    ]                                                                 │
│  }                                                                   │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Copy to Clipboard    │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Success Snackbar     │
                    │ "✓ Copied to         │
                    │  clipboard!"         │
                    └──────────┬───────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│            BACKUP & RESTORE SCREEN (Updated)                         │
├──────────────────────────────────────────────────────────────────────┤
│  EXPORT DATA                                                         │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ ✓ Copied to clipboard!                                     │     │
│  │ Last backup: Jan 27, 2025 4:00 PM                          │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  ═══════════════════════════════════════════════════════════        │
│                                                                      │
│  IMPORT DATA                                                         │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ Paste exported JSON data below to restore your tanks.     │     │
│  │                                                            │     │
│  │ ┌────────────────────────────────────────────────────────┐ │     │
│  │ │ Paste JSON here...                                     │ │     │
│  │ │                                                        │ │     │
│  │ │                                                        │ │     │
│  │ │                                                        │ │     │
│  │ └────────────────────────────────────────────────────────┘ │     │
│  │                                                            │     │
│  │  [Paste from Clipboard]              [Import]             │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  WHAT GETS EXPORTED                                                  │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ ✅ All tanks and settings                                  │     │
│  │ ✅ Livestock inventories                                   │     │
│  │ ✅ Water test logs                                         │     │
│  │ ✅ Plant inventories                                       │     │
│  │ ✅ Journal entries                                         │     │
│  │ ✅ Photo URLs                                              │     │
│  │ ❌ App preferences (theme, notifications)                  │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  ⚠️  IMPORT WARNING                                                  │
│  Importing data will ADD to your existing tanks — it won't          │
│  overwrite or delete anything.                                      │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               │ [User pastes JSON]
                               │ [Tap "Paste from Clipboard"]
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│            IMPORT DATA (JSON Pasted)                                 │
├──────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐     │
│  │ {                                                          │     │
│  │   "version": 1,                                            │     │
│  │   "exportDate": "2025-01-20T10:00:00.000Z",                │     │
│  │   "tanks": [ {...}, {...} ]                                │     │
│  │ }                                                          │     │
│  └────────────────────────────────────────────────────────────┘     │
│                                                                      │
│  [Paste from Clipboard]              [Import]  ◄── Now enabled      │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Import]
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    CONFIRMATION DIALOG                               │
├──────────────────────────────────────────────────────────────────────┤
│  Import Data?                                                        │
│                                                                      │
│  This will import 2 tanks.                                           │
│                                                                      │
│  Your existing data will NOT be affected.                            │
│                                                                      │
│                [Cancel]              [Import]                        │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ [Import]
                               ▼
                    ┌──────────────────────┐
                    │ Parse & Validate     │
                    │ - Check JSON format  │
                    │ - Validate structure │
                    │ - Extract tanks      │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ TankActions          │
                    │ .importTanks()       │
                    │ - Generate new UUIDs │
                    │ - Save each tank     │
                    │ - Preserve data      │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Success Snackbar     │
                    │ "Imported 2 tanks    │
                    │  successfully! ✓"    │
                    └──────────┬───────────┘
                               │
                               ▼
              ┌────────────────────────────┐
              │ Home Screen               │
              │ - New tanks visible       │
              │ - Tank switcher updated   │
              └───────────────────────────┘

```

**Key Points:**
- ✅ Export = Clipboard copy (fast, no file picker)
- ✅ Import = Additive (doesn't delete existing data)
- ⚠️ Photos NOT included (paths only)
- ✅ Validation before import (error handling)

---

## Summary of Critical Paths

| Flow | Entry Point | Exit Point | Critical Steps | Time |
|------|-------------|------------|----------------|------|
| 1. First-Time User | App Launch | First Water Test Logged | Onboarding (3) → Tank Creation (3) → Log Entry (1) | ~6 min |
| 2. Daily Maintenance | Home Screen | Task Completed | Water Change Log (1) → Task Completion (1) | ~90s |
| 3. Learning | Settings/Nav | XP Earned | Start Lesson → Read Content → Complete Quiz | ~15 min |
| 4. Tank Management | Tank Detail | Tasks Scheduled | Add Livestock → Add Equipment → Create Task | ~8 min |
| 5. Data Analysis | Tank Detail | Export CSV | Open Charts → Review Trends → Export | ~3 min |
| 6. Backup/Recovery | Settings | Data Restored | Export JSON → Import JSON | ~90s |
| 7. Settings | Settings Icon | Changes Persist | Theme Toggle → Notification Toggle | ~60s |

**All flows tested: ✅ PASS**

