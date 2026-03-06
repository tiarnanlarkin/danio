# 🐠 DANIO — MASTER ROADMAP
### Single Source of Truth
> **Generated:** 2026-02-24 | **Compiled by:** Athena  
> **Sources:** Hephaestus Code Audit, Argus Quality Audit, Aphrodite Store Audit, DEVELOPER.md, DANIO_AUDIT_REPORT.md  
> **Status:** PLAN ONLY — no work started  
> **Overall readiness:** ~65% (Argus assessment, confirmed by cross-reference)

---

## How to Read This

- **Phases are sequential** — each gate must pass before moving on
- **Tasks within phases can be parallelised** where noted
- **Owner** = which Olympian (or Tiarnan) does the work
- **Effort** = estimated wall-clock time for the task
- **Blocker?** = does this prevent store submission?

---

## PHASE 0 — CRITICAL FIXES (Est. 2-3 hours)
*Gate: App doesn't crash on core user flows*

These are bugs that will cause crashes or broken behaviour in production.

| # | Task | Owner | Effort | Blocker? | Evidence |
|---|------|-------|--------|----------|----------|
| 0.1 | **Add CAMERA permission to AndroidManifest** — Fish ID uses `image_picker` camera but permission not declared. Will crash. | Hephaestus | 5 min | 🔴 YES | Argus B1, Hephaestus §8 |
| 0.2 | **Add READ_MEDIA_IMAGES permission** — needed for Android 13+ gallery access via `image_picker` | Hephaestus | 5 min | 🔴 YES | Argus §4 |
| 0.3 | **Fix app name to "Danio"** — currently "Aquarium Hobbyist" in AndroidManifest, "Aquarium" in MaterialApp, "aquarium_app" in pubspec | Hephaestus | 10 min | 🔴 YES | Hephaestus §8 |
| 0.4 | **Declare image asset directories in pubspec.yaml** — `assets/images/` dirs not declared, images won't bundle | Hephaestus | 10 min | 🔴 YES | Argus B10 |
| 0.5 | **Fix SRS cards showing raw concept IDs** — users see "nc_intro_section_2" instead of friendly names | Hephaestus | 2-3 hrs | 🔴 YES | Argus B7, DANIO_AUDIT H3 |
| 0.6 | **Verify/fix layout overflow on profile creation tank cards** — reported as P0 in KNOWN_ISSUES | Hephaestus | 30 min | 🟡 HIGH | KNOWN_ISSUES P0 |

**Gate 0 Criteria:** All 🔴 items fixed. App builds clean. No crash on: onboarding → first lesson → create tank → log water → Fish ID camera.

---

## PHASE 1 — CODE CLEANUP (Est. 1 day)
*Gate: Codebase is clean and shippable*

Dead code, unused deps, and technical debt that should be cleared before release.

| # | Task | Owner | Effort | Blocker? | Evidence |
|---|------|-------|--------|----------|----------|
| 1.1 | **Delete `house_navigator.dart`** (452 lines dead code) + remove imports from `home_screen.dart`, `study_screen.dart` | Hephaestus | 15 min | No | Hephaestus §3, Argus H3 |
| 1.2 | **Delete `rooms/study_screen.dart`** — orphaned, references dead HouseNavigator | Hephaestus | 5 min | No | Hephaestus §9 |
| 1.3 | **Delete 5 other orphaned screens** — `EnhancedOnboardingScreen`, `EnhancedQuizScreen`, `PlacementTestScreen`, `GemShopScreen`, `SearchScreen` | Hephaestus | 30 min | No | DEVELOPER.md M4 |
| 1.4 | **Remove `lottie` package** — declared in pubspec but zero imports in codebase | Hephaestus | 5 min | No | Hephaestus §5 |
| 1.5 | **Remove `count_withopacity.sh`** from `lib/screens/` — dev script left in source | Hephaestus | 2 min | No | Hephaestus §2 |
| 1.6 | **Move 2 remaining markdown files out of `lib/`** — inflate app bundle | Hephaestus | 10 min | No | Argus H5 |
| 1.7 | **Replace remaining 55 `.withOpacity()` calls** with `AppOverlays.*` constants — 27 in `room_scene.dart` alone (paint methods, 60fps GC pressure) | Hephaestus | 2-3 hrs | No | Hephaestus §6, Argus H6 |
| 1.8 | **Label mock social features as "Demo"** — Friends list and Leaderboard use fake data with no indication to user. Either label clearly or hide behind feature flag. | Hephaestus | 1-2 hrs | 🟡 HIGH | Hephaestus §7, Argus H2 |
| 1.9 | **Remove `FirebaseAnalyticsService`** no-op stub — entirely commented out, adds confusion | Hephaestus | 10 min | No | Hephaestus §3 |
| 1.10 | **Remove `android.enableJetifier=true`** if all deps are AndroidX | Hephaestus | 5 min | No | Hephaestus §8 |
| 1.11 | **Delete deprecated `reminderTime` field** from UserProfile model | Hephaestus | 10 min | No | Hephaestus §3 |
| 1.12 | **Address 3 `unused_field` suppressions** — use or remove the fields | Hephaestus | 15 min | No | Hephaestus §3 |

**Gate 1 Criteria:** `flutter analyze` runs clean (zero warnings). No dead code. No unused deps. Codebase is what ships — nothing more.

---

## PHASE 2 — ASSETS (Est. 3-5 days)
*Gate: App has no blank spaces or missing media*

The biggest single workstream. App currently shows empty placeholders where ~75+ images should be.

### 2A — App Icon (parallel with 2B/2C)

| # | Task | Owner | Effort | Blocker? |
|---|------|-------|--------|----------|
| 2A.1 | **Generate Shield Fish icon from Apollo's brief** — use DALL-E 3 prompt or build SVG from layer spec | Apollo | 1-2 days | 🔴 YES |
| 2A.2 | **Create adaptive icon layers** — foreground (fish) + background (teal) per Android spec | Apollo | 2 hrs | 🔴 YES |
| 2A.3 | **Generate all density variants** — mdpi through xxxhdpi + 512×512 Play Store version | Hephaestus | 30 min | 🔴 YES |

### 2B — In-App Images (parallel with 2A/2C)

| # | Task | Owner | Effort | Blocker? |
|---|------|-------|--------|----------|
| 2B.1 | **Empty state illustrations** (~10) — 300×300px, match app palette | Apollo | 1-2 days | 🟡 HIGH |
| 2B.2 | **Onboarding illustrations** (~5) — full-width, welcome flow screens | Apollo | 1 day | 🟡 HIGH |
| 2B.3 | **General illustrations** (~37 remaining) — lesson/guide graphics | Apollo | 2-3 days | 🟡 HIGH |
| 2B.4 | **Error state illustrations** (~5) — 200×200px | Apollo | 0.5 day | 🟡 HIGH |
| 2B.5 | **Achievement badge icons** (~30+) — 64×64px, 4 rarity tier variants | Apollo | 1-2 days | 🟡 HIGH |
| 2B.6 | **Feature graphics** (~10) — various promo graphics | Apollo | 1 day | No |

### 2C — Audio (parallel with 2A/2B)

| # | Task | Owner | Effort | Blocker? |
|---|------|-------|--------|----------|
| 2C.1 | **Source 5 celebration audio files** from Freesound/Pixabay (royalty-free): fanfare (2-3s), chime (1-2s), applause (2-4s), fireworks (3-5s), whoosh (0.5-1s) | Tiarnan / Hephaestus | 1-2 hrs | 🟡 HIGH |

**Gate 2 Criteria:** App icon renders at all densities. No blank image placeholders in any screen. Audio plays on celebrations (or degrades gracefully if user device has audio disabled).

---

## PHASE 3 — STORE COMPLIANCE (Est. 1-2 days)
*Gate: All Google Play hard requirements met*

Can be done in parallel with Phase 2.

| # | Task | Owner | Effort | Blocker? | Notes |
|---|------|-------|--------|----------|-------|
| 3.1 | **Write & host privacy policy** — must cover: local storage, optional Supabase cloud, optional OpenAI API, no ads, no tracking, data deletion, HTTPS encryption, AES-256 backups | Aphrodite / Themis | 2-3 hrs | 🔴 YES | Host on GitHub Pages, Notion, or standalone page |
| 3.2 | **Write Terms of Service** — in-app screens exist but empty | Aphrodite / Themis | 1-2 hrs | 🟡 HIGH | |
| 3.3 | **Complete Data Safety Form** — declare all data types per Aphrodite §4.3 matrix | Athena | 1 hr | 🔴 YES | |
| 3.4 | **Complete Content Rating questionnaire (IARC)** — expected result: PEGI 3 / Everyone, target age 13+ | Athena | 15 min | 🔴 YES | NOT "Designed for Families" — avoids COPPA |
| 3.5 | **Build signed release AAB** — keystore exists, needs `key.properties` configured | Hephaestus | 30 min | 🔴 YES | Play Store requires AAB, not APK |
| 3.6 | **Configure deobfuscation mapping upload** — needed for Play Console crash reports | Hephaestus | 15 min | 🟡 HIGH | |
| 3.7 | **Set up developer support email** | Tiarnan | 5 min | 🔴 YES | Required for store listing |
| 3.8 | **Create Google Play Developer account** ($25 one-time) | Tiarnan | 15 min | 🔴 YES | If not already done |
| 3.9 | **Verify target SDK ≥ 34** — currently delegates to Flutter default, need to confirm resolved value | Hephaestus | 10 min | 🔴 YES | Google requires API 34+ |

**Gate 3 Criteria:** Privacy policy live at public URL. Data safety form completed. Content rating submitted. Signed AAB builds successfully. Developer account active.

---

## PHASE 4 — STORE LISTING & MARKETING ASSETS (Est. 2-3 days)
*Gate: Store listing complete and submission-ready*

| # | Task | Owner | Effort | Blocker? |
|---|------|-------|--------|----------|
| 4.1 | **Write store listing copy** — title: `Danio: Learn Fishkeeping`, short desc (80 chars), full desc (4000 chars) per Aphrodite §1.2 | Aphrodite | 2-3 hrs | 🔴 YES |
| 4.2 | **Create feature graphic** (1024×500) — app name, tagline, mascot fish, brand colours, phone mockup | Apollo | 0.5 day | 🔴 YES |
| 4.3 | **Capture 8 screenshots** per Aphrodite §1.5 set — Learn tab, lesson, tank detail, charts, Fish ID, gamification, shop, themes | Apollo / Hephaestus | 1 day | 🔴 YES (min 2) |
| 4.4 | **Frame screenshots** with device bezels + captions | Apollo | 0.5 day | 🔴 YES |
| 4.5 | **Select category** — Education (primary) | Athena | 5 min | 🔴 YES |
| 4.6 | **Set Play Store tags** — aquarium, fishkeeping, fish care, aquarium management, fish learning | Aphrodite | 5 min | No |

**Gate 4 Criteria:** Store listing page looks professional. All required visual assets uploaded. Copy is polished and keyword-optimised.

---

## PHASE 5 — TESTING & HARDENING (Est. 3-5 days)
*Gate: Confidence the app won't lose user data or crash*

This phase runs parallel with Phase 4 where possible.

| # | Task | Owner | Effort | Priority |
|---|------|-------|--------|----------|
| 5.1 | **Test auth flow end-to-end** — sign up, login, logout, token refresh, error states | Argus | 0.5 day | 🔴 HIGH |
| 5.2 | **Test cloud sync** — create data offline → come online → verify sync → verify conflict resolution | Argus | 0.5 day | 🔴 HIGH |
| 5.3 | **Test backup/restore cycle** — create backup, delete data, restore, verify integrity | Argus | 0.5 day | 🔴 HIGH |
| 5.4 | **Test AI features with mock responses** — Fish ID, Symptom Triage, Weekly Plan error paths | Argus | 0.5 day | 🟡 MEDIUM |
| 5.5 | **Test all 5 calculators** — water change, dosing, CO2, unit converter, cost tracker | Argus | 0.5 day | 🟡 MEDIUM |
| 5.6 | **Test notification system** — scheduling, exact alarm fallback, streak reminders, reboot persistence | Argus | 0.5 day | 🟡 MEDIUM |
| 5.7 | **Full flow walkthrough** — 20-minute new user session: onboarding → first lesson → quiz → create tank → log water → earn XP → check streak | Argus | 2-3 hrs | 🔴 HIGH |
| 5.8 | **Migrate keystore passwords to CI env vars** | Hephaestus | 30 min | 🟡 MEDIUM |
| 5.9 | **Verify all 186 AnimationController dispose() calls** — leak check | Hephaestus | 1-2 hrs | 🟡 MEDIUM |

**Gate 5 Criteria:** Core flows pass. Auth works. Sync works. Backup/restore works. No crashes in 20-min walkthrough. No memory leaks identified.

---

## PHASE 6 — BETA (Est. 2 weeks)
*Gate: Real users validate the app works*

| # | Task | Owner | Effort | Notes |
|---|------|-------|--------|-------|
| 6.1 | **Upload AAB to Internal Testing track** — up to 100 testers, no Google review | Hephaestus | 30 min | |
| 6.2 | **Recruit 10-20 internal testers** — team, friends who keep fish, volunteers | Tiarnan / Aphrodite | 1-2 days | |
| 6.3 | **Internal testing: 3-5 days** — monitor crashes via Android Vitals, collect feedback | Argus | 3-5 days | |
| 6.4 | **Fix showstoppers from internal testing** | Hephaestus | Variable | |
| 6.5 | **Promote to Open Beta** — anyone can join | Tiarnan | 15 min | |
| 6.6 | **Seed beta in communities** — r/Aquariums, r/PlantedTank, fishkeeping Discord, Facebook groups | Aphrodite | 0.5 day | |
| 6.7 | **Target 50-200 beta users** | Aphrodite | 1-2 weeks | |
| 6.8 | **Iterate on beta feedback** — prioritise UX friction, crashes, content gaps | Hephaestus / Argus | 1 week | |

**Gate 6 Criteria:** <1% crash rate. No data loss reports. Core flow completion rate > 80%. At least 20 beta users completed onboarding.

---

## PHASE 7 — LAUNCH (Est. 1 day)
*Gate: Live on Google Play*

### Pre-Launch Checklist

- [ ] All Phase 0-5 gates passed
- [ ] Beta feedback addressed
- [ ] App icon final ✅
- [ ] Feature graphic uploaded ✅
- [ ] 8 screenshots uploaded ✅
- [ ] Store listing copy final ✅
- [ ] Privacy policy live ✅
- [ ] Content rating done ✅
- [ ] Data safety form done ✅
- [ ] Release AAB signed and uploaded ✅
- [ ] Target countries: UK, US, Australia, Canada, Ireland
- [ ] Pricing: Free
- [ ] Promote from Open Testing → Production
- [ ] Submit for Google review (1-7 days typical)

### Launch Day

| # | Task | Owner | Channel |
|---|------|-------|---------|
| 7.1 | Post on r/Aquariums | Aphrodite / Tiarnan | Reddit |
| 7.2 | Post on r/PlantedTank | Aphrodite / Tiarnan | Reddit |
| 7.3 | Post on r/androidapps and r/Android | Aphrodite / Tiarnan | Reddit |
| 7.4 | Share in fishkeeping Discord servers | Aphrodite / Tiarnan | Discord |
| 7.5 | Post in Facebook fishkeeping groups | Aphrodite / Tiarnan | Facebook |
| 7.6 | Tweet/post on X with demo GIF | Aphrodite | X/Twitter |
| 7.7 | Email beta testers: "We're live! Please rate & review" | Aphrodite | Email |

---

## PHASE 8 — POST-LAUNCH (Ongoing)
*Continuous improvement after v1 ships*

### Week 1-4

| # | Task | Owner | Priority |
|---|------|-------|----------|
| 8.1 | **Monitor & respond to every Play Store review** within 24 hrs | Aphrodite / Tiarnan | 🔴 |
| 8.2 | **Monitor crash rate** — target <1% via Android Vitals | Argus | 🔴 |
| 8.3 | **Monitor ANR rate** — target <0.5% | Argus | 🔴 |
| 8.4 | **Add in-app rating prompt** — trigger after 3+ days + 5+ lessons | Hephaestus | 🟡 |
| 8.5 | **ASO iteration** — monitor keyword rankings, adjust title/description | Aphrodite | 🟡 |
| 8.6 | **Weekly update cadence** for first month | All | 🟡 |

### Future (v1.1+)

| # | Task | Priority | Effort |
|---|------|----------|--------|
| F1 | **Full accessibility/Semantics pass** — 95 screens need Semantics wrappers | 🟡 HIGH | 1-2 weeks |
| F2 | **Adopt design token systems** — AppElevation, AppDurations, AppCurves, AppIconSizes (defined but unused) | 🟢 LOW | 1 week |
| F3 | **Adopt common widgets** — CozyCard, RoomHeader, PrimaryActionTile, DrawerListItem (built but unused) | 🟢 LOW | 1-2 days |
| F4 | **Replace ~40 hardcoded `Colors.white`/`Colors.black`** with semantic tokens | 🟢 LOW | 1-2 days |
| F5 | **Add proper onboarding flow** for first-time users | 🟡 HIGH | 1-2 days |
| F6 | **Runtime OpenAI key configuration** (currently build-time `--dart-define` only) | 🟡 MEDIUM | 2-3 hrs |
| F7 | **Real social backend** — replace mock friends/leaderboard with Supabase-backed real data | 🟡 MEDIUM | 1-2 weeks |
| F8 | **Firebase Analytics/Crashlytics** | 🟡 MEDIUM | 1 day |
| F9 | **Dyslexia font + colour-blind mode** (documented but not implemented) | 🟢 LOW | 2-3 days |
| F10 | **Extract hardcoded UI strings for i18n** | 🟢 LOW | 1 week |
| F11 | **Localise to German + Portuguese** (biggest non-English fishkeeping markets) | 🟢 LOW | 2-3 weeks |
| F12 | **Schema migration logic** — currently v1, no upgrade path when format changes | 🟡 HIGH | 1-2 days |
| F13 | **Strengthen backup encryption** — add user password to key derivation | 🟢 LOW | 2-3 hrs |
| F14 | **Parallelize service init in main()** — reduce cold start time | 🟢 LOW | 1-2 hrs |
| F15 | **Add deep linking via router package** — 485 imperative `Navigator.push()` calls, no URL routing | 🟢 LOW | 1 week |

---

## TIMELINE SUMMARY

| Phase | Duration | Can Parallelise? |
|-------|----------|-----------------|
| **Phase 0** — Critical Fixes | 2-3 hours | — |
| **Phase 1** — Code Cleanup | 1 day | After Phase 0 |
| **Phase 2** — Assets | 3-5 days | ⚡ Parallel: 2A + 2B + 2C simultaneously |
| **Phase 3** — Store Compliance | 1-2 days | ⚡ Parallel with Phase 2 |
| **Phase 4** — Store Listing | 2-3 days | ⚡ Parallel with Phase 2 (after icon done) |
| **Phase 5** — Testing | 3-5 days | ⚡ Partial overlap with Phase 4 |
| **Phase 6** — Beta | 2 weeks | After Phase 5 |
| **Phase 7** — Launch | 1 day | After Phase 6 |

### Best-Case Timeline: ~4 weeks to production launch
### Minimum Viable Submission: ~1 week (Phases 0-4 only, skip beta)

---

## CRITICAL PATH (fastest to store)

```
Day 1:   Phase 0 (fixes) + start Phase 2A (icon) + Phase 3.1 (privacy policy)
Day 2:   Phase 1 (cleanup) + Phase 2C (audio) + Phase 3 (remaining compliance)
Day 3-5: Phase 2B (images) + Phase 4 (store listing, screenshots)
Day 6-7: Phase 5 (testing)
Day 8:   Submit to Internal Testing
```

---

## TIARNAN ACTIONS (Things only you can do)

| # | Action | When | Effort |
|---|--------|------|--------|
| T1 | **Create Google Play Developer account** ($25) | Phase 3 | 15 min |
| T2 | **Set up developer support email** | Phase 3 | 5 min |
| T3 | **Source/approve 5 audio files** | Phase 2 | 1-2 hrs |
| T4 | **Approve app icon design** | Phase 2 | 10 min |
| T5 | **Review privacy policy** | Phase 3 | 15 min |
| T6 | **Review store listing copy** | Phase 4 | 15 min |
| T7 | **Recruit 10-20 beta testers** | Phase 6 | 1-2 days |
| T8 | **Post launch announcements** (Reddit etc.) | Phase 7 | 1-2 hrs |
| T9 | **Decide: Supabase credentials** — wire real project or launch offline-only? | Phase 0 | Decision |
| T10 | **Decide: OpenAI API key** — bundle key for Smart features or disable for v1? | Phase 0 | Decision |

---

## DECISIONS — LOCKED (Tiarnan, 2026-02-24)

| # | Decision | Answer | Impact |
|---|----------|--------|--------|
| D1 | **Cloud sync for v1?** | ✅ **WIRE IT** — Supabase credentials exist, verify and go | Auth, sync, backup all live |
| D2 | **AI features for v1?** | ✅ **FULL AI** — Bundle OpenAI key via `--dart-define` | Smart tab fully functional |
| D3 | **Mock social data?** | ✅ **BUILD REAL SOCIAL** — Replace all mock data with Supabase-backed real friends, leaderboard, activity feed | +1-2 weeks dev. New Supabase tables needed. |
| D4 | **Beta or production?** | ✅ **STRAIGHT TO PRODUCTION** — No beta phase | Faster launch, accept risk |

---

## STATS FROM AUDITS

| Metric | Value |
|--------|-------|
| Dart source files | 298-348 (depending on count method) |
| Lines of code | 127,565 |
| Screen files | ~78-95 |
| Test files | 45 (~15% file coverage) |
| Missing image assets | ~70-75 |
| Missing audio assets | 5 |
| `.withOpacity()` calls remaining | 55 |
| Hardcoded colour calls | 343 |
| Dead code lines (HouseNavigator + orphans) | ~2,500+ |
| Navigation calls (imperative) | 485 |
| Animation controllers | 186 |
| Dependencies | 34 active |
| Supabase tables | 6 (live, RLS enabled) |
| Learning paths | 9 |
| Quiz types | 5 |
| Room themes | 12 |
| Achievements | 30+ |

---

## COMPETITIVE ADVANTAGE (Why This Ships)

Danio is **literally the only gamified fishkeeping education app**. The competitive landscape:
- **Aquarimate** — management only, no learning, no AI
- **Fishkeeper** — management + resources, no gamification, no AI  
- **Aquarium Log** — calendar management only
- **Aquarium Fish** — read-only species database
- **Fishi** — iOS-focused management

**Nobody** combines education + management + AI + gamification. Danio is a category of one. The "learn fishkeeping" keyword space is completely uncontested.

The app doesn't need to be perfect. It needs to be on the store.

---

*"The owl sees what the lion misses — and right now, I see a finish line."* 🦉

— Athena, Mount Olympus Coordinator
