# Danio — Feature Registry

**Updated:** 2026-03-29
**Rule:** Every feature listed with honest status. Updated every wave.

---

## Status Key

| Status | Meaning |
|--------|---------|
| ✅ Complete | Works end-to-end, tested, no known issues |
| ⚠️ Partial | Works but has known gaps or quality issues |
| 🔴 Broken | Exists but doesn't function correctly |
| ⚫ Hidden | Code exists, not reachable by users |
| 🟠 Scaffold | UI exists, backend is fake/missing |
| 🔮 Future | Planned, no implementation |

---

## Core Features

| Feature | Status | Score | Blocker IDs | Notes |
|---------|--------|-------|-------------|-------|
| 4-tab navigation | ✅ | 9/10 | — | Per-tab navigators, throttle, deep links |
| Tank management (CRUD) | ✅ | 9/10 | — | Multi-tank, parameter logging, equipment, tasks |
| Water logging | ✅ | 9/10 | — | Photo attachment, history, charts |
| Learning paths (72 lessons) | ⚠️ | 8/10 | FB-S1, FB-S3 | Content strong but safety gap (ich) + locked health path |
| SRS practice | ⚠️ | 8/10 | FB-T5, FB-O6 | Algorithm correct, error state swallowed, achievements bypass |
| Quiz engine | ✅ | 8.5/10 | — | 261 questions, explanations, hearts integration |
| Stories (6) | ✅ | 8/10 | — | 82 scenes, genuine educational branching |
| Species database | ⚠️ | 8.5/10 | FB-S2, FQ-C7 | 125+ fish, 52 plants. Corydoras safety gaps, Pea Puffer missing |
| XP / Levels | ✅ | 9/10 | — | 7 tiers, correctly wired |
| Gems economy | ✅ | 8/10 | FB-T4 | Earn/spend works. Debounce lifecycle gap. |
| Hearts / Energy | ✅ | 8.5/10 | — | Deduction, refill, regen all work (pull-based) |
| Streak + Freeze | ✅ | 9/10 | — | Purchase → prevents reset: verified |
| Daily goals | ⚠️ | 7/10 | FQ-E3 | Works but hidden in bottom sheet |
| Achievements (60) | ⚠️ | 7.5/10 | FB-O6 | Work, but SRS achievements bypass the system |
| Home room view | ✅ | 8.5/10 | — | Animated sprites, glassmorphism, room themes |
| AI: Fish ID | ✅ | 8/10 | — | Camera-based, behind proxy |
| AI: Symptom Checker | ⚠️ | 6/10 | FB-B5, FB-B6, FB-B8, FB-O5 | Dead buttons, no journal save, markdown raw, text accepts letters |
| AI: Ask Danio | ⚠️ | 7/10 | — | Works, lacks example prompts |
| AI: Weekly Plan | ✅ | 8/10 | — | Generation works, rate-limited |
| Notifications | ⚠️ | 7/10 | FB-B2, FB-H7 | Streak/task reminders work. care/water_change dead. RemindersScreen doesn't fire OS notifs. |
| GDPR / COPPA | ✅ | 8.5/10 | — | Age gate, consent, export, deletion |
| Backup / Restore | ✅ | 8/10 | — | JSON export/import with .bak copies |
| Onboarding (10 screens) | ⚠️ | 5.5/10 | FB-H2, FB-B7, FB-O3, FQ-D1, FQ-D2 | Flow works but personalisation is fake, CTA dead, design system bypassed |

## Workshop Tools

| Tool | Status | Blocker IDs | Notes |
|------|--------|-------------|-------|
| Water Change Calculator | ⚠️ | FB-O4 | No decimal input |
| Stocking Calculator | ⚠️ | FB-O4 | No decimal input |
| CO₂ Calculator | ✅ | — | Works |
| Dosing Calculator | ⚠️ | FB-S4 | Works but no "not for medication" warning |
| Tank Volume Calculator | ✅ | — | Works |
| Unit Converter | ✅ | — | Works (no swap button, minor) |
| Compatibility Checker | ✅ | — | Works |
| Cost Tracker | ✅ | — | Best utility feature. Add/delete/totals/categories. |
| Lighting Schedule | 🔴 | FB-B1 | Crashes at midnight |
| Cycling Assistant | ⚠️ | RF-3 | 833 lines, polished. Not in Workshop grid. |

## Broken / Fake Features

| Feature | Status | Blocker IDs | Notes |
|---------|--------|-------------|-------|
| XP Boost (shop) | 🔴 | FB-H4 | Doesn't work for lessons (main game loop) |
| Weekend Amulet (shop) | 🔴 | FB-H3 | Complete no-op. Zero code reads it. |
| Placement Test | 🔴 | FB-H5 | Routes to SRS, not a test. Achievement locked. |
| Difficulty Settings | 🔴 | FB-H6 | Rich UI, pure in-memory, resets on navigate. |
| SyncService | 🟠 | FB-H1 | Displays fake sync counts. No HTTP. |
| Tank Comparison | 🟠 | RF-1 | 3 static fields only. Placeholder. |

## Hidden / Dormant

| Feature | Status | Notes |
|---------|--------|-------|
| Friends (CA-002) | ⚫ | Commented-out import. No screen. |
| Leaderboard (CA-003) | ⚫ | Model scaffolding. No UI. |
| ThemeGalleryScreen | ⚫ | No route leads to it. RF-4. |

## Settings Sub-features

| Feature | Status | Blocker IDs | Notes |
|---------|--------|-------------|-------|
| Account management | ✅ | — | Email auth works |
| Notification prefs | ✅ | — | Toggle works |
| Backup/export | ✅ | — | JSON export/import |
| Data deletion | ✅ | — | Double confirmation |
| Guides (6) | ✅ | — | All reachable |
| About screen | ⚠️ | FB-O2 | Duplicate entries |
| Difficulty Settings | 🔴 | FB-H6 | See above |
| Reminders | 🔴 | FB-H7 | In-app only, no OS notifications |
| Maintenance Checklist | ✅ | — | Per-tank, auto-resets, persisted |
