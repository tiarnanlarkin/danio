# Danio — Flutter Brand Implementation Guide
## Pixar/DreamWorks Concept Art Style → Production Flutter UI

*Research completed 2026-02-28*

---

## 1. Typography: Google Fonts Pairing

### Recommendation: **Fredoka** (display) + **Nunito** (body)

This is the strongest pairing for Danio's warm, friendly, Duolingo-adjacent identity:

| Role | Font | Weight | Size Range | Why |
|------|------|--------|------------|-----|
| **Display/Headlines** | Fredoka | **600 (SemiBold)** for headlines, **700 (Bold)** for hero text | 24–36sp | Rounded, chunky, bubbly — matches the Pixar mascot energy perfectly. Same DNA as Duolingo's display type. |
| **Body/UI** | Nunito | **400 (Regular)** for body, **600 (SemiBold)** for labels, **700 (Bold)** for emphasis | 14–18sp | Rounded sans-serif that harmonises tonally with Fredoka without competing. Excellent readability at small sizes. |
| **Numeric/Stats** | Nunito | **800 (ExtraBold)** | 28–48sp | For XP counters, streak numbers, stats — the tabular figures read well at display sizes. |

**Why not the others:**
- **Baloo 2** — More expressive but harder to read at body sizes, less weight range
- **Poppins** — Too geometric/corporate, lacks the warmth needed
- **Quicksand** — Too thin/airy, doesn't match the chunky Pixar aesthetic

### Flutter Implementation

```dart
// pubspec.yaml
dependencies:
  google_fonts: ^6.2.1

// lib/theme/typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DanioTypography {
  static TextTheme get textTheme => TextTheme(
    // Hero text — big splash screens
    displayLarge: GoogleFonts.fredoka(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    // Section headers
    headlineMedium: GoogleFonts.fredoka(
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    // Card titles
    titleLarge: GoogleFonts.fredoka(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    // Smaller titles
    titleMedium: GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    // Body text
    bodyLarge: GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    // Labels, buttons
    labelLarge: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    // Small captions
    bodySmall: GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  );
}
```

---

## 2. Custom Illustration Backgrounds

### Strategy: Pre-rendered painterly PNGs with WebP optimization

For dense Pixar-style painterly backgrounds, raster PNGs are the only option (SVG can't capture painterly detail). The key is performance.

### Asset Structure

```
assets/
  illustrations/
    backgrounds/
      home_aquarium.webp          # ~200KB target
      lesson_coral_reef.webp
      profile_deep_ocean.webp
    2.0x/                         # @2x for high-DPI
      backgrounds/
        home_aquarium.webp
        ...
    3.0x/                         # @3x for flagship phones
      backgrounds/
        home_aquarium.webp
        ...
```

### Performance Rules

1. **Use WebP over PNG** — 25-35% smaller with identical quality. Flutter supports WebP natively.
2. **Target max 1080px wide** for base resolution (device will pick 2x/3x variants).
3. **Precache on app startup** for key screens.
4. **Use `cacheWidth`/`cacheHeight`** to avoid decoding full-resolution images into memory.

### Flutter Implementation

```dart
// lib/widgets/illustrated_background.dart
import 'package:flutter/material.dart';

class IllustratedBackground extends StatelessWidget {
  final String assetPath;
  final Widget child;
  final Alignment alignment;
  final BoxFit fit;

  const IllustratedBackground({
    super.key,
    required this.assetPath,
    required this.child,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background layer — positioned behind everything
        Positioned.fill(
          child: Image.asset(
            assetPath,
            fit: fit,
            alignment: alignment,
            // CRITICAL: Constrain decoded image size to screen resolution
            cacheWidth: (MediaQuery.of(context).size.width *
                    MediaQuery.of(context).devicePixelRatio)
                .round(),
            // Let height scale proportionally
            filterQuality: FilterQuality.medium,
          ),
        ),
        // Optional gradient overlay for text readability
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  DanioColors.deepViolet.withValues(alpha: 0.7),
                ],
                stops: const [0.3, 1.0],
              ),
            ),
          ),
        ),
        // Actual screen content
        child,
      ],
    );
  }
}

// Precache on app startup
class DanioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Precache the most-used backgrounds
    precacheImage(const AssetImage('assets/illustrations/backgrounds/home_aquarium.webp'), context);
    precacheImage(const AssetImage('assets/illustrations/backgrounds/lesson_coral_reef.webp'), context);

    return MaterialApp(/* ... */);
  }
}

// Usage on any screen:
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IllustratedBackground(
      assetPath: 'assets/illustrations/backgrounds/home_aquarium.webp',
      child: SafeArea(
        child: Column(/* screen content */),
      ),
    );
  }
}
```

---

## 3. Reusable Mascot Widget with Mood States

### Architecture: Enum-driven mood system with a single reusable widget

The mascot should be a **stateless display widget** driven by an enum — the screen/state management decides the mood, the widget just renders it.

### Flutter Implementation

```dart
// lib/models/mascot_mood.dart
enum MascotMood {
  idle,        // Default gentle bob
  happy,       // Lesson complete, XP earned
  excited,     // Streak milestone, achievement
  thinking,    // Quiz in progress
  sad,         // Streak lost, wrong answer
  sleeping,    // Inactive / night mode
  celebrating, // Level up, big achievement
}

// lib/widgets/danio_mascot.dart
import 'package:flutter/material.dart';

class DanioMascot extends StatelessWidget {
  final MascotMood mood;
  final double size;
  final bool showSpeechBubble;
  final String? speechText;

  const DanioMascot({
    super.key,
    this.mood = MascotMood.idle,
    this.size = 120,
    this.showSpeechBubble = false,
    this.speechText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Mascot image — swap asset per mood
          Image.asset(
            _assetForMood(mood),
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          // Optional speech bubble
          if (showSpeechBubble && speechText != null)
            Positioned(
              top: -40,
              left: size * 0.3,
              child: _SpeechBubble(text: speechText!),
            ),
        ],
      ),
    );
  }

  String _assetForMood(MascotMood mood) {
    return switch (mood) {
      MascotMood.idle        => 'assets/mascot/danio_idle.png',
      MascotMood.happy       => 'assets/mascot/danio_happy.png',
      MascotMood.excited     => 'assets/mascot/danio_excited.png',
      MascotMood.thinking    => 'assets/mascot/danio_thinking.png',
      MascotMood.sad         => 'assets/mascot/danio_sad.png',
      MascotMood.sleeping    => 'assets/mascot/danio_sleeping.png',
      MascotMood.celebrating => 'assets/mascot/danio_celebrating.png',
    };
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DanioColors.deepViolet.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

// Usage anywhere in the app:
DanioMascot(
  mood: MascotMood.happy,
  size: 100,
  showSpeechBubble: true,
  speechText: "Great job! 🐟",
)
```

### Future upgrade path:
When you're ready for animation, this widget becomes the perfect Rive integration point — swap the `Image.asset` for a `RiveAnimation` widget with state machine inputs. Same API surface, the mood enum maps directly to Rive state machine triggers.

---

## 4. Color System: M3 ColorScheme + ThemeData

### Strategy: Fully custom `ColorScheme` (NOT `fromSeed`)

`ColorScheme.fromSeed()` will generate a generic M3 tonal palette that won't match Danio's specific brand colors. For a brand-locked palette, define every role explicitly.

### Flutter Implementation

```dart
// lib/theme/colors.dart
import 'package:flutter/material.dart';

/// Danio brand colors — locked
class DanioColors {
  // === PRIMARY BRAND ===
  static const Color amberGold     = Color(0xFFC8884A);  // Warm amber-gold
  static const Color blueSlate     = Color(0xFF4A5A6B);  // Cool blue-slate
  static const Color deepViolet    = Color(0xFF2A3548);  // Deep violet shadows

  // === EXTENDED PALETTE ===
  static const Color coralAccent   = Color(0xFFE8734A);  // Warm coral for CTAs
  static const Color tealWater     = Color(0xFF5B9EA6);  // Aquarium water teal
  static const Color seafoamLight  = Color(0xFFB8D8D0);  // Light seafoam for surfaces
  static const Color creamWarm     = Color(0xFFFFF5E8);  // Warm cream background
  static const Color ivoryWhite    = Color(0xFFFFFBF5);  // Near-white warm surface

  // === JEWEL TONES (for achievements, badges, accents) ===
  static const Color rubyRed       = Color(0xFFD94F5C);  // Errors, hearts
  static const Color emeraldGreen  = Color(0xFF4CAF7D);  // Success, correct
  static const Color sapphireBlue  = Color(0xFF4A7BC8);  // Info, water depth
  static const Color amethyst      = Color(0xFF8B6BAE);  // Rare achievements
  static const Color topaz         = Color(0xFFE8A84A);  // XP, gold rewards
}

// lib/theme/theme.dart
import 'package:flutter/material.dart';

class DanioTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      // Primary — amber gold (main brand action color)
      primary: DanioColors.amberGold,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFE8CC),  // Light amber container
      onPrimaryContainer: Color(0xFF4A2800),

      // Secondary — blue slate (supporting, navigation)
      secondary: DanioColors.blueSlate,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD8E0E8),
      onSecondaryContainer: Color(0xFF1A2530),

      // Tertiary — teal water (aquarium theme accent)
      tertiary: DanioColors.tealWater,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD0F0ED),
      onTertiaryContainer: Color(0xFF0D3D3A),

      // Error — ruby red
      error: DanioColors.rubyRed,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDADA),
      onErrorContainer: Color(0xFF410002),

      // Surfaces — warm cream tones (NOT cold grey)
      surface: DanioColors.ivoryWhite,
      onSurface: DanioColors.deepViolet,
      surfaceContainerHighest: Color(0xFFEDE5DA),
      surfaceContainerHigh: Color(0xFFF2EBE0),
      surfaceContainer: Color(0xFFF7F0E6),
      surfaceContainerLow: Color(0xFFFCF5EB),
      surfaceContainerLowest: Colors.white,
      onSurfaceVariant: DanioColors.blueSlate,

      // Outline
      outline: Color(0xFFBBA98F),
      outlineVariant: Color(0xFFDDD0C0),

      // Misc
      shadow: DanioColors.deepViolet,
      scrim: DanioColors.deepViolet,
      inverseSurface: DanioColors.deepViolet,
      onInverseSurface: DanioColors.creamWarm,
      inversePrimary: Color(0xFFFFBB66),
    ),

    textTheme: DanioTypography.textTheme,

    // Card theme — warm, not flat
    cardTheme: CardThemeData(
      elevation: 0,           // We'll use custom shadows
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
    ),

    // Buttons — rounded, friendly
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DanioColors.amberGold,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // AppBar — transparent/blended, not flat color
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: DanioColors.deepViolet,
      ),
    ),
  );
}
```

### Extension for jewel tones (achievements, gamification)

```dart
// lib/theme/color_extensions.dart
@immutable
class DanioJewelTones extends ThemeExtension<DanioJewelTones> {
  final Color ruby;
  final Color emerald;
  final Color sapphire;
  final Color amethyst;
  final Color topaz;

  const DanioJewelTones({
    required this.ruby,
    required this.emerald,
    required this.sapphire,
    required this.amethyst,
    required this.topaz,
  });

  @override
  DanioJewelTones copyWith({/* ... */}) => DanioJewelTones(/* ... */);

  @override
  DanioJewelTones lerp(DanioJewelTones? other, double t) {
    if (other is! DanioJewelTones) return this;
    return DanioJewelTones(
      ruby: Color.lerp(ruby, other.ruby, t)!,
      emerald: Color.lerp(emerald, other.emerald, t)!,
      sapphire: Color.lerp(sapphire, other.sapphire, t)!,
      amethyst: Color.lerp(amethyst, other.amethyst, t)!,
      topaz: Color.lerp(topaz, other.topaz, t)!,
    );
  }
}

// Add to ThemeData:
ThemeData(
  extensions: const [
    DanioJewelTones(
      ruby: DanioColors.rubyRed,
      emerald: DanioColors.emeraldGreen,
      sapphire: DanioColors.sapphireBlue,
      amethyst: DanioColors.amethyst,
      topaz: DanioColors.topaz,
    ),
  ],
)

// Access anywhere:
final jewels = Theme.of(context).extension<DanioJewelTones>()!;
Container(color: jewels.topaz) // XP gold
```

---

## 5. Painterly Card/Surface Styling

### Strategy: Custom `Container` with `BoxDecoration` — avoid plain `Card`

M3 `Card` is too flat for a painterly aesthetic. Danio needs warm gradients, soft ambient shadows, and inner glow effects.

### Flutter Implementation

```dart
// lib/widgets/danio_card.dart
import 'package:flutter/material.dart';

enum DanioCardVariant { standard, elevated, highlighted }

class DanioCard extends StatelessWidget {
  final Widget child;
  final DanioCardVariant variant;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const DanioCard({
    super.key,
    required this.child,
    this.variant = DanioCardVariant.standard,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: _decorationForVariant(variant),
        child: child,
      ),
    );
  }

  BoxDecoration _decorationForVariant(DanioCardVariant variant) {
    return switch (variant) {
      // Standard — warm white with subtle depth
      DanioCardVariant.standard => BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),         // Pure white top-left
            Color(0xFFFFF8F0),         // Warm cream bottom-right
          ],
        ),
        boxShadow: [
          // Ambient shadow (large, soft)
          BoxShadow(
            color: DanioColors.deepViolet.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          // Key shadow (small, crisp)
          BoxShadow(
            color: DanioColors.amberGold.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: DanioColors.amberGold.withValues(alpha: 0.1),
          width: 1,
        ),
      ),

      // Elevated — more prominent, for important content
      DanioCardVariant.elevated => BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFF0E0),         // Warmer amber tint
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: DanioColors.deepViolet.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: DanioColors.amberGold.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      // Highlighted — for active/selected states (lesson in progress, etc.)
      DanioCardVariant.highlighted => BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DanioColors.amberGold.withValues(alpha: 0.15),
            DanioColors.tealWater.withValues(alpha: 0.08),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: DanioColors.amberGold.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: DanioColors.amberGold.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
    };
  }
}

// Usage:
DanioCard(
  variant: DanioCardVariant.elevated,
  onTap: () => navigateToLesson(),
  child: Row(
    children: [
      DanioMascot(mood: MascotMood.happy, size: 48),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nitrogen Cycle', style: Theme.of(context).textTheme.titleMedium),
          Text('Lesson 3 of 8', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ],
  ),
)
```

### Glass-morphism variant (for overlay panels):

```dart
// For bottom sheets, modals over illustration backgrounds
BoxDecoration(
  borderRadius: BorderRadius.circular(28),
  color: Colors.white.withValues(alpha: 0.85),
  backgroundBlendMode: BlendMode.overlay,
  boxShadow: [
    BoxShadow(
      color: DanioColors.deepViolet.withValues(alpha: 0.08),
      blurRadius: 40,
    ),
  ],
  border: Border.all(
    color: Colors.white.withValues(alpha: 0.5),
    width: 1.5,
  ),
)
```

---

## 6. Mascot Animation: Lightweight Approaches

### Tiered Strategy (start simple, upgrade when needed)

#### Tier 1: Implicit Animations (Ship Day 1 — zero dependencies)

The lightest possible approach. Use Flutter's built-in implicit animations for subtle idle motion:

```dart
// lib/widgets/animated_mascot.dart
class AnimatedMascot extends StatefulWidget {
  final MascotMood mood;
  final double size;

  const AnimatedMascot({super.key, this.mood = MascotMood.idle, this.size = 120});

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bobAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _bobAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bobAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: child,
          ),
        );
      },
      child: DanioMascot(mood: widget.mood, size: widget.size),
    );
  }
}
```

**Cost:** ~0 extra KB, 60fps, no dependencies. Just a gentle floating bob.

#### Tier 2: Lottie (Quick win if you have After Effects assets)

```yaml
# pubspec.yaml
dependencies:
  lottie: ^3.3.1
```

```dart
// Simple Lottie mascot with mood switching
class LottieMascot extends StatelessWidget {
  final MascotMood mood;

  const LottieMascot({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      _lottieAsset(mood),
      width: 120,
      height: 120,
      repeat: true,
      frameRate: FrameRate(30), // Cap at 30fps for idle — saves battery
    );
  }

  String _lottieAsset(MascotMood mood) => switch (mood) {
    MascotMood.idle => 'assets/lottie/danio_idle.json',
    MascotMood.happy => 'assets/lottie/danio_happy.json',
    // ... etc
    _ => 'assets/lottie/danio_idle.json',
  };
}
```

**Cost:** ~100KB per animation JSON, 30fps idle is plenty, good tooling ecosystem.

#### Tier 3: Rive (Best long-term — recommended for v2+)

Rive is the gold standard for interactive mascots. A single `.riv` file can contain ALL mood states in one state machine — no separate assets per mood.

```yaml
dependencies:
  rive: ^0.13.22
```

```dart
class RiveMascot extends StatefulWidget {
  final MascotMood mood;
  const RiveMascot({super.key, required this.mood});

  @override
  State<RiveMascot> createState() => _RiveMascotState();
}

class _RiveMascotState extends State<RiveMascot> {
  StateMachineController? _smController;
  SMIBool? _isHappy;
  SMIBool? _isSad;
  SMINumber? _excitement;

  void _onRiveInit(Artboard artboard) {
    _smController = StateMachineController.fromArtboard(artboard, 'MascotBrain');
    if (_smController != null) {
      artboard.addController(_smController!);
      _isHappy = _smController!.findInput<bool>('isHappy') as SMIBool?;
      _isSad = _smController!.findInput<bool>('isSad') as SMIBool?;
      _excitement = _smController!.findInput<double>('excitement') as SMINumber?;
    }
    _applyMood(widget.mood);
  }

  void _applyMood(MascotMood mood) {
    _isHappy?.value = mood == MascotMood.happy || mood == MascotMood.celebrating;
    _isSad?.value = mood == MascotMood.sad;
    _excitement?.value = mood == MascotMood.excited ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(RiveMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _applyMood(widget.mood);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(  // CRITICAL: isolate Rive redraws
      child: RiveAnimation.asset(
        'assets/rive/danio_mascot.riv',
        onInit: _onRiveInit,
        fit: BoxFit.contain,
      ),
    );
  }
}
```

**Cost:** Single .riv file ~50-200KB for full character with all states. GPU-accelerated. State machine handles blending between moods automatically.

### Recommendation for Danio:
**Start with Tier 1 (implicit animations) for MVP.** It's zero-dependency and the bob animation sells the "alive" feeling. Commission a Rive file for the mascot when budget/time allows — the widget API stays identical, just swap the implementation.

---

## 7. Duolingo-Style Gamification Widgets

### Core Components

#### 7a. XP Counter with animated increment

```dart
// lib/widgets/xp_counter.dart
class XpCounter extends StatelessWidget {
  final int xp;
  final int? xpGained; // Shows "+15 XP" animation

  const XpCounter({super.key, required this.xp, this.xpGained});

  @override
  Widget build(BuildContext context) {
    final jewels = Theme.of(context).extension<DanioJewelTones>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: jewels.topaz.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: jewels.topaz.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // XP icon (could be a small fish scale icon)
          Icon(Icons.star_rounded, color: jewels.topaz, size: 20),
          const SizedBox(width: 4),
          // Animated number
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: xp - (xpGained ?? 0), end: xp),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Text(
                '$value XP',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DanioColors.deepViolet,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

#### 7b. Streak Counter (fire emoji → water droplet for Danio)

```dart
// lib/widgets/streak_counter.dart
class StreakCounter extends StatelessWidget {
  final int streakDays;
  final bool isActive; // Did they do today's lesson?

  const StreakCounter({super.key, required this.streakDays, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  DanioColors.amberGold.withValues(alpha: 0.2),
                  DanioColors.coralAccent.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isActive ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? DanioColors.amberGold.withValues(alpha: 0.4)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Water droplet instead of fire 🐟
          Text(
            isActive ? '💧' : '💧',
            style: TextStyle(
              fontSize: 18,
              color: isActive ? null : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$streakDays',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isActive ? DanioColors.amberGold : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 7c. Weekly Streak Calendar (Duolingo-style dots)

```dart
// lib/widgets/streak_calendar.dart
class StreakCalendar extends StatelessWidget {
  final List<bool> weekCompletion; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  final int todayIndex; // 0-6

  const StreakCalendar({
    super.key,
    required this.weekCompletion,
    required this.todayIndex,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final isCompleted = weekCompletion[index];
        final isToday = index == todayIndex;
        final isFuture = index > todayIndex;

        return Column(
          children: [
            Text(
              days[index],
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? DanioColors.amberGold
                    : DanioColors.blueSlate.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? DanioColors.emeraldGreen
                    : isFuture
                        ? Colors.grey.shade200
                        : isToday
                            ? DanioColors.amberGold.withValues(alpha: 0.2)
                            : Colors.grey.shade300,
                border: isToday
                    ? Border.all(color: DanioColors.amberGold, width: 2.5)
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                    : isToday
                        ? Text('🐟', style: TextStyle(fontSize: 16))
                        : null,
              ),
            ),
          ],
        );
      }),
    );
  }
}
```

#### 7d. Achievement Badge

```dart
// lib/widgets/achievement_badge.dart
class AchievementBadge extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final bool isUnlocked;
  final String? description;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
    this.isUnlocked = false,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isUnlocked ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUnlocked
                  ? RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.1),
                      ],
                    )
                  : null,
              color: isUnlocked ? null : Colors.grey.shade200,
              border: Border.all(
                color: isUnlocked ? color : Colors.grey.shade300,
                width: 3,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: isUnlocked ? 32 : 24),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isUnlocked ? DanioColors.deepViolet : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Example achievement grid:
Wrap(
  spacing: 16,
  runSpacing: 16,
  children: [
    AchievementBadge(
      title: 'First Tank',
      emoji: '🐠',
      color: DanioColors.tealWater,
      isUnlocked: true,
    ),
    AchievementBadge(
      title: '7-Day Streak',
      emoji: '💧',
      color: DanioColors.sapphireBlue,
      isUnlocked: true,
    ),
    AchievementBadge(
      title: 'Plant Master',
      emoji: '🌿',
      color: DanioColors.emeraldGreen,
      isUnlocked: false,
    ),
    AchievementBadge(
      title: 'Cycle Pro',
      emoji: '🔬',
      color: DanioColors.amethyst,
      isUnlocked: false,
    ),
  ],
)
```

#### 7e. Progress Bar (Lesson completion)

```dart
// lib/widgets/danio_progress_bar.dart
class DanioProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final Color? color;

  const DanioProgressBar({super.key, required this.progress, this.color});

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? DanioColors.amberGold;

    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: barColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [barColor, barColor.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: barColor.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Summary: Implementation Priority

| Priority | Component | Effort | Impact |
|----------|-----------|--------|--------|
| 🔴 P0 | Color system + ThemeData | 2-3 hours | Foundation — everything depends on this |
| 🔴 P0 | Typography (Fredoka + Nunito) | 30 min | Instant brand recognition |
| 🟠 P1 | DanioCard widget | 1-2 hours | Every screen uses cards |
| 🟠 P1 | IllustratedBackground | 1 hour | Core differentiator from generic apps |
| 🟠 P1 | Mascot widget (static PNG) | 1 hour | Brand personality on every screen |
| 🟡 P2 | Gamification widgets (XP, streak, progress) | 3-4 hours | Core engagement loop |
| 🟡 P2 | Achievement badges | 2 hours | Retention + delight |
| 🟢 P3 | Mascot idle animation (Tier 1) | 1 hour | Polish |
| 🟢 P3 | Rive mascot (Tier 3) | Commission + 4 hours integration | Premium feel |

### Key Architecture Decisions

1. **Fully custom ColorScheme** — don't use `fromSeed`, it won't match the brand
2. **ThemeExtension for jewel tones** — clean way to add achievement/gamification colors
3. **WebP for illustrations** — significant size savings over PNG, same quality
4. **Mascot mood as enum** — future-proof pattern that works with PNGs today and Rive tomorrow
5. **Custom cards over M3 Card** — `BoxDecoration` gives the painterly depth that `Card` can't
6. **Start with implicit animations** — zero dependency, ship fast, upgrade to Rive later

---

## 8. Dark Mode: Warm Dark Theme

### Strategy: Explicit warm-dark ColorScheme — avoid M3's cold grey defaults

Flutter's default dark scheme generates cold blue-grey surfaces that completely kill Danio's warmth. Instead, define every dark surface as a **deep warm brown/charcoal** — think "aquarium at night" not "dead grey".

### Colour Philosophy: Deep Ocean Night

| Light | Dark equivalent | Vibe |
|-------|----------------|------|
| Ivory White `#FFFBF5` | Deep Walnut `#1A1208` | Aquarium after dark |
| Cream Warm `#FFF5E8` | Warm Charcoal `#221A10` | Cosy, not cold |
| AmberGold `#C8884A` | Bright Amber `#E8A050` | Slightly lighter to pop on dark |
| BlueSlate `#4A5A6B` | Powder Blue `#A0B4C8` | Readable on dark |
| DeepViolet `#2A3548` | → becomes text on dark | Role reversal |

### Flutter Implementation

```dart
// lib/theme/theme.dart — add darkTheme

static ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,

    // Primary — brighter amber for contrast on dark
    primary: Color(0xFFE8A050),
    onPrimary: Color(0xFF3A1800),
    primaryContainer: Color(0xFF5A3010),
    onPrimaryContainer: Color(0xFFFFDDB0),

    // Secondary — powder blue
    secondary: Color(0xFFA0B4C8),
    onSecondary: Color(0xFF0A1520),
    secondaryContainer: Color(0xFF253545),
    onSecondaryContainer: Color(0xFFD0E8F8),

    // Tertiary — teal
    tertiary: Color(0xFF88C8C0),
    onTertiary: Color(0xFF003830),
    tertiaryContainer: Color(0xFF0D4840),
    onTertiaryContainer: Color(0xFFB0E8E0),

    // Error
    error: Color(0xFFFF8B8B),
    onError: Color(0xFF600000),
    errorContainer: Color(0xFF930000),
    onErrorContainer: Color(0xFFFFDADA),

    // Surfaces — warm dark (NOT cold grey)
    surface: Color(0xFF1A1208),          // Deep warm walnut
    onSurface: Color(0xFFF0E8D8),        // Warm off-white text
    surfaceContainerHighest: Color(0xFF3A2A18),
    surfaceContainerHigh: Color(0xFF2F2010),
    surfaceContainer: Color(0xFF261808),
    surfaceContainerLow: Color(0xFF201408),
    surfaceContainerLowest: Color(0xFF120C04),
    onSurfaceVariant: Color(0xFFB8A890),

    // Outline
    outline: Color(0xFF7A6A50),
    outlineVariant: Color(0xFF4A3A28),

    // Misc
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFF0E8D8),
    onInverseSurface: Color(0xFF1A1208),
    inversePrimary: DanioColors.amberGold,
  ),

  textTheme: DanioTypography.textTheme,

  // Dark app bar — transparent
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.fredoka(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF0E8D8),
    ),
  ),
);

// In MaterialApp:
MaterialApp(
  theme: DanioTheme.lightTheme,
  darkTheme: DanioTheme.darkTheme,
  themeMode: ThemeMode.system, // Respects device setting
  // ...
)
```

### Dark Card Variant

Dark mode cards need a subtle warm gradient and glow instead of flat dark surfaces:

```dart
// In DanioCard._decorationForVariant — add dark mode awareness
BoxDecoration _decorationForVariant(DanioCardVariant variant, bool isDark) {
  if (isDark) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF2F2010),   // Warm dark top
          const Color(0xFF221508),   // Deeper warm bottom
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFFE8A050).withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: const Color(0xFFE8A050).withValues(alpha: 0.12),
        width: 1,
      ),
    );
  }
  // ... original light variants
}
```

---

## 9. Onboarding & First-Run Experience

### Strategy: Max 4 screens, mascot-led, value-first

Research: 80% of users quit learning apps within a week. Your onboarding is the last chance to hook them.

**Rules:**
1. **Show value within 30 seconds** — not feature lists, show the mascot and the promise
2. **Max 4 screens** — every extra screen loses users
3. **Always provide Skip** — forcing users to sit through onboarding breeds resentment
4. **Get to the app fast** — the best onboarding ends with the user doing something, not reading about it

### Recommended 4-Screen Flow

```
Screen 1: Hero splash — Mascot + "Duolingo for Fishkeeping" hook
Screen 2: How it works — 3 icons, 3 bullets (Learn → Practice → Track)
Screen 3: Personalisation — "What type of fishkeeper are you?" (1 choice)
Screen 4: Permission + "Let's Start" CTA
```

### Flutter Implementation

```dart
// lib/features/onboarding/onboarding_screen.dart

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      mascotMood: MascotMood.excited,
      title: 'Duolingo for\nFishkeeping 🐟',
      subtitle: 'Learn to keep healthy, thriving fish — \none lesson at a time.',
      backgroundAsset: 'assets/illustrations/backgrounds/onboarding_hero.webp',
    ),
    OnboardingPageData(
      mascotMood: MascotMood.happy,
      title: 'Learn. Practice.\nTrack.',
      subtitle: 'Bite-sized lessons, real quizzes, and a full tank dashboard.',
      backgroundAsset: 'assets/illustrations/backgrounds/onboarding_features.webp',
    ),
    OnboardingPageData(
      mascotMood: MascotMood.thinking,
      title: 'What kind of\nfishkeeper are you?',
      subtitle: null, // Shows choice buttons instead
      backgroundAsset: 'assets/illustrations/backgrounds/onboarding_profile.webp',
      isPersonalisationPage: true,
    ),
    OnboardingPageData(
      mascotMood: MascotMood.celebrating,
      title: 'Ready to dive in?',
      subtitle: 'Your aquarium journey starts now.',
      backgroundAsset: 'assets/illustrations/backgrounds/onboarding_start.webp',
      isFinalPage: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, i) => _buildPage(_pages[i]),
          ),
          // Skip button — always visible
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: AnimatedOpacity(
              opacity: _currentPage == _pages.length - 1 ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Page dots
          Positioned(
            bottom: 120,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => _buildDot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? DanioColors.amberGold
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _completeOnboarding() async {
    // Mark onboarding complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}

// Check in main.dart / router:
// if (!prefs.getBool('onboarding_complete', false)) → show OnboardingScreen
```

---

## 10. Micro-interactions & Celebrations

### Packages

```yaml
# pubspec.yaml
dependencies:
  confetti: ^0.7.0              # Core confetti burst
  easy_conffeti: ^0.0.5         # Extended types (level up, achievements)
  flutter_animate: ^4.5.0       # Chainable micro-animations (the best)
```

### Why `flutter_animate`?

`flutter_animate` is the cleanest package for micro-interactions. Chain animations declaratively:

```dart
// Correct answer feedback — scale pop + green flash
Container(
  child: const Text('✓'),
).animate()
  .scale(begin: const Offset(0.8, 0.8), duration: 200.ms, curve: Curves.elasticOut)
  .then()
  .shake(duration: 0.ms); // No shake on correct

// Wrong answer feedback — shake + red
Container(
  child: const Text('✗'),
).animate()
  .shake(hz: 4, curve: Curves.easeInOut, duration: 400.ms)
  .tint(color: DanioColors.rubyRed, duration: 300.ms);

// XP gain pop — slide up + fade
Text('+15 XP')
  .animate()
  .slideY(begin: 0.5, end: -1.5, duration: 800.ms, curve: Curves.easeOut)
  .fadeOut(begin: 0.8, duration: 800.ms);
```

### Celebration Widget

```dart
// lib/widgets/celebration_overlay.dart
import 'package:confetti/confetti.dart';

enum CelebrationLevel { correct, lessonComplete, streakMilestone, levelUp }

class CelebrationOverlay extends StatefulWidget {
  final CelebrationLevel level;
  final VoidCallback onComplete;

  const CelebrationOverlay({
    super.key,
    required this.level,
    required this.onComplete,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late ConfettiController _confettiLeft;
  late ConfettiController _confettiRight;

  // Danio brand confetti colours
  static const List<Color> _confettiColors = [
    DanioColors.amberGold,
    DanioColors.tealWater,
    DanioColors.coralAccent,
    DanioColors.emeraldGreen,
    DanioColors.sapphireBlue,
    DanioColors.amethyst,
  ];

  @override
  void initState() {
    super.initState();
    final duration = switch (widget.level) {
      CelebrationLevel.correct          => const Duration(seconds: 1),
      CelebrationLevel.lessonComplete   => const Duration(seconds: 3),
      CelebrationLevel.streakMilestone  => const Duration(seconds: 4),
      CelebrationLevel.levelUp          => const Duration(seconds: 5),
    };
    _confettiLeft = ConfettiController(duration: duration);
    _confettiRight = ConfettiController(duration: duration);
    
    _confettiLeft.play();
    _confettiRight.play();
    
    Future.delayed(duration + const Duration(milliseconds: 500), widget.onComplete);
  }

  @override
  void dispose() {
    _confettiLeft.dispose();
    _confettiRight.dispose();
    super.dispose();
  }

  int get _particleCount => switch (widget.level) {
    CelebrationLevel.correct         => 10,
    CelebrationLevel.lessonComplete  => 25,
    CelebrationLevel.streakMilestone => 40,
    CelebrationLevel.levelUp         => 60,
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left emitter
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _confettiLeft,
            blastDirection: -pi / 6,   // Slightly right of down
            numberOfParticles: _particleCount,
            maxBlastForce: 30,
            minBlastForce: 15,
            gravity: 0.3,
            colors: _confettiColors,
            emissionFrequency: 0.04,
          ),
        ),
        // Right emitter
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _confettiRight,
            blastDirection: -pi + pi / 6,  // Slightly left of down
            numberOfParticles: _particleCount,
            maxBlastForce: 30,
            minBlastForce: 15,
            gravity: 0.3,
            colors: _confettiColors,
            emissionFrequency: 0.04,
          ),
        ),
      ],
    );
  }
}
```

### Answer Feedback Widgets

```dart
// lib/widgets/answer_feedback.dart

/// Full-screen overlay for correct/wrong answer
class AnswerFeedback extends StatelessWidget {
  final bool isCorrect;
  final String? correctAnswer;
  final VoidCallback onContinue;

  const AnswerFeedback({
    super.key,
    required this.isCorrect,
    this.correctAnswer,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? DanioColors.emeraldGreen : DanioColors.rubyRed;
    final emoji = isCorrect ? '🎉' : '❌';
    final label = isCorrect ? 'Correct!' : 'Incorrect';

    return Container(
      color: color.withValues(alpha: 0.12),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon
          Text(emoji, style: const TextStyle(fontSize: 48))
              .animate()
              .scale(begin: const Offset(0, 0), duration: 300.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ).animate().fadeIn(duration: 200.ms),
          if (!isCorrect && correctAnswer != null) ...[
            const SizedBox(height: 8),
            Text(
              'Correct answer: $correctAnswer',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: DanioColors.blueSlate,
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: Text(isCorrect ? 'Continue' : 'Got it'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 11. Haptic Feedback System

### Package

```yaml
dependencies:
  haptic_feedback: ^0.5.1  # Cross-platform, iOS patterns emulated on Android
```

### Haptic Map (Danio-Specific)

| Event | Haptic Pattern | Why |
|-------|---------------|-----|
| Correct answer | `HapticFeedback.lightImpact()` | Positive, light confirmation |
| Wrong answer | `HapticFeedback.heavyImpact()` + delay 200ms + `heavyImpact()` | Double thud — unmistakable failure signal |
| Lesson complete | `HapticFeedback.mediumImpact()` × 3 in rapid succession | Celebratory triple tap |
| Streak milestone | Custom pattern: light, medium, heavy ramp-up | Building excitement |
| XP gained | `HapticFeedback.selectionClick()` | Subtle reward tick |
| Navigation tap | `HapticFeedback.selectionClick()` | Standard nav feedback |
| Button press | `HapticFeedback.lightImpact()` | Confirm press |
| Long press | `HapticFeedback.mediumImpact()` | Context menu trigger |

### Implementation

```dart
// lib/services/haptic_service.dart
import 'package:flutter/services.dart';

class HapticService {
  // Prevent construction
  HapticService._();

  static void correct() => HapticFeedback.lightImpact();

  static void wrong() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.heavyImpact();
  }

  static void lessonComplete() async {
    for (int i = 0; i < 3; i++) {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  static void streakMilestone() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();
  }

  static void xpGained() => HapticFeedback.selectionClick();
  static void tap() => HapticFeedback.selectionClick();
  static void buttonPress() => HapticFeedback.lightImpact();
}

// Usage in quiz screen:
void _onAnswerSelected(bool isCorrect) {
  if (isCorrect) {
    HapticService.correct();
    // Show green feedback + confetti
  } else {
    HapticService.wrong();
    // Show red feedback + shake
  }
}
```

---

## 12. Loading States & Skeleton Screens

### Package

```yaml
dependencies:
  skeletonizer: ^1.4.2  # Wraps any widget — zero layout code changes
```

### Why Skeletonizer?

`skeletonizer` lets you wrap your actual widgets and they automatically shimmer — no separate skeleton layout needed. Uses warm amber shimmer (not cold chrome) to stay on-brand.

```dart
// lib/widgets/danio_skeleton.dart
import 'package:skeletonizer/skeletonizer.dart';

class DanioSkeleton extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const DanioSkeleton({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      effect: ShimmerEffect(
        baseColor: DanioColors.amberGold.withValues(alpha: 0.08),
        highlightColor: DanioColors.amberGold.withValues(alpha: 0.20),
        duration: const Duration(milliseconds: 1200),
      ),
      child: child,
    );
  }
}

// Usage — wrap your actual widget, zero layout change:
DanioSkeleton(
  isLoading: _isLoadingTankData,
  child: TankCard(tank: _tankData ?? TankCard.placeholder()),
)
```

### Placeholder Data Pattern

For skeleton screens, use a `.placeholder()` factory on data models:

```dart
class TankData {
  final String name;
  final String fishCount;
  // ...

  // Fake data that fills the layout identically to real data
  factory TankData.placeholder() => TankData(
    name: '████████████',     // Long enough to fill the name field
    fishCount: '██',
  );
}
```

---

## 13. Navigation & Page Transitions

### Strategy: Custom transitions that feel aquatic

Default Flutter push/pop transitions feel mechanical. For Danio, use custom `PageRouteBuilder` with a slide-up/fade that feels like surfacing from water.

```dart
// lib/navigation/danio_routes.dart

class DanioPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  DanioPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide up + fade — feels like surfacing
            const begin = Offset(0, 0.08);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: Curves.easeOutCubic),
            );
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: const Interval(0, 0.6)),
            );

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
}

// Usage:
Navigator.of(context).push(DanioPageRoute(page: const LessonScreen()));
```

### Bottom Navigation

Danio should use a **custom bottom nav** — the standard `BottomNavigationBar` is too flat. Use `NavigationBar` (M3) with custom indicator colour:

```dart
NavigationBar(
  backgroundColor: Colors.white,
  indicatorColor: DanioColors.amberGold.withValues(alpha: 0.15),
  selectedIndex: _selectedIndex,
  onDestinationSelected: (i) => setState(() => _selectedIndex = i),
  destinations: const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school_rounded),
      label: 'Learn',
    ),
    NavigationDestination(
      icon: Icon(Icons.water_outlined),
      selectedIcon: Icon(Icons.water_rounded),
      label: 'My Tank',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outlined),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ],
)
```

---

## 14. Gamification Psychology — Duolingo Lessons for Danio

Research-backed numbers from Duolingo (34M DAUs, $14B valuation):

| Mechanic | Duolingo Result | Danio Application |
|----------|----------------|-------------------|
| 7-day streak visible | **3.6x** more likely to stay long-term | Show streak prominently on home screen |
| Streak Freeze feature | **21% churn reduction** for at-risk users | "Tank Insurance" — skip a day without losing streak |
| Home screen streak widget | **60% increase** in daily commitment | Lock screen widget (future v2) |
| XP leaderboards | **40% more** lessons per week | Weekly XP board between friends |
| Limited-time XP boosts | **50% surge** in activity | "Weekend Water Change" double XP |
| Achievement badges | **30% more** likely to finish a course | Achievement system (already in guide) |
| Daily Quests | **25% increase** in DAUs | "Today's Challenge" on home screen |

### Critical Design Principle: **Forgiveness**

Duolingo's streaks are sticky *because* they're forgiving. The Streak Freeze makes the streak feel safe to maintain. Without it, users give up when they miss a day.

**For Danio:** Introduce "Tank Insurance" — a consumable item (earned or purchasable) that protects a streak for one missed day. Show it in the streak UI so users know they're protected.

```dart
// Streak counter with insurance indicator
class StreakCounter extends StatelessWidget {
  final int streakDays;
  final bool isActive;
  final bool hasInsurance;   // "Tank Insurance" active

  // ... (extend existing widget)

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Base streak counter (existing widget)
        _buildBaseCounter(),
        // Insurance indicator
        if (hasInsurance)
          Positioned(
            top: -4, right: -4,
            child: Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: DanioColors.sapphireBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Text('🛡️', style: TextStyle(fontSize: 10)),
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## 15. Master Package Registry

Complete list of recommended packages for Danio with versions and purpose:

```yaml
dependencies:
  # Typography
  google_fonts: ^6.2.1          # Fredoka + Nunito

  # Animations & Micro-interactions
  flutter_animate: ^4.5.0       # Chainable declarative animations (MUST HAVE)
  confetti: ^0.7.0              # Celebration confetti bursts

  # Haptics
  haptic_feedback: ^0.5.1       # Cross-platform haptic patterns

  # Loading States
  skeletonizer: ^1.4.2          # Shimmer skeleton screens

  # Onboarding
  shared_preferences: ^2.3.2    # Persist onboarding completion flag

  # State Management (for gamification state)
  flutter_riverpod: ^2.6.1      # Recommended for Danio's complexity level
  # OR: bloc: ^8.1.4            # If team prefers BLoC

  # Future / Phase 2
  # rive: ^0.13.22              # Mascot animation (when ready)
  # lottie: ^3.3.1              # Alternative animation option
  # audioplayers: ^6.1.0        # Sound design (correct/wrong/level-up SFX)
```

---

## Updated Priority Table

| Priority | Component | Effort | Impact |
|----------|-----------|--------|--------|
| 🔴 P0 | Color system + ThemeData | 2-3 hrs | Foundation |
| 🔴 P0 | Typography (Fredoka + Nunito) | 30 min | Brand recognition |
| 🟠 P1 | DanioCard widget | 1-2 hrs | Every screen |
| 🟠 P1 | IllustratedBackground | 1 hr | Core differentiator |
| 🟠 P1 | Mascot widget (static PNG) | 1 hr | Brand personality |
| 🟠 P1 | Haptic feedback map | 30 min | Feel premium immediately |
| 🟡 P2 | Gamification widgets (XP, streak, progress) | 3-4 hrs | Engagement loop |
| 🟡 P2 | Achievement badges | 2 hrs | Retention |
| 🟡 P2 | Onboarding (4-screen mascot-led) | 3-4 hrs | First impression |
| 🟡 P2 | Answer feedback (correct/wrong) | 2 hrs | Quiz feel |
| 🟡 P2 | Celebration overlay (confetti) | 1-2 hrs | Delight |
| 🟡 P2 | Skeleton loading states | 1 hr | Polish |
| 🟡 P2 | Custom page transitions | 1 hr | Cohesion |
| 🟢 P3 | Dark mode | 2-3 hrs | Accessibility/preference |
| 🟢 P3 | Mascot idle animation (Tier 1) | 1 hr | Extra polish |
| 🟢 P3 | Tank Insurance mechanic | 2 hrs | Retention hook |
| 🟢 P3 | Rive mascot (Tier 3) | Commission + 4 hrs | Premium feel |
| 🔵 P4 | Sound design (SFX) | 2 hrs + audio assets | Duolingo-level feel |
| 🔵 P4 | XP leaderboards | 4+ hrs | Social retention |

---

*Guide updated: 2026-02-28 — Phase 2 expansion*
*Covers: Typography · Colors · Mascot · Backgrounds · Cards · Animations · Gamification · Dark Mode · Onboarding · Micro-interactions · Haptics · Loading States · Navigation · Psychology*

---

## 16. ⚠️ Critical Accessibility Fix: Amber Contrast Failure

### The Problem

**Amber `#F59E0B` on white `#FFFFFF` = 2.1:1 contrast ratio — this FAILS WCAG AA.**

WCAG AA requires **4.5:1 for normal text, 3:1 for large text**. Our primary amber fails both.
This affects XP counter labels, streak numbers, and any amber-coloured text on light backgrounds.

### Safe Amber Usage

| Colour | Background | Contrast | WCAG AA Status |
|--------|-----------|---------|----------------|
| `#F59E0B` (Amber 500) | White | 2.1:1 | ❌ **FAILS** |
| `#D97706` (Amber 600) | White | 3.0:1 | ⚠️ Large text only |
| `#B45309` (Amber 700) | White | 4.7:1 | ✅ **PASSES** all text |
| `#FBBF24` (Amber 400) | `#1C1917` dark | 7.2:1 | ✅ **PASSES** (dark mode) |
| `#F59E0B` (Amber 500) | `#1C1917` dark | 4.8:1 | ✅ Passes (dark mode) |

### Fix

```dart
class DanioColors {
  // Use cases:
  static const Color amberGold      = Color(0xFFC8884A);  // Decorative only (UI chrome, borders)
  static const Color amberText      = Color(0xFFB45309);  // ← NEW: AA-safe for amber text on light
  static const Color amberTextDark  = Color(0xFFFBBF24);  // ← NEW: AA-safe for amber text on dark
  // ...
}

// XP counter — use amberText not amberGold:
Text(
  '$xp XP',
  style: GoogleFonts.nunito(
    color: isDarkMode ? DanioColors.amberTextDark : DanioColors.amberText,
    fontWeight: FontWeight.w800,
  ),
)
```

### Built-in Accessibility Testing

Add this to your widget tests — it runs contrast checks automatically:

```dart
// test/accessibility_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('XP counter meets WCAG AA contrast', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: DanioTheme.lightTheme,
      home: const XpCounter(xp: 1500),
    ));
    expect(tester, meetsGuideline(textContrastGuideline));
  });

  testWidgets('Streak counter meets WCAG', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: DanioTheme.lightTheme,
      home: const StreakCounter(streakDays: 14),
    ));
    expect(tester, meetsGuideline(textContrastGuideline));
    expect(tester, meetsGuideline(androidTapTargetGuideline));
  });
}
```

---

## 17. Dark Mode v2: fromSeed + copyWith (Preferred Approach)

The Phase 2 dark mode section used a fully manual `ColorScheme`. This is correct but verbose.
A more maintainable approach: **let M3 generate the tonal palette, then override only the surfaces**:

```dart
// lib/theme/theme.dart — UPDATED dark theme approach

static ThemeData get darkTheme {
  // Let M3 generate the tonal palette from our amber seed
  final darkScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFF59E0B), // Amber seed
    brightness: Brightness.dark,
  ).copyWith(
    // Override surfaces to warm charcoal (M3 default is cold #1C1B1F)
    surface:                   const Color(0xFF1C1917), // Warm charcoal (stone-950)
    onSurface:                 const Color(0xFFFAF5F0), // Warm white
    surfaceContainerHighest:   const Color(0xFF292524), // Stone-800
    surfaceContainerHigh:      const Color(0xFF231F1E),
    surfaceContainer:          const Color(0xFF1F1B1A),
    surfaceContainerLow:       const Color(0xFF1A1614),
    surfaceContainerLowest:    const Color(0xFF110E0C),
    onSurfaceVariant:          const Color(0xFFCDBFAE), // Warm muted text
    // Override amber text to be legible on dark surfaces
    primary:                   const Color(0xFFFBBF24), // Amber-400 — passes on dark
    onPrimary:                 const Color(0xFF3A1800),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: darkScheme,
    textTheme: DanioTypography.textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFAF5F0),
      ),
    ),
  );
}
```

**Why this is better:** M3 handles primary/secondary/tertiary tonal mapping automatically, so buttons, chips, and M3 components stay cohesive. You only override the cold surfaces.

---

## 18. Accessibility: Semantic Roles for Gamification Widgets

Using Flutter 3.32's `SemanticsRole` API to make game elements screen-reader-friendly:

```dart
// lib/widgets/accessible_xp_counter.dart

class AccessibleXpCounter extends StatelessWidget {
  final int xp;
  final int? xpGained;

  const AccessibleXpCounter({super.key, required this.xp, this.xpGained});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'XP total',
      value: '$xp experience points',
      // role: SemanticsRole.status,  // Uncomment when Flutter 3.32+ confirmed
      child: XpCounter(xp: xp, xpGained: xpGained),
    );
  }
}

// lib/widgets/accessible_streak_counter.dart
class AccessibleStreakCounter extends StatelessWidget {
  final int streakDays;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Daily streak',
      value: '$streakDays days',
      hint: isActive ? 'Streak active' : 'Streak at risk — complete a lesson today',
      child: StreakCounter(streakDays: streakDays, isActive: isActive),
    );
  }
}

// lib/widgets/accessible_progress_bar.dart
class AccessibleProgressBar extends StatelessWidget {
  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: '${(progress * 100).round()}%',
      child: DanioProgressBar(progress: progress),
    );
  }
}
```

### Live Announcements for XP Gains

Screen reader users can't see the floating "+15 XP" animation. Announce it:

```dart
// When XP is awarded:
void _awardXP(int amount) {
  setState(() => _xp += amount);
  
  // Announce to screen readers
  SemanticsService.announce(
    'You earned $amount XP! Total: $_xp XP',
    TextDirection.ltr,
  );
  
  HapticService.xpGained();
}

// When achievement unlocked:
void _unlockAchievement(String name) {
  SemanticsService.announce(
    'Achievement unlocked: $name',
    TextDirection.ltr,
  );
  HapticService.streakMilestone(); // Dramatic haptic
}
```

---

## 19. Streak Milestone System

Inspired by Duolingo's 600+ A/B-tested milestone animations. 

### Milestone Thresholds

| Day | Name | Mascot State | Celebration Level |
|-----|------|-------------|------------------|
| 3 | "Getting Started" | Happy | correct |
| 7 | "One Week Wonder" | Excited | lessonComplete |
| 14 | "Fortnight Fisher" | Excited + bubble burst | streakMilestone |
| 30 | "Monthly Master" | Celebrating | streakMilestone |
| 60 | "Dedicated Diver" | Celebrating + full confetti | levelUp |
| 100 | "Century Club" | Special animation TBD | levelUp |
| 365 | "Year of the Fish" | Legendary animation | levelUp |

### Streak Milestone Widget

```dart
// lib/widgets/streak_milestone.dart

class StreakMilestone extends StatelessWidget {
  final int streakDays;
  final VoidCallback onContinue;

  const StreakMilestone({
    super.key,
    required this.streakDays,
    required this.onContinue,
  });

  String get _milestoneName => switch (streakDays) {
    3   => 'Getting Started! 🐠',
    7   => 'One Week Wonder! 🌊',
    14  => 'Fortnight Fisher! 🐟',
    30  => 'Monthly Master! 🦈',
    60  => 'Dedicated Diver! 🐙',
    100 => 'Century Club! 🪸',
    365 => 'Year of the Fish! 🌟',
    _   => 'Streak Milestone! 💧',
  };

  CelebrationLevel get _celebrationLevel => switch (streakDays) {
    <= 6  => CelebrationLevel.correct,
    <= 13 => CelebrationLevel.lessonComplete,
    <= 59 => CelebrationLevel.streakMilestone,
    _     => CelebrationLevel.levelUp,
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CelebrationOverlay(
          level: _celebrationLevel,
          onComplete: () {}, // Don't auto-dismiss — user taps Continue
        ),
        Center(
          child: DanioCard(
            variant: DanioCardVariant.elevated,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DanioMascot(mood: MascotMood.celebrating, size: 160),
                const SizedBox(height: 16),
                Text(
                  '$streakDays Days!',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  _milestoneName,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Keep Going! 🔥'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 20. Sound Design Palette

Sound is Duolingo's invisible brand element — the "ding" is as recognisable as the green owl.
Define Danio's signature sounds early; add them post-MVP.

```yaml
# pubspec.yaml (Phase 2 / P4)
dependencies:
  audioplayers: ^6.1.0  # For short SFX clips
```

### Sound Map

| Event | Sound Style | Duration | Notes |
|-------|------------|---------|-------|
| Correct answer | Warm chime + bubble pop | 0.3s | Major key, bright |
| Wrong answer | Low plonk | 0.3s | Minor key, gentle — not harsh |
| Lesson complete | Rising fanfare + bubble burst | 1.5s | Triumphant but warm |
| Streak milestone | Building swell + chime | 2s | Escalating drama |
| Level up | Full fanfare + crowd cheer | 3s | The big moment |
| Navigation tap | Soft bubble pop | 0.1s | Barely audible |
| Streak protected | Shield "ding" | 0.5s | Protective, reassuring |
| App open | Ambient water + chime | 1s | Signature brand sound |

**Sound design brief:** Aquarium-adjacent. Warm, bubbly, oceanic. Major keys for positive, gentle minor for corrective. Never harsh, never startling. Think: coral reef at dawn, not action game.

---

## 21. App Store Creative Specifications

### Screenshot Dimensions

| Platform | Dimensions | Format |
|---------|-----------|--------|
| App Store (6.9" iPhone) | 1290 × 2796px | PNG/JPEG |
| App Store (6.5" iPhone) | 1242 × 2688px | PNG/JPEG |
| Google Play | 1080 × 1920px | PNG/JPEG |
| Google Play Feature Graphic | 1024 × 500px | PNG/JPEG |

### Danio Screenshot Sequence

| # | Title | Caption (max 7 words) | Key UI Elements |
|---|-------|----------------------|----------------|
| 1 | Hero | "Learn Aquarium Keeping the Fun Way" | Mascot + painterly aquarium BG + app UI |
| 2 | Gamification | "Earn XP, Grow Your Streak" | XP bar + streak counter + badge grid |
| 3 | Content | "Real Fish, Real Knowledge" | Fish ID card + painterly art |
| 4 | Learning | "Bite-Sized Lessons, Big Results" | Quiz screen + progress bar + mascot |
| 5 | Dark mode | "Beautiful in Any Light" | Same UI in dark mode |

**Text overlay style:**
- Font: Fredoka Bold
- Colour: White on dark backgrounds, Deep Violet on light
- Position: Top 30% of screen (above device fold)
- Background: Danio amber gradient band or transparent with shadow

---

*Guide last updated: 2026-02-28 — Phase 3 expansion (deep research)*
*Total sections: 21 | Total: ~2,500+ lines*
*Covers: Typography · Colors · Mascot · Backgrounds · Cards · Animation · Gamification · Dark Mode · Onboarding · Micro-interactions · Haptics · Loading · Navigation · Psychology · WCAG Fixes · Semantics · Milestones · Sound · Screenshots*
