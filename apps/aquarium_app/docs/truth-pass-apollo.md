# TRUTH PASS — First-Impression & Emotional Layer Test
**Auditor:** Apollo (Design Subagent)  
**Date:** 2026-03-29  
**Repo:** `apps/aquarium_app`  
**Method:** Adversarial. No protection of prior work.  
**Prior rating under review:** 7.2/10

---

> *"Let me show you what you meant to say."*  
> This document will show you what the app is actually saying — versus what we hoped it would say.

---

## SECTION 1 — First-Impression Destruction

### The onboarding sequence (per `onboarding_screen.dart`, lines 301–393):
```
ConsentScreen → WelcomeScreen → ExperienceLevel → TankStatus → MicroLesson 
→ XpCelebration → FishSelect → AhaMoment → FeatureSummary → PushPermission → WarmEntry
```
That's **11 screens** before reaching the app. Duolingo does it in 4.

---

### 💀 FIRST moment that breaks the "someone cared" feeling

**File:** `main.dart` lines 354–360 / `consent_screen.dart`  
**What the user sees:** The app opens and the VERY FIRST SCREEN is a legal compliance wall.  
Not a beautiful splash. Not a hook. A `Icons.privacy_tip_outlined` icon (a Material system icon — not even a custom illustration) and two checkboxes before you've seen a single fish.

Before the user knows what Danio *is*, before they've seen the gorgeous welcome screen with its background illustration and "Your fish deserve better than guesswork" — they are filling out a GDPR form.

The consent screen design is functional but completely generic. The icon is the same one a bank app uses. The only brand signal is the primary colour on the checkboxes. There's no fish. No personality. No reason to tick "Yes."

**The specific insult:** `Icons.privacy_tip_outlined` at `consent_screen.dart:98`. This is a Material Design outline shield-with-an-"i". It communicates "legal obligation" not "we care about you." Compare: Duolingo's consent is handled inline after you've already bonded with Duo. We cold-open with it.

**Fix needed:** Move consent to page 8 (after AhaMoment, when the user is bought in). Or: make the consent screen feel like Danio with a fish illustration, warm copy, and brand voice. "We only collect what helps your fish" is better than "We only use anonymous analytics to understand how people use Danio."

---

### 💀 SECOND moment that breaks the "someone cared" feeling

**File:** `welcome_screen.dart` lines 200–209  
**What the user sees:** The secondary CTA reads: `'Skip setup, I\'ll explore first'`

This is the wrong promise. If you tap it, it calls `_quickStart()` which creates a default 60L unnamed "My Tank" and drops you straight into the home screen — a near-empty tank with a snackbar that says *"We've set up a 60L starter tank for you — you can change this in Settings"*.

You invited them to "explore first." What they explore is a blank room with a demo tank. The promise and the delivery don't match. The copy says "explore" but the outcome is "we made you a placeholder."

**The secondary wound:** On the WelcomeScreen, the button label says `"Let's get started →"`. Every app that has ever existed says this. It is noise. The Danio-worthy version would be something like *"Set up my tank"* or *"Show me what Danio does."*

**File:** `welcome_screen.dart` line 192 — button label `"Let's get started →"` is generic.

---

### 💀 THIRD moment that breaks the "someone cared" feeling

**File:** `onboarding_screen.dart` lines 357–362  
**What the user sees (if they chose `'cycling'` or `'planning'` for tank status):** At the end of onboarding, the auto-created tank is named:
- `'Cycling Tank'` (for cycling status)
- `'My Tank'` (for active)  
- `'New Tank'` (for planning)

These three names, from `onboarding_screen.dart` lines 188–193, are the most forgettable names in app history. The user just spent 10+ screens telling us about their fish. We named their tank "New Tank."

Worse: the tank volume is hardcoded to 60 litres regardless of what anyone said during onboarding. Nobody asked tank size. The app that promises to personalise care just put every single user in a 60L default.

**The compound fracture:** `onboarding_screen.dart` line 196 — `volumeLitres: 60`. Every user. Every fish. 60 litres. A Betta keeper gets 60L. An Angelfish keeper gets 60L. A beginner who said "I'm setting up my first tank" gets 60L and has no idea if that's right.

---

## SECTION 2 — Returning User Test

### Day 2 — What does the user see?

**File:** `home_screen.dart` `_checkReturningUserFlow()` lines 160–199  
**File:** `returning_user_flows.dart` `Day2StreakPrompt`

The Day 2 trigger fires if: `daysSinceSignup >= 1 && daysSinceSignup <= 2 && currentStreak >= 1 && !seen_day2_prompt`.

The widget exists. The animation exists. The copy is decent: *"Day 2 🔥 Your streak is alive. Keep it going."*

**What's broken:** The Day 2 prompt is a bottom sheet / dialog triggered by `showAppDialog`. But it only shows once, ever (`seen_day2_prompt` pref is set immediately). If the user dismisses it, they never see it again. If they return on Day 3 instead of Day 2 (the window is only 24 hours wide), they see nothing. Day 3 returning users get a blank, context-free home screen.

**The Daily Loop:** There is no persistent daily loop indicator on the home screen. The `DailyNudgeBanner` widget (`widgets/daily_nudge.dart`) is dismissible — once dismissed, `_dailyNudgeDismissed = true` — and it's a session-only flag (not persisted). So it comes back on every cold launch. But there's nothing that says "you have a lesson today" or "your streak is at risk" if the user opens the app at 11pm and hasn't done anything.

The `DailyGoalCard` widget exists (`daily_goal_progress.dart`) and is well-built, but it's buried in the gamification dashboard behind the bottom sheet, not surfaced front-and-centre on the home screen.

---

### Day 7 — What does the user see?

**File:** `home_screen.dart` lines 171–179

Trigger condition: `daysSinceSignup >= 7 && daysSinceSignup <= 8 && currentStreak >= 5`.

**🚨 Bug / Design flaw:** Day 7 milestone requires a **5-day streak** to show. You can use Danio for 7 days, have a 4-day streak (perfectly reasonable — one missed day in a week), and the Day 7 card **never appears**. 

`Day7MilestoneCard` is a beautiful card — gold gradient, `+50 XP bonus`, trophy emoji. But the condition that unlocks it is stricter than necessary. A user who's been with the app for 7 days has *already* beaten day 7 retention. They deserve the celebration regardless of streak count.

**Empty state after Day 7 milestone:** The card is shown once, `seen_day7_milestone` is set, and then the home screen returns to its default state. There's no persistent Day 7 marker. No badge. No title. The user earned "Apprentice Fishkeeper" but there's nowhere to see that title displayed on the home screen. It exists only as a semantic label in `Day7MilestoneCard`.

---

### Day 30 — What does the user see?

**File:** `home_screen.dart` lines 180–192  
**File:** `returning_user_flows.dart` `Day30CommittedCard`

Trigger condition: `daysSinceSignup >= 30 && daysSinceSignup <= 31 && currentStreak >= 1`.

The Day30 card shows `lessonsCompleted` count and `xpEarned` total, then soft-upsells with *"See what's waiting for you →"*. The `onUpgrade` callback just calls `Navigator.of(context).pop()`. There is **no upgrade screen behind this button.** The user taps "See what's waiting for you" and the dialog closes. Nothing happens.

**File:** `returning_user_flows.dart` line ~330 — `onUpgrade: () => Navigator.of(context).pop()`.

This is a conversion moment that goes nowhere. At 30 days, a committed user is ready to see what premium looks like. We show them a door, they open it, and there's a wall.

---

### Where the daily loop is broken

1. **No home screen daily goal widget visible by default.** `DailyGoalCard` is in the gamification dashboard (in the bottom sheet), not on the main view. User opens the app and sees their tank — no prompt, no progress bar, no reason to do the one daily action.

2. **Streak display is absent on home screen when there's no milestone.** The streak is visible in the learn screen (`learn_streak_card.dart`) but the home screen doesn't show a persistent streak counter unless you open the gamification dashboard.

3. **The `DailyNudgeBanner` is the only home-screen prompt**, but it only shows once per session and its messaging is generic (not personalised to the daily goal progress).

4. **The comeback banner** (`comeback_banner.dart`) fires if the user was away 2+ days and missed a streak. The logic in `home_screen.dart` lines 142–155 is correct. But after the banner auto-dismisses (4 seconds), there's nothing left to motivate the user. No "here's what you missed, let's fix it."

---

## SECTION 3 — Emotional Layer

### Where the app makes you FEEL something ✅

1. **The AhaMoment screen** (`aha_moment_screen.dart`) — The 3-phase reveal with "Building your Neon Tetra care guide..." loading dots, then card cascade, then personalised motivation text is genuinely clever. The first time it works, it feels like magic. This is the app at its best.

2. **The XpCelebration screen** (`xp_celebration_screen.dart`) — The confetti burst + badge pop + progress bar fill sequence is tight and satisfying. 30 particles, proper gravity physics, elastic button entry. This feels crafted.

3. **Fish tap interaction** (`fish_tap_interaction.dart`) — The wiggle bus + ripple + fish facts dialog is a genuine delight discovery. When a user randomly taps the tank and their fish wiggles and a fun fact appears, that's a moment. The problem is discoverability (no affordance, no hint).

4. **The WarmEntry name collection** (`warm_entry_screen.dart`) — Asking for your name here, mid-flow, after you've already bonded with your fish, is psychologically smart. It lands better than asking at signup.

5. **Day 7 milestone card** — The gold gradient, scale-pop XP badge animation, and trophy emoji together create a genuine earned feeling. When it fires, it's good.

---

### Where it fails 💀

1. **Lesson completion is emotionally flat.** After passing a quiz, `lesson_completion_flow.dart` shows a `🎉` emoji in a circle on a white background, a score, and an XP box with a gradient. There's no confetti. No level-up fanfare. No Duolingo-style character reaction. The XP award overlay (`xp_award_animation.dart`) exists but is a separate step — users who don't wait for the full animation sequence may miss it entirely.

2. **Level-up dialog is a dialog, not a celebration.** `level_up_dialog.dart` shows confetti and a level badge in a standard dialog box. It uses `showDialog` with `barrierDismissible: false`. The visual design is functional but a celebration that blocks interaction via a modal feels like an interruption rather than a reward.

3. **Fish don't have emotion.** The fish swim, they wiggle when tapped, but they have no happiness state. In Tamagotchi terms, you never know if your fish is thriving. No smile animation when parameters are good. No stress indicator. The tank is a backdrop, not a pet. There's no emotional feedback loop between "I just did a water change" and "my fish looks happier."

4. **Streak loss is silent.** If you lose a streak, the `StreakMilestoneCelebration` only fires on gains (`StreakMilestoneCelebration.show` in `streak_milestone_celebration.dart` — only called on milestones). Duolingo has an entire anxiety-inducing streak freeze/repair system. Danio just lets the streak die with no reaction.

5. **Empty states are not emotional.** `empty_room_scene.dart` shows a cartoon room with a placeholder tank outline. The `MascotAvatar(mood: MascotMood.waving)` exists but it's small and the copy is generic: *"Your aquarium adventure starts here."* Compare to Duolingo's Duo crying when you stop learning. The empty state should feel like something.

6. **Sprites are only available for 15 of 126 species** (`species_sprites.dart` has 15 entries vs 126 `SpeciesInfo` records). If you pick one of the 111 species without a sprite, every visual in onboarding falls back to `🐠`. The personalised aha moment becomes "here is a generic fish emoji with your Corydoras' stats." The emotional peak is blunted for the majority of species.

7. **Where would Duolingo do it better?**
   - **Every correct quiz answer** gets a sound + animation + colour feedback. Danio's quiz answers get a green/red indicator and nothing else (`lesson_quiz_widget.dart`).
   - **Streak recovery** is an anxious, motivated mechanic. Danio has no streak repair, no streak freeze, no "your streak is at risk" push notification architecture visible in the notification system.
   - **Mascot personality.** Duo is everywhere. Finn (the Danio mascot) appears on the empty screen, in some tooltips, and... that's about it. Finn should be reacting to quiz results, celebrating with you, and mourning your missed days.
   - **Progress is visible and inevitable.** Duolingo's XP bar is always on screen. In Danio the XP bar is in the gamification dashboard, behind a sheet pull. The primary home screen has no persistent progress indicator.

---

## SECTION 4 — Self-Challenge: Was 7.2/10 Honest?

**No. It wasn't.**

7.2/10 was a designer admiring their own work. Here's what that score glossed over:

### What was marked "complete" that isn't:

1. **Personalised onboarding** — Marked complete. But the output of personalisation (the auto-created tank) ignores every personalisation input. Tank name is "New Tank." Tank volume is 60L for everyone. The personalisation loop is broken at the output stage.

2. **Daily habit loop** — Marked complete. It has the widgets, the providers, the goals. But the daily goal is not surfaced on the home screen. A habit loop that isn't visible isn't a habit loop.

3. **Milestone moments** — Marked complete. Day 2 prompt exists. Day 7 card exists. Day 30 card exists. But Day 7 has a streak requirement that many real users won't hit, and Day 30 has an upgrade CTA that goes nowhere.

4. **Emotional layer / fish interaction** — Marked complete. Tap interaction exists, wiggle exists, fish facts exist. But sprites cover 12% of species. For 88% of users who chose anything other than the top 15 fish, the visual experience of fish interaction is a 🐠 emoji in a circle.

5. **Level up celebration** — Marked complete. Dialog exists, confetti exists. But `showDialog(barrierDismissible: false)` is a modal interruption, not a celebration. Completion doesn't feel *earned* — it feels *paused*.

6. **Upgrade path at Day 30** — Marked complete (as a stub). The stub calls `Navigator.of(context).pop()`. Nothing about "stub" should score points on a product readiness checklist.

**Honest retrospective rating: 5.8/10.**

The bones are exceptional. The craft on individual screens is often genuinely good. But the system doesn't work as a whole. The loop is broken. The emotional arc is incomplete.

---

## SECTION 5 — Top 10 "If This Stays, App Isn't Finished" Items

In order of user-facing severity:

1. **The auto-created tank at onboarding end is named "New Tank" and is always 60L.**  
   `onboarding_screen.dart` lines 188–196. Every single user gets this. It's the first thing they see in their tank list. A personalisation flow that ends in a generic placeholder is a lie.

2. **111 of 126 species have no sprite — they fall back to `🐠`.**  
   `species_sprites.dart`. The most emotionally powerful screens in the app (onboarding aha moment, warm entry card, fish tap interaction) are blunted for 88% of species choices. The app *claims* to be personalised to your fish. The fish is a generic orange emoji.

3. **Day 30 upgrade CTA calls `Navigator.of(context).pop()`.**  
   `returning_user_flows.dart` ~line 330. Your most committed users, at their highest emotional readiness, tap the upgrade door and nothing happens. If there's ever a paywall or premium tier, this is the moment it needs to exist. Clicking nothing teaches users that Danio doesn't have anything to offer.

4. **Daily goal is not visible on the home screen.**  
   The `DailyGoalCard` widget is built, the provider is reactive, but it lives inside the gamification dashboard bottom sheet. The home screen primary view shows a tank scene with no daily progress. Users who don't discover the bottom sheet don't know they have a daily goal.

5. **Lesson completion screen has no celebration animation.**  
   `lesson_completion_flow.dart`. You finish a quiz. You earn XP. You see a static `🎉` emoji in a coloured circle. The XP award animation (`xp_award_animation.dart`) exists but isn't triggered inline. The moment you complete a lesson — arguably the most important moment in a learning app — is the least emotionally charged screen in the product.

6. **Streak loss is invisible and consequence-free.**  
   There is no streak-break reaction. No sad mascot. No "you lost your X-day streak" screen. No freeze mechanic. The streak counter just resets silently. Duolingo built an entire anxiety industry around streak preservation. We built a streak counter that disappears quietly.

7. **The Day 7 milestone requires a 5-day streak.**  
   `home_screen.dart` line 175. Users with 4-day streaks after 7 days — perfectly reasonable engagement — never see the trophy card. You should celebrate 7 days of *membership*, not require near-perfect streak compliance to earn a welcome.

8. **The consent screen is the first thing users ever see.**  
   `main.dart` line 354. GDPR compliance is mandatory, but it doesn't have to be a wall. It should come after the hook. Currently: legal form → beautiful welcome screen. It should be: beautiful welcome screen → trust-building → legal form when buying in.

9. **"Skip setup, I'll explore first" creates a broken promise.**  
   `welcome_screen.dart` line 209. Users are invited to explore and land in a placeholder tank. The skip path is not an "explore" experience — it's an "abandon" experience with a snackbar. Either make the explore path genuinely explorable (demo tank with pre-populated data they can browse) or rename the CTA to "I'll skip setup."

10. **Fish have no mood/happiness state.**  
    The animated fish swim but never react to tank health. Doing a water change changes nothing visually. Testing good water parameters changes nothing. The emotional feedback loop between "I'm caring for my tank" and "my fish are thriving" is absent. This is the core Tamagotchi loop the app is supposed to deliver, and it doesn't exist.

---

## SECTION 6 — What Would Embarrass Us in an App Store Review

The adversarial perspective. What would a reviewer screenshot?

### 🔴 Screenshot 1 — The Empty Promise
> *"App says it's personalised to your fish but when I finished setup my tank was called 'New Tank' and was set to 60 litres. It didn't ask my tank size anywhere."*

`onboarding_screen.dart` lines 188–196. This is a one-star review waiting to happen. "Personalised" in the App Store description; "New Tank, 60L" in the actual product.

---

### 🔴 Screenshot 2 — The Dead Button
> *"Tapped 'See what's waiting for you' after 30 days and the popup just closed. Thought there was a premium plan but nothing happened."*

`returning_user_flows.dart` `Day30CommittedCard.onUpgrade` → `Navigator.pop()`. A reviewer will screenshot the card, tap the CTA, nothing happens, and write "broken app" or "false advertising."

---

### 🔴 Screenshot 3 — The Emoji Fish
> *"I chose Corydoras (literally one of the most popular beginner fish) and the entire onboarding used a 🐠 emoji for it. Not a great start for an app that claims to specialise in fish."*

`species_sprites.dart` has 15 species. `species_database.dart` has 126. Corydoras, Dwarf Gourami, Swordtail, White Cloud Mountain Minnow, Endler's Livebearer, Kuhli Loach, Siamese Fighting Fish variants — none have sprites. The personalisation illusion breaks immediately for most users.

---

### 🔴 Screenshot 4 — The Privacy Wall
> *"Downloaded this app about fish and the first thing I see is a legal consent form. Didn't even know what the app was yet."*

First screen on install: `ConsentScreen`. No fish. No brand. An icon that looks like it belongs in a banking app. Reviewers who are on the fence will delete before the welcome screen.

---

### 🔴 Screenshot 5 — The Silent Streak Death
> *"I had a 12-day streak and missed one day. No notification, no warning, just gone. App didn't even mention it next time I opened it."*

There's no streak-break acknowledgement in the home screen flow. `_checkReturningUserFlow()` in `home_screen.dart` doesn't handle "you just lost your streak" as a dedicated state. The comeback banner fires for 2+ day absences, but the streak counter just silently resets. A reviewer will compare this to Duolingo and feel cheated.

---

### 🟡 Screenshot 6 — The Flat Lesson Completion
> *"Passed a quiz and got... a screen with a 🎉 emoji? That's it? Duolingo gives you fireworks and sound and animations."*

`lesson_completion_flow.dart` — a plain emoji in a circle. The XP award animation exists but the *lesson complete* screen itself is the least animated, least celebratory moment in the entire app. Someone will compare it to Duolingo and that comparison will end badly.

---

### 🟡 Screenshot 7 — The Generic Tank Level Message
> *"Levelled up to Level 3 and got a popup saying 'New lessons unlocked!' …that's it? Unlocked where? How do I find them?"*

`lesson_completion_flow.dart` `getUnlockMessage(3)` → `'New lessons unlocked!'`. This message is shown in the `LevelUpDialog`. But it doesn't tell the user which lessons, where to find them, or what "unlocked" means in practice. It's noise dressed as reward.

---

## FINAL VERDICT

**Honest rating: 5.8/10**

The app is well-engineered. The individual screen craft is often genuinely excellent — the AhaMoment reveal, the XP celebration, the fish tap interaction, the WarmEntry sequence. These show a designer who cared.

But the app doesn't yet work as an *experience*. The emotional arc is broken by compliance-first ordering, placeholder output from a personalisation promise, incomplete sprite coverage that breaks the personalisation illusion, and a daily loop that isn't visible enough to create habit.

The gap between 5.8 and 7.2 is what we told ourselves was done that wasn't. Fix the top 10 list above and the score climbs to 8.0+. Leave them and the App Store will tell us in its reviews.

---

*Truth pass complete. Apollo.*  
*"Let me show you what you meant to say."*
