import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/room_theme_provider.dart';
import '../theme/room_themes.dart';

/// Which tab the header is for — determines which asset to load.
enum TabHeaderContext { learn, practice, smart }

// === ASSET PATH MAPPING ===

/// Maps a theme slug to the kebab-case used in file names.
String _themeSlug(RoomThemeType type) {
  return switch (type) {
    RoomThemeType.ocean => 'ocean',
    RoomThemeType.pastel => 'pastel',
    RoomThemeType.sunset => 'sunset',
    RoomThemeType.midnight => 'midnight',
    RoomThemeType.forest => 'forest',
    RoomThemeType.dreamy => 'dreamy',
    RoomThemeType.watercolor => 'watercolor',
    RoomThemeType.cotton => 'cotton',
    RoomThemeType.aurora => 'aurora',
    RoomThemeType.golden => 'golden',
    RoomThemeType.cozyLiving => 'cozy-living',
    RoomThemeType.eveningGlow => 'evening-glow',
  };
}

/// Returns the tab prefix used in file names.
String _tabPrefix(TabHeaderContext tab) {
  return switch (tab) {
    TabHeaderContext.learn => 'learn',
    TabHeaderContext.practice => 'practice',
    TabHeaderContext.smart => 'smart',
  };
}

/// Returns the asset path for a themed tab header image.
///
/// Every (theme, tab) combination has a path. If the file is missing at
/// runtime, the widget's [errorBuilder] shows the gradient fallback.
String headerAssetForTheme(RoomThemeType type, TabHeaderContext tab) {
  return 'assets/images/headers/${_tabPrefix(tab)}-header-${_themeSlug(type)}.webp';
}

// === GRADIENT FALLBACK ===

/// Derives a header gradient from the theme's existing background colours.
/// Used as loading placeholder and error fallback.
LinearGradient headerGradientForTheme(RoomThemeType type) {
  final theme = RoomTheme.fromType(type);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const [0.0, 0.45, 1.0],
    colors: [theme.background1, theme.background2, theme.background3],
  );
}

// === REUSABLE SLIVER HEADER WIDGET ===

/// A themed header image for tab screens (Learn, Practice, Smart).
///
/// Reads the current room theme via [roomThemeProvider] and displays the
/// matching header image with a gradient fallback and bottom fade-out.
///
/// Overlay widgets (badges, titles, hearts) are passed via [overlays] and
/// rendered on top of the image in a [Stack].
class ThemedTabHeader extends ConsumerWidget {
  /// Which tab this header belongs to.
  final TabHeaderContext tab;

  /// Header height in logical pixels.
  final double height;

  /// Widgets rendered on top of the header image (e.g. badges, titles).
  final List<Widget> overlays;

  const ThemedTabHeader({
    super.key,
    required this.tab,
    required this.height,
    this.overlays = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(roomThemeProvider);
    final assetPath = headerAssetForTheme(themeType, tab);
    final gradient = headerGradientForTheme(themeType);

    return SliverToBoxAdapter(
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.75, 1.0],
          colors: [Colors.white, Colors.transparent],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(gradient: gradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Themed header image
              Positioned.fill(
                child: ExcludeSemantics(
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    cacheWidth: 800,
                    cacheHeight: 480,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
              // Caller-provided overlays
              ...overlays,
            ],
          ),
        ),
      ),
    );
  }
}
