# Polish Backlog
Version: 1.0 | Date: 2026-02-28

Prioritized list of all remaining work to reach Quality Bar.

---

## S0 — Blockers (must fix before store submission)

- [ ] **Fix 55 analyze errors in test files** — `test/screens/home_screen_test.dart` (3 errors: AsyncValue return type mismatch) and `test/widgets/common/common_widgets_test.dart` (52 errors: API mismatch with refactored widgets — missing `emoji` param, removed `EmptyState`/`StandardInput`/`PrimaryButton` classes, renamed params). **Fix:** Rewrite tests to match current widget APIs. **Est: 2–3h**

- [ ] **Fix layout overflow on onboarding tank type cards** — `lib/screens/onboarding/profile_creation_screen.dart` — tank type cards (Freshwater/Marine) overflow by 34–62 pixels. **Fix:** Increase card height, reduce content, or use Flexible layout. **Est: 30min**

---

## S1 — High priority (ship with these fixed)

- [ ] **Fix Hearts system refill edge cases** — `lib/services/hearts_service.dart` — edge cases in refill calculation timing. 2 test failures. **Fix:** Review timer logic and boundary conditions. **Est: 1–2h**

- [ ] **Configure Firebase basics** — Add `firebase_core`, `firebase_analytics`, `firebase_crashlytics` to pubspec. Follow `docs/setup/FIREBASE_SETUP_GUIDE.md`. Even if analytics is deferred, Crashlytics is essential for post-launch. **Est: 4–6h**

- [ ] **Label social features as demo/preview** — Add "Preview" or "Coming Soon" badge to FriendsScreen, LeaderboardScreen, ActivityFeedScreen, FriendComparisonScreen headers. Currently uses mock data with no indication. **Est: 1h**

- [ ] **Label Smart features as Coming Soon** — FishIdScreen, SymptomTriageScreen, WeeklyPlanScreen need clear "Coming Soon" UI state instead of looking broken when API isn't available. **Est: 1h**

- [ ] **Verify release build signing** — Ensure `key.properties` and signing config are set up. Test `flutter build apk --release`. **Est: 2–4h**

- [ ] **Clean up stale shell script** — Remove `lib/screens/count_withopacity.sh` (development artifact). **Est: 5min**

- [ ] **Clean up disabled service** — Remove or archive `lib/services/wave3_migration_service.dart.disabled`. **Est: 5min**

---

## S2 — Medium priority (next sprint)

- [ ] **On-device polish audit** — Walk every screen on physical device checking: error states, touch targets, dark mode, font scaling 1.5×, TalkBack. Update POLISH_CHECKLIST.md with findings. **Est: 8–12h**

- [ ] **Generate test coverage report** — Run `flutter test --coverage` and identify gaps. Target: ≥60% on `lib/providers/`, `lib/services/`, `lib/models/`. **Est: 2–3h**

- [ ] **Update outdated dependencies** — 27 packages need updating. Run `flutter pub outdated`, update incrementally, test after each batch. **Est: 2–3h**

- [ ] **Remove print statements from test files** — 66 `avoid_print` info issues. Replace with proper test logging or remove. **Est: 1h**

- [ ] **Consolidate button widgets** — `app_button.dart` and `app_button_new.dart` coexist. Migrate all usages to single canonical button, delete old one. **Est: 1–2h**

- [ ] **Review and remove unused widgets** — `UNUSED_WIDGETS.md` in `lib/widgets/` documents dead code. Remove safely. **Est: 1–2h**

- [ ] **Accessibility audit** — Systematic TalkBack walkthrough. Add `Semantics` labels where missing. Test contrast ratios on actual device. **Est: 4–6h**

- [ ] **Font scaling test** — Set device to 1.5× text, walk all screens. Fix any layout breaks. **Est: 3–4h**

- [ ] **Prepare store listing assets** — 5+ screenshots per device class, feature graphic 1024×500, short description (80 chars), full description. **Est: 4–6h**

- [ ] **Verify Supabase integration** — Test with real credentials or ensure offline-only mode is properly communicated to user. **Est: 2–3h**

---

## S3 — Nice to have (post-launch)

- [ ] **Clean repo root** — Move 60+ completion/agent report .md files to `docs/archive/`. Keep only README, KNOWN_ISSUES, BUILD_INSTRUCTIONS. **Est: 1h**

- [ ] **E2E integration tests** — Write Patrol or integration_test suite covering core user journeys: onboarding → create tank → log params → complete lesson → earn XP. **Est: 8–12h**

- [ ] **CI/CD pipeline** — GitHub Actions for: `flutter analyze`, `flutter test`, build APK on PR. **Est: 4–6h**

- [ ] **Privacy policy hosting** — Publish privacy policy to live URL (GitHub Pages, Vercel). Link in app and store listing. **Est: 1h**

- [ ] **Performance profiling** — Profile cold start time, scroll jank, memory usage on mid-range device. Document baselines. **Est: 2–3h**

- [ ] **Rive animation audit** — Verify all Rive assets in `assets/rive/` load correctly and animate smoothly. **Est: 1–2h**

---

## Effort Summary

| Tier | Items | Est. Effort |
|------|-------|-------------|
| S0 Blockers | 2 | 3–4h |
| S1 High | 7 | 9–14h |
| S2 Medium | 10 | 28–42h |
| S3 Nice to have | 6 | 17–25h |
| **Total** | **25** | **57–85h** |
