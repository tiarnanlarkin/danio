# UI Perfection Audit — Part 2: Smart, Settings, Secondary Screens

**Auditor:** Athena (Senior UI/UX Review)
**Date:** 2026-02-28
**Scope:** Smart Hub (AI), Settings Hub, Community, Content, Tools, Onboarding, Celebrations & Gamification

---

## Table of Contents

1. [Smart Screen (AI Hub)](#1-smart-screen-ai-hub)
2. [Fish ID Screen](#2-fish-id-screen)
3. [Symptom Triage Screen](#3-symptom-triage-screen)
4. [Weekly Plan Screen](#4-weekly-plan-screen)
5. [Anomaly Card](#5-anomaly-card)
6. [Settings Hub Screen](#6-settings-hub-screen)
7. [Settings Screen (Preferences)](#7-settings-screen-preferences)
8. [Account Screen](#8-account-screen)
9. [Backup & Restore Screen](#9-backup--restore-screen)
10. [About Screen](#10-about-screen)
11. [Friends Screen](#11-friends-screen)
12. [Friend Comparison Screen](#12-friend-comparison-screen)
13. [Leaderboard Screen](#13-leaderboard-screen)
14. [Species Browser Screen](#14-species-browser-screen)
15. [Plant Browser Screen](#15-plant-browser-screen)
16. [Achievements Screen](#16-achievements-screen)
17. [Search Screen](#17-search-screen)
18. [Workshop Screen](#18-workshop-screen)
19. [Compatibility Checker](#19-compatibility-checker)
20. [Stocking Calculator](#20-stocking-calculator)
21. [Cost Tracker](#21-cost-tracker)
22. [Wishlist Screen](#22-wishlist-screen)
23. [Enhanced Onboarding Screen](#23-enhanced-onboarding-screen)
24. [Profile Creation Screen](#24-profile-creation-screen)
25. [Enhanced Placement Test](#25-enhanced-placement-test)
26. [Confetti Overlay](#26-confetti-overlay)
27. [Level Up Overlay](#27-level-up-overlay)
28. [Gamification Dashboard](#28-gamification-dashboard)
29. [XP Progress Bar](#29-xp-progress-bar)
30. [Streak Calendar](#30-streak-calendar)
31. [Achievement Unlocked Dialog](#31-achievement-unlocked-dialog)
32. [Priority Matrix](#priority-matrix)

---

## 1. Smart Screen (AI Hub)

### Smart Screen
**File:** `lib/screens/smart_screen.dart`
**Current state:** Competent hub screen with feature cards, recent AI history, and status indicators. Clean but lacks the premium wow-factor that makes AI features feel exciting.
**Score:** 6.5/10

**Issues:**
1. **Line 30 — Emoji in AppBar title** (`'🧠 Smart'`) — Emojis in titles look cheap on both platforms. Use a proper icon or just text. — **Fix:** `title: const Text('Smart')` with an `Icon(Icons.auto_awesome)` as a `leading` or use a custom styled title widget.
2. **Lines 36-38 — Offline banner is bland** — The `_OfflineBanner` shows a robot emoji and generic text. For a premium AI hub, this should feel like a teaser, not a dead-end. — **Fix:** Add a gradient background, a Lottie animation of a brain/neural network, and a "Notify me when ready" CTA.
3. **Lines 41-42 — Usage chip lacks context** — "$N AI calls this month" means nothing to most users. Is that a lot? Are they running out? — **Fix:** Show as a progress bar against a limit, or remove entirely if there's no limit. If unlimited, show "✨ Unlimited AI" as a premium badge.
4. **Lines 45-77 — Feature cards all look identical** — Same layout, different colors. This is a list, not a compelling showcase. Premium AI apps (ChatGPT, Gemini) use hero cards or animated previews. — **Fix:** Make the first feature (Fish ID) a hero card with a large image preview area. Vary card sizes to create visual hierarchy.
5. **Lines 45-77 — Staggered animation is too subtle** — `slideX(begin: 0.05)` is barely perceptible. — **Fix:** Increase to `begin: 0.15` or use `slideY` for a more natural top-down cascade.
6. **Lines 88-95 — "Recent AI Activity" section is a flat list** — Dense `ListTile`s with no visual personality. — **Fix:** Use timeline-style cards with colored left borders per interaction type. Add relative time badges.
7. **Line 100 — `_AquariumTipCard` feels filler** — A random tip at the bottom of an AI screen doesn't belong here. It dilutes the AI brand. — **Fix:** Move to the Home screen. Replace with an "AI Suggestions" card that shows proactive anomaly checks or maintenance reminders.

**Enhancements:**
1. **Premium AI header** — Add an animated gradient banner at the top with a neural network or water-themed AI illustration. Shows the AI is "alive." — *Effort: Medium (1-2 days)*
2. **Feature card previews** — Each card could show a tiny preview of its last result (e.g., last identified fish photo thumbnail, last diagnosis summary). — *Effort: Medium (2-3 days)*
3. **Proactive AI card** — "Your ammonia spiked 2 days ago — want me to diagnose?" Card that connects anomaly detection to triage. — *Effort: High (3-5 days)*
4. **Empty state for no history** — When history is empty, show an engaging illustration saying "Your AI assistant is ready" with sample use cases. — *Effort: Low (half day)*

---

## 2. Fish ID Screen

### Fish ID Screen
**File:** `lib/features/smart/fish_id/fish_id_screen.dart`
**Current state:** Functional camera/gallery → AI identification flow. The result card is well-structured with useful data. Loading state is barebones.
**Score:** 7/10

**Issues:**
1. **Lines 120-136 — Image placeholder is lifeless** — A `pets` icon in a bordered box doesn't sell the feature. — **Fix:** Use an illustrated placeholder (e.g., a dashed-border camera viewfinder with a fish silhouette and animated scan lines).
2. **Lines 138-153 — Loading state is just a spinner** — "Analysing image with AI..." with a `CircularProgressIndicator` is the minimum viable loading state. AI features need delight. — **Fix:** Show a shimmer skeleton of the result card, or an animated scanning effect over the image. Add progress stages: "Scanning image..." → "Identifying species..." → "Fetching care data..."
3. **Lines 100-106 — Error message is raw** — `'Failed to identify: $e'` exposes implementation details to users. — **Fix:** Map errors to friendly messages. Network errors → "Can't reach AI — check your connection." Parse errors → "Couldn't identify this one — try a clearer photo."
4. **Lines 155-165 — Error card lacks retry** — Shows the error but doesn't offer a retry button. — **Fix:** Add a "Try Again" button in the error card.
5. **Lines 205-212 — "Add to My Tank" is premature** — The button pops back with `Navigator.pop(r)`, but this screen is navigated to directly from Smart Hub, not from an "add livestock" flow. The result is lost. — **Fix:** Either navigate to the add-livestock flow with pre-filled data, or show a confirmation and save to a "recently identified" list.

**Enhancements:**
1. **Confidence score** — Show AI confidence level (e.g., "95% match"). This sets proper expectations and feels premium. — *Effort: Low (API response tweak)*
2. **"Similar species" section** — After identification, show 2-3 similar species the AI considered. Educational and impressive. — *Effort: Medium (1-2 days)*
3. **Photo comparison** — Side-by-side comparison of the user's photo with a reference image of the identified species from the database. — *Effort: Medium (need reference images)*
4. **Save & share result** — Allow sharing the identification result as an image card (screenshot-worthy). — *Effort: Medium (1-2 days)*

---

## 3. Symptom Triage Screen

### Symptom Triage Screen
**File:** `lib/features/smart/symptom_triage/symptom_triage_screen.dart`
**Current state:** Well-designed stepper wizard with symptom chips, water parameter inputs, and streaming AI diagnosis. Genuinely useful feature.
**Score:** 7.5/10

**Issues:**
1. **Lines 136-174 — Material `Stepper` is ugly** — The built-in Material `Stepper` widget is widely considered one of Flutter's worst-looking stock widgets. It's cramped and the circles look dated. — **Fix:** Build a custom stepper with larger step indicators, animated transitions between steps, and a horizontal progress bar at the top.
2. **Lines 22-33 — Symptom chips are plain** — Plain text `FilterChip`s for medical symptoms. No severity indication. — **Fix:** Color-code chips by urgency. "Death" and "Gasping at surface" should be red. "Colour loss" could be yellow. Add small icons per symptom.
3. **Lines 191-208 — Water params step has no smart defaults** — Five empty text fields. Users might not know normal ranges. — **Fix:** Add helper text showing normal ranges (e.g., pH: "Normal: 6.5-7.5"). Pre-fill from the user's latest water test if available.
4. **Lines 210-252 — Diagnosis output is raw text** — `SelectableText` with the raw AI response. No formatting, no structure. — **Fix:** Parse the AI response into sections (Likely Cause, Urgency, Immediate Actions, Vet Advice) and display each in a styled card with appropriate icons and urgency coloring.
5. **Lines 240-252 — Action buttons compete** — "Save to Journal" and "New Triage" are side-by-side `OutlinedButton` and `FilledButton`. "Save to Journal" pops the screen (losing the diagnosis unless caught). — **Fix:** Save should be a non-destructive action that doesn't navigate away. Show a confirmation toast instead.

**Enhancements:**
1. **Urgency banner** — Parse urgency level from AI response and show a colored banner (green/yellow/red/critical) at the top of the diagnosis. — *Effort: Medium (1 day)*
2. **Photo attachment** — Allow attaching a photo of the sick fish alongside symptoms. Feed to vision API for better diagnosis. — *Effort: Medium (2 days)*
3. **Treatment tracker** — After diagnosis, offer to create a treatment plan with daily reminders. — *Effort: High (3-5 days)*
4. **History of past triages** — Show previous triage results accessible from the triage screen. — *Effort: Medium (1-2 days)*

---

## 4. Weekly Plan Screen

### Weekly Plan Screen
**File:** `lib/features/smart/weekly_plan/weekly_plan_screen.dart`
**Current state:** Functional AI-generated weekly plan with expansion tiles per day. Clean and practical. Lacks interactivity.
**Score:** 6.5/10

**Issues:**
1. **Lines 113-120 — Loading is just a spinner** — Same issue as Fish ID. "Generating your weekly plan..." with a spinner. — **Fix:** Show a skeleton loader of 7 day cards. Or show a fun animation: calendar pages flipping.
2. **Lines 152-170 — `_DayCard` is an `ExpansionTile` in a `Card`** — Expansion tiles inside cards create awkward double-padding and the expansion animation looks clunky with card shadows. — **Fix:** Use a flat list with animated expand/collapse, or ditch the card and use a cleaner sectioned list.
3. **Lines 168-176 — Tasks are not interactive** — Tasks are display-only `ListTile`s. Users can't check them off, reorder them, or snooze them. — **Fix:** Add checkboxes. When a task is completed, animate it with a strike-through and award XP. This turns a passive screen into an active engagement tool.
4. **Lines 95-100 — No tank selection** — Auto-generates for all tanks. What if the user wants a plan for just one tank? — **Fix:** Add a tank selector dropdown at the top.
5. **Lines 131-143 — Footer is just "Regenerate"** — No summary of total time commitment, no stats. — **Fix:** Show "Total weekly commitment: Xh Ym" and a breakdown by priority.

**Enhancements:**
1. **Task completion with XP** — Checking off tasks awards XP and contributes to daily goals. Creates a natural daily engagement loop. — *Effort: Medium (2 days)*
2. **Calendar integration** — Export plan to device calendar. — *Effort: Medium (1-2 days)*
3. **Push notifications** — "Today's tasks: Water change for Living Room Tank (15 min)" — *Effort: Medium (2-3 days)*
4. **Plan persistence** — Currently regenerates from scratch. Track completed tasks and carry over incomplete ones. — *Effort: Medium (2-3 days)*

---

## 5. Anomaly Card

### Anomaly Card
**File:** `lib/features/smart/anomaly_detector/anomaly_card.dart`
**Current state:** Clean alert card with severity-based coloring and dismiss functionality. Good use of `.shake()` animation for attention.
**Score:** 7.5/10

**Issues:**
1. **Lines 56-59 — Shake animation on every build** — `.animate().shake()` fires every time the widget rebuilds, which happens on any provider update. This could be jarring. — **Fix:** Only animate on first appearance. Use a `key` or track whether the animation has played.
2. **Lines 86-96 — Dismiss is just an X button** — No confirmation, no "undo", no "remind me later". One tap and the anomaly is gone forever. — **Fix:** Add swipe-to-dismiss with undo snackbar, or a "Snooze 1h / Dismiss" choice.
3. **Lines 45-53 — "+N more" truncation** — Shows only 3 anomalies then "+N more". No way to see all from this card. — **Fix:** Make the "+N more" text tappable to expand or navigate to the full anomaly history.

**Enhancements:**
1. **Inline action suggestions** — "pH is high → Tap for suggested actions" linking to relevant triage or guides. — *Effort: Medium (1-2 days)*
2. **Trend sparkline** — Show a tiny sparkline of the parameter trend next to each anomaly. Makes the data more meaningful at a glance. — *Effort: Medium (1-2 days)*
3. **Notification integration** — Critical anomalies should trigger push notifications, not just in-app cards. — *Effort: Medium (2 days)*

---

## 6. Settings Hub Screen

### Settings Hub Screen
**File:** `lib/screens/settings_hub_screen.dart`
**Current state:** Well-organized hub with profile card, sectioned navigation, and consistent use of `PrimaryActionTile`. Clean and functional.
**Score:** 7/10

**Issues:**
1. **Line 27 — Emoji in AppBar title** (`'⚙️ Settings & More'`) — Same issue as Smart Screen. Looks unprofessional. — **Fix:** Use `Icon(Icons.settings)` in the AppBar or just "Settings & More" without the emoji.
2. **Lines 168-205 — Profile card is too basic** — Shows name, level, XP, and streak. No avatar customization, no tank count, no progress ring. — **Fix:** Add a circular progress ring around the avatar showing XP to next level. Show tank count ("3 tanks"). Add a small achievement badge showcase (top 3 achievements).
3. **Lines 207-218 — Section headers are plain text** — `_buildSectionHeader` is just styled text. No visual separation. — **Fix:** Add a subtle left border accent color per section, or use `ListTile` group headers with icons.
4. **Lines 42-60 — Community section has no social proof** — "Friends" and "Leaderboard" tiles give no preview of activity. — **Fix:** Show friend count on the tile subtitle ("12 friends, 3 online"). Show leaderboard rank preview ("You're #7 this week").
5. **Line 162 — Version footer is hardcoded** — `'Aquarium App v1.0.0'` is a string literal. — **Fix:** Use `PackageInfo.fromPlatform()` to get the actual version dynamically.

**Enhancements:**
1. **Quick actions row** — Add a row of icon buttons below the profile card for frequently used actions (Share Profile, Edit Avatar, QR Code for friends). — *Effort: Low (1 day)*
2. **"What's New" badge** — Show a red dot on items that have new content since the user last visited. — *Effort: Medium (2 days)*
3. **Animated profile card** — The profile card could have a subtle gradient animation or parallax effect on scroll. — *Effort: Low (half day)*

---

## 7. Settings Screen (Preferences)

### Settings Screen
**File:** `lib/screens/settings_screen.dart`
**Current state:** Massively overloaded. This screen is a dumping ground for EVERYTHING — account, appearance, accessibility, notifications, tools (11+ calculators), guides (15+ guides), shop, data, and about. It's the screen equivalent of a junk drawer.
**Score:** 3/10

**Issues:**
1. **Entire file — Catastrophic information architecture** — This screen has 40+ items across 10+ sections. A user scrolling through this would need to scroll for ages. This directly contradicts mobile UX best practices (2025 research: "Prioritize critical content, minimize cognitive load"). — **Fix:** This screen should only contain actual preferences (theme, notifications, accessibility, data). Move Tools to Workshop, Guides to Learn tab, Shop to its own section.
2. **Lines 67-70 — `_buildItems` called on every `itemBuilder`** — `ListView.builder` calls `_buildItems(context, ref, settings)` for every single item render. This recreates the entire list widget array on each build call. — **Fix:** Cache the list in `build()` and pass it to the `ListView.builder`.
3. **Lines 88-95 — RoomNavigation inside settings** — The Room Navigation widget (a gamification/exploration feature) is buried in settings. Nobody would look for it here. — **Fix:** Move to Home screen or a dedicated Explore tab.
4. **Lines 140-160 — 11 tool tiles in Settings** — Water Change Calculator, CO2 Calculator, Dosing Calculator, Unit Converter, Tank Volume Calculator, Cost Tracker, Compatibility Checker, Lighting Schedule, Stocking Calculator... all in Settings. — **Fix:** These are already in the Workshop. Remove duplicates from Settings.
5. **Lines 180-250+ — 15+ guide tiles in expandable sections** — Quick Start Guide, Emergency Guide, Nitrogen Cycle Guide, Algae Guide, Breeding Guide, etc. all in Settings. — **Fix:** Move all guides to the Learn tab where they belong.
6. **Hardcoded version `'Version 0.1.0'`** — Contradicts the `v1.0.0` shown elsewhere. Version strings should come from one source. — **Fix:** Use `PackageInfo`.

**Enhancements:**
1. **Gut this screen** — Reduce to: Account, Appearance (2-3 items), Accessibility (2-3 items), Notifications (1-2 items), Data (export/import), About. That's it. 15 items max. — *Effort: Medium (1-2 days of refactoring)*
2. **Search within settings** — If the screen must stay large, add a search bar at the top. — *Effort: Medium (1 day)*
3. **Group with Material 3 list sections** — Use proper `Card` grouping like iOS Settings does. — *Effort: Low (half day)*

---

## 8. Account Screen

### Account Screen
**File:** `lib/screens/account_screen.dart`
**Current state:** Solid account management screen with signed-in/signed-out/offline states. Standard auth form with email, password, and Google sign-in. Well-structured.
**Score:** 7/10

**Issues:**
1. **Lines 57-74 — Offline message is a dead end** — Shows "Cloud Not Configured" with no actionable next step. — **Fix:** Add a "Learn about cloud sync" link or "Request early access" button. Don't just tell users what they can't do.
2. **Lines 76-170 — Auth form is functional but generic** — Standard email/password form. Nothing wrong with it, but nothing special either. — **Fix:** Add social login options beyond Google (Apple Sign-In is required for iOS App Store). Add animated transitions between sign-in and sign-up.
3. **Lines 188-220 — Signed-in profile card** — Clean but shows minimal info. — **Fix:** Show last sync date, backup status, and device count.

**Enhancements:**
1. **Apple Sign-In** — Required for iOS App Store if you offer any third-party login. — *Effort: Medium (2-3 days)*
2. **Delete account** — GDPR compliance. Add a "Delete my account and data" option in the signed-in view. — *Effort: Medium (1-2 days)*
3. **Multi-device indicator** — Show "Signed in on 2 devices" with device names. — *Effort: Medium (2 days)*

---

## 9. Backup & Restore Screen

### Backup & Restore Screen
**File:** `lib/screens/backup_restore_screen.dart`
**Current state:** Well-structured backup/restore with progress indicators, tank listing, and clear export/import sections. The "What Gets Exported" checklist is a nice touch. Professional.
**Score:** 8/10

**Issues:**
1. **Lines 55-60 — `_buildItems` called on every `itemBuilder`** — Same performance issue as Settings screen. Rebuilds the entire widget list on each item render. — **Fix:** Cache the list.
2. **Lines 160-200 — Import warning placement** — The warning about additive imports is at the very bottom. Users might miss it before importing. — **Fix:** Move the warning above the import button, or show it as a confirmation dialog when the user taps Import.
3. **No automatic backup reminder** — Users must manually come here to back up. — **Fix:** Show a "Last backed up: X days ago" warning in Settings Hub if backup is stale.

**Enhancements:**
1. **Scheduled auto-backup** — Offer weekly automatic backup to a cloud location or local file. — *Effort: High (3-5 days)*
2. **Backup diff preview** — Before restoring, show a summary of what will be added/changed. — *Effort: High (3-5 days)*
3. **QR code backup sharing** — Generate a QR code to quickly transfer data to a new device on the same WiFi. — *Effort: High (3-5 days)*

---

## 10. About Screen

### About Screen
**File:** `lib/screens/about_screen.dart`
**Current state:** Clean, attractive about page with gradient app icon, feature highlights, and legal links. The "Made with ❤️" footer is a nice touch.
**Score:** 8/10

**Issues:**
1. **Line 63 — Hardcoded version `'Version 1.0.0'`** — Should be dynamic. — **Fix:** Use `PackageInfo.fromPlatform()`.
2. **Lines 75-100 — Feature items are generic** — "Multi-Tank Management", "Water Testing" etc. These repeat what the app already shows. — **Fix:** Show actual user stats: "You've managed 3 tanks", "47 water tests logged", "12 species identified." Makes it personal.
3. **No feedback/support link** — Privacy and Terms are there, but no way to contact support or submit feedback. — **Fix:** Add a "Contact Support" button that opens an email composer or in-app feedback form.

**Enhancements:**
1. **Easter egg** — Tap the app icon 7 times for a fun animation. Classic mobile tradition. — *Effort: Low (few hours)*
2. **Credits section** — Credit open-source libraries used. — *Effort: Low (already available via Licenses page)*
3. **Changelog** — Show what's new in each version. — *Effort: Low (1 day)*

---

## 11. Friends Screen

### Friends Screen
**File:** `lib/screens/friends_screen.dart`
**Current state:** Tabbed screen (Friends / Activity) with search, demo data indicator, and empty states using mascot. Good error handling.
**Score:** 6.5/10

**Issues:**
1. **Lines 79-94 — Demo data banner is permanent** — Hardcoded "Demo data — connect your account for real friends" always shows. — **Fix:** Conditionally show only when using demo data. When connected, hide it.
2. **Lines 250-290 — Friend tile uses hardcoded `Colors` and raw values** — `Colors.grey.shade600`, `fontSize: 16`, `fontSize: 14`. These bypass the design system. — **Fix:** Use `AppTypography` and `AppColors` throughout.
3. **Lines 140-160 — Add friend dialog is basic** — Just a text field. No friend code system, no QR code, no search by email. — **Fix:** Add multiple discovery methods: username search, share invite link, QR code scan.
4. **Line 262 — Friend count uses hardcoded styling** — `TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600)` — **Fix:** Replace with `AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)`.

**Enhancements:**
1. **Friend request system** — Currently adds friends instantly. A request/accept flow is more realistic and safer. — *Effort: High (3-5 days)*
2. **Friend activity feed** — Show what friends are doing (new tanks, achievements, test results) in a Duolingo-style feed. — *Effort: High (3-5 days)*
3. **Friend suggestions** — "People you might know" based on similar tank setups or species. — *Effort: High (3-5 days backend)*

---

## 12. Friend Comparison Screen

### Friend Comparison Screen
**File:** `lib/screens/friend_comparison_screen.dart`
**Current state:** Side-by-side user comparison with stats, progress chart, and achievements. Encouragement emoji system is charming. Well-structured.
**Score:** 7/10

**Issues:**
1. **Lines 78-84 — Preview banner is hardcoded** — "Preview — social features coming soon" is always shown. — **Fix:** Remove when social features are live. Use a feature flag.
2. **Lines 145-180 — Encouragement emoji dialog uses hardcoded colors** — `Colors.blue.shade50`, `Colors.grey.shade100`. Doesn't respect theme/dark mode. — **Fix:** Use theme-aware colors.
3. **Lines 200-230 — VS header is basic** — Just two cards with "VS" text between them. Feels like a prototype. — **Fix:** Add animated VS badge, gradient backgrounds per user card, and a subtle competitive energy (winner highlighting on stats).

**Enhancements:**
1. **Animated stat bars** — When the screen loads, stats should animate from 0 to their values with the winner's bar colored differently. — *Effort: Low (1 day)*
2. **"Challenge" feature** — Challenge a friend to a specific goal (e.g., "Who can log more water tests this week?"). — *Effort: High (3-5 days)*

---

## 13. Leaderboard Screen

### Leaderboard Screen
**File:** `lib/screens/leaderboard_screen.dart`
**Current state:** Full Duolingo-style competitive leaderboard with leagues, promotion/demotion zones, countdown timer, and rank highlighting. This is genuinely impressive for a hobby app. Very well executed.
**Score:** 8/10

**Issues:**
1. **Lines 72-78 — Demo banner uses hardcoded `Colors.amber`** — `Colors.amber.shade50`, `Colors.amber` — **Fix:** Use `AppColors.warning` and theme-aware background.
2. **Lines 155-190 — Leaderboard tile uses raw `Colors` references** — `Theme.of(context).primaryColor.withAlpha(26)`, `Colors.grey` throughout. — **Fix:** Standardize to design system tokens.
3. **Lines 180-190 — "YOU" chip is cramped** — `padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0)` results in a tiny, hard-to-read chip. — **Fix:** Increase padding and use a distinct accent color.

**Enhancements:**
1. **League animation** — Animate league badge with a shield/emblem effect when entering the screen. — *Effort: Low (1 day)*
2. **Weekly recap** — Show a "Last week's results" summary modal: rank, XP earned, promotion/demotion status. — *Effort: Medium (2 days)*
3. **Tap to view friend** — Tapping a leaderboard entry could show their profile/comparison. — *Effort: Medium (1-2 days)*

---

## 14. Species Browser Screen

### Species Browser Screen
**File:** `lib/screens/species_browser_screen.dart`
**Current state:** Solid species database browser with search, filter chips (care level + temperament), and detailed bottom sheet. XP reward for researching. Good.
**Score:** 7/10

**Issues:**
1. **Lines 80-95 — Species card uses a generic icon** — Every species gets `Icons.set_meal`. For a species database, this is disappointing. — **Fix:** Add species-specific icons or illustrations. At minimum, use different icons for fish families (cichlid icon, tetra icon, etc.).
2. **Lines 55-65 — Filter chips scroll horizontally** — 6 chips in a horizontal scroll. On small screens, users might not realize they can scroll. — **Fix:** Add a fade gradient on the right edge (like the achievements screen does) to hint at scrollability.
3. **Lines 38-45 — No sort option** — Can filter but not sort (by name, size, care level). — **Fix:** Add a sort button in the AppBar.

**Enhancements:**
1. **Species photos** — Even placeholder illustrations would be dramatically better than `set_meal` icons. — *Effort: High (need assets, but transformative)*
2. **"Add to my tank" shortcut** — From species detail, allow adding directly to a tank. — *Effort: Medium (1-2 days)*
3. **Compatibility quick-check** — In species detail, show compatibility with species already in user's tanks. — *Effort: Medium (2-3 days)*

---

## 15. Plant Browser Screen

### Plant Browser Screen
**File:** `lib/screens/plant_browser_screen.dart`
**Current state:** Nearly identical structure to Species Browser. Good filters (difficulty, placement, CO2 requirement). XP animation integration is a plus.
**Score:** 7/10

**Issues:**
1. **Same icon issue as species** — Every plant gets a generic icon. — **Fix:** Use different icons for placement types (foreground/midground/background/floating).
2. **Code duplication with Species Browser** — These two screens share 80% of their structure. — **Fix:** Extract a shared `DatabaseBrowser<T>` widget and parameterize it. This is a maintenance debt issue.
3. **Filter labels could be clearer** — "Easy/Medium/Hard" for difficulty is fine, but "Low Tech" toggle is separate from the difficulty chips, which is confusing. — **Fix:** Make "Low Tech" a filter chip alongside the difficulty chips for consistency.

**Enhancements:**
1. **Growth rate indicator** — Show a growth speed icon (slow 🐢, medium, fast 🚀) on each card. — *Effort: Low (data already exists)*
2. **Lighting requirements** — Show PAR/light level needed as a visual indicator. — *Effort: Low (half day)*

---

## 16. Achievements Screen

### Achievements Screen
**File:** `lib/screens/achievements_screen.dart`
**Current state:** Excellent trophy case with progress header, filtering (category, rarity, lock status), sorting, and gradient progress bar. The filter fade gradient is a nice touch. One of the better-designed screens.
**Score:** 8/10

**Issues:**
1. **Line 19 — Emoji in title** — `'🏆 Trophy Case'` — same emoji-in-title issue. — **Fix:** Use proper icon or styled text.
2. **Lines 100-120 — Too many filter chips** — Category chips + rarity chips + lock status = potentially 12+ chips in a horizontal scroll. Cognitive overload for a trophy case. — **Fix:** Use a filter dropdown/modal for categories and rarity. Keep only All/Unlocked/Locked as primary chips.

**Enhancements:**
1. **Achievement showcase** — Let users pin 3 achievements to their profile card. — *Effort: Low (1 day)*
2. **Rarity sparkle effect** — Legendary/Epic achievements should have a subtle particle effect on their cards. — *Effort: Medium (1-2 days)*
3. **"Next closest" suggestions** — Show 3 achievements the user is closest to unlocking at the top. — *Effort: Medium (1-2 days)*

---

## 17. Search Screen

### Search Screen
**File:** `lib/screens/search_screen.dart`
**Current state:** Global search across tanks, livestock, equipment, and species database. Functional but basic.
**Score:** 6/10

**Issues:**
1. **Lines 70-90 — Search results build synchronously in `build()`** — The `_SearchResults` widget iterates over all tanks, reads their async providers, and builds results all inline. This is a performance concern and architecturally questionable. — **Fix:** Move search logic to a dedicated search provider that returns pre-computed results.
2. **Lines 60-70 — No search history** — No recent searches, no suggestions. Starting from a blank screen every time. — **Fix:** Show recent searches and popular categories when the search field is empty.
3. **Lines 30-40 — No debounce** — `onChanged` triggers `setState` on every keystroke. — **Fix:** Add a debounce (300ms) before triggering search.
4. **Lines 85-130 — Results are flat** — All result types (tanks, livestock, equipment, species) are in one flat list with no grouping. — **Fix:** Group results by type with section headers: "Tanks (2)", "Fish (5)", "Species Database (10)".

**Enhancements:**
1. **Federated search with type filters** — Tabs or chips to filter by result type. — *Effort: Medium (1-2 days)*
2. **Fuzzy matching** — Currently exact substring match. Add fuzzy/typo-tolerant search. — *Effort: Medium (1-2 days)*
3. **Search suggestions** — As user types, show suggestions from the species database. — *Effort: Low (1 day)*

---

## 18. Workshop Screen

### Workshop Screen
**File:** `lib/screens/workshop_screen.dart`
**Current state:** Beautifully themed workshop room with custom brown/wood gradient, glassmorphic tool cards in a 2-column grid. This screen has real personality and stands out from the rest of the app. The most visually distinctive screen I've reviewed.
**Score:** 8.5/10

**Issues:**
1. **Lines 48-65 — Custom color system bypasses theme** — `WorkshopColors` defines its own complete color palette separate from `AppColors`. This means dark mode toggle won't work naturally. — **Fix:** The dark mode adaptation exists (lines 55-60) but it's manual. Consider integrating into the theme extension system for consistency.
2. **Lines 95-180 — 12 tool cards with no priority hierarchy** — All tools are presented equally in a grid. Water Change Calculator and Unit Converter shouldn't have the same visual weight. — **Fix:** Make the 3 most-used tools larger (span full width) at the top, with less-used tools in the grid below.
3. **Lines 150-155 — "Charts" and "Equipment" show info dialogs** — These tools require a tank context but show a generic info dialog. — **Fix:** Show a tank picker dialog instead. Let users choose a tank to see its charts/equipment.

**Enhancements:**
1. **Tool usage analytics** — Track which tools are used most and reorder the grid dynamically. — *Effort: Medium (1-2 days)*
2. **Quick-access favorites** — Let users pin their 3 most-used tools to the top. — *Effort: Low (1 day)*
3. **Tool discovery animation** — First-time visit: tools "build" themselves with a wrench animation. — *Effort: Medium (1-2 days)*

---

## 19. Compatibility Checker

### Compatibility Checker
**File:** `lib/screens/compatibility_checker_screen.dart`
**Current state:** Smart species compatibility checking with temperature, pH, temperament, size, and explicit incompatibility detection. The logic is thorough and the severity system (bad/warning) is well-thought-out.
**Score:** 7/10

**Issues:**
1. **Lines 85-140 — Compatibility logic is in the widget** — Complex compatibility checking with 5+ rule types lives in the StatefulWidget. This should be in a service or provider for testability and reuse. — **Fix:** Extract to a `CompatibilityService` class.
2. **Missing visual summary** — No overall compatibility score or traffic light indicator. Users must read each individual issue. — **Fix:** Show a large compatibility score (0-100%) or traffic light at the top.
3. **No "compatible with" positive feedback** — Only shows issues, never says "These fish are great together!" — **Fix:** When no issues exist, show a celebratory green banner: "Perfect combination! All species are compatible."

**Enhancements:**
1. **Import from tank** — "Check my Living Room Tank" button that auto-loads all species from an existing tank. — *Effort: Low (1 day)*
2. **Suggestion engine** — "Looking for a compatible tankmate?" suggestion based on current selection. — *Effort: Medium (2-3 days)*
3. **Visual compatibility matrix** — A grid/table showing pairwise compatibility when 3+ species are selected. — *Effort: Medium (2-3 days)*

---

## 20. Stocking Calculator

### Stocking Calculator
**File:** `lib/screens/stocking_calculator_screen.dart`
**Current state:** Practical bioload calculator with tank settings, species search, stock count management, and percentage-based stocking meter. The bioload multipliers per species type are a good touch.
**Score:** 7/10

**Issues:**
1. **Lines 60-80 — Bioload calculation is in the widget** — Same architectural concern as Compatibility Checker. Complex logic in the UI layer. — **Fix:** Extract to a service.
2. **Lines 120-135 — Tank setup row is cramped** — Three inputs and a toggle in one row. On narrow screens this will overflow. — **Fix:** Stack on small screens or use a two-row layout.
3. **No import from existing tank** — Users must manually re-enter their tank volume and species. — **Fix:** "Import from my tank" dropdown that pre-fills all data.

**Enhancements:**
1. **Visual stocking gauge** — Replace the text-based meter with an animated radial gauge (like a speedometer). Red zone clearly marked. — *Effort: Medium (1-2 days)*
2. **"What can I add?" reverse calculator** — "I want to add Neon Tetras — how many can I fit?" — *Effort: Medium (1-2 days)*
3. **Save stocking plans** — Save and name different stocking configurations to compare. — *Effort: Medium (1-2 days)*

---

## 21. Cost Tracker

### Cost Tracker
**File:** `lib/screens/cost_tracker_screen.dart`
**Current state:** Full expense tracker with categories, monthly/yearly summaries, and category breakdown. Undo on delete. Persistent via SharedPreferences.
**Score:** 7/10

**Issues:**
1. **Lines 35-50 — Data stored in SharedPreferences** — Cost data is serialized to a single string in SharedPreferences. This doesn't scale and doesn't integrate with the app's main storage system. — **Fix:** Move to the app's database/storage layer alongside tank data. Include in backup/restore.
2. **Lines 110-145 — `_buildItemCount` / `_buildListItem` manual index tracking** — Complex manual index arithmetic to build a heterogeneous list. Fragile and hard to maintain. — **Fix:** Use a single list of typed items (header, card, expense) and iterate over them.
3. **No recurring expenses** — Aquarium hobbyists have recurring costs (food, electricity, water treatment). Must be manually re-entered. — **Fix:** Add "Recurring" option with monthly/weekly frequency.

**Enhancements:**
1. **Spending trends chart** — Monthly spending trend line chart. — *Effort: Medium (1-2 days, fl_chart already in deps)*
2. **Budget setting** — "Set a monthly budget" with visual budget remaining indicator. — *Effort: Medium (1-2 days)*
3. **Cost per tank** — Associate expenses with specific tanks for per-tank cost analysis. — *Effort: Medium (2 days)*

---

## 22. Wishlist Screen

### Wishlist Screen
**File:** `lib/screens/wishlist_screen.dart`
**Current state:** Clean wishlist with category-specific theming, purchase tracking, budget integration, and history view. Uses mascot empty state. Well-structured.
**Score:** 7.5/10

**Issues:**
1. **Lines 15-35 — Emoji in title** — `'🐟 Fish Wishlist'`, `'🌿 Plant Wishlist'`, etc. — **Fix:** Use styled icons.
2. **Lines 130-145 — Delete confirmation dialog** — Unnecessarily aggressive for wishlist items. — **Fix:** Use swipe-to-delete with undo snackbar instead of a confirmation dialog.
3. **No link to species/plant database** — Adding a wishlist item is free-text. Users type names manually. — **Fix:** Add "Browse database" option that lets users add items from the species/plant database directly.

**Enhancements:**
1. **Price tracking** — "Notify me when this fish is in stock at my local shop" (future integration with Shop Street). — *Effort: High (3-5 days)*
2. **Priority ordering** — Drag to reorder by priority. — *Effort: Low (1 day)*
3. **Wishlist sharing** — Share wishlist with friends or local shops. — *Effort: Medium (2 days)*

---

## 23. Enhanced Onboarding Screen

### Enhanced Onboarding Screen
**File:** `lib/screens/enhanced_onboarding_screen.dart`
**Current state:** Polished 4-page onboarding flow with mascot, experience level selection, tank type picker, and goal selection. Progress bars, skip option, and celebration on completion. This is genuinely well-designed.
**Score:** 8/10

**Issues:**
1. **Lines 70-80 — `_complete()` navigation timing** — Uses `Future.delayed(500ms)` for celebration, then pushReplacement. This is fragile — the celebration might not show or might flash briefly. — **Fix:** Use the celebration service's completion callback to trigger navigation instead of a hardcoded delay.
2. **Lines 145-155 — Progress bar is custom but basic** — Four colored containers. No animation between states. — **Fix:** Animate the progress bars filling with a smooth transition.
3. **Lines 182-195 — Back/Continue buttons don't animate** — Page transitions via `PageView` but buttons snap. — **Fix:** Animate button text changes. "Let's Go!" → "Continue" → "Start Learning" with cross-fade.

**Enhancements:**
1. **Parallax illustrations** — Each page could have a background illustration that slightly parallaxes as you swipe between pages. — *Effort: Medium (1-2 days)*
2. **Sound effects** — Subtle sounds on selection (tap), page turn, and completion. — *Effort: Low (half day)*
3. **"Why we ask" tooltip** — Each question could have a small "?" that explains why this question matters. Builds trust. — *Effort: Low (half day)*

---

## 24. Profile Creation Screen

### Profile Creation Screen
**File:** `lib/screens/onboarding/profile_creation_screen.dart`
**Current state:** Alternative/older onboarding path with name field, experience level, tank type, and goals. Has accessibility support (FocusTraversal). Skip option goes directly to home.
**Score:** 6.5/10

**Issues:**
1. **Duplicates Enhanced Onboarding** — This screen and `EnhancedOnboardingScreen` do essentially the same thing. Two onboarding paths = maintenance burden and potential confusion. — **Fix:** Pick one and delete the other. The Enhanced version is better.
2. **Lines 78-95 — Error handling uses raw SnackBars** — `ScaffoldMessenger.of(context).showSnackBar` with red background, while the rest of the app uses `AppFeedback`. — **Fix:** Use `AppFeedback.showError()` consistently.
3. **Lines 40-55 — Skip creates a default profile silently** — Skip creates a "beginner, freshwater, keepFishAlive" profile without telling the user. — **Fix:** Show a brief note: "We'll set you up as a beginner. You can change this later in Settings."

**Enhancements:**
1. **Delete this screen** — Consolidate into Enhanced Onboarding. One path to rule them all. — *Effort: Low (cleanup only)*

---

## 25. Enhanced Placement Test

### Enhanced Placement Test
**File:** `lib/screens/onboarding/enhanced_placement_test_screen.dart`
**Current state:** Duolingo-style quiz with confetti on correct answers, shake on incorrect, progress bar, and skip-to-results after 10 questions. Proper animation controllers with dispose. Very polished.
**Score:** 8.5/10

**Issues:**
1. **Lines 83-86 — Multiple AnimationControllers** — 5 animation controllers + 2 confetti controllers is a lot of manual management. This works but is fragile. — **Fix:** Consider using `flutter_animate` (already in the project) for simpler declarative animations where possible.
2. **Lines 135-140 — Skip dialog appears at question 10** — Hard to discover. No visual indicator that skip becomes available. — **Fix:** Add a subtle progress milestone at question 10 — "You've answered enough for a good assessment! Skip to results?"

**Enhancements:**
1. **Difficulty adaptation** — If the user gets 5 in a row correct, skip ahead to harder questions. If struggling, stop early with a kind message. — *Effort: Medium (2 days)*
2. **Category-aware progress** — Show which knowledge areas (water chemistry, species, equipment) the user is strong/weak in. — *Effort: Medium (2-3 days)*

---

## 26. Confetti Overlay

### Confetti Overlay
**File:** `lib/widgets/celebrations/confetti_overlay.dart`
**Current state:** Comprehensive, highly configurable confetti system with multiple blast types (explosive, top-down, fountain, corners), particle shapes (circles, stars, fish, bubbles), and themed color sets (aquatic, rainbow, gold, level-up). This is premium-quality celebration infrastructure.
**Score:** 9/10

**Issues:**
1. **No performance concerns noted** — Well-structured with proper dispose. The only minor issue is that custom particle path drawing (fish/bubble shapes) adds some computation, but it's burst-only so acceptable.
2. **Fish particle shape** — Without seeing the full path code, ensure the fish silhouette is recognizable at confetti size (very small). — **Fix:** Simplify the path if it's too detailed for tiny particles.

**Enhancements:**
1. **Sound integration** — Pair confetti with a satisfying "pop" sound. — *Effort: Low (half day)*
2. **Reduced motion respect** — Check if `ReducedMotion` provider is respected. If the user has reduced motion enabled, confetti should be replaced with a static celebration (flash of color, no particles). — *Effort: Low (half day)*

---

## 27. Level Up Overlay

### Level Up Overlay
**File:** `lib/widgets/celebrations/level_up_overlay.dart`
**Current state:** Cinematic level-up celebration with sequenced animations (overlay fade → text bounce → level number scale → confetti → sparkle particles), haptic feedback, golden glow pulse. This is the emotional centerpiece of the gamification system and it delivers.
**Score:** 9/10

**Issues:**
1. **Lines 85-90 — 6 animation controllers** — Complex but necessary for the sequenced effect. However, this is a lot of manual orchestration. — **Fix:** Document the animation timeline clearly with comments (already partially done). Consider a state machine if it grows more complex.
2. **Lines 130-135 — Auto-dismiss duration** — 3 seconds might be too short for users to read the level title and appreciate the moment. — **Fix:** Increase to 4 seconds, or wait for user tap as primary dismiss.

**Enhancements:**
1. **Level-specific rewards preview** — "Level 5 unlocked: Advanced Filters!" Show what the new level grants. — *Effort: Medium (1-2 days)*
2. **Screenshot moment** — Brief pause before confetti where the level number is clearly visible = shareable screenshot. — *Effort: Low (timing tweak)*
3. **Reduced motion fallback** — Replace animations with a simple card overlay for accessibility. — *Effort: Low (half day)*

---

## 28. Gamification Dashboard

### Gamification Dashboard
**File:** `lib/widgets/gamification_dashboard.dart`
**Current state:** Compact stats card showing streak, XP, gems, hearts, and daily goal progress. Clean 2x2 grid with emoji icons. Daily goal progress bar is well-implemented.
**Score:** 7.5/10

**Issues:**
1. **Lines 42-60 — Too much data in one card** — Streak, XP, gems, hearts, AND daily goal progress. Five metrics in one compact card. Users' eyes glaze over. — **Fix:** Prioritize. Show streak + daily goal prominently. Make gems/hearts accessible via tap to expand.
2. **Lines 75-80 — Hearts system visibility** — Hearts with "time until refill" is a Duolingo mechanic that only works if hearts actually limit something. If hearts aren't enforced, showing them creates confusion. — **Fix:** Only show hearts if the hearts system is actively enforced.
3. **Lines 125-130 — Number formatting** — Formats numbers ≥1000 as "1.0k". But the threshold checks both ≥10000 and ≥1000 with the same format. — **Fix:** `≥10000` → "10.0k", `≥1000` → "1,000" (comma separated). Or simplify: always show "1.2k" for ≥1000.

**Enhancements:**
1. **Animated stat changes** — When XP increases, show the number animating upward (+25 XP). — *Effort: Medium (1-2 days)*
2. **Tap for detail** — Tapping any stat opens a detail sheet with history/trends. — *Effort: Medium (2 days)*
3. **Daily goal celebration** — When the daily goal is hit, the progress bar should fill with a satisfying animation and color change. — *Effort: Low (1 day)*

---

## 29. XP Progress Bar

### XP Progress Bar
**File:** `lib/widgets/xp_progress_bar.dart`
**Current state:** Beautifully animated progress bar with gradient fill, glow shadow, shimmer effect, and smooth XP transitions. Shows level, XP to next level, and total XP. This is a polished component.
**Score:** 8.5/10

**Issues:**
1. **Lines 80-85 — `_updateProgress` called in `addPostFrameCallback`** — This triggers animation on every profile provider update, even when XP hasn't changed. The `if (newProgress != _targetProgress)` guard helps but the frame callback still fires. — **Fix:** Use `ref.listen` instead to only react to actual changes.
2. **Lines 105-110 — "Max Level!" text** — Shows when `xpToNextLevel == 0`. But is there actually a max level? If not, this is misleading. — **Fix:** Either implement a max level or show the infinite progress messaging ("Keep going!").

**Enhancements:**
1. **XP gain animation** — When XP increases, show a "+25" badge floating up from the bar. — *Effort: Medium (1 day)*
2. **Level milestone markers** — Small tick marks on the bar showing where the next few levels are. — *Effort: Low (half day)*
3. **Long-press detail** — Show a tooltip with "Level 5: 450/600 XP (75%)" on long press. — *Effort: Low (half day)*

---

## 30. Streak Calendar

### Streak Calendar
**File:** `lib/widgets/streak_calendar.dart`
**Current state:** GitHub-style contribution calendar with color-coded daily activity. Includes day-of-week labels and month labels. Clean implementation.
**Score:** 7.5/10

**Issues:**
1. **Lines 55-75 — Calendar grid is calculated on every build** — Week grouping, padding, and label generation happen in `build()`. — **Fix:** Memoize the grid data. Only recalculate when goals data changes.
2. **Lines 95-110 — Month labels are misaligned** — The logic for month label placement is complex and potentially buggy (checking `lastMonth` state with weekday alignment). — **Fix:** Simplify: show month labels above the grid aligned to the first week containing that month.
3. **No interaction** — Calendar cells are display-only. — **Fix:** Add tooltips or tap handlers showing "Feb 25: 120 XP earned, daily goal completed ✅".

**Enhancements:**
1. **Current day highlight** — Highlight today's cell with a ring or different shape. — *Effort: Low (half day)*
2. **Streak counter** — Show the current streak count prominently above the calendar: "🔥 14-day streak!" — *Effort: Low (half day)*
3. **Weekly average** — Show average XP per week below the calendar. — *Effort: Low (half day)*
4. **Animation on streak milestones** — When hitting 7-day, 30-day, 100-day streaks, animate the calendar. — *Effort: Medium (1 day)*

---

## 31. Achievement Unlocked Dialog

### Achievement Unlocked Dialog
**File:** `lib/widgets/achievement_unlocked_dialog.dart`
**Current state:** Full-screen cinematic achievement dialog with confetti (multiple blast angles), scale/fade animation, rarity-based color theming, XP + gem rewards display. Forces user acknowledgment (not dismissible by barrier tap). This is satisfying.
**Score:** 8.5/10

**Issues:**
1. **Lines 60-65 — `barrierDismissible: false`** — Users MUST tap a button to dismiss. If the button is off-screen or the dialog has a bug, users are stuck. — **Fix:** Add a 5-second auto-dismiss timeout as a safety net, or make barrier dismissible after 2 seconds.
2. **Lines 120-145 — Large icon container (140x140)** — On small phones, this combined with the header text and rewards section might overflow. — **Fix:** Use `SingleChildScrollView` (already present — good) but test on small screens (320px width).
3. **Missing "Share" button** — Achievement unlocks are shareable moments. — **Fix:** Add a "Share" button that generates a screenshot-worthy achievement card.

**Enhancements:**
1. **Achievement rarity sound** — Different sounds per rarity tier. Common = ding, Epic = fanfare, Legendary = orchestral hit. — *Effort: Medium (1 day + sound assets)*
2. **Chain celebration** — If multiple achievements unlock at once, queue them with a "1 of 3" counter. — *Effort: Medium (2 days)*
3. **Social sharing card** — Generate a beautiful achievement card image for sharing on social media. — *Effort: Medium (2-3 days)*

---

## Priority Matrix

### 🔴 Critical (Fix Immediately — Visible Issues or Broken UX)

| # | Screen | Issue | Effort |
|---|--------|-------|--------|
| 1 | Settings Screen | **Catastrophic information overload** — 40+ items, needs architectural gutting | Medium (1-2 days) |
| 2 | Settings Screen | `_buildItems` performance bug (rebuilds on every item) | Low (30 min) |
| 3 | Backup & Restore | `_buildItems` same performance bug | Low (30 min) |
| 4 | Search Screen | No debounce on search, sync search in build() | Low (1 hour) |
| 5 | Profile Creation | **Delete duplicate onboarding path** — maintenance hazard | Low (1 hour) |

### 🟠 High Priority (Polish — Noticeable Quality Issues)

| # | Screen | Issue | Effort |
|---|--------|-------|--------|
| 6 | Smart Screen | Emoji in AppBar titles (affects 5+ screens) | Low (30 min) |
| 7 | Smart Screen | Feature cards need visual hierarchy, not a flat list | Medium (1 day) |
| 8 | Fish ID | Loading state needs delight (skeleton/scanning animation) | Medium (1 day) |
| 9 | Fish ID | Raw error messages exposed to users | Low (1 hour) |
| 10 | Symptom Triage | Replace Material Stepper with custom stepper | Medium (2 days) |
| 11 | Symptom Triage | Diagnosis output is unformatted raw text | Medium (1 day) |
| 12 | Friends Screen | Hardcoded `Colors` bypass design system (affects 3+ screens) | Low (1 hour) |
| 13 | Leaderboard | Hardcoded `Colors` bypass design system | Low (1 hour) |
| 14 | All Screens | Hardcoded version strings — use `PackageInfo` | Low (30 min) |
| 15 | Account Screen | Missing Apple Sign-In (App Store requirement) | Medium (2-3 days) |

### 🟡 Medium Priority (Enhancement — Competitive Differentiators)

| # | Screen | Enhancement | Effort |
|---|--------|-------------|--------|
| 16 | Smart Screen | Premium AI header with animated gradient | Medium (1-2 days) |
| 17 | Weekly Plan | Task completion with XP rewards | Medium (2 days) |
| 18 | Species/Plant Browser | Species-specific icons or illustrations | High (need assets) |
| 19 | Search Screen | Result grouping by type with section headers | Medium (1-2 days) |
| 20 | Workshop | Usage-based tool reordering / favorites | Medium (1-2 days) |
| 21 | Compatibility Checker | Overall compatibility score/traffic light | Medium (1 day) |
| 22 | Compatibility Checker | Extract logic to service layer | Medium (1 day) |
| 23 | Stocking Calculator | Visual gauge, import from tank | Medium (2 days) |
| 24 | Cost Tracker | Move from SharedPreferences to app database | Medium (2 days) |
| 25 | Gamification Dashboard | Animated stat changes on XP gain | Medium (1-2 days) |
| 26 | Streak Calendar | Tooltips and current-day highlight | Low (1 day) |
| 27 | Achievement Dialog | Share button for screenshot-worthy moments | Medium (2 days) |
| 28 | All Celebrations | Reduced motion accessibility support | Low (1 day) |

### 🟢 Low Priority (Nice-to-Have — Future Polish)

| # | Screen | Enhancement | Effort |
|---|--------|-------------|--------|
| 29 | Smart Screen | Proactive AI suggestions card | High (3-5 days) |
| 30 | Fish ID | Confidence score and similar species | Medium (1-2 days) |
| 31 | Symptom Triage | Treatment tracker with reminders | High (3-5 days) |
| 32 | Friends Screen | Friend request system (currently instant add) | High (3-5 days) |
| 33 | About Screen | Easter egg on app icon | Low (few hours) |
| 34 | Level Up Overlay | Level-specific rewards preview | Medium (1-2 days) |
| 35 | Confetti/Level Up | Sound integration for celebrations | Low (1 day) |
| 36 | Onboarding | Parallax illustrations on page swipe | Medium (1-2 days) |

---

## Summary Assessment

### What's Genuinely Good ✅
- **Celebration system (Confetti, Level Up, Achievement Dialog)** — Production-quality, emotionally satisfying, well-engineered. This is the best part of the UI.
- **Leaderboard Screen** — Full Duolingo-style competitive system with leagues and promotion zones. Impressive for a hobby app.
- **Enhanced Placement Test** — Polished quiz experience with correct/incorrect feedback animations.
- **Workshop Screen** — The most visually distinctive screen. Has personality.
- **Backup & Restore** — Clear, well-structured, informative.
- **XP Progress Bar** — Beautiful gradient, shimmer, and animation.

### What Needs Urgent Attention 🚨
- **Settings Screen** — A junk drawer that damages the entire app's perceived quality. This single screen makes the app feel unfinished. Gut it.
- **Duplicate Onboarding** — Two paths doing the same thing. Delete the older one.
- **Design System Compliance** — Hardcoded `Colors` and raw `TextStyle`s scattered across community/social screens. Inconsistent with the otherwise good design system.

### Overall Quality Distribution
- **9/10 screens:** Confetti Overlay, Level Up Overlay (celebrations are excellent)
- **8-8.5/10 screens:** Achievements, Backup & Restore, About, Leaderboard, Workshop, Placement Test, XP Bar, Achievement Dialog
- **7-7.5/10 screens:** Smart Hub, Fish ID, Symptom Triage, Settings Hub, Account, Species/Plant Browser, Anomaly Card, Gamification Dashboard, Streak Calendar, Wishlist, Cost Tracker, Stocking Calculator, Compatibility Checker
- **6-6.5/10 screens:** Weekly Plan, Search, Friends, Friend Comparison, Profile Creation, Enhanced Onboarding
- **3/10 screens:** Settings Screen (architectural problem, not just cosmetic)

### Top 5 Changes for Maximum Impact
1. **Gut Settings Screen** → Instantly makes the app feel 2x more professional
2. **AI loading/error states** → Makes the premium AI features feel premium
3. **Design system audit** → Fix all hardcoded Colors/TextStyles in 1 pass
4. **Weekly Plan interactivity** → Turns a display screen into a daily engagement hook
5. **Reduced motion support** → Accessibility compliance across all celebrations
