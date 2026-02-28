# Danio Gap Analysis
Version: 1.0 | Date: 2026-02-28

Every gap mapped to a Quality Bar item.

## Critical Gaps

| # | Gap | Quality Bar Item | Severity | Effort | Priority |
|---|-----|-----------------|----------|--------|----------|
| 1 | 55 analyze errors (all in test files: `test/screens/home_screen_test.dart`, `test/widgets/common/common_widgets_test.dart`) | `flutter analyze`: 0 errors | P0 | Low (2–3h) | **M1** |
| 2 | Layout overflow on tank type cards in onboarding | No Flutter overflow indicators | P0 | Low (30min) | **M1** |
| 3 | Firebase not configured — no crash reporting, no analytics | Crash-free sessions tracking | P1 | Medium (4–6h) | **M1** |
| 4 | Hearts system refill edge cases failing | Hearts system: complete | P1 | Low (1–2h) | **M1** |

## High Priority Gaps

| # | Gap | Quality Bar Item | Severity | Effort | Priority |
|---|-----|-----------------|----------|--------|----------|
| 5 | No release build signing configured (or unverified) | Release build works (signed APK) | P1 | Medium (2–4h) | **M1** |
| 6 | Social features use mock data only — no "demo/coming-soon" labeling visible | Friends/social: clearly marked | P1 | Low (1h) | **M1** |
| 7 | Smart/AI features (Fish ID, Symptom Triage, Weekly Plan) need "coming soon" badge | No dead ends | P1 | Low (1h) | **M1** |
| 8 | 66 `avoid_print` info issues in test files | No print in production code | P2 | Low (1h) | **M2** |
| 9 | Supabase credentials may be placeholder — cloud sync untested | Data persistence across restarts | P2 | Medium (2–3h) | **M2** |
| 10 | No automated E2E / integration tests currently runnable | E2E user journeys verified | P1 | High (8–12h) | **M2** |

## Medium Priority Gaps

| # | Gap | Quality Bar Item | Severity | Effort | Priority |
|---|-----|-----------------|----------|--------|----------|
| 11 | No systematic screen-by-screen audit for loading/empty/error states | Every screen has loading+empty+error | P2 | High (8–12h) | **M2** |
| 12 | Accessibility audit not systematically verified on-device | TalkBack semantic labels | P2 | Medium (4–6h) | **M2** |
| 13 | Font scaling at 1.5× not tested | Font scaling: no break at 1.5× | P2 | Medium (3–4h) | **M2** |
| 14 | Touch target audit not completed across all screens | Touch targets: ≥ 48dp | P2 | Medium (4–6h) | **M2** |
| 15 | 27 outdated package dependencies | Build stability | P2 | Medium (2–3h) | **M2** |
| 16 | Test coverage unknown — no coverage report generated | Test coverage ≥ 60% | P2 | Medium (2–3h) | **M2** |
| 17 | Store listing assets not prepared | Screenshots, feature graphic | P2 | Medium (4–6h) | **M2** |

## Low Priority Gaps

| # | Gap | Quality Bar Item | Severity | Effort | Priority |
|---|-----|-----------------|----------|--------|----------|
| 18 | Privacy policy URL may not be live | Privacy policy: live URL | P3 | Low (1h) | **M3** |
| 19 | Multiple unused .md files cluttering repo root (60+ completion reports) | Code quality / repo hygiene | P3 | Low (1h) | **M3** |
| 20 | `count_withopacity.sh` shell script in lib/screens/ | Repo cleanliness | P3 | Trivial | **M3** |
| 21 | `wave3_migration_service.dart.disabled` in services/ | Repo cleanliness | P3 | Trivial | **M3** |
| 22 | `UNUSED_WIDGETS.md` in widgets/ suggests dead code | Code cleanliness | P3 | Low (1–2h) | **M3** |
| 23 | `app_button.dart` + `app_button_new.dart` coexist (naming suggests migration incomplete) | Design system consistency | P3 | Low (1h) | **M3** |

## Summary

| Priority | Count | Est. Effort |
|----------|-------|-------------|
| P0 (Blocker) | 2 | 3–4h |
| P1 (High) | 5 | 10–16h |
| P2 (Medium) | 9 | 30–45h |
| P3 (Low) | 6 | 5–7h |
| **Total** | **22** | **48–72h** |
