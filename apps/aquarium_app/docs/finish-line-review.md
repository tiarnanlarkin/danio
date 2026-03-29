# Danio — Finish-Line Review
**Date:** 2026-03-29  
**Prepared by:** Athena (Coordinator), synthesised from 6 specialist reviews  
**Branch:** `openclaw/stage-system` | HEAD: `d7e14ac`  
**Tests:** 750/750 ✅ | Analyze: 0 ✅ | APK: ~86.8MB

---

## 1. Current Product Reality

### What Danio Actually Is Right Now

Danio is a substantial, functional Flutter app — a Duolingo-style aquarium fishkeeping education and tank management tool. It has no direct competitor. Every aquarium app on the market is a tank manager; none combine structured education + gamification + AI. This is genuinely unclaimed territory.

**What exists and works:**
- 4-tab navigation with per-tab navigator stacks, cross-fade transitions, deep link support
- 10-screen onboarding flow with micro-lesson, fish selection, XP celebration, GDPR consent
- Tank management: create/edit/delete tanks, multi-tank switcher, livestock CRUD, equipment tracking, water parameter logging with photo attachment, task scheduling, water change reminders
- 72 lessons across 12 learning paths with substantive, accurate content (nitrogen cycle, water chemistry, first fish, maintenance, equipment, planted tanks, aquascaping, breeding, fish health, species care, advanced topics, troubleshooting)
- Spaced repetition practice engine with real SM-2 algorithm, exponential forgetting curve, 5 mastery levels
- 261 quiz questions with explanations on correct/incorrect answers
- 6 branching interactive stories (82 scenes, 110 choices) that reinforce lesson content
- 125+ fish species and 52 plants with comprehensive structured data
- Gamification: XP levels (7 tiers), gems economy, hearts system, streaks with freeze, 60 achievements across 4 rarity tiers, daily goals, gem shop with functional purchases
- AI features: Fish ID, Symptom Checker, Weekly Plan — all behind Supabase AI proxy (deployed, verified)
- 10 Workshop calculators (water change, stocking, CO₂, dosing, compatibility, cycling assistant, etc.)
- Animated home screen with fish sprites swimming in themed room backgrounds, glassmorphism bottom sheet
- Offline-first: all core features work without network
- COPPA/GDPR: age gate, analytics consent, data export, data deletion
- 750 tests, atomic JSON storage with backup/restore, Crashlytics integration
- Notification system with streak reminders, task alerts, onboarding drip sequence

**What's partial or weak:**
- Visual asset inconsistency: 2 fish sprites, 2 illustration headers, 1 placeholder, 1 onboarding background, 2 room backgrounds don't match the chibi art bible
- Test suite: 750 tests but ~75% are "doesn't crash" smoke tests; 3 critical paths (create tank, add log, complete lesson) have zero persistence verification
- 7 silent failures where `valueOrNull ?? []` shows empty data instead of error messages
- God objects: UserProfileNotifier (1,084 lines, 8 concerns), AchievementProgressNotifier (736 lines)
- 3 screens bypass StorageService (Reminders, Maintenance Checklist, Cost Tracker) — data not in backups
- Only multiple choice questions across all 261 quiz items — no fill-in-blank, matching, or ordering
- Breeding (3 lessons) and Troubleshooting (3 lessons) are thin compared to other paths
- SyncService is scaffolding only — offline queue UI exists but nothing flushes to Supabase
- 58 direct GoogleFonts.nunito() calls in onboarding bypass AppTypography
- 25 raw Material buttons bypass AppButton component
- 37 MaterialPageRoute calls bypass custom page transitions
- 1 animation controller leak in FishCardState
- Friends and Leaderboard are dormant (model only, no screens)

**What's genuinely strong:**
- Design token system: 200+ named colour constants, pre-computed alpha variants, 90%+ spacing/radius adoption, WCAG annotations
- GlassCard component: 5 variants, haptics, reduced motion, semantic labels — premium quality
- Only 5 BackdropFilter instances total (exceptional discipline)
- 159 reduced-motion checks across the codebase
- Content accuracy: Nitrospira attribution (modern), practical advice, warm writing voice
- British English: essentially clean in user-facing copy (flagged instances are Flutter SDK API names)
- Atomic JSON storage with .bak, .corrupted copies, mutex locking — production-grade
- Species unlock system fully wired to lesson progress
- Gamification economy is balanced and coherent (not bolted-on)

---

## 2. Proposed Finish Line

### What "Finished" Should Mean for Danio v1.0

This is not dream-scope. This is what the product should be before it can honestly be called complete at this stage.

#### A. Functional Finish Line

Every feature that exists should work correctly and be wired end-to-end. Specifically:

- **All 4 tabs fully functional** with consistent transitions, empty states, and error handling
- **Onboarding completes cleanly** on all device sizes with progress indicator, readable fish names, and ≥48dp tap targets
- **Tank management CRUD works and persists** — verified by tests, not assumed
- **Learning system delivers genuine education** — 72 lessons is sufficient; Breeding and Troubleshooting should expand to 6 lessons each
- **Practice system reinforces learning** — SRS works; multiple choice is sufficient for v1 but the limitation should be acknowledged
- **AI features work when online, degrade gracefully when offline** — currently correct
- **Workshop tools are useful, not placeholder** — currently correct
- **Gamification motivates without frustrating** — economy is balanced; verify Weekend Amulet wiring
- **No silent data loss** — fix valueOrNull gaps, ensure all data in backup scope
- **No crashes on any standard user path** — currently clean

**Explicitly NOT in v1 scope:**
- Real social features (friends, live leaderboards) — dormant, planned for v2
- Saltwater/reef content — freshwater only for v1
- Cloud sync (Supabase flush) — scaffolding only, acknowledged
- Google/Apple OAuth — email auth is sufficient for v1
- Hardware integrations (tank controllers, sensors)
- Video content
- Community/forum features

#### B. Product-Quality Finish Line

The app should feel intentional and premium. A first-time user should think "someone cared about this."

- **One visual identity** — every illustration, sprite, background, and header matches the chibi art bible. No photorealistic elements in an illustrated app. No flat-cel headers on the main content tabs.
- **Design system used everywhere** — onboarding typography uses AppTypography, buttons use AppButton, transitions use custom routes on main flows
- **No "this screen looks different" moments** — consistent card styles, spacing, typography, animations across all tabs
- **Error states are helpful, not silent** — users always know what happened and what to do
- **Empty states are designed and warm** — currently strong, maintain this
- **Accessibility baseline met** — WCAG AA contrast on all text, ≥48dp touch targets, reduced motion respected, semantic labels on interactive elements
- **British English throughout** — currently clean; fix the 54 instances in lesson data files

#### C. Content / Depth Finish Line

The educational content should be sufficient for a beginner to successfully set up and maintain their first aquarium, and for an intermediate aquarist to find genuine value.

- **72 lessons is sufficient** — but expand Breeding and Troubleshooting to 6 lessons each (total: ~78 lessons)
- **261 quiz questions with multiple choice is acceptable for v1** — acknowledge single-question-type limitation; plan fill-in-blank for v1.1
- **6 stories is good** — no expansion needed for v1
- **125+ species is above market average** — add Pea Puffer (commonly mistreated, high educational value)
- **52 plants is solid** — no expansion needed for v1
- **Add medication dosing safety content** — copper toxicity for shrimp, never mix medications, proper dosing guidance. This is a genuine gap that protects fish lives.
- **Fix QT tank size inconsistency** (10L vs 20L — pick 20L)
- **Restructure equipment paths** — merge or clearly sequence the 3-lesson and 5-lesson files

#### D. Visual / Art-Direction Finish Line

The app's visual identity is the chibi fish sprite style — warm, illustrated, charming. The benchmark is the Zebra Danio mascot. Everything should feel like it came from the same artist.

**Must match art bible:**
- All 15 fish sprites (2 need regen: angelfish, amano shrimp)
- Learn and Practice tab headers (both need regen — highest-impact visual fix)
- Onboarding background (replace photorealistic with illustrated)
- Placeholder image (replace watercolour with chibi silhouette)
- All 12 room backgrounds (2 need regen: cozy-living, forest)
- 4 badge icons (create — currently missing, shop feature visually incomplete)
- Fix bristlenose_pleco.png palette mode (RGBA, not P)

**Overall visual standard:**
- Warm cream/amber/teal palette
- Chibi-proportioned characters and fish
- Glassmorphism on the home stage system
- No photorealistic elements
- No flat-cel/clip-art style illustrations
- Consistent illustration quality across all screens

---

## 3. Gap Analysis

### What Stands Between Current State and the Finish Line

#### 🔴 Must Fix (blocks "finished" claim)

| # | Gap | Category | Effort |
|---|-----|----------|--------|
| 1 | Regen learn_header.webp + practice_header.webp (wrong art style, seen every session) | Visual | Medium (art generation) |
| 2 | Regen angelfish.webp + amano_shrimp.webp (fail art bible) | Visual | Medium |
| 3 | Replace onboarding_journey_bg.webp (photorealistic in illustrated app) | Visual | Medium |
| 4 | Replace placeholder.webp (wrong style) | Visual | Small |
| 5 | Regen room-bg-cozy-living.webp (5.5/10 quality) | Visual | Medium |
| 6 | Create 4 badge icons (shop feature visually broken) | Visual | Medium |
| 7 | Fix bristlenose_pleco.png palette mode (P → RGBA) | Visual | Trivial |
| 8 | Fix 7 silent valueOrNull ?? [] failures (users think data is gone) | Code | Small |
| 9 | Add 3 golden-path persistence tests (create tank, add log, complete lesson) | Code | Small |
| 10 | Fix FishSelectScreen 3-column truncation (can't read species names) | UX | Small |
| 11 | Fix "Quick start" tap target < 48dp | Accessibility | Trivial |
| 12 | Fix AppColors.primaryLight contrast failure (WCAG AA) | Accessibility | Small |
| 13 | Fix password toggle missing tooltip | Accessibility | Trivial |
| 14 | Fix _FishCardState animation controller leak | Code | Trivial |
| 15 | Batch-fix 54 American spellings in lesson data files | Content | Trivial (sed) |
| 16 | Fix QT tank size inconsistency (10L vs 20L) | Content | Trivial |
| 17 | Restructure equipment paths (merge or sequence clearly) | Content | Small |

#### 🟠 Should Fix (improves quality significantly)

| # | Gap | Category | Effort |
|---|-----|----------|--------|
| 18 | Replace 58 GoogleFonts.nunito() in onboarding with AppTypography | Polish | Small |
| 19 | Replace 25 raw Material buttons with AppButton | Polish | Small |
| 20 | Regen room-bg-forest.webp (legacy quality) | Visual | Medium |
| 21 | Replace onboarding background with illustrated alternative | Visual | Medium |
| 22 | Add medication dosing lesson (copper toxicity, mixing medications) | Content | Medium |
| 23 | Expand Troubleshooting from 3 to 6 lessons | Content | Medium |
| 24 | Expand Breeding from 3 to 6 lessons | Content | Medium |
| 25 | Add Pea Puffer to species database | Content | Small |
| 26 | Add app version display to Settings | UX | Trivial |
| 27 | Fix empty room scene safe area insets | UX | Small |
| 28 | Add example prompts to Ask Danio | UX | Small |
| 29 | Mark AI providers autoDispose | Code | Trivial |
| 30 | Add .select() to learningStats/todaysDailyGoal providers | Code | Small |
| 31 | Fix raw SnackBar in smart_screen.dart | Polish | Trivial |

#### 🟡 Nice to Have (post-launch or if time permits)

| # | Gap | Category | Effort |
|---|-----|----------|--------|
| 32 | Move Reminders/Checklist/CostTracker data into provider layer | Architecture | Medium |
| 33 | Replace 37 MaterialPageRoute with custom transitions on main flows | Polish | Medium |
| 34 | Replace CircularProgressIndicator with BubbleLoader in content screens | Polish | Small |
| 35 | Add onboarding progress indicator (step dots) | UX | Small |
| 36 | Tank room preview in Create Tank flow | UX | Medium |
| 37 | Add fill-in-blank question type | Content | Large |
| 38 | Verify Weekend Amulet goalAdjust is fully wired | Code | Small |

#### ⬜ Post-Launch (v1.1+)

- UserProfileNotifier decomposition (plan exists)
- AchievementProgressNotifier cleanup
- SQLite migration for power users
- Real social features (friends, leaderboards)
- Cloud sync implementation
- Google/Apple OAuth
- Additional story content
- Dark mode room backgrounds

---

## 4. Category Breakdown

| Area / System | Status | Score | Key Issue |
|---------------|--------|-------|-----------|
| **Tank Management** | Complete | 9/10 | Solid CRUD, multi-tank, parameter logging |
| **Learning System (72 lessons)** | Complete | 8.5/10 | Substantive, accurate, warm writing |
| **Practice / SRS** | Complete | 8/10 | Real algorithm, single question type |
| **Gamification Economy** | Complete | 8.5/10 | Balanced, coherent, motivating |
| **AI Features** | Complete | 8/10 | Deployed, working, offline-graceful |
| **Workshop Tools** | Complete | 8/10 | 10 genuinely useful calculators |
| **Home / Room View** | Complete | 8.5/10 | Distinctive, animated, glassmorphism |
| **Species Database** | Complete | 8.5/10 | 125+ fish, 52 plants, accurate data |
| **Notifications** | Complete | 8.5/10 | Streak, tasks, drip sequence, warm copy |
| **GDPR / COPPA** | Complete | 8.5/10 | Age gate, consent, export, deletion |
| **Design Token System** | Complete | 9/10 | Exceptional — pre-computed alphas, 90%+ adoption |
| **GlassCard / Components** | Complete | 9/10 | Premium quality, haptics, reduced motion |
| **Onboarding UX** | Built but partial | 7/10 | Flow is good; typography bypasses, small tap targets, wrong background |
| **Visual Asset Consistency** | Built but weak | 6.5/10 | 2 fish, 2 headers, 2 backgrounds, 4 badges, placeholder off-style |
| **Test Quality** | Built but weak | 6/10 | 750 count misleading; 75% smoke, critical paths untested |
| **Error UX** | Built but partial | 7/10 | Good framework; 7 silent failures remain |
| **Architecture Cleanliness** | Built but partial | 7/10 | God objects documented, 3 StorageService bypasses |
| **Content Depth (Breeding)** | Needs depth | 6/10 | 3 lessons, minimum viable |
| **Content Depth (Troubleshooting)** | Needs depth | 6/10 | 3 lessons, thin for urgent-need topic |
| **Medication Safety Content** | Missing | — | Not covered; genuine gap |
| **Friends / Leaderboard** | Dormant (future) | 2/10 | Model only, no screens — intentionally deferred |
| **Cloud Sync** | Scaffolding only | 3/10 | Queue exists, nothing flushes — acknowledged |

---

## 5. Major Questions / Decisions for Tiarnan

These are things the team cannot fully decide without your input:

### Q1: Where do the new visual assets come from?
The finish line requires regenerating ~10 visual assets (2 fish sprites, 2 headers, 2+ room backgrounds, 4 badges, 1 placeholder, 1 onboarding background). **Who generates these?** Options:
- Iris (our image generation agent) using the art bible spec
- External artist commission
- Tiarnan generates manually (ComfyUI, Gemini, etc.)

The art bible benchmark is clear (chibi Zebra Danio style), but execution quality matters enormously for the "someone cared about this" feel.

### Q2: Content expansion scope — how much?
The team recommends:
- Breeding: 3→6 lessons (+3)
- Troubleshooting: 3→6 lessons (+3)
- 1 new medication dosing lesson
- 1 new species (Pea Puffer)
- Fix QT tank size inconsistency
- Restructure equipment paths

**Is this the right scope, or do you want more/less?**

### Q3: How strict on the "Must Fix" list?
17 must-fix items identified. Some are trivial (1-line fixes), some require art generation (medium effort). **Are all 17 genuinely must-fix in your view, or should some move to should-fix?**

### Q4: Firebase google-services.json
Still needed for Crashlytics/Analytics to function. **When can you provide this?** App works without it, but error telemetry won't be live.

### Q5: Supabase deep link configuration
Auth redirect needs configuring. **When can you do this?** Email auth works without it for basic flow.

### Q6: App identity — is the name final?
"Danio" is distinctive and relevant (Zebra Danio = the mascot fish). **Confirmed as the final app name?**

---

## 6. Team Findings Summary

### Prometheus (Research)
**Headline:** Danio has no direct competitor. Every aquarium app is a tank manager — none combine education + gamification + AI. The $8.9B aquarium market (projected $20.8B by 2035) has no Duolingo-style education product.
- 125+ species is above market average and sufficient for v1
- Visual asset consistency is the only gap that directly harms first impressions
- Gamification mechanics are correctly implemented (Duolingo-validated patterns)
- The "information overload" pain point in fishkeeping is exactly what Danio solves

### Apollo (Design)
**Headline:** "The app is better than it looks — and it doesn't look as good as it should yet." Overall: 7.2/10.
- Two visual identities at war: the good chibi version vs legacy flat-cel/photorealistic
- Design system is genuinely excellent (token coverage, component quality)
- Highest-impact single fix: regen the Learn/Practice headers (seen every session)
- 14 must-fix items, 20 polish items, 14 future scope items catalogued
- Component quality (GlassCard, AppButton, quiz) is best-in-class for an indie Flutter app

### Argus (QA)
**Headline:** "Approved with conditions." The app won't crash and won't corrupt data for 99% of users, but the test suite guards less than it appears.
- 750 tests: ~25% genuine behaviour tests, ~75% "doesn't crash"
- 7 silent valueOrNull ?? [] failures that show empty data on storage errors
- SyncService is scaffolding only (documented honestly in code)
- 3 critical paths with zero test coverage (create tank, add log, complete lesson persistence)
- Service tests WERE added since last audit — meaningful progress
- Storage layer is production-grade (atomic writes, backups, mutex)

### Hephaestus (Architecture)
**Headline:** 7.8/10 — production-ready with a clear post-launch improvement path.
- Architecture is solid: 395 files, clean StorageService abstraction, 86 Riverpod providers
- UserProfileNotifier (1,084 lines) and AchievementProgressNotifier (736 lines) are documented god objects with a refactoring plan
- 3 screens bypass StorageService (data not in backup scope)
- 1 animation controller leak (trivial fix)
- Dead code is minimal — firebase_analytics_service deleted, linen-wall.webp gone
- Feature completeness averages ~8/10 across all systems

### Pythia (Content)
**Headline:** 8.2/10 — genuinely ready for 1.0 launch. The content is real, not filler.
- Nitrogen Cycle path is best-in-class (Nitrospira attribution, practical, well-sequenced)
- Writing reads like a real fishkeeper, not Wikipedia or AI
- Science is accurate throughout — no significant factual errors
- Breeding (3 lessons) and Troubleshooting (3 lessons) are thin
- Only multiple choice across 261 questions — no fill-in-blank or matching
- Gamification economy is balanced and rewards consistent learning
- Missing: medication dosing safety, copper toxicity, Pea Puffer

### Daedalus (Craftsman)
**Headline:** 8.1/10 — genuinely well-crafted, focused P0/P1 set remaining.
- Design token system is exceptional (200+ named constants, 90%+ adoption)
- Only 5 BackdropFilter instances (extraordinary discipline)
- 159 reduced-motion checks across the codebase
- British English is clean in user-facing copy (flagged instances are SDK names)
- P0: bristlenose palette mode, primaryLight contrast, password tooltip
- P1: header regen, 58 onboarding typography bypasses, 25 raw buttons
- GlassCard is "what separates a craftsman from a developer"

---

## 7. Recommended Finish-Line Definition

### Danio v1.0 is finished when:

**Visual Identity:**
- [ ] Every user-facing illustration matches the chibi art bible (no photorealistic, no flat-cel)
- [ ] All 15 fish sprites pass art bible review
- [ ] All 12 room backgrounds at Wave 4 quality or above
- [ ] Learn and Practice headers regenerated in chibi style
- [ ] Onboarding background is illustrated, not photorealistic
- [ ] 4 badge icons created
- [ ] Placeholder image replaced

**User Experience:**
- [ ] Onboarding fish select is readable (2-column or larger tiles)
- [ ] All tap targets ≥ 48dp
- [ ] WCAG AA contrast on all body text
- [ ] No silent data failures (all 7 valueOrNull gaps fixed)
- [ ] Error messages are specific and helpful on all primary screens
- [ ] App version visible in Settings

**Content:**
- [ ] Breeding path expanded to 6 lessons
- [ ] Troubleshooting path expanded to 6 lessons
- [ ] Medication dosing safety lesson added
- [ ] Pea Puffer added to species database
- [ ] Equipment paths restructured (merged or clearly sequenced)
- [ ] QT tank size inconsistency fixed
- [ ] 54 American spellings fixed in lesson data
- [ ] British English consistent throughout

**Code Quality:**
- [ ] 3 golden-path persistence tests pass (create tank, add log, complete lesson)
- [ ] FishCardState controller leak fixed
- [ ] AI providers marked autoDispose
- [ ] bristlenose_pleco.png saved as RGBA
- [ ] Password toggle has tooltip

**Polish:**
- [ ] Onboarding uses AppTypography (58 bypasses fixed)
- [ ] Onboarding uses AppButton (25 raw buttons fixed)
- [ ] Raw SnackBar in smart_screen replaced with DanioSnackBar

**Explicitly NOT in v1.0 finish line:**
- UserProfileNotifier decomposition (post-launch)
- SQLite migration (post-launch)
- Real social features (v2)
- Cloud sync flush (post-launch)
- Fill-in-blank question types (v1.1)
- MaterialPageRoute migration (incremental)
- StorageService bypass cleanup for Reminders/Checklist/CostTracker (v1.1)
- Dark mode room backgrounds (v2)

---

## 8. Proposed Canonical File Structure

### Files to Create (in `docs/`)

| File | Purpose | Re-read Before Every Wave? |
|------|---------|---------------------------|
| `docs/finish-line.md` | What "finished" means — the completion reference | ✅ Yes |
| `docs/product-source.md` | What exists — every screen, tab, system, flow | Specialist-relevant sections |
| `docs/feature-registry.md` | Status of every feature (complete/partial/dormant/future) | ✅ Yes |
| `docs/design-direction.md` | Visual style standard, art bible, what matches and what doesn't | ✅ Yes (for visual work) |
| `docs/content-depth.md` | Lesson expectations, content quality bar, what's needed now vs later | ✅ Yes (for content work) |
| `docs/residual-work.md` | Live gap list between current state and finish line | ✅ Yes |
| `docs/decision-ledger.md` | Log of meaningful decisions, what's in/out and why | ✅ Yes |

### Usage Rules
1. No agent may work from memory alone — reference the relevant docs
2. Every new wave must reference finish-line.md + residual-work.md + feature-registry.md
3. Every meaningful decision must be logged in decision-ledger.md
4. Every wave must update the affected docs
5. The finish line must not be casually redefined without explicit logging and justification

### Agent Reference Matrix

| Agent | Must Read |
|-------|-----------|
| **Athena** | All 7 docs |
| **Hephaestus** (code) | finish-line.md, feature-registry.md, residual-work.md, decision-ledger.md |
| **Apollo/Daedalus/Iris** (visual) | design-direction.md, residual-work.md, decision-ledger.md |
| **Pythia** (content) | content-depth.md, residual-work.md, decision-ledger.md |
| **Argus** (QA) | finish-line.md, feature-registry.md, residual-work.md |
| **Prometheus** (research) | finish-line.md, content-depth.md, decision-ledger.md |

---

*This review was conducted by the full Mount Olympus team: Prometheus (research), Apollo (design), Argus (QA), Hephaestus (architecture), Pythia (content), Daedalus (polish). Athena coordinated, challenged, and synthesised.*

*The owl sees what the lion misses. Now it's your turn to see it too.*
