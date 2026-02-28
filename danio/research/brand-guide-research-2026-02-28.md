# Danio Brand Guide — Deep Research Report
*Generated: 2026-02-28 | Researcher: Prometheus sub-agent*

## Executive Summary

1. **Confetti + Rive is the winning celebration stack** — The `confetti` package (1.56K+ likes, 262K downloads) is the community standard for Flutter celebrations. Pair it with Rive for state-driven mascot reactions and Lottie for polished micro-animations. Custom `AnimationController` with spring physics gives the most control for score pop-ups.

2. **Duolingo's streak psychology is the single most valuable pattern to adopt** — Users with 7-day streaks are 3.6× more likely to complete courses. The streak counter, streak freeze mechanic, and milestone celebration animations (phoenix transformation) drove a 60% engagement increase. Danio should implement all three from day one.

3. **Dark mode for warm brands requires warm charcoal, not grey** — Use `ColorScheme.fromSeed()` with the same amber seed colour + `Brightness.dark`. Override surface colours to warm charcoal (#1C1917 or #2C2A29 range) instead of M3's default cool greys. This preserves brand warmth while meeting WCAG contrast requirements.

4. **Onboarding should delay signup and lead with mascot + value** — Duolingo's gradual engagement pattern (product experience before registration) is the gold standard. Danio should introduce the mascot immediately, ask 2-3 personalisation questions (aquarium experience level, interests), then drop users into a first lesson before any signup wall.

5. **Flutter 3.32's accessibility features are a game-changer** — New `SemanticsRole` API, 80% faster semantics tree compilation, and built-in WCAG guideline matchers make AA compliance significantly easier. The `accessibility_tools` package enables real-time debugging.

6. **First 3 screenshots determine 80%+ of conversion decisions** — Screenshot #1 must be the hero value proposition. Benefit-driven captions (3-7 words max), bright colours, and device frames outperform raw screenshots. Educational apps benefit from showing mascot + UI together.

7. **Premium gamified learning apps share 5 visual patterns** — Rounded corners (16-24dp), chunky illustrated mascots, bold saturated colours, generous whitespace, and celebration micro-interactions. Danio's Pixar aesthetic aligns perfectly with this pattern language.

---

## 1. Micro-interactions & Celebrations

### Key Packages & Patterns

The Flutter ecosystem offers a mature set of celebration and micro-interaction tools for gamified apps:

**`confetti` (pub.dev)** — The dominant choice with 1.56K+ likes and 262K+ monthly downloads. Provides a `ConfettiController` with configurable velocity, angle, gravity, particle count, and blast directionality (directional or explosive). Supports custom particle shapes including stars. Ideal for lesson completion, streak milestones, and achievement unlocks. Example usage involves wrapping a `ConfettiWidget` in an `Align` widget and triggering `controller.play()` on events. ([pub.dev/packages/confetti](https://pub.dev/packages/confetti))

**`easy_conffeti`** — A newer alternative (March 2025) offering pre-built celebration types: `success`, `failed`, `celebration`, `achievement`, and `levelUp`. Supports particle shapes including circles, stars, emoji, ribbons, and paper. Better for teams wanting less configuration. ([pub.dev/packages/easy_conffeti](https://pub.dev/packages/easy_conffeti))

**`reward_popup`** — Provides animated pop-up overlays with gift unwrapping + confetti combination. Good for treasure chest / reward reveals. ([fluttergems.dev/games-rewards](https://fluttergems.dev/games-rewards/))

**`flutter_confetti`** — Canvas-based confetti with drift, tilt, and wobble physics for a more realistic 3D feel. 121 likes, growing adoption. ([pub.dev/packages/flutter_confetti](https://pub.dev/packages/flutter_confetti))

**Rive** — State-driven vector animations ideal for mascot reactions (happy dance on correct answer, sad droop on wrong answer). Supports state machines that respond to app events without code-side animation management. Significantly smaller file sizes than Lottie for interactive animations. ([dev.to — Mastering Rive Animations](https://dev.to/uianimation/mastering-rive-animations-in-flutter-react-the-ultimate-guide-57d7))

**Lottie** — Best for polished, pre-designed micro-animations (checkmarks, star bursts, XP counter animations). Import JSON animations from After Effects. Ideal for non-interactive celebratory moments. ([medium.com — Flutter Micro-interactions](https://medium.com/@tiger.chirag/hidden-choreography-in-flutter-f49c5298d914))

**Custom `AnimationController` with spring physics** — For score pop-ups and XP gain animations, a custom `SpringSimulation` with `AnimationController` gives the bounciest, most satisfying feel. Use `Curves.elasticOut` for the "pop" effect on numbers incrementing. This is what top gamified apps use for the number-incrementing XP counter.

**`teqani_rewards`** — A dedicated gamification package with built-in achievement systems, streak tracking, and time-limited challenges. Supports SharedPreferences, SQLite, Hive, and Firebase storage. Includes Firebase Analytics integration. Worth evaluating as a foundation layer. ([fluttergems.dev/games-rewards](https://fluttergems.dev/games-rewards/))

### Recommended Stack for Danio
- **Confetti moments**: `confetti` package (most mature, best documented)
- **Mascot reactions**: Rive state machines (DanioMascot mood transitions)
- **Polished micro-animations**: Lottie for pre-designed celebrations
- **Score/XP pop-ups**: Custom `AnimationController` with `SpringSimulation`
- **Reward reveals**: `reward_popup` for treasure chest moments

---

## 2. Duolingo UX Dissection

### The Streak System — Duolingo's $500M Feature

Duolingo's streak counter is the result of **600+ A/B experiments over 4 years** and is directly credited with generating significant portions of their $500M+ annual revenue. The core psychological mechanisms are: ([uxmag.com](https://uxmag.com/articles/the-psychology-of-hot-streak-game-design-how-to-keep-players-coming-back-every-day-without-shame))

**Loss Aversion**: Users with a 100-day streak treat it as a trophy worth protecting. People hate losing more than they enjoy gaining — a 100-day streak feels more valuable than the sum of 100 individual daily lessons. ([orizon.co](https://www.orizon.co/blog/duolingos-gamification-secrets))

**The Zeigarnik Effect**: The brain literally won't let users forget an active streak. On day 47, the incomplete nature of the streak creates persistent mental reminders that drive daily engagement without external notifications. ([uxmag.com](https://uxmag.com/articles/the-psychology-of-hot-streak-game-design-how-to-keep-players-coming-back-every-day-without-shame))

**Variable Reinforcement**: Streak milestones (7, 30, 100, 365 days) provide escalating dopamine hits. The anticipation of hitting the next milestone drives engagement more than the milestone itself. ([uxmag.com](https://uxmag.com/articles/the-psychology-of-hot-streak-game-design-how-to-keep-players-coming-back-every-day-without-shame))

### Key Metrics
- **7-day streak users**: 3.6× more likely to stay engaged long-term
- **Streak Freeze introduction**: Reduced churn by 21% for at-risk users
- **iOS widget displaying streaks**: Increased user commitment by 60%
- **XP leaderboards**: Users complete 40% more lessons per week
- **Leagues**: Increased lesson completion by 25%
- **Badges**: 30% more likely to finish a language course
- **Daily Quests**: Increased DAU by 25%
- **Double XP Weekend**: 50% surge in activity

### The Great Separation Experiment
Duolingo's most counterintuitive insight: **making streaks easier to maintain actually increased long-term engagement**. Originally, streaks required hitting daily XP goals. Almost 40% of users active for two consecutive days had no streak because ambitious goals created a barrier. Separating streak maintenance from goal completion (just open the app and do *something*) dramatically improved retention. ([uxmag.com](https://uxmag.com/articles/the-psychology-of-hot-streak-game-design-how-to-keep-players-coming-back-every-day-without-shame))

### Streak Milestone Animation Design
Duolingo's design team evolved streak celebrations from "Duo holding number balloons" (cute but underwhelming) to a **phoenix transformation animation** — Duo physically transforms into a fiery phoenix at milestones. They chose the phoenix metaphor because it's universally understood across cultures (unlike "on fire" idioms). The animation uses multiple passes of rough animation to nail timing and energy before refinement. A share card allows social bragging. Early metrics showed more users keeping streaks alive on both iOS and Android. ([blog.duolingo.com](https://blog.duolingo.com/streak-milestone-design-animation/))

### Patterns Danio Should Adopt
1. **Streak counter** with prominent homepage placement (coral reef growing with streak)
2. **Streak freeze** mechanic (1 per week free, more via in-app currency)
3. **Low-barrier streak maintenance** (any activity counts, not just lesson completion)
4. **Milestone celebrations** at 7, 14, 30, 60, 100, 365 days with escalating Danio mascot animations
5. **XP leaderboard** with weekly leagues
6. **Daily quests** (3 per day, rotating)
7. **Surprise treasure chests** on random lesson completions
8. **Social share cards** for milestone moments

---

## 3. Flutter Onboarding Best Practices

### Duolingo's Gold Standard Onboarding

Duolingo's onboarding is consistently rated among the best in mobile apps. The key principle is **gradual engagement** — postponing registration until users have experienced the product's core value. ([goodux.appcues.com](https://goodux.appcues.com/blog/duolingo-user-onboarding))

**The Duolingo Flow:**
1. Mascot welcome (Duo waves, establishes personality)
2. Goal setting ("Why are you learning?") — creates commitment bias
3. Self-segmentation by skill level (novice vs. experienced)
4. **Immediate product experience** (first mini-lesson before any signup)
5. Progress bar showing completion
6. Signup prompt at a logical moment (after completing first lesson)
7. Celebration of first achievement

**Why It Works:**
- **Completion bias**: Getting users to commit to a goal before signup makes them 3× more likely to stick with the platform
- **Goal gradient effect**: Progress bars exploit the tendency to accelerate effort as you approach a goal
- **Gradual engagement**: Registration feels like a small step within a larger process rather than a barrier

### Flutter Implementation Patterns

**PageView with custom indicators** — The standard Flutter onboarding pattern uses `PageView` with `PageController` for swipeable screens. Custom dot indicators (animated `Container` widgets) are preferred over package-based solutions for brand consistency. Use `shared_preferences` to track first-run state. ([devthantzin.medium.com](https://devthantzin.medium.com/step-by-step-guide-to-flutter-intro-onboarding-screens-pure-flutter-no-packages-28f2d9cb7e07))

**Riverpod initialization flow** — For apps with async dependencies (loading user profile, checking login state), Andrea Bizzotto's pattern uses Riverpod providers to show loading UI during initialization before routing to onboarding or home. ([codewithandrea.com](https://codewithandrea.com/articles/robust-app-initialization-riverpod/))

**Key packages:**
- `smooth_page_indicator` — Animated page indicators with multiple styles
- `introduction_screen` — Complete onboarding scaffold with skip/done buttons
- `shared_preferences` — Persist first-run flag

### Recommended Danio Onboarding Flow
1. **Splash** → Danio mascot swims into view (Rive animation)
2. **"Welcome to Danio!"** → Mascot introduces itself, establishes personality
3. **"How experienced are you?"** → Beginner / Some experience / Expert (self-segmentation)
4. **"What interests you most?"** → Freshwater / Saltwater / Both (personalisation)
5. **First micro-lesson** → Quick interactive quiz (3 questions) with XP rewards
6. **Celebration** → Confetti + mascot dance + "You earned 50 XP!"
7. **Signup prompt** → "Save your progress" with email/Google/Apple sign-in
8. **Notification permission** → Framed as "streak reminders" with mascot asking

---

## 4. Dark Mode for Warm Brands

### The Problem with Default Dark Mode

Flutter's `ColorScheme.fromSeed()` with `Brightness.dark` generates tonal palettes that tend towards cool greys by default. For warm brands like Danio (amber/golden palette), this creates a jarring disconnect between light and dark modes. The default M3 dark surfaces (#1C1B1F range) feel cold and clinical. ([christianfindlay.com](https://www.christianfindlay.com/blog/flutter-mastering-material-design3))

### Solution: Warm Charcoal Dark Mode

**Key principle**: Use warm-tinted dark backgrounds instead of neutral/cool greys. Research from ColorHero identifies that warm charcoal (#1C1917) paired with soft gold accents (#D4A574) creates an "inviting atmosphere that avoids the cold, technical feel of typical dark modes." ([colorhero.io](https://colorhero.io/blog/dark-mode-color-palettes-2025))

**Implementation Strategy for Danio:**

```dart
// Light theme
final lightScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFFF59E0B), // Amber-500
  brightness: Brightness.light,
);

// Dark theme — override surfaces for warmth
final darkScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFFF59E0B), // Same amber seed
  brightness: Brightness.dark,
).copyWith(
  surface: Color(0xFF1C1917),         // Warm charcoal (stone-950)
  onSurface: Color(0xFFFAF5F0),       // Warm white
  surfaceContainerHighest: Color(0xFF292524), // Warm grey (stone-800)
  surfaceContainerHigh: Color(0xFF1C1917),
  surfaceContainer: Color(0xFF231F1E),
  surfaceContainerLow: Color(0xFF1A1614),
  surfaceContainerLowest: Color(0xFF110E0C),
);
```

**Best Practices:**
1. **Same seed colour for both themes** — `ColorScheme.fromSeed()` automatically adjusts primary/secondary/tertiary for dark mode contrast, maintaining brand harmony ([christianfindlay.com](https://www.christianfindlay.com/blog/flutter-mastering-material-design3))
2. **Override surface colours only** — Let M3 handle primary/secondary tonal mapping but manually warm up surfaces
3. **Use `copyWith()`** — Don't build the entire dark ColorScheme manually; just override the cold-feeling surface slots
4. **Warm white text** — Use cream-tinted whites (#FAF5F0) instead of pure white (#FFFFFF) for body text to maintain warmth
5. **Test with real content** — Amber-on-dark needs careful contrast checking. Use Flutter's built-in `meetsGuideline` accessibility tests
6. **Keep illustrations vibrant** — Reduce illustration saturation by ~10-15% in dark mode to avoid visual harshness, but don't desaturate fully

**Colour Palette Recommendation for Danio Dark:**
| Role | Light Mode | Dark Mode |
|------|-----------|-----------|
| Surface | #FFFBF0 (warm cream) | #1C1917 (warm charcoal) |
| On Surface | #1C1917 | #FAF5F0 (warm white) |
| Surface Container | #FFF5E6 | #292524 (stone-800) |
| Primary | #F59E0B (amber-500) | #FBBF24 (amber-400, slightly lighter) |
| Card Background | #FFFFFF | #231F1E |

---

## 5. Accessibility in Gamified Apps

### Flutter Accessibility Landscape (2025-2026)

Flutter 3.32 (May 2025) brought major accessibility improvements that directly benefit gamified apps like Danio: ([dcm.dev](https://dcm.dev/blog/2025/06/30/accessibility-flutter-practical-tips-tools-code-youll-actually-use))

**SemanticsRole API** — Assign fine-grained semantic roles to widgets. Critical for game elements:
```dart
Semantics(
  label: 'Daily streak counter',
  value: '47 days',
  role: SemanticsRole.status,
  child: StreakCounterWidget(days: 47),
)
```
This tells screen readers the streak counter is a status element, not a button. Available roles include `status`, `alert`, `progressBar`, `list`, `listItem` — all directly relevant to gamification UI.

**80% Faster Semantics Tree** — Frame rendering overhead with accessibility enabled is dramatically reduced, meaning VoiceOver/TalkBack users get smooth performance even during animations.

**Built-in WCAG Testing** — Flutter's test framework now supports `meetsGuideline` matchers:
```dart
testWidgets('meets accessibility guidelines', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(tester, meetsGuideline(textContrastGuideline));
  expect(tester, meetsGuideline(androidTapTargetGuideline));
  expect(tester, meetsGuideline(iOSTapTargetGuideline));
  expect(tester, meetsGuideline(labeledTapTargetGuideline));
});
```

### Gamification-Specific Accessibility Requirements

**Colour Contrast (WCAG AA):**
- Normal text: 4.5:1 minimum contrast ratio
- Large text (18pt+ or 14pt+ bold): 3:1 minimum
- **Danio concern**: Amber (#F59E0B) on white (#FFFFFF) = 2.1:1 ratio — **fails AA**. Use darker amber (#D97706) on white for text, or amber on dark backgrounds only
- UI components and graphical objects: 3:1 against adjacent colours

**Screen Reader Support for Game Elements:**
- XP gains: Use `SemanticsService.announce()` for live announcements ("You earned 50 XP!")
- Streak counters: Wrap in `Semantics(role: SemanticsRole.status)` 
- Progress bars: Use `Semantics(label: 'Lesson progress', value: '75%')` on custom progress widgets
- Celebrations: Announce achievements via `SemanticsService.announce()` — confetti is visual-only, so screen reader users need text equivalents
- Achievement badges: Each badge needs a semantic label describing what was earned and when

**Haptic Feedback Patterns:**
- `HapticFeedback.lightImpact()` — Correct answer confirmation
- `HapticFeedback.mediumImpact()` — Streak milestone reached
- `HapticFeedback.heavyImpact()` — Achievement unlocked / level up
- `HapticFeedback.selectionClick()` — Button taps and selections
- Always pair with visual feedback — haptic alone is insufficient

**Key Tools:**
- `accessibility_tools` package — Overlay that simulates screen reader view in development
- Flutter's `showSemanticsDebugger` — Built-in semantics tree visualiser
- Manual TalkBack/VoiceOver testing — No substitute for real-device testing

**Important Caveat**: As noted by the dev.to Flutter community, "it is currently not possible to make an app fully accessible in terms of WCAG guidelines using Flutter" due to full keyboard navigation limitations on iOS. However, for mobile-first apps like Danio, screen reader and touch accessibility can be comprehensively addressed. ([dev.to](https://dev.to/adepto/improving-accessibility-in-flutter-apps-a-comprehensive-guide-1jod))

---

## 6. App Store Screenshot Conversion

### Key Research Findings

App screenshots are the single most influential creative asset for conversion. Research shows users decide whether to download within seconds, often without reading the description. The first three screenshots have the biggest influence as users rarely scroll past them. ([apptweak.com](https://www.apptweak.com/en/aso-blog/how-to-optimize-your-app-screenshots))

### High-Converting Patterns for Educational/Hobby Apps

**Screenshot #1 — The Hero Shot:**
- Must communicate core value proposition immediately
- "Put your strongest hook in screenshot #1" ([reddit.com/r/apps](https://www.reddit.com/r/apps/comments/1rfnxg2/how_to_create_nice_highconverting_app_store/))
- For Danio: Show Danio mascot + a beautiful aquarium scene + text "Learn Aquarium Keeping the Fun Way"
- Benefit-driven caption, not feature-driven ("Track your fish" → "Never lose a fish again")

**Text Overlay Rules:**
- 3-7 words maximum per screenshot
- Benefit-driven language ("Master Aquarium Care" not "Aquarium Database")
- Large, bold, readable — must be legible at thumbnail size on search results
- Emotion-driven screenshots lead to higher engagement
- Don't use generic stock images — causes distrust ([apptweak.com](https://www.apptweak.com/en/aso-blog/how-to-optimize-your-app-screenshots))

**Visual Design:**
- Bright colours and high-contrast designs see higher conversion rates
- Device frames add credibility — show the app running on a phone
- Consistent colour story across all screenshots (Danio's amber palette = cohesive)
- Background colour should complement the app UI, not compete with it

**Screenshot Sequence (Recommended for Danio):**
1. **Hero**: Mascot + core value proposition ("Learn Aquarium Keeping!")
2. **Gamification**: XP bar + streak counter + achievement badges in action
3. **Content preview**: Beautiful fish identification card with painterly art
4. **Social proof**: Leaderboard / community element
5. **Dark mode**: Show both light and dark mode (demonstrates polish)

**Platform Specifics:**
- **App Store**: Up to 10 screenshots, appear prominently at top of product page, visible in search results. Size: 1290×2796 pixels (6.9" iPhone). Supports app preview videos.
- **Google Play**: Up to 8 screenshots. Size: 1080×1920 pixels. Supports A/B testing of different screenshot variations. ([apptweak.com](https://www.apptweak.com/en/aso-blog/how-to-optimize-your-app-screenshots), [mobileaction.co](https://www.mobileaction.co/guide/app-screenshot-sizes-and-guidelines-for-the-app-store/))

**A/B Testing:**
- Google Play allows native A/B testing of screenshot variations
- Apple supports custom product pages for different audience segments
- Test: hero shot with mascot vs. without, text overlay vs. pure UI, different feature orderings

---

## 7. Competitive Visual Language

### Shared Design Patterns Across Premium Gamified Learning Apps

Analysing Duolingo, Headspace, Kahoot Kids, Khan Academy Kids, and Mimo reveals consistent visual patterns that signal "premium gamified learning":

**1. Rounded, Friendly Geometry**
All five apps use heavily rounded corners (16-24dp border radius), pill-shaped buttons, and circular avatars/progress indicators. Sharp corners are virtually absent. This signals safety, friendliness, and approachability. Duolingo uses consistently rounded cards and buttons with thick outlines. Headspace uses soft, rounded rectangles for meditation cards. Danio's existing rounded card style aligns perfectly. ([reddit.com/r/UX_Design](https://www.reddit.com/r/UX_Design/comments/1jcim01/how_to_give_your_app_a_playful_yet_clean/))

**2. Bold, Saturated Primary Colours**
Each app owns a dominant colour: Duolingo (lime green #58CC02), Headspace (coral/orange), Kahoot (purple #46178F), Khan Academy Kids (green/blue), Mimo (blue/purple gradients). The primary colour is used boldly — not as an accent but as a defining brand element appearing in 40%+ of the UI. Danio's amber/gold is well-positioned for this.

**3. Illustrated Mascots with Personality**
Duolingo's Duo owl, Khan Academy Kids' whole character cast, Mimo's monkey — all use chunky, simple character designs with limited detail and strong silhouettes. Key traits: big eyes, simple shapes, 2-3 colour per character maximum, expressive faces, multiple emotional states. The mascot appears throughout the experience, not just at onboarding. Danio's zebrafish mascot should appear on home screen, lesson screens, celebrations, and error states.

**4. Generous Whitespace and Vertical Stacking**
These apps avoid dense, information-heavy layouts. Content is vertically stacked with significant padding between elements. Cards are large and tappable (minimum 48dp touch targets, most use 56-64dp). This creates a calm, uncluttered feeling despite gamification elements. ([litslink.com](https://litslink.com/blog/ui-ux-nuancese-elearning-app))

**5. Micro-Celebrations at Every Step**
Every app provides immediate positive feedback for correct actions: Duolingo's green flash + sound, Kahoot's point counter animation, Headspace's breathing circle completion. The ratio is approximately 3:1 positive-to-neutral feedback. Negative feedback is gentle and constructive (Duolingo shows the correct answer, doesn't punish). ([prodwrks.com](https://prodwrks.com/gamification-in-edtech-lessons-from-duolingo-khan-academy-ixl-and-kahoot/))

**6. Consistent Illustration Style**
Each app maintains a single illustration style across all assets. Duolingo uses flat vector with thick outlines. Headspace uses painterly, abstract illustrations. Khan Academy Kids uses bright, character-driven illustrations. Danio's Pixar/DreamWorks concept art style is more premium than most competitors — this is a differentiator. Maintain it rigorously across all screens, marketing materials, and store assets.

**7. Sound Design as Brand Element**
Often overlooked: Duolingo's "ding" for correct answers and level-up fanfare are as recognisable as their visual brand. Kahoot's countdown music creates urgency. Headspace uses ambient nature sounds. Danio should develop a signature sound palette: gentle water/bubble sounds for navigation, warm chimes for correct answers, triumphant fanfare for milestones.

### Where Danio Can Differentiate
- **Aesthetic tier**: Pixar/concept art quality is a tier above the flat vector style most competitors use
- **Subject matter**: Aquarium hobby is unique — no direct competitor uses this gamified approach
- **Warm palette**: Amber/gold is unusual in the space (competitors skew green, blue, purple)
- **Painterly gradients**: Most competitors use flat colours; Danio's gradient approach feels more premium

---

## Priority Recommendations for Brand Guide Update

1. **Add a Celebration System section** — Define 4 tiers of celebration (correct answer → lesson complete → streak milestone → achievement unlock) with specific packages and animation patterns for each. Use `confetti` + Rive + custom `AnimationController`.

2. **Add a Streak System specification** — Document streak counter widget, streak freeze UI, milestone thresholds (7/14/30/60/100/365), and the Danio mascot transformation sequence at each milestone (inspired by Duolingo's phoenix).

3. **Add Dark Mode ColorScheme** — Include the complete warm-charcoal dark palette with specific hex values for all surface roles. Ensure amber text passes WCAG AA (use #D97706 on white, #FBBF24 on dark).

4. **Add Onboarding Flow specification** — Document the 8-step onboarding sequence with mascot animation states, personalisation questions, and signup-after-value pattern.

5. **Add Accessibility Guidelines section** — Document semantic role assignments for all gamification widgets, haptic feedback patterns per event type, and screen reader announcement strategy for XP/streak changes.

6. **Add App Store Creative Guidelines** — Define the 5-screenshot sequence, text overlay style (Fredoka Bold, amber on white/dark), device frame specifications, and hero shot composition.

7. **Add Sound Design palette** — Define signature sounds for: correct answer, wrong answer, lesson complete, streak milestone, achievement, navigation tap, water ambience.

8. **Add illustration style guide for competitive differentiation** — Document the painterly gradient technique, character detail level, and colour usage rules that distinguish Danio from flat-vector competitors.

9. **Update DanioMascot widget** — Add `SemanticsRole.status` for screen reader support, add Rive state machine integration for celebration reactions, add milestone transformation animations.

10. **Add XP Leaderboard and Daily Quest widgets** — Based on Duolingo's proven patterns (40% more engagement from leaderboards, 25% DAU increase from daily quests).

---

## Sources

### Micro-interactions & Celebrations
- https://pub.dev/packages/confetti
- https://pub.dev/packages/easy_conffeti
- https://pub.dev/packages/flutter_confetti
- https://fluttergems.dev/games-rewards/
- https://xeladu.medium.com/easy-confetti-animations-in-flutter-apps-8ca6a6858283
- https://dev.to/uianimation/mastering-rive-animations-in-flutter-react-the-ultimate-guide-57d7
- https://medium.com/@tiger.chirag/hidden-choreography-in-flutter-f49c5298d914
- https://fluttergems.dev/animation-transition/

### Duolingo UX Dissection
- https://www.orizon.co/blog/duolingos-gamification-secrets
- https://blog.duolingo.com/streak-milestone-design-animation/
- https://uxmag.com/articles/the-psychology-of-hot-streak-game-design-how-to-keep-players-coming-back-every-day-without-shame
- https://medium.com/@salamprem49/duolingo-streak-system-detailed-breakdown-design-flow-886f591c953f
- https://www.justanotherpm.com/blog/the-psychology-behind-duolingos-streak-feature

### Flutter Onboarding
- https://goodux.appcues.com/blog/duolingo-user-onboarding
- https://userguiding.com/blog/duolingo-onboarding-ux
- https://devthantzin.medium.com/step-by-step-guide-to-flutter-intro-onboarding-screens-pure-flutter-no-packages-28f2d9cb7e07
- https://blog.logrocket.com/creating-flutter-onboarding-screen/
- https://codewithandrea.com/articles/robust-app-initialization-riverpod/

### Dark Mode for Warm Brands
- https://www.christianfindlay.com/blog/flutter-mastering-material-design3
- https://colorhero.io/blog/dark-mode-color-palettes-2025
- https://docs.flutter.dev/cookbook/design/themes
- https://api.flutter.dev/flutter/material/ColorScheme-class.html
- https://www.vev.design/blog/dark-mode-website-color-palette/

### Accessibility
- https://dcm.dev/blog/2025/06/30/accessibility-flutter-practical-tips-tools-code-youll-actually-use
- https://docs.flutter.dev/ui/accessibility
- https://docs.flutter.dev/ui/accessibility/assistive-technologies
- https://dev.to/adepto/improving-accessibility-in-flutter-apps-a-comprehensive-guide-1jod
- https://vibe-studio.ai/insights/flutter-accessibility-making-apps-screen-reader-friendly-and-wcag-2-2-compliant
- https://pub.dev/packages/accessibility_tools
- https://blog.flutter.wtf/mobile-app-accessibility/

### App Store Screenshots
- https://www.apptweak.com/en/aso-blog/how-to-optimize-your-app-screenshots
- https://asomobile.net/en/blog/screenshots-for-app-store-and-google-play-in-2025-a-complete-guide/
- https://www.mobileaction.co/guide/app-screenshot-sizes-and-guidelines-for-the-app-store/
- https://splitmetrics.com/blog/app-store-screenshots-aso-guide/
- https://www.reddit.com/r/apps/comments/1rfnxg2/how_to_create_nice_highconverting_app_store/

### Competitive Visual Language
- https://prodwrks.com/gamification-in-edtech-lessons-from-duolingo-khan-academy-ixl-and-kahoot/
- https://www.reddit.com/r/UX_Design/comments/1jcim01/how_to_give_your_app_a_playful_yet_clean/
- https://litslink.com/blog/ui-ux-nuancese-elearning-app
- https://shakuro.com/blog/e-learning-app-design-and-how-to-make-it-better
- https://fulcrum.rocks/blog/education-app-design
