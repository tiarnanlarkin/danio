# 🎯 MASTER INTEGRATION ROADMAP

**Version:** 2.0  
**Date:** 2026-02-11  
**Status:** ACTIVE - This is the single source of truth  
**Goal:** Wire ALL existing features into a cohesive, production-ready app  
**Philosophy:** NO new features until everything built is fully integrated  

---

## 📋 Executive Summary

### Current Reality
- **78% complete** with exceptional features already built
- **41% dead code** - 35 screens built but unreachable
- **Gamification 95% built, 25% integrated** - only 5/86 screens use it
- **100% offline-only** - sync architecture ready but no backend
- **Quality gates defined but never enforced** - 0% compliance

### The Mission
**Integrate everything that exists. Delete nothing. Ship a polished app.**

### Timeline Overview
| Phase | Focus | Duration | Hours | Outcome |
|-------|-------|----------|-------|---------|
| **0** | Quick Wins | 1-2 days | 8h | +30% features accessible |
| **1** | Gamification Wiring | 2 weeks | 40h | Full engagement system |
| **2** | Content Activation | 1 week | 20h | Achievements + databases |
| **3** | Quality & Polish | 1 week | 15h | Testing, bug fixes |
| **4** | Backend Integration | 4-5 weeks | 80h | Cloud sync (optional for MVP) |

**Total to MVP:** 4-6 weeks (83 hours)  
**Total to Full Product:** 10-12 weeks (163 hours)

---

## 🔄 Dependency Graph

```
Phase 0: Quick Wins (Navigation Links)
    ↓
    ├── Phase 1: Gamification Wiring (can start immediately after Phase 0)
    │       ↓
    │       └── Phase 2: Content Activation (depends on gamification working)
    │               ↓
    │               └── Phase 3: Quality & Polish (depends on features working)
    │
    └── Phase 4: Backend Integration (independent track, can run parallel to 1-3)
```

**Critical Path:** Phase 0 → 1 → 2 → 3 = MVP  
**Optional Enhancement:** Phase 4 = Full cloud-connected product

---

## 🚀 PHASE 0: Quick Wins (Day 1-2)

**Priority:** 🔴 CRITICAL - Do this first!  
**Duration:** 1-2 days  
**Hours:** 6-8 hours  
**ROI:** Highest (unlock 30% more features with minimal effort)

### Objective
Link all hidden, fully-implemented features to make them accessible to users.

### Tasks

#### 0.1 Workshop Screen Expansion (2 hours)
**File:** `lib/screens/workshop_screen.dart`

| Calculator to Add | Implementation | Time |
|-------------------|----------------|------|
| Water Change Calculator | 100% complete | 15 min |
| Stocking Calculator | 100% complete | 15 min |
| CO₂ Calculator | 98% complete | 15 min |
| Dosing Calculator | 90% complete | 15 min |
| Unit Converter | 95% complete | 15 min |
| Tank Volume Calculator | 100% complete | 15 min |
| Lighting Schedule | 85% complete | 15 min |
| Charts/Analytics | 90% complete | 15 min |

**Action:** Add grid tiles for each calculator with navigation to existing screens.

#### 0.2 Settings Screen Guides Section (2 hours)
**File:** `lib/screens/settings_screen.dart`

Create "Guides & Education" expansion section:

| Guide to Link | Category | Time |
|---------------|----------|------|
| Quick Start Guide | Getting Started | 10 min |
| Parameter Guide | Water Care | 10 min |
| Nitrogen Cycle Guide | Water Care | 10 min |
| Disease Guide | Health | 10 min |
| Algae Guide | Problems | 10 min |
| Feeding Guide | Care | 10 min |
| Equipment Guide | Setup | 10 min |
| Emergency Guide | Health | 10 min |
| Troubleshooting | Problems | 10 min |
| Glossary | Reference | 10 min |
| + 6 more guides | Various | 30 min |

**Action:** Add expandable "Guides" tile that reveals categorized guide links.

#### 0.3 Settings Screen Configuration Links (1 hour)
**File:** `lib/screens/settings_screen.dart`

| Setting to Link | Current Status | Time |
|-----------------|----------------|------|
| Notification Settings | Built, not linked | 10 min |
| Difficulty Settings | Built, not linked | 10 min |
| Backup & Restore | Built, not linked | 10 min |
| Theme Gallery | Built, not linked | 10 min |

#### 0.4 Tank Detail Enhancements (1 hour)
**File:** `lib/screens/tank_detail_screen.dart`

| Feature to Link | Action | Time |
|-----------------|--------|------|
| Charts Screen | Add "View Charts" button | 15 min |
| Tank Comparison | Add "Compare Tanks" option | 15 min |
| Tank Settings | Add settings icon | 15 min |
| Cost Tracker | Add from tank menu | 15 min |

### Phase 0 Success Criteria
- [ ] All 13 calculators accessible from Workshop
- [ ] All 16 guides accessible from Settings
- [ ] All 6 settings screens linked
- [ ] Build succeeds with no errors
- [ ] Manual navigation test passes

### Deliverables
- [ ] `PHASE_0_COMPLETION_REPORT.md`
- [ ] Updated navigation map
- [ ] Before/after screenshot comparison

---

## 🎮 PHASE 1: Gamification Wiring (Week 1-2)

**Priority:** 🔴 CRITICAL - Biggest engagement win  
**Duration:** 2 weeks  
**Hours:** 35-45 hours  
**Dependency:** Phase 0 complete

### Objective
Wire ALL gamification systems (XP, gems, hearts, streaks, shop) into every relevant screen.

### Sprint 1.1: Gem Earning Integration (8 hours)

**Problem:** Gem rewards are defined but NEVER triggered automatically.

| Trigger Event | Gems | File to Modify | Time |
|---------------|------|----------------|------|
| Lesson complete | 5 | `lesson_screen.dart` | 30 min |
| Quiz pass | 3 | `enhanced_quiz_screen.dart` | 30 min |
| Quiz perfect (100%) | 5 | `enhanced_quiz_screen.dart` | 15 min |
| Daily goal met | 5 | `user_profile_provider.dart` | 45 min |
| 7-day streak | 10 | `user_profile_provider.dart` | 30 min |
| 30-day streak | 25 | `user_profile_provider.dart` | 15 min |
| 100-day streak | 100 | `user_profile_provider.dart` | 15 min |
| Level up | 10-200 | `user_profile_provider.dart` | 45 min |
| Placement test complete | 10 | `placement_test_screen.dart` | 30 min |
| Weekly active (5+ days) | 10 | NEW logic in provider | 1 hour |
| Perfect week (7/7) | 25 | NEW logic in provider | 30 min |

**Code Pattern:**
```dart
// After XP/activity recording, add:
await ref.read(gemsProvider.notifier).addGems(
  amount: GemRewards.lessonComplete,
  source: 'lesson_complete',
  description: 'Completed ${widget.lesson.title}',
);
```

### Sprint 1.2: XP Integration Expansion (12 hours)

**Problem:** Only 5 screens award XP. Should be 30+.

| Screen/Action | XP | Current | File | Time |
|---------------|-----|---------|------|------|
| Tank created | 25 | ❌ | `create_tank_screen.dart` | 30 min |
| Livestock added | 10 | ❌ | `livestock_screen.dart` | 30 min |
| Equipment logged | 10 | ❌ | `equipment_screen.dart` | 30 min |
| Water test logged | 15 | ❌ | `add_log_screen.dart` | 30 min |
| Maintenance complete | 20 | ❌ | `tasks_screen.dart` | 30 min |
| Photo added | 5 | ❌ | `photo_gallery_screen.dart` | 30 min |
| Guide read | 5 | ❌ | All guide screens | 2 hours |
| Calculator used | 3 | ❌ | All calculator screens | 2 hours |
| Species researched | 5 | ❌ | `species_browser_screen.dart` | 30 min |
| Plant researched | 5 | ❌ | `plant_browser_screen.dart` | 30 min |
| Profile completed | 50 | ❌ | `profile_creation_screen.dart` | 30 min |
| Spaced repetition | 10 | ✅ | Already implemented | - |
| Lesson complete | 15 | ✅ | Already implemented | - |
| Quiz pass | 10 | ✅ | Already implemented | - |

### Sprint 1.3: Shop Item Effects (12 hours)

**Problem:** Items purchasable but don't function.

#### Consumables (8 hours)
| Item | Effect | Implementation | Time |
|------|--------|----------------|------|
| XP Boost (2x) | Double XP for 1 hour | Timer + XP multiplier flag | 2 hours |
| Hearts Refill | Restore all hearts | Call hearts service | 30 min |
| Streak Freeze | Protect streak for 1 day | Add freeze flag to profile | 1.5 hours |
| Quiz Retry | Retry failed quiz free | Bypass heart deduction | 1 hour |
| Timer Boost | Extra quiz time | Modify quiz timer logic | 1 hour |
| Hint Token | Reveal quiz answer | Add hint UI to quiz | 2 hours |

#### Cosmetics (4 hours)
| Item | Effect | Implementation | Time |
|------|--------|----------------|------|
| Badges (3) | Display on profile | Profile UI + badge state | 1 hour |
| Themes (5) | Change room themes | Theme provider integration | 2 hours |
| Effects (2) | Celebration animations | Confetti overlay triggers | 1 hour |

### Sprint 1.4: Home Screen Dashboard (6 hours)

**Problem:** Gamification hidden in dialogs, not prominent on home screen.

**Create Gamification Widget:**
```
┌─────────────────────────────────┐
│  🔥 7-day streak    ⭐ 1,250 XP │
│  💎 340 gems        ❤️ 5/5      │
│  📊 Daily Goal: 35/50 XP        │
│  ▓▓▓▓▓▓▓▓▓▓░░░░░ 70%           │
└─────────────────────────────────┘
```

**Files:** Create `lib/widgets/gamification_dashboard.dart`, integrate in `home_screen.dart`

### Phase 1 Success Criteria
- [ ] Gems earned automatically for all 14 trigger events
- [ ] XP awarded for 15+ hobby activities (not just lessons)
- [ ] All 6 consumable shop items functional
- [ ] All cosmetic items apply correctly
- [ ] Gamification dashboard visible on home screen
- [ ] All gamification persists after app restart

### Deliverables
- [ ] `PHASE_1_TEST_REPORT.md`
- [ ] `PHASE_1_FIXES_REQUIRED.md` (if bugs found)
- [ ] Updated shop item documentation

---

## 📚 PHASE 2: Content Activation (Week 3)

**Priority:** 🟡 HIGH  
**Duration:** 1 week  
**Hours:** 15-20 hours  
**Dependency:** Phase 1 complete (gamification must work for achievements)

### Objective
Activate the 55 built achievements and expand databases to production scale.

### Sprint 2.1: Achievement Activation (8 hours)

**Problem:** 55 achievements defined, 0 actively unlocking.

#### Priority 1: Core Learning Achievements (4 hours)
| Achievement | Trigger | Test Case | Time |
|-------------|---------|-----------|------|
| First Steps | 1 lesson | Complete any lesson | 20 min |
| Getting Started | 10 lessons | Counter check | 20 min |
| Dedicated Learner | 50 lessons | Counter check | 15 min |
| XP Milestones (8) | 100-50k XP | XP threshold checks | 1 hour |
| Streak Achievements (4) | 3-30 days | Streak counter | 45 min |
| Placement Complete | Test done | Placement flow | 20 min |

#### Priority 2: Hobby Achievements (4 hours)
| Achievement | Trigger | Test Case | Time |
|-------------|---------|-----------|------|
| Tank Creator | 1 tank | Tank creation | 20 min |
| Tank Collector | 5 tanks | Counter | 15 min |
| Fish Parent | 10 livestock | Counter | 20 min |
| Water Tester | 10 tests logged | Counter | 20 min |
| Maintenance Master | 50 tasks done | Counter | 20 min |
| Photo Collector | 25 photos | Counter | 15 min |
| Species Explorer | 20 species viewed | Track browsing | 30 min |
| Plant Enthusiast | 10 plants viewed | Track browsing | 20 min |
| Quiz Champion | 10 perfect quizzes | Score tracking | 30 min |

### Sprint 2.2: Species Database Expansion (6 hours)

**Current:** 45 species | **Target:** 100+ (Phase 1), 200+ (Phase 2)

**Priority Species to Add (Beginner-Friendly First):**

| Category | Count | Examples | Time |
|----------|-------|----------|------|
| Tropical Community | +20 | Mollies, Platies, Swordtails | 1.5 hours |
| Cichlids (Beginner) | +15 | Kribensis, Rams, Apistos | 1.5 hours |
| Catfish & Loaches | +10 | Bristlenose, Corydoras, Kuhli | 1 hour |
| Livebearers | +10 | Endlers, various Guppy strains | 45 min |
| Rasboras & Danios | +10 | Galaxy, Chili, Zebra variants | 45 min |

**Data Template Per Species:**
```dart
Species(
  name: 'German Blue Ram',
  scientificName: 'Mikrogeophagus ramirezi',
  category: 'Cichlid',
  temperament: 'Peaceful',
  minTankSize: 20,
  temperature: TemperatureRange(78, 85),
  ph: PhRange(5.0, 7.0),
  // ... full data
)
```

### Sprint 2.3: Plant Database Expansion (4 hours)

**Current:** 20 plants | **Target:** 50+ (Phase 1), 100+ (Phase 2)

| Category | Count | Examples | Time |
|----------|-------|----------|------|
| Beginner Plants | +15 | More Anubias, Java Fern varieties | 1.5 hours |
| Stem Plants | +10 | Rotala, Ludwigia, Bacopa | 1 hour |
| Carpeting | +5 | Monte Carlo, Dwarf Hairgrass | 45 min |
| Floating | +5 | Frogbit, Salvinia, Red Root | 45 min |

### Phase 2 Success Criteria
- [ ] 25+ achievements actively unlocking and displaying
- [ ] Species database at 100+ entries
- [ ] Plant database at 50+ entries
- [ ] All achievements tested end-to-end
- [ ] Achievement unlock notifications working

### Deliverables
- [ ] `PHASE_2_TEST_REPORT.md`
- [ ] Updated species/plant count documentation
- [ ] Achievement testing checklist (all 55)

---

## ✅ PHASE 3: Quality & Polish (Week 4)

**Priority:** 🟡 HIGH  
**Duration:** 1 week  
**Hours:** 12-18 hours  
**Dependency:** Phases 0-2 complete

### Objective
Enforce quality gates, fix all P0/P1 bugs, ensure production readiness.

### Sprint 3.1: Automated Quality Checks Setup (4 hours)

**Create:** `scripts/quality_gates/run_all_checks.sh`

```bash
#!/bin/bash
# Tier 1: Mandatory (blocking)
flutter analyze                    # Zero errors
dart format --set-exit-if-changed . # Formatting
flutter test                        # All tests pass

# Tier 2: Recommended (warnings)
# Code coverage check
# APK size check (<100MB release)
# Startup time check (<3s)
```

### Sprint 3.2: Bug Triage & Fixes (8 hours)

**Known Issues from Audits:**

| Bug | Priority | Status | Time to Fix |
|-----|----------|--------|-------------|
| Tank creation form validation | P0 | Documented | 2 hours |
| Marine tank "coming soon" | P1 | Decision needed | 1 hour |
| Duplicate screens (learn vs study) | P1 | Consolidate | 1 hour |
| Unused go_router dependency | P2 | Remove or use | 30 min |
| Empty assets folder | P2 | Add icons/images | 2 hours |

### Sprint 3.3: Regression Testing (4 hours)

**Test Each Phase's Features:**

| Phase | Test Cases | Time |
|-------|------------|------|
| Phase 0 | All navigation links work | 1 hour |
| Phase 1 | Gems/XP/shop integration | 1.5 hours |
| Phase 2 | Achievements unlock, DB queries | 1 hour |
| Overall | Full user journey test | 30 min |

### Sprint 3.4: Documentation Update (2 hours)

- [ ] Update README with current feature list
- [ ] Create CHANGELOG.md
- [ ] Update roadmap status
- [ ] Create user-facing feature documentation

### Phase 3 Success Criteria
- [ ] `flutter analyze` returns 0 errors
- [ ] All unit tests pass
- [ ] All P0 bugs fixed
- [ ] All P1 bugs fixed or explicitly deferred
- [ ] Release APK builds successfully
- [ ] APK size < 100MB

### Deliverables
- [ ] `PHASE_3_QUALITY_REPORT.md`
- [ ] Clean `flutter analyze` output
- [ ] Release APK artifact

---

## ☁️ PHASE 4: Backend Integration (Week 5-10)

**Priority:** 🟢 OPTIONAL FOR MVP  
**Duration:** 4-6 weeks  
**Hours:** 80-100 hours  
**Dependency:** Phase 3 complete (stable app first)

### Objective
Connect existing sync architecture to Supabase backend for cloud features.

### Why Optional for MVP?
- App works 100% offline already
- Can launch MVP without backend
- Backend adds complexity and cost
- Get user feedback first, then add cloud

### If Proceeding with Backend:

#### 4.1 Supabase Setup (Week 5)
- [ ] Create Supabase project
- [ ] Design PostgreSQL schema (7 tables)
- [ ] Set up Row-Level Security policies
- [ ] Create photo storage bucket

#### 4.2 Authentication (Week 6)
- [ ] Email/password signup
- [ ] Google Sign-In
- [ ] Apple Sign-In (iOS requirement)
- [ ] Guest mode (offline-only option)

#### 4.3 Sync Service Connection (Week 7-8)
- [ ] Replace fake delay with real API calls
- [ ] Implement dual-write (local + cloud)
- [ ] Test conflict resolution
- [ ] Handle offline queue

#### 4.4 Photo Sync (Week 9)
- [ ] Upload to Supabase Storage
- [ ] Thumbnail generation
- [ ] Lazy loading from cloud

#### 4.5 Real-Time Features (Week 10)
- [ ] WebSocket subscriptions
- [ ] Multi-device sync testing
- [ ] Sync status UI

### Phase 4 Success Criteria
- [ ] User can create account and sign in
- [ ] Data syncs between devices
- [ ] Offline mode still works perfectly
- [ ] Conflict resolution handles edge cases
- [ ] Photos upload and display from cloud

---

## 📊 Time Summary

### Path to MVP (Phases 0-3)

| Phase | Duration | Hours | Cumulative |
|-------|----------|-------|------------|
| Phase 0 | 1-2 days | 8h | 8h |
| Phase 1 | 2 weeks | 40h | 48h |
| Phase 2 | 1 week | 20h | 68h |
| Phase 3 | 1 week | 15h | 83h |

**MVP Total:** ~83 hours over 4-6 weeks

### Path to Full Product (+ Phase 4)

| Phase | Duration | Hours | Cumulative |
|-------|----------|-------|------------|
| Phases 0-3 | 4-6 weeks | 83h | 83h |
| Phase 4 | 4-6 weeks | 80h | 163h |

**Full Product Total:** ~163 hours over 10-12 weeks

---

## 🎯 Definition of Done

### MVP Complete When:
- [ ] All 90 screens accessible (0% dead code)
- [ ] Gamification integrated in 30+ screens
- [ ] Gem earning works for all trigger events
- [ ] Shop items function correctly
- [ ] 25+ achievements actively unlocking
- [ ] 100+ species in database
- [ ] All P0/P1 bugs fixed
- [ ] Release APK < 100MB
- [ ] All quality gates pass

### Full Product Complete When:
- [ ] All MVP criteria met
- [ ] Cloud sync working
- [ ] Multi-device tested
- [ ] User authentication live
- [ ] Photos sync to cloud

---

## ⚠️ Rules of Engagement

### 1. NO New Features
Until all existing features are integrated, we do not build anything new. The app has enough features - it just needs them wired together.

### 2. NO Deletions Without Approval
Nothing gets deleted without Tiarnan's explicit confirmation. Every screen was built for a reason.

### 3. Quality Gates Enforced
No phase is complete until:
- `flutter analyze` passes
- All tests pass
- Test report created
- Bugs documented and triaged

### 4. Daily Progress Updates
At end of each work session:
- Update `PHASE_X_PROGRESS.md`
- Commit and push changes
- Run `save_work.bat`

### 5. One Phase at a Time
Complete each phase fully before starting the next. No skipping ahead.

---

## 🚀 Getting Started

### Day 1 Action Items

1. **Read this roadmap fully** - Understand the scope
2. **Start Phase 0** - It's the quickest win
3. **Create Phase 0 branch** (optional): `git checkout -b phase-0-quick-wins`
4. **Begin Workshop screen expansion** - First task in Phase 0

### First Commit Should Be:
```bash
git add .
git commit -m "Phase 0: Add missing calculators to Workshop screen"
git push
```

---

## 📁 Reference Documents

All detailed implementation guides:

| Document | Purpose | Location |
|----------|---------|----------|
| Navigation Roadmap | Linking 42 screens | `docs/planning/ROADMAP_NAVIGATION_ACCESSIBILITY.md` |
| Gamification Roadmap | XP/Gems/Shop wiring | `docs/planning/ROADMAP_GAMIFICATION_INTEGRATION.md` |
| Content Roadmap | Achievements/Databases | `docs/planning/ROADMAP_CONTENT_EXPANSION.md` |
| Quality Roadmap | Testing/CI/CD | `docs/planning/ROADMAP_QUALITY_ENFORCEMENT.md` |
| Backend Roadmap | Supabase integration | `docs/planning/ROADMAP_BACKEND_SYNC.md` |
| Audit Summary | Comprehensive findings | `docs/testing/COMPREHENSIVE_AUDIT_SUMMARY.md` |

---

**This is your roadmap. Follow it phase by phase. You've got this.** 🔥

---

---

## 🎯 Strategic Vision

**You're building:** The FIRST gamified, educational aquarium hobby app

**Your positioning:** "Duolingo for Aquariums"

**What NO competitor has:**
- ❌ Duolingo-style gamification (XP, streaks, hearts, levels)
- ❌ Educational content / learning progression
- ❌ Modern habit formation mechanics
- ❌ Engaging onboarding experience
- ❌ Beautiful, fun UI (all competitors feel like 2012 spreadsheets)

**Your competitive moat:**
- 50 lessons (hard to replicate)
- Gamification systems (unique in market)
- Privacy-first approach (vs AquaHome's forced social)
- Modern UX (vs spreadsheet-like competitors)

---

## 📊 Success Metrics & KPIs

### MVP Launch Targets (Post Phase 3)

**Acquisition:**
- 1,000 downloads in first month
- 4.5+ star rating
- <30% uninstall rate (first 30 days)

**Activation:**
- 70%+ complete onboarding
- 50%+ create first tank
- 30%+ complete first lesson

**Retention:**
- 50% 7-day retention (Duolingo: 55%, Industry: 20%)
- 30% 30-day retention
- 10% 90-day retention

**Engagement:**
- 5+ sessions per week (active users)
- 8+ minute average session length
- 50% complete daily goal at least once

**Learning:**
- 70% complete at least 1 lesson
- 40% complete 5+ lessons
- 20% complete 20+ lessons

---

## ⚠️ Risk Mitigation

### Risk #1: Timeline Slippage
**Mitigation:** Phase 0 quick wins first, weekly progress reviews, cut scope if needed

### Risk #2: User Acquisition Cost
**Mitigation:** ASO, Reddit/forum engagement (r/Aquariums, fishlore.com), YouTube partnerships

### Risk #3: Competition Copies Features
**Mitigation:** Speed to market, content moat (50 lessons), brand positioning

### Risk #4: Backend Costs
**Mitigation:** Supabase free tier (generous), scale only with users, monitor weekly

### Risk #5: Integration Complexity
**Mitigation:** One phase at a time, no skipping, quality gates enforced

---

## 🏁 Launch Checklist

### Pre-Launch (Week Before)
- [ ] All Phase 0-3 complete
- [ ] 0 critical bugs (P0 fixed)
- [ ] Privacy policy + Terms hosted
- [ ] App Store listings ready (screenshots, description, keywords)
- [ ] Beta test complete (20-50 users)
- [ ] Analytics instrumented
- [ ] Release APK < 100MB
- [ ] Support email ready

### Launch Day
- [ ] Submit to Google Play (Android)
- [ ] Submit to App Store (iOS)
- [ ] Post on Reddit r/Aquariums
- [ ] Post on fishlore.com forums
- [ ] Social media announcement

### Week 1 Post-Launch
- [ ] Monitor crash reports
- [ ] Respond to all reviews
- [ ] Fix P0 bugs within 24 hours
- [ ] Check KPIs daily
- [ ] Iterate based on feedback

### Month 1 Targets
- [ ] 1,000 downloads
- [ ] 4.5+ star rating
- [ ] 50% 7-day retention
- [ ] Begin Phase 4 planning (if needed)

---

## 🔮 Future Phases (Post-MVP)

**After Phases 0-4 complete, consider:**

### Phase 5: Monetization
- Premium tier ($29.99/year)
- Gem packs ($0.99-$19.99)
- Ad-free experience
- Requires user validation first

### Phase 6: Community & Social
- Friends system (opt-in)
- Leaderboards
- Activity feed
- Tank journals
- Requires backend (Phase 4)

### Phase 7: Advanced Features
- AI photo fish identification
- Disease diagnosis from photos
- Smart device integration
- User-generated content
- Requires 10,000+ users first

**Philosophy:** Validate MVP → Get users → THEN add advanced features based on real demand.

---

*Last Updated: 2026-02-11*  
*Created By: Molt (AI Agent) synthesizing 10 audit reports + 5 specialized roadmaps*  
*Total Source Material: 500KB+ of analysis*
