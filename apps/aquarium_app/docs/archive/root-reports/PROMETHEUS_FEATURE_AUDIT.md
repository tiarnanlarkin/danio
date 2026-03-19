# Feature Gap Audit — Danio

**Auditor:** Prometheus (Research Agent)  
**Date:** 2026-03-01  
**Branch:** `openclaw/ui-fixes`  
**Method:** Source code analysis + competitor research + community sentiment analysis

---

## Executive Summary

Danio is a remarkably feature-rich aquarium app — the gamification layer (XP, hearts, streaks, achievements) and educational content give it a genuine Duolingo feel that no competitor matches. However, the app has significant gaps in **daily utility features** that fish keepers actually need to open the app every day: there's no feeding tracker, no health status tracking for individual fish, no TDS/dissolved oxygen parameters, and the social features are entirely mock data. The biggest competitive opportunity is **AI-powered features** (test strip scanning, fish disease identification from photos) — no aquarium app does this well yet, and users are actively requesting it.

---

## Current Feature Set (what works)

### Core Tank Management
- ✅ Unlimited tank creation with volume, dimensions, start date, water targets
- ✅ Water parameter logging: temperature, pH, ammonia, nitrite, nitrate, GH, KH, phosphate
- ✅ Pre-fills last test values for faster entry (smart UX)
- ✅ Log types: water test, water change, observation, medication
- ✅ Photo attachment on logs (up to 5)
- ✅ Bulk entry mode for water tests
- ✅ Charts with multi-param overlay, goal zones, CSV export
- ✅ Tank journal (observation logs as entries)
- ✅ Photo gallery per tank

### Livestock
- ✅ Add/edit/delete livestock with species, count, size, date added, source, temperament, notes
- ✅ Bulk add & bulk move between tanks
- ✅ Select mode for multi-operations
- ✅ Species lookup from 122-species database
- ✅ Livestock detail screen with compatibility checking
- ✅ Care guide pulled from species database

### Equipment
- ✅ Equipment tracking with type, brand, model, settings
- ✅ Maintenance interval scheduling
- ✅ Auto-generated maintenance tasks linked to equipment
- ✅ Last serviced tracking, purchase date, expected lifespan
- ✅ Equipment-to-task synchronization (excellent)

### Tasks & Reminders
- ✅ Task management with overdue/today/upcoming/disabled sections
- ✅ Recurrence support (custom interval days)
- ✅ Priority levels
- ✅ Completion tracking with count
- ✅ Auto-generated tasks from equipment
- ✅ Separate reminders system (SharedPreferences-based)

### Species & Plants Database
- ✅ 122 freshwater fish species with care requirements
- ✅ 52 plant species
- ✅ Search + filter by care level and temperament
- ✅ Compatibility checker (multi-species comparison)

### Learning System (Duolingo-style)
- ✅ 9 learning paths, 50+ lessons
- ✅ Spaced repetition practice
- ✅ Interactive quizzes with multiple question types
- ✅ Placement test for skill assessment
- ✅ Interactive stories
- ✅ Practice hub
- ✅ 14+ comprehensive guides (nitrogen cycle, disease, feeding, algae, breeding, etc.)

### Gamification
- ✅ XP system with level progression
- ✅ Gem currency + shop (boosts, streak freezes, themes)
- ✅ Hearts system (Duolingo-style limited attempts)
- ✅ Streaks + daily goals
- ✅ 55 achievements across categories

### Tools & Calculators
- ✅ Tank volume calculator
- ✅ Water change calculator
- ✅ Stocking calculator
- ✅ CO₂ calculator
- ✅ Dosing calculator
- ✅ Unit converter
- ✅ Lighting schedule planner
- ✅ Cost tracker
- ✅ Compatibility checker

### Other
- ✅ Backup/restore
- ✅ Photo gallery
- ✅ Onboarding flow
- ✅ Difficulty settings
- ✅ Theme gallery
- ✅ Wishlist
- ✅ Glossary
- ✅ FAQ
- ✅ Settings hub with notification preferences

---

## Competitor Research Findings

### Key Competitors Analysed
| App | Strength | Weakness |
|-----|----------|----------|
| **Aquarimate** | Cloud sync, cross-device, massive species database (thousands), parameter analytics | No gamification, dated UI, expensive |
| **Fishi** | Fast species additions (weekly updates!), responsive dev team, free | Limited tank tracking, no learning system |
| **Aquarium Note** | Best-in-class parameter logging + graphing, reminders, freshwater + saltwater | No gamification, basic UI, no educational content |
| **Tetra Aquatics** | **Test strip scanning via camera** — photograph strip, auto-reads params | Single brand ecosystem, limited features |
| **JBL ProScan** | Camera-based water analysis with colour chart | Requires JBL strips, limited to water testing |
| **AquaBuildr** | Modern UI, community focus | Called "super clunky" by users |

### What Users Consistently Request (from Reddit, forums, MFK)
1. **Fast, frictionless parameter entry** — "current apps are super clunky" (most common complaint)
2. **Test strip photo scanning** — eliminate manual entry entirely
3. **Cloud sync / cross-device** — #1 infrastructure request
4. **Better species database** — "if they don't have a species, I want to request it"
5. **Feeding tracking** — universally wanted, rarely done well
6. **AI-powered diagnosis** — "take a photo of sick fish, get treatment suggestions"
7. **Community / sharing** — share tank setups, get feedback
8. **Dosing log integration** — track what you dosed and how parameters changed
9. **Not having to create an account** — friction kills adoption
10. **Widget for quick logging** — home screen widgets for fast water test entry

### What No App Does Well Yet
- **AI fish/disease identification from photos**
- **Gamified learning** (Danio's unique advantage!)
- **Predictive parameter alerts** ("your nitrate is trending up, do a water change in 2 days")
- **Beginner onboarding that actually teaches** (most apps assume knowledge)
- **Social features that aren't Facebook groups**

---

## Gap Analysis

### 🔴 Critical Gaps (missing core functionality)

**1. No Feeding Tracker**
- **Why it matters:** Feeding is the #1 daily interaction a fish keeper has with their tank. It's the most natural daily app touchpoint. Every forum user wants this.
- **What's missing:** No way to log what was fed, how much, when. No feeding schedule per species. No vacation feeding planner (there's a guide but no tracking).
- → **Suggested:** Add `FeedingLog` model (food type, amount, time). Quick-log button on home screen. Weekly feeding summary. Auto-reminders. This single feature could double daily opens.

**2. No Health Status Tracking for Livestock**
- **Why it matters:** Users need to track if a fish is sick, quarantined, or has died. Currently `Livestock` model has no `healthStatus`, `deathDate`, or `healthNotes` fields.
- **What's missing:** No way to mark fish as healthy/sick/quarantined/deceased. No mortality tracking over time. No disease diagnosis linked to livestock.
- → **Suggested:** Add health status enum (healthy, stressed, sick, quarantined, deceased) to Livestock model. Death logging with cause. Health history timeline. Link to disease guide.

**3. Social Features Are Mock Data Only**
- **Why it matters:** The friends screen, leaderboard, and activity feed exist in UI but run entirely on `mock_friends.dart` / `mock_leaderboard.dart`. Users will discover this immediately and feel deceived.
- **What's missing:** No real backend. No user accounts. No real friend connections.
- → **Suggested (for v1.0 launch):** Either clearly label these as "Coming Soon" with a waitlist, or remove them entirely. Mock data that pretends to be real is worse than no feature at all. For v1.1: Firebase Auth + Firestore.

**4. No Cloud Sync / Backup to Cloud**
- **Why it matters:** The #1 infrastructure request from users across all aquarium apps. Losing tank data when switching phones is devastating.
- **What's missing:** Backup/restore exists but is local only. No Firebase, no Supabase, no cloud.
- → **Suggested:** Already in Phase 4 roadmap. Prioritize this for v1.1. Consider offering Google Drive export as a lightweight interim.

### 🟠 High Impact Additions

**5. Missing Water Parameters: TDS, Dissolved Oxygen, Chlorine, Copper, Iron, Calcium, Magnesium**
- **Why it matters:** The `WaterTestResults` model tracks 9 params (temp, pH, ammonia, nitrite, nitrate, GH, KH, phosphate, CO2). This is good for freshwater but missing TDS (crucial for shrimp keepers — a massive community), dissolved oxygen, chlorine, and several params needed when marine support is added.
- → **Suggested:** Add TDS as a priority (shrimp keepers test this weekly). Add chlorine for tap water tracking. Other params can wait for marine support.

**6. No Dosing Log (Track What You Added)**
- **Why it matters:** Users dose fertilizers, medications, water conditioners. There's a dosing calculator but no way to log *what was actually dosed*. This means you can't correlate "I added X" with "my parameters changed to Y."
- → **Suggested:** Add `DosingLog` model (product name, amount, date, linked tank). Show on parameter charts as vertical markers. This creates an incredibly powerful diagnostic tool.

**7. No Home Screen Widget for Quick Logging**
- **Why it matters:** The biggest friction point in every aquarium app is opening the app → navigating to tank → adding a log. A widget that lets you tap "Log Water Test" from the home screen would dramatically improve retention.
- → **Suggested:** Android home screen widget with: (a) quick "Log Water Test" button, (b) days since last water change, (c) overdue tasks count.

**8. No Livestock Death/Loss Tracking**
- **Why it matters:** Understanding mortality patterns helps users learn. "3 neon tetras died in week 2 when ammonia spiked" is incredibly valuable retroactive insight.
- → **Suggested:** When removing livestock count, ask "died" vs "moved/sold/given away." Track death date and optional cause. Show mortality timeline on tank analytics.

**9. No "Quick Test" Shortcut from Home**
- **Why it matters:** The add_log_screen is excellent but requires navigating through tank detail. Fish keepers test water at the tank, phone in hand — they need to log results in <30 seconds.
- → **Suggested:** Home screen FAB or card: "Log Water Test" → select tank → pre-filled form with last values → save. Three taps maximum.

**10. Cost Tracker Not Linked to Tanks**
- **Why it matters:** The cost tracker exists as a standalone screen using SharedPreferences, completely disconnected from tanks. Users want to know "how much have I spent on Tank A vs Tank B?"
- → **Suggested:** Link expenses to specific tanks. Show per-tank cost breakdown. Monthly/yearly summaries.

### 🟡 Nice to Have

**11. Water Change Auto-Scheduling Based on Parameters**
- → If nitrate exceeds target, auto-suggest a water change task. Uses existing data, just needs logic.

**12. Species Request / Community Database**
- → Users love apps where they can request new species (see Fishi's success). Add a "Can't find your species? Request it" button.

**13. Tank Age Milestones**
- → "Your tank is 90 days old! The nitrogen cycle should be fully established." Achievement + educational moment. Data exists (tank.startDate), just not used.

**14. Parameter Color Coding in List View**
- → When viewing recent logs, color-code values that are outside target ranges. The charts do this with goal zones but the log list view doesn't.

**15. Equipment Replacement Reminders**
- → Equipment model has `expectedLifespanMonths` but I don't see it surfaced as a reminder. "Your filter media is 11 months old (expected life: 12 months)."

**16. Import from Other Apps**
- → CSV import for water test history from Aquarium Note / Aquarimate would reduce switching friction.

**17. Invertebrate-Specific Features**
- → Shrimp keeping is huge and growing. Shrimp keepers need TDS, GH/KH ratio tracking, molting observations, berried female tracking. Currently all livestock is treated the same.

**18. Seasonal Tips / Location-Aware Advice**
- → "It's summer — watch your water temperature" based on location/season. Simple but shows the app "cares."

### 💡 Differentiator Opportunities (no app does this well)

**1. 📸 AI Test Strip Scanner**
- Point camera at water test strip → AI reads the colours → auto-fills parameters. Tetra and JBL have proprietary versions tied to their strips. A brand-agnostic version would be revolutionary. 
- **Difficulty:** Medium-high (needs computer vision model training)
- **Impact:** Extremely high — eliminates the #1 friction point in aquarium keeping

**2. 🐟 AI Fish Disease Identifier**
- Take a photo of a sick fish → AI identifies potential diseases → links to treatment in the disease guide.
- No app does this. Every fish keeping forum is flooded with "what's wrong with my fish?" posts.
- **Difficulty:** High (needs trained model)
- **Impact:** Would generate massive word-of-mouth and press coverage

**3. 🔮 Predictive Parameter Alerts**
- "Based on your last 4 tests, nitrate will exceed 40ppm in ~5 days. Consider a water change by Thursday."
- Uses existing data + simple linear regression. No app does proactive prediction.
- **Difficulty:** Low-medium (data exists, just needs trend analysis)
- **Impact:** High — transforms passive logging into active guidance

**4. 🎮 Gamified Learning + Real Tank Tracking = Unique Combo**
- No competitor combines both. Aquarimate tracks tanks. Duolingo teaches. Danio does both. This IS the differentiator. Lean into it: earn XP for logging parameters, completing maintenance, hitting weekly test goals.
- Currently XP is earned primarily through learning. **Extend XP to tank management actions.**

**5. 🧬 Breeding Tracker**
- Track breeding pairs, spawn dates, fry count, growth milestones. There's a breeding guide but no tracking.
- **Difficulty:** Medium
- **Impact:** Medium-high for dedicated hobbyists (high retention cohort)

**6. 📊 "Tank Health Score"**
- Single number (0-100) based on: parameter trends, maintenance consistency, stocking level, equipment age. Like a credit score for your tank.
- Gives beginners instant feedback. "Your tank health is 82 — great! Nitrate is slightly high."
- **Difficulty:** Low-medium
- **Impact:** High — gamifies the whole tank management experience

---

## Quick Wins (implement in <1 day each)

| # | Quick Win | Effort | Impact |
|---|-----------|--------|--------|
| 1 | **"Log Water Test" FAB on home screen** — skip tank navigation, select tank in modal | 2-4 hrs | 🔥🔥🔥 |
| 2 | **Add TDS field to WaterTestResults** — just add the field + UI row in add_log | 1-2 hrs | 🔥🔥 |
| 3 | **Tank age display + milestones** — show "Day 47" on tank detail, celebrate 30/60/90/365 | 2-3 hrs | 🔥🔥 |
| 4 | **XP for logging water tests** — award 10-25 XP per water test log | 1-2 hrs | 🔥🔥🔥 |
| 5 | **"Mark as deceased" option when reducing livestock count** — ask why, log it | 2-3 hrs | 🔥🔥 |
| 6 | **Color-code out-of-range params in log list** — red/yellow/green based on tank targets | 2-3 hrs | 🔥🔥 |
| 7 | **Label social features as "Coming Soon"** — replace mock data with waitlist signup | 1-2 hrs | 🔥🔥🔥 |
| 8 | **"Request a species" button** — in species browser, mailto or form link | 30 mins | 🔥 |
| 9 | **Equipment lifespan warnings** — surface expectedLifespanMonths as alerts | 2-3 hrs | 🔥🔥 |
| 10 | **Last water change badge on home** — "5 days since last water change" on tank card | 1-2 hrs | 🔥🔥 |

---

## Recommended v1.1 Feature Set

**Theme: "Make it indispensable daily"**

The v1.0 gamification and learning are strong. v1.1 should make Danio the app users *need* to open every day for tank management.

### Priority 1 — Ship within 2 weeks of launch
1. **Feeding tracker** (quick-log, schedule, history)
2. **Quick test entry from home screen** (FAB → select tank → log)
3. **XP for tank management** (log tests, complete tasks, do water changes)
4. **Health status on livestock** (healthy/sick/quarantined/deceased)
5. **Label social features as "Coming Soon"** (critical for trust)

### Priority 2 — Ship within 1 month
6. **Tank Health Score** (composite 0-100 based on params, maintenance, stocking)
7. **Dosing log** (what was added, when, linked to charts)
8. **Predictive parameter alerts** (trend-based, "water change due by Thursday")
9. **TDS + chlorine parameters** (shrimp keeper market)
10. **Link cost tracker to tanks**

### Priority 3 — Ship within 2 months (requires backend)
11. **Firebase Auth + Cloud Sync** (the unlock for everything social)
12. **Real leaderboards + friend system** (replace mock data)
13. **Home screen widget** (Android, quick log + overdue tasks)
14. **Share tank progress** (export tank card images for social media)

### Moonshot (v2.0)
15. **AI test strip scanner** (camera → auto-fill parameters)
16. **AI fish disease identifier** (photo → diagnosis → treatment)
17. **Community tank showcases** (browse other users' setups)

---

## Summary Assessment

| Area | Score | Notes |
|------|-------|-------|
| Water Parameters | 8/10 | Solid. Missing TDS, dissolved oxygen. Entry could be faster. |
| Livestock Management | 6/10 | Good basics but no health tracking, no feeding, no mortality log. |
| Equipment Tracking | 9/10 | Excellent. Auto-task generation is a standout feature. |
| Maintenance Tasks | 8/10 | Works well. Could benefit from predictive scheduling. |
| Species Database | 7/10 | 122 species is solid for launch. Needs growth path (user requests). |
| Learning Content | 9/10 | The crown jewel. 9 paths, stories, quizzes, spaced repetition. |
| Community Features | 2/10 | All mock data. Will damage trust if shipped as-is. |
| Daily Utility | 5/10 | Learning drives engagement but tank management is too many taps away. |
| Gamification | 9/10 | Hearts, XP, streaks, achievements, shop — excellent. |
| **Overall** | **7.5/10** | **Strong education + gamification. Weak on daily tank management utility and social.** |

---

*"The best aquarium app isn't the one with the most features — it's the one you actually open every day."*

— Prometheus, Research Agent, Mount Olympus
