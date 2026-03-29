# Danio — Product Source of Truth

**Updated:** 2026-03-29
**Branch:** `openclaw/stage-system` | **HEAD:** `d7e14ac`

---

## What Danio Is

A Duolingo-style aquarium fishkeeping education + tank management app. Flutter, offline-first, Supabase backend (Zurich). No direct competitor exists — all aquarium apps are tank managers only. Danio uniquely combines structured education + gamification + AI.

---

## App Structure

### Navigation
4-tab bottom navigation: **Home** | **Learn** | **Practice** | **Smart**
Per-tab Navigator stacks with cross-fade transitions. NavigationThrottle prevents double-tap.

### Tab: Home
- Animated room view with swimming fish sprites (chibi style)
- Bottom sheet with 3 tabs: Progress, Tanks, Today
- Tank switcher (multi-tank support)
- Returning user flows: Day 2 (WarmEntryScreen), Day 7 (milestone), Day 30 (committed)
- Streak/Hearts overlay
- Banner priority system (welcome, comeback, daily nudge)

### Tab: Learn
- 12 learning paths, 72 lessons, expandable path cards
- Path locking/unlocking based on prerequisites
- Placement test card (currently broken — FB-H5)
- Streak card, review banner, practice card

### Tab: Practice
- Spaced Repetition practice (SM-2 algorithm, 1→3→7→14→30 day intervals)
- Due card count
- Session delegation to quiz engine
- Self-assessment review mode

### Tab: Smart (AI)
- Fish ID (camera-based identification)
- Symptom Checker (multi-step triage)
- Ask Danio (conversational AI)
- Weekly Plan generation
- Anomaly History
- All behind Supabase AI proxy

### Settings (via gear icon)
- Account management (email auth)
- Notification preferences
- Backup/export/import
- GDPR consent management
- Data deletion
- 6 guide screens (Nitrogen Cycle, Water Params, Fish Health, Equipment, Algae, Disease)
- Difficulty Settings (currently broken — FB-H6)
- About screen

### Workshop (10 tools)
- Water Change Calculator
- CO₂ Calculator
- Dosing Calculator
- Stocking Calculator
- Tank Volume Calculator
- Unit Converter
- Compatibility Checker
- Cost Tracker
- Lighting Schedule
- Cycling Assistant (reachable from Tank Detail only — RF-3)

### Onboarding (10 screens)
- GDPR consent → Welcome → Experience level → Tank type → Fish select → Aha moment → Micro-lesson → Feature overview → Permission request → XP celebration

### Tank Management
- Create/edit/delete tanks
- Water parameter logging (with photo attachment)
- Equipment tracking
- Task scheduling
- Livestock CRUD (add/edit/delete/bulk add)
- Photo gallery (read-only currently)
- Water change reminders
- Journal

### Gamification
- XP levels (7 tiers)
- Gems economy (earn via lessons, streaks; spend in shop)
- Hearts/Energy system (deduct on wrong answer, time-based regen)
- Streaks with freeze purchase
- 60 achievements (4 rarity tiers)
- Daily goals
- Shop with purchases (streak freeze works; XP boost/weekend amulet broken — FB-H3, FB-H4)

### Content
- 72 lessons across 12 paths
- 261 quiz questions (multiple choice only)
- 6 branching interactive stories (82 scenes, 110 choices, 10 endings)
- 125+ fish species, 52 plants
- SRS with 5 mastery levels

### Infrastructure
- Offline-first: all core features work without network
- SharedPreferences + atomic JSON storage with .bak copies and mutex locking
- Crashlytics integration (pending google-services.json)
- Notification system (streak, tasks, onboarding drip)
- COPPA/GDPR compliant (age gate, consent, export, deletion)
- 750 tests (78% genuine behaviour tests)

---

## Tech Stack
- Flutter 3.41.6 / Dart 3.11.4
- Riverpod (86 providers)
- Supabase (Zurich, project fqmzaeutdvmqssdwduhu)
- SharedPreferences + JSON (StorageService abstraction)
- APK ~86.8MB
- Release signing configured
- GitHub Pages: privacy policy + ToS
