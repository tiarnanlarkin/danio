import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Scale: `xxs(2) → xs(4) → sm(8) → sm3(10) → md2(12) → sm4(14) → md(16) →
/// lg2(20) → lg(24) → xl(32) → xxl(48) → pill(100) → full(999)`
///
/// Mirrors the AppSpacing scale for predictable sizing.
class AppRadius {
  static const double xxs = 2;  // Progress bar corners, hairline rounding
  static const double xs = 4;
  static const double sm = 8;
  static const double sm3 = 10; // Between sm(8) and md2(12)
  static const double md2 = 12;
  static const double sm4 = 14; // Between md2(12) and md(16)
  static const double md = 16;
  static const double lg2 = 20; // Between md(16) and lg(24) — matches AppSpacing.lg2
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double pill = 100;
  static const double full = 999.0;

  static BorderRadius get xxsRadius => BorderRadius.circular(xxs);
  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smallRadius => BorderRadius.circular(sm);
  static BorderRadius get sm3Radius => BorderRadius.circular(sm3);
  static BorderRadius get md2Radius => BorderRadius.circular(md2);
  static BorderRadius get sm4Radius => BorderRadius.circular(sm4);
  static BorderRadius get mediumRadius => BorderRadius.circular(md);
  static BorderRadius get largeRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
  static BorderRadius get fullRadius => BorderRadius.circular(full);
}

/// Elevation scale and pre-built [BoxShadow] constants.
///
/// Use numeric levels for `Material.elevation` and `BoxShadow` constants for
/// custom `BoxDecoration`:
///
/// ```dart
/// elevation: AppElevation.level2         // 4dp — card
/// boxShadow: [AppElevation.sm]           // soft card shadow
/// boxShadow: [AppElevation.lg]           // prominent shadow
/// ```
class AppElevation {
  static const double level0 = 0;
  static const double level1 = 2;
  static const double level2 = 4;
  static const double level3 = 8;
  static const double level4 = 12;
  static const double level5 = 24;

  static const BoxShadow xs = BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 1),
    blurRadius: 2,
  );
  static const BoxShadow sm = BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 2),
    blurRadius: 4,
  );
  static const BoxShadow md = BoxShadow(
    color: Color(0x1E000000),
    offset: Offset(0, 4),
    blurRadius: 8,
  );
  static const BoxShadow lg = BoxShadow(
    color: Color(0x28000000),
    offset: Offset(0, 8),
    blurRadius: 16,
  );
}

/// Static [BoxDecoration] recipes for common card styles.
///
/// Use these when you need a styled container without the overhead of the full
/// [AppCard] widget. For interactive cards (tappable, variants, padding presets),
/// use `AppCard` from `lib/widgets/core/app_card.dart` instead.
///
/// ```dart
/// Container(
///   decoration: AppCardDecoration.elevated(context),
///   child: ...,
/// )
/// ```
abstract final class AppCardDecoration {
  /// Plain white card with a thin neutral border.
  ///
  /// Use for most list items and neutral content groupings.

  /// Returns a [BoxDecoration] for a standard white card with a thin border.
  static BoxDecoration standard(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(
      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
    ),
  );

  /// Returns a [BoxDecoration] for a card with a soft shadow (no border).
  static BoxDecoration elevated(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(AppRadius.md),
    boxShadow: [AppElevation.sm],
  );

  /// Returns a [BoxDecoration] for a transparent card with a visible border.
  static BoxDecoration outlined(BuildContext context) => BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(color: Theme.of(context).dividerColor),
  );
}

/// Pre-built [BoxShadow] lists for consistent depth and surface separation.
///
/// ```dart
/// decoration: BoxDecoration(boxShadow: AppShadows.soft)     // light, everyday cards
/// decoration: BoxDecoration(boxShadow: AppShadows.medium)   // modal cards
/// decoration: BoxDecoration(boxShadow: AppShadows.elevated) // bottom sheets, modals
/// decoration: BoxDecoration(boxShadow: AppShadows.glow)     // amber glow on CTAs
/// decoration: BoxDecoration(boxShadow: AppShadows.cozyWarm) // room/home elements
/// ```
class AppShadows {
  // Soft, subtle shadows for depth
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: AppOverlays.black5, // ~4%
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05000000), // 2%
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x0F000000), // 6%
      blurRadius: 15,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x08000000), // 3%
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x4DB45309), // Amber glow
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  // Additional shadow variants
  static const List<BoxShadow> elevated = [
    BoxShadow(color: AppOverlays.black15, blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: AppOverlays.black5, blurRadius: 48, offset: Offset(0, 16)),
  ];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x08000000), // 3%
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Premium soft shadows (inspired by high-end app designs)
  static const List<BoxShadow> dreamySoft = [
    BoxShadow(
      color: Color(0x0A000000), // 4%
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x05000000), // 2%
      blurRadius: 40,
      spreadRadius: 0,
      offset: Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> glassLight = [
    BoxShadow(
      color: Color(0x10FFFFFF), // White inner glow
      blurRadius: 1,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
    BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> glassDark = [
    BoxShadow(
      color: Color(0x20FFFFFF), // White inner glow
      blurRadius: 1,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
    BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  // Cozy warm shadow (for room/home elements)
  static const List<BoxShadow> cozyWarm = [
    BoxShadow(
      color: Color(0x15D4A574), // Warm gold tint
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
}



/// Custom page transition that slides+fades from right.
/// Applied globally via [pageTransitionsTheme] so all [MaterialPageRoute]
/// calls automatically get a consistent, polished transition.
