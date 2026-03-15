# Danio — Production Master Plan
**Created:** 2026-03-15 08:55 GMT  
**Source:** 5 audit reports (UX, Logic, Content, Navigation, Performance)  
**Total raw findings:** 205 (deduplicated to ~120 unique issues)  
**Goal:** Production-grade quality. Perfection.

---

## How to Read This

Findings from all 5 audits have been **deduplicated** (e.g. "WorkshopScreen no back button" appeared in UX, Nav, and Performance audits — counted once). Each sprint is self-contained and can be assigned to a single agent. Sprints are ordered by priority — **do not skip ahead**.

---

## 🔴 WAVE 1 — Ship Blockers (Do First)

### Sprint 1: Critical Data Safety (4 fixes)
**Estimated time:** 30 min  
**Risk if skipped:** Data loss, bricked gems, crash

| ID | Issue | File | Fix |
|----|-------|------|-----|
| LOGIC-GEM-01 | `spendGems()` catch block overwrites rollback with error state — bricks gems | `gems_provider.dart` | Remove the second `state = AsyncValue.error(e, st)` line in catch block |
| LOGIC-PRS-02 | `reviewLesson()` uses debounced save — XP lost on force-kill | `user_profile_provider.dart` | Change `reviewLesson()` to call `_saveImmediate()` instead of `_save()` |
| LOGIC-TNK-03 | `bulkMoveLivestock()` stale snapshot → StateError crash | `tank_provider.dart` | Wrap `firstWhere` per item in try-catch, or reload per item |
| LOGIC-GEM-02 | Concurrent `spendGems()` can race on balance check | `gems_provider.dart` | Add `_spending` lock flag to prevent concurrent calls |

### Sprint 2: Navigation Safety (7 fixes)
**Estimated time:** 45 min  
**Risk if skipped:** Users trapped, navigation permanently broken

| ID | Issue | File | Fix |
|----|-------|------|-----|
| NAV-BACK-01 | WorkshopScreen — no back button/AppBar | `workshop_screen.dart` | Wrap in `Scaffold` with `SliverAppBar` |
| NAV-BACK-01b | ShopStreetScreen — no back button/AppBar | `shop_street_screen.dart` | Same — wrap in `Scaffold` with `SliverAppBar` |
| NAV-EDGE-04 | NavigationThrottle static bool can permanently block ALL nav | `navigation_throttle.dart` | Add 5s safety-reset timeout via `Future.delayed` |
| NAV-BACK-02 | "Delete Tank" `popUntil(isFirst)` nukes entire tab stack | `tank_settings_screen.dart` | Replace with deterministic `pop()` × 2 |
| NAV-SHEET-05 | `_showStatsDetails` "Calendar" uses deactivated sheet context | `home_screen.dart` | Capture screen-level context before opening sheet |
| NAV-DEEP-02 | Out-of-hearts pop + PopScope(canPop:false) edge case | `lesson_screen.dart` | Add `_isExitingDueToHearts` flag to suppress confirm dialog |
| NAV-TANK-02 | `_navigateToCreateFirstTank` uses rootNavigator — no tab bar | `home_screen.dart` | Remove `rootNavigator: true`, use tab navigator |

### Sprint 3: Content Safety (P0 + Critical P1s)
**Estimated time:** 45 min  
**Risk if skipped:** Bad advice could harm fish/shrimp

| ID | Issue | File | Fix |
|----|-------|------|-----|
| LC-01 | Ammonia described as "odorless" — dangerous | `nitrogen_cycle.dart` | Remove "odorless" claim. Say "colourless — only a test kit can detect it" |
| LC-05 | Excel shrimp toxicity massively undersold | `planted_tank.dart` | "Excel is NOT SAFE for shrimp tanks at any dose" |
| LC-06 | DIY CO2 overnight crash risk undersold | `planted_tank.dart` | Add explicit warning about yeast crash suffocating fish |
| LC-07 | "50% max water change" contradicts nitrogen cycle lesson | `maintenance.dart` | Align to "50-75% is safe when temperature-matched and dechlorinated" |
| SD-01 | Betta minTankLitres: 20 → should be 40 | `species_database.dart` | Change to 40 |
| SD-06 | Discus maxTempC: 32 → should be 30 | `species_database.dart` | Change to 30 for all Discus entries |
| LC-04 | Betta minimum tank in lesson says 5 gal → should be 10 gal | `species_care.dart` | Update to "Minimum 10 gallons (40L)" |
| LC-02 | Nitrogen cycle teaches Nitrosomonas but placement test says Nitrospira | `nitrogen_cycle.dart` | Update lesson to mention Nitrospira as primary, note science evolved |

---

## 🟡 WAVE 2 — Quality & Polish (Do Next)

### Sprint 4: Achievement System Fixes (7 fixes)
**Estimated time:** 1 hour  
**Why:** 4 achievements are permanently impossible to earn — users will notice

| ID | Issue | File | Fix |
|----|-------|------|-----|
| LOGIC-ACH-02 | 6 master achievements permanently disabled but visible | `achievement_service.dart` | Mark as `isHidden: true` until implemented |
| LOGIC-ACH-03 | `midnight_scholar` only fires at exactly 00:00 | `achievement_service.dart` | Widen to `time.hour == 0` (midnight to 1AM) |
| LOGIC-ACH-04 | `weekend_warrior` — no tracking mechanism, never earnable | `achievement_service.dart` + `user_profile_provider.dart` | Track weekend activity in `recordActivity()` |
| LOGIC-ACH-05 | `heart_collector` + `daily_goal_streak` — no tracking | `achievement_service.dart` | Compute from existing data (hearts state, dailyXpHistory) |
| LOGIC-ACH-01 | `completionist` count hardcoded implicitly | `achievement_service.dart` | Compare against `AchievementDefinitions.all.length - 1` |
| LOGIC-ACH-07 | Dual achievement system (legacy + new) | `models/learning.dart` + `data/achievements.dart` | Remove legacy `Achievements` class, update all refs |
| LOGIC-GEM-04 | Day-14/50 streak rewards same as day-7/30 | `gem_economy.dart` | Define distinct `streak14Days` and `streak50Days` values |

### Sprint 5: Hearts, Streaks & Validation (8 fixes)
**Estimated time:** 1 hour

| ID | Issue | File | Fix |
|----|-------|------|-----|
| LOGIC-HRT-01 | Hearts refill timer not cleared after `refillToMax()` | `hearts_service.dart` | Set `lastHeartRefill = null` in `refillToMax()` |
| LOGIC-STK-01 | `lastActivityDate` stored as local time — timezone shift resets streak | `user_profile_provider.dart` | Store as UTC, normalise to UTC midnight |
| LOGIC-STK-03 | Streak freeze consumed even when streak is already 0 | `user_profile_provider.dart` | Add `&& c.currentStreak > 0` condition |
| LOGIC-TNK-01 | Tank volume accepts 0 or negative values | `tank_provider.dart` | Add `assert(volumeLitres > 0)` or throw |
| LOGIC-WTR-01 | Water test accepts negative pH, temp, ammonia | `log_entry.dart` | Add factory validation: pH ∈ [0,14], temp ∈ [0,50], etc. |
| LOGIC-WTR-04 | WaterTargets allows inverted ranges (phMin > phMax) | `tank.dart` | Add assertion `phMin <= phMax` |
| LOGIC-CPT-02 | Compatibility checker doesn't check tank size | `compatibility_checker_screen.dart` | Add tank size parameter, warn if species exceed tank volume |
| LOGIC-CPT-01 | `avoidWith` partial string match causes false positives | `compatibility_checker_screen.dart` | Match against exact common names only |

### Sprint 6: UX Quick Wins (8 fixes)
**Estimated time:** 1 hour

| ID | Issue | File | Fix |
|----|-------|------|-----|
| UX-003 | Demo tank has no "demo" indicator | `home_screen.dart` + `tank.dart` | Add `isDemoTank` flag, show "Demo Mode" banner in TankDetailScreen |
| ERR-002 | CreateTankScreen — no inline validation error messages | `create_tank_screen.dart` | Add `TextFormField.validator` with per-field error messages |
| ONB-001 | Force-quit recovery re-shows intro slides unnecessarily | `main.dart` | If `profileExists && !onboardingCompleted`, skip to PersonalisationScreen |
| UX-004 | Smart tab has no link to API key settings | `smart_screen.dart` | Make `_OfflineBanner` tappable → navigate to Settings AI section |
| A11Y-006 | Quiz correct/incorrect not announced to screen readers | `lesson_screen.dart` | Add `SemanticsService.announce('Correct!')` after answer selection |
| LOAD-004 | SR practice loader replaces entire Scaffold (no AppBar) | `spaced_repetition_practice_screen.dart` | Keep AppBar visible during loading |
| LOGIC-OFF-02 | Sync queue is dead code — no backend to send to | `sync_service.dart` + `offline_aware_service.dart` | Remove sync queue scaffolding OR hide from UI |
| LOGIC-LRN-02 | Quiz failures don't deduct hearts — hearts system irrelevant | `lesson_screen.dart` | Decide: deduct heart on quiz fail OR document as intentional |

### Sprint 7: Performance P1s (5 fixes)
**Estimated time:** 1.5 hours

| ID | Issue | File | Fix |
|----|-------|------|-----|
| PROV-001 | `lesson_content.dart` (4,979 lines) still imported by 3 screens | 3 screens | Migrate to `lessonContentLazy.loadPath()`, delete legacy file |
| ANIM-001 | `LightingPulseWrapper` ColorFiltered re-rasterizes room at 60fps | `lighting_pulse.dart` | Replace with colour overlay Stack approach |
| PERF-001 | `heartsStateProvider` rebuilds on every XP gain | `hearts_provider.dart` | Use `.select((a) => a.value?.hearts)` |
| BUILD-001 | `_buildLivingRoomScreen()` is 441 lines | `home_screen.dart` | Extract into `_TankCarousel`, `_RoomControlFAB`, `_DailyNudgeBanner` widgets |
| BUILD-002 | `_buildWaterTestForm()` is 378 lines | `add_log_screen.dart` | Extract each parameter into `_WaterParamRow` widgets |

---

## 🟢 WAVE 3 — Excellence (Production Polish)

### Sprint 8: Content Accuracy & Gaps (12 fixes)
**Estimated time:** 1.5 hours

| ID | Issue | File | Fix |
|----|-------|------|-----|
| SD-08 | Axolotl needs stronger avoidWith + legal disclaimer | `species_database.dart` | Expand avoidWith to all fish, add legal note |
| SD-09 | Chinese Algae Eater careLevel should be Intermediate | `species_database.dart` | Change `careLevel` |
| SD-13 | Bristlenose Pleco adultSizeCm: 15 → 12 | `species_database.dart` | Fix value |
| SD-03 | Cardinal Tetra adultSizeCm: 5 → 4 | `species_database.dart` | Fix value |
| SD-14 | Buenos Aires Tetra: add "Planted tanks" to avoidWith | `species_database.dart` | Add to avoidWith |
| LC-03 | Heater wattage 3-5W/L is outdated | `equipment.dart` | Revise to "1-3 W/L for modern tanks" |
| LC-11 | Unverified Takashi Amano quote | `planted_tank.dart` | Remove attribution or replace |
| LC-12 | Aquasoil ammonia release "2-4 weeks" → "2-6 weeks" | `planted_tank.dart` | Update text |
| ST-02 | Pleco warning imperial only | `stories.dart` | Add metric: "18 inches (45cm+)" |
| ST-05 | Water change temp in Fahrenheit only | `stories.dart` | Add Celsius equivalents |
| QZ-06 | Poor quiz distractor "It's dead" | `planted_tank.dart` | Replace with "It actively releases nutrients" |
| SG-02 | "Let us do this right" → "Let's" | `stories.dart` | Fix text |

### Sprint 9: Dead Code Removal & Architecture Cleanup
**Estimated time:** 1 hour

| ID | Issue | File | Fix |
|----|-------|------|-----|
| UX-006 | `FirstTankWizardScreen` unreachable | `first_tank_wizard_screen.dart` | Delete file OR integrate into onboarding flow |
| UX-007 | `LearningStyleScreen` + tutorial walkthrough unreachable | 2 files | Delete OR integrate |
| LOGIC-TNK-02 | `deleteTank()` and `softDeleteTank()` both exist | `tank_provider.dart` | Make `deleteTank()` private, use only `softDeleteTank()` from UI |
| LOGIC-XP-01 | Double XP write structural trap | `user_profile_provider.dart` | Consolidate into single `_applyXp()` helper |
| LOGIC-XP-03 | XP boost applied in two places | `user_profile_provider.dart` | Apply boost only at outermost call site |
| LOGIC-LRN-03 | Two separate card seeding paths | `user_profile_provider.dart` + `spaced_repetition_provider.dart` | Consolidate to single path |
| LOGIC-GEM-03 | totalEarned/totalSpent computed from truncated history | `gems_provider.dart` | Track cumulative counters as separate persisted fields |
| IMP-003 | Friends/Leaderboard stubs — verify unreachable | 2 files | Confirm hidden, add `_DEBUG` guards |

### Sprint 10: Performance Polish (Automatable + Manual)
**Estimated time:** 1 hour

| ID | Issue | Fix |
|----|-------|-----|
| CONST-001/002 | ~355 missing `const` constructors | Run `dart fix --apply` |
| ANIM-002/003 | SparkleEffect + ShimmerGlow missing RepaintBoundary | Add `RepaintBoundary` wrappers |
| ANIM-004 | `Opacity()` in 3 celebration widgets | Replace with `FadeTransition` |
| PERF-002/003/004 | Multiple widgets watching full providers for 1 field | Add targeted `.select()` calls |
| PREF-002 | `dailyXpHistory` grows unbounded | Cap to last 365 days on save |
| PREF-003 | Achievement saves fire on every check (no debounce) | Add 500ms debounce |
| IMG-002 | Journey reveal image missing cache sizing | Use `OptimizedAssetImage` |

### Sprint 11: UX Polish & Accessibility
**Estimated time:** 1.5 hours

| ID | Issue | Fix |
|----|-------|-----|
| IMP-004 | Room metaphor never explained | Add first-visit tooltip per room tab |
| INCON-005 | Hearts rules unclear to users | Add one-time tooltip explaining hearts |
| TAP-002 | Stage edge handles undiscoverable | First-visit tooltip for side panels |
| EMPTY-002 | "All Caught Up" has no next action | Add "Try a new lesson?" CTA with tap target |
| A11Y-004 | Streak/hearts banners not announced to screen readers | Wrap in `Semantics(liveRegion: true)` |
| LOAD-003 | AI response uses CircularProgressIndicator | Replace with BubbleLoader |
| NAV-MISC-01 | LearnScreen auto-scroll hardcodes 320px | Use GlobalKey + RenderBox position |
| NAV-PROFILE-01 | Notification deep links use root navigator (no tab bar) | Switch to tab first, then push within tab |

---

## 📝 DEFERRED (Post-Launch / V2)

These are real findings but acceptable for V1 launch:

| ID | Issue | Why Defer |
|----|-------|-----------|
| LOGIC-PRS-01 | Two separate persistence stores (SharedPrefs + JSON) | Architectural — needs unified storage layer (V2) |
| NAV-EDGE-02 | Quiz progress lost on app kill | Nice-to-have persistence, low frequency |
| LC-08/09/10 | Fish health, species care, advanced topics are stubs | Content gaps — ship with what exists, fill over time |
| GAP-01–07 | Missing lessons (marine, budgeting, medications, etc.) | Content roadmap, not launch blockers |
| NAV-EDGE-05 | IndexedStack holds all 5 tabs in memory | Standard Flutter pattern, acceptable |
| INCON-001/002/003 | Button families, Room vs Scaffold, Settings IA overlap | Design system cleanup — plan for V1.1 |
| IMP-002 | "Toolbox" tab naming | IA redesign — needs design thinking |
| SD-15 | Assassin Snail family classification update | Minor taxonomy, no user impact |

---

## Sprint Execution Order

```
WAVE 1 (Ship Blockers):
  Sprint 1: Critical Data Safety     → 30 min
  Sprint 2: Navigation Safety        → 45 min  
  Sprint 3: Content Safety           → 45 min
  ── flutter analyze ──
  ── Tiarnan review ──

WAVE 2 (Quality):
  Sprint 4: Achievement Fixes        → 1 hr
  Sprint 5: Hearts/Streaks/Validation→ 1 hr
  Sprint 6: UX Quick Wins            → 1 hr
  Sprint 7: Performance P1s          → 1.5 hr
  ── flutter analyze ──
  ── Tiarnan review ──

WAVE 3 (Excellence):
  Sprint 8: Content Accuracy         → 1.5 hr
  Sprint 9: Dead Code Cleanup        → 1 hr
  Sprint 10: Performance Polish      → 1 hr
  Sprint 11: UX & Accessibility      → 1.5 hr
  ── flutter analyze ──
  ── Final review ──
```

**Total estimated agent time:** ~11.5 hours  
**Parallel execution:** Sprints within each wave can run in parallel (they touch different files). Waves must be sequential.

---

## Ground Rules for Agents

1. **No changes to `pubspec.yaml`, `android/`, or `lib/main.dart`** without explicit approval
2. **Run `flutter analyze --no-pub` after every sprint** — 0 errors, 0 warnings
3. **Commit after each sprint** with a clear conventional commit message
4. **Do not delete any screen** without checking it's truly unreachable first
5. **Content changes must be factually accurate** — when in doubt, use conservative values
6. **Test data validation changes** with edge cases (0, negative, null, max values)

---

*The owl sees what the lion misses.* 🦉
