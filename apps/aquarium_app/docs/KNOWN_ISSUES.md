# Danio — Known Issues & Deferred Items

**Date:** 2026-04-05
**Version:** 1.0.0+1

---

## Deferred Items (DE) — Explicitly out of scope for v1.0

| ID | Issue | Severity | Reason Deferred |
|----|-------|----------|-----------------|
| DE-1 | UserProfileNotifier decomposition (1,084 lines) | Low | Functional as-is. Structural debt, not user-facing. |
| DE-2 | AchievementProgressNotifier decomposition (736 lines) | Low | Same — functional, structural. |
| DE-3 | SQLite migration for power users | Low | JSON + SharedPreferences works for v1 scale. |
| DE-4 | 37 MaterialPageRoute to custom transitions | Low | Works. Visual polish. Incremental. |
| DE-5 | Cloud sync implementation | Medium | Major feature, not a fix. v1.1+. |
| DE-6 | Reminders/Checklist/CostTracker bypass StorageService | Medium | Data not in backups. Works functionally. Architecture debt. |
| DE-7 | Fill-in-blank question type | Low | All 261 questions are multiple choice. Sufficient for v1. |
| DE-8 | Dark mode room backgrounds | Low | Room uses luminance-based branching. Fine for v1. |
| DE-9 | 339 hardcoded Color(0x...) values | Low | Dark mode migration done for context-aware colors. Remaining are intentional fixed colors. |
| DE-10 | 114 raw TextStyle() bypasses | Low | Incremental design system adoption. |
| DE-11 | Photo gallery full-screen viewer + add/delete | Low | Gallery is read-only. Functional. Enhancement. |
| DE-12 | Hearts/energy naming inconsistency | Low | Minor copy issue. |
| DE-13 | Fish mood/happiness state (Tamagotchi loop) | Medium | New feature, not a fix. High-value for v1.1. |
| DE-14 | 88% of species have no sprite (15/126) | Medium | Art generation at scale. Fish emoji fallback works. |
| DE-15 | Negative value validation on calculators | Low | Dosing/Volume accept negatives. Edge case, not crash. |
| DE-16 | Achievement unlock dialog queuing | Low | Rapid-fire can overlap. Edge case. |
| DE-17 | Day7 milestone streak threshold | Low | UX edge case. Not broken, just strict. |
| DE-18 | Hearts regen is pull-not-push | Low | Timer math correct but only triggers on user action. |

## External Blockers (EX) — Require user or platform action

| ID | Issue | Blocked On |
|----|-------|-----------|
| EX-1 | Firebase google-services.json | User account setup |
| EX-2 | Supabase deep link configuration | User |
| EX-4 | IARC content rating | Play Console |
| EX-5 | SCHEDULE_EXACT_ALARM declaration | Play Console |
| EX-6 | Google/Apple OAuth setup | Post-v1 (email auth sufficient) |
| EX-7 | Play Console / App Store Connect setup | User (ON HOLD) |

## Visual Items (FQ-V) — Art style verification needed

| ID | Item | Status |
|----|------|--------|
| FQ-V2 | Angelfish + amano shrimp sprite style match | Sprites exist as .webp — style match TBD |
| FQ-V3 | Onboarding background style | onboarding_journey_bg.webp exists — style match TBD |
| FQ-V4 | placeholder.webp style | Present — style match TBD |

## Git Stashes (5)

| Stash | Content | Recommendation |
|-------|---------|---------------|
| stash@{0} | shop_street_screen.dart simplification | Evaluate separately |
| stash@{1} | water_panel_content.dart rewrite (836 insertions) | Too risky to blindly apply |
| stash@{2} | 193-file cleanup (44K lines of old exports/tests) | High value for repo hygiene — apply carefully |
| stash@{3} | Duplicate of stash@{2} | Drop |
| stash@{4} | Divider theme fix from old branch | Likely superseded |

## Performance Notes

- Cold start skips ~60 frames on emulator (expected for Firebase/Supabase/Riverpod init chain)
- Room scene renders with Impeller backend (OpenGLES)
- Font tree-shaking reduces MaterialIcons by 97.4%
