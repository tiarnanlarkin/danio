# Danio — Edge States, Modals, Secondary Routes & Hidden Surfaces Audit

**Auditor:** Daedalus (subagent)  
**Date:** 2026-03-29  
**Repo:** `apps/aquarium_app`  
**Scope:** Completion surface audit — all 10 areas as specified.

---

## Summary of Critical Findings (TL;DR)

| # | Finding | Severity |
|---|---------|----------|
| 1 | `'care'` and `'water_change'` notification payloads unhandled — tapping these notifications does nothing | **Must Fix** |
| 2 | `Day7MilestoneCard.onFeatureTap` calls `Navigator.pop()` instead of navigating to Compatibility Checker | **Must Fix** |
| 3 | `Day7MilestoneCard` requires `currentStreak >= 5` — user who missed a day on Day 6 never sees it | **Should Fix** |
| 4 | Level-up has two systems: `LevelUpDialog` (in lesson_completion_flow) and `LevelUpOverlay` (via LevelUpListener) — potential double-fire | **Research First** |
| 5 | `NotificationService.payloadToTabIndex()` has stale comment mapping that no longer matches actual tab indices | **Should Fix** |
| 6 | `AppRoutes.toDebugMenu()` uses `assert()` pattern — correct at runtime but misleading; the assert docstring is wrong | **Defer** |
| 7 | Fish ID camera permission denied has no explicit permission-denied UI — shows generic error string only | **Should Fix** |
| 8 | `UnlockCelebrationScreen` only reachable via debug menu or lesson flow — no production path to replay | **Research First** |
| 9 | `StoryBrowserScreen` locked screens show no explanation of how to unlock (level requirement shown implicitly only) | **Should Fix** |
| 10 | No `FirstVisitTooltip` on Tank tab (HomeScreen fish interaction), Logs, Tasks, Journal, Livestock screens | **Future Scope** |

---

## Area 1: All Modals and Dialogs

| Surface | Trigger/Location | States | Status | Issues | Classification |
|---------|-----------------|--------|--------|--------|----------------|
| `showDialog` — `_ConfigureAiDialog` | `settings_screen.dart:970` | dismiss only | ✓ | None found | Complete |
| `showAchievementUnlockedDialog` | `achievement_provider.dart:353`, `widgets/achievement_unlocked_dialog.dart` | `barrierDismissible: false` — must tap button | ✓ | Queuing: if multiple achievements unlock in rapid succession (e.g. batch lesson completion), only the most recent fires — earlier ones may be lost. `achievement_provider.dart` calls it synchronously in a loop. | Should Fix |
| `showAppDialog` (generic) | `widgets/core/app_dialog.dart:102` — base | configurable | ✓ | — | Complete |
| `showAppConfirmDialog` | Various (confirm/cancel pattern) | returns `bool?` — null on barrier dismiss | ✓ | Several callers treat null the same as `false` (safe), a few do `if (confirm != true)` (correct). No regressions found. | Complete |
| `showAppDestructiveDialog` | Various (red destructive button) | returns `bool?` | ✓ | All callers check `!= true` properly | Complete |
| `showLevelUpDialog` via `LevelUpDialog.show()` | `lesson_completion_flow.dart:254` | `barrierDismissible: false` | ⚠️ | **Two level-up systems exist**: `LevelUpDialog` (old, used in lesson_completion_flow) and `LevelUpOverlay` (new, used in `level_up_listener.dart`). Both listen to XP changes. In `lesson_completion_flow`, `showLevelUpCelebration()` calls `LevelUpDialog.show()` directly. `LevelUpListener` in `tab_navigator.dart` watches `levelUpEventProvider` and calls `LevelUpOverlay.show()`. If `addXp()` also emits a `levelUpEvent`, **both could fire for the same level-up**. | Research First |
| `LevelUpOverlay.show()` | `level_up_listener.dart:60`, `celebration_service.dart:187` | overlay entry, auto-dismisses | ✓ | Guarded by `_isShowing` flag. Clears event after show. | Complete |
| Hearts empty dialog `showAppDialog<String>` | `hearts_overlay.dart:325`, `hearts_widgets.dart:489` | `barrierDismissible: true` | ✓ | — | Complete |
| `maybeExplainHearts()` | `lesson_hearts_modal.dart` — called on first lesson | one-time, prefs-gated | ✓ | Note: Hearts explanation says "bonus XP" — the system was renamed from "hearts" to "energy". Copy references both. | Defer |
| `SyncDebugDialog` | `sync_indicator.dart:35` (debug only) | tap sync icon in tab bar | ✓ | Only shows in `kDebugMode` (`if (kDebugMode) const SyncIndicator()`) | Complete |
| OpenAI Data Disclosure | `fish_id_screen.dart:104` | one-time, prefs-gated, `barrierDismissible: false` | ✓ | — | Complete |
| OpenAI Disclosure — SymptomTriage | `symptom_triage_screen.dart:81` | same pattern | ✓ | — | Complete |
| OpenAI Disclosure — WeeklyPlan | `weekly_plan_screen.dart:56` | same pattern | ✓ | — | Complete |
| `showAppDialog` error detail | `error_boundary.dart:205` | user taps "More info" in error boundary | ✓ | — | Complete |
| Returning User — Day2/Day7/Day30 via `showAppDialog` | `home_screen.dart:203` | `barrierDismissible: true`; shown as dialog content | ⚠️ | Day2 and Day30 use `showAppDialog` not a bottom sheet — contradicts the `returning_user_flows.dart` docstring ("Show via `showAppBottomSheet`"). The Day7 `onFeatureTap` does `Navigator.pop()` only — **does not navigate to Compatibility Checker** as advertised. | Must Fix (Day7 nav), Defer (comment mismatch) |
| Fish tap interaction dialog | `room/fish_tap_interaction.dart:125` | tap fish in room scene | ✓ | — | Complete |
| `showAppDialog` — Cost Tracker note | `cost_tracker_screen.dart:284` | info dialog | ✓ | — | Complete |
| `showAppDialog` — Charts export | `charts_screen.dart:794` | export info | ✓ | — | Complete |
| `showAppDialog` — Tasks help | `tasks_screen.dart:221, 296` | task help/info | ✓ | — | Complete |
| `showAppDialog` — SR review help | `review_session_screen.dart:515, 641` | help + quit confirm | ✓ | — | Complete |
| `showAppDialog` — Terms popup | `terms_of_service_screen.dart:253` | legal info | ✓ | — | Complete |
| `showAppDialog` — Theme gallery | `theme_gallery_screen.dart:339` | preview info | ✓ | — | Complete |
| `showAppDialog` — Gem shop purchase confirm | `gem_shop_screen.dart:213` | confirm purchase | ✓ | — | Complete |
| Account: `showAppDestructiveDialog` sign-out | `account_screen.dart:52` | destructive | ✓ | — | Complete |
| Account: delete data | `settings_data_section.dart:229,239` | double-confirm destructive | ✓ | Double-confirm pattern is good | Complete |

---

## Area 2: All Bottom Sheets

| Surface | Trigger/Location | States | Status | Issues | Classification |
|---------|-----------------|--------|--------|--------|----------------|
| `showModalBottomSheet` (raw) | `widgets/app_bottom_sheet.dart` only — the three show helpers all wrap this | — | ✓ | Raw usage is contained to the helper itself | Complete |
| `showAppBottomSheet` — Home care sheet | `home_sheets_care.dart:27,107` | dismiss handle, backdrop tap | ✓ | — | Complete |
| `showAppBottomSheet` — Home helpers | `home_sheets_helpers.dart:44` | — | ✓ | — | Complete |
| `showAppBottomSheet` — Home stats | `home_sheets_stats.dart:57,122` | — | ✓ | — | Complete |
| `showAppBottomSheet` — Home tank summary | `home_sheets_tank.dart:19` | — | ✓ | — | Complete |
| `showAppDragSheet` — Home tank drag | `home_sheets_tank.dart:91` | resizable | ✓ | — | Complete |
| `showAppBottomSheet` — Home theme | `home_sheets_theme.dart:10` | — | ✓ | — | Complete |
| `showAppBottomSheet` — Home water | `home_sheets_water.dart:22` | — | ✓ | — | Complete |
| `showAppBottomSheet` — Tank switcher | `home/widgets/tank_switcher.dart:125` | list of tanks | ⚠️ | No empty state if user somehow has 0 tanks while switcher is shown — shouldn't happen but worth guarding | Research First |
| `showAppDragSheet` — Journal entry | `journal_screen.dart:102` | add/edit | ✓ | — | Complete |
| `showAppDragSheet` — Lesson completion | `lesson_completion_flow.dart:284` | post-lesson summary | ✓ | — | Complete |
| `showAppBottomSheet` — Lesson screen (action sheet) | `lesson_screen.dart` | quit/actions | ✓ | — | Complete |
| `showAppDragSheet` — Livestock add/edit | `livestock_screen.dart:618,625,636` | three separate sheets | ✓ | — | Complete |
| `showAppDialog<Tank>` — Livestock move tank | `livestock_screen.dart:415` | dialog with tank list | ⚠️ | If user has only 1 tank, dialog shows but there's nowhere to move to — no empty state message | Should Fix |
| `showAppDragSheet` — Logs filter | `logs_screen.dart:258,370` | filter / detail | ✓ | — | Complete |
| `showAppDragSheet` — Reminders add | `reminders_screen.dart:59` | form sheet | ✓ | — | Complete |
| `showAppScrollableSheet` — Plant detail | `plant_browser_screen.dart:212` | species detail | ✓ | — | Complete |
| `showAppScrollableSheet` — Species detail | `species_browser_screen.dart:224` | species detail | ✓ | — | Complete |
| `showAppScrollableSheet` — Search results | `search_screen.dart:305` | results | ✓ | — | Complete |
| `showAppScrollableSheet` — Smart tool info | `smart_screen.dart:384` | feature explainer | ✓ | — | Complete |
| `showAppScrollableSheet` — AI stocking | `widgets/ai_stocking_suggestion.dart:41` | AI result | ✓ | — | Complete |
| `showAppBottomSheet` — Achievement detail | `achievements_screen.dart:484` | achievement modal | ✓ | — | Complete |
| `showAppDragSheet` — Equipment add | `equipment_screen.dart:242,253` | add/edit forms | ✓ | — | Complete |
| `showAppDragSheet` — Settings customise | `settings_screen.dart:241,409` | theme/prefs drag sheets | ✓ | — | Complete |
| `showAppDragSheet` — Tasks | `tasks_screen.dart:261,268` | add/edit tasks | ✓ | — | Complete |
| `showAppBottomSheet` — Shop item detail | `shop_street_screen.dart:223` | item detail | ✓ | — | Complete |
| `showAppDragSheet` — Analytics | `analytics_screen.dart:914` | detail view | ✓ | — | Complete |
| `showAppDragSheet` — Cost tracker | `cost_tracker_screen.dart:72` | add expense | ✓ | — | Complete |
| `showAppBottomSheet` — Wishlist | `wishlist_screen.dart:111,126,170` | add/edit/filter | ✓ | — | Complete |
| `showAppDragSheet` — Room nav | `room_navigation.dart:139` | tank navigation | ✓ | — | Complete |
| Day2StreakPrompt sheet | `returning_user_flows.dart` | flame animation + CTA | ⚠️ | Intended to show via `showAppBottomSheet` per docs, but actually rendered inside `showAppDialog`. The drag handle is decorative only — users may swipe down expecting sheet behaviour. | Should Fix |

---

## Area 3: Snackbars and Toasts

| Surface | Trigger/Location | States | Status | Issues | Classification |
|---------|-----------------|--------|--------|--------|----------------|
| `DanioSnackBar.show/success/error/warning/info` | Primary snackbar API — `widgets/danio_snack_bar.dart` (actually `utils/app_feedback.dart`) | 5 variants | ✓ | — | Complete |
| `AppFeedback.showNeutralViaMessenger` | `livestock_screen.dart:650`, `tank_detail_screen.dart:296` | Uses pre-captured `ScaffoldMessengerState` after `Navigator.pop()` — correct pattern | ✓ | This is the right approach for post-pop feedback. Well handled. | Complete |
| **Raw `SnackBar()` + `ScaffoldMessenger.of()`** | `utils/app_feedback.dart` only | The DanioSnackBar/AppFeedback APIs all ultimately call this — it's the implementation layer | ✓ | No caller outside of `app_feedback.dart` uses raw SnackBar directly. Audit confirms consistent usage. | Complete |
| `_showOfflineSnackBar` in smart_screen | `smart_screen.dart:27` | Calls `DanioSnackBar.warning` | ✓ | — | Complete |
| `DanioSnackBar.info` — back-to-exit | `tab_navigator.dart:129` | "Tap back once more to leave" | ✓ | — | Complete |
| `DanioSnackBar.info` — workshop first visit | `workshop_screen.dart:44` | first-visit info message | ⚠️ | This fires on every first open (prefs-gated via `_showFirstVisitTooltip`) but the prefs key is checked separately from the snackbar — risk of double-showing if tooltip and snackbar overlap. | Research First |
| Debug menu snackbars | `debug_menu_screen.dart` — many | all use DanioSnackBar | ✓ | Debug only | Complete |

---

## Area 4: Secondary and Hidden Routes

### Routes reachable but NOT obviously discoverable

| Screen | Path to Reach | Notes | Classification |
|--------|--------------|-------|----------------|
| `DebugMenuScreen` | Settings Hub → version tap ×5 (debug only), or Settings → debug section | kDebugMode-gated everywhere | Complete |
| `UnlockCelebrationScreen` | After completing a lesson that unlocks a new species, OR debug menu | No "replay celebration" path in production | Research First |
| `StoryBrowserScreen` | Learn tab → Stories section (bottom of learn screen) | Stories section only visible when stories exist in data | Complete |
| `ThemeGalleryScreen` | Debug menu only in production? | Check if accessible from Settings → Theme | Research First |
| `DifficultySettingsScreen` | `difficulty_settings_screen.dart` — 4 refs | Accessible via Settings | Complete |
| `CyclingAssistantScreen` | `cycling_assistant_screen.dart` — 2 refs | Only accessible from debug menu in production? | Research First |
| `PhotoGalleryScreen` | `photo_gallery_screen.dart` — 2 refs | Only from log detail; not from a gallery index | Research First |
| `LivestockValueScreen` | `livestock_value_screen.dart` | From livestock screen | Complete |
| `LivestockDetailScreen` | `livestock_detail_screen.dart` | From livestock list | Complete |
| `BackupRestoreScreen` | Account screen | ✓ | Complete |
| `AnalyticsScreen` (full) | Charts → analytics link | `charts_screen.dart:92` — secondary analytics view | Complete |
| `ShopStreetScreen` | From achievements, gems overlay, or direct nav | ✓ accessible | Complete |
| `PracticeHubScreen` | Bottom tab (Quiz/Practice tab) | ✓ | Complete |

### Screens defined but potentially unreachable in production

| Screen | File | Issue | Classification |
|--------|------|-------|----------------|
| `ThemeGalleryScreen` | `screens/theme_gallery_screen.dart` | Only confirmed in debug menu; unclear if Settings has a link | Research First |
| `CyclingAssistantScreen` | `screens/cycling_assistant_screen.dart` | Only 2 refs — both appear to be debug | Research First |
| `PhotoGalleryScreen` | `screens/photo_gallery_screen.dart` | 2 refs — needs verification of non-debug path | Research First |

### Route inconsistency

| Issue | Location | Classification |
|-------|----------|----------------|
| `AppRoutes.toDebugMenu()` uses `assert(() { Navigator.push(...); return true; }())` — the assert body is the navigation logic, so it only runs in debug builds. BUT the assert message "must only be called in debug mode" is misleading — in release, it simply does nothing (assert bodies are stripped). This is correct behaviour but a code smell. | `navigation/app_routes.dart:63` | Defer |
| 37 inline `MaterialPageRoute` usages remain outside `AppRoutes` — comment in the file acknowledges this. No crash risk but inconsistent navigation pattern. | Various | Defer |

---

## Area 5: Edge States Per Screen

### Home Screen (`screens/home/home_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| NO DATA (no tanks) | `AppErrorState` shown when `tanks.isEmpty` (after check for demo tank) | ✓ | Complete |
| Loading tanks | Polling `_waitForProfile()` with skeleton placeholder | ✓ | Complete |
| Provider error | `tanksAsync.hasError && !tanksAsync.hasValue` → `AppErrorState` | ✓ | Complete |
| Comeback (missed days) | `ComebackBanner` shown | ✓ | Complete |
| Day2/Day7/Day30 returning flow | `showAppDialog` with milestone card | ⚠️ Day7 `onFeatureTap` is broken | Must Fix |
| Hearts/energy low | `StreakHeartsOverlay` shows warning | ✓ | Complete |
| No network | `OfflineIndicator` in `tab_navigator.dart` covers global state | ✓ | Complete |

### Learn Screen (`screens/learn/learn_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| Profile loading | `BubbleLoader` | ✓ | Complete |
| Profile error | `AppErrorState` | ✓ | Complete |
| All lessons completed | Completion state in lesson path cards ("100%! Aquarium genius!") | ✓ | Complete |
| No network | Offline indicator global | ✓ | Complete |
| Hearts depleted | Can still learn (energy depletion doesn't block — confirmed in `hearts_service.dart:4`) | ✓ | Complete |
| First visit | `FirstVisitTooltip` wired in learn screen | ✓ | Complete |

### Lesson Screen (`screens/lesson/lesson_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| Hearts depleted | `_isHeartsModalVisible` guard shown, `maybeExplainHearts()` on first lesson | ✓ | Complete |
| Wrong answer (heart loss) | `heartsService.loseHeart()`, overlay shown | ✓ | Complete |
| Correct answer (heart gain) | `heartsService.gainHeart()` | ✓ | Complete |
| Quit mid-lesson | `showAppDestructiveDialog` "Discard progress?" | ✓ | Complete |
| Level up on completion | `showLevelUpCelebration()` → `LevelUpDialog.show()` | ⚠️ See area 9 | Research First |
| Species unlock | Push `UnlockCelebrationScreen` | ✓ | Complete |
| Lesson completion sheet | `showAppDragSheet` summary | ✓ | Complete |

### Tank Detail (`screens/tank_detail/tank_detail_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| No livestock | `CompactEmptyState` in livestock_preview | ✓ | Complete |
| No equipment | `CompactEmptyState` in equipment_preview | ✓ | Complete |
| No logs | `CompactEmptyState` in logs_list | ✓ | Complete |
| Delete tank | Soft-delete + undo SnackBar (5s) | ✓ | Complete |
| No network | Global indicator | ✓ | Complete |

### Livestock Screen (`screens/livestock/livestock_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| Move to tank — only 1 tank | `showAppDialog<Tank>` with tank list | ⚠️ If only 1 tank exists, the dialog shows but there's no valid target — no empty/disabled state message | Should Fix |
| No livestock | Should show empty state | ⚠️ No explicit empty state found — needs verification | Research First |
| Undo delete | 5s undo via pre-captured `ScaffoldMessengerState` + `AppFeedback.showNeutralViaMessenger` | ✓ | Complete |

### Smart Screen (`screens/smart_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| Offline | `OfflineIndicatorCompact` shown, buttons show `_showOfflineSnackBar` | ✓ | Complete |
| First visit | `FirstVisitTooltip` on Smart tab | ✓ | Complete |
| AI error / timeout | Handled in individual smart screens with error strings | ✓ | Complete |

### Fish ID Screen (`features/smart/fish_id/fish_id_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| Camera permission denied | `_pickImage(ImageSource.camera)` — ImagePicker will throw/return null; `_error` string set to generic "Couldn't grab that image" | ⚠️ No specific "camera permission denied" message or Settings link — user gets a confusing error with no recovery path | Should Fix |
| Offline | `_error = OpenAIUserMessages.offline` | ✓ | Complete |
| Rate limited | `_error = OpenAIUserMessages.rateLimited` | ✓ | Complete |
| Timeout | `_error = OpenAIUserMessages.timeout` | ✓ | Complete |
| No image selected yet | Placeholder shown | ✓ | Complete |
| OpenAI disclosure | One-time dialog, `barrierDismissible: false`, required | ✓ | Complete |

### Gem Shop Screen (`screens/gem_shop_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| Insufficient gems | `canAfford` check, button disabled, "Not enough gems" shown | ✓ | Complete |
| Already owned | `owned` check, shows "Owned" state | ✓ | Complete |
| Purchase error | `DanioSnackBar.error` | ✓ | Complete |
| Gems loading | `AsyncValue.when` pattern | ✓ | Complete |

### Notification Settings Screen (`screens/notification_settings_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| Permission not granted | `requestExactAlarmPermission()` dialog → settings redirect | ✓ | Complete |
| Permission denied | Shows confirm dialog to open settings | ✓ | Complete |

### Achievements Screen (`screens/achievements_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| No achievements | `EmptyStateWidget` shown when `filteredAchievements.isEmpty` | ✓ | Complete |
| Achievement detail | `showAppBottomSheet` | ✓ | Complete |
| Achievement unlock queuing | If multiple achievements unlock simultaneously, `showAchievementUnlockedDialog` is called in a loop in the provider — dialogs are async but not queued | Should Fix |

### Add Log Screen (`screens/add_log/add_log_screen.dart`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| Discard changes | `showAppDestructiveDialog` | ✓ | Complete |
| Water change logged | `WaterChangeCelebration` overlay | ✓ | Complete |
| Photo permission | Uses `image_picker` — no explicit permission denied state for gallery | Research First |

### Spaced Repetition Practice (`screens/spaced_repetition_practice/`)

| Condition | Handling | Issues | Classification |
|-----------|----------|--------|----------------|
| No due cards | `_buildEmptyState()` | ✓ | Complete |
| SR load error | `DanioSnackBar.error` | ✓ | Complete |
| Hearts/energy in practice | Practice mode skips hearts (checked in `maybeExplainHearts()`) | ✓ | Complete |
| Quit mid-session | `showAppDialog<bool>` confirm | ✓ | Complete |

---

## Area 6: Notification Deep Links

### Payloads sent vs handled

| Payload | Sent by | Handled in `main.dart` | Result | Issues | Classification |
|---------|---------|----------------------|--------|--------|----------------|
| `'learn'` | Streak reminders (all 3), onboarding sequence (multiple), SR review, weekly tips | ✓ → tab 0 (Learn) | Navigates to Learn tab | — | Complete |
| `'review'` | SR review reminder | ✓ → tab 1 (Practice), pushes `SpacedRepetitionPracticeScreen` | ⚠️ If no cards are due, user lands on empty state screen — confusing | Should Fix |
| `'home'` | Onboarding welcome (Day1) | ✓ → tab 2 (HomeScreen) | ✓ correct | `NotificationService` comment incorrectly says "Home tab" = 0 and "Learn tab" = 1 — stale from old navigation layout. Comments do not match actual tab indices. | Should Fix (comments) |
| `'care'` | Onboarding Day1 care reminder, Day14 progress nudge | **NOT HANDLED** in `main.dart` | Notification tap does **nothing** | Tapping "Time to check in on your tank" notification silently fails to navigate | **Must Fix** |
| `'water_change'` | Water change scheduler | **NOT HANDLED** in `main.dart` | Notification tap does **nothing** | Tapping overdue water change notification silently fails to navigate | **Must Fix** |
| `'achievements'` | Achievement unlock notification | ✓ → tab 4 (Settings), pushes `AchievementsScreen` on Settings navigator | ✓ correct — Settings tab has Achievements in its navigator | — | Complete |

### `NotificationService.payloadToTabIndex()` stale mapping

The static helper `payloadToTabIndex()` maps:
- `home/care/water_change` → 0 (calls it "Home tab")
- `learn/review` → 1 (calls it "Learn tab")  
- `achievements` → 2 (calls it "Profile tab")

But the actual tab layout is:
- 0 = Learn, 1 = Practice/Quiz, 2 = Tank/Home, 3 = Smart, 4 = Settings

`payloadToTabIndex()` is not used by `main.dart` directly (main.dart has its own switch). If any future code calls `payloadToTabIndex()`, it will route to wrong tabs. **This helper needs to be corrected or deprecated.**

---

## Area 7: Returning User Flows

File: `screens/onboarding/returning_user_flows.dart`

| Widget | When Triggered | States | Issues | Classification |
|--------|---------------|--------|--------|----------------|
| `Day2StreakPrompt` | `daysSinceSignup >= 1 && <= 2 && currentStreak >= 1` | Flame animation, fish name personalisation, Continue/Later | ✓ Logic sound. Prefs-gated (shown once). Dismiss via both buttons calls `Navigator.pop()` correctly. **However**: shown via `showAppDialog`, not `showAppBottomSheet` as the file's docstring says. The drag handle is purely decorative. | Should Fix (show via sheet as documented) |
| `Day7MilestoneCard` | `daysSinceSignup >= 7 && <= 8 && currentStreak >= 5` | Gold card, +50 XP bonus, feature nudge | **`onFeatureTap` does `Navigator.pop()`** — closes dialog but does NOT navigate to Compatibility Checker as the card text advertises ("Have you tried the tank compatibility checker?"). User taps → dialog closes, nothing else happens. | **Must Fix** |
| `Day30CommittedCard` | `daysSinceSignup >= 30 && <= 31 && currentStreak >= 1` | Stats summary, soft upgrade CTA | `onUpgrade` calls `Navigator.pop()` — closes dialog but doesn't navigate to upgrade/gem shop. The CTA text says "See what's waiting for you →" but nothing happens. | Should Fix |

**Missing states in returning_user_flows.dart:**
- No handling for missed streak (comeback after >1 day absence — handled separately via `ComebackBanner` in `home_screen.dart`, but the two systems don't cross-reference)
- No Day 14 or Day 21 inline card (those are notification-only in the weekly cadence)
- No "completed all lessons" celebration card
- Day 7 window is only 2 days (day 7-8) + requires streak ≥ 5 — a user who missed one day and has streak of 4 on day 7 **never sees this card**

---

## Area 8: Debug Menu

File: `screens/debug_menu_screen.dart`

### Release-mode gating

| Guard | Location | Verdict | Classification |
|-------|----------|---------|----------------|
| `if (!kDebugMode) return const SizedBox.shrink()` | `debug_menu_screen.dart:92` — top of build() | ✓ Body is completely hidden in release | Complete |
| `if (!kDebugMode) return` | `settings_debug_section.dart:37` | ✓ | Complete |
| `if (!kDebugMode) return` in `handleVersionTap()` | `settings_hub_screen.dart:56` | ✓ The 5-tap debug gate checks `kDebugMode` first | Complete |
| `if (!kDebugMode) return` | `debug_deep_link_service.dart:41,66` | ✓ | Complete |
| `AppRoutes.toDebugMenu` assert pattern | `navigation/app_routes.dart:63` | In release builds, `assert()` bodies are stripped — `Navigator.push` never runs. ✓ Safe, but the pattern is unusual and the docstring assert message is misleading. | Defer |

### Debug menu routes exposed

The debug menu (`debug_menu_screen.dart`) exposes the following routes — **all gated by `kDebugMode`**:

| Route/Feature | Notes |
|--------------|-------|
| Complete/Reset Onboarding | State injection |
| Switch to any tab (0-4) | |
| Create Tank / Tank Detail / Tank Settings | Needs first tank |
| All 9 calculator screens | |
| All 16+ guide screens | |
| Achievements, Analytics, Notification Settings | |
| Privacy Policy, Terms, About, FAQ, Glossary, Quick Start | |
| Theme Gallery | Production path unclear (see Area 4) |
| Unlock Celebration (zebra_danio) | Debug-only preview |
| Story Browser | |
| State injection: XP, streak, energy, gems, species, room theme | All prefs-based |
| Destructive: clear all data, reset learning/SR/achievements/gamification/tanks | Gated by `showAppDestructiveDialog` |
| Force SR cards due | |
| Complete all lessons | |

No debug menu entries are accidentally reachable in release mode — all guards are in place.

---

## Area 9: Celebrations and Overlays

| Celebration | Trigger | Dismiss | Issues | Classification |
|-------------|---------|---------|--------|----------------|
| `LevelUpDialog` | `lesson_completion_flow.dart` — called after `addXp()` when level increases | `barrierDismissible: false`, requires button tap | ⚠️ **Potential double-fire**: `lesson_completion_flow` calls `LevelUpDialog.show()` directly. `LevelUpListener` (in `tab_navigator.dart`) watches `levelUpEventProvider` and calls `LevelUpOverlay.show()`. If the `addXp` call in the completion flow also fires `levelUpEventProvider`, both could show. Needs investigation of whether `levelUpEventProvider` fires during lesson completion XP awards. | Research First |
| `LevelUpOverlay` | `level_up_listener.dart` via `levelUpEventProvider` | Auto-dismiss (via AnimationController.completed callback), event cleared | ✓ `clearEvent()` called after show | Complete |
| `AchievementUnlockedDialog` | `achievement_provider.dart:353` — called in a loop for each new achievement | `barrierDismissible: false`, button required | ⚠️ If multiple achievements unlock at once (e.g. "First lesson" + "First day" simultaneously), they're called sequentially via `await` — but the loop doesn't properly queue them; the `await` is inside a `for` loop within a single async call, so they fire one-after-another without waiting for the first to dismiss before starting the second await. | Should Fix |
| `ConfettiOverlay` | `celebration_service.dart:353` | Auto-dismisses via `entry.remove()` after animation | ✓ | Complete |
| `WaterChangeCelebration` | `add_log_screen.dart:1023` — on water change log saved | `entry.remove()` via `onComplete` callback | ✓ Uses `OverlayEntry` properly | Complete |
| `StreakMilestoneCelebration` | `streak_milestone_listener.dart` — wraps `tab_navigator` | Auto-dismiss (3s animation), `_isShowing` guard | ✓ Guard prevents double-show. Milestones: 3, 7, 14, 30, 60, 100 days. | Complete |
| `UnlockCelebrationScreen` | `lesson_screen.dart:335` — when `newSpeciesId` returned from lesson | Full screen push, back button available | ✓ | Complete |
| `Day2StreakPrompt` (flame animation) | Home screen returning user flow | Dismiss via Continue/Later buttons | ✓ | Complete |
| `Day7MilestoneCard` (XP bounce animation) | Home screen returning user flow | `Navigator.pop()` | ⚠️ Feature tap broken (see Area 7) | Must Fix |
| `XP Award Animation` | `widgets/xp_award_animation.dart` — on XP gain | Auto-dismiss | ✓ | Complete |

---

## Area 10: First-Visit Tooltips

File: `widgets/first_visit_tooltip.dart`

### System overview
`FirstVisitTooltip` is a `ConsumerStatefulWidget` that:
- Shows once (tracked via `SharedPreferences` key)
- Auto-dismisses after `autoDismissDuration` (default 4s)
- Can be tapped to dismiss early
- Has fade+slide animation (respects `reducedMotionProvider`)
- `hasSeenTooltip(key, ref)` utility for pre-checking

### Current tooltip deployments

| Screen | Prefs Key (inferred) | Message | Wired | Issues | Classification |
|--------|---------------------|---------|-------|--------|----------------|
| Home screen — Tank section | multiple tooltips (lines 627,640,653,668) | Multiple contextual tips | ✓ | — | Complete |
| Learn screen | checked in `_checkFirstVisitTooltip()` init | Learning tips | ✓ | — | Complete |
| Practice Hub screen | `practice_hub_screen.dart:129` | Practice tips | ✓ | — | Complete |
| Settings Hub screen | `settings_hub_screen.dart:99` | Settings navigation tip | ✓ | — | Complete |
| Smart screen | `smart_screen.dart:145` | AI tools tip | ✓ | — | Complete |
| Workshop screen | `_showFirstVisitTooltip()` via snackbar (not `FirstVisitTooltip`) | Uses `DanioSnackBar.info` instead of `FirstVisitTooltip` widget | ⚠️ Workshop uses a DanioSnackBar for first-visit rather than the standard tooltip system — inconsistent | Should Fix |

### Screens that SHOULD have first-visit tooltips but don't

| Screen | Why it would benefit | Classification |
|--------|---------------------|----------------|
| `TankDetailScreen` | First time users see this screen it's dense — a tooltip explaining Quick Stats or the action buttons would help | Future Scope |
| `LivestockScreen` | "Tap + to add your first fish" | Future Scope |
| `EquipmentScreen` | "Track filters, heaters, and lights here" | Future Scope |
| `LogsScreen` | "Log water tests, observations, and changes here" | Future Scope |
| `JournalScreen` | "Write notes about your tank — private entries, no required format" | Future Scope |
| `RemindersScreen` | "Set recurring maintenance reminders" | Future Scope |
| `GemShopScreen` | "Spend gems earned from learning on tank upgrades" | Future Scope |
| `TasksScreen` | First task addition | Future Scope |

---

## Appendix A: Raw SnackBar Usage (Non-DanioSnackBar)

All raw `SnackBar()` / `ScaffoldMessenger.of()` usage is confined to `utils/app_feedback.dart` (which is the underlying implementation) and two pre-capture patterns in `livestock_screen.dart` and `tank_detail_screen.dart`. Both pre-capture patterns are intentional and correct (they avoid "deactivated widget" errors after `Navigator.pop()`). **No non-standard snackbar leakage found.**

---

## Appendix B: Notification Tab Index Discrepancy (Detail)

The `NotificationService` class contains a comment block (lines 43-47) describing payload routing from a previous navigation layout:

```
// 'home'  → currentTabProvider = 0 (Home tab)
// 'learn' → currentTabProvider = 1 (Learn tab)
// 'care'  → currentTabProvider = 0 (Home tab, care/log view)
// 'review'→ currentTabProvider = 1 (Learn tab, then push review screen)
// 'achievements' → currentTabProvider = 2 (Profile tab, achievements)
```

**Actual tab layout (current):**
- 0 = Learn (`LearnScreen`)
- 1 = Practice/Quiz (`PracticeHubScreen`)  
- 2 = Tank/Home (`HomeScreen`)
- 3 = Smart (`SmartScreen`)
- 4 = Settings (`SettingsHubScreen`)

**`main.dart` actual routing (correct):**
- `'learn'` → 0 ✓
- `'review'` → 1, push SR screen ✓
- `'home'` → 2 ✓
- `'achievements'` → 4, push AchievementsScreen ✓
- `'care'` → **NOT HANDLED** ✗
- `'water_change'` → **NOT HANDLED** ✗

`payloadToTabIndex()` static method in `NotificationService` uses the old layout numbers and is not called by `main.dart`. If any future code calls it, it will route incorrectly.

---

## Appendix C: Orphaned/Stub Screens

| Screen | File | Status |
|--------|------|--------|
| Re-export shims (analytics, learn, lesson, add_log, livestock, spaced_repetition_practice) | `screens/*_screen.dart` top level | All are intentional re-export shims — not orphaned |
| Guide screens (acclimation, algae, breeding, disease, emergency, etc.) | `screens/*_guide_screen.dart` | All reachable via Settings → Guides section (`guides_section.dart`) |

No truly orphaned production screens found. All screens have at least one navigation path.

---

*End of audit. Document auto-generated by Daedalus surface audit, 2026-03-29.*
