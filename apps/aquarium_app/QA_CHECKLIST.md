# QA Checklist - Danio v1.0.0+1

**Date:** 2026-03-01
**Branch:** `openclaw/ui-fixes`
**Flutter:** 3.38.9 | **Dart:** 3.10.8

Legend: V = verified in code | D = needs device testing | W = known limitation

---

## Critical Path Screens

| Screen | Empty | Loading | Error | Happy | Notes |
|--------|:-----:|:-------:|:-----:|:-----:|-------|
| **Home (House Navigator)** | V | V Skeleton+liveRegion | V | D | Multi-room nav |
| **Learn** | V | V Skeleton+liveRegion | V | D | 9 learning paths |
| **Tank Detail** | V | V BubbleLoader+skeletons | V | D | Health score, trends |
| **Create Tank** | N/A | V Save loading | V Validation | D | Form validation |
| **Add Log** | N/A | V Save state | V Validation | D | Water, feeding, change |
| **Onboarding** | N/A | N/A | N/A | D | 6-step + profile |

## Tank Management

| Screen | Empty | Loading | Error | Happy | Notes |
|--------|:-----:|:-------:|:-----:|:-----:|-------|
| Tank Settings | N/A | V | V Snackbar | D | Delete w/ undo |
| Livestock | V | V | V | D | Soft delete w/ undo |
| Livestock Detail | N/A | V | N/A | D | Read-only |
| Equipment | V | V | V | D | |
| Logs | V | V Skeleton | V | D | Filter, search |
| Log Detail | N/A | N/A | N/A | D | Edit, delete |
| Charts | V | V BubbleLoader | V | D | CSV export |
| Tasks | V | V | V | D | |
| Reminders | V | V | V | D | Notifications |
| Journal | V | V BubbleLoader | V | D | |
| Photo Gallery | V | V | V | D | |

## Learning & Gamification

| Screen | Empty | Loading | Error | Happy | Notes |
|--------|:-----:|:-------:|:-----:|:-----:|-------|
| Lesson | N/A | V | N/A | D | Exercises |
| Enhanced Quiz | N/A | N/A | N/A | D | Multi-type |
| Practice Hub | V | V | V | D | Weak topics |
| Spaced Repetition | V | V | V | D | Card review |
| Achievements | V | V | V | D | 55+ achievements |
| Gem Shop | V | V | V | D | Virtual currency |
| Inventory | V | V | V | D | Purchased items |
| Difficulty Settings | V | V | N/A | D | Adaptive |
| Placement Test | N/A | N/A | N/A | D | One-time |
| Stories | V | V | V | D | Interactive |

## AI Features (require OPENAI_API_KEY)

| Screen | Empty | Loading | Error | Happy | Notes |
|--------|:-----:|:-------:|:-----:|:-----:|-------|
| Smart Hub | V | N/A | N/A | D | Feature launcher |
| Fish ID | N/A | V | V | D | Camera+gallery |
| Symptom Triage | N/A | V | V | D | AI diagnosis |
| Weekly Plan | V | V BubbleLoader | V | D | AI-generated |
| Compatibility | N/A | V | V | D | Species check |
| Anomaly Detector | V | V | V | D | Background |

## Reference (Static Content) - All verified V

About, Acclimation Guide, Algae Guide, Breeding Guide, Disease Guide,
Emergency Guide, Equipment Guide, FAQ, Feeding Guide, Glossary,
Hardscape Guide, Nitrogen Cycle, Parameter Guide, Privacy Policy,
Substrate Guide, Terms of Service, Troubleshooting, Vacation Guide

## Calculators & Tools

| Screen | Empty | Loading | Error | Happy | Notes |
|--------|:-----:|:-------:|:-----:|:-----:|-------|
| Dosing Calculator | N/A | N/A | V | D | |
| CO2 Calculator | N/A | N/A | V | D | |
| Tank Volume | N/A | N/A | V | D | |
| Water Change | N/A | N/A | V | D | |
| Stocking | N/A | N/A | V | D | |
| Unit Converter | N/A | N/A | N/A | V | |
| Lighting Schedule | N/A | N/A | N/A | D | |
| Maintenance | V | N/A | N/A | D | Reset |
| Cost Tracker | V | N/A | N/A | D | Currency |

## Social (Coming Soon overlay - all W)

Friends, Leaderboard, Activity Feed, Friend Comparison

## Settings & Utility

| Screen | Empty | Loading | Error | Happy | Notes |
|--------|:-----:|:-------:|:-----:|:-----:|-------|
| Settings | N/A | N/A | N/A | V | |
| Notification Settings | N/A | N/A | N/A | D | Perms |
| Account | V Offline | V | V Auth | D | Cloud sync |
| Backup/Restore | N/A | V | V | D | Import/export |
| Search | V | N/A | N/A | D | Global |
| Theme Gallery | N/A | N/A | N/A | D | Room themes |
| Wishlist | V | N/A | N/A | D | |

---

## Accessibility Audit Summary

| Check | Status | Details |
|-------|--------|---------|
| IconButton tooltips | PASS 62/62 | All have tooltips |
| Core widget Semantics | PASS | AppButton, AppIconButton, AppChip |
| Room scene Semantics | PASS | Temp, water quality, theme switcher |
| Hobby items Semantics | PASS | All 8 labeled |
| Swipe zones | PASS | ExcludeSemantics on invisible zones |
| Loading live regions | PASS | BubbleLoader, skeletons |
| Color contrast WCAG AA | PASS | Text opacity >= 0.5 |
| Touch targets 48dp | PASS | Core elements |

## Platform Checks

| Check | Status |
|-------|--------|
| Permissions justified | PASS |
| Camera required=false | PASS |
| Target SDK 36 | PASS |
| Min SDK 24 | PASS |
| android:exported | PASS |
| Signing config | PASS |
| R8/ProGuard | PASS |
| Debug banner off | PASS |

## Data & Lifecycle

| Check | Status |
|-------|--------|
| Hive null guards | PASS |
| Soft delete w/ undo | PASS |
| Schema versioning | PASS |
| Resume handling | PASS |
| Timer cleanup | PASS |
| Observer lifecycle | PASS |

---

Total: 113 screen files | All code-verified | Device testing needed for D items
