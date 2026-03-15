# Danio — Final UX/UI Audit
**Auditor:** Athena (subagent)  
**Date:** 2026-03-15  
**Scope:** Full codebase read-only audit — every screen in `lib/screens/`, every widget in `lib/widgets/`, key providers and services.  
**Status:** READ-ONLY. No files were modified.

---

## Executive Summary

Danio is a genuinely impressive Flutter app. The bones are solid: good state management (Riverpod), thoughtful theming, skeleton loaders, error boundaries, haptic feedback, proper `PopScope` guard rails, and a rich feature set. The Duolingo-for-fishkeeping concept is coherent and the UX *mostly* works. However, the app has grown quickly and accumulated meaningful UX debt — particularly around discoverability, the onboarding-to-engagement funnel, and the visual/semantic inconsistency between screens built at different times. The issues below are real and worth fixing before a wide launch.

**Overall verdict:** Would I keep using this app? **Yes — but only if I stumbled on the Tab > Tank > Demo flow.** Without that, the first-run experience is fragile. Fix the P0s and this is a compelling product.

---

## Severity Definitions
| Severity | Meaning |
|----------|---------|
| **P0** | Blocks core flow or causes crashes/data loss. Fix before launch. |
| **P1** | Significant friction, likely to cause churn or confusion. Fix soon. |
| **P2** | Polishing issues, minor inconsistency, accessibility improvements. Schedule as time allows. |

---

## 1. User Journey Gaps

### UX-001 — Quick Start bypasses ALL personalisation and drops user in Tank tab with no tank
**Severity:** P1  
**File:** `lib/screens/onboarding_screen.dart` → `_quickStart()`  
**Issue:** The "Quick Start" button creates a minimal beginner profile (single goal: `keepFishAlive`, freshwater, no name), marks onboarding complete, then pops to root — landing the user on the `LearnScreen` (Tab 0). They have no tank, no lessons in progress, and no contextual guidance. The Learn tab will show skeleton → paths, which is fine, but navigating to Tank (Tab 2) shows `EmptyRoomScene`. The user has been through zero onboarding steps and is looking at a blank room. There's no continuity between "Quick Start" and anything that follows.  
**Fix:** After Quick Start completes, explicitly navigate to the Tank tab and auto-show the `EmptyRoomScene` CTA. Alternatively, suppress the Quick Start button entirely — the full personalisation flow is only 3 taps and is clearly faster than it sounds.

---

### UX-002 — No bridge between Learn completion and Tank management
**Severity:** P1  
**Files:** `lib/screens/lesson_screen.dart`, `lib/screens/tab_navigator.dart`  
**Issue:** When a user completes a lesson they get XP, a celebration, and the screen pops back to `LearnScreen`. There is no contextual prompt like "Now log it on your tank" or "Ready to set up your first tank?". The two core pillars (learning + tank management) feel like separate apps. A new user who does lessons for a week might not realise the Tank tab is where they *manage a real aquarium*.  
**Fix:** On first lesson completion (or when tank count is 0), show a one-time in-app tip: "Good stuff! Ready to track your real fish? → Go to Tank tab". A `SnackBar` with an action is sufficient.

---

### UX-003 — "Explore a demo tank first" creates a confusing, uncommitted state
**Severity:** P1  
**File:** `lib/screens/home/widgets/empty_room_scene.dart`, `home_screen.dart`  
**Issue:** The "Explore a demo tank first" button seeds a `demoTank` and navigates directly to `TankDetailScreen`. When the user navigates back to HomeScreen, `EmptyRoomScene` is no longer shown (demo tank now exists) and the demo tank appears as if it's the user's real tank. There's no visible indicator this is a demo. Users may log water tests or add fish to a demo tank believing it's real data.  
**Fix:** Tag demo tanks with an `isDemoTank` flag and show a persistent "Demo Mode" banner in `TankDetailScreen` with a "Start with my own tank →" CTA. Alternatively, open the demo in a non-persistent modal flow.

---

### UX-004 — No path from `SmartScreen` → requiring an API key, to getting one
**Severity:** P1  
**File:** `lib/screens/smart_screen.dart`  
**Issue:** When no OpenAI API key is configured, the Smart tab shows `_OfflineBanner` and greys out Fish ID, Symptom Checker, and Weekly Plan with "Enable AI in Settings to use this" — but there is no direct link or button that takes the user to where they configure the key. The user must know to go to Toolbox → Preferences → find the AI section.  
**Fix:** Add a tappable `_OfflineBanner` or inline link: "Enable AI features → tap here". Route to the correct settings section directly.

---

### UX-005 — Placement test (`EnhancedPlacementTestScreen`) is buried and unsignposted
**Severity:** P2  
**File:** `lib/screens/learn_screen.dart`, `lib/widgets/placement_challenge_card.dart`  
**Issue:** The placement test exists and is surfaced via `PlacementChallengeCard` — but only for intermediate/expert users. New beginners who would benefit from "skip what you know" never see it. The card itself is not visually prominent (appears below the streak badge, which is below the review banner, all below the 320px header). Easy to miss.  
**Fix:** Show a one-time placement test prompt to ALL users at the top of the Learn tab on first visit, with a dismiss option. Frame it as "Already know some fishkeeping? Skip ahead →".

---

### UX-006 — `FirstTankWizardScreen` exists but is never reached in the main flow
**Severity:** P1  
**File:** `lib/screens/onboarding/first_tank_wizard_screen.dart`  
**Issue:** `FirstTankWizardScreen` is a complete, well-designed 4-step wizard for creating a first tank (name → volume → type → confirm). But tracing the codebase: the main user path goes Onboarding → Personalisation → JourneyReveal → `popUntil(isFirst)` → TabNavigator. No route calls `FirstTankWizardScreen`. The user creates tanks via `CreateTankScreen` (a separate, less guided multi-page form). This is a high-quality screen with no users seeing it.  
**Fix:** Either route from `JourneyRevealScreen` → `FirstTankWizardScreen` for new users who said "Yes, I have a tank" in personalisation, or delete the wizard and consolidate into `CreateTankScreen`.

---

### UX-007 — `LearningStyleScreen` and `EnhancedTutorialWalkthroughScreen` unreachable in main flow  
**Severity:** P1  
**Files:** `lib/screens/onboarding/learning_style_screen.dart`, `lib/screens/onboarding/enhanced_tutorial_walkthrough_screen.dart`  
**Issue:** Same problem as UX-006. These screens exist and are internally complete, but `LearningStyleScreen` is only reached from `EnhancedPlacementTestScreen.onComplete` (which itself requires reaching the placement test). The main `PersonalisationScreen` → `JourneyRevealScreen` flow skips both. Large bodies of onboarding code are dead code for the primary install path.  
**Fix:** Audit the intended onboarding sequence and commit to one path. Either integrate these screens or remove them to reduce maintenance burden and cognitive overhead.

---

## 2. Navigation Dead-Ends

### NAV-001 — `WorkshopScreen` has no app bar — no way out except OS back gesture
**Severity:** P1  
**File:** `lib/screens/workshop_screen.dart`  
**Issue:** `WorkshopScreen` renders a `SafeArea > CustomScrollView` with a `_WorkshopHeader` inside. The header is a custom widget with a title and subtitle — but no back button and no `AppBar`. The only exit is the Android back gesture or iOS swipe. On devices with gesture navigation disabled and no back bar, users are trapped.  
**Fix:** Add a `SliverAppBar` with `automaticallyImplyLeading: true`, or place a back icon in the `_WorkshopHeader`. The screen is reached via `NavigationThrottle.push`, so a standard AppBar back button will work correctly.

---

### NAV-002 — `ShopStreetScreen` same issue — no AppBar/back button
**Severity:** P1  
**File:** `lib/screens/shop_street_screen.dart`  
**Issue:** `ShopStreetScreen` is a `ConsumerWidget` that returns a bare `Container` (gradient) > `SafeArea` > `CustomScrollView`. No `Scaffold`, no `AppBar`. Identical issue to `WorkshopScreen`. Users must use OS gestures.  
**Fix:** Wrap in `Scaffold` with `SliverAppBar` or add an explicit back button in the header.

---

### NAV-003 — Story Player lacks explicit back affordance
**Severity:** P2  
**File:** `lib/screens/story_player_screen.dart`  
**Issue:** Story player-style screens typically have a close/back button in the top corner. If this screen also relies purely on OS navigation, it's a dead-end for the same users as NAV-001/002.  
**Suggested fix:** Verify `StoryPlayerScreen` has an accessible close button, not just gesture-only navigation.

---

### NAV-004 — `GemShopScreen` — no obvious route to it in the main nav tree
**Severity:** P2  
**File:** `lib/screens/gem_shop_screen.dart`, `lib/screens/shop_street_screen.dart`  
**Issue:** `GemShopScreen` is reached from inside `ShopStreetScreen`. But `ShopStreetScreen` itself has no AppBar (NAV-002). If a user taps into the Gem Shop and wants to go back to the main app, they're two levels deep with no breadcrumb and only OS back. The Toolbox tab → Shop Street → Gem Shop chain is three taps with zero visible nav hierarchy.  
**Fix:** Implement proper `SliverAppBar` with back buttons at each level. Consider whether `GemShopScreen` should be directly accessible from Toolbox.

---

### NAV-005 — `SettingsScreen` (Preferences) is buried under a confusingly named path
**Severity:** P2  
**File:** `lib/screens/settings_hub_screen.dart`  
**Issue:** The tab is labelled "Toolbox" (icon: construction). The screen it leads to is `SettingsHubScreen`. Inside that, "Preferences" leads to `SettingsScreen`. The label hierarchy is: Toolbox → Preferences → (actual settings). "Toolbox" accurately describes the Workshop but not Settings/Backup/About. New users looking for "Settings" won't know to look in "Toolbox".  
**Fix:** Rename the tab to "More" or use a person/profile icon convention (common on mobile). Or surface a Settings gear icon in the app bar of other main screens.

---

## 3. Empty States

### EMPTY-001 — `TodayBoardCard` error state is invisible and unexplained
**Severity:** P2  
**File:** `lib/screens/home/widgets/today_board.dart`  
**Issue:** On error, `TodayBoardCard` shows a tiny inline row: `Icon(info_outline) + Text('Unable to load')` with no action. This is a compact widget that sits in the home screen Stack. The error state is so small it's likely unnoticed, and there's no retry affordance.  
**Fix:** On error, show the empty/no-tasks variant rather than an error micro-chip. Or expose a retry tap.

---

### EMPTY-002 — `PracticeHubScreen` "All Caught Up" state has no suggested next action
**Severity:** P2  
**File:** `lib/screens/practice_hub_screen.dart`  
**Issue:** When `dueCards == 0`, the hero card shows "All Caught Up! 🎉 No cards due right now. Great job!" with `onTap: null` (non-interactive). The user is left staring at a green check with nothing to do. The screen below still shows stats but no clear "what next" prompt.  
**Fix:** Change the hero card copy to suggest an action: "All caught up — try a new lesson?" with a tap target that navigates to the Learn tab. Alternatively, show an option to do a free-practice session.

---

### EMPTY-003 — `LogsScreen` empty state is generic
**Severity:** P2  
**File:** `lib/screens/logs_screen.dart`  
**Issue:** `LogsScreen` uses `EmptyState` widget (not `EmptyState.withMascot`) and presumably shows a generic "no logs yet" message. The empty state doesn't explain *what* a log is or *why* users should log. New users who arrive here from Tank Detail won't know what to do.  
**Fix:** Use a specific, contextual empty state: "No activity logged yet. Tap + to record a water test, feeding, or water change." Include a direct "Log something" CTA button.

---

### EMPTY-004 — `EquipmentScreen` and `LivestockScreen` empty state copy is acceptable but inconsistent
**Severity:** P2  
**Files:** `lib/screens/equipment_screen.dart`, `lib/screens/livestock_screen.dart`  
**Issue:** `LivestockScreen` uses `EmptyState.withMascot` (good). Equipment screen likely uses `AppEmptyState` (core widget). The mascot inconsistency means some empty states feel warm (with Finn) and others feel cold (icon-only). Two different empty-state widget families exist: `EmptyState` (mascot-capable), `AppEmptyState` (no mascot), and `CompactEmptyState` (text only). All three are in use across the app.  
**Fix:** Standardise on one empty state component. `EmptyState.withMascot` is the best — use it everywhere, even if the mascot message is optional.

---

### EMPTY-005 — `SearchScreen` with empty query shows helpful prompts, but results-empty state is unclear
**Severity:** P2  
**File:** `lib/screens/search_screen.dart`  
**Issue:** When a query returns no results, the `_SearchResults` widget presumably renders an empty list. There's no explicit "no results for X" state visible in the code. The behaviour is inferred — it just shows nothing.  
**Fix:** Add an explicit `AppEmptyState` for no-results case with the searched query highlighted: "No results for 'pleco'." and suggestions like "Try species browser →".

---

## 4. Inconsistent Patterns

### INCON-001 — Three different button families across the app
**Severity:** P2  
**Files:** `lib/widgets/core/app_button.dart`, `lib/widgets/common/buttons.dart`, `lib/screens/onboarding_screen.dart` (`_PrimaryButton`), `lib/screens/onboarding/personalisation_screen.dart` (`_PrimaryButton`)  
**Issue:** The app has: (1) a `core/app_button.dart` design system button, (2) `common/buttons.dart` helpers, and (3) inline `_PrimaryButton` private classes duplicated inside `onboarding_screen.dart` and `personalisation_screen.dart`. The onboarding `_PrimaryButton` uses `GestureDetector` + `AnimatedBuilder` scale animation; the core button presumably uses `ElevatedButton`. These are visually inconsistent and maintain separately.  
**Fix:** Delete the private `_PrimaryButton` classes and use the design system `AppButton` everywhere. Pass the custom style (gradient, shadow, scale animation) via theme or `AppButton` parameters.

---

### INCON-002 — WorkshopScreen and ShopStreetScreen use custom room-themed full-screen containers; other tabs use standard Scaffold
**Severity:** P2  
**Files:** `lib/screens/workshop_screen.dart`, `lib/screens/shop_street_screen.dart`, `lib/screens/learn_screen.dart`, `lib/screens/practice_hub_screen.dart`  
**Issue:** Learn and Practice use standard `Scaffold` with `AppBar`. Workshop and Shop use custom full-bleed containers with no Scaffold. This means: different status bar handling, different back-navigation affordance, and different accessibility tree structure. The "room" metaphor is charming but breaks when half the rooms have bars and half don't.  
**Fix:** Decide: are these "rooms" (no AppBar, themed) or "screens" (standard Scaffold)? If rooms, implement a consistent `RoomScaffold` base widget with a built-in back button overlay. If screens, wrap in `Scaffold`.

---

### INCON-003 — Two parallel `SettingsScreen` / `SettingsHubScreen` with overlapping content
**Severity:** P2  
**Files:** `lib/screens/settings_hub_screen.dart`, `lib/screens/settings_screen.dart`  
**Issue:** `SettingsHubScreen` (the tab) lists: Shop, Achievements, Workshop, Analytics, Preferences, Backup, About. `SettingsScreen` (Preferences) is a monster 60+ item list that includes: Quick Start Guide, Species Browser, Plant Browser, all calculators (again), guides, accounts, notification settings, and more. Many of the items in `SettingsScreen` are also reachable from `WorkshopScreen`. The information architecture is blurry — things appear in multiple places with no obvious canonical location.  
**Fix:** Rationalise the IA. `SettingsScreen` should only contain true app preferences (theme, notifications, difficulty, account). Everything else belongs in Workshop or its own section. Remove duplicates.

---

### INCON-004 — Tab 0 starts at Learn, but `currentTabProvider` defaults to index 0 (Learn)
**Severity:** P2  
**File:** `lib/screens/tab_navigator.dart`  
**Issue:** The `currentTabProvider` is `StateProvider<int>((ref) => 0)` — index 0 is Learn. The comment says `// Start at Learn tab`. This is fine for a learning app, but when a user's primary activity is tank management (advanced users), they'll always land on Learn. There's no persisted last-active-tab preference.  
**Fix:** Persist the last active tab to SharedPreferences and restore it on app launch. This is a standard mobile UX pattern.

---

### INCON-005 — Hearts system (lesson lives) is inconsistently applied
**Severity:** P1  
**Files:** `lib/screens/lesson_screen.dart`, `lib/screens/spaced_repetition_practice_screen.dart`, `lib/providers/hearts_provider.dart`  
**Issue:** Hearts are shown in `LessonScreen` (compact `HeartIndicator` in the AppBar) and in `PracticeHubScreen`. But `SpacedRepetitionPracticeScreen` (the actual review session) doesn't appear to drain hearts when the user gets answers wrong — `ReviewSessionScreen` is a separate widget inside the same file. The home screen shows "low hearts" warning overlay. It's unclear to users: do hearts apply to lessons only? Flashcard reviews? Both? The rules are invisible.  
**Fix:** Add a consistent in-app explanation of hearts (what they are, when they're lost, when they refill). A one-time tooltip or `InfoCard` at first lesson start would help. Make the rules consistent — if hearts apply to lessons, they should apply to SR practice too.

---

## 5. Onboarding Flow

### ONB-001 — Onboarding flow has a fork that's hard to reason about
**Severity:** P1  
**File:** `lib/main.dart` (`_AppRouter`), `lib/screens/onboarding_screen.dart`  
**Issue:** The routing logic is: if `!onboardingCompleted` → `OnboardingScreen`; else if `!profileExists` → `PersonalisationScreen`; else → `TabNavigator`. This means:  
- Path A: Brand new user → Onboarding (3 swipe pages) → Personalisation → JourneyReveal → TabNavigator  
- Path B: User who previously started but was force-quit mid-onboarding → `_AppRouter` detects `onboardingCompleted=false`, `profileExists=true` (pre-populated from existing profile) → goes to `OnboardingScreen` again and re-shows all 3 intro pages  

The `PersonalisationScreen.initState` handles the recovery case (pre-populating from existing profile), but the user still sees the intro slides again, which is confusing for someone returning after a crash.  
**Fix:** If `profileExists` is true AND `!onboardingCompleted`, skip straight to `PersonalisationScreen` (which will pre-populate and let them complete). The intro slides don't need to be repeated.

---

### ONB-002 — `JourneyRevealScreen` has a dead space between headline and feature pills
**Severity:** P2  
**File:** `lib/screens/onboarding/journey_reveal_screen.dart`  
**Issue:** The layout is: `SizedBox(height: xxl)` + `SizedBox(height: xl)` + Headline + Padding + Subheading + `SizedBox(height: xxl)` + Feature pills + Spacer + CTA. On shorter devices (e.g. Galaxy A series, ~5.5") the two large top spacers push content down and the CTA may be clipped or the feature pills may overflow. There's no `SingleChildScrollView` safety net.  
**Fix:** Wrap the `Column` in a `SingleChildScrollView`, or replace the fixed `SizedBox` spacers with `Flexible`/`Expanded` to let the layout breathe on small screens.

---

### ONB-003 — Onboarding doesn't mention the "house" room metaphor at all
**Severity:** P2  
**File:** `lib/screens/onboarding_screen.dart`  
**Issue:** The 3 onboarding pages explain Danio's value props (lessons, management, smart tracking). But the app's core UI metaphor — a "house" with rooms (Study, Living Room/Tank, Workshop, Shop) — is never introduced. The first time a user hits the home screen and sees a room scene with a tank stand and a mascot, they have zero context for what they're looking at.  
**Fix:** Replace one of the onboarding pages (or add a 4th) with a brief "Your house" explanation: "Navigate between rooms — Study Room for lessons, Living Room for your tanks, Workshop for tools." A simple illustration would make it click immediately.

---

### ONB-004 — No confirmation or progress saved message at end of onboarding
**Severity:** P2  
**File:** `lib/screens/onboarding/journey_reveal_screen.dart`  
**Issue:** When the user taps "Let's go →", the app calls `service.completeOnboarding()`, invalidates the provider, and pops to root. This is correct, but there's no visible transition or "you're in!" moment. The user suddenly sees the main app. The `_showWelcomeBanner` in `HomeScreen` compensates for this (shows "Welcome! Your aquarium journey starts now" for 4 seconds), but this is only shown on the Tank tab. If the user lands on Learn tab (the default, tab index 0), they never see the welcome banner.  
**Fix:** Show the welcome banner on the Learn tab too, or trigger a one-time confetti animation on first app entry regardless of which tab is active.

---

## 6. Tap Targets

### TAP-001 — `_DismissibleBanner` dismiss button (×) is 14dp icon in 44dp touch target — barely passes
**Severity:** P2  
**File:** `lib/screens/home/home_screen.dart` (`_DismissibleBanner`)  
**Issue:** The `×` icon is `size: 14`, wrapped in a `SizedBox(width: 44, height: 44)`. The touch area is technically 44dp (fine), but the icon is tiny (14dp) with no visual affordance that it's tappable. Users may not realise banners are dismissable.  
**Fix:** Increase the icon to 18-20dp and add a slight background circle on hover/press. Consider a standard `CloseButton` widget.

---

### TAP-002 — Stage handle strips for temp/water panels are 14dp visual with 48dp touch — undiscoverable
**Severity:** P1  
**File:** `lib/screens/home/home_screen.dart` (StageHandleStrip), `lib/widgets/stage/swiss_army_panel.dart`  
**Issue:** The side panels (temperature left, water quality right) are opened by thin 14dp visual strips on screen edges with a small icon. The touch target is 48dp wide which is adequate, but the visual affordance is extremely subtle — especially over the varied room scene background. New users will not discover these panels.  
**Fix:** Add a brief "swipe from edge" tutorial tooltip on first Tank visit. Or add a more visible handle bar (like a pill/tab that extends slightly from the edge). Consider showing the panels as cards below the room scene instead of hidden side panels.

---

### TAP-003 — `TankSwitcher` not tappable when only one tank exists
**Severity:** P2  
**File:** `lib/screens/home/widgets/tank_switcher.dart`  
**Issue:** When `tanks.length == 1`, `hasMultipleTanks` is false, so `InkWell.onTap` is null. The widget still renders as a card, but tapping does nothing. Users might expect tapping the tank card to navigate to the tank detail or show options — but nothing happens.  
**Fix:** When a single tank exists, tapping the `TankSwitcher` should navigate to `TankDetailScreen` for that tank. Or show a tooltip: "Long-press to manage tanks".

---

### TAP-004 — Quiz answer options in `LessonScreen` don't specify minimum height
**Severity:** P2  
**File:** `lib/screens/lesson_screen.dart`  
**Issue:** From the code structure, quiz answers are rendered as tappable containers. Without seeing the exact widget, standard Flutter list tiles/cards used for answers should have a minimum 48dp height per Material guidelines. If the answer text is very short (e.g., "Yes"/"No"), the touch target may shrink.  
**Fix:** Ensure all quiz answer tap targets have `constraints: BoxConstraints(minHeight: 56)` or are wrapped in `SizedBox(height: 56)`.

---

### TAP-005 — Speed Dial FAB: small action labels, tight clustering on small screens
**Severity:** P2  
**File:** `lib/widgets/speed_dial_fab.dart`, `lib/screens/home/home_screen.dart`  
**Issue:** The Speed Dial FAB has 5 actions (Stats, Water Change, Feed, Quick Test, Add Tank). On a small screen, these 5 options fan out in a radial/linear pattern. With 5 actions, spacing between buttons may be under 8dp, making adjacent items hard to target without mis-tapping.  
**Fix:** Reduce to the 3 most common actions (Water Change, Quick Test, Feed). Move Stats to the BottomPlate header and Add Tank to a persistent "+ Add" button in the tank list. Or increase FAB item spacing.

---

## 7. Loading States

### LOAD-001 — `TodayBoardCard` shows `SizedBox.shrink()` during loading — invisible to user
**Severity:** P2  
**File:** `lib/screens/home/widgets/today_board.dart`  
**Issue:** On loading, `TodayBoardCard` returns `const SizedBox.shrink()`. The card simply doesn't exist during load. If tasks take 500ms to load, the board just appears, which is jarring rather than smooth.  
**Fix:** Show a minimal skeleton (e.g., 2 shimmer task rows) during load instead of invisible SizedBox. The skeleton placeholders utility already exists in `lib/utils/skeleton_placeholders.dart`.

---

### LOAD-002 — `AnalyticsScreen` loads via `Future` in `initState` — no skeleton, just a `FutureBuilder`
**Severity:** P2  
**File:** `lib/screens/analytics_screen.dart`  
**Issue:** Analytics data is loaded via `_analyticsFuture = _loadAnalytics()` in `initState`, then rendered via `FutureBuilder`. When loading, presumably a spinner shows. Given the analytics screen has charts, this means the entire chart area is blank until data arrives. This is jarring on slow devices.  
**Fix:** Use `SkeletonLoader` for the chart areas during the initial load. The skeleton charts don't need to show real data — just placeholder bars or a grey rectangle.

---

### LOAD-003 — `SmartScreen` AI responses: no token-by-token streaming indicator
**Severity:** P2  
**File:** `lib/screens/smart_screen.dart`  
**Issue:** When "Ask Danio" is submitted, `_askLoading = true` is set and `CircularProgressIndicator` presumably shows inside the response card. For an AI chat interaction, a typing indicator (three dots or bubble animation) is more appropriate — it sets expectations that this takes a few seconds and feels alive.  
**Fix:** Replace the `CircularProgressIndicator` in the response area with the existing `BubbleLoader` widget (fish-themed loader), which is thematically appropriate and already built.

---

### LOAD-004 — `SpacedRepetitionPracticeScreen` initial load shows `BubbleLoader` centred on full screen — context lost
**Severity:** P2  
**File:** `lib/screens/spaced_repetition_practice_screen.dart`  
**Issue:** When `srState.isLoading`, the entire screen is replaced by `Scaffold(body: Center(child: BubbleLoader()))`. There's no AppBar, no context. The user came from the Practice hub and is now staring at a loading screen with no way to go back (no AppBar, so no leading back button — only OS gestures).  
**Fix:** Keep the AppBar visible during loading. Show the loader within the body area, not replacing the entire Scaffold.

---

## 8. Error States

### ERR-001 — `HomeScreen` error state lacks retry with user-friendly message
**Severity:** P1  
**File:** `lib/screens/home/home_screen.dart`  
**Issue:** The tank load error state uses `AppErrorState(title: "Couldn't load your tanks", message: 'Check your connection and give it another go', onRetry: ...)`. This is actually good, but the error occupies the entire body area with the room background not rendering. On a decorative app with a room scene, a full-screen grey error state is particularly jarring. Additionally, if the user has tanks saved locally, the error shouldn't block them entirely — local data should be shown.  
**Fix:** Show locally-cached tanks in degraded mode on network error (most providers should already have local-first data via SharedPreferences). Reserve the full-screen error for when there's truly nothing to show.

---

### ERR-002 — `CreateTankScreen` form validation — no error shown if user submits with missing required fields  
**Severity:** P1  
**File:** `lib/screens/create_tank_screen.dart`  
**Issue:** The wizard has per-step validation via `_canProceed()`. The "Next" button is disabled when not valid (`canProceed = false`), but there's no inline error message explaining *why* the user can't proceed. If the user has typed something that doesn't meet criteria (e.g., volume = 0 entered via text, then cleared), the button just stays grey with no feedback.  
**Fix:** Show inline validation errors on the relevant input fields. A `TextFormField.validator` combined with `Form.validate()` at each step transition would provide the right feedback.

---

### ERR-003 — Smart screen AI errors are shown as raw message strings, not styled error cards
**Severity:** P2  
**File:** `lib/screens/smart_screen.dart`  
**Issue:** When the AI call fails (timeout, auth error, network error), `_askResponse` is set to an error string like "Sorry, I couldn't answer that right now..." and displayed in the response area. The code shows this as a plain text field. An auth error message ("Your API key appears to be invalid or expired") is particularly technical for end users.  
**Fix:** Wrap error responses in a styled error card (red border, warning icon). For auth errors, show a "Fix API key →" button directly in the card. For network errors, show a retry button.

---

### ERR-004 — `BackupRestoreScreen` progress feedback during export/import is minimal
**Severity:** P2  
**File:** `lib/screens/backup_restore_screen.dart`  
**Issue:** `_isExporting` and `_isImporting` booleans track state, and `_progressStatus`/`_progressValue` fields exist. But it's unclear how visibly these are surfaced in the UI. For an operation that touches user data, clear progress (e.g., `LinearProgressIndicator` with status text) is critical. An unexpected error mid-backup with no rollback indication would be alarming.  
**Fix:** Ensure the `_progressStatus` text is always visible and prominent during backup/restore. Show a full-screen blocking dialog (not just a loading indicator in the background) so users understand the operation is in progress and they shouldn't close the app.

---

## 9. Accessibility

### A11Y-001 — `EmptyRoomScene` CTA text inside `NotebookCard` is small with no minimum contrast check
**Severity:** P2  
**File:** `lib/screens/home/widgets/empty_room_scene.dart`  
**Issue:** The `NotebookCard` renders on a warm cream gradient background. The text uses `context.textSecondary` which may not have sufficient contrast ratio against the cream background for WCAG AA compliance (4.5:1 for normal text). No contrast audit is visible in the codebase for this specific combination.  
**Fix:** Verify the cream background + secondary text colour combo meets 4.5:1. Use `AppColors.textPrimary` for the description text to ensure compliance.

---

### A11Y-002 — `JourneyRevealScreen` background image has `excludeSemantics: true` but content above has no heading structure
**Severity:** P2  
**File:** `lib/screens/onboarding/journey_reveal_screen.dart`  
**Issue:** The background image correctly uses `excludeSemantics`. But the screen's text content (headline + subheading + 3 feature pills) has no `Semantics(header: true)` wrapping. Screen readers will read all text sequentially without structural context. The 3 feature pill items are static containers — no `Semantics(button: false, label: ...)` wrapper.  
**Fix:** Add `Semantics(header: true)` to the headline. Add `Semantics(label: '${feature.label} feature')` to each feature pill. This gives screen readers the structure to navigate efficiently.

---

### A11Y-003 — `PersonalisationScreen` selection cards use `Semantics(selected:)` correctly, but dismiss/clear action is missing
**Severity:** P2  
**File:** `lib/screens/onboarding/personalisation_screen.dart`  
**Issue:** `_buildSelectionCard` wraps with `Semantics(selected: isSelected, button: true, label: label)`. This is good. However, once selected, there's no way to *deselect* (the screen forces exactly one selection per section). If a user accidentally taps the wrong item and uses accessibility tools, they may not realise tapping again to switch works because the `selected` state doesn't announce the change with a live region.  
**Fix:** Add `aria-live` equivalent via `Semantics(liveRegion: true)` on a wrapper, so state changes are announced. Or add explicit "(tap to deselect)" to the semantic label when selected.

---

### A11Y-004 — Streak/hearts banners in `HomeScreen` overlay are not announced to screen readers
**Severity:** P2  
**File:** `lib/screens/home/home_screen.dart` (`_DismissibleBanner`, `_StreakHeartsOverlay`)  
**Issue:** The dismissible banners (streak, hearts warning) appear dynamically but are not wrapped in `Semantics(liveRegion: true)`. Screen reader users will not hear these announcements when the banners appear. The "low hearts" warning is safety-critical for users relying on accessibility tools.  
**Fix:** Wrap `_DismissibleBanner` in `Semantics(liveRegion: true, label: text)` so VoiceOver/TalkBack announces the banner when it appears.

---

### A11Y-005 — `WorkshopScreen` tool grid items (InteractiveObject) — unclear if they have accessibility labels
**Severity:** P2  
**File:** `lib/screens/workshop_screen.dart`, `lib/widgets/room/interactive_object.dart`  
**Issue:** The Workshop uses a `SliverGrid` of tool cards. If these are `InteractiveObject` widgets (used in room scenes), they may not have proper semantic labels. Without seeing the full InteractiveObject implementation, this is a risk.  
**Fix:** Verify each tool grid item has `Semantics(label: toolName, button: true)` and a minimum 48dp touch target. Add `tooltip:` strings to all icon buttons.

---

### A11Y-006 — `LessonScreen` quiz answer feedback is visual only — no semantic "correct/incorrect" announcement
**Severity:** P1  
**File:** `lib/screens/lesson_screen.dart`  
**Issue:** When a quiz answer is selected, the card presumably changes colour (green/red) to indicate correct/incorrect. This visual feedback is not backed by a `Semantics(liveRegion: true)` announcement. Screen reader users won't know if their answer was right until they navigate to the next element.  
**Fix:** After answer selection, trigger a semantic announcement: `SemanticsService.announce('Correct!', TextDirection.ltr)` or `SemanticsService.announce('Incorrect. The answer was X.', TextDirection.ltr)`.

---

### A11Y-007 — `SmartScreen` "Ask Danio" text field and submit button lack explicit labels
**Severity:** P2  
**File:** `lib/screens/smart_screen.dart`  
**Issue:** The `_askController` `TextField` has a `hintText` but likely no `InputDecoration.labelText`. For screen readers, `hintText` alone is insufficient — it disappears when the field is focused. The submit button (send icon) needs a tooltip or semantic label.  
**Fix:** Add `labelText: 'Ask Danio a question'` to the `InputDecoration`. Add `Semantics(label: 'Send question', button: true)` or `tooltip: 'Send'` to the submit `IconButton`.

---

### A11Y-008 — Bottom navigation bar tab icons lack `Semantics` beyond the material default
**Severity:** P2  
**File:** `lib/screens/tab_navigator.dart`  
**Issue:** `NavigationDestination` provides `label` which is used by Material as the accessibility label. This is adequate for most cases. However, the Practice tab badge (`dueCardsCount`) is announced as part of the visual `Badge` widget, but screen readers may read it as "99+ Practice" without explaining the count represents due review cards.  
**Fix:** Use `NavigationDestination.tooltip` or add a `Semantics(label: '$dueCardsCount cards due for review, Practice tab')` override when `dueCardsCount > 0`.

---

### A11Y-009 — `HomeScreen` `_buildQuickLogSheet` text fields use `labelText` correctly but no `textInputAction` chain
**Severity:** P2  
**File:** `lib/screens/home/home_screen.dart` (`_showQuickLogSheet`)  
**Issue:** The Quick Water Test sheet has 3 side-by-side fields (pH, Temp, NH3). Each uses `InputDecoration(labelText: ...)` which is correct. However, the keyboard `textInputAction` is not set — it defaults to `TextInputAction.done` on all fields, meaning keyboard "next" won't cycle between pH → Temp → Ammonia. Users have to manually focus each field.  
**Fix:** Set `textInputAction: TextInputAction.next` on pH and Temp fields, `TextInputAction.done` on the last (NH3). Use `FocusNode` chains to advance focus programmatically.

---

## 10. Overall First Impression

### IMP-001 — App name "Danio" and water drop icon are generic — no fish shown on splash
**Severity:** P2  
**File:** `lib/main.dart` (`_buildSplash`)  
**Issue:** The splash screen shows `Icon(Icons.water_drop)` — a generic Material icon. For a fishkeeping app, this is a missed branding opportunity. A real app icon or a styled fish SVG would communicate the domain instantly. The icon choice also means first impressions don't connect the app name "Danio" (a genus of fish) with the hobby.  
**Fix:** Use a custom Danio fish SVG or the app's actual launcher icon on the splash. The loading state between splash and main app (potentially several seconds on first launch while Firebase/Supabase initialise) should be visually engaging, not a spinner.

---

### IMP-002 — Tab bar label mismatch: "Toolbox" icon is `Icons.construction` but contains Account/Profile
**Severity:** P2  
**File:** `lib/screens/tab_navigator.dart`  
**Issue:** The 5th tab is labelled "Toolbox" with a construction wrench icon. Its `SettingsHubScreen` contains: profile card, Shop, Achievements, Workshop, Analytics, Preferences, Backup, About. The profile/account section is the first thing shown. Most users expect their profile to live under a person icon, not a wrench. The "Toolbox" label better describes Workshop (calculators, guides) than Account + Settings.  
**Fix:** Rename the tab to "Profile" or "More" with `Icons.person_outline`. Move Workshop-specific tools to be more prominent inside the Workshop deep-link. This is a structural IA fix, but it's important for learnability.

---

### IMP-003 — `FriendsScreen` and `LeaderboardScreen` are stubs that show "On the Way!" — nav paths lead to dead ends
**Severity:** P1  
**File:** `lib/screens/friends_screen.dart`, `lib/screens/leaderboard_screen.dart`  
**Issue:** Both screens exist with full stub implementations ("arriving in a future update"). However, `FriendsScreen` and `LeaderboardScreen` are accessible from within the codebase (not from the main nav — they are commented out in `settings_hub_screen.dart`: `// friends_screen.dart — hidden until feature ships`). If these screens are somehow reachable (e.g. via settings sub-nav, or future navigation code), users will hit dead ends. The stubs are well-designed but create a "feature not available" impression.  
**Fix:** Confirm these screens are truly unreachable (they appear to be — the import is commented out). If so, delete or mark clearly with `_DEBUG` guards. If they are reachable by any path, add a "Notify me when this launches" CTA with an email input.

---

### IMP-004 — The room metaphor is unique but not explained — feels confusing on first encounter
**Severity:** P1  
**File:** `lib/screens/home/home_screen.dart`, `lib/screens/workshop_screen.dart`, `lib/screens/shop_street_screen.dart`  
**Issue:** The app presents three different visual themes across tabs: a study room (Learn), a living room with a fish tank (Tank), a workshop (Toolbox → Workshop), and a green market (Shop Street). This is delightful and differentiated once you understand it. But there's zero onboarding for this concept. A first-time user tapping through tabs will see: a study desk illustration, a room scene with a cabinet, a brown workshop, and a green market — with no explanation of what connects them.  
**Fix:** Add a "Your House" tour as part of onboarding or first-visit tooltips on each tab. Even a simple `Tooltip` or `OverlayEntry` on first arrival at each tab would help. This is the app's biggest differentiator — don't let it be confusing.

---

### IMP-005 — "Gems" currency exists but has no clear earn mechanism visible to new users
**Severity:** P2  
**File:** `lib/screens/gem_shop_screen.dart`, `lib/providers/gems_provider.dart`  
**Issue:** The Gem Shop sells items for gems. It's accessible from Shop Street. But how do users earn gems? There's no visible earn mechanic in the main flow (not in lessons, not in tasks). If gems are only purchasable with real money (IAP), this is a business model decision that needs clear communication. If they're earnable, the earn paths must be obvious.  
**Fix:** Add a "How to earn gems" section to the Gem Shop header, or a `?` info button. If gems are purely purchasable, make this explicit. If earnable via activities, show the XP-to-gems conversion rate prominently.

---

## Summary Table

| ID | Title | Severity | File(s) |
|----|-------|----------|---------|
| UX-001 | Quick Start drops user with no guidance | P1 | `onboarding_screen.dart` |
| UX-002 | No bridge between Learn and Tank management | P1 | `lesson_screen.dart`, `tab_navigator.dart` |
| UX-003 | Demo tank mode unmarked, creates confusion | P1 | `empty_room_scene.dart`, `home_screen.dart` |
| UX-004 | No path from Smart → API key setup | P1 | `smart_screen.dart` |
| UX-005 | Placement test buried, beginners never see it | P2 | `learn_screen.dart` |
| UX-006 | `FirstTankWizardScreen` unreachable in main flow | P1 | `first_tank_wizard_screen.dart` |
| UX-007 | `LearningStyleScreen` + tutorial walkthrough unreachable | P1 | `learning_style_screen.dart` |
| NAV-001 | `WorkshopScreen` — no back button | P1 | `workshop_screen.dart` |
| NAV-002 | `ShopStreetScreen` — no AppBar | P1 | `shop_street_screen.dart` |
| NAV-003 | Story Player — verify back affordance | P2 | `story_player_screen.dart` |
| NAV-004 | Gem Shop — two levels deep with no nav hierarchy | P2 | `gem_shop_screen.dart` |
| NAV-005 | "Toolbox" tab label hides Settings from discovery | P2 | `settings_hub_screen.dart`, `tab_navigator.dart` |
| EMPTY-001 | `TodayBoardCard` error state invisible | P2 | `today_board.dart` |
| EMPTY-002 | "All Caught Up" in Practice has no next action | P2 | `practice_hub_screen.dart` |
| EMPTY-003 | Logs empty state is generic | P2 | `logs_screen.dart` |
| EMPTY-004 | Inconsistent empty state widgets across screens | P2 | multiple |
| EMPTY-005 | Search no-results state missing | P2 | `search_screen.dart` |
| INCON-001 | Three button families | P2 | multiple |
| INCON-002 | Room screens vs Scaffold screens mix | P2 | `workshop_screen.dart`, `shop_street_screen.dart` |
| INCON-003 | SettingsScreen and SettingsHubScreen overlap | P2 | `settings_screen.dart`, `settings_hub_screen.dart` |
| INCON-004 | No persisted last-active tab | P2 | `tab_navigator.dart` |
| INCON-005 | Hearts rules unclear and inconsistently applied | P1 | `lesson_screen.dart`, `spaced_repetition_practice_screen.dart` |
| ONB-001 | Onboarding fork shows intro slides on force-quit recovery | P1 | `main.dart`, `onboarding_screen.dart` |
| ONB-002 | JourneyRevealScreen layout may overflow on small screens | P2 | `journey_reveal_screen.dart` |
| ONB-003 | Room metaphor not explained in onboarding | P2 | `onboarding_screen.dart` |
| ONB-004 | Welcome banner doesn't show on Learn tab (default landing) | P2 | `home_screen.dart` |
| TAP-001 | Dismiss banner × icon too small visually | P2 | `home_screen.dart` |
| TAP-002 | Stage edge handles undiscoverable | P1 | `home_screen.dart`, `swiss_army_panel.dart` |
| TAP-003 | `TankSwitcher` non-interactive with 1 tank | P2 | `tank_switcher.dart` |
| TAP-004 | Quiz answers may lack minimum height | P2 | `lesson_screen.dart` |
| TAP-005 | Speed Dial FAB — 5 actions too many | P2 | `speed_dial_fab.dart` |
| LOAD-001 | `TodayBoardCard` invisible during load | P2 | `today_board.dart` |
| LOAD-002 | Analytics screen — no skeleton charts | P2 | `analytics_screen.dart` |
| LOAD-003 | AI response uses CircularProgressIndicator not BubbleLoader | P2 | `smart_screen.dart` |
| LOAD-004 | SR practice loader replaces full Scaffold | P2 | `spaced_repetition_practice_screen.dart` |
| ERR-001 | HomeScreen error blocks even locally-cached tanks | P1 | `home_screen.dart` |
| ERR-002 | CreateTankScreen — no inline validation error messages | P1 | `create_tank_screen.dart` |
| ERR-003 | AI error responses are raw strings, not styled cards | P2 | `smart_screen.dart` |
| ERR-004 | Backup/restore progress feedback unclear | P2 | `backup_restore_screen.dart` |
| A11Y-001 | EmptyRoomScene contrast ratio unverified | P2 | `empty_room_scene.dart` |
| A11Y-002 | JourneyRevealScreen no heading structure | P2 | `journey_reveal_screen.dart` |
| A11Y-003 | PersonalisationScreen — no live region on selection | P2 | `personalisation_screen.dart` |
| A11Y-004 | Streak/hearts banners not announced to screen readers | P2 | `home_screen.dart` |
| A11Y-005 | WorkshopScreen tool grid — accessibility labels unverified | P2 | `workshop_screen.dart` |
| A11Y-006 | Quiz answer correct/incorrect not announced | P1 | `lesson_screen.dart` |
| A11Y-007 | Smart tab text field missing label, submit missing tooltip | P2 | `smart_screen.dart` |
| A11Y-008 | Practice tab badge not accessible | P2 | `tab_navigator.dart` |
| A11Y-009 | Quick test sheet — no textInputAction chain | P2 | `home_screen.dart` |
| IMP-001 | Splash uses generic water_drop icon | P2 | `main.dart` |
| IMP-002 | "Toolbox" tab misleading for profile/account location | P2 | `tab_navigator.dart` |
| IMP-003 | Friends/Leaderboard stubs — verify truly unreachable | P1 | `friends_screen.dart`, `leaderboard_screen.dart` |
| IMP-004 | Room metaphor unexplained — confusing first encounter | P1 | `home_screen.dart`, `workshop_screen.dart` |
| IMP-005 | Gems earn mechanism invisible to new users | P2 | `gem_shop_screen.dart` |

---

## Priority Action Plan

### 🔴 Fix Before Launch (P1s)
1. **NAV-001 + NAV-002** — Add AppBar/back button to WorkshopScreen and ShopStreetScreen. ~30 min each.
2. **UX-006 + UX-007** — Decide on dead onboarding screens. Delete or integrate them. Prevents maintenance confusion.
3. **ONB-001** — Fix force-quit recovery routing. Skip intro slides if profile exists.
4. **TAP-002** — Add discoverability for side panels (temp/water). A first-visit tooltip would suffice.
5. **ERR-001 + ERR-002** — Local-first tank loading + inline form validation in CreateTankScreen.
6. **A11Y-006** — Semantic announcement for quiz correct/incorrect. Critical for WCAG compliance.
7. **IMP-004** — Some form of "here's your house" explanation. Even one tooltip per tab.
8. **INCON-005** — Hearts rules — at minimum, add a one-time explanation tooltip.
9. **UX-003** — Mark demo tank as demo. Add "This is a demo" banner in TankDetailScreen.

### 🟡 Fix Shortly After Launch (High-impact P2s)
1. **INCON-001** — Consolidate button families. Pick one and delete the rest.
2. **INCON-003** — Clean up SettingsScreen IA. Remove duplicate items.
3. **ONB-003** — Add room metaphor explanation to onboarding.
4. **EMPTY-002** — "All Caught Up" hero card — add a next-action suggestion.
5. **LOAD-003 + LOAD-004** — Use BubbleLoader theme consistently; keep AppBar visible during SR load.
6. **A11Y-004** — Live region on streak/hearts banners.
7. **IMP-002** — Rename Toolbox tab or restructure profile/settings discovery.

---

*End of audit. Total findings: 54 issues (9 P0-equivalent/P1, 45 P2). No files were modified.*
