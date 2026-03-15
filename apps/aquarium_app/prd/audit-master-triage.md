# Danio Production Audit — Master Triage

**Date:** 2026-03-15
**Auditor:** Athena (synthesised from 4 sub-agent audits)
**Scope:** Full app — Tank Creation, Polish & Optimization, Learning & Gamification, Home & Rooms

---

## Totals

| Severity | Count | Action |
|----------|-------|--------|
| **P0** | 12 | Must fix before submission |
| **P1** | 28 | Should fix — ship-blocking UX or data issues |
| **P2** | 34+ | Track for post-launch |

---

## P0 — Must Fix Before Submission

### Crash / Silent Failure
| # | Source | Issue | Fix Complexity |
|---|--------|-------|---------------|
| 1 | Polish | **Missing INTERNET permission in release AndroidManifest** — Firebase, Supabase, analytics, crashlytics all silently fail | 1 line |
| 2 | Polish | **Force-unwrap on nullable `_auth` in auth_service.dart** — crash if Supabase init fails | 1 line (null check) |
| 3 | Learning | **Empty quiz crash risk** — 17 lessons have `Quiz(questions: [])`, accessing `questions[0]` = IndexOutOfBounds if UI gate fails | Guard check |
| 4 | Learning | **Gems provider compile risk** — `_cumulativeEarned`/`_cumulativeSpent` declared `final` but reassigned | Remove or make non-final |

### Broken UX (User Can't Complete Core Flow)
| # | Source | Issue | Fix Complexity |
|---|--------|-------|---------------|
| 5 | Home | **BottomPlate overlap** — "Your Tanks" plate completely covers "Your Progress" drag handle (same `bottomOffset: 0`, same `peekHeight: 32`) | Adjust offset |
| 6 | Home | **TodayBoard never rendered** — fully implemented but never instantiated on home screen | Add to home layout |
| 7 | Home | **Missing room interactive objects** — `onTestKitTap`, `onFoodTap`, `onPlantTap` callbacks wired but no visual tap targets exist | Add tap targets or remove callbacks |
| 8 | Home | **No tank delete confirmation** — immediate soft-delete with 5s SnackBar undo only | Add confirmation dialog |
| 9 | Home | **Overlay banner stacking** — welcome, comeback, streak, daily nudge banners overlap at identical positions | Add collision avoidance |

### Code Quality / Rendering Bugs
| # | Source | Issue | Fix Complexity |
|---|--------|-------|---------------|
| 10 | Home | **XP progress bar anti-pattern** — `setState` from `addPostFrameCallback` inside `build()` | Move to initState/didUpdate |
| 11 | Home | **`_FishPainter` shared Paint mutation** — fin colour overwrites body Paint object | Clone Paint |
| 12 | Polish | **Force-unwrap in fish_id_screen** (if applicable — see audit) | Null check |

---

## P1 — Should Fix (Ship-Blocking UX/Data)

### Data Integrity
| # | Source | Issue |
|---|--------|-------|
| 1 | Tank | `isDemoTank` not serialized in `_tankToJson` — demo flag lost on restart (1-line fix) |
| 2 | Tank | `_currentTankIndex` not updated after creation — user may see wrong tank |
| 3 | Learning | Transaction history capped at 100 → lifetime gem totals silently undercount |

### UX Gaps
| # | Source | Issue |
|---|--------|-------|
| 4 | Learning | No programmatic guard before rendering empty quizzes (relies on UI gating only) |
| 5 | Learning | Hearts refill costs 50 gems with no gem purchase option in out-of-hearts modal |
| 6 | Learning | 6 hidden achievements permanently unearnable (`shouldUnlock = false`) |
| 7 | Polish | Fonts not bundled but runtime fetching disabled → system font fallback |
| 8 | Polish | Crashlytics handler set up after `runApp` → first-frame errors lost |
| 9 | Polish | Splash + About screen use placeholder icons |
| 10 | Polish | "Toolbox" tab label misleading |
| 11 | Polish | SCHEDULE_EXACT_ALARM needs Play Store justification |
| 12-28 | Home | 11 additional P1s from Home/Rooms audit (accessibility, animation edge cases, etc.) |

---

## P2 — Post-Launch Track (34+)

Across all audits. Key themes:
- Spaced repetition skips day 3 (day1 → day7 jump)
- 7 shop items purchasable but non-functional
- No tank name length limit
- Soft delete timer outlasts SnackBar undo window
- Volume preset shows "120.0" instead of "120"
- Performance concerns at scale (full-file rewrite, eager tile rendering)
- Various polish items

---

## Recommended Fix Approach

### Sprint 1: "No More Crashes" (1-2 hours)
Fix P0 items 1-4 (INTERNET permission, null checks, quiz guard, gems final). These are all tiny code changes.

### Sprint 2: "Core UX" (2-4 hours)  
Fix P0 items 5-11 (plate overlap, TodayBoard, delete confirmation, banner stacking, Paint mutation, setState anti-pattern).

### Sprint 3: "Data & Polish" (1-2 hours)
Fix P1 items 1-2 (isDemoTank serialization, tank index), plus fonts, crashlytics ordering, placeholder icons.

### Sprint 4: "Play Store Ready"
SCHEDULE_EXACT_ALARM justification, final `flutter analyze`, store screenshots, signed AAB.

**Total estimated fix time: 5-8 hours of Hephaestus work across 2-3 sessions.**

---

## Source Audit Files
- `prd/audit-prod-tank-creation.md` — 0 P0, 2 P1, 8 P2
- `prd/audit-prod-polish.md` — 3 P0, 10 P1
- `prd/audit-prod-learning.md` — 2 P0, 5 P1, 10 P2
- `prd/audit-prod-home-rooms.md` — 7 P0, 11 P1, 16 P2
