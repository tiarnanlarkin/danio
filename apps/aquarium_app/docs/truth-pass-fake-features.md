# TRUTH PASS: Fake-Complete Feature Challenge
**Date:** 2026-03-29  
**Auditor:** Aphrodite (Subagent)  
**Repo:** `apps/aquarium_app`  
**Purpose:** Challenge every feature rated 7/10 or below. For each, read the actual screen file and answer: *"If a real user tries to USE this, does it deliver?"*

---

> **VERDICT KEY**
> - ✅ **Real Feature** — Works end-to-end for a real user
> - 🟡 **Thin Feature** — Partially works but missing critical functionality
> - 🟠 **Placeholder** — UI shell with no real function
> - 🔴 **Broken** — Code exists but fails at runtime or has dead paths
> - ⚫ **Hidden** — Not reachable by a normal user

---

## 1. Tank Comparison (`tank_comparison_screen.dart`)

### What the surface audit said
Placeholder with 3 static fields.

### What's actually there
The screen is interactive, not static. It has:
- Two `DropdownButtonFormField` selectors (one per tank), correctly filtering to exclude the other tank
- A `_ComparisonSection` widget titled "Basic Info"
- A `_ComparisonRow` for **Name**, **Volume** (formatted as litres), and **Type**
- Handles <2 tanks with a proper empty state ("Need at Least 2 Tanks")
- Loads tanks from `tanksProvider` with loading/error states

### The real problem
There are **only 3 comparison fields** and the ListView ends after a single "Basic Info" card. The code literally has `const SizedBox(height: AppSpacing.xxl)` after that card — nothing else follows. No fish count, no water parameters, no last log date, no equipment list. For a tank comparison tool, 3 fields (name, volume, type) is extremely thin.

### What a real user sees
They pick two tanks, see a small card with 3 rows, and... that's it. There's no "Compare water parameters," no "Compare fish load," no "Compare maintenance history." The feature delivers something, but it's barely worth a screen.

**VERDICT: 🟡 Thin Feature** — Functional but so minimal it's barely useful. Compares 3 fields when users would expect 10+.

---

## 2. Difficulty Settings (`difficulty_settings_screen.dart`)

### What the surface audit said
Settings don't persist.

### What's actually there
The UI is impressively detailed:
- Overall skill level card with progress bar and difficulty badge
- Per-topic skill cards (6 topics) with mastery detection
- Performance history (last 5 attempts with scores)
- Manual override dropdowns per topic
- AI recommendations (increase/decrease suggestions)

### The critical bug: persistence is completely broken
**Trace the save path:**
1. `DifficultySettingsScreen` receives `skillProfile` and calls `widget.onProfileUpdated(...)` when a user changes a manual override
2. The `onProfileUpdated` callback is wired to `_DifficultySettingsWrapperState._onProfileUpdated()` in `settings_screen.dart`
3. That function is: `setState(() { _profile = updatedProfile; })` — **it only updates local widget state**
4. On every app restart (or even screen navigation), `_DifficultySettingsWrapperState.initState()` re-creates a blank `UserSkillProfile(skillLevels: {}, performanceHistory: {}, manualOverrides: {})`

There is **no SharedPreferences write, no provider update, no database call** anywhere in this path. `UserSkillProfile` is not stored in the user profile model either — it's a completely separate model that lives only in this local widget tree.

The real skill tracking that powers difficulty is done by the lesson system (via `DifficultyService.updateProfileAfterLesson()`), but that's a different code path entirely. The Difficulty Settings screen is a viewer that reads from a local blank profile, not the actual lesson-derived profile.

### What a real user sees
They open Difficulty Settings → see empty "No lessons completed yet" states everywhere (even after doing 20 lessons) → set manual overrides → leave the screen → overrides are gone. **The screen shows entirely wrong data.**

**VERDICT: 🔴 Broken** — Rich UI with completely broken data binding. Changes are never persisted. The screen initialises from an empty profile, not the real one. Overrides silently vanish.

---

## 3. Placement Test

### What the surface audit said
Routes to SpacedRepetitionPracticeScreen instead of a real test.

### What's actually there
**Confirmed true.** The `PlacementChallengeCard` widget (shown in the Learn tab to non-beginners who haven't taken the test) has a "Take the test" button wired to:

```dart
NavigationThrottle.push(context, const SpacedRepetitionPracticeScreen());
```

That's it. No dedicated placement test screen exists. The route in `app_routes.dart` for the named route `/placement_test` also maps to `SpacedRepetitionPracticeScreen`.

### The deeper problem
The `UserProfile` model has:
- `hasCompletedPlacementTest: bool`
- `hasSkippedPlacementTest: bool`  
- `completePlacementTest()` method in `user_profile_notifier.dart` (lines 690–758)

But **nothing calls `completePlacementTest()`** from the SpacedRepetitionPracticeScreen. The user can practice all day and `hasCompletedPlacementTest` will never become `true`. The achievement for `placement_complete` can never be unlocked via UI. The card just shows the generic practice screen and the user never "completes" a placement test.

### What a real user sees
They tap "Take the test" → they're in the standard spaced repetition practice session with no special placement framing → they do some flashcards → they come back to Learn tab → the "Take the test" card is still showing → confused.

**VERDICT: 🔴 Broken** — The placement test flow is broken end-to-end. The button routes to the wrong screen and the completion flag can never be set through normal UI interaction.

---

## 4. Cost Tracker (`cost_tracker_screen.dart`)

### What the surface audit said
Unknown / under review.

### What's actually there
This is one of the genuinely well-built features in the app:

**Add expenses:**
- Bottom sheet with description, amount (numeric keyboard), category dropdown (9 categories), date picker
- 4 preset icons for category auto-iconning

**Delete expenses:**
- Swipe-to-dismiss with Undo via DanioSnackBar — proper UX

**Edit expenses:**
- ❌ Not available. No edit functionality. Delete and re-add only.

**Totals:**
- This Month summary card
- This Year summary card  
- All Time Total card

**Category breakdown:**
- Visual progress bars per category, with % and amount

**Persistence:**
- `SharedPreferences` with `cost_tracker_expenses` key (JSON-encoded list)
- Currency preference also persisted
- Loads on `initState()`, saves on every mutation

**Currency support:**
- Auto-detects locale currency, falls back to £
- Settings dialog allows manual override (£ $ € ¥ A$ C$)
- Clear All Data option with confirmation dialog

### What's missing
- No edit-in-place (delete + re-add required)
- No chart/graph view (only bar-style category breakdown)
- No export

### What a real user sees
A genuinely useful expense tracker. Add expenses, see totals, swipe to delete, view breakdown by category. Survives app restarts. Actually works.

**VERDICT: ✅ Real Feature** — Fully functional for add/delete/view totals. Edit is missing but it's the only gap. Best-built "utility" screen in the app.

---

## 5. Reminders (`reminders_screen.dart`)

### What the surface audit said
Reminders may not persist or notify.

### What's actually there
**Persistence: ✅ Works**
- Reminders are stored in SharedPreferences as JSON (`aquarium_reminders` key)
- Loads on `initState()`, saves on every add/delete/complete
- Survives app restarts

**Recurring logic: ✅ Works (in-app)**
- When a recurring reminder is marked complete, `_calculateNextDue()` advances it by daily/weekly/biweekly/monthly
- Overdue vs upcoming separation works correctly

**Quick presets: ✅**
- Water Change, Filter Clean, Water Test, Feeding presets with pre-filled forms

**OS-level notifications: ❌ NOT wired**
This is the critical gap. The `NotificationService` has full infrastructure for local notifications (`flutter_local_notifications`) including:
- `scheduleReviewReminder()`
- `scheduleAllStreakNotifications()`
- `scheduleWaterChangeReminder()`
- Channels: "task_reminders", "streak_reminders", "review_reminders"

But the `RemindersScreen` **never calls any NotificationService method**. When a user adds a reminder for "Weekly water change on Friday at 10am," **no OS notification is scheduled**. The reminder exists as app data only — the user will only see it if they open the app and navigate to the screen.

The notification infrastructure exists (the app IS capable of scheduling local notifications), but the reminders screen doesn't use it.

### What a real user sees
They add reminders. They can see them in-app, with overdue/upcoming status. They set a weekly water change reminder. **The phone never rings.**

**VERDICT: 🟡 Thin Feature** — In-app checklist works fully. But the core value proposition of a "reminder" — an OS notification that fires when you're not in the app — is completely missing. This is a sophisticated-looking dead-end.

---

## 6. Maintenance Checklist (`maintenance_checklist_screen.dart`)

### What the surface audit said
Possibly just a static list.

### What's actually there
Surprisingly solid:

**Persistence: ✅**
- Per-tank keying: `checklist_{tankId}_weekly_{itemId}` in SharedPreferences
- Week/month detection: auto-resets weekly tasks on a new week (`{year}-W{n}` key), monthly tasks on a new month
- Saves on every toggle

**Content: 8 weekly tasks + 6 monthly tasks**
- Weekly: water test, water change, vacuum substrate, clean glass, count fish, check temp, trim plants, top off water
- Monthly: clean filter, inspect equipment, deep clean decor, major plant pruning, check supplies, test GH/KH

**Progress tracking: ✅**
- Dual circular progress indicators (weekly % and monthly %)
- "✓ Complete!" badge on section header when all tasks done
- Reset dialog with confirmation

**Per-tank: ✅**
- The screen requires `tankId` and `tankName` — each tank has its own checklist state

### What's missing
- No history (no "last completed date" tracking beyond the current period)
- No custom task addition

### What a real user sees
A well-built, persistent, per-tank checklist that auto-resets each week/month with progress indicators. Actually delivers what it promises.

**VERDICT: ✅ Real Feature** — One of the better-implemented utility features. State persists, auto-resets correctly, and the task list is genuinely useful for aquarium keeping.

---

## 7. Photo Gallery (`photo_gallery_screen.dart`)

### What the surface audit said
Unknown.

### What's actually there
**View photos: ✅**
- Grouped by month (e.g., "March 2026 — 4 photos")
- 3-column grid with date badge overlay
- Tapping a photo opens `_PhotoViewerScreen`

**Full-screen viewer: ✅**
- `InteractiveViewer` (pinch-to-zoom, min 0.5x, max 4x)
- `PageView.builder` for swipe-through navigation
- Photo counter ("2 / 8")
- Notes overlay at bottom if log had notes
- Date shown in AppBar

**Add photos: ⚠️ Indirect only**
- No "add photo" button in the gallery
- Photos come from tank log entries that have `photoUrls` attached
- The gallery is purely a viewer — you add photos by creating logs with photos

**Delete photos: ❌**
- No delete from gallery
- Photos must be deleted by editing/deleting the source log entry

### What a real user sees
A clean, grouped, month-based photo journal of their tank. Full-screen viewer with zoom and swipe. But they **cannot add photos from the gallery screen** and **cannot delete photos** — they must go through the log entry flow.

**VERDICT: 🟡 Thin Feature** — Viewing and full-screen works well. But it's a read-only viewer with no direct photo management. Not broken, but not a full-featured gallery.

---

## 8. Shop Street (`shop_street_screen.dart`)

### What the surface audit said
Shop functionality unknown.

### Important context: this is NOT an e-commerce shop
Shop Street is a **wishlist manager + local shop directory + budget tracker + gem shop**. It's not a store where you buy fish or equipment with real money.

### What's actually there

**Fish/Plant/Equipment Wishlists: ✅**
- Each routes to `WishlistScreen` with a category filter
- Items can be added, removed, marked as owned
- Count badges on each section card

**Gem Shop: ✅ (virtual currency only)**
- Routes to `GemShopScreen` — lets users spend in-app gems on virtual cosmetics/themes
- This works as a virtual rewards store

**Budget tracker: ✅**
- Set a monthly budget (persisted via `budgetProvider`)
- Shows budget vs actual spend (linked to cost tracker)

**Local Shops directory: ✅**
- Add/edit/delete local fish shops with name, address, distance, notes
- Full CRUD via bottom sheet dialogs
- Persisted via `localShopsProvider`

### What a real user sees
A useful planning hub — wishlists, local shop notes, budget tracking. **Not** a place to buy anything with real money. If someone expects "I can buy fish here," they'll be confused. But as a planning/organisation tool, it genuinely works.

**VERDICT: ✅ Real Feature** — Delivers fully on what it actually is (a planning hub). The "shop" branding may mislead users expecting real purchases, but all features work end-to-end.

---

## 9. Friends & Leaderboard

### What the surface audit said
Possibly hidden or scaffolded.

### What's actually there
**These features don't exist as screens.**

In `settings_hub_screen.dart`, lines 17-18:
```dart
// friends_screen.dart — hidden until feature ships (CA-002)
// leaderboard_screen.dart — hidden until feature ships (CA-003)
```

The docstring for the hub mentions "Friends, Leaderboard" but both are commented-out imports. No `FriendsScreen` class exists anywhere. No `LeaderboardScreen` class exists anywhere.

What DOES exist:
- `lib/models/leaderboard.dart` — a model file defining leaderboard data structures
- The settings hub has slots referencing them in comments
- No navigation routes, no UI, no buttons to reach them

### What a real user sees
**Nothing.** There is no entry point to Friends or Leaderboard from any screen in the app. They are completely invisible to the user.

**VERDICT: ⚫ Hidden** — Not just thin — entirely non-existent as a user-facing feature. The model scaffolding exists for future use but there's nothing to show a user.

---

## 10. SyncService (`sync_service.dart`)

### What the surface audit said
Scaffolding only.

### What's actually there
The very first line of the file:
```dart
// SCAFFOLDING: Backend sync not yet implemented. Queued actions execute locally only.
```

The service has impressive-looking code:
- `SyncAction` queue model with types (xpAward, gemPurchase, lessonComplete, etc.)
- `queueAction()` method persists to SharedPreferences
- Connectivity monitoring via `isOnlineProvider`
- `syncNow()` with conflict resolution via `ConflictResolver`
- Debug UI in `sync_debug_dialog.dart` and `sync_indicator.dart`

**But what does `syncNow()` actually do?**
```dart
// Simulate network delay for demo purposes
await Future.delayed(const Duration(milliseconds: 500));
// All actions are already applied locally when they were queued
// Clear the queue
```

There is **no HTTP call, no Firebase write, no backend API**. The 500ms delay is a fake network simulation. All actions are local only. The "sync" just clears the queue and updates `lastSyncTime`.

`CloudSyncService` (`cloud_sync_service.dart`) also exists — but looking at what the sync widgets display, the whole system is in-app only.

### What a real user sees
The sync indicator may show "Syncing..." with a brief delay and then "Synced" with a timestamp. This creates a false impression that data is backed up to a cloud backend. **It isn't.** All data is local SharedPreferences only. Uninstalling the app loses everything.

**VERDICT: 🟠 Placeholder** — The scaffolding is thorough and the UX widgets look real, but there is zero actual data transmission. The "sync" is a 500ms delay followed by queue-clearing. Users may believe their data is cloud-backed when it is not.

---

## TOP 10: "FAKE-COMPLETE" FEATURES

Features that **look real but don't deliver** their implied promise:

| Rank | Feature | Why it's fake-complete |
|------|---------|----------------------|
| 🥇 1 | **Difficulty Settings** | Looks like a full skill analytics dashboard. Shows beautiful topic skill charts, trend analysis, manual override dropdowns. But: initialises from blank data (not your actual progress), and **every change is lost on navigation**. Completely broken. |
| 🥈 2 | **SyncService** | Full UI with sync indicator, progress states, conflict resolution, "last synced" timestamp. Broadcasts confidence that data is cloud-backed. Reality: **a 500ms fake delay then queue.clear()**. No backend exists. |
| 🥉 3 | **Placement Test** | Prominent card in the Learn tab. "Take the test to unlock your level" with a real-looking button. Tapping it just goes to the standard practice screen with no placement framing. **The test doesn't exist.** The completion flag can never be set via UI. |
| 4 | **Reminders** | Full creation UI with presets, recurring options, overdue/upcoming view. Stored and displayed correctly. **Zero OS notifications ever fire.** The NotificationService infrastructure exists but is never called by RemindersScreen. |
| 5 | **Tank Comparison** | A dedicated screen with tank selector dropdowns — implies a rich comparison tool. Delivers: Name, Volume, Type. **3 fields.** Then the screen ends. |
| 6 | **Photo Gallery** | Looks like a full gallery with month grouping, thumbnails, full-screen viewer with zoom and swipe. But it's **read-only** — no add, no delete from within the gallery. Hidden dependency on log entries. |
| 7 | **Friends** | Settings hub comments reference "Friends" and the docstring includes it as a feature. Model scaffolding exists. **No screen, no navigation, no UI.** Not reachable. |
| 8 | **Leaderboard** | Same as Friends — model exists (`leaderboard.dart`), mentioned in hub comments, **zero UI built.** |
| 9 | **Placement Test Achievement** | Achievement data for `placement_complete` exists with unlock criteria. The `completePlacementTest()` notifier method is fully written. **No code path calls it.** Achievement is permanently locked. |
| 10 | **Cloud Sync indicators** (sync_indicator, sync_status_widget, sync_debug_dialog) | Three separate UI widgets dedicated to showing sync state. Look production-ready. They display real data from a fake service. |

---

## SUMMARY: WHAT'S ACTUALLY REAL

| Feature | Verdict | Notes |
|---------|---------|-------|
| Tank Comparison | 🟡 Thin | Works but only 3 fields |
| Difficulty Settings | 🔴 Broken | Data never persists, wrong source data |
| Placement Test | 🔴 Broken | Routes to wrong screen, completion never fires |
| Cost Tracker | ✅ Real | Best utility feature. Full add/delete/totals/persist |
| Reminders | 🟡 Thin | In-app works; OS notifications never fire |
| Maintenance Checklist | ✅ Real | Solid. Per-tank, auto-reset, persisted |
| Photo Gallery | 🟡 Thin | View/zoom works; no direct add or delete |
| Shop Street | ✅ Real | Works as wishlist+budget hub (not an actual shop) |
| Friends | ⚫ Hidden | Not built |
| Leaderboard | ⚫ Hidden | Not built |
| SyncService | 🟠 Placeholder | Fake network delay, no backend |

---

*Audit completed: 2026-03-29 by Aphrodite*
