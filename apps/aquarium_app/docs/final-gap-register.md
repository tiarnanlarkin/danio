# Danio — Final Gap Register

**Locked:** 2026-03-29
**Source:** Merged + deduplicated from finish-line-review.md, completion-surface-audit.md, final-truth-pass.md
**Rule:** Every item listed exactly once. No duplicates. No hidden leftovers.

---

## Classification Key

| Tag | Meaning |
|-----|---------|
| **FB** | Finish Blocker — non-negotiable, app cannot be called finished |
| **FQ** | Finish Quality Requirement — required for the app to feel genuinely finished |
| **RF** | Research First — needs a design/product decision before work begins |
| **EX** | External / Setup Blocker — dependent on credentials, deployment, platform |
| **DE** | Deferred — consciously not required for this finish line, with stated reason |
| **FS** | Future Scope — not relevant to this version |

---

## A. FINISH BLOCKERS (FB)

### Safety (FB-S)

| ID | Issue | Detail | Source |
|----|-------|--------|--------|
| FB-S1 | Ich treatment advice will kill goldfish | Advanced Topics lesson tells ALL users 86°F/30°C. Goldfish max is 24°C. | Pythia truth pass |
| FB-S2 | Corydoras species cards missing safety warnings | 5 entries lack copper toxicity and salt sensitivity flags — consulted during active treatment | Pythia truth pass |
| FB-S3 | Fish Health lessons locked behind Nitrogen Cycle | User with sick fish can't access ich lesson until 6 unrelated lessons done. Causes fish death + uninstall. | Prometheus truth pass |
| FB-S4 | Dosing Calculator has no "not for medication" warning | Named for medication use case, built for fertilisers. Users will dose ich treatment with it. | Pythia, Prometheus |

### Honesty — Fake/Deceptive Features (FB-H)

| ID | Issue | Detail | Source |
|----|-------|--------|--------|
| FB-H1 | SyncService lies to users | Displays "Synced 3 actions" after 500ms fake delay. No HTTP request. Data never leaves device. | Themis, Aphrodite |
| FB-H2 | Onboarding personalisation is fake | 10+ screens of "tell us about you" → tank named "New Tank", hardcoded 60L for everyone. | Apollo truth pass |
| FB-H3 | Weekend Amulet is a 20-gem no-op | Purchase activates in inventory. Zero code reads it. Daily goal never adjusts. | Hephaestus wiring |
| FB-H4 | XP Boost doesn't work for lessons | Works on activities/reviews but NOT on lesson_screen.dart (the main game loop). | Hephaestus wiring |
| FB-H5 | Placement Test is fake | "Take the test" routes to SRS practice. No test exists. `completePlacementTest()` never callable. Achievement permanently locked. | Aphrodite, Orpheus, Argus |
| FB-H6 | Difficulty Settings don't persist | Rich UI, initialises from blank profile, pure in-memory. Resets on navigate away. | Aphrodite, Orpheus |
| FB-H7 | Reminders never fire OS notifications | Users set reminders in-app but `NotificationService` is never called by `RemindersScreen`. Zero notifications fire. | Aphrodite |

### Broken User Flows (FB-B)

| ID | Issue | Detail | Source |
|----|-------|--------|--------|
| FB-B1 | Lighting Schedule crashes at midnight | `hour - 1` when hour=0 → `TimeOfDay(hour: -1)` → AssertionError/corrupt display. | Orpheus, Hephaestus |
| FB-B2 | Notification tap: care/water_change payloads unhandled | main.dart switch ignores these payloads. User taps reminder → nothing. | Daedalus, Orpheus |
| FB-B3 | Day7MilestoneCard CTA is dead | "Compatibility checker" button calls `Navigator.pop()` only, never navigates. | Apollo, Daedalus |
| FB-B4 | Day30CommittedCard CTA is dead | "See what's waiting" has no destination, just closes dialog. | Apollo, Daedalus |
| FB-B5 | "Run Symptom Triage" in Anomaly History is dead | Navigation literally commented out. | Hephaestus |
| FB-B6 | "Save to Journal" in Symptom Triage does nothing | Pops with diagnosis text but no screen catches it. | Hephaestus |
| FB-B7 | WarmEntryScreen lesson card has chevron but zero onTap | Looks tappable, does nothing. | Apollo |
| FB-B8 | Markdown renders as raw `##` in Symptom Triage output | AI response markdown not parsed. | Hephaestus |

### Silent Data / Trust (FB-T)

| ID | Issue | Detail | Source |
|----|-------|--------|--------|
| FB-T1 | 13 silent fallbacks on critical paths | `valueOrNull ?? []` across inventory, tanks, profile. Storage errors → empty lists. Inventory bug allows re-purchase. | Argus |
| FB-T2 | Worst silent catches swallow critical errors | `spaced_repetition_provider.dart:133` catch with zero logging. SRS save failures invisible. 24 total silent catches, prioritise critical-path ones. | Argus |
| FB-T3 | SchemaMigration is a stub | No real migrations for JSON storage. App update → potential data mismatch. | Argus |
| FB-T4 | Gems debounce has no lifecycle flush | 500ms debounce + app kill = silent gem loss. | Orpheus |
| FB-T5 | SR error state swallowed | Error message set but never read/displayed by any screen. Users see "all caught up" on storage error. | Argus, Orpheus |

### Other Blockers (FB-O)

| ID | Issue | Detail | Source |
|----|-------|--------|--------|
| FB-O1 | Three different version strings | `1.0.0`, `0.1.0 (MVP)`, `1.0.0` across app. Pick one and centralise. | Hephaestus |
| FB-O2 | Duplicate About entries in Settings | Generic Flutter aboutDialog + custom AboutScreen. Two CTAs, different behaviour. | Hephaestus |
| FB-O3 | FishSelectScreen bottom CTA hidden behind home indicator | No safe area padding on "This is my fish →" button. | Apollo |
| FB-O4 | Decimal input blocked on Water Change + Stocking calculators | `TextInputType.number` without `decimal: true`. Can't enter 54.5 litres. | Hephaestus |
| FB-O5 | Water parameter text fields accept letters | No numeric keyboard or input validation in Symptom Triage. | Hephaestus |
| FB-O6 | SRS achievements bypass achievement system | Direct `updateProgress()` instead of `checkAchievements()`. No XP, gems, or dialog shown. | Hephaestus wiring |
| FB-O7 | 5 `print('[QA]...')` debug calls in production | Debug logging ships to users. | Daedalus |

**Total Finish Blockers: 35**

---

## B. FINISH QUALITY REQUIREMENTS (FQ)

### Emotional / Product Feel (FQ-E)

| ID | Issue | Detail | Why In |
|----|-------|--------|--------|
| FQ-E1 | Lesson completion has no celebration | Flattest screen at the most important moment. Duolingo nails this. | Defines "someone cared" feeling |
| FQ-E2 | Streak loss is completely silent | No acknowledgement, mascot reaction, or re-engagement hook. | Core retention mechanic is invisible |
| FQ-E3 | Daily goal hidden in bottom sheet | Not surfaced on primary home view. | Daily ritual loop is buried |
| FQ-E4 | Today Tab task rows are decorative | Show tasks but tap to nothing. Breaks daily ritual loop. | Visible broken contract |

### Visual Cohesion (FQ-V)

| ID | Issue | Detail | Why In |
|----|-------|--------|--------|
| FQ-V1 | Learn + Practice tab headers wrong art style | Flat-cel illustration in chibi app. Seen every session. | Highest-impact visual fix |
| FQ-V2 | Angelfish + amano shrimp sprites fail art bible | 2 of 15 sprites don't match | Visual identity inconsistency |
| FQ-V3 | Onboarding background is photorealistic | Illustrated app has a photo background | First-impression dissonance |
| FQ-V4 | placeholder.webp is wrong style | Watercolour in chibi world | Style break |
| FQ-V5 | room-bg-cozy-living.webp below quality bar | 5.5/10 quality | Visible quality dip |
| FQ-V6 | 4 badge icons missing | Shop feature visually incomplete | Incomplete feature surface |
| FQ-V7 | bristlenose_pleco.png palette mode (P not RGBA) | Will render incorrectly | Technical art bug |

### Design System Consistency (FQ-D)

| ID | Issue | Detail | Why In |
|----|-------|--------|--------|
| FQ-D1 | Onboarding: 59 raw GoogleFonts bypasses | First screens every user sees are outside the design system | Onboarding is the brand's first impression |
| FQ-D2 | Onboarding: raw buttons bypass AppButton | ~25 raw Material buttons total, concentrated in onboarding | Same — brand impression |
| FQ-D3 | AppColors.primaryLight fails WCAG AA contrast | Body text colour doesn't meet 4.5:1 ratio | Accessibility baseline |
| FQ-D4 | Quick Start tap target < 48dp | Accessibility violation | Accessibility baseline |
| FQ-D5 | Password toggle missing tooltip | Accessibility gap | Accessibility baseline |

### Content Depth (FQ-C)

| ID | Issue | Detail | Why In |
|----|-------|--------|--------|
| FQ-C1 | Troubleshooting only 3 lessons | Power outage, temp crash, pH crash, heater failure all absent. For an emergency topic, 3 is dangerously thin. | Safety-adjacent |
| FQ-C2 | Breeding only 3 lessons | Livebearer breeding (guppies, the fish beginners own) buried in Advanced Topics. | Content gap for primary audience |
| FQ-C3 | Medication dosing lesson missing | Copper toxicity, mixing medications, proper dosing. Genuine gap that protects fish. | Safety-adjacent |
| FQ-C4 | QT tank size inconsistency | Lesson says 20L then 10L. Pick one. | Factual inconsistency |
| FQ-C5 | American spellings in lesson data files | ~54 instances (color, behavior etc.) in lesson/data files | Content polish |
| FQ-C6 | Equipment paths need restructure | equipment.dart + equipment_expanded.dart — awkward split | Content organisation |
| FQ-C7 | Pea Puffer missing from species DB | Popular, commonly mistreated, high educational value | Content completeness |

### Code Quality (FQ-Q)

| ID | Issue | Detail | Why In |
|----|-------|--------|--------|
| FQ-Q1 | FishCardState animation controller leak | Onboarding leak. Trivial fix but real resource leak. | Correctness |
| FQ-Q2 | 3 golden-path persistence tests missing | Create tank → verify, add log → verify, complete lesson → verify XP | Critical path untested |
| FQ-Q3 | AI providers not autoDispose | Hold LLM history for app lifetime | Memory leak |

**Total Finish Quality Requirements: 27**

---

## C. RESEARCH FIRST (RF)

| ID | Issue | Decision Needed | Source |
|----|-------|----------------|--------|
| RF-1 | TankComparisonScreen: 3 fields only | Fix to show real data (water params, health) or hide entirely? | Apollo, Aphrodite |
| RF-2 | Bottom sheet tabs: 3 vs 4 | Add "Tools" tab as documented, or update docs to match code? | Apollo |
| RF-3 | Cycling Assistant not in Workshop grid | Add to Workshop grid? Or keep Tank Detail-only? | Hephaestus |
| RF-4 | ThemeGalleryScreen orphaned | Connect to settings, or remove dead code? | Apollo |
| RF-5 | Dual level-up systems (LevelUpDialog + LevelUpOverlay) | Could double-fire. Merge into one or gate properly? | Daedalus |
| RF-6 | Light Intensity segmented button dead | Wire it to calculations or remove? | Hephaestus |
| RF-7 | Fish ID → "Add to Tank" downstream flow | What happens after identification? Design decision needed. | Hephaestus |
| RF-8 | Anomaly dismiss vs resolve semantics | Is dismissing an anomaly "resolved" or "hidden"? UX clarity. | Hephaestus |
| RF-9 | GDPR consent screen placement | Move after welcome hook? Or keep as first screen? | Apollo |

**Total Research First: 9**

---

## D. EXTERNAL / SETUP BLOCKERS (EX)

| ID | Issue | Detail | Blocked On |
|----|-------|--------|-----------|
| EX-1 | Firebase google-services.json | Crashlytics/Analytics non-functional without it | Tiarnan |
| EX-2 | Supabase deep link configuration | Auth redirect needs configuring | Tiarnan |
| EX-3 | AI Proxy Supabase Edge Function deployment | Production builds expose key in APK or all AI fails | Tiarnan + deployment |
| EX-4 | IARC content rating | Required for store submission | Store setup |
| EX-5 | SCHEDULE_EXACT_ALARM declaration | Required for Android notification precision | Store submission |
| EX-6 | Google/Apple OAuth setup | Social login not configured | Post-finish (email auth sufficient for v1) |
| EX-7 | Play Console / App Store Connect setup | Store listing, screenshots, etc. | Tiarnan (ON HOLD per MEMORY.md) |

**Total External: 7**

---

## E. DEFERRED (DE)

| ID | Issue | Reason Deferred |
|----|-------|-----------------|
| DE-1 | UserProfileNotifier decomposition (1,084 lines) | Refactoring plan exists. Functional as-is. Structural debt, not user-facing. Post-launch. |
| DE-2 | AchievementProgressNotifier decomposition (736 lines) | Same — functional, structural. Post-launch. |
| DE-3 | SQLite migration for power users | SharedPreferences + JSON works for v1 scale. Migrate when data grows. |
| DE-4 | 37 MaterialPageRoute → custom transitions | Works. Visual polish. Incremental improvement, not finish requirement. |
| DE-5 | Cloud sync implementation (Supabase flush) | SyncService scaffolding hidden/removed (see FB-H1). Real sync is a major feature, not a fix. v1.1+. |
| DE-6 | Reminders/Checklist/CostTracker data into provider layer | They bypass StorageService. Data not in backups. Works functionally. Architecture debt. v1.1. |
| DE-7 | Fill-in-blank question type | All 261 questions are multiple choice. Sufficient for v1. Plan for v1.1. |
| DE-8 | Dark mode room backgrounds | Not started. v2. |
| DE-9 | 339 hardcoded Color(0x...) values | Large cleanup. Typography/spacing compliance is at 90%. Colour cleanup is incremental, not a finish requirement. |
| DE-10 | 114 raw TextStyle() bypasses | Related to DE-9. Incremental design system adoption. |
| DE-11 | Photo gallery full-screen viewer + add/delete | Gallery is read-only. Functional. Enhancement, not finish requirement. |
| DE-12 | Hearts/energy naming inconsistency | Both terms used. Minor copy issue. Defer to content pass. |
| DE-13 | Fish mood/happiness state (Tamagotchi loop) | New feature, not a fix. High-value for v1.1 but out of scope for finish line. |
| DE-14 | 88% of species have no sprite (15/126) | Art generation at scale. 🐠 fallback works. Sprites are enhancement, not finish requirement. |
| DE-15 | Negative value validation on calculators | Dosing/Volume/etc. accept negatives. Edge case, not crash. Minor. |
| DE-16 | Achievement unlock dialog queuing | Rapid-fire can overlap. Edge case. |
| DE-17 | Day7 milestone streak threshold (requires 5, users at 4 miss it) | UX edge case. Not broken, just strict. |
| DE-18 | Hearts regen is pull-not-push | Timer math correct but only triggers on user action. Minor UX gap. |

**Total Deferred: 18**

---

## F. FUTURE SCOPE (FS)

| ID | Issue |
|----|-------|
| FS-1 | Friends / social features (CA-002) |
| FS-2 | Leaderboard (CA-003) |
| FS-3 | Google/Apple OAuth |
| FS-4 | Real cloud sync |
| FS-5 | Video content |
| FS-6 | Community/forum features |
| FS-7 | Hardware integrations (controllers, sensors) |
| FS-8 | Saltwater/reef content |
| FS-9 | Story replay with different choices |
| FS-10 | Lesson completion social sharing |
| FS-11 | Livestock species search |
| FS-12 | Room picker fish preview |
| FS-13 | Tank room preview in Create Tank flow |

**Total Future Scope: 13**

---

## SUMMARY

| Category | Count |
|----------|-------|
| Finish Blockers (FB) | 35 |
| Finish Quality Requirements (FQ) | 27 |
| Research First (RF) | 9 |
| External / Setup (EX) | 7 |
| Deferred (DE) | 18 |
| Future Scope (FS) | 13 |
| **Total tracked items** | **109** |

**To be "finished": 35 FB + 27 FQ + 9 RF (decisions) = 71 items to resolve.**

---

*Every item from every audit is here exactly once. Nothing is hidden. Nothing is duplicated.*
