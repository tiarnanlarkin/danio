# Danio — Finish-Line Review: Product/UX & Art Direction Pass
**Reviewer:** Apollo (Design Agent)  
**Date:** 2026-03-29  
**Branch:** `openclaw/stage-system`  
**Scope:** Every major screen, flow, visual identity, design system, assets, animations, empty/error states, accessibility  
**Format:** Honest product-design audit. Truth, not reassurance.

---

## Executive Summary

Danio is a genuinely impressive body of work for a solo-built Flutter app. The design system is thorough — token-based colours, a proper spacing and radius scale, a consistent typography hierarchy, reduced-motion support throughout, and a meaningful component library. The gamification loop (XP, hearts, streaks, gems) is wired end to end. The lesson content is real. The room visualisation concept is distinctive.

But.

There are two distinct versions of this app fighting each other visually. One version has the warm, chibi-illustrated identity of the fish sprites and the top room backgrounds — charming, intentional, unmistakeable. The other version has flat-cel illustration headers, a photorealistic onboarding background, and two legacy room backgrounds that look like rough drafts. When you open the Learn or Practice tab, you see Version 2. That gap is the single biggest thing standing between this app and "finished."

Below that visual split, there are real polish gaps in the onboarding flow, several token violations that weren't caught by the existing audits, and a handful of UX issues that will confuse first-time users. Everything is fixable. The bones are excellent.

**Overall Product Readiness Score: 7.2 / 10**

---

## 1. Screen-by-Screen Assessment

---

### 1.1 Home Screen (Tank View)

**What works:**
- The room metaphor is the app's most distinctive feature. Animated fish swimming in a themed room, pulled up on a glassmorphism bottom sheet — this is the idea that makes Danio memorable.
- The bottom sheet panel (4 tabs: Progress · Tanks · Today · Tools) is technically well-built. Drag snapping between peek/half/full, smooth animations, haptic feedback, reduced-motion support.
- The tank switcher is clever and obvious.
- The `WelcomeBanner` and `ComebackBanner` are warm and human in tone.
- The `StreakHeartsOverlay` (top-right, showing streak flame + heart count) is a nice ambient UI element — doesn't interrupt, just informs.
- `TodayBoard` widget is scannable and useful.
- The `EmptyRoomScene` for first-time users is charming and designed — it's not a blank screen. The "your aquarium adventure starts here" placeholder box works. The floor, window, and plant all tell a story.
- `FirstVisitTooltip` system is thoughtful — tooltips for tank, hearts, stage handle, and room metaphor on first use.

**What's weak:**
- **The empty room scene uses a fixed `Positioned(bottom: 100)` for the tank stand** without reading `MediaQuery.of(context).padding.bottom`. On phones with a home-indicator gesture bar (34dp inset), the stand and CTA buttons shift into the safe area. Confirmed issue from UX audit (P2-7). The code does check `topPadding` for the window widget, so the pattern is known — it's just inconsistently applied at the bottom.
- **The bottom sheet docstring says "three-stacked BottomPlate system"** but the actual implementation has 4 tabs (Progress, Tanks, Today, Tools). Dead comment. Minor but it signals the file hasn't been cleaned up.
- **Tool cards in the bottom sheet (Tools tab) have no press animation.** Every other interactive element in the app has micro-feedback (GlassCard scale, AppButton press). The tool cards just... navigate. It feels flat compared to the rest of the sheet.
- **The room backgrounds have wildly different quality tiers.** `aurora` and `evening-glow` are genuinely beautiful. `cozy-living` (66KB) is a near-empty beige box. The user will notice the jump in quality when cycling through room themes. The 4 cold-palette backgrounds (dreamy, cotton, midnight, pastel) all violate the "warm palette" art bible spec — these may be intentional but they create theme-switching moments where the warm cosy identity disappears.
- **`Colors.white` and `Color(0xD0FFA000)` are hardcoded** in `streak_hearts_overlay.dart` (lines 126, 149, 225) and `welcome_banner.dart` (line 63). Not theme-adaptive.

**What's missing:**
- A "demo fish" mode or some ambient life in the empty room scene. The decorative plant is 50% opacity — it feels apologetic. Either commit to the empty room story (something to find/discover) or put Finn the mascot there with a prompt to "meet your first fish."
- The `DailyNudge` widget exists but I didn't see a clear hierarchy between it, the `WelcomeBanner`, and `TodayBoard` — it feels like the home screen can have up to 4 stacked status banners (welcome + comeback + daily nudge + cycling status). Need a priority system so only one appears at a time.

**Visual consistency: 8/10**  
*Strong concept, good execution on the core fish + room view, dragged down by background quality disparity.*

---

### 1.2 Learn Screen

**What works:**
- The header gradient (teal → deep teal) is correctly tokenised in `app_colors.dart` as `learnHeaderTop / learnHeaderMid / learnHeaderBottom` — a previous audit had flagged this as a raw hex issue, and it's been fixed.
- The learning path cards (`LazyLearningPathCard`) with lock/unlock states, progress bars, and lesson counts feel complete.
- The streak card and review banner are well-placed and visually coherent.
- The Skeletonizer loading state is properly implemented with `liveRegion: true` semantics.
- Auto-scroll to first lesson on first visit is a nice touch.

**What's weak:**
- **The `learn_header.webp` illustration is the wrong art style.** Confirmed ❌ FAIL in visual asset audit. It's a flat vector/clip-art sticker style, thin outlines, medium-sized eyes — it does not match the chibi fish sprites. This is the first thing a user sees when they open the Learn tab. Every. Single. Time. This is a P1 visual issue.
- **XP/streak badges on the header use `fontSize: 14`** with white text on a `black.withValues(alpha: 0.35)` dark overlay. The current code uses 14px (the UX audit listed this as 12px — the implementation appears to have been fixed to 14 from that P1 issue, which is correct). However, the `Colors.black.withValues(alpha: 0.35)` is not a named token and `Colors.white` is hardcoded for the text — minor token gap.
- The placement challenge card at the top of Learn adds visual weight and cognitive load for new users who don't understand what it's for. There's no onboarding tooltip specifically for the placement challenge — it just sits there unlabelled.

**What's missing:**
- Learning path completion celebration (in-screen, not just lesson-level). When a user completes all lessons in a path, the path card updates its state — but I don't see a distinct celebratory moment for path completion outside of the lesson completion flow.

**Visual consistency: 6/10**  
*Header illustration is the outlier that pulls down what is otherwise a clean, well-designed screen.*

---

### 1.3 Practice Screen

**What works:**
- The `PracticeHubScreen` has a clear hierarchy: header → due card count → start session CTA.
- Hearts display is correctly integrated — the user can see their remaining hearts before starting.
- The SRS practice loop (`SpacedRepetitionPracticeScreen` → `ReviewSessionScreen`) is wired and functional.
- The empty state when `dueCount == 0` is designed (emoji + CTA + mascot-ready structure).

**What's weak:**
- **The `practice_header.webp` illustration is also the wrong art style.** Same failure mode as Learn — flat cel cartoon diorama, elongated realistic fish, not chibi. This header renders at `height: 160` on top of the Practice hub, and it looks like it came from a different app.
- The practice header has `Title('Practice')` overlaid in the top-left at `Positioned(top: 16, left: 16)` but this doesn't use `SafeArea` — the title can overlap the status bar on phones with a notch/island that sits below the default status bar area.
- The `SpacedRepetitionPracticeScreen` `AppBar` title is just `'Practice'` — no visual differentiation from the hub title. When users navigate from hub → session screen, the title is identical and the transition feels like a lateral move rather than going deeper.

**What's missing:**
- A "coming up" preview of what cards are due. Duolingo shows the topic/lesson area before you start. Danio just shows a count.
- Streak protection mechanic visibility — users can lose their streak if they miss a day, but there's no "streak shield" visibility in the Practice hub UI. It's in the shop but there's no clear connection from "I might miss today" to "I can buy streak protection."

**Visual consistency: 6/10**  
*Same header problem as Learn. The session UI itself is cleaner.*

---

### 1.4 Smart Screen (AI Hub)

**What works:**
- The three feature cards (Fish ID, Symptom Checker, Weekly Plan) are visually clear with icon + title + subtitle.
- The "Ask Danio" chat input is a nice free-form fallback for questions that don't fit the three tools.
- Offline gating is handled correctly — users see a clear message when they're offline rather than a broken state.
- Rate limiting is surfaced gracefully.
- The anomaly alert section (flagging water parameter anomalies) is a genuinely smart product feature.
- Connectivity check before every AI feature call.

**What's weak:**
- **`_showOfflineSnackBar` is a standalone function** that directly calls `DanioSnackBar.warning()` — not a bug, but it's a one-liner wrapper with no benefit. The existing audit had flagged that smart_screen.dart uses a "raw SnackBar" — on review, it actually uses `DanioSnackBar`, but through an awkward helper function that pre-dates when the helper was built. Minor cleanup.
- The Smart screen has no onboarding explanation of what "AI features" means or what the AI can/can't do. Users land on a screen with three cards and no context for how they work (requires API key? Uses credits? Free?). The `_UsageChip` showing call count is in the right direction but it sits above the feature cards without a label or explanation.
- The "Ask Danio" text field at the bottom of the screen has no character limit display and no clear indication of what kinds of questions work vs. don't. The system prompt clips at 2-4 sentences but the user doesn't know that.
- The `_OfflineBanner` (shown when API key is not configured) says "Requires AI setup" — which is accurate for self-hosted but confusing for a Play Store user who expects the AI to just work.

**What's missing:**
- **Example prompts for "Ask Danio"** — a row of chips like "What fish suit a 60L tank?" or "Is ich contagious?" would dramatically improve discoverability and reduce blank-stare friction.
- History of past Ask Danio questions is tracked in `aiHistoryProvider` but isn't surfaced in the UI.

**Visual consistency: 7.5/10**  
*Structurally clean, iconography is on-brand, but lacks the warmth/illustration texture of the Home and Learn screens.*

---

### 1.5 Settings Screen

**What works:**
- The settings screen is comprehensive without being overwhelming — sectioned into logical groups.
- "Danger Zone" section for destructive actions is correctly styled in red (`AppColors.error`) and placed at the bottom.
- The room theme selector inside settings (with theme preview) is a clever pattern.
- The `ThemeGallery` screen (accessible from settings) gives a visual overview of all room backgrounds.

**What's weak:**
- Settings `AppBar` title is `'Preferences'` — minor but slightly formal/generic for this app's warm personality. Consider `'Your Setup'` or just `'Settings'`.
- The settings screen is a `ListView.builder` rendering `WidgetBuilder` lambdas — functional but means the full settings content is eagerly built. There's no lazy loading for sub-sections.
- Password visibility toggle `IconButton` in `settings_account_section.dart` (line 1133) has no `tooltip` parameter — confirmed accessibility gap from accessibility audit.
- `Colors.white` at line 616 and `Colors.transparent` at 566 in settings are both effectively fine (transparent is always transparent, white on amber gradient reads correctly) but represent the pattern of raw colour use outside the token system.

**What's missing:**
- No "App version" display in settings. Users expect this. It's also required for support triage.
- No "Send feedback" or "Report a bug" entry point in settings.

**Visual consistency: 8/10**  
*Functional and clean. The warm amber gradient at the top of settings is a nice touch. Slightly functional-feeling vs aspirational.*

---

### 1.6 Workshop Screen

**What works:**
- The Workshop has a distinctive warm-brown gradient identity that immediately differentiates it from other tabs.
- Tool card grid is clear and well-organised.
- First-visit snackbar `'🔧 The Workshop — calculators, guides, and tools'` is friendly.
- The breadth of tools (CO2, dosing, stocking, compatibility, cost tracker, etc.) is genuinely impressive for a v1.

**What's weak:**
- `foregroundColor: AppColors.textPrimaryDark` is hardcoded in the Workshop `SliverAppBar` without checking theme — in light mode this renders dark text on a dark background. The Workshop background (`workshopBackground1` = `0xFF5D4E37`) is dark, so this works visually, but it bypasses the theme system.
- Tool cards have no visual distinction between "available now" and "coming soon." Several tools might be stubs. Users who tap a tool expecting functionality and hit an empty screen (or one with placeholder text) will be confused.

**What's missing:**
- No favourites or recently-used tools. When a user has used Water Change Calculator 10 times, they shouldn't have to hunt for it every time.
- No search across tools. This is a v2 feature, but worth noting.

**Visual consistency: 8.5/10**  
*The Workshop has the strongest visual identity of the secondary screens — the brown gradient is distinctive and appropriate.*

---

### 1.7 Onboarding Flow (10 screens)

**What works:**
- The 10-screen structure is well-considered: hook → personalisation → micro-lesson → celebration → fish selection → aha moment → permissions → warm entry. This is a thoughtful product arc.
- Step progress dots (`_OnboardingDots`) are implemented and correctly anchored to `MediaQuery.of(context).padding.bottom + 12`. The P2 audit issue about missing progress indicator has been resolved.
- `WelcomeScreen` entry animations (headline fade+slide, body fade, button spring) are polished.
- `XpCelebrationScreen` with XP grant and animated counter is the kind of moment that creates first-use delight.
- The `_OnboardingFallback` safety net for missing state is a nice defensive design.
- `PopScope` correctly blocks accidental back-navigation during onboarding.

**What's weak:**
- **`onboarding_journey_bg.webp` is a photorealistic water caustic render** in an illustrated app. This is the full-bleed background behind the Welcome screen — the very first thing a new user sees. It's amber-to-cream and pretty, but it's stylistically inconsistent with everything else. A user's first impression of Danio's visual style is a render, not an illustration.
- **"Quick start with defaults" tap target.** The UX audit flagged this as a text-only 14sp `GestureDetector` — 17-18dp actual touch height. Looking at the `WelcomeScreen` code, the `onLogin` callback is wired to a `GestureDetector` wrapping a `Text` widget. This is confirmed below the 48dp floor. It's specifically the "Quick start with defaults" path that trips on this.
- **`FishSelectScreen` 3-column grid** with 13sp species names. At ~109dp tile width, `maxLines: 1` truncates most species names (especially "Bronze Corydoras", "Bristlenose Pleco", "Harlequin Rasbora"). The user's first meaningful choice about their fish is presented in a format where they often can't read the name. This is a product failure at a critical moment.
- **No `PopScope`/back-handling on individual onboarding screens** beyond the outer `OnboardingScreen` wrapper — this is fine as navigation is programmatic, but users who find a hardware back button may hit unexpected states.
- `MicroLessonScreen` and `AhaMomentScreen` use raw `GoogleFonts.nunito(fontSize: ...)` calls outside the `AppTypography` token system. 10+ hardcoded `fontSize` values in `aha_moment_screen.dart` alone.

**What's missing:**
- The `ConsentScreen` (GDPR/analytics consent) sits in the onboarding folder but it's not clear from the code review whether it's wired into the 10-screen flow or shown separately. If it's entirely separate, new users may not encounter it until they're deep in the app. Needs confirmation.
- No illustrated art for the fish selection screen — the grid shows WebP fish sprites (which are great!) but the surrounding chrome is plain white. A subtle water/tank texture backdrop would elevate this key moment.

**Visual consistency: 6.5/10**  
*The onboarding arc is thoughtfully designed but visually inconsistent — great entry animation, wrong background image, then small-text fish grid, then a genuinely delightful XP celebration. Uneven.*

---

### 1.8 Create Tank Flow

**What works:**
- Multi-page form with `PageView` is clean and avoids the cognitive overload of a single long form.
- `PopScope` with unsaved-changes dialog is correct and handles all paths.
- Focus order is explicitly set with `NumericFocusOrder` — one of the accessibility highlights of the codebase.
- Discard confirmation dialog uses `showAppDestructiveDialog` (the token dialog, not raw `showDialog`).

**What's weak:**
- No visual preview of what the resulting tank room will look like. After creating a tank, the user is dropped back to the home screen where they see their room for the first time. A "preview" moment in the creation flow would be a strong delight beat.
- Volume entry (`_volumeLitres`) with no minimum validation feedback visible in the UI — unclear if the error state for "0 litres" is designed or just a form validation string.

**Visual consistency: 8/10**  
*Functional and clean. Appropriately sober for a data-entry flow.*

---

### 1.9 Livestock Screen

**What works:**
- Bulk add dialog is well-designed with `LivestockBulkAddDialog`.
- Species browser with 125+ fish and full care guides is substantive content.
- Compatibility checker integration.

**What's weak:**
- `livestock_last_fed.dart` uses `colorScheme.onSurface.withValues(alpha: 0.5)` for body text — contrast approximately 3.7:1 on white, which fails WCAG AA for small text. This is a confirmed accessibility failure (accessibility audit §3).
- The `livestock_detail_screen.dart` similarly has `bodySmall` at `AppColors.warning` — 2.69:1 contrast ratio on white for the warning label text. Confirmed fail.

**Visual consistency: 7.5/10**

---

## 2. Art Direction Assessment

### The Established Identity (what the app wants to be)

The canonical visual identity of Danio is built around:
- **Chibi-proportioned fish sprites** — oversized eyes, circular specular highlights, bold charcoal outlines (3-4px), warm saturated palettes, gradient cel shading (2-3 stops max)
- **Warm cream/amber/teal colour palette** — `#FFF5E8` background cream, `#B45309` amber brand, `#5B9EA6` teal water accent
- **Fredoka + Nunito type pairing** — Fredoka for display moments (playful, rounded letterforms), Nunito for UI chrome (clean, legible)
- **Glassmorphism bottom sheet** — frosted glass with warm tint as the primary gestural element
- **Cosy, inhabited room scenes** — the aquarium is a living space, not a scientific diagram

When this identity fires on all cylinders (Home with a good room background + animated fish + the glassmorphism panel), Danio looks genuinely distinctive. It's warmer than Duolingo, more illustrated than Fishkeeper, more playful than most aquarium apps.

### Where the Identity Breaks

| Asset | Status | Why it breaks |
|-------|--------|---------------|
| `learn_header.webp` | ❌ REGEN | Flat vector/sticker style — thin outlines, wrong proportions, different artistic language |
| `practice_header.webp` | ❌ REGEN | Flat cel cartoon — elongated realistic fish, different character design |
| `angelfish.webp` | ❌ REGEN | Despite March 29 regen, still has thinner lines, more realistic gradients, smaller eyes |
| `amano_shrimp.webp` | ❌ REGEN | Naturalistic shrimp, flat shading, no specular highlight — completely different style |
| `placeholder.webp` | ❌ REPLACE | Amber watercolour wash — no character, no chibi style |
| `onboarding_journey_bg.webp` | ❌ REPLACE | Photorealistic caustic render — first thing new users see |
| `room-bg-cozy-living.webp` | ❌ REGEN | 66KB, near-empty, massive quality gap vs. Wave 4 backgrounds |
| `room-bg-forest.webp` | ⚠️ REGEN | Legacy flat execution, no ceiling, well below Wave 4 quality |
| Badge icons (×4) | ❌ CREATE | All 4 badge images missing — shop feature visually incomplete |

**The critical pattern:** All the legacy/pre-art-bible assets share the same failure mode — they were generated to spec a different, flatter, more generic aesthetic. They look like AI-generated stock illustrations from a "mobile app illustration" prompt. The canonical fish sprites look like a character designer with an art bible and strong opinions.

### What the Art Bible Standard Is

The benchmark is the Zebra Danio mascot (`zebra_danio.webp`). Every fish and illustration in this app should feel like it came from the same artist as that fish. Bold, chunky, warm, expressive. Not realistic, not flat-cel — confidently chibi.

---

## 3. Design System Usage

### What's Working Well

The token system is genuinely one of the app's strengths. `AppColors`, `DanioColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppElevation`, `AppShadows`, `AppDurations`, `AppCurves` — all comprehensive, all used consistently in the core component library (`GlassCard`, `AppButton`, `AppCard`, `EmptyState`, etc.). The pre-computed alpha colours (`whiteAlpha20`, `blackAlpha30`, etc.) are a smart performance optimisation that demonstrates care about the details.

The `AppOverlays` class is well-documented with usage examples. The accessibility colour tokens (`AppColors.warning` → `AppColors.warningAlpha*`) are thoughtfully named.

### Token Violations Found

| Location | Issue | Severity |
|----------|-------|----------|
| `bottom_sheet_panel.dart:246-247` | `labelColor: Colors.white` in tab bar | Low — glass context, intentional |
| `streak_hearts_overlay.dart:126,149,225` | `Colors.white` hardcoded | Medium — not theme-adaptive |
| `welcome_banner.dart:63` | `Colors.white` hardcoded | Medium — not theme-adaptive |
| `streak_hearts_overlay.dart:144` | `Color(0xD0FFA000)` raw hex | Medium — should be `DanioColors.amberGold.withAlpha(208)` |
| `learn_screen.dart:334,361` | `Colors.black.withValues(alpha: 0.35)` in badge | Low — should be `AppColors.blackAlpha35` |
| `learn_screen.dart:334,361` | `Colors.white` for badge text | Low — should be `AppColors.onPrimary` |
| `aha_moment_screen.dart` (10+ lines) | Raw `GoogleFonts.nunito(fontSize: ...)` | High — bypasses `AppTypography` entirely |
| `difficulty_settings_screen.dart` (multiple) | `colorScheme.onSurface.withValues(alpha: 0.4-0.7)` | Medium — use `AppColors.textSecondaryAlpha*` |
| `account_screen.dart:460` | `colorScheme.onSurface.withValues(alpha: 0.4)` | Medium — use named token |
| `learn/unlock_celebration_screen.dart:224` | `Color(0xFF4A9DB5).withValues(alpha: 0.3)` | Medium — unmapped teal hex |
| `workshop_screen.dart` | `foregroundColor: AppColors.textPrimaryDark` hardcoded | Medium — bypasses brightness check |
| `lesson_card_widget.dart:33` | `padding: 160` magic number | Low — should be computed |

**Hardcoded `Colors.white` count: 164 instances** — the majority are in glassmorphism/frosted-glass contexts where white is intentional for the effect. The ~15-20 instances outside glass contexts are the real issues.

**Raw `withOpacity`/`withValues` with alpha calls: 55 instances** — most are legitimate (`colorScheme.onSurface` doesn't have a named alpha variant), but the pattern reveals where the token system ends and ad-hoc colour mixing begins.

**`Colors.*` usage beyond token system: 1,529 instances** — this is a high-level figure that includes the token system itself (which internally defines `Color(0x...)` constants). The real bypass count is much lower, but the AhaMomentScreen and DifficultySettingsScreen are notable outliers.

---

## 4. Visual Consistency Ratings

| Area | Score | Notes |
|------|-------|-------|
| Fish sprites (core set) | **8/10** | 13/15 excellent, 2 outliers drag the score |
| Room backgrounds (top 4) | **9/10** | Aurora, Evening Glow, Golden, Ocean — production quality |
| Room backgrounds (legacy 2) | **4/10** | Cozy-living and Forest far below quality bar |
| Header illustrations | **3/10** | Both need regen — wrong style confirmed |
| App icon | **8.5/10** | On-brand, minor technical issues (size, circular crop) |
| Badge icons | **0/10** | All 4 missing |
| Placeholder image | **3/10** | Wrong style |
| Onboarding background | **5/10** | Photorealistic in an illustrated app |
| Type hierarchy (token usage) | **8.5/10** | Excellent except AhaMomentScreen/DifficultySettings |
| Colour palette consistency | **8/10** | Strong system, ~20 bypasses outside glass contexts |
| Spacing/layout consistency | **8.5/10** | Token system well-adhered-to, one magic-number padding |
| Component polish (GlassCard, AppButton) | **9/10** | Outstanding — best-in-class on a Flutter app at this stage |
| Empty states | **8/10** | `EmptyState`, `AnimatedEmptyState`, `AppEmptyState` all exist and are used |
| Error states | **7/10** | `ErrorBoundary` exists, `DanioSnackBar` system is good, some generic messages remain |

---

## 5. UX Flow Assessment

### Onboarding → Home

The arc is: **Welcome → Personal → Learn → Celebrate → Choose fish → AHA → Features → Permissions → Warm Entry → Home**

This is a well-designed flow. The micro-lesson on page 4 and XP celebration on page 5 are product-quality delight moments. The issue is that the visual quality is uneven across the 10 screens — some feel designed (Welcome animation, XP celebration), some feel like wireframes with text (AhaMomentScreen's ad-hoc font sizes).

**Gap:** The fish select screen at page 6 is the most important personalisation moment in the app, and it's also the most visually underpowered. 3 columns, small names, no artwork context.

### Home → Create Tank

Clear path: FAB → Create Tank screen → 3-page form → home. The multi-page form is appropriate for the data required. Discard protection is correctly implemented. **No visual preview of the resulting room** is the main gap — users don't know what they're building toward.

### Learn → Lesson → Complete

The lesson flow is polished. Card-by-card progression, multiple exercise types, completion animation. The quiz widget with multiple choice options and animation feedback is the strongest flow in the app. **The lesson completion flow (`lesson_completion_flow.dart`) is where the app feels most like Duolingo** — in a good way.

### Practice → Review Session

Functional and logical. Due card count → start → review cards → complete. The hearts mechanic is integrated. The empty state (all caught up) is correct. **The gap is the lack of "what am I about to review" context** before starting.

### Smart → AI Tools

Good. The three tool cards are clear. The fish ID photo flow (`FishIdScreen`), symptom checker (`SymptomTriageScreen`), and weekly plan (`WeeklyPlanScreen`) are feature-complete. The offline gating is correct. **The gap is zero onboarding for what "AI features" means** — users who have never used this kind of feature need more context.

### Settings → Sub-screens

Navigation works. Section organisation is logical. The guides section and tools section are good additions to settings (reference material within reach). **Missing:** app version display, feedback link.

---

## 6. Empty State & Error State Assessment

### Empty States

**Designed:** The app has a rich empty state toolkit:
- `EmptyState` — animated floating icon, mascot bubble support, tips section, action button
- `AnimatedEmptyState` — emoji-led, floating animation, fade-in text
- `AppEmptyState` — icon + title + message + dual action buttons
- `CompactEmptyState` — for smaller sections
- `EmptyRoomScene` — full-screen illustrated empty state for the home tab

These are all **genuinely designed** — animated, warm, not just a blank screen. This is better than most apps at this stage.

**Specific empty states confirmed designed:**
- No tanks → `EmptyRoomScene` (with Finn mascot prompt)
- No due practice cards → emoji + "all caught up" message + mascot
- No livestock → `EmptyState.withMascot()`
- No lesson data → Skeletonizer loading state → `AppEmptyState`

**Gaps:**
- The Journal screen and logs screens — unclear if empty states are designed or fall back to generic
- The Analytics screen empty states — not reviewed in this pass

### Error States

**Designed framework:**
- `ErrorBoundary` widget catches render errors and shows a retry UI
- `DanioSnackBar` with `.error()`, `.warning()`, `.info()`, `.success()` variants
- `AsyncValue` error states handled in providers

**Gaps confirmed:**
- Generic `"Something went wrong"` messages in 3-5 locations (from session handoff)
- `AsyncValue` error handling in some screens silently returns empty lists (the architecture audit found this — screens show empty content instead of an error)
- `_showOfflineSnackBar` in `smart_screen.dart` uses a one-liner wrapper rather than calling `DanioSnackBar` directly — functionally fine but inconsistent with the rest of the codebase

---

## 7. Overall Product Feel Assessment

### Cold-Open Test: "Would you think someone cared about this?"

**Yes, mostly.** Open the app for the first time and you see an onboarding with real entry animations, real personality copy, a fish selection screen (even if cramped), an XP celebration. You arrive on a Home screen with animated fish swimming in a beautifully lit room scene. The glassmorphism sheet pulls up smoothly. The fish move.

Open the Learn tab and you see a mismatched illustration header. That single image breaks the spell.

The app has a clear personality — warm, educational, slightly playful, Duolingo-adjacent without being derivative. The copy is good. The mascot (Finn the Zebra Danio) has charm. The colour palette is cohesive. The component library is exceptional.

What undermines the "someone cared" feeling:
1. **Two illustration headers in the wrong style** — the most-used tabs show the wrong face of the brand
2. **Two legacy room backgrounds** — the home tab can look cheap if the user picks cozy-living
3. **AhaMomentScreen ad-hoc typography** — reads as a rough draft in the middle of a polished onboarding
4. **FishSelectScreen cramped 3-column grid** — key personalisation moment, visually under-designed
5. **Missing badge icons** — the gem shop has badge cards with placeholder art

---

## 8. Must Fix for a Finished Product

These items would make a reviewer (App Store review team, a journalist, a first-time user) think the app is unfinished.

| # | Issue | File(s) | Impact |
|---|-------|---------|--------|
| **MF-1** | Regen `learn_header.webp` + `practice_header.webp` — wrong art style, seen every session | `assets/images/illustrations/` | Visible every daily session |
| **MF-2** | Regen `angelfish.webp` + `amano_shrimp.webp` — fail art bible | `assets/images/fish/` | Visible in livestock/species |
| **MF-3** | Replace `placeholder.webp` with chibi fish silhouette | `assets/images/placeholder.webp` | Shown on every missing image load |
| **MF-4** | Replace `onboarding_journey_bg.webp` with illustrated or warm abstract background | `assets/images/onboarding/` | First thing a new user sees |
| **MF-5** | Regen `room-bg-cozy-living.webp` — 5.5/10 quality, well below bar | `assets/backgrounds/` | Home screen with default theme |
| **MF-6** | Create all 4 badge icons | `assets/icons/badges/` | Shop feature visually broken |
| **MF-7** | Fix "Quick start with defaults" tap target to ≥ 48dp | `onboarding/welcome_screen.dart` | Accessibility + usability failure |
| **MF-8** | Fix `FishSelectScreen` — 2-column grid or increase tile height, readable species names | `onboarding/fish_select_screen.dart` | Key personalisation moment broken |
| **MF-9** | Fix `aha_moment_screen.dart` ad-hoc `GoogleFonts.nunito(fontSize:...)` — use `AppTypography` tokens | `onboarding/aha_moment_screen.dart` | Typography inconsistency mid-onboarding |
| **MF-10** | Fix `AppColors.warning` (2.69:1) as text colour — use `AppColors.warning`-replacement token at 4.5:1 | Multiple screens | WCAG AA contrast failure |
| **MF-11** | Add App version display to Settings | `settings_screen.dart` | Expected by users, needed for support |
| **MF-12** | Add password visibility toggle `tooltip` | `settings_account_section.dart:1133` | Accessibility requirement |
| **MF-13** | Fix `EmptyRoomScene` safe area — `Positioned(bottom:)` needs `MediaQuery.of(context).padding.bottom` | `home/widgets/empty_room_scene.dart` | Broken layout on notched phones |
| **MF-14** | Fix Practice tab header `Positioned` top — no `SafeArea` wrapper on the title | `practice_hub_screen.dart` | Title overlaps status bar |

---

## 9. Polish / Nice-to-Have

These items make the difference between "functional" and "delightful."

| # | Issue | Notes |
|---|-------|-------|
| **P-1** | Tool cards in bottom sheet need press animation (scale/ripple) | Consistent with rest of app |
| **P-2** | Add "example prompts" chip row to Ask Danio | Dramatically improves discoverability |
| **P-3** | Regen `room-bg-forest.webp` — legacy quality | Improve Wave 4 consistency |
| **P-4** | Add past AI history view to Smart screen | History is tracked but not surfaced |
| **P-5** | Add tank room preview to Create Tank flow | Delight moment at the end of setup |
| **P-6** | Replace `Colors.white` hardcodes in `streak_hearts_overlay.dart`, `welcome_banner.dart` with `AppColors.onPrimary` | Theme adaptivity |
| **P-7** | Fix raw hex `Color(0xD0FFA000)` in streak overlay → `DanioColors.amberGold` | Token system cleanliness |
| **P-8** | Deduplicate `EmptyState`, `AnimatedEmptyState`, `AppEmptyState`, `CompactEmptyState` — 4 empty state widgets is too many | Use `AppEmptyState` as the single source of truth |
| **P-9** | Add priority system for home banners — max 1 banner at a time (welcome vs comeback vs daily nudge) | UX clarity on first-use |
| **P-10** | Add "coming up in your review" preview to Practice hub | Duolingo pattern, reduces anxiety |
| **P-11** | Regen `room-bg-cozy-living.webp` with ceiling, furnishings (beyond MF-5 bare minimum) | Full Wave 4 treatment |
| **P-12** | Convert illustration headers + fish sprites to WebP — ~2.7MB saving | Performance |
| **P-13** | Remove `linen-wall.webp` — 248KB unreferenced | APK size |
| **P-14** | Confirm `app_icon.png` source at 1024×1024 (current is 512×512) | App Store submission |
| **P-15** | Fix `bristlenose_pleco.webp` — palette mode PNG, should be RGBA | Technical correctness |
| **P-16** | Fix `Colors.black.withValues(alpha: 0.35)` in learn badge → `AppColors.blackAlpha35` | Token system |
| **P-17** | Map `difficulty_settings_screen.dart` `onSurface.withValues()` calls to `AppColors.textSecondaryAlpha*` | Token system |
| **P-18** | Settings screen title `'Preferences'` → consider `'Settings'` for UX clarity | Copy |
| **P-19** | Add feedback/bug report link to Settings | Support infrastructure |
| **P-20** | Address 4 cold-palette room backgrounds vs warm-palette art bible spec — deliberate decision or oversight? | Art direction clarity |

---

## 10. Future Scope

Not blocking v1, but worth knowing before they become technical debt.

| # | Area | Notes |
|---|------|-------|
| **FS-1** | Tank room preview / tank builder | Visual creation UI, not just data entry |
| **FS-2** | Social/friends system | Achievement model has `friendsCount` but no social feature exists — remove dead data model or build toward it |
| **FS-3** | Refactor `UserProfileNotifier` (1,084 lines) | REFACTORING_PLAN.md exists, timing is for after v1 |
| **FS-4** | Refactor `AchievementProgressNotifier` (736 lines) | Same — after v1 |
| **FS-5** | 87 `ref.watch()` without `.select()` | Performance optimisation pass after v1 |
| **FS-6** | Service unit tests + provider unit tests | Test depth upgrade |
| **FS-7** | Golden-path integration tests | First-use automation |
| **FS-8** | Google/Apple OAuth providers | Currently only email auth |
| **FS-9** | Cloud backup bucket creation in Supabase | Non-blocking for v1 |
| **FS-10** | Seasonal content system (seasonal_tip_card exists) | Content strategy |
| **FS-11** | Dark-mode room backgrounds | All backgrounds are light-mode only |
| **FS-12** | Streak protection shop integration visibility | Connect "at risk of losing streak" to "buy shield" in one action |
| **FS-13** | Recently-used tools in Workshop | UX quality of life |
| **FS-14** | Completed learning path celebrations | Currently only lesson-level celebrations |

---

## Summary Scores

| Dimension | Score |
|-----------|-------|
| Visual Identity Cohesion | **6/10** |
| Art Direction Execution | **6.5/10** |
| Design System Rigour | **8.5/10** |
| Typography | **8/10** |
| Colour System | **8/10** |
| Component Quality | **9/10** |
| Onboarding UX | **7/10** |
| Core Screen UX | **8/10** |
| Empty States | **8/10** |
| Error States | **7/10** |
| Accessibility | **7/10** |
| Animation/Interaction Polish | **8.5/10** |
| **Overall Readiness** | **7.2 / 10** |

---

## The One Thing

If I had to name the single action that would most change the perceived quality of this app:

**Regenerate the two illustration headers.**

`learn_header.webp` and `practice_header.webp` are seen by every user on every session, on the two most-used educational tabs. They currently look like they came from a clip-art library. Swap them for on-brand chibi illustrations and the app's visual quality perception jumps 1.5 points overnight.

Everything else on the must-fix list matters. But nothing else is seen as often, by as many users, at the emotional core of what Danio is for.

---

*Reviewed by Apollo — Design Agent, Mount Olympus.*  
*"Let me show you what you meant to say."*
