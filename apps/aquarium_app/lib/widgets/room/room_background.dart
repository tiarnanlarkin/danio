import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';

// === BACKGROUND IMAGE MAPPING ===

/// Returns the asset path for themes that have a dedicated background image,
/// or null for themes that use a gradient fallback.
///
/// When new WebP files are added to assets/images/room/ for the placeholder
/// themes, they will be automatically picked up — no code changes needed.
String? backgroundAssetForTheme(RoomThemeType type) {
  switch (type) {
    case RoomThemeType.cozyLiving:
      return 'assets/backgrounds/room-bg-cozy-living.webp';
    case RoomThemeType.midnight:
      return 'assets/backgrounds/room-bg-midnight.webp';
    case RoomThemeType.ocean:
      return 'assets/backgrounds/room-bg-ocean.webp';
    case RoomThemeType.forest:
      return 'assets/backgrounds/room-bg-forest.webp';
    // ── All room background WebPs provided (generated 2026-03-29).
    case RoomThemeType.pastel:
      return 'assets/backgrounds/room-bg-pastel.webp';
    case RoomThemeType.sunset:
      return 'assets/backgrounds/room-bg-sunset.webp';
    case RoomThemeType.dreamy:
      return 'assets/backgrounds/room-bg-dreamy.webp';
    case RoomThemeType.watercolor:
      return 'assets/backgrounds/room-bg-watercolor.webp';
    case RoomThemeType.cotton:
      return 'assets/backgrounds/room-bg-cotton.webp';
    case RoomThemeType.aurora:
      return 'assets/backgrounds/room-bg-aurora.webp';
    case RoomThemeType.golden:
      return 'assets/backgrounds/room-bg-golden.webp';
    case RoomThemeType.eveningGlow:
      return 'assets/backgrounds/room-bg-evening-glow.webp';
  }
}

// === GRADIENT DEFINITIONS ===
// Each theme gets 3-4 stops. The radial overlay adds depth — lighter at
// centre-right (where the tank sits), darker at the edges.

/// Returns the multi-stop linear gradient for a theme's background.
LinearGradient _gradientForTheme(RoomThemeType type) {
  switch (type) {
    case RoomThemeType.pastel:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.35, 0.65, 1.0],
        colors: [
          Color(0xFFF0F4FA), // sky lavender
          Color(0xFFE8EEF5), // soft blue-gray
          Color(0xFFDDE6F0), // muted blue
          Color(0xFFD0DCEB), // deeper muted blue
        ],
      );
    case RoomThemeType.sunset:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.30, 0.65, 1.0],
        colors: [
          Color(0xFFF5B8A0), // peach sky
          Color(0xFFE8A088), // warm orange
          Color(0xFFD08070), // burnt coral
          Color(0xFFB86860), // deep rose
        ],
      );
    case RoomThemeType.dreamy:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.33, 0.67, 1.0],
        colors: [
          Color(0xFFE8D5F5), // soft lilac
          Color(0xFFD8EAFF), // dream blue
          Color(0xFFD5F0E8), // mint whisper
          Color(0xFFEED5E8), // blush lavender
        ],
      );
    case RoomThemeType.watercolor:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.40, 0.75, 1.0],
        colors: [
          Color(0xFFE0F0F8), // watercolor sky
          Color(0xFFCCE4F4), // paper wash
          Color(0xFFB8D8EE), // deeper wash
          Color(0xFFA0CAE4), // shadow wash
        ],
      );
    case RoomThemeType.cotton:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.30, 0.65, 1.0],
        colors: [
          Color(0xFFFFF0F8), // cotton candy top
          Color(0xFFFFE0F0), // soft pink
          Color(0xFFE8D0F8), // candy purple
          Color(0xFFD0C0F0), // deeper purple
        ],
      );
    case RoomThemeType.aurora:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.25, 0.60, 1.0],
        colors: [
          Color(0xFF0D2030), // arctic night
          Color(0xFF0A2E28), // deep green-black
          Color(0xFF1A3A28), // aurora green shadow
          Color(0xFF0E1C2E), // midnight base
        ],
      );
    case RoomThemeType.golden:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.35, 0.65, 1.0],
        colors: [
          Color(0xFFFFF3C0), // golden hour sky
          Color(0xFFFFE080), // warm amber
          Color(0xFFFFCC50), // deep gold
          Color(0xFFE8A820), // rich amber
        ],
      );
    case RoomThemeType.eveningGlow:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.35, 0.68, 1.0],
        colors: [
          Color(0xFF2E1A38), // twilight purple
          Color(0xFF3A2040), // dusk violet
          Color(0xFF4A2A30), // warm dusk
          Color(0xFF2A1A20), // deep evening
        ],
      );

    // Fallback for themes that should have images but use gradient as error:
    case RoomThemeType.ocean:
    case RoomThemeType.cozyLiving:
    case RoomThemeType.midnight:
    case RoomThemeType.forest:
      final theme = RoomTheme.fromType(type);
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.45, 1.0],
        colors: [theme.waterTop, theme.background1, theme.background3],
      );
  }
}

/// A subtle radial gradient overlay that adds depth — slightly darker at
/// the edges, brighter at centre-right where the aquarium tank sits.
RadialGradient _radialDepthOverlay() {
  return const RadialGradient(
    center: Alignment(0.3, 0.0), // centre-right, upper half
    radius: 0.85,
    stops: [0.0, 0.55, 1.0],
    colors: [
      Color(0x00FFFFFF), // transparent at focus
      Color(0x08FFFFFF), // very faint mid
      Color(0x22000000), // subtle dark at edges
    ],
  );
}

// === ANIMATED GRADIENT BACKGROUND ===

/// Animated background that slowly shifts between two gradient states to
/// give the background a living, ambient feel.
///
/// - Cycle time: 24 seconds (slow enough to be imperceptible as animation,
///   felt only as subtle warmth/coolness shifts).
/// - Respects [MediaQuery.disableAnimations] — falls back to static.
class AnimatedGradientBackground extends StatefulWidget {
  final RoomThemeType type;

  const AnimatedGradientBackground({super.key, required this.type});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final gradient = _gradientForTheme(widget.type);

    if (reduceMotion) {
      return _GradientWithDepth(gradient: gradient, type: widget.type);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Subtle shift: lerp each colour stop by a tiny amount
        final t = Curves.easeInOut.transform(_controller.value);
        final shiftedColors = gradient.colors.indexed.map((entry) {
          final i = entry.$1;
          final color = entry.$2;
          // Alternate between warming and cooling each stop slightly
          final shift = (i % 2 == 0 ? 0.04 : -0.03) * t;
          return Color.lerp(color, _shiftBrightness(color, shift), 1.0)!;
        }).toList();

        final shifted = gradient.copyWith(colors: shiftedColors);
        return _GradientWithDepth(gradient: shifted, type: widget.type);
      },
    );
  }

  /// Shifts a colour's perceived brightness by [delta] (-1 to 1).
  Color _shiftBrightness(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + delta).clamp(0.0, 1.0))
        .toColor();
  }
}

/// Combines the linear gradient with a radial depth overlay on top.
class _GradientWithDepth extends StatelessWidget {
  final LinearGradient gradient;
  final RoomThemeType type;

  const _GradientWithDepth({required this.gradient, required this.type});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: gradient),
          child: const SizedBox.expand(),
        ),
        DecoratedBox(
          decoration: BoxDecoration(gradient: _radialDepthOverlay()),
          child: const SizedBox.expand(),
        ),
      ],
    );
  }
}

// === PUBLIC API ===

/// Returns an intentional gradient background for themes without a photo.
Widget gradientFallbackForTheme(RoomThemeType type) {
  return AnimatedGradientBackground(type: type);
}

/// Builds the room background widget for [type].
///
/// - If a WebP asset path exists for this theme and the file loads
///   successfully, the photo is used.
/// - Otherwise (file missing or load error), falls back to the animated
///   gradient with radial depth overlay.
Widget buildRoomBackground(RoomThemeType type) {
  final assetPath = backgroundAssetForTheme(type);
  if (assetPath == null) {
    return gradientFallbackForTheme(type);
  }
  return Image.asset(
    assetPath,
    fit: BoxFit.cover,
    cacheWidth: 1024,
    cacheHeight: 1024,
    errorBuilder: (context, error, stackTrace) =>
        gradientFallbackForTheme(type),
  );
}

// === SPARKLE (for whimsical/night themes) ===

class Sparkle extends StatelessWidget {
  final double size;
  final Color color;

  const Sparkle({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SparklePainter(color: color),
    );
  }
}

class SparklePainter extends CustomPainter {
  final Color color;
  late final Color _colorAlpha178 = color.withAlpha(178);

  SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _colorAlpha178
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // 4-point star
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(
        center.dx + r * 0.2,
        center.dy - r * 0.2,
        center.dx + r,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + r * 0.2,
        center.dy + r * 0.2,
        center.dx,
        center.dy + r,
      )
      ..quadraticBezierTo(
        center.dx - r * 0.2,
        center.dy + r * 0.2,
        center.dx - r,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - r * 0.2,
        center.dy - r * 0.2,
        center.dx,
        center.dy - r,
      );

    canvas.drawPath(path, paint);

    // Inner glow
    canvas.drawCircle(center, r * 0.3, Paint()..color = AppOverlays.white50);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// === HELPERS ===

extension _IndexedIterable<T> on Iterable<T> {
  Iterable<(int, T)> get indexed sync* {
    var i = 0;
    for (final e in this) {
      yield (i++, e);
    }
  }
}

extension _LinearGradientCopyWith on LinearGradient {
  LinearGradient copyWith({List<Color>? colors}) {
    return LinearGradient(
      begin: begin,
      end: end,
      stops: stops,
      colors: colors ?? this.colors,
      tileMode: tileMode,
      transform: transform,
    );
  }
}
