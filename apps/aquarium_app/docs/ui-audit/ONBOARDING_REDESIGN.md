# Aquarium App: Onboarding Redesign Specification

**Goal:** Reduce onboarding to <10 taps to first value (A+ first impression)  
**Created:** 2026-02-12  
**Status:** READY FOR IMPLEMENTATION

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Current State Analysis](#current-state-analysis)
3. [Best-in-Class Research](#best-in-class-research)
4. [Design Options](#design-options)
5. [Recommended Flow (Option B)](#recommended-flow-option-b)
6. [Screen-by-Screen Specification](#screen-by-screen-specification)
7. [Copy Suggestions](#copy-suggestions)
8. [Implementation Checklist](#implementation-checklist)

---

## Executive Summary

### The Problem
The current onboarding flow requires **25-40+ taps** before users see value (their tank dashboard). This creates significant friction and likely contributes to drop-off.

### The Solution
Redesigned progressive onboarding that delivers **first value in 6-8 taps** while deferring non-essential data collection to contextual moments.

### Key Principles
1. **Show value before asking for commitment** (Duolingo's "gradual engagement")
2. **Defer everything deferrable** (collect data when contextually relevant)
3. **Quick wins build motivation** (let users succeed fast)
4. **Make it feel like using the app, not filling forms**

---

## Current State Analysis

### Current Onboarding Flow Map

```
┌─────────────────────────────────────────────────────────────────────┐
│ CURRENT FLOW (25-40+ taps to first value)                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. Splash Screen (auto)                                            │
│         ↓                                                           │
│  2. OnboardingScreen - 3 carousel slides                            │
│     • Slide 1: "Track Your Aquariums" → Next (tap 1)               │
│     • Slide 2: "Manage Livestock" → Next (tap 2)                   │
│     • Slide 3: "Stay On Top" → Get Started (tap 3)                 │
│         ↓                                                           │
│  3. ExperienceAssessmentScreen - 4 questions                        │
│     • Q1: "Have you kept fish before?" → Select (tap 4)            │
│     • Q2: "Water parameters familiarity?" → Select (tap 5)         │
│     • Q3: "Tank type interests?" → Select (tap 6)                  │
│     • Q4: "Maintenance time?" → Select (tap 7)                     │
│     • Results screen → Start My Journey! (tap 8)                   │
│         ↓                                                           │
│  4. FirstTankWizardScreen - 4 steps                                 │
│     • Step 1: Tank Name → type + Next (taps 9-10)                  │
│     • Step 2: Tank Size → type + Next (taps 11-12)                 │
│     • Step 3: Water Type → select + Next (taps 13-14)              │
│     • Step 4: Summary → Create Tank! (tap 15)                      │
│         ↓                                                           │
│  5. HomeScreen (FINALLY!)                                           │
│                                                                     │
│  --- OR ALTERNATIVE PATH via ProfileCreationScreen ---              │
│                                                                     │
│  3b. ProfileCreationScreen (if returning without profile)           │
│     • Name field (optional) → type (taps 4-5)                      │
│     • Experience Level → select (tap 6)                            │
│     • Tank Type → select (tap 7)                                   │
│     • Goals (multi-select) → 1-6 taps (taps 8-14)                  │
│     • Continue to Assessment (tap 15)                              │
│         ↓                                                           │
│  4b. EnhancedPlacementTestScreen - 20+ questions!                   │
│     • Each question: read + select + Check Answer + Next            │
│     • Minimum path: ~10 questions × 3 taps = 30+ taps              │
│         ↓                                                           │
│  5b. PlacementResultScreen                                          │
│     • View results → Continue (tap)                                │
│         ↓                                                           │
│  6b. HomeScreen (40+ taps later)                                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Tap Count Summary (Current)
| Path | Minimum Taps | Maximum Taps | Notes |
|------|-------------|--------------|-------|
| Experience Assessment path | 15 | 20 | If user is decisive |
| Profile + Placement Test path | 40+ | 60+ | Full assessment |
| Skip-happy user | 8-10 | 12 | Skipping everything possible |

### Friction Points Identified

| # | Screen | Friction Point | Severity |
|---|--------|----------------|----------|
| 1 | OnboardingScreen | 3 carousel slides that don't add value | HIGH |
| 2 | OnboardingScreen | Generic feature descriptions | MEDIUM |
| 3 | ExperienceAssessment | 4 questions before any action | HIGH |
| 4 | ExperienceAssessment | Results screen is "dead end" | MEDIUM |
| 5 | ProfileCreation | Too many required fields | HIGH |
| 6 | ProfileCreation | Goals multi-select is overwhelming | MEDIUM |
| 7 | PlacementTest | 20+ questions is excessive | CRITICAL |
| 8 | FirstTankWizard | 4 separate steps for simple data | MEDIUM |
| 9 | All | No quick way to "just start" | CRITICAL |

### What's Essential vs Nice-to-Have

| Data Point | Essential? | When Needed | Recommendation |
|------------|-----------|-------------|----------------|
| Tank name | ✅ Yes | At creation | Keep (1 field) |
| Tank size | ✅ Yes | For stocking | Keep (1 field) |
| Tank type (FW/SW) | ✅ Yes | For content | Keep (1 tap) |
| User name | ❌ No | Display only | Defer to settings |
| Experience level | ⚠️ Nice | Content difficulty | Defer or infer |
| Learning goals | ❌ No | Content recs | Defer to later |
| Placement test | ❌ No | Skip unlocking | Make optional/later |
| Notifications setup | ❌ No | Reminders | Defer to first task |

---

## Best-in-Class Research

### Duolingo's Onboarding (Gold Standard)

**What they do brilliantly:**
1. **Gradual engagement** - Delay signup until after users experience value
2. **Goal-first** - Ask ONE question about user goals upfront
3. **Immediate action** - Users do a translation exercise within 3 taps
4. **Placement test = optional** - Only for those who want to skip basics
5. **Mascot personality** - Duo creates emotional connection
6. **Progress bars** - Visual completion bias keeps users moving

**Key metric:** Users complete a lesson BEFORE creating an account

### Headspace's Onboarding

**What they do brilliantly:**
1. **Only 3 questions** - Experience, motivation, schedule
2. **Routine anchoring** - "When do you wake up?" not "Pick a time"
3. **Immediate meditation** - First session available immediately
4. **Intrinsic motivation** - Helps users understand their "why"

**Key metric:** Under 1 minute to first meditation

### Notion's Progressive Disclosure

**What they do brilliantly:**
1. **Empty state onboarding** - Teach features in context
2. **Templates as onboarding** - Pre-filled examples show value
3. **Tooltips on demand** - No mandatory tours

### Key Patterns to Apply

| Pattern | Application to Aquarium App |
|---------|----------------------------|
| Gradual engagement | Create tank FIRST, profile later |
| Value before signup | Show dashboard before asking questions |
| One question at a time | Single-screen selections, not forms |
| Goal gradient effect | Progress bar during tank creation |
| Empty state education | First-run tooltips on dashboard |
| Deferred registration | Optional account creation |
| Quick wins | Celebrate tank creation! |

---

## Design Options

### Option A: Ultra-Minimal (5-7 taps)

```
Welcome! → Tank Name → Tank Size (slider) → Water Type → 🎉 Your Tank!
```

**Pros:**
- Fastest time to value (under 30 seconds)
- Zero friction
- Perfect for "just let me use it" users

**Cons:**
- No personalization
- Miss opportunity to collect useful data
- Learning content not customized

**Data collected:** Tank name, size, type only

### Option B: Progressive (6-8 taps) ⭐ RECOMMENDED

```
Welcome! → Quick Goal → Tank Basics (name + size + type) → 🎉 Home!
                                                              ↓
                                          First lesson teaser on dashboard
```

**Pros:**
- Balance of speed and personalization
- Collects useful goal data
- Natural upsell to learning content
- Assessment deferred but accessible

**Cons:**
- Slightly more than absolute minimum
- Goal question could be skipped

**Data collected:** User goal, tank basics

### Option C: Personalized (10-12 taps)

```
Welcome! → 3 quick questions → Tank Setup → Guided First Action → Home
```

**Pros:**
- Full personalization from start
- Learning path ready immediately
- Better for "teach me everything" users

**Cons:**
- Still 10+ taps
- Assessment upfront creates friction
- Commitment before value shown

**Data collected:** Goals, experience, tank details

---

## Recommended Flow (Option B)

### Why Option B?

1. **6-8 taps** hits the <10 target with margin
2. **Single goal question** enables personalization without friction
3. **Tank creation is the value** - gets there in 4 screens
4. **Assessment is deferred** but prominently available
5. **First lesson teaser** creates natural next step

### New Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│ NEW FLOW (6-8 taps to first value)                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ 1. WELCOME SCREEN                                  [Skip →]  │   │
│  │    ┌─────────┐                                               │   │
│  │    │  🐠    │  "Ready to track your first tank?"            │   │
│  │    │ (wave) │                                                │   │
│  │    └─────────┘                                               │   │
│  │    [Let's Go!]                                   TAP 1       │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                           ↓                                         │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ 2. QUICK GOAL (optional - can skip)              [Skip →]    │   │
│  │                                                              │   │
│  │    "What's your main focus?"                                 │   │
│  │                                                              │   │
│  │    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │   │
│  │    │ 🐟 Keep    │  │ 📊 Track   │  │ 🎓 Learn   │        │   │
│  │    │ fish alive │  │ parameters │  │ aquariums  │        │   │
│  │    └─────────────┘  └─────────────┘  └─────────────┘        │   │
│  │                                                   TAP 2      │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                           ↓                                         │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ 3. TANK SETUP (combined screen)                  [← Back]    │   │
│  │                                                              │   │
│  │    "Name your tank"                                          │   │
│  │    ┌────────────────────────────────────────────────────┐    │   │
│  │    │ Living Room Tank                              │    │   │
│  │    └────────────────────────────────────────────────────┘    │   │
│  │                                                              │   │
│  │    "How big?" (drag slider)                                  │   │
│  │    ○─────────●─────────────────○                             │   │
│  │    10 gal   [20 gal]          100+ gal                       │   │
│  │                                                              │   │
│  │    "Water type"                                              │   │
│  │    ┌─────────────┐  ┌─────────────┐                         │   │
│  │    │ 🌊 Fresh  │  │ 🐠 Salt   │                         │   │
│  │    │ (selected) │  │           │                         │   │
│  │    └─────────────┘  └─────────────┘                         │   │
│  │                                                              │   │
│  │    [Create Tank]                                TAP 3-6      │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                           ↓                                         │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ 4. CELEBRATION SCREEN (2 seconds auto-advance or tap)        │   │
│  │                                                              │   │
│  │                    🎉                                        │   │
│  │           "Living Room Tank created!"                        │   │
│  │                                                              │   │
│  │    ━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100%                         │   │
│  │                                                              │   │
│  │    [→ Go to Dashboard]                          TAP 7 (opt)  │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                           ↓                                         │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ 5. HOME SCREEN (with contextual first-run hints)             │   │
│  │                                                              │   │
│  │    ┌────────────────────────────────────────────────────┐    │   │
│  │    │ 💡 First Lesson Available!                        │    │   │
│  │    │    "The Nitrogen Cycle" - 5 min                   │    │   │
│  │    │    [Start Lesson] [Maybe Later]                   │    │   │
│  │    └────────────────────────────────────────────────────┘    │   │
│  │                                                              │   │
│  │    ┌────────────────────────────────────────────────────┐    │   │
│  │    │ Living Room Tank                           20 gal │    │   │
│  │    │ ─────────────────────────────────────────────────│    │   │
│  │    │ ℹ️ Tap to add your first water test!             │    │   │
│  │    └────────────────────────────────────────────────────┘    │   │
│  │                                                              │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  DEFERRED TO CONTEXTUAL MOMENTS:                                    │
│  • Profile name → Settings (or first time logging)                  │
│  • Experience level → Before first lesson (quick prompt)            │
│  • Placement test → Optional card on Learn tab                      │
│  • Notifications → When setting first reminder                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Tap Count Comparison

| Action | Old Flow | New Flow |
|--------|----------|----------|
| Welcome → Start | 3 (carousel) | 1 |
| Assessment | 8 (4 questions + results) | 1 (single goal) |
| Tank creation | 8-15 (4 screens) | 4 (1 combined screen) |
| To dashboard | 15-40+ | **6-8** |

### What Gets Deferred

| Data | Deferred To | Trigger |
|------|-------------|---------|
| User name | Settings | User opens settings |
| Experience level | Pre-lesson prompt | First lesson started |
| Learning goals | Learn tab | Browse learning content |
| Placement test | Learn tab banner | User taps "Skip ahead?" |
| Full profile | Profile card | Tap avatar/profile |
| Notification prefs | First reminder | Create first task |

---

## Screen-by-Screen Specification

### Screen 1: Welcome

**Purpose:** Single emotional connection point, immediately actionable

**Layout:**
```
┌────────────────────────────────────────┐
│                              [Skip →]  │
│                                        │
│           ┌──────────────┐             │
│           │     🐠      │             │
│           │   (waving)   │             │
│           └──────────────┘             │
│                                        │
│        Ready to track your             │
│          first tank?                   │
│                                        │
│    ┌──────────────────────────────┐    │
│    │       Let's Go!              │    │
│    └──────────────────────────────┘    │
│                                        │
│           Already have tanks?          │
│              [Import →]                │
└────────────────────────────────────────┘
```

**Interactions:**
- [Let's Go!] → Screen 2 (Goal)
- [Skip →] → Screen 3 (Tank Setup) 
- [Import →] → Backup restore flow

**Technical Notes:**
- Show animated fish mascot (existing branding)
- Auto-focus [Let's Go!] button
- Accessibility: Screen reader announces purpose

### Screen 2: Quick Goal

**Purpose:** Single personalization question, skip-able

**Layout:**
```
┌────────────────────────────────────────┐
│  [← Back]                    [Skip →]  │
│                                        │
│         What's your main focus?        │
│                                        │
│    ┌────────────────────────────┐      │
│    │  🐟  Keep my fish healthy  │      │
│    └────────────────────────────┘      │
│                                        │
│    ┌────────────────────────────┐      │
│    │  📊  Track water & data    │      │
│    └────────────────────────────┘      │
│                                        │
│    ┌────────────────────────────┐      │
│    │  🎓  Learn about aquariums │      │
│    └────────────────────────────┘      │
│                                        │
│    ┌────────────────────────────┐      │
│    │  🌿  Build an aquascape    │      │
│    └────────────────────────────┘      │
│                                        │
│         You can always change this     │
└────────────────────────────────────────┘
```

**Interactions:**
- Any option → Screen 3 (Tank Setup)
- [Skip →] → Screen 3 (Tank Setup) with no goal saved
- [← Back] → Screen 1

**Technical Notes:**
- Store selection in `UserProfile.primaryGoal`
- Selection auto-advances (300ms delay for visual feedback)
- If skipped, default to "fish healthy" for content recs

### Screen 3: Tank Setup (Combined)

**Purpose:** Collect all essential tank data in ONE screen

**Layout:**
```
┌────────────────────────────────────────┐
│  [← Back]                              │
│                                        │
│           Create Your Tank             │
│                                        │
│    Name                                │
│    ┌────────────────────────────────┐  │
│    │ Living Room Tank          ✏️  │  │
│    └────────────────────────────────┘  │
│                                        │
│    Size                                │
│        10      20      40      75+     │
│    ○───────●───────────────────○      │
│              20 gallons                │
│                                        │
│    Water Type                          │
│    ┌─────────────┐  ┌─────────────┐   │
│    │ 🌊 Fresh  │  │ 🐠 Salt   │   │
│    │ (selected)  │  │            │   │
│    └─────────────┘  └─────────────┘   │
│                                        │
│    ┌────────────────────────────────┐  │
│    │       Create Tank              │  │
│    └────────────────────────────────┘  │
│                                        │
│           Skip for now                 │
└────────────────────────────────────────┘
```

**Interactions:**
- Name field: Text input, auto-capitalize
- Size slider: Continuous, common presets highlighted
- Water type: Toggle buttons
- [Create Tank] → Creates tank, shows Screen 4
- [Skip for now] → HomeScreen with no tanks (empty state)

**Technical Notes:**
- Pre-fill name with "My First Tank" as placeholder
- Slider defaults to 20 gallons (most common)
- Freshwater pre-selected (most common)
- Validate: name required, size > 0
- Consider unit toggle (gallons/liters) based on locale

### Screen 4: Celebration

**Purpose:** Positive reinforcement, brief pause before dashboard

**Layout:**
```
┌────────────────────────────────────────┐
│                                        │
│                 🎉                     │
│                                        │
│        Living Room Tank                │
│            created!                    │
│                                        │
│    ━━━━━━━━━━━━━━━━━━━━━━━ 100%       │
│                                        │
│      "First tank tracked!"             │
│                                        │
│    ┌────────────────────────────────┐  │
│    │       Go to Dashboard          │  │
│    └────────────────────────────────┘  │
│                                        │
└────────────────────────────────────────┘
```

**Interactions:**
- Auto-advances after 2 seconds
- [Go to Dashboard] → HomeScreen
- Any tap → HomeScreen

**Technical Notes:**
- Confetti animation (reuse from quiz)
- Progress bar animates from 0 to 100%
- Play subtle success sound (if sounds enabled)
- Haptic feedback on completion

### Screen 5: HomeScreen (First Run)

**Purpose:** Contextual education without blocking usage

**First-Run Elements:**

1. **Lesson Banner** (dismissible):
```
┌────────────────────────────────────────┐
│ 💡 Ready to learn?                [×] │
│ Start with "The Nitrogen Cycle" - 5min │
│ [Start] [Later]                        │
└────────────────────────────────────────┘
```

2. **Empty Tank Card** (hint overlay):
```
┌────────────────────────────────────────┐
│ Living Room Tank              20 gal  │
│ ───────────────────────────────────── │
│ 📝 Tap to log your first water test! │
│                                        │
└────────────────────────────────────────┘
```

3. **Bottom Sheet** (one-time):
```
┌────────────────────────────────────────┐
│ ─────                                  │
│                                        │
│  Quick tips:                           │
│  • Swipe cards to see more tanks       │
│  • Tap + to add fish or equipment      │
│  • Check Learn tab for tutorials       │
│                                        │
│         [Got it!]                      │
└────────────────────────────────────────┘
```

**Technical Notes:**
- Store first_run_seen flags per element
- Only show tips that are relevant to current state
- Tips auto-dismiss after 5 seconds or on interaction

---

## Copy Suggestions

### Screen 1: Welcome
- **Headline:** "Ready to track your first tank?"
- **Alt:** "Let's set up your aquarium!"
- **CTA:** "Let's Go!"
- **Skip text:** "Skip intro"

### Screen 2: Quick Goal
- **Headline:** "What's your main focus?"
- **Subtext:** "You can always change this later"
- **Options:**
  - 🐟 "Keep my fish healthy"
  - 📊 "Track water parameters"
  - 🎓 "Learn about aquariums"
  - 🌿 "Build an aquascape"

### Screen 3: Tank Setup
- **Headline:** "Create Your Tank"
- **Name label:** "Give it a name"
- **Name placeholder:** "Living Room Tank"
- **Size label:** "How big is it?"
- **Type label:** "Water type"
- **CTA:** "Create Tank"
- **Skip text:** "I'll add a tank later"

### Screen 4: Celebration
- **Headline:** "[Tank Name] created!"
- **Subtext:** "Your first tank is tracked 🎉"
- **Achievement:** "First tank tracked!"
- **CTA:** "Go to Dashboard"

### First-Run Hints
- **Lesson banner:** "Ready to learn? Start with 'The Nitrogen Cycle'"
- **Empty tank:** "Tap to log your first water test!"
- **Tips:** "Swipe to see more tanks • Tap + to add fish • Check Learn for tutorials"

### Tone Guidelines
- Friendly and encouraging (never condescending)
- Use "you/your" not "users/the user"
- Emojis add personality but don't overuse
- Short sentences, action-oriented
- Celebrate small wins

---

## Implementation Checklist

### Phase 1: Core Flow Refactor (Priority: CRITICAL)

- [ ] **Create new `SimpleOnboardingScreen`**
  - [ ] Welcome screen with animated mascot
  - [ ] Goal selection (skip-able)
  - [ ] Combined tank setup screen
  - [ ] Celebration screen with confetti

- [ ] **Update routing in `main.dart`**
  - [ ] Replace `OnboardingScreen` with `SimpleOnboardingScreen`
  - [ ] Remove `ExperienceAssessmentScreen` from mandatory flow
  - [ ] Remove `ProfileCreationScreen` from mandatory flow
  - [ ] Update `_AppRouterState` logic

- [ ] **Simplify tank creation**
  - [ ] Create combined tank input widget
  - [ ] Add size slider component
  - [ ] Add water type toggle
  - [ ] Validation: name + size required

### Phase 2: Deferred Data Collection (Priority: HIGH)

- [ ] **Move experience level**
  - [ ] Add pre-lesson prompt component
  - [ ] Show before first lesson starts
  - [ ] Store in UserProfile

- [ ] **Move placement test**
  - [ ] Add "Skip Ahead?" card to Learn tab
  - [ ] Make test fully optional
  - [ ] Keep test functionality intact

- [ ] **Move profile details**
  - [ ] Add profile completion card to Settings
  - [ ] Allow name entry later
  - [ ] Make goals optional

### Phase 3: First-Run Experience (Priority: MEDIUM)

- [ ] **Add lesson banner**
  - [ ] Show on first HomeScreen visit
  - [ ] Dismissible with [×]
  - [ ] "Start" links to first lesson
  - [ ] Track dismissal in local storage

- [ ] **Add empty state hints**
  - [ ] Tank card: "Log first test" hint
  - [ ] Tasks: "Create first reminder" hint
  - [ ] Fish: "Add your first fish" hint

- [ ] **Add tips bottom sheet**
  - [ ] Show once after first HomeScreen load
  - [ ] Quick swipe/interaction tips
  - [ ] "Got it!" dismisses permanently

### Phase 4: Polish (Priority: LOW)

- [ ] **Animations**
  - [ ] Welcome mascot wave animation
  - [ ] Goal selection scale animation
  - [ ] Tank creation success animation
  - [ ] Progress bar fill animation

- [ ] **Accessibility**
  - [ ] Screen reader announcements for each step
  - [ ] Focus management between screens
  - [ ] Semantic labels for all interactive elements
  - [ ] Respect reduced motion setting

- [ ] **Analytics**
  - [ ] Track onboarding start
  - [ ] Track goal selection (or skip)
  - [ ] Track tank creation success
  - [ ] Track time-to-first-value
  - [ ] Track lesson banner engagement

### Files to Modify

| File | Changes |
|------|---------|
| `lib/main.dart` | Update router to use new onboarding |
| `lib/screens/onboarding_screen.dart` | Replace entirely |
| `lib/screens/onboarding/` | Archive old screens, create new |
| `lib/screens/home_screen.dart` | Add first-run hints |
| `lib/screens/learn_screen.dart` | Add placement test card |
| `lib/providers/user_profile_provider.dart` | Add goal field |
| `lib/services/onboarding_service.dart` | Simplify state |
| `lib/widgets/` | New components for onboarding |

### Files to Archive (Not Delete)

```
lib/screens/onboarding/ (archive entire folder)
├── experience_assessment_screen.dart → archive/
├── profile_creation_screen.dart → archive/
├── enhanced_placement_test_screen.dart → keep (used later)
├── first_tank_wizard_screen.dart → archive/
```

### New Files to Create

```
lib/screens/simple_onboarding_screen.dart
lib/widgets/goal_selector.dart
lib/widgets/tank_setup_form.dart
lib/widgets/celebration_overlay.dart
lib/widgets/first_run_hints.dart
lib/widgets/lesson_banner.dart
```

---

## Success Metrics

| Metric | Current | Target | How to Measure |
|--------|---------|--------|----------------|
| Taps to first value | 15-40+ | <10 | Analytics event timing |
| Onboarding completion rate | Unknown | >90% | Completion event tracking |
| Time to first tank | Unknown | <60 seconds | Timestamp comparison |
| First lesson started | Unknown | >40% | Event tracking |
| Day 1 retention | Unknown | >50% | Return visit tracking |

---

## Appendix: Competitor Analysis Summary

| App | Taps to Value | Key Technique |
|-----|---------------|---------------|
| Duolingo | 3-5 | Gradual engagement, product first |
| Headspace | 6-8 | 3 questions max, routine anchoring |
| Notion | 2-3 | Templates as onboarding |
| Spotify | 4-6 | Music immediately, prefs later |
| Instagram | 5-7 | Social proof, minimal required |
| **Aquarium (new)** | **6-8** | Goal + tank, defer the rest |

---

*Document created by Onboarding Redesign Agent*  
*Ready for implementation review*
