# Danio — Surface Audit: Onboarding · Home · Tank · Livestock · Room/Fish
**Auditor:** Apollo (AI Design Lead)  
**Date:** 2026-03-29  
**Scope:** Exhaustive per-element, per-state audit of every screen, modal, button, CTA, and state variant across five areas.  
**Method:** Full source read of every referenced .dart file; traced every Navigator.push, showDialog, showModalBottomSheet, showAppBottomSheet, onTap, onPressed, and .when() handler.

---

## Legend

| Classification | Meaning |
|---|---|
| ✅ Complete | Working, designed, states handled |
| 🔴 Must Fix | Broken, dead, missing-critical, ships a bad experience |
| 🟠 Should Fix | Works but quality/coverage gap |
| 🟡 Research First | Needs design decision before work starts |
| 🔵 Defer | Out of scope for current milestone |
| ⚫ Future Scope | Post-MVP feature |
| 🚫 Blocked | Can't assess without runtime |

---

## Area 1 — Onboarding

**Orchestrator:** `lib/screens/onboarding_screen.dart`  
**Flow:** 10-page PageView, `NeverScrollableScrollPhysics`, purely programmatic navigation.

---

### 1.1 WelcomeScreen (`onboarding/welcome_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| WelcomeScreen | Full-bleed background image `onboarding_journey_bg.webp` | loaded, error (Container fallback) | ✅ | errorBuilder falls back to `AppColors.textPrimary` solid colour — looks fine | ✅ Complete |
| WelcomeScreen | Headline text "Your fish deserve better than guesswork." | animated fade+slide up | ✅ | Reduce-motion respected | ✅ Complete |
| WelcomeScreen | Body copy | animated fade | ✅ | Reduce-motion respected | ✅ Complete |
| WelcomeScreen | CTA "Let's get started →" | animated slide+fade | ✅ | Calls `widget.onNext()` → advance to page 1 (ExperienceLevelScreen); haptic `lightImpact()` | ✅ Complete |
| WelcomeScreen | "Skip setup, I'll explore first" TextButton | same fade animation | ✅ | Calls `widget.onLogin?.call()` → `_quickStart()` which creates default beginner profile + 60L tank + completes onboarding; haptic `selectionClick()` | ✅ Complete |
| WelcomeScreen | Bottom safe area padding | `MediaQuery.of(context).padding.bottom` | ✅ | Uses Positioned with bottomPadding | ✅ Complete |
| WelcomeScreen | Back button / pop scope | `PopScope(canPop: false)` at OnboardingScreen level | ✅ | Destructive confirm dialog before exit | ✅ Complete |
| WelcomeScreen | Progress dots | Positioned overlay at bottom of Scaffold Stack | ✅ | Active dot shown on page 0 | ✅ Complete |
| WelcomeScreen | "Skip setup" label copy | — | 🟠 | Labelled "Skip setup, I'll explore first" but actually creates a full profile and tank silently. User expectation mismatch — this IS setup, it just uses defaults. Label should be "Use default setup" or "Set up later". | 🟠 Should Fix |

---

### 1.2 ExperienceLevelScreen (`onboarding/experience_level_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| ExperienceLevelScreen | 3 tap-to-select cards (Beginner/Intermediate/Expert) | unselected, selected, pulse animation | ✅ | Pulse scale on selected, reduce-motion respected | ✅ Complete |
| ExperienceLevelScreen | "Continue" button | disabled (null `onPressed`) until selection, then active | ✅ | Calls `widget.onSelected()` → saves to `_experienceLevel` state, advance to page 2 | ✅ Complete |
| ExperienceLevelScreen | "Skip setup" TextButton | visible only when `widget.onSkip != null` | ✅ | Calls `_quickStart()` | ✅ Complete |
| ExperienceLevelScreen | SafeArea | ✅ wrapped | ✅ | — | ✅ Complete |
| ExperienceLevelScreen | Reduce motion | respected via `MediaQuery.of(context).disableAnimations` | ✅ | — | ✅ Complete |
| ExperienceLevelScreen | Cards overflow test | `NeverScrollableScrollPhysics` ListView with `Expanded` | 🟠 | On very small screens (<480px height) the Continue button may be pushed off screen because the cards are in `Expanded` + non-scrollable ListView. No scroll fallback. | 🟠 Should Fix |

---

### 1.3 TankStatusScreen (`onboarding/tank_status_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| TankStatusScreen | 3 tap-to-select cards (Planning/Cycling/Active) | unselected, selected | ✅ | Same pattern as ExperienceLevelScreen | ✅ Complete |
| TankStatusScreen | "Continue" button | disabled until selection | ✅ | Calls `widget.onSelected()` → saves `_tankStatus`, advance to page 3 | ✅ Complete |
| TankStatusScreen | No back/skip button | intentional — PageView back is via hardware/OS | 🟠 | User has no visible back button to go to previous step. Onboarding PageView doesn't expose a back CTA on any step after page 0. Accessibility/discoverability gap. | 🟠 Should Fix |
| TankStatusScreen | SafeArea | ✅ | ✅ | — | ✅ Complete |

---

### 1.4 MicroLessonScreen (`onboarding/micro_lesson_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| MicroLessonScreen | Lesson badge "Quick Lesson · 30 seconds" | static | ✅ | — | ✅ Complete |
| MicroLessonScreen | Headline + body paragraphs | beginner vs expert variant | ✅ | Content switches on `_isAdvanced` | ✅ Complete |
| MicroLessonScreen | 3 answer tiles (tap to select) | unselected, answered-correct (green), answered-wrong (grey strikethrough), answered-other (dim) | ✅ | Full feedback states, bounce animation on correct | ✅ Complete |
| MicroLessonScreen | Answer tiles after answering | `!_answered` guard — taps disabled once answered | ✅ | — | ✅ Complete |
| MicroLessonScreen | Feedback text | appears after answering, correct vs wrong branch | ✅ | — | ✅ Complete |
| MicroLessonScreen | "Got it →" button | hidden until answered (slide+fade), `onPressed` only active when `_answered` | ✅ | Calls `widget.onComplete()` → advance to page 4 | ✅ Complete |
| MicroLessonScreen | ScrollView | `SingleChildScrollView` wraps all content | ✅ | No overflow risk | ✅ Complete |
| MicroLessonScreen | SafeArea | ✅ | ✅ | — | ✅ Complete |
| MicroLessonScreen | Reduce motion | ✅ respected | ✅ | — | ✅ Complete |

---

### 1.5 XpCelebrationScreen (`onboarding/xp_celebration_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| XpCelebrationScreen | Confetti burst (CustomPainter) | animated 800ms, reduce-motion skip | ✅ | — | ✅ Complete |
| XpCelebrationScreen | +10 XP badge (spring scale pop) | animated, reduce-motion skip | ✅ | — | ✅ Complete |
| XpCelebrationScreen | Progress bar fill 0→10% | animated 600ms | ✅ | — | ✅ Complete |
| XpCelebrationScreen | "First lesson complete 🎣" text + body | fade in | ✅ | — | ✅ Complete |
| XpCelebrationScreen | "Add my fish →" CTA | slide+fade, then calls `widget.onNext()` → page 5 (FishSelectScreen) | ✅ | haptic `mediumImpact()` | ✅ Complete |
| XpCelebrationScreen | SafeArea | ✅ | ✅ | — | ✅ Complete |
| XpCelebrationScreen | Confetti colour `Color(0xFFFFD54F)` | hardcoded non-token value | 🟠 | One confetti colour uses raw hex, not an AppColors token. Minor but breaks colour management. | 🟠 Should Fix |

---

### 1.6 FishSelectScreen (`onboarding/fish_select_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| FishSelectScreen | Search bar (TextField) | empty, typing, results, no results | ✅ | Clear button appears while searching; "No species found" empty state | ✅ Complete |
| FishSelectScreen | Popular grid (3-col) | default state, selected tile (amber border + check) | ✅ | 12 hardcoded popular species; falls back to emoji if sprite missing | ✅ Complete |
| FishSelectScreen | Search results list | results state, empty state | ✅ | AnimatedSwitcher between grid and list | ✅ Complete |
| FishSelectScreen | Species tile / search card tap | calls `_selectFish()` → stores `_selectedFish`, shows bottom tray | ✅ | haptic `selectionClick()` | ✅ Complete |
| FishSelectScreen | Bottom tray slide-in | animated spring (easeOutBack), shows fish name + CTA | ✅ | — | ✅ Complete |
| FishSelectScreen | "This is my fish →" CTA button | calls `_confirmSelection()` → `widget.onFishSelected()` → saves `_selectedFish`, advance to page 6 | ✅ | Pulse animation while tray is open | ✅ Complete |
| FishSelectScreen | Bottom tray bottom spacing | hardcoded `AppSpacing.lg` — no SafeArea | 🔴 | Bottom tray has no `bottomPadding` from MediaQuery. On devices with home indicator (iPhone X+, Android nav bar), the "This is my fish →" button may be hidden behind the system navigation gesture bar. | 🔴 Must Fix |
| FishSelectScreen | Sprite fallback | emoji fallback with amber circle background | ✅ | — | ✅ Complete |
| FishSelectScreen | SafeArea | outer `SafeArea` on body, but bottom tray is in a `Positioned` outside SafeArea | 🔴 | See above — Positioned tray ignores bottom inset | 🔴 Must Fix |

---

### 1.7 AhaMomentScreen (`onboarding/aha_moment_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| AhaMomentScreen | Phase 1: fish circle + building dots animation | 1.8s theatrical delay, dots loop, reduce-motion skip | ✅ | — | ✅ Complete |
| AhaMomentScreen | Phase 1→2: overlay fade transition | 400ms | ✅ | — | ✅ Complete |
| AhaMomentScreen | Phase 2: 3 care cards (pH, tank mates, care level) | staggered slide-in from right | ✅ | — | ✅ Complete |
| AhaMomentScreen | Phase 3: invite text + "Start your journey →" CTA | fade in after 300ms delay | ✅ | — | ✅ Complete |
| AhaMomentScreen | "Start your journey →" CTA | disabled after tap (`_ctaTapped`), 2s silent beat then `widget.onComplete()` → advance to page 7 | ✅ | haptic `mediumImpact()` | ✅ Complete |
| AhaMomentScreen | CTA in loading state | button label changes to `'...'`, `onPressed` null | ✅ | — | ✅ Complete |
| AhaMomentScreen | ScrollView | `SingleChildScrollView` | ✅ | — | ✅ Complete |
| AhaMomentScreen | SafeArea | ✅ | ✅ | — | ✅ Complete |
| AhaMomentScreen | Fallback (if state missing) | `_OnboardingFallback` widget shown with "Go back" button | ✅ | Guarded via Builder on page 6 | ✅ Complete |
| AhaMomentScreen | `_cardSlides` uses `Transform.translate(offset: _cardSlides[index].value)` | Offset not type-safe — uses `Offset` but animation is `Animation<Offset>` | 🟠 | Uses `.value` on slide correctly but `begin: const Offset(40, 0)` means 40 LOGICAL PIXELS horizontal — intentional but not documented. | 🟠 Should Fix (comment clarity only) |

---

### 1.8 FeatureSummaryScreen (`onboarding/feature_summary_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| FeatureSummaryScreen | Fish header with bounce animation | loaded | ✅ | — | ✅ Complete |
| FeatureSummaryScreen | "Everything you need, right here." + "free to use" copy | static | ✅ | Honest messaging, no paywall | ✅ Complete |
| FeatureSummaryScreen | Feature list (4 checkmarks) | static | ✅ | — | ✅ Complete |
| FeatureSummaryScreen | "Let's go! →" CTA (bottom pinned section) | active, calls `widget.onComplete()` → advance to page 8 | ✅ | haptic `mediumImpact()` | ✅ Complete |
| FeatureSummaryScreen | `onSkip` callback | wired at OnboardingScreen but both onComplete and onSkip call `_nextPage()` | ✅ | Skip = advance, same as complete. Intentional. | ✅ Complete |
| FeatureSummaryScreen | Bottom section shadow above CTA | `BoxShadow` with `blackAlpha05` — barely visible on light bg | 🟠 | Visually very subtle; could be mistaken for a floating tray that clips content. | 🟠 Should Fix |
| FeatureSummaryScreen | SafeArea | `SafeArea(bottom: false)` on Column, bottom handled in `bottomPadding` | ✅ | — | ✅ Complete |
| FeatureSummaryScreen | Fallback (if `_selectedFish` null) | `_OnboardingFallback` shown via Builder guard on page 7 | ✅ | — | ✅ Complete |

---

### 1.9 PushPermissionScreen (`onboarding/push_permission_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| PushPermissionScreen | Illustration (water + bell icons) | float animation, reduce-motion skip | ✅ | — | ✅ Complete |
| PushPermissionScreen | "Yes, keep me informed →" CTA | active, calls `widget.onAllow()` → `_handleNotificationAllow()` (requests OS permission) → `_nextPage()` | ✅ | haptic `mediumImpact()` | ✅ Complete |
| PushPermissionScreen | "Not right now" text button | active, calls `widget.onSkip()` → `_nextPage()` | ✅ | haptic `lightImpact()` | ✅ Complete |
| PushPermissionScreen | OS permission request failure | try/catch in `_handleNotificationAllow` — always advances | ✅ | Error is logged but flow continues | ✅ Complete |
| PushPermissionScreen | Bottom padding | `MediaQuery.of(context).padding.bottom + AppSpacing.lg` | ✅ | — | ✅ Complete |
| PushPermissionScreen | SafeArea | `SafeArea(bottom: false)` | ✅ | — | ✅ Complete |
| PushPermissionScreen | Illustration semantics | `Semantics(label: '...', image: true)` | ✅ | — | ✅ Complete |
| PushPermissionScreen | Screen entry fade | 200ms on `_fadeController` | ✅ | — | ✅ Complete |

---

### 1.10 WarmEntryScreen (`onboarding/warm_entry_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| WarmEntryScreen | Name input (TextField + "Next →" button) | pre-name-submit state | ✅ | Autofocus, `textCapitalization: words`, `TextInputAction.done` → calls `_submitName()` | ✅ Complete |
| WarmEntryScreen | "Skip" text button | calls `_submitName()` with empty name | ✅ | — | ✅ Complete |
| WarmEntryScreen | "Next →" button | calls `_submitName()` | ✅ | — | ✅ Complete |
| WarmEntryScreen | Post-submit: fish care card, lesson card, XP bar, streak counter | animated sequence (fish → lesson → xp → streak) | ✅ | All animate in after `_submitName()` | ✅ Complete |
| WarmEntryScreen | Lesson card → no onTap | static card — chevron visible but no tap handler | 🔴 | The lesson card at the bottom has a `chevron_right` icon suggesting it's tappable, but there is **no `onTap` handler**. Dead UI. | 🔴 Must Fix |
| WarmEntryScreen | Full screen tap to advance | `GestureDetector(behavior: opaque, onTap: _callReady)` | ✅ | — | ✅ Complete |
| WarmEntryScreen | Auto-advance after 2.5s | `Future.delayed(2500ms, _callReady)` from `_submitName()` | ✅ | — | ✅ Complete |
| WarmEntryScreen | `_callReady()` guard | `_hasCalledReady` flag prevents double-call | ✅ | — | ✅ Complete |
| WarmEntryScreen | `onReady` → `_completeOnboarding()` | creates profile, unlocks species, awards 10 XP, creates default tank, schedules notifications, completes onboarding via service | ✅ | Error snackbar on failure | ✅ Complete |
| WarmEntryScreen | `_completeOnboarding()` error state | catch + `DanioSnackBar.error()` | ✅ | — | ✅ Complete |
| WarmEntryScreen | SafeArea | ✅ | ✅ | — | ✅ Complete |
| WarmEntryScreen | Reduce motion | via `platformDispatcher.accessibilityFeatures.disableAnimations` | ✅ | — | ✅ Complete |
| WarmEntryScreen | Greeting text `_greeting` | personalised to tankStatus + userName | ✅ | — | ✅ Complete |

---

### 1.11 ConsentScreen (`onboarding/consent_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| ConsentScreen | Age confirmation checkbox | unchecked, checked | ✅ | Whole row is tappable via `InkWell` | ✅ Complete |
| ConsentScreen | "I'm under 13" TextButton | tap → sets `under_13_blocked: true` in prefs, navigates to AgeBlockedScreen via `pushAndRemoveUntil` | ✅ | Stack fully cleared | ✅ Complete |
| ConsentScreen | ToS acceptance checkbox | unchecked, checked | ✅ | — | ✅ Complete |
| ConsentScreen | "Terms of Service" link | opens `https://tiarnanlarkin.github.io/danio/terms-of-service.html` via `url_launcher` | ✅ | — | ✅ Complete |
| ConsentScreen | "Privacy Policy" link | opens `https://tiarnanlarkin.github.io/danio/privacy-policy.html` | ✅ | — | ✅ Complete |
| ConsentScreen | "Accept Analytics" button | disabled until `_ageConfirmed && _tosAccepted`; calls `_respond(true)` | ✅ | Saves prefs, applies Firebase Crashlytics | ✅ Complete |
| ConsentScreen | "No Thanks" button | disabled until checks complete; calls `_respond(false)` | ✅ | — | ✅ Complete |
| ConsentScreen | SafeArea | ✅ | ✅ | — | ✅ Complete |
| ConsentScreen | Both buttons disabled simultaneously | no loading state while saving prefs | 🟠 | If prefs write is slow there's no spinner/loading state on either button. Low risk but worth noting. | 🟠 Should Fix |

---

### 1.12 AgeBlockedScreen (`onboarding/age_blocked_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| AgeBlockedScreen | Lock icon + title + body | static | ✅ | — | ✅ Complete |
| AgeBlockedScreen | "Privacy Policy" TextButton | opens URL via `launchUrl` | ✅ | — | ✅ Complete |
| AgeBlockedScreen | No way to proceed | `pushAndRemoveUntil` clears the stack, no back button | ✅ | COPPA compliant | ✅ Complete |
| AgeBlockedScreen | Uses raw Material theme (no AppColors) | basic styling | 🟠 | Screen uses hardcoded `Colors.grey` and raw theme fonts — not consistent with app design system | 🟠 Should Fix |

---

### 1.13 Returning User Flows (`onboarding/returning_user_flows.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Day2StreakPrompt | Flame icon with flicker animation | animated, reduce-motion skip | ✅ | — | ✅ Complete |
| Day2StreakPrompt | "Continue learning →" CTA | `Navigator.of(context).pop()` — closes dialog | ✅ | Caller decides what happens next (navigate to Learn tab) | ✅ Complete |
| Day2StreakPrompt | "Later" text button | `Navigator.of(context).pop()` | ✅ | — | ✅ Complete |
| Day2StreakPrompt | Fish name personalisation | optional `fishName` param | ✅ | — | ✅ Complete |
| Day7MilestoneCard | Gold gradient card, trophy + headline | animated XP badge pop | ✅ | — | ✅ Complete |
| Day7MilestoneCard | "+50 XP bonus" pill | scale animation | ✅ | — | ✅ Complete |
| Day7MilestoneCard | "Have you tried the tank compatibility checker?" feature nudge | `widget.onFeatureTap?.call()` → `Navigator.of(context).pop()` | 🟠 | The feature tap just pops the dialog — caller in HomeScreen does `Navigator.of(context).pop()` too, so it double-pops. No navigation to compatibility checker actually fires. | 🔴 Must Fix |
| Day30CommittedCard | Stats rows (lessons, XP) | static from passed-in values | ✅ | — | ✅ Complete |
| Day30CommittedCard | "See what's waiting for you →" OutlinedButton | calls `onUpgrade()` → in HomeScreen `Navigator.of(context).pop()` | 🔴 | Upgrade button just closes the dialog. No navigation to any upgrade/feature screen. Dead button. | 🔴 Must Fix |

---

### 1.14 OnboardingScreen (Orchestrator) — special cases

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| OnboardingScreen | Progress dots overlay | 10 dots, active dot is wider pill | ✅ | Positioned at bottom of Stack, `_currentPage` tracked | ✅ Complete |
| OnboardingScreen | `PopScope(canPop: false)` | hardware back → destructive confirm dialog | ✅ | Navigator captured before async gap | ✅ Complete |
| OnboardingScreen | Page 6/7/9 fallback | `_OnboardingFallback` with "Go back" to page 5 | ✅ | Defensive guard if state null | ✅ Complete |
| OnboardingScreen | `_quickStart()` error | catch + `DanioSnackBar.error()` | ✅ | — | ✅ Complete |
| OnboardingScreen | No visible back arrow on any step | intentional per comment | 🟠 | Users tapping hardware back get a destructive exit dialog rather than "go back one step". Onboarding should allow step-back (at least on Android). | 🟠 Should Fix |
| OnboardingScreen | Consent screen | **NOT part of the 10-page flow** — ConsentScreen is invoked separately by the app router before OnboardingScreen | ✅ | Correct architecture | ✅ Complete |
| OnboardingScreen | `_completeOnboarding` XP award error | silently catches and logs | ✅ | — | ✅ Complete |
| OnboardingScreen | `onboardingCompletedProvider` invalidation as navigation trigger | no explicit `Navigator.popUntil` | ✅ | Reactive router handles it | ✅ Complete |

---

## Area 2 — Home Screen

**Main file:** `lib/screens/home/home_screen.dart`  
**Entry point:** Tab navigator item 0.

---

### 2.1 Home Screen — Top-level states

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| HomeScreen | Loading state (tanks loading) | `SkeletonRoom` widget | ✅ | Shown while `tanksAsync.isLoading && !tanksAsync.hasValue` | ✅ Complete |
| HomeScreen | Error state (tanks failed) | `AppErrorState` with "Couldn't load your tanks" + retry button | ✅ | `onRetry: () => ref.invalidate(tanksProvider)` | ✅ Complete |
| HomeScreen | Empty state (no tanks) | `EmptyRoomScene` | ✅ | Full designed empty scene with mascot, CTA, and demo option | ✅ Complete |
| HomeScreen | Loaded state (tanks exist) | Full room scene | ✅ | — | ✅ Complete |
| HomeScreen | SafeArea | Uses `MediaQuery.of(context).padding.top` for Positioned overlays | ✅ | — | ✅ Complete |

---

### 2.2 Home Screen — Top Bar Overlay

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Home TopBar | HeartIndicator (compact) | reads `heartsStateProvider` | ✅ | — | ✅ Complete |
| Home TopBar | "Tank Toolbox" IconButton (`Icons.build_outlined`) | → `showTankToolbox(context, ref, currentTank.id)` | ✅ | Opens bottom sheet with Reminders/Journal/Analytics/Search | ✅ Complete |
| Home TopBar | "Tank Settings" IconButton (`Icons.settings_outlined`) | → `NavigationThrottle.push(TankSettingsScreen)` | ✅ | — | ✅ Complete |
| Home TopBar | Gradient scrim behind top bar | `LinearGradient` black30→transparent | ✅ | — | ✅ Complete |

---

### 2.3 Home Screen — Room Scene (`LivingRoomScene`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Room Scene | `onTankTap` | → `_navigateToTankDetail()` | ✅ | — | ✅ Complete |
| Room Scene | `onTestKitTap` | → `showWaterParams()` bottom sheet | ✅ | — | ✅ Complete |
| Room Scene | `onFoodTap` | → `showFeedingInfo()` bottom sheet | ✅ | — | ✅ Complete |
| Room Scene | `onPlantTap` | → `showPlantInfo()` bottom sheet | ✅ | — | ✅ Complete |
| Room Scene | `onStatsTap` | → `showStatsInfo()` bottom sheet | ✅ | — | ✅ Complete |
| Room Scene | `onThemeTap` | → `showThemePicker()` bottom sheet | ✅ | — | ✅ Complete |
| Room Scene | `onJournalTap` | → `NavigationThrottle.push(JournalScreen)` with `RoomSlideRoute` | ✅ | — | ✅ Complete |
| Room Scene | `onCalendarTap` | → `showStreakCalendar()` → push `StreakCalendarScreen` | ✅ | — | ✅ Complete |
| Room Scene | Stage handle strips (left = Temp, right = Water) | tap → open/close SwissArmyPanel | ✅ | Subtle edge accent lines visible when panels closed | ✅ Complete |
| Room Scene | `LightingPulseWrapper` | wraps room in ambient lighting pulse | ✅ | — | ✅ Complete |
| Room Scene | `StageScrim` | IgnorePointer when no panels open | ✅ | — | ✅ Complete |
| Room Scene | `AmbientTipOverlay` | tip overlays from stage system | ✅ | — | ✅ Complete |
| Room Scene | Demo tank banner | shows when `currentTank.isDemoTank && !_demoModeDismissed` | ✅ | Dismiss × button → sets `_demoModeDismissed = true` | ✅ Complete |
| Room Scene | `LivingRoomScene` itself (fish animations, room render) | 🚫 | — | Cannot audit fish animation states without runtime | 🚫 Blocked |

---

### 2.4 Home Screen — Banners & Overlays

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| WelcomeBanner | Personalised greeting / "dismiss on tap" | shows first time only (prefs key `has_seen_welcome_banner`) | ✅ | Auto-dismisses after 4s | ✅ Complete |
| WelcomeBanner | `AnimatedOpacity` to 0 on dismiss | ✅ | — | ✅ Complete |
| ComebackBanner | Shows when streak active + not active today/yesterday | ✅ | Dismiss × button present | ✅ Complete |
| ComebackBanner | Fish name personalisation | optional `fishSpeciesName` | ✅ | — | ✅ Complete |
| DailyNudgeBanner | Shows when `todayXp == 0` | disappears when XP earned today | ✅ | Dismiss × button | ✅ Complete |
| DailyNudgeBanner | Fish name personalisation | reads from profile | ✅ | — | ✅ Complete |
| DailyNudgeBanner | Banner positioned at `padding.top + 100` | hardcoded offset | 🟠 | Multiple banners (WelcomeBanner at `padding.top + md`, ComebackBanner at same position, DailyNudge at +100) could potentially overlap when comeback and nudge show together on first-day lapse scenario. Logic in build gates them but the vertical offsets are fragile. | 🟠 Should Fix |
| StreakHeartsOverlay | Streak banner | shows when streak > 0, dismiss × | ✅ | Persisted dismiss state via prefs | ✅ Complete |
| StreakHeartsOverlay | Low hearts banner | shows when hearts ≤ 1, dismiss × | ✅ | — | ✅ Complete |
| StreakHeartsOverlay | WcStreakBanner | shows water change streak | ✅ | Dismiss × | ✅ Complete |
| StreakHeartsOverlay | Only one banner at a time | priority: streak > low hearts > WC streak | ✅ | — | ✅ Complete |
| FirstVisitTooltips | 4 tooltips (tank, hearts, stage handles, room metaphor) | shown only once (prefs key) | ✅ | Sequential: room metaphor waits for first 3 to dismiss | ✅ Complete |
| Returning User Flows | Day2/Day7/Day30 milestone dialogs | shown via `showAppDialog` | 🔴 | Day7 and Day30 CTAs are dead (see Returning User Flows section) | 🔴 Must Fix |

---

### 2.5 Home Screen — Bottom Sheet Panel (BottomSheetPanel)

*The panel is a single `DraggableScrollableSheet` with 3 tabs: Progress, Tanks, Today*

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| BottomSheetPanel | Panel drag handle | ✅ exists | ✅ | — | ✅ Complete |
| BottomSheetPanel | **Progress tab** — `GamificationDashboard` | tap → `showStatsDetails()` bottom sheet | ✅ | — | ✅ Complete |
| BottomSheetPanel | **Tanks tab** — TankSwitcher (single tank) | no picker (single tank, no interactive) | ✅ | — | ✅ Complete |
| BottomSheetPanel | **Tanks tab** — TankSwitcher (multiple tanks) | tap → `TankPickerSheet` bottom sheet | ✅ | — | ✅ Complete |
| BottomSheetPanel | **Tanks tab** — TankSwitcher long press | triggers `_toggleSelectMode()` (multiple tanks only) | ✅ | — | ✅ Complete |
| BottomSheetPanel | **Tanks tab** — TankListTile rows | tap → `_navigateToTankDetail()` | ✅ | — | ✅ Complete |
| BottomSheetPanel | **Tanks tab** — "Add New Tank" ListTile | tap → `_navigateToCreateTank()` | ✅ | — | ✅ Complete |
| BottomSheetPanel | **Tanks tab** — SelectionModePanel | visible when `_isSelectMode` | ✅ | Cancel, Delete (confirmed), Export (→ BackupRestoreScreen) | ✅ Complete |
| BottomSheetPanel | SelectionModePanel — "Export" button | navigates to `BackupRestoreScreen` but clears selected IDs before navigating | 🟠 | The selected tank IDs are cleared before backup screen opens — backup screen has no context about which tanks were selected. Export is effectively full export, not filtered. | 🟠 Should Fix |
| BottomSheetPanel | **Today tab** — `TodayBoardCard` | loading → `SizedBox.shrink()`, error → warning chip, data → task list or empty state | ✅ | Empty state → smart CTA (Practice/Learn/Search) tapping changes tab via `currentTabProvider` | ✅ Complete |
| BottomSheetPanel | **Today tab** — task rows | static display only (no tap action on individual rows) | 🟠 | Task rows in `_TaskRow` show overdue/today status but have no `onTap` to navigate to task detail or complete the task. Users can see tasks but can't act on them from here. | 🟠 Should Fix |
| BottomSheetPanel | **Tools tab** | **NOT present in code** — `BottomSheetPanel` only has Progress/Tanks/Today | 🔴 | Task brief mentions a "Tools" tab in the bottom sheet — this does not exist. The toolbox is behind the top-bar wrench icon, not a tab. | 🟡 Research First |

---

### 2.6 Home Screen — Speed Dial FAB (RoomControlFAB)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| RoomControlFAB | "Stats" action | → `showStatsInfo()` | ✅ | — | ✅ Complete |
| RoomControlFAB | "Water Change" action | → `_navigateToWaterChange()` → `AddLogScreen(initialType: waterChange)` | ✅ | — | ✅ Complete |
| RoomControlFAB | "Feed" action | → `showFeedingInfo()` | ✅ | — | ✅ Complete |
| RoomControlFAB | "Quick Test" action | → `showQuickLogSheet()` | ✅ | — | ✅ Complete |
| RoomControlFAB | "Add Tank" action | → `_navigateToCreateTank()` | ✅ | — | ✅ Complete |
| RoomControlFAB | Hidden when `_isNavigatingToCreate` | `IgnorePointer + Opacity(0)` | ✅ | — | ✅ Complete |
| RoomControlFAB | Bottom positioning | `bottom: 130 + padding.bottom` | ✅ | — | ✅ Complete |

---

### 2.7 Home Screen — Modal Sheets (home_sheets_*)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| showWaterParams | "No test results yet" empty state | shown when `wt == null || !wt.hasValues` | ✅ | — | ✅ Complete |
| showWaterParams | Test results displayed | pH, Ammonia, Nitrite, Nitrate, last tested time | ✅ | — | ✅ Complete |
| showWaterParams | "Log Water Test" CTA | → `NavigationThrottle.push(AddLogScreen(initialType: waterTest))` | ✅ | — | ✅ Complete |
| showFeedingInfo | Fed today count, last fed time | from filtered logs | ✅ | — | ✅ Complete |
| showFeedingInfo | "Log Feeding" CTA | → `AddLogScreen(initialType: feeding)` | ✅ | — | ✅ Complete |
| showPlantInfo | Plant tips, pro tip note | static content | ✅ | No action button — intentional (plants don't have a log type) | ✅ Complete |
| showStatsInfo | Temp, last fed, water change from logs | from latest log data | ✅ | — | ✅ Complete |
| showStatsDetails | GamificationDashboard + "Daily Goal" + "Calendar" buttons | ✅ | Both buttons close sheet then re-open correct sub-sheet | ✅ Complete |
| showDailyGoalDetails | XP source list | static rows | ✅ | — | ✅ Complete |
| showStreakCalendar | → `StreakCalendarScreen` push via `RoomSlideRoute` | ✅ | — | ✅ Complete |
| showTankToolbox | Reminders → `RemindersScreen` | ✅ | `addPostFrameCallback` guard | ✅ Complete |
| showTankToolbox | Tank Journal → `JournalScreen(tankId)` | ✅ | — | ✅ Complete |
| showTankToolbox | Analytics → `AnalyticsScreen` | ✅ | — | ✅ Complete |
| showTankToolbox | Species Search → `SearchScreen` | ✅ | — | ✅ Complete |
| showQuickLogSheet | pH/temp/ammonia inputs | valid parse → save log + 10 XP + invalidate providers | ✅ | Guard: if all 3 are null, does nothing | ✅ Complete |
| showQuickLogSheet | "Save & Earn 10 XP" button | no loading state during async save | 🟠 | Button is active during save; could double-tap. No spinner. | 🟠 Should Fix |
| showThemePicker | Theme grid with colour swatches + name | all `RoomThemeType.values` | ✅ | Tap → sets theme + pops sheet | ✅ Complete |

---

### 2.8 EmptyRoomScene

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| EmptyRoomScene | Mascot `MascotAvatar(mood: waving)` | static | ✅ | — | ✅ Complete |
| EmptyRoomScene | "Create Your First Tank" CTA | → `_navigateToCreateTank()` | ✅ | — | ✅ Complete |
| EmptyRoomScene | "Explore a demo tank first" text button | → `seedDemoTankIfEmpty()` → `_navigateToTankDetail(demoTank)` | ✅ | — | ✅ Complete |
| EmptyRoomScene | Background scene | gradient + window + stand + placeholder | ✅ | Decorative, no interaction needed | ✅ Complete |
| EmptyRoomScene | `NotebookCard` with slight rotation | visual polish | ✅ | — | ✅ Complete |

---

## Area 3 — Tank Surfaces

---

### 3.1 CreateTankScreen (`screens/create_tank_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| CreateTankScreen | AppBar "New Tank" + close (×) button | close → `Navigator.maybePop()` | ✅ | — | ✅ Complete |
| CreateTankScreen | PopScope back gesture | asks destructive confirm if `_hasUnsavedData` | ✅ | `_hasUnsavedData` = name not empty OR volume > 0 OR page > 0 | ✅ Complete |
| CreateTankScreen | LinearProgressIndicator (step 1/2/3 of 3) | reads `_currentPage + 1 / 3` | ✅ | Semantic label provided | ✅ Complete |
| CreateTankScreen | **Page 1 (BasicInfoPage)** — Tank name TextFormField | empty invalid, typed valid, max 50 chars enforced | ✅ | — | ✅ Complete |
| CreateTankScreen | **Page 1** — Tank type selector (Freshwater / Marine) | Freshwater selectable; Marine shows info snackbar and stays on Freshwater | ✅ | Marine card visually looks disabled but is still tappable (shows info vs selecting) | 🟠 Should Fix |
| CreateTankScreen | "Next" button | disabled when `!_canProceed()` (page 0 = name empty); active otherwise | ✅ | — | ✅ Complete |
| CreateTankScreen | **Page 2 (SizePage)** — Volume TextFormField | validates ≥1L and ≤10000L | ✅ | — | ✅ Complete |
| CreateTankScreen | **Page 2** — Dimension fields (L/W/H, optional) | nullable doubles, no validation | ✅ | — | ✅ Complete |
| CreateTankScreen | **Page 2** — Quick presets (20L/60L/120L/200L/300L) | ActionChips, tap → sets volume | ✅ | — | ✅ Complete |
| CreateTankScreen | **Page 2** — Volume preset taps don't update the text field controller | `_volumeController` in SizePage has `didUpdateWidget` sync | ✅ | — | ✅ Complete |
| CreateTankScreen | **Page 3 (WaterTypePage)** — Tropical/Coldwater options | both selectable | ✅ | — | ✅ Complete |
| CreateTankScreen | **Page 3** — Start date picker | `showDatePicker` dialog; first date 2020, last date today | ✅ | — | ✅ Complete |
| CreateTankScreen | **Page 3** — "Set to today" button | `AppButtonVariant.text` | ✅ | — | ✅ Complete |
| CreateTankScreen | "Create Tank" button | disabled while `_isCreating`; loading spinner shown | ✅ | — | ✅ Complete |
| CreateTankScreen | Tank creation success | XP award, XP animation, achievement check, success snackbar, pop, celebration overlay for first/second tank | ✅ | — | ✅ Complete |
| CreateTankScreen | Tank creation error | `AppFeedback.showError()` with retry callback | ✅ | — | ✅ Complete |
| CreateTankScreen | "Back" button (page 2/3 only) | → `_previousPage()` | ✅ | — | ✅ Complete |
| CreateTankScreen | Keyboard dismissal | `GestureDetector(onTap: FocusManager.unfocus)` | ✅ | — | ✅ Complete |

---

### 3.2 TankDetailScreen (`screens/tank_detail/tank_detail_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| TankDetailScreen | Loading state | `BubbleLoader.large(message: 'Loading tank...')` | ✅ | — | ✅ Complete |
| TankDetailScreen | Error state (tank failed to load) | `AppErrorState` + retry | ✅ | — | ✅ Complete |
| TankDetailScreen | Null tank state (deleted/not found) | custom "Tank not found" message + "Go Back" button | ✅ | — | ✅ Complete |
| TankDetailScreen | AppBar — Hero gradient header | Hero tag `tank-card-${tank.id}` | ✅ | — | ✅ Complete |
| TankDetailScreen | AppBar — Checklist icon | → `MaintenanceChecklistScreen` | ✅ | — | ✅ Complete |
| TankDetailScreen | AppBar — Gallery icon | → `PhotoGalleryScreen` | ✅ | — | ✅ Complete |
| TankDetailScreen | AppBar — Journal icon | → `JournalScreen(tankId)` | ✅ | — | ✅ Complete |
| TankDetailScreen | AppBar — Charts icon | → `ChartsScreen(tankId)` | ✅ | — | ✅ Complete |
| TankDetailScreen | AppBar — More menu (⋮) | Compare Tanks / Cost Tracker / Estimate Value / Tank Settings / Delete Tank | ✅ | All items navigate correctly | ✅ Complete |
| TankDetailScreen | Demo tank banner | tap → `CreateTankScreen` | ✅ | — | ✅ Complete |
| TankDetailScreen | Pull-to-refresh | invalidates tank, logs, livestock, equipment, tasks providers | ✅ | — | ✅ Complete |
| TankDetailScreen | QuickStats card | loaded, loading, error (inline warning) | ✅ | — | ✅ Complete |
| TankDetailScreen | TankHealthCard | loaded, loading skeleton, error (inline warning) | ✅ | — | ✅ Complete |
| TankDetailScreen | Action buttons (Log Test / Water Change / Add Note) | each → `AddLogScreen(initialType: ...)` | ✅ | Animated fade+slideY | ✅ Complete |
| TankDetailScreen | LatestSnapshotCard | loading skeleton, error (inline warning), data | ✅ | — | ✅ Complete |
| TankDetailScreen | TrendsRow | loading skeleton, error, data; tap trend → `ChartsScreen(initialParam: ...)` | ✅ | — | ✅ Complete |
| TankDetailScreen | AlertsCard | loading skeleton, error, data | ✅ | — | ✅ Complete |
| TankDetailScreen | CyclingStatusCard | not shown while loading; error inline; data → tap → `CyclingAssistantScreen` | ✅ | Only shown for tanks < 90 days old (implied by card logic) | ✅ Complete |
| TankDetailScreen | DanioDailyCard | static content | ✅ | — | ✅ Complete |
| TankDetailScreen | Tasks section header + "View All" → `TasksScreen` | ✅ | Pending task count badge | ✅ Complete |
| TankDetailScreen | Task skeleton | `Skeletonizer` list | ✅ | — | ✅ Complete |
| TankDetailScreen | TaskPreview — complete button | `_completeTask()` — saves completed task + log, updates equipment if applicable, success haptic+feedback | ✅ | — | ✅ Complete |
| TankDetailScreen | Recent Activity section header + "View All" → `LogsScreen` | ✅ | — | ✅ Complete |
| TankDetailScreen | LogsList — tap log → `LogDetailScreen` | ✅ | — | ✅ Complete |
| TankDetailScreen | Livestock section header + count + "View All" → `LivestockScreen` | ✅ | — | ✅ Complete |
| TankDetailScreen | LivestockPreview | loading skeleton, error, data | ✅ | — | ✅ Complete |
| TankDetailScreen | StockingIndicator | only shown when livestock not empty | ✅ | — | ✅ Complete |
| TankDetailScreen | Equipment section header + "View All" → `EquipmentScreen` | ✅ | — | ✅ Complete |
| TankDetailScreen | EquipmentPreview | loading skeleton, error, data | ✅ | — | ✅ Complete |
| TankDetailScreen | QuickAddFAB | water test / water change / observation → `AddLogScreen`; feeding → `_quickLogFeeding()` | ✅ | Feeding quick-logs without dialog | ✅ Complete |
| TankDetailScreen | Delete Tank (⋮ > Delete) | destructive confirm dialog → soft delete with 5s undo snackbar | ✅ | Pre-captures Navigator before async gap | ✅ Complete |
| TankDetailScreen | InlineWarning pattern | consistent across all sections | ✅ | Warning chip `Icons.info_outline` colour is `AppColors.warning` | ✅ Complete |
| TankDetailScreen | Stocking indicator missing for empty tank | `if (livestock.isEmpty) return SizedBox.shrink()` | ✅ | — | ✅ Complete |

---

### 3.3 TankSettingsScreen (`screens/tank_settings_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| TankSettingsScreen | Loading state | `BubbleLoader` | ✅ | — | ✅ Complete |
| TankSettingsScreen | Error state | "Couldn't load tank settings" text | 🟠 | Error state is just a plain `Text` — no retry button, no AppErrorState widget. | 🟠 Should Fix |
| TankSettingsScreen | Null tank state | "Tank not found" text | 🟠 | Same — plain Text, no action. | 🟠 Should Fix |
| TankSettingsScreen | Tank name field | validates non-empty, max length | ✅ | — | ✅ Complete |
| TankSettingsScreen | Tank type dropdown | Freshwater/Marine; Marine blocked with info toast | ✅ | — | ✅ Complete |
| TankSettingsScreen | Volume field | validates > 0 | ✅ | — | ✅ Complete |
| TankSettingsScreen | Dimension fields (optional) | nullable | ✅ | — | ✅ Complete |
| TankSettingsScreen | Water type selector (Tropical/Coldwater) | inferred from current `targets` | ✅ | — | ✅ Complete |
| TankSettingsScreen | Start date picker | `showDatePicker` | ✅ | — | ✅ Complete |
| TankSettingsScreen | Notes field | multi-line text | ✅ | — | ✅ Complete |
| TankSettingsScreen | "Save" AppBar button | disabled while `_isSaving`, loading state | ✅ | — | ✅ Complete |
| TankSettingsScreen | Save error | `AppFeedback.showError()` | ✅ | — | ✅ Complete |
| TankSettingsScreen | PopScope back | if unsaved changes → `_showUnsavedChangesDialog` | ✅ | — | ✅ Complete |
| TankSettingsScreen | `_initialized` flag pattern | local state initialised from tank data | 🟠 | `_initialized` checked in `build()` — state re-initialised on every widget rebuild when `_initialized = false`. Could cause resetting in-flight edits if provider re-emits before first save. | 🟡 Research First |

---

### 3.4 TankComparisonScreen (`screens/tank_comparison_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| TankComparisonScreen | Loading state | `BubbleLoader` | ✅ | — | ✅ Complete |
| TankComparisonScreen | Error state | `AppErrorState` with retry | ✅ | — | ✅ Complete |
| TankComparisonScreen | < 2 tanks state | empty state with "Need at Least 2 Tanks" message | ✅ | — | ✅ Complete |
| TankComparisonScreen | Tank selectors (2 dropdowns) | each excludes the other tank | ✅ | — | ✅ Complete |
| TankComparisonScreen | Comparison table (Basic Info section) | Name, Volume, Type | ✅ | — | ✅ Complete |
| TankComparisonScreen | Only "Basic Info" section exists | no water params, livestock count, health score comparison | 🔴 | The comparison screen only shows 3 static fields: Name, Volume, Type. No water parameter comparison, no livestock count, no last activity, no health score. The screen is a placeholder. | 🔴 Must Fix |
| TankComparisonScreen | No live data beyond static tank fields | logs, livestock, tasks not loaded | 🔴 | Linked from Tank Detail "Compare Tanks" item — users expecting a meaningful comparison will find almost nothing. | 🔴 Must Fix |

---

## Area 4 — Livestock Surfaces

---

### 4.1 LivestockScreen (`screens/livestock/livestock_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| LivestockScreen | Loading state | `_buildSkeletonList()` with `Skeletonizer` | ✅ | — | ✅ Complete |
| LivestockScreen | Error state | `AppErrorState` with retry | ✅ | — | ✅ Complete |
| LivestockScreen | Empty state | `EmptyState.withMascot()` — mascot, title, message, "Add Livestock" CTA, tips list | ✅ | Full designed empty state | ✅ Complete |
| LivestockScreen | Summary card (total count, species count, "Feed" button) | non-select mode only | ✅ | — | ✅ Complete |
| LivestockScreen | "Feed" button in summary card | → `_quickFeed()` (logs feeding entry + XP) | ✅ | — | ✅ Complete |
| LivestockScreen | `LivestockLastFedInfo` | shows last fed time | ✅ | — | ✅ Complete |
| LivestockScreen | AppBar — "Add livestock" popup | → `_showAddDialog()` → `LivestockAddDialog` bottom sheet | ✅ | — | ✅ Complete |
| LivestockScreen | AppBar — "Bulk add" popup | → `_showBulkAddDialog()` → `LivestockBulkAddDialog` | ✅ | — | ✅ Complete |
| LivestockScreen | AppBar — "Select multiple" | → `_toggleSelectMode()` | ✅ | — | ✅ Complete |
| LivestockScreen | `LivestockCard` — tap (normal mode) | → `LivestockDetailScreen(livestock: l)` | ✅ | — | ✅ Complete |
| LivestockScreen | `LivestockCard` — tap (select mode) | → `_toggleLivestockSelection()` | ✅ | — | ✅ Complete |
| LivestockScreen | `LivestockCard` — edit | → `_showEditDialog()` | ✅ | — | ✅ Complete |
| LivestockScreen | `LivestockCard` — delete | → `_confirmDelete()` + soft delete with undo snackbar | ✅ | — | ✅ Complete |
| LivestockScreen | Selection mode — "Select All" / "Clear" toggle | ✅ | — | ✅ Complete |
| LivestockScreen | Bulk delete | destructive confirm → soft delete each ID | ✅ | — | ✅ Complete |
| LivestockScreen | Bulk move to tank | shows available tanks dialog → `bulkMoveLivestock()` | ✅ | — | ✅ Complete |
| LivestockScreen | FAB (add) | hidden in select mode | ✅ | — | ✅ Complete |
| LivestockScreen | Refresh indicator | `invalidate(livestockProvider)` | ✅ | — | ✅ Complete |
| LivestockScreen | `LivestockCard` — compatibility badge | surfaced via card's built-in logic | ✅ | See `livestock_compatibility_check.dart` exports `LivestockCard` | ✅ Complete |

---

### 4.2 LivestockAddDialog (also Edit via same dialog) (`screens/livestock/livestock_add_dialog.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| LivestockAddDialog | Common name TextField | typing → `SpeciesDatabase.search()` autocomplete (≥2 chars), max 5 suggestions | ✅ | — | ✅ Complete |
| LivestockAddDialog | Autocomplete suggestion tap | fills name + scientific name fields, clears suggestions | ✅ | — | ✅ Complete |
| LivestockAddDialog | Scientific name TextField | pre-filled if species selected | ✅ | — | ✅ Complete |
| LivestockAddDialog | Count TextField | number input, defaults to 1 | ✅ | — | ✅ Complete |
| LivestockAddDialog | Save button | disabled while `_isSaving` | ✅ | — | ✅ Complete |
| LivestockAddDialog | Save success | creates livestock entry, awards XP, XP animation, closes sheet | ✅ | — | ✅ Complete |
| LivestockAddDialog | Save error | `AppFeedback.showError()` | ✅ | — | ✅ Complete |
| LivestockAddDialog | Edit mode (`existing != null`) | pre-fills all fields, shows "Save Changes" instead of "Add" | ✅ | — | ✅ Complete |
| LivestockAddDialog | Count < 1 validation | validated before save | 🟠 | Count field is a TextEditingController with no validator — count of 0 or negative would be caught only by parse logic in save, not inline on field. | 🟠 Should Fix |

---

### 4.3 LivestockBulkAddDialog (`screens/livestock/livestock_bulk_add_dialog.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| LivestockBulkAddDialog | Free-text input | parsing updates preview in real-time | ✅ | — | ✅ Complete |
| LivestockBulkAddDialog | Parse formats | "Neon Tetra, 10", "10 Neon Tetra", "Neon Tetra x10" | ✅ | — | ✅ Complete |
| LivestockBulkAddDialog | Parse error display | `_parseError` shown as inline text | ✅ | — | ✅ Complete |
| LivestockBulkAddDialog | Preview list | shows parsed items before save | ✅ | — | ✅ Complete |
| LivestockBulkAddDialog | "Add All" / save button | saves each item, awards XP | ✅ | — | ✅ Complete |
| LivestockBulkAddDialog | Save error | `AppFeedback.showError()` | ✅ | — | ✅ Complete |
| LivestockBulkAddDialog | Empty input state | no preview, disabled save | ✅ | — | ✅ Complete |

---

### 4.4 Livestock Detail Screen (`screens/livestock_detail_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| LivestockDetailScreen | Header card (count, name, species) | Hero animation `livestock-{id}` | ✅ | — | ✅ Complete |
| LivestockDetailScreen | Compatibility card | loaded, loading (`SizedBox.shrink()`), error (inline warning) | ✅ | Shows `CompatibilityLevel` + issues list | ✅ Complete |
| LivestockDetailScreen | Species not in DB | `_NoSpeciesDataCard` shown | ✅ | — | ✅ Complete |
| LivestockDetailScreen | Care guide card (if species found) | static from `SpeciesInfo` | ✅ | — | ✅ Complete |
| LivestockDetailScreen | Parameters card | pH range, temp, etc. | ✅ | — | ✅ Complete |
| LivestockDetailScreen | Compatibility notes card | avoid-with list | ✅ | — | ✅ Complete |
| LivestockDetailScreen | No edit/delete from detail screen | no actions in AppBar | 🟠 | Users browsing a species' detail can't edit or delete from here — must go back to the list. Missing action button. | 🟠 Should Fix |
| LivestockDetailScreen | AppBar back | standard `Navigator.pop()` | ✅ | — | ✅ Complete |

---

### 4.5 LivestockValueScreen (`screens/livestock_value_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| LivestockValueScreen | Loading state | `BubbleLoader` | ✅ | — | ✅ Complete |
| LivestockValueScreen | Error state | `AppErrorState` with retry | ✅ | — | ✅ Complete |
| LivestockValueScreen | Empty state | centre message + fish icon | ✅ | — | ✅ Complete |
| LivestockValueScreen | Currency selector (£/$/€/¥) | `PopupMenuButton` in AppBar | ✅ | — | ✅ Complete |
| LivestockValueScreen | Per-animal price TextFields | `_prices` map keyed by livestock.id | ✅ | — | ✅ Complete |
| LivestockValueScreen | Total value card | recalculates on every price change | ✅ | — | ✅ Complete |
| LivestockValueScreen | Info card (insurance/selling copy) | static | ✅ | — | ✅ Complete |
| LivestockValueScreen | "Tips for Accurate Valuation" section | static tips list | ✅ | — | ✅ Complete |
| LivestockValueScreen | No share/export button | users can't export the estimate | 🟡 | A share button would complete the use case — but no design decision yet | 🟡 Research First |

---

## Area 5 — Room/Fish Surfaces

---

### 5.1 ThemeGalleryScreen (`screens/theme_gallery_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| ThemeGalleryScreen | Collapsing SliverAppBar with current theme preview | pinned, expanded 280px | ✅ | — | ✅ Complete |
| ThemeGalleryScreen | Free themes grid (2 columns) | all `RoomThemeType.values` | ✅ | Tap → `setTheme()` + success snackbar | ✅ Complete |
| ThemeGalleryScreen | Selected theme indicator | border/checkmark on selected card | ✅ | — | ✅ Complete |
| ThemeGalleryScreen | Premium themes section header | "ARRIVING SOON" gold badge | ✅ | — | ✅ Complete |
| ThemeGalleryScreen | Premium theme placeholders | locked state cards | ✅ | — | ✅ Complete |
| ThemeGalleryScreen | Premium theme tap | shows "coming soon" info dialog | ✅ | — | ✅ Complete |
| ThemeGalleryScreen | ThemeGalleryScreen not reachable from Home | `showThemePicker()` in `home_sheets_theme.dart` opens an inline bottom sheet — the full `ThemeGalleryScreen` is **not linked from anywhere in the current navigation** | 🔴 | `ThemeGalleryScreen` is an orphaned screen. The home theme picker sheet is separate and simpler. This screen is unreachable unless directly pushed. | 🔴 Must Fix |

---

### 5.2 Room Selection / Theme Picker (inline bottom sheet via `showThemePicker`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Theme Picker Sheet | Room theme `Wrap` grid | all `RoomThemeType.values` | ✅ | — | ✅ Complete |
| Theme Picker Sheet | Selected theme highlight | thick border + accent colour | ✅ | — | ✅ Complete |
| Theme Picker Sheet | Theme tile tap | `roomThemeProvider.setTheme()` + pops sheet | ✅ | — | ✅ Complete |
| Theme Picker Sheet | "View all themes" / link to ThemeGalleryScreen | **missing** | 🔴 | No link from the picker sheet to the full ThemeGalleryScreen. Premium themes and "arriving soon" content invisible from main UX. | 🔴 Must Fix |

---

### 5.3 Fish Tap Interactions (LivingRoomScene)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Fish tap | `onTankTap` | → `_navigateToTankDetail()` | ✅ | — | ✅ Complete |
| Fish tap | Individual fish animations | 🚫 | — | Cannot verify without runtime; `LivingRoomScene` internal fish sprite animations not audited from source | 🚫 Blocked |
| Fish tap | Empty room (no tank) | `EmptyRoomScene` | ✅ | Full designed scene | ✅ Complete |

---

### 5.4 SkeletonRoom (`home/widgets/skeleton_room.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| SkeletonRoom | Loading placeholder during tank fetch | shown while `tanksAsync.isLoading && !tanksAsync.hasValue` | ✅ | — | ✅ Complete |

---

## Summary — Issues by Classification

### 🔴 Must Fix (9 items)

| # | Screen | Issue |
|---|---|---|
| 1 | FishSelectScreen | Bottom tray missing bottom safe area padding — CTA hidden behind home indicator on modern devices |
| 2 | WarmEntryScreen | Lesson card has visible chevron but no `onTap` handler — dead UI |
| 3 | Day7MilestoneCard (returning_user_flows) | Feature nudge tap double-pops and never navigates to compatibility checker |
| 4 | Day30CommittedCard (returning_user_flows) | "See what's waiting" upgrade button just closes dialog — no destination |
| 5 | TankComparisonScreen | Only 3 static fields (Name/Volume/Type) — placeholder screen, not a real comparison |
| 6 | TankComparisonScreen | No live data (logs, livestock, health score) loaded |
| 7 | ThemeGalleryScreen | Orphaned screen — not linked from anywhere in current navigation |
| 8 | Theme Picker Sheet | No "View all themes" link to ThemeGalleryScreen |
| 9 | BottomSheetPanel (Home) | No "Tools" tab exists — task brief references one that doesn't exist in code |

---

### 🟠 Should Fix (15 items)

| # | Screen | Issue |
|---|---|---|
| 1 | WelcomeScreen | "Skip setup, I'll explore first" label misleading — actually runs full default setup |
| 2 | ExperienceLevelScreen | Cards in non-scrollable Expanded list may overflow on small screens |
| 3 | TankStatusScreen | No visible "Back" button — only hardware back available |
| 4 | XpCelebrationScreen | One confetti colour uses raw hex `0xFFFFD54F` not an AppColors token |
| 5 | OnboardingScreen | Hardware back shows destructive exit dialog instead of stepping back one page |
| 6 | ConsentScreen | No loading state on "Accept"/"No Thanks" buttons while prefs save |
| 7 | AgeBlockedScreen | Uses hardcoded `Colors.grey` and default theme fonts — inconsistent with design system |
| 8 | FeatureSummaryScreen | Bottom section shadow barely visible — could look like broken layout |
| 9 | DailyNudgeBanner | Multiple banner vertical offsets are hardcoded/fragile — potential overlap |
| 10 | TankSettingsScreen | Error and null states use plain `Text` with no retry action |
| 11 | TankSettingsScreen | `_initialized` flag could reset in-flight edits on provider re-emit |
| 12 | LivestockAddDialog | Count field has no inline validator for < 1 |
| 13 | LivestockDetailScreen | No edit/delete action from detail screen — forces navigation back to list |
| 14 | SelectionModePanel export | Clears selected IDs before opening backup — loses context of selection |
| 15 | BottomSheetPanel Today tab | Task rows have no `onTap` — can't act on tasks from Today view |
| 16 | showQuickLogSheet | "Save & Earn 10 XP" has no loading state — double-tap risk |

---

### 🟡 Research First (3 items)

| # | Screen | Issue |
|---|---|---|
| 1 | BottomSheetPanel | Audit spec mentions a "Tools" tab — decide: add it, or remove it from spec |
| 2 | TankSettingsScreen | `_initialized` pattern — decide if re-init on re-emit is acceptable |
| 3 | LivestockValueScreen | Share/export estimate — decide if this is in scope |

---

### 🚫 Blocked (2 items)

| # | Screen | Issue |
|---|---|---|
| 1 | LivingRoomScene fish animations | Cannot audit fish sprite tap interactions without runtime |
| 2 | LivingRoomScene empty room scene composition | Visual accuracy of room scene requires runtime |

---

## Key Wins (things that are solid)

- **Onboarding flow orchestration** — `_OnboardingFallback` guards prevent blank screens on missing state; reactive router handles transitions cleanly.
- **Onboarding animation quality** — Reduce-motion respected on every screen; all controllers properly disposed.
- **Consent + COPPA compliance** — `AgeBlockedScreen` locks the app correctly; two required checkboxes gated behind both buttons.
- **Tank Detail Screen** — Comprehensive state handling: loading skeletons, inline error chips, null tank, pull-to-refresh, soft delete with undo.
- **Livestock Screen** — Full CRUD with selection mode, bulk move, bulk delete, and a well-designed empty state.
- **Empty Room Scene** — Fully designed with mascot, tip callout, and demo tank option.
- **Banner management** — StreakHeartsOverlay correctly shows only one banner at a time, with individual dismissal and persist-dismiss state.
- **Home FAB actions** — All 5 speed dial actions wire to correct destinations.
- **All home sheet CTAs** — Every sheet's primary CTA navigates to the correct destination with consistent error handling.
